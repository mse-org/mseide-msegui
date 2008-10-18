{ MSEgui Copyright (c) 2007-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegdiprint;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

// ***********************************************************
//                            WARNING
//
// tgdiprinter and twmfprinter are depreciated, there are many
// issues with win32 printing and metafiles,
// please use tpostscriptprinter instead.
//
// ***********************************************************

interface
uses
 classes,mseprinter,msegraphics,msegraphutils,msetypes,msestrings,msedrawtext,
 msegui,mseguiglob{$ifdef mswindows},windows{$endif};
const
 mmtoinch = 1/25.4;
 defaultgdiprintppmm = mseguiglob.defaultppmm;
 screenrefprintername = 'ScreeN';
  
type
 tgdiprintcanvas = class(tprintercanvas)
  protected
   procedure beginpage; override;
   procedure endpage; override;
   procedure checkgcstate(state: canvasstatesty); override;
   function didprint: boolean; virtual;
  public
   constructor create(const user: tcustomprinter; const intf: icanvas);
   procedure drawtext(var info: drawtextinfoty); override;  
 end;

 tcustomgdiprinter = class(tprinter,icanvas)
  private
   fppinchx: real;
   fppinchy: real;
   fpoffsetx: real;
   fpoffsety: real;
   fprintername: msestring;
  protected
   function actprintername: msestring; virtual;
   procedure creategc(var agc: gcty; const aname: msestring); virtual;
   procedure initdevicecaps(const agc: gcty); virtual;
   //icanvas
   procedure gcneeded(const sender: tcanvas);
   function getmonochrome: boolean;
  public
   constructor create(aowner: tcomponent); override;
   procedure beginprint(const adryrun: boolean = false);
   procedure endprint; override;
 end;

 tgdiprinter = class(tcustomgdiprinter)
  published
   property printername: msestring read fprintername write fprintername;
                  //'' -> default printer
 end;
 
{$ifdef mswindows}

 twmfprintcanvas = class(tgdiprintcanvas)
  private
   ffilehandle: henhmetafile;
   function getenhmetafile: henhmetafile;
  protected
   function didprint: boolean; override;
  public
   constructor create(const user: tcustomprinter; const intf: icanvas);
   procedure linktopaintdevice(apaintdevice: paintdevicety; const gc: gcty;
                {const size: sizety;} const cliporigin: pointty); override;
   property metafilehandle: henhmetafile read getenhmetafile;
 end;  

 twmfprinter = class(tcustomgdiprinter)
  private
   frefprintername: msestring;
   function getcanvas: twmfprintcanvas;
   procedure setcanvas(const avalue: twmfprintcanvas);
  protected
   function actprintername: msestring; override;
   procedure creategc(var agc: gcty; const aname: msestring); override;
   function getwindowsize: sizety; override;
   procedure initdevicecaps(const agc: gcty); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property canvas: twmfprintcanvas read getcanvas write setcanvas;
   property filename: msestring read fprintername write fprintername;
                  //'' -> memory
   property refprintername: msestring read frefprintername write frefprintername;
                  //'' -> defaultprinter, 'ScreeN' -> default dc
 end;

{$endif}
 
function defaultprinter: msestring;
 
implementation
uses
 mseguiintf,msesys,sysutils,
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
 if cs_inactive in fstate then exit;
 msedrawtext.drawtext(self,info);
end;

procedure tgdiprintcanvas.beginpage;
begin
 initgcvalues;
 exclude(fpstate,pcs_matrixvalid);
 include(fstate,cs_inactive);
 if not (pcs_dryrun in fpstate) and active then begin
  exclude(fstate,cs_inactive);
 end;   
 if not (cs_inactive in fstate) then begin
  include(fstate,cs_pagestarted);
  {$ifdef mswindows}
  if not (cs_metafile in fstate) then begin
   checkprinterror(startpage(gchandle)); 
  end;
  {$endif}
 end;
 inherited;
end;

procedure tgdiprintcanvas.endpage;
begin
 inherited;
 if not (cs_inactive in fstate) and (cs_pagestarted in fstate) then begin
  exclude(fstate,cs_pagestarted);
  {$ifdef mswindows}
  if not (cs_metafile in fstate) then begin
   checkprinterror(windows.endpage(gchandle)); 
  end;
  {$endif}
 end;
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
  with mat1,tcustomgdiprinter(fprinter) do begin
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

function tgdiprintcanvas.didprint: boolean;
begin
 result:= fdrawinfo.gc.handle <> 0;
end;


{ tcustomgdiprinter }

constructor tcustomgdiprinter.create(aowner: tcomponent);
begin
 if fcanvas = nil then begin
  fcanvas:= tgdiprintcanvas.create(self,icanvas(self));
 end;
 inherited;
 fcanvas.ppmm:= defaultgdiprintppmm;
end;

function tcustomgdiprinter.getmonochrome: boolean;
begin
 result:= false;
end;

{$ifdef mswindows}

function tcustomgdiprinter.actprintername: msestring;
begin
 if fprintername = '' then begin
  result:= defaultprinter;
 end
 else begin
  result:= fprintername;
 end;
end;

procedure tcustomgdiprinter.creategc(var agc: gcty; const aname: msestring);
begin
 guierror(gui_creategc(0,gck_printer,agc,aname),'for "'+aname+'"');
end;

procedure tcustomgdiprinter.initdevicecaps(const agc: gcty);
begin
 fppinchx:= getdevicecaps(agc.handle,logpixelsx);
 fppinchy:= getdevicecaps(agc.handle,logpixelsy);
 fpoffsetx:= getdevicecaps(agc.handle,physicaloffsetx);
 fpoffsety:= getdevicecaps(agc.handle,physicaloffsety);
end;

procedure tcustomgdiprinter.gcneeded(const sender: tcanvas);
var
 gc1: gcty;
 mat1: txform;
 mstr1: msestring;
begin
 checkgdiprint;
 if not (sender is tgdiprintcanvas) then begin
  guierror(gue_invalidcanvas);
 end;
 mstr1:= actprintername;
 with tgdiprintcanvas(sender) do begin
  exclude(fstate,cs_pagestarted);
  fillchar(gc1,sizeof(gc1),0);
  gc1.size:= getwindowsize;
  gc1.ppmm:= ppmm; 
  include(gc1.drawingflags,df_highresfont);
  creategc(gc1,mstr1);
  checkprinterror(setgraphicsmode(gc1.handle,gm_advanced));
  initdevicecaps(gc1);
  linktopaintdevice(ptrint(self),gc1,{getwindowsize,}nullpoint);
 end;
end;

procedure tcustomgdiprinter.beginprint(const adryrun: boolean = false);
var
 info: tdocinfow;
begin
 checkgdiprint;
 endprint;
 with tgdiprintcanvas(fcanvas) do begin
  if adryrun then begin
   include(fpstate,pcs_dryrun)
  end
  else begin
   exclude(fpstate,pcs_dryrun);
  end;
  initprinting;
  if not (pcs_dryrun in fpstate) then begin
   if not (cs_metafile in fstate) then begin
    fillchar(info,sizeof(info),0);
    info.cbsize:= sizeof(info);
    info.lpszdocname:= pwidechar(fcanvas.title);
    checkprinterror(startdocw(fcanvas.gchandle,@info),
             'Can not start print job for "'+fcanvas.title+'".');
   end;
   beginpage;
  end;
 end;
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
procedure tcustomgdiprinter.beginprint(const adryrun: boolean = false);
begin
 checkgdiprint;
end;

procedure tcustomgdiprinter.gcneeded(const sender: tcanvas);
begin
 checkgdiprint;
end;

procedure tcustomgdiprinter.startdoc;
begin
 checkgdiprint;
end;

function defaultprinter: msestring;
begin
 checkgdiprint;
end;

function tcustomgdiprinter.actprintername: msestring;
begin
 checkgdiprint;
 result:= '';
end;

procedure tcustomgdiprinter.initdevicecaps(const agc: gcty);
begin
 checkgdiprint;
end;

procedure tcustomgdiprinter.creategc(var agc: gcty; aname: msestring);
begin
 checkgdiprint;
end;

{$endif}

procedure tcustomgdiprinter.endprint;
begin
 checkgdiprint;
 with tgdiprintcanvas(fcanvas) do begin
  if didprint then begin
   try
    try
    {$ifdef mswindows}
     endpage;
     if not (pcs_dryrun in fpstate) then begin
      if not (cs_metafile in fstate) then begin
       enddoc(gchandle);
      end;
     end;
    {$endif}
    finally
     unlink;
    end;
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
    getprocaddresses(['WINSPOOL.DRV'],
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

{$ifdef mswindows}

{ twmfprintcanvas }

constructor twmfprintcanvas.create(const user: tcustomprinter;
               const intf: icanvas);
begin
 include(fstate,cs_metafile);
 inherited;
end;

procedure twmfprintcanvas.linktopaintdevice(apaintdevice: paintdevicety;
               const gc: gcty;{ const size: sizety;} const cliporigin: pointty);
begin
 if ffilehandle <> 0 then begin
  deleteenhmetafile(ffilehandle);
  ffilehandle:= 0;
 end;
 inherited;
end;

function twmfprintcanvas.getenhmetafile: henhmetafile;
begin
 if ffilehandle = 0 then begin
  ffilehandle:= closeenhmetafile(gchandle);
  fdrawinfo.gc.handle:= 0;
  gdi(gdi_destroygc);
 end;
 result:= ffilehandle;
end;

function twmfprintcanvas.didprint: boolean;
begin
 result:= (ffilehandle <> 0) or inherited didprint;
end;

{ twmfprinter }

constructor twmfprinter.create(aowner: tcomponent);
begin
 if fcanvas = nil then begin
  fcanvas:= twmfprintcanvas.create(self,icanvas(self));
 end;
 inherited;
end;

function twmfprinter.actprintername: msestring;
begin
 result:= fprintername;
end;

procedure twmfprinter.creategc(var agc: gcty; const aname: msestring);
var
 str1: ansistring;
begin
 if frefprintername <> screenrefprintername then begin
  if frefprintername = '' then begin
   str1:= defaultprinter;
  end
  else begin
   str1:= frefprintername;
  end;
 end;
 agc.refgc:= createdc('WINSPOOL',pansichar(str1),nil,nil);
// agc.refgc:= getdc(0);        
 try
  guierror(gui_creategc(0,gck_metafile,agc,aname),'for "'+aname+'"');
 finally
  if agc.refgc <> 0 then begin
//   releasedc(0,agc.refgc);
   deletedc(agc.refgc);
   agc.refgc:= 0;
  end;
 end;
end;

function twmfprinter.getcanvas: twmfprintcanvas;
begin
 result:= twmfprintcanvas(fcanvas);
end;

procedure twmfprinter.setcanvas(const avalue: twmfprintcanvas);
begin
 fcanvas.assign(avalue);
end;

function twmfprinter.getwindowsize: sizety;
begin
 result.cx:= round(pa_width*fcanvas.ppmm);
 result.cy:= round(pa_height*fcanvas.ppmm);
end;

procedure twmfprinter.initdevicecaps(const agc: gcty);
begin
 inherited;
 fpoffsetx:= 0;
 fpoffsety:= 0;
 exit;
 fppinchx:= fppinchx * fcanvas.ppmm/mmtoinch; //paint device is virtual screen
 fppinchy:= fppinchx;
 fpoffsetx:= 0;
 fpoffsety:= 0;
end;

{$endif} //mswindows

initialization
 doinit;
end.
