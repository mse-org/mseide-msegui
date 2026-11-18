unit msesoftsurface;
{ Software drawing on 32 bit memory surfaces.
  No OS and no library dependency, shared by the SDL and Wayland backends.

  Pixel format: one longword per pixel, $AARRGGBB (b,g,r,a in memory on a
  little endian machine) = SDL ARGB8888 = Wayland WL_SHM_FORMAT_ARGB8888.
  Colors given to the drawing functions are $00RRGGBB plus a separate alpha
  (0..255, 255 = opaque). Blending is "source over", the destination alpha
  is kept opaque when the destination is opaque.

  Clipping: every drawing function except softclear and softreadpixels is
  restricted to surf^.clip, which is always inside the surface. }
{$mode objfpc}{$h+}
{$R-}{$Q-}

interface

type
 softrectty = record
  x,y,cx,cy: integer;
 end;
 psoftrectty = ^softrectty;

 softsurfacety = record
  pixels: pointer;
  width,height: integer;
  pitch: integer;          //bytes per row
  owned: boolean;          //pixels were allocated by createsoftsurface
  clip: softrectty;
 end;
 psoftsurfacety = ^softsurfacety;

function softrect(const x,y,cx,cy: integer): softrectty;

//surfaces
function createsoftsurface(const w,h: integer): psoftsurfacety;
                                           //zero filled, nil if w or h <= 0
function wrapsoftsurface(const pixels: pointer;
                          const w,h,pitch: integer): psoftsurfacety;
                                           //does not own the pixels
procedure freesoftsurface(var surf: psoftsurfacety);
procedure softsetclip(const surf: psoftsurfacety; const rect: softrectty);
procedure softresetclip(const surf: psoftsurfacety);
procedure softresize(const surf: psoftsurfacety; const w,h: integer);
                          //owned surfaces only, keeps the overlapping content,
                          //new area is 0, the surface record stays the same,
                          //the clip is reset

//primitives
procedure softclear(const surf: psoftsurfacety; const color: longword);
                                           //whole surface, ignores the clip
procedure softfillrect(const surf: psoftsurfacety; const rect: softrectty;
                       const color: longword; const alpha: byte);
procedure softdrawpoint(const surf: psoftsurfacety; const x,y: integer;
                       const color: longword; const alpha: byte);
procedure softdrawline(const surf: psoftsurfacety; const x1,y1,x2,y2: integer;
                       const color: longword; const alpha: byte);

//copying
procedure softcopy(const dest: psoftsurfacety; const dx,dy: integer;
                   const src: psoftsurfacety; const srcrect: softrectty;
                   const blend: boolean);
                   //blend false: plain copy of the pixels including alpha,
                   //blend true: source over using the alpha of the source,
                   //dest and src may be the same surface (plain copy only)
procedure softcopyscaled(const dest: psoftsurfacety; const drect: softrectty;
                   const src: psoftsurfacety; const srect: softrectty;
                   const blend: boolean);
                   //nearest neighbour scaling of srect into drect, clipped,
                   //dest and src must be different surfaces
procedure softblendmask(const dest: psoftsurfacety; const dx,dy: integer;
                   const mask: pbyte; const w,h: integer;
                   const bottomup: boolean; const color: longword);
                   //8 bit alpha mask, w*h bytes, (dx,dy) = top left corner on
                   //the surface, bottomup: the first mask row is the bottom row
procedure softreadpixels(const surf: psoftsurfacety; const rect: softrectty;
                   const dest: pointer; const destpitch: integer);
                   //pixels outside of the surface are returned as 0

function softgetpixel(const surf: psoftsurfacety; const x,y: integer): longword;
                   //0 if outside of the surface

function softvalid(const surf: psoftsurfacety): boolean;
                   //true if surf is a live surface, all functions above
                   //ignore invalid (nil, freed) surfaces

implementation

const
 maxsurfacebytes = 1024*1024*1024;      //1 GB

var
 live: array of psoftsurfacety;         //all live surfaces, sorted by address
 livecount: integer;

function findlive(const surf: psoftsurfacety; out index: integer): boolean;
var
 lo,hi,mid: integer;
