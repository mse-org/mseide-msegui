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
unit regsysutils;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 msedesignintf,msesysenv,msefilechange,regsysutils_bmp,mseprocess,
 msecomponenteditors,msepython,msestrings,msetexteditor,
 sysutils,mclasses,msesysenvmanagereditor,mseglob,msepropertyeditors;
type
 tarrayelementeditor1 = class(tarrayelementeditor);
 
 tsysenvmanagereditor = class(tcomponenteditor)
  public
   constructor create(const adesigner: idesigner;
                           acomponent: tcomponent); override;
   procedure edit; override;
 end;

 tprocessoptionseditor = class(tsetpropertyeditor)
  protected
   function getinvisibleitems: tintegerset; override;
 end;

 tpythonscriptseditor = class(tpersistentarraypropertyeditor)
  protected
   function itemgetvalue(const sender: tarrayelementeditor): msestring
                                                                  override;
 end;

 tpythonpropertyeditor = class(ttextstringspropertyeditor)
  private
//   factivebefore: boolean;
//   fdbactivebefore: boolean;
//   fintf: isqlpropertyeditor;
  protected
//   function nocheck: boolean; virtual;
   function getsyntaxindex: integer; override;
//   procedure doafterclosequery(var amodalresult: modalresultty); override;
//   function gettestbutton: boolean; override;
//   function getutf8: boolean; override;
   function getcaption: msestring; override;
   function ismsestring: boolean; override;
  public
//   procedure edit; override;
 end;
    
procedure Register;
begin
 registercomponents('NoGui',[tsysenvmanager,tfilechangenotifyer,tmseprocess,
                             tpythonscript]);
 registercomponenteditor(tsysenvmanager,tsysenvmanagereditor);
 registerpropertyeditor(typeinfo(processoptionsty),nil,'',
                                           tprocessoptionseditor);
 registerpropertyeditor(typeinfo(tpythonscripts),nil,'',
                                    tpythonscriptseditor);
 registerpropertyeditor(typeinfo(tpythonstringlist),nil,'',
                                             tpythonpropertyeditor);
end;

{ tsysenvmanagereditor }

constructor tsysenvmanagereditor.create(const adesigner: idesigner;
               acomponent: tcomponent);
begin
 inherited;
 fstate:= fstate + [cs_canedit];
end;

procedure tsysenvmanagereditor.edit;
begin
 if editsysenvmanager(tsysenvmanager(fcomponent)) = mr_ok then begin
  fdesigner.componentmodified(fcomponent);
 end;
end;

{ tprocessoptionseditor }

function tprocessoptionseditor.getinvisibleitems: tintegerset;
begin
 result:= [ord(pro_nopipeterminate)];
end;

{ tpythonscriptseditor }

function tpythonscriptseditor.itemgetvalue(
              const sender: tarrayelementeditor): msestring;
begin
 with tpythonstringlistitem(
              tarrayelementeditor1(sender).getpointervalue) do begin
  result:= '<'+name+'>';
 end;
end;

{ tpythonpropertyeditor }

const
 pythonsyntax = 
