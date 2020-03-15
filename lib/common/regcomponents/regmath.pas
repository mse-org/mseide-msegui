{ MSEide Copyright (c) 1999-2013 by Martin Schreiber

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
 msetypes,classes,mclasses,msefft,msedesignintf,msesignal,msefilter,
 mseformatstr,
 msepropertyeditors,msestrings,msedesigner,msesigfft,regmath_bmp,
 msesiggui,msesigfftgui,msesignoise,msesigmidi,msedatalist,
 mseiircoeffeditor,msefircoeffeditor,msegui,sysutils,mseglob;

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

 tiircoeffpropertyeditor = class(tdatalistpropertyeditor)
  public
   procedure edit; override;
 end;

 tfircoeffpropertyeditor = class(tdatalistpropertyeditor)
  public
   procedure edit; override;
 end;

procedure register;
begin
 registercomponents('Math',[tsigcontroller,tsigout,tsigin,
                            tsigconnector,ttrigconnector,
                            tsigadd,tsigmult,
                            tsigdelay,tsigdelayn,tsigdelayvar,tsigfir,tsigiir,
                            tsigfilter,tsigfilterbank,
                            tsigwavetable,tsignoise,tsigfuncttable,tsigenvelope,
                            tsigsampler,tsigscope,tsigscopefft,
                            tsigfft,tfft,tsigsamplerfft,
                            tsigrealedit,tsigslider,tsigkeyboard,
                            tsigmidiconnector,tsigmidimulticonnector,
                            twavetableedit,tfuncttableedit,tffttableedit,tenvelopeedit
                            ]);
 registercomponenttabhints(['Math'],
 ['Experimental mathematical and signal processing components.']);
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
 registerpropertyeditor(typeinfo(tcomplexdatalist),tsigiir,'coeff',
                                     tiircoeffpropertyeditor);
 registerpropertyeditor(typeinfo(trealdatalist),tsigfir,'coeff',
                                     tfircoeffpropertyeditor);
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
  result:= msestring('<'+designer.getcomponentdispname(inst.source)+'>');
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

{ tiircoeffpropertyeditor }

procedure tiircoeffpropertyeditor.edit;
var
 inst: tsigiir;
 int1,int2,int3: integer;
begin
 with tiircoeffeditorfo.create(nil) do begin
  inst:= tsigiir(component);
  numed.gridvalues:= inst.origcoeff.asarrayim;
  dened.gridvalues:= inst.origcoeff.asarrayre;
  numdi.gridvalues:= inst.coeff.asarrayim;
  dendi.gridvalues:= inst.coeff.asarrayre;
  int3:= 0;
  with grid.fixcols[-1] do begin
   captions.count:= grid.rowcount;
   for int1:= 0 to inst.sections.count - 1 do begin
    if int1 <> 0 then begin
     grid.rowlinewidth[int3-1]:= 3;
    end;
    for int2:= 0 to inst.sections[int1] - 1 do begin
     captions[int3]:= 's'+inttostrmse(int1)+':'+inttostrmse(-int2);
     inc(int3);
    end;
   end;
  end;
  if show(ml_application) = mr_ok then begin
   inst.coeff.asarrayre:= dendi.gridvalues;
   inst.coeff.asarrayim:= numdi.gridvalues;
   inst.origcoeff.asarrayre:= dened.gridvalues;
   inst.origcoeff.asarrayim:= numed.gridvalues;
   self.modified();
  end;
  free;
 end;
end;

{ tfircoeffpropertyeditor }

procedure tfircoeffpropertyeditor.edit;
var
 inst: tsigfir;
 int1,int2,int3: integer;
begin
 with tfircoeffeditorfo.create(nil) do begin
  inst:= tsigfir(component);
  coeffed.gridvalues:= inst.coeff.asarray;
  int3:= 0;
  with grid.fixcols[-1] do begin
   captions.count:= grid.rowcount;
   for int1:= 0 to inst.sections.count - 1 do begin
    if int1 <> 0 then begin
     grid.rowlinewidth[int3-1]:= 3;
    end;
    for int2:= 0 to inst.sections[int1] - 1 do begin
     captions[int3]:= 's'+inttostrmse(int1)+':'+inttostrmse(-int2);
     inc(int3);
    end;
   end;
  end;
  if show(ml_application) = mr_ok then begin
   inst.coeff.asarray:= coeffed.gridvalues;
   self.modified();
  end;
  free;
 end;
end;

initialization
 register;
end.
