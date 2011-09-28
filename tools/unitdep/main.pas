unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msestatfile,msebitmap,
 msedataedits,msedatanodes,mseedit,msefiledialog,msegrids,mseifiglob,
 mselistbrowser,msestrings,msesys,msetypes,msesimplewidgets,msewidgets,
 msewidgetgrid,mselist,classes,mseificomp,mseificompglob,msedispwidgets,
 msesplitter;

type
 tdependencylist = class;
 tunitdependencynode = class(trecordtreelistedititem)
  private
//   frecursion: msestring;
   flist: tdependencylist;
   fsubitemschecked: boolean;
  protected
   procedure actionnotification(var ainfo: nodeactioninfoty); override;
  public
   constructor create(const alist: tdependencylist);
 end;
 
 dependencyinfoty = record
  name: string;
  depend: string;
  checked: boolean;
 end;
 pdependencyinfoty = ^dependencyinfoty;
 dependencyinfoaty = array [0..0] of dependencyinfoty;
 pdependencyinfoaty = ^dependencyinfoaty;
 
 tdependencylist = class(trecordmap)
  private
   fapplication: string;
  protected
   function comparename(const l,r): integer;
   procedure finalizerecord(var item); override;
   procedure copyrecord(var item); override;  
  public
   constructor create;
   procedure parse(const afilename: filenamety);
//   function gettoplevelnodes: treelistedititemarty;
   function getnodes(const aname: string): treelistedititemarty;
//   function getdependencytree: ttreelistedititem;
   function find(const aname: string; out aindex: integer): pdependencyinfoty;
   function getunitnames: msestringarty;
   function findpath(const astart,adest: string): msestringarty;
 end;
 
 tmainfo = class(tmainform)
   tstatfile1: tstatfile;
   filename: tfilenameedit;
   tbutton1: tbutton;
   grid: twidgetgrid;
   treeedit: ttreeitemedit;
   dropdownunits: tifidropdownlistlinkcomp;
   start: tdropdownlistedit;
   dest: tdropdownlistedit;
   pathdisp: tstringdisp;
   tsplitter1: tsplitter;
   procedure scanexe(const sender: TObject);
   procedure pathdatentexe(const sender: TObject);
   procedure filenamedatentexe(const sender: TObject);
  private
   flist: tdependencylist;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
 end;

var
 mainfo: tmainfo;

implementation

uses
 main_mfm,msestream,strutils,msedatalist,msearrayutils;

constructor tmainfo.create(aowner: tcomponent);
begin
 flist:= tdependencylist.create;
 inherited;
end;

destructor tmainfo.destroy;
begin
 inherited;
 flist.free;
end;

procedure tmainfo.scanexe(const sender: TObject);
var
// ar1: treelistedititemarty;
 str1,str2: msestring;
begin
 flist.parse(filename.value);
 with treeedit.itemlist do begin
  clear;
  add(flist.getnodes(flist.fapplication));
 end;
 grid.fixrows[-1].captions[0].caption:= flist.fapplication;
 str1:= start.value;
 str2:= dest.value;
 dropdownunits.controller.dropdown.cols[0].asarray:= flist.getunitnames;
 start.value:= str1;
 dest.value:= str2;
 pathdatentexe(nil);
end;

procedure tmainfo.pathdatentexe(const sender: TObject);
begin
 if (start.value <> '') and (dest.value <> '') then begin
  pathdisp.value:= concatstrings(flist.findpath(start.value,dest.value),',');
 end
 else begin
  pathdisp.value:= '';
 end;
end;

procedure tmainfo.filenamedatentexe(const sender: TObject);
begin
 treeedit.itemlist.clear;
 pathdisp.value:= '';
end;

{ tdependencylist }

constructor tdependencylist.create;
begin
 inherited create(sizeof(dependencyinfoty),
            [rels_needsinitialize,rels_needsfinalize,rels_needscopy]);
 setcomparefuncs([@comparename]);
end;

procedure tdependencylist.finalizerecord(var item);
begin
 finalize(dependencyinfoty(item));
end;

procedure tdependencylist.copyrecord(var item);
begin
 with dependencyinfoty(item) do begin
  stringaddref(name);
  stringaddref(depend);
 end;
