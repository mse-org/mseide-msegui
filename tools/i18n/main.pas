{ MSEtools Copyright (c) 1999-2012 by Martin Schreiber
   
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
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,msefiledialog,msestat,msestatfile,msesimplewidgets,msegrids,
 msewidgetgrid,msegraphics,msegraphutils,mselistbrowser,msedataedits,typinfo,
 msedatanodes,msegraphedits,msestream,mseglob,msemenus,classes,mclasses,
 msetypes,msestrings,msethreadcomp,mseguiglob,msegui,mseresourceparser,
 msedialog,msememodialog,mseobjecttext,mseifiglob,msesysenv,msemacros,
 msestringcontainer,mseclasses,mseskin,msebitmap,msejson;

const
 msei18nversiontext = mseguiversiontext;
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
   convexy: tfacecomp;
   concavex: tfacecomp;
   concavey: tfacecomp;
   tgroupbox1: tgroupbox;
   tree: ttreeitemedit;
   threadcomp: tthreadcomp;
   typedisp: tenumtypeedit;
   donottranslate: tbooleanedit;
   comment: tmemodialogedit;
   value: tmemodialogedit;
   scan: tbutton;
   mainmenu1: tmainmenu;
   projectfiledialog: tfiledialog;
   coloron: tbooleanedit;
   sysenv: tsysenvmanager;
   c: tstringcontainer;
   tskincontroller1: tskincontroller;
   iconbmp: tbitmapcomp;
   menuitemframe: tframecomp;
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
   procedure exitexe(const sender: TObject);
   procedure beforelangdrawcell(const sender: tcol; const canvas: tcanvas;
                   var cellinfo: cellinfoty; var processed: Boolean);
   procedure showcolordataentered(const sender: TObject);
   procedure loadedexe(const sender: TObject);
  private
   datastream: ttextdatastream;
//   alang: integer;
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
 main_mfm,msefileutils,msesystypes,msesys,sysutils,mselist,project,
 rtlconsts,mseprocutils,msestockobjects,
 msewidgets,mseparser,mseformdatatools,mseresourcetools,
 msearrayutils,msesettings,messagesform,mseeditglob,mseformatstr;
type
 strinconsts = (
  sc_name,               //0
  sc_type,               //1
  sc_notranslate,        //2
  sc_comment,            //3
  sc_value,              //4
  sc_noproject,          //5
  sc_cannotreadmodule,   //6
  sc_newtranslateproject,//7
  sc_execerror,          //8
  sc_making,             //9
  sc_overwritesitself,   //10
  sc_error,              //11
  sc_finishedok,         //12
  sc_configuremsei18n,   //13
  sc_datahaschanged,     //14
  sc_doyouwishtosave,    //15
  sc_confirmation,       //16
  sc_closeerror          //17
  );
const
 translateext = 'trans';
 exportext = 'csv';
type
 envvarty = (env_macrodef);
const
 sysenvvalues: array[envvarty] of argumentdefty =
  ((kind: ak_pararg; name: '-macrodef'; anames: nil; flags: []; initvalue: '')
  );

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
 stockobjects.mseicon.assign(iconbmp.bitmap);
 iconchanged(nil);
// iconbmp.free;
 sysenv.init(sysenvvalues);
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
 {$ifdef openbsd}
 mainstatfile.filename:= 'msei18nobsd.sta';
 {$endif}
 {$ifdef bsd}
 mainstatfile.filename:= 'msei18nbsd.sta';
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
     with tmemodialogedit(grid.datacols[int1+variantshift].editwidget) do begin
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
           [vastring,valstring,vawstring,vautf8string,
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
   sender.caption:= msestring(node.rootstring);
  end;
 end;
end;

function tmainfo.getcolumnheaders: msestringarty;
var
 int1: integer;
begin
 setlength(result,variantshift + projectfo.grid2.rowcount);
 result[0]:= c[ord(sc_name)];
 result[1]:= c[ord(sc_type)];
 result[2]:= c[ord(sc_notranslate)];
 result[3]:= c[ord(sc_comment)];
 result[4]:= c[ord(sc_value)];
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
  mstr1:= mstr1+c[ord(sc_noproject)];
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
 edit1: tmemodialogedit;
begin
 ar1:= getcolumnheaders;
// grid.datacols.count:= variantshift;
 grid.datacols.count:= length(ar1);
 grid.fixrows[-1].captions.count:= length(ar1);
 for int1:= variantshift to high(ar1) do begin
  grid.fixrows[-1].captions[int1].caption:= getcolumnheaders[int1];
  with grid.datacols[int1] do begin
   if editwidget = nil then begin
    edit1:= tmemodialogedit.create(self);
    edit1.initgridwidget;
    edit1.frame.button.width:= 13;
    edit1.onsetvalue:= {$ifdef FPC}@{$endif}variantonsetvalue;
    edit1.Tag:= int1 - variantshift;
    edit1.optionsedit:= (edit1.optionsedit - [oe_savevalue]) + 
                                                  [oe_hintclippedtext];
    grid.datacols[int1].editwidget:= edit1;
   end;
   onbeforedrawcell:= @beforelangdrawcell;
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
  result:= msestring(node.info.name);
  rootnode.add(node);
  for int1:= 0 to high(ar1) do begin
   with ar1[int1] do begin
    if resource then begin
     node1:= tpropinfonode.Create;
     node1.info.name:= name;
     node1.info.msestringvalue:= value;
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
// po1: pchar;
begin
 scanner:= nil;
 parser:= nil;
 try
  if fpcformat and (fileext(stream.filename) = 'rsj') then begin
   ar1:= rsjgetconsts(stream);
  end
  else begin
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
  end;
  node:= tpropinfonode.Create;
  node.info.name:= ansistring(filename(stream.filename));
  result:= msestring(node.info.name);
  str1:= '';
  for int1:= 0 to high(ar1) do begin
   with ar1[int1] do begin
    if valuetype = vawstring then begin
     if fpcformat then begin
      int2:= msestrings.findchar(name,'.');
     end
     else begin
      int2:= msestrings.findchar(name,'_');
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
      node2.info.msestringvalue:= value;
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
// int1: integer;
begin
 memstream:= tmemorystream.Create;
 result:= '';
 try
  objecttexttobinarymse(stream,memstream);
  memstream.Position:= 0;
  node:= tpropinfonode.Create;
  readprops(memstream,node);
  result:= msestring(node.info.name);
  rootnode.add(node);
 except
  application.handleexception(self,c[ord(sc_cannotreadmodule)]+' '+stream.filename+':');
 end;
 memstream.Free;
 stream.Free;
end;

procedure tmainfo.writerecord(const sender: ttreenode);
var
 rec: varrecarty;
 str1,str2: string;
 mstr3: msestring;
 int1: integer;
begin
 rec:= nil; //compilerwarning
 if ttreenode1(sender).fparent <> nil then begin
  with tpropinfonode(sender),info do begin
   str1:= rootstring(',');
   str2:= ansistring(typedisp.enumname(ord(valuetype)));
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
 grid.invalidaterow(grid.row);
end;

procedure tmainfo.commentonsetvalue(const sender: tobject;
  var avalue: msestring; var accept: boolean);
begin
 tpropinfoitem(tree.item).node.info.comment:= avalue;
 datachanged;
end;

procedure tmainfo.variantonsetvalue(const sender: tobject;
             var avalue: msestring; var accept: boolean);
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

procedure tmainfo.doread(stream: ttextdatastream; aencoding: charencodingty);
var
 aname: string;
 notranslate: boolean;
 acomment: msestring;
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
             [vastring,valstring,vawstring,vautf8string]);
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

procedure tmainfo.clearonexecute(const sender: tobject);
begin
 rootnode.clear;
 updatedata;
end;

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
   doread(ttextdatastream.Create(projectfo.datafilename.value),ce_utf8);
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
 dowrite(stream,ce_utf8);
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
                       c[ord(sc_newtranslateproject)]) = mr_ok) then begin
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
 macroar: macroinfoarty;
 error: boolean;
 
 function doproc(const commandstr: msestring): boolean;
 var
  mstr1: msestring;
  int3: integer;
 begin
  result:= false;
  mstr1:= expandmacros(commandstr,macroar);
  int3:= messagesfo.messages.execprog(mstr1);
  if int3 = invalidprochandle then begin
   error:= true;
  end
  else begin
   int3:= messagesfo.messages.waitforprocess;
   if int3 <> 0 then begin
    addmessage(c[ord(sc_execerror)]+' '+inttostrmse(int3)+'.');
    error:= true;
   end
   else begin
    result:= true;
   end;
  end;
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
// actdir: filenamety;
 dirbefore: filenamety;
 basename: filenamety;

