{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegdi32gdi;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$goto on}
interface
uses
 msegraphics,msetypes,windows,msestrings,mseguiglob;

procedure init;
procedure deinit; 

function gdi32getgdifuncs: pgdifunctionaty;
//function gdi32getgdinum: integer;
procedure gdi32initdefaultfont;
function gdi32getdefaultfontnames: defaultfontnamesty;
//function gdi32creategc(paintdevice: paintdevicety; const akind: gckindty; 
//              var gc: gcty; const aprintername: msestring): guierrorty;

{$ifdef FPC}
function GetNextWindow(hWnd: HWND; uCmd: UINT): HWND; stdcall;
             external user32 name 'GetWindow';
function CreateRectRgnIndirect(const _para1:tRECT):HRGN; stdcall;
             external gdi32 name 'CreateRectRgnIndirect';
function winFillRect(hDC:HDC; const lprc:tRECT; hbr:HBRUSH):longint; stdcall;
             external user32 name 'FillRect';

type
  tTEXTMETRICW = record
    tmHeight: Longint;
    tmAscent: Longint;
    tmDescent: Longint;
    tmInternalLeading: Longint;
    tmExternalLeading: Longint;
    tmAveCharWidth: Longint;
    tmMaxCharWidth: Longint;
    tmWeight: Longint;
    tmOverhang: Longint;
    tmDigitizedAspectX: Longint;
    tmDigitizedAspectY: Longint;
    tmFirstChar: WideChar;
    tmLastChar: WideChar;
    tmDefaultChar: WideChar;
    tmBreakChar: WideChar;
    tmItalic: Byte;
    tmUnderlined: Byte;
    tmStruckOut: Byte;
    tmPitchAndFamily: Byte;
    tmCharSet: Byte;
  end;
  tTEXTMETRICA = record
    tmHeight: Longint;
    tmAscent: Longint;
    tmDescent: Longint;
    tmInternalLeading: Longint;
    tmExternalLeading: Longint;
    tmAveCharWidth: Longint;
    tmMaxCharWidth: Longint;
    tmWeight: Longint;
    tmOverhang: Longint;
    tmDigitizedAspectX: Longint;
    tmDigitizedAspectY: Longint;
    tmFirstChar: Char;
    tmLastChar: Char;
    tmDefaultChar: Char;
    tmBreakChar: Char;
    tmItalic: Byte;
    tmUnderlined: Byte;
    tmStruckOut: Byte;
    tmPitchAndFamily: Byte;
    tmCharSet: Byte;
  end;

  tGCPRESULTSW = record
       lStructSize : DWORD;
       lpOutString : pwidechar;
       lpOrder : ^UINT;
       lpDx : ^WINT;
       lpCaretPos : ^WINT;
       lpClass : pwidechar;
       lpGlyphs : ^UINT;
       nGlyphs : UINT;
       nMaxFit : UINT;
    end;
{$else}
function GetCharacterPlacementW(DC: HDC; p2: PWideChar; p3, p4: Integer;
  var p5: TGCPResultsw; p6: DWORD): DWORD; stdcall;
                        external gdi32 name 'GetCharacterPlacementW';
type
 WINT = longint;
{$endif}

const
 rasterops2: array[rasteropty] of byte =
               ($01,$09,$05,$0d,
                $03,$0b,$07,$0f,
                $02,$0a,$06,$0e,
                $04,$0c,$08,$10);
{
 inverserops2: array[rasteropty] of byte =//for 1->foreground in monochromebitmaps
                ($00,$04,$08,$0c,
                 $01,$05,$09,$0d,
                 $02,$06,$0a,$0e,
                 $03,$07,$0b,$0f);
}
 inverserops2: array[rasteropty] of byte =//for 1->foreground in monochromebitmaps
                ($10,$0e,$0f,$0d,
                 $08,$06,$07,$05,
                 $0c,$0a,$0b,$09,
                 $04,$02,$03,$01);

 firstrasterops2: array[rasteropty] of byte = //backgroudcolor = $ffffff,
               ($09,$09,$09,$09,              //textcolor = $000000, and
                $09,$09,$09,$09,
                $09,$09,$09,$09,
                $09,$09,$09,$09);

 secondrasterops2: array[rasteropty] of byte = //colorbackground = $000000,
               ($0f,$0f,$0f,$0f,               //textcolor = $ffffff, or
                $0f,$0f,$0f,$0f,
                $0f,$0f,$0f,$0f,
                $0f,$0f,$0f,$0f);

 rasterops3: array[rasteropty] of longword =
               ($000042,$8800c6,$440328,$cc0020,
                $220326,$aa0029,$660046,$ee0086,
                $1100a6,$990066,$550009,$dd0228,
                $330008,$bb0226,$7700e6,$ff0062);

 patrops3: array[rasteropty] of longword =
               ($000042,$a000c9,$500325,$f00021,
                $0a0329,$aa0029,$5a0049,$fa0089,
                $0500a9,$a50065,$550009,$f50225,
                $0f0001,$af0229,$5f00e2,$ff0062);

implementation
uses
 mseguiintf,msegraphutils,msesysintf1,sysutils,msegdiplus;
 
type
 shapety = (fs_copyarea,fs_rect,fs_ellipse,fs_arc,fs_polygon);

 gcflagty = (gcf_backgroundbrushvalid,
             gcf_colorbrushvalid,gcf_patternbrushvalid,
             gcf_rasterop,
             gcf_selectforegroundbrush,gcf_selectbackgroundbrush,
             gcf_foregroundpenvalid,
             gcf_selectforegroundpen,gcf_selectnullpen,gcf_selectnullbrush,
             gcf_ispatternpen,gcf_isopaquedashpen,gcf_smooth,
             gcf_gpregionvalid,
             gcf_gpbrushcolorvalid,gcf_gpbrushoriginvalid,
             gcf_gpmonochromebrush,
             gcf_gppencolorvalid,gcf_gppenvalid,gcf_gppenmode,gcf_gpshiftpen,
             {gcf_gpsolidfillvalid,gcf_gpspenvalid,}
                          gcf_last = 31);
            //-> longword
 gcflagsty = set of gcflagty;
 pgcflagsty = ^gcflagsty;
type
 monopalettety = record
  Flags: UINT;
  Count: UINT;
  val0: ARGB;
  val1: ARGB;
 end;

 win32gcdty = record
  flags: gcflagsty;
  gpflags: gcflagsty;
  backgroundcol,foregroundcol: longword;
  backgroundbrush: hbrush;
  colorbrush: hbrush;
  patternbrush: hbrush;
  foregroundpen: hpen;
  kind: gckindty;
  bru: pixmapty;
  rop: rasteropty;
  brushorg: pointty;
  peninfo: lineinfoty;
  gccliporigin: pointty;
  selectedpen: hpen;
  selectedbrush: hbrush;
  secondpen: hpen;
  gpgraphic: pgpgraphics;
  gpregion: pgpregion;
  gpsolidfill: pgpsolidfill;
  gptexture: pgptexture;
  gppalettedata: monopalettety;
  gptextureimage: pgpbitmap;
  gpbrush: pgpbrush;
  gppen: pgppen;
 end;
 {$if sizeof(win32gcdty) > sizeof(gcpty)} {$error 'buffer overflow'}{$ifend}
 win32gcty = record
  case integer of
   0: (d: win32gcdty;);
   1: (_bufferspace: gcpty;);
 end;
 pwin32gcty = ^win32gcty;
 
 charwidthsty = array[0..255] of integer;
 pcharwidthsty = ^charwidthsty;
 win32fontdataty = record
  charwidths: pcharwidthsty;
  overhang: integer;
  xwidth: integer;
  local: array[3..15] of longword; //plattform dependent
 end;
 
type
 tsimplebitmap1 = class(tsimplebitmap);
 tcanvas1 = class(tcanvas);
 
var
 nullpen: hpen;
 nullbrush: hbrush;


 capstyles: array[capstylety] of longword =
       (ps_endcap_flat,ps_endcap_round,ps_endcap_square);
 joinstyles: array[joinstylety] of longword =
       (ps_join_miter,ps_join_round,ps_join_bevel);
       
const
 highresfontshift = 6;  //64
 highresfontfakt = 1 shl highresfontshift;
 highresfontmask = highresfontfakt - 1; 
 CLEARTYPE_QUALITY = ANTIALIASED_QUALITY+1;

 defaultfontname = 'Tahoma';
// defaultfontname = 'MS Sans Serif';
 defaultfontnames: defaultfontnamesty =
  //stf_default           stf_empty stf_unicode stf_menu stf_message stf_hint stf_report
   (defaultfontname,          '',       '',         '',      '',       '',      'Arial',
  //stf_proportional stf_fixed,
   defaultfontname,         'Courier New',
  //stf_helvetica stf_roman          stf_courier
    'Arial',     'Times New Roman', 'Courier New');

function gdi32getdefaultfontnames: defaultfontnamesty;
begin
 result:= defaultfontnames;
end;

