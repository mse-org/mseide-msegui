{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    
    Russian translation by IvankoB.
    
}


unit mseconsts_ru;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 mseconsts;
 
implementation
const
 ru_modalresulttext: defaultmodalresulttextty =
 ('',                                             //mr_none
  '',                                             //mr_canclose
  '',                                             //mr_windowclosed
  '',                                             //mr_windowdestroyed
  '',                                             //mr_exception
  '&'#1054#1090#1084#1077#1085#1080#1090#1100 ,   //mr_cancel => &Otmenit`
  '&'#1055#1088#1077#1088#1074#1072#1090#1100 ,   //mr_abort => &Prervat`
  '&'#1043#1086#1090#1086#1074#1086 ,             //mr_ok => &Gotovo
  '&'#1044#1072 ,                                 //mr_yes => &Da
  '&'#1053#1077#1090 ,                            //mr_no => &Net
  '&'#1042#1089#1077 ,                            //mr_all => &Vse
  #1053'&'#1080#1082#1072#1082#1080#1077,         //mr_noall => // N&ikakie
  #1053#1077#1074#1072'&'#1078#1085#1086          //mr_ignore => // Neva&zhno
 );

 ru_modalresulttextnoshortcut: defaultmodalresulttextty =
 ('',                                         //mr_none
  '',                                         //mr_canclose
  '',                                         //mr_windowclosed
  '',                                         //mr_windowdestroyed
  '',                                         //mr_exception
  #1054#1090#1084#1077#1085#1080#1090#1100 ,  //mr_cancel => Otmenit`
  #1055#1088#1077#1088#1074#1072#1090#1100 ,  //mr_abort => Prervat`
  #1043#1086#1090#1086#1074#1086 ,            //mr_ok => Gotovo
  #1044#1072 ,                                //mr_yes => Da
  #1053#1077#1090 ,                           //mr_no => Net
  #1042#1089#1077 ,                           //mr_all => Vse
  #1053#1080#1082#1072#1082#1080#1077,        //mr_noall => // Nikakie  
  #1053#1077#1074#1072#1078#1085#1086	      //mr_ignore => // Nevazhno
  );

 ru_stockcaption: stockcaptionty = (
  '',                                         //sc_none
  '- '#1085#1077#1074#1077#1088#1085#1086 ,   //sc_is_invalid => - neverno
  #1053#1077#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1080#1077' '#1092#1086#1088#1084#1072#1090#1091 ,
                                              //sc_Format_error => Nesootvetstvie formatu
  #1058#1088#1077#1073#1091#1077#1090#1089#1103' '#1079#1085#1072#1095#1077#1085#1080#1077 ,
                                 //sc_Value_is_required => Trebuetsya znachenie
  #1054#1096#1080#1073#1082#1072 ,            //sc_Error => Oshibka
  #1052#1080#1085'.' ,    //sc_Min => Min.
  #1052#1072#1082#1089'.' ,    //sc_Max => Maks.
  #1053#1077#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1080#1077' '#1076#1080#1072#1087#1072#1079#1086#1085#1091 ,
                                //sc_Range_error => Nesootvetstvie diapazonu
  #1042#1077#1088#1085#1091#1090#1100 ,       //sc_Undo  /// => Vernut`
  #1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100 , 
                                              //sc_Copy   // hotkeys=> Skopirovat`
  #1042#1099#1088#1077#1079#1072#1090#1100 ,  //sc_Cut    // => Vyrezat`
  #1042#1089#1090#1072#1074#1080#1090#1100,    //sc_Paste /// => Vstavit`
  '&Dir',               //sc_Dir               /// 
  '&Up',                //sc_Up                 //
  '&New dir',           //sc_New_dir            // hotkeys
  '&Name',              //sc_Name               //
  '&Show hidden files', //sc_Show_hidden_files  //
  '&Filter',            //sc_Filter            /// 
  'Save',               //sc_save 
  'Open'                //sc_open
  );
    
initialization
 registerlangconsts(langnames[la_ru],ru_stockcaption,ru_modalresulttext,
                               ru_modalresulttextnoshortcut);
end.
