{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseftglyphs;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 msefreetype,msestrings,msebitmap,msetypes,msegraphutils;
 
type
 tftglyphs = class
  private
   fftface: pft_face;
   procedure setheight(const avalue: int32);
  protected
   fheight: int32;
   fascent: int32;
   fascent64: int32;
   fdescent: int32;
   fglyphheight: int32;
   flinespacing: int32;
   function internalgetglyph(const abitmap: tmaskedbitmap;
                       const achar: card32; const arot: real;
                       const aframe: framety; const acolor: colorty; 
                                                 const acell: boolean): boolean;
  public
   constructor create(const afontfile: filenamety; const afontindex: int32; 
                                        const aheight: int32); //pixels
   destructor destroy(); override;

   function getglyph(const abitmap: tmaskedbitmap; const achar: card32;
                                const acolor: colorty = cl_text): boolean;
                         //empty bitmap in case of error, retruns true if ok
   function getglyph(const abitmap: tmaskedbitmap; const achar: card32;
                             const aframe: framety; //padding
                                const acolor: colorty = cl_text): boolean;
                         //empty bitmap in case of error, retruns true if ok
   function getglyph(const abitmap: tmaskedbitmap; const achar: card32;
                             const arotation: real; //0.0..1.0 -> 0..360deg CCW
                             const aframe: framety; //padding
                                const acolor: colorty = cl_text): boolean;
                         //empty bitmap in case of error, retruns true if ok
   function getcell(const abitmap: tmaskedbitmap; const achar: card32;
                                const acolor: colorty = cl_text): boolean;
                         //empty bitmap in case of error, retruns true if ok
   function getcell(const abitmap: tmaskedbitmap; const achar: card32;
                             const aframe: framety; //padding
                                const acolor: colorty = cl_text): boolean;
                         //empty bitmap in case of error, retruns true if ok
   function getcell(const abitmap: tmaskedbitmap; const achar: card32;
                             const arotation: real; //0.0..1.0 -> 0..360deg CCW
                             const aframe: framety; //padding
                                const acolor: colorty = cl_text): boolean;
                         //empty bitmap in case of error, retruns true if ok
   property height: int32 read fheight write setheight;
   property ascent: int32 read fascent;
   property descent: int32 read fdescent;
   property glyphheight: int32 read fglyphheight;
   property linespacing: int32 read flinespacing;
 end;

implementation
uses
 msefileutils,sysutils,math;
 
{ tftglyphs }

constructor tftglyphs.create(const afontfile: filenamety;
                             const afontindex: int32; const aheight: int32);
begin
 initializefreetype([]);
 if ft_new_face(ftlib,pchar(ansistring(tosysfilepath(afontfile))),
                                              afontindex,fftface) = 0 then begin
  fheight:= -1; //force loading of 0
  height:= aheight;
 end
 else begin
  raise exception.create('Can not load font "'+ansistring(afontfile)+'"');
 end;
end;

procedure tftglyphs.setheight(const avalue: int32);
var
 scale: real;
begin
 if fheight <> avalue then begin
  fheight:= avalue;
  if ft_set_pixel_sizes(fftface,0,avalue) <> 0 then begin
   raise exception.create('Can not set font height '+inttostr(fheight));
  end;
  with fftface^ do begin
   scale:= fheight/units_per_em;
   fascent64:= round(ascender*scale*64); //for transformation matrix
   fascent:= (fascent64 + 32) div 64; //pixels
   fdescent:= -round(descender*scale);
   fglyphheight:= fascent+fdescent;
   flinespacing:= ceil(height*scale);
  end;
 end;
end;

destructor tftglyphs.destroy();
begin
 if fftface <> nil then begin
  ft_done_face(fftface);
 end;
 releasefreetype();
end;

function tftglyphs.internalgetglyph(const abitmap: tmaskedbitmap;
               const achar: card32; const arot: real; const aframe: framety;
                         const acolor: colorty; const acell: boolean): boolean;
const
 numscale = $10000; //for 16.16 ft number
var
 so,de: pbyte;
 i1,i2,step: int32;
 sourcestart: pointty;
 sourcesize: sizety;
 destsize: sizety;
 deststart: pointty;
 mat1: ft_matrix;
 vec1: ft_vector;
 rea1: real;
 fcos1,fsin1: real;
 cos1,sin1: int32;
 charindex1: int32;
 centre1: pointty;
label
 endlab;
begin
 result:= false;
 abitmap.beginupdate();
 abitmap.clear();
 charindex1:= ft_get_char_index(fftface,ord(achar));
 if arot <> 0 then begin
  rea1:= 2*pi*arot;
  fcos1:= cos(rea1);
  fsin1:= sin(rea1);
  cos1:= round(fcos1*numscale);
  sin1:= round(fsin1*numscale);
  mat1.xx:= cos1;
  mat1.xy:= -sin1;
  mat1.yx:= sin1;
  mat1.yy:= cos1;
  if acell then begin
   ft_set_transform(fftface,nil,nil);
   if ft_load_glyph(fftface,charindex1,ft_load_default) <> 0 then begin
    goto endlab;
   end;
   with fftface^.glyph^.metrics do begin
//    centre1.x:= width div 2 - horibearingx;
    centre1.x:= horiadvance div 2;
//    centre1.y:= horibearingy - height div 2 ;
    centre1.y:= fascent64 - fheight * 32;
    vec1.x:= -round(centre1.x*fcos1 - centre1.y*fsin1) + centre1.x;
    vec1.y:= -round(centre1.x*fsin1 + centre1.y*fcos1) + centre1.y;
   end;
   ft_set_transform(fftface,@mat1,@vec1);
  end
  else begin
   ft_set_transform(fftface,@mat1,nil);
  end;
 end
 else begin
  ft_set_transform(fftface,nil,nil);
 end;
 if ft_load_glyph(fftface,charindex1,ft_load_default) = 0 then begin
  if ft_render_glyph(fftface^.glyph,ft_render_mode_normal) = 0 then begin
   abitmap.options:= abitmap.options + [bmo_masked,bmo_graymask];
   with fftface^.glyph^.bitmap do begin //todo: check bitmap format
    if (width > 0) and (rows > 0) then begin
     sourcesize.cx:= width;
     sourcesize.cy:= rows;
     if acell then begin
//      destsize.cx:= (fftface^.glyph^.advance.x + 32) div 64;
      with fftface^.glyph^.metrics do begin
       destsize.cx:= (horiadvance + 32) div 64;
      end;
      destsize.cy:= fglyphheight;
      deststart.x:= aframe.left + fftface^.glyph^.bitmap_left;
      deststart.y:= aframe.top + fascent - fftface^.glyph^.bitmap_top;
     end
     else begin
      destsize:= sourcesize;
      deststart:= pointty(aframe.topleft);
     end; 
     destsize.cx:= destsize.cx + aframe.left + aframe.right;
     destsize.cy:= destsize.cy + aframe.top + aframe.bottom;
     if (destsize.cx > 0) and (destsize.cx > 0) and 
                         (deststart.x < destsize.cx) and 
                                   (deststart.y < destsize.cy) then begin
      abitmap.size:= destsize;
      sourcestart.x:= 0;
      if deststart.x < 0 then begin
       sourcestart.x:= -deststart.x;
       sourcesize.cx:= sourcesize.cx + deststart.x;
       deststart.x:= 0;
      end;
      sourcestart.y:= 0;
      if deststart.y < 0 then begin
       sourcestart.y:= -deststart.y;
       sourcesize.cy:= sourcesize.cy + deststart.y;
       deststart.y:= 0;
      end;
      if deststart.x + sourcesize.cx > destsize.cx then begin
       sourcesize.cx:= destsize.cx - deststart.x;
      end;
      if deststart.y + sourcesize.cy > destsize.cy then begin
       sourcesize.cy:= destsize.cy - deststart.y;
      end;
      abitmap.size:= destsize;
      abitmap.mask.init(0);
      de:= abitmap.mask.scanline[deststart.y] + deststart.x;
      abitmap.init(acolor);
      if pitch < 0 then begin
       so:= buffer+(rows-1-sourcestart.y)*pitch;
      end
      else begin
       so:= buffer+sourcestart.y*pitch;
      end;
      so:= so + sourcestart.x;
      step:= abitmap.mask.scanlinestep;
      for i1:= sourcesize.cy - 1 downto 0 do begin
       for i2:= sourcesize.cx-1 downto 0 do begin
        de[i2]:= so[i2];
       end;
       so:= so + pitch;
       de:= de + step;
      end;
     end;
    end;
    end;
   result:= true;
  end;
 end;
endlab:
 abitmap.endupdate();
end;

function tftglyphs.getglyph(const abitmap: tmaskedbitmap; const achar: card32;
               const acolor: colorty = cl_text): boolean;
begin
 result:= internalgetglyph(abitmap,achar,0.0,nullframe,acolor,false);
end;

function tftglyphs.getglyph(const abitmap: tmaskedbitmap; const achar: card32;
               const aframe: framety;
               const acolor: colorty = cl_text): boolean;
begin
 result:= internalgetglyph(abitmap,achar,0.0,aframe,acolor,false);
end;

function tftglyphs.getglyph(const abitmap: tmaskedbitmap; const achar: card32;
               const arotation: real; const aframe: framety;
               const acolor: colorty = cl_text): boolean;
begin
 result:= internalgetglyph(abitmap,achar,arotation,aframe,acolor,false);
end;

function tftglyphs.getcell(const abitmap: tmaskedbitmap; const achar: card32;
               const acolor: colorty = cl_text): boolean;
begin
 result:= internalgetglyph(abitmap,achar,0.0,nullframe,acolor,true);
end;

function tftglyphs.getcell(const abitmap: tmaskedbitmap; const achar: card32;
               const aframe: framety;
               const acolor: colorty = cl_text): boolean;
begin
 result:= internalgetglyph(abitmap,achar,0.0,aframe,acolor,true);
end;

function tftglyphs.getcell(const abitmap: tmaskedbitmap; const achar: card32;
               const arotation: real; const aframe: framety;
               const acolor: colorty = cl_text): boolean;
begin
 result:= internalgetglyph(abitmap,achar,arotation,aframe,acolor,true);
end;

end.
