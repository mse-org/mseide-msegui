{ MSEide Copyright (c) 1999-2011 by Martin Schreiber

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
unit msedbfieldeditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
uses
 mdb,msegui,mseclasses,mseforms,msedb,msestat,msestatfile,msesimplewidgets,
 msegrids,msewidgetgrid,msesplitter,msedataedits,msetypes{msestrings},mseeditglob,
 msegraphedits,mseglob,msegridsglob,msestringcontainer;

const
 dbfieldeditorstatname =  'dbfieldeditor.sta';
type
 tmsedbfieldeditorfo = class(tmseform)
   tbutton1: tbutton;
   tbutton2: tbutton;
   index: tintegeredit;
   fieldkind: tenumtypeedit;
   splitter: tsplitter;
   fieldpo: tpointeredit;
   classty: tenumtypeedit;
   tstatfile1: tstatfile;
   fielddefli: tstringgrid;
   fields: twidgetgrid;
   fieldname: tstringedit;
   deftofield: tstockglyphbutton;
   fieldtodef: tstockglyphbutton;
   c: tstringcontainer;
   procedure formloaded(const sender: TObject);
   procedure initcla(const sender: tenumtypeedit);
   procedure splitterupda(const sender: TObject);
   procedure defscellevent(const sender: TObject; var info: celleventinfoty);
   procedure defsselectioncha(const sender: TObject);
   procedure fieldnamesetvalue(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure fieldsdataentered(const sender: TObject);
   procedure fieldsrowdel(const sender: tcustomgrid; const aindex: Integer;
                                    const acount: Integer);
   procedure transferfields(const sender: TObject);
   procedure fieldrowsdeleting(const sender: tcustomgrid; var aindex: Integer;
                                  var acount: Integer);
   procedure initfieldkind(const sender: tenumtypeedit);
   procedure fieldcellevent(const sender: TObject; var info: celleventinfoty);
   procedure fieldselectioncha(const sender: TObject);
   procedure deletefields(const sender: TObject);
   procedure fieldsort(const sender: tcustomgrid; const index1: Integer;
                   const index2: Integer; var aresult: Integer);
  private
   ffields: tpersistentfields;
   procedure checkfielddefs;
   function findfielddef(aname: msestring): integer;
  public
   constructor create(const afields: tpersistentfields); reintroduce;
 end;

function editpersistentfields(const instance: tpersistentfields): boolean;

implementation
uses
 mseguiglob,msedbfieldeditor_mfm,typinfo,msewidgets,msestrings;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

type
 tpersistentfields1 = class(tpersistentfields);
 stringconststy = (
  str_dataset            //0 Dataset
 );

function editpersistentfields(const instance: tpersistentfields): boolean;
var
 fo: tmsedbfieldeditorfo;
 int1,int2: integer;
 ct1: fieldclassty;
 ar1: fieldarty;
 activebefore: boolean;
begin
 result:= false;
 fo:= tmsedbfieldeditorfo.create(instance);
 try
  with fo,tpersistentfields1(instance) do begin
   activebefore:= dataset.active;
   dataset.active:= false;
   for int1:= 0 to count - 1 do begin
    items[int1].dataset:= nil;
   end;
   try
    if show(true) = mr_ok then begin
     fo.window.nofocus; //remove empty last line
     result:= true;
     setlength(ar1,fields.rowcount-dataset.fields.count);
     for int1:= 0 to high(ar1) do begin
      ct1:= getmsefieldclass(fieldclasstypety(classty[int1]));
//      ct1:= msefieldtypeclasses[fieldclasstypety(classty[int1])];
      int2:= index[int1];
      if int2 > 0 then begin
       dec(int2);
       if ct1 <> items[int2].classtype then begin
        ar1[int1]:= ct1.create(nil);
        ar1[int1].dataset:= dataset;
       end
       else begin
        ar1[int1]:= items[int2];
        fitems[int2]:= nil;
       end;
      end
      else begin
       if fieldpo[int1] <> nil then begin
        ar1[int1]:= tfield(fieldpo[int1]);
        fieldpo[int1]:= nil;
       end
       else begin
        ar1[int1]:= ct1.create(nil);
        try
         ar1[int1].dataset:= dataset;
        except
         application.handleexception(nil);
        end;
       end;
      end;
      try
       ar1[int1].fieldname:= ansistring(fieldname[int1]);
      except
       application.handleexception(nil);
      end;
      ar1[int1].fieldkind:= tfieldkind(fieldkind[int1]);
     end;
     for int1:= 0 to count - 1 do begin
      items[int1].free;
     end;
     for int1:= 0 to high(ar1) do begin
      tfield(fieldpo[int1]).free;
     end;
     fitems:= persistentarty(ar1);
    end;
   finally
    for int1:= 0 to count - 1 do begin
     items[int1].dataset:= dataset;
    end;
    if result then begin
     for int1:= 0 to high(ar1) do begin
      items[int1].index:= int1;
     end;
     for int1:= length(ar1) to fields.rowhigh do begin
      tfield(fieldpo[int1]).index:= int1;
     end;
    end;
    if activebefore then begin
     try
      dataset.active:= true;
     except
      application.handleexception(dataset);
     end;
    end;
   end;
  end;
 finally
  fo.free;
 end;
end;

{ tmsedbfieldeditorfo }

constructor tmsedbfieldeditorfo.create(const afields: tpersistentfields);
begin
 ffields:= afields;
 inherited create(nil);
end;

procedure tmsedbfieldeditorfo.formloaded(const sender: TObject);
var
 int1: integer;
 field1: tfield;
begin
 with ffields.dataset do begin
  caption:= c[ord(str_dataset)]+': ' + msestring(name);
  fielddefli.rowcount:= fielddefs.count;
  for int1:= 0 to fielddefs.count-1 do begin
   fielddefli[0][int1]:= msestring(fielddefs[int1].name);
   fielddefli[1][int1]:= msestring(getenumname(typeinfo(tfieldtype),
                                 ord(fielddefs[int1].datatype)));
  end;
 end;
 fields.rowcount:= ffields.count + ffields.dataset.fields.count;
 for int1:= 0 to ffields.count - 1 do begin
  index[int1]:= int1+1;
  fieldname[int1]:= msestring(ffields[int1].fieldname);
  classty[int1]:= ord(fieldclasstoclasstyp(fieldclassty(ffields[int1].classtype)));
  fieldkind[int1]:= ord(ffields[int1].fieldkind);
 end;
 for int1:= ffields.count to fields.rowhigh do begin
  index[int1]:= int1+1;
  field1:= ffields.dataset.fields[int1-ffields.count];
  fieldpo[int1]:= field1;
  with field1 do begin
   self.fieldname[int1]:= msestring(fieldname);
   classty[int1]:= ord(fieldclasstoclasstyp(fieldclassty(classtype)));
   self.fieldkind[int1]:= ord(fieldkind);
  end;
  fields.rowfontstate[int1]:= 0;
 end;
 checkfielddefs;
end;

procedure tmsedbfieldeditorfo.initcla(const sender: tenumtypeedit);
begin
 sender.typeinfopo:= typeinfo(fieldclasstypety);
end;

procedure tmsedbfieldeditorfo.initfieldkind(const sender: tenumtypeedit);
begin
 sender.typeinfopo:= typeinfo(tfieldkind);
end;

procedure tmsedbfieldeditorfo.splitterupda(const sender: TObject);
begin
 deftofield.left:= splitter.left+splitter.bounds_cx;
 fieldtodef.left:= splitter.left-fieldtodef.bounds_cx;
// alignx(wam_center,[splitter,deftofield]);
end;

procedure tmsedbfieldeditorfo.defscellevent(const sender: TObject;
         var info: celleventinfoty);
begin
 with info do begin
  if (eventkind = cek_select) and selected and
          (fielddefli.rowfontstate[cell.row] <> -1) then begin
   accept:= false;
  end;
 end;
end;

procedure tmsedbfieldeditorfo.defsselectioncha(const sender: TObject);
begin
 deftofield.enabled:= fielddefli.datacols.hasselection;
end;

procedure tmsedbfieldeditorfo.fieldnamesetvalue(const sender: TObject;
            var avalue: msestring; var accept: Boolean);
var
 mstr1: msestring;
 int1: integer;
begin
 mstr1:= mseuppercase(avalue);
 for int1:= 0 to fields.rowcount-1 do begin
  if (int1 <> fields.row) and (mstr1 = mseuppercase(fieldname[int1])) then begin
   showerror('Field name exists.');
   accept:= false;
   break;
  end;
 end;
end;

procedure tmsedbfieldeditorfo.checkfielddefs;
var
 int1,int2: integer;
 ar1: msestringarty;
 mstr1: msestring;
begin
 setlength(ar1,fields.rowcount);
 for int1:= 0 to high(ar1) do begin
  ar1[int1]:= mseuppercase(fieldname[int1]);
 end;
 for int1:= 0 to fielddefli.rowcount - 1 do begin
  mstr1:= mseuppercase(fielddefli[0][int1]);
  fielddefli.rowfontstate[int1]:= -1;
  for int2:= 0 to high(ar1) do begin
   if mstr1 = ar1[int2] then begin
    fielddefli.rowfontstate[int1]:= 0;
    fielddefli.datacols.selected[makegridcoord(-1,int1)]:= false;
    break;
   end;
  end;
 end;
end;

procedure tmsedbfieldeditorfo.fieldsdataentered(const sender: TObject);
begin
 checkfielddefs;
end;

procedure tmsedbfieldeditorfo.fieldsrowdel(const sender: tcustomgrid;
              const aindex: Integer; const acount: Integer);
begin
 checkfielddefs;
end;

procedure tmsedbfieldeditorfo.transferfields(const sender: TObject);
var
 int1,int2: integer;
 ar1,ar2: integerarty;
begin
 ar1:= fielddefli.datacols.selectedrows;
 if high(ar1) >= 0 then begin
  setlength(ar2,length(ar1));
  int2:= 0;
  fields.beginupdate;
  for int1:= 0 to high(ar1) do begin
   fields.appendrow(true);
   try
    fields.row:= fields.rowhigh;
    fieldpo[fields.rowhigh]:=
               ffields.dataset.fielddefs[ar1[int1]].createfield(nil);
    tfield(fieldpo[fields.rowhigh]).dataset:= nil;
    fieldname[fields.rowhigh]:= fielddefli[0][ar1[int1]];
    classty[fields.rowhigh]:= ord(fieldclasstoclasstyp(
             ffields.dataset.fielddefs[ar1[int1]].fieldclass));
    fieldkind[fields.rowhigh]:= ord(tfield(fieldpo[fields.rowhigh]).fieldkind);
    ar2[int2]:= fields.rowhigh;
    inc(int2);
   except
    fields.rowcount:= fields.rowcount - 1;
    application.handleexception(nil);
   end;
   fielddefli.datacols.clearselection;
  end;
  setlength(ar2,int2);
  fields.datacols.selectedrows:= ar2;
  fields.endupdate;
 // fields.sort;
  checkfielddefs;
  for int1:= ar1[high(ar1)] + 1 to fielddefli.rowhigh do begin
   if fielddefli.rowfontstate[int1] = -1 then begin
    fielddefli.row:= int1;
    exit;
   end;
  end;
  for int1:= 0 to fielddefli.rowhigh do begin
   if fielddefli.rowfontstate[int1] = -1 then begin
    fielddefli.row:= int1;
    exit;
   end;
  end;
 end;
end;

procedure tmsedbfieldeditorfo.fieldrowsdeleting(const sender: tcustomgrid;
              var aindex: Integer; var acount: Integer);
var
 int1: integer;
begin
 for int1:= aindex to aindex + acount - 1 do begin
  if sender.rowfontstate[int1] <> -1 then begin
   acount:= 0;
   break;
  end;
 end;
 for int1:= aindex to aindex + acount - 1 do begin
  tfield(fieldpo[int1]).free;
 end;
end;

procedure tmsedbfieldeditorfo.fieldsort(const sender: tcustomgrid;
               const index1: Integer; const index2: Integer;
               var aresult: Integer);
begin
 aresult:= fields.rowfontstate[index1] - fields.rowfontstate[index2];
end;

procedure tmsedbfieldeditorfo.fieldcellevent(const sender: TObject;
        var info: celleventinfoty);
begin
 with info do begin
  if eventkind = cek_enter then begin
   if fields.rowfontstate[cell.row] = -1 then begin
    fields.datacols.options:= fields.datacols.options - [co_readonly];
    fields.optionsgrid:= fields.optionsgrid + [og_rowdeleting];
   end
   else begin
    fields.datacols.options:= fields.datacols.options + [co_readonly];
    fields.optionsgrid:= fields.optionsgrid - [og_rowdeleting];
   end;
  end;
  if (eventkind = cek_select) and selected then begin
   if fields.rowfontstate[cell.row] <> -1 then begin
    accept:= false;
   end;
  end;
 end;
end;

procedure tmsedbfieldeditorfo.fieldselectioncha(const sender: TObject);
begin
 fieldtodef.enabled:= fields.datacols.hasselection and
                            (length(fields.datacols.selectedrows) > 0);
end;

function tmsedbfieldeditorfo.findfielddef(aname: msestring): integer;
var
 int1: integer;
begin
 result:= invalidaxis;
 aname:= struppercase(aname);
 for int1:= 0 to fielddefli.rowhigh do begin
  if msestringicompupper(fielddefli[0][int1],aname) = 0 then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure tmsedbfieldeditorfo.deletefields(const sender: TObject);
var
 ar1,ar2: integerarty;
 int1: integer;
 int2: integer;
begin
 ar1:= fields.datacols.selectedrows;
 setlength(ar2,length(ar1)); //max
 int2:= 0;
 for int1:= high(ar1) downto 0 do begin
  ar2[int2]:= findfielddef(fieldname[ar1[int1]]);
  if ar2[int2] >= 0 then begin
   inc(int2);
  end;
 end;
 ffields.beginupdate;
 for int1:= high(ar1) downto 0 do begin
  fields.deleterow(ar1[int1]);
 end;
 ffields.endupdate;
 if int2 > 0 then begin
  setlength(ar2,int2);
  fielddefli.row:= ar2[high(ar2)];
  fielddefli.datacols.selectedrows:= ar2;
 end;
end;

end.
