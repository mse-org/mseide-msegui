unit msesumlist;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msedatalist,msetypes,msearrayprops,mseclasses;
 
type
 sumlevelty = integer;
 
 realsumty = record
  data: realty; //first!
  level: sumlevelty;
  sumup: realty;
  sumdown: realty;
 end;
 prealsumty = ^realsumty;

 tsumprop = class(tindexpersistent)
  protected
   fsumup: realty;
   fsumdown: realty;
   findexup: integer;
   findexdown: integer;
   procedure clearup;
   procedure cleardown;
  published
 end;
 psumprop = ^tsumprop;
 
 tsumarrayprop = class(tindexpersistentarrayprop)
  protected
   procedure clearup;
   procedure cleardown;
   function newsumup(const alevel: integer; const asum: realty;
                                     const aindex: integer): realty;
   function newsumdown(const alevel: integer; const asum: realty;
                                     const aindex: integer): realty;
   function needsclear(const aindex: integer): boolean;
  public
   constructor create(const aowner: tdatalist);
 end;
  
 trealsumlist = class(trealdatalist)
  private
   fsums: tsumarrayprop;
   fdefaultval: realsumty;
   function getsumlevel(index: integer): sumlevelty;
   procedure setsumlevel(index: integer; const avalue: sumlevelty);
//   function getsum(index: integer): realty;
   procedure setsums(const avalue: tsumarrayprop);
  protected
   fdirtyup: integer;
   fdirtydown: integer;
   procedure clean(const start,stop: integer); override;
   function datatyp: datatypty; override;
   procedure getgriddefaultdata(var dest); override;
   procedure getgriddata(index: integer; var dest); override;
   procedure setgriddata(index: integer; const source); override;
   function getdefault: pointer; override;
  public
   constructor create; override;
   destructor destroy; override;
   procedure change(const index: integer); override;

   property sumlevel[index: integer]: sumlevelty read getsumlevel 
                            write setsumlevel;
             //0 -> no sum > 0 top down, < 0 bottom up
//   property sum[index: integer]: realty read getsum;
  published
   property sums: tsumarrayprop read fsums write setsums;
end; 
 
implementation
uses
 msereal;
 
{ trealsumlist }

constructor trealsumlist.create;
begin
 inherited;
 fsize:= sizeof(realsumty);
 fsums:= tsumarrayprop.create(self);
 fillchar(fdefaultval,sizeof(fdefaultval),0);
 fdefaultval.data:= emptyreal;
end;

destructor trealsumlist.destroy;
begin
 fsums.free;
 inherited;
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
 clean(index,index);
 checkindex(index);
 realty(dest):= prealsumty(fdatapo+index*fsize)^.data;
 {
 po1:= prealsumty(fdatapo+index*fsize);
 if po1^.level = 0 then begin
  realty(dest):= po1^.data;
 end
 else begin
  realty(dest):= po1^.sum;
 end;
 }
end;

procedure trealsumlist.setgriddata(index: integer; const source);
var
 int1: integer;
begin
 int1:= index;
 checkindex(index);
 with prealsumty(fdatapo+index*fsize)^ do begin
  if level = 0 then begin
   data:= realty(source);
   change(int1);
  end;
 end;
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
 with prealsumty(fdatapo+index*fsize)^ do begin
  if level <> avalue then begin
   level:= avalue;
   if avalue = 0 then begin
    if defaultzero then begin
     data:= 0;
    end
    else begin
     data:= emptyreal;
    end;
   end;
   change(-1); 
  end;
 end;
end;
{
function trealsumlist.getsum(index: integer): realty;
begin
 clean(index);
 checkindex(index);
 result:= prealsumty(fdatapo+index*fsize)^.sum;
end;
}
procedure trealsumlist.clean(const start,stop: integer);
var
 po1: prealsumty;
 int1,int2: integer;
 rea1: realty;
