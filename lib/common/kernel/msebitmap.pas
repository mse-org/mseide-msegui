{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msebitmap;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 {$ifdef FPC}classes{$else}Classes{$endif},msegraphics,msetypes,msestrings,
 msegraphutils,mseclasses,mseglob,sysutils;

const
 defaultimagelistwidth = 16;
 defaultimagelistheight = 16;
 defaultimagelistsize: sizety = (cx: defaultimagelistwidth; cy: defaultimagelistheight);

type

 imagebufferinfoty = record
  image: imagety;
  mask: imagety;
 end;
 
 tbitmapcomp = class;

 tbitmap = class(tsimplebitmap)
  private
   fimage: imagety;
   fonchange: notifyeventty;
   falignment: alignmentsty;
   ftransparency: colorty;
   fnochange: integer;
//   procedure setmonochrome(const Value: boolean);
   function getscanline(index: integer): pointer;
   procedure checkimage;
   procedure getimage;
   procedure putimage;
   procedure allocimagemem;
   function getpixel(const index: pointty): colorty;
   procedure setpixel(const index: pointty; const value: colorty);
   function getpixels(const x,y: integer): colorty;
   procedure setpixels(const x,y: integer; const value: colorty);
   function checkindex(const index: pointty): integer; overload;
   function checkindex(const x,y: integer): integer; overload;
   procedure setalignment(const Value: alignmentsty);
   procedure settransparency(avalue: colorty);
   procedure updatealignment(const dest,source: rectty;
               const alignment: alignmentsty; out newdest,newsource: rectty;
               out tileorigin: pointty);
   procedure setcolorbackground(const Value: colorty);
   procedure setcolorforeground(const Value: colorty);
  protected
   procedure setsize(const Value: sizety); override;
   function getasize: sizety; virtual;
   procedure destroyhandle; override;
   procedure createhandle(copyfrom: pixmapty); override;
   function getimagepo: pimagety; override;
   function getsource: tbitmapcomp; virtual;
   procedure assign1(const source: tsimplebitmap; const docopy: boolean); override; 
                    //calls change
   procedure dochange; virtual;
  public
   constructor create(amonochrome: boolean);

   procedure savetoimage(out aimage: imagety);
   procedure loadfromimage(const aimage: imagety);
   procedure assign(source: tpersistent); override;
   procedure change;
   procedure beginupdate;
   procedure endupdate;
   procedure loaddata(const asize: sizety; data: pbyte;
             msbitfirst: boolean = false; dwordaligned: boolean = false;
             bottomup: boolean = false); virtual; //calls change
   function hasimage: boolean;
   procedure paint(const acanvas: tcanvas; const dest: rectty;
                   const asource: rectty; const aalignment: alignmentsty = [];
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default;
                      //used for monochrome bitmaps,
                      //cl_default-> acanvas.color, acanvas.colorbackground
                         const atransparency: colorty = cl_default
                      //cl_default-> self.transparency
                   );
                           overload;
   procedure paint(const acanvas: tcanvas; const dest: pointty;
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default); overload;
                 //useses self.size and self.alignment
   procedure paint(const acanvas: tcanvas; const dest: pointty;
                          const aalignment: alignmentsty;
                          const acolorforeground: colorty = cl_default;
                          const acolorbackground: colorty = cl_default); overload;
                 //useses self.size
   procedure paint(const acanvas: tcanvas; const dest: rectty;
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default); overload;
                 //useses self.size and self.alignment
   procedure paint(const acanvas: tcanvas; const dest: rectty;
                          const aalignment: alignmentsty;
                          const acolorforeground: colorty = cl_default;
                          const acolorbackground: colorty = cl_default); overload;
                 //useses self.size

   procedure init(const acolor: colorty); override;
   function compressdata: cardinalarty;
   procedure decompressdata(const asize: sizety; const adata: cardinalarty);
   property pixel[const index: pointty]: colorty read getpixel write setpixel;
   property pixels[const x,y: integer]: colorty read getpixels write setpixels;
   property scanline[index: integer]: pointer read getscanline;
   function scanhigh: integer; //max index in scanline[0]
   property colorforeground: colorty read fcolorforeground write setcolorforeground default cl_black;
                 //used for monochrome -> color conversion
   property colorbackground: colorty read fcolorbackground write setcolorbackground default cl_white;
                 //used for monochrome -> color conversion,
                 //colorbackground for color -> monochrome conversion
   property alignment: alignmentsty read falignment write setalignment default [];
   property transparency: colorty read ftransparency write settransparency default cl_none;
   property onchange: notifyeventty read fonchange write fonchange;
 end;

 imageformatty = (imfor_default);
 imageinfoty = (iminf_monochrome,iminf_masked,iminf_colormask);
 imageinfosty = set of imageinfoty;
 imageheaderty = packed record
  format: cardinal; //imageformatty;
  info: cardinal;   //imageinfosty;
  width: integer;
  height: integer;
  datasize: integer;
  reserve: array[0..7] of cardinal;
 end;

 bitmapoptionty = (bmo_monochrome,bmo_masked,bmo_colormask);
 bitmapoptionsty = set of bitmapoptionty;

 tmaskedbitmap = class(tbitmap,iobjectlink)
  private
   ftransparentcolor: colorty;
   fsource: tbitmapcomp;
   fobjectlinker: tobjectlinker;
   foptions: bitmapoptionsty;
   fmaskcolorforeground,fmaskcolorbackground: colorty;
   procedure checkmask;
   procedure freemask;
   procedure settransparentcolor(const Value: colorty);
   procedure setmask(const Value: tbitmap);
   function getobjectlinker: tobjectlinker;
   procedure setsource(const Value: tbitmapcomp);
   function getmasked: boolean;
   procedure setmasked(const Value: boolean);
   procedure readimage(stream: tstream);
   procedure writeimage(stream: tstream);
   function getmask1: tbitmap;
   function getoptions: bitmapoptionsty;
   procedure setoptions(const avalue: bitmapoptionsty);
   function getcolormask: boolean;
   procedure setcolormask(const avalue: boolean);
  protected
   fmask: tbitmap;
   procedure setmonochrome(const avalue: boolean); override;
   function getasize: sizety; override;
   procedure createmask(const acolormask: boolean); virtual;
   function getconverttomonochromecolorbackground: colorty; override;
   procedure releasehandle; override;
   procedure acquirehandle; override;
   procedure destroyhandle; override;
   procedure setsize(const Value: sizety); override;
   function writedata(const ancestor: tmaskedbitmap): boolean;
   procedure defineproperties(filer: tfiler); override;
   procedure objectevent(const sender: tobject; const event: objecteventty);
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                      ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
   function getmask: tsimplebitmap; override;
   function getsource: tbitmapcomp; override;
   procedure assign1(const source: tsimplebitmap; const docopy: boolean); override;
  public
   constructor create(amonochrome: boolean);
   destructor destroy; override;
   class procedure freeimageinfo(var ainfo: imagebufferinfoty);
   procedure loadfromimagebuffer(const abuffer: imagebufferinfoty);
   procedure savetoimagebuffer(out abuffer: imagebufferinfoty);
   
   procedure initmask;
   procedure stretch(const dest: tmaskedbitmap);
   procedure remask; //recalc mask
   procedure automask; //transparentcolor is bottomright pixel
   procedure loadfromstring(const avalue: string; const format: string = '';
                               const index: integer = -1);
   procedure loadfromstream(const stream: tstream; const format: string = '';
                               const index: integer = -1); //index in ico
   procedure loadfromfile(const filename: filenamety; const format: string = '';
                               const index: integer = -1); //index in ico
//   procedure loadfromresourcename(instance: cardinal; const resname: string);
//   procedure readimagefile(const filename: filenamety); //calls change
   property mask: tbitmap read getmask1 write setmask;
   property masked: boolean read getmasked write setmasked default false;
   property colormask: boolean read getcolormask write setcolormask default false;
   property maskcolorforeground: colorty read fmaskcolorforeground 
                    write fmaskcolorforeground default $ffffff;
                    //used to init colormask
   property maskcolorbackground: colorty read fmaskcolorbackground 
                    write fmaskcolorbackground default $000000; //max transparent
                     //used to convert monchrome mask to colormask
  published
   property transparentcolor: colorty read ftransparentcolor write settransparentcolor
                default cl_default; //cl_default ->bottom right pixel
   property options: bitmapoptionsty read getoptions write setoptions default [];
   property source: tbitmapcomp read fsource write setsource;
   property colorforeground;
   property colorbackground;
   property alignment;
   property transparency;
 end;

 tbitmapcomp = class(tmsecomponent)
  private
   fbitmap: tmaskedbitmap;
   fonchange: notifyeventty;
   procedure setbitmap(const Value: tmaskedbitmap);
   procedure change(const sender: tobject);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property bitmap: tmaskedbitmap read fbitmap write setbitmap;
   property onchange: notifyeventty read fonchange write fonchange;
 end;

 timagelist = class(tmsecomponent)
  private
   fsize: sizety;
   fcolcount,frowcount: integer;
   fbitmap: tmaskedbitmap;
   fcount: integer;
   fupdating: integer;
   fonchange: notifyeventty;
   procedure setsize(const avalue: sizety);
   function getmonochrome: boolean;
   procedure setmonochrome(const Value: boolean);
   procedure setcount(const Value: integer);
   function getmasked: boolean;
   procedure setmasked(const Value: boolean);
   function gettransparentcolor: colorty;
   procedure settransparentcolor(avalue: colorty);
   procedure setheight(const Value: integer);
   procedure setwidth(const Value: integer);
   procedure setbitmap(const Value: tmaskedbitmap);
   procedure copyimages(const image: tmaskedbitmap; const destindex: integer);
   function getcolormask: boolean;
   procedure setcolormask(const avalue: boolean);
  protected
   function indextoorg(index: integer): pointty;
   procedure change;
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   procedure beginupdate;
   procedure endupdate;

   procedure clear;
   procedure deleteimage(const index: integer);
   procedure moveimage(const fromindex: integer; const toindex: integer);
   procedure setimage(index: integer; image: tmaskedbitmap; const source: rectty); overload;
   procedure setimage(index: integer; image: tmaskedbitmap); overload;
   procedure getimage(const index: integer; const dest: tmaskedbitmap);
   function addimage(const image: tmaskedbitmap; 
                              const stretch: boolean = false): integer;

   procedure paint(const acanvas: tcanvas; const index: integer;
                   const dest: pointty; const acolor: colorty = cl_default
               //used for monochrome bitmaps, cl_default-> acanvas.color
            ); overload;
   procedure paint(const acanvas: tcanvas; const index: integer;
                   const dest: rectty; const alignment: alignmentsty = [];
                   const acolor: colorty = cl_default
               //used for monochrome bitmaps, cl_default-> acanvas.color
            ); overload;
   procedure assign(sender: tpersistent); override;

   property size: sizety read fsize write setsize;
   property bitmap: tmaskedbitmap read fbitmap write setbitmap;

  published
   property monochrome: boolean read getmonochrome 
                write setmonochrome default false;
   property width: integer read fsize.cx 
                 write setwidth default defaultimagelistwidth;
   property height: integer read fsize.cy 
                   write setheight default defaultimagelistheight;
   property masked: boolean read getmasked write setmasked default true;
   property colormask: boolean read getcolormask write setcolormask default false;
   property transparentcolor: colorty read gettransparentcolor 
                         write settransparentcolor default cl_none;
   property count: integer read fcount write setcount default 0;
                 //last!
   property onchange: notifyeventty read fonchange write fonchange;
 end;

 tformatstream = class
  private
   fstream: tstream;
   fformatname: string;
   fseekpos: integer;
   procedure setpos(const Value: integer);
  public
   constructor create(stream: tstream; formatname: string);
   procedure formaterror;
   procedure read(var dest; count: integer);
   procedure seek(count: integer);
   procedure resetpos(apos: integer = 0);
   property pos: integer read fseekpos write setpos;
 end;

implementation
uses
 mseguiintf,msebits,msestream,mseevent,msesys,msedatalist,msegraphicstream;

type
 tsimplebitmap1 = class(tsimplebitmap);
 tcanvas1 = class(tcanvas);
 twriter1 = class(twriter);
type
 tbitmap1 = class(tbitmap);

{ tformatstream }

constructor tformatstream.create(stream: tstream; formatname: string);
begin
 fstream:= stream;
 fformatname:= formatname;
end;                                  

procedure tformatstream.formaterror;
begin
 raise egraphicformat.create('Invalid file format '+fformatname);
end;

procedure tformatstream.read(var dest; count: integer);
begin
 inc(fseekpos,count);
 fstream.read(dest,count);
end;

procedure tformatstream.resetpos(apos: integer);
begin
 fseekpos:= apos;
end;

procedure tformatstream.seek(count: integer);
begin
 inc(fseekpos,count);
 fstream.seek(count,sofromcurrent);
end;

procedure tformatstream.setpos(const Value: integer);
begin
 seek(value-fseekpos);
end;

{ tbitmap }

constructor tbitmap.create(amonochrome: boolean);
begin
 ftransparency:= cl_none;
 inherited;
end;

procedure tbitmap.assign1(const source: tsimplebitmap; const docopy: boolean);
begin
 if source is tbitmap then begin
  with tbitmap(source) do begin
   if fimage.pixels <> nil then begin
    self.clear;
    self.fimage:= fimage;
    self.fimage.pixels:= gui_allocimagemem(fimage.length);
    move(fimage.pixels^,self.fimage.pixels^,fimage.length*sizeof(cardinal));
    self.fsize:= fimage.size;
    if monochrome then begin
     include(self.fstate,pms_monochrome);
    end
    else begin
     exclude(self.fstate,pms_monochrome);
    end;
   end
   else begin
    inherited;
   end;
  end;
 end
 else begin
  inherited;
 end;
 change;
end;

procedure tbitmap.loaddata(const asize: sizety; data: pbyte;
             msbitfirst: boolean = false; dwordaligned: boolean = false;
             bottomup: boolean = false);
begin
 if not monochrome then begin
  gdierror(gde_notmonochrome,self);
 end;
 destroyhandle;
 fsize:= asize;
 gdi_lock;
 fhandle:= gui_createbitmapfromdata(asize,data,msbitfirst,dwordaligned,bottomup);
 gdi_unlock;
 if fhandle = 0 then begin
  gdierror(gde_pixmap);
 end;
 creategc;
 change;
end;

procedure tbitmap.paint(const acanvas: tcanvas; const dest: rectty;
                  const asource: rectty; const aalignment: alignmentsty = [];
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default;
                         const atransparency: colorty = cl_default);
var
 bmp: tbitmap;
 sourcebmp: tbitmapcomp;
 amask: tsimplebitmap;
// maskpx: pixmapty;
// maskgchandle: cardinal;
 rect1,rect2: rectty;
 po1: pointty;
 col1,col2: colorty;
 transp: colorty;
 canvas2: tcanvas;
 bmp1: tmaskedbitmap;
 po2: prgbtripleaty;
 int1,int2: integer;
begin
 if atransparency = cl_default then begin
  transp:= transparency;
 end
 else begin
  transp:= atransparency;
 end;
 sourcebmp:= getsource;
 if sourcebmp <> nil then begin
  bmp:= sourcebmp.fbitmap;
 end
 else begin
  bmp:= self;
 end;
 with bmp do begin
  if not isempty then begin
   updatealignment(dest,asource,aalignment,rect1,rect2,po1);
   amask:= getmask;
//   maskpx:= getmaskhandle(maskgchandle);
   if (al_grayed in aalignment) and ((amask <> nil) or monochrome) then begin
    if (amask <> nil) and not amask.monochrome then begin
                     //reduced contrast grayscale
     bmp1:= tmaskedbitmap.create(false);
     bmp1.colormask:= true;
     bmp1.size:= rect2.size;
     bmp1.canvas.copyarea(canvas,rect2,nullpoint);
     bmp1.mask.canvas.copyarea(amask.canvas,rect2,nullpoint);
     po2:= bmp1.scanline[0];
     for int1:= bmp1.scanhigh downto 0 do begin
      with po2^[int1] do begin
       int2:= (red+green+blue) div 8 + $80;
       red:= int2;
       green:= int2;
       blue:= int2;
      end;
     end;
     rect2.pos:= nullpoint;
     tcanvas1(acanvas).internalcopyarea(bmp1.canvas,rect2,
               rect1,acanvas.rasterop,cl_default,bmp1.mask,aalignment,po1,transp);
     bmp1.free;     
    end
    else begin //shaddowed mask
     if monochrome then begin
      canvas2:= canvas;
     end
     else begin
      canvas2:= amask.canvas;
     end;
     with acanvas do begin
      col1:= colorbackground;
      col2:= color;
      colorbackground:= cl_transparent;
      color:= cl_white;
 //     copyarea(canvas2,rect2,addpoint(rect1.pos,makepoint(1,1)),acanvas.rasterop);
      inc(rect1.x);
      inc(rect1.y);
      inc(po1.x);
      inc(po1.y);
      tcanvas1(acanvas).internalcopyarea(canvas2,rect2,
                rect1,acanvas.rasterop,cl_default,amask{maskpx,maskgchandle},aalignment,po1,transp);
      color:= cl_dkgray;
 //     copyarea(canvas2,rect2,rect1.pos,acanvas.rasterop);
      dec(rect1.x);
      dec(rect1.y);
      dec(po1.x);
      dec(po1.y);
      tcanvas1(acanvas).internalcopyarea(canvas2,rect2,
                rect1,acanvas.rasterop,cl_default,amask{maskpx,maskgchandle},aalignment,po1,transp);
      color:= col2;
      colorbackground:= col1;
     end;
    end;
   end
   else begin
    if monochrome then begin
     col1:= acanvas.color;
     col2:= acanvas.colorbackground;
     if acolorforeground <> cl_default then begin
      acanvas.color:= acolorforeground;
     end
     else begin
      acanvas.color:= fcolorforeground;
     end;
     if acolorbackground <> cl_default then begin
      acanvas.colorbackground:= acolorbackground;
     end
     else begin
      acanvas.colorbackground:= fcolorbackground;
     end;
     tcanvas1(acanvas).internalcopyarea(bmp.canvas,rect2,
               rect1,acanvas.rasterop,cl_default,amask,aalignment,po1,transp);
     acanvas.color:= col1;
     acanvas.colorbackground:= col2;
    end
    else begin
     tcanvas1(acanvas).internalcopyarea(bmp.canvas,rect2,
               rect1,acanvas.rasterop,cl_default,amask,aalignment,po1,transp);
    end;
   end;
  end;
 end;
end;

procedure tbitmap.paint(const acanvas: tcanvas; const dest: rectty;
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default);
begin
 with tcanvas1(canvas).fvaluepo^.origin do begin
  paint(acanvas,dest,makerect(makepoint(-x,-y),getasize),falignment,
               acolorforeground,acolorbackground);
 end;
end;

procedure tbitmap.paint(const acanvas: tcanvas; const dest: rectty;
                         const aalignment: alignmentsty;
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default);
begin
 with tcanvas1(canvas).fvaluepo^.origin do begin
  paint(acanvas,dest,makerect(makepoint(-x,-y),getasize),aalignment,
               acolorforeground,acolorbackground);
 end;
end;

procedure tbitmap.paint(const acanvas: tcanvas; const dest: pointty;
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default);
begin
 with tcanvas1(canvas).fvaluepo^.origin do begin
  paint(acanvas,makerect(dest,fsize),makerect(makepoint(-x,-y),getasize),
            falignment,acolorforeground,acolorbackground);
 end;
end;

procedure tbitmap.paint(const acanvas: tcanvas; const dest: pointty;
                         const aalignment: alignmentsty;
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default);
begin
 with tcanvas1(canvas).fvaluepo^.origin do begin
  paint(acanvas,makerect(dest,getasize),makerect(makepoint(-x,-y),getasize),
            aalignment,acolorforeground,acolorbackground);
 end;
end;

procedure tbitmap.init(const acolor: colorty);
var
 rgb: cardinal;
 by1: byte;
 int1: integer;
begin
 if fimage.pixels = nil then begin
  inherited;
 end
 else begin
  rgb:= colortopixel(normalizeinitcolor(acolor));
  if monochrome then begin
   if odd(rgb) then begin
    by1:= $ff;
   end
   else begin
    by1:= $00;
   end;
   fillchar(fimage.pixels^,fimage.length*sizeof(cardinal),by1);
  end
  else begin
   for int1:= 0 to fimage.length-1 do begin
    fimage.pixels^[int1]:= rgb;
   end;
  end;
 end;
end;

procedure tbitmap.allocimagemem;
begin
 if fimage.monochrome then begin
  fimage.length:= ((fsize.cx+31) div 32) * fsize.cy;
 end
 else begin
  fimage.length:= fsize.cx * fsize.cy;
 end;
 if fimage.length > 0 then begin
  fimage.pixels:= gui_allocimagemem(fimage.length);
 end
 else begin
  fimage.pixels:= nil;
 end;
end;

procedure tbitmap.getimage;
begin
 if fhandle <> 0 then begin
  gdi_lock;
  if fcanvas <> nil then begin
   gdierrorlocked(gui_pixmaptoimage(fhandle,fimage,
                           tcanvas1(fcanvas).fdrawinfo.gc.handle));
  end
  else begin
   gdierrorlocked(gui_pixmaptoimage(fhandle,fimage,0));
  end;
 end
 else begin
  fimage.size:= fsize;
  fimage.monochrome:= monochrome;
  allocimagemem;
 end;
end;

procedure tbitmap.checkimage;
begin
 if fimage.pixels = nil then begin
  getimage;
  internaldestroyhandle;
 end;
end;

procedure tbitmap.putimage;
var
 pixmap: pixmapty;
 ca1: cardinal;
begin
 if fcanvas <> nil then begin
  ca1:= tcanvas1(fcanvas).fdrawinfo.gc.handle;
 end
 else begin
  ca1:= 0;
 end;
 gdi_lock;
 if gui_imagetopixmap(fimage,pixmap,ca1) = gde_ok then begin
  handle:= pixmap;
  include(fstate,pms_ownshandle);
 end;
 gdi_unlock;
end;

function tbitmap.checkindex(const index: pointty): integer;
begin
 if (index.x < 0) or (index.y < 0) or
     (index.x >= fsize.cx) or (index.y >= fsize.cy) then begin
  gdierror(gde_invalidindex,self);
 end;
 if monochrome then begin
  result:= index.y * ((fimage.size.cx + 31) div 32) + index.x div 32;
 end
 else begin
  result:= index.y*fimage.size.cx + index.x;
 end;
end;

function tbitmap.checkindex(const x,y: integer): integer;
begin
 if (x < 0) or (y < 0) or
     (x >= fsize.cx) or (y >= fsize.cy) then begin
  gdierror(gde_invalidindex,self);
 end;
 if monochrome then begin
  result:= y * ((fimage.size.cx + 31) div 32) + x div 32;
 end
 else begin
  result:= y * fimage.size.cx + x;
 end;
end;

function tbitmap.getscanline(index: integer): pointer;
begin
 checkimage;
 result:= @fimage.pixels[checkindex(makepoint(0,index))];
end;

function tbitmap.getpixel(const index: pointty): colorty;
var
 int1: integer;
begin
 int1:= checkindex(index);
 checkimage;
 if monochrome then begin
  if fimage.pixels^[int1] and bits[index.x and $1f] <> 0 then begin
   result:= cl_1;
  end
  else begin
   result:= cl_0;
  end;
 end
 else begin
 {$ifdef FPC}{$checkpointer off}{$endif} //not on heap in win32
  result:= fimage.pixels^[int1] and $ffffff;
 {$ifdef FPC}{$checkpointer default}{$endif}
 end;
end;

procedure tbitmap.setpixel(const index: pointty; const value: colorty);
var
 int1: integer;
begin
 int1:= checkindex(index);
 checkimage;
 if monochrome then begin
  if value = 0 then begin
   fimage.pixels^[int1]:= fimage.pixels^[int1] and not bits[index.x and $1f];
  end
  else begin
   fimage.pixels^[int1]:= fimage.pixels^[int1] or bits[index.x and $1f];
  end;
 end
 else begin
  fimage.pixels^[int1]:= value;
 end;
end;

function tbitmap.getpixels(const x,y: integer): colorty;
var
 int1: integer;
begin
 int1:= checkindex(x,y);
 checkimage;
 if monochrome then begin
  if fimage.pixels^[int1] and bits[x and $1f] <> 0 then begin
   result:= cl_1;
  end
  else begin
   result:= cl_0;
  end;
 end
 else begin
 {$ifdef FPC}{$checkpointer off}{$endif} //not on heap in win32
  result:= fimage.pixels^[int1];
 {$ifdef FPC}{$checkpointer default}{$endif}
 end;
end;

procedure tbitmap.setpixels(const x,y: integer; const value: colorty);
var
 int1: integer;
begin
 int1:= checkindex(x,y);
 checkimage;
 if monochrome then begin
  if value = 0 then begin
   fimage.pixels^[int1]:= fimage.pixels^[int1] and not bits[x and $1f];
  end
  else begin
   fimage.pixels^[int1]:= fimage.pixels^[int1] or bits[x and $1f];
  end;
 end
 else begin
  fimage.pixels^[int1]:= value;
 end;
end;

function tbitmap.getasize: sizety;
begin
 result:= fsize;
end;

procedure tbitmap.destroyhandle;
begin
 if fimage.pixels <> nil then begin
  gui_freeimagemem(fimage.pixels);
  fimage.pixels:= nil;
 end;
 inherited;
end;

procedure tbitmap.createhandle(copyfrom: pixmapty);
begin
 if (fhandle = 0) and (fimage.pixels <> nil) then begin
  putimage;
  gui_freeimagemem(fimage.pixels);
  fimage.pixels:= nil;
 end
 else begin
  inherited;
 end;
end;

function tbitmap.getimagepo: pimagety;
begin
 result:= @fimage;
end;

function tbitmap.getsource: tbitmapcomp;
begin
 result:= nil;
end;

procedure tbitmap.dochange;
begin
 if assigned(fonchange) then begin
  fonchange(self);
 end;
end;

procedure tbitmap.change;
begin
 if (fnochange = 0) then begin
  dochange;
 end;
end;

procedure tbitmap.setalignment(const Value: alignmentsty);
const
 mask: alignmentsty = [al_intpol,al_or,al_and];
begin
 if falignment <> value then begin
  falignment:= alignmentsty(setsinglebit(
                          {$ifdef FPC}longword{$else}word{$endif}(value),
                          {$ifdef FPC}longword{$else}word{$endif}(falignment),
                          {$ifdef FPC}longword{$else}word{$endif}(mask)));
  change;
 end;
end;

procedure tbitmap.settransparency(avalue: colorty);
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 if ftransparency <> avalue then begin
  ftransparency:= avalue;
  change;
 end;
end;

procedure tbitmap.updatealignment(const dest,source: rectty;
            const alignment: alignmentsty; out newdest,newsource: rectty;
            out tileorigin: pointty);
var
 int1: integer;
begin
 newdest:= dest;
 newsource:= source;
 if al_fit in alignment then begin
  exit;
 end;
 if al_xcentered in alignment then begin
  newdest.x:= dest.x + (dest.cx - source.cx) div 2
 end;
 if al_right in alignment then begin
  newdest.x:= dest.x + dest.cx - source.cx;
 end;
 if al_ycentered in alignment then begin
  newdest.y:= dest.y + (dest.cy - source.cy) div 2
 end;
 if al_bottom in alignment then begin
  newdest.y:= dest.y + dest.cy - source.cy;
 end;
 tileorigin:= newdest.pos;
 if al_tiled in alignment then begin
  newdest:= dest;
 end
 else begin
  if al_stretchx in alignment then begin
   newdest.x:= dest.x;
   newdest.cx:= dest.cx;
  end
  else begin
   int1:= newdest.x - dest.x;
   if int1 < 0 then begin
    dec(newdest.x,int1);
    dec(newsource.x,int1);
    inc(newsource.cx,int1);
   end;
   int1:=  dest.x + dest.cx - (newdest.x + newsource.cx);
   if int1 < 0 then begin
    inc(newsource.cx,int1);
   end;
   newdest.cx:= newsource.cx;
  end;
  if al_stretchy in alignment then begin
   newdest.y:= dest.y;
   newdest.cy:= dest.cy;
  end
  else begin
   int1:= newdest.y - dest.y;
   if int1 < 0 then begin
    dec(newdest.y,int1);
    dec(newsource.y,int1);
    inc(newsource.cy,int1);
   end;
   int1:=  dest.y + dest.cy - (newdest.y + newsource.cy);
   if int1 < 0 then begin
    inc(newsource.cy,int1);
   end;
   newdest.cy:= newsource.cy;
  end;
 end;
end;

procedure tbitmap.beginupdate;
begin
 inc(fnochange);
end;

procedure tbitmap.endupdate;
begin
 dec(fnochange);
 if fnochange = 0 then begin
  dochange;
 end;
end;

procedure tbitmap.setcolorbackground(const Value: colorty);
begin
 if fcolorbackground <> value then begin
  fcolorbackground := Value;
  change;
 end;
end;

procedure tbitmap.setcolorforeground(const Value: colorty);
begin
 if fcolorforeground <> value then begin
  fcolorforeground := Value;
  change;
 end;
end;

function tbitmap.compressdata: cardinalarty;
var
 int1,int2,int3: integer;
 po1: pcardinal;
 ca1: cardinal;
begin
 checkimage;
 allocuninitedarray(fimage.length,sizeof(cardinal),result); //max
 if monochrome then begin
  move(fimage.pixels^,result[0],fimage.length*sizeof(cardinal));
 end
 else begin
  po1:=  @fimage.pixels^[0];
  int2:= 0;                          //msb = run length
  int1:= fimage.length;
  while int1 > 0 do begin
   ca1:= po1^ and $ffffff;
   int3:= 0;
   repeat
    inc(po1);
    inc(int3);
    dec(int1);
   until (po1^ and $ffffff <> ca1) or (int3 = 255) or (int1 = 0);
   result[int2]:= ca1 or cardinal(int3 shl 24);
   inc(int2);
  end;
  setlength(result,int2);
 end;
end;

procedure tbitmap.decompressdata(const asize: sizety; const adata: cardinalarty);
var
 int1,int2,int3: integer;
 po1: pcardinal;
 ca1: cardinal;
begin
 clear;
 fsize:= asize;
 fimage.size:= fsize;
 fimage.monochrome:= monochrome;
 {$ifdef FPC}{$checkpointer off}{$endif} //not on heap in win32
 allocimagemem;
 if monochrome then begin
  move(adata[0],fimage.pixels^,fimage.Length*sizeof(cardinal));
 end
 else begin
  int2:= fimage.length;
  if int2 > 0 then begin
   po1:= @fimage.pixels^[0];
   for int1:= 0 to high(adata) do begin
    ca1:= adata[int1] and $ffffff;
    for int3:= (adata[int1] shr 24) - 1 downto 0 do begin
     po1^:= ca1;
     inc(po1);
     dec(int2);
     if int2 <= 0 then begin
      break;
     end;
    end;
    if int2 <= 0 then begin
     break;
    end;
   end;
  end;
 end;
 {$ifdef FPC}{$checkpointer default}{$endif}
end;

procedure tbitmap.assign(source: tpersistent);
begin
 if source is tbitmap then begin
  with tbitmap(source) do begin
   self.fcolorforeground:= colorforeground;
   self.fcolorbackground:= colorbackground;
   self.falignment:= alignment;
   self.ftransparency:= transparency;
  end;
 end;
 inherited;
end;

function tbitmap.hasimage: boolean;
var
 bmp1: tbitmapcomp;
begin
 bmp1:= getsource;
 if bmp1 <> nil then begin
  result:= not bmp1.bitmap.isempty;
 end
 else begin
  result:= not isempty;
 end;
end;

procedure tbitmap.setsize(const Value: sizety);
begin
 inherited;
 change;
end;

procedure tbitmap.savetoimage(out aimage: imagety);
begin
 if hasimage then begin
  if fimage.pixels = nil then begin
   getimage;
   aimage:= fimage;
   fimage.pixels:= nil;
  end
  else begin
   aimage:= fimage;
   allocimagemem;
   move(aimage.pixels^,fimage.pixels^,fimage.length * sizeof(cardinal));
               //get a copy
  end;
 end
 else begin
  fillchar(aimage,sizeof(aimage),0);
 end;
end;

procedure tbitmap.loadfromimage(const aimage: imagety);
begin
 if aimage.pixels = nil then begin
  clear;
 end
 else begin
  size:= aimage.size;
  if aimage.monochrome then begin
   include(fstate,pms_monochrome);
  end
  else begin
   exclude(fstate,pms_monochrome);
  end;
  fimage:= aimage;
  putimage;
  fimage.pixels:= nil;  //does not own image
 end;
end;

function tbitmap.scanhigh: integer;
begin
 result:= fsize.cx * fsize.cy - 1;
end;

{ tmaskedbitmap }

constructor tmaskedbitmap.create(amonochrome: boolean);
begin
 ftransparentcolor:= cl_default;
 fmaskcolorbackground:= $000000; //max transparent
 fmaskcolorforeground:= $ffffff;
 inherited;
end;

destructor tmaskedbitmap.destroy;
begin
 freemask;
 inherited;
 fobjectlinker.free;
end;

class procedure tmaskedbitmap.freeimageinfo(var ainfo: imagebufferinfoty);
begin
 with ainfo do begin
  if image.pixels <> nil then begin
   gui_freeimagemem(image.pixels);
   image.pixels:= nil;
  end;
  if mask.pixels <> nil then begin
   gui_freeimagemem(mask.pixels);
   mask.pixels:= nil;
  end;
 end;
end;

procedure tmaskedbitmap.freemask;
begin
 freeandnil(fmask);
end;

function tmaskedbitmap.getasize: sizety;
begin
 if fsource = nil then begin
  result:= fsize;
 end
 else begin
  result:= fsource.fbitmap.fsize;
 end;
end;

procedure tmaskedbitmap.createmask(const acolormask: boolean);
begin
 if fmask = nil then begin
  fmask:= tbitmap.create(true);
  with fmask do begin
   fcolorforeground:= fmaskcolorforeground;
   fcolorbackground:= fmaskcolorbackground;
  end;
 end
 else begin
  fmask.clear;
 end;
 fmask.monochrome:= not acolormask;
 exclude(fstate,pms_maskvalid);
end;

procedure tmaskedbitmap.initmask;
var
 bo1: boolean;
begin
 if fmask <> nil then begin
  bo1:= fmask.fcanvas = nil;
  fmask.size:= fsize;
  if not isnullsize(fsize) then begin
   if fmask.monochrome then begin
    fmask.init(cl_1);
   end
   else begin
    fmask.init(fmaskcolorforeground);
   end;
  end;
  if bo1 then begin
   fmask.freecanvas;
  end;
  include(fstate,pms_maskvalid);
 end;
end;

function tmaskedbitmap.getconverttomonochromecolorbackground: colorty;
begin
 if ftransparentcolor = cl_none then begin
  result:= inherited getconverttomonochromecolorbackground;
 end
 else begin
  if (ftransparentcolor = cl_default) and not isempty then begin
   result:= pixel[makepoint(0,fsize.cy-1)];
  end
  else begin
   result:= ftransparentcolor;
  end;
 end;
end;

procedure tmaskedbitmap.checkmask;
var
 col1: colorty;
begin
 if not (pms_maskvalid in fstate) and (ftransparentcolor <> cl_none) then begin
  freemask;
 end;
 if fmask = nil then begin
  createmask((ftransparentcolor = cl_none) and (bmo_colormask in foptions));
 end;
 if not isempty and not (pms_maskvalid in fstate) then begin
  fmask.size:= fsize;
  if ftransparentcolor = cl_default then begin
   col1:= pixel[makepoint(0,fsize.cy-1)];
   if monochrome then begin
    if col1 = cl_0 then begin
     fmask.canvas.copyarea(canvas,makerect(nullpoint,fsize),nullpoint,rop_copy);
    end
    else begin
     fmask.canvas.copyarea(canvas,makerect(nullpoint,fsize),nullpoint,rop_notcopy);
    end
   end
   else begin
    fmask.canvas.copyarea(canvas,makerect(nullpoint,fsize),nullpoint,rop_copy,col1);
   end;
  end
  else begin
   if ftransparentcolor <> cl_none then begin
    if monochrome then begin
     if ftransparentcolor = cl_0 then begin
      fmask.canvas.copyarea(canvas,makerect(nullpoint,fsize),nullpoint,rop_copy);
     end
     else begin
      fmask.canvas.copyarea(canvas,makerect(nullpoint,fsize),nullpoint,rop_notcopy);
     end
    end
    else begin
     fmask.canvas.copyarea(canvas,makerect(nullpoint,fsize),nullpoint,rop_copy,ftransparentcolor);
    end;
   end
   else begin
    initmask;
   end;
  end;
  include(fstate,pms_maskvalid);
 end;
 fmask.monochrome:= not (bmo_colormask in foptions);
end;

function tmaskedbitmap.getmask1: tbitmap;
begin
 checkmask;
 result:= fmask;
end;

procedure tmaskedbitmap.settransparentcolor(const Value: colorty);
begin
 if ftransparentcolor <> value then begin
  ftransparentcolor:= Value;
  if value <> cl_none then begin
   remask;
  end;
 end;
end;

function tmaskedbitmap.getmasked: boolean;
begin
 result:= fmask <> nil;
end;

procedure tmaskedbitmap.setmasked(const Value: boolean);
begin
 if getmasked <> value then begin
  exclude(fstate,pms_maskvalid);
  if value then begin
   include(foptions,bmo_masked);
   checkmask;
  end
  else begin
   exclude(foptions,bmo_masked);
   freemask;
  end;
  change;
 end;
end;

procedure tmaskedbitmap.setmonochrome(const avalue: boolean);
begin
 inherited;
 if avalue then begin
  include(foptions,bmo_monochrome);
 end
 else begin
  exclude(foptions,bmo_monochrome);
 end;
end;

function tmaskedbitmap.getcolormask: boolean;
begin
 result:= bmo_colormask in foptions;
end;

procedure tmaskedbitmap.setcolormask(const avalue: boolean);
begin
 if avalue then begin
  options:= foptions + [bmo_colormask];
 end
 else begin
  options:= foptions - [bmo_colormask];
 end;
end;

function tmaskedbitmap.getoptions: bitmapoptionsty;
begin
 result:= foptions;
 updatebit({$ifdef FPC}longword{$else}byte{$endif}(result),ord(bmo_monochrome),
                   monochrome);
 updatebit({$ifdef FPC}longword{$else}byte{$endif}(result),ord(bmo_masked),
                   masked);
end;

procedure tmaskedbitmap.setoptions(const avalue: bitmapoptionsty);
const
 mask1: bitmapoptionsty = [bmo_colormask];
begin
 if ({$ifdef FPC}longword{$else}byte{$endif}(foptions) xor
     {$ifdef FPC}longword{$else}byte{$endif}(avalue)) and
     {$ifdef FPC}longword{$else}byte{$endif}(mask1) <> 0 then begin
  foptions:= avalue;
  if fmask <> nil then begin
   checkmask;
   fmask.monochrome:= not (bmo_colormask in avalue);
   change;
  end;
 end
 else begin
  foptions:= avalue;
 end;
 monochrome:= bmo_monochrome in foptions;
 masked:= bmo_masked in foptions;
end;

procedure tmaskedbitmap.remask;
begin
 if fmask <> nil then begin
  exclude(fstate,pms_maskvalid);
  checkmask;
  change;
 end;
end;

procedure tmaskedbitmap.automask;
begin
 exclude(fstate,pms_maskvalid);
 if not isempty then begin
  transparentcolor:= pixel[makepoint(fsize.cx-1,fsize.cy-1)];
 end;
 masked:= true;
 checkmask;
 change;
end;

procedure tmaskedbitmap.setmask(const Value: tbitmap);
begin
 if fmask <> value then begin
  freemask;
  if value <> nil then begin
   createmask(colormask);
//   fmask:= tbitmap.create(true);
   fmask.size:= fsize;
   if sizeisequal(fsize,tsimplebitmap1(value).fsize) and 
         (value.monochrome <> colormask) then begin
    tsimplebitmap1(fmask).handle:= tsimplebitmap1(value).handle;
   end
   else begin
    if colormask then begin
     fmask.init(fmaskcolorbackground);
    end
    else begin
     fmask.init(cl_0);
    end;
    fmask.copyarea(value,makerect(nullpoint,fsize),nullpoint,rop_copy,false,
             fmaskcolorforeground,fmaskcolorbackground);
//    fmask.canvas.copyarea(value.canvas,makerect(nullpoint,fsize),nullpoint,
//             rop_copy,ftransparentcolor);
   end;
   include(fstate,pms_maskvalid);
  end;
  if masked then begin
   change;
  end;
 end;
end;
{
function tmaskedbitmap.getmaskhandle(var gchandle: cardinal): pixmapty;
begin
 if fmask <> nil then begin
  result:= tsimplebitmap1(fmask).handle;
  if tsimplebitmap1(fmask).fcanvas <> nil then begin
   gchandle:= tcanvas1(tsimplebitmap1(fmask).fcanvas).fdrawinfo.gc.handle;
  end
  else begin
   gchandle:= 0;
  end;
 end
 else begin
  result:= 0;
 end;
end;
}
function tmaskedbitmap.getmask: tsimplebitmap;
begin
 result:= fmask;
end;

procedure tmaskedbitmap.assign1(const source: tsimplebitmap; const docopy: boolean);
begin
 beginupdate;
 try
  if source is tmaskedbitmap then begin
   with tmaskedbitmap(source) do begin
    if source <> nil then begin
     self.source:= source;
    end
    else begin
     inherited;
     self.freemask;
     if fmask <> nil then begin
      self.fmask:= tbitmap.create(fmask.monochrome);
      with self,fmask do begin
       fcolorforeground:= fmaskcolorforeground;
       fcolorbackground:= fmaskcolorbackground;
      end;
      tsimplebitmap1(self.fmask).assign1(fmask,docopy);
      include(self.fstate,pms_maskvalid);
      include(self.foptions,bmo_masked);
      if fmask.monochrome then begin
       exclude(self.foptions,bmo_colormask);
      end
      else begin
       include(self.foptions,bmo_colormask);
      end;
     end
     else begin
      if masked then begin
       include(self.foptions,bmo_masked);
       exclude(self.fstate,pms_maskvalid);
      end
      else begin
       exclude(self.foptions,bmo_masked);
      end;
      if colormask then begin
       include(self.foptions,bmo_colormask);
      end
      else begin
       exclude(self.foptions,bmo_colormask);
      end;
     end;
     self.ftransparentcolor:= ftransparentcolor;
    end;
   end;
  end
  else begin
   inherited;
   freemask;
  end;
 finally
  endupdate;
 end;
end;

procedure tmaskedbitmap.releasehandle;
begin
 inherited;
// if fmask <> nil then begin
//  tsimplebitmap1(fmask).releasehandle;
// end;
end;

procedure tmaskedbitmap.acquirehandle;
begin
 inherited;
// if fmask <> nil then begin
//  tsimplebitmap1(fmask).acquirehandle;
// end;
end;

procedure tmaskedbitmap.destroyhandle;
begin
// if fmask <> nil then begin
//  tsimplebitmap1(fmask).destroyhandle;
// end;
 inherited;
end;

function tmaskedbitmap.getobjectlinker: tobjectlinker;
begin
 if fobjectlinker = nil then begin
  createobjectlinker(iobjectlink(self),{$ifdef FPC}@{$endif}objectevent,fobjectlinker);
 end;
 result:= fobjectlinker;
end;

procedure tmaskedbitmap.setsource(const Value: tbitmapcomp);
var
 bmpcomp1: tbitmapcomp;
begin
 if fsource <> value then begin
  bmpcomp1:= value;
  while bmpcomp1 <> nil do begin
   if bmpcomp1.bitmap = self then begin
    raise exception.create('Recursive bitmap source.');
   end;
   bmpcomp1:= bmpcomp1.bitmap.source;
  end; 
  beginupdate;
  try
   clear;
   getobjectlinker.setlinkedvar(iobjectlink(self),value,tmsecomponent(fsource));
  finally
   endupdate;
  end;
 end;
end;

procedure tmaskedbitmap.objectevent(const sender: tobject; const event: objecteventty);
begin
 if sender = fsource then begin
  case event of
//   oe_destroyed: source:= nil;
   oe_changed: change;
  end;
 end;
end;

procedure tmaskedbitmap.link(const source,dest: iobjectlink; valuepo: pointer = nil;
                            ainterfacetype: pointer = nil; once: boolean = false);
begin
 getobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tmaskedbitmap.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
begin
 getobjectlinker.unlink(source,dest,valuepo);
end;

procedure tmaskedbitmap.objevent(const sender: iobjectlink; const event: objecteventty);
begin
 getobjectlinker.objevent(sender,event);
end;

function tmaskedbitmap.getinstance: tobject;
begin
 result:= self;
end;

function tmaskedbitmap.getsource: tbitmapcomp;
begin
 result:= fsource;
end;

procedure tmaskedbitmap.setsize(const Value: sizety);
begin
 inherited;
 initmask;
end;

procedure tmaskedbitmap.stretch(const dest: tmaskedbitmap);
var
 size1: sizety;
begin
 dest.beginupdate;
 try
  size1:= dest.size;
  dest.clear;
  dest.monochrome:= monochrome;
  dest.colormask:= colormask;
  dest.masked:= masked;
  dest.size:= size1;
  tcanvas1(dest.canvas).internalcopyarea(canvas,makerect(nullpoint,size),
       makerect(nullpoint,size1),rop_copy,cl_none,nil,
                [al_stretchx,al_stretchy,al_intpol],
       nullpoint,cl_none);
       
  if masked then begin
   tcanvas1(dest.fmask.canvas).internalcopyarea(mask.canvas,makerect(nullpoint,size),
       makerect(nullpoint,size1),rop_copy,cl_none,nil,
                [al_stretchx,al_stretchy,al_intpol],
       nullpoint,cl_none);
   include(dest.fstate,pms_maskvalid);
  end;
 finally
  dest.endupdate;
 end;
end;

function tmaskedbitmap.writedata(const ancestor: tmaskedbitmap): boolean;
begin
 result:= (fsource = nil) and not isempty and not (pms_nosave in fstate);
 if result and (ancestor <> nil) then begin
  result:= (masked <> ancestor.masked) or
           (colormask <> ancestor.colormask) or
           (monochrome <> ancestor.monochrome) or
           (size.cx <> ancestor.size.cx) or
           (size.cy <> ancestor.size.cy);
  if not result then begin
   if masked then begin
    fmask.checkimage;
    ancestor.fmask.checkimage;
    result:= not comparemem(fmask.fimage.pixels,ancestor.fmask.fimage.pixels,
                         fmask.fimage.length * sizeof(longword));
   end;
   if not result then begin
    checkimage;
    ancestor.checkimage;
    result:= not comparemem(fimage.pixels,ancestor.fimage.pixels,
                         fimage.length * sizeof(longword));
   end;
  end;
 end;
end;

procedure tmaskedbitmap.defineproperties(filer: tfiler);
begin
 inherited;
 filer.DefineBinaryProperty('image',{$ifdef FPC}@{$endif}readimage,
                                     {$ifdef FPC}@{$endif}writeimage,
                                     writedata(tmaskedbitmap(filer.ancestor)));
end;

procedure tmaskedbitmap.writeimage(stream: tstream);
var
 header: imageheaderty;
 int1: integer;
 ar1: cardinalarty;
begin
 fillchar(header,sizeof(header),0);
 with header do begin
  width:= fsize.cx;
  height:= fsize.cy;
  if monochrome then begin
   setbit1(info,ord(iminf_monochrome));
  end;
  if masked then begin
   setbit1(info,ord(iminf_masked));
   if not fmask.monochrome then begin
    setbit1(info,ord(iminf_colormask));
   end;
  end;
  ar1:= compressdata;
  datasize:= length(ar1)*4;
  stream.Writebuffer(header,sizeof(header));
  stream.Writebuffer(ar1[0],datasize);
 end;
 if masked then begin
  checkmask;
  ar1:= fmask.compressdata;
  int1:= length(ar1)*4;
  if not fmask.monochrome then begin
   stream.WriteBuffer(int1,4);
  end;
  stream.WriteBuffer(ar1[0],int1);
 end;
end;

procedure tmaskedbitmap.readimage(stream: tstream);
var
 header: imageheaderty;
 int1: integer;
 ar1: cardinalarty;

begin
 beginupdate;
 try
  clear;
  stream.readbuffer(header,sizeof(header));
  with header do begin
   if checkbit(info,ord(iminf_monochrome)) then begin
    include(fstate,pms_monochrome);
   end
   else begin
    exclude(fstate,pms_monochrome);
   end;
   if checkbit(info,ord(iminf_masked)) then begin
    ftransparentcolor:= cl_none;
    createmask(checkbit(info,ord(iminf_colormask)));
   end
   else begin
    freemask;
   end;
   setlength(ar1,datasize div 4);
   stream.ReadBuffer(ar1[0],length(ar1)*4);
   decompressdata(makesize(width,height),ar1);
   if masked then begin
    if fmask.monochrome then begin
     int1:= ((fsize.cx + 31) div 32) * fsize.cy;
    end
    else begin
     stream.ReadBuffer(int1,sizeof(int1));
     int1:= int1 div 4;
    end;
    setlength(ar1,int1);
    stream.readbuffer(ar1[0],int1*4);
    fmask.decompressdata(fsize,ar1);
    include(fstate,pms_maskvalid);
   end;
  end;
 finally
  endupdate;
 end;
end;

procedure tmaskedbitmap.loadfromstream(const stream: tstream;
                      const format: string = ''; const index: integer = -1);
begin
 readgraphic(stream,self,format,index);
end;

procedure tmaskedbitmap.loadfromfile(const filename: filenamety;
                      const format: string = ''; const index: integer = -1);
var
 stream: tmsefilestream;
begin
 stream:= tmsefilestream.create(filename,fm_read);
 try
  loadfromstream(stream,format,index);
 finally
  stream.free;
 end;
end;

procedure tmaskedbitmap.loadfromstring(const avalue: string;
               const format: string = ''; const index: integer = -1);
var
 stream1: tstringcopystream;
begin
 if avalue = '' then begin
  clear;
 end
 else begin
  stream1:= tstringcopystream.create(avalue);
  try
   loadfromstream(stream1,format);
  finally
   stream1.free;
  end;
 end;
end;

procedure tmaskedbitmap.loadfromimagebuffer(const abuffer: imagebufferinfoty);
begin
 loadfromimage(abuffer.image);
 if abuffer.mask.pixels <> nil then begin
  include(foptions,bmo_masked);
  createmask(not abuffer.mask.monochrome);
  fmask.loadfromimage(abuffer.mask);
  if abuffer.mask.monochrome then begin
   exclude(foptions,bmo_colormask);
  end
  else begin
   include(foptions,bmo_colormask);   
  end;
  include(fstate,pms_maskvalid);
 end
 else begin
  freemask;
  exclude(foptions,bmo_masked);
  exclude(fstate,pms_maskvalid);
 end;  
end;

procedure tmaskedbitmap.savetoimagebuffer(out abuffer: imagebufferinfoty);
begin
 savetoimage(abuffer.image);
 if fmask <> nil then begin
  fmask.savetoimage(abuffer.mask);
 end
 else begin
  fillchar(abuffer.mask,sizeof(abuffer.mask),0);
 end;
end;

{
procedure tmaskedbitmap.loadfromresourcename(instance: cardinal;
  const resname: string);
var
 stream: tresourcestream;
 formatstream: tformatstream;
begin
 stream:= tresourcestream.Create(instance,uppercase(resname),RT_BITMAP);
 formatstream:= tformatstream.create(stream,'bmp');
 try
  readbmp(formatstream,0,self);
 finally
  formatstream.Free;
  stream.Free;
 end;
end;
}
{
procedure tmaskedbitmap.readimagefile(const filename: filenamety);
var
 stream: tmsefilestream;
begin
 stream:= tmsefilestream.create(filename,fm_read);
 try
  msebitmap.readimage(stream,self);
 finally
  stream.Free;
 end;
 change;
end;
}
{ tbitmapcomp }

constructor tbitmapcomp.create(aowner: tcomponent);
begin
 inherited;
 fbitmap:= tmaskedbitmap.create(false);
 fbitmap.fonchange:= {$ifdef FPC}@{$endif}change;
end;

destructor tbitmapcomp.destroy;
begin
 inherited;
 fbitmap.Free;
end;

procedure tbitmapcomp.setbitmap(const Value: tmaskedbitmap);
begin
 fbitmap.assign(value);
end;

procedure tbitmapcomp.change(const sender: tobject);
begin
 if fobjectlinker <> nil then begin
  fobjectlinker.sendevent(oe_changed);
 end;
 if assigned(fonchange) then begin
  fonchange(self);
 end;
end;

{ timagelist }

constructor timagelist.create(aowner: tcomponent);
begin
 fsize:= defaultimagelistsize;
 inherited;
 fbitmap:= tmaskedbitmap.create(false);
 fbitmap.transparentcolor:= cl_none;
 masked:= true;
end;

destructor timagelist.destroy;
begin
 fbitmap.Free;
 inherited;
end;

procedure timagelist.clear;
begin
 count:= 0;
end;

procedure timagelist.setsize(const avalue: sizety);
var
 int1: integer;
 bmp1,bmp2: tmaskedbitmap;
 sizebefore: sizety;
 countbefore: integer;
 rect1,rect2: rectty;
begin
 if not sizeisequal(fsize,avalue) then begin
  sizebefore:= fsize;
  fsize:= avalue;
  if fcount <> 0 then begin
   beginupdate;
   bmp1:= tmaskedbitmap.create(false);
   bmp1.assign(fbitmap);
   bmp2:= tmaskedbitmap.create(false);
   bmp2.assign(fbitmap); //get mask and color modes
   bmp2.size:= sizebefore;
   fbitmap.clear;
   countbefore:= fcount;
   count:= 0;
   count:= countbefore;
   rect1:= makerect(nullpoint,fsize);
   rect2:= makerect(nullpoint,sizebefore);
   centerinrect(rect1,rect2);
   for int1:= 0 to count - 1 do begin
    bmp2.canvas.copyarea(bmp1.canvas,rect2,nullpoint);
    if bmp1.mask <> nil then begin
     bmp2.mask.canvas.copyarea(bmp1.mask.canvas,rect2,nullpoint);
    end;
    setimage(int1,bmp2,rect1);
    with rect2 do begin
     inc(x,cx);
     if x >= bmp1.fsize.cx then begin
      x:= 0;
      inc(y,cy);
     end;
    end;
   end;
   bmp1.free;
   bmp2.free;
   endupdate;
  end;
 end;
end;

function timagelist.indextoorg(index: integer): pointty;
begin
 if (index < 0) or (index >= fcount) then begin
  gdierror(gde_invalidindex);
 end;
 result.x:= (index mod fcolcount) * fsize.cx;
 result.y:= (index div frowcount) * fsize.cy;
end;

function timagelist.getmasked: boolean;
begin
 result:= fbitmap.masked;
end;

procedure timagelist.setmasked(const Value: boolean);
begin
 fbitmap.masked:= value;
end;

function timagelist.getmonochrome: boolean;
begin
 result:= fbitmap.monochrome;
end;

function timagelist.getcolormask: boolean;
begin
 result:= fbitmap.colormask;
end;

procedure timagelist.setcolormask(const avalue: boolean);
begin
 fbitmap.colormask:= avalue;
end;

procedure timagelist.setmonochrome(const Value: boolean);
begin
 if fbitmap.monochrome <> value then begin
  fbitmap.monochrome:= value;
  change;
 end;
end;

procedure timagelist.paint(const acanvas: tcanvas; const index: integer; 
         const dest: rectty;  const alignment: alignmentsty = [];
         const acolor: colorty = cl_default 
  //used for monochrome bitmaps, cl_default-> acanvas.color
  );
begin
 if (index >= 0) and (index < count) then begin
  fbitmap.paint(acanvas,dest,makerect(indextoorg(index),fsize),alignment,acolor);
 end;
end;

procedure timagelist.paint(const acanvas: tcanvas; const index: integer;
                   const dest: pointty; const acolor: colorty = cl_default
               //used for monochrome bitmaps, cl_default-> acanvas.color
            );
begin
 paint(acanvas,index,makerect(dest,size),[],acolor);
end;

function timagelist.gettransparentcolor: colorty;
begin
 result:= fbitmap.ftransparentcolor;
end;

procedure timagelist.settransparentcolor(avalue: colorty);
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 fbitmap.transparentcolor:= avalue;
end;

procedure timagelist.setimage(index: integer; image: tmaskedbitmap;
                      const source: rectty);
var
 po1: pointty;
 rect1: rectty;
 bo1: boolean;
 
begin
 po1:= indextoorg(index);
 rect1:= source;
 with rect1 do begin
  bo1:= (x < 0) or (y < 0) or (x + cx > image.fsize.cx) or 
                 (y + cy > image.fsize.cy);
  if cx > fsize.cx then begin
   cx:= fsize.cx;
  end;
  if cy > fsize.cy then begin
   cy:= fsize.cy;
  end;
 end;
 if masked then begin
  fbitmap.copyarea(image,rect1,po1,rop_copy,false);
  if image.masked then begin
   if bo1 then begin
    if fbitmap.mask.monochrome then begin
     fbitmap.mask.canvas.fillrect(makerect(po1,fsize),cl_0);
    end
    else begin
     fbitmap.mask.canvas.fillrect(makerect(po1,fsize),
                          fbitmap.fmaskcolorbackground);
    end;
   end;
   fbitmap.mask.copyarea(image.mask,rect1,po1,rop_copy,false,
           fbitmap.fmaskcolorforeground,fbitmap.fmaskcolorbackground);
  end
  else begin
   if bo1 then begin
    if fbitmap.mask.monochrome then begin
     fbitmap.mask.canvas.fillrect(makerect(po1,fsize),cl_0);
    end
    else begin
     fbitmap.mask.canvas.fillrect(makerect(po1,fsize),
                          fbitmap.fmaskcolorbackground);
    end;
   end;
   subpoint1(po1,rect1.pos);
   addpoint1(pointty(rect1.size),rect1.pos);
   if fbitmap.mask.monochrome then begin
    fbitmap.mask.canvas.fillrect(makerect(po1,rect1.size),cl_1);
   end
   else begin
    fbitmap.mask.canvas.fillrect(makerect(po1,rect1.size),
                         fbitmap.fmaskcolorforeground);
   end;
  end;
 end
 else begin
  if bo1 then begin
   if monochrome then begin
    fbitmap.canvas.fillrect(makerect(po1,fsize),cl_0);
   end
   else begin
    fbitmap.canvas.fillrect(makerect(po1,fsize),fbitmap.ftransparentcolor);
   end;
  end;
  fbitmap.copyarea(image,rect1,po1,rop_copy,false);
 end;
 change;
end;

procedure timagelist.getimage(const index: integer; const dest: tmaskedbitmap);
var
 rect1: rectty;

begin
 if (index < 0) or (index >= fcount) then begin
  dest.clear;
 end
 else begin
  rect1.pos:= indextoorg(index);
  rect1.size:= size;
  dest.clear;
  dest.size:= size;
  dest.copyarea(fbitmap,rect1,nullpoint,rop_copy,masked and not dest.masked);
  if masked and dest.masked then begin
   dest.colormask:= dest.colormask or colormask;
   dest.mask.copyarea(fbitmap.fmask,rect1,nullpoint,rop_copy,false,
               dest.fmaskcolorforeground,dest.fmaskcolorbackground);
  end;
  if dest.masked and not masked then begin
   dest.mask.init(dest.fmaskcolorbackground);
  end;
 end;
end;

procedure timagelist.setimage(index: integer; image: tmaskedbitmap);
begin
 setimage(index,image,makerect(nullpoint,image.fsize));
end;

procedure timagelist.copyimages(const image: tmaskedbitmap; 
                                                 const destindex: integer);
var
 rect1: rectty;
 int1,int2: integer;
begin
 with image.fsize do begin
  if fsize.cx > cx then begin
   int2:= -(fsize.cx - cx) div 2;
  end
  else begin
   int2:= 0;
  end;
  if fsize.cy > cy then begin
   rect1.y:= -(fsize.cy - cy) div 2;
  end
  else begin
   rect1.y:= 0;
  end;
  rect1.cx:= cx - int2;
  rect1.cy:= cy - rect1.y;
 end;
 int1:= destindex;
 while rect1.y < image.fsize.cy do begin
  rect1.x:= int2;
  while rect1.x < image.fsize.cx do begin
   if int1 >= fcount then begin
    exit;
   end;
   setimage(int1,image,rect1);
   inc(int1);
   inc(rect1.x,fsize.cx);
  end;
  inc(rect1.y,fsize.cy);
 end;
end;

procedure timagelist.setcount(const Value: integer);

var
 int1,int2: integer;
 buffer: tmaskedbitmap;
 bo1: boolean;

begin
 if fcount <> value then begin
  fcount := Value;
  if value = 0 then begin
   fbitmap.clear;
   frowcount:= 0;
   fcolcount:= 0;
  end
  else begin
   int1:= bits[highestbit(fcount) div 2 + 1];
   repeat
    int2:= int1;
    int1:= (int1 * 7) shr 3; //7/8 -> 0.875*0.875 -> 0.765
    if int1 = int2 then begin
     dec(int1);
    end;
   until int1 * int1 < fcount;
   bo1:= (frowcount <> int2) or (fcolcount <> int2);
   frowcount:= int2; //square
   fcolcount:= int2;
   if bo1 then begin
    buffer:= tmaskedbitmap.create(monochrome);
    buffer.assign1(fbitmap,false);
    fbitmap.size:= makesize(int2*fsize.cx,int2*fsize.cy);
    if not buffer.isempty then begin
     copyimages(buffer,0);
    end;
    buffer.Free;
   end;
  end;
  change;
 end;
end;

function timagelist.addimage(const image: tmaskedbitmap;
                                      const stretch: boolean = false): integer;
var
 newcolcount,newrowcount,newcount: integer;
 bmp1: tmaskedbitmap;
begin
 if not image.isempty then begin
  result:= fcount;
  beginupdate;
  try
   if (fsize.cx = 0) or (fsize.cy = 0) then begin
    fsize:= image.fsize;
   end;
   if stretch then begin
    bmp1:= tmaskedbitmap.create(image.monochrome);
    bmp1.size:= fsize;
    image.stretch(bmp1);
   end
   else begin
    bmp1:= image;
   end;     
   newcolcount:= (bmp1.size.cx + fsize.cx-1) div fsize.cx;
   newrowcount:= (bmp1.size.cy + fsize.cy-1) div fsize.cy;
   newcount:= newcolcount * newrowcount;
   count:= fcount + newcount;
   copyimages(bmp1,result);
  finally
   if stretch then begin
    bmp1.free;
   end;
   endupdate;
  end;
 end
 else begin
  result:= -1;
 end;
end;

procedure timagelist.deleteimage(const index: integer);
begin
 moveimage(index,count-1);
 count:= fcount - 1;
end;

procedure timagelist.moveimage(const fromindex: integer; const toindex: integer);
var
 bmp1,bmp2: tmaskedbitmap;
 int1: integer;
begin
 if fromindex <> toindex then begin
  beginupdate;
  try
   bmp1:= tmaskedbitmap.create(monochrome);
   bmp1.masked:= masked;
   bmp2:= tmaskedbitmap.create(monochrome);
   bmp2.masked:= masked;
   try
    getimage(fromindex,bmp1);
    if fromindex < toindex then begin
     for int1:= fromindex + 1 to toindex do begin
      getimage(int1,bmp2);
      setimage(int1-1,bmp2);
     end;
    end
    else begin
     for int1:= fromindex-1 downto toindex do begin
      getimage(int1,bmp2);
      setimage(int1+1,bmp2);
     end;
    end;
    setimage(toindex,bmp1);
   finally
    bmp1.free;
    bmp2.Free;
   end;
  finally
   endupdate;
  end;
 end;
end;

procedure timagelist.setheight(const Value: integer);
begin
 setsize(makesize(fsize.cx,Value));
end;

procedure timagelist.setwidth(const Value: integer);
begin
 setsize(makesize(value,fsize.cy));
end;

procedure timagelist.setbitmap(const Value: tmaskedbitmap);
begin
 addimage(fbitmap);
end;

procedure timagelist.beginupdate;
begin
 inc(fupdating);
end;

procedure timagelist.endupdate;
begin
 dec(fupdating);
 change;
end;

procedure timagelist.change;
begin
 if (fupdating = 0) then begin
  if fobjectlinker <> nil then begin
   fobjectlinker.sendevent(oe_changed);
  end;
  if canevent(tmethod(fonchange)) then begin
   fonchange(self);
  end;
 end;
end;

procedure timagelist.defineproperties(filer: tfiler);
var
 ancestorbefore: tpersistent;
begin
 inherited;
 ancestorbefore:= filer.ancestor;
 if ancestorbefore <> nil then begin
  filer.ancestor:= timagelist(ancestorbefore).fbitmap;
 end;
 fbitmap.defineproperties(filer); //imagedata
 filer.ancestor:= ancestorbefore;
end;

procedure timagelist.assign(sender: tpersistent);
begin
 if sender is timagelist then begin
  count:= 0;
  with timagelist(sender) do begin
   self.fsize:= fsize;
   self.fcolcount:= fcolcount;
   self.frowcount:= frowcount;
   self.fcount:= fcount;
   self.fbitmap.assign(fbitmap);
  end;
  change;
 end
 else begin
  inherited;
 end;
end;

end.
