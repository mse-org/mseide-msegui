{ MSEgui Copyright (c) 2007-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseifigui;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mseclasses,mseguiglob,mseifiglob,mseifi,mseact,msegui,typinfo,
 msestrings,
 msearrayprops,mseglob,msetypes,mseifilink,msewidgetgrid,msemenus,
 mseevent,msegrids,msegraphutils,msedatalist;
 
type
 
 ifiwidgetlinkoptionty = (iwlo_sendvalue,iwlo_sendmodalresult,
      iwlo_sendhide,iwlo_sendshow,
      iwlo_sendfocus,iwlo_senddefocus,iwlo_sendactivate,iwlo_senddeactivate);
 ifiwidgetlinkoptionsty = set of ifiwidgetlinkoptionty;
const
 widgetstateoptionsty = [iwlo_sendhide,iwlo_sendshow,iwlo_sendfocus,
      iwlo_senddefocus,iwlo_sendactivate,iwlo_senddeactivate];
type  

 tvaluewidgetlink = class(tcustomvaluecomponentlink)
  private
   foptions: ifiwidgetlinkoptionsty;
   fwidgetstatebefore: ifiwidgetstatesty;
   function getwidget: twidget;
   procedure setwidget(const avalue: twidget);
  published
   property widget: twidget read getwidget write setwidget;
   property options: ifiwidgetlinkoptionsty read foptions 
                                                 write foptions default [];
 end;
 
 tvaluewidgetlinks = class(tvaluelinks) 
  private
   function getitems(const index: integer): tvaluewidgetlink;
  protected
   function getitemclass: modulelinkpropclassty; override;  
  public
   class function getitemclasstype: persistentclassty; override;
   function byname(const aname: string): tvaluewidgetlink;
   property items[const index: integer]: tvaluewidgetlink read getitems; default;   
 end;

 tformlink = class(tcustommodulelink)
  private
   function getvaluewidgets: tvaluewidgetlinks;
   procedure setvaluewidgets(const avalue: tvaluewidgetlinks);
  protected
   function widgetcommandreceived(const atag: integer; const aname: string;
                      const acommand: ifiwidgetcommandty): boolean;
   function widgetpropertiesreceived(const atag: integer; const aname: string;
                      const adata: pifibytesty): boolean;
   function processdataitem(const adata: pifirecty; var adatapo: pchar;
                  const atag: integer; const aname: string): boolean; override;
   procedure valuechanged(const sender: iifiwidget); override;
   procedure statechanged(const sender: iifiwidget;
                             const astate: ifiwidgetstatesty); override;
   procedure sendmodalresult(const sender: iifiwidget; 
                              const amodalresult: modalresultty); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property valuewidgets: tvaluewidgetlinks read getvaluewidgets 
                                                      write setvaluewidgets;
   property valuecomponents;
   property linkname;
   property actionsrx;
   property actionstx;
   property modulesrx;
   property modulestx;
   property channel;
   property options;
 end;

 trxwidgetgrid = class;
  
 tifiwidgetgridcontroller = class(tifigridcontroller)
  protected
   procedure processdata(const adata: pifirecty; var adatapo: pchar); override;
   procedure setowneractive(const avalue: boolean); override;
   function encodegriddata(const asequence: sequencety): ansistring; override;
  public
   constructor create(const aowner: trxwidgetgrid);
 end;

 tifiwidgetcol = class(twidgetcol)
  protected
   procedure datachange(const arow: integer); override;
 end;
 ifiwidgetcolarty = array of tifiwidgetcol;
  
 rxwidgetstatety = ({rws_openpending,}rws_datareceived,rws_commandsending); 
 rxwidgetstatesty = set of rxwidgetstatety;
 
 trxwidgetgrid = class(twidgetgrid,iifimodulelink)
  private
   factive: boolean;
   procedure setactive1(const avalue: boolean);
   procedure setactive(const avalue: boolean);
  protected
   fistate: rxwidgetstatesty;
   fifi: tifiwidgetgridcontroller;
   procedure setifi(const avalue: tifiwidgetgridcontroller);
   procedure loaded; override;
   procedure internalopen;
   procedure internalclose;
   procedure docolmoved(const fromindex,toindex: integer); override;
   procedure dorowsmoved(const fromindex,toindex,count: integer); override;
   procedure dorowsinserted(const index,count: integer); override;
   procedure dorowsdeleted(index,count: integer); override;
   procedure rowstatechanged(const arow: integer); override;
   procedure docellevent(var info: celleventinfoty); override;
//   procedure dorowsdatachanged(const acell: gridcoordty; 
//                                           const acount: integer); override;
   procedure createdatacol(const index: integer; out item: tdatacol); override;
   procedure setselected(const cell: gridcoordty;
                                       const avalue: boolean); override;
  //iifimodulelink
   procedure connectmodule(const sender: tcustommodulelink);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
//   procedure post;
  published
   property ifi: tifiwidgetgridcontroller read fifi write setifi;
   property active: boolean read factive write setactive1 default false;
 end;

implementation
uses
 sysutils,msestream,msesysutils,msetmpmodules,mseeditglob;
type
 tcustommodulelink1 = class(tcustommodulelink);
 tdatacols1 = class(tdatacols);
 
// tlinkdata1 = class(tlinkdata);

{ tvaluewidgetlink }

function tvaluewidgetlink.getwidget: twidget;
begin
 result:= twidget(fcomponent);
end;

procedure tvaluewidgetlink.setwidget(const avalue: twidget);
var
 intf1: iifiwidget;
begin
 intf1:= nil;
 fwidgetstatebefore:= [];
 fvalueproperty:= nil;
 if (avalue <> nil) and 
    not getcorbainterface(avalue,typeinfo(iifiwidget),intf1) then begin
  raise exception.create(avalue.name+': No ifiwidget.');
 end;
 if fintf <> nil then begin
  fintf.setifiserverintf(nil);
 end;
 fintf:= intf1;
 if fintf <> nil then begin
  fintf.setifiserverintf(iifiserver(tcustommodulelink(fowner)));
 end;
 inherited component:= avalue;
end;

{ tvaluewidgetlinks }

class function tvaluewidgetlinks.getitemclasstype: persistentclassty;
begin
 result:= tvaluewidgetlink;
end;

function tvaluewidgetlinks.getitems(const index: integer): tvaluewidgetlink;
begin
 result:= tvaluewidgetlink(inherited getitems(index));
end;

function tvaluewidgetlinks.byname(const aname: string): tvaluewidgetlink;
begin
 result:= tvaluewidgetlink(inherited byname(aname));
end;

function tvaluewidgetlinks.getitemclass: modulelinkpropclassty;
begin
 result:= tvaluewidgetlink;
end;

{ tformlink }

constructor tformlink.create(aowner: tcomponent);
begin
 if fvalues = nil then begin
  fvalues:= tvaluewidgetlinks.create(self);
 end;
 inherited;
end;

destructor tformlink.destroy;
begin
// fdatas.free;
 inherited;
end;

function tformlink.getvaluewidgets: tvaluewidgetlinks;
begin
 result:= tvaluewidgetlinks(fvalues);
end;

procedure tformlink.setvaluewidgets(const avalue: tvaluewidgetlinks);
begin
 fvalues.assign(avalue);
end;

function tformlink.processdataitem(const adata: pifirecty; 
           var adatapo: pchar; const atag: integer; const aname: string): boolean;
var
 command1: ifiwidgetcommandty;
 str2: string;
begin
 with adata^ do begin
  case header.kind of
   ik_widgetcommand: begin
    command1:= pifiwidgetcommandty(adatapo)^;
    result:= widgetcommandreceived(atag,aname,command1);
   end;
   ik_widgetproperties: begin
    result:= widgetpropertiesreceived(atag,aname,pifibytesty(adatapo));     
   end;
   else begin
    result:= inherited processdataitem(adata,adatapo,atag,aname);
   end;
  end;
 end;
end;

function tformlink.widgetcommandreceived(const atag: integer;
             const aname: string; const acommand: ifiwidgetcommandty): boolean;
var
 wi1: tvaluewidgetlink;
begin
 wi1:= tvaluewidgetlink(fvalues.finditem(aname));
 result:= wi1 <> nil;
 if result and (wi1.fcomponent <> nil) then begin
  with wi1.widget do begin
   case acommand of
    iwc_enable: begin
     enabled:= true;
    end;
    iwc_disable: begin
     enabled:= false;
    end;
    iwc_show: begin
     visible:= true;
    end;
    iwc_hide: begin
     visible:= false;
    end;
   end;
  end;
 end;    
end;

function tformlink.widgetpropertiesreceived(const atag: integer;
                     const aname: string; const adata: pifibytesty): boolean;
var
 wi1: tvaluewidgetlink;
 stream1: tmemorystream;
begin
 wi1:= tvaluewidgetlink(fvalues.finditem(aname));
 result:= wi1 <> nil;
 if result and (wi1.fcomponent <> nil) then begin
  stream1:= tmemorycopystream.create(@adata^.data,adata^.length);
  try
   stream1.readcomponent(wi1.fcomponent);
  finally
   stream1.free;
  end;
 end;
end;

procedure tformlink.valuechanged(const sender: iifiwidget);
var
 int1: integer;
begin
 if hasconnection then begin
  with tvaluewidgetlinks(fvalues ) do begin
   for int1:= 0 to high(fitems) do begin
    with tvaluewidgetlink(fitems[int1]) do begin
     if fupdatelock = 0 then begin
      if (fintf = sender) then begin
       if iwlo_sendvalue in options then begin
        sendvalue(fvalueproperty);
       end;
       break;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tformlink.sendmodalresult(const sender: iifiwidget; 
                                         const amodalresult: modalresultty);
var
 int1: integer;
begin
 if hasconnection then begin
  with tvaluewidgetlinks(fvalues ) do begin
   for int1:= 0 to high(fitems) do begin
    with tvaluewidgetlink(fitems[int1]) do begin
     if fupdatelock = 0 then begin
      if (fintf = sender) then begin
       if iwlo_sendmodalresult in options then begin
        sendmodalresult(amodalresult);
       end;
       break;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tformlink.statechanged(const sender: iifiwidget;
                             const astate: ifiwidgetstatesty);
var
 int1: integer;
 states1: ifiwidgetstatesty;
begin
 if hasconnection then begin
  with tvaluewidgetlinks(fvalues ) do begin
   for int1:= 0 to high(fitems) do begin
    with tvaluewidgetlink(fitems[int1]) do begin
     if (fintf = sender) then begin
      if options * widgetstateoptionsty <> [] then begin
       states1:= ifiwidgetstatesty(longword(fwidgetstatebefore) xor 
                                 longword(astate));
       if (iws_visible in states1) and 
           ((iwlo_sendshow in options) and (iws_visible in astate) or
             (iwlo_sendhide in options) and not (iws_visible in astate)) or
          (iws_focused in states1) and 
           ((iwlo_sendfocus in options) and (iws_focused in astate) or
             (iwlo_senddefocus in options) and not(iws_focused in astate)) or           
          (iws_active in states1) and 
           ((iwlo_sendactivate in options) and (iws_active in astate) or
             (iwlo_senddeactivate in options) and not(iws_active in astate))
                                                                     then begin
        sendstate(astate);
       end;
      end;
      fwidgetstatebefore:= astate;
      break;
     end;
    end;
   end;
  end;
 end;
end;

{ tifiwidgetgridcontroller }

constructor tifiwidgetgridcontroller.create(const aowner: trxwidgetgrid);
begin
 inherited create(aowner);
end;

procedure tifiwidgetgridcontroller.setowneractive(const avalue: boolean);
begin
 trxwidgetgrid(fowner).active:= avalue;
end;

function tifiwidgetgridcontroller.encodegriddata(
                     const asequence: sequencety): ansistring;
var
 po1,po4: pchar;
 int1,int2,int3,int4: integer;
 po2: pmsestring;
 po3: pansistring;
 ar1: booleanarty;
 ar2: bytearty;
begin
 with trxwidgetgrid(fowner) do begin
  setlength(ar1,datacols.count);
  int2:= 0;
  int3:= 0;
  for int1:= 0 to datacols.count - 1 do begin
   with datacols[int1] do begin
    ar1[int1]:= (name <> '') and (datalist <> nil) and 
                               (datalist.datatype in ifidatatypes);
    if ar1[int1] then begin
     inc(int3);
     int2:= int2 + (sizeof(listdatatypety)+1) + length(name) + 
                       datalisttoifidata(datalist);
    end;
   end;
  end;
  int2:= int2 + datalisttoifidata(tdatacols1(datacols).frowstate);
//  if tdatacols1(datacols).frowstate.folded then begin
//   int2:= int2 + rowcount * sizeof(byte);
//  end;
  inititemheader(result,ik_griddata,asequence,int2,po1);
  with pgriddatadataty(po1)^ do begin
   rows:= rowcount;
   cols:= int3;
   po1:= @data;
   for int1:= 0 to high(ar1) do begin
    if ar1[int1] then begin
     with datacols[int1] do begin
      with pcoldataty(po1)^ do begin
       kind:= datalist.datatype;
       po1:= @name;   
      end;
      inc(po1,stringtoifiname(name,pifinamety(po1)));
      datalisttoifidata(datalist,po1);
     end;
    end;
   end;
   datalisttoifidata(tdatacols1(datacols).frowstate,po1);
{
   if tdatacols1(datacols).frowstate.folded then begin
    ar2:= tdatacols1(datacols).frowstate.foldinfoar;
    inc(po1,setifibytes(pointer(ar2),rowcount,pifibytesty(po1)));
   end
   else begin
    inc(po1,setifibytes(pointer(ar2),0,pifibytesty(po1)));
   end;
   }
  end;
 end;
end;

procedure tifiwidgetgridcontroller.processdata(const adata: pifirecty;
               var adatapo: pchar);
var
 int1: integer;
 rows1,cols1: integer;
 kind1: listdatatypety;
 po1: pchar;
 str1: ansistring;
 po2: pointer;
 ckind1: gridcommandkindty;
 source1,dest1,count1: integer;
 rowstate1: rowstatecolmergety;
 select1: selectdataty;
 lwo1: longword;
 datalist1: tdatalist;
 po3: prowstatecolmergety;
begin
 with adata^.header do begin
  case kind of
   ik_requestopen: begin
    senddata(encodegriddata(sequence));
   end;
   ik_griddata: begin
    if (igo_state in foptionsrx) or 
        (answersequence <> 0) and (answersequence = fdatasequence) then begin
     with trxwidgetgrid(fowner) do begin
      beginupdate;
      try
       with pgriddatadataty(adatapo)^ do begin
        rows1:= rows;
        rowcount:= rows1;
        cols1:= cols;
        po1:= @data;
       end;
       for int1:= 0 to cols1 - 1 do begin
        with pcoldataty(po1)^ do begin
         kind1:= kind;
         po1:= @name;
         inc(po1,ifinametostring(pifinamety(po1),str1));
         inc(po1,ifidatatodatalist(kind1,rows1,po1,
                   datacols.datalistbyname(str1)));
        end;
       end;
       inc(po1,ifidatatodatalist(dl_rowstate,rows1,po1,
                                    tdatacols1(datacols).frowstate));
       include(fistate,rws_datareceived);
      finally
       endupdate;
      end;
     end;
    end;
   end;
   ik_gridcommand: begin
    inc(adatapo,decodegridcommanddata(adatapo,ckind1,source1,dest1,count1));
    with trxwidgetgrid(fowner) do begin
     inc(fcommandlock);
     try
      case ckind1 of
       gck_insertrow: begin
        if igo_rowinsert in foptionsrx then begin
         insertrow(dest1,count1);       
        end;
       end;
       gck_deleterow: begin
        if igo_rowdelete in foptionsrx then begin
         deleterow(dest1,count1);       
        end;
       end;
       gck_moverow: begin
        if igo_rowmove in foptionsrx then begin
         moverow(source1,dest1,count1);       
        end;
       end;
       gck_rowenter: begin
        if igo_rowenter in foptionsrx then begin
         row:= dest1;
        end;
       end;
      end;
     finally
      dec(fcommandlock);
     end;
    end;
   end;
   ik_coldatachange: begin
    if igo_coldata in foptionsrx then begin
     inc(fcommandlock);
     try
      int1:= pcolitemdataty(adatapo)^.header.row;
      ifinametostring(@pcolitemdataty(adatapo)^.header.name,str1);
      inc(adatapo,sizeof(colitemheaderty)+length(str1));
      datalist1:= nil;
      if igo_coldata in foptionsrx then begin
       datalist1:= trxwidgetgrid(fowner).fdatacols.datalistbyname(str1);
      end;    //skip data otherwise
      inc(adatapo,decodeifidata(pifidataty(adatapo),int1,datalist1));
     finally
      dec(fcommandlock);
     end;
    end;
   end;
   ik_rowstatechange: begin
    if igo_rowstate in foptionsrx then begin
     inc(fcommandlock);
     try
      int1:= prowstatedataty(adatapo)^.header.row;
      inc(adatapo,sizeof(rowstateheaderty));
      inc(adatapo,decodeifidata(pifidataty(adatapo),rowstate1));
      with trxwidgetgrid(fowner),rowstate1 do begin
       rowcolorstate[int1]:= normal.color;
       rowfontstate[int1]:= normal.font;
       po3:= fdatacols.rowstate.getitempocolmerge(int1);
       if po3^.colmerge.merged <> colmerge.merged then begin
        po3^.colmerge.merged:= colmerge.merged;
        tdatacols1(fdatacols).mergechanged(int1);         
       end;
       rowhidden[int1]:= normal.fold and foldhiddenmask <> 0;
       rowfoldlevel[int1]:= normal.fold and foldlevelmask;
      end;
     finally
      dec(fcommandlock);
     end;
    end;
   end;
   ik_selection: begin
    if igo_selection in foptionsrx then begin
     inc(fcommandlock);
     try
      inc(adatapo,decodeifidata(pifidataty(adatapo),select1));
      with select1 do begin
       trxwidgetgrid(fowner).fdatacols.selected[makegridcoord(col,row)]:= select;
      end;
     finally
      dec(fcommandlock);
     end;
    end;
   end;
  end;
 end;
end;

{ tifiwidgetcol }

procedure tifiwidgetcol.datachange(const arow: integer);
begin
 with trxwidgetgrid(fgrid).fifi do begin
  if (self.name <> '') and cancommandsend(igo_coldata) and 
                                            (fdata <> nil) then begin
   senditem(ik_coldatachange,[encodecolchangedata(self.name,arow,fdata)]);
  end;
 end;  
end;
{
procedure tifiwidgetcol.setdata(var arow: integer; const source;
               const noinvalidate: boolean = false);
begin
 inherited;
 datachange(arow);
end;
}
{ trxwidgetgrid }

constructor trxwidgetgrid.create(aowner: tcomponent);
begin
 if fifi = nil then begin
  fifi:= tifiwidgetgridcontroller.create(self);
 end;
 inherited;
end;

destructor trxwidgetgrid.destroy;
begin
 inherited;
 fifi.free;
end;

procedure trxwidgetgrid.setifi(const avalue: tifiwidgetgridcontroller);
begin
 fifi.assign(avalue);
end;

procedure trxwidgetgrid.setactive(const avalue: boolean);
begin
 if avalue <> factive then begin
  if avalue then begin
//   if csloading in componentstate then begin
//    include(fistate,rws_openpending);
//   end
//   else begin
    try
     internalopen;
    except
     active:= false;
     raise;
    end;
    factive:= true;
//   end;
  end
  else begin
//   exclude(fistate,rws_openpending);
   internalclose;
   factive:= false;
  end;
 end;
end;

procedure trxwidgetgrid.loaded;
begin
 inherited;
 {
 if rws_openpending in fistate then begin
  exclude(fistate,rws_openpending);
  active:= true;
 end;
 }
 fifi.loaded;
end;

procedure trxwidgetgrid.internalopen;
var
 str1: string;
 po1: pchar;
begin
 with fifi do begin
  if cansend then begin
   inititemheader(str1,ik_requestopen,0,0,po1);
//   include(fistate,rws_openpending);
   if senddataandwait(str1,fdatasequence) and 
              (rws_datareceived in fistate) then begin
   end
   else begin
    sysutils.abort;
   end;
  end;
 end;
end;
{
procedure trxwidgetgrid.post;
begin
 with fifi do begin
  if cansend then begin
   senddata(encodegriddata(0));
  end;
 end;
end;
}
procedure trxwidgetgrid.internalclose;
begin
 rowcount:= 0;
end;

procedure trxwidgetgrid.docolmoved(const fromindex: integer;
               const toindex: integer);
begin
 inherited;
end;

procedure trxwidgetgrid.dorowsmoved(const fromindex: integer;
               const toindex: integer; const count: integer);
begin
 inherited;
 with fifi do begin
  if cancommandsend(igo_rowmove) then begin
   senditem(ik_gridcommand,[
       encodegridcommanddata(gck_moverow,fromindex,toindex,count)]);
  end;
 end;
end;

procedure trxwidgetgrid.dorowsinserted(const index: integer;
               const count: integer);
begin
 inherited;
 with fifi do begin
  if cancommandsend(igo_rowinsert) then begin
   senditem(ik_gridcommand,[
       encodegridcommanddata(gck_insertrow,index,index,count)]);
  end;
 end;
end;

procedure trxwidgetgrid.dorowsdeleted(index: integer; count: integer);
begin
 inherited;
 with fifi do begin
  if cancommandsend(igo_rowdelete) then begin
   senditem(ik_gridcommand,[
       encodegridcommanddata(gck_deleterow,index,index,count)]);
  end;
 end;
end;

procedure trxwidgetgrid.rowstatechanged(const arow: integer);
begin
 inherited;
 with fifi do begin
  if cancommandsend(igo_rowstate) then begin
   senditem(ik_rowstatechange,
               encoderowstatedata(arow,fdatacols.rowstate.itemscolmerge[arow]));
  end;
 end;
end;

procedure trxwidgetgrid.setselected(const cell: gridcoordty;
                                       const avalue: boolean);
begin
 inherited;
 with fifi do begin
  if cancommandsend(igo_selection) then begin
   senditem(ik_selection,encodeselectiondata(cell,avalue));
  end;
 end;
end;

procedure trxwidgetgrid.docellevent(var info: celleventinfoty);
begin
 inherited;
 if isrowenter(info) and fifi.cancommandsend(igo_rowenter) then begin
  fifi.senditem(ik_gridcommand,[
       encodegridcommanddata(gck_rowenter,info.cell.row,info.cell.row,0)]);
 end;
end;

procedure trxwidgetgrid.createdatacol(const index: integer; out item: tdatacol);
begin
 item:= tifiwidgetcol.create(self,fdatacols);
end;

procedure trxwidgetgrid.connectmodule(const sender: tcustommodulelink);
begin
 fifi.connectmodule(sender);
end;

procedure trxwidgetgrid.setactive1(const avalue: boolean);
begin
 if fifi.setactive(avalue) then begin
  setactive(avalue);
 end;
end;

end.
