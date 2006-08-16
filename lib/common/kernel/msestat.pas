{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestat;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 Classes,mseclasses,mselist,msestream,mseguiglob,msereal,msetypes,msestrings,
 msehash,msedatalist;

const
 defaultstatfilename = 'status.sta';

type
 tstatreader = class;
 tstatwriter = class;

 istatfile = interface(iobjectlink)
  procedure dostatread(const reader: tstatreader);
  procedure dostatwrite(const writer: tstatwriter);
  procedure statreading;
  procedure statread;
  function getstatvarname: msestring;
 end;

 istatupdatevalue = interface(inullinterface)
  procedure statreadvalue(const aname: msestring; const reader: tstatreader);
  procedure statwritevalue(const aname: msestring; const writer: tstatwriter);
 end;

 tstatfile = class;

 tstatfiler = class
  private
   fstream: ttextstream;
   fownsstream: boolean;
   fiswriter: boolean;
   flistlevel: integer;
  protected
   function varname(const intf: istatfile): msestring;
  public
   constructor create(const stream: ttextstream);
   destructor destroy; override;
   function arrayname(const name: msestring; index: integer): msestring;
   function iswriter: boolean;

   procedure setsection(const name: msestring);
   procedure updatevalue(const name: msestring; var value: boolean); overload;
   procedure updatevalue(const name: msestring; var value: byte); overload;
   procedure updatevalue(const name: msestring; var value: word); overload;
   procedure updatevalue(const name: msestring; var value: integer;
               const min: integer = -(maxint)-1; const max: integer = maxint); overload;
   procedure updatevalue(const name: msestring; var value: real;
               const min: real = -bigreal; const max: real = bigreal); overload;
   procedure updatevalue(const name: msestring; var value: string); overload;
   procedure updatevalue(const name: msestring; var value: msestring); overload;
   procedure updatevalue(const name: msestring; var value: tdatalist); overload;
   procedure updatevalue(const name: msestring; var value: msestringarty); overload;
   procedure updatevalue(const name: msestring; var value: longboolarty); overload;
   procedure updatevalue(const name: msestring; var value: integerarty); overload;
   procedure updatevalue(const name: msestring; var value: realarty);  overload;

   procedure updatevalue(const name: msestring; const intf: istatupdatevalue); overload;
   procedure updatestat(const intf: istatfile);
   procedure updatememorystatstream(const name: msestring; const streamname: msestring);
   procedure updatestatfile(const name: msestring; const statfile: tstatfile);
   function beginlist(const name: msestring = ''): boolean;  virtual; abstract;
   function endlist: boolean;  virtual; abstract;
 end;

 sectionty = record
  names: thashedmsestrings;
  count: integer;
  values: msestringarty;
 end;
 psectionty = ^sectionty;
 sectionarty = array of sectionty;

 recsetcounteventty = procedure(const count: integer) of object;
 recsetcountevent1ty = procedure(const count: integer);
 recstoreeventty = procedure(const index: integer; const avalue: msestring) of object;
 recstoreevent1ty = procedure(const index: integer; const avalue: msestring);

 tstatreader = class(tstatfiler)
  private
   fsectionlist: thashedmsestrings;
   fsections: sectionarty;
   fsectioncount: integer;
   factsection: psectionty;
   factitem: integer;
   fliststart: integerarty;
   procedure checkrealrange(var value: realty; const min,max: realty);
   procedure checkintegerrange(var value: integer; const min,max: integer);
  protected
   procedure readdata;
   function findvar(const name: msestring; var value: msestring): boolean; //true if ok
  public
   constructor create(const stream: ttextstream); overload;
   constructor create(const filename: filenamety); overload;
   destructor destroy; override;
   function findsection(const name: msestring): boolean; //true if found
   function checkvar(const name: msestring): boolean; //true if found

   function readboolean(const name: msestring; const default: boolean = false): boolean;
   function readbyte(const name: msestring; const default: byte = 0): byte;
   function readword(const name: msestring; const default: word = 0): word;
   function readinteger(const name: msestring; const default: integer = 0;
               const min: integer = -(maxint)-1; const max: integer = maxint): integer;
   function readreal(const name: msestring; const default: real = 0;
               const min: real = -bigreal; const max: real = bigreal): realty;
   function readstring(const name: msestring; const default: string): string;
   function readmsestring(const name: msestring; const default: msestring): msestring;
   procedure readdatalist(const name: msestring; const value: tdatalist);
   function readarray(const name: msestring; const default: stringarty): stringarty; overload;
   function readarray(const name: msestring; const default: msestringarty): msestringarty; overload;
   function readarray(const name: msestring; const default: integerarty): integerarty; overload;
   function readarray(const name: msestring; const default: longboolarty): longboolarty; overload;
   function readarray(const name: msestring; const default: realarty): realarty; overload;
   function readlistitem: msestring;

   procedure readrecord(const name: msestring; const values: array of pointer;
                                   const default: array of const);
   procedure readrecordarray(const name: msestring;
                 setcount: recsetcounteventty; store: recstoreeventty); overload;
   procedure readrecordarray(const name: msestring;
                 setcount: recsetcountevent1ty; store: recstoreevent1ty);  overload;
                  //setcount(0) on error
   function beginlist(const name: msestring = ''): boolean; override;
   function endlist: boolean; override;

   procedure readvalue(const name: msestring; const intf: istatupdatevalue);
   procedure readstat(const intf: istatfile);
   procedure readmemorystatstream(const name: msestring; const streamname: msestring);
   procedure readstatfile(const name: msestring; const statfile: tstatfile);
 end;

 recgetrecordeventty = function(const index: integer): msestring of object;
 recgetrecordevent1ty = function(const index: integer): msestring;

 tstatwriter = class(tstatfiler)
  protected
   procedure writeval(const name: msestring; const avalue: msestring);
   procedure writelistval(const avalue: msestring);
  public
   constructor create(const stream: ttextstream); overload;
   constructor create(const filename: filenamety); overload;
 
   procedure writesection(const name: msestring);
   procedure writeboolean(const name: msestring; const value: boolean);
   procedure writebyte(const name: msestring; const value: byte);
   procedure writeword(const name: msestring; const value: word);
   procedure writeinteger(const name: msestring; const value: integer);
   procedure writereal(const name: msestring; const value: real);
   procedure writestring(const name: msestring; const value: string);
   procedure writemsestring(const name: msestring; const value: msestring);
   procedure writedatalist(const name: msestring; const value: tdatalist);
   procedure writearray(const name: msestring; const value: stringarty); overload;
   procedure writearray(const name: msestring; const value: msestringarty); overload;
   procedure writearray(const name: msestring; const value: integerarty); overload;
   procedure writearray(const name: msestring; const value: longboolarty); overload;
   procedure writearray(const name: msestring; const value: realarty); overload;
 
   procedure writelistitem(const value: msestring); overload;
   procedure writelistitem(const value: integer); overload;
   procedure writelistitem(const value: realty); overload;
 
   procedure writerecord(const name: msestring; const values: array of const);
   procedure writerecordarray(const name: msestring; const count: integer;
                  get: recgetrecordeventty); overload;
   procedure writerecordarray(const name: msestring; const count: integer;
                  get: recgetrecordevent1ty); overload;
   function beginlist(const name: msestring = ''): boolean; override;
   function endlist: boolean; override;
 
   procedure writevalue(const name: msestring; const intf: istatupdatevalue);
   procedure writestat(const intf: istatfile);
   procedure writememorystatstream(const name: msestring; const streamname: msestring);
   procedure writestatfile(const name: msestring; const statfile: tstatfile);

 end;

 statupdateeventty = procedure(const sender: tobject; const filer: tstatfiler) of object;
 statreadeventty = procedure(const sender: tobject; const reader: tstatreader) of object;
 statwriteeventty = procedure(const sender: tobject; const writer: tstatwriter) of object;

 statfileoptionty = (sfo_memory,sfo_savedata);
 statfileoptionsty = set of statfileoptionty;

 tstatfile = class(tmsecomponent,istatfile)
  private
   ffilename: filenamety;
   ffiledir: filenamety;
   floadedfile: filenamety;

   fstatvarname: msestring;
   fonstatupdate: statupdateeventty;
   fonstatread: statreadeventty;
   fonstatwrite: statwriteeventty;
   fonstatbeforeread: notifyeventty;
   fonstatafterread: notifyeventty;
   fonstatbeforewrite: notifyeventty;
   fonstatafterwrite: notifyeventty;
   areader: tstatreader;
   awriter: tstatwriter;
   foptions: statfileoptionsty;
   fencoding: charencodingty;
   fstatfile: tstatfile;
   procedure dolinkstatread(const info: linkinfoty);
   procedure dolinkstatreading(const info: linkinfoty);
   procedure dolinkstatreaded(const info: linkinfoty);
   procedure dolinkstatwrite(const info: linkinfoty);
   procedure setstatfile(const Value: tstatfile);
   procedure setfilename(const avalue: filenamety);
   procedure setfiledir(const avalue: filenamety);
   procedure setoptions(avalue: statfileoptionsty);
  protected
   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
  public
   constructor create(aowner: tcomponent); override;
   procedure initnewcomponent; override;
   procedure readstat(stream: ttextstream = nil);
   procedure writestat(const stream: ttextstream = nil);
  published
   property filename: filenamety read ffilename write setfilename nodefault;
   property filedir: filenamety read ffiledir write setfiledir;
   property encoding: charencodingty read fencoding write fencoding default ce_utf8n;
   property options: statfileoptionsty read foptions write setoptions default [];
   property statfile: tstatfile read fstatfile write setstatfile;
            //filename is stored in linked statfile, dostatread and dostatwrite are
            //called by linked statfile
   property statvarname: msestring read getstatvarname write fstatvarname;
   property onstatupdate: statupdateeventty read fonstatupdate write fonstatupdate;
   property onstatread: statreadeventty read fonstatread write fonstatread;
   property onstatwrite: statwriteeventty read fonstatwrite write fonstatwrite;
   property onstatbeforewrite: notifyeventty read fonstatbeforewrite write fonstatbeforewrite;
   property onstatafterwrite: notifyeventty read fonstatafterwrite write fonstatafterwrite;
   property onstatbeforeread: notifyeventty read fonstatbeforeread write fonstatbeforeread;
   property onstatafterread: notifyeventty read fonstatafterread write fonstatafterread;
 end;

procedure setstatfilevar(const sender: istatfile; const source: tstatfile;
              var instance: tstatfile);
procedure deletememorystatstream(const streamname: msestring);

implementation
uses
 sysutils,mseformatstr,msesys,msefileutils;

type
 tdatalist1 = class(tdatalist);
 tmemorystreamcracker = class(tcustommemorystream)
  private
   fcapacity: longint;
 end;

 tmemorytextstream = class;

 streaminfoty = record
  name: msestring;
  data: pointer;
  size: integer;
  stream: tmemorytextstream;
 end;

 tmemorystreams = class;

 tmemorytextstream = class(ttextstream)
  private
   fname: msestring;
   fowner: tmemorystreams;
//   findex: integer;
  public
   constructor create(aowner: tmemorystreams; const name: msestring;
                const openmode: fileopenmodety; var info: streaminfoty); reintroduce;
   destructor destroy; override;
 end;

 tmemorystreams = class
  private
   fstreams: array of streaminfoty;
   function findname(const name: msestring): integer;
   procedure internaldelete(index: integer);
  public
   destructor destroy; override;
   function open(const streamname: msestring;
                  const openmode: fileopenmodety): ttextstream;
   procedure delete(const name: msestring);
 end;

var
 fmemorystatstreams: tmemorystreams;

function memorystatstreams: tmemorystreams;
begin
 if fmemorystatstreams = nil then begin
  fmemorystatstreams:= tmemorystreams.create;
 end;
 result:= fmemorystatstreams;
end;

procedure deletememorystatstream(const streamname: msestring);
begin
 if fmemorystatstreams <> nil then begin
  fmemorystatstreams.delete(streamname);
 end;
end;

procedure setstatfilevar(const sender: istatfile; const source: tstatfile;
              var instance: tstatfile);
begin
 setlinkedcomponent(sender,source,tmsecomponent(instance),typeinfo(istatfile));
end;

{ tstatfiler }                                                          

function tstatfiler.arrayname(const name: msestring; index: integer): msestring;
begin
 result:= name + '_'+inttostr(index);
end;

constructor tstatfiler.create(const stream: ttextstream);
begin
 fstream:= stream;
end;

destructor tstatfiler.destroy;
begin
 if fownsstream then begin
  fstream.free;
 end;
 inherited;
end;

function tstatfiler.iswriter: boolean;
begin
 result:= fiswriter;
end;

procedure tstatfiler.setsection(const name: msestring);
begin
 if fiswriter then begin
  tstatwriter(self).writesection(name);
 end
 else begin
  tstatreader(self).findsection(name);
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; var value: boolean);
begin
 if fiswriter then begin
  tstatwriter(self).writeboolean(name,value);
 end
 else begin
  value:= tstatreader(self).readboolean(name,value);
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; var value: byte);
begin
 if fiswriter then begin
  tstatwriter(self).writebyte(name,value);
 end
 else begin
  value:= tstatreader(self).readbyte(name,value);
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; var value: word);
begin
 if fiswriter then begin
  tstatwriter(self).writeword(name,value);
 end
 else begin
  value:= tstatreader(self).readword(name,value);
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; var value: tdatalist);
begin
 if fiswriter then begin
  tstatwriter(self).writedatalist(name,value);
 end
 else begin
  tstatreader(self).readdatalist(name,value);
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; var value: integer; const min, max: integer);
begin
 if fiswriter then begin
  tstatwriter(self).writeinteger(name,value);
 end
 else begin
  value:= tstatreader(self).readinteger(name,value,min,max);
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; var value: real; const min, max: real);
begin
 if fiswriter then begin
  tstatwriter(self).writereal(name,value);
 end
 else begin
  value:= tstatreader(self).readreal(name,value,min,max);
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; var value: integerarty);
begin
 if fiswriter then begin
  tstatwriter(self).writearray(name,value);
 end
 else begin
  value:= tstatreader(self).readarray(name,value);
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; var value: longboolarty);
begin
 if fiswriter then begin
  tstatwriter(self).writearray(name,value);
 end
 else begin
  value:= tstatreader(self).readarray(name,value);
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; var value: realarty);
begin
 if fiswriter then begin
  tstatwriter(self).writearray(name,value);
 end
 else begin
  value:= tstatreader(self).readarray(name,value);
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; var value: msestringarty);
begin
 if fiswriter then begin
  tstatwriter(self).writearray(name,value);
 end
 else begin
  value:= tstatreader(self).readarray(name,value);
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; var value: string);
begin
 if fiswriter then begin
  tstatwriter(self).writestring(name,value);
 end
 else begin
  value:= tstatreader(self).readstring(name,value);
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; var value: msestring);
begin
 if fiswriter then begin
  tstatwriter(self).writemsestring(name,value);
 end
 else begin
  value:= tstatreader(self).readmsestring(name,value);
 end;
