{ MSEgui Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefontdialog;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$WARN IMPLICIT_STRING_CAST OFF}

interface

uses
 SysUtils,Classes,msetypes,mclasses,mseglob,mseguiglob,mseguiintf,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,msedialog,
 msesplitter,msesimplewidgets,msecolordialog,msedataedits,mseedit,msestrings,
 msegraphedits,msestat,msestatfile,msescrollbar,msedropdownlist,msedispwidgets;

type
 FontEventTy = PROCEDURE (CONST FontBeingSet: tWidgetFont) OF Object;

////////////////////////////////////////////
 tfontdialogfo = CLASS (tdialogform)
////////////////////////////////////////////
   tlayouter2:        tlayouter;
   tlayouter1:        tlayouter;
   Apply:             tbutton;
   Ok:                tbutton;
   Cancel:            tbutton;
   tlayouter3:        tlayouter;
   UnderlineEd:       tbooleanedit;
   StrikeoutEd:       tbooleanedit;
   BlankEd:           tbooleanedit;
//   tlayouter4:        tlayouter;
   tlayouter5:        tlayouter;
   FontNameSelector:  tdropdownlistedit;
   FontStyleSelector: tdropdownlistedit;
   FontSizeSelector:  trealspinedit;
   Anzeigetext:       tstringedit;
   Colorstepper:      tstepbox;
   FontcolorEd:       tcoloredit;
   BackgroundColorEd: tcoloredit;
   SelectColorEd:     tcoloredit;
   SelectBgcolorEd:   tcoloredit;

   FUNCTION  getBg: colorty;
   PROCEDURE setBg     (CONST BgColor: colorty);
   FUNCTION  getFont: tWidgetFont;
   PROCEDURE setFont   (CONST FontBeingSet: tWidgetFont);
   PROCEDURE set_style (const sender: TObject; avalue: msestring);
   PROCEDURE applyFont (CONST sender: TObject);
   procedure FormClose (CONST Sender: TObject);
   procedure StepColor (const sender: TObject; const stepkind: stepkindty;
                        var handled: Boolean);

   PROCEDURE setSizeEd  (CONST avalue: Boolean);
   PROCEDURE setSelStep (CONST avalue: Boolean);
   FUNCTION  getSizeEd:  Boolean;
   FUNCTION  getSelStep: Boolean;

   procedure set_underline   (const sender: TObject; var avalue: Boolean;
                              var accept: Boolean);
   procedure set_strikeout   (const sender: TObject; var avalue: Boolean;
                              var accept: Boolean);
   procedure set_blanking    (const sender: TObject; var avalue: Boolean;
                              var accept: Boolean);

   procedure font_selected   (const sender: TObject; var avalue: msestring;
                              var accept: Boolean);
   procedure style_selected  (const sender: TObject; var avalue: msestring;
                              var accept: Boolean);
   procedure size_selected   (const sender: TObject; var avalue: realty;
                              var accept: Boolean);
   procedure set_fontcolor   (const sender: TObject; var avalue: colorty;
                              var accept: Boolean);
   procedure set_fontbackgnd (const sender: TObject; var avalue: colorty;
                              var accept: Boolean);
   procedure set_Background  (const sender: TObject; var avalue: colorty;
                              var accept: Boolean);
   procedure set_SelColor    (const sender: TObject; var avalue: colorty;
                              var accept: Boolean);
   procedure set_SelBackgnd  (const sender: TObject; var avalue: colorty;
                              var accept: Boolean);
   procedure AnzeigeClick    (const sender: twidget; var ainfo: mouseeventinfoty);

  PRIVATE
   FL:             TStringList;
   FontApplicator: FontEventTy;

  PUBLISHED
   PROPERTY Font:         tWidgetFont READ getFont        WRITE SetFont;
   PROPERTY BgColor:      colorty     READ getBg          WRITE SetBg;
   PROPERTY allowSizing:  boolean     READ getSizeEd      WRITE setSizeEd;
   PROPERTY SelectColors: boolean     READ getSelStep     WRITE setSelStep;
   PROPERTY FontSetter:   FontEventTy READ FontApplicator WRITE FontApplicator;
 end;


implementation

uses
 msefontdialog_mfm,
 fontlist;

(* stock fonts: (numbers used in tskincontroller)
     0    stf_default
     1    stf_empty
     2    stf_unicode
     3    stf_menu
     4    stf_message
     5    stf_hint
     6    stf_report
     7    stf_proportional
     8    stf_fixed
     9    stf_helvetica
    10    stf_roman
    11    stf_courier

   defined in graphics/msegraphics.pas:

   formatinfoty = record
    index: integer;            //0-> from first char
    newinfos: newinfosty;
    style: charstylety;
   end;
*)

