{ MSEgui Copyright (c) 1999-20012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesysenv;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}

interface
uses
 Classes,msestat,msestatfile,mseclasses,msetypes,msestrings,msedatalist,sysutils,
 mselist,msearrayutils,msemacros;
 
const
 commandlineparchar = '-';
 defaulterrorcode = 1;

type
 argumentkindty = (ak_none,
                 ak_envvar, //environement variable z.b. 'PATH'
                 ak_par,    //commandlineparameter
                            //z.b. '-v', '--help'
                 ak_pararg, //commandlineparameter mit argument
                            //z.b. '-vabc', '-v abc', '-v "abc def"
                            // '--file=abc'
                 ak_arg     //commandline argument, name muss '' sein,
                            // z.b. 'abc', '"abc def"
                 );

 argumentkindsty = set of argumentkindty;
const
 at_pars = [ak_par,ak_pararg];

type
 sysenverrornrty = (ern_io,ern_user,ern_invalidparameter,ern_missedargument,ern_invalidargument,
              ern_ambiguousparameter,ern_invalidinteger);
const
 errtexte: array[sysenverrornrty] of string = ('','',
  'Invalid Parameter','Missed Argument','Invalid Argument','Ambiguous Parameter',
  'Invalid Integer');
type
 argumentflagty = (arf_envdefined,   // wert aus env. gesetzt
                   arf_statdefined,  // wert aus statfile. gesetzt
                   arf_setdefined,   // wert aus programm gesetzt
                   arf_res1,arf_res2,arf_res3,arf_res4,arf_res5,
                   arf_argopt,       // argument optional
                   arf_filenames,    // argument wird durch pathsep gesplitted
                   arf_statoverride, // wert wird durch statfile ueberschrieben
                                     // ev. auch geloescht
                   arf_stataddval,   // wert wird von statfile geschrieben falls
                                     // noch nicht gesetzt
                   arf_integer       //fuer arg und pararg
                   );

 argumentflagsty = set of argumentflagty;

 sysenvoptionty = (seo_haltonerror,seo_exceptiononerror,seo_exitoninfo,seo_noerrormess,
                   seo_tooutput, //info -> outputpipe
                   seo_toerror   //errormeldung -> errorpipe
                   );
 sysenvoptionsty = set of sysenvoptionty;

const
 arf_defined = [arf_envdefined,arf_statdefined,arf_setdefined];
 defaultsysenvmanageroptions = [seo_tooutput,seo_toerror];

