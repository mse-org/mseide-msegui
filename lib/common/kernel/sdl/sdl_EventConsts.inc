const
    SDL_SCANCODE_UNKNOWN = 0;

    {*
     *  \name Usage page 0x07
     *
     *  These values are from usage page 0x07 (USB keyboard page).
     }
    {@}

    SDL_SCANCODE_A = 4;
    SDL_SCANCODE_B = 5;
    SDL_SCANCODE_C = 6;
    SDL_SCANCODE_D = 7;
    SDL_SCANCODE_E = 8;
    SDL_SCANCODE_F = 9;
    SDL_SCANCODE_G = 10;
    SDL_SCANCODE_H = 11;
    SDL_SCANCODE_I = 12;
    SDL_SCANCODE_J = 13;
    SDL_SCANCODE_K = 14;
    SDL_SCANCODE_L = 15;
    SDL_SCANCODE_M = 16;
    SDL_SCANCODE_N = 17;
    SDL_SCANCODE_O = 18;
    SDL_SCANCODE_P = 19;
    SDL_SCANCODE_Q = 20;
    SDL_SCANCODE_R = 21;
    SDL_SCANCODE_S = 22;
    SDL_SCANCODE_T = 23;
    SDL_SCANCODE_U = 24;
    SDL_SCANCODE_V = 25;
    SDL_SCANCODE_W = 26;
    SDL_SCANCODE_X = 27;
    SDL_SCANCODE_Y = 28;
    SDL_SCANCODE_Z = 29;

    SDL_SCANCODE_1 = 30;
    SDL_SCANCODE_2 = 31;
    SDL_SCANCODE_3 = 32;
    SDL_SCANCODE_4 = 33;
    SDL_SCANCODE_5 = 34;
    SDL_SCANCODE_6 = 35;
    SDL_SCANCODE_7 = 36;
    SDL_SCANCODE_8 = 37;
    SDL_SCANCODE_9 = 38;
    SDL_SCANCODE_0 = 39;

    SDL_SCANCODE_RETURN = 40;
    SDL_SCANCODE_ESCAPE = 41;
    SDL_SCANCODE_BACKSPACE = 42;
    SDL_SCANCODE_TAB = 43;
    SDL_SCANCODE_SPACE = 44;

    SDL_SCANCODE_MINUS = 45;
    SDL_SCANCODE_EQUALS = 46;
    SDL_SCANCODE_LEFTBRACKET = 47;
    SDL_SCANCODE_RIGHTBRACKET = 48;
    SDL_SCANCODE_BACKSLASH = 49;{*< Located at the lower left of the return
                                  *   key on ISO keyboards and at the right end
                                  *   of the QWERTY row on ANSI keyboards.
                                  *   Produces REVERSE SOLIDUS (backslash) and
                                  *   VERTICAL LINE in a US layout;REVERSE
                                  *   SOLIDUS and VERTICAL LINE in a UK Mac
                                  *   layout;NUMBER SIGN and TILDE in a UK
                                  *   Windows layout;DOLLAR SIGN and POUND SIGN
                                  *   in a Swiss German layout;NUMBER SIGN and
                                  *   APOSTROPHE in a German layout;GRAVE
                                  *   ACCENT and POUND SIGN in a French Mac
                                  *   layout;and ASTERISK and MICRO SIGN in a
                                  *   French Windows layout.
                                  }
    SDL_SCANCODE_NONUSHASH = 50;{*< ISO USB keyboards actually use this code
                                  *   instead of 49 for the same key;but all
                                  *   OSes I've seen treat the two codes
                                  *   identically. So;as an implementor;unless
                                  *   your keyboard generates both of those
                                  *   codes and your OS treats them differently;
                                  *   you should generate SDL_SCANCODE_BACKSLASH
                                  *   instead of this code. As a user;you
                                  *   should not rely on this code because SDL
                                  *   will never generate it with most (all?)
                                  *   keyboards.
                                  }
    SDL_SCANCODE_SEMICOLON = 51;
    SDL_SCANCODE_APOSTROPHE = 52;
    SDL_SCANCODE_GRAVE = 53;{*< Located in the top left corner (on both ANSI
                              *   and ISO keyboards). Produces GRAVE ACCENT and
                              *   TILDE in a US Windows layout and in US and UK
                              *   Mac layouts on ANSI keyboards;GRAVE ACCENT
                              *   and NOT SIGN in a UK Windows layout;SECTION
                              *   SIGN and PLUS-MINUS SIGN in US and UK Mac
                              *   layouts on ISO keyboards;SECTION SIGN and
                              *   DEGREE SIGN in a Swiss German layout (Mac:
                              *   only on ISO keyboards);CIRCUMFLEX ACCENT and
                              *   DEGREE SIGN in a German layout (Mac: only on
                              *   ISO keyboards);SUPERSCRIPT TWO and TILDE in a
                              *   French Windows layout;COMMERCIAL AT and
                              *   NUMBER SIGN in a French Mac layout on ISO
                              *   keyboards;and LESS-THAN SIGN and GREATER-THAN
                              *   SIGN in a Swiss German;German;or French Mac
                              *   layout on ANSI keyboards.
                              }
    SDL_SCANCODE_COMMA = 54;
    SDL_SCANCODE_PERIOD = 55;
    SDL_SCANCODE_SLASH = 56;

    SDL_SCANCODE_CAPSLOCK = 57;

    SDL_SCANCODE_F1 = 58;
    SDL_SCANCODE_F2 = 59;
    SDL_SCANCODE_F3 = 60;
    SDL_SCANCODE_F4 = 61;
    SDL_SCANCODE_F5 = 62;
    SDL_SCANCODE_F6 = 63;
    SDL_SCANCODE_F7 = 64;
    SDL_SCANCODE_F8 = 65;
    SDL_SCANCODE_F9 = 66;
    SDL_SCANCODE_F10 = 67;
    SDL_SCANCODE_F11 = 68;
    SDL_SCANCODE_F12 = 69;

    SDL_SCANCODE_PRINTSCREEN = 70;
    SDL_SCANCODE_SCROLLLOCK = 71;
    SDL_SCANCODE_PAUSE = 72;
    SDL_SCANCODE_INSERT = 73;{*< insert on PC;help on some Mac keyboards (but
                                   does send code 73;not 117) }
    SDL_SCANCODE_HOME = 74;
    SDL_SCANCODE_PAGEUP = 75;
    SDL_SCANCODE_DELETE = 76;
    SDL_SCANCODE_END = 77;
    SDL_SCANCODE_PAGEDOWN = 78;
    SDL_SCANCODE_RIGHT = 79;
    SDL_SCANCODE_LEFT = 80;
    SDL_SCANCODE_DOWN = 81;
    SDL_SCANCODE_UP = 82;

    SDL_SCANCODE_NUMLOCKCLEAR = 83;{*< num lock on PC;clear on Mac keyboards
                                     }
    SDL_SCANCODE_KP_DIVIDE = 84;
    SDL_SCANCODE_KP_MULTIPLY = 85;
    SDL_SCANCODE_KP_MINUS = 86;
    SDL_SCANCODE_KP_PLUS = 87;
    SDL_SCANCODE_KP_ENTER = 88;
    SDL_SCANCODE_KP_1 = 89;
    SDL_SCANCODE_KP_2 = 90;
    SDL_SCANCODE_KP_3 = 91;
    SDL_SCANCODE_KP_4 = 92;
    SDL_SCANCODE_KP_5 = 93;
    SDL_SCANCODE_KP_6 = 94;
    SDL_SCANCODE_KP_7 = 95;
    SDL_SCANCODE_KP_8 = 96;
    SDL_SCANCODE_KP_9 = 97;
    SDL_SCANCODE_KP_0 = 98;
    SDL_SCANCODE_KP_PERIOD = 99;

    SDL_SCANCODE_NONUSBACKSLASH = 100;{*< This is the additional key that ISO
                                        *   keyboards have over ANSI ones;
                                        *   located between left shift and Y.
                                        *   Produces GRAVE ACCENT and TILDE in a
                                        *   US or UK Mac layout;REVERSE SOLIDUS
                                        *   (backslash) and VERTICAL LINE in a
                                        *   US or UK Windows layout;and
                                        *   LESS-THAN SIGN and GREATER-THAN SIGN
                                        *   in a Swiss German;German;or French
                                        *   layout. }
    SDL_SCANCODE_APPLICATION = 101;{*< windows contextual menu;compose }
    SDL_SCANCODE_POWER = 102;{*< The USB document says this is a status flag;
                               *   not a physical key - but some Mac keyboards
                               *   do have a power key. }
    SDL_SCANCODE_KP_EQUALS = 103;
    SDL_SCANCODE_F13 = 104;
    SDL_SCANCODE_F14 = 105;
    SDL_SCANCODE_F15 = 106;
    SDL_SCANCODE_F16 = 107;
    SDL_SCANCODE_F17 = 108;
    SDL_SCANCODE_F18 = 109;
    SDL_SCANCODE_F19 = 110;
    SDL_SCANCODE_F20 = 111;
    SDL_SCANCODE_F21 = 112;
    SDL_SCANCODE_F22 = 113;
    SDL_SCANCODE_F23 = 114;
    SDL_SCANCODE_F24 = 115;
    SDL_SCANCODE_EXECUTE = 116;
    SDL_SCANCODE_HELP = 117;
    SDL_SCANCODE_MENU = 118;
    SDL_SCANCODE_SELECT = 119;
    SDL_SCANCODE_STOP = 120;
    SDL_SCANCODE_AGAIN = 121;  {*< redo }
    SDL_SCANCODE_UNDO = 122;
    SDL_SCANCODE_CUT = 123;
    SDL_SCANCODE_COPY = 124;
    SDL_SCANCODE_PASTE = 125;
    SDL_SCANCODE_FIND = 126;
    SDL_SCANCODE_MUTE = 127;
    SDL_SCANCODE_VOLUMEUP = 128;
    SDL_SCANCODE_VOLUMEDOWN = 129;
{ not sure whether there's a reason to enable these }
{     SDL_SCANCODE_LOCKINGCAPSLOCK = 130; }
{     SDL_SCANCODE_LOCKINGNUMLOCK = 131;}
{     SDL_SCANCODE_LOCKINGSCROLLLOCK = 132;}
    SDL_SCANCODE_KP_COMMA = 133;
    SDL_SCANCODE_KP_EQUALSAS400 = 134;

    SDL_SCANCODE_INTERNATIONAL1 = 135;{*< used on Asian keyboards;see
                                            footnotes in USB doc }
    SDL_SCANCODE_INTERNATIONAL2 = 136;
    SDL_SCANCODE_INTERNATIONAL3 = 137;{*< Yen }
    SDL_SCANCODE_INTERNATIONAL4 = 138;
    SDL_SCANCODE_INTERNATIONAL5 = 139;
    SDL_SCANCODE_INTERNATIONAL6 = 140;
    SDL_SCANCODE_INTERNATIONAL7 = 141;
    SDL_SCANCODE_INTERNATIONAL8 = 142;
    SDL_SCANCODE_INTERNATIONAL9 = 143;
    SDL_SCANCODE_LANG1 = 144;{*< Hangul/English toggle }
    SDL_SCANCODE_LANG2 = 145;{*< Hanja conversion }
    SDL_SCANCODE_LANG3 = 146;{*< Katakana }
    SDL_SCANCODE_LANG4 = 147;{*< Hiragana }
    SDL_SCANCODE_LANG5 = 148;{*< Zenkaku/Hankaku }
    SDL_SCANCODE_LANG6 = 149;{*< reserved }
    SDL_SCANCODE_LANG7 = 150;{*< reserved }
    SDL_SCANCODE_LANG8 = 151;{*< reserved }
    SDL_SCANCODE_LANG9 = 152;{*< reserved }

    SDL_SCANCODE_ALTERASE = 153;{*< Erase-Eaze }
    SDL_SCANCODE_SYSREQ = 154;
    SDL_SCANCODE_CANCEL = 155;
    SDL_SCANCODE_CLEAR = 156;
    SDL_SCANCODE_PRIOR = 157;
    SDL_SCANCODE_RETURN2 = 158;
    SDL_SCANCODE_SEPARATOR = 159;
    SDL_SCANCODE_OUT = 160;
    SDL_SCANCODE_OPER = 161;
    SDL_SCANCODE_CLEARAGAIN = 162;
    SDL_SCANCODE_CRSEL = 163;
    SDL_SCANCODE_EXSEL = 164;

    SDL_SCANCODE_KP_00 = 176;
    SDL_SCANCODE_KP_000 = 177;
    SDL_SCANCODE_THOUSANDSSEPARATOR = 178;
    SDL_SCANCODE_DECIMALSEPARATOR = 179;
    SDL_SCANCODE_CURRENCYUNIT = 180;
    SDL_SCANCODE_CURRENCYSUBUNIT = 181;
    SDL_SCANCODE_KP_LEFTPAREN = 182;
    SDL_SCANCODE_KP_RIGHTPAREN = 183;
    SDL_SCANCODE_KP_LEFTBRACE = 184;
    SDL_SCANCODE_KP_RIGHTBRACE = 185;
    SDL_SCANCODE_KP_TAB = 186;
    SDL_SCANCODE_KP_BACKSPACE = 187;
    SDL_SCANCODE_KP_A = 188;
    SDL_SCANCODE_KP_B = 189;
    SDL_SCANCODE_KP_C = 190;
    SDL_SCANCODE_KP_D = 191;
    SDL_SCANCODE_KP_E = 192;
    SDL_SCANCODE_KP_F = 193;
    SDL_SCANCODE_KP_XOR = 194;
    SDL_SCANCODE_KP_POWER = 195;
    SDL_SCANCODE_KP_PERCENT = 196;
    SDL_SCANCODE_KP_LESS = 197;
    SDL_SCANCODE_KP_GREATER = 198;
    SDL_SCANCODE_KP_AMPERSAND = 199;
    SDL_SCANCODE_KP_DBLAMPERSAND = 200;
    SDL_SCANCODE_KP_VERTICALBAR = 201;
    SDL_SCANCODE_KP_DBLVERTICALBAR = 202;
    SDL_SCANCODE_KP_COLON = 203;
    SDL_SCANCODE_KP_HASH = 204;
    SDL_SCANCODE_KP_SPACE = 205;
    SDL_SCANCODE_KP_AT = 206;
    SDL_SCANCODE_KP_EXCLAM = 207;
    SDL_SCANCODE_KP_MEMSTORE = 208;
    SDL_SCANCODE_KP_MEMRECALL = 209;
    SDL_SCANCODE_KP_MEMCLEAR = 210;
    SDL_SCANCODE_KP_MEMADD = 211;
    SDL_SCANCODE_KP_MEMSUBTRACT = 212;
    SDL_SCANCODE_KP_MEMMULTIPLY = 213;
    SDL_SCANCODE_KP_MEMDIVIDE = 214;
    SDL_SCANCODE_KP_PLUSMINUS = 215;
    SDL_SCANCODE_KP_CLEAR = 216;
    SDL_SCANCODE_KP_CLEARENTRY = 217;
    SDL_SCANCODE_KP_BINARY = 218;
    SDL_SCANCODE_KP_OCTAL = 219;
    SDL_SCANCODE_KP_DECIMAL = 220;
    SDL_SCANCODE_KP_HEXADECIMAL = 221;

    SDL_SCANCODE_LCTRL = 224;
    SDL_SCANCODE_LSHIFT = 225;
    SDL_SCANCODE_LALT = 226;{*< alt;option }
    SDL_SCANCODE_LGUI = 227;{*< windows;command (apple);meta }
    SDL_SCANCODE_RCTRL = 228;
    SDL_SCANCODE_RSHIFT = 229;
    SDL_SCANCODE_RALT = 230;{*< alt gr;option }
    SDL_SCANCODE_RGUI = 231;{*< windows;command (apple);meta }

    SDL_SCANCODE_MODE = 257;   {*< I'm not sure if this is really not covered
                                 *   by any of the above;but since there's a
                                 *   special KMOD_MODE for it I'm adding it here
                                 }

    {@}{Usage page 0x07}

    {*
     *  \name Usage page 0x0C
     *
     *  These values are mapped from usage page 0x0C (USB consumer page).
     }
    {@}

    SDL_SCANCODE_AUDIONEXT = 258;
    SDL_SCANCODE_AUDIOPREV = 259;
    SDL_SCANCODE_AUDIOSTOP = 260;
    SDL_SCANCODE_AUDIOPLAY = 261;
    SDL_SCANCODE_AUDIOMUTE = 262;
    SDL_SCANCODE_MEDIASELECT = 263;
    SDL_SCANCODE_WWW = 264;
    SDL_SCANCODE_MAIL = 265;
    SDL_SCANCODE_CALCULATOR = 266;
    SDL_SCANCODE_COMPUTER = 267;
    SDL_SCANCODE_AC_SEARCH = 268;
    SDL_SCANCODE_AC_HOME = 269;
    SDL_SCANCODE_AC_BACK = 270;
    SDL_SCANCODE_AC_FORWARD = 271;
    SDL_SCANCODE_AC_STOP = 272;
    SDL_SCANCODE_AC_REFRESH = 273;
    SDL_SCANCODE_AC_BOOKMARKS = 274;


    SDL_SCANCODE_BRIGHTNESSDOWN = 275;
    SDL_SCANCODE_BRIGHTNESSUP = 276;
    SDL_SCANCODE_DISPLAYSWITCH = 277;{*< display mirroring/dual display
                                           switch;video mode switch }
    SDL_SCANCODE_KBDILLUMTOGGLE = 278;
    SDL_SCANCODE_KBDILLUMDOWN = 279;
    SDL_SCANCODE_KBDILLUMUP = 280;
    SDL_SCANCODE_EJECT = 281;
    SDL_SCANCODE_SLEEP = 282;


    { Add any other keys here. }

    SDL_NUM_SCANCODES = 512; {*< not a key;just marks the number of scancodes
                                 for array bounds }

const
    SDL_FIRSTEVENT     = 0;     //*< Unused (do not remove) */

    // Application events */
    SDL_QUITEV           = $100; //*< User-requested quit */

    // Window events */
    SDL_WINDOWEVENT    = $200; //*< Window state change */
    SDL_SYSWMEVENT     = $201;             //*< System specific event */

    // Keyboard events */
    SDL_KEYDOWN        = $300; //*< Key pressed */
    SDL_KEYUP = $301;                  //*< Key released */
    SDL_TEXTEDITING = $302;            //*< Keyboard text editing (composition) */
    SDL_TEXTINPUT = $303;              //*< Keyboard text input */

    // Mouse events */
    SDL_MOUSEMOTION    = $400; //*< Mouse moved */
    SDL_MOUSEBUTTONDOWN = $401;        //*< Mouse button pressed */
    SDL_MOUSEBUTTONUP = $402;          //*< Mouse button released */
    SDL_MOUSEWHEEL = $403;             //*< Mouse wheel motion */

    // Tablet or multiple mice input device events */
    SDL_INPUTMOTION    = $500; //*< Input moved */
    SDL_INPUTBUTTONDOWN = $501;        //*< Input button pressed */
    SDL_INPUTBUTTONUP = $502;          //*< Input button released */
    SDL_INPUTWHEEL = $503;             //*< Input wheel motion */
    SDL_INPUTPROXIMITYIN = $504;       //*< Input pen entered proximity */
    SDL_INPUTPROXIMITYOUT = $505;      //*< Input pen left proximity */

    // Joystick events */
    SDL_JOYAXISMOTION  = $600; //*< Joystick axis motion */
    SDL_JOYBALLMOTION  = $601;          //*< Joystick trackball motion */
    SDL_JOYHATMOTION  = $602;           //*< Joystick hat position change */
    SDL_JOYBUTTONDOWN  = $603;          //*< Joystick button pressed */
    SDL_JOYBUTTONUP  = $604;            //*< Joystick button released */

    // Touch events */
    SDL_FINGERDOWN      = $700;
    SDL_FINGERUP   = $701;
    SDL_FINGERMOTION   = $702;
    SDL_TOUCHBUTTONDOWN   = $703;
    SDL_TOUCHBUTTONUP   = $7004;    

    // Gesture events */
    SDL_DOLLARGESTURE   = $800;
    SDL_DOLLARRECORD   = $801;
    SDL_MULTIGESTURE   = $802;

    // Clipboard events */
    SDL_CLIPBOARDUPDATE = $900; //*< The clipboard changed */

    // Drag and drop events */
    SDL_DROPFILE        = $1000; //*< The system requests a file open */

    {//* Events ::SDL_USEREVENT through ::SDL_LASTEVENT are for your use;
     *  and should be allocated with SDL_RegisterEvents()}
    SDL_USEREVENT    = $8000;

     {*  This last event is only for bounding internal arrays}
    SDL_LASTEVENT    = $FFFF;

      // SDL_KeyCode constan
    SDLK_UNKNOWN = $00;
    SDLK_BACKSPACE = $08;
    SDLK_TAB = $09;
    SDLK_RETURN = $0D;
    SDLK_ESCAPE = $1B;
    SDLK_SPACE = $20;
    SDLK_EXCLAIM = $21;
    SDLK_QUOTEDBL = $22;
    SDLK_HASH = $23;
    SDLK_DOLLAR = $24;
    SDLK_PERCENT = $25;
    SDLK_AMPERSAND = $26;
    SDLK_QUOTE = $27;
    SDLK_LEFTPAREN = $28;
    SDLK_RIGHTPAREN = $29;
    SDLK_ASTERISK = $2A;
    SDLK_PLUS = $2B;
    SDLK_COMMA = $2C;
    SDLK_MINUS = $2D;
    SDLK_PERIOD = $2E;
    SDLK_SLASH = $2F;
    SDLK_0 = $30;
    SDLK_1 = $31;
    SDLK_2 = $32;
    SDLK_3 = $33;
    SDLK_4 = $34;
    SDLK_5 = $35;
    SDLK_6 = $36;
    SDLK_7 = $37;
    SDLK_8 = $38;
    SDLK_9 = $39;
    SDLK_COLON = $3A;
    SDLK_SEMICOLON = $3B;
    SDLK_LESS = $3C;
    SDLK_EQUALS = $3D;
    SDLK_GREATER = $3E;
    SDLK_QUESTION = $3F;
    SDLK_AT = $40;
    SDLK_LEFTBRACKET = $5B;
    SDLK_BACKSLASH = $5C;
    SDLK_RIGHTBRACKET = $5D;
    SDLK_CARET = $5E;
    SDLK_UNDERSCORE = $5F;
    SDLK_BACKQUOTE = $60;
    SDLK_a = $61;
    SDLK_b = $62;
    SDLK_c = $63;
    SDLK_d = $64;
    SDLK_e = $65;
    SDLK_f = $66;
    SDLK_g = $67;
    SDLK_h = $68;
    SDLK_i = $69;
    SDLK_j = $6A;
    SDLK_k = $6B;
    SDLK_l = $6C;
    SDLK_m = $6D;
    SDLK_n = $6E;
    SDLK_o = $6F;
    SDLK_p = $70;
    SDLK_q = $71;
    SDLK_r = $72;
    SDLK_s = $73;
    SDLK_t = $74;
    SDLK_u = $75;
    SDLK_v = $76;
    SDLK_w = $77;
    SDLK_x = $78;
    SDLK_y = $79;
    SDLK_z = $7A;
    SDLK_DELETE = $B1;
    SDLK_CAPSLOCK = $40000039;
    SDLK_F1 = $4000003A;
    SDLK_F2 = $4000003B;
    SDLK_F3 = $4000003C;
    SDLK_F4 = $4000003D;
    SDLK_F5 = $4000003E;
    SDLK_F6 = $4000003F;
    SDLK_F7 = $40000040;
    SDLK_F8 = $40000041;
    SDLK_F9 = $40000042;
    SDLK_F10 = $40000043;
    SDLK_F11 = $40000044;
    SDLK_F12 = $40000045;
    SDLK_PRINTSCREEN = $40000046;
    SDLK_SCROLLLOCK = $40000047;
    SDLK_PAUSE = $40000048;
    SDLK_INSERT = $40000049;
    SDLK_HOME = $4000004A;
    SDLK_PAGEUP = $4000004B;
    SDLK_END = $4000004D;
    SDLK_PAGEDOWN = $4000004E;
    SDLK_RIGHT = $4000004F;
    SDLK_LEFT = $40000050;
    SDLK_DOWN = $40000051;
    SDLK_UP = $40000052;
    SDLK_NUMLOCKCLEAR = $40000053;
    SDLK_KP_DIVIDE = $40000054;
    SDLK_KP_MULTIPLY = $40000055;
    SDLK_KP_MINUS = $40000056;
    SDLK_KP_PLUS = $40000057;
    SDLK_KP_ENTER = $40000058;
    SDLK_KP_1 = $40000059;
    SDLK_KP_2 = $4000005A;
    SDLK_KP_3 = $4000005B;
    SDLK_KP_4 = $4000005C;
    SDLK_KP_5 = $4000005D;
    SDLK_KP_6 = $4000005E;
    SDLK_KP_7 = $4000005F;
    SDLK_KP_8 = $40000060;
    SDLK_KP_9 = $40000061;
    SDLK_KP_0 = $40000062;
    SDLK_KP_PERIOD = $40000063;
    SDLK_APPLICATION = $40000065;
    SDLK_POWER = $40000066;
    SDLK_KP_EQUALS = $40000067;
    SDLK_F13 = $40000068;
    SDLK_F14 = $40000069;
    SDLK_F15 = $4000006A;
    SDLK_F16 = $4000006B;
    SDLK_F17 = $4000006C;
    SDLK_F18 = $4000006D;
    SDLK_F19 = $4000006E;
    SDLK_F20 = $4000006F;
    SDLK_F21 = $40000070;
    SDLK_F22 = $40000071;
    SDLK_F23 = $40000072;
    SDLK_F24 = $40000073;
    SDLK_EXECUTE = $40000074;
    SDLK_HELP = $40000075;
    SDLK_MENU = $40000076;
    SDLK_SELECT = $40000077;
    SDLK_STOP = $40000078;
    SDLK_AGAIN = $40000079;
    SDLK_UNDO = $4000007A;
    SDLK_CUT = $4000007B;
    SDLK_COPY = $4000007C;
    SDLK_PASTE = $4000007D;
    SDLK_FIND = $4000007E;
    SDLK_MUTE = $4000007F;
    SDLK_VOLUMEUP = $40000080;
    SDLK_VOLUMEDOWN = $40000081;
    SDLK_KP_COMMA = $40000085;
    SDLK_KP_EQUALSAS400 = $40000086;
    SDLK_ALTERASE = $40000099;
    SDLK_SYSREQ = $4000009A;
    SDLK_CANCEL = $4000009B;
    SDLK_CLEAR = $4000009C;
    SDLK_PRIOR = $4000009D;
    SDLK_RETURN2 = $4000009E;
    SDLK_SEPARATOR = $4000009F;
    SDLK_OUT = $400000A0;
    SDLK_OPER = $400000A1;
    SDLK_CLEARAGAIN = $400000A2;
    SDLK_CRSEL = $400000A3;
    SDLK_EXSEL = $400000A4;
    SDLK_KP_00 = $400000B0;
    SDLK_KP_000 = $400000B1;
    SDLK_THOUSANDSSEPARATOR = $400000B2;
    SDLK_DECIMALSEPARATOR = $400000B3;
    SDLK_CURRENCYUNIT = $400000B4;
    SDLK_CURRENCYSUBUNIT = $400000B5;
    SDLK_KP_LEFTPAREN = $400000B6;
    SDLK_KP_RIGHTPAREN = $400000B7;
    SDLK_KP_LEFTBRACE = $400000B8;
    SDLK_KP_RIGHTBRACE = $400000B9;
    SDLK_KP_TAB = $400000BA;
    SDLK_KP_BACKSPACE = $400000BB;
    SDLK_KP_A = $400000BC;
    SDLK_KP_B = $400000BD;
    SDLK_KP_C = $400000BE;
    SDLK_KP_D = $400000BF;
    SDLK_KP_E = $400000C0;
    SDLK_KP_F = $400000C1;
    SDLK_KP_XOR = $400000C2;
    SDLK_KP_POWER = $400000C3;
    SDLK_KP_PERCENT = $400000C4;
    SDLK_KP_LESS = $400000C5;
    SDLK_KP_GREATER = $400000C6;
    SDLK_KP_AMPERSAND = $400000C7;
    SDLK_KP_DBLAMPERSAND = $400000C8;
    SDLK_KP_VERTICALBAR = $400000C9;
    SDLK_KP_DBLVERTICALBAR = $400000CA;
    SDLK_KP_COLON = $400000CB;
    SDLK_KP_HASH = $400000CC;
    SDLK_KP_SPACE = $400000CD;
    SDLK_KP_AT = $400000CE;
    SDLK_KP_EXCLAM = $400000CF;
    SDLK_KP_MEMSTORE = $400000D0;
    SDLK_KP_MEMRECALL = $400000D1;
    SDLK_KP_MEMCLEAR = $400000D2;
    SDLK_KP_MEMADD = $400000D3;
    SDLK_KP_MEMSUBTRACT = $400000D4;
    SDLK_KP_MEMMULTIPLY = $400000D5;
    SDLK_KP_MEMDIVIDE = $400000D6;
    SDLK_KP_PLUSMINUS = $400000D7;
    SDLK_KP_CLEAR = $400000D8;
    SDLK_KP_CLEARENTRY = $400000D9;
    SDLK_KP_BINARY = $400000DA;
    SDLK_KP_OCTAL = $400000DB;
    SDLK_KP_DECIMAL = $400000DC;
    SDLK_KP_HEXADECIMAL = $400000DD;
    SDLK_LCTRL = $400000E0;
    SDLK_LSHIFT = $400000E1;
    SDLK_LALT = $400000E2;
    SDLK_LGUI = $400000E3;
    SDLK_RCTRL = $400000E4;
    SDLK_RSHIFT = $400000E5;
    SDLK_RALT = $400000E6;
    SDLK_RGUI = $400000E7;
    SDLK_MODE = $40000101;
    SDLK_AUDIONEXT = $40000102;
    SDLK_AUDIOPREV = $40000103;
    SDLK_AUDIOSTOP = $40000104;
    SDLK_AUDIOPLAY = $40000105;
    SDLK_AUDIOMUTE = $40000106;
    SDLK_MEDIASELECT = $40000107;
    SDLK_WWW = $40000108;
    SDLK_MAIL = $40000109;
    SDLK_CALCULATOR = $4000010A;
    SDLK_COMPUTER = $4000010B;
    SDLK_AC_SEARCH = $4000010C;
    SDLK_AC_HOME = $4000010D;
    SDLK_AC_BACK = $4000010E;
    SDLK_AC_FORWARD = $4000010F;
    SDLK_AC_STOP = $40000110;
    SDLK_AC_REFRESH = $40000111;
    SDLK_AC_BOOKMARKS = $40000112;
    SDLK_BRIGHTNESSDOWN = $40000113;
    SDLK_BRIGHTNESSUP = $40000114;
    SDLK_DISPLAYSWITCH = $40000115;
    SDLK_KBDILLUMTOGGLE = $40000116;
    SDLK_KBDILLUMDOWN = $40000117;
    SDLK_KBDILLUMUP = $40000118;
    SDLK_EJECT = $40000119;
    SDLK_SLEEP = $4000011A;

    SDL_QUERY	  = -1;
    SDL_IGNORE  =  0;
    SDL_DISABLE =  0;
    SDL_ENABLE  =  1;

  //key modifier
  // Enumeration of valid key mods (possibly OR'd together)
  KMOD_NONE = $0000;
  KMOD_LSHIFT = $0001;
  KMOD_RSHIFT = $0002;
  KMOD_LCTRL = $0040;
  KMOD_RCTRL = $0080;
  KMOD_LALT = $0100;
  KMOD_RALT = $0200;
  KMOD_LMETA = $0400;
  KMOD_RMETA = $0800;
  KMOD_NUM = $1000;
  KMOD_CAPS = $2000;
  KMOD_MODE = 44000;
  KMOD_RESERVED = $8000;

  KMOD_CTRL = (KMOD_LCTRL or KMOD_RCTRL);
  KMOD_SHIFT = (KMOD_LSHIFT or KMOD_RSHIFT);
  KMOD_ALT = (KMOD_LALT or KMOD_RALT);
  KMOD_META = (KMOD_LMETA or KMOD_RMETA);

