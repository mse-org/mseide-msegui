unit mserealsumedit;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesumlist,msedataedits,msewidgetgrid,msedatalist,msestrings,mseeditglob,
 msegrids;
 
type

 tgridrealsumlist = class(trealsumlist)
  private
   fowner: twidgetcol;
  protected
   function getdefault: pointer; override;
   procedure setsourcename(const avalue: string); override;
  public
   constructor create(owner: twidgetcol); reintroduce;
  published
   property sourcename;
 end;

 trealsumedit = class(trealedit)
  protected
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatype: listdatatypety; override;
//   function internaldatatotext(const data): msestring; override;
//   procedure valuetogrid(const arow: integer); override;
   function getoptionsedit: optionseditty; override;
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

procedure tgridrealsumlist.setsourcename(const avalue: string);
begin
 inherited;
 fowner.sourcenamechanged;
end;

{ trealsumedit }

function trealsumedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridrealsumlist.create(sender);
end;

function trealsumedit.getdatatype: listdatatypety;
begin
 result:= dl_realsum;
end;

function trealsumedit.griddata: tgridrealsumlist;
begin
 result:= tgridrealsumlist(inherited griddata);
end;

function trealsumedit.getoptionsedit: optionseditty;
var
 datacol1: tdatacol;
 data1: tgridrealsumlist;
 int1: integer;
begin
 result:= inherited getoptionsedit;
 if fgridintf <> nil then begin
  datacol1:= fgridintf.getcol;
  data1:= tgridrealsumlist(datacol1.datalist);
  if (data1 <> nil) then begin
   int1:= datacol1.grid.row;
   if (int1 >= 0) and (data1.sumlevel[int1] <> 0) then begin
    include(result,oe_readonly);
   end;
  end;
 end;
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
