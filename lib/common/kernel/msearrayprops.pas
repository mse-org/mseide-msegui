{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msearrayprops;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
  {$ifdef FPC}sysutils,classes{$else}SysUtils,Classes{$endif},typinfo,mselist,
  msegraphics{,msegui},msetypes,msestrings,mseclasses,mseguiglob,msestat;

type
 earraystreamerror = class(estreamerror);
 earrayproperror = class(exception);

 tarrayprop = class;
 arrayproparrayty = array of tarrayprop;

 arraychangeeventty = procedure(const sender: tarrayprop; const index: integer) of object;
 arraysizechangeeventty = procedure(sender: tarrayprop) of object;

 arraypropstatety = (aps_linking,aps_destroying,aps_needsindexing);
 arraypropsstatesty = set of arraypropstatety;

 tarrayprop = class(tpersistent)
  private
   itemsread: boolean;
   linkedarrays: arrayproparrayty;
   fonchange: arraychangeeventty;
   ffixcount: integer;
//   fonsizechanged: arraysizechangeeventty;
   procedure internalinsert(const index: integer; const init: boolean);
   procedure setfixcount(const avalue: integer);
  protected
   fstate: arraypropsstatesty;
   fupdating: integer;
   fcountbefore: integer;
   procedure change(const index: integer); virtual;
   function getcount: integer; virtual; abstract;
   function getdatapo: pointer; virtual; abstract;
   procedure checkcount(var acount: integer);
   procedure setcount1(acount: integer; doinit: boolean); virtual;
   procedure setcount(const acount: integer);
   procedure dosizechanged; virtual;
   function getsize: integer; virtual; abstract;
   function getitemspo(const index: integer): pointer; virtual; abstract;
   procedure writeitem(const index: integer; writer: twriter); virtual; abstract;
   procedure readitem(const index: integer; reader: treader); virtual; abstract;
   procedure defineproperties(filer: tfiler); override;
   procedure readcount(reader: treader);
   procedure writecount(writer: twriter);
   procedure readitems(reader: treader);
   procedure writeitems(writer: twriter);
   procedure init(startindex,endindex: integer); virtual;
   procedure dochange(const aindex: integer); virtual;
   procedure checkindex(const index: integer);
   function checkstored(ancestor: tpersistent): boolean; virtual;
  public
   procedure beginupdate;
   procedure endupdate(nochange: boolean = false);
   procedure clear;
   procedure insertempty(const index: integer);
   procedure insertdefault(const index: integer);
   procedure delete(const index: integer);
   procedure move(const curindex,newindex: integer); virtual;
   procedure order(const sourceorder: integerarty); //sourceorder can be nil
   procedure reorder(const destorder: integerarty); //destorder can be nil
   procedure link(alinkedarrays: array of tarrayprop{;
               onsizechanged: arraysizechangeeventty = nil});
   property fixcount: integer read ffixcount write setfixcount default 0;
   property onchange: arraychangeeventty read fonchange write fonchange;
  published
   property count: integer read getcount write setcount default 0;
  end;

 tintegerarrayprop = class(tarrayprop)
  private
   function getitems(const index: integer): integer;
   procedure setitems(const index: integer; const Value: integer);
  protected
   fitems: integerarty;
   function getcount: integer; override;
   procedure setcount1(acount: integer; doinit: boolean); override;
   procedure writeitem(const index: integer; writer: twriter); override;
   procedure readitem(const index: integer; reader: treader); override;
   function getsize: integer; override;
   function getdatapo: pointer; override;
   function getitemspo(const index: integer): pointer; override;
   function checkstored(ancestor: tpersistent): boolean; override;
  public
   procedure assign(source: tpersistent); override;
   property items[const index: integer]: integer read getitems write setitems; default;
 end;

 tcolorarrayprop = class(tintegerarrayprop)
  private
   function getitems(const index: integer): colorty;
   procedure setitems(const index: integer; const Value: colorty);
  protected
   procedure init(startindex,endindex: integer); override;
  public
   property items[const index: integer]: colorty read getitems write setitems; default;
 end;

 trealarrayprop = class(tarrayprop)
  private
   function getitems(const index: integer): real;
   procedure setitems(const index: integer; const Value: real);
  protected
   fitems: realarty;
   function getcount: integer; override;
   procedure setcount1(acount: integer; doinit: boolean); override;
   procedure writeitem(const index: integer; writer: twriter); override;
   procedure readitem(const index: integer; reader: treader); override;
   function getsize: integer; override;
   function getdatapo: pointer; override;
   function getitemspo(const index: integer): pointer; override;
   function checkstored(ancestor: tpersistent): boolean; override;
  public
   procedure assign(source: tpersistent); override;
   property items[const index: integer]: real read getitems write setitems; default;
 end;

 tstringarrayprop = class(tarrayprop)
  private
   function getitems(const index: integer): string;
   procedure setitems(const index: integer; const Value: string);
  protected
   fitems: stringarty;
   function getcount: integer; override;
   procedure setcount1(acount: integer; doinit: boolean); override;
   procedure writeitem(const index: integer; writer: twriter); override;
   procedure readitem(const index: integer; reader: treader); override;
   function getsize: integer; override;
   function getdatapo: pointer; override;
   function getitemspo(const index: integer): pointer; override;
   function checkstored(ancestor: tpersistent): boolean; override;
  public
   procedure assign(source: tpersistent); override;
   property items[const index: integer]: string read getitems write setitems; default;
 end;

 tmsestringarrayprop = class(tarrayprop)
  private
   function getitems(const index: integer): msestring;
   procedure setitems(const index: integer; const Value: msestring);
  protected
   fitems: msestringarty;
   function getcount: integer; override;
   procedure setcount1(acount: integer; doinit: boolean); override;
   procedure writeitem(const index: integer; writer: twriter); override;
   procedure readitem(const index: integer; reader: treader); override;
   function getsize: integer; override;
   function getdatapo: pointer; override;
   function getitemspo(const index: integer): pointer; override;
   function checkstored(ancestor: tpersistent): boolean; override;
  public
   procedure assign(source: tpersistent); override;
   property items[const index: integer]: msestring read getitems write setitems; default;
 end;

 tbooleanarrayprop = class(tintegerarrayprop)
  private
   function getitems(const index: integer): boolean;
   procedure setitems(const index: integer; const Value: boolean);
  public
   property items[const index: integer]: boolean read getitems write setitems; default;
 end;

 tenumarrayprop = class(tintegerarrayprop)
  protected
   ftypeinfo: ptypeinfo;
  public
   constructor create(typeinfo: ptypeinfo); reintroduce;
 end;

 tsetarrayprop = class(tarrayprop)
  private
   fsize: integer;
   function getitems(const index: integer): tintegerset;
  protected
   ftypeinfo: ptypeinfo;
   fitems: array of tintegerset;
   procedure setitems(const index: integer; const Value: tintegerset); virtual;
   function getcount: integer; override;
   procedure setcount1(acount: integer; doinit: boolean); override;
   procedure writeitem(const index: integer; writer: twriter); override;
   procedure readitem(const index: integer; reader: treader); override;
   function getsize: integer; override;
   function getdatapo: pointer; override;
   function getitemspo(const index: integer): pointer; override;
  public
   constructor create(typeinfo: ptypeinfo); reintroduce;
   property items[const index: integer]: tintegerset read getitems write setitems; default;
   procedure getset(const index: integer; out value);
   procedure setset(const index: integer; const value);
 end;

 tpersistentarrayprop = class(tarrayprop,iobjectlink)
  private                           //same layout as tintegerarrayprop!
  protected
   fitems: array of tpersistent;    //same layout as tintegerarrayprop!
   fitemclasstype: virtualpersistentclassty;
   fobjectlinker: tobjectlinker;

   function _addref: integer; stdcall;
   function _release: integer; stdcall;
   function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;

    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                      ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
   
   function getobjectlinker: tobjectlinker;
   procedure objectevent(const sender: tobject; const event: objecteventty); virtual;
   function getitems(const index: integer): tpersistent;{ virtual;}
   procedure init(startindex,endindex: integer); override;
   function getcount: integer; override;
   procedure setcount1(acount: integer; doinit: boolean); override;
   procedure writeitem(const index: integer; writer: twriter); override;
   procedure readitem(const index: integer; reader: treader); override;
   function getsize: integer; override;
   function getdatapo: pointer; override;
   function getitemspo(const index: integer): pointer; override;
   procedure createitem(const index: integer; var item: tpersistent); virtual;
   procedure defineproperties(filer: tfiler); override;
   procedure readcollection(reader: treader);
   procedure writecollection(writer: twriter);
   function ispropertystored(index: integer): boolean; virtual;
   procedure setlinkedvar(const source: tmsecomponent; var dest: tmsecomponent;
              const linkintf: iobjectlink = nil); overload;
   procedure setlinkedvar(const source: tlinkedobject; var dest: tlinkedobject;
              const linkintf: iobjectlink = nil); overload;
  public
   constructor create(itemclasstype: virtualpersistentclassty); reintroduce;
   destructor destroy; override;
   function displayname(const index: integer): msestring; virtual;
   procedure add(const item: tpersistent);
   function indexof(const aitem: tpersistent): integer; //-1 if not found
   property itemclasstype: virtualpersistentclassty read fitemclasstype;
   property items[const index: integer]: tpersistent read getitems; default;
 end;

 ownedpersistentclassty = class of townedpersistent;

 townedpersistentarrayprop = class(tpersistentarrayprop)
  private
  protected
   fowner: tobject;
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure internalcreate(const aowner: tobject;
                           aclasstype: virtualpersistentclassty);
  public
   constructor create(const aowner: tobject; aclasstype: ownedpersistentclassty); virtual;
 end;

 ownedeventpersistentclassty = class of townedeventpersistent;

 townedeventpersistentarrayprop = class(tpersistentarrayprop)
  private
  protected
   fowner: tobject;
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   constructor create(const aowner: tobject; aclasstype: ownedeventpersistentclassty);
 end;

 tpersistonchangearrayprop = class(tpersistentarrayprop)
  protected
   onchange1: notifyeventty;
  public
   constructor create(aclasstype: virtualpersistentclassty; aonchange: notifyeventty);
 end;

 tstringlistarrayprop = class(tpersistentarrayprop)
  private
   function getitems(index: integer): tstringlist; reintroduce;
   procedure setitems(index: integer; const Value: tstringlist); reintroduce;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   property items[index: integer]: tstringlist read getitems write setitems;
 end;

 tindexpersistentarrayprop = class;

 tindexpersistent = class(townedeventpersistent)
  private
   fident: integer;
   fprop: tindexpersistentarrayprop;
  protected
   findex: integer;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure dostatread(const reader: tstatreader); virtual;
  public
   constructor create(const aowner: tobject;
         const aprop: tindexpersistentarrayprop); reintroduce; virtual;
   property index: integer read findex;
   property ident: integer read fident;
   property prop: tindexpersistentarrayprop read fprop;
 end;

 indexpersistentclassty = class of tindexpersistent;

 tindexpersistentarrayprop = class(townedpersistentarrayprop)
  private
   fident: integer;
   function getidents: integerarty;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure change(const index: integer); override;
   function getidentnum(const index: integer): integer;
   procedure dosizechanged; override;
  public
   constructor create(const aowner: tobject; aclasstype: indexpersistentclassty);
                   reintroduce; virtual;
   procedure add(const item: tindexpersistent);
   procedure dostatwrite(const writer: tstatwriter);
   function readorder(const reader: tstatreader): integerarty;
   procedure dostatread(const reader: tstatreader);
   function newident: integer;
   property idents: integerarty read getidents;
 end;
 
implementation

uses
 rtlconsts,msedatalist;

type
 {$ifdef FPC}
  TWritercracker = class(TFiler)
  private
    FDriver: TAbstractObjectWriter;
    FDestroyDriver: Boolean;
    FRootAncestor: TComponent;
    FPropPath: String;
  end;
  {$else}
  TWritercracker = class(TFiler)
  protected
    FRootAncestor: TComponent;
    FPropPath: string;
  end;
  {$endif}

 twriter1 = class(twriter);
 treader1 = class(treader);

{ tarrayprop }

procedure tarrayprop.checkindex(const index: integer);
begin
 if (index < 0) or (index >= count) then begin
  tlist.Error({$ifndef FPC}@{$endif}SListIndexError, Index);
 end;
end;

function tarrayprop.checkstored(ancestor: tpersistent): boolean;
begin
 if ancestor is tarrayprop then begin
  with tarrayprop(ancestor) do begin
   result:= (self.count <> 0) or (count <> 0);
  end;
 end
 else begin
  result:= false;
 end;
end;

procedure tarrayprop.change(const index: integer);
begin
 if (fupdating = 0) and not (aps_destroying in fstate) then begin
  dochange(index);
 end;
end;

procedure tarrayprop.beginupdate;
begin
 inc(fupdating);
end;

procedure tarrayprop.endupdate(nochange: boolean = false);
begin
 dec(fupdating);
 if not nochange then begin
  change(-1);
 end;
end;

procedure tarrayprop.clear;
begin
 count:= 0;
end;

procedure tarrayprop.dosizechanged;
begin
 //dummy
{
 if assigned(fonsizechanged) then begin
  fonsizechanged(self);
 end;
 }
end;

procedure tarrayprop.checkcount(var acount: integer);
begin
 if ffixcount <> 0 then begin
  acount:= ffixcount;
 end;
end;

procedure tarrayprop.setcount1(acount: integer; doinit: boolean);
var
 int1: integer;
 obj: tarrayprop;
 count2: integer;

begin
 if acount <> fcountbefore then begin
  count2:= fcountbefore;
  if acount > fcountbefore then begin
//   fillchar(getitemspo(fcountbefore)^,(acount-fcountbefore)*getsize,#0);
   if doinit then begin
    init(fcountbefore,acount-1);
   end;
  end
  else begin
   include(fstate,aps_needsindexing);
  end;
  fcountbefore:= acount;
  if not (aps_linking in fstate) then begin
   for int1:= 0 to length(linkedarrays) - 1 do begin
    obj:= linkedarrays[int1];
    if obj <> self then begin
     include(obj.fstate,aps_linking);
     try
      obj.count:= acount;
     finally
      exclude(obj.fstate,aps_linking);
     end;
    end;
   end;
  end;
  change(-1);
  if (count2 <> acount) and not (aps_destroying in fstate) then begin
   dosizechanged;
  end;
 end;
end;

procedure tarrayprop.setcount(const acount: integer);
begin
 setcount1(acount,true);
end;

procedure tarrayprop.setfixcount(const avalue: integer);
begin
 if ffixcount <> avalue then begin
  ffixcount:= avalue;
  setcount(avalue);
 end;
end;

procedure tarrayprop.readcount(reader: treader);
begin
 beginupdate;
 try
  count:= reader.ReadInteger;
 finally
  endupdate;
 end;
end;

procedure tarrayprop.writecount(writer: twriter);
begin
 writer.writeinteger(count);
end;

procedure tarrayprop.readitems(reader: treader);
var
 int1: integer;
begin
 int1:= 0;
 reader.ReadListBegin;
 while not reader.EndOfList do begin
  if int1 >= count then begin
   raise earraystreamerror.create('Arrayproperty length mismatch: '+
         inttostr(count) + '.');
  end;
  readitem(int1,reader);
  inc(int1);
 end;
 reader.readlistend;
 itemsread:= true;
end;

procedure tarrayprop.writeitems(writer: twriter);
var
 int1: integer;
begin
 writer.writeListBegin;
 for int1:= 0 to count-1 do begin
  writeitem(int1,writer);
 end;
 writer.writelistend;
end;

procedure tarrayprop.defineproperties(filer: tfiler);

  function DoWrite: Boolean;
  begin
   if Filer.Ancestor <> nil then begin
    Result := checkstored(filer.Ancestor);
   end
   else begin
    Result := Count > 0;
   end;
  end;

begin
// filer.DefineProperty('count',readcount,writecount,true);
 filer.DefineProperty('items',{$ifdef FPC}@{$endif}readitems,
           {$ifdef FPC}@{$endif}writeitems,dowrite);
 if itemsread then begin
  itemsread:= false;
  change(-1);
 end;
end;

procedure tarrayprop.link(alinkedarrays: array of tarrayprop{;
                  onsizechanged: arraysizechangeeventty = nil});
var
 int1: integer;
begin
// fonsizechanged:= onsizechanged;
 setlength(linkedarrays,high(alinkedarrays)+1);
 for int1:= 0 to high(alinkedarrays) do begin
  linkedarrays[int1]:= alinkedarrays[int1];
 end;
 for int1:= 0 to length(linkedarrays)-1 do begin
  if linkedarrays[int1] <> self then begin
   linkedarrays[int1].linkedarrays:= linkedarrays;
  end;
 end;
 setcount(count);
end;

procedure tarrayprop.init(startindex, endindex: integer);
begin
 //dummy
end;

procedure tarrayprop.dochange(const aindex: integer);
begin
 if assigned(fonchange) then begin
  fonchange(self,aindex);
 end;
end;

procedure tarrayprop.move(const curindex, newindex: integer);
var
 postart,pocur,ponew,poend,backup: pchar;
 size,count1: integer;
begin
 if curindex <> newindex then begin
  checkindex(curindex);
  checkindex(newindex);
  size:= getsize;
  count1:= getcount;
  postart:= getitemspo(0);
  pocur:= postart + curindex*size;
  ponew:= postart + newindex*size;
  poend:= postart + count1*size;
  getmem(backup,size);
  try
   system.move(pocur^,backup^,size);
   system.move((pocur+size)^,pocur^,poend-pocur-size);
   system.move(ponew^,(ponew+size)^,poend-ponew-size);
   system.move(backup^,ponew^,size);
  finally
   freemem(backup);
  end;
  change(-1);
//  change(curindex);
//  change(newindex);
 end;
end;

procedure tarrayprop.order(const sourceorder: integerarty);
var
 int1: integer;
begin
 if sourceorder <> nil then begin
  int1:= getcount;
  if int1 <> length(sourceorder) then begin
   raise exception.create('tarrayprop: Wrong length of neworder');
  end;
  if int1 > 0 then begin
   orderarray(sourceorder,getdatapo^,getsize);
  end;
  change(-1);
 end;
end;

procedure tarrayprop.reorder(const destorder: integerarty);
var
 int1: integer;
begin
 int1:= getcount;
 if int1 <> length(destorder) then begin
  raise exception.create('tarrayprop: Wrong length of neworder');
 end;
 if int1 > 0 then begin
  reorderarray(destorder,getdatapo^,getsize);
 end;
 change(-1);
end;

procedure tarrayprop.delete(const index: integer);
begin
 beginupdate;
 try
  move(index,count - 1);
  count:= count - 1;
 finally
  endupdate;
 end;
end;

procedure tarrayprop.internalinsert(const index: integer; const init: boolean);
begin
 beginupdate;
 try
  setcount1(count + 1,init);
  move(count-1,index);
 finally
  endupdate;
 end;
end;

procedure tarrayprop.insertempty(const index: integer);
begin
 internalinsert(index,false);
end;

procedure tarrayprop.insertdefault(const index: integer);
begin
 internalinsert(index,true);
end;

{ tintegerarraypropmse }

function tintegerarrayprop.checkstored(ancestor: tpersistent): boolean;
begin
 result:= not (ancestor is tintegerarrayprop);
 if not result then begin
  with tintegerarrayprop(ancestor) do begin
   result:= self.count <> count;
   if not result then begin
    result:= not comparemem(@self.fitems[0],@fitems[0],
        length(fitems)*sizeof(integer));
   end;
  end;
 end;
end;

function tintegerarrayprop.getcount: integer;
begin
 result:= length(fitems);
end;

procedure tintegerarrayprop.readitem(const index: integer; reader: treader);
begin
 fitems[index]:= reader.ReadInteger;
end;

procedure tintegerarrayprop.writeitem(const index: integer; writer: twriter);
begin
 writer.writeinteger(fitems[index]);
end;

procedure tintegerarrayprop.setcount1(acount: integer; doinit: boolean);
begin
 checkcount(acount);
 setlength(fitems,acount);    //immer zuerst!
 inherited;
end;

function tintegerarrayprop.getitemspo(const index: integer): pointer;
begin
 result:= @fitems[index];
end;

function tintegerarrayprop.getsize: integer;
begin
 result:= sizeof(integer);
end;

function tintegerarrayprop.getdatapo: pointer;
begin
 result:= @fitems;
end;

function tintegerarrayprop.getitems(const index: integer): integer;
begin
 checkindex(index);
 result:= fitems[index];
end;

procedure tintegerarrayprop.setitems(const index: integer; const Value: integer);
begin
 checkindex(index);
 fitems[index]:= value;
 change(index);
end;

procedure tintegerarrayprop.assign(source: tpersistent);
begin
 if source is tintegerarrayprop then begin
  fitems:= copy(tintegerarrayprop(source).fitems);
  beginupdate;
  setcount1(length(fitems),false);
  endupdate;
 end
 else begin
  inherited;
 end;
end;

{ tcolorarrayprop }

function tcolorarrayprop.getitems(const index: integer): colorty;
begin
 checkindex(index);
 result:= fitems[index];
end;

procedure tcolorarrayprop.setitems(const index: integer; const Value: colorty);
begin
 inherited setitems(index,value);
end;

procedure tcolorarrayprop.init(startindex, endindex: integer);
var
 int1: integer;
begin
 for int1:= startindex to endindex do begin
  items[int1]:= cl_transparent;
 end;
end;

{ trealarraypropmse }

function trealarrayprop.getcount: integer;
begin
 result:= length(fitems);
end;

function trealarrayprop.getitemspo(const index: integer): pointer;
begin
 result:= @fitems[index];
end;

function trealarrayprop.getsize: integer;
begin
 result:= sizeof(real);
end;

function trealarrayprop.getdatapo: pointer;
begin
 result:= @fitems;
end;

procedure trealarrayprop.setcount1(acount: integer; doinit: boolean);
begin
 checkcount(acount);
 setlength(fitems,acount);    //immer zuerst!
 inherited;
end;

procedure trealarrayprop.readitem(const index: integer; reader: treader);
begin
 fitems[index]:= reader.ReadFloat;
end;

procedure trealarrayprop.writeitem(const index: integer; writer: twriter);
begin
 writer.writefloat(fitems[index]);
end;

function trealarrayprop.getitems(const index: integer): real;
begin
 checkindex(index);
 result:= fitems[index];
end;

procedure trealarrayprop.setitems(const index: integer; const Value: real);
begin
 checkindex(index);
 fitems[index]:= value;
 change(index);
end;

function trealarrayprop.checkstored(ancestor: tpersistent): boolean;
begin
 result:= not (ancestor is trealarrayprop);
 if not result then begin
  with trealarrayprop(ancestor) do begin
   result:= self.count <> count;
   if not result then begin
    result:= not comparemem(@self.fitems[0],@fitems[0],
        length(fitems)*sizeof(real));
   end;
  end;
 end;
end;

procedure trealarrayprop.assign(source: tpersistent);
begin
 if source is trealarrayprop then begin
  fitems:= copy(trealarrayprop(source).fitems);
  beginupdate;
  setcount1(length(fitems),false);
  endupdate;
 end
 else begin
  inherited;
 end;
end;

{ tstringarrayprop }

function tstringarrayprop.checkstored(ancestor: tpersistent): boolean;
var
 int1: integer;
begin
 result:= not (ancestor is tstringarrayprop);
 if not result then begin
  with tstringarrayprop(ancestor) do begin
   result:= self.count <> count;
   if not result then begin
    for int1:= 0 to count - 1 do begin
     if self.fitems[int1] <> fitems[int1] then begin
      result:= true;
      break;
     end;
    end;
   end;
  end;
 end;
end;

function tstringarrayprop.getcount: integer;
begin
 result:= length(fitems);
end;

function tstringarrayprop.getitems(const index: integer): string;
begin
 checkindex(index);
 result:= fitems[index];
end;

function tstringarrayprop.getitemspo(const index: integer): pointer;
begin
 result:= @fitems[index];
end;

function tstringarrayprop.getsize: integer;
begin
 result:= sizeof(string);
end;

function tstringarrayprop.getdatapo: pointer;
begin
 result:= @fitems;
end;

procedure tstringarrayprop.readitem(const index: integer; reader: treader);
begin
 fitems[index]:= reader.Readstring;
end;

procedure tstringarrayprop.setcount1(acount: integer; doinit: boolean);
begin
 checkcount(acount);
 setlength(fitems,acount);    //immer zuerst!
 inherited;
end;

procedure tstringarrayprop.setitems(const index: integer; const Value: string);
begin
 checkindex(index);
 fitems[index]:= value;
 change(index);
end;

procedure tstringarrayprop.writeitem(const index: integer; writer: twriter);
begin
 writer.writestring(fitems[index]);
end;

procedure tstringarrayprop.assign(source: tpersistent);
begin
 if source is tstringarrayprop then begin
  fitems:= copy(tstringarrayprop(source).fitems);
  beginupdate;
  setcount1(length(fitems),false);
  endupdate;
 end
 else begin
  inherited;
 end;
end;

{ tmsestringarrayprop }

function tmsestringarrayprop.checkstored(ancestor: tpersistent): boolean;
var
 int1: integer;
begin
 result:= not (ancestor is tstringarrayprop);
 if not result then begin
  with tstringarrayprop(ancestor) do begin
   result:= self.count <> count;
   if not result then begin
    for int1:= 0 to count - 1 do begin
     if self.fitems[int1] <> fitems[int1] then begin
      result:= true;
      break;
     end;
    end;
   end;
  end;
 end;
end;

function tmsestringarrayprop.getcount: integer;
begin
 result:= length(fitems);
end;

function tmsestringarrayprop.getitems(const index: integer): msestring;
begin
 checkindex(index);
 result:= fitems[index];
end;

function tmsestringarrayprop.getitemspo(const index: integer): pointer;
begin
 result:= @fitems[index];
end;

function tmsestringarrayprop.getsize: integer;
begin
 result:= sizeof(msestring);
end;

function tmsestringarrayprop.getdatapo: pointer;
begin
 result:= @fitems;
end;

procedure tmsestringarrayprop.readitem(const index: integer; reader: treader);
begin
 fitems[index]:= reader.Readwidestring; //msestringimplementation
end;

procedure tmsestringarrayprop.setcount1(acount: integer; doinit: boolean);
begin
 checkcount(acount);
 setlength(fitems,acount);    //immer zuerst!
 inherited;
end;

procedure tmsestringarrayprop.setitems(const index: integer; const Value: msestring);
begin
 checkindex(index);
 fitems[index]:= value;
 change(index);
end;

procedure tmsestringarrayprop.writeitem(const index: integer; writer: twriter);
begin
 writer.writewidestring(fitems[index]); //msestringimplementation
end;

procedure tmsestringarrayprop.assign(source: tpersistent);
begin
 if source is tmsestringarrayprop then begin
  fitems:= copy(tmsestringarrayprop(source).fitems);
  beginupdate;
  setcount1(length(fitems),false);
  endupdate;
 end
 else begin
  inherited;
 end;
end;

{ tbooleanarrayprop }

function tbooleanarrayprop.getitems(const index: integer): boolean;
begin
 checkindex(index);
 result:= boolean(fitems[index]);
end;

procedure tbooleanarrayprop.setitems(const index: integer;
  const Value: boolean);
begin
 inherited setitems(index,integer(value));
end;

{ tenumarrayprop }

constructor tenumarrayprop.create(typeinfo: ptypeinfo);
begin
 if typeinfo^.Kind <> tkenumeration then begin
  raise earrayproperror.Create('typ muss enum sein!');
 end;
 ftypeinfo:= typeinfo;
 inherited create;
end;

{ tsetarraypropmse }

constructor tsetarrayprop.create(typeinfo: ptypeinfo);
var
 typedatapo: ptypedata;

begin
 if typeinfo^.Kind <> tkset then begin
  raise earrayproperror.Create('typ muss set sein!');
 end;
 ftypeinfo:= typeinfo;
 typedatapo:= gettypedata(ftypeinfo);
 typedatapo:= gettypedata(typedatapo^.comptype{$ifndef FPC}^{$endif});
 fsize:= (typedatapo^.maxvalue - typedatapo^.minvalue) div 8 + 1;
 if fsize > sizeof(tintegerset) then begin
  raise earrayproperror.Create('set muss <= 32 sein!');
 end;
 {$ifdef FPC}
 fsize:= sizeof(longword);
 {$endif}
 inherited create;
end;

function tsetarrayprop.getcount: integer;
begin
 result:= length(fitems);
end;

function tsetarrayprop.getitems(const index: integer): tintegerset;
begin
 checkindex(index);
 result:= fitems[index];
end;

function tsetarrayprop.getitemspo(const index: integer): pointer;
begin
 result:= @fitems[index];
end;

function tsetarrayprop.getsize: integer;
begin
 result:= sizeof(tintegerset);
end;

function tsetarrayprop.getdatapo: pointer;
begin
 result:= @fitems;
end;

procedure tsetarrayprop.setcount1(acount: integer; doinit: boolean);
begin
 checkcount(acount);
 setlength(fitems,acount);    //immer zuerst!
 inherited;
end;

procedure tsetarrayprop.setitems(const index: integer; const Value: tintegerset);
begin
 checkindex(index);
 fitems[index]:= value;
 change(index);
end;

procedure tsetarrayprop.writeitem(const index: integer; writer: twriter);
var
 I: Integer;
 BaseType: PTypeInfo;
 value: tintegerset;
begin
 value:= fitems[index];
 BaseType := GetTypeData(ftypeinfo)^.CompType{$ifndef FPC}^{$endif};
 with twriter1(writer) do begin
 {$ifdef FPC}
  driver.writeset(longint(value),basetype);
 {$else}
  writevalue(vaset);
  for I := 0 to SizeOf(TIntegerSet) * 8 - 1 do begin
   if I in TIntegerSet(Value) then begin
    WriteStr(GetEnumName(BaseType, I));
   end;
  end;
  WriteStr('');
  {$endif}
 end;
end;

procedure tsetarrayprop.readitem(const index: integer; reader: treader);
begin
 fitems[index]:=
  tintegerset(treader1(reader).{$ifdef FPC}driver.{$endif}readset(ftypeinfo));
end;

procedure tsetarrayprop.getset(const index: integer; out value);
begin
 checkindex(index);
 system.move(fitems[index],value,fsize);
end;

procedure tsetarrayprop.setset(const index: integer; const value);
begin
 checkindex(index);
 fillchar(fitems[index],sizeof(tintegerset),0);
 system.move(value,fitems[index],fsize);
end;

{ tpersistentarrayprop }

constructor tpersistentarrayprop.create(itemclasstype: virtualpersistentclassty);
begin
 fitemclasstype:= itemclasstype;
 inherited create;
end;

destructor tpersistentarrayprop.destroy;
begin
 include(fstate,aps_destroying);
 setlength(linkedarrays,0);
 clear;
 inherited;
 fobjectlinker.free;
end;

function tpersistentarrayprop.getcount: integer;
begin
 result:= length(fitems);
end;

procedure tpersistentarrayprop.init(startindex, endindex: integer);
var
 int1: integer;
begin
 inherited;
 for int1:= startindex to endindex do begin
  createitem(int1,fitems[int1]);
 end;
end;

procedure tpersistentarrayprop.setcount1(acount: integer; doinit: boolean);
var
 lengthvorher,int1: integer;
begin
 checkcount(acount);
 lengthvorher:= length(fitems);
 if acount < lengthvorher then begin
  for int1:= lengthvorher-1 downto acount do begin
   fitems[int1].free;
  end;
 end;
 setlength(fitems,acount);
 inherited;
end;

procedure tpersistentarrayprop.readitem(const index: integer; reader: treader);
begin
 //dummy
end;

procedure tpersistentarrayprop.writeitem(const index: integer; writer: twriter);
begin
 //dummy
end;

function tpersistentarrayprop.getitemspo(const index: integer): pointer;
begin
 result:= @fitems[index];
end;

function tpersistentarrayprop.getsize: integer;
begin
 result:= sizeof(tpersistent);
end;

function tpersistentarrayprop.getdatapo: pointer;
begin
 result:= @fitems;
end;

procedure tpersistentarrayprop.createitem(const index: integer;
                  var item: tpersistent);
begin
 if fitemclasstype <> nil then begin
  item:= fitemclasstype.create;
 end
 else begin
  item:= nil;
 end;
end;

function tpersistentarrayprop.ispropertystored(index: integer): boolean;
begin
 result:= fitems[index] <> nil;
end;

procedure tpersistentarrayprop.readcollection(reader: treader);
var
 int1: integer;

begin
 with treader1(reader) do begin
  readvalue;
  int1:= 0;
  while not EndOfList do begin
   if int1 >= count then begin
    raise earraystreamerror.create('Arrayproperty length mismatch: '+
          inttostr(count) + '.');
   end;
   if NextValue in [vaInt8, vaInt16, vaInt32] then ReadInteger;
   ReadListBegin;
   while not EndOfList do  begin
    treader1(reader).ReadProperty(getitems(int1));
   end;
   ReadListEnd;
   inc(int1);
  end;
  readlistend;
 end;
 itemsread:= true;
end;

procedure tpersistentarrayprop.writecollection(writer: twriter);
var
 int1: integer;
 proppathvorher: string;
 ancestorbefore: tpersistentarrayprop;

begin
 proppathvorher:= twritercracker(writer).fproppath;
 twritercracker(writer).fproppath:= '';
 ancestorbefore:= tpersistentarrayprop(writer.ancestor);
 try
  with twriter1(writer) do begin
  {$ifdef FPC}
   driver.begincollection;
  {$else}
   WriteValue(vaCollection);
   {$endif}
   for int1 := 0 to Count - 1 do begin
    WriteListBegin;
    if (ancestorbefore <> nil) and (int1 < ancestorbefore.count) then begin
     ancestor:= ancestorbefore.fitems[int1];
    end
    else begin
     ancestor:= nil;
    end;
    if ispropertystored(int1) then begin
     twriter1(writer).WriteProperties(getitems(int1));
    end;
    WriteListEnd;
   end;
   WriteListEnd;
  end;
 finally
  twritercracker(writer).fproppath:= proppathvorher;
  writer.Ancestor:= ancestorbefore;
 end;
end;

procedure tpersistentarrayprop.defineproperties(filer: tfiler);
begin
 filer.DefineProperty('items',{$ifdef FPC}@{$endif}readcollection,
                              {$ifdef FPC}@{$endif}writecollection,count>0);
// inherited;
 if itemsread and (filer is treader) then begin
  itemsread:= false;
  change(-1);
 end;
end;

procedure tpersistentarrayprop.link(const source,dest: iobjectlink; valuepo: pointer = nil;
                            ainterfacetype: pointer = nil; once: boolean = false);
begin
 getobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tpersistentarrayprop.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
begin
 getobjectlinker.unlink(source,dest,valuepo);
end;

procedure tpersistentarrayprop.objevent(const sender: iobjectlink; const event: objecteventty);
begin
 getobjectlinker.objevent(sender,event);
end;

function tpersistentarrayprop.getinstance: tobject;
begin
 result:= self;
end;

function tpersistentarrayprop._addref: integer; stdcall;
begin
 result:= -1;
end;

function tpersistentarrayprop._release: integer; stdcall;
begin
 result:= -1;
end;

function tpersistentarrayprop.QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
begin
 if GetInterface(IID, Obj) then begin
   Result:=0
 end
 else begin
  result:= integer(e_nointerface);
 end;
end;

function tpersistentarrayprop.getobjectlinker: tobjectlinker;
begin
 if fobjectlinker = nil then begin
  createobjectlinker(iobjectlink(self),{$ifdef FPC}@{$endif}objectevent,fobjectlinker);
 end;
 result:= fobjectlinker;
end;

procedure tpersistentarrayprop.objectevent(const sender: tobject;
                  const event: objecteventty);
begin
 //dummy
end;

procedure tpersistentarrayprop.setlinkedvar(const source: tmsecomponent;
                   var dest: tmsecomponent; const linkintf: iobjectlink = nil);
begin
 if linkintf = nil then begin
  getobjectlinker.setlinkedvar(iobjectlink(self),source,dest);
 end
 else begin
  getobjectlinker.setlinkedvar(linkintf,source,dest);
 end;
end;

procedure tpersistentarrayprop.setlinkedvar(const source: tlinkedobject;
                   var dest: tlinkedobject; const linkintf: iobjectlink = nil);
begin
 if linkintf = nil then begin
  getobjectlinker.setlinkedvar(iobjectlink(self),source,dest);
 end
 else begin
  getobjectlinker.setlinkedvar(linkintf,source,dest);
 end;
end;

function tpersistentarrayprop.getitems(const index: integer): tpersistent;
begin
 checkindex(index);
 result:= fitems[index];
end;

function tpersistentarrayprop.displayname(const index: integer): msestring;
begin
 if fitemclasstype <> nil then begin
  result:= PTypeInfo(fitemclasstype.ClassInfo)^.name;
 end
 else begin
  result:= '';
 end;
end;

procedure tpersistentarrayprop.add(const item: tpersistent);
begin
 beginupdate;
 insertempty(length(fitems));
 fitems[high(fitems)]:= item;
 endupdate;
end;

function tpersistentarrayprop.indexof(const aitem: tpersistent): integer; //-1 if not found
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(fitems) do begin
  if fitems[int1] = aitem then begin
   result:= int1;
  end;
 end;
end;

{ townedpersistentarrayprop }

constructor townedpersistentarrayprop.create(const aowner: tobject;
                            aclasstype: ownedpersistentclassty);
begin
 internalcreate(aowner,aclasstype);
end;

procedure townedpersistentarrayprop.internalcreate(const aowner: tobject;
                     aclasstype: virtualpersistentclassty);
begin
 fowner:= aowner;
 inherited create(aclasstype);
end;

procedure townedpersistentarrayprop.createitem(const index: integer;
                  var item: tpersistent);
begin
 if fitemclasstype <> nil then begin
  item:= ownedpersistentclassty(fitemclasstype).create(fowner);
 end
 else begin
  item:= nil;
 end;
end;

{ townedeventpersistentarrayprop }

constructor townedeventpersistentarrayprop.create(const aowner: tobject;
  aclasstype: ownedeventpersistentclassty);
begin
 fowner:= aowner;
 inherited create(aclasstype);
end;

procedure townedeventpersistentarrayprop.createitem(const index: integer;
                                 var item: tpersistent);
begin
 if fitemclasstype <> nil then begin
  item:= ownedeventpersistentclassty(fitemclasstype).create(fowner);
 end
 else begin
  item:= nil;
 end;
end;

{ tpersistonchangearrayprop }

constructor tpersistonchangearrayprop.create(aclasstype: virtualpersistentclassty;
      aonchange: notifyeventty);
begin
 onchange1:= aonchange;
 inherited create(aclasstype);
end;

{ tstringlistarrayprop }

procedure tstringlistarrayprop.createitem(const index: integer;
                                                   var item: tpersistent);
begin
 item:= tstringlist.create;
end;

function tstringlistarrayprop.getitems(index: integer): tstringlist;
begin
 result:= tstringlist(fitems[index]);
end;

procedure tstringlistarrayprop.setitems(index: integer;
  const Value: tstringlist);
begin
 tstringlist(fitems[index]).assign(value);
end;

{ tindexpersistentarrayprop }

constructor tindexpersistentarrayprop.create(const aowner: tobject;
                             aclasstype: indexpersistentclassty);
begin
 internalcreate(aowner,aclasstype);
end;

procedure tindexpersistentarrayprop.createitem(const index: integer;
                                   var item: tpersistent);
begin
 if fitemclasstype <> nil then begin
  item:= indexpersistentclassty(fitemclasstype).create(fowner,self);
  tindexpersistent(item).findex:= index;
 end
 else begin
  item:= nil;
 end;
end;

procedure tindexpersistentarrayprop.change(const index: integer);
var
 int1: integer;
 item1: tindexpersistent;
begin
 if (index < 0) and (fupdating = 0) then begin
  for int1:= 0 to high(fitems) do begin
   item1:= tindexpersistent(fitems[int1]);
   if item1 <> nil then begin
    item1.findex:= int1;
   end;
  end;
 end;
 inherited;
end;

function tindexpersistentarrayprop.getidentnum(const index: integer): integer;
var
 item1: tindexpersistent;
begin
 item1:= tindexpersistent(fitems[index]);
 if item1 <> nil then begin
  result:= item1.fident;
 end
 else begin
  result:= bigint;
 end;
end;

function tindexpersistentarrayprop.newident: integer;
begin
 if aps_needsindexing in fstate then begin
  result:= newidentnum(count,{$ifdef FPC}@{$endif}getidentnum);
 end
 else begin
  result:= fident;
  inc(fident);
 end;
end;

procedure tindexpersistentarrayprop.dosizechanged;
begin
 if count = 0 then begin
  exclude(fstate,aps_needsindexing);
  fident:= 0;
 end;
 inherited;
end;

procedure tindexpersistentarrayprop.dostatwrite(const writer: tstatwriter);
var
 int1,int2,int3: integer;
 ar1: integerarty;
 bo1: boolean;
begin
 if count > 0 then begin
  setlength(ar1,count);
  int2:= tindexpersistent(fitems[0]).fident;
  bo1:= false;
  for int1:= 0 to count -1 do begin
   int3:= tindexpersistent(fitems[int1]).fident;
   if int3 < int2 then begin
    bo1:= true;
   end;
   ar1[int1]:= int3;
   int2:= int3;
   tindexpersistent(fitems[int1]).dostatwrite(writer);
  end;
  if bo1 then begin
   writer.writearray('order',ar1);
  end;
 end;
end;

function tindexpersistentarrayprop.readorder(const reader: tstatreader): integerarty;
var
 ar1,ar2: integerarty;
 int1: integer;
begin
 result:= nil;
 beginupdate;
 try
  ar1:= nil;
  ar1:= reader.readarray('order',ar1);
  if (ar1 <> nil) and (high(ar1) = high(fitems)) then begin
   sortarray(ar1,ar2);
   for int1:= 0 to high(ar1) do begin
    if ar1[int1] <> int1 then begin
     exit; //invalid
    end;
   end;
   reorderarray(ar2,pointerarty(fitems));
   for int1:= 0 to count -1 do begin
    tindexpersistent(fitems[int1]).findex:= int1;
   end;
   result:= ar2;
  end;
 finally
  endupdate;
 end;
end;

procedure tindexpersistentarrayprop.dostatread(const reader: tstatreader);
var
 int1: integer;
begin
 beginupdate;
 try
  readorder(reader);
  for int1:= 0 to count -1 do begin
   tindexpersistent(fitems[int1]).dostatread(reader);
  end;
 finally
  endupdate;
 end;
end;

procedure tindexpersistentarrayprop.add(const item: tindexpersistent);
begin
 item.findex:= count;
 inherited add(item);
end;

function tindexpersistentarrayprop.getidents: integerarty;
var
 int1: integer;
begin
 setlength(result,count);
 for int1:= 0 to high(fitems) do begin
  result[int1]:= tindexpersistent(fitems[int1]).fident;
 end;
end;

{ tindexpersistent }

constructor tindexpersistent.create(const aowner: tobject;
               const aprop: tindexpersistentarrayprop);
begin
 findex:= -1;
 fprop:= aprop;
 inherited create(aowner);
 fident:= fprop.newident;
end;

procedure tindexpersistent.dostatread(const reader: tstatreader);
begin
 //dummy
end;

procedure tindexpersistent.dostatwrite(const writer: tstatwriter);
begin
 //dummy
end;

end.
