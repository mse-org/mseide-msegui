
unit form_potools;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,mseact,
 mclasses,msedataedits,msedropdownlist,mseedit,mseificomp,mseificompglob,
 msestockobjects_dynpo,mseifiglob,msememodialog,msestatfile,msestream,SysUtils,
 msesimplewidgets,mseconsts_dynpo,msefileutils,msebitmap,msedatanodes,msedragglob,
 msegrids,msegridsglob,LazUTF8,mselistbrowser,msesys,msegraphedits,msescrollbar,
 msetimer,msedispwidgets,mserichstring,msestringcontainer,msefiledialogx;

type
  theaderfo = class(tmseform)
    memopoheader: tmemodialogedit;
    tbutton2: TButton;
    alldir: tbooleanedit;
    ttimer1: ttimer;
    paneldone: tgroupbox;
    labdone: tlabel;
    sc: tstringcontainer;
    tbutton4: TButton;
    outputdir: tfilenameeditx;
    impexpfiledialog: tfiledialogx;
    tstatfile1: tstatfile;
   tlabel1: tlabel;
   tbutton3: tbutton;
    procedure createnew(Const Sender: TObject);
    procedure createnewconst(Const Sender: TObject; fn: msestring);
    procedure createnewpo(Const Sender: TObject; fn: msestring);
    procedure oncreateform(Const Sender: TObject);
    procedure ontime(Const Sender: TObject);
   procedure oncreated(const sender: TObject);
  end;

var
  headerfo: theaderfo;
  forgoogle: boolean;
  astro, astrt, acomp: utf8String;
  defaultresult, constvaluearray :array of msestring;

implementation

uses
form_potools_mfm;

procedure theaderfo.createnewpo(Const Sender: TObject; fn: msestring);
var
  x, y: integer;
  file1: ttextdatastream;
  imodalresultty: modalresultty;
  imainformty: mainformty;
  iextendedty: extendedty;
  istockcaptionty: stockcaptionty;
begin

  setlength(defaultresult, length(en_modalresulttext));
  for imodalresultty := Low(modalresultty) to High(modalresultty) do
    defaultresult[Ord(imodalresultty)] := en_modalresulttext[(imodalresultty)];

  y := length(defaultresult);
  setlength(defaultresult, length(en_modalresulttextnoshortcut) + y);
   for imodalresultty := Low(modalresultty) to High(modalresultty) do
    defaultresult[y + Ord(imodalresultty)] := en_modalresulttextnoshortcut[(imodalresultty)];

  y := length(defaultresult);
  setlength(defaultresult, length(en_stockcaption) + y);
  for istockcaptionty := Low(stockcaptionty) to High(stockcaptionty) do
    defaultresult[y + Ord(istockcaptionty)] := en_stockcaption[(istockcaptionty)];

  y := length(defaultresult);
  setlength(defaultresult, length(en_extendedtext) + y);
  for iextendedty := Low(extendedty) to High(extendedty) do
    defaultresult[y + Ord(iextendedty)] := en_extendedtext[(iextendedty)];

  y := length(defaultresult);
   setlength(defaultresult, length(en_mainformtext) + y);
   for imainformty := Low(mainformty) to High(mainformty) do
    defaultresult[y + Ord(imainformty)] := en_mainformtext[(imainformty)];

   // Languages must be the last in po
   y := length(defaultresult);
   setlength(defaultresult, length(en_langnamestext) + y);
   for x := 0 to length(en_langnamestext) - 1 do
    defaultresult[x+y] := en_langnamestext[x];

 // check if double "msgid"
 {
  str1 := '';
  int1:= 0;
  for x := 0 to length(defaultresult) - 1 do
  begin
    if int1 > 1 then writeln('Similar msgid = ' + destr1 + ' = ' + inttostr(int1)) ;
    int1:= 0;
    str1 := defaultresult[x];
    if trim(str1) <> '' then
    for y := 0 to length(defaultresult) - y do
    begin
      if defaultresult[y] = str1 then inc(int1);
     end;
  end;
 }

    if forgoogle = false then
  file1 := ttextdatastream.Create(outputdir.Value +
           'podemo_empty.po', fm_create)
  else
   file1 := ttextdatastream.Create(outputdir.Value +
           'podemo_empty.txt', fm_create);

  file1.encoding := ce_utf8;

    if forgoogle = false then
  file1.writeln(memopoheader.Value)
  else
  begin
  file1.writeln();
  end;

  file1.writeln();

  for x := 0 to length(defaultresult) - 1 do
    if trim(defaultresult[x]) <> '' then
      begin
        if forgoogle = false then
        begin
        file1.writeln('msgid "' + defaultresult[x] + '"');
        file1.writeln('msgstr ""');
        end else
        begin
        file1.writeln('msgstr "' + defaultresult[x] + '"');
        end;
        file1.writeln('');
      end;
  file1.Free;
end;

procedure theaderfo.createnew(Const Sender: TObject);
var
  filterlista, filterlistb: msestringarty;
  str1: msestring;
