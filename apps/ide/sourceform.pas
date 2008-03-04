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
unit sourceform;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 msetextedit,msewidgetgrid,mseforms,Classes,msegdbutils,msegraphedits,mseevent,
 msehash,msebitmap,msetabs,sourcepage,mseglob,
 msetypes,msestrings,mseguiglob,msegui,msesyntaxpainter,msemenus,
 mseactions,msesyntaxedit,msestat,finddialogform,msestream,msefilechange,
 breakpointsform,mseparser,msesimplewidgets,msegrids,msegraphutils,
 mseact;

type
 tsourcefo = class;

 tnaviglist = class(tsourceposlist)
  private
   fsourcefo: tsourcefo;
   findex: integer;
   procedure updateshowpos(const acellpos: cellpositionty = cep_rowcenteredif);
  public
   constructor create;
   procedure showsource(const apos: sourceposty; const asetfocus: boolean = false);
   function back: boolean;
   function forward: boolean;
 end;

 tsourcefo = class(tdockform)
   completeclassact: taction;
   tpopupmenu1: tpopupmenu;
   tabwidget: ttabwidget;
   syntaxpainter: tsyntaxpainter;
   imagelist: timagelist;
   filechangenotifyer: tfilechangenotifyer;
   navigforwardact: taction;
   navigbackact: taction;
   tstockglyphbutton1: tstockglyphbutton;
   tstockglyphbutton2: tstockglyphbutton;
   procedure formonidle(var again: boolean);
   procedure doselectpage(const sender: TObject);

   procedure navigback(const sender: TObject);
   procedure navigforward(const sender: TObject);
   procedure onfilechanged(const sender: tfilechangenotifyer; 
                     const info: filechangeinfoty);
   procedure sourcefoonclosequery(const sender: tcustommseform; 
                    var modalresult: modalresultty);
   procedure tabwidgetpageremoved(const sender: TObject; const awidget: twidget);
   procedure tabwidgetonactivepagechanged(const sender: tobject);
   procedure addwatchactonexecute(const sender: tobject);
   procedure sourcefoonactivate(const sender: tobject);
   procedure editbreakpointexec(const sender: TObject);
   procedure popupmonupdate(const sender: tcustommenu);
   procedure completeclassexecute(const sender: TObject);
   procedure showasformexe(const sender: TObject);
   procedure setbmexec(const sender: TObject);
   procedure findbmexec(const sender: TObject);
   procedure insguiexec(const sender: TObject);
