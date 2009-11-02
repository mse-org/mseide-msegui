unit mserealsumedit;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesumlist,msedataedits,msewidgetgrid,msedatalist,msestrings,mseeditglob,
 msegrids,msegui,msemenus,msetypes,mseevent,mseguiglob,mseedit;
 
type

 tgridrealsumlist = class(trealsumlist)
  private
   fowner: twidgetcol;
  protected
   procedure setoptions(const avalue: optionssumty); override;
   function getdefault: pointer; override;
   procedure setsourcevalue(const avalue: string); override;
   procedure setsourcelevel(const avalue: string); override;
   procedure setsourceissum(const avalue: string); override;
   procedure linksource(const source: tdatalist; const atag: integer); override;
  public
   constructor create(owner: twidgetcol); reintroduce;
  published
   property sourcevalue;
   property sourcelevel;
   property sourceissum;
 end;

 trealsumedit = class(trealedit)
  private
   function getsumlevel(index: integer): integer;
   procedure setsumlevel(index: integer; const avalue: integer);
  protected
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatype: listdatatypety; override;
//   function internaldatatotext(const data): msestring; override;
//   procedure valuetogrid(const arow: integer); override;
   function getoptionsedit: optionseditty; override;
   function internaldatatotext(const data): msestring; override;
  public
   function griddata: tgridrealsumlist;
   property gridsumlevel[index: integer]: integer read getsumlevel 
                              write setsumlevel;
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

procedure tgridrealsumlist.setsourcevalue(const avalue: string);
begin
 inherited;
 fowner.sourcenamechanged(0);
end;

procedure tgridrealsumlist.setsourcelevel(const avalue: string);
begin
 inherited;
 fowner.sourcenamechanged(sumleveltag);
end;

procedure tgridrealsumlist.setsourceissum(const avalue: string);
begin
 inherited;
 fowner.sourcenamechanged(2);
end;

procedure tgridrealsumlist.setoptions(const avalue: optionssumty);
var
 optionsbefore: optionssumty;
begin
 if foptions <> avalue then begin
  optionsbefore:= foptions;
  foptions:= avalue;
  if osu_foldsum in 
         optionssumty({$ifdef FPC}longword{$else}byte{$endif}(avalue) xor
         {$ifdef FPC}longword{$else}byte{$endif}(optionsbefore)) then begin
   fowner.sourcenamechanged(sumleveltag);
  end;
  change(-1);
 end;
end;

procedure tgridrealsumlist.linksource(const source: tdatalist;
               const atag: integer);
begin
 if {(source = nil) and} (atag = sumleveltag) and 
                                      (osu_foldsum in options) then begin
  inherited linksource(fowner.grid.datacols.rowstate,atag);  
 end
 else begin
  inherited;
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
  if (po1 <> nil) then begin
   if osu_foldsum in trealsumlist(fdatalist).options then begin
    if (po1^.issum) then begin
     include(result,oe_readonly);
    end;
   end
   else begin
    if (po1^.data.int <> 0) then begin
     include(result,oe_readonly);
    end;
   end;
  end;
 end;
end;

function trealsumedit.internaldatatotext(const data): msestring;
var
 po1: prealsumty;
begin
 if (fdatalist <> nil) and 
        (osu_sumsonly in tgridrealsumlist(fdatalist).options) then begin
  po1:= @data;
  if (po1 = nil) then begin
   po1:= fgridintf.getrowdatapo;
  end;   
  if (po1 <> nil) and (po1^.data.int = 0) then begin
   result:= '';
   exit;
  end;
 end; 
 result:= inherited internaldatatotext(data);
end;

function trealsumedit.getsumlevel(index: integer): integer;
var
 list: tdatalist;
begin
 list:= checkgrid(index);
 if list <> nil then begin
  result:= tgridrealsumlist(list).sumlevel[index];
 end
 else begin
  result:= 0;
 end;
end;

procedure trealsumedit.setsumlevel(index: integer; const avalue: integer);
var
 list: tdatalist;
begin
 list:= checkgrid(index);
 if list <> nil then begin
  tgridrealsumlist(list).sumlevel[index]:= avalue;
  fgridintf.datachange(index);
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
