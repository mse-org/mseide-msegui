{ MSEgui Copyright (c) 1999-2017 by Martin Schreiber

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
 classes,mclasses,mseguiglob,msegui,mseimage,msewidgetgrid,msegrids,msedatalist,
 msegraphutils,msedragglob,
 msegraphics,mseclasses,mseeditglob,msebitmap,msemenus,mseevent,
 msetypes{msestrings},
 msepointer,msegridsglob{$ifdef mse_with_ifi},mseificomp,mseifiglob{$endif},
 mseglob,msehash;
 
type
 imagecachedataty = record
  data: pointer;
  image: maskedimagety;
  prev: int32; //offset from fdata
  next: int32; //offset from fdata
 end;
 imagecachehashdataty = record
  header: hashheaderty;
  data: imagecachedataty;
 end;
 pimagecachehashdataty = ^imagecachehashdataty;

 timagecache = class(thashdatalist)
  private
   fmaxsize: int32;
   fimagedatasize: int32;
   ffirst: int32; //offset from fdata
   flast: int32; //offset from fdata
  protected
   function getrecordsize(): int32 override;
//   procedure inititem(const aitem: phashdataty) override;
   procedure finalizeitem(const aitem: phashdataty) override;
   function hashkey(const akey): hashvaluety override;
   function checkkey(const akey; const aitem: phashdataty): boolean override;
  public
   constructor create();
   procedure clear() override;
   function find(const adata: string; out aimage: maskedimagety): boolean;
   procedure add(const adata: string; const aimage: maskedimagety);
   procedure delete(const adata: string);
   property maxsize: int32 read fmaxsize write fmaxsize;
 end;
 
 tcustomdataimage = class(timage,igridwidget)
  private
   fonchange: notifyeventty;
   fformat: string;
   fgridsettingx: integer;
   procedure checkgrid;
   function getgridvalue(index: integer): string;
   procedure setgridvalue(index: integer; const avalue: string);
   procedure readvalue(stream: tstream);
   procedure writevalue(stream: tstream);
   function getcachesize: int32;
   procedure setcachesize(const avalue: int32);
//   function getvalue: string;
  protected
   fgridintf: iwidgetgrid;
   fgriddatalink: pointer;
   fvalue: string;   //in design mode only
   fcurformat: string;
   feditstate: dataeditstatesty;
   fcache: timagecache;
//   procedure setisdb;
   function geteditstate: dataeditstatesty;
   procedure seteditstate(const avalue: dataeditstatesty);
   function getgridintf: iwidgetgrid;
   procedure defineproperties(filer: tfiler); override;
   procedure setvalue(const avalue: string); virtual;
   procedure setformat(const avalue: string);
   procedure internaldrawcell(const canvas: tcanvas; const dest: rectty);

    //igridwidget
   procedure initgridwidget; virtual;
   function getoptionsedit: optionseditty;
   procedure setfirstclick(var ainfo: mouseeventinfoty);
   procedure setreadonly(const avalue: boolean);
   function createdatalist(const sender: twidgetcol): tdatalist; virtual;
   procedure datalistdestroyed;
   function getdatalistclass: datalistclassty;
   function getdefaultvalue: pointer;
   function getrowdatapo(const arow: integer): pointer; virtual;
   procedure setgridintf(const intf: iwidgetgrid);
   function getcellframe: framety;
   function needscellfocuspaint(): boolean;
   function getcellcursor(const arow: integer; const acellzone: cellzonety;
                                          const apos: pointty): cursorshapety;
   procedure updatecellzone(const row: integer; const apos: pointty;
                            var result: cellzonety);
   function getnulltext: msestring;
   function getassistivecelltext(const arow: int32): msestring;
   procedure loadcellbmp(const acanvas: tcanvas; 
                                        const abmp: tmaskedbitmap); virtual;
   procedure drawcell(const canvas: tcanvas);
   procedure updateautocellsize(const canvas: tcanvas);
   procedure beforecelldragevent(var ainfo: draginfoty; const arow: integer;
                               var handled: boolean); virtual;
   procedure aftercelldragevent(var ainfo: draginfoty; const arow: integer;
                               var handled: boolean); virtual;
   procedure valuetogrid(row: integer); virtual;
   procedure gridtovalue(row: integer); virtual;
   procedure setvaluedata(const source); virtual;
   procedure getvaluedata(out dest); virtual;
   procedure docellevent(const ownedcol: boolean; var info: celleventinfoty); virtual;
   function sortfunc(const l,r): integer; virtual;
   procedure gridvaluechanged(const index: integer); virtual;
   procedure updatecoloptions(const aoptions: coloptionsty);
   procedure updatecoloptions1(const aoptions: coloptions1ty);
   procedure statdataread; virtual;
   procedure griddatasourcechanged; virtual;
   {$ifdef mse_with_ifi}
   function getifilink: tifilinkcomp;
   {$endif}
   procedure setparentgridwidget(const intf: igridwidget);
   procedure childdataentered(const sender: igridwidget); virtual;
   procedure childfocused(const sender: igridwidget); virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
   function seteditfocus: boolean;
   procedure changed; override;
   function actualcolor: colorty; override;
   function loadfromstream(const astream: tstream): string;    //returns format
   function loadfromfile(const afilename: filenamety): string; //returns format
   procedure storeimage(const aformat: string; const params: array of const);
                   //writes image data to value property
   procedure drawimage(const canvas: tcanvas; const cellinfo: pcellinfoty;
                                                           const dest: rectty);
   property value: string read fvalue{getvalue} write setvalue stored false;
   property gridvalue[index: integer]: string read getgridvalue
                             write setgridvalue; default;
   property format: string read fformat write setformat;
   property cachesize: int32 read getcachesize 
                               write setcachesize default 0;
                                       //kibibyte
   property onchange: notifyeventty read fonchange write fonchange;
 end;

 tdataimage = class(tcustomdataimage)
  published
   property value;
   property format;
   property cachesize;
   property onbeforepaint;
   property onpaintbackground;
   property onpaint;
   property onafterpaint;
 end;
   
implementation
uses
 msestream,sysutils,mseformatstr;
type
 tsimplebitmap1 = class(tsimplebitmap);
 tcustomwidgetgrid1 = class(tcustomwidgetgrid);
 
{ timagecache }

constructor timagecache.create();
begin
 inherited;
 fstate:= fstate + [hls_needsfinalize];
end;

procedure timagecache.clear();
begin
 inherited;
 fimagedatasize:= 0;
 ffirst:= 0;
 flast:= 0;
end;

function timagecache.getrecordsize(): int32;
begin
 result:= sizeof(imagecachehashdataty);
end;
{
procedure timagecache.inititem(const aitem: phashdataty);
begin
 initialize(pimagecachehashdataty(aitem)^);
end;
}
procedure timagecache.finalizeitem(const aitem: phashdataty);
begin
 freeimage(pimagecachehashdataty(aitem)^.data.image);
end;

function timagecache.hashkey(const akey): hashvaluety;
begin
 result:= pointerhash(pointer(akey));
end;

function timagecache.checkkey(const akey; const aitem: phashdataty): boolean;
begin
 result:= pointer(akey) = pimagecachehashdataty(aitem)^.data.data;
end;

function timagecache.find(const adata: string; 
                                    out aimage: maskedimagety): boolean;
var
 p1: pimagecachehashdataty;
begin
 result:= false;
 if fmaxsize > 0 then begin
  p1:= pimagecachehashdataty(internalfind(pointer(adata)));
  if p1 <> nil then begin
   aimage:= p1^.data.image;
   result:= true;
  end;
 end;
end;

procedure timagecache.add(const adata: string; const aimage: maskedimagety);
var
 i1: int32;
 p1: pimagecachehashdataty;
begin
 if (fmaxsize > 0) and (adata <> '') then begin
  if (fimagedatasize > fmaxsize) and (ffirst <> 0) then begin
   p1:= fdata+ffirst;
   delete(string(p1^.data.data));
  end;
  p1:= pimagecachehashdataty(internaladd(pointer(adata)));
  p1^.data.data:= pointer(adata);
  p1^.data.image:= aimage;
  p1^.data.prev:= flast;
  p1^.data.next:= 0;
  i1:= pointer(p1)-fdata;
  if ffirst = 0 then begin
   ffirst:= i1;
  end;
  if flast <> 0 then begin
   pimagecachehashdataty(fdata+flast)^.data.next:= i1;
  end;
  flast:= i1;
  fimagedatasize:= fimagedatasize + (aimage.image.length+aimage.mask.length)*4;
 end;
end;

procedure timagecache.delete(const adata: string);
var
 i1: int32;
 p1: pimagecachehashdataty;
begin
 if (fmaxsize > 0) and (adata <> '') then begin
  p1:= pimagecachehashdataty(internalfind(pointer(adata)));
  if p1 <> nil then begin
   i1:= pointer(p1)-data;
   if p1^.data.prev <> 0 then begin
    pimagecachehashdataty(fdata+p1^.data.prev)^.data.next:= i1;
   end;
   if p1^.data.next <> 0 then begin
    pimagecachehashdataty(fdata+p1^.data.next)^.data.prev:= i1;
   end;
   if i1 = ffirst then begin
    ffirst:= p1^.data.next;
   end;
   if i1 = flast then begin
    flast:= p1^.data.prev;
   end;
   fimagedatasize:= fimagedatasize - 
                   (p1^.data.image.image.length+p1^.data.image.mask.length)*4;
   internaldeleteitem(phashdataty(p1));
  end;
 end;
end;

{ tcustomdataimage }

constructor tcustomdataimage.create(aowner: tcomponent);
begin
 fcache:= timagecache.create();
 inherited;
{$warnings off}
 include(tsimplebitmap1(bitmap).fstate,pms_nosave);
{$warnings on}
end;

destructor tcustomdataimage.destroy();
begin
 inherited;
 fcache.free;
end;

procedure tcustomdataimage.setvalue(const avalue: string);
var
 int1: integer;
 str1: string;
begin
 if pointer(fvalue) <> pointer(avalue) then begin
 {
  if pointer(avalue) <> pointer(fvalue) then begin
   fcache.delete(fvalue); 
  end;
 }
  fvalue:= avalue;
  try
   fcurformat:= bitmap.loadfromstring(avalue,fformat,[]);
  except
   fcurformat:= '';
   bitmap.clear;
  end;
  if (fgridintf <> nil) and not (csdesigning in componentstate) and 
                                                  (fgridsettingx = 0) then begin
   int1:= fgridintf.getrow();
   fgridintf.getdata(int1,str1);
   fgridintf.setdata(int1,avalue,false);
   if pointer(avalue) <> pointer(str1) then begin
    fcache.delete(str1); 
   end;
  end;
 end;
// if csdesigning in componentstate then begin
//  fvalue:= avalue;
// end;
 changed;
end;
{
procedure tcustomdataimage.setvalue(const avalue: string);
var
 int1: integer;
 str1: string;
begin
 if (fgridintf <> nil) and not (csdesigning in componentstate) then begin
  inc(fgridsetting);
  try
   int1:= -1;
   fgridintf.getdata(int1,str1);
   fgridintf.setdata(int1,avalue);
  finally
   dec(fgridsetting);
  end;
 end;
 try
  fcurformat:= bitmap.loadfromstring(avalue,fformat,[]);
 except
  fcurformat:= '';
  bitmap.clear;
 end;
 if csdesigning in componentstate then begin
  fvalue:= avalue;
 end;
 changed;
 if pointer(avalue) <> pointer(str1) then begin
  fcache.delete(str1); 
 end;
end;
}
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
 if not (ws_loadedproc in fwidgetstate) and
                            canevent(tmethod(fonchange)) then begin
  fonchange(self);
 end;
end;

procedure tcustomdataimage.setfirstclick(var ainfo: mouseeventinfoty);
begin
 //dummy
end;

function tcustomdataimage.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridbinarystringdatalist.create(sender);
end;

function tcustomdataimage.getdatalistclass: datalistclassty;
begin
 result:= tgridbinarystringdatalist;
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

function tcustomdataimage.needscellfocuspaint(): boolean;
begin
 result:= inherited needsfocuspaint();
end;

function tcustomdataimage.getcellcursor(const arow: integer;
                                  const acellzone: cellzonety;
                                          const apos: pointty): cursorshapety;
begin
 result:= actualcursor(nullpoint);
end;

procedure tcustomdataimage.updatecellzone(const row: integer;
                            const apos: pointty; var result: cellzonety);
begin
 //dummy
end;

function tcustomdataimage.getnulltext: msestring;
begin
 result:= '';
end;

function tcustomdataimage.getassistivecelltext(const arow: int32): msestring;
begin
 result:= '';
end;

procedure tcustomdataimage.loadcellbmp(const acanvas: tcanvas;
                                            const abmp: tmaskedbitmap);
var
 image1: maskedimagety;
begin
 with cellinfoty(acanvas.drawinfopo^) do begin
  if fcache.maxsize > 0 then begin
   if fcache.find(string(datapo^),image1) then begin
    abmp.loadfrommaskedimage(image1);
   end
   else begin
    abmp.loadfromstring(string(datapo^),fformat,[]);
    abmp.savetomaskedimage(image1);
    fcache.add(string(datapo^),image1);
   end;
  end
  else begin
   abmp.loadfromstring(string(datapo^),fformat,[]);
  end;
 end;
end;

procedure tcustomdataimage.internaldrawcell(const canvas: tcanvas; 
                                                         const dest: rectty);
var
 bmp: tmaskedbitmap;
 int1: integer;
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  if (datapo <> nil) and (string(datapo^) <> '') then begin
   bmp:= tmaskedbitmap.create(bitmap.kind);
   try
    with bitmap do begin
     bmp.alignment:= alignment;
     bmp.options:= options;
     bmp.opacity:= opacity;
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
     paintbmp(canvas,bmp,dest);
    end;
   except;
   end;
   bmp.free;
  end;
 end;
end;

procedure tcustomdataimage.drawcell(const canvas: tcanvas);
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  internaldrawcell(canvas,innerrect);
 end;
end;

procedure tcustomdataimage.drawimage(const canvas: tcanvas;
                            const cellinfo: pcellinfoty; const dest: rectty);
var
 p1: pointer;
 p2: pcellinfoty;
 cellinfo1: cellinfoty;
begin
 p2:= canvas.drawinfopo;
 if cellinfo = nil then begin
  canvas.drawinfopo:= @cellinfo1;
  cellinfo1.cell.row:= fgridintf.getgrid.row;
  cellinfo1.calcautocellsize:= false;
 end
 else begin
  canvas.drawinfopo:= cellinfo;
 end;
 with pcellinfoty(canvas.drawinfopo)^ do begin
  p1:= datapo;
  datapo:= fgridintf.getdatapo(cell.row);
  internaldrawcell(canvas,dest);
  datapo:= p1;
 end;
 canvas.drawinfopo:= p2;
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
// if fgridsetting = 0 then begin
// if row <> -2 then begin //not default value
  inc(fgridsettingx);
  try
   fgridintf.getdata(row,str1);
   value:= str1;
  finally
   dec(fgridsettingx);
  end;
// end;
// end;
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

procedure tcustomdataimage.updatecoloptions1(const aoptions: coloptions1ty);
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

function tcustomdataimage.geteditstate: dataeditstatesty;
begin
 result:= feditstate;
end;

procedure tcustomdataimage.seteditstate(const avalue: dataeditstatesty);
begin
 feditstate:= avalue;
end;
{
procedure tcustomdataimage.setisdb;
begin
 //dummy
end;
}
procedure tcustomdataimage.setgridvalue(index: integer;
               const avalue: string);
var
 str1: string;
begin
 checkgrid;
 fgridintf.getdata(index,str1);
 fgridintf.setdata(index,avalue);
 fcache.delete(str1);
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

function tcustomdataimage.getcachesize: int32;
begin
 result:= fcache.maxsize;
end;

procedure tcustomdataimage.setcachesize(const avalue: int32);
begin
 fcache.maxsize:= avalue;
 if avalue = 0 then begin
  fcache.clear;
 end;
end;
(*
function tcustomdataimage.getvalue: string;
//var
// i1: int32;
begin
 result:= fvalue;
{
 result:= '';
 if fgridintf <> nil then begin
  i1:= fgridintf.getgrid.row;
  if i1 >= 0 then begin
   result:= gridvalue[i1];
  end;
 end;
}
end;
*)
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

procedure tcustomdataimage.datalistdestroyed;
begin
 //dummy
end;

procedure tcustomdataimage.setvaluedata(const source);
begin
 value:= string(source);
end;

procedure tcustomdataimage.getvaluedata(out dest);
begin
 //dummy
end;

procedure tcustomdataimage.setparentgridwidget(const intf: igridwidget);
begin
 //dummy
end;

procedure tcustomdataimage.childdataentered(const sender: igridwidget);
begin
 //dummy
end;

procedure tcustomdataimage.childfocused(const sender: igridwidget);
begin
 //dummy
end;

end.
