{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedataimage;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,msegui,mseimage,msewidgetgrid,msegrids,msedatalist,msegraphutils,
 msegraphics,mseclasses,mseeditglob,msebitmap,msemenus,mseevent;
 
type
 tcustomdataimage = class(timage,igridwidget)
  private
   fonchange: notifyeventty;
   fformat: string;
   fgridsetting: integer;
   procedure setvalue(const avalue: string);
   procedure setformat(const avalue: string);
   procedure checkgrid;
   function getgridvalue(const index: integer): string;
   procedure setgridvalue(const index: integer; const avalue: string);   
  protected
   fgridintf: iwidgetgrid;
   function getgridintf: iwidgetgrid;
   //igridwidget
   procedure initgridwidget; virtual;
   function getoptionsedit: optionseditty;
   procedure setfirstclick;
   function createdatalist(const sender: twidgetcol): tdatalist; virtual;
   function getdatatyp: datatypty;
   function getdefaultvalue: pointer;
   function getrowdatapo(const info: cellinfoty): pointer; virtual;
   procedure setgridintf(const intf: iwidgetgrid);
   function getcellframe: framety;
   procedure loadcellbmp(const acanvas: tcanvas; const abmp: tmaskedbitmap); virtual;
   procedure drawcell(const canvas: tcanvas);
   procedure valuetogrid(const row: integer); virtual;
   procedure gridtovalue(const row: integer); virtual;
   procedure docellevent(const ownedcol: boolean; var info: celleventinfoty); virtual;
   procedure sortfunc(const l,r; var result: integer); virtual;
   procedure gridvaluechanged(const index: integer); virtual;
   procedure updatecoloptions(var aoptions: coloptionsty);
   procedure statdataread; virtual;
   procedure griddatasourcechanged; virtual;
  public
   function seteditfocus: boolean;
   procedure changed; override;
   property value: string write setvalue;
   property gridvalue[const index: integer]: string read getgridvalue 
                             write setgridvalue;
   property format: string read fformat write setformat;
   property onchange: notifyeventty read fonchange write fonchange;
 end;

 tdataimage = class(tcustomdataimage)
  published
   property value;
   property format;
 end;
   
implementation
uses
 msestream,sysutils;
  
{ tcustomdataimage }

procedure tcustomdataimage.setvalue(const avalue: string);
begin
 if (fgridintf <> nil) and not (csdesigning in componentstate) then begin
  inc(fgridsetting);
  try
   fgridintf.setdata(fgridintf.getrow,avalue);
  finally
   dec(fgridsetting);
  end;
 end;
 try
  bitmap.loadfromstring(avalue,fformat);
 except
  bitmap.clear;
 end;
 changed;
end;

function tcustomdataimage.seteditfocus: boolean;
begin
 if fgridintf = nil then begin
  if canfocus then begin
   setfocus;
  end;
 end
 else begin
  with fgridintf.getcol do begin
   grid.col:= index;
   if grid.canfocus then begin
    if not focused then begin
     grid.setfocus;
    end;
   end; 
  end;
 end;
 result:= focused;
end;

procedure tcustomdataimage.changed;
begin
 inherited;
 if not (ws_loadedproc in fwidgetstate) and canevent(tmethod(fonchange)) then begin
  fonchange(self);
 end;
end;

procedure tcustomdataimage.setfirstclick;
begin
 //dummy
end;

function tcustomdataimage.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tansistringdatalist.create;
end;

function tcustomdataimage.getdatatyp: datatypty;
begin
 result:= dl_ansistring;
end;

function tcustomdataimage.getdefaultvalue: pointer;
begin
 result:= nil;
end;

function tcustomdataimage.getrowdatapo(const info: cellinfoty): pointer;
begin
 result:= nil;
end;

procedure tcustomdataimage.setgridintf(const intf: iwidgetgrid);
begin
 fgridintf:= intf;
end;

function tcustomdataimage.getcellframe: framety;
begin
 result:= getinnerstframe;
end;

procedure tcustomdataimage.loadcellbmp(const acanvas: tcanvas;
                                            const abmp: tmaskedbitmap);
begin
 with cellinfoty(acanvas.drawinfopo^) do begin
  abmp.loadfromstring(string(datapo^),fformat);
 end;
end;

procedure tcustomdataimage.drawcell(const canvas: tcanvas);
var
 bmp: tmaskedbitmap;
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  if (datapo <> nil) and (string(datapo^) <> '') then begin
   bmp:= tmaskedbitmap.create(bitmap.monochrome);
   try
    with bitmap do begin
     bmp.alignment:= alignment;
     bmp.options:= options;
     bmp.transparency:= transparency;
     bmp.transparentcolor:= transparentcolor;
    end;
    loadcellbmp(canvas,bmp);
    paintbmp(canvas,bmp,innerrect);
   except;
   end;
   bmp.free;
  end;
 end;
end;

procedure tcustomdataimage.valuetogrid(const row: integer);
begin
 //dummy
end;

procedure tcustomdataimage.gridtovalue(const row: integer);
var
 str1: string;
begin
 if fgridsetting = 0 then begin
  fgridintf.getdata(row,str1);
  value:= str1;
 end;
end;

procedure tcustomdataimage.docellevent(const ownedcol: boolean;
               var info: celleventinfoty);
begin
 //dummy
end;

procedure tcustomdataimage.sortfunc(const l; const r; var result: integer);
begin
 //dummy
end;

procedure tcustomdataimage.gridvaluechanged(const index: integer);
begin
end;

procedure tcustomdataimage.updatecoloptions(var aoptions: coloptionsty);
begin
 //dummy
end;

procedure tcustomdataimage.statdataread;
begin
 //dummy
end;

procedure tcustomdataimage.griddatasourcechanged;
begin
 //dummy
end;

function tcustomdataimage.getoptionsedit: optionseditty;
begin
 result:= [oe_readonly];
end;

procedure tcustomdataimage.initgridwidget;
begin
 //dummy
end;

procedure tcustomdataimage.setformat(const avalue: string);
begin
 fformat:= avalue;
end;

procedure tcustomdataimage.checkgrid;
begin
 if fgridintf = nil then begin
  raise exception.Create('No grid.');
 end;
 if fgridintf.getcol = nil then begin
  raise exception.Create('No datalist.');
 end;
end;

function tcustomdataimage.getgridvalue(const index: integer): string;
begin
 checkgrid;
 fgridintf.getdata(index,result);
end;

procedure tcustomdataimage.setgridvalue(const index: integer;
               const avalue: string);
begin
 checkgrid;
 fgridintf.setdata(index,avalue);
end;

function tcustomdataimage.getgridintf: iwidgetgrid;
begin
 result:= fgridintf;
end;

end.
