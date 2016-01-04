{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesyntaxedit;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 classes,mclasses,msetextedit,msesyntaxpainter,mseclasses,msegraphutils,
 mseglob,mseguiglob,msetypes,mseevent,
 mseeditglob,msestrings,msewidgetgrid,msedatalist,msemenus,msegui,mseinplaceedit,
 msegrids,mseedit,msegraphics;
 
type
 bracketkindty = (bki_none,bki_round,bki_square,bki_curly);
 
const
 openbrackets: array[bracketkindty] of msechar = (#0,'(','[','{');
 closebrackets: array[bracketkindty] of msechar = (#0,')',']','}');

type
 syntaxeditoptionty = (seo_autoindent,seo_markbrackets,seo_defaultsyntax);
 syntaxeditoptionsty = set of syntaxeditoptionty;
 
 tsyntaxedit = class(tundotextedit)
  private
   fsyntaxpainter: tsyntaxpainter;
   fsyntaxpainterhandle: integer;
//   fautoindent: boolean;
   flinkpos: gridcoordty;
   flinklength: integer;
//   fdefaultsyntax: boolean;
   fsyntaxchanging: integer;
   fbracketsetting: integer;
   fbracketchecking: integer;
   fpairmarkbkgcolor: colorty;
   procedure setsyntaxpainter(const Value: tsyntaxpainter);
   procedure unregistersyntaxpainter;
   procedure syntaxchanged(const sender: tobject; const index: integer);
//   procedure setdefaultsyntax(const avalue: boolean);
   procedure checkdefaultsyntax;
   procedure readautoindent(reader: treader);
   procedure readdefaultsyntax(reader: treader);
   function getautoindent: boolean;
   procedure setautoindent(const avalue: boolean);
   function getmarkbrackets: boolean;
   procedure setmarkbrackets(const avalue: boolean);
   procedure setoptions(const avalue: syntaxeditoptionsty);
  protected
   foptions: syntaxeditoptionsty;
   fbracket1,fbracket2: gridcoordty;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure gridvaluechanged(const index: integer); override;
   procedure insertlinebreak; override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure loaded; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure defineproperties(filer: tfiler); override;
   procedure clearbrackets();
   procedure checkbrackets();
   procedure editnotification(var info: editnotificationinfoty); override;
   procedure doasyncevent(var atag: integer); override;
   procedure doafterpaint(const canvas: tcanvas); override;
   function needsfocuspaint: boolean; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure setsyntaxdef(const sourcefilename: filenamety); overload;
                      //'' for none
   procedure setsyntaxdef(const handle: integer); overload;
   procedure refreshsyntax(const start,count: integer);

   function charatpos(const apos: gridcoordty): msechar; //0 if none
   function charbeforepos(const apos: gridcoordty): msechar; //0 if none
   function wordatpos(const apos: gridcoordty; out word: msestring;
              const delimchars: msestring; 
              const nodelimstrings: array of msestring;
              const leftofcursor: boolean = false): gridcoordty; overload;
   function wordatpos(const apos: gridcoordty; out start: gridcoordty;
              const delimchars: msestring; 
              const nodelimstrings: array of msestring;
              const leftofcursor: boolean = false): msestring; overload;
   function wordatpos(const apos: gridcoordty;
              const delimchars: msestring; 
              const nodelimstrings: array of msestring;
              const leftofcursor: boolean = false): msestring; overload;
   procedure indent(const acount: integer; const atabs: boolean);
   procedure unindent(const acount: integer);
   procedure removelink;
   procedure showlink(const apos: gridcoordty;
                       const delimchars: msestring {= defaultmsedelimchars});
   procedure selectword(const apos: gridcoordty; const delimchars: msestring);
   function matchbracket(const apos: gridcoordty; const akind: bracketkindty;
                const open: boolean; maxrows: integer = 100): gridcoordty;
   property syntaxpainterhandle: integer read fsyntaxpainterhandle;
   function syntaxchanging: boolean;
   property autoindent: boolean read getautoindent write setautoindent;
   property markbrackets: boolean read getmarkbrackets write setmarkbrackets;
  published
   property syntaxpainter: tsyntaxpainter read fsyntaxpainter
                                                    write setsyntaxpainter;
//   property defaultsyntax: boolean read fdefaultsyntax 
//                             write setdefaultsyntax default false;
   property options: syntaxeditoptionsty read foptions write setoptions 
                                                                  default [];
   property pairmarkbkgcolor: colorty read fpairmarkbkgcolor 
                                 write fpairmarkbkgcolor default cl_none;
 end;

function checkbracketkind(const achar: msechar; out open: boolean): bracketkindty;

implementation
uses
 mserichstring,msekeyboard,msepointer;
const
 checkbrackettag = 84621847;
 
type
 tundoinplaceedit1 = class(tundoinplaceedit);
 ttextundolist1 = class(ttextundolist);

function checkbracketkind(const achar: msechar; out open: boolean): bracketkindty;
var
 br1: bracketkindty;
begin
 for br1:= bki_round to high(bracketkindty) do begin
  if openbrackets[br1] = achar then begin
   result:= br1;
   open:= true;
   exit;
  end;
 end;
 result:= bki_none;
 open:= false; 
 for br1:= bki_round to high(bracketkindty) do begin
  if closebrackets[br1] = achar then begin
   result:= br1;
   break;
  end;
 end;
end;

{ tsyntaxedit }

constructor tsyntaxedit.create(aowner: tcomponent);
begin
 fsyntaxpainterhandle:= -1;
 flinkpos:= invalidcell;
 fbracket1:= invalidcell;
 fbracket2:= invalidcell;
 fpairmarkbkgcolor:= cl_none;
 inherited;
end;

destructor tsyntaxedit.destroy;
begin
 unregistersyntaxpainter;
 inherited;
end;

procedure tsyntaxedit.objectevent(const sender: tobject;
  const event: objecteventty);
var
 int1,int2: integer;
 po1: prichstringty;
begin
 inherited;
 if sender = fsyntaxpainter then begin
  if event in [oe_destroyed,oe_disconnect] then begin
   fsyntaxpainterhandle:= -1;
   if flines <> nil then begin
    with flines do begin
     int2:= size;
     po1:= datapo;
     for int1:= count-1 downto 0 do begin
      po1^.format:= nil;
      inc(pchar(po1),int2);
     end;
    end;
   end;
   feditor.format:= nil;
   if fgridintf <> nil then begin
    fgridintf.changed;
   end;
//   fsyntaxpainter:= nil;
  end;
 end;
end;

procedure tsyntaxedit.unregistersyntaxpainter;
begin
 if (fsyntaxpainter <> nil) and (fsyntaxpainterhandle >= 0) then begin
  fsyntaxpainter.unregisterclient(fsyntaxpainterhandle);
 end;
 fsyntaxpainterhandle:= -1;
end;

procedure tsyntaxedit.checkdefaultsyntax;
begin
 if (seo_defaultsyntax in foptions) and not (csloading in componentstate) and 
       (fsyntaxpainter <> nil) and (flines <> nil) and 
            (fsyntaxpainterhandle < 0) then begin
  setsyntaxdef(fsyntaxpainter.defaultsyntax);
 end;
end;

procedure tsyntaxedit.setsyntaxpainter(const Value: tsyntaxpainter);
begin
 if value <> fsyntaxpainter then begin
  if fsyntaxpainter <> nil then begin
   unregistersyntaxpainter;
  end;
  setlinkedvar(value,tmsecomponent(fsyntaxpainter));
  checkdefaultsyntax;
 end;
end;
{
procedure tsyntaxedit.setdefaultsyntax(const avalue: boolean);
begin
 fdefaultsyntax:= avalue;
 checkdefaultsyntax;
end;
}
procedure tsyntaxedit.setsyntaxdef(const sourcefilename: filenamety);
begin
 if fsyntaxpainter <> nil then begin
  if sourcefilename = '' then begin
   unregistersyntaxpainter;
  end
  else begin
   setsyntaxdef(fsyntaxpainter.linkdeffile(sourcefilename));
  end;
 end;
end;

procedure tsyntaxedit.setsyntaxdef(const handle: integer);
begin
 if fsyntaxpainter <> nil then begin
  unregistersyntaxpainter;
  if handle >= 0 then begin
   fsyntaxpainterhandle:= fsyntaxpainter.registerclient(self,flines,
           {$ifdef FPC}@{$endif}syntaxchanged,handle);
   refreshsyntax(0,bigint);
  end;
 end;
end;

procedure tsyntaxedit.syntaxchanged(const sender: tobject;
  const index: integer);
begin
 if fgridintf <> nil then begin
  inc(fsyntaxchanging);
  try
   fgridintf.getcol.cellchanged(index);
   if index = fgridintf.getrow then begin
    feditor.richtext:= flines.richitems[index];
   end;
  finally
   dec(fsyntaxchanging);
  end;
 end;
end;

procedure tsyntaxedit.refreshsyntax(const start, count: integer);
begin
 if fsyntaxpainterhandle >= 0 then begin
  fsyntaxpainter.paintsyntax(fsyntaxpainterhandle,start,bigint,true);
//  fsyntaxpainter.paintsyntax(fsyntaxpainterhandle,start,bigint,false);
 end;
end;

procedure tsyntaxedit.gridvaluechanged(const index: integer);
begin
 inherited;
 if index >= 0 then begin
  refreshsyntax(index,1);
 end
 else begin
  refreshsyntax(0,bigint);
 end;
end;

function tsyntaxedit.charatpos(const apos: gridcoordty): msechar;
var
 stringpo: pmsestring;
begin
 result:= #0; 
 if (apos.col >= 0) and (apos.row >= 0) and (apos.row < flines.count) then begin
  stringpo:= pmsestring(flines.getitempo(apos.row));
  if apos.col < length(stringpo^) then begin
   result:= stringpo^[apos.col+1];
  end;
 end;
end;

function tsyntaxedit.charbeforepos(const apos: gridcoordty): msechar;
var
 stringpo: pmsestring;
begin
 if apos.col = 0 then begin
  result:= charbeforepos(makegridcoord(bigint,apos.row-1));
 end
 else begin
  result:= #0; 
  if (apos.row >= 0) and (apos.row < flines.count) and (apos.col >= 0) then begin
   stringpo:= pmsestring(flines.getitempo(apos.row));
   if stringpo^ <> '' then begin
    if apos.col >= length(stringpo^) then begin
     result:= stringpo^[length(stringpo^)];
    end
    else begin
     result:= stringpo^[apos.col];
    end;
   end;
  end;
 end;
end;

function tsyntaxedit.wordatpos(const apos: gridcoordty; out word: msestring;
                 const delimchars: msestring;
                 const nodelimstrings:  array of msestring;
                 const leftofcursor: boolean = false): gridcoordty;
     //returns startpos
var
 po1,po2: pmsechar;
 stringpo: pmsestring;
 gc1: gridcoordty;
begin
 po2:= nil;
 word:= '';
 if (apos.row < 0) or (apos.row >= flines.count) then begin
  result:= invalidcell;
 end
 else begin
  result.row:= apos.row;
  stringpo:= pmsestring(flines.getitempo(apos.row));
  if stringpo^ <> '' then begin
   if delimchars <> '' then begin
    wordatindex(stringpo^,apos.col,po1,po2,delimchars,nodelimstrings);
   end
   else begin
    wordatindex(stringpo^,apos.col,po1,po2,defaultmsedelimchars,nodelimstrings);
   end;
   if po1 = po2 then begin
    po1:= nil;
   end;
  end
  else begin
   po1:= nil;
  end;
  if po1 = nil then begin
   result.col:= -1;
  end
  else begin
   result.col:= po1 - pmsechar(stringpo^);
   word:= copy(msestring(po1),1,po2-po1);
  end;
 end;
 if (word = '') and leftofcursor and (apos.col > 0) then begin
  gc1:= apos;
  dec(gc1.col);
  result:= wordatpos(gc1,word,delimchars,nodelimstrings);
 end;
end;

function tsyntaxedit.wordatpos(const apos: gridcoordty; out start: gridcoordty;
              const delimchars: msestring; 
              const nodelimstrings: array of msestring;
              const leftofcursor: boolean = false): msestring;
begin
 start:= wordatpos(apos,result,delimchars,nodelimstrings,leftofcursor);
end;

function tsyntaxedit.wordatpos(const apos: gridcoordty;
               const delimchars: msestring;
               const nodelimstrings: array of msestring;
               const leftofcursor: boolean = false): msestring;
begin
 wordatpos(apos,result,delimchars,nodelimstrings,leftofcursor);
end;


procedure tsyntaxedit.indent(const acount: integer; const atabs: boolean);
var
 int1,int2: integer;
 str1: msestring;
 pos1,pos2: gridcoordty;
 po1: prichstringaty;
 selstart,selend: gridcoordty;
 ch1: msechar;
begin
 selstart:= selectstart;
 selend:= selectend;
 normalizeselectedrows(int1,int2);
 ch1:= ' ';
 if atabs then begin
  ch1:= c_tab;
 end;
 str1:= charstring(ch1,acount);
 pos1:= makegridcoord(0,int1);
 pos2:= makegridcoord(acount,int1);
 po1:= datalist.datapo;
 beginupdate;
 feditor.begingroup;
 try
  clearselection;
  while (pos1.row <= int2) do begin
   richinsert(str1,po1^[pos1.row],1);
   tundoinplaceedit1(feditor).fundolist.setpos(pos1,false);
   tundoinplaceedit1(feditor).fundolist.inserttext(pos1,pos2,str1,false,false);
//   inserttext(pos1,str1);
   inc(pos1.row);
   pos2.row:= pos1.row;
  end;
  setselection(selstart,selend,true);
 finally
  feditor.endgroup;
  endupdate;
 end;
end;

procedure tsyntaxedit.unindent(const acount: integer);
var
 int1,int2,int3,int4: integer;
 pos1,pos2: gridcoordty;
 selstart,selend: gridcoordty;
 str1: msestring;
 po1: prichstringaty;

begin
 selstart:= selectstart;
 selend:= selectend;
 normalizeselectedrows(int1,int2);
 pos1:= makegridcoord(0,int1);
 pos2.row:= int1;
 po1:= datalist.datapo;
 beginupdate;
 feditor.begingroup;
 try
  clearselection;
  for int1:= int1 to int2 do begin
   with po1^[pos1.row] do begin
    if length(text) < acount then begin
     int4:= length(text);
    end
    else begin
     int4:= acount;
    end;
    for int3:= 1 to int4 do begin
     if (text[int3] <> ' ') and (text[int3] <> c_tab) then begin
      int4:= int3 - 2;
      break;
     end;
    end;
   end;
   if int4 >= 0 then begin
    pos2.col:= int4;
    str1:= copy(po1^[pos1.row].text,1,int4);
    richdelete(po1^[pos1.row],1,int4);
//    str1:= charstring(msechar(' '),int4);
    tundoinplaceedit1(feditor).fundolist.setpos(pos2,false);
    tundoinplaceedit1(feditor).fundolist.deletetext(pos2,pos1,str1,false,true);
//    deletetext(pos1,pos2);
   end;
   inc(pos1.row);
   inc(pos2.row);
  end;
  setselection(selstart,selend,true);
 finally
  feditor.endgroup;
  endupdate;
 end;
end;

procedure tsyntaxedit.removelink;
begin
 if (flinkpos.row >= 0) then begin
  application.cursorshape:= cr_default;
  if (flinkpos.row < datalist.count) then begin
   if updatefontstyle1(datalist.getformatpo(flinkpos.row)^,flinkpos.col,
          flinklength,fs_underline,false) then begin
    with fgridintf.getcol do begin
     cellchanged(flinkpos.row);
     if grid.row = flinkpos.row then begin
      self.gridtovalue(flinkpos.row);
     end;
    end;
   end;
  end;
  flinkpos.row:= invalidaxis;
 end;
end;

procedure tsyntaxedit.showlink(const apos: gridcoordty;
                    const delimchars: msestring {= defaultmsedelimchars});
var
 str1: msestring;
 pos1: gridcoordty;
 length1: integer;
begin
 pos1:= wordatpos(apos,str1,delimchars,[]);
 length1:= length(str1);
 if (pos1.col <> flinkpos.col) or (pos1.row <> flinkpos.row) or
     (length1 <> flinklength) then begin
  removelink;
  flinkpos:= pos1;
  flinklength:= length1;
  if flinklength > 0 then begin
   application.cursorshape:= cr_pointinghand;
   if updatefontstyle1(datalist.getformatpo(flinkpos.row)^,flinkpos.col,
          flinklength,fs_underline,true) then begin
    with fgridintf.getcol do begin
     cellchanged(flinkpos.row);
     if grid.row = flinkpos.row then begin
      self.gridtovalue(flinkpos.row);
     end;
    end;
   end;
  end;
 end;
end;

procedure tsyntaxedit.selectword(const apos: gridcoordty;
                                            const delimchars: msestring);
var
 str1: msestring;
 pos1: gridcoordty;
begin
 pos1:= wordatpos(apos,str1,delimchars,[]);
 if str1 <> '' then begin
  setselection(pos1,makegridcoord(pos1.col+length(str1),pos1.row),true);
 end;
end;

function tsyntaxedit.matchbracket(const apos: gridcoordty;
                  const akind: bracketkindty;
                 const open: boolean; maxrows: integer = 100): gridcoordty;
                 
var
 level: integer;
 strpo: pmsestring;
 x,y: integer;
 po1: pmsecharaty;
 int1: integer;
 openchar,closechar,mch1: msechar;
begin
 result:= invalidcell;
 level:= 0;
 x:= apos.col;
 y:= apos.row;
 openchar:= openbrackets[akind];
 closechar:= closebrackets[akind];
 if open then begin
  while (maxrows > 0) and (y < flines.count) do begin
   strpo:= pmsestring(flines.getitempo(y));
   po1:= pmsecharaty(strpo^);
   for int1:= x to length(strpo^)-1 do begin
    mch1:= po1^[int1];
    if mch1 = openchar then begin
     inc(level);
    end;
    if mch1 = closechar then begin
     dec(level);
     if level <= 0 then begin
      result.row:= y;
      result.col:= int1;
      exit;
     end;
    end;
   end;
   x:= 0;
   dec(maxrows);
   inc(y);
  end; 
 end
 else begin
  strpo:= pmsestring(flines.getitempo(y));
  while (maxrows > 0) do begin
   po1:= pmsecharaty(strpo^);
   for int1:= x downto 0 do begin
    mch1:= po1^[int1];
    if mch1 = closechar then begin
     inc(level);
    end;
    if mch1 = openchar then begin
     dec(level);
     if level <= 0 then begin
      result.row:= y;
      result.col:= int1;
      exit;
     end;
    end;
   end;
   dec(maxrows);
   dec(y);
   if y < 0 then begin
    break;
   end;
   strpo:= pmsestring(flines.getitempo(y));
   x:= length(strpo^)-1;
  end; 
 end;
end;

const
 noboldchars: markinfoty = (backgroundcolor: cl_none; items: nil);
 
procedure tsyntaxedit.clearbrackets();
begin
 if (fbracket1.col >= 0) and (fbracketsetting = 0) then begin
  inc(fbracketsetting);
  try
   setfontstyle(fbracket1,makegridcoord(fbracket1.col+1,fbracket1.row),
                                  fs_bold,false,cl_transparent);
   setfontstyle(fbracket2,makegridcoord(fbracket2.col+1,fbracket2.row),
                                  fs_bold,false,cl_transparent);
   refreshsyntax(fbracket1.row,1);
   refreshsyntax(fbracket2.row,1);
   fbracket1:= invalidcell;
   fbracket2:= invalidcell;
   if syntaxpainterhandle >= 0 then begin
    syntaxpainter.boldchars[syntaxpainterhandle]:= noboldchars;
   end;
  finally
   dec(fbracketsetting);
  end;
 end;  
end;

procedure tsyntaxedit.checkbrackets();
var
 mch1: msechar;
 br1,br2: bracketkindty;
 open,open2: boolean;
 pt1,pt2: gridcoordty;
 ar1: gridcoordarty;
 boldinfo1: markinfoty;
begin
 clearbrackets;
 pt2:= invalidcell;
 pt1:= editpos;
 mch1:= charatpos(pt1);
 br1:= checkbracketkind(mch1,open);
 if (br1 <> bki_none) and (pt1.col > 0) then begin
  dec(pt1.col);
  br2:= checkbracketkind(charatpos(pt1),open2);
  if (br2 = bki_none) or (open <> open2) then begin
   inc(pt1.col);
  end
  else begin
   br1:= br2;
  end;
  pt2:= matchbracket(pt1,br1,open);
 end
 else begin
  dec(pt1.col);
  if pt1.col >= 0 then begin
   mch1:= charatpos(pt1);
   br1:= checkbracketkind(mch1,open);
   if br1 <> bki_none then begin
    pt2:= matchbracket(pt1,br1,open);
   end;
  end;
 end;
 if pt2.col >= 0 then begin
  fbracket1:= pt1;
  fbracket2:= pt2;
  boldinfo1.backgroundcolor:= fpairmarkbkgcolor;
  if syntaxpainterhandle >= 0 then begin
   setlength(ar1,2);
   ar1[0]:= fbracket1;
   ar1[1]:= fbracket2;
   boldinfo1.backgroundcolor:= 
            syntaxpainter.colors[syntaxpainterhandle].pairmarkbackground;
   if boldinfo1.backgroundcolor = cl_default then begin
    boldinfo1.backgroundcolor:= fpairmarkbkgcolor;
   end;
   boldinfo1.items:= ar1;
   syntaxpainter.boldchars[syntaxpainterhandle]:= boldinfo1;
   refreshsyntax(fbracket1.row,1);
   refreshsyntax(fbracket2.row,1);
  end;
  inc(fbracketsetting);
  try
   if boldinfo1.backgroundcolor = cl_none then begin
    boldinfo1.backgroundcolor:= cl_transparent;
   end;
   setfontstyle(pt1,makegridcoord(pt1.col+1,pt1.row),fs_bold,true,
                                             boldinfo1.backgroundcolor);
   setfontstyle(pt2,makegridcoord(pt2.col+1,pt2.row),fs_bold,true,
                                             boldinfo1.backgroundcolor);
  finally
   dec(fbracketsetting);
  end;
 end;
end;
 
procedure tsyntaxedit.insertlinebreak;
var
 mstr1: msestring;
 po1: gridcoordty;
 po2: pmsechar;
begin
 application.caret.remove;
 beginupdate;
 feditor.begingroup;
 try
  inherited;
  if seo_autoindent in foptions then begin
   po1:= editpos;
   if po1.row > 0 then begin
    mstr1:= gridvalue[po1.row-1];
    po2:= pmsechar(mstr1);
    while (po2^ = ' ') or  (po2^ = c_tab) do begin
     inc(po2);
    end;
    setlength(mstr1,po2-pmsechar(mstr1));
//    mstr1:= charstring(msechar(' '),countleadingchars(mstr1,msechar(' ')));
    if mstr1 <> '' then begin
     po1.col:= 0;
     inserttext(po1,mstr1);
    end;
   end;
  end;
 finally
  application.caret.restore;
  feditor.endgroup;
  endupdate;
 end;
end;

const
 stopchars = [' ',c_tab,'=',':',';',',','.','''','-','+','/','*','^',
              '[',']','(',')','{','}'];
 
procedure tsyntaxedit.dokeydown(var info: keyeventinfoty);

 function isstopchar(const avalue: msechar): boolean;
 begin
  result:= (word(avalue) < $100) and (char(byte(avalue)) in stopchars)
 end;
 
var
 int1,int2: integer;
 co1: gridcoordty;
 shiftstate1: shiftstatesty;
begin
 with info do begin
  shiftstate1:= shiftstate * shiftstatesmask;
  if (shiftstate1 = [ss_ctrl]) or (shiftstate1 = [ss_ctrl,ss_shift]) then begin
   case key of
    key_left: begin
     repeat //skip stopchars
      int2:= 0;
      for int1:= feditor.curindex downto 1 do begin
       if not isstopchar(feditor.text[int1]) then begin
        int2:= int1;
        break;
       end;
      end;
      if int2 = 0 then begin
       if editpos.row > 0 then begin
        co1.row:= editpos.row - 1;
        co1.col:= bigint;
        seteditpos(co1,ss_shift in shiftstate1);
       end
       else begin
        break;
       end;
      end;
     until (int2 > 0);
     co1.row:= editpos.row;
     co1.col:= int2;
     seteditpos(co1,ss_shift in shiftstate1);
     int2:= 0; //skip normal chars
     for int1:= feditor.curindex downto 1 do begin
      if isstopchar(feditor.text[int1]) then begin
       int2:= int1;
       break;
      end;
     end;
     co1.row:= editpos.row;
     co1.col:= int2;
     seteditpos(co1,ss_shift in shiftstate1);
     include(eventstate,es_processed);
    end;
    key_right: begin
     repeat //skip stopchars
      int2:= bigint;
      for int1:= feditor.curindex + 1 to length(feditor.text) do begin
       if not isstopchar(feditor.text[int1]) then begin
        int2:= int1;
        break;
       end;
      end;
      if int2 = bigint then begin
       if editpos.row < linecount - 1 then begin
        co1.row:= editpos.row + 1;
        co1.col:= 0;
        seteditpos(co1,ss_shift in shiftstate1);
       end
       else begin
        break;
       end;
      end;
     until (int2 < bigint);
     co1.row:= editpos.row;
     co1.col:= int2;
     seteditpos(co1,ss_shift in shiftstate1);
     int2:= bigint; //skip normal chars
     for int1:= feditor.curindex + 1 to length(feditor.text) do begin
      if isstopchar(feditor.text[int1]) then begin
       int2:= int1;
       break;
      end;
     end;
     co1.row:= editpos.row;
     co1.col:= int2-1;
     seteditpos(co1,ss_shift in shiftstate1);
     include(eventstate,es_processed);
    end;
(*
    key_left: begin
     repeat
      int2:= 0;
      for int1:= feditor.curindex downto 1 do begin
       if isstopchar(feditor.text[int1]) then begin
        int2:= int1;
        break;
       end;
      end;
      if int2 = 0 then begin
       if editpos.row > 0 then begin
        co1.row:= editpos.row - 1;
        co1.col:= bigint;
        seteditpos(co1,ss_shift in shiftstate1);
        if (length(feditor.text) > 0) and 
           not isstopchar(feditor.text[length(feditor.text)]) then begin
         int2:= length(feditor.text);
        end;
       end;
      end;
     until (int2 > 0) or (editpos.row <= 0);
     co1.row:= editpos.row;
     co1.col:= int2;
     seteditpos(co1,ss_shift in shiftstate1);
     repeat
      int2:= 0;
      for int1:= feditor.curindex downto 1 do begin
       if not isstopchar(feditor.text[int1]) then begin
        int2:= int1;
        break;
       end;
      end;
      if int2 = 0 then begin
       if editpos.row > 0 then begin
        co1.row:= editpos.row - 1;
        co1.col:= bigint;
        seteditpos(co1,ss_shift in shiftstate1);
       end;
      end;
     until (int2 > 0) or (editpos.row <= 0);
     if int2 > 0 then begin
      co1.row:= editpos.row;
      co1.col:= int2;
      seteditpos(co1,ss_shift in shiftstate1);
     end;
     include(eventstate,es_processed);
    end;
    key_right: begin
     repeat
      int2:= bigint;
      for int1:= feditor.curindex + 1 to length(feditor.text) do begin
       if isstopchar(feditor.text[int1]) then begin
        int2:= int1;
        break;
       end;
      end;
      if int2 = bigint then begin
       if editpos.row < linecount - 1 then begin
        co1.row:= editpos.row + 1;
        co1.col:= 0;
        seteditpos(co1,ss_shift in shiftstate1);
        if (length(feditor.text) > 0) and 
                    not isstopchar(feditor.text[1]) then begin
         int2:= 0;
        end;
       end;
      end;
     until (int2 < bigint) or (editpos.row >= linecount - 1);
     co1.row:= editpos.row;
     co1.col:= int2;
     seteditpos(co1,ss_shift in shiftstate1);
     repeat
      int2:= bigint;
      for int1:= feditor.curindex + 1 to length(feditor.text) do begin
       if not isstopchar(feditor.text[int1]) then begin
        int2:= int1;
        break;
       end;
      end;
      if int2 = bigint then begin
       if editpos.row < linecount - 1 then begin
        co1.row:= editpos.row + 1;
        co1.col:= 0;
        seteditpos(co1,ss_shift in shiftstate1);
       end;
      end;
     until (int2 < bigint) or (editpos.row >= linecount - 1);
     if int2 < bigint then begin
      co1.row:= editpos.row;
      co1.col:= int2-1;
      seteditpos(co1,ss_shift in shiftstate1);
     end;
     include(eventstate,es_processed);
    end;
*)
   end;
  end;
  if not (es_processed in eventstate) then begin
   inherited;
  end;
 end;
end;

procedure tsyntaxedit.loaded;
begin
 inherited;
 checkdefaultsyntax;
end;

function tsyntaxedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= inherited createdatalist(sender);
 checkdefaultsyntax;
end;

function tsyntaxedit.syntaxchanging: boolean;
begin
 result:= fsyntaxchanging <> 0;
end;

procedure tsyntaxedit.readautoindent(reader: treader);
begin
 if reader.readboolean then begin
  include(foptions,seo_autoindent);
 end;
end;

procedure tsyntaxedit.readdefaultsyntax(reader: treader);
begin
 if reader.readboolean then begin
  include(foptions,seo_defaultsyntax);
 end;
end;

procedure tsyntaxedit.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('autoindent',@readautoindent,nil,false);
 filer.defineproperty('defaultsyntax',@readdefaultsyntax,nil,false);
end;

procedure tsyntaxedit.editnotification(var info: editnotificationinfoty);
begin
 inherited;
 if (info.action = ea_beforechange) and not syntaxchanging then begin
  clearbrackets;
 end
 else begin
  if (seo_markbrackets in options) and
      (info.action in [ea_indexmoved,ea_delchar,ea_deleteselection,
                              ea_pasteselection,ea_textentered]) then begin
   if (fbracketchecking = 0) then begin
    inc(fbracketchecking);
    asyncevent(checkbrackettag);
   end;
  end;
 end; 
end;

procedure tsyntaxedit.doasyncevent(var atag: integer);
begin
 inherited;
 if atag = checkbrackettag then begin
  fbracketchecking:= 0;
  checkbrackets();
 end;
end;

procedure tsyntaxedit.doafterpaint(const canvas: tcanvas);
begin
 inherited;
 if (fgridintf <> nil) and not (csdesigning in componentstate) then begin
  fgridintf.widgetpainted(canvas);
 end;
end;

function tsyntaxedit.needsfocuspaint: boolean;
begin
 result:= (fgridintf = nil) and inherited needsfocuspaint;
end;

function tsyntaxedit.getautoindent: boolean;
begin
 result:= seo_autoindent in options;
end;

procedure tsyntaxedit.setautoindent(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [seo_autoindent];
 end
 else begin
  options:= options - [seo_autoindent];
 end;
end;

function tsyntaxedit.getmarkbrackets: boolean;
begin
 result:= seo_markbrackets in options;
end;

procedure tsyntaxedit.setmarkbrackets(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [seo_markbrackets];
 end
 else begin
  options:= options - [seo_markbrackets];
 end;
end;

procedure tsyntaxedit.setoptions(const avalue: syntaxeditoptionsty);
var
 delta: syntaxeditoptionsty;
begin
 delta:= foptions >< avalue;
 if delta <> [] then begin
  foptions:= avalue;
  if seo_defaultsyntax in delta then begin
   checkdefaultsyntax;
  end;
 end;
end;

end.
