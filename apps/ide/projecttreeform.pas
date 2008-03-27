{ MSEide Copyright (c) 1999-2008 by Martin Schreiber
   
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
unit projecttreeform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,msewidgetgrid,mselistbrowser,msedatanodes,msetypes,msemenus,mseevent,
 mseactions,msefiledialog,msestat,msegrids,msedesigner,msedataedits,
 msegraphutils,msegui,msestrings,mseact;

type

 tprojecttreefo = class(tdockform)
   grid: twidgetgrid;
   projectedit: ttreeitemedit;
   edit: trecordfieldedit;
   unitpopup: tpopupmenu;
   addunitfileact: taction;
   removeunitfileact: taction;
   unitfiledialog: tfiledialog;
   procedure projecteditonchange(const sender: TObject);
   procedure projecteditonstatreaditem(const sender: TObject; 
                const reader: tstatreader; var aitem: ttreelistitem);
   procedure projecteditonupdaterowvalues(const sender: TObject; 
                const aindex: Integer; const aitem: tlistitem);
   procedure projecttreefooncreate(const sender: tobject);
   procedure projecttreefoonloaded(const sender: tobject);
   procedure projecttreefoondestroy(const sender: tobject);
   procedure projecteditonpopup(const sender: tobject; var amenu: tpopupmenu;
                      var mouseinfo: mouseeventinfoty);

   procedure unitpopuponupdate(const sender: tcustommenu);
   procedure addunitfileonexecute(const sender: tobject);
   procedure removeunitfileonexecute(const sender: tobject);

   procedure projecttreeonupdatestat(const sender: tobject;
                const filer: tstatfiler);
   procedure projecteditoncellevent(const sender: tobject; 
                var info: celleventinfoty);

   procedure itemoncheckrowmove(const curindex: Integer; const newindex: Integer;
                    var accept: Boolean);

   procedure gridondragbegin(const sender: TObject; const apos: pointty; 
                  var dragobject: tdragobject; var processed: Boolean);
   procedure gridonderagdrop(const sender: TObject; const apos: pointty; 
                  var dragobject: tdragobject; var processed: Boolean);
   procedure gridondragover(const sender: TObject; const apos: pointty; 
                  var dragobject: tdragobject; var accept: Boolean;
                  var processed: Boolean);
  protected
  public
   procedure clear;
 end;

 projectnodety = (pnk_none,pnk_source,pnk_form,pnk_files);

 tprojectnode = class(ttreelistedititem)
   fkind: projectnodety;
   ferror: boolean;
  public
   constructor create(const akind: projectnodety);
 end;

 tfilenode = class(tprojectnode)
  private
   ffilename: filenamety;
   procedure setfilename(const value: filenamety); virtual;
  protected
  public
   constructor create(const akind: projectnodety; const afilename: filenamety);
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
   function getvaluetext: msestring; override;

   property filename: filenamety read ffilename write setfilename;
 end;

 tformnode = class(tfilenode,irecordfield)
  private
   fclasstype: msestring;
   fformname: msestring;
   finstancevarname: msestring;
  protected
   procedure setfilename(const value: filenamety); override;
   function getfieldtext(const fieldindex: integer): msestring;
   procedure setfieldtext(const fieldindex: integer; var avalue: msestring);
  public
   constructor create(const afilename: filenamety);
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
 end;

 tunitnode = class(tfilenode)
  private
   fformfile: tformnode;
  public
   procedure dostatread(const reader: tstatreader); override;
   function setformfile(afilename: filenamety): tformnode;
 end;

 tprojectrootnode = class(tprojectnode)
  public
   function getvaluetext: msestring; override;
 end;

 tfilesnode = class(tprojectrootnode)
  protected
   function createsubnode: ttreelistitem; override;
   function createnode(const afilename: filenamety): tfilenode; virtual;
  public
   constructor create;
   function addfile(const afilename: filenamety): tfilenode;
   procedure addfiles(const afilenames: filenamearty);
   function findfile(const filename: filenamety): tfilenode;
 end;

 tunitsnode = class(tfilesnode)
  private
   fmoduleclassnames: filenamearty;
   fmodulenames: filenamearty;
   fmodulefilenames: filenamearty;
   fstatreading: boolean;
  protected
   function createsubnode: ttreelistitem; override;
   function createnode(const afilename: filenamety): tfilenode; override;
  public
   constructor create;
   function addfile(const afilename: filenamety): tunitnode;
   function moduleclassnames: msestringarty;
   function modulenames: msestringarty;
   function modulefilenames: filenamearty;
 end;

 tprojecttree = class
  private
   funits: tunitsnode;
   ffiles: tfilesnode;
   procedure docellevent(const projectedit: ttreeitemedit;
                    var info: celleventinfoty);
  public
   constructor create;
   function units: tunitsnode;
   function files: tfilesnode;
   procedure updatestat(const filer: tstatfiler);
 end;

var
 projecttreefo: tprojecttreefo;
 projecttree: tprojecttree;

function isformfile(const aname: filenamety): boolean;

implementation
uses
 projecttreeform_mfm,msefileutils,sysutils,main,sourceform,msewidgets,
 msedatalist,msedrag;

function isformfile(const aname: filenamety): boolean;
begin
 result:= issamefilename(aname,replacefileext(aname,formfileext));
end;

{ tprojectnode }

constructor tprojectnode.create(const akind: projectnodety);
begin
 fkind:= akind;
 inherited create;
 fstate:= fstate + [ns_sorted];
end;

{ tfilenode }

constructor tfilenode.create(const akind: projectnodety; const afilename: filenamety);
begin
 fkind:= akind;
 inherited create(akind);
 filename:= afilename;
 include(fstate,ns_readonly);
end;

procedure tfilenode.dostatread(const reader: tstatreader);
begin
 ffilename:= reader.readmsestring('file',ffilename);
 inherited;
end;

procedure tfilenode.dostatwrite(const writer: tstatwriter);
begin
 writer.writemsestring('file',ffilename);
 writer.writeinteger('kind',ord(fkind));
 inherited;
end;

procedure tfilenode.setfilename(const value: filenamety);
begin
 ffilename:= value;
 caption:= msefileutils.filename(value);
end;

function tfilenode.getvaluetext: msestring;
begin
 result:= ffilename;
end;

{ tformnode }

constructor tformnode.create(const afilename: filenamety);
begin
 inherited create(pnk_form,'');
 include(fstate,ns_nosubnodestat);
 filename:= afilename;
 add(trecordfielditem.create(irecordfield(self),0,'classtype'));
 add(trecordfielditem.create(irecordfield(self),1,'name'));
 add(trecordfielditem.create(irecordfield(self),2,'instancevarname'));
end;

procedure tformnode.dostatread(const reader: tstatreader);
begin
 inherited;
 fclasstype:= reader.readmsestring('classtype',fclasstype);
 fformname:= reader.readmsestring('formname',fformname);
 finstancevarname:= reader.readmsestring('instancevarname',finstancevarname);
end;

procedure tformnode.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 writer.writemsestring('classtype',fclasstype);
 writer.writemsestring('formname',fformname);
 writer.writemsestring('instancevarname',finstancevarname);
end;

procedure tformnode.setfilename(const value: filenamety);
var
 po1: pmoduleinfoty;
begin
 if value <> '' then begin
  po1:= nil;
  try
   po1:= mainfo.openformfile(value,false,false,false,true);
  except
  end;
  if po1 <> nil then begin
   fclasstype:= po1^.moduleclassname;
   fformname:= po1^.instance.Name;
   finstancevarname:= po1^.instancevarname;
  end
  else begin
   fclasstype:= '';
  end;
 end;
 inherited;
 caption:= removefileext(msefileutils.filename(value));
end;


function tformnode.getfieldtext(const fieldindex: integer): msestring;
begin
 case fieldindex of
  0: result:= fclasstype;
  1: result:= fformname;
  2: result:= finstancevarname;
  else result:= '';
 end;
end;

procedure tformnode.setfieldtext(const fieldindex: integer; var avalue: msestring);
begin
 case fieldindex of
  0: begin
   fclasstype:= designer.changemoduleclassname(ffilename,avalue);
   avalue:= fclasstype;
  end;
  1: begin
   fformname:= designer.changemodulename(ffilename,avalue);
   avalue:= fformname;
  end;
  2: begin
   finstancevarname:= designer.changeinstancevarname(ffilename,avalue);
   avalue:= finstancevarname;
  end;
 end;
end;

{ tunitnode }

procedure tunitnode.dostatread(const reader: tstatreader);
begin
 inherited;{
 if (ftreelevel = 2) and (fkind = pnk_form) or isformfile(ffilename) then begin
  fkind:= pnk_form;
  tunitnode(fparent).fformfile:= self;
 end;
 }
end;

function tunitnode.setformfile(afilename: filenamety): tformnode;
begin
 if afilename = '' then begin
  fformfile:= nil;
  clear;
 end
 else begin
  if fformfile = nil then begin
   fformfile:= tformnode.create(afilename);
   add(ttreelistitem(fformfile));
  end
  else begin
   fformfile.filename:= afilename;
  end;
 end;
 result:= fformfile;
end;

{ tprojectrootnode }

function tprojectrootnode.getvaluetext: msestring;
begin
 result:= '';
end;

{ tfilesnode }

constructor tfilesnode.create;
begin
 inherited create(pnk_files);
 fstate:= fstate + [ns_readonly,ns_drawemptybox];
 caption:= 'Files';
end;

function tfilesnode.addfile(const afilename: filenamety): tfilenode;
begin
 result:= findfile(afilename);
 if result = nil then begin
  result:= createnode(afilename);
  add(ttreelistedititem(result));
 end;
end;

procedure tfilesnode.addfiles(const afilenames: filenamearty);
var
 int1: integer;
begin
 beginupdate;
 try
  for int1:= 0 to high(afilenames) do begin
   addfile(afilenames[int1]);
  end;
 finally
  endupdate;
 end;
end;

function tfilesnode.findfile(const filename: filenamety): tfilenode;
var
 int1: integer;
begin
 result:= nil;
 for int1:= 0 to fcount - 1 do begin
  if tfilenode(fitems[int1]).ffilename = filename then begin
   result:= tfilenode(fitems[int1]);
   break;
  end;
 end;
end;

function tfilesnode.createnode(const afilename: filenamety): tfilenode;
begin
 result:= tfilenode.create(pnk_source,afilename);
end;

function tfilesnode.createsubnode: ttreelistitem;
begin
 result:= tfilenode.create(pnk_none,'');
end;

{ tunitsnode }

function tunitsnode.addfile(const afilename: filenamety): tunitnode;
begin
 result:= tunitnode(inherited addfile(afilename));
end;

constructor tunitsnode.create;
begin
 inherited create;
 caption:= 'Units';
end;

function tunitsnode.createnode(const afilename: filenamety): tfilenode;
begin
 result:= tunitnode.create(pnk_source,afilename);
end;

function tunitsnode.createsubnode: ttreelistitem;
begin
 result:= tunitnode.create(pnk_none,'');
end;

function tunitsnode.modulefilenames: filenamearty;
var
 int1,int2,int3: integer;
begin
 if fstatreading then begin
  result:= fmodulefilenames;
 end
 else begin
  int2:= 0;
  for int1:= 0 to fcount - 1 do begin
   with tfilenode(fitems[int1]) do begin
    for int3:= 0 to count - 1 do begin
     with tfilenode(items[int3]) do begin
      if fkind = pnk_form then begin
       additem(result,ffilename,int2);
      end;
     end;
    end;
   end;
  end;
  setlength(result,int2);
 end;
end;

function tunitsnode.modulenames: msestringarty;
var
 int1,int2,int3: integer;
begin
 if fstatreading then begin
  result:= fmodulenames;
 end
 else begin
  int2:= 0;
  for int1:= 0 to fcount - 1 do begin
   with tfilenode(fitems[int1]) do begin
    for int3:= 0 to count - 1 do begin
     with tformnode(items[int3]) do begin
      if fkind = pnk_form then begin
       additem(result,struppercase(fformname),int2);
      end;
     end;
    end;
   end;
  end;
  setlength(result,int2);
 end;
end;

function tunitsnode.moduleclassnames: msestringarty;
var
 int1,int2,int3: integer;
begin
 if fstatreading then begin
  result:= fmoduleclassnames;
 end
 else begin
  int2:= 0;
  for int1:= 0 to fcount - 1 do begin
   with tfilenode(fitems[int1]) do begin
    for int3:= 0 to count - 1 do begin
     with tformnode(items[int3]) do begin
      if fkind = pnk_form then begin
       additem(result,struppercase(fclasstype),int2);
      end;
     end;
    end;
   end;
  end;
  setlength(result,int2);
 end;
end;

{ tprojecttree }

constructor tprojecttree.create;
begin
 funits:= tunitsnode.create;
 ffiles:= tfilesnode.create;
end;

function tprojecttree.files: tfilesnode;
begin
 result:= ffiles;
end;

function tprojecttree.units: tunitsnode;
begin
 result:= funits;
end;

procedure tprojecttree.updatestat(const filer: tstatfiler);
begin
 if not filer.iswriter then begin
  funits.clear;
  ffiles.clear;
  funits.beginupdate;
  ffiles.beginupdate;
 end
 else begin
  funits.fmodulefilenames:= funits.modulefilenames;
  funits.fmodulenames:= funits.modulenames;
  funits.fmoduleclassnames:= funits.moduleclassnames;
 end;
 try
  funits.fstatreading:= true;
  try
   if filer.beginlist('units') then begin
    filer.updatevalue('modulefilenames',funits.fmodulefilenames);
    filer.updatevalue('modulenames',funits.fmodulenames);
    filer.updatevalue('moduleclassnames',funits.fmoduleclassnames);
    funits.dostatupdate(filer);
    filer.endlist;
   end;
  finally
   funits.fstatreading:= false;
  end;
  if filer.beginlist('files') then begin
   ffiles.dostatupdate(filer);
   filer.endlist;
  end;
 finally
  if not filer.iswriter then begin
   funits.endupdate;
   ffiles.endupdate;
  end;
 end;
end;

procedure tprojecttree.docellevent(const projectedit: ttreeitemedit;
                var info: celleventinfoty);
var
 node1,node2: ttreelistitem;
begin
 if iscellclick(info,[ccr_nodefaultzone,ccr_dblclick]) then begin
  if projectedit.item.treelevel > 0 then begin
   node1:= projectedit[info.cell.row];
   node2:= node1.rootnode;
   if node2 = funits then begin
    with tunitnode(node1) do begin
     case fkind of
      pnk_form: begin
       mainfo.openformfile(ffilename,true,true,true,true);
      end;
      pnk_source: begin
       sourcefo.openfile(ffilename,true);
      end;
     end;
    end;
   end
   else begin
    if node2 = ffiles then begin
     with tfilenode(node1) do begin
      sourcefo.openfile(ffilename);
     end;
    end;
   end;
  end;
 end;
end;

{ tprojecttreefo }

procedure tprojecttreefo.projecteditonstatreaditem(const sender: TObject;
                   const reader: tstatreader; var aitem: ttreelistitem);
var
 kind: projectnodety;
begin
 kind:= projectnodety(reader.readinteger('kind',ord(pnk_none),ord(low(projectnodety)),
                  ord(high(projectnodety))));
 case kind of
  pnk_form: begin
   aitem:= tformnode.create('');
  end;
  pnk_source,pnk_files: begin
   aitem:= tfilenode.create(kind,'');
  end;
 end;
end;

procedure tprojecttreefo.projecteditonupdaterowvalues(const sender: TObject;
            const aindex: Integer; const aitem: tlistitem);
begin
{
 if aitem is trecordfielditem then begin
  edit[aindex]:= trecordfielditem(aitem).valuetext;
 end
 else begin
  if aitem is tfilenode then begin
   edit[aindex]:= tfilenode(aitem).ffilename;
  end
  else begin
   edit[aindex]:= '';
  end;
 end;
 }
end;

procedure tprojecttreefo.projecttreefooncreate(const sender: tobject);
begin
 projecttree:= tprojecttree.create;
end;

procedure tprojecttreefo.projecttreefoonloaded(const sender: tobject);
begin
 projecttree.units.caption:= 'Units';
 projecttree.files.caption:= 'Files';
 projectedit.itemlist.add(ttreelistedititem(projecttree.units));
 projectedit.itemlist.add(ttreelistedititem(projecttree.files));
end;

procedure tprojecttreefo.clear;
begin
 projecttree.units.clear;
 projecttree.files.clear;
end;

procedure tprojecttreefo.projecttreefoondestroy(const sender: tobject);
begin
 projecttree.Free;
end;

procedure tprojecttreefo.projecteditonpopup(const sender: tobject;
  var amenu: tpopupmenu; var mouseinfo: mouseeventinfoty);
begin
 if projectedit.item.rootnode = projecttree.units then begin
  freeandnil(amenu);
  tpopupmenu.additems(amenu,self,mouseinfo,unitpopup);
 end;
end;

procedure tprojecttreefo.addunitfileonexecute(const sender: tobject);
begin
 mainfo.opensource(fk_unit,true,false);
 activate; //windowmanager can activate new form window
end;

procedure tprojecttreefo.removeunitfileonexecute(const sender: tobject);
begin
 with tfilenode(projectedit.item) do begin
  if askok('Do you wish to remove "'+ ffilename +
            '"?','') then begin
   if sourcefo.closepage(ffilename) then begin
    projectedit.item.Free;
   end;
  end;
 end;
end;

procedure tprojecttreefo.projecttreeonupdatestat(const sender: tobject;
  const filer: tstatfiler);
begin
// projecttree.updatestat(filer);
end;

procedure tprojecttreefo.projecteditoncellevent(const sender: tobject;
  var info: celleventinfoty);
begin
 projecttree.docellevent(projectedit,info);
end;

procedure tprojecttreefo.itemoncheckrowmove(const curindex: Integer; const newindex: Integer;
                    var accept: Boolean);
var
 source,dest: ttreelistitem;
begin
 source:= projectedit[curindex];
 dest:= projectedit[newindex];
 if (source.treelevel = 1) and (dest.treelevel = 1) and
                (source.parent = dest.parent) then begin
  accept:= true;
 end;
end;

procedure tprojecttreefo.unitpopuponupdate(const sender: tcustommenu);
begin
 removeunitfileact.enabled:= projectedit.item.treelevel = 1;
end;

procedure tprojecttreefo.projecteditonchange(const sender: TObject);
begin
// updatesubmodules;
end;

procedure tprojecttreefo.gridondragbegin(const sender: TObject; const apos: pointty;
           var dragobject: tdragobject; var processed: Boolean);
begin
 if projectedit.candragsource(translateclientpoint(apos,grid,projectedit)) then begin
  ttagdragobject.create(self,dragobject,nullpoint,grid.cellatpos(apos).row);
 end;
end;

procedure tprojecttreefo.gridondragover(const sender: TObject; const apos: pointty;
        var dragobject: tdragobject; var accept: Boolean; var processed: Boolean);
var
 cell1: gridcoordty;
begin
 if dragobject is ttagdragobject then begin
  processed:= true;
  if grid.editwidgetatpos(apos,cell1) = projectedit then begin
   itemoncheckrowmove(ttagdragobject(dragobject).tag,cell1.row,accept);
  end;
 end;
end;

procedure tprojecttreefo.gridonderagdrop(const sender: TObject; const apos: pointty;
                        var dragobject: tdragobject; var processed: Boolean);
begin
 grid.moverow(ttagdragobject(dragobject).tag,grid.cellatpos(apos).row);
end;

end.

