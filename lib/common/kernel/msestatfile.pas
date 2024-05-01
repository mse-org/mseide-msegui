{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestatfile;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,msestat,mseapplication,msetypes,msestrings,mseclasses,msestream,
 mseglob,msearrayprops;

type
 statupdateeventty = procedure(const sender: tobject;
                                  const filer: tstatfiler) of object;
 statreadeventty = procedure(const sender: tobject;
                                  const reader: tstatreader) of object;
 statwriteeventty = procedure(const sender: tobject;
                                  const writer: tstatwriter) of object;

 statfileoptionty = (sfo_memory,sfo_deletememorydata, //delete after read
                     sfo_createpath,
//////////////////////////
                     sfo_useexename,
//////////////////////////
                     sfo_transaction, //use intermedate file and rename
                     sfo_savedata,sfo_autoreadstat,sfo_autowritestat,
                     sfo_activatorread,sfo_activatorwrite,
                     sfo_nodata,sfo_nostate,sfo_nooptions);
 statfileoptionsty = set of statfileoptionty;
const
 defaultstatfileoptions = [sfo_activatorread,sfo_activatorwrite,sfo_transaction];
//////////////////////////
 StatExt = '.sta';
//////////////////////////

type
 tstatfile = class;
 statfilemissingeventty = procedure (const sender: tstatfile;
                  const afilename: filenamety;
                  var astream: ttextstream; var aretry: boolean) of object;
 statfilemodety = (sfm_inactive,sfm_reading,sfm_writing);

 statclientinfoty = record
  intf: istatfile;
  priority: integer;
 end;
 pstatclientinfoty = ^statclientinfoty;
 statclientarty = array of statclientinfoty;

 statfilestatety = (stfs_reading);
 statfilestatesty = set of statfilestatety;

 tstatfile = class(tactcomponent,istatfile)
  private
   ffilename: filenamety;
   ffiledir: filenamety;
   floadedfile: filenamety;

   fstatvarname: msestring;
   fonstatupdate: statupdateeventty;
   fonstatread: statreadeventty;
   fonstatwrite: statwriteeventty;
   fonstatbeforeread: notifyeventty;
   fonstatafterread: notifyeventty;
   fonstatbeforewrite: notifyeventty;
   fonstatafterwrite: notifyeventty;
   areader: tstatreader;
   awriter: tstatwriter;
   aclients: statclientarty;
   aclientcount: integer;
   foptions: statfileoptionsty;
   fencoding: charencodingty;
   fstatfile: tstatfile;
   fsavedmemoryfiles: msestring;
   fonfilemissing: statfilemissingeventty;
   fcryptohandler: tcustomcryptohandler;
   fnext: tstatfile;
   fstatpriority: integer;
   procedure dolinkstatread(const info: linkinfoty);
   procedure dolinkstatreading(const info: linkinfoty);
   procedure dolinkstatreaded(const info: linkinfoty);
   procedure dolinkstatwrite(const info: linkinfoty);
   procedure setstatfile(const Value: tstatfile);
   procedure setfilename(const avalue: filenamety);
   procedure setfiledir(const avalue: filenamety);
//   procedure setoptions(avalue: statfileoptionsty);
   procedure setcryptohandler(const avalue: tcustomcryptohandler);
   function getmode: statfilemodety;
   procedure setnext(const avalue: tstatfile);
   procedure internalreadstat;
   procedure internalwritestat;
  protected
   fstate: statfilestatesty;
   procedure objevent(const sender: iobjectlink;
                                 const event: objecteventty); override;
   procedure objectevent(const sender: tobject;
                          const event: objecteventty); override;
   procedure updateoptions(const afiler: tstatfiler);
   function defaultfile(const adirs: filenamearty): filenamety;

   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   function getstatpriority: integer;
/////////////////////////////////////////////
   PROCEDURE completepath (ar1: filenamearty);
/////////////////////////////////////////////
  public
   constructor create(aowner: tcomponent); override;
   procedure initnewcomponent(const ascale: real); override;
   procedure readstat(const stream: ttextstream = nil); overload;
   procedure readstat(const afilename: filenamety); overload; //disk file
   procedure readstat(const aname: msestring;
                                     const statreader: tstatreader); overload;
   procedure writestat(const stream: ttextstream = nil); overload;
   procedure writestat(const afilename: filenamety); overload; //disk file
   procedure writestat(const aname: msestring;
                                     const statwriter: tstatwriter); overload;
   procedure updatestat(const aname: msestring; const statfiler: tstatfiler);
   property mode: statfilemodety read getmode;
  published
   property filename: filenamety read ffilename write setfilename nodefault;
   property filedir: filenamety read ffiledir write setfiledir;
   property encoding: charencodingty read fencoding write fencoding
                                                           default ce_utf8;
   property options: statfileoptionsty read foptions write foptions
                              default defaultstatfileoptions;
   property statfile: tstatfile read fstatfile write setstatfile;
            //filename is stored in linked statfile, dostatread and dostatwrite are
            //called by linked statfile
   property savedmemoryfiles: msestring read fsavedmemoryfiles write
                           fsavedmemoryfiles;
            //use quotes for several filenames '"file1.sta" "file2.sta*"',
            //'*' and '?' wildcards supported.
   property statvarname: msestring read getstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority
                                       write fstatpriority default 0;
   property cryptohandler: tcustomcryptohandler read fcryptohandler
                                     write setcryptohandler;
   property activator;
   property next: tstatfile read fnext write setnext;
   property onstatupdate: statupdateeventty read fonstatupdate write fonstatupdate;
   property onstatread: statreadeventty read fonstatread write fonstatread;
   property onstatwrite: statwriteeventty read fonstatwrite write fonstatwrite;
   property onstatbeforewrite: notifyeventty read fonstatbeforewrite
                                                    write fonstatbeforewrite;
   property onstatafterwrite: notifyeventty read fonstatafterwrite
                                                    write fonstatafterwrite;
   property onstatbeforeread: notifyeventty read fonstatbeforeread
                                                    write fonstatbeforeread;
   property onstatafterread: notifyeventty read fonstatafterread
                                                    write fonstatafterread;
   property onfilemissing: statfilemissingeventty read fonfilemissing
                                                    write fonfilemissing;
 end;

 tstatfileitem = class(tmsecomponentlinkitem)
  private
   function getstatfile: tstatfile;
   procedure setstatfile(const avalue: tstatfile);
  published
   property statfile: tstatfile read getstatfile write setstatfile;
 end;

 tstatfilearrayprop = class(tmsecomponentlinkarrayprop)
  private
   function getitems(const index: integer): tstatfileitem;
  public
   constructor create;
   class function getitemclasstype: persistentclassty; override;
   property items[const index: integer]: tstatfileitem read getitems; default;
 end;

procedure setstatfilevar(const sender: istatfile; const source: tstatfile;
              var instance: tstatfile);

////////////////////////////////////////////
FUNCTION SavedMemoryFiles (CONST Filer: tstatfiler): msestringarty;
PROCEDURE registerNewMemoryFile (StateFile: tStatFile; CONST SavedName: msestring);
PROCEDURE registerSavedMemoryFiles (StateFile: tStatFile; CONST SavedNames: msestringarty);
////////////////////////////////////////////

implementation
uses
 msesystypes,msesys,msefileutils,sysutils,msearrayutils;

procedure setstatfilevar(const sender: istatfile; const source: tstatfile;
              var instance: tstatfile);
var
 int1: integer;
begin
 if source <> instance then begin
  if (instance <> nil) and (stfs_reading in instance.fstate) then begin
   for int1:= 0 to high(instance.aclients) do begin
    with instance.aclients[int1] do begin
     if intf = sender then begin
      intf:= nil;
     end;
    end;
   end;
  end;
  if (source <> nil) and (stfs_reading in source.fstate) then begin
   setlength(source.aclients,high(source.aclients)+2);
   source.aclients[high(source.aclients)].intf:= sender;
  end;
 end;
 setlinkedcomponent(sender,source,tmsecomponent(instance),typeinfo(istatfile));
end;

////////////////////////////////////////////
FUNCTION SavedMemoryFiles (CONST Filer: tstatfiler): msestringarty;
 BEGIN
   IF filer IS tStatReader THEN BEGIN
     Result:= (Filer AS tStatReader).ReadArray ('savedmemoryfiles', msestringarty (NIL));
   END;
 END;

PROCEDURE registerNewMemoryFile (StateFile: tStatFile; CONST SavedName: msestring);
 BEGIN
   WITH  StateFile DO
     IF savedmemoryfiles <> ''
       THEN savedmemoryfiles:= savedmemoryfiles+ ' '+ SavedName
       ELSE savedmemoryfiles:= SavedName;
 END;

PROCEDURE registerSavedMemoryFiles (StateFile: tStatFile; CONST SavedNames: msestringarty);
 VAR
   i:        integer;
   NameList: msestring;
 BEGIN
   NameList:= '';
   WITH  StateFile DO
     IF savedmemoryfiles <> ''
       THEN NameList:= savedmemoryfiles+ ' ';

   FOR i:= 0 TO high (SavedNames) DO
     NameList:= NameList+ ' '+ uppercase (SavedNames [i]);

   StateFile.savedmemoryfiles:= NameList;
 END;
////////////////////////////////////////////

{ tstatfile }

constructor tstatfile.create(aowner: tcomponent);
begin
// ffilename:= defaultstatfilename;
 fencoding:= ce_utf8;
 foptions:= defaultstatfileoptions;
 inherited;
end;

procedure tstatfile.initnewcomponent(const ascale: real);
begin
 ffilename:= defaultstatfilename;
end;

procedure tstatfile.dostatread(const reader: tstatreader);
var
 ar1,ar2: stringarty;
 ar3: msestringarty;
 stream1: ttextstream;
 int1: integer;
 reader1: tstatreader;
begin
 ar1:= nil; //compiler warning
 ar2:= nil; //compiler warning
 if reader <> areader then begin
  if not (sfo_memory in foptions) then begin
   if sfo_savedata in foptions then begin
    reader1:= areader;
    areader:= reader;
    try
     internalreadstat;
    finally;
     areader:= reader1;
    end;
   end
   else begin
    filename:= reader.readmsestring('filename',ffilename);
   end;
  end
  else begin
   if sfo_savedata in foptions then begin
    stream1:= memorystatstreams.open(ffilename,fm_read);
    try
     ar2:= stream1.readstrings;
    finally
     stream1.free;
    end;
    ar1:= reader.readarray('data',ar2);
    stream1:= memorystatstreams.open(ffilename,fm_create);
    try
     stream1.writestrings(ar1);
    finally
     stream1.free;
    end;
    if sfo_autoreadstat in foptions then begin
     readstat;
    end;
   end;
  end;
//  statread;
 end
 else begin
/////////////////////////////////////
// moved before reloading saved memeory files
// to allow for inspection, modification and handling
  if assigned(fonstatupdate) then begin
   fonstatupdate(self,reader);
  end;
/////////////////////////////////////
  if fsavedmemoryfiles <> '' then begin
   ar3:= reader.readarray('savedmemoryfiles',msestringarty(nil));
   for int1:= 0 to high(ar3) do begin
    reader.readmemorystatstream(ar3[int1],ar3[int1]);
   end;
  end;
/////////////////////////////////////
//  previous position: fonstatupdate(self,reader);
  if assigned(fonstatread) then begin
   fonstatread(self,reader);
  end;
 end;
end;

procedure tstatfile.dostatwrite(const writer: tstatwriter);
var
 ar1: stringarty;
 ar3: msestringarty;
 stream1: ttextstream;
 int1: integer;
 writer1: tstatwriter;
begin
 ar1:= nil;  //compiler warning
 if (writer <> awriter) then begin
  if not (sfo_memory in foptions) then begin
   if sfo_savedata in foptions then begin
    writer1:= awriter;
    awriter:= writer;
    try
     internalwritestat;
    finally;
     awriter:= writer1;
    end;
   end
   else begin
    writer.writemsestring('filename',ffilename);
   end;
  end
  else begin
   if sfo_savedata in foptions then begin
    if sfo_autowritestat in foptions then begin
     writestat;
    end;
    stream1:= memorystatstreams.open(ffilename,fm_read);
    try
     ar1:= stream1.readstrings;
    finally
     stream1.free;
    end;
    writer.writearray('data',ar1);
   end;
  end;
//  if ffilename <> '' then begin
//   writestat;
//  end;
 end
 else begin
/////////////////////////////////////
// moved before (re)saving stored memeory files
// to allow for inspection, modification and handling
  if assigned(fonstatupdate) then begin
   fonstatupdate(self,writer);
  end;
/////////////////////////////////////
  if fsavedmemoryfiles <> '' then begin
   ar3:= memorystatstreams.findfiles(fsavedmemoryfiles);
   writer.writearray('savedmemoryfiles',ar3);
   for int1:= 0 to high(ar3) do begin
    writer.writememorystatstream(ar3[int1],ar3[int1]);
   end;
/////////////////////////////////////
//  previous position: fonstatupdate(self,writer);
  end;
  if assigned(fonstatwrite) then begin
   fonstatwrite(self,writer);
  end;
 end;
end;

function tstatfile.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tstatfile.dolinkstatread(const info: linkinfoty);
begin
 areader.readstat(istatfile(info.dest));
end;

procedure tstatfile.dolinkstatreading(const info: linkinfoty);
begin
 with pstatclientinfoty(additempo(aclients,typeinfo(statclientarty),
                                                   aclientcount))^ do begin
  intf:= istatfile(info.dest);
  priority:= intf.getstatpriority;
 end;
 istatfile(info.dest).statreading;
end;

procedure tstatfile.objevent(const sender: iobjectlink;
                                       const event: objecteventty);
var
 int1: integer;
begin
 if event = oe_destroyed then begin
  for int1:= 0 to high(aclients) do begin
   if aclients[int1].intf = sender then begin
    aclients[int1].intf:= nil;
   end;
  end;
 end;
 inherited;
end;

procedure tstatfile.dolinkstatreaded(const info: linkinfoty);
begin
 istatfile(info.dest).statread;
end;

procedure tstatfile.updateoptions(const afiler: tstatfiler);
var
 opt1: statfileroptionsty;
begin
 opt1:= afiler.options;
 if sfo_nodata in foptions then begin
  include(opt1,sfro_nodata);
 end;
 if sfo_nostate in foptions then begin
  include(opt1,sfro_nostate);
 end;
 if sfo_nooptions in foptions then begin
  include(opt1,sfro_nooptions);
 end;
 afiler.options:= opt1;
end;

function tstatfile.defaultfile(const adirs: filenamearty): filenamety;
begin
 if high(adirs) >= 0 then begin
  result:= filepath(adirs[0],ffilename);
 end
 else begin
  result:= filepath(ffilename);
 end;
end;

function cmpclients(const l,r): integer;
begin
 result:= statclientinfoty(r).priority - statclientinfoty(l).priority;
                  //highest priority first
end;

procedure tstatfile.internalreadstat;
var
 int1: integer;
begin
 if assigned(fonstatread) or assigned(fonstatupdate) or
                                  (fsavedmemoryfiles <> '') then begin
  areader.readstat(istatfile(self));
 end;
 if fobjectlinker <> nil then begin
  aclients:= nil;
  aclientcount:= 0;
  fobjectlinker.forall({$ifdef FPC}@{$endif}dolinkstatreading,
                                                     typeinfo(istatfile));
  setlength(aclients,aclientcount);
  sortarray(aclients,sizeof(statclientinfoty),@cmpclients);
  include(fstate,stfs_reading);
  try
   int1:= 0;
   while int1 <= high(aclients) do begin
    with aclients[int1] do begin
     if intf <> nil then begin
      areader.readstat(intf);
     end;
    end;
    inc(int1);
   end;
//   fobjectlinker.forall({$ifdef FPC}@{$endif}dolinkstatread,
//                                                     typeinfo(istatfile));
  finally
   exclude(fstate,stfs_reading);
   aclients:= nil;
   fobjectlinker.forall({$ifdef FPC}@{$endif}dolinkstatreaded,
                                                     typeinfo(istatfile));
  end;
//    if assigned(fonstatafterread) then begin
//     fonstatafterread(self);
//    end;
 end;
end;

/////////////////////////////////////////////
PROCEDURE tstatfile.completepath (ar1: filenamearty);
 VAR
   i: integer;
 BEGIN
   FOR i:= 0 TO high (ar1) DO BEGIN
{$IFDEF linux OR defined (freebsd) or defined (netbsd) OR
                 defined (openbsd) OR defined (Solaris)}
     // On Linux, resolve tilde character and replace with home directory
     IF ar1 [i][1] = '~'
       THEN ar1 [i]:= GetEnvironmentVariable ('HOME')+
                      Copy (ar1 [i], 2, Length (ar1 [i]));
{$ENDIF}
     // No directory separator after directory name?
     IF ar1 [i][Length (ar1 [i])] <> DirectorySeparator
       THEN ar1 [i]:= ar1 [i]+ DirectorySeparator;
   END;
 END;
/////////////////////////////////////////////

procedure tstatfile.readstat(const stream: ttextstream = nil);
var
 stream1: ttextstream;
 ar1: filenamearty;
 by1: boolean;
begin
 if stfs_reading in fstate then begin
  exit;
 end;
 if assigned(fonstatbeforeread) then begin
  fonstatbeforeread(self);
 end;
 stream1:= stream;
/////////////////////////////////////////////
// Suggestion: if no filename specified, use executable base name - ???
// - optionally do so only if a NEWLY DEFINED option ("sfo_useexename" or so) is set
// - presumes fixed extension of "ConfExt = '.sta';" or such
// -code:
   IF (sfo_useexename in foptions) AND (NOT (sfo_memory in foptions)) AND
      (stream1 = nil) AND  // not a memory stat file ??
      (fFileName = '')     // use program name as a "last ressort"
   THEN fFileName:= ExtractFilename (Argv [0])+ StatExt;
/////////////////////////////////////////////
 try
  if (stream1 = nil) and (filename <> '') then begin
   if sfo_memory in foptions then begin
    floadedfile:= '';
    stream1:= memorystatstreams.open(ffilename,fm_read);
   end
   else begin
    by1:= false;
    repeat
     unquotefilename(ffiledir,ar1);
/////////////////////////////////////////////
     completepath (ar1);
/////////////////////////////////////////////
     if not findfile(ffilename,ar1,floadedfile) then begin
      floadedfile:= ffilename;
     end;
     if ttextstream.trycreate(stream1,floadedfile,fm_read) <> sye_ok then begin
      floadedfile:= defaultfile(ar1);
      if assigned(fonfilemissing) then begin
       fonfilemissing(self,floadedfile,stream1,by1);
       if stream1 <> nil then begin
        floadedfile:= '';
       end;
      end;
     end;
    until (stream1 <> nil) or not by1;
    if stream1 = nil then begin
     floadedfile:= '';
    end;
   end;
  end;
  if (fcryptohandler <> nil) and (stream1 <> nil) then begin
   stream1.cryptohandler:= fcryptohandler;
  end;
  areader:= tstatreader.create(stream1,fencoding);
  updateoptions(areader);
  try
   internalreadstat;
  finally
   freeandnil(areader);
//   areader.free;
  end;
 finally
  if stream = nil then begin
   stream1.Free;
   if (stream1 <> nil) and (foptions * [sfo_memory,sfo_deletememorydata] =
         [sfo_memory,sfo_deletememorydata]) then begin
    memorystatstreams.delete(ffilename);
   end;
  end
  else begin
   if (fcryptohandler <> nil) and (stream1 <> nil) then begin
    stream1.cryptohandler:= nil;
   end;
  end;
 end;
 if fnext <> nil then begin
  fnext.readstat(nil);
 end;
 if assigned(fonstatafterread) then begin
  fonstatafterread(self);
 end;
end;

procedure tstatfile.readstat(const afilename: filenamety);
var
 stream1: ttextstream;
begin
 stream1:= ttextstream.create(afilename,fm_read);
 try
  stream1.encoding:= fencoding;
  readstat(stream1);
 finally
  stream1.free;
 end;
end;

procedure tstatfile.writestat(const afilename: filenamety);
var
 stream1: ttextstream;
 fname1: filenamety;
begin
 fname1:= afilename;
 if sfo_transaction in foptions then begin
  stream1:= ttextstream.createtransaction(fname1);
 end
 else begin
  stream1:= ttextstream.create(fname1,fm_create);
 end;
 try
  stream1.encoding:= fencoding;
  writestat(stream1);
 finally
  stream1.free;
 end;
end;

procedure tstatfile.statreading;
begin
 //dummy
end;

procedure tstatfile.statread;
begin
 //dummy
end;

procedure tstatfile.dolinkstatwrite(const info: linkinfoty);
begin
 awriter.writestat(istatfile(info.dest));
end;

procedure tstatfile.internalwritestat;
begin
 if assigned(fonstatwrite) or assigned(fonstatupdate) or
                                  (fsavedmemoryfiles <> '') then begin
  awriter.writestat(istatfile(self));
 end;
 if fobjectlinker <> nil then begin
  fobjectlinker.forall({$ifdef FPC}@{$endif}dolinkstatwrite,typeinfo(istatfile));
 end;
end;

procedure tstatfile.writestat(const stream: ttextstream = nil);
var
 stream1: ttextstream;
 ar1: filenamearty;
// fname1: filenamety;
 bo1: boolean;
begin
 if assigned(fonstatbeforewrite) then begin
  fonstatbeforewrite(self);
 end;
 if fnext <> nil then begin
  fnext.writestat(nil);
 end;
 stream1:= stream;
 if (stream1 = nil) and (filename <> '') then begin
  if sfo_memory in foptions then begin
   stream1:= memorystatstreams.open(ffilename,fm_create);
  end
  else begin
   if floadedfile = '' then begin
    unquotefilename(ffiledir,ar1);
/////////////////////////////////////////////
    completepath (ar1);
/////////////////////////////////////////////
    if not findfile(ffilename,ar1,floadedfile) then begin
     floadedfile:= defaultfile(ar1);
    end;
    if (sfo_createpath in foptions) and not findfile(floadedfile) then begin
     createdirpath(msefileutils.filedir(floadedfile));
    end;
   end;
   try
    if sfo_transaction in foptions then begin
     stream1:= ttextstream.createtransaction(floadedfile);
    end
    else begin
     stream1:= ttextstream.Create(floadedfile,fm_create);
    end;
   except
    floadedfile:= '';
    raise;
   end;
  end;
//  stream1.encoding:= fencoding;
 end;
 if stream1 = nil then begin
  exit;
 end;
 try
  if (fcryptohandler <> nil) then begin
   stream1.cryptohandler:= fcryptohandler;
  end;
  awriter:= tstatwriter.create(stream1,fencoding);
  updateoptions(awriter);
  bo1:= false;
  try
   if (stream1.handle <> invalidfilehandle) and
                                  not stream1.usewritebuffer then begin
    bo1:= true;
    stream1.usewritebuffer:= true;
   end;
   internalwritestat;
//   if assigned(fonstatafterwrite) then begin
//    fonstatafterwrite(self);
//   end;
  finally
   freeandnil(awriter);
   if bo1 then begin
    stream1.usewritebuffer:= false;
   end;
  end;
 finally
  if stream = nil then begin
   stream1.Free;
  end
  else begin
   if (fcryptohandler <> nil) then begin
    stream1.cryptohandler:= nil;
   end;
  end;
 end;
 if assigned(fonstatafterwrite) then begin
  fonstatafterwrite(self);
 end;
end;

procedure tstatfile.setstatfile(const Value: tstatfile);
var
 sf: tstatfile;
begin
 if fstatfile <> value then begin
  if value <> nil then begin
   sf:= value;
   while sf <> nil do begin
    if sf = self then begin
     raise exception.Create(name+': Recursive statfile');
    end;
    sf:= sf.fstatfile;
   end;
  end;
  setstatfilevar(istatfile(self),value,fstatfile);
 end;
end;

procedure tstatfile.setfilename(const avalue: filenamety);
begin
 floadedfile:= '';
 ffilename:= avalue;
end;

procedure tstatfile.setfiledir(const avalue: filenamety);
begin
 floadedfile:= '';
 ffiledir:= avalue;
end;
{
procedure tstatfile.setoptions(avalue: statfileoptionsty);
begin
 if not (sfo_memory in avalue) then begin
  exclude(avalue,sfo_savedata);
 end;
 foptions:= avalue;
end;
}
procedure tstatfile.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (sender = activator) and not (csdesigning in componentstate) then begin
  case event of
   oe_activate: begin
    if sfo_activatorwrite in foptions then begin
     readstat;
    end;
   end;
   oe_deactivate: begin
    if sfo_activatorwrite in foptions then begin
     writestat;
    end;
   end;
   else ;
  end;
 end;
end;

procedure tstatfile.readstat(const aname: msestring;
                                 const statreader: tstatreader);
var
 stream: ttextstream;
 ar1: msestringarty;
begin
 ar1:= statreader.readarray(aname,msestringarty(nil));
 stream:= ttextstream.Create;
 stream.encoding:= fencoding;
 try
  stream.writemsestrings(ar1);
  stream.Position:= 0;
  readstat(stream);
 finally
  stream.Free;
 end;
end;

procedure tstatfile.writestat(const aname: msestring;
                                         const statwriter: tstatwriter);
var
 stream: ttextstream;
 ar1: msestringarty;
begin
 stream:= ttextstream.Create;
 stream.encoding:= ce_utf8;
 try
  writestat(stream);
  stream.position:= 0;
  ar1:= stream.readmsestrings;
  statwriter.writearray(aname,ar1);
 finally
  stream.Free;
 end;
end;

procedure tstatfile.updatestat(const aname: msestring;
                                        const statfiler: tstatfiler);
begin
 if statfiler.iswriter then begin
  writestat(aname,tstatwriter(statfiler));
 end
 else begin
  readstat(aname,tstatreader(statfiler));
 end;
end;

procedure tstatfile.setcryptohandler(const avalue: tcustomcryptohandler);
begin
 setlinkedvar(avalue,tmsecomponent(fcryptohandler));
end;

function tstatfile.getmode: statfilemodety;
begin
 result:= sfm_inactive;
 if areader <> nil then begin
  result:= sfm_reading;
 end
 else begin
  if awriter <> nil then begin
   result:= sfm_writing;
  end;
 end;
end;

procedure tstatfile.setnext(const avalue: tstatfile);
var
 sf: tstatfile;
begin
 if fnext <> avalue then begin
  if avalue <> nil then begin
   sf:= avalue;
   while sf <> nil do begin
    if sf = self then begin
     raise exception.Create(name+': Recursive next statfile');
    end;
    sf:= sf.fnext;
   end;
  end;
  setlinkedvar(avalue,tmsecomponent(fnext));
 end;
end;

function tstatfile.getstatpriority: integer;
begin
 result:= fstatpriority;
end;

{ tstatfileitem }

function tstatfileitem.getstatfile: tstatfile;
begin
 result:= tstatfile(item);
end;

procedure tstatfileitem.setstatfile(const avalue: tstatfile);
begin
 item:= avalue;
end;

{ tstatfilearrayprop }

constructor tstatfilearrayprop.create;
begin
 inherited create(tstatfileitem);
end;

function tstatfilearrayprop.getitems(const index: integer): tstatfileitem;
begin
 result:= tstatfileitem(inherited getitems(index));
end;

class function tstatfilearrayprop.getitemclasstype: persistentclassty;
begin
 result:= tstatfileitem;
end;

end.
