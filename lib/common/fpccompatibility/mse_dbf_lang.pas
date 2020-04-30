unit mse_dbf_lang;

{$I dbf_common.inc}

interface

uses
{$ifdef WINDOWS}
  Windows;
{$else}
{$ifdef KYLIX}
  Libc, 
{$endif}  
  Types, mse_dbf_wtil;
{$endif}

const

//*************************************************************************//
// DB3/DB4/FoxPro Lang ID consts, for readable code
//*************************************************************************//

// ...
  FoxLangId_ENU_437       = $01; // DOS USA
  FoxLangId_Intl_850      = $02; // DOS multilingual
  FoxLangId_Windows_1252  = $03; // Windows ANSI
  FoxLangId_Mac_10000     = $04; // Standard Macintosh
// ...
  DbfLangId_DAN_865       = $08;
  DbfLangId_NLD_437       = $09;
  DbfLangId_NLD_850       = $0A;
  DbfLangId_FIN_437       = $0B;
  DbfLangId_FIN_850       = $0C;    // is it used? does not exist in BDE
  DbfLangId_FRA_437       = $0D;
  DbfLangId_FRA_850       = $0E;
  DbfLangId_DEU_437       = $0F;
  DbfLangId_DEU_850       = $10;
  DbfLangId_ITA_437       = $11;
  DbfLangId_ITA_850       = $12;
  DbfLangId_JPN_932       = $13;
  DbfLangId_ESP_850       = $14;
  DbfLangId_SVE_437       = $15;
  DbfLangId_SVE_850       = $16;
  DbfLangId_NOR_865       = $17;
  DbfLangId_ESP_437       = $18;
  DbfLangId_ENG_437       = $19;
  DbfLangId_ENG_850       = $1A;
  DbfLangId_ENU_437       = $1B;
  DbfLangId_FRC_863       = $1C;
  DbfLangId_FRC_850       = $1D;
// ...
  DbfLangId_CSY_852       = $1F;
  DbfLangId_CSY_867       = $20;
// ...
  DbfLangId_HUN_852       = $22;
  DbfLangId_PLK_852       = $23;
  DbfLangId_PTG_860       = $24;
  DbfLangId_PTB_850       = $25;
  DbfLangId_RUS_866       = $26;
// ...
  DbfLangId_ENU_850       = $37;
// ...
  DbfLangId_CHS_936       = $4D;
  DbfLangId_KOR_949       = $4E;
  DbfLangId_CHT_950       = $4F;
  DbfLangId_THA_874       = $50;
// ...
  DbfLangId_JPN_DIC_932   = $56;
  DbfLangId_Ascii_1252    = $57;
  DbfLangId_WEurope_1252  = $58;
  DbfLangId_Spanish_1252  = $59;
// ...
// Additional FoxPro references:
// http://msdn.microsoft.com/en-us/library/8t45x02s%28v=VS.80%29.aspx
// http://www.clicketyclick.dk/databases/xbase/format/dbf.html#DBF_STRUCT
  FoxLangId_German_437    = $5E;
  FoxLangId_Nordic_437    = $5F;
  FoxLangId_Nordic_850    = $60;
  FoxLangId_German_1252   = $61;
  FoxLangId_Nordic_1252   = $62;
// ...
  FoxLangId_EEurope_852   = $64; // DOS
  FoxLangId_Russia_866    = $65; // DOS //todo: verify, MS docs say this is $66
  FoxLangId_Nordic_865    = $66; // DOS //todo: verify, MS docs say this is $65
  FoxLangId_Iceland_861   = $67; // DOS
  FoxLangId_Czech_895     = $68; // DOS Kamenicky
// ...
  DbfLangId_POL_620       = $69; // DOS Polish Mazovia
// ...
  FoxLangId_Greek_737     = $6A; // DOS (437G)
  FoxLangId_Turkish_857   = $6B; // DOS
// ...
  FoxLangId_Taiwan_950    = $78; // Windows
  FoxLangId_Korean_949    = $79; // Windows
  FoxLangId_Chinese_936   = $7A; // Windows Chinese simplified
  FoxLangId_Japan_932     = $7B; // Windows
  FoxLangId_Thai_874      = $7C; // Windows
  FoxLangId_Hebrew_1255   = $7D; // Windows
  FoxLangId_Arabic_1256   = $7E; // Windows
