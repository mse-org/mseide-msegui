{ MSEtools Copyright (c) 1999-2007 by Martin Schreiber
   
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
unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mseforms,msefiledialog,msestat,msestatfile,msesimplewidgets,msegrids,msewidgetgrid,
 mselistbrowser,msedataedits,typinfo,msedatanodes,msegraphedits,msestream,mseglob,
 msemenus,classes,msetypes,msestrings,mseguithread,mseguiglob,msegui,mseresourceparser;

const
 drcext = '_DRC.rc';
 rstext = '_rst';
 variantshift = 5;

type
 resfilekindty = (rfk_module,rfk_unit,rfk_resource,rfk_resstrings);
 
 tmainfo = class(tmseform)
   mainstatfile: tstatfile;
   clear: tbutton;
   flat: tbooleanedit;
   stringonly: tbooleanedit;
   nont: tbooleanedit;
   ntonly: tbooleanedit;
   grid: twidgetgrid;
   convexx: tfacecomp;
   menuitemframe: tframecomp;
   convexy: tfacecomp;
   concavex: tfacecomp;
   concavey: tfacecomp;
   tgroupbox1: tgroupbox;
   tree: ttreeitemedit;
   threadcomp: tthreadcomp;
   typedisp: tenumtypeedit;
   donottranslate: tbooleanedit;
   comment: tstringedit;
   value: tstringedit;
   scan: tbutton;
   mainmenu1: tmainmenu;
   projectfiledialog: tfiledialog;
   procedure onprojectopen(const sender: tobject);
   procedure onprojectsave(const sender: tobject);
   procedure onprojectedit(const sender: tobject);
 //  procedure readonexecute(const sender: tobject);
 //  procedure writeonexecute(const sender: tobject);
   procedure exportonexecute(const sender: tobject);
   procedure importonexecute(const sender: tobject);
   procedure clearonexecute(const sender: tobject);
   procedure edoninit(const sender: tenumtypeedit);
   procedure typedisponinit(const sender: tenumtypeedit);
   procedure treeonupdaterowvalues(const sender: tobject; const aindex: integer;
                    const aitem: tlistitem);
   procedure tmainfooncreate(const sender: tobject);
   procedure tmainfoonloaded(const sender: tobject);
   procedure tmainfoondestroy(const sender: tobject);
   procedure formatchanged(const sender: tobject);
   procedure nontonsetvalue(const sender: tobject; var avalue: boolean;
                              var accept: boolean);
   procedure ntonlyonsetvalue(const sender: tobject; var avalue: boolean;
                              var accept: boolean);
   procedure donottranslateonsetvalue(const sender: tobject; var avalue: boolean;
                    var accept: boolean);
   procedure commentonsetvalue(const sender: tobject; var avalue: msestring;
                               var accept: boolean);
   procedure variantonsetvalue(const sender: tobject; var avalue: msestring;
                                   var accept: boolean);
 
//   procedure scanonexecute(const sender: tobject);
   procedure makeonexecute(const sender: tobject);
   procedure mainupdatestat(const sender: TObject; const filer: tstatfiler);
   procedure configureonexecute(const sender: TObject);
   procedure makeexecute(const sender: tthreadcomp);
   procedure maketerminate(const sender: tthreadcomp);
   procedure mainclosequery(const sender: tcustommseform; 
                               var amodalresult: modalresultty);
   procedure saveasexecute(const sender: TObject);
   procedure newprojectexe(const sender: TObject);
   procedure mainmenuupdate(const sender: tcustommenu);
   procedure aboutexe(const sender: TObject);
  private
   datastream: ttextdatastream;
   alang: integer;
   fdatachanged: boolean;
   procedure datachanged;
   procedure updatecaption;
   procedure updatedata;
   procedure refreshnodedata;
   procedure writerecord(const sender: ttreenode);
   procedure writeexprecord(const sender: ttreenode);
   procedure checkitem(const sender: ttreelistitem; var delete: boolean);
   function filternode(const anode: ttreenode): boolean;
   function readunit(const  stream: tmsefilestream): msestring;
   function readstringresource(const  stream: tmsefilestream;
                                      const fpcformat: boolean): msestring;
   function readmodule(const  stream: tmsefilestream): msestring;
   procedure doread(stream: ttextdatastream; aencoding: charencodingty);
   procedure dowrite(stream: ttextdatastream; aencoding: charencodingty);
   procedure doimport(stream: ttextdatastream; aencoding: charencodingty);
   procedure doexport(stream: ttextdatastream; aencoding: charencodingty);
   function getcolumnheaders: msestringarty;
   function checksave(cancelonly: boolean = false): boolean;
  public
   procedure loadproject;
   procedure readprojectdata;
   procedure writeprojectdata;
 end;

var
 mainfo: tmainfo;
 rootnode: tpropinfonode;

implementation
uses
 main_mfm,msefileutils,msesys,sysutils,mselist,project,
 rtlconsts,mseprocutils,
 msewidgets,mseparser,mseformdatatools,mseresourcetools,
 msedatalist,msesettings,msesysenv,messagesform,mseclasses,mseeditglob;

const
 translateext = 'trans';
 exportext = 'csv';

type
 ttreenode1 = class(ttreenode);
 tpropinfonode1 = class(tpropinfonode);

{ tmainfo }

const
 sn_header = 'header';
 sn_prop = '.prop';
 svn_compclass = 'compclass';
 svn_compname = 'compname';
 svn_name = 'name';
 svn_type = 'type';
 svn_value = 'value';

procedure tmainfo.tmainfooncreate(const sender: tobject);
var
 wstr1: msestring;
begin
 wstr1:= filepath(statdirname);
 if not finddir(wstr1) then begin
  createdir(wstr1);
 end;
 {$ifdef mswindows}
 mainstatfile.filename:= 'msei18nwi.sta';
 {$endif}
 {$ifdef linux}
 mainstatfile.filename:= 'msei18nli.sta';
 {$endif}
 rootnode:= tpropinfonode.Create;
 application.createform(tprojectfo, projectfo);
 updatecaption;
end;

procedure tmainfo.tmainfoonloaded(const sender: tobject);
begin
 mainstatfile.readstat;
 show;
end;

procedure tmainfo.tmainfoondestroy(const sender: tobject);
begin
 freeandnil(rootnode);
end;

procedure tmainfo.edoninit(const sender: tenumtypeedit);
begin
 sender.typeinfopo:= typeinfo(tvaluetype);
end;

procedure tmainfo.typedisponinit(const sender: tenumtypeedit);
begin
 sender.typeinfopo:= typeinfo(tvaluetype);
end;

procedure tmainfo.treeonupdaterowvalues(const sender: tobject;
  const aindex: integer; const aitem: tlistitem);
var
 int1: integer;
begin
 with tpropinfoitem(aitem) do begin
  if node <> nil then begin
   with node do begin
    typedisp[aindex]:= ord(info.valuetype);
    donottranslate[aindex]:= info.donottranslate;
    comment[aindex]:= info.comment;
    value[aindex]:= valuetext;
    for int1:= 0 to grid.datacols.count - variantshift - 1 do begin
     with tstringedit(grid.datacols[int1+variantshift].editwidget) do begin
      if high(info.variants) >= int1 then begin
       gridvalue[aindex]:= info.variants[int1];
      end
      else begin
       gridvalue[aindex]:= '';
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tmainfo.filternode(const anode: ttreenode): boolean;
begin
 result:= true;
 if result and stringonly.value then begin
  result:= tpropinfonode(anode).info.valuetype in
           [vastring,valstring,vawstring{$ifndef FPC},vautf8string{$endif},
                   vanull,valist,vacollection];
 end;
 if result then begin
  if nont.value then begin
   result:= not tpropinfonode(anode).info.donottranslate;
  end
  else begin
   if ntonly.value then begin
    result:= tpropinfonode(anode).info.donottranslate or
          (tpropinfonode(anode).info.valuetype in [vanull,valist,vacollection]);
   end;
  end;
 end;
end;

procedure tmainfo.checkitem(const sender: ttreelistitem; var delete: boolean);
begin
 with tpropinfoitem(sender),node,info do begin
  delete:= (sender.count = 0) and (valuetype in [vanull,valist,vacollection]) and 
           (stringonly.value or ntonly.value and not donottranslate);
  if not delete and flat.value then begin
   sender.caption:= node.rootstring;
  end;
 end;
end;

function tmainfo.getcolumnheaders: msestringarty;
var
 int1: integer;
begin
 setlength(result,variantshift + projectfo.grid2.rowcount);
 result[0]:= 'name';
 result[1]:= 'type';
 result[2]:= 'notranslate';
 result[3]:= 'comment';
 result[4]:= 'value';
 for int1:= 0 to projectfo.grid2.rowcount - 1 do begin
  result[int1 + variantshift]:= projectfo.lang[int1];
 end;
end;

procedure tmainfo.updatecaption;
var
 mstr1: msestring;
begin
 mstr1:= 'MSEi18n (';
 if fdatachanged then begin
  mstr1:= mstr1+'*';
 end;
 if projectfo.projectstat.filename = '' then begin
  mstr1:= mstr1+'<no project>';
 end
 else begin
  mstr1:= mstr1+msefileutils.filename(projectfo.projectstat.filename);
 end;
 caption:= mstr1 + ')';
end;

procedure tmainfo.datachanged;
begin
 fdatachanged:= true;
 updatecaption;
end;

procedure tmainfo.updatedata;
var
 int1: integer;
 item: ttreelistedititem;
 ar1: msestringarty;
 edit1: tstringedit;
begin
 ar1:= getcolumnheaders;
// grid.datacols.count:= variantshift;
 grid.datacols.count:= length(ar1);
 grid.fixrows[-1].captions.count:= length(ar1);
 for int1:= variantshift to high(ar1) do begin
  grid.fixrows[-1].captions[int1].caption:= getcolumnheaders[int1];
  if grid.datacols[int1].editwidget = nil then begin
   edit1:= tstringedit.create(self);
   edit1.initgridwidget;
   edit1.onsetvalue:= {$ifdef FPC}@{$endif}variantonsetvalue;
   edit1.Tag:= int1 - variantshift;
   edit1.optionsedit:= edit1.optionsedit - [oe_savevalue];
   grid.datacols[int1].editwidget:= edit1;
  end;
 end;
 grid.beginupdate;
 try
  item:= rootnode.converttotreelistitem(flat.value,false,
                  {$ifdef FPC}@{$endif}filternode);
  item.checkitems({$ifdef FPC}@{$endif}checkitem);
  tree.itemlist.assign(item);
 finally
  grid.endupdate;
 end;
end;

procedure tmainfo.refreshnodedata;
begin
 tree.itemlist.refreshitemvalues;
end;

function tmainfo.readunit(const  stream: tmsefilestream): msestring;
var
 scanner: tscanner;
 parser: tconstparser;
 ar1: constinfoarty;
 node,node1: tpropinfonode;
 int1: integer;
begin
 scanner:= nil;
 parser:= nil;
 try
  scanner:= tscanner.Create;
  scanner.source:= stream.readdatastring;
  parser:= tconstparser.Create;
  parser.scanner:= scanner;
  node:= tpropinfonode.Create;
  node.info.name:= parser.getconsts(ar1);
  result:= node.info.name;
  rootnode.add(node);
  for int1:= 0 to high(ar1) do begin
   with ar1[int1] do begin
    if resource then begin
     node1:= tpropinfonode.Create;
     node1.info.name:= name;
     node1.info.widestringvalue:= value;
     node1.info.valuetype:= valuetype;
     node1.info.coffset:= offset;
     node1.info.clen:= len;
     node.add(node1);
    end;
   end;
  end;
  updatedata;
 finally
  parser.Free;
  scanner.Free;
  stream.Free;
 end;
end;
 
function tmainfo.readstringresource(const stream: tmsefilestream; 
                    const fpcformat: boolean): msestring;
var
 scanner: tscanner;
 parser: tparser;
 ar1: constinfoarty;
 node,node1,node2: tpropinfonode;
 int1,int2: integer;
 str1: string;
 po1: pchar;
begin
 scanner:= nil;
 parser:= nil;
 try
  if fpcformat then begin
   scanner:= tpascalscanner.Create;
   scanner.source:= stream.readdatastring;
   parser:= tfpcresstringparser.create(nil);
  end
  else begin
   scanner:= tcscanner.Create;
   scanner.source:= stream.readdatastring;
   parser:= tresstringlistparser.Create(nil);
  end;
  parser.scanner:= scanner;
  if fpcformat then begin
   tfpcresstringparser(parser).getconsts(ar1);
  end
  else begin
   tresstringlistparser(parser).getconsts(ar1);
  end;
  node:= tpropinfonode.Create;
  node.info.name:= filename(stream.filename);
  result:= node.info.name;
  str1:= '';
  for int1:= 0 to high(ar1) do begin
   with ar1[int1] do begin
    if valuetype = vawstring then begin
     if fpcformat then begin
      int2:= msestrings.strscan(name,'.');
     end
     else begin
      int2:= msestrings.strscan(name,'_');
     end;
     if int2 > 0 then begin
      str1:= copy(name,1,int2-1);
      name:= copy(name,int2+1,bigint);
      node1:= nil;
      for int2:= 0 to node.count - 1 do begin
       if node[int2].info.name = str1 then begin
        node1:= node[int2];
        break;
       end;
      end;
      if node1 = nil then begin
       node1:= tpropinfonode.Create;
       node1.info.name:= str1;
       node.add(node1);
      end;
      node2:= tpropinfonode.Create;
      node2.info.name:= name;
      node2.info.widestringvalue:= value;
      node2.info.valuetype:= valuetype;
      node2.info.coffset:= offset;
      node2.info.clen:= len;
      node1.add(node2);
     end;
    end;
   end;
  end;
  rootnode.add(node);
//  updatedata;
 finally
  parser.Free;
  scanner.Free;
  stream.Free;
 end;
end;

function tmainfo.readmodule(const stream: tmsefilestream): msestring;
var
 memstream: tmemorystream;
 node: tpropinfonode;
 int1: integer;
begin
 memstream:= tmemorystream.Create;
 result:= '';
 try
  objecttexttobinary(stream,memstream);
  memstream.Position:= 0;
  node:= tpropinfonode.Create;
  readprops(memstream,node);
  result:= node.info.name;
  rootnode.add(node);
 except
  application.handleexception(self,'Can not read module '+stream.filename+':');
 end;
 memstream.Free;
 stream.Free;
end;

procedure tmainfo.writerecord(const sender: ttreenode);
var
 rec: varrecarty;
 str1,str2: string;
 mstr3: widestring;
 int1: integer;
begin
 rec:= nil; //compilerwarning
 if ttreenode1(sender).fparent <> nil then begin
  with tpropinfonode(sender),info do begin
   str1:= rootstring(',');
   str2:= typedisp.enumname(ord(valuetype));
   mstr3:= valuetext;
   rec:= mergevarrec([str1,str2,donottranslate,comment,mstr3],[]);
   for int1:= 0 to high(variants) do begin
    rec:= mergevarrec(rec,[variants[int1]]);
   end;
  end;
  datastream.writerecord(rec);
 end;
end;

procedure tmainfo.donottranslateonsetvalue(const sender: tobject;
  var avalue, accept: boolean);
begin
 tpropinfoitem(tree.item).node.info.donottranslate:= avalue;
 datachanged;
end;

procedure tmainfo.commentonsetvalue(const sender: tobject;
  var avalue: msestring; var accept: boolean);
begin
 tpropinfoitem(tree.item).node.info.comment:= avalue;
 datachanged;
end;

procedure tmainfo.variantonsetvalue(const sender: tobject;
             var avalue: widestring; var accept: boolean);
begin
 with tpropinfoitem(tree.item).node.info,twidget(sender) do begin
  if high(variants) < tag then begin
   setlength(variants,tag+1);
  end;
  variants[tag]:= avalue;
 end;
 datachanged;
end;

procedure tmainfo.formatchanged(const sender: tobject);
begin
 updatedata;
end;
{
procedure tmainfo.writeonexecute(const sender: tobject);
begin
 try
  datastream:= ttextdatastream.Create(filename.value+'.'+translateext,fm_create);
  datastream.writerecord(getcolumnheaders);
  rootnode.iterate(writerecord);
 finally
  datastream.Free;
 end;
end;
}
procedure tmainfo.doread(stream: ttextdatastream; aencoding: charencodingty);
var
 aname: string;
 notranslate: boolean;
 acomment: widestring;
 node: tpropinfonode;
 str1: string;
 ar1: stringarty;
 avariants: msestringarty;
 pointers: pointerarty;
 int1: integer;
begin
 try
  stream.encoding:= aencoding;
  stream.readln(str1); //header
  splitstringquoted(str1,ar1,'"',',');
  int1:= length(ar1);
  if int1 < variantshift then begin
   int1:= variantshift;
  end;
  setlength(pointers,int1);
  str1:= 's bSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS';
  setlength(str1,length(pointers));
  pointers[0]:= @aname;
  pointers[2]:= @notranslate;
  pointers[3]:= @acomment;
  while not stream.eof do begin
   aname:= '';
   notranslate:= false;
   setlength(avariants,length(pointers) - variantshift);
   for int1:= 0 to high(avariants) do begin
    avariants[int1]:= '';
    pointers[int1 + variantshift]:= @avariants[int1];
   end;
   if stream.readrecord(pointers,str1) then begin
    node:= rootnode.findsubnode(','+aname);
    if node <> nil then begin
     with node.info do begin
      donottranslate:= notranslate;
      comment:= acomment;
      variants:= avariants;
     end;
    end
    else begin
     //todo: errorlist
    end;
   end
   else begin
    //todo: errormesage
   end;
  end;
 finally
  stream.Free;
 end;
// refreshnodedata;
// updatedata;
end;

procedure tmainfo.doimport(stream: ttextdatastream; aencoding: charencodingty);
begin
 doread(stream,aencoding);
 fdatachanged:= true;
 updatecaption;
end;

procedure tmainfo.importonexecute(const sender: tobject);
var
 stream: ttextdatastream;
 str1: filenamety;
begin
 if checksave and 
       projectfo.impexpfiledialog.controller.execute(str1,fdk_open) then begin
  stream:= ttextdatastream.create(str1,fm_read);
  doimport(stream,charencodingty(projectfo.impexpencoding.value));
  updatedata;
 end;
end;

procedure tmainfo.writeexprecord(const sender: ttreenode);
var
 bo1,bo2: boolean;
 int1: integer;
begin
 with tpropinfonode1(sender) do begin
  bo2:= not nont.value or not info.donottranslate;
  if fparent <> nil then begin
   bo1:= not stringonly.value or (info.valuetype in
             [vastring,valstring,vawstring{$ifndef FPC},vautf8string{$endif}]);
   if bo1 and bo2 then begin
    writerecord(sender);
   end;
  end;
  if bo2 then begin
   for int1:= 0 to fcount -1 do begin
    writeexprecord(fitems[int1]);
   end;
  end;
 end;
end;

procedure tmainfo.doexport(stream: ttextdatastream; aencoding: charencodingty);
begin
 stream.encoding:= aencoding;
 datastream:= stream;
 try
  datastream.writerecord(getcolumnheaders);
  writeexprecord(rootnode);
 finally
  datastream.Free;
 end;
end;

procedure tmainfo.exportonexecute(const sender: tobject);
var
 stream: ttextdatastream;
 str1: filenamety;
begin
 if projectfo.impexpfiledialog.controller.execute(str1,fdk_save) then begin
  stream:= ttextdatastream.create(str1,fm_create);
  doexport(stream,charencodingty(projectfo.impexpencoding.value));
 end;
end;
{
procedure tmainfo.readonexecute(const sender: tobject);
begin
 doread(ttextdatastream.Create(filename.value+'.'+translateext,fm_read));
end;
}
procedure tmainfo.clearonexecute(const sender: tobject);
begin
 rootnode.clear;
 updatedata;
end;
{
procedure tmainfo.scanonexecute(const sender: tobject);
var
 stream: tmsefilestream;
begin
 stream:= tmsefilestream.Create('main.pas',fm_read);
 readunit(stream);
end;
}
procedure tmainfo.loadproject;
var
 int1: integer;
 file1: tmsefilestream;
 mstr1: msestring;
begin
 rootnode.clear;
 try
  for int1:= 0 to projectfo.grid.rowcount - 1 do begin
   file1:= tmsefilestream.create(projectfo.filename[int1]);
   case resfilekindty(projectfo.filekind[int1]) of
    rfk_module: begin
     mstr1:= readmodule(file1);
    end;
    rfk_unit: begin
     mstr1:= readunit(file1);
    end;
    rfk_resstrings: begin
     mstr1:= readstringresource(file1,true);
    end;
    rfk_resource: begin
     mstr1:= readstringresource(file1,false);
    end;
   end;
   projectfo.rootname[int1]:= mstr1;
  end;
  rootnode.initlang(projectfo.grid2.rowcount);
  readprojectdata;
  updatedata;
 finally
  updatecaption;
 end;
end;

procedure tmainfo.readprojectdata;
begin
 if projectfo.datafilename.value <> '' then begin
  try
   doread(ttextdatastream.Create(projectfo.datafilename.value),ce_utf8n);
  except
   application.handleexception(self);
  end;
 end;
end;

procedure tmainfo.dowrite(stream: ttextdatastream; aencoding: charencodingty);
begin
 stream.encoding:= aencoding;
 datastream:= stream;
 try
  datastream.writerecord(getcolumnheaders);
  rootnode.iterate({$ifdef FPC}@{$endif}writerecord);
 finally
  datastream.Free;
 end;
end;

procedure tmainfo.writeprojectdata;
var
 stream: ttextdatastream;
 begin
 stream:= ttextdatastream.Create(projectfo.datafilename.value,fm_create);
 dowrite(stream,ce_utf8n);
 fdatachanged:= false;
 updatecaption;
end;

procedure tmainfo.onprojectopen(const sender: tobject);
begin
 if projectfiledialog.execute = mr_ok then begin
  projectfo.projectstat.filename:= projectfiledialog.controller.filename;
  projectfo.projectstat.readstat;
 end;
end; 

procedure tmainfo.onprojectsave(const sender: tobject);
begin
 writeprojectdata;
end;
 
procedure tmainfo.newprojectexe(const sender: TObject);
begin
 if checksave and (projectfiledialog.controller.execute(fdk_save,
                       'New translate project') = mr_ok) then begin
  projectfo.free;
  application.createform(tprojectfo, projectfo);
  clearonexecute(nil);
  with projectfo.projectstat do begin
   filename:= projectfiledialog.controller.filename;
   if not fileexists(filename) then begin
    projectfo.datafilename.value:= replacefileext(filename,'trd');
    projectfo.impexpfiledialog.controller.clear;
    projectfo.impexpfiledialog.controller.filename:= replacefileext(filename,'csv');
    writeprojectdata;
   end
   else begin
    writestat;
   end;
  end;
  updatecaption;
 end;
end;

procedure tmainfo.saveasexecute(const sender: TObject);
begin
 if projectfiledialog.controller.execute(fdk_save) = mr_ok then begin
  projectfo.projectstat.filename:= projectfiledialog.controller.filename;
  projectfo.projectstat.writestat;
  writeprojectdata;
 end;
end;

procedure tmainfo.onprojectedit(const sender: tobject);
begin
 projectfo.show(true);
 projectfo.projectstat.writestat;
 projectfo.projectstat.readstat;
end;

procedure tmainfo.makeexecute(const sender: tthreadcomp);

 procedure addmessage(const amessage: msestring);
 begin
  application.lock;
  messagesfo.messages.addchars(amessage);
  application.unlock;
 end;
 
var
 int1,int2,int3: integer;
 stream,stream1: tmsefilestream;
 stream2: ttextstream;
 node: tpropinfonode;
 afilename: filenamety;
 modulenames,resourcenames: stringarty;
 str1: string;
 commandstring: msestring;
 mstr1: msestring;
 macroar: macroinfoarty;
 actdir: filenamety;
 dirbefore: filenamety;
 error: boolean;

begin
 commandstring:= expandmacros(projectfo.makecommand.value,getsyssettingsmacros);
 setlength(macroar,2);
 macroar[0].name:= 'LIBFILE';
 macroar[1].name:= 'LIBFILEBASE';
 dirbefore:= getcurrentdir;
 error:= false;
 for int1:= 0 to projectfo.grid2.rowcount - 1 do begin
  if error then break;
  rootnode.transferlang(int1);
  try
   addmessage('Making "'+projectfo.dir[int1]+'".'+lineend);
   modulenames:= nil;
   resourcenames:= nil;
   for int2:= 0 to projectfo.grid.rowcount - 1 do begin
    if error then break;
    node:= nil;
    afilename:= filepath(projectfo.dir[int1],msefileutils.filename(projectfo.filename[int2]));
    if issamefilename(afilename,filepath(projectfo.filename[int2])) then begin
     addmessage(afilename+' overwrites it self.');
     error:= true;
     break;
    end;
    for int3:= 0 to rootnode.count - 1 do begin
     if rootnode[int3].info.name = projectfo.rootname[int2] then begin
      node:= rootnode[int3];
      break;
     end;
    end;
    if node <> nil then begin
     case resfilekindty(projectfo.filekind[int2]) of
      rfk_resource: begin
       stream:= tmsefilestream.Create(projectfo.filename[int2],fm_read);
       try
        stream1:= tmsefilestream.Create(removefileext(afilename)+drcext,fm_create);
        try
         writeresources(stream,stream1,node);
        finally
         stream1.Free;
        end;
       finally
        stream.Free;
       end;
      end;
      rfk_resstrings: begin
       stream2:= ttextstream.Create(afilename,fm_create);
       try
        writefpcresourcestrings(stream2,node);
       finally
        stream2.Free;
       end;
       str1:= filenamebase(afilename)+rstext;
       resourcetexttoresourcesource(afilename,str1,true);
       additem(resourcenames,str1);
      end;
      rfk_unit: begin
       stream:= tmsefilestream.Create(projectfo.filename[int2],fm_read);
       try
        stream1:= tmsefilestream.Create(afilename,fm_create);
        try
         writeconsts(stream,stream1,node);
        finally
         stream1.Free;
        end;
       finally
        stream.Free;
       end;
      end;
      rfk_module: begin
       stream:= tmsefilestream.Create; //memory
       try
        writeprops(stream,node);
        stream.Position:= 0;
        stream1:= tmsefilestream.Create(afilename,fm_create);
        try
         objectbinarytotextmse(stream,stream1);
        finally
         stream1.Free;
        end;
       finally
        stream.Free;
       end;
       formtexttoobjsource(afilename,'','',of_default,true);
       additem(modulenames,filenamebase(afilename));
      end;
     end;
    end;
   end;
   if (modulenames <> nil) or (resourcenames <> nil) then begin
    with projectfo do begin
     macroar[0].value:= filenamebase(projectstat.filename)+'_'+lang[int1]+'.pas';
     macroar[1].value:= filenamebase(macroar[0].value);
     createlanglib(dir[int1]+macroar[0].value,modulenames,resourcenames);
     if makeon.value then begin
      try
       msefileutils.setcurrentdir(dir[int1]);
       mstr1:= expandmacros(commandstring,macroar);
       int3:= messagesfo.messages.execprog(mstr1);
       if int3 = invalidprochandle then begin
        error:= true;
       end
       else begin
        int3:= messagesfo.messages.waitforprocess;
        if int3 <> 0 then begin
         addmessage('Exec error '+inttostr(int3)+'.');
         error:= true;
        end
        else begin
         mstr1:= macroar[1].value;
         {$ifdef mswindows}
         mstr1:= mstr1+'.dll';
         {$else}
         mstr1:= 'lib'+mstr1+'.so';
         {$endif}
         copyfile(mstr1,'../'+mstr1,true);
        end;
       end;
      finally
       setcurrentdir(dirbefore);
      end;
     end;
    end;
   end;
  except
   on e: exception do begin
    addmessage(e.message+lineend);
    error:= true;
   end;
   else begin
    error:= true;
   end;
  end;
 end;
 if error then begin
  addmessage('**** ERROR ****'+lineend);
 end
 else begin
  addmessage('Finished OK'+lineend);
 end;
 application.lock;
 messagesfo.running:= false;
 application.unlock;
end;

procedure tmainfo.makeonexecute(const sender: tobject);
begin
 if checksave(true) then begin
  messagesfo.messages.clear;
  messagesfo.running:= true;
  threadcomp.run; 
  messagesfo.show(true);
  loadproject;
 end;
end;

procedure tmainfo.maketerminate(const sender: tthreadcomp);
begin
 messagesfo.running:= false;
end;

procedure tmainfo.nontonsetvalue(const sender: tobject; var avalue,
  accept: boolean);
begin
 if avalue then begin
  ntonly.value:= false;
 end;
end;

procedure tmainfo.ntonlyonsetvalue(const sender: tobject; var avalue,
  accept: boolean);
begin
 if avalue then begin
  nont.value:= false;
 end;
end;

procedure tmainfo.mainupdatestat(const sender: TObject; const filer: tstatfiler);
var
 mstr1: msestring;
begin
 updatesettings(filer);
 mstr1:= projectfo.projectstat.filename;
 filer.updatevalue('projectfile',mstr1);
 projectfo.projectstat.filename:= mstr1;
 if mstr1 <> '' then begin
  try
   msefileutils.setcurrentdir(filedir(mstr1));
  except
   application.handleexception(nil);
  end;
 end;
 if filer.iswriter then begin
  projectfo.projectstat.writestat;
 end
 else begin
  projectfo.projectstat.readstat;
 end;
end;

procedure tmainfo.configureonexecute(const sender: TObject);
begin
 editsettings('Configure MSEi18n');
end;

function tmainfo.checksave(cancelonly: boolean = false): boolean;
var
 mstr1: msestring;
begin
 result:= true;
 if fdatachanged then begin
  mstr1:= 'Data has changed.'+lineend+'Do you wish to save?';
  if cancelonly then begin
   if askok(mstr1,'CONFIRMATION') then begin
    writeprojectdata;
   end
   else begin
    result:= false;
   end;
  end
  else begin
   case askyesnocancel(mstr1,'CONFIRMATION') of
    mr_no: begin end;
    mr_yes: begin
     writeprojectdata;
    end;
    else begin
     result:= false;
    end;
   end;
  end;
 end;
end;

procedure tmainfo.mainclosequery(const sender: tcustommseform;
                                             var amodalresult: modalresultty);
begin
 if not checksave then begin
  amodalresult:= mr_none;
 end
 else begin
  mainstatfile.writestat;
 end;
end;

procedure tmainfo.mainmenuupdate(const sender: tcustommenu);
var
 bo1: boolean;
begin
 bo1:= projectfo.projectstat.filename <> '';
 with mainmenu.menu do begin
  itembyname('save').enabled:= bo1;
  itembyname('saveas').enabled:= bo1;
  itembyname('edit').enabled:= bo1;
  itembyname('import').enabled:= bo1;
  itembyname('export').enabled:= bo1;
  itembyname('make').enabled:= bo1;
 end;
end;

procedure tmainfo.aboutexe(const sender: TObject);
begin
 showmessage('MSEgui version: '+mseguiversiontext+lineend+
         'MSEi18n version: ' + mseguiversiontext,'About MSEi18n');
end;

end.
