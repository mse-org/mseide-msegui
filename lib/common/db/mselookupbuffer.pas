unit mselookupbuffer;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface

uses
 classes,db,msedb,msetypes,msestrings,mseclasses,msearrayprops,mselist,msegui;
 
type
 
 tcustomlookupbuffer = class;
 tcustomdblookupbuffer = class;
 
 lbfiltereventty = procedure(const sender: tcustomlookupbuffer; 
                    const physindex: integer; var valid: boolean) of object;
                    
 tlookupbufferdatalink = class(tmsedatalink)
  private
   fowner: tcustomlookupbuffer;
  public
   constructor create(const aowner: tcustomlookupbuffer);
 end;
 
 tlookupbufferfieldsdatalink = class(tlookupbufferdatalink)
  private
   procedure datachanged;
  protected
   procedure activechanged; override;
   procedure updatedata; override;
   procedure dataevent(event: tdataevent; info: ptrint); override;
  public
   constructor create(const aowner: tcustomdblookupbuffer);
 end;
 
 tlookupbuffermemodatalink = class(tlookupbufferdatalink)
  protected
   procedure recordchanged(field: tfield); override;
 end;
 
 stringindexinfoty = record
  indexcasesensitive: integerarty;
  indexcaseinsensitive: integerarty;
  data: msestringarty;
 end;
 stringindexinfoarty = array of stringindexinfoty;
 
 integerindexinfoty = record
  index: integerarty;
  data: integerarty;
 end;
 integerindexinfoarty = array of integerindexinfoty;
 
 floatindexinfoty = record
  index: integerarty;
  data: realarty;
 end;
 floatindexinfoarty = array of floatindexinfoty;

 lookupbufferstatety = (lbs_changed,lbs_buffervalid,lbs_changeeventposted);
 lookupbufferstatesty = set of lookupbufferstatety;

const
 changeeventtag = 85839;