begin
// basename:= filenamebase(projectfo.projectstat.filename);
 basename:= projectfo.destname.value;
 if basename = '' then begin
  basename:= filenamebase(projectfo.datafilename.value);
 end;
 if basename = '' then begin
  basename:= filenamebase(projectfo.projectstat.filename);
 end;
 commandstring:= expandmacros(projectfo.makecommand.value,
             sysenv.getcommandlinemacros(ord(env_macrodef),-1,-1,
                                              getsyssettingsmacros));
 setlength(macroar,2);
 macroar[0].name:= 'LIBFILE';
 macroar[1].name:= 'LIBFILEBASE';
 dirbefore:= getcurrentdirmse;
 error:= false;
 for int1:= 0 to projectfo.grid2.rowcount - 1 do begin
  if error then break;
  rootnode.transferlang(int1);
  try
   addmessage(c[ord(sc_making)]+' "'+projectfo.dir[int1]+'".'+lineend);
   modulenames:= nil;
   resourcenames:= nil;
   for int2:= 0 to projectfo.grid.rowcount - 1 do begin
    if error then break;
    node:= nil;
    afilename:= filepath(projectfo.dir[int1],msefileutils.filename(projectfo.filename[int2]));
    if issamefilename(afilename,filepath(projectfo.filename[int2])) then begin
     addmessage(afilename+' '+c[ord(sc_overwritesitself)]+'.');
     error:= true;
     break;
    end;
    for int3:= 0 to rootnode.count - 1 do begin
     if rootnode[int3].info.name = 
                       ansistring(projectfo.rootname[int2]) then begin
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
       str1:= ansistring(filenamebase(afilename))+rstext;
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
       additem(modulenames,ansistring(filenamebase(afilename)));
      end;
     end;
    end;
   end;
   if (modulenames <> nil) or (resourcenames <> nil) then begin
    with projectfo do begin
     macroar[0].value:= basename+'_'+lang[int1]+'.pas';
     macroar[1].value:= filenamebase(macroar[0].value);
     createlanglib(dir[int1]+macroar[0].value,modulenames,resourcenames);
     if makeon.value then begin
      try
       setcurrentdirmse(dir[int1]);
       if beforemake.value <> '' then begin
        if not doproc(beforemake.value) then begin
         break;
        end;
       end;
       if doproc(commandstring) then begin
        if aftermake.value <> '' then begin
         doproc(aftermake.value);
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
       setcurrentdirmse(dirbefore);
      end;
     end;
    end;
   end;
  except
   on e: exception do begin
    addmessage(msestring(e.message+lineend));
    error:= true;
   end;
   else begin
    error:= true;
   end;
  end;
 end;
 if error then begin
  addmessage('**** '+c[ord(sc_error)]+' ****'+lineend);
 end
 else begin
  addmessage(c[ord(sc_finishedok)]+lineend);
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
  messagesfo.show; //winid must exist
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
   setcurrentdirmse(filedir(mstr1));
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
 editsettings(c[ord(sc_configuremsei18n)]);
