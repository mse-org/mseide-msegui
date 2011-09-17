{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedataimage;
{$ifdef FPC}
 {$mode objfpc}{$h+}{$interfaces corba}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}
interface
uses
 classes,mseguiglob,msegui,mseimage,msewidgetgrid,msegrids,msedatalist,msegraphutils,
 msegraphics,mseclasses,mseeditglob,msebitmap,msemenus,mseevent,msestrings,
 msepointer,msegridsglob{$ifdef mse_with_ifi},mseificomp{$endif},mseglob;
 
type
 tcustomdataimage = class(timage,igridwidget)
  private
   fonchange: notifyeventty;
   fformat: string;
   fgridsetting: integer;
   procedure setformat(const avalue: string);
   procedure checkgrid;
   function getgridvalue(index: integer): string;
   procedure setgridvalue(index: integer; const avalue: string);
   procedure readvalue(stream: tstream);
   procedure writevalue(stream: tstream);
  protected
   fgridintf: iwidgetgrid;
   fgriddatalink: pointer;
   fvalue: string;   //in design mode only
   fcurformat: string;
   procedure setisdb;
   function getgridintf: iwidgetgrid;
   procedure defineproperties(filer: tfiler); override;
   procedure setvalue(const avalue: string); virtual;

  //igridwidget
   procedure initgridwidget; virtual;
   function getoptionsedit: optionseditty;
   procedure setfirstclick;
   procedure setreadonly(const avalue: boolean);
   function createdatalist(const sender: twidgetcol): tdatalist; virtual;
   function getdatatype: listdatatypety;
   function getdefaultvalue: pointer;
   function getrowdatapo(const arow: integer): pointer; virtual;
   procedure setgridintf(const intf: iwidgetgrid);
   function getcellframe: framety;
   function getcellcursor(const arow: integer;
                             const acellzone: cellzonety): cursorshapety;
   procedure updatecellzone(const row: integer; const apos: pointty;
                            var result: cellzonety);
   function getnulltext: msestring;
   procedure loadcellbmp(const acanvas: tcanvas; const abmp: tmaskedbitmap); virtual;
   procedure drawcell(const canvas: tcanvas);
   procedure updateautocellsize(const canvas: tcanvas);
   procedure beforecelldragevent(var ainfo: draginfoty; const arow: integer;
                               var handled: boolean); virtual;
   procedure aftercelldragevent(var ainfo: draginfoty; const arow: integer;
                               var handled: boolean); virtual;
   procedure valuetogrid(row: integer); virtual;
   procedure gridtovalue(row: integer); virtual;
   procedure docellevent(const ownedcol: boolean; var info: celleventinfoty); virtual;
   function sortfunc(const l,r): integer; virtual;
   procedure gridvaluechanged(const index: integer); virtual;
   procedure updatecoloptions(const aoptions: coloptionsty);
   procedure statdataread; virtual;
   procedure griddatasourcechanged; virtual;
   {$ifdef mse_with_ifi}
   function getifilink: tifilinkcomp;
   {$endif}
  public
   constructor create(aowner: tcomponent); override;
   function seteditfocus: boolean;
   procedure changed; override;
   function actualcolor: colorty; override;
   function loadfromstream(const astream: tstream): string;    //returns format
   function loadfromfile(const afilename: filenamety): string; //returns format
   procedure storeimage(const aformat: string;
                                          const params: array of const);
   property value: string write setvalue stored false;
   property gridvalue[index: integer]: string read getgridvalue
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
type
 tsimplebitmap1 = class(tsimplebitmap);
 tcustomwidgetgrid1 = class(tcustomwidgetgrid);
 
{ tcustomdataimage }

constructor tcustomdataimage.create(aowner: tcomponent);
begin
 inherited;
{$warnings off}
 include(tsimplebitmap1(bitmap).fstate,pms_nosave);
{$warnings on}
end;

procedure tcustomdataimage.setvalue(const avalue: string);
var
 int1: integer;
begin
 if (fgridintf <> nil) and not (csdesigning in componentstate) then begin
  inc(fgridsetting);
  try
   int1:= -1;
   fgridintf.setdata(int1,avalue);
  finally
   dec(fgridsetting);
  end;
 end;
 try
  fcurformat:= bitmap.loadfromstring(avalue,fformat);
 except
  fcurformat:= '';
  bitmap.clear;
 end;
 if csdesigning in componentstate then begin
  fvalue:= avalue;
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
 result:= tgridansistringdatalist.create(sender);
end;

function tcustomdataimage.getdatatype: listdatatypety;
begin
 result:= dl_ansistring;
end;

function tcustomdataimage.getdefaultvalue: pointer;
begin
 result:= nil;
end;

function tcustomdataimage.getrowdatapo(const arow: integer): pointer;
begin
 result:= nil;
end;

procedure tcustomdataimage.setgridintf(const intf: iwidgetgrid);
begin
 fgridintf:= intf;
 if fgridintf <> nil then begin
  fgriddatalink:= tcustomwidgetgrid1(fgridintf.getgrid).getgriddatalink;
 end
 else begin
  fgriddatalink:= nil;
 end;
