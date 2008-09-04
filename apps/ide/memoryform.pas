unit memoryform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,msedock,msegrids,msestrings,
 msetypes,msedataedits,mseedit,msegraphedits;

type
 tmemoryfo = class(tdockform)
   grid: tstringgrid;
   add: tintegeredit;
   cnt: tintegeredit;
   memon: tbooleanedit;
   procedure adent(const sender: TObject);
   procedure drawfixcol(const sender: tcol; const canvas: tcanvas;
                   const cellinfo: cellinfoty);
  private
   firstadd: ptrint;
  public
   procedure refresh;
 end;
var
 memoryfo: tmemoryfo;
implementation
uses
 memoryform_mfm,mseformatstr,msedrawtext,main;
 
procedure tmemoryfo.adent(const sender: TObject);
begin
 refresh;
end;

procedure tmemoryfo.refresh;
var
 linecount: integer;
 int1,int2,int3: integer;
 bytes: bytearty;
begin
 if memon.value then begin
  firstadd:= add.value and $fffffff0;
  linecount:= ((add.value + cnt.value + $f)-firstadd) div $10;
  if linecount > 1000 then begin
   linecount:= 1000;
  end;
  grid.rowcount:= linecount;
  if mainfo.gdb.cancommand then begin
   bytes:= nil;
   mainfo.gdb.readmemorybytes(add.value,cnt.value,bytes);
   int3:= -(firstadd and $f);
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

end.