//   procedure togglebreakpointexe(const sender: TObject);
   procedure convpasex(const sender: TObject);
  private
   fasking: boolean;
   fgdbpage: tsourcepage;
   ffileloading: boolean;
   ffiletag: cardinal;
   fnaviglist: tnaviglist;
   fsourcehintwidget: twidget;
   feditposar: gridcoordarty;
   factbookmark: integer;
   fbookmarkar: array of bookmarkarty;
   fpagedestroying: integer;
   popuprow: integer;
   fallsaved: boolean;
   function geteditpositem(const index: integer): msestring;
   procedure seteditposcount(const count: integer);
   procedure  seteditpositem(const index: integer; const avalue: msestring);
   function getbookmarkitem(const index: integer): msestring;
   procedure setbookmarkcount(const count: integer);
   procedure  setbookmarkitem(const index: integer; const avalue: msestring);
   function getitems(const index: integer): tsourcepage;
   function createnewpage(const afilename: filenamety): tsourcepage;
   function getsourcepos: sourceposty;
   procedure setsourcehintwidget(const avalue: twidget);
  public
   hintsize: sizety;
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   procedure updatestat(const statfiler: tstatfiler);

   function hidesourcehint: boolean;    //false if no action;
   procedure updatebreakpointicon(const path: filenamety; 
                 const info: bkptlineinfoty);
   procedure textmodified(const sender: tsourcepage);
   function openfile(const filename: filenamety;
           aactivate: boolean = false): tsourcepage; //nil if not ok
   function showsourceline(const filename: filenamety;
            line: integer; col: integer = 0; asetfocus: boolean = false;
             const aposition: cellpositionty = cep_rowcentered): tsourcepage;
   function showsourcepos(const apos: sourceposty;
                asetfocus: boolean = false;
                const aposition: cellpositionty = cep_top): tsourcepage;
   procedure resetactiverow;
   function locate(const info: stopinfoty): tsourcepage;
   function count: integer;
   function activepage: tsourcepage;
   procedure updatecaption;
   function newpage: tsourcepage;
   function findsourcepage(afilename: filenamety; wholepath: boolean = true;
                              onlyifloaded: boolean = false): tsourcepage;
   procedure saveactivepage(const newname: filenamety = '');
   function saveall(noconfirm: boolean): modalresultty; //false if canceled
   procedure savecanceled; //resets fallsaved
   property allsaved: boolean read fallsaved;
   function closeactivepage: boolean;
   function closepage(const apage: tsourcepage;
                        noclosecheck: boolean = false): boolean; overload;
   function closepage(const aname: filenamety): boolean; overload;
   function closeall(const nosave: boolean): boolean; //false on cancel
   function gdbpage: tsourcepage;
   function modified: boolean;
   function newfiletag: cardinal;
   property items[const index: integer]: tsourcepage read getitems;
   property naviglist: tnaviglist read fnaviglist;
   function findbookmark(const bookmarknum: integer): boolean;
   procedure setbookmark(const apage: tsourcepage; const arow: integer;
                            const bookmarknum: integer);
    //true if found

   function gettextstream(const filename: filenamety; forwrite: boolean): ttextstream;
   function getfiletext(const filename: filenamety;
                   const startpos,endpos: gridcoordty): string;
   procedure replacefiletext(const filename: filenamety;
                   const startpos,endpos: gridcoordty; const newtext: string);
   property sourcepos: sourceposty read getsourcepos;
   property sourcehintwidget: twidget read fsourcehintwidget write setsourcehintwidget;
 end;

  errorlevelty = (el_all,el_hint,el_warning,el_error);

var
 sourcefo: tsourcefo;

function locateerrormessage(const text: msestring; var apage: tsourcepage;
                   minlevel: errorlevelty = el_all): boolean;
         //true if valid errormessage

implementation
uses
 sourceform_mfm,msefileutils,sysutils,mseformatstr,
 projectoptionsform,main,mseeditglob,watchform,msesys,msewidgets,msedesigner,
 selecteditpageform,sourceupdate,pascaldesignparser,mseclasses,msedatalist,
 msebits,msesysutils;

type
 tsourcepage1 = class(tsourcepage);

function locateerrormessage(const text: msestring; var apage: tsourcepage;
              minlevel: errorlevelty = el_all): boolean;
var
 ar1,ar2,ar3: msestringarty;
 col,row: integer;
 alevel: errorlevelty;
begin
 apage:= nil;
 result:= false;
 splitstring(text,ar1,msechar('('));
 if length(ar1) > 1 then begin
  splitstring(ar1[1],ar2,msechar(')'));
  if length(ar2) > 1 then begin
   splitstring(ar2[0],ar3,msechar(','));
   if (length(ar3) >= 1) then begin
    if startsstr(' Error:',ar2[1]) or startsstr(' Fatal:',ar2[1]) then begin
     alevel:= el_error;
    end
    else begin
     if startsstr(' Warning:',ar2[1]) then begin
      alevel:= el_warning;
     end
     else begin
      if startsstr(' Hint:',ar2[1]) then begin
       alevel:= el_hint;
      end
      else begin
       alevel:= el_all;
      end;
     end;
    end;
    if alevel >= minlevel then begin
     try
      result:= true;
      row:= strtoint(ar3[0]) - 1;
      if high(ar3) >= 1 then begin
       col:= strtoint(ar3[1]) - 1;
      end
      else begin
       col:= 0;
      end;
      apage:= sourcefo.showsourceline(ar1[0],row,col,true);
     except
     end;
    end;
   end;
  end;
 end;
end;

{ tnaviglist }

constructor tnaviglist.create;
begin
 findex:= -1;
 inherited;
end;

procedure tnaviglist.updateshowpos(
                         const acellpos: cellpositionty = cep_rowcenteredif);
begin
 with fsourcefo do begin
  showsourcepos(self.items[findex]^,true,acellpos);
  navigforwardact.enabled:= findex < fcount - 1;
  navigbackact.enabled:= findex > 0;
 end;
