{ MSEide Copyright (c) 1999-2016 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit pascaldesignparser;

{$ifdef FPC}{$mode objfpc}{$h+}{$GOTO ON}{$endif}

interface
uses
 classes,mseparser,typinfo,msetypes,mselist,msestrings,mseclasses,
 msedesignparser;

type

  tpascaldesignparser = class(tpascalparser,idesignparser)
   private
    funitinfopo: punitinfoty;
    fimplementation: boolean;
    finterface: boolean;
    finterfaceonly: boolean;
   protected
    function skipexpression: boolean;
    procedure parsetype;
    procedure parselabel;
    procedure parseconst;
    procedure parsevar;
    function parseclasstype: boolean;
    function parseinterfacetype: boolean;
    function parserecord: boolean;
    function parseobject: boolean;
    function parseprocparams(const akind: tmethodkind;
                var aflags: methodflagsty; var params: paraminfoarty;
                                const acceptnameonly: boolean): boolean;
    function parseclassprocedureheader(atoken: pascalidentty;
                  classinfopo: pclassinfoty; const managed: boolean): boolean;
    function skipprocedureparams(atoken: pascalidentty): boolean;
    function skipprocedureheader(atoken: pascalidentty): boolean;
    procedure parseprocedurebody;
    procedure parseimplementation;
   public
    constructor create(unitinfopo: punitinfoty;
               const afilelist: tmseindexednamelist;
               const getincludefile: getincludefileeventty;
                const ainterfaceonly: boolean); overload;
    constructor create(const afilelist: tmseindexednamelist; 
                 const atext: string); overload;
    procedure parse; override;
    function dogetincludefile(const afilename: filenamety;
                     const astatementstart,astatementend: sourceposty): tscanner; override;
    function parseprocedureheader(atoken: pascalidentty;
                   procedureinfopo: pprocedureinfoty): boolean;
  end;

function findclassinfobyinstance(const ainstance: tmsecomponent; 
                                 const infopo: punitinfoty): pclassinfoty;
function isemptysourcepos(const apos: sourceposty): boolean;
function isinrowrange(const apos,startpos,endpos: sourceposty): boolean;
procedure parsepascaldef(const adef: pdefinfoty; out atext: string; out scope: tdeflist);

implementation
uses
 sysutils,msedatalist,msefileutils,msedesigner,sourceupdate,msestream;
type
 tdeflist1 = class(tdeflist);
 tusesinfolist1 = class(tusesinfolist);
 
procedure parsepascaldef(const adef: pdefinfoty; out atext: string; out scope: tdeflist);
var
 parser: tpascalparser;

 procedure doaddidents;
 begin
  with parser do begin
   while checkoperator('^') do begin
   end;
   if checkident(ord(pid_array)) then begin
    if checkoperator('[') then begin
     findoperator(']');
    end;
    checkident(ord(pid_of));
    while checkoperator('^') do begin
    end;
   end;
   scope.addidentpath(parser,'.');
  end;
 end;

 procedure parsecase;
 var
  ident1: pascalidentty;
  int1: integer;
 begin
  with parser do begin
   if not checkname then begin
    exit;
   end;
   if checkoperator(':') then begin
    if not checkname then begin
     exit;
    end;
   end;
   if pascalidentty(getident) <> pid_of then begin
    exit;
   end;
   repeat
    if not findoperator(':') then begin
     exit;
    end;
    if not checkoperator('(') then begin
     exit;
    end;
    while not checkoperator(')') and not eof do begin
     if not getnameorident(int1) then begin
      exit;
     end;
     ident1:= pascalidentty(int1);
     if ident1 = pid_case then begin
      parsecase;
     end
     else begin
      skipnamelist;
      if not checkoperator(':') then begin
       exit;
      end;
      doaddidents;
     end;
     checkoperator(';');
    end;
    checkoperator(';');
   until eof or testident(ord(pid_end));
  end;
 end;
 
 procedure parsetypedef;
 var
  ident1: pascalidentty;
  int1: integer;
 begin
  with parser do begin
   while checkoperator('^') do begin
   end;
   ident1:= pascalidentty(getident);
   case ident1 of
    pid_case: begin
     parsecase;
    end;
    pid_record: begin
     repeat
      if not getnameorident(int1) then begin
       nexttoken;
       break;
      end;
      ident1:= pascalidentty(int1);
      if ident1 = pid_case then begin
       parsecase;
      end
      else begin
       skipnamelist;
       if checkoperator(':') then begin
        parsetypedef;
       end
       else begin
        nexttoken;
        break;
       end;
      end;
     until eof or checkident(ord(pid_end));
    end;
    else begin
     lasttoken;
     doaddidents;
    end;
   end;
   checkoperator(';');
  end;
 end;

var
 bo1: boolean;
begin
 scope:= tdeflist.create(adef^.kind,false);
 atext:= sourceupdater.getdefinfotext(adef);
 if atext <> '' then begin
  parser:= tpascalparser.create(designer.designfiles,atext);
  try
   with parser do begin
    if adef^.kind in [syk_procdef,syk_classprocimp,syk_procimp] then begin
     nextnonwhitetoken; //procedure or function
     if adef^.kind = syk_classprocimp then begin
      nextnonwhitetoken; //classname
      nextnonwhitetoken; //dot
     end;
     nextnonwhitetoken;  //procname
     if checkoperator('(') then begin
      repeat
       while not eof and not checkoperator(':') do begin
        nexttoken;
       end;
       doaddidents;
       while not eof and not checkoperator(';') do begin
        if checkoperator(')') then begin
         break;
        end;
        nexttoken;
       end;
      until eof;
     end;
     if checkoperator(':') then begin
      doaddidents;
     end;       
    end
    else begin
//     ident1:= getident;
     if skipnamenoident then begin
      case adef^.kind of
       syk_typedef: begin
        if checkoperator('=') then begin
         parsetypedef;
        end;
       end;
       syk_vardef,syk_pardef: begin
        bo1:= true;
        while bo1 and checkoperator(',') do begin
         bo1:= checknamenoident;
        end;
        if bo1 and checkoperator(':') then begin
         doaddidents;
        end;
       end;
       syk_classdef: begin
        if checkoperator('=') and 
               (checkident([ord(pid_class),ord(pid_object)])  >= 0) and 
                                               checkoperator('(') then begin
         scope.addidents(parser,',','.');
//         doaddidents;
        end;
       end;
       syk_interfacedef: begin
        if checkoperator('=') and checkident(ord(pid_interface))
                                   and checkoperator('(') then begin
         scope.addidents(parser,#0,'.');
        end;
       end;
      end;
     end;
    end;
   end;
  finally
   parser.Free;
  end;
 end;
end;

function isemptysourcepos(const apos: sourceposty): boolean;
begin
 with apos do begin
  result:= (filenum = 0) {and (pos.col = 0) and (pos.row = 0)};
 end;
end;

function isinrowrange(const apos,startpos,endpos: sourceposty): boolean;
begin
// result:= (apos.filenum = startpos.filenum) and (apos.filenum = endpos.filenum) and
//          (apos.pos.row >= startpos.line) and (apos.pos.row <= endpos.line);
 result:= (apos.line >= startpos.line) and (apos.line <= endpos.line);
end;

function findclassinfobyinstance(const ainstance: tmsecomponent; const infopo: punitinfoty): pclassinfoty;
var
 po1: pmoduleinfoty;
begin
 result:= nil;
 if infopo <> nil then begin
  po1:= designer.modules.findmodule(ainstance);
  if po1 <> nil then begin
   result:= infopo^.p.classinfolist.finditembyname(po1^.moduleclassname,true);
  end;
 end;
end;

{ tpascaldesignparser }

constructor tpascaldesignparser.create(unitinfopo: punitinfoty;
            const afilelist: tmseindexednamelist;
            const getincludefile: getincludefileeventty;
            const ainterfaceonly: boolean);
begin
 finterfaceonly:= ainterfaceonly;
 inherited create(afilelist);
 funitinfopo:= unitinfopo;
 funitinfopo^.interfacecompiled:= false;
 funitinfopo^.implementationcompiled:= false;
 ongetincludefile:= getincludefile;
end;

constructor tpascaldesignparser.create(const afilelist: tmseindexednamelist; 
                 const atext: string);
begin
 fnoautoparse:= true;
 inherited create(afilelist,atext);
end;

function tpascaldesignparser.skipexpression: boolean;
var
 bracketlevel: integer;
 ch1: char;
 str1: string;
begin
 result:= true;
 bracketlevel:= 0;
 repeat
  ch1:= getoperator;
  case ch1 of
   '(','[': inc(bracketlevel);
   ')',']': dec(bracketlevel);
   '*','/','+','-','^',',': begin
   end;
   else begin
    if ch1 <> #0 then begin
     lasttoken; //' for pascalstring
    end;
    if getvaluestring(str1) = vk_none then begin
     if ch1 <> #0 then begin
      break; //error
     end
     else begin
      nexttoken; //was ident
     end;
    end;
   end;
  end;
 until eof or (bracketlevel < 0);
 if bracketlevel < 0 then begin
  lasttoken;
 end;
end;

function tpascaldesignparser.parseprocparams(const akind: tmethodkind;
                            var aflags: methodflagsty;
                            var params: paraminfoarty;
                            const acceptnameonly: boolean): boolean;
var
 ar1: stringarty;
 paraflags: tparamflags;
 defaultstr: string;
 apos,epos: sourceposty;

 procedure putparams(const atypename: string);
 var
  int1,int2: integer;
 begin
  int2:= length(params);
  setlength(params,int2+length(ar1));
  for int1:= 0 to high(ar1) do begin
   with params[int2] do begin
    name:= ar1[int1];
    flags:= paraflags;
    typename:= atypename;
    defaultvalue:= defaultstr;
    start:= apos;
    stop:= epos;
   end;
   inc(int2);
  end;
 end;

var
 str1: string;
 int1: integer;
 po1: pchar;

begin
 ar1:= nil; //compiler warning
 params:= nil;
 result:= false;
 if checkoperator(';') then begin
  if not (akind in [mkfunction,mkclassfunction]) or acceptnameonly then begin
   result:= true;   //no params
  end;
 end
 else begin
  if checkoperator('(') then begin
   include(aflags,mef_brackets);
   while not eof do begin
    defaultstr:= '';
    int1:= getident;
    case pascalidentty(int1) of
     pid_const: paraflags:= [pfconst];
     pid_var: paraflags:= [pfvar];
     pid_out: paraflags:= [pfout];
     else paraflags:= [];
    end;
    if (paraflags = []) and (int1 >= 0) then begin
     break;
    end;
    apos:= sourcepos;
    ar1:= lstringartostringar(getorignamelist);
    if not checkoperator(':') then begin
     epos:= sourcepos;
     putparams(''); //untyped
    end
    else begin
     if checkident(ord(pid_array)) then begin
      include(paraflags,pfarray);
      checkident(ord(pid_of));
      if checkident(ord(pid_const)) then begin
       str1:= 'TVarRec';
      end
      else begin
       str1:= getorigname;
      end;
     end
     else begin
      str1:= getorigname;
     end;
     if str1 = '' then begin
      break;
     end;
     if checkoperator('=') then begin
      skipwhitespace;
      po1:= fto^.value.po;
      skipexpression;
      defaultstr:= getorigtext(po1);
     end;
     epos:= sourcepos;
     putparams(str1);
    end;
    if checkoperator(')') then begin
     result:= true;
     break;
    end;
    if not checkoperator(';') then begin
     break;
    end;
   end;
  end
  else begin
   apos:= sourcepos;
   result:= true;
  end;
  if result then begin
   if (akind in [mkfunction,mkclassfunction]) then begin
    if checkoperator(':') then begin
     setlength(params,length(params)+1);
     with params[high(params)] do begin
      typename:= getorigname;
      start:= apos;
      stop:= sourcepos;
     end;
    end
    else begin
     result:= acceptnameonly;
    end;
   end;
  end;
  if result then begin
   checkoperator(';');
   mark();
   if checkident(ord(pid_inline)) then begin
    pop();
    checkoperator(';');
   end
   else begin
    back(); //after semicolon
   end;
  end;
 end;
end;

function tpascaldesignparser.parseprocedureheader(atoken: pascalidentty;
                   procedureinfopo: pprocedureinfoty): boolean;
begin
// result:= false;
 with procedureinfopo^ do begin
  intinsertpos:= lasttokenpos;
  skipwhitespace;
  intstartpos:= sourcepos;
  case atoken of
   pid_function: params.kind:= mkfunction;
   pid_constructor: params.kind:= mkconstructor;
   pid_destructor: params.kind:= mkdestructor;
   else params.kind:= mkprocedure;
  end;
  name:= getorigname;
  result:= not checkoperator('.'); //interface proc definition?
  if result then begin
   uppername:= uppercase(name);
   result:= parseprocparams(params.kind,params.flags,params.params,false);
   if result then begin
    intendpos:= sourcepos;
   end;
  end;
 end;
end;

function tpascaldesignparser.parseclassprocedureheader(atoken: pascalidentty;
                   classinfopo: pclassinfoty; const managed: boolean): boolean;
var
 po1: pprocedureinfoty;
 token1: tokenidty;
 pos1,pos2: sourceposty;
 bo1: boolean;
 int1: integer;
begin
 result:= false;
 bo1:= atoken = pid_class;
 if bo1 then begin
  if getident(int1) then begin
   atoken:= pascalidentty(int1);
   if  not ((atoken = pid_function) or (atoken = pid_procedure)) then begin
    lasttoken;
    exit;
   end;
  end
  else begin
   exit;
  end;
 end;
 with classinfopo^ do begin
  po1:= procedurelist.newitem;
  token1:= acttoken;
  po1^.managed:= managed;
  po1^.classproc:= bo1;
  result:= parseprocedureheader(atoken,po1);
  pos2:= sourcepos;
  if result then begin
   while true do begin
    case pascalidentty(getclassident) of
     pid_abstract: include(po1^.params.flags,mef_abstract);
     pid_inherited: include(po1^.params.flags,mef_inherited);
     pid_overload: include(po1^.params.flags,mef_overload);
     pid_override: include(po1^.params.flags,mef_override);
     pid_virtual: include(po1^.params.flags,mef_virtual);
     pid_inline: begin end; //include(po1^.params.flags,mef_inline);
     pid_invalid: break;
    else
     lasttoken;
     break;
    end;
    if not checkoperator(';') then begin
     break;
    end;
   end;
   if isemptysourcepos(procedurestart) then begin
    procedurestart:= po1^.intinsertpos;
   end;
   pos1:= getsourcepos(token1);
   dec(pos1.offset,pos1.pos.col);
   pos1.pos.col:= 0;
   funitinfopo^.deflist.add(pos1,pos2,po1);
  end
  else begin
   procedurelist.deletelast;
  end;
 end;
end;

function tpascaldesignparser.skipprocedureparams(atoken: pascalidentty): boolean;
var
 ar1: paraminfoarty;
 flags1: methodflagsty;
begin
 case atoken of
  pid_procedure: begin
   result:= parseprocparams(mkprocedure,flags1,ar1,false);
  end;
  pid_function: begin
   result:= parseprocparams(mkfunction,flags1,ar1,false);
  end
  else begin
   result:= false;
  end;
 end;
end;

function tpascaldesignparser.skipprocedureheader(atoken: pascalidentty): boolean;
var
 lstr1: lstringty;
begin
 if getnamenoident(lstr1) then begin
  result:= skipprocedureparams(atoken);
 end
 else begin
  result:= false;
 end;
end;

function tpascaldesignparser.parseinterfacetype: boolean;
var
 value: lstringty;
 ident1: pascalidentty;
 intfinfopo: pinterfaceinfoty;
begin
 result:= getorignamenoident(value) and checkoperator('=') and
      checkident(integer(pid_interface));
 if result then begin
  while not eof do begin
   ident1:= pascalidentty(getident);
   case ident1 of
    pid_end: begin
     intfinfopo:= funitinfopo^.p.interfacelist.newitem;
     with intfinfopo^ do begin
      name:= lstringtostring(value);
      uppername:= uppercase(name);
     end;
     break;
    end;
    pid_implementation: begin
     break;
    end;
    pid_procedure,pid_function: begin
     skipprocedureheader(ident1);
    end;
    else begin
     nexttoken;
    end;
   end;
  end;
 end;
end;

function tpascaldesignparser.parseclasstype: boolean;
var
 value: lstringty;
 ar1: lstringarty;
 classinfopo: pclassinfoty;
 pos1: sourceposty;
 ident1: pascalidentty;
 lstr2: lstringty;
 pc,pc1: pcompinfoty;
 pd: pdefinfoty;
 bo1: boolean;
 token1: tokenidty;
 first: boolean;
 int1: integer;

begin
 ar1:= nil; //compiler warning
 token1:= acttoken;
 result:= getorignamenoident(value) and checkoperator('=') and 
                  (checkident([integer(pid_class),integer(pid_object)]) >= 0);
 if result then begin
  if checkoperator(';') then begin
   lasttoken;           //forward declaration
  end
  else begin
   if checkident(integer(pid_of)) then begin
    result:= checkname and checkoperator(';');
    if result then begin
     funitinfopo^.deflist.add(lstringtostring(value),syk_typedef,
                  getsourcepos(token1),sourcepos);
    end;
    exit;
   end;
   classinfopo:= funitinfopo^.p.classinfolist.newitem;
   with classinfopo^ do begin
    inimplementation:= fimplementation;
    managedstart:= lasttokenpos;
    name:= lstringtostring(value);
    uppername:= uppercase(name);
    if checkoperator('(') then begin
     ar1:= getnamelist;
     result:= checkoperator(')');
    end
    else begin
     ar1:= nil;
    end;
    headerstop:= getsourcepos(acttoken);
    if ar1 <> nil then begin
     parentname:= lstringtostring(ar1[0]);
    end
    else begin
     parentname:= 'TObject';
    end;
    if result then begin
     deflist:= funitinfopo^.deflist.beginnode(getsourcepos(token1),classinfopo);
     first:= true;
     while not eof do begin
      ident1:= getclassident;
      case ident1 of
       pid_end,pid_private,pid_protected,pid_public,pid_published,pid_automated,
           pid_implementation: begin
        if isemptysourcepos(managedend) then begin
         managedend:= lasttokenpos;
        end;
        if isemptysourcepos(procedurestart) then begin
         procedurestart:= managedend;
        end;
        if (ident1 = pid_private) then begin
         if isemptysourcepos(privatestart) then begin
          privatestart:= sourcepos;
         end;
        end
        else begin
         if not isemptysourcepos(privatestart) and 
                            isemptysourcepos(privateend) then begin
          privateend:= lasttokenpos;
          if isemptysourcepos(privatefieldend) then begin
           privatefieldend:= privateend;
          end;
         end;
        end;
        if ident1 = pid_end then begin
         break;
        end;
       end;
       pid_class,pid_procedure,pid_function,pid_constructor,pid_destructor: begin
        if isemptysourcepos(privatefieldend) and 
                     not isemptysourcepos(privatestart) and 
                     isemptysourcepos(privateend) then begin
         privatefieldend:= lasttokenpos;
        end;
        parseclassprocedureheader(ident1,classinfopo,
                                        isemptysourcepos(managedend));
       end;
       else begin
        pos1:= sourcepos;
        ar1:= getorignamelist;
        if high(ar1) >= 0 then begin
         if isemptysourcepos(managedend) and (ident1 <> pid_property) then begin
          pc:= componentlist.newitem; //managed component
          bo1:= false;
          with pc^ do begin
           insertpos:= lasttokenpos;
           namepos:= pos1;
           nameend:= sourcepos;
           if checkoperator(':') then begin
            skipwhitespace;
            typepos:= sourcepos;
            if getorigname(lstr2) then begin
             typeend:= sourcepos;
             name:= lstringtostring(ar1[0]);
             uppername:= uppercase(name);
             typename:= lstringtostring(lstr2);
             uppertypename:= uppercase(typename);
             checkoperator(';');
             checknewline;
             endpos:= sourcepos;
             bo1:= true;
             funitinfopo^.deflist.add(name,syk_vardef,namepos,endpos);
            end;
           end;
          end;
          if not bo1 then begin
           componentlist.deletelast;
           nexttoken;
          end
          else begin
           for int1:= 1 to high(ar1) do begin
            pc1:= componentlist.newitem; //managed component
            pc1^:= pc^;
            pc1^.name:= lstringtostring(ar1[int1]);
            pc1^.uppername:= uppercase(pc1^.name);
           end;
          end;         
         end
         else begin
          if ident1 = pid_property then begin
           if checkoperator('[') then begin
            while not eof and not checkoperator(']') do begin
             nexttoken;
            end;
           end;
          end;
          if checkoperator(':') then begin
           while not eof and not checkoperator(';') do begin
            nexttoken;
           end;
           pd:= funitinfopo^.deflist.add(lstringtostring(ar1[0]),
                      syk_vardef,pos1,sourcepos);
           if ident1 = pid_property then begin
            pd^.varflags:= [vf_property];
           end;
           for int1:= 1 to high(ar1) do begin
            funitinfopo^.deflist.add(lstringtostring(ar1[int1]),
                      syk_vardef,pos1,sourcepos)            
           end;
          end;
         end;
        end
        else begin
         if first and (getoperator = ';') then begin
          break; //xxx = class(tclassxx);
         end;
         nexttoken;
        end;
       end;
      end;
      first:= false;
     end;
     if result then begin
      funitinfopo^.deflist.endnode(sourcepos);
     end
     else begin
      funitinfopo^.deflist.deletenode;
     end;
    end;
   end;
   if not result then begin
    funitinfopo^.p.classinfolist.deletelast;
   end;
  end;
 end;
end;

function tpascaldesignparser.parserecord: boolean;
                //todo: parse subitems
var
 ident1: pascalidentty;
 blocklevel: integer;
begin
 result:= true;
 blocklevel:= 1;
 while not eof and (blocklevel > 0) do begin
  ident1:= pascalidentty(getident);
  case ident1 of
   pid_end: begin
    dec(blocklevel)
   end;
   pid_begin,pid_record: begin
    inc(blocklevel)
   end;
  end;
  nexttoken;
 end;
end;

function tpascaldesignparser.parseobject: boolean;
                //todo: parse subitems
var
 ident1: pascalidentty;
 blocklevel: integer;
begin
 result:= true;
 blocklevel:= 1;
 while not eof and (blocklevel > 0) do begin
  ident1:= pascalidentty(getident);
  case ident1 of
   pid_end: begin
    dec(blocklevel);
    nexttoken;
   end;
   pid_begin,pid_record: begin
    inc(blocklevel);
    nexttoken;
   end;
   pid_procedure,pid_function: begin
    skipprocedureheader(ident1);
   end;
   else begin
    nexttoken;
   end;
  end;
 end;
end;

procedure tpascaldesignparser.parselabel;
var
 ident1: pascalidentty;
begin
 while not eof do begin
  skipwhitespace;
  ident1:= pascalidentty(getident);
  case ident1 of
   pid_type,pid_const,pid_var,pid_implementation,pid_function,pid_procedure,
                    pid_constructor,pid_destructor,pid_begin: begin
    lasttoken;
    break;
   end;
   pid_label: begin
   end;
   else begin
    nexttoken;
   end;
  end;
 end;
end;

procedure tpascaldesignparser.parsetype;
var
 statementstart: tokenidty;
 ident1: pascalidentty;
 lstr1: lstringty;
// bo1: boolean;
begin
 while not eof do begin
  skipwhitespace;
  statementstart:= acttoken;
  ident1:= pascalidentty(getident);
  case ident1 of
   pid_label,pid_const,pid_var,pid_implementation,pid_function,pid_procedure,
                    pid_constructor,pid_destructor,pid_begin: begin
    lasttoken;
    break;
   end;
   pid_type: begin
   end;
   else begin
    if (ident1 = pid_invalid) and getorigname(lstr1) and
                                            checkoperator('=') then begin
     ident1:= pascalidentty(getident);
     case ident1 of
      pid_interface: begin
       mark;
       acttoken:= statementstart;
       if parseinterfacetype then begin
        pop;
        funitinfopo^.deflist.add(lstringtostring(lstr1),syk_interfacedef,
                   getsourcepos(statementstart),sourcepos);
       end
       else begin
        back;
       end;
      end;
      pid_class,pid_object: begin
       mark;
       acttoken:= statementstart;
       if parseclasstype then begin
        pop;
       end
       else begin
        back;
       end;
      end;
      {
      pid_object: begin
       parseobject;
       funitinfopo^.deflist.add(lstringtostring(lstr1),syk_typedef,
                  getsourcepos(statementstart),sourcepos);
      end;
      }
      pid_record: begin
       parserecord;
       funitinfopo^.deflist.add(lstringtostring(lstr1),syk_typedef,
                  getsourcepos(statementstart),sourcepos);
      end;
      pid_procedure,pid_function: begin
       if skipprocedureparams(ident1) then begin
        if checkident(ord(pid_of)) then begin
         checkident(ord(pid_object));
        end;
        checkoperator(';');
        funitinfopo^.deflist.add(lstringtostring(lstr1),syk_typedef,
                   getsourcepos(statementstart),sourcepos);
       end;
      end;
      else begin
       while not eof and not checkoperator(';') do begin
        nexttoken;
       end;
       funitinfopo^.deflist.add(lstringtostring(lstr1),syk_typedef,
                  getsourcepos(statementstart),sourcepos);
      end;
     end;
    end
    else begin
     nexttoken; //invalid
    end;
   end;
  end;
 end;
end;

procedure tpascaldesignparser.parseconst;
var
 ident1: integer;
 apos: sourceposty;
 str1: string;

begin
 while not eof do begin
  ident1:= getident;
  if ident1 >= 0 then begin
   lasttoken;
   break;
  end;
  if (fto^.kind = tk_name) then begin
   apos:= sourcepos;
   str1:= self.getorigtoken;
   if checkoperator('=') then begin
            //todo: parse typed constants
    while not eof and not checkoperator(';') do begin
     nexttoken;
    end;
    funitinfopo^.deflist.add(str1,syk_constdef,apos,sourcepos);
   end
   else begin
    while not eof and not checkoperator(';') do begin
     nexttoken;
    end;
   end;
  end
  else begin
   nexttoken;
  end;
 end;
end;

procedure tpascaldesignparser.parsevar;
var
 ident1: integer;
 apos: sourceposty;
 ar1: lstringarty;
 int1: integer;

begin
 ar1:= nil; //compiler warning
 while not eof do begin
  ident1:= getident;
  if (ident1 >= 0) and (ident1 <> ord(pid_threadvar)) then begin
   lasttoken;
   break;
  end;
  if fto^.kind = tk_name then begin
   apos:= sourcepos;
   ar1:= getorignamelist;
   if checkoperator(':') then begin
    while not eof and not checkoperator(';') do begin
     nexttoken;
    end;
    for int1:= 0 to high(ar1) do begin
     funitinfopo^.deflist.add(lstringtostring(ar1[int1]),syk_vardef,
                                     apos,sourcepos);
    end;
   end
   else begin
    while not eof and not checkoperator(';') do begin
     nexttoken;
    end;
   end;
  end
  else begin
   nexttoken;
  end;
 end;
end;

procedure tpascaldesignparser.parseprocedurebody;

 procedure getidentinfo;
 var
  bracketlevel: integer;
  pos1: sourceposty;
 begin
  funitinfopo^.deflist.actnode.startident(self);
  while checkoperator('.') do begin
   skipwhitespace;
   if fto^.kind = tk_name then begin
    funitinfopo^.deflist.actnode.addident(self);
   end
   else begin
    funitinfopo^.deflist.actnode.addemptyident(self);
   end; 
  end;
  if checkoperator('(') then begin
   mark;
   bracketlevel:= 0;
   while not eof and (bracketlevel >= 0) do begin
    if checkoperator('(') then begin
     inc(bracketlevel);
    end
    else begin
     if checkoperator(')') then begin
      dec(bracketlevel);
     end
     else begin
      nexttoken;
     end;
    end;
   end;
   pos1:= sourcepos;
   back;
   funitinfopo^.deflist.actnode.endident(self,pos1);
  end
  else begin
   skipwhitespace;
   funitinfopo^.deflist.actnode.endident(self);
  end;
 end;

var
 blocklevel: integer;
 aident: integer;
 str1: string;

begin
 blocklevel:= 0;
 while not eof and (blocklevel >= 0) do begin
  if getident(aident) then begin
   case pascalidentty(aident) of
    pid_begin,pid_try,pid_case: begin
     inc(blocklevel);
    end;
    pid_end: begin
     dec(blocklevel);
    end;
   end;
  end
  else begin
   if (fto^.kind = tk_name) then begin
    getidentinfo;
   end
   else begin
    if (fto^.kind = tk_operator) and (fto^.op = '''') and
             getpascalstring(str1) then begin

    end
    else begin
     nexttoken;
    end;
   end;
  end;
 end;
end;

procedure tpascaldesignparser.parseimplementation;

var
 procnestinglevel: integer;
 
 procedure parseprocedure(const akind: tmethodkind);
 var
  classname,procname: lstringty;
  pos1: sourceposty;
  po1: pclassinfoty;
  po2: pprocedureinfoty;
  po3: pdefinfoty;
  methodinfo: methodparaminfoty;
  aident: integer;
  deflist1: tdeflist1;
  
   procedure setprocinfo(const ainfo: pprocedureinfoty);
   var
    lstr1: lstringty;
   begin
    with ainfo^ do begin
     params:= methodinfo;
     lstr1:= procname;
     inc(lstr1.po,origoffset);
     name:= lstringtostring(lstr1);
     uppername:= lstringtostring(procname);
    end;
   end;
 var
  i1: int32;
 begin
  if procnestinglevel < 32 then begin
   classname.po:= nil;
   classname.len:= 0;
   inc(procnestinglevel);
   lasttoken;
   pos1:= sourcepos;
   nexttoken;
   if getname(procname) then begin
    if checkoperator('.') then begin
     classname:= procname;
     getname(procname);
     po1:= funitinfopo^.p.classinfolist.finditembyname(classname,false);
     if (po1 <> nil) and isemptysourcepos(po1^.procimpstart) then begin
      po1^.procimpstart:= pos1;
     end;
    end
    else begin
     po1:= nil;
    end;
    methodinfo.kind:= akind;
    if parseprocparams(akind,methodinfo.flags,
                            methodinfo.params,classname.po <> nil) then begin
     if po1 <> nil then begin //class or object
      po2:= po1^.procedurelist.finditembyuppername(procname,methodinfo,true);
                                    //can update methodinfo
      if po2 = nil then begin
       po2:= po1^.procedurelist.newitem;
       setprocinfo(po2);
      end;
      po3:= funitinfopo^.deflist.beginnode(
                lstringtostring(classname)+'.'+lstringtostring(procname)+
                     mangleprocparams(methodinfo),
                            syk_classprocimp,pos1,sourcepos);
      deflist1:= tdeflist1(po3^.deflist);
//      if po2 <> nil then begin
//       po2^.impheaderstartpos:= pos1;
//       po2^.impheaderendpos:= sourcepos;
//      end;
      deflist1.fparentscope:= po1^.deflist;
     end
     else begin
      po2:= funitinfopo^.p.procedurelist.finditembyuppername(
                                              procname,methodinfo,false);
      if po2 = nil then begin
       po2:= funitinfopo^.p.procedurelist.newitem;
       setprocinfo(po2)
      end;
      po3:= funitinfopo^.deflist.beginnode(
                lstringtostring(procname)+mangleprocparams(methodinfo),
                syk_procimp,pos1,sourcepos);
      deflist1:= tdeflist1(po3^.deflist);
      po3^.procindex:= po2^.b.index;
      po2:= nil;
     end;
     if po2 <> nil then begin
      po3^.procindex:= po2^.b.index;
      po2^.impheaderstartpos:= pos1;
      po2^.impheaderendpos:= sourcepos;
     end;
     for i1:= 0 to high(methodinfo.params) do begin
      with methodinfo.params[i1] do begin
       funitinfopo^.deflist.add(name,syk_pardef,start,stop);
      end;
     end;

     while not eof do begin
      if getident(aident) then begin
       case pascalidentty(aident) of
        pid_var: begin
         parsevar;
        end;
        pid_const: begin
         parseconst;
        end;
        pid_type: begin
         parsetype;
        end;
        pid_label: begin
         parselabel;
        end;
        pid_procedure: begin
         parseprocedure(mkprocedure);
        end;
        pid_function: begin
         parseprocedure(mkfunction);
        end;
        pid_begin: begin
         parseprocedurebody;
         break;
        end;
        else begin
         break;
        end;
       end;
      end
      else begin
       nexttoken;
      end;
     end;
     checkoperator(';');
     checknewline;
     pos1:= sourcepos;
     funitinfopo^.deflist.endnode(pos1);
     if po1 <> nil then begin
      po1^.procimpend:= pos1;
      if po2 <> nil then begin
       po2^.impendpos:= po1^.procimpend;
      end;
     end;
    end;
   end;
   dec(procnestinglevel);
  end;
 end;

  procedure checkend;
  begin
   if isemptysourcepos(funitinfopo^.p.implementationend) then begin
    lasttoken;
    funitinfopo^.p.implementationend:= sourcepos;
    nexttoken;
   end;
  end;

var
 aident: integer;
 
begin
 finterface:= false;
 fimplementation:= true;
 funitinfopo^.p.implementationstart:= sourcepos;
 funitinfopo^.p.implementationbodystart:= funitinfopo^.p.implementationstart;
 procnestinglevel:= 0;
 while not eof do begin
  if getident(aident) then begin;
   case pascalidentty(aident) of
    pid_procedure: begin
     parseprocedure(mkprocedure);
    end;
    pid_function: begin
     parseprocedure(mkfunction);
    end;
    pid_constructor: begin
     parseprocedure(mkconstructor);
    end;
    pid_destructor: begin
     parseprocedure(mkdestructor);
    end;
    pid_type: begin
     parsetype;
    end;
    pid_var: begin
     parsevar;
    end;
    pid_uses: begin
     with tusesinfolist1(funitinfopo^.p.implementationuses) do begin
      fstartpos:= sourcepos;
      add(getorignamelist);
      fendpos:= sourcepos;
     end;
     checkoperator(';');     
     checknewline;
     funitinfopo^.p.implementationbodystart:= sourcepos;
    end;
    pid_begin: begin
     if funitinfopo^.isprogram then begin
      parseprocedurebody;
     end;
    end;
    pid_initialization: begin
     checkend;
     funitinfopo^.p.initializationstart:= nexttokenornewlinepos;
    end;
    pid_finalization: begin
     checkend;
     funitinfopo^.p.finalizationstart:= nexttokenornewlinepos;
    end;
    pid_end: begin
     if checkoperator('.') then begin
      lasttoken;
      checkend;
      nexttoken;
      break;
     end;
    end;
   end;
  end
  else begin
   nexttoken;
  end;
 end;
 funitinfopo^.unitend:= sourcepos;
 if isemptysourcepos(funitinfopo^.p.implementationend) then begin
  lasttoken;
  funitinfopo^.p.implementationend:= sourcepos;
 end;
end;

procedure tpascaldesignparser.parse;
var
 int1: integer;
 po1: pprocedureinfoty;
 pos1: sourceposty;
begin
 inherited parse;
 if fnoautoparse then begin
  exit;
 end;
 initcompinfo(funitinfopo^);
 with funitinfopo^ do begin
  int1:= getident;
  isprogram:= pascalidentty(int1) = pid_program;
  if isprogram or (pascalidentty(int1) = pid_unit) then begin
   origunitname:= getorigname;
   unitname:= uppercase(origunitname);
  end;
  if isprogram then begin
   parseimplementation;
  end
  else begin
   while not eof do begin
    skipwhitespace;
    pos1:= sourcepos;
    int1:= getident;
    case pascalidentty(int1) of
     pid_type: begin
      parsetype;
     end;
     pid_const: begin
      parseconst;
     end;
     pid_var: begin
      parsevar;
     end;
     pid_procedure,pid_function: begin
      po1:= p.procedurelist.newitem;
      if parseprocedureheader(pascalidentty(int1),po1) then begin
       deflist.add(pos1,sourcepos,po1);
      end
      else begin
       p.procedurelist.deletelast;
      end;
     end;
     pid_interface: begin
      finterface:= true;
     end;
     pid_uses: begin
      with tusesinfolist1(funitinfopo^.p.interfaceuses) do begin
       fstartpos:= sourcepos;
       add(getorignamelist);
       fendpos:= sourcepos;
      end;
     end;
     pid_implementation: begin
      if not finterfaceonly then begin
       parseimplementation;
      end;
      break;
     end;
     else begin
      nexttoken;
     end;
    end;
   end;
  end;
  afterparse(self,funitinfopo^,isprogram or not finterfaceonly);
 end;
end;

function tpascaldesignparser.dogetincludefile(const afilename: filenamety;
                   const astatementstart, astatementend: sourceposty): tscanner;
begin
 result:= inherited dogetincludefile(afilename,astatementstart,astatementend);
 if result <> nil then begin
  addincludefile(funitinfopo^,afilename,astatementstart,astatementend);
 end;
end;

end.
