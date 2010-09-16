{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit regmath;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 classes,{$ifdef FPC}msefft,{$endif}msedesignintf,msesignal,msefilter,
 msepropertyeditors,msestrings,msedesigner;

type
 tinputconnpropertyeditor = class(tsubcomponentpropertyeditor)
  protected
   function getlinksource: tcomponent; override;
  public
   function getvalue: msestring; override;  
 end;
 
 tinputconnarraypropertyeditor = class(tpersistentarraypropertyeditor)
  protected
   function geteditorclass: propertyeditorclassty; override;
 end;
 
procedure register;
begin
{$ifdef FPC}
 registercomponents('Math',[tfft,tsigfir,tsigiir,tsigout,tsigin,
                            tsigadd,tsigmult,tsigcontroller]);
 registercomponenttabhints(['Math'],['Experimental Mathematical Components']);
 registerpropertyeditor(typeinfo(tdoubleconn),tdoublezcomp,'',
                                                   tsubcomponentpropertyeditor);
// registerpropertyeditor(typeinfo(tdoubleconn),tdoubleinpconnitem,'',
//                                                   tsubcomponentpropertyeditor);
 registerpropertyeditor(typeinfo(tdoubleinputconn),nil,'',
                                                   tinputconnpropertyeditor);
 registerpropertyeditor(typeinfo(tdoubleinpconnarrayprop),nil,'',
                                     tinputconnarraypropertyeditor);
{$endif}
end;

{ tinputconnpropertyeditor }

function tinputconnpropertyeditor.getvalue: msestring;
var
 inst: tdoubleinputconn;
begin
 inst:= tdoubleinputconn(getpointervalue);
 if inst.source = nil then begin
  result:= '<open>';
 end
 else begin
  result:= '<'+designer.getcomponentdispname(inst.source)+'>';
 end;
end;

function tinputconnpropertyeditor.getlinksource: tcomponent;
begin
 result:= tdoubleinputconn(getpointervalue).source;
end;

{ tinputconnarraypropertyeditor }

function tinputconnarraypropertyeditor.geteditorclass: propertyeditorclassty;
begin
 result:= tinputconnpropertyeditor;
end;

initialization
 register;
end.
