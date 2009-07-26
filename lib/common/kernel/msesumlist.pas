unit msesumlist;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msedatalist,msetypes;
 
type
 sumlevelty = byte;
 
 realsumty = record
  data: realty; //first!
  prev,next: integer;
  sum: realty;
  level: sumlevelty;
 end;
 prealsumty = ^realsumty;
 
 trealsumlist = class(trealdatalist)
  private
   function getsumlevel(index: integer): sumlevelty;
   procedure setsumlevel(index: integer; const avalue: sumlevelty);
   function getsum(index: integer): realty;
  protected
   fdirty: integer;
   procedure clean(const aindex: integer); override;
   function datatyp: datatypty; override;
   procedure getgriddefaultdata(var dest); override;
   procedure getgriddata(index: integer; var dest); override;
   procedure setgriddata(index: integer; const source); override;
  public
   constructor create; override;
   procedure change(const index: integer); override;

   property sumlevel[index: integer]: sumlevelty read getsumlevel 
                            write setsumlevel;
   property sum[index: integer]: realty read getsum;
end; 
 
implementation
uses
 msereal;
 
{ trealsumlist }

constructor trealsumlist.create;
begin
 inherited;
 fsize:= sizeof(realsumty);
end;

function trealsumlist.datatyp: datatypty;
begin
 result:= dl_realsum;
end;

procedure trealsumlist.getgriddefaultdata(var dest);
begin
 realty(dest):= emptyreal;
end;

procedure trealsumlist.getgriddata(index: integer; var dest);
var
 po1: prealsumty;
begin
 checkindex(index);
 po1:= prealsumty(fdatapo+index*fsize);
 if po1^.level = 0 then begin
  realty(dest):= po1^.data;
 end
 else begin
  realty(dest):= po1^.sum;
 end;
end;

procedure trealsumlist.setgriddata(index: integer; const source);
var
 int1: integer;
begin
 int1:= index;
 checkindex(index);
 prealsumty(fdatapo+index*fsize)^.data:= realty(source);
 change(int1);
end;

function trealsumlist.getsumlevel(index: integer): sumlevelty;
begin
 checkindex(index);
 result:= prealsumty(fdatapo+index*fsize)^.level;
end;

procedure trealsumlist.setsumlevel(index: integer;
               const avalue: sumlevelty);
var
 int1: integer;
begin
 int1:= index;
 checkindex(index);
 if  prealsumty(fdatapo+index*fsize)^.level <> avalue then begin
  prealsumty(fdatapo+index*fsize)^.level:= avalue;
  change(-1); 
 end;
end;

function trealsumlist.getsum(index: integer): realty;
begin
 clean(index);
 checkindex(index);
 result:= prealsumty(fdatapo+index*fsize)^.sum;
end;

procedure trealsumlist.clean(const aindex: integer);
var
 po1: prealsumty;
 int1: integer;
 rea1: realty;
begin
 if aindex >= fdirty then begin
  po1:= datapo;
  inc(po1,fdirty-1);
  rea1:= emptyreal;
  for int1:= fdirty - 1 downto 0 do begin
   if po1^.level = 0 then begin
    rea1:= po1^.sum;
    break;
   end;
   inc(po1);
  end;
  for int1:= aindex - fdirty downto 0 do begin
   if po1^.level = 0 then begin
    rea1:= addrealty(rea1,po1^.data);
   end;
   po1^.sum:= rea1;
   inc(po1);
  end;
  fdirty:= aindex;
 end;
end;

procedure trealsumlist.change(const index: integer);
begin
 if index < fdirty then begin
  fdirty:= index;
  if fdirty < 0 then begin
   fdirty:= 0;
  end;
 end;
 inherited change(-1); //sum invalid
end;

initialization
 registerdatalistclass(dl_realsum,trealsumlist);
end.
