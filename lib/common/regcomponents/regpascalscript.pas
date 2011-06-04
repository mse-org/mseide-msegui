{ MSEide Copyright (c) 1999-2010 by Martin Schreiber

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
unit regpascalscript;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface 
implementation
uses
 classes,msedesignintf,msepascalscript,msepascimport,
 msepropertyeditors,msetypes,msestrings,
 msetexteditor,mseglob,mseguiglob,msegui,msewidgets,uPSComponent,
 uPSComponent_Default,
 msepascimportmsegui,formdesigner,sourceupdate,mseparser,pascaldesignparser,
 msedesigner,mserichstring,mseclasses,msedesignparser;
type
 tpascaleditor = class(ttextstringspropertyeditor)
  protected
   function getscript: tpasc; virtual;
   function getsyntaxindex: integer; override;   
   procedure doafterclosequery(var amodalresult: modalresultty); override;
   function gettestbutton: boolean; override;
   function getcaption: msestring; override;
 end;
 
 tpascformeditor = class(tpascaleditor)
  private
   fmoduleprefix: ansistring;
  protected
   function getscript: tpasc; override;  
   procedure edit; override;
   procedure doafterclosequery(var amodalresult: modalresultty); override;
   procedure updateline(var aline: ansistring); override;
 end;

function sourcetoformscript(const amodule: tmsecomponent;
                      const asource: trichstringdatalist): boolean; forward;
const
 pascformintf: designmoduleintfty = 
  (createfunc: {$ifdef FPC}@{$endif}createpascform;
     initnewcomponent: nil; getscale: nil; sourcetoform: @sourcetoformscript);
 
procedure Register;
begin          
 registerclass(tpascform);
 registercomponents('PaSc',[tpasc,tpascdllplugin,tpascimport_classes,
                            tpascimport_dateutils,tpascimportmsegui]);
 registerpropertyeditor(typeinfo(tstrings),tpasc,'Script',tpascaleditor);
 registerpropertyeditor(typeinfo(tstrings),tpascform,'pasc_script',
                            tpascformeditor);
 registerdesignmoduleclass(tpascform,@pascformintf);
 registercomponenttabhints(['PaSc'],
         ['Experimental PascalScript Components']);
end;

procedure doupdateline(aline: pchar; const moduleprefix: ansistring);
var                       //todo: patch PascalScript to accept classname
 int1: integer;
 po1,po2,po3: pchar;
begin                  //remove module prefix
 if (moduleprefix <> '') and (aline <> nil) then begin
  po1:= pchar(aline);
  while po1^ <> #0 do begin
   po2:= pchar(moduleprefix);
   po3:= po1;
   while (upperchars[po1^] = po2^) and (po1^ <> #0) do begin
    inc(po1);
    inc(po2);
   end;
   if po2^ = #0 then begin //found
    for int1:= 0 to (po2 - pchar(moduleprefix)) - 1 do begin
     po3[int1]:= ' ';
    end;
   end
   else begin
    po1:= po3+1;   //next char
   end;
  end;
 end;
end;

function sourcetoformscript(const amodule: tmsecomponent;
                      const asource: trichstringdatalist): boolean;
var
 bo1: boolean;
 po1: punitinfoty;
 po2: pmoduleinfoty;
 mstr1: msestring;
 start,stop: sourceposty;
 prefix: ansistring;
 int1: integer;
begin
 bo1:= getimplementationtext(amodule,po1,start,stop,mstr1);
 if bo1 then begin
  po2:= designer.modules.findmodule(amodule);
  prefix:= struppercase(po2^.moduleclassname)+'.';
  with tpascform(amodule).script.script do begin
   text:= mstr1;
   for int1:= 0 to count - 1 do begin
    doupdateline(pchar(strings[int1]),prefix);
   end;
  end;
  designer.componentmodified(amodule);
 end;
 result:= true;
end;

var
 pascalindex: integer = -1;
const
 pascalsyntax =
'caseinsensitive'+lineend+
'styles'+lineend+
' default '''''+lineend+
' words ''b'''+lineend+
' comment ''i'' cl_dkblue'+lineend+
' option ''b'' cl_dkblue'+lineend+
' string '''' cl_dkblue'+lineend+

'keyworddefs pascal'+lineend+
' ''ABSOLUTE'' ''ABSTRACT'' ''AND'' ''ARRAY'' ''AS'' ''ASM'' ''ASSEMBLER'' ''BEGIN'''+lineend+
' ''BREAK'' ''CASE'' ''CDECL'' ''CLASS'' ''CONST'' ''CONSTRUCTOR'''+lineend+
' ''CONTINUE'' ''DEFAULT'' ''DESTRUCTOR'' ''DISPOSE'' ''DIV'' ''DO'' ''DOWNTO'''+lineend+
' ''ELSE'' ''END'' ''EXCEPT'' ''EXIT'' ''EXPORT'' ''EXPORTS'' ''EXTERNAL'' ''FAIL'''+lineend+
' ''FALSE'' ''FAR'' ''FILE'' ''FINALIZATION'' ''FINALLY'' ''FOR'' ''FORWARD'' ''FUNCTION'' ''GOTO'' ''IF'''+lineend+
' ''IMPLEMENTATION'' ''IN'' ''INDEX'' ''INHERITED'''+lineend+
' ''INITIALIZATION'' ''INLINE'' ''INTERFACE'' ''INTERRUPT'' ''IS'' ''LABEL'' ''LIBRARY'''+lineend+
' ''MOD'' ''NEW'' ''NIL'' ''NODEFAULT'' ''NOT'' ''OBJECT'''+lineend+
' ''OF'' ''ON'' ''OPERATOR'' ''OR'' ''OUT'' ''OTHERWISE'' ''PACKED'' ''POPSTACK'' ''PRIVATE'' '+lineend+
' ''PROCEDURE'' ''PROGRAM'' ''PROPERTY'' ''PROTECTED'''+lineend+
' ''PUBLIC'' ''PUBLISHED'' ''RAISE'' ''READ'' ''RECORD'' ''REINTRODUCE'' ''REPEAT'' '+lineend+
' ''RESOURCESTRING'''+lineend+
' ''SELF'' ''SET'' ''SHL'' ''SHR'''+lineend+
' ''STDCALL'' ''STORED'' ''THEN'' ''THREADVAR'' ''TO'' ''TRUE'' ''TRY'' ''TYPE'' ''UNIT'' ''UNTIL'''+lineend+
' ''USES'' ''VAR'' ''VIRTUAL'' ''WHILE'' ''WITH'' ''WRITE'' ''XOR'''+lineend+
' ''OVERLOAD'' ''OVERRIDE'''+lineend+

'scope option option'+lineend+
' endtokens'+lineend+
'  ''}'''+lineend+
  
'scope comment1 comment'+lineend+
' endtokens'+lineend+
'  ''}'''+lineend+

'scope comment2 comment'+lineend+
' endtokens'+lineend+
'  '''''+lineend+

'scope comment3 comment'+lineend+
' endtokens'+lineend+
'  ''*)'''+lineend+
  
'scope string string'+lineend+
' endtokens'+lineend+
'  '''''''' '''''+lineend+

'scope string1 string'+lineend+
' calltokens'+lineend+
'  '''''''' string'+lineend+
' endtokens'+lineend+
'  '' '' '''''+lineend+

'scope main'+lineend+

' keywords words'+lineend+
'  pascal'+lineend+

' calltokens'+lineend+
'  ''{$'' option'+lineend+
'  ''{'' comment1'+lineend+
'  ''//'' comment2'+lineend+
'  ''(*'' comment3'+lineend+
'  '''''''' string'+lineend+
'  ''#'' string1';


{ tpascaleditor }

function tpascaleditor.getscript: tpasc;
begin
 result:= tpasc(getordvalue(0));
end;

procedure tpascaleditor.doafterclosequery(var amodalresult: modalresultty);
begin
 if amodalresult = mr_canclose then begin
  with getscript do begin
   if compile then begin
//    showmessage('Compile OK');
   end
   else begin
    showmessage(compilermessagetext,'Compile Error');
    amodalresult:= mr_none;
   end;
  end;
 end;
end;

function tpascaleditor.gettestbutton: boolean;
begin
 result:= true;
end;

function tpascaleditor.getcaption: msestring;
begin
 result:= 'PascalScript Editor';
end;

function tpascaleditor.getsyntaxindex: integer;
begin
 if pascalindex < 0 then begin
  pascalindex:= msetexteditor.syntaxpainter.readdeffile(pascalsyntax);
 end;
 result:= pascalindex;
end;

{ tpascformeditor }

function tpascformeditor.getscript: tpasc;
begin
 result:= tpascform(component).script;
end;

procedure tpascformeditor.edit;
var
 bo1: boolean;
 po1: punitinfoty;
 po2: pmoduleinfoty;
 mstr1: msestring;
 start,stop: sourceposty;
begin
 bo1:= getimplementationtext(fmodule,po1,start,stop,mstr1);
 if bo1 then begin
  po2:= designer.modules.findmodule(fmodule);
  fmoduleprefix:= struppercase(po2^.moduleclassname)+'.';
  getscript.script.text:= mstr1;
 end
 else begin
  fmoduleprefix:= '';
 end;
 inherited;
 if bo1 and (fmodalresult = mr_ok) then begin
  sourceupdater.replacetext(po1,start,stop,
        concatstrings(forigtext,msestring(lineend))+lineend);
 end;
end;

procedure tpascformeditor.doafterclosequery(var amodalresult: modalresultty);
begin
 if amodalresult in [mr_canclose,mr_ok] then begin
 end;
 inherited; 
end;

procedure tpascformeditor.updateline(var aline: ansistring);
                       //todo: patch PascalScript to accept classname
begin
 doupdateline(pchar(aline),fmoduleprefix);
end;

initialization
 register;
end.
