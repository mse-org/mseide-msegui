unit msesumlist;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msedatalist,msetypes,msearrayprops,mseclasses;

const
 foldlevelsumname = '#foldlevel';
 
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

 optionsumty = (osu_sumup,osu_sumdown,osu_sumsonly,
                osu_foldsumdown,osu_folddefaultsum);
 optionssumty = set of optionsumty;
 
 
 tsumarrayprop = class(tindexpersistentarrayprop)
  private
   procedure setoptions(const avalue: optionssumty);
  protected
   foptions: optionssumty;
   procedure clearup;
   procedure cleardown;
   function newsumup(const alevel: integer; const asum: realty;
                                     const aindex: integer): realty;
   function newsumdown(const alevel: integer; const asum: realty;
                                     const aindex: integer): realty;
   function needsclear(const aindex: integer): boolean;
  public
   constructor create(const aowner: tdatalist);
  published
   property options: optionssumty read foptions write setoptions
                                                     default [];
 end;
  
 trealsumlist = class(trealdatalist)
  private
   fsums: tsumarrayprop;
   fdefaultval: realsumty;
//   fsourceissumname: string;
   function getsumlevel(index: integer): sumlevelty;
   procedure setsumlevel(index: integer; const avalue: sumlevelty);
//   function getsum(index: integer): realty;
   procedure setsums(const avalue: tsumarrayprop);
   function getlinkdatatypes(const atag: integer): listdatatypesty; override;
  protected
//   fsourceleveldirtystart: integer;
//   fsourceleveldirtystop: integer;
   fdirtyup: integer;
   fdirtydown: integer;
//   fsourcelevelname: string;
   flinkvalue: listlinkinfoty;
   flinklevel: listlinkinfoty;
   flinkissum: listlinkinfoty;
   procedure setsourcevalue(const avalue: string); virtual;
   procedure setsourcelevel(const avalue: string); virtual;
   procedure setsourceissum(const avalue: string); virtual;
   procedure listdestroyed(const sender: tdatalist); override;
   procedure clean(const start,stop: integer); override;
   function datatype: listdatatypety; override;
   procedure getgriddefaultdata(var dest); override;
   procedure getgriddata(index: integer; var dest); override;
   procedure setgriddata(index: integer; const source); override;
   function getdefault: pointer; override;
  public
   constructor create; override;
   destructor destroy; override;
   procedure change(const index: integer); override;
   procedure sourcechange(const sender: tdatalist; 
                                         const index: integer); override;
   function getsourcenamecount: integer; override;
   function getsourcename(const atag: integer): string; override;
   procedure linksource(const source: tdatalist; const atag: integer); override;

   property sumlevel[index: integer]: sumlevelty read getsumlevel 
                            write setsumlevel;
             //0 -> no sum > 0 top down, < 0 bottom up
//   property sum[index: integer]: realty read getsum;
  public
   property sourcevalue: string read flinkvalue.name 
                                            write setsourcevalue;
   property sourcelevel: string read flinklevel.name 
                                            write setsourcelevel;
   property sourceissum: string read flinkissum.name 
                                            write setsourceissum;
          //define leaves for #foldlevel
  published
   property sums: tsumarrayprop read fsums write setsums;
end; 
 
implementation
uses
 msereal;
 
{ trealsumlist }

constructor trealsumlist.create;
begin
 initsource(flinkvalue);
 initsource(flinklevel);
 initsource(flinkissum);
 inherited;
 fsize:= sizeof(realsumty);
 fsums:= tsumarrayprop.create(self);
 fillchar(fdefaultval,sizeof(fdefaultval),0);
 fdefaultval.data:= emptyreal;
end;

destructor trealsumlist.destroy;
begin
 removesource(flinkvalue);
 removesource(flinklevel);
 removesource(flinkissum);
 fsums.free;
 inherited;
end;

procedure trealsumlist.listdestroyed(const sender: tdatalist);
begin
 checklistdestroyed(flinkvalue,sender);
 checklistdestroyed(flinklevel,sender);
 checklistdestroyed(flinkissum,sender);
end;

function trealsumlist.datatype: listdatatypety;
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
   sourcechange(flinkvalue.source,int1); //restore value
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
procedure copyvalue(const source,dest: pointer);
begin
 prealsumty(dest)^.data:= preal(source)^;
end;

procedure copylevel(const source,dest: pointer);
begin
 prealsumty(dest)^.level:= pinteger(source)^;
end;

procedure copylevelrowstate(const source,dest: pointer);
begin
 prealsumty(dest)^.level:= -(prowstatety(source)^.fold + 1);
end;

procedure copylevelrowstateissum(const source1,source2,dest: pointer);
begin
 if pinteger(source2)^ <> 0 then begin
  prealsumty(dest)^.level:= -(prowstatety(source1)^.fold + 1);
 end
 else begin
  prealsumty(dest)^.level:= 0;
 end;
end;

procedure copylevelrowstateissumsum(const source1,source2,dest: pointer);
begin
 if pinteger(source2)^ = 0 then begin
  prealsumty(dest)^.level:= -(prowstatety(source1)^.fold + 1);
 end
 else begin
  prealsumty(dest)^.level:= 0;
 end;
end;

procedure copylevelrowstatedown(const source,dest: pointer);
begin
 prealsumty(dest)^.level:= prowstatety(source)^.fold + 1;
