{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefileutils;
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
 msesysintf,msearrayutils,msedatalist,msesystypes,msesys,msebits,msetypes,
 msestream,msestrings;

type
 filelistoptionty = (flo_sortname,flo_sorttime,flo_sortsize,
                     flo_sorttype,flo_casesensitive,flo_downsort);
 filelistoptionsty = set of filelistoptionty;
 filekindty = (fk_default,fk_file,fk_dir);

 filechangety = (fc_name,fc_attributes,fc_modtime,fc_accesstime,fc_ctime,
            fc_size,fc_removed,fc_direntries,fc_force);
 filechangesty = set of filechangety;
 checkfileeventty = procedure (const sender: tobject;
                                    const streaminfo: dirstreaminfoty;
                                    const fileinfo: fileinfoty;
                                    var accept: boolean) of object;
                                     //default true
 pathrelocateoptionty = (pro_preferenew,pro_onlynew,pro_rootpath);
 pathrelocateoptionsty = set of pathrelocateoptionty;

const
 sortflags: filelistoptionsty = [flo_sortname,flo_sorttime,flo_sortsize];
 intermediatefileextension = '.tmp';
type
 filesortfuncty = function(const l,r: fileinfoty): integer of object;

 tcustomfiledatalist = class(tdynamicdatalist)
  private
   foptions: filelistoptionsty;
   fsortfunc: filesortfuncty;
   function getitems(index: integer): fileinfoty;
   procedure setoptions(const Value: filelistoptionsty);
   function sortname(const l,r: fileinfoty): integer;
   function sorttime(const l,r: fileinfoty): integer;
   function sortsize(const l,r: fileinfoty): integer;
  protected
   procedure freedata(var data); override;
   procedure beforecopy(var data); override;
   function compare(const l,r): integer; override;
  public
   constructor create; override;
   function add(const value: fileinfoty): integer;
   function adddirectory(const directoryname: filenamety;
        ainfolevel: fileinfolevelty = fil_name; const amask: filenamearty = nil;
        const aincludeattrib: fileattributesty = [fa_all];
        const aexcludeattrib: fileattributesty = [];
        const aoptions: dirstreamoptionsty = [];
        const acheckproc: checkfileeventty = nil;
        const noexception: boolean = false): boolean; overload;
        //amask = nil -> all, true if ok
   function adddirectory(const directoryname: filenamety;
        ainfolevel: fileinfolevelty; const amask: filenamety;
        const aincludeattrib: fileattributesty = [fa_all];
        const aexcludeattrib: fileattributesty = [];
        const aoptions: dirstreamoptionsty = [];
        const acheckproc: checkfileeventty = nil;
        const noexception: boolean = false): boolean; overload;
        //amask = '' -> all, true if ok
   {$ifndef FPC}
   function adddirectory1(const directoryname: filenamety;
        ainfolevel: fileinfolevelty = fil_name; const amask: filenamearty = nil;
        const aincludeattrib: fileattributesty = [fa_all];
        const aexcludeattrib: fileattributesty = [];
        const aoptions: dirstreamoptionsty = [];
        const acheckproc: checkfileeventty = nil;
        const noexception: boolean = false): boolean;
        //amask = nil -> all, true if ok
   function adddirectory2(const directoryname: filenamety;
        ainfolevel: fileinfolevelty; const amask: filenamety;
        const aincludeattrib: fileattributesty = [fa_all];
        const aexcludeattrib: fileattributesty = [];
        const aoptions: dirstreamoptionsty = [];
        const acheckproc: checkfileeventty = nil;
        const noexception: boolean = false): boolean;
        //amask = '' -> all, true if ok
   {$endif}
   function itempo(const index: integer): pfileinfoty;
    //invalid after capacity change!
   function indexof(const filename: filenamety): integer;
              //case sensitive
   function isdir(index: integer): boolean;
   property items[index: integer]: fileinfoty read getitems; default;
   property options: filelistoptionsty read foptions write setoptions default [];
 end;

 tfiledatalist = class(tcustomfiledatalist)
  published
   property options;
 end;

function quotefilename(const name: filenamety): filenamety; overload;
function quotefilename(const directory,name: filenamety): filenamety; overload;
function quotefilename(const names: filenamearty): filenamety; overload;
function quotefilename(const names: array of filenamety): filenamety; overload;
procedure unquotefilename(const names: filenamety;
                               var result: filenamearty); overload;
function unquotefilename(const name: filenamety): filenamety; overload;
function extractrootpath(var names: filenamearty): filenamety;
function combinerootpath(const rootpath: filenamety;
                               const names: filenamearty): filenamearty; overload;
function combinerootpath(const rootpaths: filenamearty;
                               const name: filenamety): filenamearty; overload;

function syscommandline(const acommandline: filenamety): filenamety;
                 //converts exec path to sys format
function filepath({const} directory: filenamety; {const} filename: filenamety;
                        kind: filekindty = fk_default;
                        relative: boolean = false): filenamety; overload;
 //directory ignored if filename starts with root
 //"~/....." expands to sys_getuserhomedir()/.....
 //"^/....." expands to sys_getapphomedir()/.....

function filepath({const} path: filenamety;
                        kind: filekindty = fk_default;
                        relative: boolean = false): filenamety; overload;
function relativepath(const path: filenamety; const root: filenamety = '';
                        const kind: filekindty = fk_default): filenamety;
       //root = '' -> currentdir
function relocatepath(const olddir,newdir: filenamety;
          var apath: filenamety;
                     const options: pathrelocateoptionsty = []): boolean;
//searches file in newdir relative to olddir or in original position,
//updates apath, returns true if found
function isrelativepath(const path: filenamety): boolean;
function isrootdir(const path: filenamety): boolean;
function removelastpathsection(path: filenamety): filenamety;
function getlastpathsection(const path: filenamety): filenamety;
function removelastdir(path: filenamety; var newpath: filenamety): filenamety;
procedure splitfilepath(const path: filenamety;
                            out directory,filename: filenamety); overload;
procedure splitfilepath(const path: filenamety;
                            out directory,filename,fileext: filenamety); overload;
function splitfilepath(const path: filenamety): filenamearty;
function splitrootpath(const path: filenamety): filenamearty;
function mergerootpath(const segments: filenamearty): filenamety;

function checkfilename(const filename,mask: filenamety;
                          casesensitive: boolean = false): boolean; overload;
          //true if filename fits mask, maskchars: '*','?'
function checkfilename(const filename: filenamety; const mask: filenamearty;
                          casesensitive: boolean = false): boolean; overload;
function checkfilename(const filename: filenamety;
                        const dirstream: dirstreamty): boolean; overload;
function hasmaskchars(const filename: filenamety): boolean;
function issamefilename(const a,b: filenamety): boolean;
function issamefilepath(const a,b: filenamety): boolean;

function filename(const path: filenamety): filenamety;
function filedir(const path: filenamety): filenamety;
function filenamebase(const path: filenamety): filenamety; //without ext
function fileext(const path: filenamety): filenamety;
function removefileext(const path: filenamety): filenamety;
function hasfileext(const path: filenamety): boolean;
function checkfileext(const path: filenamety; const extensions: array of filenamety): boolean;
function replacefileext(const path,newext: filenamety): filenamety;

function tomsefilepath(const path: filenamety;
                                const quoted: boolean = false): filenamety;
procedure tomsefilepath1(var path: filenamety; const quoted: boolean = false);
function tosysfilepath(const path: filenamety;
                                const quoted: boolean = false): filenamety;
function tosysfilepath(const path: filenamearty;
                                const quoted: boolean = false): filenamearty;
procedure tosysfilepath1(var path: filenamety; const quoted: boolean = false);

function searchfile(const filename: filenamety; dir: boolean = false;
                     const aoptions: dirstreamoptionsty = []): filenamety; overload;
           //returns rootpath if file exists, '' otherwise
function searchfile(const afilename: filenamety;
                      const adirnames: array of filenamety;
                      const ainclude: fileattributesty = [fa_all];
                      const aexclude: fileattributesty = [];
                      const aoptions: dirstreamoptionsty = []): filenamety; overload;
           //returns directory of last occurence in dirs, '' if none
           //afilename can be path and can have wildchars ('?','*'),
           //adirnames can have wildchars ('?','*','**','***')
              //'?'   -> any char
              //'*'   -> any chars
              //'**'  -> 1..x directory levels
              //'***' -> 0..x directory levels
function searchfile(const afilename: filenamety; const adirname: filenamety;
                  const ainclude: fileattributesty = [fa_all];
                  const aexclude: fileattributesty = [];
                  const aoptions: dirstreamoptionsty = []): filenamety; overload;
           //returns directory, '' if none
           //afilename must be simple filename and can have wildchars ('?','*'),
           //adirname can have wildchars ('?','*','**','***')

function searchfiles(const afilename: filenamety;
              const adirnames: array of filenamety;
              const ainclude: fileattributesty = [fa_all];
              const aexclude: fileattributesty = [];
              const aoptions: dirstreamoptionsty = []): filenamearty; overload;
           //returns filepaths
           //afilename can be path or quoted list of paths
           //and can have wildchars ('?','*') example: '"a/*.pas" "b/*.pp"',
           //adirnames can have wildchars ('?','*','**','***')
function searchfiles(const afilename: filenamety;
               const adirname: filenamety;
               const ainclude: fileattributesty = [fa_all];
               const aexclude: fileattributesty = [];
               const aoptions: dirstreamoptionsty = []): filenamearty; overload;
         //returns filepaths
         //afilename must be simple filename or quoted list of simple filenames
         //and can have wildchars ('?','*') example: '"*.pp" "*.pas"',
         //adirname can have wildchars ('?','*','**','***')

function searchfilenames(const afilename: filenamety; const adirname: filenamety;
                      const ainclude: fileattributesty = [fa_all];
                      const aexclude: fileattributesty = [];
                      const aoptions: dirstreamoptionsty = []): filenamearty;
           //returns filenames
           //afilename must be simple filename or quoted list of simple filenames
           //and can have wildchars ('?','*') example: '"*.pp" "*.pas"',
           //empty -> all

function dirhasentries(const adirname: filenamety;
                         const ainclude: fileattributesty = [fa_all];
                         const aexclude: fileattributesty = []): boolean;

function findfile(filename: filenamety; //no const bcause of var path param
                             const dirnames: array of filenamety;
                             var path: filenamety): boolean; overload;
                               //no out because of caller side finalization
                               //true if found, path not touched if not found
function findfile(filename: filenamety; //no const bcause of var path param
                             var path: filenamety): boolean; overload;
                               //no out because of caller side finalization
                               //true if found, path not touched if not found
function findfile(const filename: filenamety; const dirnames:
                         array of filenamety): boolean; overload;
function findfile(const filename: filenamety): boolean; overload;
function finddir(const filename: filenamety): boolean;
function findfileordir(const filename: filenamety): boolean;
function uniquefilename(const path: filenamety): filenamety;
                             //adds numbers if necessary

function isrootpath(const path: filenamety): boolean;
function copyfile(const oldfile,newfile: filenamety;
                                const canoverwrite: boolean = true): boolean;
                      //false if newfile exists and not canoverwrite
function trycopyfile(const oldfile,newfile: filenamety;
                                const canoverwrite: boolean = true): boolean;
                      //false on error or newfile exists and not canoverwrite
function renamefile(const oldname,newname: filenamety;
                                const canoverwrite: boolean = true): boolean;
                      //false if newname exists and not canoverwrite
function deletefile(const filename: filenamety): boolean;
                      //false if not existing
function trydeletefile(const filename: filenamety): boolean;
                      //false if not existing or not deleted
procedure createdir(const path: filenamety;
                                 const rights: filerightsty = defaultdirrights);
procedure createdirpath(const path: filenamety;
                                 const rights: filerightsty = defaultdirrights);
function deletedir(const path: filenamety): boolean;
           //deletes files and directories recursively, false if not existing
function trydeletedir(const path: filenamety): boolean;
     //deletes files and directories recursively,
     // false if not existing or not deleted
function getcurrentdir: filenamety; deprecated;
function getcurrentdirmse: filenamety;
function setcurrentdir(const path: filenamety): filenamety; deprecated;
function setcurrentdirmse(const path: filenamety): filenamety;
function trysetcurrentdirmse(const path: filenamety): boolean; overload;
function trysetcurrentdirmse(const path: filenamety;
                            out pathbefore: msestring): boolean; overload;

procedure clearfileinfo(var info: fileinfoty);
procedure initdirfileinfo(var info: fileinfoty; const aname: filenamety;
                                                        open: boolean = false);
function getfileinfo(const path: filenamety; var info: fileinfoty): boolean;
                  //false if not found
function getfilemodtime(const path: filenamety): tdatetime;
           //empty date if not found

function filesystemiscaseinsensitive: boolean;

function compfileinfos(const info1,info2: fileinfoty): filechangesty;
function compfiletime(const a,b: tdatetime): integer;
            //-1 if a < b, 0 if a = b, 1 if a > b

function intermediatefilename(const aname: filenamety): filenamety;
function msegettempdir: filenamety;
function msegettempfilename(const aname: filenamety): filenamety;

implementation
uses
 sysutils,msedate,mseprocutils,mseformatstr;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

const
 quotechar = msechar('"');
 slashchar = msechar('/');
 dotchar = msechar('.');

type
 checkmaskresultty = (cmr_correct,cmr_wrong,cmr_wrongfinished,cmr_correctfinished);
const
 checkmaskfinished = cmr_wrongfinished;

function msegettempdir: filenamety;
begin
 result:= sys_gettempdir;
end;

function msegettempfilename(const aname: filenamety): filenamety;
begin
 result:= intermediatefilename(filepath(msegettempdir,aname,fk_file));
end;

function intermediatefilename(const aname: filenamety): filenamety;
var
 fname1,fname2: filenamety;
 int1: integer;
begin
 fname1:= aname + intermediatefileextension + inttostrmse(getpid);
 fname2:= fname1;
 int1:= 0;
 while findfile(fname2) do begin
  inc(int1);
  fname2:= fname1 + '_'+inttostrmse(int1);
 end;
 result:= fname2;
end;

procedure commitstreamtransaction(const astream: tmsefilestream;
                                     const aname: filenamety);
var
 fname1: filenamety;
begin
 astream.flush;
 fname1:= astream.filename;
 astream.close;
 msefileutils.renamefile(fname1,aname);
end;

function compfiletime(const a,b: tdatetime): integer;
            //-1 if a < b, 0 if a = b, 1 if a > b
const
 deltamin = 1/(24*60*60*1000); //1 ms

var
 rea1: real;
begin
 result:= 0;
 rea1:= a - b;
 if rea1 < -deltamin then begin
  result:= -1;
 end
 else begin
  if rea1 > deltamin then begin
   result:= 1;
  end;
 end;
end;

function compfileinfos(const info1,info2: fileinfoty): filechangesty;
begin
 result:= [];
 if info1.name <> info2.name then include(result,fc_name);
 if info1.extinfo1.attributes <> info2.extinfo1.attributes then include(result,fc_attributes);
 if compfiletime(info1.extinfo1.modtime,info2.extinfo1.modtime) <> 0 then include(result,fc_modtime);
 if compfiletime(info1.extinfo1.accesstime,info2.extinfo1.accesstime) <> 0 then include(result,fc_accesstime);
 if compfiletime(info1.extinfo1.ctime,info2.extinfo1.ctime) <> 0 then include(result,fc_ctime);
 if info1.extinfo1.size <> info2.extinfo1.size then include(result,fc_size);
end;

procedure clearfileinfo(var info: fileinfoty);
begin
 finalize(info);
 fillchar(info,sizeof(info),0);
end;

procedure initdirfileinfo(var info: fileinfoty; const aname: filenamety; open: boolean = false);
begin
 clearfileinfo(info);
 with info do begin
  name:= aname;
  if open then begin
   state:= [fis_typevalid,fis_diropen];
  end
  else begin
   state:= [fis_typevalid];
  end;
  extinfo1.filetype:= ft_dir;
 end;
end;

function getfileinfo(const path: filenamety; var info: fileinfoty): boolean;
                  //false if not found
begin
 result:= sys_getfileinfo(path,info);
end;

function getfilemodtime(const path: filenamety): tdatetime;
           //empty date if not found
var
 info1: fileinfoty;
begin
 if getfileinfo(path,info1) then begin
  result:= info1.extinfo1.modtime;
 end
 else begin
  result:= emptydatetime;
 end;
end;

function copyfile(const oldfile,newfile: filenamety;
                                const canoverwrite: boolean = true): boolean;
                      //false if dest exists and not canoverwrite
 //todo: remove race condition
begin
 if not canoverwrite and findfile(newfile) then begin
  result:= false;
 end
 else begin
  result:= true;
  syserror(sys_copyfile(oldfile,newfile),
            'Can not copy File "'+oldfile+'" to "'+newfile+'": ');
 end;
end;

function trycopyfile(const oldfile,newfile: filenamety;
                                const canoverwrite: boolean = true): boolean;
                      //false if dest exists and not canoverwrite
begin
 //todo: remove race condition
 if not canoverwrite and findfile(newfile) then begin
  result:= false;
 end
 else begin
  result:= sys_copyfile(oldfile,newfile) = sye_ok;
 end;
end;

function renamefile(const oldname,newname: filenamety;
                                const canoverwrite: boolean = true): boolean;
                      //false if newname exists and not canoverwrite
begin
 if not canoverwrite and findfile(newname) then begin
  result:= false;
 end
 else begin
  result:= true;
  syserror(sys_renamefile(oldname,newname),
          'Can not rename File "'+oldname+'" to "'+newname+'": ');
 end;
end;

function deletefile(const filename: filenamety): boolean;
                      //false if not existing
var
 err: syserrorty;
begin
 err:= sys_deletefile(filename);
 result:= err = sye_ok;
 if not result and findfile(filename) then begin
  syserror(err,'Can not delete file "'+filename+'".');
 end;
end;

function trydeletefile(const filename: filenamety): boolean;
                      //false if not existing or not deleted
begin
 result:= sys_deletefile(filename) = sye_ok;
end;

function deletefilesanddir(const path: filenamety): syserrorty;
var
 ar1: filenamearty;
 i1: int32;
begin
 ar1:= searchfilenames('',path,[fa_all],[fa_dir]);
 for i1:= 0 to high(ar1) do begin
  result:= sys_deletefile(path+'/'+ar1[i1]);
  if result <> sye_ok then begin
   exit;
  end;
 end;
 ar1:= searchfilenames('',path,[fa_dir]);
 for i1:= 0 to high(ar1) do begin
  result:= deletefilesanddir(path+'/'+ar1[i1]);
  if result <> sye_ok then begin
   exit;
  end;
 end;
 result:= sys_deletedir(path);
end;

function deletedir(const path: filenamety): boolean;
           //deletes files and directories recursively, false if not existing
var
 err: syserrorty;
begin
 err:= deletefilesanddir(path);
 result:= err = sye_ok;
 if not result and finddir(path) then begin
  syserror(err,'Can not delete dir "'+path+'". ');
 end;
end;

function trydeletedir(const path: filenamety): boolean;
     //deletes files and directories recursively,
     // false if not existing or not deleted
begin
 result:= deletefilesanddir(path) = sye_ok;
end;

procedure createdir(const path: filenamety;
                               const rights: filerightsty = defaultdirrights);
begin
// syserror(sys_createdir(tosysfilepath(path)));
 syserror(sys_createdir(path,rights));
end;

procedure createdirpath(const path: filenamety;
                                 const rights: filerightsty = defaultdirrights);
var
 ar1: filenamearty;
 mstr1: filenamety;
 int1: integer;
begin
 ar1:= splitrootpath(path);
 mstr1:= '';
 for int1:= 0 to high(ar1) do begin
  mstr1:= mstr1+slashchar+ar1[int1];
  if not finddir(mstr1) then begin
   createdir(mstr1,rights);
  end;
 end;
end;

function getcurrentdirmse: filenamety;
begin
 result:= sys_getcurrentdir;
end;

function getcurrentdir: filenamety;
begin
 result:= getcurrentdirmse;
end;

function setcurrentdirmse(const path: filenamety): filenamety;
var
 error: syserrorty;
begin
//writeln('mynameis ' + path);
 result:= sys_getcurrentdir;
 error:= sys_setcurrentdir(path);
 if error <> sye_ok then begin
  syserror(error,'Setcurrentdir "'+ path + quotechar+':'+lineend);
 end;
end;

function trysetcurrentdirmse(const path: filenamety;
                            out pathbefore: filenamety): boolean;
begin
 pathbefore:= sys_getcurrentdir;
 result:= sys_setcurrentdir(path) = sye_ok;
end;

function trysetcurrentdirmse(const path: filenamety): boolean;
begin
 result:= sys_setcurrentdir(path) = sye_ok;
end;

function setcurrentdir(const path: filenamety): filenamety;
begin
 result:= setcurrentdirmse(path);
end;

function remquote(const path: filenamety): filenamety;
begin
 if pmsechar(path)^ = quotechar then begin
  result:= copy(path,2,bigint);
 end
 else begin
  result:= path;
 end;
end;

procedure requote(var path: filenamety; const newvalue: filenamety);
begin
 if pmsechar(path)^ = quotechar then begin
  path:= quotechar + newvalue;
 end
 else begin
  path:= newvalue;
 end;
end;

function isrootpath(const path: filenamety): boolean;
var
 str1: filenamety;
begin
 str1:= remquote(path);
 tomsefilepath1(str1);
 result:= (length(str1) > 0) and (str1[1] = slashchar);
end;

procedure checkmask(s: pmsechar; mask: pmsechar; var result: checkmaskresultty);
var
 po1: pmsechar;
begin
 while true do begin
  if s^ = #0 then begin
   if mask^ = #0 then begin
    result:= cmr_correctfinished;
    break;
   end;
  end;
  case mask^ of
   '*': begin
    po1:= mask + 1;
    if po1^ = #0 then begin
     result:= cmr_correctfinished;
     break;
    end;
    while true do begin
     checkmask(s,po1,result);
     if (result = cmr_correctfinished) or (s^ = #0) then begin
      break;
     end;
     inc(s);
     result:= cmr_correct;
    end;
    break;
   end;
   '?': begin
    if s^ = #0 then begin
     result:= cmr_wrongfinished;
     break;
    end;
    inc(s);
    inc(mask);
   end;
   #0: begin
    result:= cmr_wrongfinished;
    break;
   end;
   else begin
    if s^ = mask^ then begin
     inc(s);
     inc(mask);
     continue;
    end
    else begin
     result:= cmr_wrong;
     break;
    end;
   end;
  end;
 end;
end;

function internalcheckfilename(const filename,mask: filenamety): boolean;
var
 checkresult: checkmaskresultty;
begin
 checkresult:= cmr_correct;
 checkmask(pmsechar(filename),pmsechar(mask),checkresult);
 result:= checkresult = cmr_correctfinished;
end;

function checkfilename(const filename,mask: filenamety;
                 casesensitive: boolean = false): boolean;
          //'*' and '?' are possible maskchars
var
 str1,str2: msestring;
begin
 if casesensitive then begin
  result:= internalcheckfilename(filename,mask);
 end
 else begin
  str1:= mseuppercase(filename);
  str2:= mseuppercase(mask);
  result:= internalcheckfilename(str1,str2);
 end;
end;

function checkfilename(const filename: filenamety; const mask: filenamearty;
                          casesensitive: boolean = false): boolean;
var
 str1,str2: msestring;
 int1: integer;
begin
 if mask = nil then begin
  result:= true;
 end
 else begin
  result:= false;
  if casesensitive then begin
   for int1:= 0 to high(mask) do begin
    if internalcheckfilename(filename,mask[int1]) then begin
     result:= true;
     break;
    end;
   end;
  end
  else begin
   str1:= mseuppercase(filename);
   for int1:= 0 to high(mask) do begin
    str2:= mseuppercase(mask[int1]);
    if internalcheckfilename(str1,str2) then begin
     result:= true;
     break;
    end;
   end;
  end;
 end;
end;

function checkfilename(const filename: filenamety;
                        const dirstream: dirstreamty): boolean;
                          //mask must be uppercase if case sensitive
var
 str1{,str2}: msestring;
 int1: integer;
begin
 with dirstream,dirinfo do begin
  if mask = nil then begin
   result:= true;
  end
  else begin
   result:= false;
   if caseinsensitive then begin
    str1:= mseuppercase(filename);
    for int1:= 0 to high(mask) do begin
     if internalcheckfilename(str1,mask[int1]) then begin
      result:= true;
      break;
     end;
    end;
   end
   else begin
    for int1:= 0 to high(mask) do begin
     if internalcheckfilename(filename,mask[int1]) then begin
      result:= true;
      break;
     end;
    end;
   end;
  end;
 end;
end;

function hasmaskchars(const filename: filenamety): boolean;
begin
 if msestrscan(pmsechar(filename),msechar('*')) = nil then begin
  result:= msestrscan(pmsechar(filename),msechar('?')) <> nil;
 end
 else begin
  result:= true;
 end;
end;

function filesystemiscaseinsensitive: boolean;
begin
 result:= sys_filesystemiscaseinsensitive;
end;

function issamefilename(const a,b: filenamety): boolean;
begin
 if filesystemiscaseinsensitive then begin
  result:= msecomparetext(filepath(a),filepath(b)) = 0;
 end
 else begin
  result:= filepath(a) = filepath(b);
 end;
end;

function issamefilepath(const a,b: filenamety): boolean;
begin
 result:= issamefilename(filepath(a),filepath(b));
end;

function searchfile(const filename: filenamety;dir: boolean = false;
         const aoptions: dirstreamoptionsty = []): filenamety; overload;
           //returns rootpath if file exists, '' otherwise
begin
 result:= filepath(filename);
 if not (dir and finddir(result) or
                 not dir and findfile(result)) then begin
  result:= '';
 end;
end;

function searchfile(const afilename: filenamety; const adirname: filenamety;
                      const ainclude: fileattributesty = [fa_all];
                      const aexclude: fileattributesty = [];
                      const aoptions: dirstreamoptionsty = []): filenamety;
var
 ar1{,ar2}: filenamearty;
 int1: integer;
 dirstream: dirstreamty;
 fileinfo: fileinfoty;
 recursive: boolean;
 fna1: filenamety;
begin
 result:= '';
 ar1:= nil; //compiler warning
 fillchar(dirstream,sizeof(dirstream),0);
 if hasmaskchars(adirname) then begin
  recursive:= false;
  ar1:= splitrootpath(adirname);
  for int1:= 0 to high(ar1) do begin
   if hasmaskchars(ar1[int1]) then begin
    with dirstream,dirinfo do begin
     if int1 > 0 then begin
      dirname:= mergerootpath(copy(ar1,0,int1));
     end
     else begin
      dirname:= slashchar;
     end;
     if ar1[int1] = '***' then begin
      deleteitem(ar1,int1);
      result:= searchfile(afilename,mergerootpath(ar1),
                                         ainclude,aexclude,aoptions);
      if result <> '' then begin
       break;
      end;
      insertitem(ar1,int1,'**');
     end;
     mask:= copy(ar1,int1,1);
     if mask[0] = '**' then begin
      recursive:= true;
      mask[0]:= '*';
     end;
     include:= [fa_dir];
     if sys_opendirstream(dirstream) <> sye_ok then begin
      exit;
     end;
     fna1:= ar1[int1];
     while sys_readdirstream(dirstream,fileinfo) do begin
      if (fileinfo.name <> dotchar) and (fileinfo.name <> '..') then begin
       ar1[int1]:= fileinfo.name;
       result:= searchfile(afilename,mergerootpath(ar1),ainclude,
                                                      aexclude,aoptions);
       if result <> '' then begin
        break;
       end;
       if recursive then begin
        insertitem(ar1,int1+1,'**');
        result:= searchfile(afilename,mergerootpath(ar1));
        if result <> '' then begin
         break;
        end;
        deleteitem(ar1,int1+1);
       end;
      end;
     end;
     ar1[int1]:= fna1;
    end;
    sys_closedirstream(dirstream);
    exit;
   end;
  end;
 end
 else begin
  with dirstream,dirinfo do begin
   dirname:= filepath(adirname,fk_file);
   if afilename <> '' then begin
    setlength(mask,1);
    mask[0]:= afilename;
   end;
   include:= ainclude;
   exclude:= aexclude;
   if sys_opendirstream(dirstream) <> sye_ok then begin
    exit;
   end;
   if sys_readdirstream(dirstream,fileinfo) then begin
    result:= filepath(adirname,fk_dir);
   end;
   sys_closedirstream(dirstream);
  end;
 end;
end;

function searchfile(const afilename: filenamety;
                         const adirnames: array of filenamety;
                         const ainclude: fileattributesty = [fa_all];
                         const aexclude: fileattributesty = [];
                         const aoptions: dirstreamoptionsty = []): filenamety;
           //returns directory of last occurence in adirnames, '' if none
var
 int1: integer;
 dir1,file1: filenamety;
begin
 result:= '';
 file1:= trim(afilename);
 if (file1 <> '') and (high(adirnames) < 0) then begin
  splitfilepath(afilename,dir1,file1);
  result:= searchfile(file1,dir1,ainclude,aexclude,aoptions);
 end
 else begin
  for int1:= high(adirnames) downto 0 do begin
   if afilename = '' then begin
    dir1:= adirnames[int1];
   end
   else begin
    splitfilepath(filepath(adirnames[int1],afilename,fk_file,true),dir1,file1);
   end;
   result:= searchfile(file1,dir1,ainclude,aexclude,aoptions);
   if result <> '' then begin
    break;
   end;
  end;
 end;
end;

function searchfiles(const afilename: filenamety; const adirname: filenamety;
                      const ainclude: fileattributesty = [fa_all];
                      const aexclude: fileattributesty = [];
                      const aoptions: dirstreamoptionsty = []): filenamearty;
var
 ar1{,ar2}: filenamearty;
 int1,int2: integer;
 dirstream: dirstreamty;
 fileinfo: fileinfoty;
 recursive: boolean;
 fna1: filenamety;
begin
// result:= '';
 result:= nil;
 ar1:= nil; //compiler warning
 fillchar(dirstream,sizeof(dirstream),0);
 if hasmaskchars(adirname) then begin
  recursive:= false;
  ar1:= splitrootpath(adirname);
  for int1:= 0 to high(ar1) do begin
   if hasmaskchars(ar1[int1]) then begin
    with dirstream,dirinfo do begin
     if int1 > 0 then begin
      dirname:= mergerootpath(copy(ar1,0,int1));
     end
     else begin
      dirname:= slashchar;
     end;
     if ar1[int1] = '***' then begin
      deleteitem(ar1,int1);
      stackarray(searchfiles(afilename,mergerootpath(ar1),
                                          ainclude,aexclude,aoptions),result);
      insertitem(ar1,int1,'**');
     end;
     mask:= copy(ar1,int1,1);
     if mask[0] = '**' then begin
      recursive:= true;
      mask[0]:= '*';
     end;
     include:= [fa_dir];
     if sys_opendirstream(dirstream) <> sye_ok then begin
      exit;
     end;
     fna1:= ar1[int1];
     while sys_readdirstream(dirstream,fileinfo) do begin
      if (fileinfo.name <> dotchar) and (fileinfo.name <> '..') then begin
       ar1[int1]:= fileinfo.name;
       stackarray(searchfiles(afilename,
                       mergerootpath(ar1),ainclude,aexclude,aoptions),result);
       if recursive then begin
        insertitem(ar1,int1+1,'**');
        stackarray(searchfiles(afilename,
                       mergerootpath(ar1),ainclude,aexclude,aoptions),result);
        deleteitem(ar1,int1+1);
       end;
      end;
     end;
     ar1[int1]:= fna1;
    end;
    sys_closedirstream(dirstream);
    exit;
   end;
  end;
 end
 else begin
  with dirstream,dirinfo do begin
   dirname:= filepath(adirname,fk_file);
   options:= aoptions;
   if afilename <> '' then begin
    unquotefilename(afilename,mask);
//    setlength(mask,1);
//    mask[0]:= afilename;
   end;
   include:= ainclude;
   exclude:= aexclude;
   infolevel:= fil_type;
   if sys_opendirstream(dirstream) <> sye_ok then begin
    exit;
   end;
   int2:= 0;
   while sys_readdirstream(dirstream,fileinfo) do begin
    if (fileinfo.extinfo1.filetype <> ft_dir) or
                  (fileinfo.name <> dotchar) and (fileinfo.name <> '..') then begin
     if high(result) < int2 then begin
      setlength(result,int2*2+16);
     end;
     result[int2]:= filepath(dirname,fileinfo.name);
     inc(int2);
    end;
   end;
   setlength(result,int2);
   sys_closedirstream(dirstream);
  end;
 end;
end;

function searchfilenames(const afilename: filenamety; const adirname: filenamety;
                      const ainclude: fileattributesty = [fa_all];
                      const aexclude: fileattributesty = [];
                      const aoptions: dirstreamoptionsty = []): filenamearty;
var
 int2: integer;
 dirstream: dirstreamty;
 fileinfo: fileinfoty;
begin
 result:= nil;
 fillchar(dirstream,sizeof(dirstream),0);
 with dirstream,dirinfo do begin
  dirname:= filepath(adirname,fk_file);
  options:= aoptions;
  if afilename <> '' then begin
   unquotefilename(afilename,mask);
//   setlength(mask,1);
//   mask[0]:= afilename;
  end;
  include:= ainclude;
  exclude:= aexclude;
  infolevel:= fil_type;
  if sys_opendirstream(dirstream) <> sye_ok then begin
   exit;
  end;
  int2:= 0;
  while sys_readdirstream(dirstream,fileinfo) do begin
   if (fileinfo.extinfo1.filetype <> ft_dir) or
                 (fileinfo.name <> dotchar) and (fileinfo.name <> '..') then begin
    if high(result) < int2 then begin
     setlength(result,int2*2+16);
    end;
    result[int2]:= fileinfo.name;
    inc(int2);
   end;
  end;
  setlength(result,int2);
  sys_closedirstream(dirstream);
 end;
end;

function searchfiles(const afilename: filenamety;
                      const adirnames: array of filenamety;
                      const ainclude: fileattributesty = [fa_all];
                      const aexclude: fileattributesty = [];
                      const aoptions: dirstreamoptionsty = []): filenamearty;
var
 int1,i2: integer;
 dir1,file1: filenamety;
 ar1: filenamearty;
begin
 result:= nil;
 file1:= trim(afilename);
 unquotefilename(file1,ar1);
 if (file1 <> '') and (high(adirnames) < 0) then begin
  for int1:= 0 to high(ar1) do begin
   splitfilepath(ar1[int1],dir1,file1);
   stackarray(searchfiles(file1,dir1,ainclude,aexclude,aoptions),result);
  end;
 end
 else begin
  for int1:= 0 to high(adirnames) do begin
   if afilename = '' then begin
    dir1:= adirnames[int1];
    stackarray(searchfiles(file1,dir1,ainclude,aexclude,aoptions),result);
   end
   else begin
    for i2:= 0 to high(ar1) do begin
     splitfilepath(filepath(adirnames[int1],ar1[int1],fk_file,true),dir1,file1);
     stackarray(searchfiles(file1,dir1,ainclude,aexclude,aoptions),result);
    end;
   end;
  end;
 end;
end;

function dirhasentries(const adirname: filenamety;
                         const ainclude: fileattributesty = [fa_all];
                         const aexclude: fileattributesty = []): boolean;
var
 dirstream: dirstreamty;
 fileinfo: fileinfoty;
begin
 result:= false;
 fillchar(dirstream,sizeof(dirstream),0);
 with dirstream,dirinfo do begin
  dirname:= filepath(adirname,fk_file);
  include:= ainclude;
  exclude:= aexclude;
  if sys_opendirstream(dirstream) <> sye_ok then begin
   exit;
  end;
  while sys_readdirstream(dirstream,fileinfo) do begin
   if (fileinfo.name <> dotchar) and (fileinfo.name <> '..') then begin
    result:= true;
    break;
   end;
  end;
  sys_closedirstream(dirstream);
 end;
end;

function findfile(filename: filenamety;
           const dirnames: array of filenamety; var path: filenamety): boolean;
                               //true if found, path not touched if not found
var
 fna1: filenamety;
begin
 fna1:= searchfile(filename,dirnames);
 if fna1 <> '' then begin
  path:= fna1 + msefileutils.filename(filename);
  result:= true;
 end
 else begin
  result:= false;
 end;
end;

function findfile(filename: filenamety; //no const bcause of var path param
                             var path: filenamety): boolean;
                               //no out because of caller side finalization
                               //true if found, path not touched if not found
var
 fna1: filenamety;
begin
 fna1:= searchfile(filename);
 if fna1 <> '' then begin
  path:= fna1 + msefileutils.filename(filename);
  result:= true;
 end
 else begin
  result:= false;
 end;
end;

function findfile(const filename: filenamety;
                                 const dirnames: array of filenamety): boolean;
            //true if found
var
 fna1: filenamety;
begin
 result:= findfile(filename,dirnames,fna1);
end;

function findfileordir(const filename: filenamety): boolean;
var
 info: fileinfoty;
begin
{$ifdef bsd}
if (fileexists(filename)) or (directoryexists(filename)) then 
 result := true else result := false;
{$else}
 result:= sys_getfileinfo(filename,info);
{$endif}  
end;

function findfile(const filename: filenamety): boolean; overload;
var
 info: fileinfoty;
begin
{$ifdef bsd}
 result:= fileexists(filename);
{$else}
 result:= sys_getfileinfo(filename,info) and (info.extinfo1.filetype <> ft_dir);
{$endif} 
end;

function finddir(const filename: filenamety): boolean;
var
 info: fileinfoty;
begin
{$ifdef bsd}
 result:= directoryexists(filename);
{$else}
 result:= sys_getfileinfo(filename,info) and (info.extinfo1.filetype = ft_dir);
{$endif}
end;

function quotefilename(const name: filenamety): filenamety; overload;
begin
 if (findchar(name,msechar(' ')) = 0) or (name[1] = quotechar) then begin
  result:= name;
 end
 else begin
  result:= quotestring(name,quotechar);
 end;
end;

function quotefilename(const names: filenamearty): filenamety; overload;
var
 int1: integer;
begin
 result:= '';
 if length(names) = 1 then begin
  result:= quotefilename(names[0]);
 end
 else begin
  for int1:= 0 to high(names) do begin
   if pointer(names[int1]) <> nil then begin
    result:= result + quotestring(names[int1],quotechar) + ' ';
   end;
  end;
  if length(result) > 0 then begin
   setlength(result,length(result)-1);
  end;
 end;
end;

function quotefilename(const names: array of filenamety): filenamety; overload;
begin
 result:= quotefilename(opentodynarraym(names));
end;

function quotefilename(const directory,name: filenamety): filenamety;
var
 ar1: filenamearty;
 str1: filenamety;
 int1: integer;
begin
 unquotefilename(name,ar1);
 str1:= unquotefilename(trim(directory));
 if str1 <> '' then begin
  str1:= filepath(str1,fk_dir,true);
  for int1:= 0 to high(ar1) do begin
   ar1[int1]:= filepath(str1+ar1[int1],fk_file,true);
  end
 end
 else begin
  for int1:= 0 to high(ar1) do begin
   ar1[int1]:= filepath(ar1[int1],fk_file,true);
  end;
 end;
 result:= quotefilename(ar1);
end;

procedure unquotefilename(const names: filenamety; var result: filenamearty);
begin
 if findchar(names,quotechar) <> 0 then begin
  splitstringquoted(trim(names),result,quotechar);
 end
 else begin
  setlength(result,1);
  result[0]:= trim(names);
  if result[0] = '' then begin
   result:= nil;
  end;
 end;
end;

function unquotefilename(const name: filenamety): filenamety; overload;
begin
 result:= trim(name);
 if (length(result) > 1) and
     (result[1] = quotechar) and (result[length(result)] = quotechar) then begin
  result:= copy(result,2,length(result)-2);
 end;
end;

function extractrootpath(var names: filenamearty): filenamety;
var
 ch1: msechar;
 int1,int2,int3: integer;
 bo1: boolean;
begin
 result:= '';
 if names <> nil then begin
  int3:= 0;
  bo1:= false;
  for int2:= 1 to length(names[0]) do begin
   ch1:= names[0][int2];
   for int1:= 1 to high(names) do begin
    if names[int1][int2] <> ch1 then begin
     bo1:= true;
     break;
    end;
   end;
   if bo1 then begin
    break;
   end;
   if ch1 = slashchar then begin
    int3:= int2;
   end;
  end;
  result:= copy(names[0],1,int3);
  names:= copy(names);
  for int1:= 0 to high(names) do begin
   names[int1]:= copy(names[int1],int3+1,bigint);
  end;
 end;
end;

function combinerootpath(const rootpath: filenamety; const names: filenamearty): filenamearty;
var
 int1: integer;
 str1,str2: filenamety;
begin
 str1:= filepath(rootpath,fk_dir,true);
 setlength(result,length(names));
 for int1:= 0 to high(names) do begin
  str2:= filepath(names[int1],fk_default,true);
  if (length(str2) > 0) and (str2[1] = slashchar) then begin
   result[int1]:= str2;
  end
  else begin
   result[int1]:= str1 + str2 {$ifndef FPC}+''{$endif}; //delphi bug
  end;
 end;
end;

function combinerootpath(const rootpaths: filenamearty; const name: filenamety): filenamearty;
var
 int1: integer;
begin
 setlength(result,length(rootpaths));
 for int1:= 0 to high(rootpaths) do begin
  result[int1]:= filepath(rootpaths[int1],name,fk_default,true);
 end;
end;

function isrelativepath(const path: filenamety): boolean;
var
 str1: filenamety;
begin
 str1:= remquote(path);
 result:= not (
  (length(str1) > 0) and ((str1[1] = '\') or (str1[1] = slashchar)) or
  (length(str1) >= 1) and (str1[2] = ':')
            );
end;

function isrootdir(const path: filenamety): boolean;
begin
 result:= (path = slashchar) or (path = '\') or (path = '"/"') or (path = '"\"');
end;

procedure tomsefilepath1(var path: filenamety; const quoted: boolean = false);

 procedure doname(var path: filenamety);
 var
  str1: filenamety;
 begin
  str1:= remquote(path);
  replacechar1(str1,msechar('\'),msechar(slashchar)); //calls uniquestring
  if (length(str1) >= 2) and (str1[2] = ':'){ and (str1[3] = slashchar)} then begin
   setlength(str1,length(str1)+1);
   move(str1[1],str1[2],(length(str1)-1)*sizeof(msechar)); // 'c:x' -> 'cc:x'
   pmsecharaty(str1)^[0]:= slashchar; // /c:
   pmsecharaty(str1)^[1]:= str1[2];//charuppercase(str1[2]);
  end;
  requote(path,str1);
 end;

var
 ar1: filenamearty;
 int1: integer;

begin //tomsefilepath1
 path:= trim(path);
 if findchar(path,quotechar) <> 0 then begin
  unquotefilename(path,ar1);
  for int1:= 0 to high(ar1) do begin
   doname(ar1[int1]);
  end;
  path:= quotefilename(ar1);
 end
 else begin
  doname(path);
  if quoted then begin
   path:= quotefilename(path);
  end;
 end;
end;

procedure tosysfilepath1(var path: filenamety; const quoted: boolean = false);
var
 ar1: filenamearty;
 int1: integer;
begin
 path:= trim(path);
 if findchar(path,quotechar) <> 0 then begin
  unquotefilename(path,ar1);
  for int1:= 0 to high(ar1) do begin
   syserror(sys_tosysfilepath(ar1[int1]));
  end;
  path:= quotefilename(ar1);
 end
 else begin
  if quoted then begin
   path:= quotefilename(path);
  end;
  syserror(sys_tosysfilepath(path));
 end;
end;

function tomsefilepath(const path: filenamety;
                                  const quoted: boolean = false): filenamety;
begin
 result:= path;
 tomsefilepath1(result,quoted);
end;

function tosysfilepath(const path: filenamety;
                                  const quoted: boolean = false): filenamety;
begin
 result:= path;
 tosysfilepath1(result,quoted);
end;

function tosysfilepath(const path: filenamearty;
                                  const quoted: boolean = false): filenamearty;
var
 i1: int32;
begin
 setlength(result,length(path));
 for i1:= 0 to high(path) do begin
  result[i1]:= tosysfilepath(path[i1],quoted);
 end;
end;

procedure syncpathdelim(const source: filenamety; var dest: filenamety;
              kind: filekindty);
begin
 if length(dest) > 0 then begin
  if (length(dest) >= 3) and (length(dest) <= 4) and
                       (dest[1] = slashchar) and (dest[3] = ':') then begin
   kind:= fk_dir;      // /a:  -> /a:/
                       // /a:/ -> /a:/
  end;
  if kind = fk_default then begin
   if (length(source) > 0) and (source[length(source)] = slashchar) then begin
    kind:= fk_dir;
   end
   else begin
    kind:= fk_file;
   end;
  end;
  case kind of
   fk_dir: begin
    if dest[length(dest)] <> slashchar then begin
     dest:= dest + slashchar;
    end;
   end;
   fk_file: begin
    if (length(dest) > 1) and (dest[length(dest)] = slashchar) then begin
     setlength(dest,length(dest) - 1);
    end;
   end;
   else ;
  end;
 end;
end;

function filepath({const} path: filenamety;
     kind: filekindty = fk_default; relative: boolean = false): filenamety; overload;
var
 ar1,ar2: filenamearty;
 int1,int2: integer;
 mstr1: filenamety;
 bo1: boolean;
begin
 mstr1:= unquotefilename(tomsefilepath(path));
 if (length(mstr1) > 1) and (mstr1[2] = slashchar) then begin
  if mstr1[1] = '~' then begin
   mstr1:= sys_getuserhomedir + copy(mstr1,2,bigint);
  end
  else begin
   if mstr1[1] = '^' then begin
    mstr1:= sys_getapphomedir + copy(mstr1,2,bigint);
   end
  end;
 end;
 if not relative and not isrootpath(mstr1) then begin
  if mstr1 <> '' then begin
   mstr1:= sys_getcurrentdir + slashchar + mstr1;
  end
  else begin
   mstr1:= sys_getcurrentdir;
  end;
 end;
 ar1:= nil;
 splitstring(msestring(mstr1),msestringarty(ar1),msechar(slashchar));
 setlength(ar2,length(ar1));
 int2:= 0;
 for int1:= 0 to high(ar1) do begin
  if ar1[int1] = '..' then begin
   if (int2 > 1) or
    (int2 = 1) and not ((length(ar2[0]) = 2) and (ar2[0][2] = ':')) then begin
    dec(int2);
    if ar2[int2] = '..' then begin //for relative path
     inc(int2);
     ar2[int2]:= ar1[int1];
     inc(int2);
    end;
   end
   else begin
    if relative then begin  //if not relative ignore '..' if rootdir
     ar2[int2]:= ar1[int1];
     inc(int2);
    end;
   end;
  end
  else begin
   if (ar1[int1] <> dotchar) and (ar1[int1] <> '') then begin
    ar2[int2]:= ar1[int1];
    inc(int2);
   end;
  end;
 end;
 result:= '';
 bo1:= (length(mstr1) > 0) and (mstr1[1] = slashchar); //rootpath
 if bo1 and (int2 = 0) then begin
  result:= slashchar;
//  inc(int2);
 end;
 bo1:= not relative or bo1;
 for int1:= 0 to int2 - 1 do begin
  if bo1 then begin
   result:= result + slashchar + ar2[int1];
  end
  else begin
   result:= result + ar2[int1]; //relative start
   bo1:= true;
  end;
 end;
 if relative and ((mstr1 = dotchar) or msestartsstr('./',mstr1)) and
           not msestartsstr('../',result) then begin
  result:= './' + result;
 end;
 syncpathdelim(mstr1,result,kind);
 if msestartsstr('//',mstr1) then begin
  result:= slashchar+result; //restore uncfilename
 end;
end;

function filepath({const} directory,filename: filenamety; kind: filekindty = fk_default;
                           relative: boolean = false): filenamety; overload;
begin
 if not isrelativepath(filename) then begin
  result:= filepath(filename,kind,relative);
 end
 else begin
  result:= filepath(directory,fk_dir,relative);
  result:= filepath(result + unquotefilename(filename),kind,relative);
  tomsefilepath1(result); //really needed?
 end;
end;

function syscommandline(const acommandline: filenamety): filenamety;
                 //converts exec path to sys format
var
 int1,int2,int3: integer;
begin
 result:= '';
 int1:= 0;
 int2:= 0;
 int3:= 0;
 if length(acommandline) > 0 then begin
  int1:= 1; //start exe
  if acommandline[1] = quotechar then begin
   int1:= 2;
   int2:= findchar(pmsechar(@acommandline[2]),quotechar);//end of exe
   if int2 = 0 then begin
    int2:= length(acommandline);
   end
   else begin
    inc(int2);
   end;
   int3:= int2+1; //start of params
  end
  else begin
   int2:= findchar(acommandline,' ');//end of exe
   if int2 <= 0 then begin
    int2:= length(acommandline);
   end;
   int3:= int2;
  end;
 end;
 if int1 > 1 then begin //quoted
  result:= quotechar+tosysfilepath(copy(acommandline,int1,int2-int1)) +
                                    quotechar+ copy(acommandline,int3,bigint);
 end
 else begin
  result:= tosysfilepath(copy(acommandline,int1,int2-int1)) +
                       copy(acommandline,int3,bigint);
 end;
end;

function relativepath(const path: filenamety; const root: filenamety = '';
                       const kind: filekindty = fk_default): filenamety;
       //root = '' -> currentdir
var
 root1: filenamety;
 str1,str2,str3: filenamety;
 ar1,ar2,ar3:filenamearty;
 int1,int2,int3: integer;
begin
 if root = '' then begin
  root1:= sys_getcurrentdir;
 end
 else begin
  root1:= filepath(root,fk_dir);
 end;
 str1:= filepath(path);
 ar3:= splitrootpath(str1);
 if filesystemiscaseinsensitive then begin
  str2:= mseuppercase(root1);
  str3:= mseuppercase(str1);
  ar2:= splitrootpath(str3);
 end
 else begin
  str2:= root1;
  str3:= str1;
  ar2:= ar3;
 end;
 ar1:= splitrootpath(str2);
 int2:= high(ar2);
 if int2 > high(ar1) then begin
  int2:= high(ar1);
 end;
 int3:= int2 + 1;
 for int1:= 0 to int2 do begin
  if ar1[int1] <> ar2[int1] then begin
   int3:= int1;
   break;
  end;
 end;
 result:= '';
 for int1:= int3 to high(ar1) do begin
  result:= result + '../';
 end;
 for int1:= int3 to high(ar3) do begin
  result:= result + ar3[int1] + slashchar;
 end;
 if int3 <= high(ar3) then begin
  setlength(result,length(result)-1); //remove last slashchar
 end;
 if result = '' then begin
  result:= dotchar;
 end;
 syncpathdelim(str1,result,kind);
end;

function relocatepath(const olddir,newdir: filenamety;
                      var apath: filenamety;
                      const options: pathrelocateoptionsty = []): boolean;
//searches file in newdir relative to olddir if apath not found, updates
//apath to the new location if found
var
 mstr1: filenamety;
begin
 result:= true;
 if options * [pro_preferenew,pro_onlynew] <> [] then begin
  mstr1:= filepath(newdir,relativepath(apath,olddir));
  result:= findfile(mstr1);
  if result then begin
   apath:= mstr1;
  end
  else begin
   if not (pro_onlynew in options) then begin
    result:= findfile(apath);
   end;
  end;
 end
 else begin
  if not findfile(apath) then begin
   mstr1:= filepath(newdir,relativepath(apath,olddir));
   result:= findfile(mstr1);
   if result then begin
    apath:= mstr1;
   end;
  end;
 end;
 if pro_rootpath in options then begin
  apath:= filepath(apath);
 end;
end;

procedure splitfilepath(const path: filenamety;
                              out directory,filename: filenamety);
var
 str1: filenamety;
begin
// str1:= unquotefilename(filepath(path,fk_default,true));
 str1:= filepath(path,fk_default,true);
 if (str1 = '') or (str1[length(str1)] = slashchar) then begin
  directory:= str1;
  filename:= '';
 end
 else begin
  directory:= removelastpathsection(str1);
  if directory <> '' then begin
   if directory = slashchar then begin //root
    filename:= copy(str1,2,bigint);
   end
   else begin
    if directory = '//' then begin //unc root
     filename:= copy(str1,3,bigint);
    end
    else begin
     directory:= directory + slashchar;
     filename:= copy(str1,length(directory)+1,bigint);
    end;
   end;
  end
  else begin
   filename:= str1;
  end;
 end;
end;

procedure splitfilepath(const path: filenamety;
                            out directory,filename,fileext: filenamety);
var
 fstr1: filenamety;
 int1: integer;
begin
 splitfilepath(path,directory,fstr1);
 int1:= findlastchar(fstr1,dotchar);
 if int1 > 1 then begin
  filename:= copy(fstr1,1,int1-1);
  fileext:= copy(fstr1,int1,bigint);
 end
 else begin
  filename:= fstr1;
  fileext:= '';
 end;
end;

function splitfilepath(const path: filenamety): filenamearty;
var
 str1: filenamety;
begin
 str1:= unquotefilename(filepath(path,fk_file,true));
 result:= nil;
 if str1 <> '' then begin
  splitstring(str1,result,msechar(slashchar));
  if result[0] = '' then begin //root
   result:= copy(result,1,bigint);
  end;
 end;
end;

function splitrootpath(const path: filenamety): filenamearty;
var
 str1: filenamety;
begin
 str1:= unquotefilename(filepath(path,fk_file));
 result:= nil;
 splitstring(str1,result,msechar(slashchar));
 result:= copy(result,1,bigint);
end;

function mergerootpath(const segments: filenamearty): filenamety;
var
 int1: integer;
begin
 if segments = nil then begin
  result:= slashchar;
 end
 else begin
  result:= '';
  for int1:= 0 to high(segments) do begin
   result:= result + slashchar + segments[int1];
  end;
 end;
end;

function filename(const path: filenamety): filenamety;
var
 str1: filenamety;
begin
 splitfilepath(path,str1,result);
end;

function filedir(const path: filenamety): filenamety;
var
 str1: filenamety;
begin
 splitfilepath(path,result,str1);
end;

function filenamebase(const path: filenamety): filenamety; //without ext
var
 mstr1,mstr2: filenamety;
begin
 splitfilepath(path,mstr1,result,mstr2);
end;

function removefileext(const path: filenamety): filenamety;
var
 str1: filenamety;
 int1: integer;
begin
 str1:= tomsefilepath(path);
 int1:= findlastchar(str1,dotchar);
 if (int1 > 1) and (findlastchar(str1,slashchar) < int1) then begin
  result:= copy(str1,1,int1-1);
 end
 else begin
  result:= str1;
 end;
end;

function hasfileext(const path: filenamety): boolean;
var
 int1: integer;
begin
 int1:= findlastchar(path,dotchar);
 result:= (int1 > 1) and (findlastchar(path,slashchar) < int1);
end;

function fileext(const path: filenamety): filenamety;
var
 str1: filenamety;
 int1: integer;
begin
 str1:= filename(path);
 int1:= findlastchar(str1,dotchar);
 if int1 > 1 then begin
  result:= copy(str1,int1+1,bigint);
 end
 else begin
  result:= '';
 end;
end;

function checkfileext(const path: filenamety; const extensions: array of filenamety): boolean;
var
 int1: integer;
 ext: filenamety;
begin
 result:= false;
 ext:= fileext(path);
 if filesystemiscaseinsensitive then begin
  ext:= mseuppercase(ext);
 end;
 for int1:= 0 to high(extensions) do begin
  if filesystemiscaseinsensitive then begin
   result:= ext = mseuppercase(extensions[int1]);
  end
  else begin
   result:= ext = extensions[int1];
  end;
  if result then begin
   break;
  end;
 end;
end;

function replacefileext(const path,newext: filenamety): filenamety;
begin
 result:= removefileext(path);
 if newext <> '' then begin
  result:= result + dotchar + newext;
 end;
end;

function uniquefilename(const path: filenamety): filenamety;
                             //adds numbers if necessary
var
 int1: integer;
 dir,name,ext: filenamety;
begin
 result:= path;
 if findfileordir(path) then begin
  int1:= 1;
  splitfilepath(path,dir,name,ext);
  repeat
   result:= dir+name+inttostrmse(int1)+ext;
   inc(int1);
  until not findfileordir(result);
 end;
end;

function removelastpathsection(path: filenamety): filenamety;
var
 int1: integer;
begin
 int1:= findlastchar(path,msechar(slashchar));
 if (int1 > 1) then begin
  result:= copy(path,1,int1-1);
  if (int1 = 2) and (path[1] = slashchar) then begin
   result:= slashchar + result; //UNC
  end;
 end
 else begin
  if int1 = 1 then begin
   result:= slashchar; //root
  end
  else begin
   result:= '';
  end;
 end;
end;

function getlastpathsection(const path: filenamety): filenamety;
var
 fna1: filenamety;
 int1,int2: integer;
// po1: pmsechar;
begin
 result:= '';
 fna1:= filepath(path);
 if fna1 <> '' then begin
  int1:= length(fna1);
  if fna1[int1] = slashchar then begin
   dec(int1); //skip trailing slash
  end;
  int2:= int1;
  while int2 > 0 do begin
   if fna1[int2] = slashchar then begin
    break;
   end;
   dec(int2);
  end;
  if (int2 <= 1) or (int2 = 2) and (fna1[1] = slashchar) then begin //UNC
   result:= copy(fna1,1,int1); //all without trailing slash
   exit;
  end;
  result:= copy(fna1,int2+1,int1-int2);
 end;
end;

function removelastdir(path: filenamety; var newpath: filenamety): filenamety;
begin
 if (path = '') or isrootdir(path) then begin
  newpath:= path;
  result:= '';
 end
 else begin
  if path[length(path)] = slashchar then begin
   newpath:= removelastpathsection(copy(path,1,length(path)-1));
   if newpath = slashchar then begin
    result:= copy(path,length(newpath)+1,length(path)-length(newpath)-1);
   end
   else begin
    result:= copy(path,length(newpath)+2,length(path)-length(newpath)-2);
   end;
  end
  else begin
   newpath:= removelastpathsection(path);
   result:= copy(path,length(newpath)+2,length(path)-length(newpath)-1);
  end;
  if (newpath <> slashchar) and (newpath <> '//') then begin
   newpath:= newpath + slashchar;
  end;
 end;
end;

{ tcustomfiledatalist }

constructor tcustomfiledatalist.create;
begin
 inherited;
 fsize:= sizeof(fileinfoty)
end;

procedure tcustomfiledatalist.beforecopy(var data);
begin
 stringaddref(fileinfoty(data).name);
end;

procedure tcustomfiledatalist.freedata(var data);
begin
 fileinfoty(data).name:= '';
end;

function tcustomfiledatalist.adddirectory(const directoryname: filenamety;
        ainfolevel: fileinfolevelty = fil_name; const amask: filenamearty = nil;
        const aincludeattrib: fileattributesty = [fa_all];
        const aexcludeattrib: fileattributesty = [];
        const aoptions: dirstreamoptionsty = [];
        const acheckproc: checkfileeventty = nil;
        const noexception: boolean = false
        ): boolean;
        //amask = '' -> all,
var
 dirstream: dirstreamty;
 info: fileinfoty;
 bo1,bo2: boolean;
 err1: syserrorty;
 ar1: filenamearty;
 i1: int32;
begin
 unquotefilename(directoryname,ar1);
 fillchar(dirstream,sizeof(dirstream),0);
 beginupdate();
 try
  for i1:= 0 to high(ar1) do begin
   with dirstream,dirinfo do begin
    options:= aoptions;
    dirname:= filepath(ar1[i1],fk_file);
    mask:= amask;
    include:= aincludeattrib;
    exclude:= aexcludeattrib;
    infolevel:= ainfolevel;
   end;
   err1:= sys_opendirstream(dirstream);
   result:= err1 = sye_ok;
   if not result then begin
    if not noexception then begin
     syserror(err1,quotechar+dirstream.dirinfo.dirname + '" ');
    end
    else begin
     exit;
    end;
   end;
   try
    finalize(info);
    fillchar(info,sizeof(info),0);
    repeat
     bo1:= sys_readdirstream(dirstream,info);
     if bo1 then begin
      if not ((info.extinfo1.filetype = ft_dir) and ((info.name = dotchar) or
                   (info.name = '..'))) then begin
       bo2:= true;
       if assigned(acheckproc) then begin
        acheckproc(self,dirstream.dirinfo,info,bo2);
       end;
       if bo2 then begin
        add(info);
       end;
      end;
     end;
    until not bo1;
   finally
    sys_closedirstream(dirstream);
   end;
  end;
 finally
  endupdate();
 end;
end;

function tcustomfiledatalist.adddirectory(const directoryname: filenamety;
        ainfolevel: fileinfolevelty; const amask: filenamety;
        const aincludeattrib: fileattributesty = [fa_all];
        const aexcludeattrib: fileattributesty = [];
        const aoptions: dirstreamoptionsty = [];
        const acheckproc: checkfileeventty = nil;
        const noexception: boolean = false): boolean;
        //amask = '' -> all
var
 ar1: filenamearty;
begin
 unquotefilename(amask,ar1);
 result:= adddirectory(directoryname,ainfolevel,ar1,
              aincludeattrib,aexcludeattrib,aoptions,acheckproc,noexception);
end;

{$ifndef FPC}
function tcustomfiledatalist.adddirectory1(const directoryname: filenamety;
    ainfolevel: fileinfolevelty = fil_name; const amask: filenamearty = nil;
    const aincludeattrib: fileattributesty = [fa_all];
    const aexcludeattrib: fileattributesty = [];
    const aoptions: dirstreamoptionsty = [];
    const acheckproc: checkfileeventty = nil;
    const noexception: boolean = false): boolean;
    //amask = nil -> all, true if ok
begin
 result:= adddirectory(directoryname,ainfolevel,amask,aincludeattrib,
             aexcludeattrib,aoptions,acheckproc,noexception);
end;

function tcustomfiledatalist.adddirectory2(const directoryname: filenamety;
    ainfolevel: fileinfolevelty; const amask: filenamety;
    const aincludeattrib: fileattributesty = [fa_all];
    const aexcludeattrib: fileattributesty = [];
    const aoptions: dirstreamoptionsty = [];
    const acheckproc: checkfileeventty = nil;
    const noexception: boolean = false): boolean;
    //amask = '' -> all, true if ok
begin
 result:= adddirectory(directoryname,ainfolevel,amask,aincludeattrib,
               aexcludeattrib,aoptions,acheckproc,noexception);
end;
{$endif}

function tcustomfiledatalist.itempo(const index: integer): pfileinfoty;
begin
 result:= pfileinfoty(getitempo(index));
end;

function tcustomfiledatalist.indexof(const filename: filenamety): integer;
              //case sensitive
var
 po1: pfileinfoty;
 int1: integer;
begin
 normalizering;
 result:= -1;
 po1:= pfileinfoty(fdatapo);
 for int1:= 0 to count - 1 do begin
  if po1^.name = filename then begin
   result:= int1;
   break;
  end;
  inc(po1);
 end;
end;

function tcustomfiledatalist.getitems(index: integer): fileinfoty;
begin
 result:= itempo(index)^;
end;

function tcustomfiledatalist.add(const value: fileinfoty): integer;
begin
 result:= adddata(value);
end;

procedure tcustomfiledatalist.setoptions(const Value: filelistoptionsty);
begin
 if foptions <> value then begin
  foptions:= filelistoptionsty(
  {$ifdef FPC}
        setsinglebit(longword(value),longword(foptions),longword(sortflags)));
  {$else}
        setsinglebit(byte(value),byte(foptions),byte(sortflags)));
  {$endif}

  {$ifdef FPC}
  case longword(foptions*sortflags) of
  {$else}
  case byte(foptions*sortflags) of
  {$endif}
   1 shl byte(flo_sortname): begin
    fsortfunc:= {$ifdef FPC}@{$endif}sortname;
   end;
   1 shl byte(flo_sorttime): begin
    fsortfunc:= {$ifdef FPC}@{$endif}sorttime;
   end;
   1 shl byte(flo_sortsize): begin
    fsortfunc:= {$ifdef FPC}@{$endif}sortsize;
   end;
   else begin
    fsortfunc:= nil;
   end;
  end;
  if assigned(fsortfunc) or (flo_sorttype in foptions) then begin
   if sorted then begin
    sort;
   end
   else begin
    sorted:= true;
   end
  end
  else begin
   sorted:= false;
  end;
 end;
end;

function tcustomfiledatalist.compare(const l,r): integer;
begin
 if flo_sorttype in foptions then begin
  result:= integer(fileinfoty(l).extinfo1.filetype) -
             integer(fileinfoty(r).extinfo1.filetype);
 end
 else begin
  result:= 0;
 end;
 if (result = 0) and assigned(fsortfunc) then begin
  result:= fsortfunc(fileinfoty(l),fileinfoty(r));
  if result = 0 then begin
   if flo_sortname in foptions then begin
    result:= sorttime(fileinfoty(l),fileinfoty(r));
   end
   else begin
    result:= sortname(fileinfoty(l),fileinfoty(r));
   end;
  end;
  if flo_downsort in foptions then begin
   result:= - result;
  end;
 end;
end;

function tcustomfiledatalist.sortname(const l, r: fileinfoty): integer;
begin
 if flo_casesensitive in foptions then begin
//  {$ifdef FPC}
//  result:= comparestr(l.name,r.name); //!!!!todo
//  {$else}
  result:= msecomparestr(l.name,r.name);
//  {$endif}
 end
 else begin
//  {$ifdef FPC}
//  result:= comparetext(l.name,r.name);    //!!!!todo
//  {$else}
  result:= msecomparetext(l.name,r.name);
//  {$endif}
 end;
end;

function tcustomfiledatalist.sortsize(const l, r: fileinfoty): integer;
begin
 if l.extinfo1.size > r.extinfo1.size then begin
  result:= 1
 end
 else begin
  if l.extinfo1.size = r.extinfo1.size then begin
   result:= 0;
  end
  else begin
   result:= -1;
  end;
 end;
end;

function tcustomfiledatalist.sorttime(const l, r: fileinfoty): integer;
begin
 if l.extinfo1.modtime > r.extinfo1.modtime then begin
  result:= 1
 end
 else begin
  if l.extinfo1.modtime = r.extinfo1.modtime then begin
   result:= 0;
  end
  else begin
   result:= -1;
  end;
 end;
end;

function tcustomfiledatalist.isdir(index: integer): boolean;
begin
 result:= fa_dir in itempo(index)^.extinfo1.attributes;
end;

end.