'caseinsensitive'+lineend+
'styles'+lineend+
' default '''''+lineend+
' words ''b'''+lineend+
' comment ''i'' cl_dkblue'+lineend+
' option ''b'' cl_dkblue'+lineend+
' string '''' cl_dkblue'+lineend+
' '+lineend+
'keyworddefs sql'+lineend+
' ''ACTION'' ''ACTIVE'' ''ADD'' ''ADMIN'' ''AFTER'' ''ALL'' ''ALTER'' ''AND'''+lineend+
' ''ANY'' ''AS'' ''ASC'''+lineend+
' ''ASCENDING'' ''AT'' ''AUTO'' ''AUTODDL'''+lineend+
' ''AVG'' ''BASED'' ''BASENAME'' ''BASE_NAME'' ''BEFORE'' ''BEGIN'' ''BETWEEN'''+lineend+
' ''BLOB'' '+lineend+
' ''BLOBEDIT'' ''BUFFER'' ''BY'' ''CACHE'''+lineend+
' ''CASCADE'' ''CASE'' ''CAST'' ''CHAR'' ''CHARACTER'' ''CHARACTER_LENGTH'''+lineend+
' ''CHAR_LENGTH'' ''CHECK'' '+lineend+
' ''CHECK_POINT_LEN'''+lineend+
' ''CHECK_POINT_LENGTH'' ''COLLATE'' ''COLLATION'' ''COLUMN'' ''COMMIT'''+lineend+
' ''COMMITTED'' '+lineend+
' ''COMPILETIME'''+lineend+
' ''COMPUTED'' ''CLOSE'' ''CONDITIONAL'' ''CONNECT'' ''CONSTRAINT'''+lineend+
' ''CONTAINING'' ''CONTINUE'' '+lineend+
' ''COUNT'' ''CREATE'''+lineend+
' ''CSTRING'' ''CURRENT'' ''CURRENT_DATE'' ''CURRENT_TIME'''+lineend+
' ''CURRENT_TIMESTAMP'' ''CURSOR'''+lineend+
' ''DATABASE'' ''DATE'' ''DAY'' ''DB_KEY'' ''DEBUG'' ''DEC'' ''DECIMAL'''+lineend+
' ''DECLARE'' ''DEFAULT'' '+lineend+
' ''DELETE'' ''DESC'' ''DESCENDING'''+lineend+
' ''DESCRIBE'' ''DESCRIPTOR'' ''DISCONNECT'' ''DISPLAY'' ''DISTINCT'' ''DO'''+lineend+
' ''DOMAIN'' '+lineend+
' ''DOUBLE'' ''DROP'''+lineend+
' ''ECHO'' ''EDIT'' ''ELSE'' ''END'' ''ENTRY_POINT'' ''ESCAPE'' ''EVENT'''+lineend+
' ''EXCEPTION'' ''EXECUTE'''+lineend+
' ''EXISTS'' ''EXIT'' ''EXTERN'' ''EXTERNAL'' ''EXTRACT'' ''FETCH'' ''FILE'''+lineend+
' ''FILTER'' ''FLOAT'' '+lineend+
' ''FOR'' ''FOREIGN'' ''FOUND'''+lineend+
' ''FREE_IT'' ''FROM'' ''FULL'' ''FUNCTION'' ''GDSCODE'' ''GENERATOR'''+lineend+
' ''GEN_ID'' ''GLOBAL'' '+lineend+
' ''GOTO'''+lineend+
' ''GRANT'' ''GROUP'' ''GROUP_COMMIT_WAIT'' ''GROUP_COMMIT_'' ''WAIT_TIME'''+lineend+
' ''HAVING'' ''HELP'' '+lineend+
' ''HOUR'' ''IF'''+lineend+
' ''IMMEDIATE'' ''IN'' ''INACTIVE'' ''INDEX'' ''INDICATOR'' ''INIT'' ''INNER'''+lineend+
' ''INPUT'' '+lineend+
' ''INPUT_TYPE'''+lineend+
' ''INSERT'' ''INT'' ''INTEGER'' ''INTO'' ''IS'' ''ISOLATION'' ''ISQL'''+lineend+
' ''JOIN'' ''KEY'' '+lineend+
' ''LC_MESSAGES'' ''LC_TYPE'' ''LEFT'''+lineend+
' ''LENGTH'' ''LEV'' ''LEVEL'' ''LIKE'' ''LIMIT'''+lineend+
' ''LOGFILE'' ''LOG_BUFFER_SIZE'''+lineend+
' ''LOG_BUF_SIZE'' '+lineend+
' ''LONG'' ''MANUAL'''+lineend+
' ''MAX'' ''MAXIMUM'' ''MAXIMUM_SEGMENT'' ''MAX_SEGMENT'' ''MERGE'''+lineend+
' ''MESSAGE'' ''MIN'' '+lineend+
' ''MINIMUM'' ''MINUTE'''+lineend+
' ''MODULE_NAME'' ''MONTH'' ''NAMES'' ''NATIONAL'' ''NATURAL'' ''NCHAR'''+lineend+
' ''NO'' ''NOAUTO'' '+lineend+
' ''NOT'''+lineend+
' ''NULL'' ''NUMERIC'' ''NUM_LOG_BUFS'' ''NUM_LOG_BUFFERS'' ''OCTET_LENGTH'''+lineend+
' ''OF'' ''ON'' '+lineend+
' ''ONLY'' ''OPEN'''+lineend+
' ''OPTION'' ''OR'' ''ORDER'' ''OUTER'' ''OUTPUT'' ''OUTPUT_TYPE'' ''OVERFLOW'''+lineend+
' ''PAGE'' '+lineend+
' ''PAGELENGTH'''+lineend+
' ''PAGES'' ''PAGE_SIZE'' ''PARAMETER'' ''PASSWORD'' ''PLAN'' ''POSITION'''+lineend+
' ''POST_EVENT'' '+lineend+
' ''PRECISION'' ''PREPARE'''+lineend+
' ''PROCEDURE'' ''PROTECTED'' ''PRIMARY'' ''PRIVILEGES'' ''PUBLIC'' ''QUIT'''+lineend+
' ''RAW_PARTITIONS'' ''RDB$DB_KEY'' ''READ'' ''REAL'' ''RECORD_VERSION'''+lineend+
' ''REFERENCES'''+lineend+
' ''RELEASE'' ''RESERV'' ''RESERVING'' ''RESTRICT'' ''RETAIN'' ''RETURN'''+lineend+
' ''RETURNING_VALUES'' ''RETURNS'' ''REVOKE'' ''RIGHT'' ''ROLE'' ''ROLLBACK'''+lineend+
' ''RUNTIME'' '+lineend+
' ''SCHEMA'' ''SECOND'''+lineend+
' ''SEGMENT'' ''SELECT'' ''SET'' ''SHADOW'' ''SHARED'' ''SHELL'' ''SHOW'''+lineend+
' ''SINGULAR'' ''SIZE'''+lineend+
' ''SMALLINT'' ''SNAPSHOT'' ''SOME'' ''SORT'' ''SQLCODE'' ''SQLERROR'''+lineend+
' ''SQLWARNING'' '+lineend+
' ''STABILITY'' ''STARTING'''+lineend+
' ''STARTS'' ''STATEMENT'' ''STATIC'' ''STATISTICS'' ''SUB_TYPE'' ''SUM'''+lineend+
' ''SUSPEND'' '+lineend+
' ''TABLE'' ''TERMINATOR'''+lineend+
' ''THEN'' ''TIME'' ''TIMESTAMP'' ''TO'' ''TRANSACTION'' ''TRANSLATE'''+lineend+
' ''TRANSLATION'' '+lineend+
' ''TRIGGER'' ''TRIM'''+lineend+
' ''TYPE'' ''UNCOMMITTED'' ''UNION'' ''UNIQUE'' ''UPDATE'' ''UPPER'' ''USER'''+lineend+
' ''USING'' '+lineend+
' ''VALUE'+lineend+
' ''VALUES'' ''VARCHAR'' ''VARIABLE'' ''VARYING'' ''VERSION'' ''VIEW'' ''WAIT'''+lineend+
' ''WEEKDAY'' '+lineend+
' ''WHEN'''+lineend+
' ''WHENEVER'' ''WHERE'' ''WHILE'' ''WITH'' ''WORK'' ''WRITE'' ''YEAR'''+lineend+
' ''YEARDAY'''+lineend+
''+lineend+
'scope comment1 comment'+lineend+
' endtokens'+lineend+
'  ''*/'''+lineend+
'  '+lineend+
'scope comment2 comment'+lineend+
' endtokens'+lineend+
'  '''''+lineend+
'  '+lineend+
'scope string string'+lineend+
' endtokens'+lineend+
'  '''''''' '''''+lineend+
'  '+lineend+
'scope main'+lineend+
''+lineend+
' keywords words'+lineend+
'  sql'+lineend+
' calltokens'+lineend+
'  ''/*'' comment1'+lineend+
'  ''--'' comment2'+lineend+
'  '''''''' string'+lineend;

var
 pythonindex: integer = -1;

function tpythonpropertyeditor.getsyntaxindex: integer;
begin
 if pythonindex < 0 then begin
  pythonindex:= msetexteditor.syntaxpainter.readdeffile(pythonsyntax);
 end;
 result:= pythonindex;
end;

function tpythonpropertyeditor.getcaption: msestring;
begin
 result:= 'Python Editor';
end;

function tpythonpropertyeditor.ismsestring: boolean;
begin
 result:= true;
end;

initialization
 register;
end.