end;

procedure tstatfiler.updatestat(const intf: istatfile);
begin
 if fiswriter then begin
  tstatwriter(self).writestat(intf);
 end
 else begin
  intf.statreading;
  try
   tstatreader(self).readstat(intf);
  finally
   intf.statread;
  end;
 end;
end;

procedure tstatfiler.updatevalue(const name: msestring; const intf: istatupdatevalue);
begin
 if fiswriter then begin
  tstatwriter(self).writevalue(name,intf);
 end
 else begin
  tstatreader(self).readvalue(name,intf);
 end;
end;

procedure tstatfiler.updatememorystatstream(const name: msestring; const streamname: msestring);
begin
 if iswriter then begin
  tstatwriter(self).writememorystatstream(name,streamname);
 end
 else begin
  tstatreader(self).readmemorystatstream(name,streamname);
 end;
end;

procedure tstatfiler.updatestatfile(const name: msestring; const statfile: tstatfile);
begin
 if iswriter then begin
  tstatwriter(self).writestatfile(name,statfile);
 end
 else begin
  tstatreader(self).readstatfile(name,statfile);
 end;
end;

function tstatfiler.varname(const intf: istatfile): msestring;
begin
 result:= intf.getstatvarname;
 if result = '' then begin
  result:= ownernamepath(tcomponent(intf.getinstance));
 end;
