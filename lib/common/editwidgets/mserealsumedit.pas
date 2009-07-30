unit mserealsumedit;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesumlist,msedataedits,msewidgetgrid,msedatalist,msestrings;
 
type

 tgridrealsumlist = class(trealsumlist)
  private
   fowner: twidgetcol;
  protected
   function getdefault: pointer; override;
  public
   constructor create(owner: twidgetcol); reintroduce;
 end;

 trealsumedit = class(trealedit)
  protected
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatyp: datatypty; override;
//   function internaldatatotext(const data): msestring; override;
//   procedure valuetogrid(const arow: integer); override;
  public
   function griddata: tgridrealsumlist;
 end;
 
implementation

{ tgridrealsumlist }

constructor tgridrealsumlist.create(owner: twidgetcol);
begin
 fowner:= owner;
 inherited create;
 finternaloptions:= finternaloptions + [ilo_nostreaming,ilo_propertystreaming];
end;

function tgridrealsumlist.getdefault: pointer;
begin
 result:= inherited getdefault;
end;

{ trealsumedit }

function trealsumedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridrealsumlist.create(sender);
end;

function trealsumedit.getdatatyp: datatypty;
begin
 result:= dl_realsum;
end;

function trealsumedit.griddata: tgridrealsumlist;
begin
 result:= tgridrealsumlist(inherited griddata);
end;
{
procedure trealsumedit.valuetogrid(const arow: integer);
begin
 griddata.setgriddata(arow,fvalue);
end;
}
{
function trealsumedit.internaldatatotext(const data): msestring;
begin
 if (@data = nil) or (realsumty(data).level = 0) then begin
  result:= inherited internaldatatotext(data);
 end
 else begin
  result:= inherited internaldatatotext(realsumty(data).sum);
 end;
end;
}
function createtgridrealsumlist(const aowner:twidgetcol): tdatalist;
begin
 result:= tgridrealsumlist.create(aowner);
end;

initialization
 registergriddatalistclass(tgridrealsumlist.classname,
                     {$ifdef FPC}@{$endif}createtgridrealsumlist);

end.
