unit regpascalscript;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface 
implementation
uses
 classes,msedesignintf,msepascalscript,msepropertyeditors,msetypes,msestrings,
 msetexteditor,msegui,msewidgets,uPSComponent,uPSComponent_Default,
 psimportmsegui;
type
 tpascaleditor = class(ttextstringspropertyeditor)
  protected
   function getsyntaxindex: integer; override;   
   procedure doafterclosequery(var amodalresult: modalresultty); override;
   function gettestbutton: boolean; override;
   function getcaption: msestring; override;
end;
 
procedure Register;
begin          
 registercomponents('PaSc',[tmsepsscript,tpsdllplugin,tpsimport_classes,
                            tpsimport_dateutils,tpsimportmsegui]);
 registerpropertyeditor(typeinfo(tstrings),tmsepsscript,'Script',tpascaleditor);
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

procedure tpascaleditor.doafterclosequery(var amodalresult: modalresultty);
var
 str1: ansistring;
 int1: integer;
begin
 if amodalresult = mr_canclose then begin
  with tmsepsscript(fprops[0].instance) do begin
   if compile then begin
//    showmessage('Compile OK');
   end
   else begin
    str1:= '';
    for int1:= 0 to compilermessagecount - 1 do begin
     str1:= str1 + compilermessages[int1].messagetostring+lineend;
    end;
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

initialization
 register;
end.