end;

{ tstatreader }

constructor tstatreader.create(const stream: ttextstream);
begin
 inherited;
 fsectionlist:= thashedmsestrings.create;
 readdata;
end;

constructor tstatreader.create(const filename: filenamety);
begin
 fownsstream:= true;
 create(ttextstream.Create(filename,fm_read));
end;

destructor tstatreader.destroy;
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to fsectioncount - 1 do begin
  fsections[int1].names.Free;
 end;
 fsectionlist.Free;
end;

procedure tstatreader.readdata;
var
 str1: msestring;
 int1: integer;
begin
 if fstream <> nil then begin
  str1:= '';
  while not fstream.eof do begin
   while not fstream.eof and not((length(str1) > 0) and (str1[1] = '[')) do begin
    try
     fstream.readln(str1);
    except
     exit;
    end;
   end;
   if not fstream.eof then begin
    int1:= msestrscan(str1,msechar(']'));
    if int1 > 0 then begin
     if fsectioncount <= length(fsections) then begin
      setlength(fsections,length(fsections)+16);
     end;
     inc(fsectioncount);
     fsectionlist.add(copy(str1,2,int1-2),pointer(fsectioncount));
     with fsections[fsectioncount-1] do begin
      names:= thashedmsestrings.create;
      count:= 0;
      while fstream.readln(str1) do begin
       if (length(str1) > 0) and (str1[1] = '[') then begin
        break;
       end;
       if count >= length(values) then begin
        setlength(values,length(values)+16);
       end;
       inc(count);
       if (length(str1) > 0) and (str1[1] <> ' ') then begin
        int1:= msestrscan(str1,msechar('='));
        if int1 > 0 then begin
         names.add(copy(str1,1,int1-1),pointer(count));
         values[count-1]:= copy(str1,int1+1,bigint);
        end
        else begin
         values[count-1]:= str1;
        end;
       end
       else begin
        values[count-1]:= str1;
       end;
      end;
     end;
    end
    else begin
     str1:= '';
    end;
   end;
  end;
 end;