end;

function tnaviglist.back: boolean;
begin
 if findex > 0 then begin
  result:= true;
  dec(findex);
  updateshowpos;
 end
 else begin
  result:= false;
 end;
end;

function tnaviglist.forward: boolean;
begin
 if (findex < count - 1) then begin
  result:= true;
  inc(findex);
  updateshowpos;
 end
 else begin
  result:= false;
 end;
end;

procedure tnaviglist.showsource(const apos: sourceposty;
                                       const asetfocus: boolean = false);
begin
 count:= findex + 1;
 if count = 0 then begin
  add(fsourcefo.sourcepos);
 end
 else begin
  items[findex]^:= fsourcefo.sourcepos;
 end;
 findex:= add(apos);
 updateshowpos(cep_top);
end;

{ tsourcefo }

constructor tsourcefo.create(aowner: tcomponent);
begin
 fnaviglist:= tnaviglist.create;
 fnaviglist.fsourcefo:= self;
 inherited create(aowner);
end;

destructor tsourcefo.destroy;
begin
 hidesourcehint;
 inherited;
 fnaviglist.Free;
end;

function tsourcefo.hidesourcehint: boolean;
begin
 if fsourcehintwidget <> nil then begin
  result:= true;
  freeandnil(fsourcehintwidget);
 end
 else begin
  result:= false;
 end;
end;

procedure tsourcefo.tabwidgetpageremoved(const sender: TObject; const awidget: twidget);
begin
 if awidget = fgdbpage then begin
  fgdbpage:= nil;
 end;
end;

procedure tsourcefo.updatestat(const statfiler: tstatfiler);
var
 int1: integer;
 filenames,relpaths,modulenames: filenamearty;
 ismod: longboolarty;
 ar1: longboolarty;
 page1: tsourcepage1;
 intar1,intar2: integerarty;
 mstr1: filenamety;
 bo1: boolean;
 
