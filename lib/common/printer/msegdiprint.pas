unit msegdiprint;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseprinter,msegraphics,msegraphutils,msetypes,msestrings,msedrawtext;
type
 tgdiprintcanvas = class(tprintercanvas)
  protected
   procedure beginpage; override;
   procedure endpage; override;
   procedure checkgcstate(state: canvasstatesty); override;
  public
   constructor create(const user: tcustomprinter; const intf: icanvas);
   procedure drawtext(var info: drawtextinfoty); override;  
 end;
 
 tgdiprinter = class(tprinter,icanvas)
  private
   fppinchx: integer;
   fppinchy: integer;
  protected
   //icanvas
   procedure gcneeded(const sender: tcanvas);
   function getmonochrome: boolean;
  public
   constructor create(aowner: tcomponent); override;
   procedure beginprint;
   procedure endprint; override;
 end;
 
implementation
uses
 {$ifdef mswindows}windows,{$endif}mseguiintf,mseguiglob,msesys;
 
{$ifdef mswindows}
procedure checkprinterror(const aresult: integer; const atext: string = '');
begin
 if aresult <= 0 then begin
  syserror(syelasterror,atext);
 end;
end;
{$endif}

{ tgdiprinter }

constructor tgdiprinter.create(aowner: tcomponent);
begin
 fcanvas:= tgdiprintcanvas.create(self,icanvas(self));
 inherited;
end;

function tgdiprinter.getmonochrome: boolean;
begin
 result:= false;
end;

{$ifdef mswindows}
{$ifdef FPC}
type
     DOCINFOW = record
          cbSize : longint;
          lpszDocName : LPCWSTR;
          lpszOutput : LPCWSTR;
          lpszDatatype : LPCWSTR;
          fwType : DWORD;
       end;
     TDOCINFOW = DOCINFOW;
     PDOCINFOW = ^DOCINFOW;
{$endif}
    
function sysw_startdoc(const dc: hdc; const docname: msestring): integer;
var
 info: tdocinfow;
begin
 fillchar(info,sizeof(info),0);
 info.cbsize:= sizeof(info);
 info.lpszdocname:= pwidechar(docname);
 {$ifdef FPC}
 result:= startdocw(dc,@info);
 {$else}
 result:= startdocw(dc,info);
 {$endif}
end;

procedure tgdiprinter.gcneeded(const sender: tcanvas);
var
 gc1: gcty;
 mat1: txform;
begin
 if not (sender is tgdiprintcanvas) then begin
  guierror(gue_invalidcanvas);
 end;
 with tgdiprintcanvas(sender) do begin
  fillchar(gc1,sizeof(gc1),0);
  guierror(gui_creategc(0,gck_printer,gc1,
                               'HP LaserJet 6P/6MP - Standard'));
  checkprinterror(setgraphicsmode(gc1.handle,gm_advanced));
  fppinchx:= getdevicecaps(gc1.handle,logpixelsx);
  fppinchy:= getdevicecaps(gc1.handle,logpixelsy);
  linktopaintdevice(ptrint(self),gc1,getwindowsize,nullpoint);
 end;
end;

procedure tgdiprinter.beginprint;
begin
 checkprinterror(sysw_startdoc(fcanvas.gchandle,fcanvas.title),
          'Can not start print job for "'+fcanvas.title+'".');
end;

{$else}
procedure tgdiprinter.beginprint;
begin
end;

procedure tgdiprinter.gcneeded(const sender: tcanvas);
begin
 raise exception.create('gdi printer not supported.');
end;
{$endif}

procedure tgdiprinter.endprint;
begin
 with tgdiprintcanvas(fcanvas) do begin
  if fdrawinfo.gc.handle <> 0 then begin
  {$ifdef mswindows}
   endpage;
   enddoc(gchandle);
  {$endif}
   try
    unlink;
   except
   end;
  end;
 end;
 inherited;
end;

{ tgdiprintcanvas }

constructor tgdiprintcanvas.create(const user: tcustomprinter;
               const intf: icanvas);
begin
 inherited;
 exclude(fstate,cs_internaldrawtext);
end;

procedure tgdiprintcanvas.drawtext(var info: drawtextinfoty);
begin
 msedrawtext.drawtext(self,info);
end;

procedure tgdiprintcanvas.beginpage;
begin
 initgcvalues;
 exclude(fpstate,pcs_matrixvalid);
 {$ifdef mswindows}
 checkprinterror(startpage(gchandle)); 
 {$endif}
 inherited;
end;

procedure tgdiprintcanvas.endpage;
begin
 inherited;
 {$ifdef mswindows}
 checkprinterror(windows.endpage(gchandle)); 
 {$endif}
end;

procedure tgdiprintcanvas.checkgcstate(state: canvasstatesty);
begin
 inherited;
 if not (pcs_matrixvalid in fpstate) then begin
  include(fpstate,pcs_matrixvalid);
 end;
end;

end.