end;

function tstatreader.findvar(const name: msestring; var value: msestring): boolean;
var
 int1: integer;
 ch1: msechar;
 int2: integer;
begin
 if factsection <> nil then begin
  with factsection^ do begin
   if flistlevel = 0 then begin
    factitem:= integer(names.find(name));
    if factitem = 0 then begin
     result:= false;
    end
    else begin
     dec(factitem);
     value:= values[factitem];
     result:= true;
    end;
   end
   else begin
    result:= false;
    for int1:= fliststart[flistlevel] to high(values) do begin
     if length(values[int1]) > flistlevel then begin
      ch1:= values[int1][flistlevel+1];
      if ch1 = ')' then begin
       break;
      end;
      if ch1 <> ' ' then begin
       int2:= msestrscan(values[int1],msechar('='));
       if (int2 > 0) and (msestrlcomp(pmsechar(values[int1])+flistlevel,
               pmsechar(name),length(name)) = 0) then begin
        factitem:= int1;
        value:= copy(values[int1],int2+1,bigint);
        result:= true;
        break;
       end;
      end;
     end;
    end;
   end;
  end;
 end
 else begin
  result:= false;
 end;
end;

function tstatreader.checkvar(const name: msestring): boolean;
begin
 result:= (factsection <> nil) and (factsection^.names.find(name) <> nil);
end;

function tstatreader.readboolean(const name: msestring; const default: boolean = false): boolean;
begin
 result:= readinteger(name,integer(default)) <> 0;
end;

function tstatreader.readbyte(const name: msestring; const default: byte = 0): byte;
begin
 result:= readinteger(name,default);
end;

function tstatreader.readword(const name: msestring; const default: word = 0): word;
begin
 result:= readinteger(name,default);
end;

procedure tstatreader.checkintegerrange(var value: integer; const min,max: integer);
begin
 if value > max then begin
  value:= max;
 end
 else begin
  if value < min then begin
   value:= min;
  end;
 end;
end;

function tstatreader.readinteger(const name: msestring; const default: integer = 0;
               const min: integer = -(maxint)-1; const max: integer = maxint): integer;
var
 str1: msestring;
begin
 if not findvar(name,str1) then begin
  result:= default;
 end
 else begin
  try
   result:= strtoint(str1);
   checkintegerrange(result,min,max);
  except
   result:= default;
  end;
 end;
end;

procedure tstatreader.checkrealrange(var value: realty; const min,max: realty);
begin
 if cmprealty(value,max) > 0 then begin
  value:= max;
 end
 else begin
  if cmprealty(value,min) < 0 then begin
   value:= min;
  end;
 end;
end;

function tstatreader.readreal(const name: msestring; const default: real = 0;
               const min: real = -bigreal; const max: real = bigreal): realty;
var
 str1: msestring;
begin
 if not findvar(name,str1) then begin
  result:= default;
 end
 else begin
  try
   result:= strtorealtydot(str1);
   checkrealrange(result,min,max);
  except
   result:= default;
  end;
 end;
end;

function tstatreader.readstring(const name: msestring; const default: string): string;
var
 str1: msestring;
begin
 if not findvar(name,str1) then begin
  result:= default;
 end
 else begin
  result:= str1;
 end;
end;

function tstatreader.readmsestring(const name: msestring;
  const default: msestring): msestring;
begin
 result:= ''; //compilerwarning
 if not findvar(name,result) then begin
  result:= default;
 end;
end;

function tstatreader.readlistitem: msestring;
var
 int1: integer;
begin
 inc(factitem);
 result:= '';
 if factitem < factsection^.count then begin
  result:= factsection^.values[factitem];
  if result <> '' then begin
   for int1:= 1 to flistlevel + 1 do begin
    if result[int1] <> ' ' then begin
     exit;
    end;
   end;
  end;
  result:= copy(result,flistlevel+2,bigint);
 end;
end;

procedure tstatreader.readdatalist(const name: msestring;  const value: tdatalist);
var
 str1: msestring;
// wstr1: msestring;
// int1,int2: integer;
// rea1: realty;
begin
 if findvar(name,str1) then begin
  try
   tdatalist1(value).readstate(self,strtoint(str1));
  except
  end;
 end;