type   
 tcustomlookupbuffer = class(tguicomponent)
  private
 //  fbuffervalid: boolean;
   fonchange: notifyeventty;
   procedure checkindex(const index: integer);
   function internalfind(const avalue; var index: integerarty;
                var data; const itemsize: integer;
                compfunc: arraysortcomparety; const filter: lbfiltereventty;
                out aindex: integer): boolean;//true if exact else next bigger
  protected
   fupdating: integer;
   fcount: integer;
   fstate: lookupbufferstatesty;
   ftextdata: stringindexinfoarty;
   fintegerdata: integerindexinfoarty;
   ffloatdata: floatindexinfoarty;
   function getfieldcounttext: integer; virtual;
   function getfieldcountinteger: integer; virtual;
   function getfieldcountfloat: integer; virtual;
   procedure setfieldcounttext(const avalue: integer); virtual;
   procedure setfieldcountinteger(const avalue: integer); virtual;
   procedure setfieldcountfloat(const avalue: integer); virtual;
   procedure loadbuffer; virtual;
   procedure invalidatebuffer;
   procedure readonlyprop;
   procedure changed;
   procedure asyncchanged; //calls changed by postevent
   procedure doasyncevent(var atag: integer); override;
   procedure setcount(const avalue: integer);
   procedure loaded; override;
   function checkfilter(const filter: lbfiltereventty; 
                     const index: integerarty; var aindex: integer): boolean;
   procedure checkindexar(var aitem: integerindexinfoty); overload;
   procedure checkindexar(var aitem: floatindexinfoty); overload;
   procedure checkindexar(var aitem: stringindexinfoty;
                       const caseinsensitive: boolean); overload;
   procedure checkarrayindex(const value; const index: integer);
                   //calls checkbuffer
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure beginupdate;
   procedure endupdate;
   procedure clearbuffer; virtual;
   procedure checkbuffer; //automatically called

   function find(const fieldno: integer; const avalue: integer;
         out aindex: integer; const filter: lbfiltereventty = nil): boolean; overload;
              //logical index, true if found else next bigger
   function find(const fieldno: integer; const avalue: realty;
                 out aindex: integer; const filter: lbfiltereventty = nil): boolean; overload;
              //logical index, true if found else next bigger
   function find(const fieldno: integer; const avalue: msestring;
                 out aindex: integer;
                 const caseinsensitive: boolean;
                 const filter: lbfiltereventty = nil): boolean; overload;
              //logical index, true if found else next bigger

   function findphys(const fieldno: integer; const avalue: integer;
         out aindex: integer; const filter: lbfiltereventty = nil): boolean; overload;
              //physical index, true if found else next bigger
   function findphys(const fieldno: integer; const avalue: realty;
                 out aindex: integer; const filter: lbfiltereventty = nil): boolean; overload;
              //physical index, true if found else next bigger
   function findphys(const fieldno: integer; const avalue: msestring;
                 out aindex: integer;
                 const caseinsensitive: boolean;
                 const filter: lbfiltereventty = nil): boolean; overload;
              //physical index, true if found else next bigger

   function integervaluephys(const fieldno,aindex: integer): integer;
              //physical index
   function integervaluelog(const fieldno,aindex: integer): integer;
              //logical index
   function integerindex(const fieldno,aindex: integer): integer;
              //logical -> physical index
   function integerindexar(const fieldno: integer): integerarty;
   function integerar(const fieldno: integer): integerarty;
   
   function floatvaluephys(const fieldno,aindex: integer): realty;
              //physical index
   function floatvaluelog(const fieldno,aindex: integer): realty;
              //logical index
   function floatindex(const fieldno,aindex: integer): integer;
              //logical -> physical index
   function floatindexar(const fieldno: integer): integerarty;
   function floatar(const fieldno: integer): realarty;
   
   function textvaluephys(const fieldno,aindex: integer): msestring;
              //physical index
   function textvaluelog(const fieldno,aindex: integer;
                       const caseinsensitive: boolean): msestring;
              //logical index
   function textindex(const fieldno,aindex: integer;
                      const caseinsensitive: boolean): integer;
              //logical -> physical index
   function textindexar(const fieldno: integer;
                            const caseinsensitive: boolean): integerarty;
   function textar(const fieldno: integer): msestringarty;
   
   function lookupinteger(const integerkeyfieldno,integerfieldno,
                                keyvalue: integer): integer; overload;
                           //0 if not found
   function lookupinteger(const stringkeyfieldno,integerfieldno: integer;
                         const keyvalue: msestring): integer; overload;
                           //0 if not found
   function lookuptext(const integerkeyfieldno,textfieldno,
                                keyvalue: integer): msestring; overload;
                           //'' if not found
   function lookuptext(const stringkeyfieldno,textfieldno: integer;
                      const keyvalue: msestring): msestring; overload;
                           //'' if not found
   function lookupfloat(const integerkeyfieldno,floatfieldno,
                                keyvalue: integer): realty; overload;
                           //emptyreal if not found
   function lookupfloat(const stringkeyfieldno,floatfieldno: integer;
                                keyvalue: msestring): realty; overload;
                           //emptyreal if not found
                           
   function count: integer; virtual;
   property fieldcounttext: integer read getfieldcounttext
                                        write setfieldcounttext;
   property fieldcountfloat: integer read getfieldcountfloat
                                        write setfieldcountfloat;
   property fieldcountinteger: integer read getfieldcountinteger 
                                        write setfieldcountinteger;
   property integervalue[const fieldno,aindex: integer]: integer 
                                   read integervaluephys;
   property floatvalue[const fieldno,aindex: integer]: realty 
                                   read floatvaluephys;
   property textvalue[const fieldno,aindex: integer]: msestring 
                                   read textvaluephys;
   property onchange: notifyeventty read fonchange write fonchange;
 end;

 tlookupbuffer = class(tcustomlookupbuffer)
  public
   procedure addrow(const integervalues: array of integer;
                    const textvalues: array of msestring;
                    const floatvalues: array of realty);
   procedure addrows(const integervalues: array of integerarty;
                    const textvalues: array of msestringarty;
                    const floatvalues: array of realarty);
  published
   property fieldcounttext;
   property fieldcountinteger;
   property fieldcountfloat;
   property onchange;
 end;

 tdatalookupbuffer = class(tcustomlookupbuffer)
  protected
   procedure loaded; override;
   procedure setfieldcounttext(const avalue: integer); override;
   procedure setfieldcountinteger(const avalue: integer); override;
   procedure setfieldcountfloat(const avalue: integer); override;
   procedure fieldschanged(const sender: tarrayprop; const index: integer);
  public
   function count: integer; override;
 end;
  
 lbdboptionty = (olbdb_closedataset,olbdb_invalidateifmodified);
 lbdboptionsty = set of lbdboptionty; 
 
 tcustomdblookupbuffer = class(tdatalookupbuffer)
  private
   fdatalink: tlookupbufferdatalink;
   ftextfields: tdbfieldnamearrayprop;
   fintegerfields: tdbfieldnamearrayprop;
   ffloatfields: tdbfieldnamearrayprop;
   foptionsdb: lbdboptionsty;
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
   procedure settextfields(const avalue: tdbfieldnamearrayprop);
   procedure setintegerfields(const avalue: tdbfieldnamearrayprop);
   procedure setfloatfields(const avalue: tdbfieldnamearrayprop);
   procedure getfields(out aintegerfields,atextfields,afloatfields: fieldarty);
  protected
   function getfieldcounttext: integer; override;
   function getfieldcountinteger: integer; override;
   function getfieldcountfloat: integer; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clearbuffer; override;
   property datasource: tdatasource read getdatasource write setdatasource;
   property textfields: tdbfieldnamearrayprop read ftextfields write settextfields;
   property integerfields: tdbfieldnamearrayprop read fintegerfields write setintegerfields;
   property floatfields: tdbfieldnamearrayprop read ffloatfields write setfloatfields;
   property optionsdb: lbdboptionsty read foptionsdb write foptionsdb default [];
 end;
   
 tdblookupbuffer = class(tcustomdblookupbuffer)
  protected
   procedure loadbuffer; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property onchange;
   property datasource;
   property textfields;
   property integerfields;
   property floatfields;
   property optionsdb;
 end;
  
 tdbmemolookupbuffer = class(tcustomdblookupbuffer)
  protected
   procedure loadbuffer; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property onchange;
   property datasource;
   property textfields;
   property integerfields;
   property floatfields;
 end;
  
implementation
uses
 msedatalist,rtlconsts,sysutils,msereal;
 
type 
 tarrayprop1 = class(tarrayprop);
 
{ tcustomlookupbuffer }

constructor tcustomlookupbuffer.create(aowner: tcomponent);
begin
 inherited;
end;

