{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegraphutils;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,msestrings,mseerr;
 
const
 redmask = $ff0000;
 redshift = 16;
 greenmask = $00ff00;
 greenshift = 8;
 bluemask = $0000ff;
 blueshift = 0;
 
type
 imagenrty = type integer; //for timagelist
 facenrty = type integer;  //for tfacelist
 pixelty = longword;
 pixelaty = array[0..0] of pixelty;
 ppixelaty = ^pixelaty;

 colorty = type longword;
 pcolorty = ^colorty;
 colorarty = array of colorty;
 
 rgbtriplety = packed record
  blue: byte;
  green: byte;
  red: byte;
  res: byte;
 end;
 prgbtriplety = ^rgbtriplety;
 rgbtriplearty = array of rgbtriplety;
 rgbtripleaty = array[0..0] of rgbtriplety;
 prgbtripleaty = ^rgbtripleaty;

 colormapsty = (cm_rgb,cm_functional,cm_mapped,cm_namedrgb,cm_user);
 colormapty = array[colormapsty] of longwordarty;
 
 colorinfoty = record
                name: string;
                rgb: rgbtriplety;
               end;
 pcolorinfoty = ^colorinfoty;
 colorinfoarty = array of colorinfoty;
 
const
 maxopacity = $00ffffff;
 speccolormask =         $f0000000;
 speccolorshift = 28;
 cl_functional = colorty($80000000);
 cl_mapped =     colorty($90000000);
 cl_namedrgb =   colorty($a0000000);
 cl_user =       colorty($b0000000);

 cl_invalid =                cl_functional + 0; 
                 //can not be used as default value
 cl_default =                cl_functional + 1;
 cl_parent =                 cl_functional + 2;
 cl_transparent =            cl_functional + 3;
 cl_brush =                  cl_functional + 4;
 cl_brushcanvas =            cl_functional + 5;
 cl_none =                   cl_functional + 6; cl_nonenum = 6;
 cl_font =                   cl_functional + 7; //use color of current font
 cl_normal =                 cl_functional + 8; //used in tmenitem.coloractive
 cl_lastfunctional =         cl_functional + 9;

 cl_dkshadow =               cl_mapped + 0;
 cl_shadow =                 cl_mapped + 1;
 cl_mid =                    cl_mapped + 2;
 cl_light =                  cl_mapped + 3;
 cl_highlight =              cl_mapped + 4;
 cl_background =             cl_mapped + 5;
 cl_foreground =             cl_mapped + 6;
 cl_active =                 cl_mapped + 7;
 cl_noedit =                 cl_mapped + 8;
 cl_text =                   cl_mapped + 9;
 cl_selectedtext =           cl_mapped + 10;
 cl_selectedtextbackground = cl_mapped + 11;
 cl_infobackground =         cl_mapped + 12;
 cl_glyph =                  cl_mapped + 13;
 cl_activegrip =             cl_mapped + 14;
 cl_empty =                  cl_mapped + 15;
 cl_emptytext =              cl_mapped + 16;
 cl_emptytextbackground =    cl_mapped + 17;
 cl_zebra =                  cl_mapped + 18;
 cl_lastmapped =             cl_mapped + 19;

 cl_0 =                      cl_namedrgb + 0; //select colorbackground for monochrome bitmaps
 cl_1 =                      cl_namedrgb + 1; //select colorforeground
 cl_black =                  cl_namedrgb + 2;
 cl_dkgray =                 cl_namedrgb + 3;
 cl_gray =                   cl_namedrgb + 4;
 cl_ltgray =                 cl_namedrgb + 5;
 cl_white =                  cl_namedrgb + 6;

 cl_red =                    cl_namedrgb + 7;
 cl_green =                  cl_namedrgb + 8;
 cl_blue =                   cl_namedrgb + 9;
 cl_cyan =                   cl_namedrgb + 10;
 cl_magenta =                cl_namedrgb + 11;
 cl_yellow =                 cl_namedrgb + 12;

 cl_dkred =                  cl_namedrgb + 13;
 cl_dkgreen =                cl_namedrgb + 14;
 cl_dkblue =                 cl_namedrgb + 15;
 cl_dkcyan =                 cl_namedrgb + 16;
 cl_dkmagenta =              cl_namedrgb + 17;
 cl_dkyellow =               cl_namedrgb + 18;

 cl_ltred =                  cl_namedrgb + 19;
 cl_ltgreen =                cl_namedrgb + 20;
 cl_ltblue =                 cl_namedrgb + 21;
 cl_ltcyan =                 cl_namedrgb + 22;
 cl_ltmagenta =              cl_namedrgb + 23;
 cl_ltyellow =               cl_namedrgb + 24;

 cl_lastnamedrgb =           cl_namedrgb + 25;
 
 cl_user0 =                  cl_user     + 0;
 cl_user1 =                  cl_user     + 1;
 cl_user2 =                  cl_user     + 2;
 cl_user3 =                  cl_user     + 3;
 cl_user4 =                  cl_user     + 4;
 cl_user5 =                  cl_user     + 5;
 cl_user6 =                  cl_user     + 6;
 cl_user7 =                  cl_user     + 7;
 cl_user8 =                  cl_user     + 8;
 cl_user9 =                  cl_user     + 9;
 cl_user10 =                 cl_user     + 10;
 cl_user11 =                 cl_user     + 11;
 cl_user12 =                 cl_user     + 12;
 cl_user13 =                 cl_user     + 13;
 cl_user14 =                 cl_user     + 14;
 cl_user15 =                 cl_user     + 15;
 cl_user16 =                 cl_user     + 16;
 cl_user17 =                 cl_user     + 17;
 cl_user18 =                 cl_user     + 18;
 cl_user19 =                 cl_user     + 19;
 cl_fade0 =                  cl_user     + 20;
 cl_fade1 =                  cl_user     + 21;
 cl_fade2 =                  cl_user     + 22;
 cl_fade3 =                  cl_user     + 23;
 cl_fade4 =                  cl_user     + 24;
 cl_fade5 =                  cl_user     + 25;
 cl_fade6 =                  cl_user     + 26;
 cl_fade7 =                  cl_user     + 27;
 cl_fade8 =                  cl_user     + 28;
 cl_fade9 =                  cl_user     + 29;
 
 cl_lastuser =               cl_user     + 30;

 functionalcolorcount = integer(cl_lastfunctional)-integer(cl_functional);
 mappedcolorcount = integer(cl_lastmapped)-integer(cl_mapped);
 namedrgbcolorcount = integer(cl_lastnamedrgb)-integer(cl_namedrgb);
 usercolorcount = integer(cl_lastuser)-integer(cl_user);
 mapcolorcounts: array[colormapsty] of integer = (
              0,
              functionalcolorcount,
              mappedcolorcount,
              namedrgbcolorcount,
              usercolorcount
            );

 defaultfunctional: array[0..functionalcolorcount-1]
                     of colorinfoty =
   (
    (name: 'cl_invalid';  rgb:               (blue: $ff; green: $ff; red: $ff; res: $00)), //0
    (name: 'cl_default'; rgb:                (blue: $ff; green: $ff; red: $ff; res: $00)), //1
    (name: 'cl_parent';  rgb:                (blue: $ff; green: $ff; red: $ff; res: $00)), //2
    (name: 'cl_transparent'; rgb:            (blue: $ff; green: $ff; red: $ff; res: $00)), //3
    (name: 'cl_brush';  rgb:                 (blue: $ff; green: $ff; red: $ff; res: $00)), //4
    (name: 'cl_brushcanvas'; rgb:            (blue: $ff; green: $ff; red: $ff; res: $00)), //5
    (name: 'cl_none';  rgb:                  (blue: $ff; green: $ff; red: $ff; res: $00)), //6
    (name: 'cl_font';  rgb:                  (blue: $00; green: $00; red: $00; res: $00)), //7
    (name: 'cl_normal';  rgb:                (blue: $ff; green: $ff; red: $ff; res: $00))  //8
//    (name: 'cl_mask'; rgb:                   (blue: $00; green: $00; red: $00; res: $00))
//    (name: 'cl_grayed'; rgb:                 (blue: $80; green: $80; red: $80; res: $00))
   );

 defaultmapped: array[0..mappedcolorcount-1]
                     of colorinfoty =
   (
    (name: 'cl_dkshadow'; rgb:               (blue: $00; green: $00; red: $00; res: $00)), //0
    (name: 'cl_shadow'; rgb:                 (blue: $80; green: $80; red: $80; res: $00)), //1
    (name: 'cl_mid'; rgb:                    (blue: $c0; green: $c0; red: $c0; res: $00)), //2
    (name: 'cl_light'; rgb:                  (blue: $e0; green: $e0; red: $e0; res: $00)), //3
    (name: 'cl_highlight'; rgb:              (blue: $ff; green: $ff; red: $ff; res: $00)), //4
    (name: 'cl_background';  rgb:            (blue: $d0; green: $d0; red: $d0; res: $00)), //5
    (name: 'cl_foreground';  rgb:            (blue: $ff; green: $ff; red: $ff; res: $00)), //6
    (name: 'cl_active';  rgb:                (blue: $e0; green: $e0; red: $e0; res: $00)), //7
    (name: 'cl_noedit';  rgb:                (blue: $e0; green: $e0; red: $e0; res: $00)), //8
                                //canvas defaultcolors
    (name: 'cl_text';  rgb:                  (blue: $00; green: $00; red: $00; res: $00)), //9
    (name: 'cl_selectedtext'; rgb:           (blue: $ff; green: $ff; red: $ff; res: $00)), //10
    (name: 'cl_selectedtextbackground'; rgb: (blue: $c0; green: $00; red: $00; res: $00)), //11
    (name: 'cl_infobackground'; rgb:         (blue: $e0; green: $ff; red: $ff; res: $00)), //12
    (name: 'cl_glyph'; rgb:                  (blue: $00; green: $00; red: $00; res: $00)), //13
    (name: 'cl_activegrip'; rgb:             (blue: $90; green: $20; red: $20; res: $00)), //14
    (name: 'cl_empty';  rgb:                 (blue: $a0; green: $a0; red: $ff; res: $00)), //15
    (name: 'cl_emptytext';  rgb:             (blue: $ff; green: $ff; red: $ff; res: $00)), //16
    (name: 'cl_emptytextbackground';  rgb:   (blue: $00; green: $00; red: $ff; res: $00)), //17
    (name: 'cl_zebra';  rgb:                 (blue: $ff; green: $ff; red: $e0; res: $00))  //18
   );

 defaultnamedrgb: array[0..namedrgbcolorcount-1]
                     of colorinfoty =
   (
    (name: 'cl_0';  rgb:                     (blue: $00; green: $00; red: $00; res: $00)), //0
    (name: 'cl_1';  rgb:                     (blue: $ff; green: $ff; red: $ff; res: $00)), //1

    (name: 'cl_black'; rgb:                  (blue: $00; green: $00; red: $00; res: $00)), //2
    (name: 'cl_dkgray';  rgb:                (blue: $80; green: $80; red: $80; res: $00)), //3
    (name: 'cl_gray';  rgb:                  (blue: $c0; green: $c0; red: $c0; res: $00)), //4
    (name: 'cl_ltgray';  rgb:                (blue: $e0; green: $e0; red: $e0; res: $00)), //5
    (name: 'cl_white';  rgb:                 (blue: $ff; green: $ff; red: $ff; res: $00)), //6

    (name: 'cl_red';   rgb:                  (blue: $00; green: $00; red: $ff; res: $00)), //7
    (name: 'cl_green'; rgb:                  (blue: $00; green: $ff; red: $00; res: $00)), //8
    (name: 'cl_blue';  rgb:                  (blue: $ff; green: $00; red: $00; res: $00)), //9
    (name: 'cl_cyan';  rgb:                  (blue: $ff; green: $ff; red: $00; res: $00)), //10
    (name: 'cl_magenta';  rgb:               (blue: $ff; green: $00; red: $ff; res: $00)), //11
    (name: 'cl_yellow';  rgb:                (blue: $00; green: $ff; red: $ff; res: $00)), //12

    (name: 'cl_dkred';   rgb:                (blue: $00; green: $00; red: $c0; res: $00)), //13
    (name: 'cl_dkgreen'; rgb:                (blue: $00; green: $c0; red: $00; res: $00)), //14
    (name: 'cl_dkblue';  rgb:                (blue: $c0; green: $00; red: $00; res: $00)), //15
    (name: 'cl_dkcyan';  rgb:                (blue: $80; green: $80; red: $00; res: $00)), //16
    (name: 'cl_dkmagenta';  rgb:             (blue: $80; green: $00; red: $80; res: $00)), //17
    (name: 'cl_dkyellow';  rgb:              (blue: $00; green: $80; red: $80; res: $00)), //18

    (name: 'cl_ltred';   rgb:                (blue: $a0; green: $a0; red: $ff; res: $00)), //19
    (name: 'cl_ltgreen'; rgb:                (blue: $a0; green: $ff; red: $a0; res: $00)), //20
    (name: 'cl_ltblue';  rgb:                (blue: $ff; green: $a0; red: $a0; res: $00)), //21
    (name: 'cl_ltcyan';  rgb:                (blue: $ff; green: $ff; red: $a0; res: $00)), //22
    (name: 'cl_ltmagenta';  rgb:             (blue: $ff; green: $a0; red: $ff; res: $00)), //23
    (name: 'cl_ltyellow';  rgb:              (blue: $a0; green: $ff; red: $ff; res: $00))  //24
   );

 defaultuser: array[0..usercolorcount-1]
                     of colorinfoty =
   (
    (name: 'cl_user0';  rgb:                 (blue: $00; green: $00; red: $00; res: $00)), //0
    (name: 'cl_user1';  rgb:                 (blue: $00; green: $00; red: $00; res: $00)), //1
    (name: 'cl_user2';  rgb:                 (blue: $00; green: $00; red: $00; res: $00)), //2
    (name: 'cl_user3';  rgb:                 (blue: $00; green: $00; red: $00; res: $00)), //3
    (name: 'cl_user4';  rgb:                 (blue: $00; green: $00; red: $00; res: $00)), //4
    (name: 'cl_user5';  rgb:                 (blue: $00; green: $00; red: $00; res: $00)), //5
    (name: 'cl_user6';  rgb:                 (blue: $00; green: $00; red: $00; res: $00)), //6
    (name: 'cl_user7';  rgb:                 (blue: $00; green: $00; red: $00; res: $00)), //7
    (name: 'cl_user8';  rgb:                 (blue: $00; green: $00; red: $00; res: $00)), //8
    (name: 'cl_user9';  rgb:                 (blue: $00; green: $00; red: $00; res: $00)), //9
    (name: 'cl_user10';  rgb:                (blue: $00; green: $00; red: $00; res: $00)), //10
    (name: 'cl_user11';  rgb:                (blue: $00; green: $00; red: $00; res: $00)), //11
    (name: 'cl_user12';  rgb:                (blue: $00; green: $00; red: $00; res: $00)), //12
    (name: 'cl_user13';  rgb:                (blue: $00; green: $00; red: $00; res: $00)), //13
    (name: 'cl_user14';  rgb:                (blue: $00; green: $00; red: $00; res: $00)), //14
    (name: 'cl_user15';  rgb:                (blue: $00; green: $00; red: $00; res: $00)), //15
    (name: 'cl_user16';  rgb:                (blue: $00; green: $00; red: $00; res: $00)), //16
    (name: 'cl_user17';  rgb:                (blue: $00; green: $00; red: $00; res: $00)), //17
    (name: 'cl_user18';  rgb:                (blue: $00; green: $00; red: $00; res: $00)), //18
    (name: 'cl_user19';  rgb:                (blue: $00; green: $00; red: $00; res: $00)), //19
    (name: 'cl_fade0';   rgb:                (blue: $00; green: $00; red: $00; res: $00)), //20
    (name: 'cl_fade1';   rgb:                (blue: $00; green: $00; red: $00; res: $00)), //21
    (name: 'cl_fade2';   rgb:                (blue: $00; green: $00; red: $00; res: $00)), //22
    (name: 'cl_fade3';   rgb:                (blue: $00; green: $00; red: $00; res: $00)), //23
    (name: 'cl_fade4';   rgb:                (blue: $00; green: $00; red: $00; res: $00)), //24
    (name: 'cl_fade5';   rgb:                (blue: $00; green: $00; red: $00; res: $00)), //25
    (name: 'cl_fade6';   rgb:                (blue: $00; green: $00; red: $00; res: $00)), //26
    (name: 'cl_fade7';   rgb:                (blue: $00; green: $00; red: $00; res: $00)), //27
    (name: 'cl_fade8';   rgb:                (blue: $00; green: $00; red: $00; res: $00)), //28
    (name: 'cl_fade9';   rgb:                (blue: $00; green: $00; red: $00; res: $00))  //29
   );
   
type
 graphicdirectionty = (gd_right,gd_up,gd_left,gd_down,gd_none);
 pgraphicdirectionty = ^graphicdirectionty;
 graphicdirectionsty = set of graphicdirectionty;
 pgraphicdirectionsty = ^graphicdirectionsty;

 alignmentty = (al_left,al_xcentered,al_right,al_top,al_ycentered,al_bottom,
                al_grayed,
                al_stretchx,al_stretchy,al_fit,al_tiled,
                al_intpol,al_or,al_and);
 alignmentsty = set of alignmentty;

 
 fontstylety = (fs_bold,fs_italic,
                fs_underline,fs_strikeout,fs_selected,fs_blank,
                fs_force);
                      //order fix
 fontstylesty = set of fontstylety;

 pointty = record
            x,y: integer;
           end;
 ppointty = ^pointty;
 pointarty = array of pointty;
 ppointarty = ^pointarty;
 pointararty = array of pointarty;
 pointaty = array[0..0] of pointty;
 ppointaty = ^pointaty;
 pointpoarty = array of ppointty;

 fpointty = record
             x,y: single;
            end;
 pfpointty = ^fpointty;
 fpointarty = array of fpointty;
 pfpointarty = ^fpointarty;
 fpointaty = array[0..0] of fpointty;
 pfpointaty = ^fpointaty;

 segmentty = record a,b: pointty end;
 psegmentty = ^segmentty;
 segmentarty = array of segmentty;

 graphicvectorty = record
  start: pointty;
  direction: graphicdirectionty;
  length: integer;
 end;

 sizety = record
            cx,cy: integer;
          end;

 rectty = record
           case integer of
            0: (x,y,cx,cy: integer);
            1: (pos: pointty; size: sizety);
          end;
 framety = record
            case integer of
             0: (left,top,right,bottom: integer);
             1: (topleft,bottomright: sizety);
           end;
 pframety = ^framety;
 prectty = ^rectty;
 rectarty = array of rectty;
 prectarty = ^rectarty;
 rectextty = record
            case integer of
             0: (left,top,right,bottom: integer);
             1: (topleft,bottomright: pointty);
           end;
 prectextty = ^rectextty;

const
 nullpoint: pointty = (x: 0; y: 0);
 nullsize: sizety = (cx: 0; cy: 0);
 nullrect: rectty = (x: 0; y: 0; cx: 0; cy: 0);
 nullframe: framety = (left: 0; top: 0; right: 0; bottom: 0);
 emptyrectext: rectextty = (left: maxint; top: maxint; right: minint;
                                                       bottom: minint);

 minimalframe: framety = (left: 1; top: 1; right: 1; bottom: 1);
 minimaltextframe: framety = (left: 1; top: 0; right: 1; bottom: 0);

type
 gdierrorty = (gde_ok,
               gde_creategc,gde_createprintergc,gde_createmetafilegc,
               gde_invalidgc,
               gde_notruecolor,
               gde_invalidcolor,
               gde_invalidsaveindex,
               gde_parameter,
               gde_font,
               gde_pixmap,gde_freepixmap,
               gde_invalidcopymode,gde_mustbebitmap,
               gde_notmonochrome,gde_unmatchedmonochrome,
               gde_fontmetrics,gde_image,gde_invalidrect,gde_invalidfileformat,
               gde_invalidindex,
               gde_notimplemented,
               gde_noglx,gde_novisual,gde_rendercontext,gde_glxpixmap,
               gde_createwindow
              );
              
 egdi = class(eerror)
  private
   ferror1: gdierrorty;
  public
   constructor create(aerror: gdierrorty; atext: string);
   property error: gdierrorty read ferror1;
 end;

type
 getrectintegerty = function(const arect: rectty): integer;
 setrectintegerty = procedure(var arect: rectty; const avalue: integer);
 getintpointty = function(const value,ovalue: integer): pointty;
 getintsizety = function(const value,ovalue: integer): sizety;
 getpointintty = function(const apoint: pointty): integer;
 getsizeintty = function(const asize: sizety): integer;
 setpointintty = procedure(var apoint: pointty; const avalue: integer);
 setsizeintty = procedure(var asize: sizety; const avalue: integer);
 
 rectaccessty = record
  pos,size,stop,opos,osize,ostop: getrectintegerty;
  setpos,setsize,setstop,setopos,setosize,setostop: setrectintegerty;
  makepos,makeopos: getintpointty;
  makesize,makeosize: getintsizety;
  pt,opt: getpointintty;
  si,osi: getsizeintty;
  setpt,setopt: setpointintty;
  setsi,setosi: setsizeintty;
 end;
 prectaccessty = ^rectaccessty;
  
function rx(const arect: rectty): integer;
function ry(const arect: rectty): integer;
function rcx(const arect: rectty): integer;
function rcy(const arect: rectty): integer;
function rstopx(const arect: rectty): integer;
function rstopy(const arect: rectty): integer;
procedure rsetx(var arect: rectty; const avalue: integer);
procedure rsety(var arect: rectty; const avalue: integer);
procedure rsetcx(var arect: rectty; const avalue: integer);
procedure rsetcy(var arect: rectty; const avalue: integer);
procedure rsetstopx(var arect: rectty; const avalue: integer);
procedure rsetstopy(var arect: rectty; const avalue: integer);
function makesizex(const value,ovalue: integer): sizety;
function makesizey(const value,ovalue: integer): sizety;
function makeposx(const value,ovalue: integer): pointty;
function makeposy(const value,ovalue: integer): pointty;
function px(const apoint: pointty): integer;
function py(const apoint: pointty): integer;
function sx(const asize: sizety): integer;
function sy(const asize: sizety): integer;
procedure psetx(var apoint: pointty; const avalue: integer);
procedure psety(var apoint: pointty; const avalue: integer);
procedure ssetx(var asize: sizety; const avalue: integer);
procedure ssety(var asize: sizety; const avalue: integer);

const
 rectaccessx: rectaccessty =  (
   pos: {$ifdef FPC}@{$endif}rx;
   size: {$ifdef FPC}@{$endif}rcx;
   stop: {$ifdef FPC}@{$endif}rstopx;
   opos: {$ifdef FPC}@{$endif}ry;
   osize: {$ifdef FPC}@{$endif}rcy;
   ostop: {$ifdef FPC}@{$endif}rstopy;
   setpos: {$ifdef FPC}@{$endif}rsetx;
   setsize: {$ifdef FPC}@{$endif}rsetcx;
   setstop: {$ifdef FPC}@{$endif}rsetstopx;
   setopos: {$ifdef FPC}@{$endif}rsety;
   setosize: {$ifdef FPC}@{$endif}rsetcy;
   setostop: {$ifdef FPC}@{$endif}rsetstopy;
   makepos: {$ifdef FPC}@{$endif}makeposx;
   makeopos: {$ifdef FPC}@{$endif}makeposy;
   makesize: {$ifdef FPC}@{$endif}makesizex;
   makeosize: {$ifdef FPC}@{$endif}makesizey;
   pt: {$ifdef FPC}@{$endif}px;
   opt: {$ifdef FPC}@{$endif}py;
   si: {$ifdef FPC}@{$endif}sx;
   osi: {$ifdef FPC}@{$endif}sy;
   setpt: {$ifdef FPC}@{$endif}psetx;
   setopt: {$ifdef FPC}@{$endif}psety;
   setsi: {$ifdef FPC}@{$endif}ssetx;
   setosi: {$ifdef FPC}@{$endif}ssety;
 );
 rectaccessy: rectaccessty =  (
   pos: {$ifdef FPC}@{$endif}ry;
   size: {$ifdef FPC}@{$endif}rcy;
   stop: {$ifdef FPC}@{$endif}rstopy;
   opos: {$ifdef FPC}@{$endif}rx;
   osize: {$ifdef FPC}@{$endif}rcx;
   ostop: {$ifdef FPC}@{$endif}rstopy;
   setpos: {$ifdef FPC}@{$endif}rsety;
   setsize: {$ifdef FPC}@{$endif}rsetcy;
   setstop: {$ifdef FPC}@{$endif}rsetstopy;
   setopos: {$ifdef FPC}@{$endif}rsetx;
   setosize: {$ifdef FPC}@{$endif}rsetcx;
   setostop: {$ifdef FPC}@{$endif}rsetstopx;
   makepos: {$ifdef FPC}@{$endif}makeposy;
   makeopos: {$ifdef FPC}@{$endif}makeposx;
   makesize: {$ifdef FPC}@{$endif}makesizey;
   makeosize: {$ifdef FPC}@{$endif}makesizex;
   pt: {$ifdef FPC}@{$endif}py;
   opt: {$ifdef FPC}@{$endif}px;
   si: {$ifdef FPC}@{$endif}sy;
   osi: {$ifdef FPC}@{$endif}sx;
   setpt: {$ifdef FPC}@{$endif}psety;
   setopt: {$ifdef FPC}@{$endif}psetx;
   setsi: {$ifdef FPC}@{$endif}ssety;
   setosi: {$ifdef FPC}@{$endif}ssetx;
 );

procedure gdierror(error: gdierrorty; const text: string = ''); overload;
procedure gdierror(error: gdierrorty; sender: tobject;
                                            text: string = ''); overload;
 
function stringtocolor(value: string): colorty;
function colortostring(value: colorty): string;
function getcolornames: msestringarty;
function getcolorvalues: colorarty;

function makepoint(const x,y: integer): pointty; {$ifdef FPC}inline;{$endif}
function makesize(const cx,cy: integer): sizety; {$ifdef FPC}inline;{$endif}
function makerect(const x,y,cx,cy: integer): rectty; overload;
                               {$ifdef FPC}inline;{$endif}
function makerect(const pos: pointty; const size: sizety): rectty; overload;
                               {$ifdef FPC}inline;{$endif}
function makesegment(const a,b: pointty): segmentty;
                               {$ifdef FPC}inline;{$endif}
function makeframe(const left,top,right,bottom: integer): framety;
                               {$ifdef FPC}inline;{$endif}

function mp(const x,y: integer): pointty; {$ifdef FPC}inline;{$endif}
function ms(const cx,cy: integer): sizety; {$ifdef FPC}inline;{$endif}
function mr(const x,y,cx,cy: integer): rectty; overload; 
                               {$ifdef FPC}inline;{$endif}
function mr(const pos: pointty; const size: sizety): rectty; overload;
                               {$ifdef FPC}inline;{$endif}
function mg(const a,b: pointty): segmentty;
                               {$ifdef FPC}inline;{$endif}
function mf(const left,top,right,bottom: integer): framety;
                               {$ifdef FPC}inline;{$endif}

function bottomright(const rect: rectty): pointty; {$ifdef FPC}inline;{$endif}
function isnullpoint(const point: pointty): boolean; {$ifdef FPC}inline;{$endif}
function isnullsize(const size: sizety): boolean; {$ifdef FPC}inline;{$endif}
function isnullrect(const rect: rectty): boolean; {$ifdef FPC}inline;{$endif}
function isnullframe(const frame: framety): boolean; {$ifdef FPC}inline;{$endif}
function pointisequal(const a,b: pointty): boolean; {$ifdef FPC}inline;{$endif}
function sizeisequal(const a,b: sizety): boolean; {$ifdef FPC}inline;{$endif}
function rectisequal(const a,b: rectty): boolean; {$ifdef FPC}inline;{$endif}
function frameisequal(const a,b: framety): boolean; {$ifdef FPC}inline;{$endif}

function addpoint(const a,b: pointty): pointty;{$ifdef FPC}inline;{$endif}
                       //result:= a+b
procedure addpoint1(var dest: pointty; const point: pointty);{$ifdef FPC}inline;{$endif}
function subpoint(const a,b: pointty): pointty; {$ifdef FPC}inline;{$endif}
                       //result:= a-b
procedure subpoint1(var dest: pointty; const point: pointty);
                                                {$ifdef FPC}inline;{$endif}
function distance(const a,b: pointty): integer;{$ifdef FPC}inline;{$endif}

function addsize(const a,b: sizety): sizety;{$ifdef FPC}inline;{$endif}
                          //result:= a+b
procedure addsize1(var dest: sizety; const size: sizety);
                                    {$ifdef FPC}inline;{$endif}
function subsize(const a,b: sizety): sizety; {$ifdef FPC}inline;{$endif}
                                     //result:= a-b
procedure subsize1(var dest: sizety; const size: sizety);
                                      {$ifdef FPC}inline;{$endif}

function fitsize(const asize: sizety; const maxsize: sizety): sizety;

function rectcenter(const arect: rectty): pointty;
procedure centerrect(apos: pointty; asize: integer; out rect: rectty);
function excenterrect(const arect: rectty): rectty;
function recenterrect(const arect: rectty): rectty;

function inflaterect(const rect: rectty; value: integer): rectty; overload;
function inflaterect(const rect: rectty; const frame: framety): rectty; overload;
procedure inflaterect1(var rect: rectty; value: integer); overload;
procedure inflaterect1(var rect: rectty; const frame: framety); overload;
function deflaterect(const rect: rectty; const frame: framety): rectty;
procedure deflaterect1(var rect: rectty; const frame: framety);
procedure normalizerect1(var arect: rectty);
function normalizerect(const arect: rectty): rectty;
procedure swapxy1(var arect: rectty);

function addframe(const a,b: framety): framety;
procedure addframe1(var dest: framety; const frame: framety);
function subframe(const a,b: framety): framety;
procedure subframe1(var dest: framety; const frame: framety);
function expandrectext(const a,b: rectextty): rectextty;
procedure expandrectext1(var dest: rectextty; const frame: rectextty);

procedure inflaterectext1(var ext: rectextty; const frame: framety);
function inflaterectext(const ext: rectextty; const frame: framety): rectextty;
procedure deflaterectext1(var ext: rectextty; const frame: framety);
function deflaterectext(const ext: rectextty; const frame: framety): rectextty;

procedure inflateframe1(var frame: framety; value: integer);
function inflateframe(const frame: framety; value: integer): framety;

function moverect(const rect: rectty; const dist: pointty): rectty;
procedure moverect1(var rect: rectty; const dist: pointty);
function removerect(const rect: rectty; const dist: pointty): rectty;
procedure removerect1(var rect: rectty; const dist: pointty);
procedure shiftinrect(var rect: rectty; const outerrect: rectty);
procedure centerinrect(var rect: rectty; const outerrect: rectty);
function changerectdirection(const arect: rectty;
                const olddirction,newdirection: graphicdirectionty): rectty;
function rotateframe(const aframe: framety; const olddirection,
                  newdirection: graphicdirectionty): framety;
procedure rotateframe1(var aframe: framety; const olddirection,
                  newdirection: graphicdirectionty);
                
function intersectrect(const a,b: rectty; out dest: rectty): boolean; overload;
function intersectrect(const a,b: rectty): rectty; overload;
procedure intersectrect1(var dest: rectty; const source: rectty);
function testintersectrect(const a,b: rectty): boolean;
     //true on intersection
function clipinrect(const point: pointty;
                               const boundsrect: rectty): pointty; overload;
function clipinrect(const rect: rectty;
                                const boundsrect: rectty): rectty; overload;
function clipinrect1(var point: pointty;
                                const boundsrect: rectty): boolean; overload;
function clipinrect1(var rect: rectty; 
                              const boundsrect: rectty): boolean; overload;
            //true if changed
function calcrectalignment(const dest: rectty; source: rectty;
                                 const alignment: alignmentsty): rectty;

function pointinrect(const point: pointty; const rect: rectty): boolean;
     //true if point is in rect
function pointinellipse(const point: pointty; const rect: rectty): boolean;
     //true if point is in ellipse circumscribed by rect
function rectinrect(const inner,outer: rectty): boolean;
     //true if inner in outer

function segment(const a,b: pointty): segmentty; {$ifdef FPC}inline;{$endif}

procedure vectortoline(const vector: graphicvectorty; out a,b: pointty);

function rotatedirection(const olddest,newvalue,
                            oldvalue: graphicdirectionty): graphicdirectionty;

procedure removeduplicatedpoints(var vect: pointarty);

function hsbtorgb(hue,sat,bri: word): colorty;

implementation
uses
 mseglob,SysUtils,mseformatstr,classes,mclasses;
const
 errortexts: array[gdierrorty] of string = (
   '',
   'Invalid GC',
   'Can not create gc',
   'Can not create printer gc',
   'Can not create metafile gc',
   'Color mode must be truecolor',
   'Invalid color',
   'Invalid saveindex',
   'Invalid parameter',
   'Invalid font',
   'Invalid pixmap',
   'Can not free pixmap',
   'Invalid copymode',
   'Must be bitmap',
   'Must be monochrome',
   'Unmatched monochrome',
   'Invalid fontmetrics',
   'Can not create image',
   'Invalid rect',
   'Invalid file format',
   'Invalid index',
   'Not implemented',
   'GLX extension not supported.',
   'Could not find visual.',
   'Could not create a rendering context.',
   'Could not create a GLXPixmap.',
   'Could not create canvas window.'
 );

function hsbtorgb(hue,sat,bri: word): colorty;
var
 r,g,b: real;
 int1: integer;
 rea1,rea2: real;
begin
 if hue > 360 then begin
  hue:= 360;
 end;
 if sat > 100 then begin
  sat:= 100;
 end;
 if bri > 100 then begin
  bri:= 100;
 end;
 int1:= hue;
 r:= 0;
 g:= 0;
 b:= 0;
 if int1 < 60 then begin
  r:= 60;
  g:= int1;
 end
 else begin
  if int1 < 120 then begin
   r:= 120 - int1;
   g:= 60;
  end
  else begin
   if int1 < 180 then begin
    g:= 60;
    b:= int1 - 120;
   end
   else begin
    if int1 < 240 then begin
     g:= 240 - int1;
     b:= 60
    end
    else begin
     if int1 < 300 then begin
      b:= 60;
      r:= int1 - 240;
     end
     else begin
      b:= 360 - int1;
      r:= 60;
     end;
    end;
   end;
  end;
 end;
 rea1:= sat / 100;
 rea2:= 1-rea1;
 rea1:= rea1 / 60;
 r:= r * rea1 + rea2;
 g:= g * rea1 + rea2;
 b:= b * rea1 + rea2;
 rea1:= bri / 100;
 r:= r*rea1;
 g:= g*rea1;
 b:= b*rea1;
 with rgbtriplety(result) do begin
  res:= 0;
  red:= round(r*255);
  green:= round(g*255);
  blue:= round(b*255);
 end;
end;

function calcrectalignment(const dest: rectty; source: rectty;
                                 const alignment: alignmentsty): rectty;
begin
 result:= dest;
 if al_tiled in alignment then begin
  exit;
 end;
 if al_fit in alignment then begin
  if source.cy * dest.cx > source.cx * dest.cy then begin //fit vert
   if source.cy <> 0 then begin
    source.cx:= (source.cx * dest.cy) div source.cy;
    source.cy:= (source.cy * dest.cy) div source.cy;
   end;
  end
  else begin
   if source.cx <> 0 then begin
    source.cy:= (source.cy * dest.cx) div source.cx;
    source.cx:= (source.cx * dest.cx) div source.cx; //fit horz
   end;
  end;
 end;
 if al_stretchx in alignment then begin
  source.cx:= dest.cx;
 end;
 if al_stretchy in alignment then begin
  source.cy:= dest.cy;
 end;
 result.size:= source.size;
 if al_xcentered in alignment then begin
  result.x:= dest.x + (dest.cx - source.cx) div 2
 end
 else begin
  if al_right in alignment then begin
   result.x:= dest.x + dest.cx - source.cx;
  end;
 end;
 if al_ycentered in alignment then begin
  result.y:= dest.y + (dest.cy - source.cy) div 2
 end
 else begin
  if al_bottom in alignment then begin
   result.y:= dest.y + dest.cy - source.cy;
  end;
 end;
 intersectrect1(result,dest);
end;

procedure removeduplicatedpoints(var vect: pointarty);
var
 ar1: pointarty;
 int1,int2: integer;
begin
 if vect <> nil then begin
  setlength(ar1,length(vect));
  int2:= 0;
  ar1[0]:= vect[0];
  for int1:= 1 to high(vect) do begin
   if (ar1[int2].x <> vect[int1].x) or (ar1[int2].y <> vect[int1].y) then begin
    inc(int2);
    ar1[int2]:= vect[int1];
   end;
  end;
  setlength(ar1,int2+1);
  vect:= ar1;
 end;
end;

function stringtocolor(value: string): colorty;
var
 ca1: longword;
begin
 result:= cl_none;
 if trystrtohex(value,longword(result)) then begin
  if longword(result) > $00ffffff then begin
   gdierror(gde_invalidcolor);
  end;
 end
 else begin
  value:= lowercase(value);
  for ca1:= 0 to mapcolorcounts[cm_namedrgb] - 1 do begin
   if defaultnamedrgb[ca1].name = value then begin
    result:= colorty(ca1 + longword(cl_namedrgb));
    exit;
   end;
  end;
  for ca1:= 0 to mapcolorcounts[cm_mapped] - 1 do begin
   if defaultmapped[ca1].name = value then begin
    result:= colorty(ca1 + longword(cl_mapped));
    exit;
   end;
  end;
  for ca1:= 0 to mapcolorcounts[cm_functional] - 1 do begin
   if defaultfunctional[ca1].name = value then begin
    result:= colorty(ca1 + longword(cl_functional));
    exit;
   end;
  end;
  for ca1:= 0 to mapcolorcounts[cm_user] - 1 do begin
   if defaultuser[ca1].name = value then begin
    result:= colorty(ca1 + longword(cl_user));
    exit;
   end;
  end;
  gdierror(gde_invalidcolor);
 end;
end;

function colortostring(value: colorty): string;
begin
 if longword(value) <= $00ffffff then begin
  result:= '$'+hextostr(longword(value),6);
 end
 else begin
  if (longword(value) >= longword(cl_namedrgb)) and
       (longword(value) < longword(cl_lastnamedrgb)) then begin
   result:= defaultnamedrgb[longword(value) - longword(cl_namedrgb)].name;
  end
  else begin
   if (longword(value) >= longword(cl_mapped)) and
        (longword(value) < longword(cl_lastmapped)) then begin
    result:= defaultmapped[longword(value) - longword(cl_mapped)].name;
   end
   else begin
    if (longword(value) >= longword(cl_functional)) and
         (longword(value) < longword(cl_lastfunctional)) then begin
     result:= defaultfunctional[longword(value) - longword(cl_functional)].name;
    end
    else begin
     if (longword(value) >= longword(cl_user)) and
          (longword(value) < longword(cl_lastuser)) then begin
      result:= defaultuser[longword(value) - longword(cl_user)].name;
     end
     else begin
      result:= 'Invalid ($'+hextostr(longword(value),8)+')';
     end;
    end;
   end;
  end;
 end;
end;

function getcolornames: msestringarty;
var
 int1,int2: integer;
begin
 setlength(result,namedrgbcolorcount+mappedcolorcount+
          functionalcolorcount+usercolorcount-1);
 for int1:= 0 to high(defaultnamedrgb) do begin
  result[int1]:= defaultnamedrgb[int1].name;
 end;
 int2:= namedrgbcolorcount;
 for int1:= 0 to high(defaultmapped) do begin
  result[int1+int2]:= defaultmapped[int1].name;
 end;
 inc(int2,mappedcolorcount);
 result[int2]:= defaultfunctional[cl_nonenum].name;
 for int1:= 1 to cl_nonenum-1 do begin
  result[int1+int2]:= defaultfunctional[int1].name;
 end;
 for int1:= cl_nonenum + 1 to functionalcolorcount-1 do begin
  result[int1-1+int2]:= defaultfunctional[int1].name;
 end;
 {
 for int1:= cl_nonenum+1 to high(defaultfunctional) do begin
  result[int1+int2-1]:= defaultfunctional[int1].name;
 end;
 }
 inc(int2,functionalcolorcount-1);
 for int1:= 0 to high(defaultuser) do begin
  result[int1+int2]:= defaultuser[int1].name;
 end;
end;

function getcolorvalues: colorarty;
var
 int1,int2: integer;
begin
 setlength(result,namedrgbcolorcount+mappedcolorcount+
                     functionalcolorcount+usercolorcount-1);
 for int1:= 0 to high(defaultnamedrgb) do begin
  result[int1]:= cl_namedrgb + longword(int1);
 end;
 int2:= namedrgbcolorcount;
 for int1:= 0 to high(defaultmapped) do begin
  result[int1+int2]:= cl_mapped + longword(int1);
 end;
 inc(int2,mappedcolorcount);
 result[int2]:= cl_functional+cl_nonenum;
 for int1:= 1 to cl_nonenum-1 do begin
  result[int1+int2]:= cl_functional + longword(int1);
 end;
 for int1:= cl_nonenum+1 to functionalcolorcount-1 do begin
  result[int1+int2]:= cl_functional + longword(int1);
 end;
 inc(int2,functionalcolorcount-1);
 for int1:= 0 to high(defaultuser) do begin
  result[int1+int2]:= cl_user + longword(int1);
 end;
end;


function rotateframe(const aframe: framety; const olddirection,
                  newdirection: graphicdirectionty): framety;
begin
 result:= aframe;
 rotateframe1(result,olddirection,newdirection);
end;

procedure rotateframe1(var aframe: framety; const olddirection,
                  newdirection: graphicdirectionty);
var
 int1: integer;
 frame1: framety;
begin
 if olddirection <> newdirection then begin
  frame1:= aframe;
  int1:= (ord(newdirection) - ord(olddirection)) and $3;
  case int1 of
   1: begin
    aframe.top:= frame1.right;
    aframe.left:= frame1.top;
    aframe.bottom:= frame1.left;
    aframe.right:= frame1.bottom;
   end;
   2: begin
    aframe.left:= frame1.right;
    aframe.bottom:= frame1.top;
    aframe.right:= frame1.left;
    aframe.top:= frame1.bottom;
   end;
   3: begin
    aframe.bottom:= frame1.right;
    aframe.right:= frame1.top;
    aframe.top:= frame1.left;
    aframe.left:= frame1.bottom;
   end;
  end;
 end;
end;

function rotatedirection(const olddest,newvalue,
                    oldvalue: graphicdirectionty): graphicdirectionty;
begin
 result:= graphicdirectionty(((ord(olddest)+ord(newvalue)-ord(oldvalue)) and $3));
end;

procedure shiftinrect(var rect: rectty; const outerrect: rectty);
var
 int1: integer;
begin
 with rect do begin
  int1:= outerrect.x + outerrect.cx - (x + cx);
  if int1 < 0 then begin
   inc(x,int1);
  end;
  int1:= outerrect.y + outerrect.cy - (y + cy);
  if int1 < 0 then begin
   inc(y,int1);
  end;
  if x < outerrect.x then begin
   x:= outerrect.x;
  end;
  if y < outerrect.y then begin
   y:= outerrect.y;
  end;
 end;
end;

procedure centerinrect(var rect: rectty; const outerrect: rectty);
begin
 with outerrect do begin
  rect.x:= x + (cx - rect.cx) div 2;
  rect.y:= y + (cy - rect.cy) div 2;
 end;
end;

function changerectdirection(const arect: rectty;
                const olddirction,newdirection: graphicdirectionty): rectty;
begin
 result.pos:= arect.pos;
 if (olddirction in [gd_left,gd_right]) xor 
                (newdirection in [gd_left,gd_right]) then begin
  result.cx:= arect.cy;
  result.cy:= arect.cx;
 end
 else begin
  result.size:= arect.size;
 end;
end;

function makepoint(const x,y: integer): pointty; {$ifdef FPC}inline;{$endif}
begin
 result.x:= x;
 result.y:= y;
end;

function makesize(const cx,cy: integer): sizety; {$ifdef FPC}inline;{$endif}
begin
 result.cx:= cx;
 result.cy:= cy;
end;

function makerect(const x,y,cx,cy: integer): rectty; {$ifdef FPC}inline;{$endif}
begin
 result.x:= x;
 result.y:= y;
 result.cx:= cx;
 result.cy:= cy;
end;

function makerect(const pos: pointty; const size: sizety): rectty; overload;
                                    {$ifdef FPC}inline;{$endif}
begin
 result.pos:= pos;
 result.size:= size;
end;

function makeframe(const left,top,right,bottom: integer): framety;
                               {$ifdef FPC}inline;{$endif}
begin
 result.left:= left;
 result.top:= top;
 result.right:= right;
 result.bottom:= bottom;
end;

function mf(const left,top,right,bottom: integer): framety;
                               {$ifdef FPC}inline;{$endif}
begin
 result.left:= left;
 result.top:= top;
 result.right:= right;
 result.bottom:= bottom;
end;

function makesegment(const a,b: pointty): segmentty;
                               {$ifdef FPC}inline;{$endif}
begin
 result.a:= a;
 result.b:= b;
end;

function mp(const x,y: integer): pointty;{$ifdef FPC}inline;{$endif}
begin
 result.x:= x;
 result.y:= y;
end;

function ms(const cx,cy: integer): sizety; {$ifdef FPC}inline;{$endif}
begin
 result.cx:= cx;
 result.cy:= cy;
end;

function mr(const x,y,cx,cy: integer): rectty; {$ifdef FPC}inline;{$endif}
begin
 result.x:= x;
 result.y:= y;
 result.cx:= cx;
 result.cy:= cy;
end;

function mr(const pos: pointty; const size: sizety): rectty; overload;
                                      {$ifdef FPC}inline;{$endif}
begin
 result.pos:= pos;
 result.size:= size;
end;

function mg(const a,b: pointty): segmentty;
                               {$ifdef FPC}inline;{$endif}
begin
 result.a:= a;
 result.b:= b;
end;

function bottomright(const rect: rectty): pointty; {$ifdef FPC}inline;{$endif}
begin
 result.x:= rect.x + rect.cx;
 result.y:= rect.y + rect.cy;
end;

function isnullpoint(const point: pointty): boolean;{$ifdef FPC}inline;{$endif}
begin
 with point do begin
  result:= (x = 0) and (y = 0);
 end;
end;

function isnullsize(const size: sizety): boolean;{$ifdef FPC}inline;{$endif}
begin
 with size do begin
  result:= (cx = 0) and (cy = 0);
 end;
end;

function isnullrect(const rect: rectty): boolean;{$ifdef FPC}inline;{$endif}
begin
 with rect do begin
  result:= (x = 0) and (y = 0) and (cx = 0) and (cy = 0);
 end;
end;

function isnullframe(const frame: framety): boolean;{$ifdef FPC}inline;{$endif}
begin
 with frame do begin
  result:= (left = 0) and (top = 0) and (right = 0) and (bottom = 0);
 end;
end;

function pointisequal(const a,b: pointty): boolean;{$ifdef FPC}inline;{$endif}
begin
 result:= (a.x = b.x) and (a.y = b.y);
end;

function sizeisequal(const a,b: sizety): boolean; {$ifdef FPC}inline;{$endif}
begin
 result:= (a.cx = b.cx) and (a.cy = b.cy);
end;

function rectisequal(const a,b: rectty): boolean; {$ifdef FPC}inline;{$endif}
begin
 result:= (a.x = b.x) and (a.y = b.y) and
                    (a.cx = b.cx) and (a.cy = b.cy);
end;

function frameisequal(const a,b: framety): boolean;{$ifdef FPC}inline;{$endif}
begin
 result:= (a.left = b.left) and (a.top = b.top) and
                  (a.right = b.right) and (a.bottom = b.bottom);
end;

function addpoint(const a,b: pointty): pointty;{$ifdef FPC}inline;{$endif}
                                                     //result:= a-b
begin
 result.x:= a.x+b.x;
 result.y:= a.y+b.y;
end;

procedure addpoint1(var dest: pointty; const point: pointty);
                                              {$ifdef FPC}inline;{$endif}
begin
 inc(dest.x,point.x);
 inc(dest.y,point.y);
end;

function subpoint(const a,b: pointty): pointty;{$ifdef FPC}inline;{$endif}
                                      //result:= a-b
begin
 result.x:= a.x-b.x;
 result.y:= a.y-b.y;
end;

procedure subpoint1(var dest: pointty; const point: pointty);
                                                  {$ifdef FPC}inline;{$endif}
begin
 dec(dest.x,point.x);
 dec(dest.y,point.y);
end;

function distance(const a,b: pointty): integer;{$ifdef FPC}inline;{$endif}
begin
 result:= abs(a.x-b.x) + abs(a.y-b.y);
end;

function addsize(const a,b: sizety): sizety;{$ifdef FPC}inline;{$endif}
                                //result:= a+b
begin
 result.cx:= a.cx+b.cx;
 result.cy:= a.cy+b.cy;
end;

procedure addsize1(var dest: sizety; const size: sizety);
                         {$ifdef FPC}inline;{$endif}
begin
 inc(dest.cx,size.cx);
 inc(dest.cy,size.cy);
end;

function subsize(const a,b: sizety): sizety;{$ifdef FPC}inline;{$endif}
                     //result:= a-b
begin
 result.cx:= a.cx-b.cx;
 result.cy:= a.cy-b.cy;
end;

procedure subsize1(var dest: sizety; const size: sizety);
                                        {$ifdef FPC}inline;{$endif}
begin
 dec(dest.cx,size.cx);
 dec(dest.cy,size.cy);
end;

function segment(const a,b: pointty): segmentty; {$ifdef FPC}inline;{$endif}
begin
 result.a:= a;
 result.b:= b;
end;

procedure vectortoline(const vector: graphicvectorty; out a,b: pointty);
begin
 with vector do begin
  a:= start;
  case direction of
   gd_right: begin
    b.x:= start.x+length;
    b.y:= start.y;
   end;
   gd_up: begin
    b.x:= start.x;
    b.y:= start.y - length;
   end;
   gd_left: begin
    b.x:= start.x - length;
    b.y:= start.y;
   end;
   gd_down: begin
    b.x:= start.x;
    b.y:= start.y + length;
   end;
  end;
 end;
end;

function deflaterect(const rect: rectty; const frame: framety): rectty;
begin
 result.x:= rect.x + frame.left;
 result.cx:= rect.cx - frame.left - frame.right;
 result.y:= rect.y + frame.top;
 result.cy:= rect.cy - frame.top - frame.bottom;
end;

procedure deflaterect1(var rect: rectty; const frame: framety);
begin
 inc(rect.x,frame.left);
 dec(rect.cx,frame.left);
 inc(rect.y,frame.top);
 dec(rect.cy,frame.top);
 dec(rect.cx,frame.right);
 dec(rect.cy,frame.bottom);
end;

procedure normalizerect1(var arect: rectty);
begin
 if arect.cx < 0 then begin
  arect.x:= arect.x + arect.cx + 1;
  arect.cx:= -arect.cx;
 end;
 if arect.cy < 0 then begin
  arect.y:= arect.y + arect.cy + 1;
  arect.cy:= -arect.cy;
 end;
end;

function normalizerect(const arect: rectty): rectty;
begin
 result:= arect;
 normalizerect1(result);
end;

procedure swapxy1(var arect: rectty);
var
 int1: integer;
begin
 with arect do begin
  int1:= x;
  x:= y;
  y:= int1;
  int1:= cx;
  cx:= cy;
  cy:= int1;
 end;
end;

function addframe(const a,b: framety): framety;
begin
 with result do begin
  left:= a.left + b.left;
  top:= a.top + b.top;
  right:= a.right + b.right;
  bottom:= a.bottom + b.bottom;
 end;
end;

procedure addframe1(var dest: framety; const frame: framety);
begin
 with dest do begin
  left:= left + frame.left;
  top:= top + frame.top;
  right:= right + frame.right;
  bottom:= bottom + frame.bottom;
 end;
end;

function subframe(const a,b: framety): framety;
begin
 with result do begin
  left:= a.left - b.left;
  top:= a.top - b.top;
  right:= a.right - b.right;
  bottom:= a.bottom - b.bottom;
 end;
end;

procedure subframe1(var dest: framety; const frame: framety);
begin
 with dest do begin
  left:= left - frame.left;
  top:= top - frame.top;
  right:= right - frame.right;
  bottom:= bottom - frame.bottom;
 end;
end;

function expandrectext(const a,b: rectextty): rectextty;
begin
 result:= a;
 with result do begin
  if b.left < left then begin
   left:= b.left;
  end;
  if b.right > right then begin
   right:= b.right;
  end;
  if b.top < top then begin
   top:= b.top;
  end;
  if b.bottom < bottom then begin
   bottom:= b.bottom;
  end;
 end;
end;

procedure expandrectext1(var dest: rectextty; const frame: rectextty);
begin
 with dest do begin
  if frame.left < left then begin
   left:= frame.left;
  end;
  if frame.right > right then begin
   right:= frame.right;
  end;
  if frame.top < top then begin
   top:= frame.top;
  end;
  if frame.bottom > bottom then begin
   bottom:= frame.bottom;
  end;
 end;
end;

procedure inflaterectext1(var ext: rectextty; const frame: framety);
begin
 with ext do begin
  left:= left - frame.left;
  top:= top - frame.top;
  right:= right + frame.right;
  bottom:= bottom + frame.bottom;
 end;
end;

function inflaterectext(const ext: rectextty; const frame: framety): rectextty;
begin
 with result do begin
  left:= ext.left - frame.left;
  top:= ext.top - frame.top;
  right:= ext.right + frame.right;
  bottom:= ext.bottom + frame.bottom;
 end;
end;

procedure deflaterectext1(var ext: rectextty; const frame: framety);
begin
 with ext do begin
  left:= left + frame.left;
  top:= top + frame.top;
  right:= right - frame.right;
  bottom:= bottom - frame.bottom;
 end;
end;

function deflaterectext(const ext: rectextty; const frame: framety): rectextty;
begin
 with result do begin
  left:= ext.left + frame.left;
  top:= ext.top + frame.top;
  right:= ext.right - frame.right;
  bottom:= ext.bottom - frame.bottom;
 end;
end;

function pointinrect(const point: pointty; const rect: rectty): boolean;
     //true if point is in rect
begin
 result:= (point.x >= rect.x) and (point.x < rect.x + rect.cx) and
          (point.y >= rect.y) and (point.y < rect.y + rect.cy);
end;

function pointinellipse(const point: pointty; const rect: rectty): boolean;
     //true if point is in ellipse circumscribed by rect
var
 x1,y1: real;
 x0q,y0q: real;
begin
 x1:= point.x - rect.x - rect.cx div 2;
 y1:= point.y - rect.y - rect.cy div 2;
 x0q:= rect.cx*rect.cx;
 y0q:= rect.cy*rect.cy;
 result:= (x1*x1*y0q+y1*y1*x0q)*4 <= x0q*y0q;
end;

function fitsize(const asize: sizety; const maxsize: sizety): sizety;
begin
 result:= nullsize;
 if asize.cx*maxsize.cy > maxsize.cx*asize.cy then begin //fit horz
  result.cx:= maxsize.cx;
  if asize.cx <> 0 then begin
   result.cy:= (asize.cy*maxsize.cx) div asize.cx;
  end;
 end
 else begin                                  //fit vert
  result.cy:= maxsize.cy;
  if asize.cy <> 0 then begin
   result.cx:= (asize.cx*maxsize.cy) div asize.cy;
  end;
 end;
end;

function rectcenter(const arect: rectty): pointty;
begin
 with arect do begin
  result.x:= x + cx div 2;
  result.y:= y + cy div 2;
 end;
end;

procedure centerrect(apos: pointty; asize: integer; out rect: rectty);
var
 int1: integer;
begin
 int1:= asize div 2;
 with rect do begin
  x:= apos.x - int1;
  y:= apos.y - int1;
  cx:= asize;
  cy:= asize;
 end;
end;

function excenterrect(const arect: rectty): rectty;
begin
 with result do begin
  x:= arect.x - arect.cx div 2;
  y:= arect.y - arect.cy div 2;
  cx:= arect.cx;
  cy:= arect.cy;
 end;
end;

function recenterrect(const arect: rectty): rectty;
begin
 with result do begin
  x:= arect.x + arect.cx div 2;
  y:= arect.y + arect.cy div 2;
  cx:= arect.cx;
  cy:= arect.cy;
 end;
end;

function inflaterect(const rect: rectty; value: integer): rectty;
begin
 with rect do begin
  result.x:= x - value;
  result.y:= y - value;
  result.cx:= cx + value + value;
  result.cy:= cy + value + value;
 end;
end;

function inflaterect(const rect: rectty; const frame: framety): rectty;
begin
 result.x:= rect.x - frame.left;
 result.cx:= rect.cx + frame.left + frame.right;
 result.y:= rect.y - frame.top;
 result.cy:= rect.cy + frame.top + frame.bottom;
end;

procedure inflaterect1(var rect: rectty; value: integer);
begin
 with rect do begin
  dec(x,value);
  dec(y,value);
  inc(cx,value);
  inc(cx,value);
  inc(cy,value);
  inc(cy,value);
 end;
end;

procedure inflaterect1(var rect: rectty; const frame: framety);
begin
 dec(rect.x,frame.left);
 inc(rect.cx,frame.left);
 dec(rect.y,frame.top);
 inc(rect.cy,frame.top);
 inc(rect.cx,frame.right);
 inc(rect.cy,frame.bottom);
end;


procedure inflateframe1(var frame: framety; value: integer);
begin
 inc(frame.left,value);
 inc(frame.top,value);
 inc(frame.right,value);
 inc(frame.bottom,value);
end;

function inflateframe(const frame: framety; value: integer): framety;
begin
 result.left:= frame.left + value;
 result.top:= frame.top + value;
 result.right:= frame.right + value;
 result.bottom:= frame.bottom + value;
end;


function moverect(const rect: rectty; const dist: pointty): rectty;
begin
 result.x:= rect.x + dist.x;
 result.y:= rect.y + dist.y;
 result.size:= rect.size;
end;

procedure moverect1(var rect: rectty; const dist: pointty);
begin
 inc(rect.x,dist.x);
 inc(rect.y,dist.y);
end;

function removerect(const rect: rectty; const dist: pointty): rectty;
begin
 result.x:= rect.x - dist.x;
 result.y:= rect.y - dist.y;
 result.size:= rect.size;
end;

procedure removerect1(var rect: rectty; const dist: pointty);
begin
 dec(rect.x,dist.x);
 dec(rect.y,dist.y);
end;

function intersectrect(const a,b: rectty; out dest: rectty): boolean;
var
 rect1: rectty;
begin
 with rect1 do begin
  if a.x > b.x then begin
   x:= a.x;
   if a.x + a.cx > b.x + b.cx then begin
    cx:= b.x + b.cx - a.x;
   end
   else begin
    cx:= a.cx;
   end;
  end
  else begin
   x:= b.x;
   if b.x + b.cx > a.x + a.cx then begin
    cx:= a.x + a.cx - b.x;
   end
   else begin
    cx:= b.cx;
   end;
  end;
  if a.y > b.y then begin
   y:= a.y;
   if a.y + a.cy > b.y + b.cy then begin
    cy:= b.y + b.cy - a.y;
   end
   else begin
    cy:= a.cy;
   end;
  end
  else begin
   y:= b.y;
   if b.y + b.cy > a.y + a.cy then begin
    cy:= a.y + a.cy - b.y;
   end
   else begin
    cy:= b.cy;
   end;
  end;
  if (cx <= 0) or (cy <= 0) then begin
   result:= false;
   dest:= nullrect;
  end
  else begin
   result:= true;
   dest:= rect1;
  end;
 end;
end;

function intersectrect(const a,b: rectty): rectty;
begin
 intersectrect(a,b,result);
end;

procedure intersectrect1(var dest: rectty; const source: rectty);
begin
 intersectrect(source,dest,dest);
end;

function testintersectrect(const a,b: rectty): boolean;
     //true on intersection
var
 rect1: rectty;
begin
 result:= intersectrect(a,b,rect1);
end;

function rectinrect(const inner,outer: rectty): boolean;

 procedure normalize(const rect: rectty; out topleft,bottomright: pointty);
 begin
  with rect do begin
   if cx < 0 then begin
    topleft.x:= x + cx;
    bottomright.x:= x;
   end
   else begin
    topleft.x:= x;
    bottomright.x:= x + cx;
   end;
   if cy < 0 then begin
    topleft.y:= y + cy;
    bottomright.y:= y;
   end
   else begin
    topleft.y:= y;
    bottomright.y:= y + cy;
   end;
  end;
 end;

var
 itopleft,ibottomright: pointty;
 otopleft,obottomright: pointty;
begin
 normalize(inner,itopleft,ibottomright);
 normalize(outer,otopleft,obottomright);
 result:= (itopleft.x >= otopleft.x) and (ibottomright.x <= obottomright.x) and
          (itopleft.y >= otopleft.y) and (ibottomright.y <= obottomright.y);
end;

function clipinrect1(var point: pointty; const boundsrect: rectty): boolean;
begin
 result:= false;
 with boundsrect do begin
  if point.x < x then begin
   result:= true;
   point.x:= x;
  end;
  if point.x >= x + cx then begin
   result:= true;
   point.x:= x + cx - 1;
  end;
  if point.y < y then begin
   result:= true;
   point.y:= y;
  end;
  if point.y >= y + cy then begin
   result:= true;
   point.y:= y + cy - 1;
  end;
 end;
end;

function clipinrect(const point: pointty; const boundsrect: rectty): pointty;
begin
 result:= point;
 clipinrect1(result,boundsrect);
end;

function clipinrect1(var rect: rectty; const boundsrect: rectty): boolean;
begin
 result:= false;
 with boundsrect do begin
  if rect.x < x then begin
   result:= true;
   rect.x:= x;
  end;
  if rect.x + rect.cx > x + cx then begin
   rect.x:= x + cx - rect.cx;
   if rect.x < x then begin
    result:= true;
    rect.x:= x;
    rect.cx:= cx;
   end;
  end;
  if rect.y < y then begin
   result:= true;
   rect.y:= y;
  end;
  if rect.y + rect.cy > y + cy then begin
   result:= true;
   rect.y:= y + cy - rect.cy;
   if rect.y < y then begin
    rect.y:= y;
    rect.cy:= cy;
   end;
  end;
 end;
end;

function clipinrect(const rect: rectty; const boundsrect: rectty): rectty;
begin
 result:= rect;
 clipinrect1(result,boundsrect);
end;

function rx(const arect: rectty): integer;
begin
 result:= arect.x;
end;

function ry(const arect: rectty): integer;
begin
 result:= arect.y;
end;

function rcx(const arect: rectty): integer;
begin
 result:= arect.cx;
end;

function rcy(const arect: rectty): integer;
begin
 result:= arect.cy;
end;

function rstopx(const arect: rectty): integer;
begin
 result:= arect.x + arect.cx;
end;

function rstopy(const arect: rectty): integer;
begin
 result:= arect.y + arect.cy;
end;

procedure rsetx(var arect: rectty; const avalue: integer);
begin
 arect.x:= avalue;
end;

procedure rsety(var arect: rectty; const avalue: integer);
begin
 arect.y:= avalue;
end;

procedure rsetcx(var arect: rectty; const avalue: integer);
begin
 arect.cx:= avalue;
end;

procedure rsetcy(var arect: rectty; const avalue: integer);
begin
 arect.cy:= avalue;
end;

procedure rsetstopx(var arect: rectty; const avalue: integer);
begin
 arect.cx:= avalue - arect.x;
end;

procedure rsetstopy(var arect: rectty; const avalue: integer);
begin
 arect.cy:= avalue - arect.y;
end;

function makesizex(const value,ovalue: integer): sizety;
begin
 result.cx:= value;
 result.cy:= ovalue;
end;

function makesizey(const value,ovalue: integer): sizety;
begin
 result.cy:= value;
 result.cx:= ovalue;
end;

function makeposx(const value,ovalue: integer): pointty;
begin
 result.x:= value;
 result.y:= ovalue;
end;

function makeposy(const value,ovalue: integer): pointty;
begin
 result.y:= value;
 result.x:= ovalue;
end;

function px(const apoint: pointty): integer;
begin
 result:= apoint.x;
end;

function py(const apoint: pointty): integer;
begin
 result:= apoint.y;
end;

function sx(const asize: sizety): integer;
begin
 result:= asize.cx;
end;

function sy(const asize: sizety): integer;
begin
 result:= asize.cy;
end;

procedure psetx(var apoint: pointty; const avalue: integer);
begin
 apoint.x:= avalue;
end;

procedure psety(var apoint: pointty; const avalue: integer);
begin
 apoint.y:= avalue;
end;

procedure ssetx(var asize: sizety; const avalue: integer);
begin
 asize.cx:= avalue;
end;

procedure ssety(var asize: sizety; const avalue: integer);
begin
 asize.cy:= avalue;
end;

procedure gdierror(error: gdierrorty; const text: string = ''); overload;
begin
 if error = gde_ok then begin
  exit;
 end;
 raise egdi.create(error,text);
end;

procedure gdierror(error: gdierrorty; sender: tobject;
                       text: string = ''); overload;
begin
 if error = gde_ok then begin
  exit;
 end;
 if sender <> nil then begin
  text:= sender.classname + ' ' + text;
  if sender is tcomponent then begin
   text:= text + ' ' + fullcomponentname(tcomponent(sender));
  end;
 end;
 gdierror(error,text);
end;

{ egdi }

constructor egdi.create(aerror: gdierrorty; atext: string);
begin
 inherited create(integer(aerror),atext,errortexts);
end;

end.

