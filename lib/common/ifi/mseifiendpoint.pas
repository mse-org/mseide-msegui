{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseifiendpoint;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestrings,mclasses,mseclasses,mseificompglob,mseificomp,typinfo,msedatalist,
 msetypes;
 
type
 tifidataendpoint = class(tmsecomponent,iifidatalink)
  private
   fonchange: notifyeventty;
  protected
   fifilink: tifilinkcomp;
   procedure change;
    //iifidatalink
   function getifilinkkind: ptypeinfo;
   procedure setifilink(const avalue: tifilinkcomp);
   function ifigriddata: tdatalist;
   procedure updateifigriddata(const sender: tobject; const alist: tdatalist);
   function getgriddata: tdatalist;
   function getvalueprop: ppropinfo;
   procedure updatereadonlystate;
  published
   property onchange: notifyeventty read fonchange write fonchange;
 end;

 tifiintegerendpoint = class(tifidataendpoint)
  private
   fvalue: integer;
   fondatachange: updateintegereventty;
   function getifilink: tifiintegerlinkcomp;
   procedure setifilink(const avalue: tifiintegerlinkcomp);
   procedure setvalue(const avalue: integer);
  published
   property ifilink: tifiintegerlinkcomp read getifilink write setifilink;
   property value: integer read fvalue write setvalue default 0;
   property ondatachange: updateintegereventty read fondatachange
                                                      write fondatachange;
 end;
 
 tifiint64endpoint = class(tifidataendpoint)
  private
   fvalue: int64;
   fondatachange: updateint64eventty;
   function getifilink: tifiint64linkcomp;
   procedure setifilink(const avalue: tifiint64linkcomp);
   procedure setvalue(const avalue: int64);
  published
   property ifilink: tifiint64linkcomp read getifilink write setifilink;
   property value: int64 read fvalue write setvalue default 0;
   property ondatachange: updateint64eventty read fondatachange
                                                      write fondatachange;
 end;
 
 tifibooleanendpoint = class(tifidataendpoint)
  private
   fvalue: boolean;
   fondatachange: updatebooleaneventty;
   function getifilink: tifibooleanlinkcomp;
   procedure setifilink(const avalue: tifibooleanlinkcomp);
   procedure setvalue(const avalue: boolean);
  published
   property ifilink: tifibooleanlinkcomp read getifilink write setifilink;
   property value: boolean read fvalue write setvalue default false;
   property ondatachange: updatebooleaneventty read fondatachange
                                                      write fondatachange;
 end;

 tifirealendpoint = class(tifidataendpoint)
  private
   fvalue: real;
   fondatachange: updaterealeventty;
   function getifilink: tifireallinkcomp;
   procedure setifilink(const avalue: tifireallinkcomp);
   procedure setvalue(const avalue: real);
  public
   constructor create(aowner: tcomponent); override;
  published
   property ifilink: tifireallinkcomp read getifilink write setifilink;
   property value: real read fvalue write setvalue;
   property ondatachange: updaterealeventty read fondatachange
                                                      write fondatachange;
 end;
 
 tifidatetimeendpoint = class(tifidataendpoint)
  private
   fvalue: tdatetime;
   fondatachange: updatedatetimeeventty;
   function getifilink: tifidatetimelinkcomp;
   procedure setifilink(const avalue: tifidatetimelinkcomp);
   procedure setvalue(const avalue: tdatetime);
  public
   constructor create(aowner: tcomponent); override;
  published
   property ifilink: tifidatetimelinkcomp read getifilink write setifilink;
   property value: tdatetime read fvalue write setvalue;
   property ondatachange: updatedatetimeeventty read fondatachange
                                                      write fondatachange;
 end;

 tifistringendpoint = class(tifidataendpoint)
  private
   fvalue: msestring;
   fondatachange: updatestringeventty;
   function getifilink: tifistringlinkcomp;
   procedure setifilink(const avalue: tifistringlinkcomp);
   procedure setvalue(const avalue: msestring);
  public
  published
   property ifilink: tifistringlinkcomp read getifilink write setifilink;
   property value: msestring read fvalue write setvalue;
   property ondatachange: updatestringeventty read fondatachange
                                                      write fondatachange;
 end;

 tifiactionendpoint = class(tmsecomponent,iifiexeclink)
  private
   fonexecute: notifyeventty;
   procedure setifilink(const avalue: tifiactionlinkcomp);
    //iifilink
   function getifilinkkind: ptypeinfo;
  protected
   fifilink: tifiactionlinkcomp;
  public
    //iifiexeclink
   procedure execute;
  published
   property ifilink: tifiactionlinkcomp read fifilink write setifilink;
   property onexecute: notifyeventty read fonexecute write fonexecute;
 end;

implementation

{ tifidataendpoint }

function tifidataendpoint.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidatalink);
end;