destructor tcustomlookupbuffer.destroy;
begin
 inherited;
end;

procedure tcustomlookupbuffer.invalidatebuffer;
begin
 exclude(fstate,lbs_buffervalid);
// fbuffervalid:= false;
end;

procedure tcustomlookupbuffer.clearbuffer;
var
 int1: integer;
begin
 for int1:= 0 to high(fintegerdata) do begin
  with fintegerdata[int1] do begin
   index:= nil;
   data:= nil;
  end;
 end;
 for int1:= 0 to high(ftextdata) do begin
  with ftextdata[int1] do begin
   indexcasesensitive:= nil;
   indexcaseinsensitive:= nil;
   data:= nil;
  end;
 end;
 for int1:= 0 to high(ffloatdata) do begin
  with ffloatdata[int1] do begin
   index:= nil;
   data:= nil;
  end;
 end;
 fcount:= 0;
 exclude(fstate,lbs_buffervalid);
// fbuffervalid:= false;
 changed;
end;

procedure tcustomlookupbuffer.loadbuffer;
begin
 include(fstate,lbs_buffervalid);
// fbuffervalid:= true;
end;

procedure tcustomlookupbuffer.checkbuffer;
begin
 if not (lbs_buffervalid in fstate) then begin
  loadbuffer;
 end;
end;

function tcustomlookupbuffer.checkfilter(const filter: lbfiltereventty; 
          const index: integerarty; var aindex: integer): boolean;
var
 int1: integer;
 bo1: boolean;
begin
 for int1:= aindex to high(index) do begin
  bo1:= true;
  filter(self,index[int1],bo1);
  if bo1 then begin
   aindex:= int1;
   result:= true;
   exit;
  end;
 end;
 result:= false;
 aindex:= length(index);
end;

function tcustomlookupbuffer.internalfind(const avalue; var index: integerarty;
                var data; const itemsize: integer;
                compfunc: arraysortcomparety; const filter: lbfiltereventty;
                out aindex: integer): boolean; //true if found else next bigger
var
 int1: integer;
 bo1: boolean;
begin
 result:= findarrayvalue(avalue,data,index,compfunc,itemsize,aindex);
 if assigned(filter) then begin
  if result then begin
   result:= false;
   for int1:= aindex downto 0 do begin
    if compfunc((pchar(data)+index[int1]*itemsize)^,avalue) <> 0 then begin
     break; //not found
    end;
    bo1:= true;
    filter(self,index[int1],bo1);
    if bo1 then begin
     result:= true;
     aindex:= int1;
     break;
    end;
   end;
  end;
  if aindex <= high(index) then begin
   for int1:= aindex to high(index) do begin
    bo1:= true;
    filter(self,index[int1],bo1);
    if bo1 then begin
     aindex:= int1;
     exit;
    end;
   end;
   aindex:= length(index);
  end;
 end;
end;

procedure tcustomlookupbuffer.checkindexar(var aitem: integerindexinfoty);
begin
 with aitem do begin
  if (index = nil) and (data <> nil) then begin
   application.beginwait;
   try
    quicksortarray(data,@compareinteger,sizeof(integer),length(data),
                      false,index);
   finally
    application.endwait;
   end;
  end;
 end;
end;

function tcustomlookupbuffer.find(const fieldno: integer; const avalue: integer;
             out aindex: integer; const filter: lbfiltereventty = nil): boolean;
begin
// checkbuffer;
 checkarrayindex(fintegerdata,fieldno);
 checkindexar(fintegerdata[fieldno]);
 with fintegerdata[fieldno] do begin
  result:= internalfind(avalue,index,data,sizeof(integer),
                                     @compareinteger,filter,aindex);
 end;
end;

procedure tcustomlookupbuffer.checkindexar(var aitem: floatindexinfoty);
begin
 with aitem do begin
  if (index = nil) and (data <> nil) then begin
   application.beginwait;
   try
    quicksortarray(data,@comparerealty,sizeof(realty),length(data),
                      false,index);
   finally
    application.endwait;
   end;
  end;
 end;
end;

function tcustomlookupbuffer.find(const fieldno: integer; const avalue: realty;
           out aindex: integer; const filter: lbfiltereventty = nil): boolean;
begin
// checkbuffer;
 checkarrayindex(ffloatdata,fieldno);
 checkindexar(ffloatdata[fieldno]);
 with ffloatdata[fieldno] do begin
  result:= internalfind(avalue,index,data,sizeof(realty),
                        @comparerealty,filter,aindex);
 end;
end;

procedure tcustomlookupbuffer.checkindexar(var aitem: stringindexinfoty;
                                          const caseinsensitive: boolean);
begin
 with aitem do begin
  if caseinsensitive then begin
   if (indexcaseinsensitive = nil) and (data <> nil) then begin
    application.beginwait;
    try
     quicksortarray(data,@compareimsestring,sizeof(msestring),length(data),
                       false,indexcaseinsensitive);
    finally
     application.endwait;
    end;
   end;
  end
  else begin
   if (indexcasesensitive = nil) and (data <> nil) then begin
    application.beginwait;
    try
     quicksortarray(data,@comparemsestring,sizeof(msestring),length(data),
                       false,indexcasesensitive);
    finally
     application.endwait;
    end;
   end;
  end;
 end;
end;

function tcustomlookupbuffer.find(const fieldno: integer; const avalue: msestring;
                        out aindex: integer; const caseinsensitive: boolean;
                             const filter: lbfiltereventty = nil): boolean;