end;

procedure tdependencylist.parse(const afilename: filenamety);
var
 stream1: ttextstream;
 str1: string;
 int1,int2: integer;
 info1: dependencyinfoty;
 name1{,depend1}: string;
begin
 stream1:= ttextstream.create(afilename);
 try
  clear;
  while not stream1.eof do begin
   stream1.readln(str1);
   if str1 <> '' then begin
    if str1[1] = '(' then begin
     int1:= pos(')',str1);
     if int1 > 0 then begin
      name1:= struppercase(copy(str1,2,int1-2));
      if (fapplication = '') and 
                     (name1 <> 'PROGRAM') and (name1 <> 'SYSTEM') then begin
       fapplication:= name1;
      end;
      if name1 = fapplication then begin
       int2:= posex(' Load from ',str1,int1);
       if int2 >= int1+1 then begin
        info1.name:= name1;
        info1.depend:= copy(str1,findlastchar(str1,' ')+1,bigint);
        add(info1);
       end;
      end
      else begin      
       int2:= posex(' depends on ',str1,int1); //FPC 2.6
       if int2 > 0 then begin
        info1.name:= name1;
        info1.depend:= copy(str1,int2+12,bigint);
        add(info1);
       end
       else begin
        int2:= posex(' Add dependency of ',str1,int1); //FPC 2.4
        if int2 > 0 then begin
         info1.name:= name1;
         info1.depend:= copy(str1,findlastchar(str1,' ')+1,bigint);
         add(info1);
        end
       end;
      end;
//      }
     end;
    end;
   end;
  end;
//   sorted:= true;
 finally
  stream1.free;
 end;
end;

function tdependencylist.comparename(const l; const r): integer;
begin
 with dependencyinfoty(l) do begin
  result:= stringcomp(name,dependencyinfoty(r).name);
  if result = 0 then begin
   result:= stringcomp(depend,dependencyinfoty(r).depend);
  end;
 end;
end;
(*
function tdependencylist.getdependencytree: ttreelistedititem;
var
 pend: pdependencyinfoty;
 
 procedure loadnode(const aparent: ttreelistedititem;
                              start: pdependencyinfoty;
                               out aend: pdependencyinfoty);
 var
  str1: string;
  mstr1: msestring;
  n1: ttreelistitem;
  n2: tunitdependencynode;
 begin
  if start <> nil then begin
   n2:= tunitdependencynode.create;
   str1:= start^.name;
   mstr1:= str1;
   n2.caption:= mstr1;
   aparent.add(n2);
   n1:= aparent;
   while (n1 <> nil) and ((n1.caption) <> mstr1) do begin
    n1:= n1.parent;
   end;
   if (n1 <> nil) and (n1.parent <> nil) then begin
    n2.frecursion:= n1.parent.caption;
   end
   else begin  
    while (start < pend) and (start^.name = str1) do begin
     loadnode(n2,find(start^.depend),aend);
     inc(start);
    end;
   end;
  end;
  aend:= start;
 end;
 
var
 po1: pdependencyinfoty; 
begin
 result:= ttreelistedititem.create;
 po1:= datapo;
 pend:= dataend;
 repeat
  loadnode(result,po1,po1);
 until po1 >= pend;
end;
*)

function tdependencylist.find(const aname: string; out aindex: integer): pdependencyinfoty;
var
 info1: dependencyinfoty;
begin
 result:= nil;
 info1.name:= aname;
 internalfind(0,info1,aindex,result);
 if (result <> nil) and (result^.name <> aname) then begin
  result:= nil;
 end;
end;
{
function tdependencylist.gettoplevelnodes: treelistedititemarty;
var
 count1: integer;
 po1: pdependencyinfoty;
 n1: tunitdependencynode;
 ar1: pointerarty;
 int1: integer;
begin
 result:= nil;
 order:= 0;
 find(fapplication,int1);
 if int1 >= 0 then begin
  count1:= 0;
  ar1:= findexes[0];
  while (int1 < fcount) do begin
   with pdependencyinfoty(ar1[int1])^ do begin
    if name <> fapplication then begin
     break;
    end;
    n1:= tunitdependencynode.create(self);
    n1.caption:= depend;
    additem(pointerarty(result),pointer(n1),count1);
    inc(int1);
   end;
  end;
  setlength(result,count1);
 end;
end;
}
function tdependencylist.getnodes(const aname: string): treelistedititemarty;
var
 count1: integer;