type
 ehalt = class(exception);

 argumentdefty = record
  kind: argumentkindty;
  name: string;   //case sensitive, single char ->
                  //  short parameter 'a' 'b' -> '-a' '-b' or '-ab' or '-ba',
                  // '-abcde' -> '--abcde'
  anames: pstring;//pointer auf array[0..0] of string alias,
                     //letzter string muss leer sein ('abc','def','');
  flags: argumentflagsty;
  initvalue: string;
 end;

 argumentdefpoty = ^argumentdefty;
 argumentdefarty = array [0..0] of argumentdefty;
 argumentdefarpoty = ^argumentdefarty;

 envvarty = record
  flags: argumentflagsty;
  values: msestringarty;
  name: msestring;
 end;
 envvararty = array of envvarty;

 tsysenvmanager = class;
 sysenvmanagereventty = procedure(sender: tsysenvmanager) of object;

 sysenvmanagervalueeventty = procedure(sender: tsysenvmanager;
           const index: integer; var defined: boolean;
                   var argument: msestringarty; var error: sysenverrornrty) of object;

 tsysenvmanager = class(tmsecomponent,istatfile)
  private
   foninit: sysenvmanagereventty;
   fenvvars: envvararty;
   foptions: sysenvoptionsty;
   ferrorcode: integer;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fonvalueread: sysenvmanagervalueeventty;
   procedure setoninit(const Value: sysenvmanagereventty);
   procedure doinit;
   procedure errorme(nr: sysenverrornrty; value: string);
   procedure printmessage(value: string);
   procedure checkindex(index: integer);
   function getdefined(index: integer): boolean;
   function getvalue(index: integer): msestring;
   function getvalues(index: integer): msestringarty;
   procedure setstatfile(const Value: tstatfile);
   function dovalueread(const index: integer;
                 var defined: boolean; var value: msestringarty): sysenverrornrty;
   procedure setdefined(index: integer; const Value: boolean);
   procedure setvalue(index: integer; const Value: msestring);
   procedure setvalues(index: integer; const Value: msestringarty);
   function setdef(index: integer; avalue: msestringarty;
             adefined: argumentflagsty): sysenverrornrty; overload;
   function setdef(index: integer; avalue: msestring;
             adefined: argumentflagsty): sysenverrornrty; overload;
   function getintegervalue1(index: integer): integer;
   procedure setintegervalue(index: integer; const Value: integer);
  protected
   //istatfiler
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;

   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure init(const arguments: array of argumentdefty);
   procedure processinfo(index: integer; value: string);
   procedure errormessage(const mess: string);
   function getcommandlinemacros(
           const macrodef: integer;
           const firstenvvarmacro: integer = -1; const lastenvvarmacro: integer = -1;
           prepend: macroinfoarty = nil): macroinfoarty;

   property defined[index: integer]: boolean read getdefined write setdefined; default;
   property objectlinker: tobjectlinker read getobjectlinker {$ifdef msehasimplements}
                                implements istatfile{$endif};
   property values[index: integer]: msestringarty read getvalues write setvalues;
   property value[index: integer]: msestring read getvalue write setvalue;
               //bringt letzten string in array
   property integervalue[index: integer]: integer read getintegervalue1
                        write setintegervalue;
               //bringt letzten string in array als integer
   function getintegervalue(var avalue: integer; const index: integer;
                   const min: integer = minint; const max: integer = maxint): boolean;
                             //false if not defined or not in range
   function findfirstfile(filename: filenamety; searchinvars: array of integer): filenamety;
                 //bringt erstes filevorkommen
   function findlastfile(filename: filenamety; searchinvars: array of integer): filenamety;
                 //bringt letztes filevorkommen
  published
   property options: sysenvoptionsty read foptions write foptions default defaultsysenvmanageroptions;
   property errorcode: integer read ferrorcode write ferrorcode default defaulterrorcode;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;

   property onvalueread: sysenvmanagervalueeventty read fonvalueread write fonvalueread;
   property oninit: sysenvmanagereventty read foninit write setoninit;
 end;

implementation
uses
 msesysutils,RTLConsts,msestream,msesys{$ifdef UNIX},mselibc{$endif};

{ tsysenvmanager }

constructor tsysenvmanager.create(aowner: tcomponent);
begin
 ferrorcode:= defaulterrorcode;
 foptions:= defaultsysenvmanageroptions;
 inherited;
end;

procedure tsysenvmanager.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

function tsysenvmanager.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tsysenvmanager.dostatread(const reader: tstatreader);
var
 int1,int2: integer;
 strar1: msestringarty;
 aflags: argumentflagsty;
begin
 strar1:= nil;
 with reader do begin
  int1:= readinteger('envvars',0,0,maxint);
  for int1:= 0 to int1-1 do begin
   int2:= readinteger(arrayname('flags',int1));
   strar1:= readarray(arrayname('values',int1),msestringarty(nil));
   aflags:= argumentflagsty({$ifdef FPC}longword{$else}word{$endif}(int2));
   if int1 < length(fenvvars) then begin
    with fenvvars[int1] do begin
     if aflags * arf_defined <> [] then begin
      aflags:= aflags - arf_defined + [arf_statdefined];
     end
     else begin
      aflags:= aflags - arf_defined;
     end;
     if arf_statoverride in flags then begin
      setdef(int1,strar1,flags);
     end
     else begin
      if (arf_stataddval in flags) and not (arf_envdefined in flags) and
              (arf_statdefined in aflags) then begin
       setdef(int1,strar1,aflags);
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tsysenvmanager.statreading;
begin
 //dummy