end;

procedure copylevelrowstateissumdown(const source1,source2,dest: pointer);
begin
 if pinteger(source2)^ <> 0 then begin
  prealsumty(dest)^.level:= (prowstatety(source1)^.fold + 1);
 end
 else begin
  prealsumty(dest)^.level:= 0;
 end;
end;

procedure copylevelrowstateissumdownsum(const source1,source2,dest: pointer);
begin
 if pinteger(source2)^ = 0 then begin
  prealsumty(dest)^.level:= (prowstatety(source1)^.fold + 1);
 end
 else begin
  prealsumty(dest)^.level:= 0;
 end;
end;

procedure trealsumlist.clean(const start,stop: integer);
var
 po1: prealsumty;
 po2: prowstatety;
 po3: pinteger;
 int1,int2: integer;
 rea1: realty;
begin
 checksourcecopy(flinkvalue,@copyvalue);
 if flinklevel.source is tcustomrowstatelist then begin
  if osu_foldsumdown in fsums.options then begin
   if flinkissum.source <> nil then begin
    if osu_folddefaultsum in fsums.options then begin
     checksourcecopy2(flinklevel,flinkissum.source,
                                         @copylevelrowstateissumdownsum);
    end
    else begin
     checksourcecopy2(flinklevel,flinkissum.source,@copylevelrowstateissumdown);
    end;
   end
   else begin
    checksourcecopy(flinklevel,@copylevelrowstatedown);
   end;
  end
  else begin
   if flinkissum.source <> nil then begin
    if osu_folddefaultsum in fsums.options then begin
     checksourcecopy2(flinklevel,flinkissum.source,@copylevelrowstateissumsum);
    end
    else begin
     checksourcecopy2(flinklevel,flinkissum.source,@copylevelrowstateissum);
    end;
   end
   else begin
    checksourcecopy(flinklevel,@copylevelrowstate);
   end;
  end;
 end
 else begin
  checksourcecopy(flinklevel,@copylevel);
 end;
 if osu_sumup in fsums.options then begin
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
 end;
 if osu_sumdown in fsums.options then begin
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

procedure trealsumlist.sourcechange(const sender: tdatalist; 
                                                const index: integer);
begin
 inherited;
 if sender = flinkvalue.source then begin
  change(index);
 end
 else begin
  if (sender = flinkissum.source) then begin
   checksourcechange(flinklevel,flinklevel.source,index); //invalid
   checksourcechange(flinkvalue,flinkvalue.source,index); //restore value
   change(-1);
  end
  else begin
   if checksourcechange(flinklevel,sender,index) then begin
    checksourcechange(flinkvalue,flinkvalue.source,index); //restore value
    change(-1);
   end;
  end;
 end;
end;

function trealsumlist.getlinkdatatypes(const atag: integer): listdatatypesty;
begin
 result:= inherited getlinkdatatypes(atag);
 case atag of
  0: begin
   result:= result + [dl_real];
  end;
  1,3: begin
   result:= [dl_integer];
  end;
  2: begin
   result:= [dl_rowstate];
  end;
 end;
end;

procedure trealsumlist.setsourcevalue(const avalue: string);
begin
 flinkvalue.name:= avalue;
end;

procedure trealsumlist.setsourcelevel(const avalue: string);
begin
 flinklevel.name:= avalue;
end;

procedure trealsumlist.setsourceissum(const avalue: string);
begin
 flinkissum.name:= avalue;
end;

procedure trealsumlist.linksource(const source: tdatalist; const atag: integer);
begin
 case atag of
  0: begin
   internallinksource(source,atag,flinkvalue.source);
  end;
  1,2: begin
   if (atag = 1) or (flinklevel.name = foldlevelsumname) then begin
    internallinksource(source,atag,flinklevel.source);
   end;
  end;
  3: begin
   if internallinksource(source,atag,flinkissum.source) and 
                                   (flinklevel.source <> nil)then begin
    sourcechange(flinklevel.source,-1); //sum level invalid
   end;
  end;
  {
 if (atag = 0) and internallinksource(source,atag,flinksource) then begin
  sourcechange(source,-1);
 end
 else begin
  if (atag = 1) or (atag = 2) and (fsourcelevelname = foldlevelsumname) then begin
   if internallinksource(source,atag,flinksourcelevel) then begin
    sourcechange(source,-1);
   end;
  end
  else begin
   if (atag = 3) then begin
    if internallinksource(source,atag,flinksourceissum) and 
                                    (flinksourcelevel <> nil)then begin
     sourcechange(flinksourcelevel,-1); //sum level invalid
    end;
   end;
  end;
  }
 end;
end;

function trealsumlist.getsourcenamecount: integer;
begin
 result:= 4;
end;

function trealsumlist.getsourcename(const atag: integer): string;
begin
 case atag of
  0: begin
   result:= flinkvalue.name;
  end;
  1,2: begin
   if (flinklevel.name = foldlevelsumname) xor (atag = 2) then begin
    result:= '';
   end
   else begin
    result:= flinklevel.name;
   end;
  end;
  3: begin
   result:= flinkissum.name;
  end
  else begin
   result:= '';
  end;
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

procedure tsumarrayprop.setoptions(const avalue: optionssumty);
begin
 if foptions <> avalue then begin
  foptions:= avalue;
  tdatalist(fowner).change(-1);
 end;
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
