{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefiledialogres;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseclasses,msebitmap,msegui,msedatamodules;

type
 filedialogiconty = (fdi_dir,fdi_diropen,fdi_file,fdi_direntry);
 tfiledialogres = class(tmsedatamodule)
  images: timagelist;
 public
  procedure getfileicon(const aimage: filedialogiconty; var imagelist: timagelist;
                   out imagenr: integer);
 end;

function filedialogres: tfiledialogres;

implementation

uses
 msefiledialogres_mfm,sysutils;
var
 ffiledialogres: tfiledialogres;

function filedialogres: tfiledialogres;
begin
 result:= ffiledialogres;
end;

{ tfiledialogres }

procedure tfiledialogres.getfileicon(const aimage: filedialogiconty;
  var imagelist: timagelist; out imagenr: integer);
begin
 if imagelist = nil then begin
  imagelist:= images;
 end;
 imagenr:= ord(aimage);
end;

initialization
 application; //create application instance
 createmodule(nil,tfiledialogres,ffiledialogres);
finalization
 freeandnil(ffiledialogres);
end.
