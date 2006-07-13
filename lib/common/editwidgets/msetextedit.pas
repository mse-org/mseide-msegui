{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msetextedit;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mseeditglob,mseedit,msewidgetgrid,classes,msedatalist,msegraphics,msestream,
 msetypes,mserichstring,msestat,mseclasses,mseinplaceedit,msegrids,mseevent,
 msegui,msegraphutils,msestrings,msedrawtext,msearrayprops;

const
 defaulttexteditoptions =  (defaultoptionsedit + [oe_linebreak]) -
              [oe_autoselect,oe_autoselectonfirstclick,oe_endonenter,
               oe_resetselectonexit,oe_undoonesc,oe_shiftreturn];
 texteditminimalframe: framety = (left: 1; top: 0; right: 1; bottom: 0);
 defaulttexteditwidgetoptions = 
         (defaulteditwidgetoptions - [ow_fontglyphheight]) + [ow_fontlineheight];

type
// texteditstatety = record
// end;

 textmouseeventinfoty = record
  eventkind: celleventkindty;
  mouseeventinfopo: pmouseeventinfoty;
  pos: gridcoordty;
 end;

 textmouseeventty = procedure(const sender: tobject;
          var info: textmouseeventinfoty) of object;

 texteditstatety = (tes_selectinvalid);
 texteditstatesty = set of texteditstatety;

 tcustomtextedit = class(tcustomedit,igridwidget,istatfile)
  private
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fselectstart,fselectend: gridcoordty;
   fcolindex: integer;
   fmodified: boolean;
   fonmodifiedchanged: booleanchangedeventty;
   fontextmouseevent: textmouseeventty;
   fmousetextpos: gridcoordty;
   foneditnotification: editnotificationeventty;
   foncellevent: celleventty;
   fonfontchanged: notifyeventty;
   fstate: texteditstatesty;
   fmarginlinecolor: colorty;
   fmarginlinepos: integer;
   ftabulators: ttabulators;
   fencoding: charencodingty;
   procedure setstatfile(const Value: tstatfile);
   function geteditpos: gridcoordty;
   procedure seteditpos1(const value: gridcoordty);
   function getgridvalue(const index: integer): msestring;
   procedure setgridvalue(const index: integer; const Value: msestring);
   function getgridvalues: msestringarty;
   procedure setgridvalues(const Value: msestringarty);
   function getrichlines(const index: integer): richstringty;
   procedure setrichlines(const index: integer; const Value: richstringty);
   function getrichformats(const index: integer): formatinfoarty;
   procedure setrichformats(const index: integer; const avalue: formatinfoarty);
   procedure setmodified(const Value: boolean);
   procedure setdatalist(const Value: trichstringdatalist);

   procedure mousepostotextpos1(const row: integer; const mousepos: pointty;
               var textpos: gridcoordty; var result: boolean);
   procedure setmarginlinecolor(const avalue: colorty);
   procedure setmarginlinepos(const avalue: integer);
   procedure colchanged;
   function gettabulators: ttabulators;
   procedure settabulators(const Value: ttabulators);
  protected
   fgridintf: iwidgetgrid;
   fupdating: integer;
   fnotificationchangelock: integer;
   ffilename: filenamety;
   flines: trichstringdatalist;
   procedure setoptionsedit(const avalue: optionseditty); override;

   procedure fontchanged; override;
   procedure tabulatorschanged(const sender: tarrayprop; const index: integer);
   procedure dobeforepaintforeground(const canvas: tcanvas); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure dochange; override;
   procedure getstate(out state: texteditstatety); virtual;
   procedure setstate(const state: texteditstatety); virtual;
   procedure setfilename(const value: filenamety);
   procedure insertlinebreak; virtual;
   procedure editnotification(var info: editnotificationinfoty); override;
   procedure updateindex(select: boolean);
   procedure textinserted(const apos: gridcoordty;
               const atext: msestring; const selected: boolean;
               const endpos: gridcoordty; const backwards: boolean); virtual;
   procedure textdeleted(const apos: gridcoordty;
               const atext: msestring; const selected: boolean;
               const endpos: gridcoordty; const backwards: boolean); virtual;

   procedure dotextmouseevent(var info: textmouseeventinfoty);
   procedure setupeditor; override;
   procedure dofontheightdelta(var delta: integer); override;

    //igridwidget
   procedure setfirstclick;
   function createdatalist(const sender: twidgetcol): tdatalist; virtual;
   function getdatatyp: datatypty; virtual;
   function getinitvalue: pointer;
   function getdefaultvalue: pointer;
   function getrowdatapo(const info: cellinfoty): pointer; virtual;
   procedure setgridintf(const intf: iwidgetgrid);
   function getcellframe: framety; virtual;
   procedure drawcell(const canvas: tcanvas);
   procedure initgridwidget;
   procedure valuetogrid(const row: integer);
   procedure gridtovalue(const row: integer);
   procedure docellevent(const ownedcol: boolean; var info: celleventinfoty); virtual;
   procedure sortfunc(const l,r; var result: integer);
   procedure gridvaluechanged(const index: integer); virtual;
   procedure updatecoloptions(var aoptions: coloptionsty);
   procedure statdataread; virtual;
   procedure griddatasourcechanged;

    //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   procedure checkgrid;

   procedure setedpos(const Value: gridcoordty; const select: boolean;
                     const donotify: boolean);
   procedure normalizeselectedrows(var start,stop: integer);
   procedure internalclearselection;

  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure createtabulators;
   function actualcolor: colorty; override;
   procedure synctofontheight; override;
   procedure reloadfile(restorestate: boolean = true);
   procedure loadfromstream(const stream: ttextstream; 
                                  restorestate: boolean = false);
   procedure loadfromfile(const afilename: filenamety;
                                  restorestate: boolean = false); virtual;
   procedure savetostream(const stream: ttextstream);
   procedure savetofile(const afilename: filenamety = '');
                       //afilename = '' -> actual filename
   procedure beginupdate;
   procedure endupdate;
   procedure clear;
   function filename: filenamety;

   procedure seteditpos(const Value: gridcoordty; const select: boolean = false);
   procedure inserttext(const apos: gridcoordty; const atext: msestring;
                           out aendpos: gridcoordty;
                           selected: boolean = false;
                           insertbackwards: boolean = false); overload;
   procedure inserttext(const apos: gridcoordty; const atext: msestring;
                               selected: boolean = false;
                               insertbackwards: boolean = false); overload;
   procedure inserttext(const atext: msestring;
                                    selected: boolean = false); overload;
   procedure deletetext(const start,stop: gridcoordty);
   function appendrow(const atext: msestring): integer; overload;
   function appendrow(const atext: richstringty): integer; overload;

   function hasselection: boolean;
   function selectedtext: msestring;

   property optionsedit default defaulttexteditoptions;
   property selectstart: gridcoordty read fselectstart;
   property selectend: gridcoordty read fselectend;
   procedure setselection(const start,stop: gridcoordty; aseteditpos: boolean = false);
   procedure clearselection;
   procedure copyselection;
   procedure cutselection;
   function canpaste: boolean;
   procedure paste;
   procedure deleteselection;

   function find(const atext: msestring; options: searchoptionsty;
              var textpos: gridcoordty; const endpos: gridcoordty; 
              selectfound: boolean = false): boolean;

   function gettext(const start, stop: gridcoordty): msestring;
   function linecount: integer;
   property gridvalue[const index: integer]: msestring 
                 read getgridvalue write setgridvalue; default;
   property gridvalues: msestringarty read getgridvalues write setgridvalues;
   property richlines[const index: integer]: richstringty 
                 read getrichlines write setrichlines;
   property richformats[const index: integer]: formatinfoarty 
                 read getrichformats write setrichformats;
   property datalist: trichstringdatalist read flines write setdatalist;

   function mousepostotextpos(const mousepos: pointty; out textpos: gridcoordty;
                                 widgetorg: boolean = false): boolean;
                     //if widgetorg = false -> org mousepos = topleft of col
                     // org mousepos = clientpos otherwise
                     //false if out of text, textpos clamped to textrange
   function textpostomousepos(const textpos: gridcoordty;
                                      const screenorg: boolean = false): pointty;
   function textpostomouserect(const textpos: gridcoordty;
                                     const screenorg: boolean = false): rectty;
                     //y:= top of character cell cx = 0 cy = linespacing
   property editpos: gridcoordty read geteditpos write seteditpos1;
   property modified: boolean read fmodified write setmodified;

   property encoding: charencodingty read fencoding write fencoding;
   property textflags default defaulttextflags - [tf_noselect];
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property tabulators: ttabulators read gettabulators write settabulators;
   property marginlinepos: integer read fmarginlinepos write setmarginlinepos default 0;
                     //offset to innerclientrect.x
   property marginlinecolor: colorty read fmarginlinecolor 
                                     write setmarginlinecolor default cl_none;
   property onfontchanged: notifyeventty read fonfontchanged write fonfontchanged;
   property onmodifiedchanged: booleanchangedeventty read fonmodifiedchanged
                                     write fonmodifiedchanged;
   property ontextmouseevent: textmouseeventty read fontextmouseevent 
                                     write fontextmouseevent;
   property oneditnotifcation: editnotificationeventty read foneditnotification 
                                     write foneditnotification;
   property oncellevent: celleventty read foncellevent write foncellevent;
 end;

 ttextedit = class(tcustomtextedit)
  published
   property font;
   property caretwidth;
   property optionsedit;
   property encoding;
   property textflags;
   property textflagsactive;
   property onkeydown;
   property statfile;
   property statvarname;
   property marginlinepos;
                     //offset to innerclientrect.x
   property marginlinecolor;
   property tabulators;
   property onfontchanged;
   property onmodifiedchanged;
   property ontextmouseevent;
   property oneditnotifcation;
   property oncellevent;
 end;

 tundotextedit = class(ttextedit,iundo)
  private
   function getmaxundocount: integer;
   procedure setmaxundocount(const Value: integer);
   function getmaxundosize: integer;
   procedure setmaxundosize(const Value: integer);
  protected
   procedure textinserted(const apos: gridcoordty;
            const atext: msestring; const selected: boolean;
            const endpos: gridcoordty; const backwards: boolean); override;
   procedure textdeleted(const apos: gridcoordty;
            const atext: msestring; const selected: boolean;
           const endpos: gridcoordty; const backwards: boolean); override;
   procedure getselectstart(var selectstartpos: gridcoordty);
   procedure setselectstart(const selectstartpos: gridcoordty);
  protected
  public
   constructor create(aowner: tcomponent); override;
   procedure undo;
   procedure redo;
   function canundo: boolean;
   function canredo: boolean;
  published
   property maxundocount: integer read getmaxundocount write
                  setmaxundocount default defaultundomaxcount;
   property maxundosize: integer read getmaxundosize write
                  setmaxundosize default defaultundobuffermaxsize;
 end;

implementation
uses
 msefileutils,sysutils,msesysutils,msesys,mseguiglob,msewidgets,
 msekeyboard;

const
 valuevarname = 'value';
type
 tcustomwidgetgrid1 = class(tcustomwidgetgrid);
 tinplaceedit1 = class(tinplaceedit);
 twidgetcol1 = class(twidgetcol);

procedure normalizetextrect(const po1,po2: gridcoordty; out start,stop: gridcoordty);
begin
 if po1.row > po2.row then begin
  start:= po2;
  stop:= po1;
 end
 else begin
  if po1.row < po2.row then begin
   start:= po1;
   stop:= po2;
  end
  else begin
   if po1.col > po2.col then begin
    start:= po2;
    stop:= po1;
   end
   else begin
    start:= po1;
    stop:= po2;
   end;
  end;
 end;
end;

{ tcustomtextedit }

constructor tcustomtextedit.create(aowner: tcomponent);
begin
 fmousetextpos:= invalidcell;
 fmarginlinecolor:= cl_none;
 if feditor = nil then begin
  feditor:= tinplaceedit.create(self,iedit(self),true);
 end;
 inherited;
 foptionswidget:= defaulttexteditwidgetoptions;
 optionsedit:= defaulttexteditoptions;
 textflags:= defaulttextflags - [tf_noselect];
end;

destructor tcustomtextedit.destroy;
begin
 inherited;
 ftabulators.Free;
end;

function tcustomtextedit.actualcolor: colorty;
begin
 if (fgridintf <> nil) and (fcolor = cl_default) then begin
  result:= fgridintf.getcol.rowcolor(fgridintf.getrow);
 end
 else begin
  result:= inherited actualcolor;
 end;
end;

procedure tcustomtextedit.synctofontheight;
begin
 inherited;
 if fgridintf <> nil then begin
  fgridintf.getcol.grid.datarowheight:= bounds_cy - font.glyphheight + font.lineheight;
 end;
end;

procedure tcustomtextedit.dofontheightdelta(var delta: integer);
begin
 inherited;
 if fgridintf <> nil then begin
  with fgridintf.getcol.grid do begin
   datarowheight:= datarowheight + delta;
  end;
 end;
end;

procedure tcustomtextedit.setgridintf(const intf: iwidgetgrid);
begin
 fgridintf:= intf;
 if (intf <> nil) and (ow_autoscale in foptionswidget) and
             (foptionswidget * [ow_fontglyphheight,ow_fontlineheight] <> []) then begin
  fgridintf.getcol.grid.datarowheight:= bounds_cy;
 end;
end;

function tcustomtextedit.getcellframe: framety;
begin
 if fframe <> nil then begin
  result:= fframe.innerframe;
 end
 else begin
  result:= texteditminimalframe;
 end;
end;

function tcustomtextedit.createdatalist(
  const sender: twidgetcol): tdatalist;
begin
 flines:= trichstringdatalist.create;
 result:= flines;
end;

function tcustomtextedit.getdatatyp: datatypty;
begin
 result:= dl_none;
end;

procedure tcustomtextedit.dobeforepaintforeground(const canvas: tcanvas);
var
 int1: integer;
begin
 if fmarginlinecolor <> cl_none then begin
  int1:= innerclientpos.x + fmarginlinepos;
  if fframe = nil then begin
   inc(int1,texteditminimalframe.left);
  end;
  canvas.drawline(makepoint(int1,0),makepoint(int1,clientsize.cy),fmarginlinecolor);
 end;
end;

procedure tcustomtextedit.drawcell(const canvas: tcanvas);
var
 int1: integer;
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  if fmarginlinecolor <> cl_none then begin
   int1:= innerrect.x + fmarginlinepos;
   canvas.drawline(makepoint(int1,0),makepoint(int1,rect.cy),fmarginlinecolor);
  end;
  drawtext(canvas,prichstringty(datapo)^,innerrect,feditor.textflags,nil,ftabulators);
 end;
end;

procedure tcustomtextedit.fontchanged;
begin
 inherited;
 if fgridintf <> nil then begin
  fgridintf.getcol.changed;
 end;
 if canevent(tmethod(fonfontchanged)) then begin
  fonfontchanged(self);
 end;
end;

{
procedure tcustomtextedit.updatecellzone(const pos: pointty; var result: cellzonety);
begin
 //dummy
end;
}
function tcustomtextedit.getdefaultvalue: pointer;
begin
 result:= nil;
end;

function tcustomtextedit.getrowdatapo(const info: cellinfoty): pointer;
begin
 result:= nil;
end;

procedure tcustomtextedit.setfirstclick;
begin
 //dummy
end;

function tcustomtextedit.getinitvalue: pointer;
begin
 result:= nil;
end;

procedure tcustomtextedit.valuetogrid(const row: integer);
begin
 fgridintf.setdata(row,feditor.richtext);
end;

procedure tcustomtextedit.gridtovalue(const row: integer);
var
 text1: richstringty;
begin
 if fupdating = 0 then begin
  fgridintf.getdata(row,text1);
  inc(fupdating);
  try
   feditor.richtext:= text1;
  finally
   dec(fupdating);
  end;
 end;
end;

procedure tcustomtextedit.initgridwidget;
begin
 optionswidget:= optionswidget - [ow_autoscale];
 frame:= nil;
 with fgridintf.grid do begin
  optionsgrid:= optionsgrid + [og_autofirstrow];
 end;
end;

procedure tcustomtextedit.sortfunc(const l, r; var result: integer);
begin
 //dummy
end;

procedure tcustomtextedit.gridvaluechanged(const index: integer);
begin
 modified:= true;
end;

procedure tcustomtextedit.updatecoloptions(var aoptions: coloptionsty);
begin
 coloptionstoeditoptions(aoptions,foptionsedit);
end;

procedure tcustomtextedit.statdataread;
begin
 modified:= false;
end;

procedure tcustomtextedit.griddatasourcechanged;
begin
 //dummy
end;

procedure tcustomtextedit.setoptionsedit(const avalue: optionseditty);
begin
 inherited setoptionsedit(avalue - [oe_trimleft,oe_trimright,oe_uppercase,
        oe_lowercase,oe_autopopupmenu]);
end;

procedure tcustomtextedit.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if (fgridintf <> nil) then begin
   if ((shiftstate = [ss_shift,ss_ctrl]) or (shiftstate = [ss_ctrl])) then begin
    if key = key_home then begin
     seteditpos(makegridcoord(0,0),ss_shift in shiftstate);
     include(eventstate,es_processed);
    end
    else begin
     if key = key_end then begin
      seteditpos(makegridcoord(bigint,bigint),ss_shift in shiftstate);
      include(eventstate,es_processed);
     end;
    end;
   end;
   if (info.key = key_return) and (shiftstate - [ss_shift] = []) and
          (foptionsedit * [oe_readonly,oe_linebreak] = [oe_linebreak]) and
         ((ss_shift in shiftstate) xor not (oe_shiftreturn in foptionsedit))
                                             then begin
    insertlinebreak;
    include(eventstate,es_processed);
   end;
  end;
  if not (es_processed in eventstate) then begin
   inherited;
  end;
 end;
end;

procedure tcustomtextedit.dochange;
begin
 inherited;
{
 if not (csdesigning in componentstate) then begin
  if fupdating = 0 then begin
   if fgridintf <> nil then begin
    inc(fupdating);
    try
     valuetogrid(fgridintf.getrow);
    finally
     dec(fupdating);
    end;
   end;
   inherited;
  end;
 end;
 }
end;

procedure tcustomtextedit.reloadfile(restorestate: boolean = true);
begin
 inc(fnotificationchangelock);
 try
  loadfromfile(ffilename,restorestate);
 finally
  dec(fnotificationchangelock);
 end;
end;

procedure tcustomtextedit.loadfromstream(const stream: ttextstream;
               restorestate: boolean = false);
var
 statsave: texteditstatety;
begin
 if restorestate then begin
  getstate(statsave);
 end;
 beginupdate;
 clear;
 try
  flines.loadfromstream(stream);
  fgridintf.getcol.grid.rowcount:= flines.count;
  if restorestate then begin
   setstate(statsave);
  end;
 finally
  endupdate;
 end;
 modified:= false;
end;

procedure tcustomtextedit.loadfromfile(const afilename: filenamety;
                                 restorestate: boolean = false);
var
 stream: ttextstream;

begin
 stream:= ttextstream.Create(afilename,fm_read);
 try
  stream.encoding:= fencoding;
  loadfromstream(stream,restorestate);
  setfilename(afilename);
 finally
  stream.Free;
 end;
end;

procedure tcustomtextedit.savetostream(const stream: ttextstream);
begin
 flines.savetostream(stream);
 modified:= false;
end;

procedure tcustomtextedit.savetofile(const afilename: filenamety = ''); //afilename = '' -> actual filename
var
 stream: ttextstream;
 str1: filenamety;
begin
 if afilename = '' then begin
  str1:= ffilename;
 end
 else begin
  str1:= afilename;
 end;
 stream:= ttextstream.Create(str1,fm_create);
 stream.encoding:= fencoding;
 try
  savetostream(stream);
  setfilename(str1);
 finally
  stream.Free;
 end;
end;

procedure tcustomtextedit.getstate(out state: texteditstatety);
begin
 //dummy
end;

procedure tcustomtextedit.setstate(const state: texteditstatety);
begin
 //dummy
end;

procedure tcustomtextedit.beginupdate;
begin
 if flines <> nil then begin
  flines.beginupdate;
 end;
end;

procedure tcustomtextedit.clear;
begin
 ffilename:= '';
 if flines <> nil then begin
  flines.clear;
//  fgridintf.getcol.grid.rowcount:= 0;
 end;
 modified:= false;
end;

procedure tcustomtextedit.endupdate;
begin
 if flines <> nil then begin
  flines.endupdate;
 end;
end;

procedure tcustomtextedit.setfilename(const value: filenamety);
begin
 ffilename:= filepath(value);
{
 removefilechangenotification;
 ffilepath:= expanduncfilename(value);
 addfilechangenotification;
 if (seo_autosyntax in foptions) and (fsyntaxpainter <> nil) then begin
  try
   syntaxhandle:= fsyntaxpainter.linkdeffile(fileext(value));
  except
   on e: exception do begin
    writeexceptionmessage(e);
    syntaxhandle:= -1;
   end;
  end;
 end;
 }
end;

function tcustomtextedit.filename: filenamety;
begin
 result:= ffilename;
end;

procedure tcustomtextedit.dostatread(const reader: tstatreader);
begin
 if fgridintf = nil then begin
  if oe_savevalue in foptionsedit then begin
//   value:= reader.readmsestring(valuevarname,value);
  end;
 end;
 if oe_savestate in foptionsedit then begin
//  readstatstate(reader);
 end;
 if oe_saveoptions in foptionsedit then begin
//  readstatoptions(reader);
 end;
end;

procedure tcustomtextedit.dostatwrite(const writer: tstatwriter);
begin
 if fgridintf = nil then begin
  if oe_savevalue in foptionsedit then begin
//   writestatvalue(writer);
  end;
 end;
 if oe_savestate in foptionsedit then begin
//  writestatstate(writer);
 end;
 if oe_saveoptions in foptionsedit then begin
//  writestatoptions(writer);
 end;
end;

function tcustomtextedit.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tcustomtextedit.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

procedure tcustomtextedit.statreading;
begin
 //dummy
end;

procedure tcustomtextedit.statread;
begin
 //dummy
end;

procedure tcustomtextedit.inserttext(const apos: gridcoordty; const atext: msestring;
                        out aendpos: gridcoordty;
                        selected: boolean = false;
                        insertbackwards: boolean = false);
var
 ar1: msestringarty;
 int1: integer;
begin
 beginupdate;
 feditor.begingroup;
 try
  clearselection;
  ar1:= breaklines(atext);
  with fgridintf.getcol do begin
   aendpos.row:= apos.row + high(ar1);
   if ar1 = nil then begin
    aendpos.col:= 0;
   end
   else begin
    aendpos.col:= length(ar1[high(ar1)]);
   end;
   if length(ar1) > 1 then begin
    ar1[high(ar1)]:= ar1[high(ar1)] + copy(flines[apos.row],apos.col + 1,bigint);
    grid.insertrow(apos.row+1,high(ar1));
    for int1:= 1 to high(ar1) do begin
     flines.items[apos.row+int1]:= ar1[int1];
    end;
    flines[apos.row]:= copy(flines[apos.row],1,apos.col) + ar1[0];
   end
   else begin
    richinsert(atext,prichstringty(flines.getitempo(apos.row))^,apos.col+1);
    aendpos.col:= aendpos.col + apos.col;
   end;
  end;
  int1:= fgridintf.getrow;
  if (int1 >= 0) and (int1 < flines.count) then begin
   feditor.richtext:= flines.richitems[int1];
  end;
  if insertbackwards then begin
   seteditpos(aendpos,false);
   textinserted(aendpos,atext,selected,apos,true);
   seteditpos(apos,false);
   if selected then begin
    fselectstart:= aendpos;
    fselectend:= aendpos;
   end;
  end
  else begin
   seteditpos(apos,false);
   textinserted(apos,atext,selected,aendpos,false);
   seteditpos(aendpos,false);
   if selected then begin
    fselectstart:= apos;
    fselectend:= apos;
   end;
  end;
  updateindex(selected);
 finally
  feditor.endgroup;
  endupdate;
 end;
end;

procedure tcustomtextedit.inserttext(const apos: gridcoordty; const atext: msestring;
                 selected: boolean = false;
                 insertbackwards: boolean = false);
var
 po1: gridcoordty;
begin
 inserttext(apos,atext,po1,selected,insertbackwards);
end;

procedure tcustomtextedit.deletetext(const start, stop: gridcoordty);
var
 po1,po2: gridcoordty;
 bo1: boolean;
 grid: tcustomwidgetgrid1;
begin
 if (start.col <> stop.col) or (start.row <> stop.row) then begin
  normalizetextrect(start,stop,po1,po2);
  beginupdate;
  bo1:= false;
  feditor.begingroup;
  application.caret.remove;
  grid:= tcustomwidgetgrid1(fgridintf.getcol.grid);
  bo1:= og_appendempty in grid.optionsgrid;
  try
   include(grid.foptionsgrid,og_appendempty);
   clearselection;
   seteditpos(stop,false);
   textdeleted(stop,gettext(po1,po2),false,po1,
               isequalgridcoord(po2,stop));
   seteditpos(po1,false);
   if po1.row = po2.row then begin
    richdelete(prichstringty(flines.getitempo(po1.row))^,po1.col+1,po2.col-po1.col);
   end
   else begin
    richdelete(prichstringty(flines.getitempo(po1.row))^,po1.col+1,bigint);
    if po2.col > 0 then begin
     richdelete(prichstringty(flines.getitempo(po2.row))^,1,po2.col);
    end;
    if po2.row < flines.count then begin
     prichstringty(flines.getitempo(po1.row))^:=
          richconcat(prichstringty(flines.getitempo(po1.row))^,
          prichstringty(flines.getitempo(po2.row))^);
    end;
    if (po1.row+1 < flines.count) then begin
     fgridintf.getcol.grid.deleterow(po1.row+1,po2.row-po1.row);
    end
    else begin
     if po1.col = 0 then begin
      fgridintf.getcol.grid.deleterow(po1.row,po2.row-po1.row);
     end;
    end;
   end;
  finally
   application.caret.restore;
   feditor.endgroup;
   if bo1 then begin
    exclude(grid.foptionsgrid,og_appendempty);
   end;
   endupdate;
  end;
 end;
end;

function tcustomtextedit.appendrow(const atext: richstringty): integer;
begin
 checkgrid;
 result:= fgridintf.getcol.grid.appendrow;
 richlines[result]:= atext;
end;

function tcustomtextedit.appendrow(const atext: msestring): integer;
var
 richstring: richstringty;
begin
 richstring.text:= atext;
 richstring.format:= nil;
 result:= appendrow(richstring);
end;

function intersecttextrect(const a1,a2,b1,b2: gridcoordty;
                                out i1,i2: gridcoordty): boolean;
               //i = a * b, true if intersection exist, values have to be ordered
begin
 if b1.row > a1.row then begin
  i1:= b1;
 end
 else begin
  i1:= a1;
  if (b1.row = a1.row) and (b1.col > a1.col) then begin
   i1.col:= b1.col;
  end;
 end;
 if b2.row < a2.row then begin
  i2:= b2;
 end
 else begin
  i2:= a2;
  if (b2.row = a2.row) and (b2.col < a2.col) then begin
   i2.col:= b2.col;
  end;
 end;
 result:= (i1.row < i2.row) or (i1.row = i2.row) and (i1.col < i2.col);
end;

function compgridcoord(const a,b: gridcoordty): integer;
begin
 result:= a.row-b.row;
 if result = 0 then begin
  result:= a.col - b.col;
 end;
end;

procedure tcustomtextedit.setselection(const start,stop: gridcoordty;
                         aseteditpos: boolean = false);
var
 astart,astop: gridcoordty;

 function checkoverlap(const a1,a2,b1,b2: gridcoordty): boolean;
  //true if a <> (a ^ b)
 var
  int1: integer;
  i1,i2: gridcoordty;
 begin
  if not intersecttextrect(a1,a2,b1,b2,i1,i2) then begin
   result:= true;
   astart:= a1;
   astop:= a2;
   exit;    //no intersection
  end;
  result:= (a1.row <> i1.row) or (a1.col <> i1.col) or
           (a2.row <> i2.row) or (a2.col <> i2.col);
  if result then begin
   int1:= compgridcoord(a1,i1);
   if int1 < 0 then begin
    astart:= a1;
    astop:= i1;
   end
   else begin
    astart:= i2;
    astop:= a2;
   end;
  end;
 end;

var
 col: twidgetcol;
 grid: twidgetgrid;
 cell: gridcoordty;

 procedure updatestyle(value: boolean);
 var
  int1,int2: integer;

 begin
  for int1:= astart.row to astop.row do begin //deselect old
   if int1 = astop.row then begin
    int2:= astop.col - astart.col;
   end
   else begin
    int2:= bigint;
   end;
   if int2 > 0 then begin
    updatefontstyle(prichstringty(flines.getitempo(int1))^.format,
                astart.col,int2,fs_selected,value);
    cell.row:= int1;
    grid.invalidatecell(cell);
   end;
   astart.col:= 0;
  end;
 end;

var
 new1,new2,old1,old2: gridcoordty;
 int1: integer;

begin
 if aseteditpos then begin
  seteditpos(start,false);
  seteditpos(stop,true);
 end
 else begin
  col:= fgridintf.getcol;
  grid:= twidgetgrid(col.grid);
  cell.col:= col.colindex;

  normalizetextrect(start,stop,new1,new2);
  int1:= grid.row;
  if int1 > new1.row then begin
   if int1 < new2.row then begin
    feditor.selstart:= 0;
    feditor.sellength:= bigint;
   end
   else begin
    if int1 = new2.row then begin
     if new1.row < int1 then begin
      feditor.selstart:= 0;
     end
     else begin
      feditor.selstart:= new1.col;
     end;
     feditor.sellength:= new2.col-feditor.selstart;
    end
    else begin
     feditor.sellength:= 0;
    end;
   end;
  end
  else begin
   if int1 = new1.row then begin
    feditor.selstart:= new1.col;
    if new2.row > int1 then begin
     feditor.sellength:= bigint;
    end
    else begin
     feditor.sellength:= new2.col - new1.col;
    end;
   end
   else begin
    feditor.sellength:= 0;
   end;
  end;
  normalizetextrect(fselectstart,fselectend,old1,old2);
  fselectstart:= start;
  fselectend:= stop;
  int1:= fgridintf.getcol.grid.rowcount;
  if old1.row >= int1 then begin
   old1.row:= int1 - 1;
   old1.col:= 0;
   old2:= old1;
  end
  else begin
   if old2.row >= int1 then begin
    old2.row:= int1-1;
    old2.col:= bigint;
   end;
  end;
  if tes_selectinvalid in fstate then begin
   astart:= new1;
   astop:= new2;
   updatestyle(true);
   exclude(fstate,tes_selectinvalid);
  end
  else begin
   if checkoverlap(old1,old2,new1,new2) then begin
    updatestyle(false);
   end;
   if checkoverlap(new1,new2,old1,old2) then begin
    updatestyle(true);
   end;
  end;
 end;
end;

procedure tcustomtextedit.updateindex(select: boolean);
var
 selectstart1,selectend1: gridcoordty;

begin
 selectstart1:= fselectstart;
 selectend1:= fselectend;
 if select then begin
  selectend1.col:= feditor.curindex;
  selectend1.row:= tcustomwidgetgrid1(fgridintf.getcol.grid).row
 end
 else begin
  selectstart1.col:= feditor.curindex;
  selectstart1.row:= tcustomwidgetgrid1(fgridintf.getcol.grid).row;
  selectend1:= selectstart1;
 end;
 setselection(selectstart1,selectend1);
end;

procedure tcustomtextedit.insertlinebreak;
begin
 feditor.begingroup;
 try
  deleteselection;
  inserttext(fselectstart,lineend);
 finally
  feditor.endgroup;
 end;
end;

procedure tcustomtextedit.editnotification(var info: editnotificationinfoty);
var
 int1: integer;
 str1: msestring;
 po1,po2: gridcoordty;
 rect1: rectty;
 grid: tcustomgrid;

begin
 if canevent(tmethod(foneditnotification)) then begin
  foneditnotification(self,info);
 end;
 if fgridintf <> nil then begin
  grid:= fgridintf.getcol.grid;
  with info do begin
   case action of
    ea_clearselection: begin
     internalclearselection;
    end;
    ea_textedited: begin
     if not (csdesigning in componentstate) then begin
      if fupdating = 0 then begin
       inc(fupdating);
       try
        int1:= fgridintf.getrow;
        fgridintf.setdata(int1,feditor.richtext,true);
        gridvaluechanged(int1);
       finally
        dec(fupdating);
       end;
       inherited;
      end;
     end;
    end;
    {
    ea_textentered: begin
     if foptionsedit * [oe_readonly,oe_linebreak,oe_shiftreturn] = 
                                [oe_linebreak] then begin
      insertlinebreak;
      action:= ea_none;
     end;
    end;
    }
    ea_indexmoved: begin
     fcolindex:= feditor.curindex;
     updateindex(eas_shift in state);
    end;
    ea_delchar: begin
     if (fselectstart.col = fselectend.col) and (fselectstart.row = fselectend.row) then begin
      if (feditor.curindex = length(feditor.text)) then begin
       if fselectstart.row < grid.rowcount - 1 then begin
        fselectstart.row:= fselectend.row+1;
        fselectstart.col:= 0;
        deleteselection;             //remove linebreak
        action:= ea_none;
       end;
      end;
     end
     else begin 
      deleteselection;
      action:= ea_none;
     end;
    end;
    ea_deleteselection: begin
     deleteselection;
     action:= ea_none;
    end;
    ea_copyselection: begin
     copyselection;
     action:= ea_none;
    end;
    ea_pasteselection: begin
     if msewidgets.pastefromclipboard(str1) then begin
      beginupdate;
      feditor.begingroup;
      try
       deleteselection;
       po2:= editpos;
       inserttext(po2,str1,po1,false);
      finally
       feditor.endgroup;
       endupdate;
      end;
     end;
     action:= ea_none;
    end;
    ea_exit: begin
     action:= ea_none;
     if dir = gd_left then begin
      if editpos.row > 0 then begin
       int1:= length(flines[editpos.row-1]);
       if eas_delete in state then begin
        deletetext(makegridcoord(0,editpos.row),makegridcoord(int1,editpos.row-1));
//        flines.richitems[editpos.row-1]:= richadd(flines.richitems[editpos.row-1],flines.richitems[editpos.row]);
       end
       else begin
        seteditpos(makegridcoord(int1,editpos.row - 1),state = [eas_shift]);
       end;{
       if eas_delete in state then begin
        deletetext(makegridcoord(0,editpos.row+1),makegridcoord(0,editpos.row+2));
       end;
       }
      end
      else begin
       if not (eas_shift in state) then begin
        internalclearselection;
       end;
      end;
     end
     else begin
      if dir = gd_right then begin
       if editpos.row < linecount - 1 then begin
        seteditpos(makegridcoord(0,editpos.row + 1),state = [eas_shift]);
       end
       else begin
        if not (eas_shift in state) then begin
         internalclearselection;
        end;
       end;
      end;
     end;
    end;
    ea_caretupdating: begin
     if focused then begin
      fgridintf.showcaretrect(info.caretrect,fframe);
     end;
      {
     rect1:= info.caretrect;
     if fframe <> nil then begin
      inflaterect1(rect1,fframe.innerframe);
     end;
     translateclientpoint1(rect1.pos,self,grid);
     grid.showrect(rect1,cep_nearest,grid.noscrollingcol);
     }
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tcustomtextedit.mousepostotextpos1( const row: integer; const mousepos: pointty;
             var textpos: gridcoordty; var result: boolean);
var
 textinfo: drawtextinfoty;
begin
 textinfo.text:= flines.richitems[row];
// textinfo.font:= fgridintf.getcol.getgridfont(row);
 textinfo.font:= fgridintf.getcol.rowfont(row);
 textinfo.flags:= feditor.textflags;
 textinfo.dest:= innerclientrect;
 textinfo.tabulators:= ftabulators;
 result:= postotextindex(getcanvas,textinfo,mousepos,textpos.col);
 textpos.row:= row;
end;

function tcustomtextedit.mousepostotextpos(const mousepos: pointty;
                     out textpos: gridcoordty; widgetorg: boolean = false): boolean;
                     //false if out of text, textpos clamped to textrange
var
 grid: tcustomwidgetgrid1;
 arow: integer;
 po1: pointty;
 int1: integer;
begin
 result:= true;
 grid:= tcustomwidgetgrid1(fgridintf.getcol.grid);
 if widgetorg then begin
  int1:= fgridintf.getrow * grid.ystep;
 end
 else begin
  int1:= 0;
 end;
 int1:= (mousepos.y + int1);
 arow:= int1 div grid.ystep;
 int1:= int1 - arow * grid.ystep;
 if arow < 0 then begin
  result:= false;
  arow:= 0;
 end
 else begin
  if arow >= grid.frowcount then begin
   result:= false;
   arow:= grid.frowcount-1;
  end;
 end;
 if widgetorg then begin
  mousepostotextpos1(arow,makepoint(mousepos.x,int1),textpos,result);
 end
 else begin
  po1:= fgridintf.getcol.cellorigin;
  mousepostotextpos1(arow,makepoint(mousepos.x - po1.x,
     mousepos.y - arow*grid.ystep - po1.y),textpos,result);
 end;
end;

function tcustomtextedit.textpostomousepos(const textpos: gridcoordty;
                                      const screenorg: boolean = false): pointty;
var
 po1,po2: pointty;
 textinfo: drawtextinfoty;
begin
 textinfo.text:= flines.richitems[textpos.row];
// textinfo.font:= fgridintf.getcol.getgridfont(textpos.row);
 textinfo.font:= fgridintf.getcol.rowfont(textpos.row);
 textinfo.flags:= feditor.textflags;
 textinfo.dest:= innerclientrect;
 textinfo.tabulators:= ftabulators;
 po1:= textindextopos(getcanvas,textinfo,textpos.col);
 po2:= fgridintf.getcol.cellorigin;
 result.y:= po1.y + po2.y + textpos.row * tcustomwidgetgrid1(fgridintf.getcol.grid).ystep;
 result.x:= po1.x + po2.x;
 if screenorg then begin
  translateclientpoint1(result,fgridintf.getcol.grid,nil);
 end;
end;

function tcustomtextedit.textpostomouserect(const textpos: gridcoordty;
                                   const screenorg: boolean = false): rectty;
              //y:= top of character cell cx = 0 cy = linespacing
begin
 result.pos:= textpostomousepos(textpos,screenorg);
 result.cx:= 0;
 result.cy:= font.lineheight;
 dec(result.y,font.ascent);
end;

procedure tcustomtextedit.dotextmouseevent(var info: textmouseeventinfoty);
begin
 if canevent(tmethod(fontextmouseevent)) then begin
  fontextmouseevent(self,info);
 end;
end;
{
procedure tcustomtextedit.clientmouseevent(var info: mouseeventinfoty);
begin
 if fgridintf <> nil then begin
  twidgetcol1(fgridintf.getcol).childmouseevent(self,info);
 end;
 inherited;
end;
}
procedure tcustomtextedit.docellevent(const ownedcol: boolean; var info: celleventinfoty);
var
 textinfo: textmouseeventinfoty;
 bo1: boolean;
 po1: pointty;
 int1: integer;
begin
 if ownedcol then begin
  with info do begin
   textinfo.eventkind:= eventkind;
   if eventkind = cek_enter then begin
    tinplaceedit1(feditor).frow:= newcell.row;
   end;
   if canevent(tmethod(foncellevent)) then begin
    foncellevent(self,info);
   end;
   case eventkind of
    cek_enter: begin
     feditor.curindex:= fcolindex;
     int1:= fcolindex;
     feditor.moveindex(feditor.curindex,
                  selectaction in [fca_focusinshift,fca_focusinrepeater],true{false});
     fcolindex:= int1; //restore
     if selectaction = fca_focusinrepeater then begin
      setclientclick;
     end;
    end;
    cek_mousemove,cek_mousepark,cek_buttonpress,cek_buttonrelease: begin
     if cell.row >= 0 then begin
      mousepostotextpos1(cell.row,mouseeventinfopo^.pos,textinfo.pos,bo1);
      if (eventkind = cek_mousemove) and (cell.row <> fgridintf.getcol.grid.row) and
             (info.mouseeventinfopo^.shiftstate = [ss_left]) then begin
       fcolindex:= textinfo.pos.col;
       fgridintf.getcol.grid.focuscell(cell,fca_focusinshift);
       
       setclientclick;
       exit;
      end;
      if not bo1 then begin
       textinfo.pos:= invalidcell;
      end;
     end
     else begin
      textinfo.pos:= invalidcell;
     end;
     if not(eventkind in [cek_mousemove]) or (textinfo.pos.col <> fmousetextpos.col) or
               (textinfo.pos.row <> fmousetextpos.row) then begin
      fmousetextpos:= textinfo.pos;
      po1:= subpoint(gridmousepos,mouseeventinfopo^.pos);
      mouseeventinfopo^.pos:= gridmousepos;
      textinfo.mouseeventinfopo:= mouseeventinfopo;
      try
       dotextmouseevent(textinfo);
      finally
       subpoint1(mouseeventinfopo^.pos,po1);
      end;
     end;
    end;
    cek_mouseleave: begin
     fmousetextpos:= invalidcell;
     textinfo.pos:= invalidcell;
     textinfo.mouseeventinfopo:= mouseeventinfopo;
     dotextmouseevent(textinfo);
    end;
   end;
  end;
 end;
 inherited;
end;

function tcustomtextedit.geteditpos: gridcoordty;
begin
 result:= makegridcoord(feditor.curindex,fgridintf.getrow);
end;

procedure tcustomtextedit.internalclearselection;
begin
 setselection(editpos,editpos);
end;

procedure tcustomtextedit.clearselection;
begin
 seteditpos(editpos,false);
end;

procedure tcustomtextedit.setedpos(const Value: gridcoordty; const select: boolean;
                       const donotify: boolean);
var
 po1: gridcoordty;
begin
 tinplaceedit1(feditor).frow:= value.row;
 po1.row:= value.row;
 po1.col:= fgridintf.getcol.colindex;
// if not select then begin
//  clearselection;
// end;
 fcolindex:= feditor.curindex;
 if select then begin
  fgridintf.getcol.grid.focuscell(po1,fca_focusinshift);
 end
 else begin
  fgridintf.getcol.grid.focuscell(po1,fca_focusin);
 end;
 feditor.moveindex(value.col,select,donotify);
// fgridintf.setrow(value.row);
// feditor.moveindex(value.col,false,false);
// fcolindex:= feditor.curindex;
 updateindex(select);
end;

procedure tcustomtextedit.seteditpos(const Value: gridcoordty; const select: boolean = false);
begin
 setedpos(value,select,true);
end;

procedure tcustomtextedit.seteditpos1(const Value: gridcoordty);
begin
 seteditpos(value,false);
end;

procedure tcustomtextedit.normalizeselectedrows(var start,stop: integer);
var
 int1: integer;
begin
 int1:= fselectend.row - fselectstart.row;
 if int1 > 0 then begin
  start:= fselectstart.row;
  stop:= fselectend.row;
  if fselectend.col = 0 then begin
   dec(stop);
  end;
 end
 else begin
  if int1 <> 0 then begin
   start:= fselectend.row;
   stop:= fselectstart.row;
   if fselectstart.col = 0 then begin
    dec(stop);
   end;
  end
  else begin
   start:= editpos.row;
   stop:= start;
  end;
 end;
end;

procedure tcustomtextedit.deleteselection;
begin
 if hasselection then begin
  deletetext(fselectstart,fselectend);
 end;
end;

procedure tcustomtextedit.copyselection;
begin
 if hasselection then begin
  msewidgets.copytoclipboard(selectedtext);
 end;
end;

procedure tcustomtextedit.cutselection;
begin
 copyselection;
 deleteselection;
end;

function tcustomtextedit.canpaste: boolean;
begin
 result:= canpastefromclipboard;
end;

procedure tcustomtextedit.paste;
var
 str1: msestring;
begin
 if msewidgets.pastefromclipboard(str1) then begin
  feditor.begingroup;
  try
   deleteselection;
   inserttext(editpos,str1,true);
  finally
   feditor.endgroup;
  end;
 end;
end;

function tcustomtextedit.gettext(const start,stop: gridcoordty): msestring;
var
 po1,po2: gridcoordty;
 int1: integer;
begin
 normalizetextrect(start,stop,po1,po2);
 if po1.row = po2.row then begin
  result:= copy(flines[po1.row],po1.col+1,po2.col-po1.col);
 end
 else begin
  result:= copy(flines[po1.row],po1.col+1,bigint);
  for int1:= po1.row + 1 to po2.row - 1 do begin
   result:= result + lineend + flines[int1];
  end;
  result:= result + lineend;
  if po2.row < flines.count then begin
   result:= result + copy(flines[po2.row],1,po2.col);
  end;
 end;
end;

function tcustomtextedit.hasselection: boolean;
begin
 result:= (fselectstart.row <> fselectend.row) or
            (fselectstart.col <> fselectend.col);
end;

function tcustomtextedit.selectedtext: msestring;
begin
 if hasselection then begin
  result:= gettext(fselectstart,fselectend);
 end
 else begin
  result:= '';
 end;
end;

function tcustomtextedit.find(const atext: msestring; options: searchoptionsty;
              var textpos: gridcoordty; const endpos: gridcoordty;
              selectfound: boolean = false): boolean;
var
 int1,int2: integer;
 endrow: integer;


 function checkresult: boolean;
 begin
  if (int1 > 0) and ((int2 < endrow) or 
     (int2 = endrow) and (int1 - 1 + length(atext) <= endpos.col)) then begin
   textpos.row:= int2;
   textpos.col:= int1-1;
   result:= true;
   if selectfound then begin
    setselection(textpos,makegridcoord(textpos.col + length(atext),textpos.row),true);
   end;
  end
  else begin
   result:= false;
  end;
 end;

var
 po1: prichstringty;
 pos1: gridcoordty;
 str1,str2: msestring;

begin
 result:= false;
 if flines.count > 0 then begin
  if so_caseinsensitive in options then begin
   str1:= mselowercase(atext);
   str2:= mseuppercase(atext);
  end
  else begin
   str1:= atext;
   str2:= '';
  end;
  pos1:= textpos;
  endrow:= endpos.row;
  if endrow >= flines.count then begin
   endrow:= flines.count - 1;
  end;
  po1:= flines.datapo;
  if pos1.row < 0 then begin
   pos1.row:= 0;
   pos1.col:= 1;
  end
  else begin
   if pos1.row <= endrow then begin
    inc(pos1.col);
    if pos1.col < 1 then begin
     pos1.col:= 1;
    end;
   end
   else begin
    exit;
   end;
  end;
  inc(po1,pos1.row);
  int1:= msestringsearch(str1,po1^.text,pos1.col,options,str2);
  int2:= pos1.row;
  while true do begin
   if checkresult then begin
    result:= true;
    exit;
   end;
   inc(int2);
   if int2 > endrow then begin
    exit;
   end;
   inc(po1);
   int1:= msestringsearch(str1,po1^.text,1,options,str2);
  end;
 end;
end;

function tcustomtextedit.getgridvalue(const index: integer): msestring;
begin
 result:= flines[index];
end;

procedure tcustomtextedit.setgridvalue(const index: integer;
  const Value: msestring);
begin
 flines[index]:= value;
end;

function tcustomtextedit.linecount: integer;
begin
 if flines = nil then begin
  result:= 0;
 end
 else begin
  result:= flines.count;
 end;
end;

function tcustomtextedit.getgridvalues: msestringarty;
begin
 result:= flines.asmsestringarray;
end;

procedure tcustomtextedit.setgridvalues(const Value: msestringarty);
begin
 flines.assignarray(value);
end;

function tcustomtextedit.getrichlines(const index: integer): richstringty;
begin
 result:= flines.richitems[index];
end;

procedure tcustomtextedit.setrichlines(const index: integer;
  const Value: richstringty);
begin
 flines.richitems[index]:= value;
end;

function tcustomtextedit.getrichformats(const index: integer): formatinfoarty;
begin
 result:= flines.formats[index];
end;

procedure tcustomtextedit.setrichformats(const index: integer; 
              const avalue: formatinfoarty);
begin
 flines.formats[index]:= avalue;
end;

procedure tcustomtextedit.setmodified(const Value: boolean);
begin
 if fmodified <> value then begin
  fmodified := Value;
  if canevent(tmethod(fonmodifiedchanged)) then begin
   fonmodifiedchanged(self,value);
  end;
 end;
end;

procedure tcustomtextedit.setdatalist(const Value: trichstringdatalist);
begin
 flines.assign(value);
end;

procedure tcustomtextedit.textinserted (const apos: gridcoordty;
      const atext: msestring; const selected: boolean;
      const endpos: gridcoordty; const backwards: boolean);
begin
 //dummy
end;

procedure tcustomtextedit.textdeleted(const apos: gridcoordty;
  const atext: msestring; const selected: boolean;
  const endpos: gridcoordty; const backwards: boolean);
begin
 //dummy
end;

procedure tcustomtextedit.setupeditor;
//{$ifdef FPC}
//var
// str1: msestring;
//{$endif}
var
 rect1: rectty;
begin
 if not (csloading in componentstate) then begin
  with feditor do begin
// {$ifdef FPC}     //!!!!todo fpcerror 3197
//   str1:= text;
// {$endif}
  //feditor text already set
   rect1:= innerclientrect;
   if fframe = nil then begin
    deflaterect1(rect1,texteditminimalframe);
   end;
   setup(text,curindex,false,rect1,clientrect,richtext.format,ftabulators,font);
  end;
 end;
end;

procedure tcustomtextedit.checkgrid;
begin
 if fgridintf = nil then begin
  raise exception.Create('No grid.');
 end;
end;

procedure tcustomtextedit.colchanged;
begin
 invalidate;
 if fgridintf <> nil then begin
  fgridintf.getcol.invalidate;
 end;
end;

procedure tcustomtextedit.setmarginlinecolor(const avalue: colorty);
begin
 if fmarginlinecolor <> avalue then begin
  fmarginlinecolor := avalue;
  colchanged;
 end;
end;

procedure tcustomtextedit.setmarginlinepos(const avalue: integer);
begin
 if fmarginlinepos <> avalue then begin
  fmarginlinepos := avalue;
  colchanged;
 end;
end;

procedure tcustomtextedit.createtabulators;
begin
 ftabulators:= ttabulators.create;
 ftabulators.onchange:= {$ifdef FPC}@{$endif}tabulatorschanged;
 tabulatorschanged(nil,-1);
end;

function tcustomtextedit.gettabulators: ttabulators;
begin
 getoptionalobject(ftabulators,{$ifdef FPC}@{$endif}createtabulators);
 result:= ftabulators;
end;

procedure tcustomtextedit.settabulators(const Value: ttabulators);
begin
 setoptionalobject(value,ftabulators,{$ifdef FPC}@{$endif}createtabulators);
end;

procedure tcustomtextedit.tabulatorschanged(const sender: tarrayprop;
                    const index: integer);
begin
 if not (csloading in componentstate) then begin
  colchanged;
 end;
end;

procedure tcustomtextedit.inserttext(const atext: msestring;
               selected: boolean = false);
begin
 inserttext(editpos,atext,selected);
end;

{ tundotextedit }

constructor tundotextedit.create(aowner: tcomponent);
begin
 feditor:= tundoinplaceedit.create(self,iedit(self),iundo(self),true);
 inherited;
end;

function tundotextedit.canredo: boolean;
begin
 result:= tundoinplaceedit(feditor).undolist.canredo;
end;

function tundotextedit.canundo: boolean;
begin
 result:= tundoinplaceedit(feditor).undolist.canundo;
end;

function tundotextedit.getmaxundocount: integer;
begin
 result:= tundoinplaceedit(feditor).undolist.maxcount;
end;

procedure tundotextedit.setmaxundocount(const Value: integer);
begin
 tundoinplaceedit(feditor).undolist.maxcount:= value;
end;

function tundotextedit.getmaxundosize: integer;
begin
 result:= tundoinplaceedit(feditor).undolist.maxsize;
end;

procedure tundotextedit.setmaxundosize(const Value: integer);
begin
 tundoinplaceedit(feditor).undolist.maxsize:= value;
end;

procedure tundotextedit.undo;
begin
 tundoinplaceedit(feditor).undolist.undo;
end;

procedure tundotextedit.redo;
begin
 tundoinplaceedit(feditor).undolist.redo;
end;

procedure tundotextedit.textinserted(const apos: gridcoordty; const atext: msestring;
  const selected: boolean; const endpos: gridcoordty; const backwards: boolean);
begin
 tundoinplaceedit(feditor).undolist.inserttext(apos,endpos,atext,selected,backwards);
end;

procedure tundotextedit.textdeleted(const apos: gridcoordty;
               const atext: msestring; const selected: boolean;
                   const endpos: gridcoordty; const backwards: boolean);
begin
 tundoinplaceedit(feditor).undolist.deletetext(apos,endpos,atext,selected,backwards)
end;

procedure tundotextedit.getselectstart(var selectstartpos: gridcoordty);
begin
 selectstartpos:= fselectstart;
end;

procedure tundotextedit.setselectstart(const selectstartpos: gridcoordty);
begin
 internalclearselection;
 include(fstate,tes_selectinvalid);
 fselectstart:= selectstartpos;
end;

end.
