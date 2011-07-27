{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefcfontselect;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msegraphics,msetypes,msefontconfig;

const
 highresfontshift = 6;  //64
 highresfontfakt = 1 shl highresfontshift;
 highresfontmask = highresfontfakt - 1; 

type
 fontnamety = (
      fn_foundry,fn_family_name,fn_weight_name,fn_slant,fn_setwidth_name,
      fn_addstyle_name,fn_pixel_size,fn_point_size,fn_resolution_x,
      fn_resolution_y,fn_spacing,fn_average_width,fn_charset_registry,
      fn_encoding);
 fontinfoty = array[fontnamety] of string;
 
procedure setupfontinfo(const fontdata: fontdataty; var fontinfo: fontinfoty);
procedure setfontinfoname(const aname: string; var ainfo: fontinfoty);
function buildxftpat(const fontdata: fontdataty; 
               const fontinfo: fontinfoty; const highres: boolean): pfcpattern;
function getfcfontfile(const ainfo: getfontinfoty; out filename: string;
                          out index: integer; out height: integer): boolean;

var
 defaultfontinfo: fontinfoty;
 
implementation
uses
 sysutils,msestrings,msegraphutils,msectypes;

procedure setfontinfoname(const aname: string; var ainfo: fontinfoty);
var
 ar1: stringarty;
begin
 ar1:= splitstring(aname,':');
 if (high(ar1) = 1) and (ar1[0] <> '') and (ar1[1] <> '') then begin
  ainfo[fn_foundry]:= ar1[0];
  ainfo[fn_family_name]:= ar1[1];
 end
 else begin
  ainfo[fn_family_name]:= aname;
 end;
end;
 
procedure setupfontinfo(const fontdata: fontdataty; var fontinfo: fontinfoty);
var
 ar1: stringarty;
 height1,width1: integer;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 ar1:= nil; //compiler warning;
 fontinfo:= defaultfontinfo;
 with pfontdataty(@fontdata)^ do begin
  height1:= (h.d.height + fontsizeroundvalue) shr fontsizeshift;
  width1:= (h.d.width + fontsizeroundvalue) shr fontsizeshift;
  if height1 <> 0 then begin
   fontinfo[fn_pixel_size]:= inttostr(height1);
  end;
  if width1 <> 0 then begin
   fontinfo[fn_average_width]:= inttostr(width1);
  end;
  if h.charset <> '' then begin
   ar1:= splitstring(h.charset,'-');
   fontinfo[fn_charset_registry]:= ar1[0];
   if high(ar1) > 0 then begin
    fontinfo[fn_encoding]:= ar1[1];
   end;
  end;
  if h.name <> '' then begin
   setfontinfoname(h.name,fontinfo);
  end
  else begin
  end;
  if fs_bold in h.d.style then begin
   fontinfo[fn_weight_name]:= 'bold';
  end;
  if fs_italic in h.d.style then begin
   fontinfo[fn_slant]:= 'i';
  end;
 end;
end;

function buildxftpat(const fontdata: fontdataty; 
                  const fontinfo: fontinfoty; const highres: boolean): pfcpattern;
var
 int1: integer;
 str1: ansistring;
 mat1: tfcmatrix;
 rea1: real;
begin
{$ifdef mse_debuggdisync}
 checkgdilock;
{$endif} 
 with fontdata do begin
  if fontinfo[fn_charset_registry] <> '*' then begin
   str1:= fontinfo[fn_charset_registry];
   if fontinfo[fn_encoding] <> '*' then begin
    str1:= str1 +'-'+fontinfo[fn_encoding];
   end;
   result:= fcnameparse(pansichar(str1));
  end
  else begin
   result:= fcpatterncreate();
  end;
  if fontinfo[fn_foundry] <> '*' then begin
   fcpatternaddstring(result,fc_foundry,pansichar(fontinfo[fn_foundry]));
  end;
  if (h.d.familyoptions = []) then begin
   if (h.d.pitchoptions = []) and (fontinfo[fn_family_name] <> '*') then begin
    fcpatternaddstring(result,fc_family,pansichar(fontinfo[fn_family_name]));
   end;
  end
  else begin
   if foo_helvetica in h.d.familyoptions then begin
    fcpatternaddstring(result,fc_family,'sans');
   end
   else begin
    if foo_roman in h.d.familyoptions then begin
     fcpatternaddstring(result,fc_family,'serif');
    end
    else begin
     if foo_decorative in h.d.familyoptions then begin
     end
     else begin
      if foo_script in h.d.familyoptions then begin
      end;
     end;
    end;
   end;
  end;
  if fs_bold in h.d.style then begin
   fcpatternaddinteger(result,fc_weight,fc_weight_bold);
  end;
  if fs_italic in h.d.style then begin
   fcpatternaddinteger(result,fc_slant,fc_slant_italic);
  end;
  if fontinfo[fn_pixel_size] <> '*' then begin
   try
    rea1:= strtofloat(fontinfo[fn_pixel_size]);
    if highres then begin
     rea1:= rea1 * highresfontfakt;
    end;
    fcpatternadddouble(result,fc_pixel_size,rea1);
   except
   end;
  end;
  if fontinfo[fn_average_width] <> '*' then begin
   try
    int1:= (strtoint(fontinfo[fn_average_width]) + 5) div 10;
    fcpatternaddinteger(result,fc_char_width,int1);
   except
   end;
  end;
  if foo_fixed in h.d.pitchoptions then begin
   fcpatternaddinteger(result,fc_spacing,fc_mono);
  end;
  if foo_proportional in h.d.pitchoptions then begin
   fcpatternaddinteger(result,fc_spacing,fc_proportional);
  end;
  if [foo_antialiased,foo_antialiased2]*h.d.antialiasedoptions <> [] then begin
   fcpatternaddbool(result,fc_antialias,true);
  end;
  if foo_nonantialiased in h.d.antialiasedoptions then begin
   fcpatternaddbool(result,fc_antialias,false);
  end;
  if (h.d.xscale <> 1.0) or (h.d.rotation <> 0) then begin
   fcmatrixinit(mat1);
   mat1.xx:= h.d.xscale;
   if h.d.rotation <> 0 then begin
    fcmatrixrotate(@mat1,cos(h.d.rotation),sin(h.d.rotation));
   end;
   fcpatternaddmatrix(result,fc_matrix,@mat1);
  end;
  {
  if foo_xcore in xcoreoptions then begin
   str1:= str1 + ':core=1';
  end;
  if foo_noxcore in xcoreoptions then begin
   str1:= str1 + ':core=0';
  end;
  }
 end;
end;

function getfcfontfile(const ainfo: getfontinfoty; out filename: string;
                            out index: integer; out height: integer): boolean;
var
 fontinfo: fontinfoty;
 po1,po2: pfcpattern;
 res1: tfcresult;
 po3: pchar;
 int1: integer;
 do1: cdouble;
begin
 result:= false;
 filename:= '';
 index:= 0;
 setupfontinfo(ainfo.fontdata^,fontinfo);
 po1:= buildxftpat(ainfo.fontdata^,fontinfo,false);
 fcconfigsubstitute(nil,po1,fcmatchpattern);
 fcdefaultsubstitute(po1);
 po2:= fcfontmatch(nil,po1,@res1);
 if po2 <> nil then begin
  if fcpatterngetstring(po2,'file',0,@po3) = fcresultmatch then begin
   filename:= po3;
  end;
  if fcpatterngetinteger(po2,'index',0,@int1) = fcresultmatch then begin
   index:= int1;
  end;
  if fcpatterngetdouble(po2,'pixelsize',0,@do1) = fcresultmatch then begin
   height:= round(do1);
  end
  else begin
   if fontinfo[fn_pixel_size] <> '' then begin
    height:= strtoint(fontinfo[fn_pixel_size]);
   end
   else begin
    height:= 14;
   end;
  end;
  result:= true;
  fcpatterndestroy(po2);
 end;
 fcpatterndestroy(po1);
end;

end.
