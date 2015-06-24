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
  procedure getvalueinfo(out avalues: recvaluearty);
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

 trecordfieldvalueitem = class(trecordfielditem,irecordfield)
  protected
   function getfieldtext(const afieldindex: integer): msestring;
   procedure setfieldtext(const afieldindex: integer; var avalue: msestring);
   procedure getvalueinfo(out avalues: recvaluearty);
   procedure setvalue(const atype: listdatatypety;
               const aindex: int32; const getvaluemethod: getvaluemethodty);
  public
   constructor create(const intf: irecordvaluefield; const afieldindex: integer;
                      const acaption: msestring;
                      const fixedcaption: boolean = false;
                      const aimagenr: integer = 0;
                      const aimagelist: timagelist = nil);
 end;

 trecordtreelistedititem = class(ttreelistedititem,irecordfield)   
                                          //does not statsave subitems
  protected
   function getfieldtext(const fieldindex: integer): msestring;
   procedure setfieldtext(const fieldindex: integer; var avalue: msestring);
  public
   constructor create(const aowner: tcustomitemlist = nil;
              const aparent: ttreelistitem = nil); override;
 end;

 trecordlistedititem = class(tlistedititem,irecordvaluefield)
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
   procedure getvalueinfo(out avalues: recvaluearty); override;
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
   procedure getvalueinfo(out avalues: recvaluearty); override;
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
   procedure getvalueinfo(out avalues: recvaluearty); override;
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
   procedure getvalueinfo(out avalues: recvaluearty); override;
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
   procedure getvalueinfo(out avalues: recvaluearty); override;
   procedure setvalue(const atype: listdatatypety;
       const aindex: int32; const getvaluemethod: getvaluemethodty); override;
  public
   property value: msestring read fvalue write setvalue;
 end;
 
implementation
uses
 msearrayutils;
 
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

procedure trecordfieldvalueitem.getvalueinfo(out avalues: recvaluearty);
begin
 irecordvaluefield(fintf).getvalueinfo(avalues);
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

{ trecordlistedititem }

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

procedure trecordlistedititem.getvalueinfo(out avalues: recvaluearty);
begin
 avalues:= nil;
end;

procedure trecordlistedititem.initvalueinfo(out ainfo: recvaluety);
begin
 ainfo.dummypointer:= nil;
end;

procedure trecordlistedititem.initvalueinfo(const aindex: int32;
               var avalue: int32; out ainfo: recvaluety);
begin
 initvalueinfo(ainfo);
 ainfo.datatype:= dl_integer;
 ainfo.valueindex:= aindex;
 ainfo.valuead:= @avalue;
end;

procedure trecordlistedititem.initvalueinfo(const aindex: int32;
               var avalue: longbool; out ainfo: recvaluety);
begin
 initvalueinfo(ainfo);
 ainfo.datatype:= dl_integer;
 ainfo.valueindex:= aindex;
 ainfo.valuead:= @avalue;
end;

procedure trecordlistedititem.initvalueinfo(const aindex: int32;
               var avalue: realty; out ainfo: recvaluety);
begin
 initvalueinfo(ainfo);
 ainfo.datatype:= dl_real;
 ainfo.valueindex:= aindex;
 ainfo.valuead:= @avalue;
end;

procedure trecordlistedititem.initvalueinfo(const aindex: int32;
               var avalue: tdatetime; out ainfo: recvaluety);
begin
 initvalueinfo(ainfo);
 ainfo.datatype:= dl_real;
 ainfo.valueindex:= aindex;
 ainfo.valuead:= @avalue;
end;

procedure trecordlistedititem.initvalueinfo(const aindex: int32;
               var avalue: msestring; out ainfo: recvaluety);
begin
 initvalueinfo(ainfo);
 ainfo.datatype:= dl_msestring;
 ainfo.valueindex:= aindex;
 ainfo.valuead:= @avalue;
end;

{ trecordvaluelistedititem }

constructor trecordvaluelistedititem.create(const avalueindex: int32;
               const aowner: tcustomitemlist = nil);
begin
 fvalueindex:= avalueindex;
 create(aowner);
end;

procedure trecordvaluelistedititem.getvalueinfo(out avalues: recvaluearty);
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

procedure tintegervaluelistedititem.getvalueinfo(out avalues: recvaluearty);
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

procedure trealvaluelistedititem.getvalueinfo(out avalues: recvaluearty);
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

procedure tdatetimevaluelistedititem.getvalueinfo(out avalues: recvaluearty);
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

procedure tstringvaluelistedititem.getvalueinfo(out avalues: recvaluearty);
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