begin
 lo:= 0;
 hi:= livecount - 1;
 while lo <= hi do begin
  mid:= (lo + hi) div 2;
  if ptruint(live[mid]) = ptruint(surf) then begin
   index:= mid;
   result:= true;
   exit;
  end;
  if ptruint(live[mid]) < ptruint(surf) then begin
   lo:= mid + 1;
  end
  else begin
   hi:= mid - 1;
  end;
 end;
 index:= lo;                           //insert position
 result:= false;
end;

procedure addlive(const surf: psoftsurfacety);
var
 i: integer;
begin
 if not findlive(surf,i) then begin
  if livecount >= length(live) then begin
   setlength(live,livecount * 2 + 64);
  end;
  move(live[i],live[i + 1],(livecount - i) * sizeof(live[0]));
  live[i]:= surf;
  inc(livecount);
 end;
end;

procedure removelive(const surf: psoftsurfacety);
var
 i: integer;
begin
 if findlive(surf,i) then begin
  move(live[i + 1],live[i],(livecount - i - 1) * sizeof(live[0]));
  dec(livecount);
 end;
end;

function softvalid(const surf: psoftsurfacety): boolean;
var
 i: integer;
begin
 result:= (surf <> nil) and findlive(surf,i);
end;

function softrect(const x,y,cx,cy: integer): softrectty;
begin
 result.x:= x;
 result.y:= y;
 result.cx:= cx;
 result.cy:= cy;
end;

function intersectrect(const a,b: softrectty): softrectty;
var
 x1,y1,x2,y2: integer;
begin
 x1:= a.x;
 if b.x > x1 then begin
  x1:= b.x;
 end;
 y1:= a.y;
 if b.y > y1 then begin
  y1:= b.y;
 end;
 x2:= a.x + a.cx;
 if b.x + b.cx < x2 then begin
  x2:= b.x + b.cx;
 end;
 y2:= a.y + a.cy;
 if b.y + b.cy < y2 then begin
  y2:= b.y + b.cy;
 end;
 result.x:= x1;
 result.y:= y1;
 if x2 > x1 then begin
  result.cx:= x2 - x1;
 end
 else begin
  result.cx:= 0;
 end;
 if y2 > y1 then begin
  result.cy:= y2 - y1;
 end
 else begin
  result.cy:= 0;
 end;
end;

function pixelpo(const surf: psoftsurfacety; const x,y: integer): plongword;
begin
 result:= plongword(pbyte(surf^.pixels) + y*surf^.pitch + x*4);
end;

function blendpixel(const dst: longword; const color: longword;
                                         const alpha: cardinal): longword;
var
 ia,r,g,b,a: cardinal;
begin
 if alpha >= 255 then begin
  result:= $FF000000 or (color and $00FFFFFF);
  exit;
 end;
 if alpha = 0 then begin
  result:= dst;
  exit;
 end;
 ia:= 255 - alpha;
 r:= (((color shr 16) and $ff) * alpha + ((dst shr 16) and $ff) * ia + 127)
                                                                    div 255;
 g:= (((color shr 8) and $ff) * alpha + ((dst shr 8) and $ff) * ia + 127)
                                                                    div 255;
 b:= ((color and $ff) * alpha + (dst and $ff) * ia + 127) div 255;
 a:= alpha + (((dst shr 24) and $ff) * ia + 127) div 255;
 if a > 255 then begin
  a:= 255;
 end;
 result:= (a shl 24) or (r shl 16) or (g shl 8) or b;
end;

function createsoftsurface(const w,h: integer): psoftsurfacety;
begin
 result:= nil;
 if (w <= 0) or (h <= 0) or (int64(w) * h * 4 > maxsurfacebytes) then begin
  exit;                      //empty or absurdly large, 32 bit overflow
 end;
 new(result);
 addlive(result);
 result^.width:= w;
 result^.height:= h;
 result^.pitch:= w * 4;
 result^.owned:= true;
 getmem(result^.pixels,result^.pitch * h);
 fillchar(result^.pixels^,result^.pitch * h,0);
 softresetclip(result);
