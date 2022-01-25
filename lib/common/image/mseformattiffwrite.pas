{ MSEgui Copyright (c) 2012-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseformattiffwrite;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
const
 tifflabel = 'tif';
procedure registerformat;

implementation
uses
 classes,mclasses,msegraphics,msebitmap,msefpwritetiff,msegraphicstream,
 msefpimage;

//
// todo: -TFPWriterTiff writes a black image, maybe it needs initialization
//       -add parameter
//
procedure writegraphic(const dest: tstream;
                               const source: tobject; const format: string;
                               const params: array of const);
                 //no params up to now
var
 ima: tmsefpmemoryimage;
 writer: tfpwritertiff;
begin
 try
  ima:= tmsefpmemoryimage.create(0,0);
  ima.assign(tpersistent(source));
  writer:= tfpwritertiff.create;
  ima.writetostream(dest,writer);
 finally
  ima.free;
 end;
end;

procedure registerformat;
begin
 registergraphicformat(tifflabel,nil,{$ifdef FPC}@{$endif}writegraphic,
        'TIFF_Image',['*.tif','*.tiff']);
end;

initialization
 registerformat();
end.
