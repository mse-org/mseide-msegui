{ MSEgui Copyright (c) 2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseifidbgui;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,db,mseifigui,mseifids,mseifi,msedatalist,msegui,msemenus,msegrids,
 mseguiglob,msetypes;
type
 tdbrxwidgetgrid = class;
 
 tifidbwidgetgridcontroller = class(tifiwidgetgridcontroller)
  private
   fcolbinding: subdatainfoarty;
  protected
   procedure decoderecord(const aindex: integer; var adatapo: pifidataty);
   procedure processdata(const adata: pifirecty; var adatapo: pchar); override;
   function getifireckinds: ifireckindsty; override;
  public
   constructor create(const aowner: tdbrxwidgetgrid);
 end;
 
 tdbrxwidgetgrid = class(trxwidgetgrid)
  private
   function getifi1: tifidbwidgetgridcontroller;
   procedure setifi1(const avalue: tifidbwidgetgridcontroller);
  public
   constructor create(aowner: tcomponent); override;
  published
   property ifi: tifidbwidgetgridcontroller read getifi1 write setifi1;
 end;
  
implementation
uses
 mseifilink;
 
{ tifidbwidgetgridcontroller }

constructor tifidbwidgetgridcontroller.create(const aowner: tdbrxwidgetgrid);
begin
 inherited;
end;

function tifidbwidgetgridcontroller.getifireckinds: ifireckindsty;
begin
 result:= inherited getifireckinds + [ik_dsdata,ik_fieldrec];
end;

procedure tifidbwidgetgridcontroller.decoderecord(const aindex: integer;
               var adatapo: pifidataty);
var
 int1: integer;
begin
 for int1:= 0 to high(fcolbinding) do begin
  inc(pchar(adatapo),decodeifidata(adatapo,aindex,fcolbinding[int1]));
 end;
end;

procedure tifidbwidgetgridcontroller.processdata(const adata: pifirecty;
                                                           var adatapo: pchar);
var
 fielddefs1: tfielddefs;
 int1,int2: integer;
 index1: integer;
begin
 with adata^.header do begin
  case kind of
   ik_dsdata: begin
    fielddefs1:= tfielddefs.create(nil);
    try
     if decodefielddefs(pfdefdataty(adatapo),fielddefs1,int1) then begin
      inc(adatapo,int1);
      with tdbrxwidgetgrid(fowner) do begin
       setlength(fcolbinding,fielddefs1.count);
       for int1:= 0 to high(fcolbinding) do begin
        fcolbinding[int1]:= datacols.colsubdatainfo(fielddefs1[int1].name);
       end;
       if (igo_state in foptionsrx) or 
           (answersequence <> 0) and (answersequence = fdatasequence) then begin
        beginupdate;
        inc(fcommandlock);
        try
         rowcount:= precdataty(adatapo)^.header.count;
         inc(adatapo,sizeof(recdataheaderty));
         for int1:= 0 to rowcount - 1 do begin
          decoderecord(int1,pifidataty(adatapo));
         end;
         include(fistate,rws_datareceived);
        finally
         dec(fcommandlock);
         endupdate;
        end;
       end;
      end;
     end;
    finally
     fielddefs1.free;
    end;    
   end;
   ik_fieldrec: begin
    with pfieldrecdataty(adatapo)^.header do begin
     index1:= rowindex;
     int2:= count;
     with tdbrxwidgetgrid(fowner) do begin
      case kind of
       frk_insert: begin
        insertrow(index1);
       end;
       frk_delete: begin
        deleterow(index1);
        exit;
       end;
      end;      
     end;
    end;
    adatapo:= @pfieldrecdataty(adatapo)^.data;
    inc(fcommandlock);
    try
     for int1:= 0 to int2 - 1 do begin
      with pfielddataty(adatapo)^ do begin
       inc(adatapo,decodeifidata(@data,index1,fcolbinding[header.index]) + 
                     sizeof(fielddataheaderty));
      end;
     end;
    finally
     dec(fcommandlock);
    end;
   end;
   else begin
    inherited;
   end;
  end;
 end;
end;

{ tdbrxwidgetgrid }

constructor tdbrxwidgetgrid.create(aowner: tcomponent);
begin
 fifi:= tifidbwidgetgridcontroller.create(self);
 inherited;
end;

function tdbrxwidgetgrid.getifi1: tifidbwidgetgridcontroller;
begin
 result:= tifidbwidgetgridcontroller(fifi);
end;

procedure tdbrxwidgetgrid.setifi1(const avalue: tifidbwidgetgridcontroller);
begin
 setifi(avalue);
end;

end.
