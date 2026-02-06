{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseuniintf; //X11

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msegraphics,msetypes{msestrings};

{$include ../mseuniintf.inc}

function uni_listfontswithglyph(achar: msechar): msestringarty;

implementation
uses
 mseguiintf,msex11gdi,mxft,mxlib,msefontconfig;

function uni_getfontwithglyph(var drawinfo: drawinfoty): boolean;
var
 pat1: pfcpattern;
 charset1,charset2: pfccharset;
 res1: tfcresult;
 fontset1: pfcfontset;
 po1: ppfcpattern;
 int1: integer;
 font1: pxftfont;
begin
 result:= false;
 if hasxft then begin
{$ifdef FPC} {$checkpointer off} {$endif}
  pat1:= fontdatatoxftpat(drawinfo.getfont.fontdata^,false);
  if pat1 <> nil then begin
   with drawinfo.getfont.fontdata^ do begin
    charset1:= fccharsetcreate();
    fccharsetaddchar(charset1,h.d.glyph);
    fcpatternaddcharset(pat1,fc_charset,charset1);
    fccharsetdestroy(charset1);
    fcconfigsubstitute(nil,pat1,fcmatchpattern);
    fcconfigsubstitute(nil,pat1,fcmatchfont);
    xftdefaultsubstitute(msedisplay,xdefaultscreen(msedisplay),pat1);
    fontset1:= fcfontsort(nil,pat1,true,@charset1,@res1);
    if fccharsethaschar(charset1,h.d.glyph) then begin
     with fontset1^ do begin
      po1:= fonts;
      for int1:= 0 to nfont - 1 do begin
       if fcpatterngetcharset(po1^,fc_charset,0,@charset2) = fcresultmatch then begin
        if fccharsethaschar(charset2,h.d.glyph) then begin
         font1:= xftfontopenpattern(msedisplay,
                                     fcfontrenderprepare(nil,pat1,po1^));
         if font1 <> nil then begin
          if xftcharexists(msedisplay,font1,h.d.glyph) then begin
           getxftfontdata(font1,drawinfo);
           result:= true;
          end
          else begin
           xftfontclose(msedisplay,font1);
          end;
         end;
         break;
        end;
       end;
       inc(po1);
      end;
     end;
    end;
    fccharsetdestroy(charset1);
    fcpatterndestroy(pat1);
    fcfontsetdestroy(fontset1);
   end;
  end;
{$ifdef FPC} {$checkpointer default} {$endif}
 end;
end;

function uni_listfontswithglyph(achar: msechar): msestringarty;
var
 pat1: pfcpattern;
 charset1,charset2: pfccharset;
 res1: tfcresult;
 fontset1: pfcfontset;
 po1: ppfcpattern;
 int1,int2: integer;
// font1: pxftfont;
 po2: pchar;
begin
 result:= nil;
 if hasxft then begin
{$ifdef FPC} {$checkpointer off} {$endif}
  pat1:= fcpatterncreate();
  charset1:= fccharsetcreate();
  fccharsetaddchar(charset1,longword(achar));
  fcpatternaddcharset(pat1,fc_charset,charset1);
  fccharsetdestroy(charset1);
  fcconfigsubstitute(nil,pat1,fcmatchpattern);
  fcconfigsubstitute(nil,pat1,fcmatchfont);
  xftdefaultsubstitute(msedisplay,xdefaultscreen(msedisplay),pat1);
  fontset1:= fcfontsort(nil,pat1,true,@charset1,@res1);
  if fccharsethaschar(charset1,longword(achar)) then begin
   with fontset1^ do begin
    po1:= fonts;
    setlength(result,nfont);
    int2:= 0;
    for int1:= 0 to nfont - 1 do begin
     if fcpatterngetcharset(po1^,fc_charset,0,@charset2) = fcresultmatch then begin
      if fccharsethaschar(charset2,longword(achar)) then begin
       if fcpatterngetstring(po1^,fc_family,0,@po2) = fcresultmatch then begin
        result[int2]:= po2;
       end;
       inc(int2);
      end;
     end;
     inc(po1);
    end;
    setlength(result,int2);
   end;
  end;
  fccharsetdestroy(charset1);
  fcpatterndestroy(pat1);
  fcfontsetdestroy(fontset1);
 end;
{$ifdef FPC} {$checkpointer default} {$endif}
end;

end.