begin

   if TButton(Sender).tag = 0 then
    begin
      setlength(filterlista, 1);
      setlength(filterlistb, 1);
      filterlista[0] := 'podemo_xz.txt to joint';
      filterlistb[0] := '*.txt';
      impexpfiledialog.controller.filter := '*.txt';
      impexpfiledialog.controller.options := [fdo_savelastdir];

      with impexpfiledialog.controller.filterlist do
        begin
          asarraya := filterlista;
          asarrayb := filterlistb;
        end;

      impexpfiledialog.controller.filterindex := 0;
      application.ProcessMessages;

      if impexpfiledialog.Execute(fdk_open) = mr_ok then
        begin
          paneldone.frame.colorclient := $FFD1A1;
          labdone.Caption   := sc[0];
          paneldone.Visible := True;
          application.ProcessMessages;
          str1 := impexpfiledialog.controller.filename;
          createnewconst(Sender, str1);
          paneldone.frame.colorclient := cl_ltgreen;
          labdone.Caption   := sc[1];
          paneldone.Visible := True;
          ttimer1.Enabled   := True;
          end;
        end;

 if (TButton(Sender).tag = 1) or (TButton(Sender).tag = 2) then
       begin
      if (TButton(Sender).tag = 1) then forgoogle := false else forgoogle := true;
      createnewpo(Sender, '');
      paneldone.frame.colorclient := cl_ltgreen;
      labdone.Caption   := sc[1];
      paneldone.Visible := True;
      ttimer1.Enabled   := True;
    end;

end;

procedure theaderfo.createnewconst(Const Sender: TObject; fn: msestring);
var
  x: integer;
  file1: ttextdatastream;
  str1,  strlang, filename1: msestring;
  str2 : utf8String;

begin
  str1    := fn;
  strlang := '';

  if fileexists(str1) then
    begin

      file1 := ttextdatastream.Create(str1, fm_read);

      filename1 := copy(filename(str1), 1, length(filename(str1)) - 4);
      strlang   := trim(copy(filename1, system.pos('_', filename1) + 1, length(filename1)));

      strlang := utf8StringReplace(strlang, '@', '_', [rfReplaceAll]);

      file1.encoding := ce_utf8;

      setlength(constvaluearray, 0);

    //  file1.readln(str1);

      while not file1.EOF do
        begin
          str1    := '';
          file1.readln(str1);
          str2    := '';
          if (trim(str1) <> '') and (UTF8Copy(str1, 1, 1) <> '#') then
            if (UTF8Copy(str1, 1, 6) = 'msgstr') then
              begin
                str2        := UTF8Copy(str1, 7, length(str1));
                str2        := utf8StringReplace(str2, '\n', '', [rfReplaceAll]);
                str2        := utf8StringReplace(str2, '\', '', [rfReplaceAll]);
                str2        := utf8StringReplace(str2, '"', '', [rfReplaceAll]);
                if str2 <> '' then
                  begin
                    setlength(constvaluearray, length(constvaluearray) + 1);
                    constvaluearray[length(constvaluearray) - 1] := trim(str2);
                  end;
              end;
        end;

      file1.Free;

      str1 := ExtractFilePath(ParamStr(0)) + directoryseparator + 'lang' + directoryseparator +
              'podemo_empty.po';

      if fileexists(str1) then
        begin

          file1          := ttextdatastream.Create(str1, fm_read);
          file1.encoding := ce_utf8;

          setlength(defaultresult, 0);

          file1.readln(str1);

          while not file1.EOF do
            begin
              str1    := '';
              file1.readln(str1);
              str2    := '';
              if (trim(str1) <> '') and (UTF8Copy(str1, 1, 1) <> '#') then
                if (UTF8Copy(str1, 1, 5) = 'msgid') then
                  begin
                    str2        := UTF8Copy(str1, 7, length(str1));
                    str2        := utf8StringReplace(str2, '\n', '', [rfReplaceAll]);
                    str2        := utf8StringReplace(str2, '\', '', [rfReplaceAll]);
                    str2        := utf8StringReplace(str2, '"', '', [rfReplaceAll]);
                    if trim(str2) <> '' then
                      begin
                        setlength(defaultresult, length(defaultresult) + 1);
                        defaultresult[length(defaultresult) - 1] := trim(str2);
                      end;
                  end;
            end;

          file1.Free;
        end;

      file1          := ttextdatastream.Create(outputdir.Value + 'podemo_' + strlang + '.po',
                        fm_create);
      file1.encoding := ce_utf8;

      file1.writeln(memopoheader.Value);
      file1.writeln();

      // writeln('length(defaultresult) ' + inttostr(length(defaultresult)));
      // writeln('length(constvaluearray) ' + inttostr(length(constvaluearray)));
      str2 := '';

      for x := 0 to length(defaultresult) - 1 do
        begin
          file1.writeln('msgid "' + defaultresult[x] + '"');

          if x < length(constvaluearray) then
            begin
              if trim(constvaluearray[x]) <> '' then
                file1.writeln('msgstr "' + constvaluearray[x] + '"')
              else
                file1.writeln('msgstr "' + defaultresult[x] + '"');
            end
          else
            file1.writeln('msgstr "' + defaultresult[x] + '"');

          file1.writeln('');
        end;

      file1.Free;

    end;
end;

procedure theaderfo.oncreateform(Const Sender: TObject);
begin
  outputdir.Value := ExtractFilePath(ParamStr(0)) + 'output' + directoryseparator;
end;

procedure theaderfo.ontime(Const Sender: TObject);
begin
  paneldone.Visible := False;
end;

procedure theaderfo.oncreated(const sender: TObject);
begin
 // createnewlang('');
end;

end.
