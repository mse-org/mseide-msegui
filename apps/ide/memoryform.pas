unit memoryform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,msedock,msegrids,msestrings,
 msetypes,msedataedits,mseedit,msegraphedits,msesplitter;

type
 tmemoryfo = class(tdockform)
   grid: tstringgrid;
   tlayouter1: tlayouter;
   memon: tbooleanedit;
   bitwidth: tenumedit;
   cnt: tintegeredit;
   add: tintegeredit;
   procedure adent(const sender: TObject);
   procedure drawfixcol(const sender: tcol; const canvas: tcanvas;
                   const cellinfo: cellinfoty);
   procedure updatelayout(const sender: TObject);
   procedure formshow(const sender: TObject);
   procedure cellsetvalue(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
  private
   firstadd: ptrint;
  public
   procedure refresh;
 end;
var
 memoryfo: tmemoryfo;
implementation
uses
 memoryform_mfm,mseformatstr,msedrawtext,main,msegdbutils,msewidgets;
 
type
 bitwidthty = (bw_8,bw_16,bw_32); 
 
procedure tmemoryfo.adent(const sender: TObject);
begin
 updatelayout(nil);
end;

procedure tmemoryfo.refresh;
var
 linecount: integer;
 int1,int2,int3: integer;
 bytes: bytearty;
 words: wordarty;
 longwords: longwordarty;
begin
 if memon.value and isvisible then begin
  firstadd:= add.value and $fffffff0;
  linecount:= ((add.value + cnt.value + $f)-firstadd) div $10;
  if linecount > 1000 then begin
   linecount:= 1000;
  end;
  grid.rowcount:= linecount;
  if mainfo.gdb.cancommand then begin
   case bitwidthty(bitwidth.value) of
    bw_8: begin
     bytes:= nil;
     mainfo.gdb.readmemorybytes(add.value,cnt.value,bytes);
     int3:= -(add.value and $f);
     for int1:= 0 to linecount-1 do begin        //todo: optimize
      for int2:= 0 to 15 do begin
       if (int3 < 0) or (int3 > high(bytes)) then begin
        grid[int2][int1]:= '';
       end
       else begin
        grid[int2][int1]:= hextostr(bytes[int3],2);
       end;
       inc(int3);
      end;
     end;
    end;
    bw_16: begin
     words:= nil;
     mainfo.gdb.readmemorywords(add.value,cnt.value div 2,words);
     int3:= -(add.value and $f) div 2;
     for int1:= 0 to linecount-1 do begin        //todo: optimize
      for int2:= 0 to 7 do begin
       if (int3 < 0) or (int3 > high(words)) then begin
        grid[int2][int1]:= '';
       end
       else begin
        grid[int2][int1]:= hextostr(words[int3],4);
       end;
       inc(int3);
      end;
     end;
    end;
    bw_32: begin
     longwords:= nil;
     mainfo.gdb.readmemorylongwords(add.value,cnt.value div 4,longwords);
     int3:= -(add.value and $f) div 4;
     for int1:= 0 to linecount-1 do begin        //todo: optimize
      for int2:= 0 to 3 do begin
       if (int3 < 0) or (int3 > high(longwords)) then begin
        grid[int2][int1]:= '';
       end
       else begin
        grid[int2][int1]:= hextostr(longwords[int3],8);
       end;
       inc(int3);
      end;
     end;
    end;
   end;
  end;
  grid.invalidate;
 end
 else begin
  grid.rowcount:= 0;
 end;
end;

procedure tmemoryfo.drawfixcol(const sender: tcol; const canvas: tcanvas;
               const cellinfo: cellinfoty);
begin
 drawtext(canvas,hextostr(firstadd+cellinfo.cell.row*16,8),cellinfo.innerrect);
end;

procedure tmemoryfo.updatelayout(const sender: TObject);
var
 int1: integer;
 mstr1: msestring;
begin
 case bitwidthty(bitwidth.value) of
  bw_8: begin
   mstr1:= 'WW';
   grid.datacols.count:= 16;
   for int1:= 0 to 15 do begin
    grid.fixrows[-1].captions[int1].caption:= charhex[int1];
//    grid.datacols[int1].ondataentered:= {$ifdef FPC}@{$endif}celldataentered;
    grid.datacols[int1].onsetvalue:= {$ifdef FPC}@{$endif}cellsetvalue;
   end;
  end;
  bw_16: begin
   mstr1:= 'WWWW';
   grid.datacols.count:= 8;
   for int1:= 0 to 7 do begin
    grid.fixrows[-1].captions[int1].caption:= charhex[int1*2];
//    grid.datacols[int1].ondataentered:= {$ifdef FPC}@{$endif}celldataentered;
    grid.datacols[int1].onsetvalue:= {$ifdef FPC}@{$endif}cellsetvalue;
   end;
   add.value:= add.value and not 3;
  end;
  bw_32: begin
   mstr1:= 'WWWWWWWW';
   grid.datacols.count:= 4;
   for int1:= 0 to 3 do begin
    grid.fixrows[-1].captions[int1].caption:= charhex[int1*4];
//    grid.datacols[int1].ondataentered:= {$ifdef FPC}@{$endif}celldataentered;
    grid.datacols[int1].onsetvalue:= {$ifdef FPC}@{$endif}cellsetvalue;
   end;
   add.value:= add.value and not 7;
  end;
 end;
 int1:= getcanvas.getstringwidth(mstr1,grid.font);
 grid.datacols.width:= int1+4;
 grid.fixcols[-1].width:= getcanvas.getstringwidth('WWWWWWWW',grid.font)+4;
 refresh; 
end;

procedure tmemoryfo.formshow(const sender: TObject);
begin
 refresh;
end;

procedure tmemoryfo.cellsetvalue(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
var
 val: longword;
 str1: ansistring;
 res: gdbresultty;
begin
 if mainfo.gdb.cancommand then begin
  accept:= false;
  val:= strtohex(avalue);
  res:= gdb_error;
  case bitwidthty(bitwidth.value) of
   bw_8: begin
    res:= mainfo.gdb.writememorybyte(firstadd+grid.row*16+grid.col,val);
   end;
   bw_16: begin
    res:= mainfo.gdb.writememoryword(firstadd+grid.row*16+grid.col*2,val);
   end;
   bw_32: begin
    res:= mainfo.gdb.writememorylongword(firstadd+grid.row*16+grid.col*4,val);
   end;
  end;
  if res <> gdb_ok then begin
   str1:= mainfo.gdb.errormessage;
   showerror(str1);
  end;
  refresh;
 end;
end;

end.
