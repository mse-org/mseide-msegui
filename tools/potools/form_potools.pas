
unit form_potools;

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
  mseact,
  mclasses,
  msedataedits,
  msedropdownlist,
  mseedit,
  mseificomp,
  mseificompglob,
  msestockobjects,
  mseifiglob,
  msememodialog,
  msestatfile,
  msestream,
  SysUtils,
  msesimplewidgets,
  mseconsts,
  msefileutils,
  msebitmap,
  msedatanodes,
  msedragglob,
  msegrids,
  msegridsglob,
  LazUTF8,
  mselistbrowser,
  msesys,
  msegraphedits,
  msescrollbar,
  msetimer,
  msedispwidgets,
  mserichstring,
  msestringcontainer,
  msefiledialogx;

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
    tlabel1: tlabel;
    tbutton3: TButton;
    tbutton5: TButton;
    tmemoedit1: tmemoedit;
    tbutton1: TButton;
    procedure createnew(const Sender: TObject);
    procedure createnewconst(const Sender: TObject; fn: msestring);
    procedure extractcaption(const Sender: TObject; fn: msestring);
    procedure createnewpo(const Sender: TObject; fn: msestring);
    procedure oncreateform(const Sender: TObject);
    procedure ontime(const Sender: TObject);
    procedure oncreated(const Sender: TObject);
    procedure onclose(const Sender: TObject);
    procedure onactiv(const Sender: TObject);
  end;

var
  headerfo: theaderfo;
  forgoogle: Boolean;
  astro, astrt, acomp: utf8String;
  defaultresult, constvaluearray: array of msestring;

implementation

uses
  form_conflang,
  form_potools_mfm;

procedure theaderfo.extractcaption(const Sender: TObject; fn: msestring);
var
  file1: ttextdatastream;
  str1: msestring;
  strobject, strcaption, strcaptionmenu, strmenu, strmenusub2, strmenusub3, strmenusub1: mseString;
  isfirst: Boolean = True;
  ismenu: Boolean = False;
  issubmenubegin: Boolean = False;
  issubmenuend: Boolean = False;
