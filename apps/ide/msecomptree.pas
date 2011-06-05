{ MSEide Copyright (c) 2011 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit msecomptree;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,msewidgetgrid,mselistbrowser,msedatanodes,msetypes,msestrings,msegui,
 mseglob,mseclasses,msegrids,msesys,msegridsglob,msestat,msestatfile;

const
 compnamedialogstatname = 'compnamedialog.sta';
 
type
 tcompnameitem = class(ttreelistedititem)
  public
   isvalue: boolean;
 end;
 
 tcompnametreefo = class(tmseform)
   grid: twidgetgrid;
   treeitem: ttreeitemedit;
   tstatfile1: tstatfile;
   procedure treeitemoncreateitem(const sender: tcustomitemlist;
                     var item: ttreelistedititem); virtual;
   procedure treeitemonitemnotification(const sender: tlistitem;
                 var action: nodeactionty); virtual;
   procedure treeitemondataentered(const sender: tobject); virtual;
   procedure treeitemoncellevent(const sender: tobject;
                 var info: celleventinfoty); virtual;
  private
  public
 end;
{
 tdiredit = class(tstringedit)
  private
 end;
}
//var
// dirtreefo: tdirtreefo;

function compnamedialog(const avalues: tcompnameitem; //will be freed
                                var avalue: msestring): modalresultty;

implementation
uses
 msecomptree_mfm,msesysintf,mseeditglob,msefiledialog,msebitmap,mseevent,
 mseguiglob;

function compnamedialog(const avalues: tcompnameitem;
                                var avalue: msestring): modalresultty;
var
 fo1: tcompnametreefo;
 ar1: msestringarty;
 item1: ttreelistitem;
begin
 fo1:= tcompnametreefo.create(nil);
 try
  ar1:= splitstring(avalue,msechar('.'));
  item1:= avalues.finditembycaption(ar1);
  if item1 <> nil then begin
   item1.expandtoroot;
  end;
  fo1.treeitem.itemlist.assign(avalues);
  if item1 <> nil then begin
   fo1.grid.row:= item1.index;
  end;
  result:= fo1.show(true);
  if result = mr_ok then begin
   ar1:= tcompnameitem(fo1.treeitem.item).rootcaptions;
   avalue:= ar1[0];
   if high(ar1) > 0 then begin
    avalue:= ar1[0]+'.'+ar1[1];
    if high(ar1) > 1 then begin
     if high(ar1) = 2 then begin
      avalue:= avalue+':'+ar1[2];
     end
     else begin
      avalue:= avalue+':'+concatstrings(copy(ar1,2,bigint),':');
     end;
    end;
   end;
  end;
 finally
  fo1.free;
 end;
end;

{ tcompnametreefo }

procedure tcompnametreefo.treeitemoncellevent(const sender: tobject;
  var info: celleventinfoty);
begin
 case info.eventkind of
  cek_enter: begin
//   if assigned(fonpathchanged) then begin
//    fonpathchanged(self);
//   end;
  end;
 end;
 if iscellclick(info) and (info.zone = cz_caption) then begin
  treeitem.checkvalue;
 end;
end;

procedure tcompnametreefo.treeitemoncreateitem(const sender: tcustomitemlist;
  var item: ttreelistedititem);
begin
 item:= tcompnameitem.create(sender);
end;

procedure tcompnametreefo.treeitemondataentered(const sender: tobject);
begin
 if tcompnameitem(treeitem.item).isvalue then begin
  window.modalresult:= mr_ok;
 end;
end;

procedure tcompnametreefo.treeitemonitemnotification(const sender: tlistitem;
  var action: nodeactionty);
//var
// bo1: boolean;
begin
{
 with tdirlistitem(sender) do begin
  case action of
   na_expand: begin
    include(finfo.state,fis_diropen);
    updateinfo;
    if (count = 0) or not(dto_checkbox in foptions) then begin
     adddir(tdirlistitem(sender));
    end;
    if count = 0 then begin
     state:= state - [ns_subitems,ns_expanded];
     action:= na_none;
    end;
   end;
   na_collapse: begin
    bo1:= count > 0;
    if not (dto_checkbox in foptions) then begin
     clear;
    end;
    if bo1 then begin
     state:= state + [ns_subitems];
    end;
    exclude(finfo.state,fis_diropen);
    updateinfo;
   end;
  end;
 end;
 }
end;

end.
