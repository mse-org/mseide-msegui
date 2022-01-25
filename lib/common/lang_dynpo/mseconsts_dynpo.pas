
{ MSEgui Copyright (c) 1999-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

// Updated for dynamic loading of po files by fredvs

unit mseconsts_dynpo;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
  msestockobjects_dynpo,
  mseglob,
  msestrings,
  mseapplication,
  msetypes;

type
  defaultmodalresulttextty  = array[modalresultty] of msestring;
  pdefaultmodalresulttextty = ^defaultmodalresulttextty;

  stockcaptionaty  = array[stockcaptionty] of msestring;
  pstockcaptionaty = ^stockcaptionaty;

  extendedaty  = array[extendedty] of msestring;
  pextendedaty = ^extendedaty;

  // your custom array
  mainformaty  = array[mainformty] of msestring;
  pmainformaty = ^mainformaty;

const
  en_modalresulttext: defaultmodalresulttextty =
    ('',             //mr_none
    '',              //mr_canclose
    '',              //mr_windowclosed
    '',              //mr_windowdestroyed
    '',              //mr_escape
    '',              //mr_f10
    '',              //mr_exception
    '&Cancel',       //mr_cancel
    '&Abort',        //mr_abort
    '&OK',           //mr_ok
    '&Yes',          //mr_yes
    '&No',           //mr_no
    '&All',          //mr_all
    'Yes &all',      //mr_yesall
    'N&o all',       //mr_noall
    '&Ignore',       //mr_ignore
    '&Skip',         //mr_skip
    'Skip a&ll',     //mr_skipall
    'Co&ntinue'      //mr_continue
    );

  en_modalresulttextnoshortcut: defaultmodalresulttextty =
    ('',            //mr_none
    '',             //mr_canclose
    '',             //mr_windowclosed
    '',             //mr_windowdestroyed
    '',             //mr_esc
    '',             //mr_f10
    '',             //mr_exception
    'Cancel',       //mr_cancel
    'Abort',        //mr_abort
    'OK',           //mr_ok
    'Yes',          //mr_yes
    'No',           //mr_no
    'All',          //mr_all
    'Yes all',      //mr_yesall
    'No all',       //mr_noall
    'Ignore',       //mr_ignore
    'Skip',         //mr_skip
    'Skip all',     //mr_skipall
    'Continue'      //mr_continue
    );

  en_stockcaption: stockcaptionaty       = (
    '',                                        //sc_none
    'is invalid',                              //sc_is_invalid
    'Format error',                            //sc_Format_error
    'Value is required',                       //sc_Value_is_required
    'Error',                                   //sc_Error
    'Min',                                     //sc_Min
    'Max',                                     //sc_Max
    'Range error',                             //sc_Range_error

    '&Undo',                                   //sc_Undohk       ///         ///
    '&Redo',                                   //sc_Redohk        //          //
    '&Copy',                                   //sc_Copyhk        // hotkeys  //
    'Cu&t',                                    //sc_Cuthk         //          //
    '&Paste',                                  //sc_Pastehk       //          // hotkeys
    'Select &all',                             //sc_Select_allhk ///          //
    '&Insert Row',                             //sc_insert_rowhk ///          //
    '&Append Row',                             //sc_append_rowhk  // hotkeys  //
    '&Delete Row',                             //sc_delete_rowhk ///         ///

    '&Dir',                                    //sc_Dirhk               ///
    '&Home',                                   //sc_homehk               //
    '&Up',                                     //sc_Uphk                 //
    '&New',                                    //sc_New_dirhk            // hotkeys
    '&Name',                                   //sc_Namehk               //
    '&Show hidden files',                      //sc_Show_hidden_fileshk  //
    '&Filter',                                 //sc_Filterhk            ///
    'Save',                                    //sc_save
    'Open',                                    //sc_open
    'Name',                                    //sc_name
    'Create new directory',                    //sc_create_new_directory
    'Back',                                    //sc_back
    'Forward',                                 //sc_forward
    'Up',                                      //sc_up
    'exists, do you want to overwrite?',       //sc_exists_overwrite
    'is modified. Save?',                      //sc_is_modified_save
    'WARNING',                                 //sc_warningupper
    'Exception',                               //sc_exception
    'System',                                  //sc_system
    'does not exist',                          //sc_does_not_exist
    'PASSWORD',                                //sc_passwordupper
    'Enter password',                          //sc_enterpassword
    'Invalid password!',                       //sc_invalidpassword
    'Can not read directory',                  //sc_can_not_read_directory
    'Graphic format not supported',            //sc_graphic_not_supported
    'Graphic format error',                    //sc_graphic_format_error
    'All Images',                              //sc_All
    'Confirmation',                            //sc_Confirmation
    'Delete record?',                          //sc_Delete_record_question
    'Copy record?',                            //sc_Copy_record_question
    'Close page',                              //sc_close_page
    'First',                                   //sc_first
    'Prior',                                   //sc_prior
    'Next',                                    //sc_next
    'Last',                                    //sc_last
    'Append',                                  //sc_append
    'Delete',                                  //sc_delete
    'Edit',                                    //sc_edit
    'Post',                                    //sc_post
    'Annul',                                   //sc_cancel
    'Refresh',                                 //sc_refresh
    'Edit filter',                             //sc_filter_filter
    'Edit filter minimum',                     //sc_edit_filter_min
    'Edit filter maximum',                     //sc_filter_edit_max
    'Reset filter',                            //sc_reset_filter
    'Filter on',                               //sc_filter_on
    'Search',                                  //sc_search
    'Auto edit',                               //sc_auto_edit
    'Copy record',                             //sc_copy_record
    'Dialog',                                  //sc_dialog
    'Insert',                                  //sc_insert
    'Copy',                                    //sc_copy
    'Paste',                                   //sc_paste
    'Row insert',                              //sc_row_insert
    'Row append',                              //sc_row_append
    'Row delete',                              //sc_row_delete
    'Undo',                                    //sc_undo
    'Redo',                                    //sc_redo
    'Cut',                                     //sc_cut
    'Select all',                              //sc_select_all
    'Filter off',                              //sc_filter_off
    'Portrait',                                //sc_portrait print orientation
    'Landscape',                               //sc_landscape print orientation
    'Delete row?',                             //sc_Delete_row_question
    'selected rows?',                          //sc_selected_rows
    'Single item only',                        //sc_Single_item_only
    'Copy Cells',                              //sc_Copy_Cells
    'Paste Cells',                             //sc_Paste_Cells
    'Close',                                   //sc_close
    'Maximize',                                //sc_maximize
    'Normalize',                               //sc_normalize
    'Minimize',                                //sc_minimize
    'Fix size',                                //sc_fix_size
    'Float',                                   //sc_float
    'Stay on top',                             //sc_stay_on_top
    'Stay in background',                      //sc_stay_in_background
    'Lock children',                           //sc_lock_children
    'No lock',                                 //sc_no_lock
    'Input',                                   //sc_input
    'Button',                                  //sc_button
    'On',                                      //sc_on
    'Off',                                     //sc_off
    'Left border',                             //sc_leftborder
    'Top border',                              //sc_topborder
    'Right border',                            //sc_rightborder
    'Bottom border',                           //sc_bottomborder
    'Begin of text',                           //sc_beginoftext
    'End of text',                             //sc_endoftext
    'Inputmode',                               //sc_inputmode
    'Overwrite',                               //sc_overwrite
    'Deleted',                                 //sc_deleted
    'Copied',                                  //sc_copied
    'Inserted',                                //sc_inserted
    'Pasted',                                  //sc_pasted
    'Withdrawn',                               //sc_withdrawn
    'Window activated',                        //sc_windowactivated
    'Menu',                                    //sc_menu
    'Beginning of file',                       //sc_bof
    'End of file',                             //sc_eof
    'Voice output',                            //sc_voiceoutput
    'Speak again',                             //sc_speakagain
    'First column',                            //sc_firstcol
    'First row',                               //sc_firstrow
    'Last column',                             //sc_lastcol
    'Last row',                                //sc_lastrow
    'Selection',                               //sc_selection
    'Speak path',                              //sc_speakpath
    'Disabled button',                         //sc_disabledbutton
    'First field',                             //sc_firstfield
    'Last field',                              //sc_lastfield
    'First element',                           //sc_firstelement
    'Last element',                            //sc_lastelement
    'Slower',                                  //sc_slower
    'Faster',                                  //sc_faster
    'Window',                                  //sc_window
    'Area',                                    //sc_area
    'Area activated',                          //sc_areaactivated
    'Volume down',                             //sc_volumedown
    'Volume up',                               //sc_volumeup
    'Cancel speech',                           //sc_cancelspeech
    'New',                                     //sc_newfile
    'Tools',                                   //sc_tools
    'Languages',                               // sc_lang
    'Directory',                               // sc_directory
    'No icons',                                // sc_noicons
    'No lateral',                              // sc_themes
    'Compact',                                 // sc_compact
    'Path',                                    // sc_path
    'File'                                     // sc_file
     );

  en_extendedtext: extendedaty =
    ('Delete selected row?',    // ex_del_row_selected
    'Delete %s selected rows?'  // ex_del_rows_selected
    );

   en_mainformtext: mainformaty           = (
    'This is a test of internationalization.',
    'That is a other test.',
    'This is the end.'
    );

  en_langnamestext: array[0..5] of msestring = (
    'English [en]',
    'Russian [ru]',
    'French [fr]',
    'German [de]',
    'Spanish [es]',
    'Portuguese [pt]'
    );

implementation

uses
  SysUtils,
  msesysintf,
  msearrayutils,
  mseformatstr;

initialization

end.