end;

function tstatreader.findsection(const name: msestring): boolean;
var
 int1: integer;
begin
 flistlevel:= 0;
 int1:= integer(fsectionlist.find(name));
 if int1 = 0 then begin
  factsection:= nil;
 end
 else begin
  factsection:= @fsections[int1-1];
 end;
 result:= int1 <> 0;
end;

procedure tstatreader.readstat(const intf: istatfile);
begin
 if intf <> nil then begin
  findsection(varname(intf));
  intf.dostatread(self);
 end;
end;

procedure tstatreader.readvalue(const name: msestring; const intf: istatupdatevalue);
begin
 if intf <> nil then begin
  intf.statreadvalue(name,self);
 end;
end;

function tstatreader.readarray(const name: msestring;
                     const default: msestringarty): msestringarty;
var
 str1: msestring;
 int1,int2: integer;
begin
 if findvar(name,str1) then begin
  int2:= strtoint(str1);
  setlength(result,int2);
  for int1:= 0 to int2-1 do begin
   result[int1]:= readlistitem;
  end;
 end
 else begin
  result:= default;
  setlength(result,length(result));
 end;
end;

function tstatreader.readarray(const name: msestring;
  const default: stringarty): stringarty;
var
 str1: msestring;
 int1,int2: integer;
begin
 if findvar(name,str1) then begin
  int2:= strtoint(str1);
  setlength(result,int2);
  for int1:= 0 to int2-1 do begin
   result[int1]:= readlistitem;
  end;
 end
 else begin
  result:= default;
 end;
end;

function tstatreader.readarray(const name: msestring;
  const default: integerarty): integerarty;
var
 str1: msestring;
 int1,int2: integer;
begin
 if findvar(name,str1) then begin
  int2:= strtoint(str1);
  setlength(result,int2);
  for int1:= 0 to int2-1 do begin
   try
    result[int1]:= strtoint(readlistitem);
   except
    break;
   end;
  end;
 end
 else begin
  result:= default;
 end;
end;

function tstatreader.readarray(const name: msestring;
            const default: longboolarty): longboolarty;
var
 str1: msestring;
 int1,int2: integer;
begin
 if findvar(name,str1) then begin
  int2:= strtoint(str1);
  setlength(result,int2);
  for int1:= 0 to int2-1 do begin
   try
    result[int1]:= longbool(strtoint(readlistitem));
   except
    break;
   end;
  end;
 end
 else begin
  result:= default;
 end;
end;

function tstatreader.readarray(const name: msestring;
  const default: realarty): realarty;
var
 str1: msestring;
 int1,int2: integer;
begin
 if findvar(name,str1) then begin       //todo: how to cancel on error?
  int2:= strtoint(str1);
  setlength(result,int2);
  for int1:= 0 to int2-1 do begin
   try
    result[int1]:= strtorealtydot(readlistitem);
   except
    break;
   end;
  end;
 end
 else begin
  result:= default;
 end;
end;

procedure tstatreader.readrecord(const name: msestring; const values: array of pointer;
                                   const default: array of const);
var
 str1: msestring;
 str2: string;
begin
 str2:= getrecordtypechars(default);
 if length(str2) > length(values) then begin
  setlength(str2,length(values));
 end;
 if not findvar(name,str1) or not decoderecord(str1,values,str2) then begin
  copyvariantarray(default,values);
 end;
end;

procedure tstatreader.readrecordarray(const name: msestring;
                 setcount: recsetcounteventty; store: recstoreeventty);
var
 str1: msestring;
 int1,int2: integer;
begin
 if findvar(name,str1) then begin
  try
   int2:= strtoint(str1);
   setcount(int2);
   for int1:= 0 to int2-1 do begin
    store(int1,readlistitem);
   end;
  except
   setcount(0);
  end;
 end
 else begin
  setcount(0);
 end;
end;

procedure tstatreader.readrecordarray(const name: msestring;
                 setcount: recsetcountevent1ty; store: recstoreevent1ty);
var
 str1: msestring;
 int1,int2: integer;
begin
 if findvar(name,str1) then begin
  try
   int2:= strtoint(str1);
   setcount(int2);
   for int1:= 0 to int2-1 do begin
    store(int1,readlistitem);
   end;
  except
   setcount(0);
  end;
 end
 else begin
  setcount(0);
 end;
end;

function tstatreader.beginlist(const name: msestring = ''): boolean;
var
 str1: msestring;
begin
 result:= false;
 if factsection <> nil then begin
  if (name <> '') and not findvar(name,str1) then begin
   exit;
  end;
  inc(flistlevel);
  inc(factitem);
  with factsection^ do begin
   if (high(values) >= factitem) and (length(values[factitem]) > flistlevel) and
    (values[factitem][flistlevel+1] = '(') then begin
    result:= true;
    if high(fliststart) <= flistlevel then begin
     setlength(fliststart,flistlevel+16);
    end;
    fliststart[flistlevel]:= factitem;
   end
   else begin
    dec(flistlevel);
    dec(factitem);
   end;
  end;
 end;
end;

function tstatreader.endlist: boolean;
var
 int1: integer;
begin
 result:= false;
 if (factsection <> nil) and (flistlevel > 0) then begin
  with factsection^ do begin
   for int1:= fliststart[flistlevel] to high(values) do begin
    if (length(values[int1]) > flistlevel) and
           (values[int1][flistlevel+1] = ')') then begin
     result:= true;
     factitem:= int1;
     break;
    end;
   end;
  end;
  dec(flistlevel);
 end;
end;

procedure tstatreader.readmemorystatstream(const name, streamname: msestring);
var
 ar1: msestringarty;
 stream: ttextstream;
