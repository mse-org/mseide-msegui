{ MSEide Copyright (c) 1999-2006 by Martin Schreiber

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit msesearchreplace;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
 mclasses,mseconsts,msestockobjects,mseguiglob,msegui,mseclasses,mseforms,
 msegraphedits,msedataedits,msesimplewidgets,msestat,msestatfile,mseglob,
 msestrings,msegraphics, msegraphutils, msemenus, msewidgets,msedialog,
 msesplitter,mseificomp,mseificompglob,mseifiglob,msescrollbar,msetypes;

type
  findinfoty = record
    Text:         msestring;
    options:      searchoptionsty;
    selectedonly: boolean;
    history:      msestringarty;
  end;

  replaceinfoty = record
    find:        findinfoty;
    replacetext: msestring;
    prompt:      boolean;
  end;

  treplacedialogfo = class (tdialogform)  // tmseform)
    layouter1:       tlayouter;
    layouter2:       tlayouter;
    FindFirst:       TButton;
    Replace:         TButton;
    butok:           tbutton;
    layouter3:       tlayouter;
    findtext:        thistoryedit;
    replacetext:     thistoryedit;
    layouter4:       tlayouter;
    casesensitive:   tbooleanedit;
    wholeword:       tbooleanedit;
    selectedonly:    tbooleanedit;
    layouter5:       tlayouter;
    promptonreplace: tbooleanedit;
    doall:           tbooleanedit;
    backwards:       tbooleanedit;

    procedure oncreat (const sender: TObject);
    procedure onok    (const sender: TObject);
    procedure setreplace;
    procedure setsearch;

////////////////////////////////////////////
    PROCEDURE readValues  (CONST Sender: TObject; CONST Reader: tstatreader);
    PROCEDURE writeValues (CONST Sender: TObject; CONST Writer: tstatwriter);
////////////////////////////////////////////
    CONSTRUCTOR Create (CONST Sender: TComponent; replacer: boolean = true;
                        where: dialogposty = dp_none); OVERLOAD; //REINTRODUCE;
    CONSTRUCTOR Create (CONST Sender: TComponent; CONST StatName: msestring;
                        replacer: boolean = true; where: dialogposty = dp_none); OVERLOAD; //REINTRODUCE;
////////////////////////////////////////////

  Private
    issearcher: boolean;  // will be initialized to "false"

    procedure valuestoinfo (out info: replaceinfoty);
    procedure infotovalues (const info: replaceinfoty);
    procedure setlangfindreplace;
    procedure setFindReplace;
  end;
{
procedure replacedialogdotextsize;
function replacedialogexecute(var info: replaceinfoty): modalresultty;
}

implementation

uses
  msesearchreplace_mfm;
{
var
  fo: treplacedialogfo;

procedure replacedialogdotextsize;
begin
//  fo.font.Height := confideufo.fontsize.Value;
//  fo.font.Name   := ansistring(confideufo.fontname.Value);

  fo.findtext.top := 34;
  fo.replacetext.top := fo.findtext.top + fo.findtext.Height + 2;
  fo.casesensitive.top := fo.replacetext.top + fo.replacetext.Height + 2;
  fo.wholeword.top := fo.casesensitive.top + fo.casesensitive.Height + 2;
  fo.selectedonly.top := fo.wholeword.top + fo.wholeword.Height + 2;
  fo.promptonreplace.top := fo.selectedonly.top + fo.selectedonly.Height + 2;
  fo.Height := fo.promptonreplace.top + fo.promptonreplace.Height + 10;
end;

function replacedialogexecute(var info: replaceinfoty): modalresultty;
begin
  fo := treplacedialogfo.Create(nil);
  try
    replacedialogdotextsize;
    fo.infotovalues(info);
    Result := fo.Show(True, nil);
    if Result in [mr_ok, mr_all] then
      fo.valuestoinfo(info);
  finally
    fo.Free;
  end;
end;
}
{ treplacedialogfo }

procedure treplacedialogfo.valuestoinfo(out info: replaceinfoty);
begin
{$warnings off}
  with info.find do
  begin
    Text         := findtext.Value;
    history      := findtext.dropdown.valuelist.asarray;
    options      := encodesearchoptions(not casesensitive.Value, wholeword.Value);
    selectedonly := self.selectedonly.Value;
  end;
  info.prompt := promptonreplace.Value;
  info.replacetext := replacetext.Value;
end;

{$warnings on}

procedure treplacedialogfo.setlangfindreplace();
begin
{
  Caption := lang_xstockcaption[ord(sc_find_replace)];
  tintegerbutton1.Caption := lang_xstockcaption[ord(sc_replace)];
  tintegerbutton2.Caption := lang_xstockcaption[ord(sc_replaceall)];
  butok.Caption := lang_stockcaption[ord(sc_close)];
  findtext.frame.Caption        := lang_xstockcaption[ord(sc_texttofind)];
  replacetext.frame.Caption     := lang_xstockcaption[ord(sc_replacewith)];
  promptonreplace.frame.Caption := lang_xstockcaption[ord(sc_promptonreplace)];

  casesensitive.frame.Caption := lang_xstockcaption[ord(sc_casesensitive)];
  selectedonly.frame.Caption  := lang_xstockcaption[ord(sc_selectedonly)];
  wholeword.frame.Caption     := lang_xstockcaption[ord(sc_wholeword)];
}
end;

procedure treplacedialogfo.infotovalues(const info: replaceinfoty);
begin
  with info.find do
  begin
    findtext.Value      := Text;
    findtext.dropdown.valuelist.asarray := history;
    casesensitive.Value := not (so_caseinsensitive in options);
    wholeword.Value     := so_wholeword in options;
    //  self.selectedonly.value:= selectedonly;
  end;
end;

procedure treplacedialogfo.oncreat(const sender: TObject);
 begin
   setlangfindreplace ();
 end;

procedure treplacedialogfo.onok(const sender: TObject);
 begin
   close;
 end;

procedure treplacedialogfo.setreplace;
 var
   delta3, delta45: integer;
 begin
   delta45:= doall.bounds_y- backwards.bounds_y;
   delta3:= replacetext.bounds_y- findtext.bounds_y;
   if issearcher then begin  // if not already a replacer, must change height
     bounds_cy:= bounds_cy+ delta3+ delta45;
     bounds_cymin:= bounds_cy+ delta3+ delta45;
     with layouter1 do bounds_cy:= bounds_cy+ delta3+ delta45;
     with layouter3 do bounds_cy:= bounds_cy+ delta3;
     with layouter4 do bounds_cy:= bounds_cy+ delta45;
     with layouter5 do bounds_cy:= bounds_cy+ delta45;
   end;
   replace.show; replacetext.show;
   promptonreplace.show; doall.show;
 end;

procedure treplacedialogfo.setsearch;
 var
   delta3, delta45: integer;
 begin
   delta45:= doall.bounds_y- backwards.bounds_y;
   delta3:= replacetext.bounds_y- findtext.bounds_y;
   promptonreplace.hide; doall.hide;
   replace.hide; replacetext.hide;
   if not issearcher then begin  // if not already a searcher, must change height
     with layouter5 do bounds_cy:= bounds_cy- delta45;
     with layouter4 do bounds_cy:= bounds_cy- delta45;
     with layouter3 do bounds_cy:= bounds_cy- delta3;
     with layouter1 do bounds_cy:= bounds_cy- (delta3+ delta45);
     bounds_cymin:= bounds_cymin- (delta3+ delta45);
     bounds_cy:= bounds_cy- (delta3+ delta45);
     bounds_y:=  bounds_y+  ((delta3+ delta45) DIV 2);
   end;
 end;

////////////////////////////////////////////

PROCEDURE treplacedialogfo.readValues (CONST Sender: TObject; CONST Reader: tstatreader);
 BEGIN
   WITH Reader DO BEGIN
     FindText.Value:=      ReadString  ('FindText', FindText.Value);
     FindText.dropDown.ValueList.asArray:=
                           ReadArray   ('History', FindText.dropDown.ValueList.asArray);

     casesensitive.Value:= ReadBoolean ('useCase',   casesensitive.Value);
     wholeword.Value:=     ReadBoolean ('wholeWord', wholeword.Value);
     selectedonly.Value:=  ReadBoolean ('inSelect',  selectedonly.Value);
     backwards.Value:=     ReadBoolean ('backwards', backwards.Value);

     IF NOT issearcher THEN BEGIN   // Only for replace dialog
       ReplaceText.Value:=     ReadString  ('ReplaceText', ReplaceText.Value);
       ReplaceText.dropDown.ValueList.asArray:=
                               ReadArray   ('ReplaceHist',  ReplaceText.dropDown.ValueList.asArray);
       doall.Value:=           ReadBoolean ('replaceAll', doall.Value);
       promptonreplace.Value:= ReadBoolean ('askReplace', promptonreplace.Value);
     END;
   END;
 END;

PROCEDURE treplacedialogfo.writeValues (CONST Sender: TObject; CONST Writer: tstatwriter);
 BEGIN
   WITH Writer DO BEGIN
     WriteString  ('FindText',  FindText.Value);
     WriteArray   ('FindHist',  FindText.dropDown.ValueList.asArray);

     WriteBoolean ('useCase',   casesensitive.Value);
     WriteBoolean ('wholeWord', wholeword.Value);
     WriteBoolean ('inSelect',  selectedOnly.Value);
     WriteBoolean ('backwards', backwards.Value);

     IF NOT issearcher THEN BEGIN   // Only for replace dialog
       WriteString  ('ReplaceText', ReplaceText.Value);
       WriteArray   ('ReplaceHist', ReplaceText.dropDown.ValueList.asArray);
       WriteBoolean ('replaceAll',  doall.Value);
       WriteBoolean ('askReplace',  promptOnReplace.Value);
     END;
   END;
 END;
////////////////////////////////////////////
PROCEDURE treplacedialogfo.setFindReplace;
 BEGIN
   IF issearcher THEN BEGIN
     issearcher:= false;
     setsearch; Caption:= 'Find Text';
     issearcher:= true;
   END
   ELSE BEGIN
     setreplace; Caption:= 'Find and Replace Text';
   END;
 END;

CONSTRUCTOR treplacedialogfo.Create (CONST Sender: TComponent; replacer: boolean; where: dialogposty);
 BEGIN
   Options:= Options+ [fo_freeonclose]; issearcher:= NOT replacer;
   INHERITED Create (Sender);
   setFindReplace; show; setPosition (where);  // neccessity of "show;" here is VERY unclear!
 END;

CONSTRUCTOR treplacedialogfo.Create (CONST Sender: TComponent; CONST StatName: msestring;
                                     replacer: boolean; where: dialogposty);
 BEGIN
   Options:= Options+ [fo_freeonclose]; issearcher:= NOT replacer;
   onstatread:= @readValues; onstatwrite:= @writeValues;
   INHERITED Create (Sender, StatName);
   setFindReplace; show; setPosition (where);  // neccessity of "show;" here is VERY unclear!
 END;
////////////////////////////////////////////
end.