// ...
  DbfLangId_Hebrew        = $85;
  DbfLangId_ELL_437       = $86; // greek, code page 737 (?)
  DbfLangId_SLO_852       = $87;
  DbfLangId_TRK_857       = $88;
// ...
  DbfLangId_BUL_868       = $8E;
// ...
  FoxLangId_Russia_10007  = $96; // Macintosh
  FoxLangId_EEurope_10029 = $97; // Macintosh
  FoxLangId_Greek_10006   = $98; // Macintosh
// ...
  FoxLangId_Czech_1250    = $9B;
  FoxLangId_Czech_850     = $9C; // DOS
// ...
  FoxLangId_EEurope_1250  = $C8; // Windows
  FoxLangId_Russia_1251   = $C9; // Windows
  FoxLangId_Turkish_1254  = $CA; // Windows
  FoxLangId_Greek_1253    = $CB; // Windows


// special constants
  DbfLocale_NotFound   = $010000;
  DbfLocale_Bul868     = $020000;

//*************************************************************************//
// DB3/DB4/FoxPro Language ID to CodePage conversion table
// Visual FoxPro docs call language ID "code page mark"
// or "code page identifier"
//*************************************************************************//

  LangId_To_CodePage: array[Byte] of Word =
//      |  0|    1|    2|    3|    4|    5|    6|    7|
//      |  8|    9|    A|    B|    C|    D|    E|    F|
//      |   |     |     |     |     |     |     |     |
{00}   (   0,  437,  850, 1252,10000,    0,    0,    0,
{08}     865,  437,  850,  437,  850,  437,  850,  437,
{10}     850,  437,  850,  932,  850,  437,  850,  865,
{18}     437,  437,  850,  437,  863,  850,    0,  852,
{20}     867,    0,  852,  852,  860,  850,  866,    0,
{28}       0,    0,    0,    0,    0,    0,    0,    0,
{30}       0,    0,    0,    0,    0,    0,    0,  850,
{38}       0,    0,    0,    0,    0,    0,    0,    0,
{40}       0,    0,    0,    0,    0,    0,    0,    0,
{48}       0,    0,    0,    0,    0,  936,  949,  950,
{50}     874,    0,    0,    0,    0,    0,  932, 1252,
{58}    1252, 1252,    0,    0,    0,    0,  437,  437,
{60}     850, 1252, 1252,    0,  852,  866,  865,  861,
{68}     895,  620,  737,  857,    0,    0,    0,    0,
{70}       0,    0,    0,    0,    0,    0,    0,    0,
{78}     950,  949,  936,  932,  874, 1255, 1256,    0,
{80}       0,    0,    0,    0,    0,  862,  437,  852,
{88}     857,    0,    0,    0,    0,    0,  868,    0,
{90}       0,    0,    0,    0,    0,    0,10007,10029,
{98}   10006,    0,    0, 1250,  850,    0,    0,    0,
{A0}       0,    0,    0,    0,    0,    0,    0,    0,
{A8}       0,    0,    0,    0,    0,    0,    0,    0,
{B0}       0,    0,    0,    0,    0,    0,    0,    0,
{B8}       0,    0,    0,    0,    0,    0,    0,    0,
{C0}       0,    0,    0,    0,    0,    0,    0,    0,
{C8}    1250, 1251, 1254, 1253,    0,    0,    0,    0,
{D0}       0,    0,    0,    0,    0,    0,    0,    0,
{D8}       0,    0,    0,    0,    0,    0,    0,    0,
{E0}       0,    0,    0,    0,    0,    0,    0,    0,
{E8}       0,    0,    0,    0,    0,    0,    0,    0,
{F0}       0,    0,    0,    0,    0,    0,    0,    0,
{F8}       0,    0,    0,    0,    0,    0,    0,    0);


{$ifdef FPC_VERSION}
{$ifdef VER1_0}
  LANG_ARABIC                          = $01;
  LANG_HEBREW                          = $0d;
  LANG_THAI                            = $1e;
  SUBLANG_KOREAN                       = $01;    { Korean (Extended Wansung) }
  SORT_CHINESE_PRC                     = $2;     { PRC Chinese Stroke Count order }
{$endif}
{$endif}