begin
 ar1:= readarray(name,msestringarty(nil));
 if high(ar1) >= 0 then begin
  stream:= nil;
  try
   try
    stream:= memorystatstreams.open(streamname,fm_read);
    stream.encoding:= fstream.encoding;
    stream.size:= 0;
    stream.writemsestrings(ar1);
   finally
    stream.Free;
   end;
  except
  end;
 end
 else begin
  memorystatstreams.delete(streamname);
 end;
end;

procedure tstatreader.readstatfile(const name: msestring; const statfile: tstatfile);
var
 stream: ttextstream;
 ar1: msestringarty;
begin
 ar1:= readarray(name,msestringarty(nil));
 stream:= ttextstream.Create;
 try
  stream.writemsestrings(ar1);
  stream.Position:= 0;
  statfile.readstat(stream);
 finally
  stream.Free;
 end;
end;

{ tstatwriter }

constructor tstatwriter.create(const stream: ttextstream);
begin
 fiswriter:= true;
 inherited;
end;

constructor tstatwriter.create(const filename: filenamety);
begin
 fownsstream:= true;
 create(ttextstream.Create(filename,fm_create));
end;

procedure tstatwriter.writesection(const name: msestring);
begin
 fstream.writeln(msestring('[')+name+msestring(']'));
 flistlevel:= 0;
end;

procedure tstatwriter.writestat(const intf: istatfile);
begin
 if (intf <> nil) and (fstream <> nil) then begin
  writesection(varname(intf));
  intf.dostatwrite(self);
 end;
end;

procedure tstatwriter.writevalue(const name: msestring; const intf: istatupdatevalue);
begin
 if intf <> nil then begin
  intf.statwritevalue(name,self);
 end;
end;

procedure tstatwriter.writeval(const name: msestring; const avalue: msestring);
begin
 fstream.writeln(charstring(msechar(' '),flistlevel)+name+'='+avalue);
end;

procedure tstatwriter.writeinteger(const name: msestring; const value: integer);
begin
 writeval(name,inttostr(value));
end;

procedure tstatwriter.writeboolean(const name: msestring; const value: boolean);
begin
 writeinteger(name,integer(value));
end;

procedure tstatwriter.writebyte(const name: msestring; const value: byte);
begin
 writeinteger(name,value);
end;

procedure tstatwriter.writeword(const name: msestring; const value: word);
begin
 writeinteger(name,value);
end;

procedure tstatwriter.writereal(const name: msestring; const value: real);
begin
 writeval(name,realtytostrdot(value));
end;

procedure tstatwriter.writestring(const name: msestring; const value: string);
begin
 writeval(name,value);
end;

procedure tstatwriter.writemsestring(const name: msestring;
  const value: msestring);
begin
 writeval(name,value);
end;

procedure tstatwriter.writerecord(const name: msestring;
  const values: array of const);
begin
 writemsestring(name,encoderecord(values));
end;

procedure tstatwriter.writerecordarray(const name: msestring; const count: integer;
                 get: recgetrecordeventty);
var
 int1: integer;
begin
 writeinteger(name,count);
 for int1:= 0 to count - 1 do begin
  writelistval(get(int1));
 end;
end;

procedure tstatwriter.writerecordarray(const name: msestring; const count: integer;
                 get: recgetrecordevent1ty);
var
 int1: integer;
begin
 writeinteger(name,count);
 for int1:= 0 to count - 1 do begin
  writelistval(get(int1));
 end;
end;

procedure tstatwriter.writelistval(const avalue: msestring);
begin
 fstream.writeln(charstring(msechar(' '),flistlevel+1)+avalue)
end;

procedure tstatwriter.writelistitem(const value: msestring);
begin
 writelistval(value);
end;

procedure tstatwriter.writelistitem(const value: integer);
begin
 writelistval(inttostr(value));
end;

procedure tstatwriter.writelistitem(const value: realty);
begin
 writelistval(realtytostrdot(value));
end;

procedure tstatwriter.writedatalist(const name: msestring; const value: tdatalist);
begin
 tdatalist1(value).writestate(self,name);
end;

procedure tstatwriter.writearray(const name: msestring; const value: msestringarty);
var
 int1: integer;
begin
 writeinteger(name,length(value));
 for int1:= 0 to high(value) do begin
  writelistitem(value[int1]);
 end;
end;

procedure tstatwriter.writearray(const name: msestring; const value: stringarty);
var
 int1: integer;
begin
 writeinteger(name,length(value));
 for int1:= 0 to high(value) do begin
  writelistitem(value[int1]);
 end;
end;

procedure tstatwriter.writearray(const name: msestring; const value: integerarty);
var
 int1: integer;
begin
 writeinteger(name,length(value));
 for int1:= 0 to high(value) do begin
  writelistitem(value[int1]);
 end;
end;

procedure tstatwriter.writearray(const name: msestring; const value: longboolarty);
var
 int1: integer;
begin
 writeinteger(name,length(value));
 for int1:= 0 to high(value) do begin
  writelistitem(integer(value[int1]));
 end;
end;

procedure tstatwriter.writearray(const name: msestring; const value: realarty);
var
 int1: integer;
begin
 writeinteger(name,length(value));
 for int1:= 0 to high(value) do begin
  writelistitem(value[int1]);
 end;
end;

function tstatwriter.beginlist(const name: msestring = ''): boolean;
begin
 result:= true;
 if name <> '' then begin
  writestring(name,'');
 end;
 inc(flistlevel);
 fstream.writeln(charstring(msechar(' '),flistlevel)+'(');
end;

function tstatwriter.endlist: boolean;
begin
 if flistlevel > 0 then begin
  result:= true;
  fstream.writeln(charstring(msechar(' '),flistlevel)+')');
  dec(flistlevel);
 end
 else begin
  result:= false;
 end;