var
 int1: integer;
begin
// checkbuffer;
 checkarrayindex(ftextdata,fieldno);
 checkindexar(ftextdata[fieldno],caseinsensitive);
 with ftextdata[fieldno] do begin
  if caseinsensitive then begin  
   result:= internalfind(avalue,indexcaseinsensitive,data,sizeof(msestring),
                         @compareimsestring,filter,aindex);
  end
  else begin
   result:= internalfind(avalue,indexcasesensitive,data,sizeof(msestring),
                         @comparemsestring,filter,aindex);
  end;
 end;
end;

function tcustomlookupbuffer.findphys(const fieldno: integer; const avalue: integer;
         out aindex: integer; const filter: lbfiltereventty = nil): boolean; overload;
              //physical index, true if found else next bigger
var
 int1: integer;
begin
 result:= find(fieldno,avalue,int1,filter);
 if result then begin
  aindex:= integerindex(fieldno,int1);
 end
 else begin
  aindex:= -1;
 end;
end;

function tcustomlookupbuffer.findphys(const fieldno: integer; const avalue: realty;
                 out aindex: integer; const filter: lbfiltereventty = nil): boolean; overload;
              //physical index, true if found else next bigger
var
 int1: integer;
begin
 result:= find(fieldno,avalue,int1,filter);
 if result then begin
  aindex:= floatindex(fieldno,int1);
 end
 else begin
  aindex:= -1;
 end;
end;

function tcustomlookupbuffer.findphys(const fieldno: integer; const avalue: msestring;
                 out aindex: integer;
                 const caseinsensitive: boolean;
                 const filter: lbfiltereventty = nil): boolean; overload;
              //physical index, true if found else next bigger
var
 int1: integer;
begin
 result:= find(fieldno,avalue,int1,caseinsensitive,filter);
 if result then begin
  aindex:= textindex(fieldno,int1,caseinsensitive);
 end
 else begin
  aindex:= -1;
 end;
end;

procedure tcustomlookupbuffer.checkindex(const index: integer);
begin
 if (index < 0) or (index >= fcount) then begin
  tlist.Error(SListIndexError, Index);
 end;  
end;

function tcustomlookupbuffer.integervaluephys(const fieldno,aindex: integer): integer;
begin
 checkarrayindex(fintegerdata,fieldno);
 checkindex(aindex);
 result:= fintegerdata[fieldno].data[aindex];
end;

function tcustomlookupbuffer.integervaluelog(const fieldno,aindex: integer): integer;
begin
 checkarrayindex(fintegerdata,fieldno);
 checkindexar(fintegerdata[fieldno]);
 checkindex(aindex);
 with fintegerdata[fieldno] do begin
  result:= data[index[aindex]];
 end;
end;

function tcustomlookupbuffer.integerindex(const fieldno,aindex: integer): integer;
begin
 checkarrayindex(fintegerdata,fieldno);
 checkindexar(fintegerdata[fieldno]);
 checkindex(aindex);
 result:= fintegerdata[fieldno].index[aindex];
end;

function tcustomlookupbuffer.integerindexar(const fieldno: integer): integerarty;
begin
 checkarrayindex(fintegerdata,fieldno);
 checkindexar(fintegerdata[fieldno]);
 result:= fintegerdata[fieldno].index;
end;

function tcustomlookupbuffer.integerar(const fieldno: integer): integerarty;
begin
 checkarrayindex(fintegerdata,fieldno);
 result:= fintegerdata[fieldno].data;
end;

function tcustomlookupbuffer.floatvaluephys(const fieldno,aindex: integer): realty;
begin
 checkarrayindex(ffloatdata,fieldno);
 checkindex(aindex);
 result:= ffloatdata[fieldno].data[aindex];
end;

function tcustomlookupbuffer.floatvaluelog(const fieldno,aindex: integer): realty;
begin
 checkarrayindex(ffloatdata,fieldno);
 checkindexar(ffloatdata[fieldno]);
 checkindex(aindex);
 with ffloatdata[fieldno] do begin
  result:= data[index[aindex]];
 end;
end;

function tcustomlookupbuffer.floatindex(const fieldno,aindex: integer): integer;
begin
 checkarrayindex(ffloatdata,fieldno);
 checkindexar(ffloatdata[fieldno]);
 checkindex(aindex);
 result:= ffloatdata[fieldno].index[aindex];
end;

function tcustomlookupbuffer.floatindexar(const fieldno: integer): integerarty;
begin
 checkarrayindex(ffloatdata,fieldno);
 checkindexar(ffloatdata[fieldno]);
 result:= ffloatdata[fieldno].index;
end;

function tcustomlookupbuffer.floatar(const fieldno: integer): realarty;
begin
 checkarrayindex(ffloatdata,fieldno);
 result:= ffloatdata[fieldno].data;
end;

function tcustomlookupbuffer.textvaluephys(const fieldno,aindex: integer): msestring;
begin
 checkarrayindex(ftextdata,fieldno);
 checkindex(aindex);
 result:= ftextdata[fieldno].data[aindex];
end;

function tcustomlookupbuffer.textvaluelog(const fieldno,aindex: integer;
          const caseinsensitive: boolean): msestring;