//*************************************************************************//
// DB3/DB4/FoxPro Language ID to Locale convert table
//*************************************************************************//

// table
  LangId_To_Locale: array[Byte] of LCID =
      (
      DbfLocale_NotFound,
{01}  LANG_ENGLISH    or (SUBLANG_ENGLISH_US           shl 10) or (SORT_DEFAULT shl 16),
      LANG_ENGLISH    or (SUBLANG_ENGLISH_UK           shl 10) or (SORT_DEFAULT shl 16),      {international ??}
      LANG_ENGLISH    or (SUBLANG_ENGLISH_UK           shl 10) or (SORT_DEFAULT shl 16),      {windows ??}
      LANG_ENGLISH    or (SUBLANG_ENGLISH_UK           shl 10) or (SORT_DEFAULT shl 16),      {macintosh ??}
      0,0,0,
{08}  LANG_DANISH     or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_DUTCH      or (SUBLANG_DUTCH                shl 10) or (SORT_DEFAULT shl 16),
      LANG_DUTCH      or (SUBLANG_DUTCH                shl 10) or (SORT_DEFAULT shl 16),
      LANG_FINNISH    or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_FINNISH    or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_FRENCH     or (SUBLANG_FRENCH               shl 10) or (SORT_DEFAULT shl 16),
      LANG_FRENCH     or (SUBLANG_FRENCH               shl 10) or (SORT_DEFAULT shl 16),
      LANG_GERMAN     or (SUBLANG_GERMAN               shl 10) or (SORT_DEFAULT shl 16),
      LANG_GERMAN     or (SUBLANG_GERMAN               shl 10) or (SORT_DEFAULT shl 16),
      LANG_ITALIAN    or (SUBLANG_ITALIAN              shl 10) or (SORT_DEFAULT shl 16),
      LANG_ITALIAN    or (SUBLANG_ITALIAN              shl 10) or (SORT_DEFAULT shl 16),
      LANG_JAPANESE   or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_SPANISH    or (SUBLANG_SPANISH              shl 10) or (SORT_DEFAULT shl 16),
      LANG_SWEDISH    or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_SWEDISH    or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_NORWEGIAN  or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_SPANISH    or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_ENGLISH    or (SUBLANG_ENGLISH_UK           shl 10) or (SORT_DEFAULT shl 16),
      LANG_ENGLISH    or (SUBLANG_ENGLISH_UK           shl 10) or (SORT_DEFAULT shl 16),
      LANG_ENGLISH    or (SUBLANG_ENGLISH_US           shl 10) or (SORT_DEFAULT shl 16),
      LANG_FRENCH     or (SUBLANG_FRENCH_CANADIAN      shl 10) or (SORT_DEFAULT shl 16),
      LANG_FRENCH     or (SUBLANG_FRENCH_CANADIAN      shl 10) or (SORT_DEFAULT shl 16),
{1E}  0,
{1F}  LANG_CZECH      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      0 {Used to be LANG_CZECH in previous versions but DBase IV tables show no support here.},
{21}  0,
{22}  LANG_HUNGARIAN  or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_POLISH     or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_PORTUGUESE or (SUBLANG_PORTUGUESE_BRAZILIAN shl 10) or (SORT_DEFAULT shl 16),
      LANG_PORTUGUESE or (SUBLANG_PORTUGUESE_BRAZILIAN shl 10) or (SORT_DEFAULT shl 16),
      LANG_RUSSIAN    or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
{27}  0,0,0,0,0,0,0,0,0,
{30}  0,0,0,0,0,0,0,
{37}  LANG_ENGLISH    or (SUBLANG_ENGLISH_US           shl 10) or (SORT_DEFAULT shl 16),
{38}  0,0,0,0,0,0,0,0,
{40}  0,0,0,0,0,0,0,0,0,0,0,0,0,
{4D}  LANG_CHINESE    or (SUBLANG_CHINESE_SIMPLIFIED   shl 10) or (SORT_DEFAULT shl 16),
      LANG_KOREAN     or (SUBLANG_KOREAN               shl 10) or (SORT_DEFAULT shl 16),
      LANG_CHINESE    or (SUBLANG_CHINESE_TRADITIONAL  shl 10) or (SORT_DEFAULT shl 16),
      LANG_THAI       or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
{51}  0,0,0,0,0,
{56}  LANG_JAPANESE   or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),    // JPN: Dic932 ??
{57}  0, // ANSI/ASCII binary (interpret e.g. as ISO 8859_1 depending on client}
      LANG_ENGLISH    or (SUBLANG_ENGLISH_UK           shl 10) or (SORT_DEFAULT shl 16),    // Western Europe ??
      LANG_SPANISH    or (SUBLANG_SPANISH              shl 10) or (SORT_DEFAULT shl 16),
{5A}  0,0,0,0,
// FoxPro
{5E}  LANG_GERMAN     or (SUBLANG_GERMAN               shl 10) or (SORT_DEFAULT shl 16),
      LANG_NORWEGIAN  or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_NORWEGIAN  or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_GERMAN     or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_NORWEGIAN  or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
{63}  0,
{64}  LANG_CZECH      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),    // Eastern Europe ??
      LANG_RUSSIAN    or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_NORWEGIAN  or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_ICELANDIC  or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_CZECH      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_POLISH     or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_GREEK      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_TURKISH    or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
{6C}  0,0,0,0,
{70}  0,0,0,0,0,0,0,0,
{78}  LANG_CHINESE    or (SUBLANG_CHINESE_HONGKONG     shl 10) or (SORT_DEFAULT shl 16),
      LANG_KOREAN     or (SUBLANG_KOREAN               shl 10) or (SORT_DEFAULT shl 16),
      LANG_CHINESE    or (SUBLANG_CHINESE_SINGAPORE    shl 10) or (SORT_CHINESE_PRC shl 16),
      LANG_JAPANESE   or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),    // JPN: Dic932 ??
      LANG_THAI       or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_HEBREW     or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_ARABIC     or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      0,
{80}  0,0,0,0,0,
// dBase
{85}  LANG_HEBREW     or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_GREEK      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_SLOVAK     or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_TURKISH    or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
{89}  0,0,0,0,0,
{8E}  LANG_BULGARIAN  or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
{8F}  0,0,0,0,0,0,0,
{96}  LANG_RUSSIAN    or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_CZECH      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),    // Eastern Europe ??
      LANG_GREEK      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      0,0,
