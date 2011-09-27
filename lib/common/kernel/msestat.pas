{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestat;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 Classes,mseclasses,mselist,msestream,mseglob,msereal,msetypes,msestrings,
 msehash,msedatalist,msesys,mseeditglob;

const
 defaultstatfilename = 'status.sta';
type
 tstatreader = class;
 tstatwriter = class;

 istatfile = interface(iobjectlink)['{447AC132-A833-4532-82AB-244C0F5EE25E}']
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
 statfileroptionty = (sfro_nodata,sfro_nostate,sfro_nooptions);
 statfileroptionsty = set of statfileroptionty;
 
 tstatfiler = class
  private
   fstream: ttextstream;
   fownsstream: boolean;
   fiswriter: boolean;
   flistlevel: integer;
   foptions: statfileroptionsty;
  protected
  public
   constructor create(const astream: ttextstream;
                            const aencoding: charencodingty = ce_utf8n);
   destructor destroy; override;
   function varname(const intf: istatfile): msestring;
   function arrayname(const name: msestring; index: integer): msestring;
   function iswriter: boolean;
   property stream: ttextstream read fstream;

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
   procedure updatevalue(const name: msestring; var value: int64arty); overload;
   procedure updatevalue(const name: msestring; var value: realarty);  overload;
   procedure updatevalue(const name: msestring; var value: complexarty);  overload;

   procedure updatevalue(const name: msestring; const intf: istatupdatevalue); overload;
   procedure updatestat(const intf: istatfile);
   procedure updatememorystatstream(const name: msestring; const streamname: msestring);
   function beginlist(const name: msestring = ''): boolean;  virtual; abstract;
   function endlist: boolean;  virtual; abstract;
   property options: statfileroptionsty read foptions write foptions;
   function candata: boolean;
   function canstate: boolean;
   function canoptions: boolean;
 end;

 sectionty = record
  fileposition: integer;
  names: thashedmsestrings;
  count: integer;
  values: msestringarty;
 end;
 psectionty = ^sectionty;
 sectionarty = array of sectionty;

 recsetcounteventty = procedure(const acount: integer) of object;
 recsetcountevent1ty = procedure(const acount: integer);
 recstoreeventty = procedure(const aindex: integer; const avalue: msestring) of object;
 recstoreevent1ty = procedure(const aindex: integer; const avalue: msestring);

 tstatreader = class(tstatfiler)
  private
   fsectionlist: thashedmsestrings;
   fsections: sectionarty;
   fsectioncount: integer;
   factsection: psectionty;
   factitem: integer;
   fliststart: integerarty;
   fstatend: integer;
   procedure checkrealrange(var value: realty; const min,max: realty);
   procedure checkintegerrange(var value: integer; const min,max: integer);
   procedure checkint64range(var value: int64; const min,max: int64);
  protected
   procedure readdata;
   function findvar(const name: msestring; var value: msestring): boolean;
                                                overload; //true if ok
   function findvar(const name: msestring; var value: msestring;
                        out isarray: boolean): boolean; overload; //true if ok
  public
   constructor create(const astream: ttextstream;
                      const aencoding: charencodingty = ce_utf8n); overload;
   constructor create(const filename: filenamety;
                      const aencoding: charencodingty = ce_utf8n); overload;
   destructor destroy; override;
   function sections: msestringarty;
   function findsection(const name: msestring): boolean; //true if found
   function checkvar(const name: msestring): boolean; //true if found
   function streamdata: string;    //returns data after [-]
   function streamtext: msestring; //returns text after [-]

   function readboolean(const name: msestring; const default: boolean = false): boolean;
   function readbyte(const name: msestring; const default: byte = 0): byte;
   function readword(const name: msestring; const default: word = 0): word;
   function readinteger(const name: msestring; const default: integer = 0;
               const min: integer = -(maxint)-1; const max: integer = maxint): integer;
   function readint64(const name: msestring; const default: int64 = 0;
               const min: int64 = -(maxint64)-1; const max: int64 = maxint64): int64;
   function readreal(const name: msestring; const default: real = 0;
               const min: real = -bigreal; const max: real = bigreal): realty;
   function readstring(const name: msestring; const default: string): string;
   function readmsestring(const name: msestring; const default: msestring): msestring;
   function readmsestrings(const name: msestring; const default: msestring): msestring;
                         //handles linebreaks, 'ar' is multiline name extension
   procedure readdatalist(const name: msestring; const value: tdatalist);
   function readarray(const name: msestring; const default: stringarty): stringarty; overload;
   function readarray(const name: msestring; const default: msestringarty): msestringarty; overload;
   function readarray(const name: msestring; const default: widestringarty): widestringarty; overload;
   function readarray(const name: msestring; const default: integerarty): integerarty; overload;
   function readarray(const name: msestring; const default: int64arty): int64arty; overload;
   function readarray(const name: msestring; const default: booleanarty): booleanarty; overload;
   function readarray(const name: msestring; const default: longboolarty): longboolarty; overload;
   function readarray(const name: msestring;
                          const default: realarty): realarty; overload;
   function readarray(const name: msestring;
                          const default: complexarty): complexarty; overload;
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
 end;

 recgetrecordeventty = function(const index: integer): msestring of object;
 recgetrecordevent1ty = function(const index: integer): msestring;

 tstatwriter = class(tstatfiler)
  protected
   procedure writeval(const name: msestring; const avalue: msestring);
   procedure writelistval(const avalue: msestring);
  public
   constructor create(const astream: ttextstream;
                              const aencoding: charencodingty = ce_utf8n); overload;
   constructor create(const filename: filenamety; 
                              const aencoding: charencodingty = ce_utf8n;
                              const atransaction: boolean = true); overload;
 
   procedure writesection(const name: msestring);
   procedure writeboolean(const name: msestring; const value: boolean);
   procedure writebyte(const name: msestring; const value: byte);
   procedure writeword(const name: msestring; const value: word);
   procedure writeinteger(const name: msestring; const value: integer);
   procedure writeint64(const name: msestring; const value: int64);
   procedure writereal(const name: msestring; const value: real);
   procedure writestring(const name: msestring; const value: string);
   procedure writemsestring(const name: msestring; const value: msestring);
   procedure writemsestrings(const name: msestring; const value: msestring);
                       //handles linebreaks, 'ar' is multiline name extension
   procedure writedatalist(const name: msestring; const value: tdatalist);
   procedure writearray(const name: msestring; const value: stringarty); overload;
   procedure writearray(const name: msestring; const value: msestringarty); overload;
   procedure writearray(const name: msestring; const value: integerarty); overload;
   procedure writearray(const name: msestring; const value: int64arty); overload;
   procedure writearray(const name: msestring; const value: booleanarty); overload;
   procedure writearray(const name: msestring; const value: longboolarty); overload;
   procedure writearray(const name: msestring; const value: realarty); overload;
   procedure writearray(const name: msestring; const value: complexarty); overload;
 
   procedure writelistitem(const value: msestring); overload;
   procedure writelistitem(const value: integer); overload;
   procedure writelistitem(const value: realty); overload;
   procedure writelistitem(const value: complexty); overload;
 
   procedure writerecord(const name: msestring; const values: array of const);
   procedure writerecordarray(const name: msestring; const count: integer;
                  get: recgetrecordeventty); overload;
   procedure writerecordarray(const name: msestring; const count: integer;
                  get: recgetrecordevent1ty); overload;
   function beginlist(const name: msestring = ''): boolean; override;
   function endlist: boolean; override;
 
   procedure writevalue(const name: msestring; const intf: istatupdatevalue);
   procedure writestat(const intf: istatfile);
   procedure writememorystatstream(const name: msestring;
                                                 const streamname: msestring);
   procedure streamdata(const adata: string);
   procedure streamtext(const atext: msestring);
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
   function findfiles(const aname: msestring): msestringarty;
 end;
 
procedure deletememorystatstream(const streamname: msestring);
function memorystatstreams: tmemorystreams;

function canstatvalue(const editoptions: optionseditty;
                         const stat: tstatfiler): boolean;
function canstatstate(const editoptions: optionseditty;
                         const stat: tstatfiler): boolean;
function canstatoptions(const editoptions: optionseditty;
                         const stat: tstatfiler): boolean;

procedure readstringar(const reader: treader; out avalue: stringarty);
procedure writestringar(const writer: twriter; const avalue: stringarty);

implementation
uses
 sysutils,mseformatstr,msefileutils,msearrayutils;

type
 tdatalist1 = class(tdatalist);
 tmemorystreamcracker = class(tcustommemorystream)
  private
   fcapacity: longint;
 end;

procedure readstringar(const reader: treader; out avalue: stringarty);
var
 int1: integer;
begin
 reader.readlistbegin;
 int1:= 0;
 while not reader.endoflist do begin
  additem(avalue,reader.readstring,int1);
 end;
 reader.readlistend;
 setlength(avalue,int1);
end;

procedure writestringar(const writer: twriter; const avalue: stringarty);
var
 int1: integer;
begin
 writer.writelistbegin;
 for int1:= 0 to high(avalue) do begin
  writer.writestring(avalue[int1]);
 end;
 writer.writelistend;
end;

function canstatvalue(const editoptions: optionseditty;
                         const stat: tstatfiler): boolean;
begin
 result:= (oe_savevalue in editoptions) and stat.candata;
end;

function canstatstate(const editoptions: optionseditty;
                         const stat: tstatfiler): boolean;
begin
 result:= (oe_savestate in editoptions) and stat.canstate;
end;

function canstatoptions(const editoptions: optionseditty;
                         const stat: tstatfiler): boolean;
begin
 result:= (oe_saveoptions in editoptions) and stat.canoptions;
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

{ tstatfiler }                                                          

constructor tstatfiler.create(const astream: ttextstream;
                              const aencoding: charencodingty = ce_utf8n);
begin
 fstream:= astream;
 if fstream <> nil then begin
  fstream.encoding:= aencoding;
 end;
end;

function tstatfiler.arrayname(const name: msestring; index: integer): msestring;
begin
 result:= name + '_'+inttostrmse(index);
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

procedure tstatfiler.updatevalue(const name: msestring; var value: int64arty);
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

procedure tstatfiler.updatevalue(const name: msestring; var value: complexarty);
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
{
procedure tstatfiler.updatestatfile(const name: msestring; const statfile: tstatfile);
begin
 if iswriter then begin
  tstatwriter(self).writestatfile(name,statfile);
 end
 else begin
  tstatreader(self).readstatfile(name,statfile);
 end;
end;
}
function tstatfiler.varname(const intf: istatfile): msestring;
begin
 result:= intf.getstatvarname;
 if result = '' then begin
  result:= ownernamepath(tcomponent(intf.getinstance));
 end;
end;

function tstatfiler.candata: boolean;
begin
 result:= not (sfro_nodata in foptions);
end;

function tstatfiler.canstate: boolean;
begin
 result:= not (sfro_nostate in foptions);
end;

function tstatfiler.canoptions: boolean;
begin
 result:= not (sfro_nooptions in foptions);
end;

{ tstatreader }

constructor tstatreader.create(const astream: ttextstream;
                                  const aencoding: charencodingty = ce_utf8n);
begin
 inherited;
 fsectionlist:= thashedmsestrings.create;
 readdata;
end;

constructor tstatreader.create(const filename: filenamety;
                               const aencoding: charencodingty = ce_utf8n);
var
 stream1: ttextstream;
begin
 fownsstream:= true;
 stream1:= ttextstream.Create(filename,fm_read);
// stream1.encoding:= aencoding;
 create(stream1,aencoding);
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
//    int1:= msestrscan(str1,msechar(']'));
    int1:= findchar(str1,msechar(']'));
    if int1 > 0 then begin
     if int1 = 2 then begin
      fstatend:= fstream.position;
      exit;
     end;
     if fsectioncount <= length(fsections) then begin
      setlength(fsections,length(fsections)+16);
     end;
     inc(fsectioncount);
     fsectionlist.add(copy(str1,2,int1-2),pointer(ptruint(fsectioncount)));
     with fsections[fsectioncount-1] do begin
      fileposition:= fstream.position;
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
//        int1:= msestrscan(str1,msechar('='));
        int1:= findchar(str1,msechar('='));
        if int1 > 0 then begin
         names.add(copy(str1,1,int1-1),pointer(ptruint(count)));
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

function tstatreader.findvar(const name: msestring; 
                                         var value: msestring): boolean;
var
 int1: integer;
 ch1: msechar;
 int2: integer;
begin
 if factsection <> nil then begin
  with factsection^ do begin
   if flistlevel = 0 then begin
    factitem:= ptruint(names.find(name));
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
//       int2:= msestrscan(values[int1],msechar('='));
       int2:= findchar(values[int1],msechar('='));
       if (int2 = flistlevel+length(name)+1) and (msestrlcomp(pmsechar(values[int1])+flistlevel,
//       if (int2 > 0) and (msestrlcomp(pmsechar(values[int1])+flistlevel,
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

function tstatreader.findvar(const name: msestring; var value: msestring;
                                                out isarray: boolean): boolean;
begin
 result:= findvar(name,value);
 isarray:= false;
 if result then begin
  with factsection^ do begin
   if (factitem < count - 1) and (length(values[factitem+1]) > flistlevel) and
              (values[factitem+1][flistlevel+1] = ' ') then begin
    isarray:= true;
   end;
  end;
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
 if max < min then begin  //unsigned
  if longword(value) > longword(max) then begin
   value:= max;
  end
  else begin
   if longword(value) < longword(min) then begin
    value:= min;
   end;
  end;
 end
 else begin
  if value > max then begin
   value:= max;
  end
  else begin
   if value < min then begin
    value:= min;
   end;
  end;
 end;
end;

procedure tstatreader.checkint64range(var value: int64; const min,max: int64);
begin
 if max < min then begin  //unsigned
 {$ifdef FPC}
  if qword(value) > qword(max) then begin
   value:= max;
  end
  else begin
   if qword(value) < qword(min) then begin
    value:= min;
   end;
  end;
  {$else}
   //delphi has no unsigned 64 bit type
  {$endif}
 end
 else begin
  if value > max then begin
   value:= max;
  end
  else begin
   if value < min then begin
    value:= min;
   end;
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
  if trystrtointmse(str1,result) then begin
   checkintegerrange(result,min,max);
  end
  else begin
   result:= default;
  end;
 end;
end;

function tstatreader.readint64(const name: msestring; const default: int64 = 0;
               const min: int64 = -(maxint64)-1; const max: int64 = maxint64): int64;
var
 str1: msestring;
begin
 if not findvar(name,str1) then begin
  result:= default;
 end
 else begin
  if trystrtoint64mse(str1,result) then begin
   checkint64range(result,min,max);
  end
  else begin
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

function tstatreader.readmsestrings(const name: msestring;
  const default: msestring): msestring;
var
 ar1: msestringarty;
begin
 ar1:= readarray(name+'ar',msestringarty(nil){ar1});
 if high(ar1) >= 0 then begin
  result:= concatstrings(ar1,lineend);
 end
 else begin
  result:= readmsestring(name,default);
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
 int1: integer;
begin
 if findvar(name,str1) then begin
  try
   value.beginupdate;
   try
    if trystrtointmse(str1,int1) then begin
     tdatalist1(value).readstate(self,int1);
     tdatalist1(value).readappendix(self,name);
    end;
   finally
    value.endupdate;
   end;
  except
  end;
 end;
end;

function tstatreader.findsection(const name: msestring): boolean;
var
 int1: integer;
begin
 flistlevel:= 0;
 int1:= ptruint(fsectionlist.find(name));
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
 if findvar(name,str1) and trystrtointmse(str1,int2)then begin
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
                     const default: widestringarty): widestringarty;
var
 str1: msestring;
 int1,int2: integer;
begin
 if findvar(name,str1) and trystrtointmse(str1,int2) then begin
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
 if findvar(name,str1) and trystrtointmse(str1,int2) then begin
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
 if findvar(name,str1) and trystrtointmse(str1,int2) then begin
  setlength(result,int2);
  for int1:= 0 to int2-1 do begin
   if not trystrtointmse(readlistitem,result[int1]) then begin
    result:= default;
    break;
   end;
  end;
 end
 else begin
  result:= default;
 end;
end;

function tstatreader.readarray(const name: msestring;
                             const default: int64arty): int64arty;
var
 str1: msestring;
 int1,int2: integer;
begin
 if findvar(name,str1) and trystrtointmse(str1,int2) then begin
  setlength(result,int2);
  for int1:= 0 to int2-1 do begin
   if not trystrtoint64mse(readlistitem,result[int1]) then begin
    result:= default;
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
 int1,int2,int3: integer;
begin
 if findvar(name,str1) and trystrtointmse(str1,int2) then begin
  setlength(result,int2);
  for int1:= 0 to int2-1 do begin
   if not trystrtointmse(readlistitem,int3) then begin
    result:= default;
    break;
   end;
   result[int1]:= longbool(int3);
  end;
 end
 else begin
  result:= default;
 end;
end;

function tstatreader.readarray(const name: msestring;
            const default: booleanarty): booleanarty;
var
 str1: msestring;
 int1,int2,int3: integer;
begin
 if findvar(name,str1) and trystrtointmse(str1,int2) then begin
  setlength(result,int2);
  for int1:= 0 to int2-1 do begin
   if not trystrtointmse(readlistitem,int3) then begin
    result:= default;
    break;
   end;
   result[int1]:= boolean(int3);
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
 if findvar(name,str1) and trystrtointmse(str1,int2) then begin
  setlength(result,int2);
  for int1:= 0 to int2-1 do begin
   if not trystrtorealtydot(readlistitem,result[int1]) then begin
    result:= default;
    break;
   end;
  end;
 end
 else begin
  result:= default;
 end;
end;

function tstatreader.readarray(const name: msestring;
                               const default: complexarty): complexarty;
var
 str1: msestring;
 int1,int2: integer;
begin
 if findvar(name,str1) and trystrtointmse(str1,int2) then begin   
  setlength(result,int2);
  for int1:= 0 to int2-1 do begin
   if not decoderecord(
          readlistitem,[@result[int1].re,@result[int1].im],'rr') then begin
    result:= default;
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
 if findvar(name,str1) and trystrtointmse(str1,int2) then begin
  try
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
 if findvar(name,str1) and trystrtointmse(str1,int2) then begin
  try
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
 stream1: ttextstream;
begin
 ar1:= readarray(name,msestringarty(nil));
 if high(ar1) >= 0 then begin
  stream1:= nil;
  try
   try
    stream1:= memorystatstreams.open(streamname,fm_read);
    stream1.encoding:= fstream.encoding;
    stream1.size:= 0;
    stream1.writemsestrings(ar1);
   finally
    stream1.Free;
   end;
  except
  end;
 end
 else begin
  memorystatstreams.delete(streamname);
 end;
end;

function tstatreader.sections: msestringarty;
var
 int1: integer;
begin
 setlength(result,fsectionlist.count);
 for int1:= 0 to high(result) do begin
  result[int1]:= fsectionlist.next^.key;
 end;
end;

function tstatreader.streamdata: string;
begin
 result:= '';
 if fstatend > 0 then begin
  fstream.position:= fstatend;
  result:= fstream.readdatastring;
 end;
end;

function tstatreader.streamtext: msestring;
begin
 result:= '';
 if fstatend > 0 then begin
  fstream.position:= fstatend;
  result:= fstream.readmsedatastring;
 end;
end;
{
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
}
{ tstatwriter }

constructor tstatwriter.create(const astream: ttextstream;
                                const aencoding: charencodingty = ce_utf8n);
begin
 fiswriter:= true;
 inherited;
end;

constructor tstatwriter.create(const filename: filenamety;
                               const aencoding: charencodingty = ce_utf8n;
                                       const atransaction: boolean = true);
var
 stream1: ttextstream;
begin
 fownsstream:= true;
 if atransaction then begin
  stream1:= ttextstream.Createtransaction(filename);
 end
 else begin
  stream1:= ttextstream.Create(filename,fm_create);
 end;
 create(stream1,aencoding);
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
 writeval(name,inttostrmse(value));
end;

procedure tstatwriter.writeint64(const name: msestring; const value: int64);
begin
 writeval(name,inttostrmse(value));
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

procedure tstatwriter.writemsestrings(const name: msestring;
  const value: msestring);
var
 ar1: msestringarty;
begin
 ar1:= breaklines(value);
 if high(ar1) > 0 then begin
  writearray(name+'ar',ar1);
 end
 else begin
  writeval(name,value);
 end;
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
 writelistval(inttostrmse(value));
end;

procedure tstatwriter.writelistitem(const value: realty);
begin
 writelistval(realtytostrdot(value));
end;

procedure tstatwriter.writelistitem(const value: complexty);
begin
 writelistval(encoderecord([value.re,value.im]));
end;

procedure tstatwriter.writedatalist(const name: msestring; const value: tdatalist);
begin
 tdatalist1(value).writestate(self,name);
 tdatalist1(value).writeappendix(self,name);
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

procedure tstatwriter.writearray(const name: msestring; const value: int64arty);
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

procedure tstatwriter.writearray(const name: msestring; const value: booleanarty);
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

procedure tstatwriter.writearray(const name: msestring; const value: complexarty);
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
 stream1: ttextstream;
 ar1: msestringarty;
begin
 ar1:= nil; //compiler warning
 stream1:= memorystatstreams.open(streamname,fm_read);
 try
  stream1.encoding:= fstream.encoding;
  if stream1.Size > 0 then begin
   ar1:= stream1.readmsestrings;
   writearray(name,ar1);
  end;
 finally
  stream1.Free;
 end;
end;

procedure tstatwriter.streamdata(const adata: string);
begin
 writesection('');
 fstream.write(adata);
end;

procedure tstatwriter.streamtext(const atext: msestring);
begin
 writesection('');
 fstream.write(atext);
end;
{
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
}
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
{$warnings off}
   tmemorystreamcracker(fmemorystream).setpointer(info.data,info.size);
{$warnings on}
{$warnings off}
   tmemorystreamcracker(fmemorystream).fcapacity:= info.size;
{$warnings on}
  {$endif}
 {$else}
{$warnings off}
   tmemorystreamcracker(fmemorystream).setpointer(info.data,info.size);
{$warnings on}
{$warnings off}
   tmemorystreamcracker(fmemorystream).fcapacity:= info.size;
{$warnings on}
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
{$warnings off}
   tmemorystreamcracker(fmemorystream).setpointer(nil,0);
{$warnings on}
   reallocmem(data,size);
 {$endif}
{$else}
   data:= fmemorystream.memory;
{$warnings off}
   tmemorystreamcracker(fmemorystream).setpointer(nil,0);
{$warnings on}
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

function tmemorystreams.findfiles(const aname: msestring): msestringarty;
var
 ar1: msestringarty;
 int1,int2: integer;
begin
 ar1:= nil;
 int2:= 0;
 splitstringquoted(aname,ar1);
 setlength(result,length(fstreams)); //max
 for int1:= 0 to high(result) do begin
  if checkfilename(fstreams[int1].name,ar1) then begin
   result[int2]:= fstreams[int1].name;
   inc(int2);
  end;
 end;
 setlength(result,int2);
end;

initialization
finalization
 fmemorystatstreams.free;
end.
