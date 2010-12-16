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
unit regmath;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 classes,msefft,msedesignintf,msesignal,msefilter,
 msepropertyeditors,msestrings,msedesigner,msesigfft,regmath_bmp,
 msesiggui,msesigfftgui,msesignoise;

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
 registercomponents('Math',[tsigcontroller,tsigout,tsigin,tsigconnector,
                            tsigadd,tsigmult,
                            tsigdelay,tsigdelayn,tsigfir,tsigiir,tsigfilter,
                            tsigwavetable,tsignoise,tsigfuncttable,tsigenvelope,
                            tsigsampler,tsigscope,tsigscopefft,
                            tsigfft,tfft,tsigsamplerfft,
                            tsigslider,tsigkeyboard,
                            twavetableedit,tfuncttableedit,tffttableedit,tenvelopeedit
                            ]);
 registercomponenttabhints(['Math'],['Experimental mathematical and signal processing components']);
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

function toutputconnpropertyeditor.filtercomponent(
                                  const acomponent: tcomponent): boolean;
var
 cont1: tsigcontroller;
begin
 cont1:= tdoubleinputconn(instance).controller;
 result:= (cont1 <> nil) and (tdoubleoutputconn(acomponent).controller = cont1);
end;

initialization
 register;
end.