begin
 checkarrayindex(ftextdata,fieldno);
 checkindexar(ftextdata[fieldno],caseinsensitive);
 checkindex(aindex);
 with ftextdata[fieldno] do begin
  if caseinsensitive then begin
   result:= data[indexcaseinsensitive[aindex]];
  end
  else begin
   result:= data[indexcasesensitive[aindex]];
  end;
 end;
end;

function tcustomlookupbuffer.textindex(const fieldno,aindex: integer;
                                 const caseinsensitive: boolean): integer;
begin
 checkarrayindex(ftextdata,fieldno);
 checkindexar(ftextdata[fieldno],caseinsensitive);
 checkindex(aindex);
 with ftextdata[fieldno] do begin
  if caseinsensitive then begin
   result:= indexcaseinsensitive[aindex];
  end
  else begin
   result:= indexcasesensitive[aindex];
  end;
 end;
end;

function tcustomlookupbuffer.textindexar(const fieldno: integer;
                            const caseinsensitive: boolean): integerarty;
begin
 checkarrayindex(ftextdata,fieldno);
 checkindexar(ftextdata[fieldno],caseinsensitive);
 if caseinsensitive then begin
  result:= ftextdata[fieldno].indexcaseinsensitive;
 end
 else begin
  result:= ftextdata[fieldno].indexcasesensitive;
 end;
end;

function tcustomlookupbuffer.textar(const fieldno: integer): msestringarty;
begin
 checkarrayindex(ftextdata,fieldno);
 result:= ftextdata[fieldno].data;
end;

function tcustomlookupbuffer.count: integer;
begin
 result:= fcount;
end;

function tcustomlookupbuffer.getfieldcounttext: integer;
begin
 result:= length(ftextdata);
end;

procedure tcustomlookupbuffer.setfieldcounttext(const avalue: integer);
begin
 clearbuffer;
 setlength(ftextdata,avalue);
end;

function tcustomlookupbuffer.getfieldcountinteger: integer;
begin
 result:= length(fintegerdata);
end;

procedure tcustomlookupbuffer.setfieldcountinteger(const avalue: integer);
begin
 clearbuffer;
 setlength(fintegerdata,avalue);
end;

function tcustomlookupbuffer.getfieldcountfloat: integer;
begin
 result:= length(ffloatdata);
end;

procedure tcustomlookupbuffer.setfieldcountfloat(const avalue: integer);
begin
 clearbuffer;
 setlength(ffloatdata,avalue);
end;

procedure tcustomlookupbuffer.readonlyprop;
begin
 raise exception.create('Property is readonly');
end;

procedure tcustomlookupbuffer.beginupdate;
begin
 inc(fupdating);
end;

procedure tcustomlookupbuffer.endupdate;
begin
 dec(fupdating);
 if fupdating = 0 then begin
  changed;
 end;
end;

procedure tcustomlookupbuffer.changed;
begin
 if fupdating = 0 then begin
  if csloading in componentstate then begin
   include(fstate,lbs_changed);
  end
  else begin
   exclude(fstate,lbs_changed);
   sendchangeevent;
   if canevent(tmethod(fonchange)) then begin
    inc(fupdating);
    try
     fonchange(self);
    finally
     dec(fupdating);
    end;
   end;
  end;
 end;
end;

procedure tcustomlookupbuffer.doasyncevent(var atag: integer);
begin
 inherited;
 if atag = changeeventtag then begin
  exclude(fstate,lbs_changeeventposted);
  changed;
 end;
end;

procedure tcustomlookupbuffer.asyncchanged;
begin
 if not (lbs_changeeventposted in fstate) then begin
  include(fstate,lbs_changeeventposted);
  asyncevent(changeeventtag);
 end;
end;

procedure tcustomlookupbuffer.setcount(const avalue: integer);
var
 int1: integer;
begin
 if avalue <> fcount then begin
  for int1:= 0 to high(fintegerdata) do begin
   with fintegerdata[int1] do begin
    setlength(data,avalue);
    index:= nil;
   end;
  end;
  for int1:= 0 to high(ftextdata) do begin
   with ftextdata[int1] do begin
    setlength(data,avalue);
    indexcasesensitive:= nil;
    indexcaseinsensitive:= nil;
   end;
  end; 
  for int1:= 0 to high(ffloatdata) do begin
   with ffloatdata[int1] do begin
    setlength(data,avalue);
    index:= nil;
   end;
  end;
  fcount:= avalue;
  exclude(fstate,lbs_buffervalid);
 end;
end;

procedure tcustomlookupbuffer.loaded;
begin
 inherited;
 if not (lbs_buffervalid in fstate) or (lbs_changed in fstate) then begin
  changed;
 end;
end;

function tcustomlookupbuffer.lookupinteger(const integerkeyfieldno,integerfieldno,
                                keyvalue: integer): integer;
                           //0 if not found
var
 int1: integer;
begin
 if findphys(integerkeyfieldno,keyvalue,int1) then begin
  result:= integervaluephys(integerfieldno,int1);
 end
 else begin
  result:= 0;
 end;
end;

function tcustomlookupbuffer.lookupinteger(const stringkeyfieldno: integer;
               const integerfieldno: integer;
               const keyvalue: msestring): integer;
var
 int1: integer;
begin
 if findphys(stringkeyfieldno,keyvalue,int1,false) then begin
  result:= integervaluephys(integerfieldno,int1);
 end
 else begin
  result:= 0;
 end;
end;

