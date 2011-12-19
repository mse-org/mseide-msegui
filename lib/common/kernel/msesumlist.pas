unit msesumlist;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msedatalist,msetypes,msearrayprops,mseclasses;

//todo: optimize!!!

const
// foldlevelsumname = '#foldlevel';
 sumleveltag = 1;
 sumissumtag = 2;
 
type
 
 realsumty = record
  data: realintty;
  sumup: realty;
  sumdown: realty;
  issum: boolean;
 end;
 prealsumty = ^realsumty;

 tsumprop = class(tindexpersistent)
  protected
   fsum: realty;
   fsumindex: integer;
  published
 end;
 psumprop = ^tsumprop;

 optionsumty = (osu_sumsonly,osu_valuesonly,
                osu_foldsum{,osu_foldsumdown,osu_folddefaultsum});
 optionssumty = set of optionsumty;
 
 
 tsumarrayprop = class(tindexpersistentarrayprop)
  private
  protected
   function newsum(const alevel: integer; const asum: realty;
                                     const aindex: integer): realty;
  public
   constructor create(const aowner: tdatalist); reintroduce;
 end;

 tsumuparrayprop = class(tsumarrayprop)
 end;
 
 tsumdownarrayprop = class(tsumarrayprop)
 end;
 
 trealsumlist = class(trealintdatalist)
  private
   fsumsup: tsumuparrayprop;
   fsumsdown: tsumdownarrayprop;
   fdefaultval: realsumty;
   function getsumlevel(index: integer): integer;
   procedure setsumlevel(index: integer; const avalue: integer);
   function getisfoldsum(index: integer): boolean;
   procedure setisfoldsum(index: integer; const avalue: boolean);
   procedure setsumsup(const avalue: tsumuparrayprop);
   procedure setsumsdown(const avalue: tsumdownarrayprop);
  protected
   fdirtyup: integer;
   fdirtydown: integer;
   flinkvalue: listlinkinfoty;
   flinklevel: listlinkinfoty;
   flinkissum: listlinkinfoty;
   foptions: optionssumty;
   procedure setoptions(const avalue: optionssumty); virtual;
   procedure setsourcevalue(const avalue: string); virtual;
   procedure setsourcelevel(const avalue: string); virtual;
   procedure setsourceissum(const avalue: string); virtual;
   procedure getgriddefaultdata(var dest); override;
   procedure getgriddata(index: integer; out dest); override;
   procedure setgriddata(index: integer; const source); override;
   function getdefault: pointer; override;
   function getlinkdatatypes(const atag: integer): listdatatypesty; override;
  public
   constructor create; override;
   destructor destroy; override;
   procedure listdestroyed(const sender: tdatalist); override;
   procedure clean(const start,stop: integer); override;
   procedure change(const index: integer); override;
   function datatype: listdatatypety; override;
   procedure sourcechange(const sender: tdatalist; 
                                         const index: integer); override;
   function getsourcecount: integer; override;
   function getsourceinfo(const atag: integer): plistlinkinfoty; override;
   procedure linksource(const source: tdatalist; const atag: integer); override;

   procedure clearmemberitem(const subitem: integer; 
                                    const index: integer); override;
   procedure setmemberitem(const subitem: integer; 
                         const index: integer; const avalue: integer); override;
   property sumlevel[index: integer]: integer read getsumlevel 
                            write setsumlevel;
             //0 -> no sum > 0 top down, < 0 bottom up, not used for osu_foldsum
   property isfoldsum[index: integer]: boolean read getisfoldsum 
                            write setisfoldsum;
             //for osu_foldsum only
   property sourcevalue: string read flinkvalue.name 
                                            write setsourcevalue;
   property sourcelevel: string read flinklevel.name 
                                            write setsourcelevel;
   property sourceissum: string read flinkissum.name 
                                            write setsourceissum;
            //for osu_foldsum only
  published
   property sumsup: tsumuparrayprop read fsumsup write setsumsup;
   property sumsdown: tsumdownarrayprop read fsumsdown write setsumsdown;
   property options: optionssumty read foptions write setoptions
                                                     default [];
end; 
 
implementation
uses
 msereal,msebits;
 
{ trealsumlist }

constructor trealsumlist.create;
begin
 initsource(flinkvalue);
 initsource(flinklevel);
 initsource(flinkissum);
 inherited;
 fsize:= sizeof(realsumty);
{$warnings off}
 fsumsup:= tsumuparrayprop.create(self);
{$warnings on}
{$warnings off}
 fsumsdown:= tsumdownarrayprop.create(self);
{$warnings on}
 fillchar(fdefaultval,sizeof(fdefaultval),0);
 fdefaultval.data.rea:= emptyreal;
end;

destructor trealsumlist.destroy;
begin
 removesource(flinkvalue);
 removesource(flinklevel);
 removesource(flinkissum);
 fsumsup.free;
 fsumsdown.free;
 inherited;
end;

procedure trealsumlist.listdestroyed(const sender: tdatalist);
begin
 inherited;
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