end;

function tmainfo.checksave(cancelonly: boolean = false): boolean;
var
 mstr1: msestring;
begin
 result:= true;
 if fdatachanged then begin
  mstr1:= c[ord(sc_datahaschanged)]+'.'+lineend+c[ord(sc_doyouwishtosave)]+'?';
  if cancelonly then begin
   if askok(mstr1,c[ord(sc_confirmation)]) then begin
    writeprojectdata;
   end
   else begin
    result:= false;
   end;
  end
  else begin
   case askyesnocancel(mstr1,c[ord(sc_confirmation)]) of
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
  try
   mainstatfile.writestat;
  except
   on e: exception do begin
    if showmessage(c[ord(sc_closeerror)]+lineend+msestring(e.message),
          c[ord(sc_error)],[mr_ignore,mr_cancel]) <> mr_ignore then begin
     amodalresult:= mr_none;
    end;
   end;
  end;
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
         'MSEi18n version: ' + msei18nversiontext,'About MSEi18n');
end;

procedure tmainfo.exitexe(const sender: TObject);
begin
 close;
end;

procedure tmainfo.beforelangdrawcell(const sender: tcol; const canvas: tcanvas;
               var cellinfo: cellinfoty; var processed: Boolean);
var
 int1: integer;
begin
 if coloron.value then begin
  with cellinfo.cell do begin
   int1:= typedisp[row];
   if ((int1 = ord(vastring)) or (int1 = ord(vawstring))) and 
          not donottranslate[row] and 
          (tstringedit(grid.datacols[col].editwidget)[row] =
                 value[row]) and (value[row] <> '') then begin
    cellinfo.color:= cl_ltred;
   end;
  end;
 end;
end;

procedure tmainfo.showcolordataentered(const sender: TObject);
begin
 grid.invalidate;
end;

procedure tmainfo.loadedexe(const sender: TObject);
begin
 iconbmp.free;
end;

end.
