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
 msecomponenteditors,msepython,msestrings,msetexteditor,mseguiprocess,
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
 registercomponents('Gui',[tguiprocess]);
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
'styles'+lineend+
' default '''''+lineend+
' words ''b'''+lineend+
' comment ''i'' cl_dkblue'+lineend+
' option ''b'' cl_dkblue'+lineend+
' string '''' cl_dkblue'+lineend+
' '+lineend+
'keyworddefs python'+lineend+
' ''False'' ''class'' ''finally'' ''is'' ''return'''+lineend+
' ''None'' ''continue'' ''for'' ''lambda'' ''try'''+lineend+
' ''True'' ''def'' ''from'' ''nonlocal'' ''while'''+lineend+
' ''and'' ''del'' ''global'' ''not'' ''with'''+lineend+
' ''as'' ''elif'' ''if'' ''or'' ''yield'''+lineend+
' ''assert'' ''else'' ''import'' ''pass'''+lineend+
' ''break'' ''except'' ''in'' ''raise'''+lineend+
''+lineend+
'scope comment1 comment'+lineend+
' endtokens'+lineend+
'  '''''+lineend+
'scope string1 string'+lineend+
' endtokens'+lineend+
'  '''''''' '''''+lineend+
'scope string2 string'+lineend+
' endtokens'+lineend+
'  ''"'' '''''+lineend+
'scope string3 string'+lineend+
' endtokens'+lineend+
'  '''''''''''''''''+lineend+
'scope string4 string'+lineend+
' endtokens'+lineend+
'  ''"""'''+lineend+
'  '+lineend+
'scope main'+lineend+
''+lineend+
' keywords words'+lineend+
'  python'+lineend+
' calltokens'+lineend+
'  ''#'' comment1'+lineend+
'  '''''''''''''''' string3'+lineend+
'  '''''''' string1'+lineend+
'  ''"""'' string4'+lineend+
'  ''"'' string2'+lineend+
'';

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
