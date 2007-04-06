{ Contributed module by Mikhail Kozlov (mihnik_k@mail.ru) for MSEgui(c)

    See the file COPYING.MSE the part of the MSEgui distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit GuiStyle;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
  msegraphics, msebits 
  {$ifdef mswindows},windows{$endif}
  {$ifdef linux},msestat,strutils,sysutils,classes{$endif};

  procedure SetDesktopSkin;

implementation
{$ifdef linux}
const
  QT_COLOR_BACKGROUND = 1;
  QT_COLOR_HILIGHT = 2;
  QT_COLOR_LIGHT = 3;
  QT_COLOR_DKSHADOW = 4;
  QT_COLOR_SHADOW = 5;
  QT_COLOR_TEXT = 6;
  QT_COLOR_BTNTEXT = 8;
  QT_COLOR_FOREGROUND = 9;
  QT_COLOR_INFOBG = 10;
  QT_COLOR_SELBACKGROUND = 12;
  QT_COLOR_SELECTEDTEXT = 13;
  QT_COLOR_GRAYTEXT = 24;
{$endif}

procedure SetDesktopSkin;
{$ifdef linux}
var
  sr: tstatreader;
  s: string;
  sl: TStringList;
  I, int1: Integer;
  clrs: colorarty;
  
  function StaStringToInt(Str: String): Integer;
  begin
    Result := 0;
    try
      Result := Hex2Dec(AnsiReplaceStr(Str, '#', ''));
    except
    end;
  end;
  
{$endif}
begin
  {$ifdef mswindows}
  SetColorMapValue(cl_dkshadow, swaprgb(GetSysColor(COLOR_3DDKSHADOW)));
  SetColorMapValue(cl_shadow, swaprgb(GetSysColor(COLOR_3DSHADOW)));
  SetColorMapValue(cl_mid, swaprgb(GetSysColor(COLOR_BTNTEXT)));
  SetColorMapValue(cl_light, swaprgb(GetSysColor(COLOR_3DLIGHT)));
  SetColorMapValue(cl_highlight, swaprgb(GetSysColor(COLOR_3DHILIGHT)));
  SetColorMapValue(cl_background, swaprgb(GetSysColor(COLOR_BTNFACE)));
  SetColorMapValue(cl_foreground, swaprgb(GetSysColor(COLOR_WINDOW)));
  SetColorMapValue(cl_active, swaprgb(GetSysColor(COLOR_HIGHLIGHT)));
  SetColorMapValue(cl_noedit, swaprgb(GetSysColor(COLOR_GRAYTEXT)));
  SetColorMapValue(cl_text, swaprgb(GetSysColor(COLOR_WINDOWTEXT)));
  SetColorMapValue(cl_selectedtext, swaprgb(GetSysColor(COLOR_HIGHLIGHTTEXT)));
  SetColorMapValue(cl_selectedtextbackground, swaprgb(GetSysColor(COLOR_HIGHLIGHT)));
  SetColorMapValue(cl_infobackground, swaprgb(GetSysColor(COLOR_INFOBK)));
  {$else}
  try
    sr := tstatreader.create('~/.qt/qtrc');
    sl := TStringList.Create;
    try
      if sr.FindSection('General') then
      begin
        s := sr.ReadString('font', s);
        sl.Text := AnsiReplaceStr(s, ',', #13);
        if sl.Count > 2 then
        begin
          RegisterFontAlias('stf_default', sl[0], fam_overwrite,
            StrToIntDef(sl[1], 16));
          RegisterFontAlias('stf_menu', sl[0], fam_overwrite,
            StrToIntDef(sl[1], 16));
        end;
      end;
      if sr.FindSection('Palette') then
      begin
        s := sr.ReadString('active', s);
        sl.Text := AnsiReplaceStr(AnsiReplaceStr(s, '#', ''), '^e', #13);
        SetLength(clrs, sl.Count * 2);
        for I := 0 to sl.count - 1 do
          clrs[I] := StaStringToInt(sl[I]);
        int1 := sl.Count;
        s := sr.ReadString('disabled', s);
        sl.Text := AnsiReplaceStr(AnsiReplaceStr(s, '#', ''), '^e', #13);
        for I := 0 to sl.count - 1 do
          clrs[I + int1] := StaStringToInt(sl[I]);
        SetColorMapValue(cl_dkshadow, clrs[QT_COLOR_DKSHADOW]);
        SetColorMapValue(cl_shadow, clrs[QT_COLOR_SHADOW]);
        SetColorMapValue(cl_mid, clrs[QT_COLOR_BTNTEXT]);
        SetColorMapValue(cl_highlight, clrs[QT_COLOR_HILIGHT]);
        SetColorMapValue(cl_light, clrs[QT_COLOR_LIGHT]);
        SetColorMapValue(cl_background, clrs[QT_COLOR_BACKGROUND]);
        SetColorMapValue(cl_foreground, clrs[QT_COLOR_FOREGROUND]);
        SetColorMapValue(cl_active, clrs[QT_COLOR_HILIGHT]);
        SetColorMapValue(cl_noedit, clrs[QT_COLOR_GRAYTEXT]);
        SetColorMapValue(cl_text, clrs[QT_COLOR_TEXT]);
        SetColorMapValue(cl_selectedtext, clrs[QT_COLOR_SELECTEDTEXT]);
        SetColorMapValue(cl_selectedtextbackground, clrs[QT_COLOR_SELBACKGROUND]);
        SetColorMapValue(cl_infobackground, clrs[QT_COLOR_INFOBG]);
      end;
    finally
      sl.Free;
      sr.Free;
    end;
  except
  end;
  {$endif}
end;

end.
