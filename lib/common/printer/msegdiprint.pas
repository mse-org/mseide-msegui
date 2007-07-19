unit msegdiprint;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseprinter,msegraphics,msegraphutils,msetypes,msestrings,msedrawtext,
 msegui,mseguiglob;
const
 mmtoinch = 1/25.4;
 defaultgdiprintppmm = mseguiglob.defaultppmm;
 
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
   fpoffsetx: integer;
   fpoffsety: integer;
   fprintername: msestring;
  protected
   //icanvas
   procedure gcneeded(const sender: tcanvas);
   function getmonochrome: boolean;
  public
   constructor create(aowner: tcomponent); override;
   procedure beginprint;
   procedure endprint; override;
  published
   property printername: msestring read fprintername write fprintername;
                  //'' -> default printer
 end;

function defaultprinter: msestring;
 
implementation
uses
 {$ifdef mswindows}windows,{$endif}mseguiintf,msesys,sysutils,
 msesysintf;
var
 hasgdiprint: boolean;
 
{$ifdef mswindows}
type
 WINBOOL = longbool;
 DOCINFOW = record
  cbSize: longint;
  lpszDocName: LPCWSTR;
  lpszOutput: LPCWSTR;
  lpszDatatype: LPCWSTR;
  fwType: DWORD;
 end;
 TDOCINFOW = DOCINFOW;
 PDOCINFOW = ^DOCINFOW;
var     
 SetWorldTransform: function(_para1:HDC; var _para2:XFORM):WINBOOL; stdcall;
 StartDocW: function(_para1:HDC; _para2:PDOCINFOW):longint; stdcall;
 GetDefaultPrinterW: function(pszBuffer: pwidechar;
                              pcchBuffer: pdword): WINBOOL; stdcall;
{$endif}
  
{$ifdef mswindows}
procedure checkprinterror(const aresult: integer; const atext: string = '');
begin
 if aresult <= 0 then begin
  syserror(syelasterror,atext);
 end;
end;

procedure checkprintboolerror(const aresult: boolean; const atext: string = '');
begin
 if not aresult then begin
  syserror(syelasterror,atext);
 end;
end;
{$endif}

procedure checkgdiprint;
begin
 if not hasgdiprint then begin
  exception.create('GDI printing not supported.');
 end;
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
{$ifdef mswindows}
var
 mat1: txform;
{$endif}
begin
 inherited;
 if not (pcs_matrixvalid in fpstate) then begin
{$ifdef mswindows}
  fillchar(mat1,sizeof(mat1),0);
  with mat1,tgdiprinter(fprinter) do begin
   if printorientation = pao_landscape then begin
    em21:= (fppinchx*mmtoinch) / ppmm;
    em12:= -(fppinchy*mmtoinch) / ppmm;
    edx:= -fpoffsetx + pa_frametop*mmtoinch*fppinchx;
    edy:= -fpoffsety + (pa_height - pa_frameleft)*mmtoinch*fppinchy;
   end
   else begin
    em11:= (fppinchx*mmtoinch) / ppmm;
    em22:= (fppinchy*mmtoinch) / ppmm;
    edx:= -fpoffsetx + pa_frameleft*mmtoinch*fppinchx;
    edy:= -fpoffsety + pa_frametop*mmtoinch*fppinchy;
   end;
   checkprintboolerror(setworldtransform(fdrawinfo.gc.handle,mat1));
  end;
{$endif}
  include(fpstate,pcs_matrixvalid);
 end;
end;

{ tgdiprinter }

constructor tgdiprinter.create(aowner: tcomponent);
begin
 fcanvas:= tgdiprintcanvas.create(self,icanvas(self));
 inherited;
 fcanvas.ppmm:= defaultgdiprintppmm;
end;

function tgdiprinter.getmonochrome: boolean;
begin
 result:= false;
end;

{$ifdef mswindows}
    
procedure tgdiprinter.gcneeded(const sender: tcanvas);
var
 gc1: gcty;
 mat1: txform;
 mstr1: msestring;
begin
 checkgdiprint;
 if not (sender is tgdiprintcanvas) then begin
  guierror(gue_invalidcanvas);
 end;
 if fprintername = '' then begin
  mstr1:= defaultprinter;
 end
 else begin
  mstr1:= fprintername;
 end;
 with tgdiprintcanvas(sender) do begin
  fillchar(gc1,sizeof(gc1),0);
  guierror(gui_creategc(0,gck_printer,gc1,mstr1),'for "'+mstr1+'"');
  checkprinterror(setgraphicsmode(gc1.handle,gm_advanced));
  fppinchx:= getdevicecaps(gc1.handle,logpixelsx);
  fppinchy:= getdevicecaps(gc1.handle,logpixelsy);
  fpoffsetx:= getdevicecaps(gc1.handle,physicaloffsetx);
  fpoffsety:= getdevicecaps(gc1.handle,physicaloffsety);
  linktopaintdevice(ptrint(self),gc1,getwindowsize,nullpoint);
 end;
end;

procedure tgdiprinter.beginprint;
var
 info: tdocinfow;
begin
 checkgdiprint;
 fillchar(info,sizeof(info),0);
 info.cbsize:= sizeof(info);
 info.lpszdocname:= pwidechar(fcanvas.title);
 checkprinterror(startdocw(fcanvas.gchandle,@info),
          'Can not start print job for "'+fcanvas.title+'".');
end;

function defaultprinter: msestring;
const
 maxlen = 2048;
var
 int1: integer;
begin
 checkgdiprint;
 int1:= maxlen;
 setlength(result,int1);
 checkprintboolerror(getdefaultprinterw(pwidechar(result),@int1));
 setlength(result,int1-1);
end;

{$else}
procedure tgdiprinter.beginprint;
begin
 checkgdiprint;
end;

procedure tgdiprinter.gcneeded(const sender: tcanvas);
begin
 checkgdiprint;
end;

function defaultprinter: msestring;
begin
 checkgdiprint;
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

procedure doinit;
var
 haserror: boolean;
begin
 haserror:= false;
 {$ifdef mswindows}
 if not iswin95 then begin
  try
   getprocaddresses(getmodulehandle('gdi32'),
     [
     'SetWorldTransform',                        //0
     'StartDocW'                                 //1
     ],
     [
     {$ifndef FPC}@{$endif}@SetWorldTransform,     //0
     {$ifndef FPC}@{$endif}@StartDocW              //1
     ]);
   except begin
    haserror:= true;
   end;
  end;
  if not haserror then begin
   try
    getprocaddresses('WINSPOOL.DRV',
      [
     'GetDefaultPrinterW'                        //0
      ],
      [
     {$ifndef FPC}@{$endif}@GetDefaultPrinterW     //0
      ]);
    except begin
     haserror:= true;
    end;
   end;
  end;
 end
 else begin
  haserror:= true;
 end;
 {$endif}
 hasgdiprint:= not haserror;
end;

initialization
 doinit;
end.