end;

procedure tstatwriter.writememorystatstream(const name,streamname: msestring);
var
 stream: ttextstream;
 ar1: msestringarty;
begin
 ar1:= nil; //compiler warning
 stream:= memorystatstreams.open(streamname,fm_read);
 try
  stream.encoding:= fstream.encoding;
  if stream.Size > 0 then begin
   ar1:= stream.readmsestrings;
   writearray(name,ar1);
  end;
 finally
  stream.Free;
 end;
end;

procedure tstatwriter.writestatfile(const name: msestring; const statfile: tstatfile);
var
 stream: ttextstream;
 ar1: msestringarty;
begin
 stream:= ttextstream.Create;
 try
  statfile.writestat(stream);
  stream.position:= 0;
  ar1:= stream.readmsestrings;
  writearray(name,ar1);
 finally
  stream.Free;
 end;
end;

{ tstatfile }

constructor tstatfile.create(aowner: tcomponent);
begin
// ffilename:= defaultstatfilename;
 fencoding:= ce_utf8n;
 inherited;
end;

procedure tstatfile.initnewcomponent;
begin
 ffilename:= defaultstatfilename;
end;

procedure tstatfile.dostatread(const reader: tstatreader);
var
 ar1,ar2: stringarty;
 stream1: ttextstream;
begin
 if reader <> areader then begin
  if not (sfo_memory in foptions) then begin
   filename:= reader.readstring('filename',ffilename);
  end
  else begin
   if sfo_savedata in foptions then begin
    stream1:= memorystatstreams.open(ffilename,fm_read);
    try
     ar2:= stream1.readstrings;
    finally
     stream1.free;
    end;
    ar1:= reader.readarray('data',ar2);
    stream1:= memorystatstreams.open(ffilename,fm_create);
    try
     stream1.writestrings(ar1);     
    finally
     stream1.free;
    end;
   end;
  end;
  statread;
 end
 else begin
  if assigned(fonstatupdate) then begin
   fonstatupdate(self,reader);
  end;
  if assigned(fonstatread) then begin
   fonstatread(self,reader);
  end;
 end;
end;

procedure tstatfile.dostatwrite(const writer: tstatwriter);
var
 ar1: stringarty;
 stream1: ttextstream;
begin
 if (writer <> awriter) then begin
  if not (sfo_memory in foptions) then begin
   writer.writestring('filename',ffilename);
  end
  else begin
   if sfo_savedata in foptions then begin
    stream1:= memorystatstreams.open(ffilename,fm_read);
    try
     ar1:= stream1.readstrings;     
    finally
     stream1.free;
    end;
    writer.writearray('data',ar1);
   end;
  end;
//  if ffilename <> '' then begin
//   writestat;
//  end;
 end
 else begin
  if assigned(fonstatupdate) then begin
   fonstatupdate(self,writer);
  end;
  if assigned(fonstatwrite) then begin
   fonstatwrite(self,writer);
  end;
 end;
end;

function tstatfile.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tstatfile.dolinkstatread(const info: linkinfoty);
begin
 areader.readstat(istatfile(info.dest));
end;

procedure tstatfile.dolinkstatreading(const info: linkinfoty);
begin
 istatfile(info.dest).statreading;
end;

procedure tstatfile.dolinkstatreaded(const info: linkinfoty);
begin
 istatfile(info.dest).statread;
end;

procedure tstatfile.readstat(stream: ttextstream = nil);
var
 stream1: ttextstream;
 ar1: filenamearty;
begin
 if assigned(fonstatbeforeread) then begin
  fonstatbeforeread(self);
 end;
 stream1:= stream;
 try
  if (stream1 = nil) and (filename <> '') then begin
   try
    if sfo_memory in foptions then begin
     stream1:= memorystatstreams.open(ffilename,fm_read);
    end
    else begin
     unquotefilename(ffiledir,ar1);
     if not findfile(ffilename,ar1,floadedfile) then begin
      floadedfile:= ffilename;
     end;
     stream1:= ttextstream.Create(floadedfile,fm_read);
    end;
    stream1.encoding:= fencoding;
   except
    floadedfile:= '';
   end;
  end;
  areader:= tstatreader.create(stream1);
  try
   if assigned(fonstatread) or assigned(fonstatupdate) then begin
    areader.readstat(istatfile(self));
   end;
   if fobjectlinker <> nil then begin
    fobjectlinker.forall({$ifdef FPC}@{$endif}dolinkstatreading,typeinfo(istatfile));
    try
     fobjectlinker.forall({$ifdef FPC}@{$endif}dolinkstatread,typeinfo(istatfile));
    finally
     fobjectlinker.forall({$ifdef FPC}@{$endif}dolinkstatreaded,typeinfo(istatfile));
    end;
    if assigned(fonstatafterread) then begin
     fonstatafterread(self);
    end;
   end;
  finally
   areader.free;
  end;
 finally
  if stream = nil then begin
   stream1.Free;
  end;
 end;
end;

procedure tstatfile.statreading;
begin
 //dummy
end;

procedure tstatfile.statread;
begin
 //dummy
end;

procedure tstatfile.dolinkstatwrite(const info: linkinfoty);
begin
 awriter.writestat(istatfile(info.dest));
end;

procedure tstatfile.writestat(const stream: ttextstream = nil);
var
 stream1: ttextstream;
 ar1: filenamearty;