begin
 with statfiler do begin
  setsection('edit');
  updatevalue('hintwidth',hintsize.cx);
  updatevalue('hintheight',hintsize.cy);
  with projectoptions do begin
   updatevalue('autoindent',autoindent);
   updatevalue('blockindent',blockindent);
   updatevalue('rightmarginon',rightmarginon);
   updatevalue('rightmarginchars',rightmarginchars);
   updatevalue('tabstops',tabstops);
   with findreplaceinfo do begin
    updatevalue('finddtext',find.text);
    updatevalue('findhistory',find.history);
    int1:= {$ifdef FPC}longword{$else}byte{$endif}(find.options);
    updatevalue('findoptions',int1);
    find.options:= searchoptionsty({$ifdef FPC}longword{$else}byte{$endif}(int1));
   end;
  end;
  if iswriter then begin
   intar1:= tabwidget.idents;
   sortarray(intar1,intar2);
   setlength(filenames,count);  
   setlength(relpaths,count);  
   setlength(feditposar,count); 
   setlength(fbookmarkar,count); 
   setlength(ismod,count); 
   for int1:= 0 to high(filenames) do begin
    with items[intar2[int1]] do begin
     filenames[int1]:= filepath;
     relpaths[int1]:= relpath;
     feditposar[int1]:= edit.editpos;
     fbookmarkar[int1]:= getbookmarks;
     ismod[int1]:= ismoduletext;
    end;
   end;
   setlength(modulenames,designer.modules.count);
   setlength(ar1,length(modulenames));
   for int1:= 0 to designer.modules.count - 1 do begin
    with designer.modules[int1]^ do begin
     modulenames[int1]:= filename;
     ar1[int1]:= designform.visible;
    end;
   end;
   tstatwriter(statfiler).writerecordarray('editpos',length(feditposar),
               {$ifdef FPC}@{$endif}geteditpositem);
   for int1:= 0 to high(fbookmarkar) do begin
    factbookmark:= int1;
    tstatwriter(statfiler).writerecordarray('bookmarks'+inttostr(int1),
                length(fbookmarkar[int1]),
                {$ifdef FPC}@{$endif}getbookmarkitem);
   end;
  end
  else begin
   tstatreader(statfiler).readrecordarray('editpos',
            {$ifdef FPC}@{$endif}seteditposcount,
            {$ifdef FPC}@{$endif}seteditpositem);
   setlength(fbookmarkar,length(feditposar));
   for int1:= 0 to high(fbookmarkar) do begin
    factbookmark:= int1;
    tstatreader(statfiler).readrecordarray('bookmarks'+inttostr(int1),
            {$ifdef FPC}@{$endif}setbookmarkcount,
            {$ifdef FPC}@{$endif}setbookmarkitem);
   end;
  end;
  updatevalue('sourcefiles',filenames);
  updatevalue('relpaths',relpaths);
  updatevalue('ismoduletexts',ismod);
  updatevalue('modules',modulenames);
  updatevalue('visiblemodules',ar1);
  if not iswriter then begin
   tabwidget.window.nofocus;
   tabwidget.clear;
   for int1:= 0 to high(filenames) do begin
    page1:= tsourcepage1(createnewpage(''));
    if (page1 <> nil) then begin
     page1.finitialfilepath:= filenames[int1];
     if int1 <= high(relpaths) then begin
      page1.relpath:= relpaths[int1];
     end;
     if int1 <= high(ismod) then begin
      page1.ismoduletext:= ismod[int1];
     end;
     if int1 <= high(feditposar) then begin
      page1.finitialeditpos:= feditposar[int1];
      if page1.finitialeditpos.col < 0 then begin
       page1.finitialeditpos.col:= 0;
      end;
      if page1.finitialeditpos.row < 0 then begin
       page1.finitialeditpos.row:= 0;
      end;
     end;
     if int1 <= high(fbookmarkar) then begin
      page1.finitialbookmarks:= fbookmarkar[int1];
     end;
     page1.updatecaption(false);
    end;
   end;
   mainfo.errorformfilename:= '';
   for int1:= 0 to high(modulenames) do begin
    try
     if int1 > high(ar1) then begin
      bo1:= true;
     end
     else begin
      bo1:= ar1[int1];
     end;
     mstr1:= relativepath(modulenames[int1],projectoptions.projectdir);
     if findfile(mstr1) then begin
      mainfo.openformfile(filepath(mstr1),bo1,false,true);
     end
     else begin
      mainfo.openformfile(modulenames[int1],bo1,false,true);
     end;
    except
     if checkprojectloadabort then begin
      break; //do not load more modules
     end;
    end;
   end;
  end;
  if visible and (activepage <> nil) then begin
   activepage.sourcefoonshow(nil);
  end;
  feditposar:= nil; //no longer used
  fbookmarkar:= nil;
  updatestat(istatfile(tabwidget));
  if mainfo.errorformfilename <> '' then begin
   showsourceline(mainfo.errorformfilename,0,0,true);
  end;
 end;
end;

procedure tsourcefo.doselectpage(const sender: TObject);
begin
 selecteditpage;
end;

procedure tsourcefo.navigback(const sender: TObject);
begin
 fnaviglist.back;
end;

procedure tsourcefo.navigforward(const sender: TObject);
begin
 fnaviglist.forward;
end;

procedure tsourcefo.formonidle(var again: boolean);
var
 int1: integer;
 wstr1: msestring;
begin
 if (application.activewindow <> nil) and not fasking then begin
  fasking:= true;
  try
   for int1:= 0 to count - 1 do begin
    with items[int1] do begin
     if filechanged then begin
      filechanged:= false;
      wstr1:= 'File "'+filepath+'" has changed.';
      if modified then begin
       wstr1:= wstr1 + ' There are modifications in edit buffer also.'
      end;
      wstr1:= wstr1 + ' Do you wish to reload from disk?';
      if askok(wstr1,'Confirmation') then begin
       reload;
       mainfo.sourcechanged(items[int1]);
      end;
     end;
    end;
   end;
  finally
   fasking:= false;
  end;
 end;
end;

procedure tsourcefo.onfilechanged(const sender: tfilechangenotifyer; 
                                          const info: filechangeinfoty);
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  with items[int1] do begin
   if (cardinal(info.tag) = filetag) and canchangenotify(info) then begin
    filechanged:= true;
    application.wakeupmainthread;
   end;
  end;
 end;
end;