// FoxPro
{9B}  LANG_CZECH      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_CZECH      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
{9D}  0,0,0,
{A0}  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
{B0}  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
{C0}  0,0,0,0,0,0,0,0,
{C8}  LANG_CZECH      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),    // Eastern Europe ??
      LANG_RUSSIAN    or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_TURKISH    or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      LANG_GREEK      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
{CC}  0,0,0,0,
{D0}  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
{E0}  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
{F0}  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      );

  //*************************************************************************//
  // Visual FoxPro CodePage<>Language ID conversion table
  //*************************************************************************//
  // table: note layout is different:
    VFPCodePage_LangID: array[0..51] of integer =
//        Code page|Codepage identifier/LangID
        (
        437,$01,// U.S. MS-DOS
        620,$69,// Mazovia (Polish) MS-DOS
        737,$6A,// Greek MS-DOS (437G)
        850,$02,// International MS-DOS
        852,$64,// Eastern European MS-DOS
        857,$6B,// Turkish MS-DOS
        861,$67,// Icelandic MS-DOS
        865,$66,// Nordic MS-DOS //todo: verify this. not 65?
        866,$64,// Russian MS-DOS //todo: verify this. not 66?
        874,$7C,// Thai Windows
        895,$68,// Kamenicky (Czech) MS-DOS
        932,$7B,// Japanese Windows
        936,$7A,// Chinese Simplified (PRC, Singapore) Windows
        949,$79,// Korean Windows
        950,$78,// Traditional Chinese (Hong Kong SAR, Taiwan) Windows
        1250,$C8,// Eastern European Windows
        1251,$C9,// Russian Windows
        1252,$03,// Windows ANSI
        1253,$CB,// Greek Windows
        1254,$CA,// Turkish Windows
        1255,$7D,// Hebrew Windows
        1256,$7E,// Arabic Windows
        10000,$04,// Standard Macintosh
        10006,$98,// Greek Macintosh
        10007,$96,// Russian Macintosh
        10029,$97// Macintosh EE (=Eastern European?)
        );

//*************************************************************************//
// DB7 LangID Locale substrings
//*************************************************************************//

