{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesyntaxedit;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 Classes,msetextedit,msesyntaxpainter,mseclasses,mseguiglob,msetypes,mseevent,
 mseeditglob,msestrings,msewidgetgrid,msedatalist;

type
 tsyntaxedit = class(tundotextedit)
  private
   fsyntaxpainter: tsyntaxpainter;
   fsyntaxpainterhandle: integer;
   fautoindent: boolean;
   flinkpos: gridcoordty;
   flinklength: integer;
   fdefaultsyntax: boolean;
   procedure setsyntaxpainter(const Value: tsyntaxpainter);
   procedure unregistersyntaxpainter;
   procedure syntaxchanged(const sender: tobject; const index: integer);
   procedure refreshsyntax(const start,count: integer);
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
   function wordatpos(const apos: gridcoordty; out word: msestring;
               const delimchars: msestring {= defaultmsedelimchars}): gridcoordty;
   procedure indent(const acount: integer);
   procedure unindent(const acount: integer);
   procedure removelink;
   procedure showlink(const apos: gridcoordty;
                       const delimchars: msestring {= defaultmsedelimchars});
  published
   property syntaxpainter: tsyntaxpainter read fsyntaxpainter write setsyntaxpainter;
   property defaultsyntax: boolean read fdefaultsyntax 
                             write setdefaultsyntax default false;
   property autoindent: boolean read fautoindent write fautoindent default false;
 end;

implementation
uses
 msegrids,mserichstring,mseinplaceedit,msegraphics,msekeyboard,msegui;

type
 tundoinplaceedit1 = class(tundoinplaceedit);
 ttextundolist1 = class(ttextundolist);

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
  fgridintf.getcol.cellchanged(index);
  if index = fgridintf.getrow then begin
   feditor.richtext:= flines.richitems[index];
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

function tsyntaxedit.wordatpos(const apos: gridcoordty; out word: msestring;
                 const delimchars: msestring {= defaultmsedelimchars}): gridcoordty;
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
    wordatindex(stringpo^,apos.col,po1,po2,delimchars);
   end
   else begin
    wordatindex(stringpo^,apos.col,po1,po2,defaultmsedelimchars);
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

procedure tsyntaxedit.indent(const acount: integer);
var
 int1,int2: integer;
 str1: msestring;
 pos1,pos2: gridcoordty;
 po1: prichstringaty;
 selstart,selend: gridcoordty;
begin
 selstart:= selectstart;
 selend:= selectend;
 normalizeselectedrows(int1,int2);
 str1:= charstring(msechar(' '),acount);
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
     if text[int3] <> ' ' then begin
      int4:= int3 - 2;
      break;
     end;
    end;
   end;
   if int4 >= 0 then begin
    pos2.col:= int4;
    richdelete(po1^[pos1.row],1,int4);
    str1:= charstring(msechar(' '),int4);
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
 if (flinkpos.row >= 0) and (flinkpos.row < datalist.count) then begin
  if updatefontstyle(datalist.getformatpo(flinkpos.row)^,flinkpos.col,
         flinklength,fs_underline,false) then begin
   fgridintf.getcol.cellchanged(flinkpos.row);
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
 pos1:= wordatpos(apos,str1,delimchars);
 length1:= length(str1);
 if (pos1.col <> flinkpos.col) or (pos1.row <> flinkpos.row) or
     (length1 <> flinklength) then begin
  removelink;
  flinkpos:= pos1;
  flinklength:= length1;
  if flinklength > 0 then begin
   if updatefontstyle(datalist.getformatpo(flinkpos.row)^,flinkpos.col,
          flinklength,fs_underline,true) then begin
    fgridintf.getcol.cellchanged(flinkpos.row);
   end;
  end;
 end;
end;

procedure tsyntaxedit.insertlinebreak;
var
 str1: msestring;
 po1: gridcoordty;
begin
 application.caret.remove;
 beginupdate;
 feditor.begingroup;
 try
  inherited;
  if fautoindent then begin
   po1:= editpos;
   if po1.row > 0 then begin
    str1:= gridvalue[po1.row-1];
    str1:= charstring(msechar(' '),countleadingchars(str1,msechar(' ')));
    if str1 <> '' then begin
     po1.col:= 0;
     inserttext(po1,str1);
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

end.