function tsourcefo.count: integer;
begin
 result:= tabwidget.count;
end;

function tsourcefo.getitems(const index: integer): tsourcepage;
begin
 result:= tsourcepage(tabwidget[index]);
end;

function tsourcefo.findsourcepage(afilename: filenamety;
                   wholepath: boolean = true; 
                   onlyifloaded: boolean = false): tsourcepage;
var
 int1: integer;
begin
 result:= nil;
 if wholepath then begin
  for int1:= 0 to count - 1 do begin
   if issamefilename(items[int1].filepath,afilename) then begin
    result:= items[int1];
    break;
   end;
  end;
 end
 else begin
  for int1:= 0 to count - 1 do begin
   if issamefilename(items[int1].filepath,afilename) then begin
    result:= items[int1];
    break;
   end;
  end
 end;
 if result <> nil then begin
  if onlyifloaded then begin
   if not result.fileloaded then begin
    result:= nil;
   end;
  end
  else begin
   result.loadfile;
  end;
 end;
end;

function tsourcefo.createnewpage(const afilename: filenamety): tsourcepage;
begin
 result:= tsourcepage.create(nil);
 try
  result.edit.syntaxpainter:= syntaxpainter;
  result.dataicon.imagelist:= imagelist;
  result.filepath:= afilename;
  tabwidget.add(result,tabwidget.activepageindex+1);
  if afilename <> '' then begin
   filechangenotifyer.addnotification(result.filepath,result.filetag);
   designer.designfiles.add(afilename);
  end;
 except
  result.Free;
  result:= nil;
  application.handleexception(self);
 end;
end;

function tsourcefo.newpage: tsourcepage;
begin
 result:= createnewpage('');               
 result.updatecaption(false);
 result.show;
 result.setfocus(true);
end;

function tsourcefo.openfile(const filename: filenamety;
             aactivate: boolean = false): tsourcepage;
              //nil if not ok

 function loadfile(aname: filenamety): tsourcepage;
 begin
  ffileloading:= true;
  try
   result:= createnewpage(aname);
   if result <> nil then begin
    mainfo.loadformbysource(aname);
   end;
  finally
   ffileloading:= false;
  end;
 end;

var
 str1: filenamety;
 bo1: boolean;
begin
 result:= nil;
 if filename = '' then begin
  exit;
 end;
 application.beginwait;
 try
  bo1:= isrootpath(filename);
  if bo1 then begin
   result:= findsourcepage(filename);
   if result = nil then begin
    if findfile(filename) then begin
     result:= loadfile(filename);
    end;
   end;
  end;
  if result = nil then begin
   if bo1 and findfile(msefileutils.filename(filename),projectoptions.texp.sourcedirs,str1) or
      not bo1 and findfile(filename,projectoptions.texp.sourcedirs,str1) then begin
    result:= findsourcepage(str1);
    if result = nil then begin
     result:= loadfile(str1);
    end;
   end;
  end;
  if (result <> nil) and aactivate then begin
   result.activate(true);
  end;
 finally
  application.endwait;
 end;
end;

function tsourcefo.showsourceline(const filename: filenamety;
            line: integer; col: integer = 0; asetfocus: boolean = false;
             const aposition: cellpositionty = cep_rowcentered): tsourcepage;
begin
 result:= openfile(filename);
 if result <> nil then begin
  result.show;
  if line >= 0 then begin
   result.grid.showcell(makegridcoord(0,line),aposition);
   if asetfocus then begin
    result.edit.editpos:= makegridcoord(col,line);
    result.grid.setfocus;
    result.window.bringtofront;
   end;
  end;
 end;
end;

function tsourcefo.showsourcepos(const apos: sourceposty;
          asetfocus: boolean = false;
           const aposition: cellpositionty = cep_top): tsourcepage;
var
 str1: filenamety;
begin
 result:= nil;
 str1:= designer.designfiles.getname(apos.filename);
 if str1 <> '' then begin
  result:= showsourceline(str1,apos.pos.row,apos.pos.col,asetfocus,aposition);
 end;
end;

procedure tsourcefo.resetactiverow;
begin
 if fgdbpage <> nil then begin
  fgdbpage.activerow:= -1;
 end;
end;

