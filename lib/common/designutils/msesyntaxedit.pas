{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

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
 Classes,msetextedit,msesyntaxpainter,mseclasses,
 mseglob,mseguiglob,msetypes,mseevent,
 mseeditglob,msestrings,msewidgetgrid,msedatalist,msemenus,msegui,mseinplaceedit,
 msegrids;
 
type
 bracketkindty = (bki_none,bki_round,bki_square,bki_curly);
 
const
 openbrackets: array[bracketkindty] of msechar = (#0,'(','[','{');
 closebrackets: array[bracketkindty] of msechar = (#0,')',']','}');

type
 tsyntaxedit = class(tundotextedit)
  private
   fsyntaxpainter: tsyntaxpainter;
   fsyntaxpainterhandle: integer;
   fautoindent: boolean;
   flinkpos: gridcoordty;
   flinklength: integer;
   fdefaultsyntax: boolean;
   fsyntaxchanging: integer;
   procedure setsyntaxpainter(const Value: tsyntaxpainter);
   procedure unregistersyntaxpainter;
   procedure syntaxchanged(const sender: tobject; const index: integer);
   procedure setdefaultsyntax(const avalue: boolean);
   procedure checkdefaultsyntax;
  protected
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   procedure gridvaluechanged(const index: integer); override;
   procedure insertlinebreak; override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure loaded; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure setsyntaxdef(const sourcefilename: filenamety); overload; //'' for none
   procedure setsyntaxdef(const handle: integer); overload;
   procedure refreshsyntax(const start,count: integer);

   function charatpos(const apos: gridcoordty): msechar; //0 if none
   function charbeforepos(const apos: gridcoordty): msechar; //0 if none
   function wordatpos(const apos: gridcoordty; out word: msestring;
                             const delimchars: msestring; 
                             const nodelimstrings: array of msestring): gridcoordty;
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
  published
   property syntaxpainter: tsyntaxpainter read fsyntaxpainter write setsyntaxpainter;
   property defaultsyntax: boolean read fdefaultsyntax 
                             write setdefaultsyntax default false;
   property autoindent: boolean read fautoindent write fautoindent default false;
 end;

function checkbracketkind(const achar: msechar; out open: boolean): bracketkindty;

implementation
uses
 mserichstring,msegraphics,msekeyboard,msegraphutils,msepointer;

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
 inherited;
end;

destructor tsyntaxedit.destroy;
begin
 unregistersyntaxpainter;
 inherited;
end;

procedure tsyntaxedit.objectevent(const sender: tobject;
  const event: objecteventty);
begin
 inherited;
 if sender = fsyntaxpainter then begin
  if event = oe_destroyed then begin
   fsyntaxpainterhandle:= -1;
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
 if fdefaultsyntax and not (csloading in componentstate) and 
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

procedure tsyntaxedit.setdefaultsyntax(const avalue: boolean);
begin
 fdefaultsyntax:= avalue;
 checkdefaultsyntax;
end;

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
                 const nodelimstrings:  array of msestring): gridcoordty;
     //returns startpos
var
 po1,po2: pmsechar;
 stringpo: pmsestring;

begin
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
   if updatefontstyle(datalist.getformatpo(flinkpos.row)^,flinkpos.col,
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
   if updatefontstyle(datalist.getformatpo(flinkpos.row)^,flinkpos.col,
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
  if fautoindent then begin
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
  result:= (avalue < #$100) and (char(avalue) in stopchars)
 end;
 
var
 int1,int2: integer;
 co1: gridcoordty;
begin
 with info do begin
  if (shiftstate = [ss_ctrl]) or (shiftstate = [ss_ctrl,ss_shift]) then begin
   case key of
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
        seteditpos(co1,ss_shift in shiftstate);
        if (length(feditor.text) > 0) and 
           not isstopchar(feditor.text[length(feditor.text)]) then begin
         int2:= length(feditor.text);
        end;
       end;
      end;
     until (int2 > 0) or (editpos.row <= 0);
     co1.row:= editpos.row;
     co1.col:= int2;
     seteditpos(co1,ss_shift in shiftstate);
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
        seteditpos(co1,ss_shift in shiftstate);
       end;
      end;
     until (int2 > 0) or (editpos.row <= 0);
     if int2 > 0 then begin
      co1.row:= editpos.row;
      co1.col:= int2;
      seteditpos(co1,ss_shift in shiftstate);
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
        seteditpos(co1,ss_shift in shiftstate);
        if (length(feditor.text) > 0) and 
                    not isstopchar(feditor.text[1]) then begin
         int2:= 0;
        end;
       end;
      end;
     until (int2 < bigint) or (editpos.row >= linecount - 1);
     co1.row:= editpos.row;
     co1.col:= int2;
     seteditpos(co1,ss_shift in shiftstate);
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
        seteditpos(co1,ss_shift in shiftstate);
       end;
      end;
     until (int2 < bigint) or (editpos.row >= linecount - 1);
     if int2 < bigint then begin
      co1.row:= editpos.row;
      co1.col:= int2-1;
      seteditpos(co1,ss_shift in shiftstate);
     end;
     include(eventstate,es_processed);
    end;
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

end.
