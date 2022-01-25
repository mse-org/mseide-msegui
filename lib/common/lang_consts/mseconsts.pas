{ MSEgui Copyright (c) 1999-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseconsts;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
 msestockobjects,mseglob,msestrings,mseapplication,msetypes;

type
 stockcaptionaty = array[stockcaptionty] of msestring;
 pstockcaptionaty = ^stockcaptionaty;
 defaultmodalresulttextty = array[modalresultty] of msestring;
 pdefaultmodalresulttextty = ^defaultmodalresulttextty;
 defaultgeneratortextty = array[textgeneratorty] of textgeneratorfuncty;
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

const
 en_modalresulttext: defaultmodalresulttextty =
 ('',          //mr_none
  '',          //mr_canclose
  '',          //mr_windowclosed
  '',          //mr_windowdestroyed
  '',          //mr_escape
  '',          //mr_f10
  '',          //mr_exception
  '&Cancel',   //mr_cancel
  '&Abort',    //mr_abort
  '&OK',       //mr_ok
  '&Yes',      //mr_yes
  '&No',       //mr_no
  '&All',      //mr_all
  'Yes &all',  //mr_yesall
  'N&o all',   //mr_noall
  '&Ignore',   //mr_ignore
  '&Skip',     //mr_skip
  'Skip a&ll', //mr_skipall
  'Co&ntinue'  //mr_continue
  );

 en_modalresulttextnoshortcut: defaultmodalresulttextty =
 ('',         //mr_none
  '',         //mr_canclose
  '',         //mr_windowclosed
  '',         //mr_windowdestroyed
  '',         //mr_esc
  '',         //mr_f10
  '',         //mr_exception
  'Cancel',   //mr_cancel
  'Abort',    //mr_abort
  'OK',       //mr_ok
  'Yes',      //mr_yes
  'No',       //mr_no
  'All',      //mr_all
  'Yes all',  //mr_yesall
  'No all',   //mr_noall
  'Ignore',   //mr_ignore
  'Skip',     //mr_skip
  'Skip all', //mr_skipall
  'Continue'  //mr_continue
  );

 en_stockcaption: stockcaptionaty = (
  '',                   //sc_none
  'is invalid',         //sc_is_invalid
  'Format error',       //sc_Format_error
  'Value is required',  //sc_Value_is_required
  'Error',              //sc_Error
  'Min',                //sc_Min
  'Max',                //sc_Max
  'Range error',        //sc_Range_error

  '&Undo',              //sc_Undohk       ///         ///
  '&Redo',              //sc_Redohk        //          //
  '&Copy',              //sc_Copyhk        // hotkeys  //
  'Cu&t',               //sc_Cuthk         //          //
  '&Paste',             //sc_Pastehk       //          // hotkeys
  'Select &all',        //sc_Select_allhk ///          //
  '&Insert Row',        //sc_insert_rowhk ///          //
  '&Append Row',        //sc_append_rowhk  // hotkeys  //
  '&Delete Row',        //sc_delete_rowhk ///         ///

  '&Dir',               //sc_Dirhk               ///
  '&Home',              //sc_homehk               //
  '&Up',                //sc_Uphk                 //
  '&New dir',           //sc_New_dirhk            // hotkeys
  '&Name',              //sc_Namehk               //
  '&Show hidden files', //sc_Show_hidden_fileshk  //
  '&Filter',            //sc_Filterhk            ///
  'Save',               //sc_save
  'Open',               //sc_open
  'Name',                //sc_name
  'Create new directory',//sc_create_new_directory
  'Back',                //sc_back
  'Forward',             //sc_forward
  'Up',                  //sc_up
  'File',                //sc_file
  'exists, do you want to overwrite?', //sc_exists_overwrite
  'is modified. Save?',  //sc_is_modified_save
  'WARNING',               //sc_warningupper
  'ERROR',                 //sc_errorupper
  'Exception',             //sc_exception
  'System',                //sc_system
  'does not exist',        //sc_does_not_exist
  'PASSWORD',              //sc_passwordupper
  'Enter password',        //sc_enterpassword
  'Invalid password!',     //sc_invalidpassword
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
  'TIFF Image',         //sc_TIFF_image
  'All',                //sc_All
  'Confirmation',       //sc_Confirmation
  'Delete record?',     //sc_Delete_record_question
  'Copy record?',       //sc_Copy_record_question
  'Close page',         //sc_close_page
  'First',              //sc_first
  'Prior',              //sc_prior
  'Next',               //sc_next
  'Last',               //sc_last
  'Append',             //sc_append
  'Delete',             //sc_delete
  'Edit',               //sc_edit
  'Post',               //sc_post
  'Cancel',             //sc_cancel
  'Refresh',            //sc_refresh
  'Edit filter',        //sc_filter_filter
  'Edit filter minimum',//sc_edit_filter_min
  'Edit filter maximum',//sc_filter_edit_max
  'Reset filter',       //sc_reset_filter
  'Filter on',          //sc_filter_on
  'Search',             //sc_search
  'Auto edit',          //sc_auto_edit
  'Copy record',        //sc_copy_record
  'Dialog',             //sc_dialog
  'Insert',             //sc_insert
  'Copy',               //sc_copy
  'Paste',              //sc_paste
  'Row insert',         //sc_row_insert
  'Row append',         //sc_row_append
  'Row delete',         //sc_row_delete
  'Undo',               //sc_undo
  'Redo',               //sc_redo
  'Cut',                //sc_cut
  'Select all',         //sc_select_all

  'Filter off',         //sc_filter_off
  'Portrait',           //sc_portrait print orientation
  'Landscape',          //sc_landscape print orientation
  'Delete row?',        //sc_Delete_row_question
  'selected rows?',     //sc_selected_rows
  'Single item only',    //sc_Single_item_only
  'Copy Cells',          //sc_Copy_Cells
  'Paste Cells',         //sc_Paste_Cells
  'Close',               //sc_close
  'Maximize',            //sc_maximize
  'Normalize',           //sc_normalize
  'Minimize',            //sc_minimize
  'Fix size',            //sc_fix_size
  'Float',               //sc_float
  'Stay on top',         //sc_stay_on_top
  'Stay in background',  //sc_stay_in_background
  'Lock children',       //sc_lock_children
  'No lock',             //sc_no_lock
  'Input',               //sc_input
  'Button',              //sc_button
  'On',                  //sc_on
  'Off',                 //sc_off
  'Left border',         //sc_leftborder
  'Top border',          //sc_topborder
  'Right border',        //sc_rightborder
  'Bottom border',       //sc_bottomborder
  'Begin of text',       //sc_beginoftext
  'End of text',         //sc_endoftext
  'Inputmode',           //sc_inputmode
  'Overwrite',           //sc_overwrite
  'Deleted',             //sc_deleted
  'Copied',              //sc_copied
  'Inserted',            //sc_inserted
  'Pasted',              //sc_pasted
  'Withdrawn',           //sc_withdrawn
  'Window activated',    //sc_windowactivated
  'Menu',                //sc_menu
  'Beginning of file',   //sc_bof
  'End of file',         //sc_eof
  'Voice output',        //sc_voiceoutput
  'Speak again',         //sc_speakagain
  'First column',        //sc_firstcol
  'First row',           //sc_firstrow
  'Last column',         //sc_lastcol
  'Last row',            //sc_lastrow
  'Selection',           //sc_selection
  'Speak path',          //sc_speakpath
  'Disabled button',     //sc_disabledbutton
  'First field',         //sc_firstfield
  'Last field',          //sc_lastfield
  'First element',       //sc_firstelement
  'Last element',        //sc_lastelement
  'Slower',              //sc_slower
  'Faster',              //sc_faster
  'Window',              //sc_window
  'Area',                //sc_area
  'Area activated',      //sc_areaactivated
  'Volume down',         //sc_volumedown
  'Volume up',           //sc_volumeup
  'Cancel speech',        //sc_cancelspeech
  'New',                 //sc_newfile
  'Tools',               //sc_tools
  'Languages',           // sc_lang
  'Directory',           // sc_directory
  'No icons',            // sc_noicons
  'No lateral',          // sc_themes
  'Compact',             // sc_compact
  'Path'               // sc_path
 );

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
end.
