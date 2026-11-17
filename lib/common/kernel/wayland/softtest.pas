program softtest;
{ Test of msesoftsurface: checks pixel values and writes softtest.bmp.
  Build:  fpc -Mobjfpc -Fu<folder of msesoftsurface.pas> softtest.pas
  Run:    ./softtest   (exit code 0 = all checks passed) }
{$mode objfpc}{$h+}

uses
 msesoftsurface;

const
 W = 400;
 H = 300;

var
 surf: psoftsurfacety;
 fails,checks: integer;

procedure check(const name: string; const value,expected: longword);
begin
 inc(checks);
 if value <> expected then begin
  inc(fails);
  writeln('FAIL ',name,': got ',hexstr(value,8),' expected ',hexstr(expected,8));
 end
 else begin
  writeln('ok   ',name);
 end;
end;

procedure putle32(var buf: array of byte; const pos: integer;
                                                      const value: longword);
begin
 buf[pos]:= value and $ff;
 buf[pos+1]:= (value shr 8) and $ff;
 buf[pos+2]:= (value shr 16) and $ff;
 buf[pos+3]:= (value shr 24) and $ff;
end;

procedure writebmp(const filename: string; const s: psoftsurfacety);
//24 bit bmp, rows bottom up, each row padded to 4 bytes
var
 f: file;
 hdr: array[0..53] of byte;
 row: array of byte;
 rowsize,x,y: integer;
 p: longword;
begin
 rowsize:= ((s^.width * 3 + 3) div 4) * 4;
 fillchar(hdr,sizeof(hdr),0);
 hdr[0]:= ord('B');
 hdr[1]:= ord('M');
 putle32(hdr,2,54 + rowsize * s^.height);
 putle32(hdr,10,54);
 putle32(hdr,14,40);
 putle32(hdr,18,s^.width);
 putle32(hdr,22,s^.height);
 hdr[26]:= 1;
 hdr[28]:= 24;
 putle32(hdr,34,rowsize * s^.height);
 setlength(row,rowsize);
 assign(f,filename);
 rewrite(f,1);
 blockwrite(f,hdr,sizeof(hdr));
 for y:= s^.height - 1 downto 0 do begin
  fillchar(row[0],rowsize,0);
  for x:= 0 to s^.width - 1 do begin
   p:= softgetpixel(s,x,y);
   row[x*3]:= p and $ff;               //b
   row[x*3+1]:= (p shr 8) and $ff;     //g
   row[x*3+2]:= (p shr 16) and $ff;    //r
  end;
  blockwrite(f,row[0],rowsize);
 end;
 close(f);
end;

var
 mask: array[0..63] of byte;
 buf: array[0..3] of longword;
 i: integer;
 wrapped: psoftsurfacety;
 ext: array[0..(10*10)-1] of longword;