// convert table

  LangId_To_LocaleStr: array[Byte] of Cardinal =
      (
      DbfLocale_NotFound,
{01}  Ord('U') or (Ord('S') shl 8) or (Ord('0') shl 16),
      Ord('U') or (Ord('K') shl 8) or (Ord('0') shl 16),
      Ord('U') or (Ord('K') shl 8) or (Ord('0') shl 16),
      Ord('U') or (Ord('K') shl 8) or (Ord('0') shl 16),
      0,0,0,
{08}  Ord('D') or (Ord('A') shl 8) or (Ord('0') shl 16),
      Ord('N') or (Ord('L') shl 8) or (Ord('0') shl 16),
      Ord('N') or (Ord('L') shl 8) or (Ord('0') shl 16),
      Ord('F') or (Ord('I') shl 8) or (Ord('0') shl 16),
      Ord('F') or (Ord('I') shl 8) or (Ord('0') shl 16),
      Ord('F') or (Ord('R') shl 8) or (Ord('0') shl 16),
      Ord('F') or (Ord('R') shl 8) or (Ord('0') shl 16),
      Ord('D') or (Ord('E') shl 8) or (Ord('0') shl 16),
      Ord('D') or (Ord('E') shl 8) or (Ord('0') shl 16),
      Ord('I') or (Ord('T') shl 8) or (Ord('0') shl 16),
      Ord('I') or (Ord('T') shl 8) or (Ord('1') shl 16),
      Ord('J') or (Ord('P') shl 8) or (Ord('0') shl 16),
      Ord('E') or (Ord('S') shl 8) or (Ord('0') shl 16),
      Ord('S') or (Ord('V') shl 8) or (Ord('0') shl 16),
      Ord('S') or (Ord('V') shl 8) or (Ord('1') shl 16),
      Ord('N') or (Ord('O') shl 8) or (Ord('0') shl 16),
      Ord('E') or (Ord('S') shl 8) or (Ord('1') shl 16),
      Ord('U') or (Ord('K') shl 8) or (Ord('0') shl 16),
      Ord('U') or (Ord('K') shl 8) or (Ord('0') shl 16),
      Ord('U') or (Ord('S') shl 8) or (Ord('0') shl 16),
      Ord('C') or (Ord('F') shl 8) or (Ord('1') shl 16),
      Ord('C') or (Ord('F') shl 8) or (Ord('1') shl 16),
{1E}  0,
{1F}  Ord('C') or (Ord('Z') shl 8) or (Ord('0') shl 16),
      Ord('C') or (Ord('Z') shl 8) or (Ord('0') shl 16),
{21}  0,
{22}  Ord('H') or (Ord('D') shl 8) or (Ord('C') shl 16),
      Ord('P') or (Ord('O') shl 8) or (Ord('0') shl 16),
      Ord('P') or (Ord('T') shl 8) or (Ord('0') shl 16),
      Ord('P') or (Ord('T') shl 8) or (Ord('0') shl 16),
      Ord('R') or (Ord('U') shl 8) or (Ord('0') shl 16),
{27}  0,0,0,0,0,0,0,0,0,
{30}  0,0,0,0,0,0,0,
{37}  Ord('U') or (Ord('S') shl 8) or (Ord('0') shl 16),
{38}  0,0,0,0,0,0,0,0,
{40}  0,0,0,0,0,0,0,0,0,0,0,0,0,
{4D}  Ord('C') or (Ord('N') shl 8) or (Ord('0') shl 16),
      Ord('K') or (Ord('O') shl 8) or (Ord('0') shl 16),
      Ord('T') or (Ord('W') shl 8) or (Ord('0') shl 16),
      Ord('T') or (Ord('H') shl 8) or (Ord('0') shl 16),
{51}  0,0,0,0,0,
{56}  Ord('J') or (Ord('P') shl 8) or (Ord('1') shl 16),
      Ord('U') or (Ord('S') shl 8) or (Ord('0') shl 16),
      Ord('W') or (Ord('E') shl 8) or (Ord('0') shl 16),
      Ord('E') or (Ord('S') shl 8) or (Ord('0') shl 16),
{5A}  0,0,0,0,
// FoxPro
{5E}  Ord('D') or (Ord('E') shl 8),
      Ord('N') or (Ord('O') shl 8),
      Ord('N') or (Ord('O') shl 8),
      Ord('D') or (Ord('E') shl 8),
      Ord('N') or (Ord('O') shl 8),
{63}  0,
{64}  Ord('C') or (Ord('Z') shl 8) or (Ord('0') shl 16),
      Ord('R') or (Ord('U') shl 8) or (Ord('0') shl 16),
      Ord('N') or (Ord('O') shl 8),
      Ord('I') or (Ord('C') shl 8) or (Ord('0') shl 16),    // made this one up: iceland
      Ord('C') or (Ord('Z') shl 8) or (Ord('0') shl 16),
{69}  Ord('P') or (Ord('O') shl 8) or (Ord('1') shl 16),
      Ord('G') or (Ord('R') shl 8) or (Ord('0') shl 16),
      Ord('T') or (Ord('R') shl 8) or (Ord('0') shl 16),
{6C}  0,0,0,0,
{70}  0,0,0,0,0,0,0,0,
{78}  Ord('C') or (Ord('H') shl 8) or (Ord('0') shl 16),    // made this one up: chinese hongkong
      Ord('K') or (Ord('O') shl 8) or (Ord('0') shl 16),
      Ord('C') or (Ord('S') shl 8) or (Ord('0') shl 16),    // made this one up: chinese singapore
      Ord('J') or (Ord('P') shl 8) or (Ord('0') shl 16),
      Ord('T') or (Ord('H') shl 8) or (Ord('0') shl 16),
      Ord('R') or (Ord('E') shl 8) or (Ord('W') shl 16),
      Ord('A') or (Ord('R') shl 8) or (Ord('0') shl 16),    // made this one up: arabic (default)
{7F}  0,
{80}  0,0,0,0,0,
// dBase
{85}  Ord('R') or (Ord('E') shl 8) or (Ord('W') shl 16),
      Ord('G') or (Ord('R') shl 8) or (Ord('0') shl 16),
      Ord('S') or (Ord('L') shl 8) or (Ord('0') shl 16),
      Ord('T') or (Ord('R') shl 8) or (Ord('0') shl 16),
{89}  0,0,0,0,0,
{8E}  DbfLocale_Bul868,
{8F}  0,0,0,0,0,0,0,
{96}  Ord('R') or (Ord('U') shl 8) or (Ord('0') shl 16),
      Ord('C') or (Ord('Z') shl 8) or (Ord('0') shl 16),
      Ord('G') or (Ord('R') shl 8) or (Ord('0') shl 16),
{99}  0,0,
// FoxPro
{9B}  0, //LANG_CZECH      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
      0, //LANG_CZECH      or (SUBLANG_DEFAULT              shl 10) or (SORT_DEFAULT shl 16),
{9D}  0,0,0,
{A0}  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
{B0}  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
{C0}  0,0,0,0,0,0,0,0,
{C8}  Ord('C') or (Ord('Z') shl 8) or (Ord('0') shl 16),
      Ord('R') or (Ord('U') shl 8) or (Ord('0') shl 16),
      Ord('T') or (Ord('R') shl 8) or (Ord('0') shl 16),
      Ord('G') or (Ord('R') shl 8) or (Ord('0') shl 16),
{CC}  0,0,0,0,
{D0}  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
{E0}  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
{F0}  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      );

