{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msecomponenteditors;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 Classes,msedesignintf,mseglob,mseguiglob,mseclasses,mselist,msetypes;

type

 componentinfoty = record
  name: string;
  instance: tcomponent;
 end;
 pcomponentinfoty = ^componentinfoty;

 tcomponenteditor = class(tnullinterfacedobject,icomponenteditor)
  protected
   fcomponent: tcomponent;
   fstate: componenteditorstatesty;
   fdesigner: idesigner;
  public
   constructor create(const adesigner: idesigner; acomponent: tcomponent); virtual;
   function state: componenteditorstatesty;
   procedure edit; virtual;
   property component: tcomponent read fcomponent;
 end;

 componenteditorclassty = class of tcomponenteditor;

 timagelisteditor = class(tcomponenteditor)
  public
   constructor create(const adesigner: idesigner;
                           acomponent: tcomponent); override;
   procedure edit; override;
 end;

 componenteditorinfoty = record
  componentclass: componentclassty;
  componenteditorclass: componenteditorclassty;
 end;
 pcomponenteditorinfoty = ^componenteditorinfoty;

 tcomponenteditors = class(trecordlist)
  protected
   procedure add(componentclass: componentclassty; componenteditorclass: componenteditorclassty);
  public
   constructor create;
   function geteditorclass(const component: componentclassty): componenteditorclassty;
 end;

function componenteditors: tcomponenteditors;
procedure registercomponenteditor(componentclass: componentclassty;
                  componenteditorclass: componenteditorclassty);

implementation
uses
 msegui,mseimagelisteditor,msebitmap,SysUtils;

var
 acomponenteditors: tcomponenteditors;

function componenteditors: tcomponenteditors;
begin
 if acomponenteditors = nil then begin
  acomponenteditors:= tcomponenteditors.create;
 end;
 result:= acomponenteditors;
end;

procedure registercomponenteditor(componentclass: componentclassty;
                  componenteditorclass: componenteditorclassty);
begin
 componenteditors.add(componentclass,componenteditorclass)
end;


{ tcomponenteditors }

procedure tcomponenteditors.add(componentclass: componentclassty;
  componenteditorclass: componenteditorclassty);
var
 info: componenteditorinfoty;
begin
 fillchar(info,sizeof(info),0);
 info.componentclass:= componentclass;
 info.componenteditorclass:= componenteditorclass;
 inherited add(info);
end;

constructor tcomponenteditors.create;
begin
 inherited create(sizeof(componentinfoty));
end;

function tcomponenteditors.geteditorclass(
  const component: componentclassty): componenteditorclassty;
var
 level: integer;
 int1: integer;
 int2: integer;
 po1: pcomponenteditorinfoty;
 class1: tclass;
begin
 result:= nil;
 level:= bigint;
 po1:= pcomponenteditorinfoty(fdata);
 for int1:= 0 to count - 1 do begin
  with po1^ do begin
   class1:= component;
   int2:= 0;
   while (class1 <> componentclass) and (class1 <> nil) do begin
    inc(int2);
    class1:= class1.ClassParent;
   end;
   if (class1 <> nil) and (int2 < level) then begin
    level:= int2;
    result:= componenteditorclass;
   end;
  end;
  inc(po1);
 end;
end;

{ tcomponenteditor }

constructor tcomponenteditor.create(const adesigner: idesigner; acomponent: tcomponent);
begin
 fdesigner:= adesigner;
 fcomponent:= acomponent;
end;

function tcomponenteditor.state: componenteditorstatesty;
begin
 result:= fstate;
end;

procedure tcomponenteditor.edit;
begin
 //dummy
end;

{ timagelisteditor }

constructor timagelisteditor.create(const adesigner: idesigner;
                                                    acomponent: tcomponent);
begin
 inherited;
 fstate:= fstate + [cs_canedit];
end;

procedure timagelisteditor.edit;
begin
 if editimagelist(timagelist(fcomponent)) = mr_ok then begin
  fdesigner.componentmodified(fcomponent);
 end;
end;

initialization
 acomponenteditors:= tcomponenteditors.Create;
finalization
 freeandnil(acomponenteditors);
end.
