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
unit projecttreeform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

//todo: relative path linking

interface
uses
 mseforms,msewidgetgrid,mselistbrowser,msedatanodes,msetypes,msemenus,mseevent,
 mseactions,msefiledialog,msestat,msegrids,msedesigner,msedataedits,
 msegraphutils,msegui,msestrings,mseact,mseguiglob,mseclasses,msebitmap,mseedit,
 mseglob,msegraphics,msescrollbar,msesys,msehash,mseifiglob;

type
 projectnodety = (pnk_none,pnk_source,pnk_form,pnk_files,pnk_dir);
const
 filenodes = [pnk_source,pnk_dir,pnk_form];
type
 tdirnode = class;
 tprojecttreefo = class(tdockform)
   grid: twidgetgrid;
   projectedit: ttreeitemedit;
   edit: trecordfieldedit;
   unitpopup: tpopupmenu;
   addunitfileact: taction;
   removeunitfileact: taction;
   filedialog: tfiledialog;
   filepopup: tpopupmenu;
   addfileact: taction;
   removefileact: taction;
   cmodulepopup: tpopupmenu;
   removecmoduleact: taction;
   addcmoduleact: taction;
   cmoduledialog: tfiledialog;
   adddiract: taction;
   removediract: taction;
   nodeicons: timagelist;
   dummyimage: timagelist;
   editdiract: taction;
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

   procedure addunitfileonexecute(const sender: tobject);
   procedure removeunitfileonexecute(const sender: tobject);

   procedure projecttreeonupdatestat(const sender: tobject;
                const filer: tstatfiler);
   procedure projecteditoncellevent(const sender: tobject; 
                var info: celleventinfoty);

   procedure itemoncheckrowmove(const curindex: Integer; const newindex: Integer;
                    var accept: Boolean);

   procedure addfileexe(const sender: TObject);
   procedure editdragbegin(const sender: ttreeitemedit;
                   const aitem: ttreelistitem; var candrag: Boolean;
                   var dragobject: ttreeitemdragobject; var processed: Boolean);
   procedure editdragover(const sender: ttreeitemedit;
                   const source: ttreelistitem; const dest: ttreelistitem;
                   var dragobject: ttreeitemdragobject; var accept: Boolean;
                   var processed: Boolean);
   procedure editdragrop(const sender: ttreeitemedit;
                   const source: ttreelistitem; const dest: ttreelistitem;
                   var dragobject: ttreeitemdragobject; var processed: Boolean);
   procedure editoncellevent(const sender: TObject; var info: celleventinfoty);
   procedure removefileonexecute(const sender: TObject);
   procedure addcmoduleonexecute(const sender: TObject);
   procedure removecmoduleonexecute(const sender: TObject);
   procedure adddirexe(const sender: TObject);
   procedure receditdialogexe(const sender: TObject);
   procedure gridcellevent(const sender: TObject; var info: celleventinfoty);
   procedure edithintexe(const sender: TObject; var info: hintinfoty);
   procedure colshowhintexe(const sender: tdatacol; const arow: Integer;
                   var info: hintinfoty);
   procedure updateremdirexe(const sender: tcustomaction);
   procedure updateadddirexe(const sender: tcustomaction);
   procedure remdirexe(const sender: TObject);
   procedure remfileupdateexe(const sender: tcustomaction);
   procedure udateeditdirexe(const sender: tcustomaction);
   procedure editdirexe(const sender: TObject);
   procedure captionset(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
  private
   funitloading: boolean;
  protected
   function addirectory(const aname: filenamety): tdirnode;
   function gettreedir: filenamety;
  public
   procedure clear;
 end;

 tprojectnode = class(ttreelistedititem)
   fkind: projectnodety;
   ferror: boolean;
  protected
   function getcurrentimagenr: integer; virtual;
   function compare(const l,r: ttreelistitem): integer; override;
  public
   constructor create(const akind: projectnodety); reintroduce;
 end;

 tfilenode = class(tprojectnode)
  private
   ffilename: filenamety;
   fpath: filenamety;
   fmodified: boolean;
  protected
   function getcurrentimagenr: integer; override;
   procedure setfilename(const value: filenamety); virtual;
   function parentpath: msestring;
   procedure updatepath;
  public
   constructor create(const akind: projectnodety);
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
   function getvaluetext: msestring; override;

   property filename: filenamety read ffilename write setfilename;
   property path: filenamety read fpath;
 end;

 tdirnode = class(tfilenode)
  protected
   fcustomcaption: msestring;
   procedure setfilename(const value: filenamety); override;
   function getcurrentimagenr: integer; override;
   function calccaption: msestring;
  public
   constructor create;
   procedure setvaluetext(var avalue: msestring); override;
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
 end;
 
 tcmodulenode = class(tfilenode)
 end;
 
 tformnode = class(tfilenode,irecordfield)
  private
   fclasstype: msestring;
   fformname: msestring;
   finstancevarname: msestring;
  protected
   function getcurrentimagenr: integer; override;
   procedure setfilename(const value: filenamety); override;
   function getfieldtext(const fieldindex: integer): msestring;
   procedure setfieldtext(const fieldindex: integer; var avalue: msestring);
  public
   constructor create;
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
 end;

 tunitnode = class(tfilenode)
  private
   fformfile: tformnode;
  protected
   function getcurrentimagenr: integer; override;
  public
   procedure dostatread(const reader: tstatreader); override;
   function setformfile(afilename: filenamety): tformnode;
 end;

 tprojectrootnode = class(tprojectnode)
  public
   function getvaluetext: msestring; override;
 end;

 tfilenodehashlist = class(tpointermsestringhashdatalist)
 end;

 tnamehashlist = class(tpointeransistringhashdatalist)
 end;
 
 tfilesnode = class(tprojectrootnode)
  private
   fhashlist: tfilenodehashlist;
   fchangedcount: integer;
  protected
   function getcurrentimagenr: integer; override;
   function createsubnode: ttreelistitem; override;
   function createnode: tfilenode; virtual;
   procedure removefilehash(const anode: tfilenode); virtual;
   procedure addfilehash(const anode: tfilenode); virtual;
  public
   constructor create;
   destructor destroy; override;
   procedure clear; override;
   procedure loadlist; virtual;
   function addfile(const currentnode: tprojectnode;
                             const afilename: filenamety): tfilenode;
   procedure addfiles(const currentnode: tprojectnode;
                                 const afilenames: filenamearty);
   procedure removefile(const anode: tfilenode);
   function findfile(const filename: filenamety): tfilenode;
 end;

 tunitsnode = class(tfilesnode)
  private
//   fmoduleclassnames: filenamearty;
//   fmodulenames: filenamearty;
//   fmodulefilenames: filenamearty;
//   fstatreading: boolean;
   fnamelist: tnamehashlist;
   fclasstypelist: tnamehashlist;   
  protected
   function createsubnode: ttreelistitem; override;
   function createnode: tfilenode; override;
   procedure removefilehash(const anode: tfilenode); override;
   procedure addfilehash(const anode: tfilenode); override;
  public
   constructor create;
   destructor destroy; override;
   procedure clear; override;
   procedure loadlist; override;
   function addfile(const currentnode: tprojectnode; 
                                      const afilename: filenamety): tunitnode;
//   function moduleclassnames: msestringarty;
//   function modulenames: msestringarty;
//   function modulefilenames(const aname: string): filenamearty;
   function findformbyname(const aname: string;
                                    out afilename: filenamety): boolean;
   function findformbyclass(const aclassname: string;
                                    out afilename: filenamety): boolean;
 end;

 stopcheckprocty = procedure (var astop: boolean) of object;
 tcmodulesnode = class(tfilesnode)
  protected
   function createsubnode: ttreelistitem; override;
   function createnode(const afilename: filenamety): tfilenode; 
                                                reintroduce; virtual;
  public
   constructor create;
   procedure parse(const astopcheckproc: stopcheckprocty = nil);
   procedure modulechanged(const aname: filenamety);
   procedure modulecompiled(const aname: filenamety);
 end;
 
 tprojecttree = class
  private
   funits: tunitsnode;
   fcmodules: tcmodulesnode;
   ffiles: tfilesnode;
   procedure docellevent(const projectedit: ttreeitemedit;
                    var info: celleventinfoty);
  protected
  public
   constructor create;
   function units: tunitsnode;
   function cmodules: tcmodulesnode;
   function files: tfilesnode;
   procedure updatestat(const filer: tstatfiler);
   procedure updatelist;
 end;

var
 projecttreefo: tprojecttreefo;
 projecttree: tprojecttree;

function isformfile(const aname: filenamety): boolean;

implementation
uses
 sysutils,projecttreeform_mfm,msefileutils,main,sourceform,msewidgets,
 msedatalist,msedrag,sourceupdate,msesysenv,projectoptionsform;
const
 unitscaption = 'Pascal Units';
 cmodulescaption = 'C Modules';
 filescaption = 'Text Files';
 mainico = -1;
 fileico = 0;
 unitico = 2;
 formico = 4;
 dirico = 6;
 
function isformfile(const aname: filenamety): boolean;
begin
 result:= issamefilename(aname,replacefileext(aname,formfileext));
end;

{ tprojectnode }

constructor tprojectnode.create(const akind: projectnodety);
begin
 fkind:= akind;
 inherited create;
 include(fstate1,ns1_customsort);
 fstate:= fstate + [ns_sorted];
end;

function tprojectnode.compare(const l: ttreelistitem;
               const r: ttreelistitem): integer;
begin
 result:= 0;
 if tprojectnode(l).fkind = pnk_dir then begin
  dec(result);
 end;
 if tprojectnode(r).fkind = pnk_dir then begin
  inc(result);
 end;
 if result = 0 then begin
  result:= msestringicomp(l.caption,r.caption);
 end;
end;

function tprojectnode.getcurrentimagenr: integer;
begin
 result:= -1;
end;

{ tfilenode }

constructor tfilenode.create(const akind: projectnodety);
begin
 fkind:= akind;
 inherited create(akind);
// filename:= afilename;
 include(fstate,ns_readonly);
end;

procedure tfilenode.dostatread(const reader: tstatreader);
begin
 ffilename:= reader.readmsestring('file',ffilename);
// ffilenamerel:= reader.readmsestring('filerel',ffilename);
// tfilesnode(rootnode).fhashlist.add(ffilename,self);
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
 ffilename:= relativepath(value,parentpath);
 if fkind <> pnk_dir then begin
  caption:= msefileutils.filename(value);
 end;
 with tfilesnode(rootnode) do begin
  removefilehash(self);
  self.updatepath;
  addfilehash(self);
 end;
end;

function tfilenode.getvaluetext: msestring;
begin
 result:= ffilename;
end;
{
function tfilenode.getpath: filenamety;
begin
 result:= ffilename;
end;
}
function tfilenode.parentpath: msestring;
var
 n1: tprojectnode;
begin
 n1:= self;
 repeat
  n1:= tprojectnode(n1.fparent);
 until (n1 = nil) or (n1.fkind = pnk_dir);
 if n1 <> nil then begin
  result:= tfilenode(n1).path;
 end
 else begin
  result:= msegetcurrentdir;
 end;
end;

procedure tfilenode.updatepath;
var
 mstr1,mstr2: msestring;
begin
 mstr1:= filename;
 if fkind = pnk_dir then begin
  expandprmacros1(mstr1);    
 end;
 mstr2:= parentpath;
 fpath:= filepath(mstr2,mstr1);
 case fkind of
  pnk_dir: begin
   with tdirnode(self) do begin
    if fcustomcaption <> '' then begin
     caption:= fcustomcaption;
    end
    else begin
     if (mstr1 <> '') and (mstr1[1] = '/') then begin
      caption:= fpath;
     end
     else begin
      caption:= relativepath(fpath,mstr2);
     end;
    end;
   end;
  end;
  pnk_source,pnk_form: begin
   caption:= msefileutils.filename(fpath);
  end;
 end;
end;

function tfilenode.getcurrentimagenr: integer;
begin
 result:= fileico;
end;

{ tformnode }

constructor tformnode.create;
begin
 inherited create(pnk_form);
 include(fstate,ns_nosubnodestat);
// filename:= afilename;
 add(trecordfielditem.create(irecordfield(self),0,'classtype',-1,
                                 projecttreefo.dummyimage));
 add(trecordfielditem.create(irecordfield(self),1,'name',-1,
                                 projecttreefo.dummyimage));
 add(trecordfielditem.create(irecordfield(self),2,'instancevarname',-1,
                                 projecttreefo.dummyimage));
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
   po1:= mainfo.openformfile(value,false,false,false,true,false);
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
var
 n1: tfilesnode;
begin
 n1:= tfilesnode(rootnode);
 n1.removefilehash(self);
 case fieldindex of
  0: begin
   fclasstype:= designer.changemoduleclassname(fpath,avalue);
   avalue:= fclasstype;
  end;
  1: begin
   fformname:= designer.changemodulename(fpath,avalue);
   avalue:= fformname;
  end;
  2: begin
   finstancevarname:= designer.changeinstancevarname(fpath,avalue);
   avalue:= finstancevarname;
  end;
 end;
 n1.addfilehash(self);
end;

function tformnode.getcurrentimagenr: integer;
begin
 result:= formico;
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

function tunitnode.getcurrentimagenr: integer;
begin
 result:= fileico;
 if fcount > 0 then begin
  result:= unitico;
 end;
end;

function tunitnode.setformfile(afilename: filenamety): tformnode;
begin
 if afilename = '' then begin
  fformfile:= nil;
  clear;
 end
 else begin
  if fformfile = nil then begin
   fformfile:= tformnode.create;
   add(ttreelistitem(fformfile));
  end;
  fformfile.filename:= afilename;
 end;
 result:= fformfile;
 imagenr:= getcurrentimagenr;
end;

{ tprojectrootnode }

function tprojectrootnode.getvaluetext: msestring;
begin
 result:= '';
end;

{ tfilesnode }

constructor tfilesnode.create;
begin
 fhashlist:= tfilenodehashlist.create;
 inherited create(pnk_files);
 fstate:= fstate + [ns_readonly,ns_drawemptybox];
 caption:= filescaption;
end;

destructor tfilesnode.destroy;
begin
 inherited;
 fhashlist.free;
end;

function tfilesnode.addfile(const currentnode: tprojectnode;
                                   const afilename: filenamety): tfilenode;
var
 n1: tprojectnode;
 ind1: integer;
begin
 result:= findfile(afilename);
 if result = nil then begin
  projecttreefo.projectedit.itemlist.beginupdate;
  n1:= currentnode;
  if n1 <> nil then begin
   ind1:= n1.count;
  end;  
  while (n1 <> nil) and (n1.fkind <> pnk_dir) do begin
   ind1:= n1.parentindex;
   n1:= tprojectnode(n1.parent);
  end;
  if (n1 = nil) then begin
   n1:= self;
   ind1:= count;   
  end;
  result:= createnode;   
  n1.insert(result,ind1);
  result.filename:= afilename;
  fhashlist.add(result.fpath,result);
  inc(fchangedcount);
  projecttreefo.projectedit.itemlist.endupdate;
 end;
end;

procedure tfilesnode.removefilehash(const anode: tfilenode);
begin
 if anode.fkind <> pnk_dir then begin
  fhashlist.delete(anode.fpath,anode);
 end;
end;

procedure tfilesnode.addfilehash(const anode: tfilenode);
begin
 if anode.fkind <> pnk_dir then begin
  fhashlist.add(anode.fpath,anode);
 end;
end;

procedure tfilesnode.addfiles(const currentnode: tprojectnode;
                                     const afilenames: filenamearty);
var
 int1: integer;
begin
 beginupdate;
 try
  for int1:= 0 to high(afilenames) do begin
   addfile(currentnode,afilenames[int1]);
  end;
 finally
  endupdate;
 end;
end;

procedure tfilesnode.removefile(const anode: tfilenode);
var
 int1: integer;
begin
 with anode do begin
  if fkind <> pnk_dir then begin
   if fmodified then begin
    dec(fchangedcount);
   end;
   removefilehash(anode);
  end;
  for int1:= 0 to count - 1 do begin
   if tprojectnode(fitems[int1]).fkind in [pnk_source,pnk_dir] then begin
    removefile(tfilenode(fitems[int1]));
   end;
  end;
 end;
// fhashlist.delete(anode.fpath,anode);
end;

function tfilesnode.findfile(const filename: filenamety): tfilenode;
//var
// int1: integer;
begin
 result:= tfilenode(fhashlist.find(filename));
end;

function tfilesnode.createnode: tfilenode;
begin
 result:= tfilenode.create(pnk_source);
end;

function tfilesnode.createsubnode: ttreelistitem;
begin
 result:= tfilenode.create(pnk_none);
end;

procedure tfilesnode.clear;
begin
 fhashlist.clear;
 inherited;
 fchangedcount:= 0;
end;

procedure tfilesnode.loadlist;
var
 li: tmacrolist;

 procedure scan(const anode: tprojectnode; const apath: filenamety);
 var
  int1: integer;
  mstr1: filenamety;
 begin
  with tfilenode(anode) do begin
   if fkind in filenodes then begin
    mstr1:= filename;
    if fkind = pnk_dir then begin
     li.expandmacros(mstr1);    
    end;
    fpath:= filepath(apath,mstr1);
    case fkind of
     pnk_dir: begin
      with tdirnode(anode) do begin
       if fcustomcaption <> '' then begin
        fcaption:= fcustomcaption;
       end
       else begin
        if (mstr1 <> '') and (mstr1[1] = '/') then begin
         fcaption:= fpath;
        end
        else begin
         fcaption:= relativepath(fpath,apath);
        end;
       end;
      end;
      for int1:= 0 to fcount-1 do begin
       scan(tprojectnode(fitems[int1]),fpath);
      end;
     end;
     pnk_source,pnk_form: begin
//      fhashlist.add(fpath,anode);
      addfilehash(tfilenode(anode));
      if fkind = pnk_source then begin
       for int1:= 0 to fcount-1 do begin
        scan(tprojectnode(fitems[int1]),apath);
       end;
      end;
     end;
    end;
   end;
  end;
  anode.imagenr:= anode.getcurrentimagenr;
 end; //scan

var
 int1: integer;
 mstr1: msestring;

begin
 li:= getmacros;
 beginupdate;
 try
  fhashlist.clear;
  mstr1:= msegetcurrentdir;
  for int1:= 0 to fcount-1 do begin
   scan(tprojectnode(fitems[int1]),mstr1);
  end;
  imagenr:= getcurrentimagenr;
 finally
  fchangedcount:= fhashlist.count;
  li.Free;
  endupdate;
 end;
end;

function tfilesnode.getcurrentimagenr: integer;
begin
 result:= dirico;
end;

{ tunitsnode }

constructor tunitsnode.create;
begin
 inherited create;
 caption:= unitscaption;
 fnamelist:= tnamehashlist.create;
 fclasstypelist:= tnamehashlist.create;
end;

destructor tunitsnode.destroy;
begin
 inherited;
 fnamelist.free;
 fclasstypelist.free;
end;

function tunitsnode.addfile(const currentnode: tprojectnode;
                                 const afilename: filenamety): tunitnode;
begin
 result:= tunitnode(inherited addfile(currentnode,afilename));
end;

function tunitsnode.createnode: tfilenode;
begin
 result:= tunitnode.create(pnk_source);
end;

function tunitsnode.createsubnode: ttreelistitem;
begin
 result:= tunitnode.create(pnk_none);
end;

function tunitsnode.findformbyclass(const aclassname: string;
                                    out afilename: filenamety): boolean;
var
 n1: tformnode;
begin
 afilename:= '';
 result:= fclasstypelist.find(aclassname,pointer(n1));
 if result then begin
  afilename:= n1.path;
 end;
end;

function tunitsnode.findformbyname(const aname: string;
                                    out afilename: filenamety): boolean;
var
 n1: tformnode;
begin
 afilename:= '';
 result:= fnamelist.find(aname,pointer(n1));
 if result then begin
  afilename:= n1.path;
 end;
end;

procedure tunitsnode.clear;
begin
 fnamelist.clear;
 fclasstypelist.clear;
 inherited;
end;

procedure tunitsnode.removefilehash(const anode: tfilenode);
begin
 if anode.fkind = pnk_form then begin
  with tformnode(anode) do begin
   fnamelist.delete(struppercase(string(fformname)),anode);
   fclasstypelist.delete(struppercase(string(fclasstype)),anode);
  end;
 end;
 inherited;
end;

procedure tunitsnode.addfilehash(const anode: tfilenode);
begin
 if anode.fkind = pnk_form then begin
  with tformnode(anode) do begin
   fnamelist.add(struppercase(string(fformname)),anode);
   fclasstypelist.add(struppercase(string(fclasstype)),anode);
  end;
 end;
end;

procedure tunitsnode.loadlist;
begin
 fnamelist.clear;
 fclasstypelist.clear;
 inherited;
end;

{
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
}
{ tcmodulesnode }

constructor tcmodulesnode.create;
begin
 inherited;
 caption:= cmodulescaption;
end;

procedure tcmodulesnode.parse(const astopcheckproc: stopcheckprocty);
var
 int1,int2: integer;
 bo1: boolean;
begin
 if fchangedcount > 0 then begin
  application.beginwait;
  try
   bo1:= false;
   for int1:= 0 to count - 1 do begin
    with tcmodulenode(fitems[int1]) do begin
     if fmodified then begin
      if application.waitescaped then begin
       break;
      end;
      sourceupdater.updatesourceunit(ffilename,int2,false);
     end;
    end;
    if {$ifndef FPC}@{$endif}astopcheckproc <> nil then begin
     astopcheckproc(bo1);
     if bo1 then begin
      break;
     end;
    end;
   end;
  finally
   application.endwait;
  end;
 end;
end;

function tcmodulesnode.createsubnode: ttreelistitem;
begin
 result:= tcmodulenode.create(pnk_none);
end;

function tcmodulesnode.createnode(const afilename: filenamety): tfilenode;
begin
 result:= tcmodulenode.create(pnk_source);
end;

procedure tcmodulesnode.modulechanged(const aname: filenamety);
var
 node1: tcmodulenode;
begin
 node1:= tcmodulenode(fhashlist.find(aname));
 if (node1 <> nil) and not node1.fmodified then begin
  node1.fmodified:= true;
  inc(fchangedcount);
 end;
end;

procedure tcmodulesnode.modulecompiled(const aname: filenamety);
var
 node1: tcmodulenode;
begin
 node1:= tcmodulenode(fhashlist.find(aname));
 if (node1 <> nil) and node1.fmodified then begin
  node1.fmodified:= false;
  dec(fchangedcount);
 end;
end;

{ tprojecttree }

constructor tprojecttree.create;
begin
 funits:= tunitsnode.create;
 fcmodules:= tcmodulesnode.create;
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

function tprojecttree.cmodules: tcmodulesnode;
begin
 result:= fcmodules;
end;

procedure tprojecttree.updatelist;
begin
 funits.loadlist;
 fcmodules.loadlist;
 ffiles.loadlist;
 projecttreefo.grid.invalidate;
end;

procedure tprojecttree.updatestat(const filer: tstatfiler);

 procedure scan(const anode: tprojectnode);
 var
  int1: integer;
 begin
  with anode do begin
   if fkind = pnk_form then begin
    with tformnode(anode) do begin
     funits.fnamelist.add(struppercase(string(fformname)),anode);
     funits.fclasstypelist.add(struppercase(string(fclasstype)),anode);
    end;
   end;
   for int1:= 0 to count-1 do begin
    scan(tprojectnode(fitems[int1]));
   end;
  end;
 end;
 
begin
 if not filer.candata then begin
  exit;
 end;
 if not filer.iswriter then begin
  funits.clear;
  fcmodules.clear;
  ffiles.clear;
 end;
 projecttreefo.projectedit.itemlist.beginupdate;
 try
  projecttreefo.funitloading:= true;
  projecttreefo.projectedit.itemlist.updatenode('units',filer,funits);
  scan(funits);
  projecttreefo.funitloading:= false;
  projecttreefo.projectedit.itemlist.updatenode('cmodules',filer,fcmodules);
  projecttreefo.projectedit.itemlist.updatenode('files',filer,ffiles);
  funits.caption:= unitscaption;
  fcmodules.caption:= cmodulescaption;
  ffiles.caption:= filescaption;
 finally
  projecttreefo.projectedit.itemlist.endupdate;
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
       mainfo.openformfile(fpath,true,true,true,true,false);
      end;
      pnk_source: begin
       sourcefo.openfile(fpath,true);
      end;
     end;
    end;
   end
   else begin
    if (node2 = ffiles) or (node2 = fcmodules) then begin
     with tfilenode(node1) do begin
      if fkind <> pnk_dir then begin
       sourcefo.openfile(fpath,true);
      end;
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
   aitem:= tformnode.create;
  end;
  pnk_source: begin
   if funitloading then begin
    aitem:= tunitnode.create(kind);
   end
   else begin
    aitem:= tfilenode.create(kind);
   end;
  end;
  pnk_dir: begin
   aitem:= tdirnode.create;
  end;
 end;
end;

function tprojecttreefo.addirectory(const aname: filenamety): tdirnode;
var
 n2: tprojectnode;
begin
 result:= tdirnode.create;
 result.filename:= relativepath(aname,gettreedir);
 n2:= tprojectnode(projectedit.item);
 if (n2.fkind = pnk_dir) or (n2.parent = nil) then begin
  n2.insert(result,0);
 end
 else begin
  while (n2.treelevel > 1) and
                     (tprojectnode(n2.parent).fkind <> pnk_dir) do begin
   n2:= tprojectnode(n2.parent);
  end;
  n2.parent.insert(result,n2.parentindex);
 end;
 tfilesnode(n2.rootnode).loadlist;
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
 projecttree.units.caption:= unitscaption;
 projecttree.files.caption:= filescaption;
 projecttree.cmodules.caption:= cmodulescaption;
 projectedit.itemlist.add(ttreelistedititem(projecttree.units));
 projectedit.itemlist.add(ttreelistedititem(projecttree.cmodules));
 projectedit.itemlist.add(ttreelistedititem(projecttree.files));
end;

procedure tprojecttreefo.clear;
begin
 projecttree.units.clear;
 projecttree.files.clear;
 projecttree.cmodules.clear;
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
 end
 else begin
  if projectedit.item.rootnode = projecttree.files then begin
   freeandnil(amenu);
   tpopupmenu.additems(amenu,self,mouseinfo,filepopup);
  end
  else begin
   if projectedit.item.rootnode = projecttree.cmodules then begin
    freeandnil(amenu);
    tpopupmenu.additems(amenu,self,mouseinfo,cmodulepopup);
   end;
  end;
 end;
end;

procedure tprojecttreefo.addunitfileonexecute(const sender: tobject);
begin
 mainfo.openfile.controller.filename:= gettreedir;
 mainfo.opensource(fk_unit,true,false,tprojectnode(projectedit.item));
 activate; //windowmanager can activate new form window
end;

procedure tprojecttreefo.removeunitfileonexecute(const sender: tobject);
var
 rowbefore: integer;
 rnode: ttreelistitem;
begin
 with tfilenode(projectedit.item) do begin
  if askok('Do you wish to remove "'+ ffilename +
            '"?','') then begin
   if sourcefo.closepage(fpath) then begin
    rowbefore:= grid.row;
    rnode:= rootnode;
    if rnode is tfilesnode then begin
     tfilesnode(rnode).removefile(tfilenode(projectedit.item));
    end;
    projectedit.item.Free;
    grid.row:= rowbefore;
   end;
  end;
 end;
end;

procedure tprojecttreefo.addcmoduleonexecute(const sender: TObject);
begin
 cmoduledialog.controller.filename:= gettreedir;
 if cmoduledialog.execute = mr_ok then begin
  projecttree.cmodules.addfiles(tprojectnode(projectedit.item),
                                  cmoduledialog.controller.filenames);
 end;
end;

procedure tprojecttreefo.removecmoduleonexecute(const sender: TObject);
begin
 removeunitfileonexecute(sender);
end;

procedure tprojecttreefo.addfileexe(const sender: TObject);
begin
 with mainfo.openfile do begin
  controller.filename:= gettreedir;
  if execute = mr_ok then begin
   projecttree.files.addfiles(tprojectnode(projectedit.item),
                                                        controller.filenames);
  end;
 end;
end;

procedure tprojecttreefo.adddirexe(const sender: TObject);
var
 int1: integer;
begin
 with mainfo.openfile.controller do begin
  filename:= gettreedir;
  if execute(fdk_open,'Select Directory',[fdo_directory]) = mr_ok then begin
   int1:= addirectory(filename).index;
   if int1 >= 0 then begin
    grid.row:= int1;
   end;
  end;
 end;
end;

procedure tprojecttreefo.remdirexe(const sender: TObject);
 
begin
 if askyesno('Do you want to remove '+lineend+
    tfilenode(projectedit.item).fpath+lineend+
    'with the sub-items from project?') then begin
  tfilesnode(projectedit.item.rootnode).removefile(tdirnode(projectedit.item));
  projectedit.item.free;
 end;
end;

procedure tprojecttreefo.removefileonexecute(const sender: TObject);
begin
 removeunitfileonexecute(sender);
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

procedure tprojecttreefo.editoncellevent(const sender: TObject;
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

procedure tprojecttreefo.projecteditonchange(const sender: TObject);
begin
// updatesubmodules;
end;

procedure tprojecttreefo.editdragbegin(const sender: ttreeitemedit;
               const aitem: ttreelistitem; var candrag: Boolean;
               var dragobject: ttreeitemdragobject; var processed: Boolean);
begin
 candrag:= aitem.treelevel = 1;
end;

procedure tprojecttreefo.editdragover(const sender: ttreeitemedit;
               const source: ttreelistitem; const dest: ttreelistitem;
               var dragobject: ttreeitemdragobject; var accept: Boolean;
               var processed: Boolean);
begin
 accept:= source.parent = dest.parent;
end;

procedure tprojecttreefo.editdragrop(const sender: ttreeitemedit;
               const source: ttreelistitem; const dest: ttreelistitem;
               var dragobject: ttreeitemdragobject; var processed: Boolean);
begin
 sender.dragdrop(dragobject);
end;

procedure tprojecttreefo.receditdialogexe(const sender: TObject);
var
 fn1: filenamety;
 no1: tfilenode;
begin
 no1:= tfilenode(projectedit.item);
 fn1:= no1.path;
 with mainfo.openfile.controller do begin
  if execute(fn1,fdk_open,'Select Directory',[fdo_directory]) then begin
   no1.filename:= relativepath(fn1,no1.parentpath);
  end;
 end;
end;

procedure tprojecttreefo.gridcellevent(const sender: TObject;
               var info: celleventinfoty);
begin
 if isrowenter(info) then begin
  edit.frame.buttons[1].visible:= 
                            tprojectnode(projectedit.item).fkind = pnk_dir;
 end;
 if isrowexit(info) then begin
  projectedit.readonly:= true;
 end;
end;

procedure tprojecttreefo.colshowhintexe(const sender: tdatacol;
               const arow: Integer; var info: hintinfoty);
begin
 if projectedit.items[arow] is tfilenode then begin
  info.caption:= tfilenode(projectedit.items[arow]).path;
 end;
end;

procedure tprojecttreefo.edithintexe(const sender: TObject;
               var info: hintinfoty);
begin
 if projectedit.item is tfilenode then begin
  info.caption:= tfilenode(projectedit.item).path;
 end;
end;

function tprojecttreefo.gettreedir: filenamety;
var
 n1: tprojectnode;
begin
 result:= '';
 n1:= tprojectnode(projectedit.item);
 while (n1 <> nil) and not (n1.fkind in [pnk_dir,pnk_source]) do begin
  n1:= tprojectnode(n1.parent);
 end;
 if n1 <> nil then begin
  case n1.fkind of
   pnk_dir: begin
    result:= tfilenode(n1).path;
   end;
   pnk_source: begin
    result:= tfilenode(n1).parentpath;
   end;
  end;
 end;
 if result = '' then begin
  result:= msegetcurrentdir;
 end;
end;

procedure tprojecttreefo.updateremdirexe(const sender: tcustomaction);
begin
 sender.enabled:= (projectedit.item <> nil) and 
                    (tprojectnode(projectedit.item).fkind = pnk_dir);
end;

procedure tprojecttreefo.updateadddirexe(const sender: tcustomaction);
begin
 sender.enabled:= (projectedit.item <> nil) and 
     (tprojectnode(projectedit.item).fkind in [pnk_source,pnk_dir,pnk_files]);
end;

procedure tprojecttreefo.remfileupdateexe(const sender: tcustomaction);
begin
 sender.enabled:= tprojectnode(projectedit.item).fkind = pnk_source;
end;

procedure tprojecttreefo.udateeditdirexe(const sender: tcustomaction);
begin
 sender.enabled:= tprojectnode(projectedit.item).fkind = pnk_dir;
end;

procedure tprojecttreefo.editdirexe(const sender: TObject);
begin
 projectedit.readonly:= false;
 projectedit.beginedit;
end;

procedure tprojecttreefo.captionset(const sender: TObject;
               var avalue: msestring; var accept: Boolean);
begin
 if projectedit.item is tdirnode then begin
  with tdirnode(projectedit.item) do begin
   fcustomcaption:= avalue;
   if avalue = '' then begin
    avalue:= calccaption;
   end;
  end;
 end;
end;

{ tdirnode }

constructor tdirnode.create;
begin
 inherited create(pnk_dir);
 exclude(fstate,ns_readonly);
end;

procedure tdirnode.setvaluetext(var avalue: msestring);
begin
 setfilename(avalue);
end;

procedure tdirnode.setfilename(const value: filenamety);
begin
 ffilename:= value;
 if fowner <> nil then begin
  tfilesnode(rootnode).loadlist;
 end;
 if fparent <> nil then begin
  fparent.sort(false);
 end;
end;

function tdirnode.getcurrentimagenr: integer;
begin
 result:= dirico;
end;

procedure tdirnode.dostatread(const reader: tstatreader);
begin
 fcustomcaption:= reader.readmsestring('capt','');
 inherited;
end;

procedure tdirnode.dostatwrite(const writer: tstatwriter);
begin
 writer.writemsestring('capt',fcustomcaption);
 inherited;
end;

function tdirnode.calccaption: msestring;
begin
 result:= filename;
 expandprmacros(result);
 if (result <> '') and (result[1] = '/') then begin
  result:= fpath;
 end
 else begin
  result:= relativepath(fpath,parentpath);
 end;
end;

end.