procedure trealsumlist.getgriddata(index: integer; out dest);
//var
// po1: prealsumty;
begin
 clean(index,index);
 checkindex(index);
 realty(dest):= prealsumty(fdatapo+index*fsize)^.data.rea;
end;

procedure trealsumlist.setgriddata(index: integer; const source);
var
 int1: integer;
begin
 int1:= index;
 checkindex(index);
 with prealsumty(fdatapo+index*fsize)^ do begin
  if data.int = 0 then begin
   data.rea:= realty(source);
   change(int1);
  end;
 end;
end;

function trealsumlist.getsumlevel(index: integer): integer;
begin
 checkindex(index);
 result:= prealsumty(fdatapo+index*fsize)^.data.int;
end;

procedure trealsumlist.setsumlevel(index: integer;
               const avalue: integer);
var
 int1: integer;
begin
 int1:= index;
 checkindex(index);
 with prealsumty(fdatapo+index*fsize)^ do begin
  if data.int <> avalue then begin
   data.int:= avalue;
   if not (osu_foldsum in foptions) then begin
    if avalue = 0 then begin
     if defaultzero then begin
      data.rea:= 0;
     end
     else begin
      data.rea:= emptyreal;
     end;
    end;
    sourcechange(flinkvalue.source,int1); //restore value
    change(-1); 
   end;
  end;
 end;
end;

function trealsumlist.getisfoldsum(index: integer): boolean;
begin
 checkindex(index);
 result:= prealsumty(fdatapo+index*fsize)^.issum;
end;

procedure trealsumlist.setisfoldsum(index: integer;
               const avalue: boolean);
var
 int1: integer;
begin
 int1:= index;
 checkindex(index);
 with prealsumty(fdatapo+index*fsize)^ do begin
  if issum <> avalue then begin
   issum:= avalue;
   if (osu_foldsum in foptions) then begin
    if not avalue then begin
     if defaultzero then begin
      data.rea:= 0;
     end
     else begin
      data.rea:= emptyreal;
     end;
    end;
   end;
   sourcechange(flinklevel.source,int1); //restore sumlevel
   sourcechange(flinkvalue.source,int1); //restore value
   change(-1); 
  end;
 end;
end;

procedure copyvalue(const source,dest: pointer);
begin
 prealsumty(dest)^.data.rea:= preal(source)^;
end;

procedure copylevel(const source,dest: pointer);
begin
 prealsumty(dest)^.data.int:= pinteger(source)^;
end;

procedure copylevelrowstate(const source,dest: pointer);
begin
 with prowstatety(source)^ do begin
  prealsumty(dest)^.issum:= flags and foldissummask <> 0;
  if prealsumty(dest)^.issum then begin
   prealsumty(dest)^.data.int:= -(fold + 1);
  end
  else begin
   prealsumty(dest)^.data.int:= 0
  end;
 end;
end;

procedure copylevelrowstateissum(const source1,source2,dest: pointer);
begin
 with prealsumty(dest)^ do begin
  if pinteger(source2)^ <> 0 then begin
   data.int:= -(prowstatety(source1)^.fold + 1);
   issum:= true;
  end
  else begin
   data.int:= 0;
   issum:= false;
  end;
 end;
end;

procedure trealsumlist.clean(const start,stop: integer);
var
 po1: prealsumty;
// po2: prowstatety;
// po3: pinteger;
 int1,int2: integer;
 rea1: realty;
begin
 checksourcecopy(flinkvalue,@copyvalue);
 if flinklevel.source is tcustomrowstatelist then begin
  if flinkissum.source <> nil then begin
   checksourcecopy2(flinklevel,flinkissum.source,@copylevelrowstateissum);
  end
  else begin
   checksourcecopy(flinklevel,@copylevelrowstate);
  end;
 end
 else begin
  checksourcecopy(flinklevel,@copylevel);
 end;
 if fsumsup.count > 0 then begin
  if stop >= fdirtyup then begin
   if fdirtyup > 0 then begin
    po1:= datapo;
    inc(po1,fdirtyup-1);
    rea1:= po1^.sumup;
   end
   else begin
    with fsumsup do begin
     for int1:= 0 to high(fitems) do begin
      with tsumprop(fitems[int1]) do begin
       fsum:= emptyreal;
       fsumindex:= -1;
      end;
     end;
    end;
    rea1:= emptyreal;
   end;
   po1:= datapo;
   inc(po1,fdirtyup);
   for int1:= fdirtyup to stop do begin
    int2:= po1^.data.int;
    if int2 = 0 then begin
     rea1:= addrealty(rea1,po1^.data.rea);
    end
    else begin
     if int2 > 0 then begin
      if int2 <= high(fsumsup.fitems) then begin
       po1^.data.rea:= fsumsup.newsum(int2-1,rea1,int1);
      end
      else begin
       po1^.data.rea:= rea1;
      end;
     end;
    end;
    po1^.sumup:= rea1;
    inc(po1);
   end;
   fdirtyup:= stop+1;
  end;
 end;
 if fsumsdown.count > 0 then begin
  if start <= fdirtydown then begin
   if fdirtydown < count - 1 then begin
    po1:= datapo;
    inc(po1,fdirtydown+1);
    rea1:= po1^.sumdown;
   end
   else begin
    with fsumsdown do begin
     for int1:= 0 to high(fitems) do begin
      with tsumprop(fitems[int1]) do begin
       fsum:= emptyreal;
       fsumindex:= maxint;
      end;
     end;
    end;
    rea1:= emptyreal;
   end;
   po1:= datapo;
   inc(po1,fdirtydown);
   for int1:= fdirtydown downto start do begin
    int2:= -po1^.data.int;
    if int2 = 0 then begin
     rea1:= addrealty(rea1,po1^.data.rea);
    end
    else begin
     if int2 > 0 then begin
      if int2 <= high(fsumsdown.fitems) then begin
       po1^.data.rea:= fsumsdown.newsum(int2-1,rea1,int1);
      end
      else begin
       po1^.data.rea:= rea1;
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
 if index < 0 then begin
  fdirtyup:= 0;
  fdirtydown:= count-1;
 end
 else begin
  with fsumsup do begin
   if (fitems <> nil) and 
            (tsumprop(fitems[high(fitems)]).fsumindex <= index) then begin
    fdirtyup:= 0;
   end;
  end;
  with fsumsdown do begin
   if (fitems <> nil) and 
            (tsumprop(fitems[high(fitems)]).fsumindex >= index) then begin
    fdirtydown:= self.count-1;
   end;
  end;
 end;
 inherited change(-1); //sum invalid