function tcustomlookupbuffer.lookuptext(const integerkeyfieldno: integer;
               const textfieldno: integer; const keyvalue: integer): msestring;
var
 int1: integer;
begin
 if findphys(integerkeyfieldno,keyvalue,int1) then begin
  result:= textvaluephys(textfieldno,int1);
 end
 else begin
  result:= '';
 end;
end;

function tcustomlookupbuffer.lookuptext(const stringkeyfieldno: integer;
               const textfieldno: integer;
               const keyvalue: msestring): msestring;
var
 int1: integer;
begin
 if findphys(stringkeyfieldno,keyvalue,int1,false) then begin
  result:= textvaluephys(textfieldno,int1);
 end
 else begin
  result:= '';
 end;
end;

function tcustomlookupbuffer.lookupfloat(const integerkeyfieldno: integer;
               const floatfieldno: integer; const keyvalue: integer): realty;
var
 int1: integer;
begin
 if findphys(integerkeyfieldno,keyvalue,int1) then begin
  result:= floatvaluephys(floatfieldno,int1);
 end
 else begin
  result:= emptyreal;
 end;
end;


function tcustomlookupbuffer.lookupfloat(const stringkeyfieldno: integer;
               const floatfieldno: integer; keyvalue: msestring): realty;
var
 int1: integer;
begin
 if findphys(stringkeyfieldno,keyvalue,int1,false) then begin
  result:= floatvaluephys(floatfieldno,int1);
 end
 else begin
  result:= emptyreal;
 end;
end;

procedure tcustomlookupbuffer.checkarrayindex(const value;
               const index: integer);
begin
 checkbuffer;
 msedatalist.checkarrayindex(value,index);
end;

{ tlookupbuffer }

procedure tlookupbuffer.addrow(const integervalues: array of integer;
              const textvalues: array of msestring;
              const floatvalues: array of realty);
var
 int1: integer;
begin
 setcount(fcount + 1);
 for int1:= 0 to high(integervalues) do begin
  if int1 > high(fintegerdata) then begin
   break;
  end;
  fintegerdata[int1].data[fcount-1]:= integervalues[int1];
 end;
 for int1:= 0 to high(textvalues) do begin
  if int1 > high(ftextdata) then begin
   break;
  end;
  ftextdata[int1].data[fcount-1]:= textvalues[int1];
 end;
 for int1:= 0 to high(floatvalues) do begin
  if int1 > high(ffloatdata) then begin
   break;
  end;
  ffloatdata[int1].data[fcount-1]:= floatvalues[int1];
 end;
 changed;
end;

procedure tlookupbuffer.addrows(const integervalues: array of integerarty;
              const textvalues: array of msestringarty;
              const floatvalues: array of realarty);
var
 int1,int2,int3,countbefore: integer;
begin
 int2:= bigint;
 for int1:= 0 to high(integervalues) do begin
  if high(integervalues[int1]) < int2 then begin
   int2:= high(integervalues[int1]);
  end;
 end;
 for int1:= 0 to high(textvalues) do begin
  if high(textvalues[int1]) < int2 then begin
   int2:= high(textvalues[int1]);
  end;
 end;
 for int1:= 0 to high(floatvalues) do begin
  if high(floatvalues[int1]) < int2 then begin
   int2:= high(floatvalues[int1]);
  end;
 end;
 countbefore:= fcount;
 setcount(fcount+int2+1);
 for int1:= 0 to high(integervalues) do begin
  if int1 > high(fintegerdata) then begin
   break;
  end;
  for int3:= 0 to int2 do begin
   fintegerdata[int1].data[int3+countbefore]:= integervalues[int1][int3];
  end;
 end;
 for int1:= 0 to high(textvalues) do begin
  if int1 > high(ftextdata) then begin
   break;
  end;
  for int3:= 0 to int2 do begin
   ftextdata[int1].data[int3+countbefore]:= textvalues[int1][int3];
  end;
 end;
 for int1:= 0 to high(floatvalues) do begin
  if int1 > high(ffloatdata) then begin
   break;
  end;
  for int3:= 0 to int2 do begin
   ffloatdata[int1].data[int3+countbefore]:= floatvalues[int1][int3];
  end;
 end;
end;

{ tdatalokupbuffer }

procedure tdatalookupbuffer.loaded;
begin
 if not (lbs_buffervalid in fstate) then begin
  clearbuffer;
 end;
 inherited;
end;

procedure tdatalookupbuffer.setfieldcountinteger(const avalue: integer);
begin
 readonlyprop;
end;

procedure tdatalookupbuffer.setfieldcountfloat(const avalue: integer);
begin
 readonlyprop;
end;

procedure tdatalookupbuffer.setfieldcounttext(const avalue: integer);
begin
 readonlyprop;
end;

function tdatalookupbuffer.count: integer;
begin
 checkbuffer;
 result:= inherited count;
end;

procedure tdatalookupbuffer.fieldschanged(const sender: tarrayprop;
                 const index: integer);
begin
 invalidatebuffer;
end;

{ tlookupbufferdatalink }

constructor tlookupbufferdatalink.create(const aowner: tcustomlookupbuffer);
begin
 fowner:= aowner;
 inherited create;
end;

{ tcustomdblookupbuffer }

