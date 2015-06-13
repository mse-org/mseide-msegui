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
 msetypes;
type
 irecordfield = interface(inullinterface)
  function getfieldtext(const fieldindex: integer): msestring;
  procedure setfieldtext(const fieldindex: integer; var avalue: msestring);
 end;

 getvaluemethodty = procedure(out dest) of object;

 irecordvaluefield = interface(irecordfield)
  procedure getvalueinfo(out atype: listdatatypety; out aindex: int32;
                                                        out avaluead: pointer);
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

 trecordfieldvalueitem = class(trecordfielditem)
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

 trecordvaluelistedititem = class(tlistedititem,irecordvaluefield)
  private
  protected
   fvalueindex: int32;
    //irecordvaluefield
   function getfieldtext(const fieldindex: integer): msestring; virtual;
   procedure setfieldtext(const fieldindex: integer;
                                              var avalue: msestring); virtual;
   procedure getvalueinfo(out atype: listdatatypety; out aindex: int32;
                                                out avaluead: pointer); virtual;
   procedure setvalue(const atype: listdatatypety;
          const aindex: int32; const getvaluemethod: getvaluemethodty); virtual;
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
   procedure getvalueinfo(out atype: listdatatypety;
                        out aindex: int32; out avaluead: pointer); override;
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
   procedure getvalueinfo(out atype: listdatatypety;
                        out aindex: int32; out avaluead: pointer); override;
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
   procedure getvalueinfo(out atype: listdatatypety;
                        out aindex: int32; out avaluead: pointer); override;
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
   procedure getvalueinfo(out atype: listdatatypety;
                        out aindex: int32; out avaluead: pointer); override;
   procedure setvalue(const atype: listdatatypety;
       const aindex: int32; const getvaluemethod: getvaluemethodty); override;
  public
   property value: msestring read fvalue write setvalue;
 end;
   
implementation

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

{ trecordvaluelistedititem }

procedure trecordvaluelistedititem.getvalueinfo(out atype: listdatatypety;
                                   out aindex: int32; out avaluead: pointer);
begin
 atype:= dl_none;
 aindex:= fvalueindex;
 avaluead:= nil;
end;

function trecordvaluelistedititem.getfieldtext(
              const fieldindex: integer): msestring;
begin
 result:= '';
end;

procedure trecordvaluelistedititem.setfieldtext(const fieldindex: integer;
               var avalue: msestring);
begin
 //dummy
end;

procedure trecordvaluelistedititem.setvalue(const atype: listdatatypety;
                  const aindex: int32; const getvaluemethod: getvaluemethodty);
begin
 //dummy
end;

constructor trecordvaluelistedititem.create(const avalueindex: int32;
               const aowner: tcustomitemlist = nil);
begin
 fvalueindex:= avalueindex;
 create(aowner);
end;

{ tintegervaluelistedititem }

procedure tintegervaluelistedititem.setvalue(const avalue: int32);
begin
 if fvalue <> avalue then begin
  fvalue:= avalue;
  valuechange();
 end;
end;

procedure tintegervaluelistedititem.getvalueinfo(out atype: listdatatypety;
               out aindex: int32; out avaluead: pointer);
begin
 inherited;
 atype:= dl_integer;
 avaluead:= @fvalue;
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

procedure trealvaluelistedititem.getvalueinfo(out atype: listdatatypety;
             out aindex: int32; out avaluead: pointer);
begin
 inherited;
 atype:= dl_real;
 avaluead:= @fvalue;
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

procedure tdatetimevaluelistedititem.getvalueinfo(out atype: listdatatypety;
               out aindex: int32; out avaluead: pointer);
begin
 inherited;
 atype:= dl_real;
 avaluead:= @fvalue;
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

procedure tstringvaluelistedititem.getvalueinfo(out atype: listdatatypety;
               out aindex: int32; out avaluead: pointer);
begin
 inherited;
 atype:= dl_msestring;
 avaluead:= @fvalue;
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