begin
 fails:= 0;
 checks:= 0;
 surf:= createsoftsurface(W,H);
 if surf = nil then begin
  writeln('createsoftsurface failed');
  halt(2);
 end;

 //clear
 softclear(surf,$E0E0E0);
 check('clear',softgetpixel(surf,5,5),$FFE0E0E0);

 //opaque rectangle
 softfillrect(surf,softrect(10,10,50,30),$FF0000,255);
 check('fillrect inside',softgetpixel(surf,20,20),$FFFF0000);
 check('fillrect left of it',softgetpixel(surf,9,10),$FFE0E0E0);
 check('fillrect last pixel',softgetpixel(surf,59,39),$FFFF0000);
 check('fillrect after last',softgetpixel(surf,60,39),$FFE0E0E0);

 //blend, blue with alpha 128 over red: r=127, g=0, b=128
 softfillrect(surf,softrect(40,20,50,40),$0000FF,128);
 check('blend over red',softgetpixel(surf,45,25),$FF7F0080);
 //blue with alpha 128 over the gray background: r=(0*128+224*127+127)/255=112
 check('blend over gray',softgetpixel(surf,80,50),$FF7070F0);

 //lines
 softdrawline(surf,0,100,W-1,100,$00FF00,255);
 check('hline',softgetpixel(surf,200,100),$FF00FF00);
 check('hline end',softgetpixel(surf,W-1,100),$FF00FF00);
 softdrawline(surf,200,110,200,190,$0000FF,255);
 check('vline',softgetpixel(surf,200,150),$FF0000FF);
 softdrawline(surf,0,0,99,99,$000000,255);
 check('diagonal middle',softgetpixel(surf,50,50),$FF000000);
 check('diagonal start',softgetpixel(surf,0,0),$FF000000);
 check('diagonal end',softgetpixel(surf,99,99),$FF000000);
 softdrawline(surf,99,0,0,99,$000000,255);   //reverse direction
 check('anti diagonal',softgetpixel(surf,50,49),$FF000000);

 //point
 softdrawpoint(surf,300,200,$123456,255);
 check('point',softgetpixel(surf,300,200),$FF123456);

 //clip
 softsetclip(surf,softrect(100,150,50,50));
 softfillrect(surf,softrect(0,120,W,170),$FFFF00,255);
 check('clip inside',softgetpixel(surf,120,170),$FFFFFF00);
 check('clip left',softgetpixel(surf,99,170),$FFE0E0E0);
 check('clip right',softgetpixel(surf,150,170),$FFE0E0E0);
 check('clip above',softgetpixel(surf,120,149),$FFE0E0E0);
 softresetclip(surf);

 //rectangle partly outside of the surface must not crash
 softfillrect(surf,softrect(-10,-10,20,20),$808080,255);
 check('outside rect',softgetpixel(surf,0,0),$FF808080);
 softfillrect(surf,softrect(W-5,H-5,20,20),$808080,255);
 check('outside rect 2',softgetpixel(surf,W-1,H-1),$FF808080);

 //copy
 softcopy(surf,200,200,surf,softrect(10,10,50,30),false);
 //dest (210,205) comes from source (20,15), plain red (the diagonal line
 //crosses (20,20), so that pixel is not used)
 check('copy',softgetpixel(surf,210,205),$FFFF0000);
 //overlapping copy in the same surface, moving down and right
 softcopy(surf,205,205,surf,softrect(200,200,50,30),false);
 check('overlap copy',softgetpixel(surf,215,210),$FFFF0000);
 //source (249,229) = original (59,39) = red with the half blue over it
 check('overlap copy end',softgetpixel(surf,254,234),$FF7F0080);

 //copy with blending of a half transparent source
 wrapped:= createsoftsurface(10,10);
 softclear(wrapped,0);
 softfillrect(wrapped,softrect(0,0,10,10),$FFFFFF,128);   //a=128 on a=255 clear
 //the clear made it opaque, make a pixel with alpha 128 explicitly
 pcardinal(wrapped^.pixels)^:= $80FFFFFF;
 softfillrect(surf,softrect(300,250,10,10),$000000,255);
 softcopy(surf,300,250,wrapped,softrect(0,0,10,10),true);
 //white with alpha 128 over black: 128*255+127/255 = 128
 check('copy blend',softgetpixel(surf,300,250),$FF808080);
 freesoftsurface(wrapped);

 //mask, first mask row opaque
 fillchar(mask,sizeof(mask),0);
 for i:= 0 to 7 do begin
  mask[i]:= 255;
 end;
 softblendmask(surf,300,50,@mask[0],8,8,true,$0000FF);   //bottom up
 check('mask bottomup bottom row',softgetpixel(surf,300,57),$FF0000FF);
 check('mask bottomup top row',softgetpixel(surf,300,50),$FFE0E0E0);
 softblendmask(surf,330,50,@mask[0],8,8,false,$0000FF);
 check('mask top row',softgetpixel(surf,330,50),$FF0000FF);
 check('mask bottom row',softgetpixel(surf,330,57),$FFE0E0E0);
 //half transparent mask
 fillchar(mask,sizeof(mask),128);
 softblendmask(surf,360,50,@mask[0],8,8,false,$000000);
 //black alpha 128 over E0: (0*128+224*127+127)/255 = 112 = $70
 check('mask half',softgetpixel(surf,360,50),$FF707070);

 //read pixels incl. area outside of the surface
 softreadpixels(surf,softrect(-1,-1,2,2),@buf[0],8);
 check('read outside',buf[0],0);
 check('read inside',buf[3],softgetpixel(surf,0,0));
 softreadpixels(surf,softrect(10,15,10,10),@ext[0],40);
 check('read rect',ext[0],$FFFF0000);

 //wrapping of foreign memory
 wrapped:= wrapsoftsurface(@ext[0],10,10,40);
 softfillrect(wrapped,softrect(0,0,10,10),$00FF00,255);
 check('wrapped',ext[55],$FF00FF00);
 freesoftsurface(wrapped);

 //scaled copy: 2x2 source -> 4x4, every source pixel becomes a 2x2 block
 wrapped:= createsoftsurface(2,2);
 pcardinal(wrapped^.pixels)^:= $FF0000FF;                    //(0,0) blue
 (pcardinal(wrapped^.pixels) + 1)^:= $FF00FF00;              //(1,0) green
 (pcardinal(wrapped^.pixels) + 2)^:= $FFFF0000;              //(0,1) red
 (pcardinal(wrapped^.pixels) + 3)^:= $FFFFFFFF;              //(1,1) white
 softcopyscaled(surf,softrect(100,250,4,4),wrapped,softrect(0,0,2,2),false);
 check('scaled 0,0',softgetpixel(surf,100,250),$FF0000FF);
 check('scaled 1,1',softgetpixel(surf,101,251),$FF0000FF);
 check('scaled 2,0',softgetpixel(surf,102,250),$FF00FF00);
 check('scaled 0,2',softgetpixel(surf,100,252),$FFFF0000);
 check('scaled 3,3',softgetpixel(surf,103,253),$FFFFFFFF);
 freesoftsurface(wrapped);

 //resize keeps the overlapping content
 wrapped:= createsoftsurface(4,4);
 softfillrect(wrapped,softrect(0,0,4,4),$112233,255);
 softresize(wrapped,6,2);
 check('resize kept',softgetpixel(wrapped,3,1),$FF112233);
 check('resize new area',softgetpixel(wrapped,5,1),0);
 check('resize width',longword(wrapped^.width),6);
 check('resize height',longword(wrapped^.height),2);
 freesoftsurface(wrapped);

 writebmp('softtest.bmp',surf);
 freesoftsurface(surf);
 writeln(checks - fails,' of ',checks,' checks passed, softtest.bmp written');
 if fails <> 0 then begin
  halt(1);
 end;
end.