end;

procedure trealsumlist.setsumsup(const avalue: tsumuparrayprop);
begin
 fsumsup.assign(avalue);
end;

procedure trealsumlist.setsumsdown(const avalue: tsumdownarrayprop);
begin
 fsumsdown.assign(avalue);
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
 if sender <> nil then begin
  if sender = flinkvalue.source then begin
   checksourcechange(flinkvalue,flinkvalue.source,index); //restore value
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
end;

function trealsumlist.getlinkdatatypes(const atag: integer): listdatatypesty;
begin
 result:= inherited getlinkdatatypes(atag);
 case atag of
  0: begin
   result:= result + [dl_real];
  end;
  sumleveltag: begin
   if osu_foldsum in foptions then begin
    result:= [dl_rowstate];
   end
   else begin
    result:= [dl_integer];
   end;
  end;
  sumissumtag: begin
   result:= [dl_integer];
  end;
 end;
end;

procedure trealsumlist.setoptions(const avalue: optionssumty);
const
 mask1: optionssumty = [osu_sumsonly,osu_valuesonly];
begin
 if foptions <> avalue then begin
  foptions:= optionssumty(
        setsinglebit({$ifdef FPC}longword{$else}byte{$endif}(avalue),
                      {$ifdef FPC}longword{$else}byte{$endif}(foptions),
                      {$ifdef FPC}longword{$else}byte{$endif}(mask1)));
  change(-1);
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
  sumleveltag: begin
   internallinksource(source,atag,flinklevel.source);
  end;
  sumissumtag: begin
   if internallinksource(source,atag,flinkissum.source) and 
                                   (flinklevel.source <> nil)then begin
    sourcechange(flinklevel.source,-1); //sum level invalid
   end;
  end;
 end;
end;

function trealsumlist.getsourcecount: integer;
begin
 result:= 3;
end;

function trealsumlist.getsourceinfo(const atag: integer): plistlinkinfoty;
begin
 case atag of
  0: begin
   result:= @flinkvalue;
  end;
  sumleveltag: begin
   result:= @flinklevel;
  end;
  sumissumtag: begin
   result:= @flinkissum;
  end
  else begin
   result:= nil;
  end;
 end;
end;

procedure trealsumlist.clearmemberitem(const subitem: integer;
                                                     const index: integer);
begin
 if subitem = 1 then begin
  if osu_foldsum in foptions then begin
   isfoldsum[index]:= false;
  end
  else begin
   sumlevel[index]:= 0;
  end;
 end;
end;

procedure trealsumlist.setmemberitem(const subitem: integer;
                                const index: integer; const avalue: integer);
begin
 if subitem = 1 then begin
  if osu_foldsum in foptions then begin
   isfoldsum[index]:= avalue <> 0;
  end
  else begin
   sumlevel[index]:= avalue;
  end;
 end;
end;

{ tsumprop }

{ tsumarrayprop }

constructor tsumarrayprop.create(const aowner: tdatalist);
begin
 inherited create(aowner,tsumprop);
end;

function tsumarrayprop.newsum(const alevel: integer;
              const asum: realty; const aindex: integer): realty;
var
 po1: psumprop;
 int1: integer;
begin
 po1:= psumprop(@fitems[alevel]);
 result:= subrealty(asum,po1^.fsum);
 for int1:= alevel to high(fitems) do begin
  po1^.fsum:= asum;
  po1^.findex:= aindex;
  inc(po1);
 end;
end;

initialization
 registerdatalistclass(dl_realsum,trealsumlist);
end.