begin
  str1 := fn;

  if fileexists(str1) then
  begin

    file1          := ttextdatastream.Create(str1, fm_read);
    file1.encoding := ce_utf8;
    tmemoedit1.Visible := True;
    tbutton1.Visible := True;

    file1.readln(str1);
    str1      := trim(StringReplace(str1, 'object', '', [rfReplaceAll]));
    str1      := trim(copy(str1, 1, system.pos(':', str1) - 1));
    strobject := trim(str1);


    tmemoedit1.Value := 'with ' + trim(str1) + ' do' + lineend + '  begin';
    isfirst          := True;

    strmenusub2 := '';
    strmenusub3 := '';
    strmenusub1 := '';

    while not file1.EOF do
    begin
      str1 := '';
      file1.readln(str1);
      if (system.pos('object', str1) > 0) then
      begin
        if (system.pos('tmainmenu', str1) > 0) then
          ismenu         := True
        else
        begin
          ismenu         := False;
          issubmenubegin := False;
          issubmenuend   := False;
        end;
        if trim(strcaption) <> '' then
        begin
          // strcaption := StringReplace(strcaption, 'strmenusub1', 'parent_item', [rfReplaceAll]);
          //  strcaption := StringReplace(strcaption, 'strmenusub2', strmenusub2, [rfReplaceAll]);
          //  strcaption := StringReplace(strcaption, 'strmenusub3', strmenusub3, [rfReplaceAll]);

          strmenusub1 := '';
          strmenusub2 := '';
          strmenusub3 := '';

          tmemoedit1.Value := tmemoedit1.Value + strcaption + lineend;
        end;
        isfirst    := False;
        strobject  := trim(str1);
        strobject  := StringReplace(strobject, 'object', '', [rfReplaceAll]);
        strobject  := trim(copy(strobject, 1, system.pos(':', strobject) - 1));
        strcaption := '';
      end;

      if (ismenu = True) and ('submenu.items = <' = trim(str1)) then
        issubmenubegin := True;

      if ismenu = True then
        if (system.pos('name =', str1) > 0) then
        begin
          strmenu        := trim(copy(str1, system.pos('name =', str1) + 7, length(str1)));
          strcaptionmenu := StringReplace(strcaptionmenu, 'menuxyz', strmenu, [rfReplaceAll]);
          //  if issubmenubegin then strcaptionmenu := StringReplace(strcaptionmenu, 'parentmenu', strmenusub, [rfReplaceAll]);
          strcaption     := strcaption + lineend + strcaptionmenu;
          strcaptionmenu := '';
          if issubmenubegin = False then
            strmenusub1 := strmenu;
        end;

      if (ismenu = True) and ('end>' = trim(str1)) then
      begin
      {
        if strmenusub1 = '' then
        strmenusub1   := strmenu else
        if strmenusub2 = '' then
        strmenusub2   := strmenu else
        if strmenusub3 = '' then
        strmenusub3   := strmenu;
      }
        issubmenubegin := False;
        issubmenuend   := True;
      end;


      if (system.pos('optionsdock = [', str1) = 0) and
        (system.pos('object', str1) = 0) and
        (system.pos('captionpos', str1) = 0) and
        (system.pos('captiondist', str1) = 0) and
        (system.pos('state = [', str1) = 0) and (system.pos('options = [', str1) = 0) and
        ((system.pos('caption', str1) > 0) or (system.pos('hint', str1) > 0)) then
      begin
        str1 := trim(StringReplace(str1, '=', ':=', [rfReplaceAll]));

        if isfirst = False then
        begin
          if ismenu = False then
            strcaption := strcaption + lineend + '      ' + strobject + '.' + trim(str1) + ';'
          else
          begin
            if issubmenubegin = False then
            begin
              strcaptionmenu := strcaptionmenu + lineend + '      ' +
                strobject + '.menu.itembynames([menuxyz]).' + trim(str1) + ';';
              strmenusub1    := '';
              strmenusub2    := '';
              strmenusub3    := '';
            end
            else
              strcaptionmenu := strcaptionmenu + lineend + '      ' +
                strobject + '.menu.itembynames([''parentitem'',menuxyz]).' + trim(str1) + ';';

               { if strmenusub1 = '' then
             else if (strmenusub1 <> '') and (strmenusub2 = '') and (strmenusub3 = '')then
               strcaptionmenu := strcaptionmenu + lineend + '      ' +
                strobject + '.menu.itembynames([strmenusub2,strmenusub1,menuxyz]).' + trim(str1) + ';';

                 strcaptionmenu := strcaptionmenu + lineend + '      ' +
               //   strobject + '.menu.itembynames([strmenusub,menuxyz]).' + trim(str1) + ';'
               }
          end;

        end
        else
          strcaption := strcaption + lineend + '      ' + trim(str1) + ';';
      end;
    end;
    tmemoedit1.Value := tmemoedit1.Value + lineend + '  end;';
    file1.Free;
  end;
end;

///////////////////////

procedure theaderfo.createnewpo(const Sender: TObject; fn: msestring);
var
  x, y, int1: integer;
  str1, str2: msestring;
  file1: ttextdatastream;
  imodalresultty: modalresultty;
  iextendedty: extendedty;
  istockcaptionty: stockcaptionty;
  imyformty: myformty;
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
  setlength(defaultresult, length(en_myformtext) + y);
  for imyformty := Low(myformty) to High(myformty) do
    defaultresult[y + Ord(imyformty)] := en_myformtext[(imyformty)];

  // Languages must be the last in po
  y     := length(defaultresult);
  setlength(defaultresult, length(en_langnamestext) + y);
  for x := 0 to length(en_langnamestext) - 1 do
    defaultresult[x + y] := en_langnamestext[x];

  // check if double "msgid"
  str1 := '';
  str2 := '';
  int1 := 0;
  for x := 0 to length(defaultresult) - 1 do
  begin
    if int1 > 1 then
      str2 := str2 +
        'Similar msgid = ' + str1 + ' = ' + IntToStr(int1) + lineend;
    int1   := 0;
    str1   := defaultresult[x];
    if trim(str1) <> '' then
      for y := 0 to length(defaultresult) - y do
        if defaultresult[y] = str1 then
          Inc(int1);
  end;

  if trim(str2) = '' then
    ShowMessage('   Good: No double similar "msgid" found!   ',
      'Result of double "msegid"')
  else
    ShowMessage('Those double similar "msgid" were found:' + lineend + str2,
      'Result of check for double "msegid"');

  if forgoogle = False then
    file1 := ttextdatastream.Create(outputdir.Value +
      'podemo_empty.po', fm_create)
  else
    file1 := ttextdatastream.Create(outputdir.Value +
      'podemo_empty.txt', fm_create);

  file1.encoding := ce_utf8;

  if forgoogle = False then
    file1.writeln(memopoheader.Value)
  else
    file1.writeln();

  file1.writeln();

  for x := 0 to length(defaultresult) - 1 do
    if trim(defaultresult[x]) <> '' then
    begin
      if forgoogle = False then
      begin
        file1.writeln('msgid "' + defaultresult[x] + '"');
        file1.writeln('msgstr ""');
      end
      else
        file1.writeln('msgstr "' + defaultresult[x] + '"');
      file1.writeln('');
    end;
  file1.Free;
