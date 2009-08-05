unit mserealsumedit;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesumlist,msedataedits,msewidgetgrid,msedatalist,msestrings,mseeditglob,
 msegrids;
 
type

 optionsumeditty = (ose_sumsonly);
 optionssumeditty = set of optionsumeditty;
 
 tgridrealsumlist = class(trealsumlist)
  private
   fowner: twidgetcol;
   foptionssum: optionssumeditty;
   procedure setoptionssum(const avalue: optionssumeditty);
  protected
   function getdefault: pointer; override;
   procedure setsourcename(const avalue: string); override;
  public
   constructor create(owner: twidgetcol); reintroduce;
  published
   property sourcename;
  published
   property optionssum: optionssumeditty read foptionssum write setoptionssum
                                                     default [];
 end;

 trealsumedit = class(trealedit)
  private
  protected
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatype: listdatatypety; override;
//   function internaldatatotext(const data): msestring; override;
//   procedure valuetogrid(const arow: integer); override;
   function getoptionsedit: optionseditty; override;
   function internaldatatotext(const data): msestring; override;
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

procedure tgridrealsumlist.setoptionssum(const avalue: optionssumeditty);
begin
 if foptionssum <> avalue then begin
  foptionssum:= avalue;
  fowner.changed;
 end;
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
 po1: prealsumty;
 datacol1: tdatacol;
 data1: tgridrealsumlist;
 int1: integer;
begin
 result:= inherited getoptionsedit;
 if fgridintf <> nil then begin
  po1:= fgridintf.getrowdatapo;
  if (po1 <> nil) and (po1^.level <> 0) then begin
   include(result,oe_readonly);
  end;
 end;
end;

function trealsumedit.internaldatatotext(const data): msestring;
var
 po1: prealsumty;
begin
 if (fdatalist <> nil) and 
        (ose_sumsonly in tgridrealsumlist(fdatalist).foptionssum) then begin
  po1:= @data;
  if (po1 = nil) then begin
   po1:= fgridintf.getrowdatapo;
  end;   
  if (po1 <> nil) and (po1^.level = 0) then begin
   result:= '';
   exit;
  end;
 end; 
 result:= inherited internaldatatotext(data);
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