procedure tfontdialogfo.set_underline (const sender: TObject; var avalue: Boolean;
                                       var accept: Boolean);
 begin
   WITH Anzeigetext.Font DO
     IF UnderlineEd.value
       THEN Style:= Style- [fs_underline]
       ELSE Style:= Style+ [fs_underline];
 end;

procedure tfontdialogfo.set_strikeout (const sender: TObject; var avalue: Boolean;
                                       var accept: Boolean);
 begin
   WITH Anzeigetext.Font DO
     IF StrikeoutEd.value
       THEN Style:= Style- [fs_strikeout]
       ELSE Style:= Style+ [fs_strikeout];
 end;

procedure tfontdialogfo.set_blanking (const sender: TObject; var avalue: Boolean;
                                      var accept: Boolean);
 begin
   WITH Anzeigetext.Font DO
     IF BlankEd.value
       THEN Style:= Style- [fs_blank]
       ELSE Style:= Style+ [fs_blank];
 end;

(*
 fontstylety = (fs_bold,fs_italic,
                fs_underline,fs_strikeout,fs_selected,fs_blank,
                fs_force);
*)
procedure tfontdialogfo.set_style (const sender: TObject; avalue: msestring);
 var
   i:      integer;
   Styles: TStringList;
 begin
   IF NOT assigned (FL) THEN Exit;

   Styles:= TStringList.Create;
   WITH Styles DO BEGIN
     Delimiter:= ';'; StrictDelimiter:= true;
     DelimitedText:= FL.Values [aValue];
   END;
   WITH FontStyleselector.DropDown, Cols [0] DO BEGIN
     clear;
     FOR i:= 0 TO pred (Styles.Count) DO add (Styles [i]);
     ItemIndex:= 0;
   END;
 end;

procedure tfontdialogfo.font_selected (const sender: TObject; var avalue: msestring;
                                       var accept: Boolean);
 begin
   Anzeigetext.Font.Name:= ANSIstring (aValue);
   IF FontNameSelector.Value <> aValue
     THEN set_style (sender, aValue);
   FontNameSelector.Value:= aValue;
 end;

procedure tfontdialogfo.style_selected (const sender: TObject; var avalue: msestring;
                                        var accept: Boolean);
 begin
   Anzeigetext.Font.Style:= FontStyle (aValue);
   FontStyleSelector.Value:= aValue;
 end;

procedure tfontdialogfo.size_selected (const sender: TObject; var avalue: realty;
                                       var accept: Boolean);
 begin
   Anzeigetext.Font.Height:= round (aValue);
   FontSizeSelector.Value:= aValue;
 end;

procedure tfontdialogfo.set_fontcolor (const sender: TObject; var avalue: colorty;
                                       var accept: Boolean);
 begin
   Anzeigetext.Font.Color:= aValue;
   WITH FontcolorEd DO BEGIN
     ValueDefault:= aValue; Value:= ValueDefault;
   END;
 end;

procedure tfontdialogfo.set_fontbackgnd (const sender: TObject; var avalue: colorty;
                                         var accept: Boolean);
 begin
   Anzeigetext.Font.ColorBackground:= aValue;
   WITH BackgroundColorEd DO BEGIN
     ValueDefault:= aValue; Value:= ValueDefault;
   END;
 end;

procedure tfontdialogfo.set_Background (const sender: TObject; var avalue: colorty;
                                        var accept: Boolean);
 begin
   Anzeigetext.Font.ColorBackground:= aValue;
   WITH BackgroundColorEd DO BEGIN
     ValueDefault:= aValue; Value:= ValueDefault;
   END;
 end;

procedure tfontdialogfo.set_SelColor (const sender: TObject; var avalue: colorty;
                                      var accept: Boolean);
 begin
   Anzeigetext.Font.ColorSelect:= aValue;
   WITH SelectColorEd DO BEGIN
     ValueDefault:= aValue; Value:= ValueDefault;
   END;
 end;

procedure tfontdialogfo.set_SelBackgnd (const sender: TObject; var avalue: colorty;
                                        var accept: Boolean);
 begin
   Anzeigetext.Font.ColorSelectBackground:= aValue;
   WITH SelectBgcolorEd DO BEGIN
     ValueDefault:= aValue; Value:= ValueDefault;
   END;
 end;