procedure gdi_createpixmap(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.createpixmap do begin
  pixmap:= gui_createpixmap(size,0,kind,copyfrom);
 end;
end;

procedure gdi_pixmaptoimage(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.pixmapimage do begin
  gui_pixmaptoimage(pixmap,image,drawinfo.gc.handle);
 end;
end;

procedure gdi_imagetopixmap(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.pixmapimage do begin
  error:= gui_imagetopixmap(image,pixmap,drawinfo.gc.handle);
 end;
end;

//function gdi32creategc(paintdevice: paintdevicety; const akind: gckindty; 
//              var gc: gcty; const aprintername: msestring): guierrorty;
procedure gdi_creategc(var drawinfo: drawinfoty);
var
 wrect1: trect;
begin
 with drawinfo.creategc do begin
  gcpo^.gdifuncs:= gui_getgdifuncs;
  case kind of
   gck_pixmap: begin
    error:= gde_creategc;
    gcpo^.handle:= createcompatibledc(0);
    if gcpo^.handle <> 0 then begin
     selectobject(gcpo^.handle,paintdevice);
     win32gcty(gcpo^.platformdata).d.kind:= kind;
    end;
   end;
   gck_printer: begin
    error:= gde_createprintergc;
    gcpo^.handle:= createdc('WINSPOOL',pansichar(ansistring(printernamepo^)),nil,nil);
    setmapperflags(gcpo^.handle,1); //match font-device aspectratio
   end;
   gck_metafile: begin
    error:= gde_createmetafilegc;
    wrect1.left:= 0;
    wrect1.top:= 0;
    wrect1.right:= round((gcpo^.paintdevicesize.cx*100)/gcpo^.ppmm);
    wrect1.bottom:= round((gcpo^.paintdevicesize.cy*100)/gcpo^.ppmm);
    if printernamepo^ = '' then begin
     gcpo^.handle:= createenhmetafilew(gcpo^.refgc,nil,@wrect1,nil); //memory
    end
    else begin
     gcpo^.handle:= createenhmetafilew(gcpo^.refgc,pmsechar(printernamepo^),@wrect1,nil); 
                                                    //file
    end;
    setmapperflags(gcpo^.handle,1); //match font-device aspectratio
   end;
   else begin
    error:= gde_creategc;
    gcpo^.handle:= getdc(paintdevice);
   end;
  end;
  if gcpo^.handle <> 0 then begin
 {$ifdef mse_debuggdi}
   inc(gccount);
 {$endif}
   win32gcty(gcpo^.platformdata).d.kind:= kind;
   settextalign(gcpo^.handle,ta_left or ta_baseline or ta_noupdatecp);
   setbkmode(gcpo^.handle,transparent);
   setmapmode(gcpo^.handle,mm_text);
   error:= gde_ok;
  end;
 end;
end;

procedure transformpoints(var drawinfo: drawinfoty; const aclose: boolean);
var
 po1: ppointty;
 po2: ppointty;
 int1: integer;
begin
 with drawinfo.points do begin
  int1:= count;
  if aclose then begin
   inc(int1);
  end;
  allocbuffer(drawinfo.buffer,int1*sizeof(pointty));
  po1:= points;
  po2:= drawinfo.buffer.buffer;
  int1:= count;
  with drawinfo.origin do begin
   while int1 > 0 do begin
    po2^.x:= po1^.x + x;
    po2^.y:= po1^.y + y;
    inc(po1);
    inc(po2);
    dec(int1);
   end;
  end;
  if aclose then begin
   move(drawinfo.buffer.buffer^,(pchar(drawinfo.buffer.buffer)+
              count*sizeof(pointty))^,sizeof(pointty));
  end;
 end;
end;

procedure adjustlineend(po: ppointty); //solve lineto lastpixel problem
var
 po1: ppoint;
 dx,dy,dist: integer;

begin
 po1:= ppoint(pchar(po)-sizeof(pointty));
 dx:= po^.x - po1^.x;
 dy:= po^.y - po1^.y;
 dist:= (abs(dx) + abs(dy)) div 2;
 if dx < 0 then begin
  if dx + dist <= 0 then begin
   dec(po^.x);
  end;
 end
 else begin
  if dx >= dist then begin
   inc(po^.x);
  end;
 end;
 if dy < 0 then begin
  if dy + dist <= 0 then begin
   dec(po^.y);
  end;
 end
 else begin
  if dy >= dist then begin
   inc(po^.y);
  end;
 end;
end;

procedure transformrect(var drawinfo: drawinfoty);
begin
 allocbuffer(drawinfo.buffer,sizeof(trect));
 with drawinfo,prect(buffer.buffer)^,rect do begin
  Left:= rect^.x + origin.x;
  right:= Left + rect^.cx;
  top:= rect^.y + origin.y;
  bottom:= top + rect^.cy;
 end;
end;

procedure offsetrect(var drawinfo: drawinfoty);
begin
 allocbuffer(drawinfo.buffer,sizeof(rectty));
 with drawinfo,prectty(buffer.buffer)^,rect do begin
  x:= rect^.x + origin.x;
  cx:= rect^.cx;
  y:= rect^.y + origin.y;
  cy:= rect^.cy;
 end;
end;

procedure transformellipseinfo(var drawinfo: drawinfoty; const fill: boolean);
var
 int1: integer;
begin
 allocbuffer(drawinfo.buffer,sizeof(trect));
 int1:= 1;
 if fill then begin
  int1:= 2;
 end;
 with drawinfo,prect(buffer.buffer)^,rect do begin
  Left:= rect^.x + origin.x - drawinfo.rect.rect^.cx div 2;
  right:= Left + rect^.cx+int1;
  top:= rect^.y + origin.y - drawinfo.rect.rect^.cy div 2;
  bottom:= top + rect^.cy+int1;
 end;
end;

procedure updateopaquemode(var gc: gcty);
begin
 with gc,win32gcty(platformdata).d do begin
  settextcolor(handle,foregroundcol);
  if df_opaque in drawingflags then begin
   setbkmode(handle,opaque);
   setbkcolor(handle,backgroundcol);
  end
  else begin
   setbkmode(handle,transparent);
  end;
 end;
end;

procedure checkgc2(var gc: gcty);
         //second pass for transparent patternpen
begin
 with gc,win32gcty(platformdata).d do begin
  if gcf_isopaquedashpen in flags then begin
   selectobject(handle,secondpen);
   deleteobject(selectedpen);
   selectedpen:= secondpen;
   foregroundpen:= secondpen;
   exclude(flags,gcf_foregroundpenvalid);
  end
  else begin
   setbkcolor(handle,$000000);
   settextcolor(handle,foregroundcol);
   setrop2(handle,secondrasterops2[rop]);
   exclude(flags,gcf_rasterop);
  end;
 end;
end;

function checkgc(var gc: gcty; aflags: gcflagsty): boolean;
               //true if second drawing needed
var
 flags1: gcflagsty;
 brushinfo: logbrush;
 adashes: array[0..high(dashesstringty)] of longword;
 int1: integer;
 po1: pointer;
 dashlen: integer;
 astyle: longword;
 awidth: integer;

begin
 result:= false;
 with gc,win32gcty(platformdata).d do begin
  exclude(flags,gcf_isopaquedashpen);
  if (df_brush in drawingflags) xor (gcf_ispatternpen in flags) then begin
   exclude(flags,gcf_foregroundpenvalid);
  end;
  if  not (gcf_rasterop in flags) and
   ([gcf_selectforegroundbrush,gcf_selectforegroundpen] * aflags <>
    [gcf_selectforegroundbrush,gcf_selectforegroundpen]) then begin
   exclude(flags,gcf_selectforegroundbrush);   //refresh rasterop
   exclude(flags,gcf_selectforegroundpen);
   if df_canvasismonochrome in drawingflags then begin
    setrop2(handle,inverserops2[rop]);
   end
   else begin
    setrop2(handle,rasterops2[rop]);
   end;
   include(flags,gcf_rasterop);
  end;
  flags1:= gcflagsty((longword(aflags) xor longword(flags)) and longword(aflags));
       //needed objects
  if df_brush in drawingflags then begin
   exclude(flags1,gcf_colorbrushvalid);
  end
  else begin
   exclude(flags1,gcf_patternbrushvalid);
  end;
  if gcf_backgroundbrushvalid in flags1 then begin
   if backgroundbrush <> 0 then begin
    if backgroundbrush = selectedbrush then begin
     selectobject(handle,nullbrush);
    end;
    deleteobject(backgroundbrush);
   end;
   backgroundbrush:= createsolidbrush(backgroundcol);
  end;
  if gcf_colorbrushvalid in flags1 then begin
   if colorbrush <> 0 then begin
    if colorbrush = selectedbrush then begin
     selectobject(handle,nullbrush);
    end;
    deleteobject(colorbrush);
   end;
   colorbrush:= createsolidbrush(foregroundcol);
  end;
  if gcf_patternbrushvalid in flags1 then begin
   if patternbrush <> 0 then begin
    if patternbrush = selectedbrush then begin
     selectobject(handle,nullbrush);
    end;
    deleteobject(patternbrush);
   end;
   patternbrush:= createpatternbrush(bru);
  end;
  if gcf_foregroundpenvalid in flags1 then begin
   if foregroundpen <> 0 then begin
    if selectedpen = foregroundpen then begin
     selectobject(handle,nullpen);
    end;
    deleteobject(foregroundpen);
   end;
                //todo: emulations for win95, opaquemode
   with peninfo do begin
    po1:= nil;
    dashlen:= length(dashes);
    if dashlen > 0 then begin
     if df_opaque in drawingflags then begin
      include(flags,gcf_isopaquedashpen);
      result:= true;
     end;
     if iswin95 then begin
      astyle:= ps_dot;
     end
     else begin
      if dashes = #1#1 then begin
       astyle:= ps_alternate or ps_cosmetic;
       dashlen:= 0;
      end
      else begin
       for int1:= 1 to length(dashes) do begin
        adashes[int1-1]:= ord(dashes[int1]){ div 3};
       end;
       po1:= @adashes;
       astyle:= ps_userstyle or ps_geometric;
      end;
     end;
    end
    else begin
     if (df_brush in drawingflags) or (width > 0) then begin
      astyle:= ps_geometric;
     end
     else begin
      astyle:= ps_cosmetic;
     end;
    end;
    if astyle and ps_geometric <> 0 then begin
     astyle:= astyle or capstyles[capstyle] or joinstyles[joinstyle];
    end;
    with brushinfo do begin
     if df_brush in drawingflags then begin
      lbStyle:= bs_pattern;
      lbhatch:= bru;
      include(flags,gcf_ispatternpen);
     end
     else begin
      lbStyle:= bs_solid;
      lbColor:= foregroundcol;
      exclude(flags,gcf_ispatternpen);
     end;
    end;
    if width = 0 then begin
     awidth:= 1
    end
    else begin
     awidth:= width
    end;
    foregroundpen:= extcreatepen(astyle,awidth,brushinfo,
                    dashlen,po1);
    if gcf_isopaquedashpen in flags then begin
     secondpen:= foregroundpen;
     with brushinfo do begin
      lbStyle:= bs_solid;
      lbColor:= backgroundcol;
     end;
     foregroundpen:= extcreatepen(astyle and 
         not(ps_userstyle or ps_dot or ps_alternate),awidth,brushinfo,
                    0,nil);         
    end;
   end;
  end;
  if gcf_selectbackgroundbrush in aflags then begin
   selectobject(gc.handle,backgroundbrush);
   selectedbrush:= backgroundbrush;
  end;
  if gcf_selectforegroundbrush in aflags then begin
   if df_brush in drawingflags then begin
    selectobject(gc.handle,patternbrush);
    selectedbrush:= patternbrush;
   end
   else begin
    selectobject(gc.handle,colorbrush);
    selectedbrush:= colorbrush;
   end;
  end;
  if gcf_selectforegroundpen in aflags then begin
   if (gcf_ispatternpen in flags) and
    (drawingflags * [df_monochrome,df_opaque] = [df_monochrome]) then begin
    result:= true;
    setbkcolor(handle,$ffffff);
    settextcolor(handle,$000000);
    setrop2(handle,firstrasterops2[rop]);
   end
   else begin
    updateopaquemode(gc);
   end;
   selectobject(gc.handle,foregroundpen);
   selectedpen:= foregroundpen;
  end;
  if gcf_selectnullpen in aflags then begin
   selectobject(gc.handle,nullpen);
   selectedpen:= nullpen;
  end;
  if gcf_selectnullbrush in aflags then begin
   selectobject(gc.handle,nullbrush);
   selectedbrush:= nullbrush;
  end;
  flags:= flags + flags1;
 end;
end;

procedure deletepgtexture(var gc: gcty);
begin
 with win32gcty(gc.platformdata).d do begin
  if gptexture <> nil then begin
   gdipdeletebrush(pgpbrush(gptexture));
   gptexture:= nil;
  end;
  if gptextureimage <> nil then begin
   gdipdisposeimage(pgpimage(gptextureimage));
//   gdipfree(gptextureimage);
   gptextureimage:= nil;
  end;
  gpflags:= gpflags -
          [gcf_gpmonochromebrush,gcf_patternbrushvalid,
           gcf_gpbrushoriginvalid,gcf_gpbrushcolorvalid];
 end;
end;

const
 alphamax = $ff000000;

function gpcolor(const apixel: pixelty): pixelty; inline;
begin
 result:= apixel and $0000ff00 or 
                (apixel and $00ff0000 shr 16) or
                (apixel and $000000ff shl 16) or alphamax;
end;

//todo: optimize, update invalid values only

const
 gpcaps: array[capstylety] of gplinecap = 
                 (linecapflat,linecapround,linecapsquare);
 gpdashcaps: array[capstylety] of gpdashcap = 
                 (dashcapflat,dashcapround,dashcaptriangle);
 gpjoins: array[joinstylety] of gplinejoin = 
                 (linejoinmiterclipped,linejoinround,linejoinbevel);
const
 gpstartflags = [gcf_patternbrushvalid,gcf_gpbrushoriginvalid,gcf_gpregionvalid,
                 gcf_gpmonochromebrush,
                 gcf_gpbrushcolorvalid,gcf_gppencolorvalid,gcf_gppenvalid];
// gcfgpflags = [gcf_gppenmode];
 gplineflags = [gcf_selectforegroundpen];
 gpfillflags = [gcf_selectforegroundbrush];

procedure checkgpgc(var gc: gcty; aflags: gcflagsty);

 function checkbrushorcolor: boolean; //true if changed
  procedure updatepalette;
  begin
   with gc,win32gcty(platformdata).d do begin
    if gcf_gpmonochromebrush in gpflags then begin       
     with gppalettedata do begin
      longword(val0):= gpcolor(foregroundcol) or $ff000000;
      if df_opaque in drawingflags then begin
       longword(val1):= gpcolor(backgroundcol) or $ff000000;
       flags:= 0;
      end
      else begin
       longword(val1):= backgroundcol;
       flags:= PaletteFlagsHasAlpha;
      end;
     end;
     gdipsetimagepalette(pgpimage(gptextureimage),@gppalettedata);
    end;
   end;
  end; //checkgpgc
var
 newtexture: boolean;  
 begin
  result:= false;
  with gc,win32gcty(platformdata).d do begin
   newtexture:= false;
   if df_brush in drawingflags then begin
    if not (gcf_patternbrushvalid in gpflags) then begin
     if gdipcreatebitmapfromhbitmap(bru,0,@gptextureimage) = ok then begin
      if df_monochrome in drawingflags then begin
       include(gpflags,gcf_gpmonochromebrush);
      end;
      updatepalette;
      gdipcreatetexture(pgpimage(gptextureimage),wrapmodetile,@gptexture);
     end;
     include(gpflags,gcf_patternbrushvalid);
     newtexture:= true;
     result:= true;
    end;
    if gptexture <> nil then begin
     gpbrush:= pgpbrush(gptexture);
     if not (gcf_gpbrushoriginvalid in gpflags) then begin
      gdipresettexturetransform(gptexture);
      gdiptranslatetexturetransform(gptexture,brushorg.x,brushorg.y,
                                                   matrixorderprepend);
      include(gpflags,gcf_gpbrushoriginvalid);
      result:= true;
     end;
    end
    else begin
     gpbrush:= pgpbrush(gpsolidfill); //error
    end;
   end
   else begin
    gpbrush:= pgpbrush(gpsolidfill);
   end;
   if not (gcf_gpbrushcolorvalid in gpflags) then begin
    result:= true;
    gdipsetsolidfillcolor(gpsolidfill,gpcolor(foregroundcol));
    if not newtexture then begin
     updatepalette;
     if gpbrush = pointer(gptexture) then begin
      gdipdeletebrush(gpbrush);
      gdipcreatetexture(pgpimage(gptextureimage),
                                       wrapmodetile,@gptexture);
      gdiptranslatetexturetransform(gptexture,brushorg.x,brushorg.y,
                                                    matrixorderprepend);
      gpbrush:= pgpbrush(gptexture);
     end;
    end;
    include(gpflags,gcf_gpbrushcolorvalid);
   end;
  end;
 end; //checkbrushorcolor

var
 cap1: gplinecap;
 dash1: array[0..high(dashesstringty)] of gpreal;
 int1: integer;
 dasca: real;
 reg: hrgn;
begin
 with gc,win32gcty(platformdata).d do begin
  if not (gcf_gpregionvalid in gpflags) then begin
   if gpregion <> nil then begin
    gdipdeleteregion(gpregion);
   end;
   reg:= createrectrgn(0,0,0,0);
   if getcliprgn(handle,reg) = 0 then begin
    gdipresetclip(gpgraphic);
    gpregion:= nil;
   end
   else begin
    GdipCreateRegionHrgn(reg,@gpregion);
    gdipsetclipregion(gpgraphic,gpregion,combinemodereplace);
   end;
   include(gpflags,gcf_gpregionvalid);
   deleteobject(reg);
  end;
  if gcf_selectforegroundpen in aflags then begin
   if checkbrushorcolor then begin
    if df_brush in drawingflags then begin
     gdipsetpenbrushfill(gppen,gpbrush);
    end
    else begin
     gdipsetpencolor(gppen,gpcolor(foregroundcol));
    end;
   end;
   if not (gcf_gppenvalid in gpflags) then begin
    exclude(gpflags,gcf_gppenmode);
    if df_brush in drawingflags then begin
     gdipsetpenbrushfill(gppen,gpbrush);
    end
    else begin
     gdipsetpencolor(gppen,gpcolor(foregroundcol));
    end;
    exclude(gpflags,gcf_gpshiftpen);
    if peninfo.width = 0 then begin
     gdipsetpenwidth(gppen,1);
     dasca:= 1;
    end
    else begin
     if not odd(peninfo.width) then begin
      include(gpflags,gcf_gpshiftpen);
     end;
     gdipsetpenwidth(gppen,peninfo.width);
     dasca:= 1/peninfo.width;
    end;
    cap1:= gpcaps[peninfo.capstyle];
    gdipsetpenlinecap197819(gppen,cap1,cap1,
                               gpdashcaps[peninfo.capstyle]);
    gdipsetpenlinejoin(gppen,gpjoins[peninfo.joinstyle]);
    if length(peninfo.dashes) > 0 then begin
     for int1:= 1 to length(peninfo.dashes) do begin
      dash1[int1-1]:= ord(peninfo.dashes[int1])*dasca;
     end;
     gdipsetpendasharray(gppen,@dash1,length(peninfo.dashes));
     gdipsetpendashoffset(gppen,0.5*dasca);
    end
    else begin
     gdipsetpendashstyle(gppen,dashstylesolid);
    end;
    include(gpflags,gcf_gppenvalid);
   end;
  end;
  if gcf_selectforegroundbrush in aflags then begin
   checkbrushorcolor;
  end;
  if (gcf_selectforegroundpen in aflags) xor 
                              (gcf_gppenmode in gpflags) then begin
   if (gcf_selectforegroundpen in aflags) then begin
    if gcf_gpshiftpen in gpflags then begin
     gdipsetpixeloffsetmode(gpgraphic,pixeloffsetmodehalf);
    end
    else begin
     gdipsetpixeloffsetmode(gpgraphic,pixeloffsetmodenone);
    end;
//    gdipsetpixeloffsetmode(gpgraphic,pixeloffsetmodehalf);
    include(gpflags,gcf_gppenmode);
   end
   else begin
    gdipsetpixeloffsetmode(gpgraphic,pixeloffsetmodehalf);
    exclude(gpflags,gcf_gppenmode);
   end;
{
   gdipresetworldtransform(gpgraphic);
   if gcf_gppenmode in aflags then begin
    gdiptranslateworldtransform(gpgraphic,0.5,0.5,matrixorderprepend);
    include(gpflags,gcf_gppenmode);
   end
   else begin
    exclude(gpflags,gcf_gppenmode);
   end;
}
  end;
 end;
end;

function createregion: regionty; overload;
begin
{$ifdef mse_debuggdi}
 inc(regioncount);
{$endif}
 result:= createrectrgnindirect(trect(nullrect));
end;

function createregion(var rect: rectty; const gc: gcty): regionty; overload;
var
 rect1: rectty;
begin
{$ifdef mse_debuggdi}
 inc(regioncount);
{$endif}
 if win32gcty(gc.platformdata).d.kind = gck_printer then begin
  rect1:= rect;
  recttowinrect(rect1);
  lptodp(gc.handle,
     {$ifdef FPC}lppoint(@{$endif}rect1{$ifdef FPC}){$endif},2);
  result:= createrectrgnindirect(trect(rect1));   
 end
 else begin
  recttowinrect(rect);
  result:= createrectrgnindirect(trect(rect));
  winrecttorect(rect);
 end;
end;

procedure gdi_createemptyregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  dest:= createregion;
 end;
end;

procedure gdi_setcliporigin(var drawinfo: drawinfoty);
var
 reg1: hrgn;
 delta: pointty;
begin
 with drawinfo.gc,win32gcty(platformdata).d do begin
  delta:= subpoint(cliporigin,gccliporigin);
  if (delta.x <> 0) or (delta.y <> 0) then begin
   reg1:= createregion;
   if getcliprgn(handle,reg1) > 0 then begin
    offsetrgn(reg1,delta.x,delta.y);
    selectcliprgn(handle,reg1);
   end;
   deleteobject(reg1);
{$ifdef mse_debuggdi}
   dec(regioncount);
{$endif}
  end;
  gccliporigin:= cliporigin;
 end;
// gdierror(gde_notimplemented,'setcliporigin');
end;

procedure gdi_createrectregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  dest:= createregion(rect,drawinfo.gc);
 end;
end;

procedure gdi_createrectsregion(var drawinfo: drawinfoty);
var
 reg1: hrgn;
 int1: integer;
 rect1: rectty;
begin
 with drawinfo.regionoperation do begin
  dest:= createregion;
  if rectscount > 0 then begin
   if win32gcty(drawinfo.gc.platformdata).d.kind = gck_printer then begin
    for int1:= 0 to rectscount - 1 do begin
     rect1:= rectspo^[int1];
     recttowinrect(rect1);
     lptodp(drawinfo.gc.handle,
          {$ifdef FPC}lppoint(@{$endif}rect1{$ifdef FPC}){$endif},2);
     reg1:= createrectrgnindirect(trect(rect1));
     combinergn(dest,dest,reg1,rgn_or);
     deleteobject(reg1);
    end;
   end
   else begin
    recttowinrect(@rectspo^[0],rectscount);
    for int1:= 0 to rectscount - 1 do begin
     reg1:= createrectrgnindirect(trect(rectspo^[int1]));
     combinergn(dest,dest,reg1,rgn_or);
     deleteobject(reg1);
    end;
    winrecttorect(@rectspo^[0],rectscount);
   end;
  end;
 end;
end;

procedure gdi_destroyregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  if source <> 0 then begin
{$ifdef mse_debuggdi}
   dec(regioncount);
{$endif}
   deleteobject(source);
  end;
 end;
end;

procedure gdi_regionisempty(var drawinfo: drawinfoty);
var
 rect1: trect;
begin
 with drawinfo.regionoperation do begin
  if getrgnbox(source,rect1) = nullregion then begin
   dest:= 1;
  end
  else begin
   dest:= 0;
  end;
 end;
end;

procedure gdi_regionclipbox(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  getrgnbox(source,trect(rect));
  if win32gcty(drawinfo.gc.platformdata).d.kind = gck_printer then begin
   dptolp(drawinfo.gc.handle,
          {$ifdef FPC}lppoint(@{$endif}rect{$ifdef FPC}){$endif},2);
  end;
  winrecttorect(rect);
 end;
end;

procedure gdi_copyregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  if source = 0 then begin
   dest:= 0;
  end
  else begin
   dest:= createregion;
   combinergn(dest,source,0,rgn_copy);
  end;
 end;
end;

procedure gdi_moveregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  offsetrgn(source,rect.x,rect.y);
 end;
end;

procedure gdi_regsubrect(var drawinfo: drawinfoty);
var
 reg1: hrgn;
begin
 with drawinfo.regionoperation do begin
  reg1:= createregion(rect,drawinfo.gc);
  combinergn(dest,dest,reg1,rgn_diff);
  deleteobject(reg1);
{$ifdef mse_debuggdi}
  dec(regioncount);
{$endif}
 end;
end;

procedure gdi_regsubregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  combinergn(dest,dest,source,rgn_diff);
 end;
end;

procedure gdi_regaddrect(var drawinfo: drawinfoty);
var
 reg1: hrgn;
begin
 with drawinfo.regionoperation do begin
  reg1:= createregion(rect,drawinfo.gc);
  combinergn(dest,dest,reg1,rgn_or);
  deleteobject(reg1);
{$ifdef mse_debuggdi}
  dec(regioncount);
{$endif}
 end;
end;

procedure gdi_regaddregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  combinergn(dest,dest,source,rgn_or);
 end;
end;

procedure gdi_regintersectrect(var drawinfo: drawinfoty);
var
 reg1: hrgn;
begin
 with drawinfo.regionoperation do begin
  reg1:= createregion(rect,drawinfo.gc);
  combinergn(dest,dest,reg1,rgn_and);
  deleteobject(reg1);
{$ifdef mse_debuggdi}
  dec(regioncount);
{$endif}
 end;
end;

procedure gdi_regintersectregion(var drawinfo: drawinfoty);
begin
 with drawinfo.regionoperation do begin
  combinergn(dest,dest,source,rgn_and);
 end;
end;

var
 fgdipluschecked: boolean;
 fhasgdiplus: boolean;
  
procedure gdi_destroygc(var drawinfo: drawinfoty);
begin
 with drawinfo,gc,win32gcty(platformdata).d do begin
  selectobject(handle,nullpen);
  selectobject(handle,nullbrush);
{$ifdef mse_debuggdi}
  dec(gccount);
{$endif}
  if handle <> 0 then begin
   case kind of
    gck_pixmap,gck_printer: begin
 //   bmp1:= createcompatiblebitmap(handle,0,0);
 //   bmp2:= selectobject(handle,bmp1); //select actual bitmap out of dc
                                      //really needed?
    deletedc(handle);
 //   deleteobject(bmp1);
    end;
    gck_metafile: begin
     deleteenhmetafile(closeenhmetafile(handle));
    end
    else begin
     releasedc(paintdevice,handle);
    end;
   end;
  end;
  if backgroundbrush <> 0 then begin
   deleteobject(backgroundbrush);
   backgroundbrush:= 0;
  end;
  if colorbrush <> 0 then begin
   deleteobject(colorbrush);
   colorbrush:= 0;
  end;
  if patternbrush <> 0 then begin
   deleteobject(patternbrush);
   patternbrush:= 0;
  end;
  if foregroundpen <> 0 then begin
   deleteobject(foregroundpen);
   foregroundpen:= 0;
  end;
  selectedpen:= 0;
  selectedbrush:= 0;
  if fhasgdiplus then begin
   if gpgraphic <> nil then begin
    gdipdeletegraphics(gpgraphic);
    gpgraphic:= nil;
    gdipdeletebrush(pgpbrush(gpsolidfill));
    gdipdeletepen(gppen);
    if gpregion <> nil then begin
     gdipdeleteregion(gpregion);
     gpregion:= nil;
    end;
    if gptexture <> nil then begin
     gdipdeletebrush(pgpbrush(gptexture));
     gptexture:= nil;
    end;
    deletepgtexture(gc);
   end;
  end;
 end;
end;

function hasgdiplus: boolean;
begin
 if not fhasgdiplus and not fgdipluschecked then begin
  fgdipluschecked:= true;
  fhasgdiplus:= initializegdiplus([],true);
 end;
 result:= fhasgdiplus;
end;

procedure checkgdiplusgraphic(var drawinfo: drawinfoty);
var
 reg: hrgn;
 int1: int;
begin
 with drawinfo.gc,win32gcty(platformdata).d do begin
  if gpgraphic = nil then begin
   with gppalettedata do begin
    flags:= 0;
    count:= 2;
    val0:= 0;
    val1:= $ffffffff;
   end;
   reg:= createrectrgn(0,0,0,0);
   int1:= getcliprgn(handle,reg);
   selectcliprgn(handle,0); //use full paintdevice rect
   gdipcreatefromhdc(handle,@gpgraphic);
   if int1 > 0 then begin
    selectcliprgn(handle,reg);
   end;
   deleteobject(reg);
   if gpgraphic <> nil then begin
    gdipsetsmoothingmode(gpgraphic,smoothingmodeantialias);
    gdipsetpixeloffsetmode(gpgraphic,pixeloffsetmodehalf);
//    gdipsetpixeloffsetmode(gpgraphic,pixeloffsetmodenone);
    gdipcreatesolidfill(alphamax,@gpsolidfill);
    gdipcreatepen1(alphamax,1,unitpixel,@gppen);
    gpflags:= [];
//    gdipsetpenmode(gppen,penalignmentcenter);
   end;
  end;
 end;
end;

procedure gdi_changegc(var drawinfo: drawinfoty);
begin
 with drawinfo.gcvalues^,drawinfo.gc,win32gcty(platformdata).d do begin
  if gvm_colorbackground in mask then begin
   exclude(flags,gcf_backgroundbrushvalid);
   exclude(gpflags,gcf_gpbrushcolorvalid);
   backgroundcol:= colorbackground;
  end;
  if gvm_colorforeground in mask then begin
   flags:= flags - [gcf_colorbrushvalid,gcf_foregroundpenvalid];
   gpflags:= gpflags - [gcf_gpbrushcolorvalid,gcf_gppencolorvalid];
   foregroundcol:= colorforeground;
  end;
  if mask * [gvm_linewidth,gvm_dashes,gvm_capstyle,gvm_joinstyle] <> [] then begin
   exclude(flags,gcf_foregroundpenvalid);
   exclude(gpflags,gcf_gppenvalid);
   peninfo:= lineinfo;
   peninfo.width:= (peninfo.width + linewidthroundvalue) shr linewidthshift;
  end;
  if gvm_rasterop in mask then begin
   exclude(flags,gcf_rasterop);
   rop:= rasterop;
  end;
  if gvm_brush in mask then begin
   exclude(flags,gcf_patternbrushvalid);
//   exclude(gpflags,gcf_patternbrushvalid);
   bru:= tsimplebitmap1(brush).handle;
   deletepgtexture(drawinfo.gc); //resets vaildflags
  end;
  if gvm_brushorigin in mask then begin
   exclude(gpflags,gcf_gpbrushoriginvalid);
   brushorg:= brushorigin;
   setbrushorgex(handle,brushorigin.x,brushorigin.y,nil);
  end;
  if gvm_clipregion in mask then begin
   gccliporigin:= cliporigin;
   if ((cliporigin.x <> 0) or (cliporigin.y <> 0)) and (clipregion <> 0) then begin
    offsetrgn(clipregion,cliporigin.x,cliporigin.y);
    selectcliprgn(handle,clipregion);
    offsetrgn(clipregion,-cliporigin.x,-cliporigin.y);
   end
   else begin
    selectcliprgn(handle,clipregion);
   end;
   exclude(gpflags,gcf_gpregionvalid);
  end
  else begin
//   include(gpflags,gcf_gpregionvalid); //???
  end;
  if gvm_font in mask then begin
   selectobject(handle,font);
  end;
  if gvm_options in mask then begin
   if cao_smooth in options then begin
    if hasgdiplus then begin
     checkgdiplusgraphic(drawinfo);
     if gpgraphic <> nil then begin
      if not (gcf_smooth in flags) then begin
       gpflags:= gpflags - gpstartflags;
       include(flags,gcf_smooth);
      end;
     end;
    end;
   end
   else begin
    exclude(flags,gcf_smooth);
   end;
  end;
//  gpflags:= gpflags - ((flags >< flagsbefore)*flagsbefore);
                              //invalidate gdiplus
 end;
end;

procedure gdi_getcanvasclass(var drawinfo: drawinfoty); //gdifunc
begin
 //dummy
end;

procedure gdi_endpaint(var drawinfo: drawinfoty); //gdifunc
begin
 //dummy
end;

procedure gdi_flush(var drawinfo: drawinfoty); //gdifunc
begin
 with win32gcty(drawinfo.gc.platformdata).d do begin
  if gpgraphic <> nil then begin
   gdipflush(gpgraphic,flushintentionsync);
  end;
 end;
end;

procedure gdi_movewindowrect(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.moverect do begin
  gui_movewindowrect(drawinfo.paintdevice,dist^,rect^);  
 end;
end;

procedure gdi_drawlines(var drawinfo: drawinfoty);
var
 po1: ppointty;
 bo1: boolean;
begin
 transformpoints(drawinfo,false);
 if gcf_smooth in win32gcty(drawinfo.gc.platformdata).d.flags then begin
  checkgpgc(drawinfo.gc,gplineflags);
  with drawinfo,points,win32gcty(gc.platformdata).d do begin
   if closed then begin
    gdipdrawpolygoni(gpgraphic,gppen,buffer.buffer,count);
   end
   else begin
    gdipdrawlinesi(gpgraphic,gppen,buffer.buffer,count);
   end;
  end;
 end
 else begin
  with drawinfo,points do begin
   if closed then begin
    bo1:= checkgc(gc,[gcf_foregroundpenvalid,gcf_selectforegroundpen,
                         gcf_selectnullbrush]);
    windows.polygon(gc.handle,buffer.buffer^,count);
    if bo1 then begin
     checkgc2(gc);
     windows.polygon(gc.handle,buffer.buffer^,count);
    end;
   end
   else begin
    bo1:= checkgc(gc,[gcf_foregroundpenvalid,gcf_selectforegroundpen]);
    if ((win32gcty(gc.platformdata).d.peninfo.width <= 1) or
            (win32gcty(gc.platformdata).d.peninfo.capstyle = cs_butt)) and 
            (count > 0) then begin
     po1:= @pointarty(buffer.buffer)[count-1]; //endpoint
     if (po1^.x <> pointarty(buffer.buffer)[0].x) or
            (po1^.y <> pointarty(buffer.buffer)[0].y) then  begin
      adjustlineend(po1);
     end;
    end;
    windows.polyline(gc.handle,buffer.buffer^,count);
    if bo1 then begin
     checkgc2(gc);
     windows.polyline(gc.handle,buffer.buffer^,count);
    end;
   end;
  end;
 end;
end;

procedure gdi_drawlinesegments(var drawinfo: drawinfoty);
var
 int1,int2: integer;
 po1,po2: pdword;
 po3: ppointty;
 bo1: boolean;
begin
 with drawinfo,win32gcty(gc.platformdata).d do begin
  int1:= points.count div 2;
  allocbuffer(buffer,points.count*sizeof(pointty)+int1*sizeof(integer));
      //reserve memory
  transformpoints(drawinfo,false);
  po3:= buffer.buffer; //segments
  int1:= points.count div 2; //segmentcount
  if gcf_smooth in flags then begin
   checkgpgc(drawinfo.gc,gplineflags);
   for int2:= 0 to int1-1 do begin
    gdipdrawlinesi(gpgraphic,gppen,pointer(po3),2);
    inc(po3,2);
   end;
  end
  else begin
   po1:= pointer(pchar(buffer.buffer) + int1*sizeof(segmentty));
   inc(po3);            //segmentend
   po2:= po1;           //counts
   bo1:= (win32gcty(gc.platformdata).d.peninfo.width < 1);
   for int2:= 0 to int1 - 1 do begin
    if bo1 then begin
     adjustlineend(po3);
     inc(po3,2);
    end;
    po2^:= 2;
    inc(po2);
   end;
   bo1:= checkgc(gc,[gcf_foregroundpenvalid,gcf_selectforegroundpen]);
   windows.polyPolyline(gc.handle,buffer.buffer^,po1^,int1);
   if bo1 then begin
    checkgc2(gc);
    windows.polyPolyline(gc.handle,buffer.buffer^,po1^,int1);
   end;
  end;
 end;
end;

procedure gdi_drawellipse(var drawinfo: drawinfoty);
var
 bo1: boolean;
begin
 if gcf_smooth in win32gcty(drawinfo.gc.platformdata).d.flags then begin
  checkgpgc(drawinfo.gc,gplineflags);
  with drawinfo,rect.rect^,win32gcty(gc.platformdata).d do begin
   gdipdrawellipsei(gpgraphic,gppen,origin.x+x-cx div 2,
                              origin.y+y-cy div 2,cx,cy);
  end;
 end
 else begin
  transformellipseinfo(drawinfo,false);
  with drawinfo do begin
   bo1:= checkgc(gc,[gcf_foregroundpenvalid,gcf_selectforegroundpen,
                                                        gcf_selectnullbrush]);
   windows.ellipse(gc.handle,trect(buffer.buffer^).Left,
                             trect(buffer.buffer^).top,
                             trect(buffer.buffer^).right,
                             trect(buffer.buffer^).bottom);
   if bo1 then begin
    checkgc2(gc);
    windows.ellipse(gc.handle,trect(buffer.buffer^).Left,
                              trect(buffer.buffer^).top,
                              trect(buffer.buffer^).right,
                              trect(buffer.buffer^).bottom);
   end;
  end;
 end;
end;

procedure getarcinfo(const info: drawinfoty; 
                    out xstart,ystart,xend,yend: integer);
var
 stopang: real;
begin
 with info,arc,rect^ do begin
  stopang:= (startang+extentang);
  xstart:= (round(cos(startang)*cy) div 2) + x + origin.x;
  ystart:= (round(-sin(startang)*cy) div 2) + y + origin.y;
  xend:= (round(cos(stopang)*cy) div 2) + x + origin.x;
  yend:= (round(-sin(stopang)*cy) div 2) + y + origin.y;
 end;
end;

const
 radianttograd = -360.0/(2.0*pi);

type
 gparcinfoty = record
  rect: rectty;
  startang,extentang: real;
 end;
 
procedure adjustgparc(const drawinfo: drawinfoty; out ainfo: gparcinfoty);
begin
 with drawinfo,arc,rect^ do begin
  ainfo.rect.x:= x + origin.x - cx div 2;
  ainfo.rect.y:= y + origin.y - cy div 2;
  ainfo.rect.size:= size;
  ainfo.startang:= startang*radianttograd;
  ainfo.extentang:= extentang*radianttograd;
  {
  if extentang < 0 then begin
   startang:= startang+extentang;
   extentang:= -extentang;
  end;
  while startang < 0 do begin
   startang:= startang + 360;
  end;
  }
 end;
end;
 
procedure gdi_drawarc(var drawinfo: drawinfoty);
var                         //todo: optimize
 bo1: boolean;
 xstart,ystart,xend,yend: integer;
 arcinfo: gparcinfoty;
begin
 if gcf_smooth in win32gcty(drawinfo.gc.platformdata).d.flags then begin
  checkgpgc(drawinfo.gc,gplineflags);
  adjustgparc(drawinfo,arcinfo);
  with drawinfo,arcinfo,win32gcty(gc.platformdata).d do begin
   gdipdrawarci(gpgraphic,gppen,rect.x,rect.y,rect.cx,rect.cy,
                                                    startang,extentang);
  end;
 end
 else begin
  getarcinfo(drawinfo,xstart,ystart,xend,yend);
  with drawinfo,arc,rect^ do begin
   if (xstart = xend) and (ystart = yend) and (abs(extentang) < 1) then begin
    checkgc(gc,[gcf_foregroundpenvalid,gcf_selectforegroundpen,gcf_selectnullbrush]);
    movetoex(gc.handle,xstart,ystart,nil);
    if (win32gcty(gc.platformdata).d.peninfo.width = 0) {and 
            (win32gcty(gc.platformdata).peninfo.capstyle <> cs_butt)} then begin
     inc(xstart);
    end;
    lineto(gc.handle,xstart,ystart);
    exit;
   end;
   if extentang < 0 then begin
    setarcdirection(gc.handle,ad_clockwise);
   end
   else begin
    setarcdirection(gc.handle,ad_counterclockwise);
   end;
  end;
  transformellipseinfo(drawinfo,false);
  with drawinfo do begin
   bo1:= checkgc(gc,[gcf_foregroundpenvalid,gcf_selectforegroundpen,gcf_selectnullbrush]);
   windows.arc(gc.handle,trect(buffer.buffer^).Left,
                             trect(buffer.buffer^).top,
                             trect(buffer.buffer^).right,
                             trect(buffer.buffer^).bottom,
                             xstart,ystart,xend,yend);
   if bo1 then begin
    checkgc2(gc);
    windows.arc(gc.handle,trect(buffer.buffer^).Left,
                              trect(buffer.buffer^).top,
                              trect(buffer.buffer^).right,
                              trect(buffer.buffer^).bottom,
                              xstart,ystart,xend,yend);
   end;
  end;
 end;
end;

procedure gdi_drawstring16(var drawinfo: drawinfoty);
begin
 with drawinfo do begin
  updateopaquemode(gc);
  with gc,drawinfo.text16pos do begin
   windows.textoutw(handle,pos^.x + origin.x,pos^.y + origin.y,text,count);
  end;
 end;
end;

//todo!!!!!: support all rops on win95, test!!!

function win95maskblt(DestDC: HDC; XDest, YDest, Width, Height: Integer; SrcDC: HDC;
  XScr, YScr: Integer; Mask: HBITMAP; amaskdc: hdc; xMask, yMask: Integer; Rop: rasteropty): boolean;
var
 maskdc: hdc;
 bmp: hbitmap;
 dc: hdc;
 textcol,bkcol: longword;

 procedure getcopy(arop: rasteropty);
 begin
  textcol:= gettextcolor(destdc);
  bkcol:= getbkcolor(destdc);
  settextcolor(destdc,$ffffff);
  setbkcolor(destdc,$000000);
  bmp:= createcompatiblebitmap(destdc,width,height);
  dc:= createcompatibledc(destdc);
  selectobject(dc,bmp);
  settextcolor(dc,textcol);
  setbkcolor(dc,bkcol);
  bitblt(dc,0,0,width,height,srcdc,xscr,yscr,rasterops3[rop_copy]);
  settextcolor(dc,$ffffff);
  setbkcolor(dc,$000000);
  bitblt(dc,0,0,width,height,maskdc,xmask,ymask,rasterops3[arop]);
 end;

begin
 result:= true;
 bmp:= 0;
 if amaskdc = 0 then begin
  maskdc:= createcompatibledc(0);
  selectobject(maskdc,mask);
 end
 else begin
  maskdc:= amaskdc;
 end;
 case rop of
  rop_copy,rop_xor,rop_or: begin
   getcopy(rop_and);
   if rop = rop_copy then begin
    bitblt(destdc,xdest,ydest,width,height,maskdc,xmask,ymask,rasterops3[rop_notand]);
    settextcolor(destdc,textcol);
    setbkcolor(destdc,bkcol);
    bitblt(destdc,xdest,ydest,width,height,dc,0,0,rasterops3[rop_or]);
   end
   else begin
    settextcolor(destdc,textcol);
    setbkcolor(destdc,bkcol);
    bitblt(destdc,xdest,ydest,width,height,dc,0,0,rasterops3[rop]);
   end;
  end;
  rop_and: begin
   getcopy(rop_notor);
   settextcolor(destdc,textcol);
   setbkcolor(destdc,bkcol);
   bitblt(destdc,xdest,ydest,width,height,dc,0,0,rasterops3[rop]);
  end;
 end;
 if amaskdc = 0 then begin
  deletedc(maskdc);
 end;
 if bmp <> 0 then begin
  deletedc(dc);
  deleteobject(bmp);
 end;
end;

procedure fill(var drawinfo: drawinfoty; shape: shapety);

var
 xstart,ystart,xend,yend: integer; 
 
 procedure fill1( adc: hdc; arop: rasteropty);
 begin
  with drawinfo do begin
   if (shape <> fs_rect) and (shape <> fs_copyarea) then begin
    if df_canvasismonochrome in gc.drawingflags then begin
     setrop2(adc,inverserops2[arop]);
    end
    else begin
     setrop2(adc,rasterops2[arop]);
    end;
   end;
   if shape <> fs_copyarea then begin
    with win32gcty(gc.platformdata).d do begin
     if patternbrush <> 0 then begin
      selectobject(adc,patternbrush);
      if adc = gc.handle then begin
       selectedbrush:= patternbrush;
      end;
     end;
    end;
   end;
   case shape of
    fs_copyarea: begin
     with copyarea,sourcerect^ do begin
      if mask = nil then begin
       bitblt(adc,destrect^.x,destrect^.y,cx,cy,tcanvas1(source).fdrawinfo.gc.handle,x,y,rasterops3[arop]);
      end
      else begin
       if iswin95 or (win32gcty(gc.platformdata).d.kind = gck_printer) then begin
//        win95maskblt(adc,destrect^.x,destrect^.y,cx,cy,source^.gc.handle,
//                    x,y,mask,maskgchandle,x,y,arop);
        tcanvas1(mask.canvas).checkgcstate([cs_gc]);
        win95maskblt(adc,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,tsimplebitmap1(mask).handle,
                    tcanvas1(mask.canvas).fdrawinfo.gc.handle,x,y,arop);
       end
       else begin
        maskblt(adc,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,tsimplebitmap1(mask).handle,x,y,
                    makerop4(rasterops3[rop_nop],rasterops3[arop]));
       end;
      end;
     end;
    end;
    fs_rect: begin
     with prectty(buffer.buffer)^ do begin
      windows.patblt(adc,x,y,cx,cy,patrops3[arop]);
     end;
    end;
    fs_ellipse: begin
     with trect(buffer.buffer^) do begin
      windows.ellipse(adc,left,top,right,bottom);
     end;
    end;
    fs_arc: begin
     with trect(buffer.buffer^) do begin
      if arc.pieslice then begin
       windows.pie(adc,left,top,right,bottom,xstart,ystart,xend,yend);
      end
      else begin
       windows.chord(adc,left,top,right,bottom,xstart,ystart,xend,yend);
      end;
     end;
    end;
    fs_polygon: begin
     windows.Polygon(adc,buffer.buffer^,points.count);
    end;
   end;
  end;
 end;

var
 rect1,rect2: rectty;
 po1: ppointty;
 int1: integer;
 bmp: hbitmap;
 dc1: hdc;

begin
 if shape = fs_arc then begin
  getarcinfo(drawinfo,xstart,ystart,xend,yend);
 end;
 with drawinfo do begin
  with gc,win32gcty(platformdata).d do begin
   if (drawingflags * [df_monochrome,df_opaque,df_brush] = 
                                          [df_monochrome,df_brush]) then begin
    if shape <> fs_rect then begin
     if shape <> fs_copyarea then begin
      checkgc(gc,[gcf_patternbrushvalid,gcf_selectnullpen]);
      exclude(flags,gcf_rasterop);
     end;
    end
    else begin
     checkgc(gc,[gcf_patternbrushvalid]);
    end;
    if rop in [rop_or,rop_xor,rop_and,rop_copy,rop_set,rop_clear] then begin
     case rop of
      rop_or,rop_xor: begin
//       setbkcolor(handle,foregroundcol);
       settextcolor(handle,foregroundcol);
//       settextcolor(handle,$00000000);
       setbkcolor(handle,$00000000);
       fill1(handle,rop);
      end;
      rop_and: begin
//       setbkcolor(handle,foregroundcol);
       settextcolor(handle,foregroundcol);
//       settextcolor(handle,$00ffffff);
       setbkcolor(handle,$00ffffff);
       fill1(handle,rop_and);
      end;
      rop_set: begin
//       setbkcolor(handle,$00ffffff);
       settextcolor(handle,$00ffffff);
//       settextcolor(handle,$00000000);
       setbkcolor(handle,$00000000);
       fill1(handle,rop_or); //set pattern
      end
      else begin
//       setbkcolor(handle,$00000000);
       settextcolor(handle,$00000000);
//       settextcolor(handle,$00ffffff);
       setbkcolor(handle,$00ffffff);
       fill1(handle,rop_and);  //clear pattern
       if rop = rop_copy then begin
//        settextcolor(handle,$00000000);
        setbkcolor(handle,$00000000);
//        setbkcolor(handle,foregroundcol);
        settextcolor(handle,foregroundcol);
        fill1(handle,rop_or);  //fill pattern
       end;
      end;
     end;
    end
    else begin //buffer needed
     getclipbox(handle,trect(rect1));
     winrecttorect(rect1);
     if (shape = fs_rect) or (shape = fs_copyarea) then begin
      rect2:= prectty(buffer.buffer)^;
     end
     else begin
      rect2.x:= maxint;
      rect2.y:= maxint;
      rect2.cx:= minint;
      rect2.cy:= minint;
      case shape of           //calculate max. dims
       fs_polygon: begin
        po1:= buffer.buffer;
        for int1:= 0 to points.count - 1 do begin
         if po1^.x < rect2.x then begin
          rect2.x:= po1^.x;
         end;
         if po1^.x > rect2.cx then begin
          rect2.cx:= po1^.x;
         end;
         if po1^.y < rect2.y then begin
          rect2.y:= po1^.y;
         end;
         if po1^.y > rect2.cy then begin
          rect2.cy:= po1^.y;
         end;
         inc(po1);
        end;
       end;
      end;
      winrecttorect(rect2);
     end;
     if msegraphutils.intersectrect(rect1,rect2,rect1) then begin
//      bmp:= gui_createpixmap(rect1.size,0,df_canvasismonochrome in drawingflags);
      bmp:= gui_createpixmap(rect1.size,0,gc.kind);
      if bmp <> 0 then begin
       dc1:= createcompatibledc(0);
       if dc1 <> 0 then begin
        selectobject(dc1,bmp);
        setwindoworgex(dc1,rect1.x,rect1.y,nil);
        bitblt(dc1,rect1.x,rect1.y,rect1.cx,rect1.cy,handle,rect1.x,rect1.y,srccopy); //get copy
        setbrushorgex(dc1,brushorg.x-rect1.x,brushorg.y-rect1.y,nil);
        settextcolor(dc1,foregroundcol);
        setbkcolor(dc1,backgroundcol);
        fill1(dc1,rop);                //draw pattern
        settextcolor(dc1,$00000000);
        setbkcolor(dc1,$00ffffff);
        fill1(dc1,rop_notand);         //erase background
        settextcolor(handle,$00000000);
        setbkcolor(handle,$00ffffff);
        fill1(handle,rop_and);         //erase pattern
        bitblt(handle,rect1.x,rect1.y,rect1.cx,rect1.cy,dc1,rect1.x,rect1.y,
                    rasterops3[rop_or]); //combine
        deletedc(dc1);
       end;
       gui_freepixmap(bmp);
      end;
     end;
    end;
   end
   else begin
    if df_opaque in drawingflags then begin
//     settextcolor(handle,backgroundcol);
     setbkcolor(handle,backgroundcol);
//     setbkcolor(handle,foregroundcol);
     settextcolor(handle,foregroundcol);
    end;
    if shape <> fs_rect then begin
     checkgc(gc,[gcf_colorbrushvalid,gcf_patternbrushvalid,
                            gcf_selectforegroundbrush,gcf_selectnullpen]);
    end;
    case shape of
     fs_rect: begin
      with prectty(buffer.buffer)^ do begin
       if (df_brush in drawingflags) then begin
        checkgc(gc,[gcf_colorbrushvalid,gcf_patternbrushvalid,
                             gcf_selectforegroundbrush]);
        windows.patblt(handle,x,y,cx,cy,patrops3[rop]);
       end
       else begin
        if  rop = rop_copy then begin
         checkgc(gc,[gcf_colorbrushvalid]);
         {$ifdef FPC}
         winfillrect(handle,mrect(x,y,x+cx,y+cy),colorbrush);
         {$else}
         windows.fillrect(handle,mrect(x,y,x+cx,y+cy),colorbrush);
         {$endif}
        end
        else begin
         checkgc(gc,[gcf_colorbrushvalid,gcf_selectforegroundbrush]);
         windows.patblt(handle,x,y,cx,cy,patrops3[rop]);
        end;
       end;
      end;
     end;
     fs_ellipse: begin
      with trect(buffer.buffer^) do begin
       windows.ellipse(gc.handle,left,top,right,bottom);
      end;
     end;
     fs_arc: begin
      with trect(buffer.buffer^) do begin
       if arc.pieslice then begin
        windows.pie(gc.handle,left,top,right,bottom,xstart,ystart,xend,yend);
       end
       else begin
        windows.chord(gc.handle,left,top,right,bottom,xstart,ystart,xend,yend);
       end;
      end;
     end;
     fs_polygon: begin
      windows.Polygon(gc.handle,buffer.buffer^,points.count);
     end;
    end;
   end;
  end;
 end;
end;

procedure gdi_fillrect(var drawinfo: drawinfoty);
begin
 offsetrect(drawinfo);
 fill(drawinfo,fs_rect);
end;

procedure gdi_fillellipse(var drawinfo: drawinfoty);
begin
 if gcf_smooth in win32gcty(drawinfo.gc.platformdata).d.flags then begin
  checkgpgc(drawinfo.gc,gpfillflags);
  with drawinfo,rect.rect^,win32gcty(gc.platformdata).d do begin
   gdipfillellipsei(gpgraphic,gpbrush,origin.x+x-cx div 2,
                              origin.y+y-cy div 2,cx,cy);
  end;
 end
 else begin
  transformellipseinfo(drawinfo,true);
  fill(drawinfo,fs_ellipse);
 end;
end;

procedure gdi_fillarc(var drawinfo: drawinfoty);
var
 pa1: pGpPath;
 arc1: gparcinfoty;
begin
 if gcf_smooth in win32gcty(drawinfo.gc.platformdata).d.flags then begin
  checkgpgc(drawinfo.gc,gpfillflags);
  adjustgparc(drawinfo,arc1);
  with drawinfo,arc1,win32gcty(gc.platformdata).d do begin
   if arc.pieslice then begin
    gdipfillpiei(gpgraphic,gpbrush,
           rect.x,rect.y,rect.cx,rect.cy,startang,extentang);
   end
   else begin
    gdipcreatepath(fillmodealternate,@pa1);
    gdipaddpatharc(pa1,rect.x,rect.y,rect.cx,rect.cy,startang,extentang);
    gdipfillpath(gpgraphic,gpbrush,pa1);
    gdipdeletepath(pa1);
   end;
  end;
 end
 else begin
  transformellipseinfo(drawinfo,true);
  fill(drawinfo,fs_arc);
 end;
end;

procedure gdi_fillpolygon(var drawinfo: drawinfoty);
begin
 transformpoints(drawinfo,false);
 with win32gcty(drawinfo.gc.platformdata).d do begin
  if gcf_smooth in flags then begin
   checkgpgc(drawinfo.gc,gpfillflags);
   gdipfillpolygon2i(gpgraphic,gpbrush,drawinfo.buffer.buffer,
                                                    drawinfo.points.count);   
  end
  else begin
   fill(drawinfo,fs_polygon);
  end;
 end;
end;

procedure gdi_copyarea(var drawinfo: drawinfoty);

var
 maskbmp,stretchedbmp: pixmapty;
 smaskdc,destdc: hdc;
 bufferbmp: hbitmap;
 rect1: rectty;
 nomaskblt: boolean;

 procedure setintpolmode(const ahandle: hdc);
 var
  pt1: tpoint;
 begin
  with drawinfo.copyarea do begin
   if (al_intpol in alignment) and not iswin95 then begin
    getbrushorgex(ahandle,pt1);
    setstretchbltmode(ahandle,halftone);
    setbrushorgex(ahandle,pt1.x,pt1.y,nil);
   end
   else begin
    if al_or in alignment then begin
     setstretchbltmode(ahandle,blackonwhite);
    end
    else begin
     if al_and in alignment then begin
      setstretchbltmode(ahandle,whiteonblack);
     end
     else begin
      setstretchbltmode(ahandle,coloroncolor);
     end;
    end;
   end;
  end;
 end;
 
 procedure getstretchedbmps;
 var
  po1: pointty;
 begin
  with drawinfo,copyarea,sourcerect^,gc do begin
   po1.x:= destrect^.x - rect1.x;
   po1.y:= destrect^.y - rect1.y;
   if mask <> nil then begin
    tcanvas1(mask.canvas).checkgcstate([cs_gc]);
    smaskdc:= tcanvas1(mask.canvas).fdrawinfo.gc.handle;
    maskbmp:= gui_createpixmap(rect1.size,0,bmk_mono);
//    maskbmp:= gui_createpixmap(rect1.size,0,true);
   end
   else begin
    maskbmp:= 0;
   end;
   stretchedbmp:= createcompatiblebitmap(tcanvas1(source).fdrawinfo.gc.handle,
                                                              rect1.cx,rect1.cy);
   destdc:= createcompatibledc(0);
   setintpolmode(destdc);
   if mask <> nil then begin
    selectobject(destdc,maskbmp);
    stretchblt(destdc,po1.x,po1.y,destrect^.cx,destrect^.cy,smaskdc,
                   x,y,cx,cy,rasterops3[rop_copy]);
   end;
   selectobject(destdc,stretchedbmp);
   stretchblt(destdc,po1.x,po1.y,destrect^.cx,destrect^.cy,
                  tcanvas1(source).fdrawinfo.gc.handle,
                  x,y,cx,cy,rasterops3[rop_copy]);
  end;
 end;

 procedure deletestretchedbmps;
 begin
  if maskbmp <> 0 then begin
   if bufferbmp = 0 then begin
    gui_freepixmap(maskbmp);
//    deleteobject(maskbmp);
   end;
  end;
  deletedc(destdc);
  deleteobject(stretchedbmp);
 end;

 procedure transfer(double: boolean = false);
 begin
  with drawinfo,copyarea,sourcerect^,gc,win32gcty(platformdata).d do begin
   if alignment * [al_stretchx,al_stretchy] = [] then begin
    if mask = nil then begin
     bitblt(handle,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,rasterops3[copymode]);
     if double then begin
      setbkcolor(handle,$000000);
      settextcolor(handle,foregroundcol);
      bitblt(handle,destrect^.x,destrect^.y,cx,cy,
                     tcanvas1(source).fdrawinfo.gc.handle,
                     x,y,rasterops3[rop_or]);
     end;
    end
    else begin
     if nomaskblt then begin
      tcanvas1(mask.canvas).checkgcstate([cs_gc]);
      win95maskblt(handle,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,tsimplebitmap1(mask).fhandle,
                    tcanvas1(mask.canvas).fdrawinfo.gc.handle,x,y,copymode);
     end
     else begin
      maskblt(handle,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,tsimplebitmap1(mask).handle,x,y,
                    makerop4(rasterops3[rop_nop],rasterops3[copymode]));
     end;
     if double then begin
      setbkcolor(handle,$000000);
      settextcolor(handle,foregroundcol);
      if nomaskblt then begin
       win95maskblt(handle,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,tsimplebitmap1(mask).fhandle,
                    tcanvas1(mask.canvas).fdrawinfo.gc.handle,x,y,rop_or);
      end
      else begin
       maskblt(handle,destrect^.x,destrect^.y,cx,cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,tsimplebitmap1(mask).fhandle,x,y,
                    makerop4(rasterops3[rop_nop],rasterops3[rop_or]));
      end;
     end;
    end;
   end
   else begin
    if mask = nil then begin
     stretchblt(handle,destrect^.x,destrect^.y,destrect^.cx,destrect^.cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,cx,cy,rasterops3[copymode]);
     if double then begin
      setbkcolor(handle,$000000);
      settextcolor(handle,foregroundcol);
      stretchblt(handle,destrect^.x,destrect^.y,destrect^.cx,destrect^.cy,
                    tcanvas1(source).fdrawinfo.gc.handle,
                    x,y,cx,cy,rasterops3[rop_or]);
     end;
    end
    else begin
     getstretchedbmps;
     if nomaskblt then begin
      win95maskblt(handle,rect1.x,rect1.y,rect1.cx,rect1.cy,destdc,
                    0,0,maskbmp,0,0,0,copymode);
     end
     else begin
      maskblt(handle,rect1.x,rect1.y,rect1.cx,rect1.cy,destdc,
                    0,0,maskbmp,0,0,makerop4(rasterops3[rop_nop],rasterops3[copymode]));
     end;
     if double then begin
      setbkcolor(handle,$000000);
      settextcolor(handle,foregroundcol);
      if nomaskblt then begin
       win95maskblt(handle,rect1.x,rect1.y,rect1.cx,rect1.cy,destdc,
                    0,0,maskbmp,0,0,0,rop_or);
      end
      else begin
       maskblt(handle,rect1.x,rect1.y,rect1.cx,rect1.cy,destdc,
                    0,0,maskbmp,0,0,makerop4(rasterops3[rop_nop],rasterops3[rop_or]));
      end;
     end;
     deletestretchedbmps;
    end;
   end;
  end;
 end;

var
 ropbefore: rasteropty;
 destdcbefore: hdc;
 destpointbefore: pointty;
 rect1posbefore: pointty;
 destbmp,colormaskbmp: hbitmap;
 destbmpdc,maskdc,colormaskdc: hdc;
 destimage,sourceimage,colormaskimage: imagety;
 rs,gs,bs,rd,gd,bd: integer;
 int1: integer;
 colormask: tsimplebitmap1;
 bufferbmpback: hbitmap;
// point1: tpoint;
 maskbefore: tsimplebitmap; 
begin
 with drawinfo,copyarea,gc,win32gcty(platformdata).d do begin
  
  nomaskblt:= iswin95 or (kind = gck_printer);
  setintpolmode(handle);
  getclipbox(handle,trect(rect1));
  winrecttorect(rect1);
  intersectrect(destrect^,rect1,rect1);
  maskbefore:= mask;
  if (mask <> nil) and (mask.kind <> bmk_mono) then begin
   colormask:= tsimplebitmap1(mask);
   mask:= nil;
  end
  else begin
   colormask:= nil;
  end;
  if ((longword(opacity) <> maxopacity) or (colormask <> nil))
               and not (df_canvasismonochrome in drawingflags) then begin
   maskbmp:= 0;
   destdcbefore:= handle;
   destpointbefore:= destrect^.pos;
   bufferbmp:= createcompatiblebitmap(handle,rect1.cx,rect1.cy);
   destrect^.pos:= subpoint(destrect^.pos,rect1.pos);
   handle:= createcompatibledc(0);
   setintpolmode(handle);
   selectobject(handle,bufferbmp);
   rect1posbefore:= rect1.pos;
   rect1.pos:= nullpoint;
  end
  else begin
   bufferbmp:= 0;
   destdcbefore:= 0; //compilerwarning
  end;
  if df_colorconvert in drawingflags then begin
   if df_canvasismonochrome in drawingflags then begin
               //convert to monochrome
    setbkcolor(tcanvas1(source).fdrawinfo.gc.handle,transparentcolor);
//    copymode:= rasteropty(inverserops[copymode]);
    transfer;
   end
   else begin
               //convert from monochrome
    if not (df_opaque in drawingflags) then begin
     if copymode = rop_xor then begin
      setbkcolor(handle,$000000);
      settextcolor(handle,foregroundcol);
      transfer;
     end
     else begin
      ropbefore:= copymode;
      setbkcolor(handle,$ffffff);
      settextcolor(handle,$000000);
      copymode:= rop_and;
      transfer(true);
      copymode:= ropbefore;
     end;
//      fill(drawinfo,fs_copyarea);
    end
    else begin
//     settextcolor (handle,backgroundcol);
     setbkcolor(handle,backgroundcol);
//     setbkcolor(handle,foregroundcol);
     settextcolor(handle,foregroundcol);
//     settextcolor(handle,$00ffffff);
     transfer;
    end;
   end;
  end
  else begin //no colorconvert
   if df_canvasismonochrome in drawingflags then begin
    setbkcolor(handle,$ffffff);
    settextcolor(handle,$000000);
//    setbkcolor(handle,backgroundcol);
//    settextcolor(handle,foregroundcol);
   end;
   transfer;
  end;
  if bufferbmp <> 0 then begin //alpha operation  //todo: optimze
   rect1.pos:= rect1posbefore;
   destbmp:= createcompatiblebitmap(handle,rect1.cx,rect1.cy);
   destbmpdc:= createcompatibledc(0);
   setintpolmode(destbmpdc);
   selectobject(destbmpdc,destbmp);
   bitblt(destbmpdc,0,0,rect1.cx,rect1.cy,destdcbefore,rect1.x,rect1.y,srccopy);
   gui_pixmaptoimage(destbmp,destimage,destbmpdc);
   gui_pixmaptoimage(bufferbmp,sourceimage,handle);
   if colormask = nil then begin
    rs:= (opacity.red*256 + 128) div 255;
    gs:= (opacity.green*256 + 128) div 255;
    bs:= (opacity.blue*256 + 128) div 255;
    rd:= 256-rs;
    gd:= 256-gs;
    bd:= 256-bs;
    for int1:= 0 to destimage.length - 1 do begin
     with rgbtriplety(destimage.pixels^[int1]) do begin
      red:= (rd*red + rs*rgbtriplety(sourceimage.pixels^[int1]).red) shr 8;
      green:= (gd*green + gs*rgbtriplety(sourceimage.pixels^[int1]).green) shr 8;
      blue:= (bd*blue + bs*rgbtriplety(sourceimage.pixels^[int1]).blue) shr 8;
     end;
    end;
   end
   else begin
    colormaskbmp:= createcompatiblebitmap(handle,rect1.cx,rect1.cy);
    colormaskdc:= createcompatibledc(0);
    setintpolmode(colormaskdc);
    selectobject(colormaskdc,colormaskbmp);
    tcanvas1(colormask.canvas).checkgcstate([cs_gc]);
    with sourcerect^ do begin
     stretchblt(colormaskdc,destrect^.x,destrect^.y,destrect^.cx,destrect^.cy,
      tcanvas1(colormask.canvas).fdrawinfo.gc.handle,x,y,cx,cy,
                                  rasterops3[rop_copy]);
    end;
    gui_pixmaptoimage(colormaskbmp,colormaskimage,colormaskdc);
    for int1:= 0 to destimage.length - 1 do begin
     with rgbtriplety(destimage.pixels[int1]) do begin
      red:=   (byte(255 - rgbtriplety(colormaskimage.pixels^[int1]).red) * red +
               rgbtriplety(colormaskimage.pixels^[int1]).red *
                rgbtriplety(sourceimage.pixels^[int1]).red) div byte(255);
      green:= (byte(255 - rgbtriplety(colormaskimage.pixels^[int1]).green) * green +
               rgbtriplety(colormaskimage.pixels^[int1]).green *
                rgbtriplety(sourceimage.pixels^[int1]).green) div byte(255);
      blue:=  (byte(255 - rgbtriplety(colormaskimage.pixels^[int1]).blue) * blue +
               rgbtriplety(colormaskimage.pixels^[int1]).blue *
                rgbtriplety(sourceimage.pixels^[int1]).blue) div byte(255);
     end;
    end;
    gui_freeimagemem(colormaskimage.pixels);
    deletedc(colormaskdc);
    deleteobject(colormaskbmp);
   end;
   bufferbmpback:= bufferbmp;
   gui_imagetopixmap(destimage,pixmapty(bufferbmp),handle);
//{$ifdef mse_debuggdi}
//   dec(pixmapcount);
//{$endif}
   gui_freeimagemem(destimage.pixels);
   gui_freeimagemem(sourceimage.pixels);
   if mask <> nil then begin
    if maskbmp <> 0 then begin
     if nomaskblt then begin
      maskdc:= createcompatibledc(0);
      selectobject(maskdc,maskbmp);
      settextcolor(destdcbefore,$000000);
      setbkcolor(destdcbefore,$ffffff);
      bitblt(destdcbefore,rect1.x,rect1.y,rect1.cx,rect1.cy,
                maskdc,0,0,rasterops3[rop_and]);
      settextcolor(handle,$ffffff);
      setbkcolor(handle,$000000);
      bitblt(handle,0,0,rect1.cx,rect1.cy,maskdc,rect1.x,rect1.y,rasterops3[rop_and]);
      bitblt(destdcbefore,rect1.x,rect1.y,rect1.cx,rect1.cy,
                handle,0,0,rasterops3[rop_or]);
      deletedc(maskdc);
     end
     else begin
      maskblt(destdcbefore,rect1.x,rect1.y,
                  rect1.cx,rect1.cy,handle,0,0,maskbmp,0,0,
                      makerop4(rasterops3[rop_nop],srccopy));
     end;
     deleteobject(maskbmp);
    end
    else begin
     if nomaskblt then begin
      tcanvas1(mask.canvas).checkgcstate([cs_gc]);
      smaskdc:= tcanvas1(mask.canvas).fdrawinfo.gc.handle;
      settextcolor(destdcbefore,$000000);
      setbkcolor(destdcbefore,$ffffff);
      bitblt(destdcbefore,rect1.x,rect1.y,rect1.cx,rect1.cy,
                smaskdc,sourcerect^.x-destrect^.x,
                sourcerect^.y-destrect^.y,rasterops3[rop_and]);
      settextcolor(handle,$ffffff);
      setbkcolor(handle,$000000);
      bitblt(handle,0,0,destrect^.cx,destrect^.cy,smaskdc,
                    sourcerect^.x-destrect^.x,sourcerect^.y-destrect^.y,
                    rasterops3[rop_and]);
      bitblt(destdcbefore,rect1.x,rect1.y,rect1.cx,rect1.cy,
                handle,0,0,rasterops3[rop_or]);
     end
     else begin
      maskblt(destdcbefore,rect1.x,rect1.y,
                rect1.cx,rect1.cy,handle,
                    0,0,tsimplebitmap1(mask).handle,
                    sourcerect^.x-destrect^.x,sourcerect^.y-destrect^.y,
                    makerop4(rasterops3[rop_nop],srccopy));
     end;
    end;
   end
   else begin
    bitblt(destdcbefore,rect1.x,rect1.y,rect1.cx,
                 rect1.cy,handle,0,0,srccopy);
   end;
   deletedc(handle);
//   deleteobject(bufferbmp);
   gui_freepixmap(bufferbmp);
   deleteobject(bufferbmpback);
   handle:= destdcbefore;
   destrect^.pos:= destpointbefore;
   deletedc(destbmpdc);
   deleteobject(destbmp);
  end;
  mask:= maskbefore;
 end;
end;

procedure gdi_getimage(var drawinfo: drawinfoty); //gdifunc
begin
 //dummy
end;

procedure gdi_fonthasglyph(var drawinfo: drawinfoty);
begin
 with drawinfo,fonthasglyph do begin
  hasglyph:= true;
 end;
end;

var
 defaultfontinfo: logfont;
type
 charsetinfoty = record
  name: string;
  code: integer;
 end;
 charsetinfoaty = array[0..18] of charsetinfoty;

const
 charsets: charsetinfoaty = (
  (name: 'ANSI'; code: 0),
  (name: 'DEFAULT'; code: 1),
  (name: 'SYMBOL'; code: 2),
  (name: 'SHIFTJIS'; code: $80),
  (name: 'HANGEUL'; code: 129),
  (name: 'GB2312'; code: 134),
  (name: 'CHINESEBIG5'; code: 136),
  (name: 'OEM'; code: 255),
  (name: 'JOHAB'; code: 130),
  (name: 'HEBREW'; code: 177),
  (name: 'ARABIC'; code: 178),
  (name: 'GREEK'; code: 161),
  (name: 'TURKISH'; code: 162),
  (name: 'VIETNAMESE'; code: 163),
  (name: 'THAI'; code: 222),
  (name: 'EASTEUROPE'; code: 238),
  (name: 'RUSSIAN'; code: 204),
  (name: 'MAC'; code: 77),
  (name: 'BALTIC'; code: 186));
  
type
 pboolean = ^boolean;

{$ifdef FPC}
function fontenumcallback(var _para1:ENUMLOGFONTEX;
       var _para2:NEWTEXTMETRICEX; _para3:longint; _para4:LPARAM):longint; stdcall;
{$else}
function fontenumcallback(var _para1:ENUMLOGFONTEX;
       var _para2:TNEWTEXTMETRICEXa; _para3:longint; _para4:LPARAM):longint; stdcall;
{$endif}
begin
 pboolean(_para4)^:= true;
 result:= 0;
end;


procedure gdi32initdefaultfont;
var
 dc1: hdc;
 bo1: boolean;
begin
 fillchar(defaultfontinfo,sizeof(defaultfontinfo),0);
 defaultfontinfo.lfHeight:= -11;
 bo1:= false;
 defaultfontinfo.lfFaceName:= defaultfontname;
 dc1:= getdc(0);
 {$ifdef FPC}
 enumfontfamiliesex(dc1,@defaultfontinfo,@fontenumcallback,ptruint(@bo1),0);
 {$else}
 enumfontfamiliesex(dc1,defaultfontinfo,@fontenumcallback,ptruint(@bo1),0);
 {$endif}
 if not bo1 then begin
  defaultfontinfo.lfFaceName:= 'MS Sans Serif';
 end;
 releasedc(0,dc1);
end;

function dogetfont(var drawinfo: drawinfoty; const ahighres: boolean): boolean;

var
 dc1: hdc;  //printer gc is invalid -> create temporary gc
 fontbefore: hfont;
 font1: hfont;

 procedure closedc;
 begin
  selectobject(dc1,fontbefore);
  releasedc(0,dc1);
  with drawinfo.getfont.fontdata^ do begin
   if (font1 <> font) and (font1 <> fonthighres) then begin
    deleteobject(font1);
   end;
  end;
 end;
  
var
 fontinfo1: logfont;
// textmetricsw: ttextmetricw;
 textmetricsa: ttextmetrica;
 str1: string;
 int1: integer;
// ar1: array[0..255] of abc;
 height1,width1: integer;
 rea1: real;

label
 endlab;
  
begin
 result:= false;
 with drawinfo.getfont.fontdata^ do begin
  height1:= (h.d.height + fontsizeroundvalue) shr fontsizeshift;
  width1:= (h.d.width + fontsizeroundvalue) shr fontsizeshift;
  fontinfo1:= defaultfontinfo;
  with fontinfo1 do begin
   if height1 <> 0 then begin
    lfheight:= -height1; //use character height
   end;
   if h.d.xscale = 1 then begin
    if width1 <> 0 then begin
     lfwidth:= (width1 + 5) div 10;
     if lfwidth = 0 then begin
      lfwidth:= 1;
     end;
     lfoutprecision:= out_tt_only_precis;
    end;
   end;
   if fs_bold in h.d.style then begin
    lfweight:= fw_bold;
   end;
   if fs_italic in h.d.style then begin
    lfitalic:= 1;
   end;
   if (h.d.pitchoptions <> []) or (h.d.familyoptions <> []) then begin
    lffacename[0]:= #0;
   end
   else begin
    if (h.name <> '') then begin
     strlcopy(@lffacename,pchar(h.name),sizeof(lffacename)-1);
    end;
   end;
   if h.charset <> '' then begin
    str1:= uppercase(h.charset);
    for int1:= 0 to high(charsets) do begin
     if charsets[int1].name = str1 then begin
      lfcharset:= charsets[int1].code;
      break;
     end;
    end;
   end;
   if foo_fixed in h.d.pitchoptions then begin
    lfpitchandfamily:= lfpitchandfamily or fixed_pitch;
   end
   else begin
    if foo_proportional in h.d.pitchoptions then begin
     lfpitchandfamily:= lfpitchandfamily or variable_pitch;
    end
   end;
   if foo_helvetica in h.d.familyoptions then begin
    lfpitchandfamily:= lfpitchandfamily or ff_swiss;
   end
   else begin
    if foo_roman in h.d.familyoptions then begin
     lfpitchandfamily:= lfpitchandfamily or ff_roman;
    end
    else begin
     if foo_script in h.d.familyoptions then begin
      lfpitchandfamily:= lfpitchandfamily or ff_script;
     end
     else begin
      if foo_decorative in h.d.familyoptions then begin
       lfpitchandfamily:= lfpitchandfamily or ff_decorative;
      end
     end;
    end;
   end;
   if (foo_antialiased2 in h.d.antialiasedoptions) then begin
    if cancleartype then begin
     lfquality:= cleartype_quality;
    end
    else begin
     lfquality:= antialiased_quality;
    end;
   end
   else begin
    if foo_antialiased in h.d.antialiasedoptions then begin
     lfquality:= antialiased_quality;
    end
    else begin
     if foo_nonantialiased in h.d.antialiasedoptions then begin
      lfquality:= nonantialiased_quality;
     end;
    end;
   end;
   if h.d.rotation <> 0 then begin
    int1:= round(h.d.rotation*((10*360)/(2*pi)));
    lfescapement:= int1;
    lforientation:= int1;
    lfoutprecision:= out_tt_only_precis;
   end;
   if ahighres then begin
    lfheight:= lfheight * highresfontfakt;
    lfwidth:= lfwidth * highresfontfakt;
   end;
   
   font1:= createfontindirect({$ifdef FPC}@{$endif}fontinfo1);
  end;
  if font1 = 0 then begin
   fontinfo1.lfFaceName:= defaultfontinfo.lfFaceName;
   font1:= createfontindirect({$ifdef FPC}@{$endif}fontinfo1);
   if font1 = 0 then begin
    if ahighres then begin
     exit; //no highres font available
    end;
    font1:= createfontindirect({$ifdef FPC}@{$endif}defaultfontinfo);
   end;
  end;
  if font1 <> 0 then begin
   dc1:= getdc(0);
   fontbefore:= selectobject(dc1,font1);
   if not gettextmetricsa(dc1,{$ifdef FPC}@{$endif}textmetricsa) then begin
    goto endlab;
   end;
   if h.d.xscale <> 1 then begin
    closedc;
    int1:= h.d.width;
    rea1:= h.d.xscale;
    with win32fontdataty(platformdata) do begin
     if ahighres then begin
      fontinfo1.lfwidth:= ((xwidth+5) div 10) shl highresfontshift;
      //round up
      fonthighres:= createfontindirect({$ifdef FPC}@{$endif}fontinfo1);
      result:= fonthighres <> 0;
     end
     else begin
      xwidth:= round(h.d.xscale * textmetricsa.tmavecharwidth*10);
      h.d.width:= xwidth shl fontsizeshift; 
      h.d.xscale:= 1.0;
      result:= dogetfont(drawinfo,false);
     end;
    end;
    h.d.width:= int1;  //restore
    h.d.xscale:= rea1; 
    exit;
   end;
   with win32fontdataty(platformdata) do begin
    if ahighres then begin
     fonthighres:= font1;
     goto endlab;
    end;
    font:= font1;
    ascent:= textmetricsa.tmAscent;
    descent:= textmetricsa.tmDescent;
    linespacing:= textmetricsa.tmheight + textmetricsa.tmexternalleading;
    realheight:= textmetricsa.tmheight;
    overhang:= textmetricsa.tmOverhang;
    if textmetricsa.tmpitchandfamily and tmpf_truetype <> 0 then begin
     caretshift:= 0;
    end
    else begin
     caretshift:= 1;
    end;
    if iswin95 then begin
     new(charwidths);
    (*
     if false {getcharabcwidths(dc1,0,255,ar1)} then begin
      for int1:= 0 to high(ar1) do begin
       with ar1[int1] do begin
        charwidths^[int1]:= abca + integer(abcb) + abcc;
       end;
      end;
     end
     else begin      //no truetype font
     *)
      if not getcharwidthw(dc1,0,255,charwidths^) then begin
       dispose(charwidths);
       goto endlab;
      end;
      if Overhang <> 0 then begin
       for int1:= 0 to high(charwidths^) do begin
        dec(charwidths^[int1],Overhang);
       end;
      end;
//     end;
    end
    else begin
    {
     new(charwidths);
     if not getcharwidth32w(dc1,0,255,charwidths^) then begin
      dispose(charwidths);
      closedc;
      exit;
     end;
    }
    end;
   end;
   result:= true;
  end;
 end;
endlab:
{$ifdef mse_debuggdi}
 if result then begin
  inc(fontcount);
 end;
{$endif}
 closedc; 
end;

procedure gdi_getfonthighres(var drawinfo: drawinfoty);
begin
 dogetfont(drawinfo,true);
end;

procedure gdi_getfont(var drawinfo: drawinfoty);
begin
 drawinfo.getfont.ok:= dogetfont(drawinfo,false);
end;

procedure gdi_freefontdata(var drawinfo: drawinfoty);
begin
 with drawinfo.getfont.fontdata^,win32fontdataty(platformdata) do begin
  if charwidths <> nil then begin
   dispose(charwidths);
  end;
  if font <> 0 then begin
{$ifdef mse_debuggdi}
   dec(fontcount);
{$endif}
   deleteobject(font);
  end;
  if fonthighres <> 0 then begin
{$ifdef mse_debuggdi}
   dec(fontcount);
{$endif}
   deleteobject(fonthighres);
  end;
 end;
end;

procedure gdi_gettext16width(var drawinfo: drawinfoty);
label                     //todo: kerning?
 endlab;
var
 int1,int2: integer;
 po1: pmsechar;
 wo1: word;
 widths: pcharwidthsty;
 overha: integer;
 fh1: hfont;
 gc1: hdc;
 gcpresults: tgcpresultsw;
begin
 with drawinfo.gettext16width do begin
  if drawinfo.gc.handle = invalidgchandle then begin
   gc1:= getdc(0);  //use default dc
  end
  else begin
   gc1:= drawinfo.gc.handle;
  end;
  fh1:= selectobject(gc1,fontdata^.font);
  if fh1 <> 0 then begin
   if not iswin95 then begin
    fillchar(gcpresults,sizeof(gcpresults),0);
    gcpresults.lstructsize:= sizeof(gcpresults);
    gcpresults.nglyphs:= count;
    {$ifdef FPC}
    result:= getcharacterplacementw(gc1,text,count,0,@gcpresults,0) and $ffff;
    {$else}
    result:= getcharacterplacementw(gc1,text,count,0,gcpresults,0) and $ffff;
    {$endif}
   end
   else begin
    result:= 0;
    int1:= count;
    po1:= text;
    with win32fontdataty(fontdata^.platformdata) do begin
     widths:= charwidths;
     overha:= overhang;
    end;
    while int1 > 0 do begin
     wo1:= word(po1^);
     if wo1 < 256 then begin
      inc(result,widths^[wo1]);
     end
     else begin
      int2:= 0;
      if iswin95 then begin
       if not getcharwidthw(gc1,wo1,wo1,int2) then begin
        result:= -1;
        goto endlab;
       end;
       dec(int2,overha);
      end
      else begin
       if not getcharwidth32w(gc1,wo1,wo1,int2) then begin
        result:= -1;
        goto endlab;
       end;
      end;
      inc(result,int2);
     end;
     dec(int1);
     inc(po1);
    end;
   end;
  end
  else begin
   result:= -1;
  end;
endlab:
  if fh1 <> 0 then begin
   selectobject(gc1,fh1);
  end; 
  if drawinfo.gc.handle = invalidgchandle then begin
   releasedc(0,gc1);
  end;
 end;
end;

procedure gdi_getchar16widths(var drawinfo: drawinfoty);
label                        //todo: kerning?
 endlab;
var
 int1,int2: integer;
 po1: pmsechar;
 po2: {$ifdef FPC}objpas.{$endif}pinteger;
 wo1: word;
 widths: pcharwidthsty;
 overha: integer;
 ahandle: thandle;
 gc1: hdc;
 gcpresults: tgcpresultsw;
// fo1: hfont;
 hires: boolean;
begin
// result:= gde_fontmetrics;
 with drawinfo.getchar16widths do begin
  hires:= (df_highresfont in drawinfo.gc.drawingflags) and 
                          (fontdata^.fonthighres <> 0);
  if (drawinfo.gc.handle = invalidgchandle) or hires then begin
   gc1:= getdc(0);  //use default dc
  end
  else begin
   gc1:= drawinfo.gc.handle;
  end;
  if hires then begin
   ahandle:= selectobject(gc1,fontdata^.fonthighres);
  end
  else begin
   ahandle:= selectobject(gc1,fontdata^.font);
  end;
  if ahandle <> 0 then begin
   if not iswin95 then begin
    fillchar(gcpresults,sizeof(gcpresults),0);
    gcpresults.lstructsize:= sizeof(gcpresults);
    gcpresults.lpdx:= pointer(resultpo);
    gcpresults.nglyphs:= count;
    {$ifdef FPC}
    getcharacterplacementw(gc1,text,count,0,@gcpresults,0);
    {$else}
    getcharacterplacementw(gc1,text,count,0,gcpresults,0);
    {$endif}
    if hires then begin
     po2:= resultpo;
     int2:= highresfontfakt div 2; //round up
     for int1:= 0 to count - 1 do begin
      int2:= int2 + po2^;
      po2^:= int2 shr highresfontshift;
      int2:= int2 and highresfontmask;
      inc(po2);
     end;
    end;
   end
   else begin
    po1:= text;
    po2:= resultpo;
    with win32fontdataty(fontdata^.platformdata) do begin
     widths:= charwidths;
     overha:= overhang;
    end;
    int1:= count;
    while int1 > 0 do begin
     wo1:= word(po1^);
     if wo1 < 256 then begin
      po2^:= widths^[wo1];
     end
     else begin
      if iswin95 then begin
       if not getcharwidthw(gc1,wo1,wo1,po2^) then begin
        goto endlab;
       end;
       dec(po2^,overha);
      end
      else begin
       if not getcharwidth32w(gc1,wo1,wo1,po2^) then begin
        goto endlab;
       end;
      end;
     end;
     inc(po1);
     inc(po2);
     dec(int1);
    end;
   end;
//   selectobject(gc1,ahandle);
//   result:= gde_ok;
  end;
 end;

endlab:
 if ahandle <> 0 then begin
  selectobject(gc1,ahandle);
 end;
 if (drawinfo.gc.handle = invalidgchandle) or hires then begin
  releasedc(0,gc1);
 end;
end;

procedure gdi_getfontmetrics(var drawinfo: drawinfoty);
var
 data: abc;
 bo1: boolean;
 ahandle: thandle;

begin
// result:= gde_fontmetrics;
 with drawinfo,drawinfo.getfontmetrics do begin
  ahandle:= selectobject(gc.handle,fontdata^.font);
  if ahandle <> 0 then begin
   fillchar(data,sizeof(data),0);
   if iswin95 then begin
    bo1:= getcharabcwidthsw(gc.handle,longword(char),longword(char),data);
   {
    if ord(char) < 256 then begin
     bo1:= getcharabcwidthsa(gc.handle,longword(char),longword(char),data);
    end
    else begin
     bo1:= false;
    end;
    }
   end
   else begin
    bo1:= getcharabcwidthsw(gc.handle,longword(char),longword(char),data);
   end;
   if not bo1 then begin
    if iswin95 then begin
     bo1:= getcharwidthw(drawinfo.gc.handle,longword(char),longword(char),data.abcb);
     dec(data.abcB,win32fontdataty(fontdata^.platformdata).overhang);
    end
    else begin
     bo1:= getcharwidth32w(drawinfo.gc.handle,longword(char),longword(char),data.abcb);
    end;
    data.abca:= 0;
    data.abcC:= 0;
   end;
   if bo1 then begin
    with resultpo^ do begin
     leftbearing:= data.abca;
     width:= data.abca + integer(data.abcb) + data.abcc;
     rightbearing:= data.abcc;
    end;
    selectobject(gc.handle,ahandle);
//    result:= gde_ok;
   end;
  end;
 end;
end;

procedure init;
var
 brushinfo: tlogbrush;
begin
 nullpen:= createpen(ps_null,0,0);
 fillchar(brushinfo,sizeof(brushinfo),0);
 brushinfo.lbStyle:= bs_null;
 nullbrush:= createbrushindirect(brushinfo);
end;

procedure deinit;
begin
 deleteobject(nullpen);
 nullpen:= 0;
 deleteobject(nullbrush);
 nullbrush:= 0;
 if fhasgdiplus then begin
  releasegdiplus;
 end;
end;

const
 gdifunctions: gdifunctionaty = (
   {$ifdef FPC}@{$endif}gdi_creategc,
   {$ifdef FPC}@{$endif}gdi_destroygc,
   {$ifdef FPC}@{$endif}gdi_changegc,
   {$ifdef FPC}@{$endif}gdi_createpixmap,
   {$ifdef FPC}@{$endif}gdi_pixmaptoimage,
   {$ifdef FPC}@{$endif}gdi_imagetopixmap,
   {$ifdef FPC}@{$endif}gdi_getcanvasclass,
   {$ifdef FPC}@{$endif}gdi_endpaint,
   {$ifdef FPC}@{$endif}gdi_flush,
   {$ifdef FPC}@{$endif}gdi_movewindowrect,
   {$ifdef FPC}@{$endif}gdi_drawlines,
   {$ifdef FPC}@{$endif}gdi_drawlinesegments,
   {$ifdef FPC}@{$endif}gdi_drawellipse,
   {$ifdef FPC}@{$endif}gdi_drawarc,
   {$ifdef FPC}@{$endif}gdi_fillrect,
   {$ifdef FPC}@{$endif}gdi_fillellipse,
   {$ifdef FPC}@{$endif}gdi_fillarc,
   {$ifdef FPC}@{$endif}gdi_fillpolygon,
//   {$ifdef FPC}@{$endif}gdi_drawstring,
   {$ifdef FPC}@{$endif}gdi_drawstring16,
   {$ifdef FPC}@{$endif}gdi_setcliporigin,
   {$ifdef FPC}@{$endif}gdi_createemptyregion,
   {$ifdef FPC}@{$endif}gdi_createrectregion,
   {$ifdef FPC}@{$endif}gdi_createrectsregion,
   {$ifdef FPC}@{$endif}gdi_destroyregion,
   {$ifdef FPC}@{$endif}gdi_copyregion,
   {$ifdef FPC}@{$endif}gdi_moveregion,
   {$ifdef FPC}@{$endif}gdi_regionisempty,
   {$ifdef FPC}@{$endif}gdi_regionclipbox,
   {$ifdef FPC}@{$endif}gdi_regsubrect,
   {$ifdef FPC}@{$endif}gdi_regsubregion,
   {$ifdef FPC}@{$endif}gdi_regaddrect,
   {$ifdef FPC}@{$endif}gdi_regaddregion,
   {$ifdef FPC}@{$endif}gdi_regintersectrect,
   {$ifdef FPC}@{$endif}gdi_regintersectregion,
   {$ifdef FPC}@{$endif}gdi_copyarea,
   {$ifdef FPC}@{$endif}gdi_getimage,
   {$ifdef FPC}@{$endif}gdi_fonthasglyph,
   {$ifdef FPC}@{$endif}gdi_getfont,
   {$ifdef FPC}@{$endif}gdi_getfonthighres,
   {$ifdef FPC}@{$endif}gdi_freefontdata,
   {$ifdef FPC}@{$endif}gdi_gettext16width,
   {$ifdef FPC}@{$endif}gdi_getchar16widths,
   {$ifdef FPC}@{$endif}gdi_getfontmetrics
);

//var
// gdinumber: integer;

function gdi32getgdifuncs: pgdifunctionaty;
begin
 result:= @gdifunctions;
end;
{
function gdi32getgdinum: integer;
begin
 result:= gdinumber;
end;

initialization
 gdinumber:= registergdi(gdi32getgdifuncs);
}
end.