begin
 if assigned(fonstatbeforewrite) then begin
  fonstatbeforewrite(self);
 end;
 stream1:= stream;
 if (stream1 = nil) and (filename <> '') then begin
  if sfo_memory in foptions then begin
   stream1:= memorystatstreams.open(ffilename,fm_create);
  end
  else begin
   if floadedfile = '' then begin
    unquotefilename(ffiledir,ar1);
    if not findfile(ffilename,ar1,floadedfile) then begin
     if high(ar1) >= 0 then begin
      floadedfile:= filepath(ar1[0],ffilename);
     end
     else begin
      floadedfile:= ffilename;
     end;
    end;
   end;
   try
    stream1:= ttextstream.Create(floadedfile,fm_create);
   except
    floadedfile:= '';
    raise;
   end;
  end;
  stream1.encoding:= fencoding;
 end;
 try
  awriter:= tstatwriter.create(stream1);
  try
   if assigned(fonstatwrite) or assigned(fonstatupdate) then begin
    awriter.writestat(istatfile(self));
   end;
   if fobjectlinker <> nil then begin
    fobjectlinker.forall({$ifdef FPC}@{$endif}dolinkstatwrite,typeinfo(istatfile));
   end;
   if assigned(fonstatafterwrite) then begin
    fonstatafterwrite(self);
   end;
  finally
   awriter.free;
  end;
 finally
  if stream = nil then begin
   stream1.Free;
  end;
 end;
end;

procedure tstatfile.setstatfile(const Value: tstatfile);
var
 sf: tstatfile;
begin
 if fstatfile <> value then begin
  if value <> nil then begin
   sf:= value;
   while sf <> nil do begin
    if sf = self then begin
     raise exception.Create(name+': Recursive statfile');
    end;
    sf:= sf.fstatfile;
   end;
  end;
  setstatfilevar(istatfile(self),value,fstatfile);
 end;
end;

procedure tstatfile.setfilename(const avalue: filenamety);
begin
 floadedfile:= '';
 ffilename:= avalue;
end;

procedure tstatfile.setfiledir(const avalue: filenamety);
begin
 floadedfile:= '';
 ffiledir:= avalue;
end;

procedure tstatfile.setoptions(avalue: statfileoptionsty);
begin
 if not (sfo_memory in avalue) then begin
  exclude(avalue,sfo_savedata);
 end;
 foptions:= avalue;
end;

{ tmemorytextstream }

constructor tmemorytextstream.create(aowner: tmemorystreams; const name: msestring;
                           const openmode: fileopenmodety; var info: streaminfoty);
begin
 fowner:= aowner;
 fname:= name;
 info.name:= name;
 info.stream:= self;
 inherited create;
 if info.size > 0 then begin
  if openmode <> fm_create then begin
 {$ifdef mswindows}
  {$ifndef FPC}
   fmemorystream.SetSize(info.size);
   move(info.data^,fmemorystream.memory^,info.size);
            //on delphi memory is not on normal heap
   freemem(info.data);
  {$else}
   tmemorystreamcracker(fmemorystream).setpointer(info.data,info.size);
   tmemorystreamcracker(fmemorystream).fcapacity:= info.size;
  {$endif}
 {$else}
   tmemorystreamcracker(fmemorystream).setpointer(info.data,info.size);
   tmemorystreamcracker(fmemorystream).fcapacity:= info.size;
 {$endif} 
  end
  else begin
   freemem(info.data);
  end;
 end;
 info.data:= nil;
 info.size:= 0;
end;

destructor tmemorytextstream.destroy;
var
 int1: integer;
begin
 int1:= fowner.findname(fname);
 if int1 >= 0 then begin
  with fowner.fstreams[int1] do begin
   size:= self.Size;
{$ifdef mswindows}
 {$ifndef FPC}
   getmem(data,size);
   move(fmemorystream.memory^,data^,size);
           //on delphi memory is not on normal heap
 {$else}
   data:= fmemorystream.memory;
   tmemorystreamcracker(fmemorystream).setpointer(nil,0);
   reallocmem(data,size);
 {$endif}
{$else}
   data:= fmemorystream.memory;
   tmemorystreamcracker(fmemorystream).setpointer(nil,0);
   reallocmem(data,size);
{$endif}
   stream:= nil;
  end;
 end;
 inherited;
end;

{ tmemorystreams }

procedure tmemorystreams.internaldelete(index: integer);
begin
 if index >= 0 then begin
  with fstreams[index] do begin
   freeandnil(stream);
   if data <> nil then begin
    freemem(data);
    data:= nil;
   end;
   size:= 0;
   name:= '';
  end;
 end;
end;

procedure tmemorystreams.delete(const name: msestring);
begin
 internaldelete(findname(name));
end;

destructor tmemorystreams.destroy;
var
 int1: integer;
begin
 for int1:= 0 to high(fstreams) do begin
  internaldelete(int1);
 end;
 inherited;
end;

function tmemorystreams.findname(const name: msestring): integer;
var
 int1: integer;
begin
 result:= -1;
 for int1:= 0 to high(fstreams) do begin
  if fstreams[int1].name = name then begin
   result:= int1;
   break;
  end;
 end;
end;

function tmemorystreams.open(const streamname: msestring;
                    const openmode: fileopenmodety): ttextstream;
var
 int1: integer;
begin
 if streamname = '' then begin
  raise exception.Create('Invalid memory stream name.');
 end;
 int1:= findname(streamname);
 if (int1 >= 0) and (fstreams[int1].stream <> nil) then begin
  raise exception.Create('Memorystream '''+streamname+''' allready open.');
 end;
 if int1 < 0 then begin
  int1:= findname('');
  if int1 < 0 then begin
   int1:= length(fstreams);
   setlength(fstreams,int1+1);
  end;
 end;
 result:= tmemorytextstream.create(self,streamname,openmode,fstreams[int1]);
end;

initialization
finalization
 fmemorystatstreams.free;
end.