constructor tcustomdblookupbuffer.create(aowner: tcomponent);
begin
 if fdatalink = nil then begin
  fdatalink:= tlookupbufferdatalink.create(self);
 end;
 fintegerfields:= tdbfieldnamearrayprop.create(
                   msedb.integerfields+[ftboolean],
                      {$ifdef FPC}@{$endif}getdatasource);
 ftextfields:= tdbfieldnamearrayprop.create(
                   msedb.textfields+[ftboolean],
                  {$ifdef FPC}@{$endif}getdatasource);
 ffloatfields:= tdbfieldnamearrayprop.create(msedb.realfields + msedb.datetimefields,
                      {$ifdef FPC}@{$endif}getdatasource);
 fintegerfields.onchange:= @fieldschanged;
 ftextfields.onchange:= @fieldschanged;
 ffloatfields.onchange:= @fieldschanged;
 inherited;
end;

destructor tcustomdblookupbuffer.destroy;
begin
 inherited;
 fdatalink.free;
 fintegerfields.free;
 ftextfields.free;
 ffloatfields.free;
end;

function tcustomdblookupbuffer.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tcustomdblookupbuffer.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

procedure tcustomdblookupbuffer.setintegerfields(const avalue: tdbfieldnamearrayprop);
begin
 fintegerfields.assign(avalue);
end;

procedure tcustomdblookupbuffer.setfloatfields(const avalue: tdbfieldnamearrayprop);
begin
 ffloatfields.assign(avalue);
end;

procedure tcustomdblookupbuffer.settextfields(const avalue: tdbfieldnamearrayprop);
begin
 ftextfields.assign(avalue);
end;

procedure tcustomdblookupbuffer.clearbuffer;
begin
 setlength(fintegerdata,fintegerfields.count);
 setlength(ftextdata,ftextfields.count);
 setlength(ffloatdata,ffloatfields.count);
 inherited;
end;

function tcustomdblookupbuffer.getfieldcounttext: integer;
begin
 result:= ftextfields.count;
end;

function tcustomdblookupbuffer.getfieldcountinteger: integer;
begin
 result:= fintegerfields.count;
end;

function tcustomdblookupbuffer.getfieldcountfloat: integer;
begin
 result:= floatfields.count;
end;


procedure tcustomdblookupbuffer.getfields(out aintegerfields,atextfields,
        afloatfields: fieldarty);
var
 int1: integer;
begin
 with fdatalink.datasource.dataset do begin
  setlength(aintegerfields,fintegerfields.count);
  for int1:= 0 to high(aintegerfields) do begin
   aintegerfields[int1]:= fieldbyname(fintegerfields[int1]);
  end;
  setlength(atextfields,ftextfields.count);
  for int1:= 0 to high(atextfields) do begin
   atextfields[int1]:= fieldbyname(ftextfields[int1]);
  end;
  setlength(afloatfields,ffloatfields.count);
  for int1:= 0 to high(afloatfields) do begin
   afloatfields[int1]:= fieldbyname(ffloatfields[int1]);
  end;
 end;
end;

{ tlookupbufferfieldsdatalink }

constructor tlookupbufferfieldsdatalink.create(const aowner: tcustomdblookupbuffer);
begin
 inherited create(aowner);
end;

procedure tlookupbufferfieldsdatalink.datachanged;
begin
 with tcustomdblookupbuffer(fowner) do begin
  if active or 
    not active and (lbs_buffervalid in fstate) and 
                       not (olbdb_closedataset in foptionsdb) then begin
   exclude(fstate,lbs_buffervalid);
   asyncchanged;
  end;
 end;
end;

procedure tlookupbufferfieldsdatalink.activechanged;
begin
 inherited;
 datachanged;
end;

procedure tlookupbufferfieldsdatalink.updatedata;
begin
 inherited;
// if olbdb_invalidateonupdatedata in tcustomdblookupbuffer(fowner).foptionsdb then begin
//  datachanged;
// end;
end;

procedure tlookupbufferfieldsdatalink.dataevent(event: tdataevent; info: ptrint);
begin
 inherited;
 if (event = tdataevent(de_modified)) and 
           (olbdb_invalidateifmodified in 
                       tcustomdblookupbuffer(fowner).foptionsdb) then begin
  datachanged;
 end;
end;

{ tdblookupbuffer }

constructor tdblookupbuffer.create(aowner: tcomponent);
begin
 fdatalink:= tlookupbufferfieldsdatalink.create(self);
 inherited;
end;

procedure tdblookupbuffer.loadbuffer;
var
 int1,int3,int4: integer;
 bm: string;
 textf: array of tfield;
 integerf: array of tfield;
 realf: array of tfield;
 datas: tdataset;
 utf8: boolean;
 bo1: boolean;
 ismsestringfield: booleanarty;
begin
 beginupdate;
 try
  clearbuffer;
  datas:= fdatalink.dataset;
  include(fstate,lbs_buffervalid);
  if (datas <> nil) and 
       (datas.active or 
        (olbdb_closedataset in foptionsdb) {and
               not (csloading in datas.componentstate)}) then begin