function tsourcefo.locate(const info: stopinfoty): tsourcepage;
begin
 resetactiverow;
 if info.filename <> '' then begin
  result:= openfile(info.filename);
  if result <> nil then begin
   result.activerow:= info.line-1;
   result.show;
  end;
 end
 else begin
  result:= nil;
 end;
 fgdbpage:= result;
end;

function tsourcefo.saveall(noconfirm: boolean): modalresultty;
var
 int1,int2: integer;
begin
 result:= mr_none;
 for int1:= 0 to tabwidget.count - 1 do begin
  result:= mainfo.checksavecancel(
           tsourcepage(tabwidget[int1]).checksave(noconfirm,true));
  case result of
   mr_cancel: begin
    exit;
   end;
   mr_noall: begin
    break;
   end;
   mr_all: begin
    for int2:= int1 to tabwidget.count - 1 do begin
     tsourcepage(tabwidget[int2]).checksave(true,true);
    end;
    break;
   end;
  end;
 end;
 fallsaved:= fallsaved or not noconfirm;
end;

function tsourcefo.modified: boolean;
var
 int1: integer;
begin
 result:= false;
 if fpagedestroying = 0 then begin
  for int1:= 0 to count - 1 do begin
   if items[int1].modified then begin
    result:= true;
    break;
   end;
  end;
 end;
end;

function tsourcefo.newfiletag: cardinal;
begin
 inc(ffiletag);
 if ffiletag = 0 then begin
  ffiletag:= 1;
 end;
 result:= ffiletag;
end;

procedure tsourcefo.sourcefoonclosequery(const sender: tcustommseform;
  var modalresult: modalresultty);
begin
{
 if saveall(false) = mr_cancel then begin
  modalresult:= mr_none;
 end;
}
end;

procedure tsourcefo.updatecaption;
var
 page: tsourcepage;

begin
 page:= tsourcepage(tabwidget.activepage);
 if page <> nil then begin
  caption:= page.caption;
 end
 else begin
  caption:= '<none>';
 end;
end;

procedure tsourcefo.tabwidgetonactivepagechanged(const sender: tobject);
begin
 updatecaption;
end;

procedure tsourcefo.saveactivepage(const newname: filenamety = '');
begin
 if activepage <> nil then begin
  if newname <> '' then begin
   filechangenotifyer.removenotification(activepage.filepath);
  end;
  activepage.save(newname);
  if newname <> '' then begin
   filechangenotifyer.addnotification(activepage.filepath,activepage.filetag);
  end;
 end;
end;

function tsourcefo.closepage(const apage: tsourcepage;
                        noclosecheck: boolean = false): boolean;
var
 str1: filenamety;
 bo1: boolean;
begin
 result:= apage = nil;
 if not result then begin
  if apage.checksave(false,false) <> mr_cancel then begin
   str1:= apage.filepath;
   if not noclosecheck and (fileext(str1) = pasfileext) then begin
    if not mainfo.closemodule(
       designer.modules.findmodule(replacefileext(str1,formfileext)),true,
                     noclosecheck) then begin
     exit;
    end;
   end;
   filechangenotifyer.removenotification(str1);
   inc(fpagedestroying);
   try
    bo1:= tabwidget.entered;
    apage.free;
    if bo1 then begin
     tabwidget.setfocus;
    end;
   finally
    dec(fpagedestroying);
   end;
   result:= true;
  end;
 end;
end;

function tsourcefo.closepage(const aname: filenamety): boolean;
begin
 result:= closepage(findsourcepage(aname));
end;

function tsourcefo.closeactivepage: boolean;
begin
 result:= closepage(activepage);
end;

function tsourcefo.closeall(const nosave: boolean): boolean; //false on cancel
var
 int1: integer;
begin
 result:= nosave or (saveall(false) <> mr_cancel);
 if result then begin
  for int1:= count - 1 downto 0 do begin
   items[int1].enabled:= false; //avoid showing
  end;
  for int1:= count - 1 downto 0 do begin
   closepage(items[int1],true);
  end;
 end;
end;

function tsourcefo.activepage: tsourcepage;
begin
 if fpagedestroying > 0 then begin
  result:= nil;
 end
 else begin
  result:= tsourcepage(tabwidget.activepage);
 end;
