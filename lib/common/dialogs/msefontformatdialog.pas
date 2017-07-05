{ MSEgui Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefontformatdialog;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,
 mserichstring,msesplitter,msesimplewidgets,msestatfile,mseact,msecolordialog,
 msedataedits,mseedit,mseificomp,mseificompglob,mseifiglob,msestream,msestrings,
 sysutils,msegraphedits,msescrollbar;
type
 tfontformatdialogfo = class(tmseform)
   tlayouter1: tlayouter;
   tbutton2: tbutton;
   tbutton1: tbutton;
   tlayouter2: tlayouter;
   tstatfile1: tstatfile;
   tlayouter3: tlayouter;
   bolded: tbooleanedit;
   italiced: tbooleanedit;
   underlineed: tbooleanedit;
   strikeouted: tbooleanedit;
   blanked: tbooleanedit;
   tlayouter4: tlayouter;
   backgroundcolored: tcoloredit;
   fontcolored: tcoloredit;
 end;
 
function editfontformat(const avalue: formatinfoarty; 
                                    const start,count: int32): formatinfoarty;

implementation
uses
 msefontformatdialog_mfm;

function editfontformat(const avalue: formatinfoarty; 
                                    const start,count: int32): formatinfoarty;
var
 style1: charstylety;
begin
 result:= copy(avalue);
 with tfontformatdialogfo.create(nil) do begin
  style1:= getcharstyle(avalue,start);
  fontcolored.value:= charstyletocolor(style1.fontcolor);
  backgroundcolored.value:= charstyletocolor(style1.colorbackground);
  bolded.value:= fs_bold in style1.fontstyle;
  italiced.value:= fs_italic in style1.fontstyle;
  underlineed.value:= fs_underline in style1.fontstyle;
  strikeouted.value:= fs_strikeout in style1.fontstyle;
//  selecteded.value:= fs_selected in style1.fontstyle;
  blanked.value:= fs_blank in style1.fontstyle;
  if show(ml_application) = mr_ok then begin
   style1.fontcolor:= colortocharstyle(fontcolored.value);
   style1.colorbackground:= colortocharstyle(backgroundcolored.value);
   style1.fontstyle:= style1.fontstyle - [fs_bold,fs_italic,fs_underline,
                                            fs_strikeout{,fs_selected},fs_blank];
   if bolded.value then begin
    include(style1.fontstyle,fs_bold);
   end;
   if italiced.value then begin
    include(style1.fontstyle,fs_italic);
   end;
   if underlineed.value then begin
    include(style1.fontstyle,fs_underline);
   end;
   if strikeouted.value then begin
    include(style1.fontstyle,fs_strikeout);
   end;
   {
   if selecteded.value then begin
    include(style1.fontstyle,fs_selected);
   end;
   }
   if blanked.value then begin
    include(style1.fontstyle,fs_blank);
   end;
   setcharstyle1(result,start,count,style1);
  end;
 end;
end;

end.