//   fbuffervalid:= true; 
   utf8:= fdatalink.utf8;
   bo1:= fdatalink.active;
   application.beginwait;
   try
    datas.disablecontrols;
    try
     datas.active:= true;
     try
      bm:= datas.bookmark;
      try
       getfields(integerf,textf,realf);
       setlength(ismsestringfield,length(textf));
       for int1:= high(ismsestringfield) downto 0 do begin
        ismsestringfield[int1]:= textf[int1] is tmsestringfield;
       end;
       datas.first;
       int3:= 0;
       int1:= 0;
       try
        while not datas.eof do begin
         if int3 <= int1 then begin
          int3:= (int3 * 3) div 2 + 100;
          for int4:= 0 to high(ftextdata) do begin
           setlength(ftextdata[int4].data,int3);
          end;
          for int4:= 0 to high(fintegerdata) do begin
           setlength(fintegerdata[int4].data,int3);
          end;
          for int4:= 0 to high(ffloatdata) do begin
           setlength(ffloatdata[int4].data,int3);
          end;
         end;
         for int4:= 0 to high(integerf) do begin
          if integerf[int4] <> nil then begin
           fintegerdata[int4].data[int1]:= integerf[int4].asinteger;
          end;
         end;
         for int4:= 0 to high(realf) do begin
          if realf[int4] <> nil then begin
           if realf[int4].isnull then begin
            ffloatdata[int4].data[int1]:= emptyreal;
           end
           else begin
            ffloatdata[int4].data[int1]:= realf[int4].asfloat;
           end;
          end;
         end;
         for int4:= 0 to high(textf) do begin
          if textf[int4] <> nil then begin
           if ismsestringfield[int4] then begin
            ftextdata[int4].data[int1]:= tmsestringfield(textf[int4]).asmsestring;
           end
           else begin
            if utf8 then begin
             ftextdata[int4].data[int1]:= utf8tostring(textf[int4].asstring);
            end
            else begin
             ftextdata[int4].data[int1]:= textf[int4].asstring;
            end;
           end;
          end;
         end;
         inc(int1);
         datas.next;
        end;
       finally
        for int4:= 0 to high(fintegerdata) do begin
         setlength(fintegerdata[int4].data,int1);
        end;
        for int4:= 0 to high(ftextdata) do begin
         setlength(ftextdata[int4].data,int1);
        end;
        for int4:= 0 to high(ffloatdata) do begin
         setlength(ffloatdata[int4].data,int1);
        end;
        fcount:= int1;
       end;
      finally
       datas.bookmark:= bm;
      end;
     finally
      if not bo1 and (olbdb_closedataset in foptionsdb) then begin
       datas.active:= false;
      end;
     end;
    finally
     datas.enablecontrols;
    end;
   finally
    application.endwait;
   end;
  end;
 finally
  endupdate;
 end;
end;

{ tlookupbuffermemodatalink }

procedure tlookupbuffermemodatalink.recordchanged(field: tfield);
begin
 with fowner do begin
  if (fupdating = 0) and (lbs_buffervalid in fstate) then begin
   exclude(fstate,lbs_buffervalid);
//   fbuffervalid:= false;
   changed;
  end;
 end;
end;

{ tdbmemolookupbuffer }

constructor tdbmemolookupbuffer.create(aowner: tcomponent);
begin
 fdatalink:= tlookupbuffermemodatalink.create(self);
 inherited;
 fintegerfields.fieldtypes:= memofields + msedb.textfields;
 ftextfields.fieldtypes:= memofields + msedb.textfields;
 ffloatfields.fieldtypes:= memofields + msedb.textfields;
end;

procedure tdbmemolookupbuffer.loadbuffer;
var
 textf: array of tfield;
 integerf: array of tfield;
 realf: array of tfield;
 ar3: stringarty;
 int1,int2: integer;
 utf8: boolean;
begin
 beginupdate;
 try
  clearbuffer;
  if fdatalink.active then begin
   utf8:= fdatalink.utf8;
   getfields(integerf,textf,realf);
   for int1:= 0 to high(integerf) do begin
    if not integerf[int1].isnull then begin
     ar3:= breaklines(integerf[int1].asstring);
     setlength(fintegerdata[int1].data,length(ar3));
     for int2:= 0 to high(ar3) do begin
      fintegerdata[int1].data[int2]:= strtoint(ar3[int2]);
     end;
    end;
   end;
   for int1:= 0 to high(realf) do begin
    if not realf[int1].isnull then begin
     ar3:= breaklines(integerf[int1].asstring);
     setlength(ffloatdata[int1].data,length(ar3));
     for int2:= 0 to high(ar3) do begin
      ffloatdata[int1].data[int2]:= strtorealty(ar3[int2]);
     end;
    end;
   end;
   for int1:= 0 to high(textf) do begin
    if utf8 then begin
     ftextdata[int1].data:= breaklines(utf8tostring(textf[int1].asstring));
    end
    else begin
     ftextdata[int1].data:= breaklines(msestring(textf[int1].asstring));
    end;
   end;
   int2:= bigint;
   for int1:= 0 to high(fintegerdata) do begin
    if high(fintegerdata[int1].data) < int2 then begin
     int2:= high(fintegerdata[int1].data);
    end;
   end;
   for int1:= 0 to high(ffloatdata) do begin
    if high(ffloatdata[int1].data) < int2 then begin
     int2:= high(ffloatdata[int1].data);
    end;
   end;
   for int1:= 0 to high(ftextdata) do begin
    if high(ftextdata[int1].data) < int2 then begin
     int2:= high(ftextdata[int1].data);
    end;
   end;
   setcount(int2+1);
  end;
 finally
  include(fstate,lbs_buffervalid);
//  fbuffervalid:= true;
  endupdate;
 end;
end;

end.
