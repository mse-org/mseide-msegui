{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseuniintf; //i386-linux

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegraphics;
 
{$include ../mseuniintf.inc}

implementation
uses
 mseguiintf,xft,xlib;
 
function uni_getfontwithglyph(var drawinfo: drawinfoty): boolean;
var
 str1: ansistring;
 pat1: pfcpattern;
 charset1,charset2: pfccharset;
 value1: tfcvalue;
 res1: tfcresult;
 fontset1: pfcfontset;
 po1: ppfcpattern;
 int1: integer;
 font1: pxftfont;
 
begin
 result:= false;
 if hasxft then begin
  str1:= fontdatatoxftname(drawinfo.getfont.fontdata^);
  pat1:= xftnameparse(pansichar(str1));
  if pat1 <> nil then begin
   with drawinfo.getfont.fontdata^ do begin
    charset1:= fccharsetcreate();
    fccharsetaddchar(charset1,glyph);
    value1.u.c:= charset1;
    fcpatternadd(pat1,fc_charset,value1,true);
    fccharsetdestroy(charset1);
    fcconfigsubstitute(nil,pat1,fcmatchpattern);
    fcconfigsubstitute(nil,pat1,fcmatchfont);
    xftdefaultsubstitute(msedisplay,xdefaultscreen(msedisplay),pat1);
    fontset1:= fcfontsort(nil,pat1,true,@charset1,@res1);
    if fccharsethaschar(charset1,glyph) then begin
     with fontset1^ do begin
      po1:= fonts;
      for int1:= 0 to nfont - 1 do begin
       if fcpatterngetcharset(po1^,fc_charset,0,@charset2) = fcresultmatch then begin
        if fccharsethaschar(charset2,glyph) then begin
        {$ifdef FPC} {$checkpointer off} {$endif}
         font1:= xftfontopenpattern(msedisplay,
                                     fcfontrenderprepare(nil,pat1,po1^));
         if font1 <> nil then begin
          if xftcharexists(msedisplay,font1,glyph) then begin
           getxftfontdata(font1,drawinfo);
          end
          else begin
           xftfontclose(msedisplay,font1);
          end;
        {$ifdef FPC} {$checkpointer default} {$endif}
          result:= true;
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
 end;
end;

end.