// po1: pdependencyinfoty;
 n1: tunitdependencynode;
 ar1: pointerarty;
 int1: integer;
 dep1: string;
begin
 result:= nil;
 order:= 0;
 find(aname,int1);
 if int1 >= 0 then begin
  count1:= 0;
  ar1:= findexes[0];
  dep1:= '';
  while (int1 < fcount) do begin
   with pdependencyinfoty(ar1[int1])^ do begin
    if name <> aname then begin
     break;
    end;
    if depend <> dep1 then begin
     dep1:= depend;
     n1:= tunitdependencynode.create(self);
     n1.caption:= depend;
     additem(pointerarty(result),pointer(n1),count1);
    end;
    inc(int1);
   end;
  end;
  setlength(result,count1);
 end;
end;

function tdependencylist.getunitnames: msestringarty;
var
 int1,int2: integer;
 str1: string;
 ar1: pointerarty;
begin
 setlength(result,fcount); //max
 int2:= 0;
 ar1:= findexes[0];
 str1:= '';
 for int1:= 0 to fcount - 1 do begin
  if str1 <> pdependencyinfoty(ar1[int1])^.name then begin
   str1:= pdependencyinfoty(ar1[int1])^.name;
   result[int2]:= str1;
   inc(int2);
  end;
 end;
 setlength(result,int2);
end;

function tdependencylist.findpath(const astart: string;
               const adest: string): msestringarty;
var
 destar1: stringarty;
 maxlevel: integer;
 maxlevelfound: boolean;
 
 function find1(const aname: string; const alevel: integer): boolean;
 var
//  po1: pdependencyinfoty;
  int1: integer;
//  str1: string;
 begin
  result:= aname = adest;
  if not result then begin
   if find(aname,int1) <> nil then begin
    if alevel > maxlevel then begin
     maxlevelfound:= true;
     exit;
    end;
    while int1 < fcount do begin
     with pdependencyinfoty(findexes[0][int1])^ do begin
      if (name <> aname) or checked then begin
       break;
      end;
      checked:= true;
      result:= find1(depend,alevel+1);
      if result then begin
       break;
      end;
      inc(int1);
     end;
    end;
   end;
  end;  
  if result then begin
   additem(destar1,aname);
  end;
 end;
var
 int1,int2: integer; 
 po1,po2: pdependencyinfoty;
begin
 result:= nil;
 po2:= dataend;
 maxlevel:= 0;
 repeat
  po1:= datapo;
  while po1 < po2 do begin
   po1^.checked:= false;
   inc(po1);
  end;
  maxlevelfound:= false;
  if find1(astart,0) then begin
   setlength(result,length(destar1));
   int2:= 0;
   for int1:= high(destar1) downto 0 do begin
    result[int2]:= destar1[int1];
    inc(int2);
   end;
   break;
  end;
  inc(maxlevel);
 until not maxlevelfound;
end;

{ tunitdependencynode }

constructor tunitdependencynode.create(const alist: tdependencylist);
begin
 flist:= alist;
 inherited create; 
 include(fstate,ns_subitems);
end;

procedure tunitdependencynode.actionnotification(var ainfo: nodeactioninfoty);
var
 int1: integer;
 n1,n2: ttreelistitem;
begin
 if (ainfo.action = na_expand) and not fsubitemschecked then begin
  fsubitemschecked:= true;
  add(flist.getnodes(caption));
  for int1:= 0 to fcount - 1 do begin
   n1:= fitems[int1];
   n2:= n1.parent;
   while n2 <> nil do begin
    if n2.caption = n1.caption then begin
     exclude(tunitdependencynode(n1).fstate,ns_subitems); //recursive
     break;
    end;
    n2:= n2.parent;
   end;
  end;
 end;
 inherited;
end;

end.