procedure tfontdialogfo.AnzeigeClick (const sender: twidget; var ainfo: mouseeventinfoty);
 begin
   IF (ek_ButtonPress = aInfo.EventKind) AND (ss_double IN aInfo.ShiftState)
   THEN BEGIN
     WITH Anzeigetext       DO Value:= ValueDefault;
     WITH FontcolorEd       DO Value:= ValueDefault;
     WITH BackgroundColorEd DO Value:= ValueDefault;
     WITH SelectColorEd     DO Value:= ValueDefault;
     WITH SelectBgcolorEd   DO Value:= ValueDefault;
     aInfo.EventKind:= ek_None;
   END;
 end;

FUNCTION tfontdialogfo.getBg: colorty;
 BEGIN
   Result:= Anzeigetext.Frame.ColorClient;
 end;

procedure tfontdialogfo.setBg (CONST BgColor: colorty);
 BEGIN
   Anzeigetext.Frame.ColorClient:= BgColor;
 end;

FUNCTION tfontdialogfo.getFont: tWidgetFont;
 BEGIN
   Result:= Anzeigetext.Font;
 end;

procedure tfontdialogfo.setFont (CONST FontBeingSet: tWidgetFont);
 VAR
   i: integer;
 BEGIN
   IF NOT assigned (FL) THEN BEGIN
     FL:= FontPropertiesList (MSEFallbackLang{, true});
     IF assigned (FL) THEN
       FOR i:= 0 TO pred (FL.Count) DO
         FontNameSelector.DropDown.Cols [0].add (FL.Names [i]);
   END;

   Anzeigetext.Font:= FontBeingSet;

   WITH FontBeingSet DO BEGIN
     set_style (NIL, Name);
     FontNameSelector.Value:= Name;
     FontSizeSelector.Value:= Height;

     FontcolorEd.Value:= Color;
     SelectColorEd.value:= ColorSelect;
     BackgroundColorEd.Value:= ColorBackground;
     SelectBgcolorEd.value:= ColorSelectBackground;

     IF fs_bold IN Style THEN BEGIN
       i:= pred (FontStyleselector.DropDown.Cols [0].Count);
       WHILE (i >= 0) AND (FontStyle (FontStyleselector.DropDown.Cols [0][i]) <> [fs_bold]) DO
         Dec (i);
       IF i >= 0 THEN FontStyleselector.DropDown.ItemIndex:= i;
     END;

     UnderlineEd.value:= fs_underline IN Style;
     StrikeoutEd.value:= fs_strikeout IN Style;
     BlankEd.value:=     fs_blank     IN Style;
   END;
 END;

procedure tfontdialogfo.FormClose (CONST Sender: TObject);
 begin
   FreeAndNil (FL);
 end;

procedure tfontdialogfo.applyFont (CONST sender: TObject);
 begin
   IF assigned (FontSetter) THEN FontSetter (Anzeigetext.Font);
 end;

procedure tfontdialogfo.StepColor (const sender: TObject; const stepkind: stepkindty;
                                   var handled: Boolean);
 begin
   CASE stepkind OF
     sk_down:
       BEGIN
         FontcolorEd.hide; BackgroundColorEd.hide;
         SelectColorEd.bounds_y:= FontcolorEd.bounds_y;
         SelectBgcolorEd.bounds_y:= BackgroundColorEd.bounds_y;
         SelectColorEd.show; SelectBgcolorEd.show;
         handled:= true;
       END;
     sk_up:
       BEGIN
         SelectColorEd.hide; SelectBgcolorEd.hide;
         FontcolorEd.show; BackgroundColorEd.show;
         handled:= true;
       END
     ELSE { nothing to do - ignore };
   END (* CASE stepkind *);
 end;

PROCEDURE tfontdialogfo.setSizeEd (CONST avalue: Boolean);
 begin
   FontSizeSelector.enabled:= avalue;
 end;

PROCEDURE tfontdialogfo.setSelStep (CONST avalue: Boolean);
 begin
   WITH ColorStepper.Frame DO
     IF avalue
       THEN buttonsvisible:= buttonsvisible+ [sk_up, sk_down]
       ELSE buttonsvisible:= buttonsvisible- [sk_up, sk_down];
 end;

FUNCTION tfontdialogfo.getSizeEd: Boolean;
 begin
   getSizeEd:= FontSizeSelector.enabled;
 end;

FUNCTION tfontdialogfo.getSelStep: Boolean;
 begin
   getSelStep:= (ColorStepper.Frame.buttonsvisible* [sk_up, sk_down]) <> [];
 end;

end.