begin
 if stop >= fdirtyup then begin
  if fdirtyup > 0 then begin
   po1:= datapo;
   inc(po1,fdirtyup-1);
   rea1:= po1^.sumup;
  end
  else begin
   fsums.clearup;
   rea1:= emptyreal;
  end;
  po1:= datapo;
  inc(po1,fdirtyup);
  for int1:= fdirtyup to stop do begin
   int2:= po1^.level;
   if int2 = 0 then begin
    rea1:= addrealty(rea1,po1^.data);
   end
   else begin
    if int2 > 0 then begin
     if int2 <= high(fsums.fitems) then begin
      po1^.data:= fsums.newsumup(int2-1,rea1,int1);
     end
     else begin
      po1^.data:= rea1;
     end;
    end;
   end;
   po1^.sumup:= rea1;
   inc(po1);
  end;
  fdirtyup:= stop+1;
 end;
 if start <= fdirtydown then begin
  if fdirtydown < count - 1 then begin
   po1:= datapo;
   inc(po1,fdirtydown+1);
   rea1:= po1^.sumdown;
  end
  else begin
   fsums.cleardown;
   rea1:= emptyreal;
  end;
  po1:= datapo;
  inc(po1,fdirtydown);
  for int1:= fdirtydown downto start do begin
   int2:= -po1^.level;
   if int2 = 0 then begin
    rea1:= addrealty(rea1,po1^.data);
   end
   else begin
    if int2 > 0 then begin
     if int2 <= high(fsums.fitems) then begin
      po1^.data:= fsums.newsumdown(int2-1,rea1,int1);
     end
     else begin
      po1^.data:= rea1;
     end;
    end;
   end;
   po1^.sumdown:= rea1;
   dec(po1);
  end;
  fdirtydown:= start-1;
 end;
end;

procedure trealsumlist.change(const index: integer);
begin
 if fsums.needsclear(index) then begin
  fdirtyup:= 0;
  fdirtydown:= count-1;
 end
 else begin
  if index < fdirtyup then begin
   fdirtyup:= index;
  end;
  if index > fdirtydown then begin
   fdirtydown:= index;
  end;
 end;
 inherited change(-1); //sum invalid
end;

procedure trealsumlist.setsums(const avalue: tsumarrayprop);
begin
 fsums.assign(avalue);
end;

function trealsumlist.getdefault: pointer;
begin
 if defaultzero then begin
  result:= nil;
 end
 else begin
  result:= @fdefaultval;
 end;
end;

{ tsumprop }

procedure tsumprop.clearup;
begin
 fsumup:= emptyreal;
 findexup:= -1;
end;

procedure tsumprop.cleardown;
begin
 fsumdown:= emptyreal;
 findexdown:= maxint;
end;

{ tsumarrayprop }

constructor tsumarrayprop.create(const aowner: tdatalist);
begin
 inherited create(aowner,tsumprop);
end;

procedure tsumarrayprop.clearup;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tsumprop(fitems[int1]).clearup;
 end;
end;

procedure tsumarrayprop.cleardown;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  tsumprop(fitems[int1]).cleardown;
 end;
end;

function tsumarrayprop.newsumup(const alevel: integer;
              const asum: realty; const aindex: integer): realty;
var
 po1: psumprop;
 int1: integer;
begin
 po1:= psumprop(@fitems[alevel]);
 result:= subrealty(asum,po1^.fsumup);
 for int1:= alevel to high(fitems) do begin
  po1^.fsumup:= asum;
  po1^.findexup:= aindex;
  inc(po1);
 end;
end;

function tsumarrayprop.newsumdown(const alevel: integer;
              const asum: realty; const aindex: integer): realty;
var
 po1: psumprop;
 int1: integer;
begin
 po1:= psumprop(@fitems[alevel]);
 result:= subrealty(asum,po1^.fsumdown);
 for int1:= alevel to high(fitems) do begin
  po1^.fsumdown:= asum;
  po1^.findexdown:= aindex;
  inc(po1);
 end;
end;

function tsumarrayprop.needsclear(const aindex: integer): boolean;
var
 int1: integer;
begin
 result:= (aindex < 0);
 if not result and (fitems <> nil) then begin
  with tsumprop(fitems[high(fitems)]) do begin
   result:= (aindex <= findexup) or (aindex >= findexdown);
  end;
 end;
end;

initialization
 registerdatalistclass(dl_realsum,trealsumlist);
end.
