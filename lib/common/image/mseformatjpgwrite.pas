{ MSEgui Copyright (c) 2006-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseformatjpgwrite;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
const
 jpglabel = 'jpeg';
procedure registerformat;

implementation
uses
 classes,mclasses,msegraphics,msebitmap,msefpreadjpeg,msegraphicstream,
 msestream,msefpwritejpeg,sysutils,typinfo;

procedure writegraphic(const dest: tstream;
                               const source: tobject; const format: string;
                               const params: array of const);
                            //[compressionquality: integer] 0..100, default 75
var
 ima: tmsefpmemoryimage;
 writer: tfpwriterjpeg;
begin
 try
  ima:= tmsefpmemoryimage.create(0,0);
  ima.assign(tpersistent(source));
  writer:= tfpwriterjpeg.create;
  if (length(params) > 0) and (tvarrec(params[0]).vtype = vtinteger) then begin
   writer.compressionquality:= tvarrec(params[0]).vinteger;
  end;
  ima.writetostream(dest,writer);
 finally
  ima.free;
 end;
end;

procedure registerformat;
begin
 registergraphicformat(jpglabel,nil,{$ifdef FPC}@{$endif}writegraphic,
       'JPEG_Image',['*.jpg','*.jpeg']);
end;

initialization
 registerformat();
end.