{
  DbfLocaleId_DAN_865       = Ord('D') or (Ord('A') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_NLD_437       = Ord('N') or (Ord('L') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_NLD_850       = Ord('N') or (Ord('L') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_FIN_437       = Ord('F') or (Ord('I') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_FIN_850       = Ord('F') or (Ord('I') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_FRA_437       = Ord('F') or (Ord('R') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_FRA_850       = Ord('F') or (Ord('R') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_DEU_437       = Ord('D') or (Ord('E') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_DEU_850       = Ord('D') or (Ord('E') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_ITA_437       = Ord('I') or (Ord('T') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_ITA_850       = Ord('I') or (Ord('T') shl 8) or (Ord('1') shl 16);
  DbfLocaleId_JPN_932       = Ord('J') or (Ord('P') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_ESP_850       = Ord('E') or (Ord('S') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_SVE_437       = Ord('S') or (Ord('V') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_SVE_850       = Ord('S') or (Ord('V') shl 8) or (Ord('1') shl 16);
  DbfLocaleId_NOR_865       = Ord('N') or (Ord('O') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_ESP_437       = Ord('E') or (Ord('S') shl 8) or (Ord('1') shl 16);
  DbfLocaleId_ENG_437       = Ord('U') or (Ord('K') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_ENG_850       = Ord('U') or (Ord('K') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_ENU_437       = Ord('U') or (Ord('S') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_FRC_863       = Ord('C') or (Ord('F') shl 8) or (Ord('1') shl 16);
  DbfLocaleId_FRC_850       = Ord('C') or (Ord('F') shl 8) or (Ord('1') shl 16);
// ...
  DbfLocaleId_CSY_852       = Ord('C') or (Ord('Z') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_CSY_867       = Ord('C') or (Ord('Z') shl 8) or (Ord('0') shl 16);
// ...
  DbfLocaleId_HUN_852       = Ord('H') or (Ord('D') shl 8) or (Ord('C') shl 16);
  DbfLocaleId_PLK_852       = Ord('P') or (Ord('O') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_PTG_860       = Ord('P') or (Ord('T') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_PTB_850       = Ord('P') or (Ord('T') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_RUS_866       = Ord('R') or (Ord('U') shl 8) or (Ord('0') shl 16);
// ...
  DbfLocaleId_ENU_850       = Ord('U') or (Ord('S') shl 8) or (Ord('0') shl 16);
// ...
  DbfLocaleId_CHS_936       = Ord('C') or (Ord('N') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_KOR_949       = Ord('K') or (Ord('O') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_CHT_950       = Ord('T') or (Ord('W') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_THA_874       = Ord('T') or (Ord('H') shl 8) or (Ord('0') shl 16);
// ...
  DbfLocaleId_JPN_DIC_932   = Ord('J') or (Ord('P') shl 8) or (Ord('1') shl 16);
  DbfLocaleId_Ascii_Ansi    = Ord('U') or (Ord('S') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_WEurope_Ansi  = Ord('W') or (Ord('E') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_Spanish_Ansi  = Ord('E') or (Ord('S') shl 8) or (Ord('0') shl 16);
// ...
  DbfLocaleId_Hebrew        = Ord('R') or (Ord('E') shl 8) or (Ord('W') shl 16);
  DbfLocaleId_ELL_437       = Ord('G') or (Ord('R') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_SLO_852       = Ord('S') or (Ord('L') shl 8) or (Ord('0') shl 16);
  DbfLocaleId_TRK_857       = Ord('T') or (Ord('R') shl 8) or (Ord('0') shl 16);
// ...
  DbfLocaleId_BUL_868       = 'BGDB868';
}

// VdBase 7 Language strings
//  'DBWIN...' -> Charset 1252 (ansi)
//  'DB999...' -> Code page 999, 9 any digit
//  'DBHEBREW' -> Code page 1255 ??
//  'FOX..999' -> Code page 999, 9 any digit
//  'FOX..WIN' -> Charset 1252 (ansi)

//*************************************************************************//
// reverse convert routines
//*************************************************************************//

// Visual DBaseVII specific; the IsFoxPro means a FoxPro codepage, which DB7 supports
function ConstructLangName(CodePage: Integer; Locale: LCID; IsFoxPro: Boolean): string;

function ConstructLangId(CodePage: Integer; Locale: LCID; IsFoxPro: Boolean): Byte;

// Visual DBaseVII specific
function GetLangId_From_LangName(LocaleStr: string): Byte;

implementation

uses
  SysUtils;

type
  PCardinal = ^Cardinal;

function ConstructLangName(CodePage: Integer; Locale: LCID; IsFoxPro: Boolean): string;
var
  SubType: Cardinal;
begin
  // ANSI?
  SubType := LangId_To_LocaleStr[ConstructLangId(CodePage, Locale, IsFoxPro)];
  // found?
  if SubType <> DbfLocale_NotFound then
  begin
    // foxpro or dbase?
    if IsFoxPro then
    begin
      Result := 'FOX' + PChar(@SubType);
      if CodePage = 1252 then
        Result := Result + 'WIN'
      else
        Result := Result + IntToStr(CodePage);
    end else begin
      if SubType = DbfLocale_Bul868 then
      begin
        // special case
        Result := 'BGDB868';
      end else begin
        // start with DB
        Result := 'DB';
        // add codepage
        if CodePage = 1252 then
          Result := Result + 'WIN'
        else
          Result := Result + IntToStr(CodePage);
        // add subtype
        Result := Result + PChar(@SubType);
      end;
    end;
  end;
end;

const
  // range of Dbase locales; these are INCLUSIVE (the rest are FoxPro)
  dBase_RegionCount = 4;
  dBase_Regions: array[0..dBase_RegionCount*2-1] of Byte =
   ($00, $00,
    $05, $5D,
    $69, $69, // a lonely dbf entry :-)
    $80, $90);

function FindLangId(CodePage, DesiredLocale: Cardinal; LanguageIDToLocaleTable: PCardinal; IsFoxPro: Boolean): Byte;
// DesiredLocale: pointer to lookup array: language ID=>locale
var
  i, LangID, Region: Integer;
begin
  Region := 0;
  if IsFoxPro then
  begin
    // scan for a language ID matching the given codepage;
    // default to Win1252 Western European codepage
    result:=$03;
    for i := 0 to high(VFPCodePage_LangID) div 2 do
    begin
      if CodePage=VFPCodePage_LangID[i*2] then
      begin
        result := Byte(VFPCodePage_LangID[1+i*2]);
        break;
      end;
    end;
  end
  else
  begin
    // DBase
    // scan for a language ID matching the given codepage
    result:=0;
    for LangID := 0 to $FF do
    begin
      // check if need to advance to next region
      if Region + 2 < dBase_RegionCount then
        if LangID >= dBase_Regions[Region + 2] then
          Inc(Region, 2);
      // it seems delphi does not properly understand pointers?
      // what a mess :-(
      if ((LangId_To_CodePage[LangID] = CodePage) or (CodePage = 0)) and
        (PCardinal(PChar(LanguageIDToLocaleTable)+(LangID*4))^ = DesiredLocale) then
        // Ignore (V)FP results
        if LangID <= dBase_Regions[Region+1] then
          result := Byte(LangID);
    end;
  end;
end;

function ConstructLangId(CodePage: Integer; Locale: LCID; IsFoxPro: Boolean): Byte;
begin
  // locale: lower 16bits only, with default sorting
  Locale := (Locale and $FFFF) or (SORT_DEFAULT shl 16);
  if IsFoxPro then
    Result := FindLangID(CodePage, Locale, @VFPCodePage_LangID[0], true)
  else
    Result := FindLangId(CodePage, Locale, @LangId_To_Locale[0], false);
  // not found? try any codepage
  if Result = 0 then
    if IsFoxPro then
      Result := FindLangID(0, Locale, @VFPCodePage_LangID[0], true)
    else
    begin
      Result := FindLangId(0, Locale, @LangId_To_Locale[0], false);
      // Dbase: last resort; include foxpro codepages;
      // compatible with older tdbf but unknow whether this actually works
      if Result = 0 then
        Result := FindLangID(0, Locale, @VFPCodePage_LangID[0], true)
    end;
end;

function GetLangId_From_LangName(LocaleStr: string): Byte;
var
  CodePage, SubType: Integer;
  IsFoxPro: Boolean;
  CodePageStr: string;
begin
  // determine foxpro/dbase
  IsFoxPro := CompareMem(PChar('FOX'), PChar(LocaleStr), 3);
  // get codepage/locale subtype
  if IsFoxPro then
  begin
    CodePageStr := Copy(LocaleStr, 6, 3);
    SubType := Integer(LocaleStr[4]) or (Integer(LocaleStr[5]) shl 8);
  end else begin
    CodePageStr := Copy(LocaleStr, 3, 3);
    SubType := Integer(LocaleStr[6]) or (Integer(LocaleStr[7]) shl 8) or (Integer(LocaleStr[8]) shl 16);
  end;
  // convert codepage string to codepage id
  if CodePageStr = 'WIN' then
    CodePage := 1252
  else if CodePageStr = 'REW' then    // Hebrew
    CodePage := 1255
  else
    CodePage := StrToIntDef(CodePageStr,0); //fail to codepage 0
  // find lang id
  Result := FindLangId(CodePage, SubType, @LangId_To_LocaleStr[0], IsFoxPro);
end;

end.

