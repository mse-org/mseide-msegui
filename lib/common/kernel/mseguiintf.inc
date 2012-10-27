{ MSEgui Copyright (c) 1999-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
function gui_init: guierrorty;
function gui_deinit: guierrorty;
procedure gui_cancelshutdown;
procedure GUI_DEBUGBEGIN; export;
procedure GUI_DEBUGEND; export;

function gui_registergdi: guierrorty;
function gui_setmainthread: guierrorty; //set mainthread to currentthread
function gui_sethighrestimer(const avalue: boolean): guierrorty;
function gui_grouphideminimizedwindows: boolean; //true for win32

//application has to be locked for all following calls
function gui_postevent(event: tmseevent): guierrorty;
function gui_settimer(us: longword): guierrorty;
               //send et_timer event after delay of us (micro seconds)

function gui_hasevent: boolean;         //false if no event pending
function gui_getevent: tmseevent;          //can be nil
function gui_escapepressed: boolean;
procedure gui_resetescapepressed;


function gui_createwindow(const rect: rectty; const options: internalwindowoptionsty;
                               var awindow: windowty): guierrorty;
function gui_destroywindow(var awindow: windowty): guierrorty;
                      //id can be 0
function gui_getparentwindow(const awindow: winidty): winidty;
function gui_reparentwindow(const child: winidty; const parent: winidty;
                            const pos: pointty): guierrorty;
function gui_getchildren(const id: winidty; out children: winidarty): guierrorty;

function gui_showsysdock(var awindow: windowty): guierrorty;
function gui_hidesysdock(var awindow: windowty): guierrorty;

function gui_docktosyswindow(var child: windowty; 
                                   const akind: syswindowty): guierrorty;
                    //hides window
//function gui_undockfromsyswindow(var child: windowty): guierrorty;
                    //hides window

function gui_traymessage(var awindow: windowty; const message: msestring;
                          out messageid: longword;
                          const timeoutms: longword = 0): guierrorty;
function gui_canceltraymessage(var awindow: windowty;
                          const messageid: longword): guierrorty;
function gui_settrayicon(var awindow: windowty;
                                     const icon,mask: pixmapty): guierrorty;
function gui_settrayhint(var awindow: windowty;
                                     const hint: msestring): guierrorty;

//function gui_creategc(paintdevice: paintdevicety; const akind: gckindty;
//                var gc: gcty; const aprintername: msestring = ''): guierrorty;
//function gui_destroygc(winid: winidty; var gc: gcty): guierrorty;
function gui_flushgdi(const synchronize: boolean = false): guierrorty;
function gui_showwindow(id: winidty): guierrorty;
function gui_hidewindow(id: winidty): guierrorty;
function gui_raisewindow(id: winidty): guierrorty;
function gui_lowerwindow(id: winidty): guierrorty;
function gui_stackunderwindow(id: winidty; predecessor: winidty): guierrorty;
function gui_stackoverwindow(id: winidty; predecessor: winidty): guierrorty;
function gui_canstackunder: boolean; //no way found to change stacking order in KDE
function gui_getzorder(const ids: winidarty; out zorders: integerarty): guierrorty;
    //topevel -> highest, numbers have not to be contiguous

function gui_getwindowrect(id: winidty; out rect: rectty): guierrorty;
             //screen coordinates
function gui_getwindowpos(id: winidty; out pos: pointty): guierrorty;
             //parent window coordinates
function gui_getwindowsize(id: winidty): windowsizety;
function gui_getwindowdesktop(const id: winidty): integer;
function gui_windowvisible(id: winidty): boolean;
function gui_setwindowstate(id: winidty; size: windowsizety; visible: boolean): guierrorty;
function gui_setwindowcaption(id: winidty; const caption: msestring): guierrorty;
function gui_setwindowicon(id: winidty; const icon,mask: pixmapty): guierrorty;
            
function gui_setsizeconstraints(id: winidty; const min,max: sizety): guierrorty;
function gui_reposwindow(id: winidty; const rect: rectty): guierrorty;
function gui_getdecoratedwindowrect(id: winidty; out arect: rectty): guierrorty;
function gui_setdecoratedwindowrect(id: winidty; const rect: rectty; 
                                    out clientrect: rectty): guierrorty;
function gui_setembeddedwindowrect(id: winidty; const rect: rectty): guierrorty;
function gui_setwindowfocus(id: winidty): guierrorty;
function gui_setimefocus(var awindow: windowty): guierrorty;
function gui_unsetimefocus(var awindow: windowty): guierrorty;
{
function gui_windowgetfocus(var awindow: windowty): guierrorty;
function gui_windowloosefocus(var awindow: windowty): guierrorty;
}
function gui_setappfocus(id: winidty): guierrorty;
function gui_minimizeapplication: guierrorty;
function gui_setwindowgroup(id: winidty; group: winidty): guierrorty;
function gui_settransientfor(var awindow: windowty; 
                                  const transientfor: winidty): guierrorty;
function gui_movewindowrect(id: winidty; const dist: pointty; 
                                         const rect: rectty): guierrorty;
function gui_windowatpos(const pos: pointty): winidty;
function gui_getscreenrect(const id: winidty): rectty; //0 -> virtual screen
function gui_getworkarea(id: winidty): rectty;
function gui_setapplicationicon(const icon,mask: pixmapty): guierrorty;
function gui_pidtowinid(const pids: procidarty): winidty;

function gui_setcursorshape(winid: winidty; shape: cursorshapety): guierrorty;
function gui_getpointerpos: pointty;
function gui_setpointerpos(const pos: pointty): guierrorty;
function gui_movepointer(const dist: pointty): guierrorty;
function gui_grabpointer(id: winidty): guierrorty;
function gui_ungrabpointer: guierrorty;

function gui_rgbtopixel(rgb: longword): pixelty;
function gui_pixeltorgb(pixel: pixelty): longword;
//function gui_rgbtocolormappixel(rgb: longword): pixelty;
              //neutralizes color in 8bit coler depth
function gui_initcolormap: guierrorty;

function gui_regiontorects(const aregion: regionty): rectarty;
//procedure gui_changegc(var drawinfo: drawinfoty; const values: gcvaluesty);

function gui_getdefaultfontnames: defaultfontnamesty;

function gui_createpixmap(const size: sizety; winid: winidty = 0;
      monochrome: boolean = false; copyfrom: pixmapty = 0): pixmapty; overload;
function gui_freepixmap(pixmap: pixmapty): gdierrorty;
function gui_getpixmapinfo(var info: pixmapinfoty): gdierrorty;
function gui_createbitmapfromdata(const size: sizety; datapo: pbyte;
             msbitfirst: boolean = false; dwordaligned: boolean = false;
             bottomup: boolean = false): pixmapty;
function gui_pixmaptoimage(pixmap: pixmapty; out image: imagety; gchandle: longword): gdierrorty;
                    //gchandle is used on win32 to select bitmap out of devicecontext,
                    //can be 0
function gui_imagetopixmap(const image: imagety; out pixmap: pixmapty; gchandle: longword): gdierrorty;
                    //gchandle is used on win32 to select bitmap out of devicecontext,
                    //can be 0
function gui_allocimagemem(length: integer): plongwordaty;
procedure gui_freeimagemem(data: plongwordaty);

//procedure gui_copyarea(var drawinfo: drawinfoty);

procedure gui_beep;
function gui_copytoclipboard(const value: msestring): guierrorty;
function gui_pastefromclipboard(out value: msestring): guierrorty;
function gui_canpastefromclipboard: boolean;

function gui_sysdnd(const action: sysdndactionty): guierrorty;

function gui_getgdifuncs: pgdifunctionaty;
                 
(*
procedure gdi_creategc(var drawinfo: drawinfoty);
procedure gdi_destroygc(var drawinfo: drawinfoty);
procedure gdi_changegc(var drawinfo: drawinfoty);
procedure gdi_drawlines(var drawinfo: drawinfoty);
procedure gdi_drawlinesegments(var drawinfo: drawinfoty);
procedure gdi_drawellipse(var drawinfo: drawinfoty);
procedure gdi_drawarc(var drawinfo: drawinfoty);
procedure gdi_fillrect(var drawinfo: drawinfoty);
procedure gdi_fillelipse(var drawinfo: drawinfoty);
procedure gdi_fillarc(var drawinfo: drawinfoty);
procedure gdi_fillpolygon(var drawinfo: drawinfoty);
procedure gdi_drawstring16(var drawinfo: drawinfoty);
procedure gdi_setcliporigin(var drawinfo: drawinfoty);
procedure gdi_createemptyregion(var drawinfo: drawinfoty);
procedure gdi_createrectregion(var drawinfo: drawinfoty);
procedure gdi_createrectsregion(var drawinfo: drawinfoty);
procedure gdi_destroyregion(var drawinfo: drawinfoty);
procedure gdi_copyregion(var drawinfo: drawinfoty);
procedure gdi_moveregion(var drawinfo: drawinfoty);
procedure gdi_regionisempty(var drawinfo: drawinfoty);
procedure gdi_regionclipbox(var drawinfo: drawinfoty);
procedure gdi_regsubrect(var drawinfo: drawinfoty);
procedure gdi_regsubregion(var drawinfo: drawinfoty);
procedure gdi_regaddrect(var drawinfo: drawinfoty);
procedure gdi_regaddregion(var drawinfo: drawinfoty);
procedure gdi_regintersectrect(var drawinfo: drawinfoty);
procedure gdi_regintersectregion(var drawinfo: drawinfoty);
procedure gdi_copyarea(var drawinfo: drawinfoty);
procedure gdi_fonthasglyph(var drawinfo: drawinfoty);
procedure gdi_getfont(var drawinfo: drawinfoty);
procedure gdi_getfonthighres(var drawinfo: drawinfoty);
procedure gdi_freefontdata(var drawinfo: drawinfoty);
procedure gdi_gettext16width(var drawinfo: drawinfoty);
procedure gdi_getchar16widths(var drawinfo: drawinfoty);
procedure gdi_getfontmetrics(var drawinfo: drawinfoty);
*)