end;

procedure tsysenvmanager.statread;
begin
 //dummy
end;

procedure tsysenvmanager.dostatwrite(const writer: tstatwriter);
var
 int1: integer;
begin
 with writer do begin
  writeinteger('envvars',length(fenvvars));
  for int1:= 0 to high(fenvvars) do begin
   with fenvvars[int1] do begin
    writeinteger('flags',{$ifdef FPC}longword{$else}word{$endif}(flags));
    writearray(arrayname('values',int1),values);
//    writeln(word(flags));
//    writeln(values);
   end;
  end;
 end;
end;

procedure tsysenvmanager.checkindex(index: integer);
begin
 if (index < 0) or (index >= length(fenvvars)) then begin
  tlist.Error(SListIndexError, Index);
 end;
end;

procedure tsysenvmanager.doinit;
begin
 if not (csdesigning in componentstate) and
    assigned(foninit) then begin
  foninit(self);
 end;
end;

procedure tsysenvmanager.errorme(nr: sysenverrornrty; value: string);
var
 str1: string;
begin
 if nr <> ern_io then begin
  if not (seo_noerrormess in foptions) then begin
   if nr = ern_user then begin
    str1:= value;
   end
   else begin
    str1:= errtexte[nr] + ': '''+value+'''.';
   end;
   if seo_toerror in foptions then begin
    writestderr(str1,true);
   end
   else begin
//    dispfehler(str1,'Parameter Error'); //!!!!todo
   end;
  end;
  if seo_exceptiononerror in foptions then begin
   raise ehalt.Create('');
  end;
  if seo_haltonerror in foptions then begin
   halt(ferrorcode);
  end;
 end;
end;

procedure tsysenvmanager.printmessage(value: string);
begin
 if seo_tooutput in foptions then begin
  value:= value+lineend;
  writestdout(value);
 end
 else begin
//  dispmessage(value);  //!!!!todo
 end;
 if seo_exitoninfo in foptions then begin
  halt(0);
 end;
end;

function tsysenvmanager.findfirstfile(filename: filenamety;
  searchinvars: array of integer): filenamety;
var
 int1,int2: integer;
 index: integer;
 str1: filenamety;
begin
 result:= '';
 for int1:= 0 to high(searchinvars) do begin
  index:= searchinvars[int1];
  checkindex(index);
  for int2:= 0 to high(fenvvars[index].values) do begin
   str1:= fenvvars[index].values[int2];
   if str1 <> '' then begin
    str1:= includetrailingpathdelimiter(str1);
   end;
   str1:= str1 + filename;
   if fileexists(str1) then begin
    result:= str1;
    exit;
   end;
  end;
 end;
end;

function tsysenvmanager.findlastfile(filename: filenamety;
  searchinvars: array of integer): filenamety;
var
 int1,int2: integer;
 index: integer;
 str1: filenamety;
begin
 result:= '';
 for int1:= high(searchinvars) downto 0 do begin
  index:= searchinvars[int1];
  checkindex(index);
  for int2:= high(fenvvars[index].values) downto 0 do begin
   str1:= fenvvars[index].values[int2];
   if str1 <> '' then begin
    str1:= includetrailingpathdelimiter(str1);
   end;
   str1:= str1 + filename;
   if fileexists(str1) then begin
    result:= str1;
    exit;
   end;
  end;
 end;
end;

function tsysenvmanager.getdefined(index: integer): boolean;
begin
 checkindex(index);
 result:= fenvvars[index].flags * arf_defined <> [];
end;

procedure tsysenvmanager.setdefined(index: integer;
  const Value: boolean);
begin
 checkindex(index);
 if value then begin
  fenvvars[index].flags:= fenvvars[index].flags + [arf_setdefined];
 end
 else begin
  fenvvars[index].flags:= fenvvars[index].flags - arf_defined;
 end;
end;

function tsysenvmanager.getvalue(index: integer): msestring;
begin
 checkindex(index);
 if length(fenvvars[index].values) = 0 then begin
  result:= '';
 end
 else begin
  result:= fenvvars[index].values[high(fenvvars[index].values)];
 end;
end;

procedure tsysenvmanager.setvalue(index: integer; const Value: msestring);
var
 strar: msestringarty;
begin
 checkindex(index);
 setlength(strar,1);
 strar[0]:= value;
 setvalues(index,strar);
end;

function tsysenvmanager.getvalues(index: integer): msestringarty;
begin
 checkindex(index);
 result:= fenvvars[index].values;
end;

procedure tsysenvmanager.setvalues(index: integer;
  const Value: msestringarty);
begin
 checkindex(index);
 fenvvars[index].values:= value;
 setdefined(index,true);
end;

function tsysenvmanager.dovalueread(const index: integer;
               var defined: boolean; var value: msestringarty): sysenverrornrty;
begin
 result:= ern_io;
 if assigned(fonvalueread) then begin
  fonvalueread(self,index,defined,value,result);
 end;
end;

function tsysenvmanager.setdef(index: integer; avalue: msestringarty;
                            adefined: argumentflagsty): sysenverrornrty;
var
 strar1: msestringarty;
 int1: integer;
 bo1: boolean;
begin
 result:= ern_io;
 if index >= 0 then begin
  bo1:= adefined <> [];
  result:= dovalueread(index,bo1,avalue);
  if not bo1 then begin
   adefined:= adefined - arf_defined;
  end;
  adefined:= adefined * arf_defined;
  
  with fenvvars[index] do begin
   if flags * arf_defined = [] then begin
   {$ifdef FPC}
    setlength(values,0); //values:= nil; -> av!
   {$else}
    values:= nil; //initvalue entfernen
   {$endif}
   end;
   if adefined = [] then begin
    flags:= flags - arf_defined;
   end
   else begin
    flags:= flags + adefined;
   end;
   if result = ern_io then begin
    if arf_filenames in flags then begin
     for int1:= 0 to high(avalue) do begin
      splitstring(avalue[int1],strar1,pathsep);
      stackarray(strar1,values);
     end;
    end
    else begin
     if arf_integer in flags then begin
      for int1:= 0 to high(avalue) do begin
       try
        strtoint(avalue[int1]);
       except
        result:= ern_invalidinteger;
        break;
       end;
      end;
     end;
     if result = ern_io then begin
      stackarray(avalue,values);
     end;
    end;
   end;
  end;
 end;
end;

function tsysenvmanager.setdef(index: integer; avalue: msestring;
       adefined: argumentflagsty): sysenverrornrty;
var
 strar1: msestringarty;
begin
 setlength(strar1,1);
 strar1[0]:= avalue;
 result:= setdef(index,strar1,adefined);
end;

procedure tsysenvmanager.init(const arguments: array of argumentdefty);

var
 index: integer;
 strar1: stringarty;

 function finddef(typen: argumentkindsty; aname: string): integer;

  function checkname(const argumentdef: argumentdefty): boolean;

   function checkanames: boolean;
   var
    po1: pstring;
   begin
    result:= false;
    po1:= argumentdef.anames;
    if po1 <> nil then begin
     while po1^ <> '' do begin
      if comparestrlen(aname,po1^) = 0 then begin
       result:= true;
       exit;
      end;
      inc(po1);
     end;
    end;
   end;

  begin //checkname
   with argumentdef do begin
    result:= kind in typen;
    if result then begin
     result:= (comparestrlen(aname,name) = 0) or checkanames;
    end;
   end;
  end;

 var
  int1,int2: integer;
 begin
  for int1:= 0 to high(arguments) do begin
   if checkname(arguments[int1]) then begin
    result:= int1;
    for int2:= int1 + 1 to high(arguments) do begin
     if checkname(arguments[int2]) then begin
      errorme(ern_ambiguousparameter,strar1[index]);
      result:= -2;
      break;
     end;
    end;
    exit;
   end;
  end;
  result:= -1;
 end;

 function isparameter(const str: string): boolean;
 begin
  result:= (length(str) > 0) and (str[1] = commandlineparchar);
 end;

 procedure findswitch(str1: string);
 var
  int1: integer;

  procedure setoptargument;
  var
   needed: boolean;
  begin
   needed:= not (arf_argopt in arguments[int1].flags);
   inc(index);
   if index < length(strar1) then begin
    if isparameter(strar1[index]) then begin
     dec(index);
     if needed then begin
      errorme(ern_missedargument,strar1[index]);
     end
     else begin
      errorme(setdef(int1,nil,[arf_envdefined]),strar1[index]);
     end;
    end
    else begin
     errorme(setdef(int1,strar1[index],[arf_envdefined]),strar1[index]);
    end;
   end
   else begin
    dec(index);
    if needed then begin
     errorme(ern_missedargument,strar1[index]);
    end
    else begin
     errorme(setdef(int1,nil,[arf_envdefined]),strar1[index]);
    end;
   end;
  end;

  procedure checkarguments;
  begin
   case arguments[int1].kind of
    ak_pararg: begin
     if length(str1) > 0 then begin
      errorme(setdef(int1,str1,[arf_envdefined]),str1)
     end
     else begin
      setoptargument;
     end;
    end;
    ak_par: begin
     errorme(setdef(int1,nil,[arf_envdefined]),str1);
     if length(str1) > 0 then begin
      findswitch(str1);
     end;
    end;
   end;
  end;

 var
  strar2: stringarty;

 begin //findswitch
  if length(str1) > 0 then begin
   if isparameter(str1) then begin //langer parameter
    setlength(strar2,2);
    splitstring(str1,strar2,'=');
    int1:= finddef(at_pars,strar2[0]);
    if int1 >= 0 then begin
     with fenvvars[int1] do begin
      case arguments[int1].kind of
       ak_par: begin
        if length(strar2) > 1 then begin
         errorme(ern_invalidargument,strar1[index]);
        end
        else begin
         include(flags,arf_envdefined);
        end;
       end;
       ak_pararg: begin
        if length(strar2) > 1 then begin
         errorme(setdef(int1,strar2[1],[arf_envdefined]),strar1[index]);
        end
        else begin
         setoptargument;
        end;
       end;
      end;
     end;
    end
    else begin
     if int1 = -1 then begin
      errorme(ern_invalidparameter,strar1[index]);
     end;
    end;
   end
   else begin
    int1:= finddef(at_pars,str1);
    if int1 < 0 then begin
     int1:= finddef(at_pars,str1[1]);
     if int1 >= 0 then begin
      str1:= copy(str1,2,maxint);
      if int1 >= 0 then begin
       checkarguments;
      end;
     end
     else begin
      if int1 = -1 then begin
       errorme(ern_invalidparameter,strar1[index]);
      end;
     end;
    end
    else begin
     str1:= copy(str1,length(arguments[int1].name)+1,maxint);
     checkarguments;
    end;
   end;
  end
  else begin
   errorme(ern_invalidparameter,strar1[index]);
  end;
 end;

var
 int1: integer;
 str1: string;
 {$ifdef UNIX}
 po1: pchar;
 {$endif}
begin            //init
 if high(arguments) = -1 then begin
  exit;
 end;
 setlength(fenvvars,high(arguments)+1);
 for int1:= 0 to high(fenvvars) do begin
  with fenvvars[int1] do begin
   flags:= arguments[int1].flags;
   name:= arguments[int1].name;
   setlength(values,1);
   values[0]:= arguments[int1].initvalue;
  end;
 end;
 strar1:= getcommandlinearguments;
 index:= 1;
 while index < length(strar1) do begin
  str1:= strar1[index];
  if isparameter(str1) then begin
   str1:= copy(str1,2,maxint);
   findswitch(str1);
  end
  else begin
   int1:= finddef([ak_arg],'');
   if int1 >= 0 then begin
    errorme(setdef(int1,str1,[arf_envdefined]),str1);
   end
   else begin
    errorme(ern_invalidargument,str1);
   end;
  end;
  inc(index);
 end;
 for int1:= 0 to high(arguments) do begin
  with arguments[int1] do begin
   if kind = ak_envvar then begin
    {$ifdef mswindows}
    str1:=
    {$ifdef FPC}sysutils.{$endif}getenvironmentvariable(name);
           //!!!!  delphi bug flicken(info in qc)!!
    if str1 <> '' then begin
//     errorme(setdef(int1,str1,true),name);
     errorme(setdef(int1,str1,[arf_envdefined]),name);
    end;
    {$else}
    po1:= getenv(pchar(name));
    if po1 <> nil then begin
     errorme(setdef(int1,po1,[arf_envdefined]),name);
    end;
    {$endif};
   end;
  end;
 end;
end;

procedure tsysenvmanager.processinfo(index: integer; value: string);
begin
 if defined[index] then begin
  printmessage(value);
 end;
end;

procedure tsysenvmanager.setoninit(const Value: sysenvmanagereventty);
begin
 foninit := Value;
 if not (csloading in componentstate) then begin
  doinit;
 end;
end;

procedure tsysenvmanager.loaded;
begin
 inherited;
 doinit;
end;

function tsysenvmanager.getintegervalue1(index: integer): integer;
begin
 result:= strtoint(getvalue(index));
end;

function tsysenvmanager.getintegervalue(var avalue: integer; const index: integer;
                   const min: integer = minint; const max: integer = maxint): boolean;
                             //false if not defined or not in range
var
 int1: integer;
begin
 result:= defined[index];
 if result then begin
  int1:= integervalue[index];
  if (int1 < min) or (int1 > max) then begin
   result:= false;
  end
  else begin
   avalue:= int1;
  end;
 end;
end;

procedure tsysenvmanager.setintegervalue(index: integer;
  const Value: integer);
begin
 setvalue(index,inttostr(value));
end;

procedure tsysenvmanager.errormessage(const mess: string);
begin
 errorme(ern_user,mess);
end;

function tsysenvmanager.getcommandlinemacros(
         const macrodef: integer;
         const firstenvvarmacro: integer = -1; const lastenvvarmacro: integer = -1;
        prepend: macroinfoarty = nil): macroinfoarty;
var
 ar1,ar2: msestringarty;
 int1,int2,int3,int4: integer;
begin
 result:= prepend;
 checkindex(macrodef);
 if (firstenvvarmacro >= 0) and (lastenvvarmacro >= 0) then begin
  checkindex(firstenvvarmacro);
  checkindex(lastenvvarmacro);
  for int1:= ord(firstenvvarmacro) to ord(lastenvvarmacro) do begin
             //envvar macros can be overridden by --macrodef
   if defined[int1] then begin
    setlength(result,high(result) + 2);
    with result[high(result)] do begin
     name:= fenvvars[int1].name;
     value:= value[int1];
    end;
   end;
  end;
 end;
 ar1:= values[macrodef];
 for int1:= 0 to high(ar1) do begin
  ar2:= nil;
  splitstringquoted(ar1[int1],ar2,msechar('"'),msechar(','));
  if ar2 <> nil then begin
   int3:= length(result);
   int4:= (high(ar2)+2) div 2; //pair count
   setlength(result,int3+int4); 
   for int2:= 0 to int4-1 do begin
    with result[int2+int3] do begin
     int4:= int2 * 2;
     name:= ar2[int4];
     if int4 < high(ar2) then begin
      value:= ar2[int4+1]
     end;
    end;
   end;
  end;
 end;
end;

end.
