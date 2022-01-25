{ MSEgui Copyright (c) 2006-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseformatpngwrite;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
const
 pnglabel = 'png';
procedure registerformat;

implementation
uses
 classes,mclasses,msegraphics,msebitmap,msefpwritepng,msegraphicstream,
 msefpimage;

procedure writegraphic(const dest: tstream;
                               const source: tobject; const format: string;
                               const params: array of const);
                               //[grayscale      (default false),
                               // indexed        (default false),
                               // compressedtext (default true),
                               // wordsized      (default false),
                               // usealpha       (default source): boolean]
var
 ima: tmsefpmemoryimage;
 writer: tfpwriterpng;
 col1: tfpcolor;
begin
 try
  ima:= tmsefpmemoryimage.create(0,0);
  ima.assign(tpersistent(source));
  writer:= tfpwriterpng.create;
  writer.grayscale:= false;
  writer.indexed:= false;
  writer.compressedtext:= true;
  writer.wordsized:= false;
  writer.usealpha:= ima.hasalpha;
  if (length(params) > 0) and (tvarrec(params[0]).vtype = vtboolean) then begin
   writer.grayscale:= tvarrec(params[0]).vboolean;
   if (length(params) > 1) and (tvarrec(params[1]).vtype = vtboolean) then begin
    writer.indexed:= tvarrec(params[1]).vboolean;
    if (length(params) > 2) and (tvarrec(params[2]).vtype = vtboolean) then begin
     writer.compressedtext:= tvarrec(params[2]).vboolean;
     if (length(params) > 3) and (tvarrec(params[3]).vtype = vtboolean) then begin
      writer.wordsized:= tvarrec(params[3]).vboolean;
      if (length(params) > 4) and (tvarrec(params[4]).vtype = vtboolean) then begin
       writer.usealpha:= tvarrec(params[4]).vboolean;
      end;
     end;
    end;
   end;
  end;
  with ima do begin
   if hasalpha and monoalpha then begin
    if (height <> 0) and (width <> 0) then begin
     col1:= colors[0,0];         //force mode 4
     if col1.alpha = 0 then begin
      col1.alpha:= 1;
     end
     else begin
      col1.alpha:= $fffe;
     end;
     colors[0,0]:= col1;
    end;
   end;
  end;
  ima.writetostream(dest,writer);
 finally
  ima.free;
 end;
end;

procedure registerformat;
begin
 registergraphicformat(pnglabel,nil,{$ifdef FPC}@{$endif}writegraphic,
    'PNG_Image',['*.png']);
end;

initialization
 registerformat();
end.