end;

procedure theaderfo.createnew(const Sender: TObject);
var
  filterlista, filterlistb: msestringarty;
  str1: msestring;
begin

  if (TButton(Sender).tag = 0) or (TButton(Sender).tag = 3) then
  begin
    setlength(filterlista, 1);
    setlength(filterlistb, 1);
    if (TButton(Sender).tag = 0) then
    begin
      filterlista[0] := 'podemo_xz.txt to joint';
      filterlistb[0] := '*.txt';
      impexpfiledialog.controller.filter := '*.txt';
    end;
    if (TButton(Sender).tag = 3) then
    begin
      filterlista[0] := '.mfm to extract captions ';
      filterlistb[0] := '*.mfm';
      impexpfiledialog.controller.filter := '*.mfm';
    end;
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
      labdone.Caption := sc[0];
      paneldone.Visible := True;
      application.ProcessMessages;
      str1 := impexpfiledialog.controller.filename;
      if (TButton(Sender).tag = 0) then
        createnewconst(Sender, str1);
      if (TButton(Sender).tag = 3) then
        extractcaption(Sender, str1);
      paneldone.frame.colorclient := cl_ltgreen;
      labdone.Caption   := sc[1];
      paneldone.Visible := True;
      ttimer1.Enabled   := True;
    end;
  end;

  if (TButton(Sender).tag = 1) or (TButton(Sender).tag = 2) then
  begin
    if (TButton(Sender).tag = 1) then
      forgoogle := False
    else
      forgoogle := True;
    createnewpo(Sender, '');
    paneldone.frame.colorclient := cl_ltgreen;
    labdone.Caption := sc[1];
    paneldone.Visible := True;
    ttimer1.Enabled   := True;
  end;

end;

procedure theaderfo.createnewconst(const Sender: TObject; fn: msestring);
var
  x: integer;
  file1: ttextdatastream;
  str1, strlang, filename1: msestring;
  str2: utf8String;
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
      str1 := '';
      file1.readln(str1);
      str2 := '';
      if (trim(str1) <> '') and (UTF8Copy(str1, 1, 1) <> '#') then
        if (UTF8Copy(str1, 1, 6) = 'msgstr') then
        begin
          str2 := UTF8Copy(str1, 7, length(str1));
          str2 := utf8StringReplace(str2, '\n', '', [rfReplaceAll]);
          str2 := utf8StringReplace(str2, '\', '', [rfReplaceAll]);
          str2 := utf8StringReplace(str2, '"', '', [rfReplaceAll]);
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
        str1 := '';
        file1.readln(str1);
        str2 := '';
        if (trim(str1) <> '') and (UTF8Copy(str1, 1, 1) <> '#') then
          if (UTF8Copy(str1, 1, 5) = 'msgid') then
          begin
            str2 := UTF8Copy(str1, 7, length(str1));
            str2 := utf8StringReplace(str2, '\n', '', [rfReplaceAll]);
            str2 := utf8StringReplace(str2, '\', '', [rfReplaceAll]);
            str2 := utf8StringReplace(str2, '"', '', [rfReplaceAll]);
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

procedure theaderfo.oncreateform(const Sender: TObject);
begin
  outputdir.Value := ExtractFilePath(ParamStr(0)) + 'output' + directoryseparator;
end;

procedure theaderfo.ontime(const Sender: TObject);
begin
  paneldone.Visible := False;
end;

procedure theaderfo.oncreated(const Sender: TObject);
begin
  //headerfo.visible := false;
end;

procedure theaderfo.onclose(const Sender: TObject);
begin
  tbutton1.Visible   := False;
  tmemoedit1.Visible := False;
end;

procedure theaderfo.onactiv(const Sender: TObject);
begin
  //visible := false;
end;

end.

