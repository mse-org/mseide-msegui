{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseconsts;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface

uses
 msestockobjects,msegui,msestrings;
 
type
 stockcaptionty = array[stockcaptionsty] of widestring;
 pstockcaptionty = ^stockcaptionty;
 defaultmodalresulttextty = array[modalresultty] of msestring;
 pdefaultmodalresulttextty = ^defaultmodalresulttextty;
 langty = (la_none,la_en,la_de,la_ru,la_es,la_uzcyr);
const
 langnames: array[langty] of string = ('','en','de','ru','es','uz_cyr');

 function modalresulttext(const index: modalresultty): msestring;
 function modalresulttextnoshortcut(const index: modalresultty): msestring;
 function stockcaptions(const index: stockcaptionsty): widestring;
 function uc(const index: integer): msestring; //get user caption

 procedure registeruserlangconsts(name: string;
                                      const caption: array of msestring);
 procedure registerlangconsts(const name: string; const stockcaption: stockcaptionty;
            const modalresulttext: defaultmodalresulttextty;
            const modalresulttextnoshortcut: defaultmodalresulttextty);
 function setlangconsts(const name: string): boolean;
                 //true if ok, no change otherwise

implementation
uses
 sysutils,msesysintf;
 
type
 langinfoty = record
  name: string;
  stockcaption: pstockcaptionty;
  modalresulttext: pdefaultmodalresulttextty;
  modalresulttextnoshortcut: pdefaultmodalresulttextty;
 end;
 userlanginfoty = record
  name: string;
  caption: msestringarty;
 end;
 
var
 langs: array of langinfoty;
 lang: langinfoty;
 userlangs: array of userlanginfoty;
 userlang: userlanginfoty;
 
const
 en_modalresulttext: defaultmodalresulttextty =
 ('',         //mr_none
  '',         //mr_canclose
  '',         //mr_windowclosed
  '',         //mr_windowdestroyed
  '',         //mr_escape
  '',         //mr_f10
  '',         //mr_exception
  '&Cancel',  //mr_cancel
  '&Abort',   //mr_abort
  '&OK',      //mr_ok
  '&Yes',     //mr_yes
  '&No',      //mr_no
  'A&ll',     //mr_all
  'No all',   //mr_noall
  'I&gnore'   //mr_ignore
  );

 en_modalresulttextnoshortcut: defaultmodalresulttextty =
 ('',        //mr_none
  '',        //mr_canclose
  '',        //mr_windowclosed
  '',        //mr_windowdestroyed
  '',         //mr_esc
  '',         //mr_f10
  '',        //mr_exception
  'Cancel',  //mr_cancel
  'Abort',   //mr_abort
  'OK',      //mr_ok
  'Yes',     //mr_yes
  'No',      //mr_no
  'All',     //mr_all
  'No all',  //mr_noall
  'Ignore'   //mr_ignore
  );

 en_stockcaption: stockcaptionty = (
  '',                   //sc_none
  'is invalid',         //sc_is_invalid
  'Format error',       //sc_Format_error
  'Value is required',  //sc_Value_is_required
  'Error',              //sc_Error
  'Min',                //sc_Min
  'Max',                //sc_Max
  'Range error',        //sc_Range_error  
  '&Undo',              //sc_Undo  ///
  '&Copy',              //sc_Copy   // hotkeys
  'Cu&t',               //sc_Cut    //
  '&Paste',             //sc_Paste ///
  '&Dir',               //sc_Dir               /// 
  '&Up',                //sc_Up                 //
  '&New dir',           //sc_New_dir            // hotkeys
  '&Name',              //sc_Name               //
  '&Show hidden files', //sc_Show_hidden_files  //
  '&Filter',            //sc_Filter            /// 
  'Save',               //sc_save 
  'Open',               //sc_open
  'Name',                //sc_name1
  'Create new directory',//sc_create_new_directory
  'File',               //sc_file
  'exists, do you want to overwrite?', //sc_exists_overwrite
  'WARNING',               //sc_warningupper
  'ERROR',                 //sc_errorupper
  'does not exist',        //sc_does_not_exist
  'Can not read directory', //sc_can_not_read_directory
  'Graphic format not supported', //sc_graphic_not_supported
  'Graphic format error', //sc_graphic_format_error
  'MS Bitmap',          //sc_MS_Bitmap
  'MS Icon',            //sc_MS_Icon
  'JPEG Image',         //sc_JPEG_Image 
  'PNG Image',          //sc_PNG_Image
  'XPM Image',          //sc_XPM_Image
  'PNM Image',          //sc_PNM_Image
  'TARGA Image',        //sc_TARGA_image
  'All',                //sc_All
  'Confirmation',       //sc_Confirmation
  'Delete record?'      //sc_Delete_record

                       );

procedure registerlangconsts(const name: string; const stockcaption: stockcaptionty;
            const modalresulttext: defaultmodalresulttextty;
            const modalresulttextnoshortcut: defaultmodalresulttextty);
 procedure setitem(var item: langinfoty);
 begin
  item.name:= name;
  item.stockcaption:= @stockcaption;
  item.modalresulttext:= @modalresulttext;
  item.modalresulttextnoshortcut:= @modalresulttextnoshortcut;
 end;
 
var
 int1: integer;
begin
 for int1:= 0 to high(langs) do begin
  if langs[int1].name = name then begin
   setitem(langs[int1]);
   exit;
  end;
 end;
 setlength(langs,high(langs)+2);
 setitem(langs[high(langs)]);
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
    with lang do begin
     name:= langnames[la_en];
     stockcaption:= @en_stockcaption;
     modalresulttext:= @en_modalresulttext;  
     modalresulttextnoshortcut:= @en_modalresulttextnoshortcut;
    end;
   end;
  end
  else begin
   application.langchanged;
  end;
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

function stockcaptions(const index: stockcaptionsty): widestring;
begin
 checklang;
 result:= lang.stockcaption^[index];
end;

initialization
 registerlangconsts(langnames[la_en],en_stockcaption,en_modalresulttext,
                               en_modalresulttextnoshortcut);
end.