end;

function tcustomdataimage.getcellframe: framety;
begin
 if fframe <> nil then begin
  result:= fframe.cellframe;
 end
 else begin
  result:= nullframe;
 end;
end;

function tcustomdataimage.getcellcursor(const arow: integer;
                                  const acellzone: cellzonety): cursorshapety;
begin
 result:= actualcursor(nullpoint);
end;

procedure tcustomdataimage.updatecellzone(const row: integer; const apos: pointty;
                            var result: cellzonety);
begin
 //dummy
end;

function tcustomdataimage.getnulltext: msestring;
begin
 result:= '';
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
 int1: integer;
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
    if calcautocellsize then begin
     int1:= bmp.size.cx - innerrect.cx + rect.cx;
     if int1 > autocellsize.cx then begin
      autocellsize.cx:= int1;
     end;
     int1:= bmp.size.cy - innerrect.cy + rect.cy;
     if int1 > autocellsize.cy then begin
      autocellsize.cy:= int1;
     end;
    end
    else begin
     paintbmp(canvas,bmp,innerrect);
    end;
   except;
   end;
   bmp.free;
  end;
 end;
end;

procedure tcustomdataimage.updateautocellsize(const canvas: tcanvas);
begin
 drawcell(canvas);
end;

procedure tcustomdataimage.valuetogrid(row: integer);
begin
 //dummy
end;

procedure tcustomdataimage.gridtovalue(row: integer);
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

function tcustomdataimage.sortfunc(const l,r): integer;
begin
 result:= 0;
end;

procedure tcustomdataimage.gridvaluechanged(const index: integer);
begin
 //dummy
end;

procedure tcustomdataimage.updatecoloptions(const aoptions: coloptionsty);
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

{$ifdef mse_with_ifi}
function tcustomdataimage.getifilink: tifilinkcomp;
begin
 result:= nil;
end;
{$endif}

function tcustomdataimage.getoptionsedit: optionseditty;
begin
 result:= [oe_readonly];
end;

procedure tcustomdataimage.initgridwidget;
begin
 defaultinitgridwidget(self,fgridintf);
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

function tcustomdataimage.getgridvalue(index: integer): string;
begin
 checkgrid;
 fgridintf.getdata(index,result);
end;

procedure tcustomdataimage.setisdb;
begin
 //dummy
end;

procedure tcustomdataimage.setgridvalue(index: integer;
               const avalue: string);
begin
 checkgrid;
 fgridintf.setdata(index,avalue);
end;

function tcustomdataimage.getgridintf: iwidgetgrid;
begin
 result:= fgridintf;
end;

procedure tcustomdataimage.beforecelldragevent(var ainfo: draginfoty;
               const arow: integer; var handled: boolean);
begin
 //dummy
end;

procedure tcustomdataimage.aftercelldragevent(var ainfo: draginfoty;
               const arow: integer; var handled: boolean);
begin
 //dummy
end;

procedure tcustomdataimage.setreadonly(const avalue: boolean);
begin
 //dummy
end;

procedure tcustomdataimage.readvalue(stream: tstream);
var
 str1: string;
 int1: integer;
begin
 stream.readbuffer(int1,sizeof(integer)); 
 setlength(str1,int1);
 stream.readbuffer(pointer(str1)^,int1);
 value:= str1;
end;

procedure tcustomdataimage.writevalue(stream: tstream);
var
 int1: integer;
begin
 int1:= length(fvalue);
 stream.writebuffer(int1,sizeof(integer)); 
 stream.writebuffer(pointer(fvalue)^,int1);
end;

procedure tcustomdataimage.defineproperties(filer: tfiler);
begin
 inherited;
 filer.definebinaryproperty('valuedata',{$ifdef FPC}@{$endif}readvalue,
            {$ifdef FPC}@{$endif}writevalue,
             (filer.ancestor = nil) and (fvalue <> '') or 
             (filer.ancestor <> nil) and 
                       (tcustomdataimage(filer.ancestor).fvalue <> fvalue));
end;

function tcustomdataimage.actualcolor: colorty;
begin
 if (fgridintf <> nil) and (fcolor = cl_default) then begin
  result:= fgridintf.getcol.rowcolor(fgridintf.getrow);
 end
 else begin
  result:= inherited actualcolor;
 end;
end;

function tcustomdataimage.loadfromstream(const astream: tstream): string;
//var
// str1: string;
begin
 fcurformat:= '';
 value:= readstreamdatastring(astream);
 result:= fcurformat;
end;

function tcustomdataimage.loadfromfile(const afilename: filenamety): string;
var
 stream1: tmsefilestream;
begin
 stream1:= tmsefilestream.create(afilename);
 try
  result:= loadfromstream(stream1);
 finally
  stream1.free;
 end; 
end;

procedure tcustomdataimage.storeimage(const aformat: string;
                                          const params: array of const);
var
 str1: string;
begin
 if aformat <> '' then begin
  str1:= aformat;
 end
 else begin
  str1:= format;
 end;
 value:= bitmap.writetostring(str1,params);
end;

end.
