unit form_conflang;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
  msetypes,
  mseglob,
  mseguiglob,
  mseguiintf,
  mseapplication,
  msestat,
  msemenus,
  msegui,
  msegraphics,
  msegraphutils,
  mseevent,
  mseclasses,
  msewidgets,
  mseforms,
  msesimplewidgets,
  msegraphedits,
  mseificomp,
  mseificompglob,
  mseifiglob,
  msescrollbar,
  msestatfile,
  mseact,
  msedataedits,
  msedragglob,
  msedropdownlist,
  mseedit,
  msegrids,
  msegridsglob,
  msestream,
  msewidgetgrid,
  SysUtils,
  msedispwidgets,
  mserichstring;

type
  tconflangfo = class(tmseform)
    ok: TButton;
    gridlang: twidgetgrid;
    gridlangtext: tstringedit;
    gridlangbool: tbooleaneditradio;
    gridlangcode: tstringedit;
    bpotools: TButton;
    tlabel1: tlabel;
    tlabel2: tlabel;
    tlabel3: tlabel;
    tstatfile1: tstatfile;
    procedure oncok(const Sender: TObject);
    procedure oncreat(const Sender: TObject);
    procedure oncellev(const Sender: TObject; var info: celleventinfoty);
    procedure ontools(const Sender: TObject);
    procedure setlangdemo(thelang: string);
  end;

  // Your enums
type
  myformty = (
    my_test1,                 //0 This is a test of internationalization
    my_test2,                 //1 That is a other test
    my_test3                  //2 This is the end.
    );

  // your custom array
  myformaty = array[myformty] of msestring;

  // Your consts
const
  en_myformtext: myformaty = (
    'This is a test of internationalization.',
    'That is a other test.',
    'This is the end.'
    );

var
  lang_myform: array of msestring;
  conflangloaded: shortint = 0;
  conflangfo: tconflangfo;

implementation

uses
{$ifdef mse_dynpo}
  po2arrays,
{$endif}
  msestockobjects,
  form_potools,
  form_conflang_mfm;

procedure tconflangfo.setlangdemo(thelang: string);
var
  x: shortint;
  str: string;
begin
{$ifdef mse_dynpo}
  createnewlang(thelang);

  conflangfo.gridlang.rowcount := length(lang_langnames);

  for x := 0 to length(lang_langnames) - 1 do
  begin
    conflangfo.gridlangtext[x] := lang_langnames[x];
    str := trim(copy(lang_langnames[x], system.pos('[', lang_langnames[x]), 10));
    str := StringReplace(str, '[', '', [rfReplaceAll]);
    str := StringReplace(str, ']', '', [rfReplaceAll]);
    conflangfo.gridlangcode[x] := str;
  end;

  conflangfo.ok.Caption := lang_modalresult[Ord(mr_ok)];  // captions from msegui widgets.

  conflangfo.bpotools.Caption := 'Po ' + lang_stockcaption[Ord(sc_tools)]; // captions from msegui widgets.

  conflangfo.Caption := lang_stockcaption[Ord(sc_lang)]; // captions from msegui widgets.

  conflangfo.tlabel1.Caption := lang_myform[Ord(my_test1)]; // captions from this application.

  conflangfo.tlabel2.Caption := lang_myform[Ord(my_test2)];  // captions from this application.


  conflangfo.tlabel3.Caption := lang_myform[Ord(my_test3)]; // captions from this application.

{$endif}
  application.ProcessMessages;
end;


procedure tconflangfo.oncok(const Sender: TObject);
begin
  Close;
end;

procedure tconflangfo.oncreat(const Sender: TObject);
begin
{$ifdef mse_dynpo}
  setlangdemo(MSEFallbackLang);
{$endif}
end;

procedure tconflangfo.oncellev(const Sender: TObject; var info: celleventinfoty);
var
  x: integer;
begin
{$ifdef mse_dynpo}
   if info.eventkind = cek_buttonrelease then
  begin
    MSEFallbackLang := '';
    for x           := 0 to gridlang.rowcount - 1 do
      if x = info.cell.row then
      begin
        gridlangbool[x] := True;
        MSEFallbackLang := gridlangcode[x];
        setlangdemo(MSEFallbackLang);
      end
      else
        gridlangbool[x] := False;
  end;
{$endif}
end;

procedure tconflangfo.ontools(const Sender: TObject);
begin
{$ifdef mse_dynpo}
 headerfo.Visible := True;
{$endif}
end;

end.