procedure tifidataendpoint.setifilink(const avalue: tifilinkcomp);
begin
 mseificomp.setifilinkcomp(iifidatalink(self),avalue,fifilink);
end;

function tifidataendpoint.ifigriddata: tdatalist;
begin
 result:= nil;
end;

procedure tifidataendpoint.updateifigriddata(const sender: tobject; 
                                                const alist: tdatalist);
begin
 //dummy
end;

function tifidataendpoint.getgriddata: tdatalist;
begin
 result:= nil;
end;

function tifidataendpoint.getvalueprop: ppropinfo;
begin
 result:= nil;
end;

procedure tifidataendpoint.updatereadonlystate;
begin
 //dummy
end;

procedure tifidataendpoint.change;
begin
 if canevent(tmethod(fonchange)) then begin
  fonchange(self);
 end;
 if fifiserverintf <> nil then begin
  fifiserverintf.valuechanged(iifidatalink(self));
 end;
end;

{ tifiintegerendpoint }

function tifiintegerendpoint.getifilink: tifiintegerlinkcomp;
begin
 result:= tifiintegerlinkcomp(fifilink);
end;

procedure tifiintegerendpoint.setifilink(const avalue: tifiintegerlinkcomp);
begin
 inherited setifilink(avalue);
end;

procedure tifiintegerendpoint.setvalue(const avalue: integer);
begin
 fvalue:= avalue;
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,fvalue);
 end;
 change;
end;

{ tifiint64endpoint }

function tifiint64endpoint.getifilink: tifiint64linkcomp;
begin
 result:= tifiint64linkcomp(fifilink);
end;

procedure tifiint64endpoint.setifilink(const avalue: tifiint64linkcomp);
begin
 inherited setifilink(avalue);
end;

procedure tifiint64endpoint.setvalue(const avalue: int64);
begin
 fvalue:= avalue;
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,fvalue);
 end;
 change;
end;

{ tifibooleanendpoint }

function tifibooleanendpoint.getifilink: tifibooleanlinkcomp;
begin
 result:= tifibooleanlinkcomp(fifilink);
end;

procedure tifibooleanendpoint.setifilink(const avalue: tifibooleanlinkcomp);
begin
 inherited setifilink(avalue);
end;

procedure tifibooleanendpoint.setvalue(const avalue: boolean);
begin
 fvalue:= avalue;
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,fvalue);
 end;
 change;
end;

{ tifirealendpoint }

constructor tifirealendpoint.create(aowner: tcomponent);
begin
 fvalue:= emptyreal;
 inherited;
end;

function tifirealendpoint.getifilink: tifireallinkcomp;
begin
 result:= tifireallinkcomp(fifilink);
end;

procedure tifirealendpoint.setifilink(const avalue: tifireallinkcomp);
begin
 inherited setifilink(avalue);
end;

procedure tifirealendpoint.setvalue(const avalue: real);
begin
 fvalue:= avalue;
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,fvalue);
 end;
 change;
end;

{ tifidatetimeendpoint }

constructor tifidatetimeendpoint.create(aowner: tcomponent);
begin
 fvalue:= emptydatetime;
 inherited;
end;

function tifidatetimeendpoint.getifilink: tifidatetimelinkcomp;
begin
 result:= tifidatetimelinkcomp(fifilink);
end;

procedure tifidatetimeendpoint.setifilink(const avalue: tifidatetimelinkcomp);
begin
 inherited setifilink(avalue);
end;

procedure tifidatetimeendpoint.setvalue(const avalue: tdatetime);
begin
 fvalue:= avalue;
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,fvalue);
 end;
 change;
end;

{ tifistringendpoint }

function tifistringendpoint.getifilink: tifistringlinkcomp;
begin
 result:= tifistringlinkcomp(fifilink);
end;

procedure tifistringendpoint.setifilink(const avalue: tifistringlinkcomp);
begin
 inherited setifilink(avalue);
end;

procedure tifistringendpoint.setvalue(const avalue: msestring);
begin
 fvalue:= avalue;
 if canevent(tmethod(fondatachange)) then begin
  fondatachange(self,fvalue);
 end;
 change;
end;

{ tifiactionendpoint }

procedure tifiactionendpoint.setifilink(const avalue: tifiactionlinkcomp);
begin
 mseificomp.setifilinkcomp(iifiexeclink(self),avalue,tifilinkcomp(fifilink));
end;

procedure tifiactionendpoint.execute;
begin
 if canevent(tmethod(fonexecute)) then begin
  fonexecute(self);
 end;
 if fifiserverintf <> nil then begin
  fifiserverintf.execute(iifiexeclink(self));
 end;
end;

function tifiactionendpoint.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidatalink);
end;

end.
