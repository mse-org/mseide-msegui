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
  public
   constructor create(const afontfile: filenamety; const afontindex: int32; 
                                        const aheight: int32); //pixels
   destructor destroy(); override;
   function getglyph(const abitmap: tmaskedbitmap; const achar: card32;
                              const acolor: colorty = cl_text): boolean;
                         //empty bitmap in case of error, retruns true if ok
 end;

implementation
uses
 msefileutils,sysutils;
 
{ tftglyphs }

constructor tftglyphs.create(const afontfile: filenamety;
                             const afontindex: int32; const aheight: int32);
begin
 initializefreetype([]);
 if ft_new_face(ftlib,pchar(ansistring(tosysfilepath(afontfile))),
                                              afontindex,fftface) = 0 then begin
  if ft_set_pixel_sizes(fftface,0,aheight) <> 0 then begin
   raise exception.create('Can not set font height '+inttostr(aheight));
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

function tftglyphs.getglyph(const abitmap: tmaskedbitmap; const achar: card32;
                                     const acolor: colorty = cl_text): boolean;
var
 so,de: pbyte;
 i1,i2,step: int32;
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
     abitmap.size:= ms(width,rows);
     abitmap.init(acolor);
     if pitch < 0 then begin
      so:= buffer+(rows-1)*pitch;
     end
     else begin
      so:= buffer;
     end;
     step:= abitmap.mask.scanlinestep;
     de:= abitmap.mask.scanline[0];
     for i1:= rows - 1 downto 0 do begin
      for i2:= width-1 downto 0 do begin
       de[i2]:= so[i2];
      end;
      so:= so + pitch;
      de:= de + step;
     end;
    end;
   end;
   result:= true;
  end;
 end;
 abitmap.endupdate();
end;

end.
