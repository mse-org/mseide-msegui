{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
  * # CategoryScancode
  *
  * Defines keyboard scancodes.
  *
  * Please refer to the Best Keyboard Practices document for details on what
  * this information means and how best to use it.
  *
  * https://wiki.libsdl.org/SDL3/BestKeyboardPractices
  }

{** The SDL keyboard scancode representation.
 *
 * An SDL scancode is the physical representation of a key on the keyboard,
 * independent of language and keyboard mapping.
 *
 * Values of this type are used to represent keyboard keys, among other places
 * in the `scancode` field of the SDL_KeyboardEvent structure.
 *
 * The values in this enumeration are based on the USB usage page standard:
 * https://usb.org/sites/default/files/hut1_5.pdf
 *
 * \since This enum is available since SDL 3.2.0.
  }
type
  PPSDL_Scancode = ^PSDL_Scancode;
  PSDL_Scancode = ^TSDL_Scancode;
  TSDL_Scancode =  Integer;
const
  SDL_SCANCODE_UNKNOWN  = TSDL_Scancode(0);

  {*
     *  \name Usage page 0x07
     *
     *  These values are from usage page 0x07 (USB keyboard page).
      }

  SDL_SCANCODE_A  = TSDL_Scancode(4);
  SDL_SCANCODE_B  = TSDL_Scancode(5);
  SDL_SCANCODE_C  = TSDL_Scancode(6);
  SDL_SCANCODE_D  = TSDL_Scancode(7);
  SDL_SCANCODE_E  = TSDL_Scancode(8);
  SDL_SCANCODE_F  = TSDL_Scancode(9);
  SDL_SCANCODE_G  = TSDL_Scancode(10);
  SDL_SCANCODE_H  = TSDL_Scancode(11);
  SDL_SCANCODE_I  = TSDL_Scancode(12);
  SDL_SCANCODE_J  = TSDL_Scancode(13);
  SDL_SCANCODE_K  = TSDL_Scancode(14);
  SDL_SCANCODE_L  = TSDL_Scancode(15);
  SDL_SCANCODE_M  = TSDL_Scancode(16);
  SDL_SCANCODE_N  = TSDL_Scancode(17);
  SDL_SCANCODE_O  = TSDL_Scancode(18);
  SDL_SCANCODE_P  = TSDL_Scancode(19);
  SDL_SCANCODE_Q  = TSDL_Scancode(20);
  SDL_SCANCODE_R  = TSDL_Scancode(21);
  SDL_SCANCODE_S  = TSDL_Scancode(22);
  SDL_SCANCODE_T  = TSDL_Scancode(23);
  SDL_SCANCODE_U  = TSDL_Scancode(24);
  SDL_SCANCODE_V  = TSDL_Scancode(25);
  SDL_SCANCODE_W  = TSDL_Scancode(26);
  SDL_SCANCODE_X  = TSDL_Scancode(27);
  SDL_SCANCODE_Y  = TSDL_Scancode(28);
  SDL_SCANCODE_Z  = TSDL_Scancode(29);

  SDL_SCANCODE_1  = TSDL_Scancode(30);
  SDL_SCANCODE_2  = TSDL_Scancode(31);
  SDL_SCANCODE_3  = TSDL_Scancode(32);
  SDL_SCANCODE_4  = TSDL_Scancode(33);
  SDL_SCANCODE_5  = TSDL_Scancode(34);
  SDL_SCANCODE_6  = TSDL_Scancode(35);
  SDL_SCANCODE_7  = TSDL_Scancode(36);
  SDL_SCANCODE_8  = TSDL_Scancode(37);
  SDL_SCANCODE_9  = TSDL_Scancode(38);
  SDL_SCANCODE_0  = TSDL_Scancode(39);

  SDL_SCANCODE_RETURN  = TSDL_Scancode(40);
  SDL_SCANCODE_ESCAPE  = TSDL_Scancode(41);
  SDL_SCANCODE_BACKSPACE  = TSDL_Scancode(42);
  SDL_SCANCODE_TAB  = TSDL_Scancode(43);
  SDL_SCANCODE_SPACE  = TSDL_Scancode(44);

  SDL_SCANCODE_MINUS  = TSDL_Scancode(45);
  SDL_SCANCODE_EQUALS  = TSDL_Scancode(46);
  SDL_SCANCODE_LEFTBRACKET  = TSDL_Scancode(47);
  SDL_SCANCODE_RIGHTBRACKET  = TSDL_Scancode(48);
  SDL_SCANCODE_BACKSLASH  = TSDL_Scancode(49); {*< Located at the lower left of the return
                                                *   key on ISO keyboards and at the right end
                                                *   of the QWERTY row on ANSI keyboards.
                                                *   Produces REVERSE SOLIDUS (backslash) and
                                                *   VERTICAL LINE in a US layout, REVERSE
                                                *   SOLIDUS and VERTICAL LINE in a UK Mac
                                                *   layout, NUMBER SIGN and TILDE in a UK
                                                *   Windows layout, DOLLAR SIGN and POUND SIGN
                                                *   in a Swiss German layout, NUMBER SIGN and
                                                *   APOSTROPHE in a German layout, GRAVE
                                                *   ACCENT and POUND SIGN in a French Mac
                                                *   layout, and ASTERISK and MICRO SIGN in a
                                                *   French Windows layout.
                                                 }
  SDL_SCANCODE_NONUSHASH  = TSDL_Scancode(50); {*< ISO USB keyboards actually use this code
                                                *   instead of 49 for the same key, but all
                                                *   OSes I've seen treat the two codes
                                                *   identically. So, as an implementor, unless
                                                *   your keyboard generates both of those
                                                *   codes and your OS treats them differently,
                                                *   you should generate SDL_SCANCODE_BACKSLASH
                                                *   instead of this code. As a user, you
                                                *   should not rely on this code because SDL
                                                *   will never generate it with most (all?)
                                                *   keyboards.
                                                 }
  SDL_SCANCODE_SEMICOLON  = TSDL_Scancode(51);
  SDL_SCANCODE_APOSTROPHE  = TSDL_Scancode(52);
  SDL_SCANCODE_GRAVE  = TSDL_Scancode(53); {*< Located in the top left corner (on both ANSI
                                            *   and ISO keyboards). Produces GRAVE ACCENT and
                                            *   TILDE in a US Windows layout and in US and UK
                                            *   Mac layouts on ANSI keyboards, GRAVE ACCENT
                                            *   and NOT SIGN in a UK Windows layout, SECTION
                                            *   SIGN and PLUS-MINUS SIGN in US and UK Mac
                                            *   layouts on ISO keyboards, SECTION SIGN and
                                            *   DEGREE SIGN in a Swiss German layout (Mac:
                                            *   only on ISO keyboards), CIRCUMFLEX ACCENT and
                                            *   DEGREE SIGN in a German layout (Mac: only on
                                            *   ISO keyboards), SUPERSCRIPT TWO and TILDE in a
                                            *   French Windows layout, COMMERCIAL AT and
                                            *   NUMBER SIGN in a French Mac layout on ISO
                                            *   keyboards, and LESS-THAN SIGN and GREATER-THAN
                                            *   SIGN in a Swiss German, German, or French Mac
                                            *   layout on ANSI keyboards.
                                             }
  SDL_SCANCODE_COMMA  = TSDL_Scancode(54);
  SDL_SCANCODE_PERIOD  = TSDL_Scancode(55);
  SDL_SCANCODE_SLASH  = TSDL_Scancode(56);

  SDL_SCANCODE_CAPSLOCK  = TSDL_Scancode(57);

  SDL_SCANCODE_F1  = TSDL_Scancode(58);
  SDL_SCANCODE_F2  = TSDL_Scancode(59);
  SDL_SCANCODE_F3  = TSDL_Scancode(60);
  SDL_SCANCODE_F4  = TSDL_Scancode(61);
  SDL_SCANCODE_F5  = TSDL_Scancode(62);
  SDL_SCANCODE_F6  = TSDL_Scancode(63);
  SDL_SCANCODE_F7  = TSDL_Scancode(64);
  SDL_SCANCODE_F8  = TSDL_Scancode(65);
  SDL_SCANCODE_F9  = TSDL_Scancode(66);
  SDL_SCANCODE_F10  = TSDL_Scancode(67);
  SDL_SCANCODE_F11  = TSDL_Scancode(68);
  SDL_SCANCODE_F12  = TSDL_Scancode(69);

  SDL_SCANCODE_PRINTSCREEN  = TSDL_Scancode(70);
  SDL_SCANCODE_SCROLLLOCK  = TSDL_Scancode(71);
  SDL_SCANCODE_PAUSE  = TSDL_Scancode(72);
  SDL_SCANCODE_INSERT  = TSDL_Scancode(73); {*< insert on PC, help on some Mac keyboards (but
                                             does send code 73, not 117)  }
  SDL_SCANCODE_HOME  = TSDL_Scancode(74);
  SDL_SCANCODE_PAGEUP  = TSDL_Scancode(75);
  SDL_SCANCODE_DELETE  = TSDL_Scancode(76);
  SDL_SCANCODE_END  = TSDL_Scancode(77);
  SDL_SCANCODE_PAGEDOWN  = TSDL_Scancode(78);
  SDL_SCANCODE_RIGHT  = TSDL_Scancode(79);
  SDL_SCANCODE_LEFT  = TSDL_Scancode(80);
  SDL_SCANCODE_DOWN  = TSDL_Scancode(81);
  SDL_SCANCODE_UP  = TSDL_Scancode(82);

  SDL_SCANCODE_NUMLOCKCLEAR  = TSDL_Scancode(83); {*< num lock on PC, clear on Mac keyboards
                                                  }
  SDL_SCANCODE_KP_DIVIDE  = TSDL_Scancode(84);
  SDL_SCANCODE_KP_MULTIPLY  = TSDL_Scancode(85);
  SDL_SCANCODE_KP_MINUS  = TSDL_Scancode(86);
  SDL_SCANCODE_KP_PLUS  = TSDL_Scancode(87);
  SDL_SCANCODE_KP_ENTER  = TSDL_Scancode(88);
  SDL_SCANCODE_KP_1  = TSDL_Scancode(89);
  SDL_SCANCODE_KP_2  = TSDL_Scancode(90);
  SDL_SCANCODE_KP_3  = TSDL_Scancode(91);
  SDL_SCANCODE_KP_4  = TSDL_Scancode(92);
  SDL_SCANCODE_KP_5  = TSDL_Scancode(93);
  SDL_SCANCODE_KP_6  = TSDL_Scancode(94);
  SDL_SCANCODE_KP_7  = TSDL_Scancode(95);
  SDL_SCANCODE_KP_8  = TSDL_Scancode(96);
  SDL_SCANCODE_KP_9  = TSDL_Scancode(97);
  SDL_SCANCODE_KP_0  = TSDL_Scancode(98);
  SDL_SCANCODE_KP_PERIOD  = TSDL_Scancode(99);

  SDL_SCANCODE_NONUSBACKSLASH  = TSDL_Scancode(100); {*< This is the additional key that ISO
                                                      *   keyboards have over ANSI ones,
                                                      *   located between left shift and Z.
                                                      *   Produces GRAVE ACCENT and TILDE in a
                                                      *   US or UK Mac layout, REVERSE SOLIDUS
                                                      *   (backslash) and VERTICAL LINE in a
                                                      *   US or UK Windows layout, and
                                                      *   LESS-THAN SIGN and GREATER-THAN SIGN
                                                      *   in a Swiss German, German, or French
                                                      *   layout.  }
  SDL_SCANCODE_APPLICATION  = TSDL_Scancode(101); {*< windows contextual menu, compose  }
  SDL_SCANCODE_POWER  = TSDL_Scancode(102); {*< The USB document says this is a status flag,
                                             *   not a physical key - but some Mac keyboards
                                             *   do have a power key.  }
  SDL_SCANCODE_KP_EQUALS  = TSDL_Scancode(103);
  SDL_SCANCODE_F13  = TSDL_Scancode(104);
  SDL_SCANCODE_F14  = TSDL_Scancode(105);
  SDL_SCANCODE_F15  = TSDL_Scancode(106);
  SDL_SCANCODE_F16  = TSDL_Scancode(107);
  SDL_SCANCODE_F17  = TSDL_Scancode(108);
  SDL_SCANCODE_F18  = TSDL_Scancode(109);
  SDL_SCANCODE_F19  = TSDL_Scancode(110);
  SDL_SCANCODE_F20  = TSDL_Scancode(111);
  SDL_SCANCODE_F21  = TSDL_Scancode(112);
  SDL_SCANCODE_F22  = TSDL_Scancode(113);
  SDL_SCANCODE_F23  = TSDL_Scancode(114);
  SDL_SCANCODE_F24  = TSDL_Scancode(115);
  SDL_SCANCODE_EXECUTE  = TSDL_Scancode(116);
  SDL_SCANCODE_HELP  = TSDL_Scancode(117);   {*< AL Integrated Help Center  }
  SDL_SCANCODE_MENU  = TSDL_Scancode(118);   {*< Menu (show menu)  }
  SDL_SCANCODE_SELECT  = TSDL_Scancode(119);
  SDL_SCANCODE_STOP  = TSDL_Scancode(120);   {*< AC Stop  }
  SDL_SCANCODE_AGAIN  = TSDL_Scancode(121);  {*< AC Redo/Repeat  }
  SDL_SCANCODE_UNDO  = TSDL_Scancode(122);   {*< AC Undo  }
  SDL_SCANCODE_CUT  = TSDL_Scancode(123);    {*< AC Cut  }
  SDL_SCANCODE_COPY  = TSDL_Scancode(124);   {*< AC Copy  }
  SDL_SCANCODE_PASTE  = TSDL_Scancode(125);  {*< AC Paste  }
  SDL_SCANCODE_FIND  = TSDL_Scancode(126);   {*< AC Find  }
  SDL_SCANCODE_MUTE  = TSDL_Scancode(127);
  SDL_SCANCODE_VOLUMEUP  = TSDL_Scancode(128);
  SDL_SCANCODE_VOLUMEDOWN  = TSDL_Scancode(129);
{ not sure whether there's a reason to enable these  }
{     SDL_SCANCODE_LOCKINGCAPSLOCK = 130,   }
{     SDL_SCANCODE_LOCKINGNUMLOCK = 131,  }
{     SDL_SCANCODE_LOCKINGSCROLLLOCK = 132,  }
  SDL_SCANCODE_KP_COMMA  = TSDL_Scancode(133);
  SDL_SCANCODE_KP_EQUALSAS400  = TSDL_Scancode(134);

  SDL_SCANCODE_INTERNATIONAL1  = TSDL_Scancode(135); {*< used on Asian keyboards, see
                                                      footnotes in USB doc  }
  SDL_SCANCODE_INTERNATIONAL2  = TSDL_Scancode(136);
  SDL_SCANCODE_INTERNATIONAL3  = TSDL_Scancode(137); {*< Yen  }
  SDL_SCANCODE_INTERNATIONAL4  = TSDL_Scancode(138);
  SDL_SCANCODE_INTERNATIONAL5  = TSDL_Scancode(139);
  SDL_SCANCODE_INTERNATIONAL6  = TSDL_Scancode(140);
  SDL_SCANCODE_INTERNATIONAL7  = TSDL_Scancode(141);
  SDL_SCANCODE_INTERNATIONAL8  = TSDL_Scancode(142);
  SDL_SCANCODE_INTERNATIONAL9  = TSDL_Scancode(143);
  SDL_SCANCODE_LANG1  = TSDL_Scancode(144);       {*< Hangul/English toggle  }
  SDL_SCANCODE_LANG2  = TSDL_Scancode(145);       {*< Hanja conversion  }
  SDL_SCANCODE_LANG3  = TSDL_Scancode(146);       {*< Katakana  }
  SDL_SCANCODE_LANG4  = TSDL_Scancode(147);       {*< Hiragana  }
  SDL_SCANCODE_LANG5  = TSDL_Scancode(148);       {*< Zenkaku/Hankaku  }
  SDL_SCANCODE_LANG6  = TSDL_Scancode(149);       {*< reserved  }
  SDL_SCANCODE_LANG7  = TSDL_Scancode(150);       {*< reserved  }
  SDL_SCANCODE_LANG8  = TSDL_Scancode(151);       {*< reserved  }
  SDL_SCANCODE_LANG9  = TSDL_Scancode(152);       {*< reserved  }

  SDL_SCANCODE_ALTERASE  = TSDL_Scancode(153);    {*< Erase-Eaze  }
  SDL_SCANCODE_SYSREQ  = TSDL_Scancode(154);
  SDL_SCANCODE_CANCEL  = TSDL_Scancode(155);      {*< AC Cancel  }
  SDL_SCANCODE_CLEAR  = TSDL_Scancode(156);
  SDL_SCANCODE_PRIOR  = TSDL_Scancode(157);
  SDL_SCANCODE_RETURN2  = TSDL_Scancode(158);
  SDL_SCANCODE_SEPARATOR  = TSDL_Scancode(159);
  SDL_SCANCODE_OUT  = TSDL_Scancode(160);
  SDL_SCANCODE_OPER  = TSDL_Scancode(161);
  SDL_SCANCODE_CLEARAGAIN  = TSDL_Scancode(162);
  SDL_SCANCODE_CRSEL  = TSDL_Scancode(163);
  SDL_SCANCODE_EXSEL  = TSDL_Scancode(164);

  SDL_SCANCODE_KP_00  = TSDL_Scancode(176);
  SDL_SCANCODE_KP_000  = TSDL_Scancode(177);
  SDL_SCANCODE_THOUSANDSSEPARATOR  = TSDL_Scancode(178);
  SDL_SCANCODE_DECIMALSEPARATOR  = TSDL_Scancode(179);
  SDL_SCANCODE_CURRENCYUNIT  = TSDL_Scancode(180);
  SDL_SCANCODE_CURRENCYSUBUNIT  = TSDL_Scancode(181);
  SDL_SCANCODE_KP_LEFTPAREN  = TSDL_Scancode(182);
  SDL_SCANCODE_KP_RIGHTPAREN  = TSDL_Scancode(183);
  SDL_SCANCODE_KP_LEFTBRACE  = TSDL_Scancode(184);
  SDL_SCANCODE_KP_RIGHTBRACE  = TSDL_Scancode(185);
  SDL_SCANCODE_KP_TAB  = TSDL_Scancode(186);
  SDL_SCANCODE_KP_BACKSPACE  = TSDL_Scancode(187);
  SDL_SCANCODE_KP_A  = TSDL_Scancode(188);
  SDL_SCANCODE_KP_B  = TSDL_Scancode(189);
  SDL_SCANCODE_KP_C  = TSDL_Scancode(190);
  SDL_SCANCODE_KP_D  = TSDL_Scancode(191);
  SDL_SCANCODE_KP_E  = TSDL_Scancode(192);
  SDL_SCANCODE_KP_F  = TSDL_Scancode(193);
  SDL_SCANCODE_KP_XOR  = TSDL_Scancode(194);
  SDL_SCANCODE_KP_POWER  = TSDL_Scancode(195);
  SDL_SCANCODE_KP_PERCENT  = TSDL_Scancode(196);
  SDL_SCANCODE_KP_LESS  = TSDL_Scancode(197);
  SDL_SCANCODE_KP_GREATER  = TSDL_Scancode(198);
  SDL_SCANCODE_KP_AMPERSAND  = TSDL_Scancode(199);
  SDL_SCANCODE_KP_DBLAMPERSAND  = TSDL_Scancode(200);
  SDL_SCANCODE_KP_VERTICALBAR  = TSDL_Scancode(201);
  SDL_SCANCODE_KP_DBLVERTICALBAR  = TSDL_Scancode(202);
  SDL_SCANCODE_KP_COLON  = TSDL_Scancode(203);
  SDL_SCANCODE_KP_HASH  = TSDL_Scancode(204);
  SDL_SCANCODE_KP_SPACE  = TSDL_Scancode(205);
  SDL_SCANCODE_KP_AT  = TSDL_Scancode(206);
  SDL_SCANCODE_KP_EXCLAM  = TSDL_Scancode(207);
  SDL_SCANCODE_KP_MEMSTORE  = TSDL_Scancode(208);
  SDL_SCANCODE_KP_MEMRECALL  = TSDL_Scancode(209);
  SDL_SCANCODE_KP_MEMCLEAR  = TSDL_Scancode(210);
  SDL_SCANCODE_KP_MEMADD  = TSDL_Scancode(211);
  SDL_SCANCODE_KP_MEMSUBTRACT  = TSDL_Scancode(212);
  SDL_SCANCODE_KP_MEMMULTIPLY  = TSDL_Scancode(213);
  SDL_SCANCODE_KP_MEMDIVIDE  = TSDL_Scancode(214);
  SDL_SCANCODE_KP_PLUSMINUS  = TSDL_Scancode(215);
  SDL_SCANCODE_KP_CLEAR  = TSDL_Scancode(216);
  SDL_SCANCODE_KP_CLEARENTRY  = TSDL_Scancode(217);
  SDL_SCANCODE_KP_BINARY  = TSDL_Scancode(218);
  SDL_SCANCODE_KP_OCTAL  = TSDL_Scancode(219);
  SDL_SCANCODE_KP_DECIMAL  = TSDL_Scancode(220);
  SDL_SCANCODE_KP_HEXADECIMAL  = TSDL_Scancode(221);

  SDL_SCANCODE_LCTRL  = TSDL_Scancode(224);
  SDL_SCANCODE_LSHIFT  = TSDL_Scancode(225);
  SDL_SCANCODE_LALT  = TSDL_Scancode(226);    {*< alt, option  }
  SDL_SCANCODE_LGUI  = TSDL_Scancode(227);    {*< windows, command (apple), meta  }
  SDL_SCANCODE_RCTRL  = TSDL_Scancode(228);
  SDL_SCANCODE_RSHIFT  = TSDL_Scancode(229);
  SDL_SCANCODE_RALT  = TSDL_Scancode(230);    {*< alt gr, option  }
  SDL_SCANCODE_RGUI  = TSDL_Scancode(231);    {*< windows, command (apple), meta  }

  SDL_SCANCODE_MODE  = TSDL_Scancode(257); {*< I'm not sure if this is really not covered
                                            *   by any of the above, but since there's a
                                            *   special SDL_KMOD_MODE for it I'm adding it here
                                             }

  { Usage page 0x07  }

  {*
   *  \name Usage page 0x0C
   *
   *  These values are mapped from usage page 0x0C (USB consumer page).
   *
   *  There are way more keys in the spec than we can represent in the
   *  current scancode range, so pick the ones that commonly come up in
   *  real world usage.
    }

  SDL_SCANCODE_SLEEP  = TSDL_Scancode(258);                {*< Sleep  }
  SDL_SCANCODE_WAKE  = TSDL_Scancode(259);                 {*< Wake  }

  SDL_SCANCODE_CHANNEL_INCREMENT  = TSDL_Scancode(260);    {*< Channel Increment  }
  SDL_SCANCODE_CHANNEL_DECREMENT  = TSDL_Scancode(261);    {*< Channel Decrement  }

  SDL_SCANCODE_MEDIA_PLAY  = TSDL_Scancode(262);           {*< Play  }
  SDL_SCANCODE_MEDIA_PAUSE  = TSDL_Scancode(263);          {*< Pause  }
  SDL_SCANCODE_MEDIA_RECORD  = TSDL_Scancode(264);         {*< Record  }
  SDL_SCANCODE_MEDIA_FAST_FORWARD  = TSDL_Scancode(265);   {*< Fast Forward  }
  SDL_SCANCODE_MEDIA_REWIND  = TSDL_Scancode(266);         {*< Rewind  }
  SDL_SCANCODE_MEDIA_NEXT_TRACK  = TSDL_Scancode(267);     {*< Next Track  }
  SDL_SCANCODE_MEDIA_PREVIOUS_TRACK  = TSDL_Scancode(268); {*< Previous Track  }
  SDL_SCANCODE_MEDIA_STOP  = TSDL_Scancode(269);           {*< Stop  }
  SDL_SCANCODE_MEDIA_EJECT  = TSDL_Scancode(270);          {*< Eject  }
  SDL_SCANCODE_MEDIA_PLAY_PAUSE  = TSDL_Scancode(271);     {*< Play / Pause  }
  SDL_SCANCODE_MEDIA_SELECT  = TSDL_Scancode(272);         { Media Select  }

  SDL_SCANCODE_AC_NEW  = TSDL_Scancode(273);               {*< AC New  }
  SDL_SCANCODE_AC_OPEN  = TSDL_Scancode(274);              {*< AC Open  }
  SDL_SCANCODE_AC_CLOSE  = TSDL_Scancode(275);             {*< AC Close  }
  SDL_SCANCODE_AC_EXIT  = TSDL_Scancode(276);              {*< AC Exit  }
  SDL_SCANCODE_AC_SAVE  = TSDL_Scancode(277);              {*< AC Save  }
  SDL_SCANCODE_AC_PRINT  = TSDL_Scancode(278);             {*< AC Print  }
  SDL_SCANCODE_AC_PROPERTIES  = TSDL_Scancode(279);        {*< AC Properties  }

  SDL_SCANCODE_AC_SEARCH  = TSDL_Scancode(280);            {*< AC Search  }
  SDL_SCANCODE_AC_HOME  = TSDL_Scancode(281);              {*< AC Home  }
  SDL_SCANCODE_AC_BACK  = TSDL_Scancode(282);              {*< AC Back  }
  SDL_SCANCODE_AC_FORWARD  = TSDL_Scancode(283);           {*< AC Forward  }
  SDL_SCANCODE_AC_STOP  = TSDL_Scancode(284);              {*< AC Stop  }
  SDL_SCANCODE_AC_REFRESH  = TSDL_Scancode(285);           {*< AC Refresh  }
  SDL_SCANCODE_AC_BOOKMARKS  = TSDL_Scancode(286);         {*< AC Bookmarks  }

  { Usage page 0x0C  }

  {*
   *  \name Mobile keys
   *
   *  These are values that are often used on mobile phones.
    }

  SDL_SCANCODE_SOFTLEFT  = TSDL_Scancode(287);   {*< Usually situated below the display on phones and
                                                     used as a multi-function feature key for selecting
                                                     a software defined function shown on the bottom left
                                                     of the display.  }
  SDL_SCANCODE_SOFTRIGHT  = TSDL_Scancode(288);  {*< Usually situated below the display on phones and
                                                     used as a multi-function feature key for selecting
                                                     a software defined function shown on the bottom right
                                                     of the display.  }
  SDL_SCANCODE_CALL  = TSDL_Scancode(289);       {*< Used for accepting phone calls.  }
  SDL_SCANCODE_ENDCALL  = TSDL_Scancode(290);    {*< Used for rejecting phone calls.  }

  { Mobile keys  }

  { Add any other keys here.  }

  SDL_SCANCODE_RESERVED  = TSDL_Scancode(400); {*< 400-500 reserved for dynamic keycodes  }

  SDL_SCANCODE_COUNT  = TSDL_Scancode(512);    {*< not a key, just marks the number of scancodes for array bounds  }

