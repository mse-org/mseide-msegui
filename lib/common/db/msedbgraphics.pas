{ MSEgui Copyright (c) 1999-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedbgraphics;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 classes,mdb,mseimage,mseguiglob,msedataimage,msedbdispwidgets,msedb,msetypes,
 msedbedit,
 msegrids,msewidgetgrid,msedatalist,msebitmap,msebintree,msegraphics,
 msemenus,mseevent,msegui;

{ add the needed graphic format units to your project:
 mseformatbmpicoread,
 mseformatjpgwrite,mseformatpngwrite,
 mseformatpnmread,mseformattgaread,mseformatxpmread,
}

type
 idbgraphicfieldlink = interface(idbeditfieldlink)
  procedure setformat(const avalue: string);
 end;

 timagecachenode = class(tcachenode)
  private
   fimage: imagebufferinfoty;
   fformat: string;
  protected
   flocal: boolean;
  public
   constructor create(const aid: blobidty); overload;
   destructor destroy; override;
   property format: string read fformat write fformat;
 end;
 
 timagecache = class(tcacheavltree)
  protected
   ffindnode: timagecachenode;
  public
   constructor create;
   destructor destroy; override;
   function find(const akey: blobidty; out anode: timagecachenode): boolean;
                           overload;
 end;
  
 tmsegraphicfield = class(tmseblobfield)
  private
   fformat: string;
   fimagecache: timagecache;
   function getimagecachekb: integer;
   procedure setimagecachekb(const avalue: integer);
  protected
   procedure removecache(const aid: blobidty); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function loadbitmap(const adest: tmaskedbitmap;
                        aformat: string = ''): string; //returns format
   procedure storebitmap(const asource: tmaskedbitmap;
              aformat: string = ''); overload;
   procedure storebitmap(const asource: tmaskedbitmap; aformat: string;
                                   const params: array of const); overload;
   procedure clearcache; override;
  published
   property format: string read fformat write fformat;
   property imagecachekb: integer read getimagecachekb 
                           write setimagecachekb default 0;
                //cachesize in kilo bytes, 0 -> no cache
 end;

 tgraphicdatalink = class(teditwidgetdatalink)
  protected
   procedure setfield(const value: tfield); override;
  public
   constructor create(const intf: idbgraphicfieldlink);
   function loadbitmap(const adest: tmaskedbitmap;
                         const aformat: string): string; //returns format
 end;

 tdbdataimage = class(tcustomdataimage,idbgraphicfieldlink,ireccontrol)
  private
   fdatalink: tgraphicdatalink;
   fvaluebuffer: string;
    //idbeditfieldlink
   function getgriddatasource: tdatasource;
   function getedited: boolean;
   procedure initeditfocus;
   function checkvalue(const quiet: boolean = false): boolean;
   procedure valuetofield;
   procedure updatereadonlystate;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   procedure setmaxlength(const avalue: integer);
   function getfieldlink: tcustomeditwidgetdatalink;
    //idbgraphicfieldlink
   procedure fieldtovalue; virtual;
   procedure setnullvalue;
    //ireccontrol
   procedure recchanged;
   procedure setdatalink(const avalue: tgraphicdatalink);
  protected   
   procedure griddatasourcechanged; override;
   procedure loadcellbmp(const acanvas: tcanvas; const abmp: tmaskedbitmap); override;
   function getrowdatapo(const arow: integer): pointer; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure defineproperties(filer: tfiler); override;
   procedure setvalue(const avalue: string); override;
   procedure gridtovalue(row: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tgraphicdatalink read fdatalink write setdatalink;
   property format;
 end;
 
implementation
uses
 msestream,sysutils,msegraphicstream,typinfo;
 
type
 tsimplebitmap1 = class(tsimplebitmap);
 treader1 = class(treader);
 
 { tdbdataimage }

constructor tdbdataimage.create(aowner: tcomponent);
begin
 fdatalink:= tgraphicdatalink.create(idbgraphicfieldlink(self));
 inherited;
{$warnings off}
 include(tsimplebitmap1(bitmap).fstate,pms_nosave);
{$warnings on}
end;

destructor tdbdataimage.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbdataimage.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= blobfields + [ftstring];
end;

procedure tdbdataimage.fieldtovalue;
begin
 fcurformat:= datalink.loadbitmap(bitmap,format);
end;

procedure tdbdataimage.setnullvalue;
begin
 bitmap.clear;
end;

procedure tdbdataimage.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

procedure tdbdataimage.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbdataimage.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

function tdbdataimage.getedited: boolean;
begin
 result:= false;
end;

procedure tdbdataimage.initeditfocus;
begin
 //dummy
end;

function tdbdataimage.checkvalue(const quiet: boolean = false): boolean;
begin
 result:= false;
 //dummy
end;

procedure tdbdataimage.valuetofield;
begin
 if fvaluebuffer = '' then begin
  fdatalink.clear;
 end
 else begin
  fdatalink.asstring:= fvaluebuffer;
 end;
end;

procedure tdbdataimage.updatereadonlystate;
begin
 //dummy
end;

function tdbdataimage.getrowdatapo(const arow: integer): pointer;
begin
 if (fgriddatalink <> nil) and not 
    tgriddatalink(fgriddatalink).getrowfieldisnull(
                                   fdatalink.field,arow) then begin
  result:= tgriddatalink(fgriddatalink).getdummystringbuffer;
  pstring(result)^:= ' ';
 end
 else begin
  result:= nil;
 end;
end;

procedure tdbdataimage.loadcellbmp(const acanvas: tcanvas;
               const abmp: tmaskedbitmap);
var
 int1: integer;
begin
 with cellinfoty(acanvas.drawinfopo^) do begin
  if fdatalink.field is tmsegraphicfield then begin
   with tgriddatalink(fgriddatalink) do begin
    int1:= activerecord;
    activerecord:= cell.row;
    tmsegraphicfield(fdatalink.field).loadbitmap(abmp,format);
    activerecord:= int1;
   end;
  end
  else begin
   abmp.loadfromstring(
   string(tgriddatalink(fgriddatalink).getansistringbuffer(
                                  fdatalink.field,cell.row)^),format);
  end;
 end;
end;

function tdbdataimage.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbdataimage.setdatalink(const avalue: tgraphicdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbdataimage.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbdataimage.gridtovalue(row: integer);
begin
 //dummy
end;

procedure tdbdataimage.setvalue(const avalue: string);
var
 bufferbefore: string;
begin
 bufferbefore:= fvaluebuffer;
 fvaluebuffer:= avalue;
 try
  fdatalink.modified;
  fdatalink.dataentered;
 finally
  fvaluebuffer:= bufferbefore;
 end; 
end;

procedure tdbdataimage.setmaxlength(const avalue: integer);
begin
 //dummy
end;

function tdbdataimage.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;

{ tmsegraphicfield }

constructor tmsegraphicfield.create(aowner: tcomponent);
begin
 inherited;
 setdatatype(ftgraphic);
end;

destructor tmsegraphicfield.destroy;
begin
 freeandnil(fimagecache);
 inherited;
end;

function tmsegraphicfield.loadbitmap(const adest: tmaskedbitmap; 
                                            aformat: string = ''): string;
var
 stream1: tstringcopystream;
 str1: string;
 id1: blobidty;
 n1: timagecachenode;
begin
 result:= '';
 if isnull then begin
  adest.clear;
 end
 else begin
  if (fimagecache = nil) or not assigned(fgetblobid) or not fgetblobid(self,id1) or
               not fimagecache.find(id1,n1) then begin
   str1:= asstring;
   if str1 = '' then begin
    adest.clear;
   end
   else begin
    if aformat = '' then begin
     aformat:= format;
    end;
    stream1:= tstringcopystream.create(str1);
    try
     result:= adest.loadfromstream(stream1,aformat);
    except
     result:= '';
     adest.clear;
    end;
    stream1.free;
   end;
   if (fimagecache <> nil) and assigned(fgetblobid) then begin
    n1:= timagecachenode.create(id1);
    n1.format:= result;
    adest.savetoimagebuffer(n1.fimage);
    n1.fsize:= (n1.fimage.image.length + n1.fimage.mask.length) *
                                       sizeof(longword);
    fimagecache.addnode(n1);
   end;
  end
  else begin
   adest.loadfromimagebuffer(n1.fimage);
   result:= n1.format;
  end;
 end;
end;

procedure tmsegraphicfield.storebitmap(const asource: tmaskedbitmap; 
                         aformat: string; const params: array of const);
var
 stream1: tmsefilestream;
begin
 if aformat = '' then begin
  aformat:= format;
 end;
 stream1:= tmsefilestream.create;
 try
  writegraphic(stream1,asource,aformat,params);
  stream1.position:= 0;
  loadfromstream(stream1);
 finally
  stream1.free;
 end;
end;

procedure tmsegraphicfield.storebitmap(const asource: tmaskedbitmap; 
                         aformat: string = '');
begin
 storebitmap(asource,aformat,[]); 
end;

function tmsegraphicfield.getimagecachekb: integer;
begin
 result:= 0;
 if fimagecache <> nil then begin
  result:= fimagecache.maxsize div 1024;
 end;
end;

procedure tmsegraphicfield.setimagecachekb(const avalue: integer);
begin
 if imagecachekb <> avalue then begin
  if avalue > 0 then begin
   if fimagecache = nil then begin
    fimagecache:= timagecache.create;
   end;
   fimagecache.maxsize:= avalue * 1024;
  end
  else begin
   freeandnil(fimagecache);
  end;
 end;
end;

procedure tmsegraphicfield.clearcache;
begin
 if fimagecache <> nil then begin
  fimagecache.clear;
 end;
 inherited;
end;

procedure tmsegraphicfield.removecache(const aid: blobidty);
var
 n1: timagecachenode; 
begin
 if fimagecache <> nil then begin
  if fimagecache.find(aid,n1) then begin
   fimagecache.removenode(n1);
   n1.free;
  end;
 end;
 inherited;
end;

{ tgraphicdatalink }

constructor tgraphicdatalink.create(const intf: idbgraphicfieldlink);
begin
 inherited create(intf);
end;

procedure tgraphicdatalink.setfield(const value: tfield);
begin
 if value is tmsegraphicfield then begin
  idbgraphicfieldlink(fintf).setformat(tmsegraphicfield(value).format);
 end;
 inherited;
end;

function tgraphicdatalink.loadbitmap(const adest: tmaskedbitmap;
                                                const aformat: string): string;
var
 stream1: tstringcopystream;
 str1: string;
begin
 if field is tmsegraphicfield then begin
  with tmsegraphicfield(field) do begin
   result:= loadbitmap(adest,aformat);
  end;
 end
 else begin
  str1:= field.asstring;
  if str1 = '' then begin
   adest.clear;
  end
  else begin
   stream1:= tstringcopystream.create(str1);
   try
    result:= adest.loadfromstream(stream1,aformat);
   except
    result:= '';
    adest.clear;
   end;
   stream1.free;
  end;
 end;
end;

{ timagecachenode }

constructor timagecachenode.create(const aid: blobidty);
begin
 flocal:= aid.local;
 inherited create(aid.id);
end;

destructor timagecachenode.destroy;
begin
 tmaskedbitmap.freeimageinfo(fimage);
 inherited;
end;

{ timagecache }

function compareblobid(const left,right: tavlnode): integer;
var
 lint1: int64;
begin
 result:= integer(timagecachenode(left).flocal) - 
                 integer(timagecachenode(right).flocal);
 if result = 0 then begin
  lint1:= timagecachenode(left).fkey - timagecachenode(right).fkey;
  if lint1 > 0 then begin
   result:= 1;
  end
  else begin
   if lint1 < 0 then begin
    result:= -1;
   end;
  end;
 end;
end;

constructor timagecache.create;
begin
 ffindnode:= timagecachenode.create;
 inherited;
 fcompare:= {$ifdef FPC}@{$endif}compareblobid;
end;

destructor timagecache.destroy;
begin
 inherited;
 ffindnode.free;
end;

function timagecache.find(const akey: blobidty;
               out anode: timagecachenode): boolean;
begin
 ffindnode.fkey:= akey.id;
 ffindnode.flocal:= akey.local;
 result:= find(ffindnode,tavlnode(anode));
end;

initialization
 regfieldclass(ft_graphic,tmsegraphicfield);
end.