end;

function wrapsoftsurface(const pixels: pointer;
                          const w,h,pitch: integer): psoftsurfacety;
begin
 result:= nil;
 if (pixels = nil) or (w <= 0) or (h <= 0) or (pitch < w * 4) then begin
  exit;
 end;
 new(result);
 addlive(result);
 result^.pixels:= pixels;
 result^.width:= w;
 result^.height:= h;
 result^.pitch:= pitch;
 result^.owned:= false;
 softresetclip(result);
end;

procedure freesoftsurface(var surf: psoftsurfacety);
begin
 if softvalid(surf) then begin
  removelive(surf);
  if surf^.owned and (surf^.pixels <> nil) then begin
   freemem(surf^.pixels);
  end;
  dispose(surf);
  surf:= nil;
 end;
end;

procedure softsetclip(const surf: psoftsurfacety; const rect: softrectty);
begin
 if not softvalid(surf) then begin
  exit;
 end;
 surf^.clip:= intersectrect(rect,softrect(0,0,surf^.width,surf^.height));
end;

procedure softresetclip(const surf: psoftsurfacety);
begin
 if not softvalid(surf) then begin
  exit;
 end;
 surf^.clip:= softrect(0,0,surf^.width,surf^.height);
end;

procedure softresize(const surf: psoftsurfacety; const w,h: integer);
var
 newpix: pointer;
 newpitch,y,cw,ch: integer;
begin
 if not softvalid(surf) or not surf^.owned or (w <= 0) or (h <= 0) or
            ((w = surf^.width) and (h = surf^.height)) or
                          (int64(w) * h * 4 > maxsurfacebytes) then begin
  exit;
 end;
 newpitch:= w * 4;
 getmem(newpix,newpitch * h);
 fillchar(newpix^,newpitch * h,0);
 cw:= w;
 if surf^.width < cw then begin
  cw:= surf^.width;
 end;
 ch:= h;
 if surf^.height < ch then begin
  ch:= surf^.height;
 end;
 for y:= 0 to ch - 1 do begin
  move(pixelpo(surf,0,y)^,(pbyte(newpix) + y * newpitch)^,cw * 4);
 end;
 freemem(surf^.pixels);
 surf^.pixels:= newpix;
 surf^.width:= w;
 surf^.height:= h;
 surf^.pitch:= newpitch;
 softresetclip(surf);
end;

procedure softclear(const surf: psoftsurfacety; const color: longword);
var
 y: integer;
 value: longword;
begin
 if not softvalid(surf) then begin
  exit;
 end;
 value:= $FF000000 or (color and $00FFFFFF);
 for y:= 0 to surf^.height - 1 do begin
  filldword(pixelpo(surf,0,y)^,surf^.width,value);
 end;
end;

procedure softfillrect(const surf: psoftsurfacety; const rect: softrectty;
                       const color: longword; const alpha: byte);
var
 r: softrectty;
 x,y: integer;
 po: plongword;
 value: longword;
begin
 if (alpha = 0) or not softvalid(surf) then begin
  exit;
 end;
 r:= intersectrect(rect,surf^.clip);
 if (r.cx <= 0) or (r.cy <= 0) then begin
  exit;
 end;
 if alpha = 255 then begin
  value:= $FF000000 or (color and $00FFFFFF);
  for y:= r.y to r.y + r.cy - 1 do begin
   filldword(pixelpo(surf,r.x,y)^,r.cx,value);
  end;
 end
 else begin
  for y:= r.y to r.y + r.cy - 1 do begin
   po:= pixelpo(surf,r.x,y);
   for x:= 1 to r.cx do begin
    po^:= blendpixel(po^,color,alpha);
    inc(po);
   end;
  end;
 end;
end;

procedure softdrawpoint(const surf: psoftsurfacety; const x,y: integer;
                       const color: longword; const alpha: byte);
var
 po: plongword;
begin
 if (alpha = 0) or not softvalid(surf) or (x < surf^.clip.x) or (y < surf^.clip.y) or
          (x >= surf^.clip.x + surf^.clip.cx) or
          (y >= surf^.clip.y + surf^.clip.cy) then begin
  exit;
 end;
 po:= pixelpo(surf,x,y);
 po^:= blendpixel(po^,color,alpha);
