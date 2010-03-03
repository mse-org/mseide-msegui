{ MSEgui Copyright (c) 2010 by Martin Schreiber

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

 bindnamesty = array[rowstatememberty] of string;
// rowstatebindingty = array[rowstatememberty] of integer;
  
 tifidbwidgetgridcontroller = class(tifiwidgetgridcontroller)
  private
//   frowstatebinding: rowstatebindingty;
   fcolbinding: subdatainfoarty;
   fnames: bindnamesty;
  protected
   procedure decoderecord(const aindex: integer; var adatapo: pifidataty);
   procedure processdata(const adata: pifirecty; var adatapo: pchar); override;
   function getifireckinds: ifireckindsty; override;
   function bindnames(const aname: string; var ainfo: subdatainfoty): boolean;
  public
   constructor create(const aowner: tdbrxwidgetgrid);
  published
   property name_select: string read fnames[rsm_select] write fnames[rsm_select];
   property name_color: string read fnames[rsm_color] write fnames[rsm_color];
   property name_font: string read fnames[rsm_font] write fnames[rsm_font];
   property name_readonly: string read fnames[rsm_readonly] 
                                           write fnames[rsm_readonly];
   property name_foldlevel: string read fnames[rsm_foldlevel] 
                                           write fnames[rsm_foldlevel];
   property name_foldissum: string read fnames[rsm_foldissum] 
                                           write fnames[rsm_foldissum];
   property name_hidden: string read fnames[rsm_hidden] 
                                           write fnames[rsm_hidden];
   property name_merged: string read fnames[rsm_merged]
                                           write fnames[rsm_merged];
   property name_height: string read fnames[rsm_height] write fnames[rsm_height];
 end;
 
 tdbrxwidgetgrid = class(trxwidgetgrid)
  private
   function getifi1: tifidbwidgetgridcontroller;
   procedure setifi1(const avalue: tifidbwidgetgridcontroller);
  protected
   procedure rowstatechanged(const arow: integer); override;
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
//       fillchar(frowstatebinding,sizeof(frowstatebinding),0);
       fcolbinding:= nil;
       setlength(fcolbinding,fielddefs1.count);
       for int1:= 0 to high(fcolbinding) do begin
        if not bindnames(fielddefs1[int1].name,fcolbinding[int1]) then begin
         fcolbinding[int1]:= datacols.colsubdatainfo(fielddefs1[int1].name);
        end;
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

function tifidbwidgetgridcontroller.bindnames(const aname: string;
                                       var ainfo: subdatainfoty): boolean;
var
 na1: rowstatememberty;
begin
 result:= false;
 for na1:= low(rowstatememberty) to high(rowstatememberty) do begin
  if fnames[na1] = aname then begin
   ainfo.list:= tdbrxwidgetgrid(fowner).datacols.rowstate;
   ainfo.subindex:= ord(na1) + 1;
   result:= true;
   break;
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

procedure tdbrxwidgetgrid.rowstatechanged(const arow: integer);
var
 rsm1: rowstatememberty; 
begin
 with tifidbwidgetgridcontroller(fifi) do begin
  if cancommandsend(igo_coldata) then begin
   for rsm1:= low(rowstatememberty) to high(rowstatememberty) do begin
    if fnames[rsm1] <> '' then begin
     senditem(ik_coldatachange,[encodecolchangedata(fnames[rsm1],arow,
                    fdatacols.rowstate,rsm1)]);
    end;
   end;
  end;
 end;
 inherited;
end;

end.
