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
 
 toutputconnpropertyeditor = class(tcomponentpropertyeditor)
  protected
   function filtercomponent(const acomponent: tcomponent): boolean; override;
 end;
  
procedure register;
begin
{$ifdef FPC}
 registercomponents('Math',[tfft,tsigfir,tsigiir,tsigout,tsigin,
                            tsigadd,tsigdelay,tsigdelayn,tsigmult,tsigcontroller]);
 registercomponenttabhints(['Math'],['Experimental Mathematical Components']);
 registerpropertyeditor(typeinfo(tdoubleconn),tdoublezcomp,'',
                                                   tsubcomponentpropertyeditor);
// registerpropertyeditor(typeinfo(tdoubleconn),tdoubleinpconnitem,'',
//                                                   tsubcomponentpropertyeditor);
 registerpropertyeditor(typeinfo(tdoubleinputconn),nil,'',
                                                   tinputconnpropertyeditor);
 registerpropertyeditor(typeinfo(tdoubleoutputconn),tdoubleinputconn,'',
                                                   toutputconnpropertyeditor);
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
  result:= '<->';
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

{ toutputconnpropertyeditor }

function toutputconnpropertyeditor.filtercomponent(const acomponent: tcomponent): boolean;
var
 cont1: tsigcontroller;
begin
 cont1:= tdoubleinputconn(instance).controller;
 result:= (cont1 <> nil) and (tdoubleoutputconn(acomponent).controller = cont1);
end;

initialization
 register;
end.
