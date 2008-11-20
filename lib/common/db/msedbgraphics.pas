{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

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
 classes,db,mseimage,msedataimage,msedbdispwidgets,msedb,msetypes,msedbedit,
 msegrids,msewidgetgrid,msedatalist,msebitmap,msebintree,msegraphics,
 msemenus,mseevent,msegui;

{ add the needed graphic format units to your project:
 mseformatbmpico,mseformatjpg,mseformatpng,
 mseformatpnm,mseformattga,mseformatxpm
}

type
 idbgraphicfieldlink = interface(idbeditfieldlink)
  procedure setformat(const avalue: string);
 end;

 timagecachenode = class(tcachenode)
  private
   fimage: imagebufferinfoty;
  protected
   flocal: boolean;
  public
   constructor create(const aid: blobidty); overload;
   destructor destroy; override;
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
   procedure loadbitmap(const abitmap: tmaskedbitmap;
                             aformat: string = '');
   procedure storebitmap(const abitmap: tmaskedbitmap;
              aformat: string = ''); overload;
   procedure storebitmap(const abitmap: tmaskedbitmap;
              aformat: string; const params: array of const); overload;
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
   procedure loadbitmap(const abitmap: tmaskedbitmap; const aformat: string);
 end;

 tdbdataimage = class(tcustomdataimage,idbeditinfo,idbgraphicfieldlink,ireccontrol)
  private
   fdatalink: tgraphicdatalink;
   function getdatafield: string; overload;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
   procedure griddatasourcechanged; override;
   procedure loadcellbmp(const acanvas: tcanvas; const abmp: tmaskedbitmap); override;
   function getrowdatapo(const info: cellinfoty): pointer; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
     //idbeditinfo
   function getdatasource(const aindex: integer): tdatasource; overload;
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty); virtual;
     //idbeditfieldlink
   function getgriddatasource: tdatasource;
   function edited: boolean;
   procedure initeditfocus;
   function checkvalue(const quiet: boolean = false): boolean;
   procedure valuetofield;
   procedure updatereadonlystate;
     //idbgraphicfieldlink
   procedure fieldtovalue; virtual;
   procedure setnullvalue;
   //ireccontrol
   procedure recchanged;
  protected
   procedure gridtovalue(const row: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property datalink: tgraphicdatalink read fdatalink;
  published
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;
   property format;
 end;
 
implementation
uses
 msestream,sysutils,msegraphicstream;
 
type
 tsimplebitmap1 = class(tsimplebitmap);
 
 { tdbdataimage }

constructor tdbdataimage.create(aowner: tcomponent);
begin
 fdatalink:= tgraphicdatalink.create(idbgraphicfieldlink(self));
 inherited;
 include(tsimplebitmap1(bitmap).fstate,pms_nosave);
end;

destructor tdbdataimage.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbdataimage.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tdbdataimage.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tdbdataimage.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tdbdataimage.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

procedure tdbdataimage.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= blobfields + [ftstring];
end;

procedure tdbdataimage.fieldtovalue;
begin
 datalink.loadbitmap(bitmap,format);
end;

procedure tdbdataimage.setnullvalue;
begin
 bitmap.clear;
end;

function tdbdataimage.getdatasource(const aindex: integer): tdatasource;
begin
 result:= datasource;
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
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datasource;
end;

function tdbdataimage.edited: boolean;
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
 //dumy
end;

procedure tdbdataimage.updatereadonlystate;
begin
 //dummy
end;

function tdbdataimage.getrowdatapo(const info: cellinfoty): pointer;
begin
 with info do begin
  if (griddatalink <> nil) and not 
     tgriddatalink(griddatalink).getrowfieldisnull(
                                    fdatalink.field,cell.row) then begin
   result:= tgriddatalink(griddatalink).getdummystringbuffer;
   pstring(result)^:= ' ';
//   result:= tgriddatalink(griddatalink).getansistringbuffer(
//                                                 fdatalink.field,cell.row);
    
  end
  else begin
   result:= nil;
  end;
 end;
end;

procedure tdbdataimage.loadcellbmp(const acanvas: tcanvas;
               const abmp: tmaskedbitmap);
var
 int1: integer;
begin
 with cellinfoty(acanvas.drawinfopo^) do begin
  if fdatalink.field is tmsegraphicfield then begin
   with tgriddatalink(griddatalink) do begin
    int1:= activerecord;
    activerecord:= cell.row;
    tmsegraphicfield(fdatalink.field).loadbitmap(abmp,format);
    activerecord:= int1;
   end;
  end
  else begin
   abmp.loadfromstring(
   string(tgriddatalink(griddatalink).getansistringbuffer(fdatalink.field,cell.row)^),
                format);
  end;
 end;
end;

function tdbdataimage.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbdataimage.gridtovalue(const row: integer);
begin
 //dummy
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

procedure tmsegraphicfield.loadbitmap(const abitmap: tmaskedbitmap; 
                                            aformat: string = '');
var
 stream1: tstringcopystream;
 str1: string;
 id1: blobidty;
 n1: timagecachenode;
begin
 if isnull then begin
  abitmap.clear;
 end
 else begin
  if (fimagecache = nil) or not assigned(fgetblobid) or not fgetblobid(self,id1) or
               not fimagecache.find(id1,n1) then begin
   str1:= asstring;
   if str1 = '' then begin
    abitmap.clear;
   end
   else begin
    if aformat = '' then begin
     aformat:= format;
    end;
    stream1:= tstringcopystream.create(str1);
    try
     abitmap.loadfromstream(stream1,aformat);
    except
     abitmap.clear;
    end;
    stream1.free;
   end;
   if (fimagecache <> nil) and assigned(fgetblobid) then begin
    n1:= timagecachenode.create(id1);
    abitmap.savetoimagebuffer(n1.fimage);
    n1.fsize:= (n1.fimage.image.length + n1.fimage.mask.length) *
                                       sizeof(cardinal);
    fimagecache.addnode(n1);
   end;
  end
  else begin
   abitmap.loadfromimagebuffer(n1.fimage);
  end;
 end;
end;

procedure tmsegraphicfield.storebitmap(const abitmap: tmaskedbitmap; 
                         aformat: string; const params: array of const);
var
 stream1: tmsefilestream;
begin
 if aformat = '' then begin
  aformat:= format;
 end;
 stream1:= tmsefilestream.create;
 try
  writegraphic(stream1,abitmap,aformat,params);
  stream1.position:= 0;
  loadfromstream(stream1);
//  asstring:= stream1.readdatastring;
 finally
  stream1.free;
 end;
end;

procedure tmsegraphicfield.storebitmap(const abitmap: tmaskedbitmap; 
                         aformat: string = '');
begin
 storebitmap(abitmap,aformat,[]); 
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
 inherited;
end;

procedure tgraphicdatalink.setfield(const value: tfield);
begin
 if value is tmsegraphicfield then begin
  idbgraphicfieldlink(fintf).setformat(tmsegraphicfield(value).format);
 end;
 inherited;
end;

procedure tgraphicdatalink.loadbitmap(const abitmap: tmaskedbitmap;
                                                const aformat: string);
var
 stream1: tstringcopystream;
 str1: string;
begin
 if field is tmsegraphicfield then begin
  with tmsegraphicfield(field) do begin
   loadbitmap(abitmap,aformat);
  end;
 end
 else begin
  str1:= field.asstring;
  if str1 = '' then begin
   abitmap.clear;
  end
  else begin
   stream1:= tstringcopystream.create(str1);
   try
    abitmap.loadfromstream(stream1,aformat);
   except
    abitmap.clear;
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