end;

procedure tsourcefo.textmodified(const sender: tsourcepage);
begin
 fallsaved:= false;
 if not ffileloading then begin
  mainfo.sourcechanged(sender);
 end;
end;

function tsourcefo.gdbpage: tsourcepage;
begin
 result:= fgdbpage;
end;

procedure tsourcefo.addwatchactonexecute(const sender: tobject);
begin
 with sender as tmenuitem do begin
  watchfo.addwatch(getpascalvarname(activepage.edit,
                      translateclientpoint(owner.mouseinfopo^.pos,
                           owner.transientfor,activepage.edit)));
 end;
end;

procedure tsourcefo.updatebreakpointicon(const path: filenamety; const info: bkptlineinfoty);
var
 int1: integer;
 wstr1: msestring;
begin
 wstr1:= filename(path);
 for int1:= 0 to count - 1 do begin
  with tsourcepage(tabwidget[int1]) do begin
   if issamefilename(filename,wstr1) then begin
    try
     updatebreakpointicon(info);
    except
    end;
   end;
  end;
 end;
end;

function tsourcefo.geteditpositem(const index: integer): msestring;
begin
 result:= encoderecord([feditposar[index].col,feditposar[index].row]);
end;

procedure tsourcefo.seteditposcount(const count: integer);
begin
 setlength(feditposar,count);
end;

procedure  tsourcefo.seteditpositem(const index: integer; const avalue: msestring);
begin
 decoderecord(avalue,[@feditposar[index].col,@feditposar[index].row],'ii');
end;

function tsourcefo.getbookmarkitem(const index: integer): msestring;
begin
 result:= encoderecord([fbookmarkar[factbookmark][index].row,
                        fbookmarkar[factbookmark][index].bookmarknum]);
end;

procedure tsourcefo.setbookmarkcount(const count: integer);
begin
 setlength(fbookmarkar[factbookmark],count);
end;

procedure  tsourcefo.setbookmarkitem(const index: integer; const avalue: msestring);
begin
 decoderecord(avalue,[@fbookmarkar[factbookmark][index].row,
                      @fbookmarkar[factbookmark][index].bookmarknum],'ii');
end;

procedure tsourcefo.sourcefoonactivate(const sender: tobject);
begin
 mainfo.sourceformactivated;
end;

function tsourcefo.gettextstream(const filename: filenamety;
                 forwrite: boolean): ttextstream;
var
 page1: tsourcepage;
begin
 page1:= findsourcepage(filename,true,true);
 if forwrite then begin
  if page1 = nil then begin
   page1:= openfile(filename);
  end;
 end;
 if page1 <> nil then begin
  result:= page1.edit.datalist.dataastextstream;
 end
 else begin
  if not forwrite then begin
   result:= ttextstream.create(filename,fm_read);
  end
  else begin
   result:= nil;
  end;
 end;
end;

function tsourcefo.getfiletext(const filename: filenamety;
                   const startpos,endpos: gridcoordty): string;
var
 apage: tsourcepage;
begin
 apage:= openfile(filename);
 if apage <> nil then begin
  result:= apage.edit.gettext(startpos,endpos);
 end
 else begin
  result:= '';
 end;
end;

procedure tsourcefo.replacefiletext(const filename: filenamety;
                   const startpos,endpos: gridcoordty; const newtext: string);
var
 apage: tsourcepage;
begin
 apage:= openfile(filename);
 if apage <> nil then begin
  apage.edit.deletetext(startpos,endpos);
  apage.edit.inserttext(startpos,newtext);
 end;
end;

function tsourcefo.getsourcepos: sourceposty;
begin
 finalize(result);
 fillchar(result,sizeof(result),0);
 if activepage <> nil then begin
  result.filename:= designer.designfiles.find(activepage.filepath);
  result.pos:= activepage.edit.editpos;
 end;
end;

procedure tsourcefo.setsourcehintwidget(const avalue: twidget);
begin
 fsourcehintwidget.free;
 setlinkedvar(avalue,tmsecomponent(fsourcehintwidget));
end;

procedure tsourcefo.editbreakpointexec(const sender: TObject);
begin
 breakpointsfo.showbreakpoint(activepage.filepath,popuprow+1,true);
