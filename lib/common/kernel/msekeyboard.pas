{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msekeyboard;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 msestrings;
type
 keyty = (
        key_none =               $0000,
        key_Space =              $0020,               // 7 bit printable ASCII
        key_Any = Key_Space,
        key_Exclam =             $0021,
        key_QuoteDbl =           $0022,
        key_NumberSign =         $0023,
        key_Dollar =             $0024,
        key_Percent =            $0025,
        key_Ampersand =          $0026,
        key_Apostrophe =         $0027,
        key_ParenLeft =          $0028,
        key_ParenRight =         $0029,
        key_Asterisk =           $002a,
        key_Plus =               $002b,
        key_Comma =              $002c,
        key_Minus =              $002d,
        key_Period =             $002e,
        key_Slash =              $002f,
        key_0 =                  $0030,
        key_1 =                  $0031,
        key_2 =                  $0032,
        key_3 =                  $0033,
        key_4 =                  $0034,
        key_5 =                  $0035,
        key_6 =                  $0036,
        key_7 =                  $0037,
        key_8 =                  $0038,
        key_9 =                  $0039,
        key_Colon =              $003a,
        key_Semicolon =          $003b,
        key_Less =               $003c,
        key_Equal =              $003d,
        key_Greater =            $003e,
        key_Question =           $003f,
        key_At =                 $0040,
        key_A =                  $0041,
        key_B =                  $0042,
        key_C =                  $0043,
        key_D =                  $0044,
        key_E =                  $0045,
        key_F =                  $0046,
        key_G =                  $0047,
        key_H =                  $0048,
        key_I =                  $0049,
        key_J =                  $004a,
        key_K =                  $004b,
        key_L =                  $004c,
        key_M =                  $004d,
        key_N =                  $004e,
        key_O =                  $004f,
        key_P =                  $0050,
        key_Q =                  $0051,
        key_R =                  $0052,
        key_S =                  $0053,
        key_T =                  $0054,
        key_U =                  $0055,
        key_V =                  $0056,
        key_W =                  $0057,
        key_X =                  $0058,
        key_Y =                  $0059,
        key_Z =                  $005a,
        key_BracketLeft =        $005b,
        key_Backslash =          $005c,
        key_BracketRight =       $005d,
        key_AsciiCircum =        $005e,
        key_Underscore =         $005f,
        key_QuoteLeft =          $0060,
        key_BraceLeft =          $007b,
        key_Bar =                $007c,
        key_BraceRight =         $007d,
        key_AsciiTilde =         $007e,

        // Latin 1 codes adapted from X: keysymdef.h,v 1.21 94/08/28 16:17:06

        key_nobreakspace =       $00a0,
        key_exclamdown =         $00a1,
        key_cent =               $00a2,
        key_sterling =           $00a3,
        key_currency =           $00a4,
        key_yen =                $00a5,
        key_brokenbar =          $00a6,
        key_section =            $00a7,
        key_diaeresis =          $00a8,
        key_copyright =          $00a9,
        key_ordfeminine =        $00aa,
        key_guillemotleft =      $00ab,      // left angle quotation mark
        key_notsign =            $00ac,
        key_hyphen =             $00ad,
        key_registered =         $00ae,
        key_macron =             $00af,
        key_degree =             $00b0,
        key_plusminus =          $00b1,
        key_twosuperior =        $00b2,
        key_threesuperior =      $00b3,
        key_acute =              $00b4,
        key_mu =                 $00b5,
        key_paragraph =          $00b6,
        key_periodcentered =     $00b7,
        key_cedilla =            $00b8,
        key_onesuperior =        $00b9,
        key_masculine =          $00ba,
        key_guillemotright =     $00bb,     // right angle quotation mark
        key_onequarter =         $00bc,
        key_onehalf =            $00bd,
        key_threequarters =      $00be,
        key_questiondown =       $00bf,
        key_Agrave =             $00c0,
        key_Aacute =             $00c1,
        key_Acircumflex =        $00c2,
        key_Atilde =             $00c3,
        key_Adiaeresis =         $00c4,
        key_Aring =              $00c5,
        key_AE =                 $00c6,
        key_Ccedilla =           $00c7,
        key_Egrave =             $00c8,
        key_Eacute =             $00c9,
        key_Ecircumflex =        $00ca,
        key_Ediaeresis =         $00cb,
        key_Igrave =             $00cc,
        key_Iacute =             $00cd,
        key_Icircumflex =        $00ce,
        key_Idiaeresis =         $00cf,
        key_ETH =                $00d0,
        key_Ntilde =             $00d1,
        key_Ograve =             $00d2,
        key_Oacute =             $00d3,
        key_Ocircumflex =        $00d4,
        key_Otilde =             $00d5,
        key_Odiaeresis =         $00d6,
        key_multiply =           $00d7,
        key_Ooblique =           $00d8,
        key_Ugrave =             $00d9,
        key_Uacute =             $00da,
        key_Ucircumflex =        $00db,
        key_Udiaeresis =         $00dc,
        key_Yacute =             $00dd,
        key_THORN =              $00de,
        key_ssharp =             $00df,
        key_agrave_lower =       $00e0,
        key_aacute_lower =       $00e1,
        key_acircumflex_lower =  $00e2,
        key_atilde_lower =       $00e3,
        key_adiaeresis_lower =   $00e4,
        key_aring_lower =        $00e5,
        key_ae_lower =           $00e6,
        key_ccedilla_lower =     $00e7,
        key_egrave_lower =       $00e8,
        key_eacute_lower =       $00e9,
        key_ecircumflex_lower =  $00ea,
        key_ediaeresis_lower =   $00eb,
        key_igrave_lower =       $00ec,
        key_iacute_lower =       $00ed,
        key_icircumflex_lower =  $00ee,
        key_idiaeresis_lower =   $00ef,
        key_eth_lower =          $00f0,
        key_ntilde_lower =       $00f1,
        key_ograve_lower =       $00f2,
        key_oacute_lower =       $00f3,
        key_ocircumflex_lower =  $00f4,
        key_otilde_lower =       $00f5,
        key_odiaeresis_lower =   $00f6,
        key_division =           $00f7,
        key_oslash =             $00f8,
        key_ugrave_lower =       $00f9,
        key_uacute_lower =       $00fa,
        key_ucircumflex_lower =  $00fb,
        key_udiaeresis_lower =   $00fc,
        key_yacute_lower =       $00fd,
        key_thorn_lower =        $00fe,
        key_ydiaeresis =         $00ff,

        key_Escape =             $1000,            // misc keys
        key_Tab =                $1001,
        key_Backtab =            $1002,
        key_Backspace =          $1003,
        key_Return =             $1004,
        key_Enter =              $1005,
        key_Insert =             $1006,
        key_Delete =             $1007,
        key_Pause =              $1008,
        key_Print =              $1009,
        key_SysReq =             $100a,
        key_Home =               $1010,              // cursor movement
        key_End =                $1011,
        key_Left =               $1012,
        key_Up =                 $1013,
        key_Right =              $1014,
        key_Down =               $1015,
        key_Prior =              $1016,
        Key_PageUp = Key_Prior,
        key_Next =               $1017,
        Key_PageDown = Key_Next,

        key_Shift =              $1020,             // modifiers
        key_Control =            $1021,
        key_Meta =               $1022,
        key_Alt =                $1023,
        key_CapsLock =           $1024,
        key_NumLock =            $1025,
        key_ScrollLock =         $1026,
        key_F1 =                 $1030,                // function keys
        key_F2 =                 $1031,
        key_F3 =                 $1032,
        key_F4 =                 $1033,
        key_F5 =                 $1034,
        key_F6 =                 $1035,
        key_F7 =                 $1036,
        key_F8 =                 $1037,
        key_F9 =                 $1038,
        key_F10 =                $1039,
        key_F11 =                $103a,
        key_F12 =                $103b,
        key_F13 =                $103c,
        key_F14 =                $103d,
        key_F15 =                $103e,
        key_F16 =                $103f,
        key_F17 =                $1040,
        key_F18 =                $1041,
        key_F19 =                $1042,
        key_F20 =                $1043,
        key_F21 =                $1044,
        key_F22 =                $1045,
        key_F23 =                $1046,
        key_F24 =                $1047,
        key_F25 =                $1048,               // F25 .. F35 only on X11
        key_F26 =                $1049,
        key_F27 =                $104a,
        key_F28 =                $104b,
        key_F29 =                $104c,
        key_F30 =                $104d,
        key_F31 =                $104e,
        key_F32 =                $104f,
        key_F33 =                $1050,
        key_F34 =                $1051,
        key_F35 =                $1052,
        key_Super_L =            $1053,           // extra keys
        key_Super_R =            $1054,
        key_Menu =               $1055,
        key_Hyper_L =            $1056,
        key_Hyper_R =            $1057,
        key_Help =               $1058,

//        key_wheelup =            $1800,
//        key_wheeldown =          $1801,

        key_unknown =            $ffff
        );
const
 key_modshift =                  $2000;  //ored for shortcut in taction
 key_modctrl =                   $4000;
 key_modshiftctrl =              $6000;
 key_modalt =                    $8000;
 key_modshiftalt =               $a000;
 misckeynames: array[key_escape..key_sysreq] of msestring =
  ('Escape','Tab','Backtab','Backspace','Return','Enter',
   'Insert','Delete','Pause','Print','SysReq');
 cursorkeynames: array[key_home..key_pagedown] of msestring =
  ('Home','End','Left','Up','Right','Down','PageUp','PageDown');
 shortmisckeynames: array[key_escape..key_sysreq] of msestring =
  ('Esc','Tab','Backtab','Back','Ret','Enter',
   'Ins','Del','Pause','Print','SysReq');
 shortcursorkeynames: array[key_home..key_pagedown] of msestring =
  ('Home','End','Left','Up','Right','Down','PgUp','PgDown');
type
 specialshortcutty = (sso_menu,sso_help);
const
 specialkeys: array[specialshortcutty] of keyty = (key_menu,key_help);
 specialkeynames: array[specialshortcutty] of msestring = ('Menu','Help');
 spacekeyname = 'Space';

function keytomsechar(key: keyty): msechar; //only 0..9, a..z

implementation

function keytomsechar(key: keyty): msechar;
begin
 if (key >= key_0) and (key <= key_9) then begin
  result:= msechar(ord(msechar('0')) + ord(key)-ord(key_0));
 end
 else begin
  if (key >= key_a) and (key <= key_z) then begin
   result:= msechar(ord(msechar('a')) + ord(key)-ord(key_a));
  end
  else begin
   result:= #0;
  end;
 end;
end;

end.



