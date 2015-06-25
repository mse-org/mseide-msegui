{ MSEgui Copyright (c) 1999-2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msevaluenodes;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,msestrings,msedatalist,msedatanodes,msebitmap,mselistbrowser,
 msetypes,msevaluenodesglob,mseinterfaces;
type
 irecordfield = interface(inullinterface) [miid_irecordfield]
  function getfieldtext(const afieldindex: integer): msestring;
  procedure setfieldtext(const afieldindex: integer; var avalue: msestring);
 end;

 getvaluemethodty = procedure(out dest) of object;

 irecordvaluefield = interface(irecordfield) [miid_irecordvaluefield]
  procedure getvalueinfo(out avalues: recvaluearty; const aindex: int32 = -1);
                                                   //-1 -> all
  procedure setvalue(const atype: listdatatypety;
               const aindex: int32; const getvaluemethod: getvaluemethodty);
 end;
  
 trecordfielditem = class(ttreelistitem)
  private
   ffieldindex: integer;
   fintf: irecordfield;
  protected
  public
   constructor create(const intf: irecordfield; const afieldindex: integer;
                      const acaption: msestring;
                      const fixedcaption: boolean = false;
                      const aimagenr: integer = 0;
                      const aimagelist: timagelist = nil); reintroduce;
   function getvaluetext: msestring; override;
   procedure setvaluetext(var avalue: msestring); override;
   property fieldindex: integer read ffieldindex;
//   property valuetext: msestring read getvaluetext write setvaluetext;
 end;

 trecordfieldvalueitem = class(trecordfielditem,irecordvaluefield)
  protected
   function getfieldtext(const afieldindex: integer): msestring;
   procedure setfieldtext(const afieldindex: integer; var avalue: msestring);
   procedure getvalueinfo(out avalues: recvaluearty; const aindex: int32 = -1);
   procedure setvalue(const atype: listdatatypety;
               const aindex: int32; const getvaluemethod: getvaluemethodty);
  public
   constructor create(const intf: irecordvaluefield; const afieldindex: integer;
                      const acaption: msestring;
                      const fixedcaption: boolean = false;
                      const aimagenr: integer = 0;
                      const aimagelist: timagelist = nil);
 end;

 fieldinfoty = record
  datatype: listdatatypety;
  data: pointer;
 end;

//
// hint: irecordvaluefield can be slow
//
 trecordlistedititem = class(tlistedititem,irecordvaluefield)
  private
  protected
    //irecordvaluefield
   procedure getvalueinfo(out avalues: recvaluearty; const aindex: int32 = -1);
                                                                        virtual;
   function getfieldtext(const fieldindex: integer): msestring; virtual;
   procedure setfieldtext(const fieldindex: integer;
                                              var avalue: msestring); virtual;
   procedure setvalue(const atype: listdatatypety;
          const aindex: int32; const getvaluemethod: getvaluemethodty); virtual;
  public
 end;

 trecordtreelistedititem = class(ttreelistedititem,irecordvaluefield)   
                                          //does not statsave subitems
  protected
    //irecordvaluefield
   procedure getvalueinfo(out avalues: recvaluearty; const aindex: int32 = -1);
                                                                        virtual;
   function getfieldtext(const fieldindex: integer): msestring; virtual;
   procedure setfieldtext(const fieldindex: integer;
                                              var avalue: msestring); virtual;
   procedure setvalue(const atype: listdatatypety;
          const aindex: int32; const getvaluemethod: getvaluemethodty); virtual;
  public
   constructor create(const aowner: tcustomitemlist = nil;
              const aparent: ttreelistitem = nil); override;
 end;

{ 
 trecordtreelistedititem = class(tlistedititem,irecordvaluefield)
  private
  protected
   procedure initvalueinfo(out ainfo: recvaluety);
   procedure initvalueinfo(const aindex: int32; var avalue: int32;
                                                     out ainfo: recvaluety);
   procedure initvalueinfo(const aindex: int32; var avalue: longbool;
                                                     out ainfo: recvaluety);
   procedure initvalueinfo(const aindex: int32; var avalue: realty;
                                                     out ainfo: recvaluety);
   procedure initvalueinfo(const aindex: int32; var avalue: tdatetime;
                                                     out ainfo: recvaluety);
   procedure initvalueinfo(const aindex: int32; var avalue: msestring;
                                                     out ainfo: recvaluety);
    //irecordvaluefield
   procedure getvalueinfo(out avalues: recvaluearty); virtual;
   function getfieldtext(const fieldindex: integer): msestring; virtual;
   procedure setfieldtext(const fieldindex: integer;
                                              var avalue: msestring); virtual;
   procedure setvalue(const atype: listdatatypety;
          const aindex: int32; const getvaluemethod: getvaluemethodty); virtual;
  public
 end;
}
 trecordvaluelistedititem = class(trecordlistedititem)
  protected
   fvalueindex: int32;
   procedure getvalueinfo(out avalues: recvaluearty; const aindex: int32 = -1);
                                                                       override;
  public
   constructor create(const avalueindex: int32 = -1;
                               const aowner: tcustomitemlist = nil); virtual;
   property valueindex: int32 read fvalueindex write fvalueindex;
                             //-1 -> any
 end;
 
 tintegervaluelistedititem = class(trecordvaluelistedititem)
  private
   fvalue: int32;
   procedure setvalue(const avalue: int32);
  protected
   procedure getvalueinfo(out avalues: recvaluearty; const aindex: int32 = -1);
                                                                       override;
   procedure setvalue(const atype: listdatatypety;
       const aindex: int32; const getvaluemethod: getvaluemethodty); override;
  public
   property value: int32 read fvalue write setvalue;
 end;
  
 tbooleanvaluelistedititem = class(tintegervaluelistedititem)
  private
   procedure setvalue(const avalue: boolean); reintroduce;
   function getvalue: boolean;
  protected
  public
   property value: boolean read getvalue write setvalue;
 end;

 trealvaluelistedititem = class(trecordvaluelistedititem)
  private
   fvalue: realty;
   procedure setvalue(const avalue: realty);
  protected
   procedure getvalueinfo(out avalues: recvaluearty; const aindex: int32 = -1);
                                                                       override;
   procedure setvalue(const atype: listdatatypety;
       const aindex: int32; const getvaluemethod: getvaluemethodty); override;
  public
   property value: realty read fvalue write setvalue;
 end;

 tdatetimevaluelistedititem = class(trecordvaluelistedititem)
  private
   fvalue: tdatetime;
   procedure setvalue(const avalue: tdatetime);
  protected
   procedure getvalueinfo(out avalues: recvaluearty; const aindex: int32 = -1);
                                                                       override;
   procedure setvalue(const atype: listdatatypety;
       const aindex: int32; const getvaluemethod: getvaluemethodty); override;
  public
   property value: tdatetime read fvalue write setvalue;
 end;

 tstringvaluelistedititem = class(trecordvaluelistedititem)
  private
   fvalue: msestring;
   procedure setvalue(const avalue: msestring);
  protected
   procedure getvalueinfo(out avalues: recvaluearty; const aindex: int32 = -1);
                                                                       override;
   procedure setvalue(const atype: listdatatypety;
       const aindex: int32; const getvaluemethod: getvaluemethodty); override;
  public
   property value: msestring read fvalue write setvalue;
 end;

procedure initvalueinfo(out ainfo: recvaluety);
procedure initvalueinfo(const aindex: int32; var avalue: int32;
                                                  out ainfo: recvaluety);
procedure initvalueinfo(const aindex: int32; var avalue: longbool;
                                                  out ainfo: recvaluety);
procedure initvalueinfo(const aindex: int32; var avalue: realty;
                                                  out ainfo: recvaluety);
procedure initvalueinfo(const aindex: int32; var avalue: tdatetime;
                                                  out ainfo: recvaluety);
procedure initvalueinfo(const aindex: int32; var avalue: msestring;
                                                  out ainfo: recvaluety);
function valuefield(var avalue: int32): fieldinfoty;
function valuefield(var avalue: longbool): fieldinfoty;
function valuefield(var avalue: real): fieldinfoty;
function valuefield(var avalue: realty): fieldinfoty;
function valuefield(var avalue: tdatetime): fieldinfoty;
function valuefield(var avalue: msestring): fieldinfoty;
function buildvalueinfos(const afields: array of fieldinfoty; 
                            const aindex: int32): recvaluearty;
                                 //-1 -> all
 
implementation
uses
 msearrayutils;
 
procedure initvalueinfo(out ainfo: recvaluety);
begin
 ainfo.dummypointer:= nil;
end;

procedure initvalueinfo(const aindex: int32;
               var avalue: int32; out ainfo: recvaluety);
begin
 initvalueinfo(ainfo);
 ainfo.datatype:= dl_integer;
 ainfo.valueindex:= aindex;
 ainfo.valuead:= @avalue;
end;

procedure initvalueinfo(const aindex: int32;
               var avalue: longbool; out ainfo: recvaluety);
begin
 initvalueinfo(ainfo);
 ainfo.datatype:= dl_integer;
 ainfo.valueindex:= aindex;
 ainfo.valuead:= @avalue;
end;

procedure initvalueinfo(const aindex: int32;
               var avalue: realty; out ainfo: recvaluety);
begin
 initvalueinfo(ainfo);
 ainfo.datatype:= dl_real;
 ainfo.valueindex:= aindex;
 ainfo.valuead:= @avalue;
end;

procedure initvalueinfo(const aindex: int32;
               var avalue: tdatetime; out ainfo: recvaluety);
begin
 initvalueinfo(ainfo);
 ainfo.datatype:= dl_real;
 ainfo.valueindex:= aindex;
 ainfo.valuead:= @avalue;
end;

procedure initvalueinfo(const aindex: int32;
               var avalue: msestring; out ainfo: recvaluety);
begin
 initvalueinfo(ainfo);
 ainfo.datatype:= dl_msestring;
 ainfo.valueindex:= aindex;
 ainfo.valuead:= @avalue;
end;

function valuefield(var avalue: int32): fieldinfoty;
begin
 result.datatype:= dl_integer;
 result.data:= @avalue;
end;

function valuefield(var avalue: longbool): fieldinfoty;
begin
 result.datatype:= dl_integer;
 result.data:= @avalue;
end;

function valuefield(var avalue: real): fieldinfoty;
begin
 result.datatype:= dl_real;
 result.data:= @avalue;
end;

function valuefield(var avalue: realty): fieldinfoty;
begin
 result.datatype:= dl_real;
 result.data:= @avalue;
end;

function valuefield(var avalue: tdatetime): fieldinfoty;
begin
 result.datatype:= dl_real;
 result.data:= @avalue;
end;

function valuefield(var avalue: msestring): fieldinfoty;
begin
 result.datatype:= dl_msestring;
 result.data:= @avalue;
end;

function buildvalueinfos(
              const afields: array of fieldinfoty;
               const aindex: int32): recvaluearty;

 procedure setup(const aindex: int32; const source: fieldinfoty;
                                               out dest: recvaluety);
 begin
  initvalueinfo(dest);
  dest.datatype:= source.datatype;
  dest.valueindex:= aindex;
  dest.valuead:= source.data;
 end;//setup

var
 i1: int32;                           
begin
 if aindex < 0 then begin
  setlength(result,length(afields));
  for i1:= 0 to high(result) do begin
   setup(i1,afields[i1],result[i1]);
  end;
 end
 else begin
  if aindex <= high(afields) then begin
   setlength(result,1);
   setup(aindex,afields[aindex],result[0]);
  end
  else begin
   result:= nil;
  end;
 end;
end;

{ trecordfielditem }

constructor trecordfielditem.create(const intf: irecordfield;
               const afieldindex: integer;
               const acaption: msestring; const fixedcaption: boolean;
                                    const aimagenr: integer = 0;
                                    const aimagelist: timagelist = nil);
begin
 fintf:= intf;
 ffieldindex:= afieldindex;
 inherited create;
 fcaption:= acaption;
 fimagenr:= aimagenr;
 imagelist:= aimagelist;
 if fixedcaption then begin
  fstate1:= fstate1 + [ns1_fixedcaption];
 end;
end;

function trecordfielditem.getvaluetext: msestring;
begin
 if fintf <> nil then begin
  result:= fintf.getfieldtext(ffieldindex);
 end
 else begin
  result:= inherited getvaluetext;
 end;
end;

procedure trecordfielditem.setvaluetext(var avalue: msestring);
begin
 if fintf <> nil then begin
  fintf.setfieldtext(ffieldindex,avalue);
 end
 else begin
  if not (ns1_fixedcaption in fstate1) then begin
   inherited;
  end;
 end;
end;

{ trecordfieldvalueitem }

constructor trecordfieldvalueitem.create(const intf: irecordvaluefield;
               const afieldindex: integer; const acaption: msestring;
               const fixedcaption: boolean = false; const aimagenr: integer = 0;
               const aimagelist: timagelist = nil);
begin
 inherited create(intf,afieldindex,acaption,fixedcaption,aimagenr,aimagelist);
end;

procedure trecordfieldvalueitem.getvalueinfo(out avalues: recvaluearty;
                                                    const aindex: int32 = -1);
begin
 irecordvaluefield(fintf).getvalueinfo(avalues,fieldindex);
end;

procedure trecordfieldvalueitem.setvalue(const atype: listdatatypety;
               const aindex: int32; const getvaluemethod: getvaluemethodty);
begin
 irecordvaluefield(fintf).setvalue(atype,aindex,getvaluemethod);
end;

function trecordfieldvalueitem.getfieldtext(
              const afieldindex: integer): msestring;
begin
 result:= '';
end;

procedure trecordfieldvalueitem.setfieldtext(const afieldindex: integer;
               var avalue: msestring);
begin
 //dummy
end;

{ trecordtreelistedititem }

constructor trecordtreelistedititem.create(const aowner: tcustomitemlist;
  const aparent: ttreelistitem);
begin
 inherited;
 include(fstate,ns_nosubnodestat);
end;

function trecordtreelistedititem.getfieldtext(
              const fieldindex: integer): msestring;
begin
 result:= '';
end;

procedure trecordtreelistedititem.setfieldtext(const fieldindex: integer;
               var avalue: msestring);
begin
 //dummy
end;

procedure trecordtreelistedititem.setvalue(const atype: listdatatypety;
                  const aindex: int32; const getvaluemethod: getvaluemethodty);
var
 values1: recvaluearty;
begin
 if aindex >= 0 then begin
  getvalueinfo(values1,aindex);
  if (values1 <> nil) then begin
   with values1[0] do begin
    if datatype = atype then begin
     getvaluemethod(valuead^);
    end;
   end;
  end;
 end;
end;

procedure trecordtreelistedititem.getvalueinfo(out avalues: recvaluearty;
                                                      const aindex: int32 = -1);
begin
 avalues:= nil;
end;

{ trecordlistedititem }

procedure trecordlistedititem.getvalueinfo(out avalues: recvaluearty;
                                                   const aindex: int32 = -1);
begin
 avalues:= nil;
end;

function trecordlistedititem.getfieldtext(
              const fieldindex: integer): msestring;
begin
 result:= '';
end;

procedure trecordlistedititem.setfieldtext(const fieldindex: integer;
               var avalue: msestring);
begin
 //dummy
end;

procedure trecordlistedititem.setvalue(const atype: listdatatypety;
                  const aindex: int32; const getvaluemethod: getvaluemethodty);
begin
 //dummy
end;

{ trecordvaluelistedititem }

constructor trecordvaluelistedititem.create(const avalueindex: int32;
               const aowner: tcustomitemlist = nil);
begin
 fvalueindex:= avalueindex;
 create(aowner);
end;

procedure trecordvaluelistedititem.getvalueinfo(out avalues: recvaluearty;
                                                     const aindex: int32 = -1);
begin
 allocuninitedarray(1,sizeof(recvaluety),avalues);
 with avalues[0] do begin
  datatype:= dl_none;
  valueindex:= fvalueindex;
  valuead:= nil;
  dummypointer:= nil;
 end;
end;

{ tintegervaluelistedititem }

procedure tintegervaluelistedititem.setvalue(const avalue: int32);
begin
 if fvalue <> avalue then begin
  fvalue:= avalue;
  valuechange();
 end;
end;

procedure tintegervaluelistedititem.getvalueinfo(out avalues: recvaluearty;
                                                      const aindex: int32 = -1);
begin
 inherited;
 with avalues[0] do begin
  datatype:= dl_integer;
  valuead:= @fvalue;
 end;
end;

procedure tintegervaluelistedititem.setvalue(const atype: listdatatypety;
               const aindex: int32; const getvaluemethod: getvaluemethodty);
var
 i1: int32;
begin
 if (atype = dl_integer) then begin
  getvaluemethod(i1);
  value:= i1;
 end;
end;

{ tbooleanvaluelistedititem }

procedure tbooleanvaluelistedititem.setvalue(const avalue: boolean);
begin
 if longbool(fvalue) <> avalue then begin
  longbool(fvalue):= avalue;
  valuechange();
 end;
end;

function tbooleanvaluelistedititem.getvalue: boolean;
begin
 result:= longbool(fvalue);
end;

{ trealvaluelistedititem }

procedure trealvaluelistedititem.setvalue(const avalue: realty);
begin
 if fvalue <> avalue then begin
  fvalue:= avalue;
  valuechange();
 end;
end;

procedure trealvaluelistedititem.getvalueinfo(out avalues: recvaluearty;
                                                   const aindex: int32 = -1);
begin
 inherited;
 with avalues[0] do begin
  datatype:= dl_real;
  valuead:= @fvalue;
 end;
end;

procedure trealvaluelistedititem.setvalue(const atype: listdatatypety;
               const aindex: int32; const getvaluemethod: getvaluemethodty);
var
 rea1: realty;
begin
 if (atype = dl_real) then begin
  getvaluemethod(rea1);
  value:= rea1;
 end;
end;

{ tdatetimevaluelistedititem }

procedure tdatetimevaluelistedititem.setvalue(const avalue: tdatetime);
begin
 if fvalue <> avalue then begin
  fvalue:= avalue;
  valuechange();
 end;
end;

procedure tdatetimevaluelistedititem.getvalueinfo(out avalues: recvaluearty;
                                                     const aindex: int32 = -1);
begin
 inherited;
 with avalues[0] do begin
  datatype:= dl_real;
  valuead:= @fvalue;
 end;
end;

procedure tdatetimevaluelistedititem.setvalue(const atype: listdatatypety;
               const aindex: int32; const getvaluemethod: getvaluemethodty);
var
 dat1: tdatetime;
begin
 if (atype = dl_real) then begin
  getvaluemethod(dat1);
  value:= dat1;
 end;
end;

{ tstringvaluelistedititem }

procedure tstringvaluelistedititem.setvalue(const avalue: msestring);
begin
 if fvalue <> avalue then begin
  fvalue:= avalue;
  valuechange();
 end;
end;

procedure tstringvaluelistedititem.getvalueinfo(out avalues: recvaluearty;
                                                     const aindex: int32 = -1);
begin
 inherited;
 with avalues[0] do begin
  datatype:= dl_msestring;
  valuead:= @fvalue;
 end;
end;

procedure tstringvaluelistedititem.setvalue(const atype: listdatatypety;
               const aindex: int32; const getvaluemethod: getvaluemethodty);
var
 mstr1: msestring;
begin
 if (atype = dl_msestring) then begin
  getvaluemethod(mstr1);
  value:= mstr1;
 end;
end;

end.
