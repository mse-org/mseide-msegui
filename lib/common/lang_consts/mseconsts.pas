{ MSEgui Copyright (c) 1999-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

// Updated for dynamic loading of po files by fredvs

unit mseconsts;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
 msestockobjects,mseglob,msestrings,mseapplication,msetypes;

{$ifdef mse_dynpo}
VAR
  en_modalresulttext,
  en_modalresulttextnoshortcut,
  en_stockcaption,
  en_extendedtext: msestringarty;

implementation

INITIALIZATION

  {$Macro on}
  {$define make_modalresulttext:= en_modalresulttext:= msestringarty.Create}
  {$define make_modalresulttextnoshortcut:= en_modalresulttextnoshortcut:= msestringarty.Create}
  {$define make_stockcaption:= en_stockcaption:= msestringarty.Create}
  {$define make_extendedtext:= en_extendedtext:= msestringarty.Create}
  {$include mseconsts_strings.inc}
  {.$include mseconsts_nodynpo.inc}
{$else}
type
 stockcaptionaty = array[stockcaptionty] of msestring;
  defaultmodalresulttextty = array[modalresultty] of msestring;

// type
   extendedaty  = array[extendedty] of msestring;

defaultgeneratortextty = array[textgeneratorty] of textgeneratorfuncty;
pstockcaptionaty = ^stockcaptionaty;
pdefaultmodalresulttextty = ^defaultmodalresulttextty;
 pdefaultgeneratortextty = ^defaultgeneratortextty;

 langty = (la_none,la_en,la_de,la_ru,la_es,la_uzcyr,la_id,la_zh,
           la_fr);

const
 langnames: array[langty] of string = (
            '','en','de','ru','es','uz_cyr','id','zh',
            'fr');

 function modalresulttext(const index: modalresultty): msestring;
 function modalresulttextnoshortcut(const index: modalresultty): msestring;
 function stockcaptions(const index: stockcaptionty): msestring;
 function stocktextgenerators(const index: textgeneratorty): textgeneratorfuncty;
 function uc(const index: integer): msestring; //get user caption

 procedure registeruserlangconsts(name: string;
                                      const caption: array of msestring);
 procedure registerlangconsts(const name: string;
               const stockcaptionpo: pstockcaptionaty;
            const modalresulttextpo: pdefaultmodalresulttextty;
            const modalresulttextnoshortcutpo: pdefaultmodalresulttextty;
            const textgeneratorpo: pdefaultgeneratortextty);
 function setlangconsts(const name: string): boolean;
                 //true if ok, no change otherwise
 function getcurrentlangconstsname: string;
 procedure setuserlangconsts(const name: string);
                 //called by setlangconsts automatically
type
 langchangeprocty = procedure(const langname: ansistring);

 procedure registerlangchangeproc(const aproc: langchangeprocty);
 procedure unregisterlangchangeproc(const aproc: langchangeprocty);

const
  {$Macro on}
  {$define make_modalresulttext:= en_modalresulttext: defaultmodalresulttextty =}
  {$define make_modalresulttextnoshortcut:= en_modalresulttextnoshortcut: defaultmodalresulttextty =}
  {$define make_stockcaption:= en_stockcaption: stockcaptionaty =}
  {$define make_extendedtext:= en_extendedtext: extendedaty =}
  {$include mseconsts_strings.inc}
///////////////////
  en_langnamestext: array {$if fpc_fullversion <= 030100} [0..5] {$endif} of msestring = (
    'English [en]',
    'Russian [ru]',
    'French [fr]',
    'German [de]',
    'Spanish [es]',
    'Portuguese [pt]'
    );
///////////////////

implementation
uses
 sysutils,msesysintf,msearrayutils,mseformatstr;

type
 langinfoty = record
  name: string;
  stockcaption: pstockcaptionaty;
  modalresulttext: pdefaultmodalresulttextty;
  modalresulttextnoshortcut: pdefaultmodalresulttextty;
  textgenerator: pdefaultgeneratortextty;
 end;
 userlanginfoty = record
  name: string;
  caption: msestringarty;
 end;

var
 langs: array of langinfoty;
 lang: langinfoty;
 langbefore: ansistring;
 userlangs: array of userlanginfoty;
 userlang: userlanginfoty;
 langchangeprocs: array of langchangeprocty;

// type
//    extendedaty  = array[extendedty] of msestring;

function delete_n_selected_rows(const params: array of const): msestring;
begin
 with params[0] do begin
  if vinteger = 1 then begin
   result:= 'Delete selected row?'
  end
  else begin
   result:= 'Delete '+inttostrmse(vinteger)+' selected rows?';
  end;
 end;
end;

const
 en_textgenerator: defaultgeneratortextty = (
              {$ifdef FPC}@{$endif}delete_n_selected_rows //tg_delete_n_selected_rows
                                             );

procedure setitem(var item: langinfoty;
           const name: string;
           const stockcaptionpo: pstockcaptionaty;
           const modalresulttextpo: pdefaultmodalresulttextty;
           const modalresulttextnoshortcutpo: pdefaultmodalresulttextty;
           const textgeneratorpo: pdefaultgeneratortextty);
begin
 item.name:= name;
 item.stockcaption:= stockcaptionpo;
 item.modalresulttext:= modalresulttextpo;
 item.modalresulttextnoshortcut:= modalresulttextnoshortcutpo;
 item.textgenerator:= textgeneratorpo;
end;

procedure registerlangconsts(const name: string;
            const stockcaptionpo: pstockcaptionaty;
            const modalresulttextpo: pdefaultmodalresulttextty;
            const modalresulttextnoshortcutpo: pdefaultmodalresulttextty;
            const textgeneratorpo: pdefaultgeneratortextty);


var
 int1: integer;
begin
 for int1:= 0 to high(langs) do begin
  if langs[int1].name = name then begin
   setitem(langs[int1],name,stockcaptionpo,modalresulttextpo,
                               modalresulttextnoshortcutpo,textgeneratorpo);
   exit;
  end;
 end;
 setlength(langs,high(langs)+2);
 setitem(langs[high(langs)],name,stockcaptionpo,modalresulttextpo,
                               modalresulttextnoshortcutpo,textgeneratorpo);
end;

procedure registeruserlangconsts(name: string;
                                      const caption: array of msestring);
 procedure setitem(var item: userlanginfoty);
 var
  int1: integer;
 begin
  item.name:= name;
  setlength(item.caption,length(caption));
  for int1:= 0 to high(caption) do begin
   item.caption[int1]:= caption[int1];
  end;
 end;

var
 int1: integer;
begin
 name:= lowercase(name);
 for int1:= 0 to high(userlangs) do begin
  if userlangs[int1].name = name then begin
   setitem(userlangs[int1]);
   exit;
  end;
 end;
 setlength(userlangs,high(userlangs)+2);
 setitem(userlangs[high(userlangs)]);
end;

procedure setuserlangconsts(const name: string);
var
 int1: integer;
begin
 if name = '' then begin
  if high(userlangs) >= 0 then begin
   userlang:= userlangs[0];
  end;
 end
 else begin
  if name <> userlang.name then begin
   for int1:= 0 to high(userlangs) do begin
    if userlangs[int1].name = name then begin
     userlang:= userlangs[int1];
     break;
    end;
   end;
  end;
 end;
end;

function getcurrentlangconstsname: string;
begin
 result:= lang.name;
end;

function setlangconsts(const name: string): boolean;
var
 int1: integer;
 bo1: boolean;
 str1: string;
begin
 if name = '' then begin
  str1:= lowercase(sys_getlangname);
  if str1 = '' then begin
   str1:= langnames[la_en];
  end;
 end
 else begin
  str1:= lowercase(name);
 end;
 setuserlangconsts(str1);
 result:= false;
 bo1:= lang.name = '';
 if lang.name <> str1 then begin
  for int1:= 0 to high(langs) do begin
   if langs[int1].name = str1 then begin
    lang:= langs[int1];
    result:= true;
    break;
   end;
  end;
  if bo1 then begin
   if lang.name = '' then begin
    setitem(lang,langnames[la_en],@en_stockcaption,@en_modalresulttext,
               @en_modalresulttextnoshortcut,@en_textgenerator);
{
    with lang do begin
     name:= langnames[la_en];
     stockcaption:= @en_stockcaption;
     modalresulttext:= @en_modalresulttext;
     modalresulttextnoshortcut:= @en_modalresulttextnoshortcut;
     textgenerator:= @en_textgenerator;
    end;
}
   end;
  end;
 end;
 if lowercase(str1) <> langbefore then begin
  for int1:= 0 to high(langchangeprocs) do begin
   langchangeprocs[int1](str1);
  end;
  application.langchanged;
 end;
end;

procedure checklang;
begin
 if lang.name = '' then begin
  setlangconsts('');
 end;
end;

function uc(const index: integer): msestring;
begin
 if userlang.name = '' then begin
  setuserlangconsts('');
 end;
 if (index < 0) or (index > high(userlang.caption)) then begin
  raise exception.create('Invalid user caption index: '+inttostr(index)+'.');
 end;
 result:= userlang.caption[index];
end;

function modalresulttext(const index: modalresultty): msestring;
begin
 checklang;
 result:= lang.modalresulttext^[index];
end;

function modalresulttextnoshortcut(const index: modalresultty): msestring;
begin
 checklang;
 result:= lang.modalresulttextnoshortcut^[index];
end;

function stocktextgenerators(const index: textgeneratorty): textgeneratorfuncty;
begin
 checklang;
 result:= lang.textgenerator^[index];
end;

function stockcaptions(const index: stockcaptionty): msestring;
begin
 checklang;
 result:= lang.stockcaption^[index];
end;

procedure registerlangchangeproc(const aproc: langchangeprocty);
begin
 additem(pointerarty(langchangeprocs),{$ifndef FPC}@{$endif}aproc);
end;

procedure unregisterlangchangeproc(const aproc: langchangeprocty);
begin
 removeitem(pointerarty(langchangeprocs),{$ifndef FPC}@{$endif}aproc);
end;

initialization
 registerlangconsts(langnames[la_en],@en_stockcaption,@en_modalresulttext,
                               @en_modalresulttextnoshortcut,@en_textgenerator);
 langbefore:= langnames[la_en];
{$endif}

END.