end;

procedure softdrawline(const surf: psoftsurfacety; const x1,y1,x2,y2: integer;
                       const color: longword; const alpha: byte);
var
 ax,ay,bx,by: integer;
 dx,dy,sx,sy,err,e2: integer;
begin
 ax:= x1;
 ay:= y1;
 bx:= x2;
 by:= y2;
 if ay = by then begin                //horizontal
  if ax > bx then begin
   dx:= ax;
   ax:= bx;
   bx:= dx;
  end;
  softfillrect(surf,softrect(ax,ay,bx - ax + 1,1),color,alpha);
  exit;
 end;
 if ax = bx then begin                //vertical
  if ay > by then begin
   dy:= ay;
   ay:= by;
   by:= dy;
  end;
  softfillrect(surf,softrect(ax,ay,1,by - ay + 1),color,alpha);
  exit;
 end;
 dx:= abs(bx - ax);
 dy:= -abs(by - ay);
 if ax < bx then begin
  sx:= 1;
 end
 else begin
  sx:= -1;
 end;
 if ay < by then begin
  sy:= 1;
 end
 else begin
  sy:= -1;
 end;
 err:= dx + dy;
 while true do begin
  softdrawpoint(surf,ax,ay,color,alpha);
  if (ax = bx) and (ay = by) then begin
   break;
  end;
  e2:= 2 * err;
  if e2 >= dy then begin
   err:= err + dy;
   ax:= ax + sx;
  end;
  if e2 <= dx then begin
   err:= err + dx;
   ay:= ay + sy;
  end;
 end;
end;

procedure softcopy(const dest: psoftsurfacety; const dx,dy: integer;
                   const src: psoftsurfacety; const srcrect: softrectty;
                   const blend: boolean);
var
 sr,dr: softrectty;
 ddx,ddy,ox,oy,y,x,y0,y1,ystep: integer;
 sp,dp: plongword;
 s: longword;
begin
 if not softvalid(dest) or not softvalid(src) then begin
  exit;
 end;
 //source rectangle inside of the source surface
 sr:= intersectrect(srcrect,softrect(0,0,src^.width,src^.height));
 if (sr.cx <= 0) or (sr.cy <= 0) then begin
  exit;
 end;
 ddx:= dx + (sr.x - srcrect.x);
 ddy:= dy + (sr.y - srcrect.y);
 //destination rectangle inside of the destination clip
 dr:= intersectrect(softrect(ddx,ddy,sr.cx,sr.cy),dest^.clip);
 if (dr.cx <= 0) or (dr.cy <= 0) then begin
  exit;
 end;
 ox:= dr.x - ddx;
 oy:= dr.y - ddy;
 sr.x:= sr.x + ox;
 sr.y:= sr.y + oy;
 sr.cx:= dr.cx;
 sr.cy:= dr.cy;
 //row order, bottom up if the surfaces are the same and the rows overlap
 if (dest = src) and (dr.y > sr.y) then begin
  y0:= dr.cy - 1;
  y1:= 0;
  ystep:= -1;
 end
 else begin
  y0:= 0;
  y1:= dr.cy - 1;
  ystep:= 1;
 end;
 y:= y0;
 while true do begin
  sp:= pixelpo(src,sr.x,sr.y + y);
  dp:= pixelpo(dest,dr.x,dr.y + y);
  if blend then begin
   for x:= 1 to dr.cx do begin
    s:= sp^;
    if (s shr 24) = 255 then begin
     dp^:= s;
    end
    else begin
     if (s shr 24) <> 0 then begin
      dp^:= blendpixel(dp^,s and $00FFFFFF,s shr 24);
     end;
    end;
    inc(sp);
    inc(dp);
   end;
  end
  else begin
   move(sp^,dp^,dr.cx * 4);       //move handles overlapping memory
  end;
  if y = y1 then begin
   break;
  end;
  y:= y + ystep;
 end;
end;

