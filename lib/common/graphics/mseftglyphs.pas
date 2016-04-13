{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseftglyphs;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msefreetype,msestrings,msebitmap,msetypes,msegraphutils;
 
type
 tftglyphs = class
  private
   fftface: pft_face;
  protected
   fheight: int32;
   fascent: int32;
   fdescent: int32;
   fglyphheight: int32;
   flinespacing: int32;
   function internalgetglyph(const abitmap: tmaskedbitmap; const achar: card32; 
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
                             const aframe: framety;
                                const acolor: colorty = cl_text): boolean;
                         //empty bitmap in case of error, retruns true if ok
   function getcell(const abitmap: tmaskedbitmap; const achar: card32;
                                const acolor: colorty = cl_text): boolean;
                         //empty bitmap in case of error, retruns true if ok
   function getcell(const abitmap: tmaskedbitmap; const achar: card32;
                             const aframe: framety;
                                const acolor: colorty = cl_text): boolean;
                         //empty bitmap in case of error, retruns true if ok
 end;

implementation
uses
 msefileutils,sysutils,math;
 
{ tftglyphs }

constructor tftglyphs.create(const afontfile: filenamety;
                             const afontindex: int32; const aheight: int32);
var
 scale: real;
begin
 fheight:= aheight;
 initializefreetype([]);
 if ft_new_face(ftlib,pchar(ansistring(tosysfilepath(afontfile))),
                                              afontindex,fftface) = 0 then begin
  if ft_set_pixel_sizes(fftface,0,aheight) <> 0 then begin
   raise exception.create('Can not set font height '+inttostr(aheight));
  end;
  with fftface^ do begin
   scale:= fheight/units_per_em;
   fascent:= round(ascender*scale);
   fdescent:= -round(descender*scale);
   fglyphheight:= fascent+fdescent;
   flinespacing:= ceil(height*scale);
  end;
 end
 else begin
  raise exception.create('Can not load font "'+ansistring(afontfile)+'"');
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
                             const achar: card32; const aframe: framety;
                         const acolor: colorty; const acell: boolean): boolean;
var
 so,de: pbyte;
 i1,i2,step: int32;
 sourcestart: pointty;
 sourcesize: sizety;
 destsize: sizety;
 deststart: pointty;
begin
 result:= false;
 abitmap.beginupdate();
 abitmap.clear();
 if ft_load_glyph(fftface,ft_get_char_index(fftface,ord(achar)),
                                          ft_load_default) = 0 then begin
  if ft_render_glyph(fftface^.glyph,ft_render_mode_normal) = 0 then begin
   abitmap.options:= [bmo_masked,bmo_graymask];
   with fftface^.glyph^.bitmap do begin //todo: check bitmap format
    if (width > 0) and (rows > 0) then begin
     sourcesize.cx:= width;
     sourcesize.cy:= rows;
     if acell then begin
      destsize.cx:= (fftface^.glyph^.advance.x + 32) div 64;
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
     if (destsize.cx > 0) and (destsize.cx > 0) then begin
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
     {
       abitmap.size:= ms((fftface^.glyph^.advance.x + 32) div 64,fglyphheight);
       de:= abitmap.mask.scanline[fascent-fftface^.glyph^.bitmap_top];
       if rows1 > abitmap.height then begin
        rows1:= abitmap.height;
       end;
       if width1 > abitmap.width then begin
        width1:= abitmap.width;
       end;
      end
      else begin
       abitmap.size:= ms(width,rows);
       de:= abitmap.mask.scanline[0];
      end;
      }
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
 abitmap.endupdate();
end;

function tftglyphs.getglyph(const abitmap: tmaskedbitmap; const achar: card32;
               const acolor: colorty = cl_text): boolean;
begin
 result:= internalgetglyph(abitmap,achar,nullframe,acolor,false);
end;

function tftglyphs.getglyph(const abitmap: tmaskedbitmap; const achar: card32;
               const aframe: framety;
               const acolor: colorty = cl_text): boolean;
begin
 result:= internalgetglyph(abitmap,achar,aframe,acolor,false);
end;

function tftglyphs.getcell(const abitmap: tmaskedbitmap; const achar: card32;
               const acolor: colorty = cl_text): boolean;
begin
 result:= internalgetglyph(abitmap,achar,nullframe,acolor,true);
end;

function tftglyphs.getcell(const abitmap: tmaskedbitmap; const achar: card32;
               const aframe: framety;
               const acolor: colorty = cl_text): boolean;
begin
 result:= internalgetglyph(abitmap,achar,aframe,acolor,true);
end;

end.