end;
{
procedure tsourcefo.togglebreakpointexe(const sender: TObject);
begin
 activepage.togglebreakpoint(popuprow);
end;
}
procedure tsourcefo.popupmonupdate(const sender: tcustommenu);
begin
 if (activepage <> nil) then begin
  popuprow:= activepage.grid.cellatpos(translateclientpoint(
                   sender.mouseinfopo^.pos,activepage,activepage.grid)).row;
 end
 else begin
  popuprow:= invalidaxis;
 end;
 sender.menu.itembyname('editbreakpoint').enabled:= 
        (activepage <> nil) and (popuprow >= 0) and
        (activepage.getbreakpointstate(popuprow) > bkpts_none);
 sender.menu.itembyname('showasform').enabled:= 
        (activepage <> nil) and activepage.ismoduletext;
 sender.menu.itembyname('setbm').enabled:= 
        (activepage <> nil) and (popuprow >= 0);
 sender.menu.itembyname('insgui').enabled:= (activepage <> nil);
 sender.menu.itembyname('convpas').enabled:= (activepage <> nil) and 
                                                  activepage.edit.hasselection;
 sender.menu.itembyname('addwatch').enabled:= (activepage <> nil) and   
              (getpascalvarname(activepage.edit,
                translateclientpoint(sender.mouseinfopo^.pos,
                        activepage,activepage.edit)) <> '');
end;

procedure tsourcefo.completeclassexecute(const sender: TObject);
var
 pos1: sourceposty;
begin
 if activepage <> nil then begin
  activepage.edit.editor.begingroup;
  try
   pos1.pos:= activepage.edit.editpos;
   completeclass(activepage.filepath,pos1);
  finally
   activepage.edit.editor.endgroup;
  end;
 end;
end;

procedure tsourcefo.showasformexe(const sender: TObject);
begin
 activepage.asyncevent(integer(spat_showasform));
end;

procedure tsourcefo.setbookmark(const apage: tsourcepage; const arow: integer;
                                  const bookmarknum: integer);
var
 int1: integer;
 page1: tsourcepage;
 bo1: boolean;
begin
 if bookmarknum >= 0 then begin
  bo1:= (arow >= 0) and (bookmarknum >= 0);
  for int1:= 0 to self.count - 1 do begin
   page1:= items[int1];
   if bo1 and (page1 = apage) and (page1.findbookmark(bookmarknum) = arow) then begin
    page1.clearbookmark(bookmarknum);
    exit;
   end;
   page1.clearbookmark(bookmarknum);
  end;
 end;
 apage.setbookmark(arow,bookmarknum);
end;

procedure tsourcefo.setbmexec(const sender: TObject);
begin
 setbookmark(activepage,-1,tmenuitem(sender).tag);
end;

function tsourcefo.findbookmark(const bookmarknum: integer): boolean;
var
 int1,int2: integer;
begin
 result:= false;
 for int1:= 0 to count - 1 do begin
  with items[int1] do begin
   int2:= findbookmark(bookmarknum);
   if int2 >= 0 then begin
    grid.showcell(makegridcoord(invalidaxis,int2),cep_rowcenteredif);
    edit.editpos:= makegridcoord(0,int2);
    activate;
    result:= true;
   end;
  end;
 end;
end;

procedure tsourcefo.findbmexec(const sender: TObject);
begin
 findbookmark(tmenuitem(sender).tag);
end;

procedure tsourcefo.insguiexec(const sender: TObject);
begin
 with activepage.edit do begin
  inserttext(editpos,'['''+createguidstring+''']');
 end;
end;

procedure tsourcefo.convpasex(const sender: TObject);
var
 mstr1,mstr2: msestring;
begin
 with activepage.edit do begin
  mstr1:= selectedtext;
  mstr2:= stringtopascalstring(mstr1);
  if askyesno('Do you wish to replace:'+lineend+mstr1+lineend+'with:'+lineend+
        mstr2+lineend+'?') then begin
   editor.begingroup;
   deleteselection;
   inserttext(mstr2,true);
   editor.endgroup;
  end;
 end;
end;

procedure tsourcefo.savecanceled;
begin
 fallsaved:= false;
end;

end.