procedure softcopyscaled(const dest: psoftsurfacety; const drect: softrectty;
                   const src: psoftsurfacety; const srect: softrectty;
                   const blend: boolean);
var
 vis: softrectty;
 x,y,sx,sy: integer;
 dp: plongword;
 s: longword;
begin
 if (drect.cx <= 0) or (drect.cy <= 0) or (srect.cx <= 0) or
          (srect.cy <= 0) or not softvalid(dest) or not softvalid(src) then begin
  exit;
 end;
 vis:= intersectrect(drect,dest^.clip);
 if (vis.cx <= 0) or (vis.cy <= 0) then begin
  exit;
 end;
 for y:= vis.y to vis.y + vis.cy - 1 do begin
  sy:= srect.y + integer(((int64(2) * (y - drect.y) + 1) * srect.cy) div
                                                       (int64(2) * drect.cy));
  if (sy >= 0) and (sy < src^.height) then begin
   dp:= pixelpo(dest,vis.x,y);
   for x:= vis.x to vis.x + vis.cx - 1 do begin
    sx:= srect.x + integer(((int64(2) * (x - drect.x) + 1) * srect.cx) div
                                                       (int64(2) * drect.cx));
    if (sx >= 0) and (sx < src^.width) then begin
     s:= pixelpo(src,sx,sy)^;
     if blend then begin
      if (s shr 24) = 255 then begin
       dp^:= s;
      end
      else begin
       if (s shr 24) <> 0 then begin
        dp^:= blendpixel(dp^,s and $00FFFFFF,s shr 24);
       end;
      end;
     end
     else begin
      dp^:= s;
     end;
    end;
    inc(dp);
   end;
  end;
 end;
end;

procedure softblendmask(const dest: psoftsurfacety; const dx,dy: integer;
                   const mask: pbyte; const w,h: integer;
                   const bottomup: boolean; const color: longword);
var
 r: softrectty;
 x,y,my: integer;
 mp: pbyte;
 dp: plongword;
 a: cardinal;
begin
 if (mask = nil) or (w <= 0) or (h <= 0) or not softvalid(dest) then begin
  exit;
 end;
 r:= intersectrect(softrect(dx,dy,w,h),dest^.clip);
 if (r.cx <= 0) or (r.cy <= 0) then begin
  exit;
 end;
 for y:= r.y to r.y + r.cy - 1 do begin
  my:= y - dy;                         //row on the screen side, 0 = top
  if bottomup then begin
   my:= h - 1 - my;
  end;
  mp:= mask + my * w + (r.x - dx);
  dp:= pixelpo(dest,r.x,y);
  for x:= 1 to r.cx do begin
   a:= mp^;
   if a = 255 then begin
    dp^:= $FF000000 or (color and $00FFFFFF);
   end
   else begin
    if a <> 0 then begin
     dp^:= blendpixel(dp^,color,a);
    end;
   end;
   inc(mp);
   inc(dp);
  end;
 end;
end;

procedure softreadpixels(const surf: psoftsurfacety; const rect: softrectty;
                   const dest: pointer; const destpitch: integer);
var
 r: softrectty;
 y: integer;
 row: pbyte;
begin
 if (rect.cx <= 0) or (rect.cy <= 0) or not softvalid(surf) then begin
  exit;
 end;
 r:= intersectrect(rect,softrect(0,0,surf^.width,surf^.height));
 for y:= 0 to rect.cy - 1 do begin
  row:= pbyte(dest) + y * destpitch;
  fillchar(row^,rect.cx * 4,0);
  if (r.cx > 0) and (rect.y + y >= r.y) and (rect.y + y < r.y + r.cy) then begin
   move(pixelpo(surf,r.x,rect.y + y)^,(row + (r.x - rect.x) * 4)^,r.cx * 4);
  end;
 end;
end;

function softgetpixel(const surf: psoftsurfacety; const x,y: integer): longword;
begin
 if not softvalid(surf) or (x < 0) or (y < 0) or (x >= surf^.width) or
                                                (y >= surf^.height) then begin
  result:= 0;
 end
 else begin
  result:= pixelpo(surf,x,y)^;
 end;
end;

end.
