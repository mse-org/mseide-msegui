unit mseunicodeps;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
 msetypes,msestrings;
 
type
 unicodepagety = (ucp_00,ucp_01,ucp_02,ucp_03,ucp_04,ucp_05,ucp_06,
                  ucp_1e,
                  ucp_20,ucp_21,ucp_22,ucp_23,ucp_25,ucp_26);
 encodingty = record
  codepage: integer;
  name: string;
  glyphnames: string;
 end;
 encodingsty = array[unicodepagety] of encodingty;
 
const
 nl = lineend;
 encodings: encodingsty = (
  (
  codepage: $00;
  name: 'E00';         //latin1
  glyphnames:
'/uni0000 /uni0001 /uni0002 /uni0003 /uni0004 /uni0005 /uni0006 /uni0007 '+nl+ //00
'/uni0008 /uni0009 /uni000A /uni000B /uni000C /uni000D /uni000E /uni000F '+nl+ //08
'/uni0010 /uni0011 /uni0012 /uni0013 /uni0014 /uni0015 /uni0016 /uni0017 '+nl+ //10
'/uni0018 /uni0019 /uni001A /uni001B /uni001C /uni001D /uni001E /uni001F '+nl+ //18
'/space /exclam /quotedbl /numbersign /dollar /percent /ampersand /quotesingle '+nl+ //20
'/parenleft /parenright /asterisk /plus /comma /hyphen /period /slash '+nl+ //28
'/zero /one /two /three /four /five /six /seven '+nl+ //30
'/eight /nine /colon /semicolon /less /equal /greater /question '+nl+ //38
'/at /A /B /C /D /E /F /G '+nl+ //40
'/H /I /J /K /L /M /N /O '+nl+ //48
'/P /Q /R /S /T /U /V /W '+nl+ //50
'/X /Y /Z /bracketleft /backslash /bracketright /asciicircum /underscore '+nl+ //58
'/grave /a /b /c /d /e /f /g '+nl+ //60
'/h /i /j /k /l /m /n /o '+nl+ //68
'/p /q /r /s /t /u /v /w '+nl+ //70
'/x /y /z /braceleft /bar /braceright /asciitilde /uni007F '+nl+ //78
'/uni0080 /uni0081 /uni0082 /uni0083 /uni0084 /uni0085 /uni0086 /uni0087 '+nl+ //80
'/uni0088 /uni0089 /uni008A /uni008B /uni008C /uni008D /uni008E /uni008F '+nl+ //88
'/uni0090 /uni0091 /uni0092 /uni0093 /uni0094 /uni0095 /uni0096 /uni0097 '+nl+ //90
'/uni0098 /uni0099 /uni009A /uni009B /uni009C /uni009D /uni009E /uni009F '+nl+ //98
'/uni00A0 /exclamdown /cent /sterling /currency /yen /brokenbar /section '+nl+ //A0
'/dieresis /copyright /ordfeminine /guillemotleft /logicalnot /uni00AD /registered /macron '+nl+ //A8
'/degree /plusminus /uni00B2 /uni00B3 /acute /uni00B5 /paragraph /periodcentered '+nl+ //B0
'/cedilla /uni00B9 /ordmasculine /guillemotright /onequarter /onehalf /threequarters /questiondown '+nl+ //B8
'/Agrave /Aacute /Acircumflex /Atilde /Adieresis /Aring /AE /Ccedilla '+nl+ //C0
'/Egrave /Eacute /Ecircumflex /Edieresis /Igrave /Iacute /Icircumflex /Idieresis '+nl+ //C8
'/Eth /Ntilde /Ograve /Oacute /Ocircumflex /Otilde /Odieresis /multiply '+nl+ //D0
'/Oslash /Ugrave /Uacute /Ucircumflex /Udieresis /Yacute /Thorn /germandbls '+nl+ //D8
'/agrave /aacute /acircumflex /atilde /adieresis /aring /ae /ccedilla '+nl+ //E0
'/egrave /eacute /ecircumflex /edieresis /igrave /iacute /icircumflex /idieresis '+nl+ //E8
'/eth /ntilde /ograve /oacute /ocircumflex /otilde /odieresis /divide '+nl+ //F0
'/oslash /ugrave /uacute /ucircumflex /udieresis /yacute /thorn /ydieresis '+nl //F8
  ),
  (
  codepage: $01;
  name: 'E01';         //latin extended A
  glyphnames:
'/Amacron /amacron /Abreve /abreve /Aogonek /aogonek /Cacute /cacute '+nl+ //00
'/Ccircumflex /ccircumflex /Cdotaccent /cdotaccent /Ccaron /ccaron /Dcaron /dcaron '+nl+ //08
'/Dcroat /dcroat /Emacron /emacron /Ebreve /ebreve /Edotaccent /edotaccent '+nl+ //10
'/Eogonek /eogonek /Ecaron /ecaron /Gcircumflex /gcircumflex /Gbreve /gbreve '+nl+ //18
'/Gdotaccent /gdotaccent /Gcommaaccent /gcommaaccent /Hcircumflex /hcircumflex /Hbar /hbar '+nl+ //20
'/Itilde /itilde /Imacron /imacron /Ibreve /ibreve /Iogonek /iogonek '+nl+ //28
'/Idotaccent /dotlessi /IJ /ij /Jcircumflex /jcircumflex /Kcommaaccent /kcommaaccent '+nl+ //30
'/kgreenlandic /Lacute /lacute /Lcommaaccent /lcommaaccent /Lcaron /lcaron /Ldot '+nl+ //38
'/ldot /Lslash /lslash /Nacute /nacute /Ncommaaccent /ncommaaccent /Ncaron '+nl+ //40
'/ncaron /napostrophe /Eng /eng /Omacron /omacron /Obreve /obreve '+nl+ //48
'/Ohungarumlaut /ohungarumlaut /OE /oe /Racute /racute /Rcommaaccent /rcommaaccent '+nl+ //50
'/Rcaron /rcaron /Sacute /sacute /Scircumflex /scircumflex /Scedilla /scedilla '+nl+ //58
'/Scaron /scaron /Tcommaaccent /tcommaaccent /Tcaron /tcaron /Tbar /tbar '+nl+ //60
'/Utilde /utilde /Umacron /umacron /Ubreve /ubreve /Uring /uring '+nl+ //68
'/Uhungarumlaut /uhungarumlaut /Uogonek /uogonek /Wcircumflex /wcircumflex /Ycircumflex /ycircumflex '+nl+ //70
'/Ydieresis /Zacute /zacute /Zdotaccent /zdotaccent /Zcaron /zcaron /longs '+nl+ //78
'/uni0180 /uni0181 /uni0182 /uni0183 /uni0184 /uni0185 /uni0186 /uni0187 '+nl+ //80
'/uni0188 /uni0189 /uni018A /uni018B /uni018C /uni018D /uni018E /uni018F '+nl+ //88
'/uni0190 /uni0191 /florin /uni0193 /uni0194 /uni0195 /uni0196 /uni0197 '+nl+ //90
'/uni0198 /uni0199 /uni019A /uni019B /uni019C /uni019D /uni019E /uni019F '+nl+ //98
'/Ohorn /ohorn /uni01A2 /uni01A3 /uni01A4 /uni01A5 /uni01A6 /uni01A7 '+nl+ //A0
'/uni01A8 /uni01A9 /uni01AA /uni01AB /uni01AC /uni01AD /uni01AE /Uhorn '+nl+ //A8
'/uhorn /uni01B1 /uni01B2 /uni01B3 /uni01B4 /uni01B5 /uni01B6 /uni01B7 '+nl+ //B0
'/uni01B8 /uni01B9 /uni01BA /uni01BB /uni01BC /uni01BD /uni01BE /uni01BF '+nl+ //B8
'/uni01C0 /uni01C1 /uni01C2 /uni01C3 /uni01C4 /uni01C5 /uni01C6 /uni01C7 '+nl+ //C0
'/uni01C8 /uni01C9 /uni01CA /uni01CB /uni01CC /uni01CD /uni01CE /uni01CF '+nl+ //C8
'/uni01D0 /uni01D1 /uni01D2 /uni01D3 /uni01D4 /uni01D5 /uni01D6 /uni01D7 '+nl+ //D0
'/uni01D8 /uni01D9 /uni01DA /uni01DB /uni01DC /uni01DD /uni01DE /uni01DF '+nl+ //D8
'/uni01E0 /uni01E1 /uni01E2 /uni01E3 /uni01E4 /uni01E5 /Gcaron /gcaron '+nl+ //E0
'/uni01E8 /uni01E9 /uni01EA /uni01EB /uni01EC /uni01ED /uni01EE /uni01EF '+nl+ //E8
'/uni01F0 /uni01F1 /uni01F2 /uni01F3 /uni01F4 /uni01F5 /uni01F6 /uni01F7 '+nl+ //F0
'/uni01F8 /uni01F9 /Aringacute /aringacute /AEacute /aeacute /Oslashacute /oslashacute '+nl //F8
  ),
  (
  codepage: $02;
  name: 'E02';         //latin extended B
  glyphnames:
'/uni0200 /uni0201 /uni0202 /uni0203 /uni0204 /uni0205 /uni0206 /uni0207 '+nl+ //00
'/uni0208 /uni0209 /uni020A /uni020B /uni020C /uni020D /uni020E /uni020F '+nl+ //08
'/uni0210 /uni0211 /uni0212 /uni0213 /uni0214 /uni0215 /uni0216 /uni0217 '+nl+ //10
'/Scommaaccent /scommaaccent /uni021A /uni021B /uni021C /uni021D /uni021E /uni021F '+nl+ //18
'/uni0220 /uni0221 /uni0222 /uni0223 /uni0224 /uni0225 /uni0226 /uni0227 '+nl+ //20
'/uni0228 /uni0229 /uni022A /uni022B /uni022C /uni022D /uni022E /uni022F '+nl+ //28
'/uni0230 /uni0231 /uni0232 /uni0233 /uni0234 /uni0235 /uni0236 /uni0237 '+nl+ //30
'/uni0238 /uni0239 /uni023A /uni023B /uni023C /uni023D /uni023E /uni023F '+nl+ //38
'/uni0240 /uni0241 /uni0242 /uni0243 /uni0244 /uni0245 /uni0246 /uni0247 '+nl+ //40
'/uni0248 /uni0249 /uni024A /uni024B /uni024C /uni024D /uni024E /uni024F '+nl+ //48
'/uni0250 /uni0251 /uni0252 /uni0253 /uni0254 /uni0255 /uni0256 /uni0257 '+nl+ //50
'/uni0258 /uni0259 /uni025A /uni025B /uni025C /uni025D /uni025E /uni025F '+nl+ //58
'/uni0260 /uni0261 /uni0262 /uni0263 /uni0264 /uni0265 /uni0266 /uni0267 '+nl+ //60
'/uni0268 /uni0269 /uni026A /uni026B /uni026C /uni026D /uni026E /uni026F '+nl+ //68
'/uni0270 /uni0271 /uni0272 /uni0273 /uni0274 /uni0275 /uni0276 /uni0277 '+nl+ //70
'/uni0278 /uni0279 /uni027A /uni027B /uni027C /uni027D /uni027E /uni027F '+nl+ //78
'/uni0280 /uni0281 /uni0282 /uni0283 /uni0284 /uni0285 /uni0286 /uni0287 '+nl+ //80
'/uni0288 /uni0289 /uni028A /uni028B /uni028C /uni028D /uni028E /uni028F '+nl+ //88
'/uni0290 /uni0291 /uni0292 /uni0293 /uni0294 /uni0295 /uni0296 /uni0297 '+nl+ //90
'/uni0298 /uni0299 /uni029A /uni029B /uni029C /uni029D /uni029E /uni029F '+nl+ //98
'/uni02A0 /uni02A1 /uni02A2 /uni02A3 /uni02A4 /uni02A5 /uni02A6 /uni02A7 '+nl+ //A0
'/uni02A8 /uni02A9 /uni02AA /uni02AB /uni02AC /uni02AD /uni02AE /uni02AF '+nl+ //A8
'/uni02B0 /uni02B1 /uni02B2 /uni02B3 /uni02B4 /uni02B5 /uni02B6 /uni02B7 '+nl+ //B0
'/uni02B8 /uni02B9 /uni02BA /uni02BB /afii57929 /afii64937 /uni02BE /uni02BF '+nl+ //B8
'/uni02C0 /uni02C1 /uni02C2 /uni02C3 /uni02C4 /uni02C5 /circumflex /caron '+nl+ //C0
'/uni02C8 /uni02C9 /uni02CA /uni02CB /uni02CC /uni02CD /uni02CE /uni02CF '+nl+ //C8
'/uni02D0 /uni02D1 /uni02D2 /uni02D3 /uni02D4 /uni02D5 /uni02D6 /uni02D7 '+nl+ //D0
'/breve /dotaccent /ring /ogonek /tilde /hungarumlaut /uni02DE /uni02DF '+nl+ //D8
'/uni02E0 /uni02E1 /uni02E2 /uni02E3 /uni02E4 /uni02E5 /uni02E6 /uni02E7 '+nl+ //E0
'/uni02E8 /uni02E9 /uni02EA /uni02EB /uni02EC /uni02ED /uni02EE /uni02EF '+nl+ //E8
'/uni02F0 /uni02F1 /uni02F2 /uni02F3 /uni02F4 /uni02F5 /uni02F6 /uni02F7 '+nl+ //F0
'/uni02F8 /uni02F9 /uni02FA /uni02FB /uni02FC /uni02FD /uni02FE /uni02FF '+nl //F8
  ),
  (
  codepage: $03;
  name: 'E03';         //greek
  glyphnames:
'/gravecomb /acutecomb /uni0302 /tildecomb /uni0304 /uni0305 /uni0306 /uni0307 '+nl+ //00
'/uni0308 /hookabovecomb /uni030A /uni030B /uni030C /uni030D /uni030E /uni030F '+nl+ //08
'/uni0310 /uni0311 /uni0312 /uni0313 /uni0314 /uni0315 /uni0316 /uni0317 '+nl+ //10
'/uni0318 /uni0319 /uni031A /uni031B /uni031C /uni031D /uni031E /uni031F '+nl+ //18
'/uni0320 /uni0321 /uni0322 /dotbelowcomb /uni0324 /uni0325 /uni0326 /uni0327 '+nl+ //20
'/uni0328 /uni0329 /uni032A /uni032B /uni032C /uni032D /uni032E /uni032F '+nl+ //28
'/uni0330 /uni0331 /uni0332 /uni0333 /uni0334 /uni0335 /uni0336 /uni0337 '+nl+ //30
'/uni0338 /uni0339 /uni033A /uni033B /uni033C /uni033D /uni033E /uni033F '+nl+ //38
'/uni0340 /uni0341 /uni0342 /uni0343 /uni0344 /uni0345 /uni0346 /uni0347 '+nl+ //40
'/uni0348 /uni0349 /uni034A /uni034B /uni034C /uni034D /uni034E /uni034F '+nl+ //48
'/uni0350 /uni0351 /uni0352 /uni0353 /uni0354 /uni0355 /uni0356 /uni0357 '+nl+ //50
'/uni0358 /uni0359 /uni035A /uni035B /uni035C /uni035D /uni035E /uni035F '+nl+ //58
'/uni0360 /uni0361 /uni0362 /uni0363 /uni0364 /uni0365 /uni0366 /uni0367 '+nl+ //60
'/uni0368 /uni0369 /uni036A /uni036B /uni036C /uni036D /uni036E /uni036F '+nl+ //68
'/uni0370 /uni0371 /uni0372 /uni0373 /uni0374 /uni0375 /uni0376 /uni0377 '+nl+ //70
'/uni0378 /uni0379 /uni037A /uni037B /uni037C /uni037D /uni037E /uni037F '+nl+ //78
'/uni0380 /uni0381 /uni0382 /uni0383 /tonos /dieresistonos /Alphatonos /anoteleia '+nl+ //80
'/Epsilontonos /Etatonos /Iotatonos /uni038B /Omicrontonos /uni038D /Upsilontonos /Omegatonos '+nl+ //88
'/iotadieresistonos /Alpha /Beta /Gamma /Delta /Epsilon /Zeta /Eta '+nl+ //90
'/Theta /Iota /Kappa /Lambda /Mu /Nu /Xi /Omicron '+nl+ //98
'/Pi /Rho /uni03A2 /Sigma /Tau /Upsilon /Phi /Chi '+nl+ //A0
'/Psi /Omega /Iotadieresis /Upsilondieresis /alphatonos /epsilontonos /etatonos /iotatonos '+nl+ //A8
'/upsilondieresistonos /alpha /beta /gamma /delta /epsilon /zeta /eta '+nl+ //B0
'/theta /iota /kappa /lambda /mu /nu /xi /omicron '+nl+ //B8
'/pi /rho /sigma1 /sigma /tau /upsilon /phi /chi '+nl+ //C0
'/psi /omega /iotadieresis /upsilondieresis /omicrontonos /upsilontonos /omegatonos /uni03CF '+nl+ //C8
'/uni03D0 /theta1 /Upsilon1 /uni03D3 /uni03D4 /phi1 /omega1 /uni03D7 '+nl+ //D0
'/uni03D8 /uni03D9 /uni03DA /uni03DB /uni03DC /uni03DD /uni03DE /uni03DF '+nl+ //D8
'/uni03E0 /uni03E1 /uni03E2 /uni03E3 /uni03E4 /uni03E5 /uni03E6 /uni03E7 '+nl+ //E0
'/uni03E8 /uni03E9 /uni03EA /uni03EB /uni03EC /uni03ED /uni03EE /uni03EF '+nl+ //E8
'/uni03F0 /uni03F1 /uni03F2 /uni03F3 /uni03F4 /uni03F5 /uni03F6 /uni03F7 '+nl+ //F0
'/uni03F8 /uni03F9 /uni03FA /uni03FB /uni03FC /uni03FD /uni03FE /uni03FF '+nl //F8
  ),
  (
  codepage: $04;
  name: 'E04';         //cyrillic
  glyphnames:
'/uni0400 /afii10023 /afii10051 /afii10052 /afii10053 /afii10054 /afii10055 /afii10056 '+nl+ //00
'/afii10057 /afii10058 /afii10059 /afii10060 /afii10061 /uni040D /afii10062 /afii10145 '+nl+ //08
'/afii10017 /afii10018 /afii10019 /afii10020 /afii10021 /afii10022 /afii10024 /afii10025 '+nl+ //10
'/afii10026 /afii10027 /afii10028 /afii10029 /afii10030 /afii10031 /afii10032 /afii10033 '+nl+ //18
'/afii10034 /afii10035 /afii10036 /afii10037 /afii10038 /afii10039 /afii10040 /afii10041 '+nl+ //20
'/afii10042 /afii10043 /afii10044 /afii10045 /afii10046 /afii10047 /afii10048 /afii10049 '+nl+ //28
'/afii10065 /afii10066 /afii10067 /afii10068 /afii10069 /afii10070 /afii10072 /afii10073 '+nl+ //30
'/afii10074 /afii10075 /afii10076 /afii10077 /afii10078 /afii10079 /afii10080 /afii10081 '+nl+ //38
'/afii10082 /afii10083 /afii10084 /afii10085 /afii10086 /afii10087 /afii10088 /afii10089 '+nl+ //40
'/afii10090 /afii10091 /afii10092 /afii10093 /afii10094 /afii10095 /afii10096 /afii10097 '+nl+ //48
'/uni0450 /afii10071 /afii10099 /afii10100 /afii10101 /afii10102 /afii10103 /afii10104 '+nl+ //50
'/afii10105 /afii10106 /afii10107 /afii10108 /afii10109 /uni045D /afii10110 /afii10193 '+nl+ //58
'/uni0460 /uni0461 /afii10146 /afii10194 /uni0464 /uni0465 /uni0466 /uni0467 '+nl+ //60
'/uni0468 /uni0469 /uni046A /uni046B /uni046C /uni046D /uni046E /uni046F '+nl+ //68
'/uni0470 /uni0471 /afii10147 /afii10195 /afii10148 /afii10196 /uni0476 /uni0477 '+nl+ //70
'/uni0478 /uni0479 /uni047A /uni047B /uni047C /uni047D /uni047E /uni047F '+nl+ //78
'/uni0480 /uni0481 /uni0482 /uni0483 /uni0484 /uni0485 /uni0486 /uni0487 '+nl+ //80
'/uni0488 /uni0489 /uni048A /uni048B /uni048C /uni048D /uni048E /uni048F '+nl+ //88
'/afii10050 /afii10098 /uni0492 /uni0493 /uni0494 /uni0495 /uni0496 /uni0497 '+nl+ //90
'/uni0498 /uni0499 /uni049A /uni049B /uni049C /uni049D /uni049E /uni049F '+nl+ //98
'/uni04A0 /uni04A1 /uni04A2 /uni04A3 /uni04A4 /uni04A5 /uni04A6 /uni04A7 '+nl+ //A0
'/uni04A8 /uni04A9 /uni04AA /uni04AB /uni04AC /uni04AD /uni04AE /uni04AF '+nl+ //A8
'/uni04B0 /uni04B1 /uni04B2 /uni04B3 /uni04B4 /uni04B5 /uni04B6 /uni04B7 '+nl+ //B0
'/uni04B8 /uni04B9 /uni04BA /uni04BB /uni04BC /uni04BD /uni04BE /uni04BF '+nl+ //B8
'/uni04C0 /uni04C1 /uni04C2 /uni04C3 /uni04C4 /uni04C5 /uni04C6 /uni04C7 '+nl+ //C0
'/uni04C8 /uni04C9 /uni04CA /uni04CB /uni04CC /uni04CD /uni04CE /uni04CF '+nl+ //C8
'/uni04D0 /uni04D1 /uni04D2 /uni04D3 /uni04D4 /uni04D5 /uni04D6 /uni04D7 '+nl+ //D0
'/uni04D8 /afii10846 /uni04DA /uni04DB /uni04DC /uni04DD /uni04DE /uni04DF '+nl+ //D8
'/uni04E0 /uni04E1 /uni04E2 /uni04E3 /uni04E4 /uni04E5 /uni04E6 /uni04E7 '+nl+ //E0
'/uni04E8 /uni04E9 /uni04EA /uni04EB /uni04EC /uni04ED /uni04EE /uni04EF '+nl+ //E8
'/uni04F0 /uni04F1 /uni04F2 /uni04F3 /uni04F4 /uni04F5 /uni04F6 /uni04F7 '+nl+ //F0
'/uni04F8 /uni04F9 /uni04FA /uni04FB /uni04FC /uni04FD /uni04FE /uni04FF '+nl //F8
   ),                                                                                     
  (
  codepage: $05;
  name: 'E05';         //cyrillic supplement
  glyphnames:
'/uni0500 /uni0501 /uni0502 /uni0503 /uni0504 /uni0505 /uni0506 /uni0507 '+nl+ //00
'/uni0508 /uni0509 /uni050A /uni050B /uni050C /uni050D /uni050E /uni050F '+nl+ //08
'/uni0510 /uni0511 /uni0512 /uni0513 /uni0514 /uni0515 /uni0516 /uni0517 '+nl+ //10
'/uni0518 /uni0519 /uni051A /uni051B /uni051C /uni051D /uni051E /uni051F '+nl+ //18
'/uni0520 /uni0521 /uni0522 /uni0523 /uni0524 /uni0525 /uni0526 /uni0527 '+nl+ //20
'/uni0528 /uni0529 /uni052A /uni052B /uni052C /uni052D /uni052E /uni052F '+nl+ //28
'/uni0530 /uni0531 /uni0532 /uni0533 /uni0534 /uni0535 /uni0536 /uni0537 '+nl+ //30
'/uni0538 /uni0539 /uni053A /uni053B /uni053C /uni053D /uni053E /uni053F '+nl+ //38
'/uni0540 /uni0541 /uni0542 /uni0543 /uni0544 /uni0545 /uni0546 /uni0547 '+nl+ //40
'/uni0548 /uni0549 /uni054A /uni054B /uni054C /uni054D /uni054E /uni054F '+nl+ //48
'/uni0550 /uni0551 /uni0552 /uni0553 /uni0554 /uni0555 /uni0556 /uni0557 '+nl+ //50
'/uni0558 /uni0559 /uni055A /uni055B /uni055C /uni055D /uni055E /uni055F '+nl+ //58
'/uni0560 /uni0561 /uni0562 /uni0563 /uni0564 /uni0565 /uni0566 /uni0567 '+nl+ //60
'/uni0568 /uni0569 /uni056A /uni056B /uni056C /uni056D /uni056E /uni056F '+nl+ //68
'/uni0570 /uni0571 /uni0572 /uni0573 /uni0574 /uni0575 /uni0576 /uni0577 '+nl+ //70
'/uni0578 /uni0579 /uni057A /uni057B /uni057C /uni057D /uni057E /uni057F '+nl+ //78
'/uni0580 /uni0581 /uni0582 /uni0583 /uni0584 /uni0585 /uni0586 /uni0587 '+nl+ //80
'/uni0588 /uni0589 /uni058A /uni058B /uni058C /uni058D /uni058E /uni058F '+nl+ //88
'/uni0590 /uni0591 /uni0592 /uni0593 /uni0594 /uni0595 /uni0596 /uni0597 '+nl+ //90
'/uni0598 /uni0599 /uni059A /uni059B /uni059C /uni059D /uni059E /uni059F '+nl+ //98
'/uni05A0 /uni05A1 /uni05A2 /uni05A3 /uni05A4 /uni05A5 /uni05A6 /uni05A7 '+nl+ //A0
'/uni05A8 /uni05A9 /uni05AA /uni05AB /uni05AC /uni05AD /uni05AE /uni05AF '+nl+ //A8
'/afii57799 /afii57801 /afii57800 /afii57802 /afii57793 /afii57794 /afii57795 /afii57798 '+nl+ //B0
'/afii57797 /afii57806 /uni05BA /afii57796 /afii57807 /afii57839 /afii57645 /afii57841 '+nl+ //B8
'/afii57842 /afii57804 /afii57803 /afii57658 /uni05C4 /uni05C5 /uni05C6 /uni05C7 '+nl+ //C0
'/uni05C8 /uni05C9 /uni05CA /uni05CB /uni05CC /uni05CD /uni05CE /uni05CF '+nl+ //C8
'/afii57664 /afii57665 /afii57666 /afii57667 /afii57668 /afii57669 /afii57670 /afii57671 '+nl+ //D0
'/afii57672 /afii57673 /afii57674 /afii57675 /afii57676 /afii57677 /afii57678 /afii57679 '+nl+ //D8
'/afii57680 /afii57681 /afii57682 /afii57683 /afii57684 /afii57685 /afii57686 /afii57687 '+nl+ //E0
'/afii57688 /afii57689 /afii57690 /uni05EB /uni05EC /uni05ED /uni05EE /uni05EF '+nl+ //E8
'/afii57716 /afii57717 /afii57718 /uni05F3 /uni05F4 /uni05F5 /uni05F6 /uni05F7 '+nl+ //F0
'/uni05F8 /uni05F9 /uni05FA /uni05FB /uni05FC /uni05FD /uni05FE /uni05FF '+nl //F8
   ),                                                                                     
  (
  codepage: $06;
  name: 'E06';         //arabic
  glyphnames:
'/uni0600 /uni0601 /uni0602 /uni0603 /uni0604 /uni0605 /uni0606 /uni0607 '+nl+ //00
'/uni0608 /uni0609 /uni060A /uni060B /afii57388 /uni060D /uni060E /uni060F '+nl+ //08
'/uni0610 /uni0611 /uni0612 /uni0613 /uni0614 /uni0615 /uni0616 /uni0617 '+nl+ //10
'/uni0618 /uni0619 /uni061A /afii57403 /uni061C /uni061D /uni061E /afii57407 '+nl+ //18
'/uni0620 /afii57409 /afii57410 /afii57411 /afii57412 /afii57413 /afii57414 /afii57415 '+nl+ //20
'/afii57416 /afii57417 /afii57418 /afii57419 /afii57420 /afii57421 /afii57422 /afii57423 '+nl+ //28
'/afii57424 /afii57425 /afii57426 /afii57427 /afii57428 /afii57429 /afii57430 /afii57431 '+nl+ //30
'/afii57432 /afii57433 /afii57434 /uni063B /uni063C /uni063D /uni063E /uni063F '+nl+ //38
'/afii57440 /afii57441 /afii57442 /afii57443 /afii57444 /afii57445 /afii57446 /afii57470 '+nl+ //40
'/afii57448 /afii57449 /afii57450 /afii57451 /afii57452 /afii57453 /afii57454 /afii57455 '+nl+ //48
'/afii57456 /afii57457 /afii57458 /uni0653 /uni0654 /uni0655 /uni0656 /uni0657 '+nl+ //50
'/uni0658 /uni0659 /uni065A /uni065B /uni065C /uni065D /uni065E /uni065F '+nl+ //58
'/afii57392 /afii57393 /afii57394 /afii57395 /afii57396 /afii57397 /afii57398 /afii57399 '+nl+ //60
'/afii57400 /afii57401 /afii57381 /uni066B /uni066C /afii63167 /uni066E /uni066F '+nl+ //68
'/uni0670 /uni0671 /uni0672 /uni0673 /uni0674 /uni0675 /uni0676 /uni0677 '+nl+ //70
'/uni0678 /afii57511 /uni067A /uni067B /uni067C /uni067D /afii57506 /uni067F '+nl+ //78
'/uni0680 /uni0681 /uni0682 /uni0683 /uni0684 /uni0685 /afii57507 /uni0687 '+nl+ //80
'/afii57512 /uni0689 /uni068A /uni068B /uni068C /uni068D /uni068E /uni068F '+nl+ //88
'/uni0690 /afii57513 /uni0692 /uni0693 /uni0694 /uni0695 /uni0696 /uni0697 '+nl+ //90
'/afii57508 /uni0699 /uni069A /uni069B /uni069C /uni069D /uni069E /uni069F '+nl+ //98
'/uni06A0 /uni06A1 /uni06A2 /uni06A3 /afii57505 /uni06A5 /uni06A6 /uni06A7 '+nl+ //A0
'/uni06A8 /uni06A9 /uni06AA /uni06AB /uni06AC /uni06AD /uni06AE /afii57509 '+nl+ //A8
'/uni06B0 /uni06B1 /uni06B2 /uni06B3 /uni06B4 /uni06B5 /uni06B6 /uni06B7 '+nl+ //B0
'/uni06B8 /uni06B9 /afii57514 /uni06BB /uni06BC /uni06BD /uni06BE /uni06BF '+nl+ //B8
'/uni06C0 /uni06C1 /uni06C2 /uni06C3 /uni06C4 /uni06C5 /uni06C6 /uni06C7 '+nl+ //C0
'/uni06C8 /uni06C9 /uni06CA /uni06CB /uni06CC /uni06CD /uni06CE /uni06CF '+nl+ //C8
'/uni06D0 /uni06D1 /afii57519 /uni06D3 /uni06D4 /afii57534 /uni06D6 /uni06D7 '+nl+ //D0
'/uni06D8 /uni06D9 /uni06DA /uni06DB /uni06DC /uni06DD /uni06DE /uni06DF '+nl+ //D8
'/uni06E0 /uni06E1 /uni06E2 /uni06E3 /uni06E4 /uni06E5 /uni06E6 /uni06E7 '+nl+ //E0
'/uni06E8 /uni06E9 /uni06EA /uni06EB /uni06EC /uni06ED /uni06EE /uni06EF '+nl+ //E8
'/uni06F0 /uni06F1 /uni06F2 /uni06F3 /uni06F4 /uni06F5 /uni06F6 /uni06F7 '+nl+ //F0
'/uni06F8 /uni06F9 /uni06FA /uni06FB /uni06FC /uni06FD /uni06FE /uni06FF '+nl //F8
   ),                                                                                     
  (
  codepage: $1E;
  name: 'E1E';         //latin extended additional
  glyphnames:
'/uni1E00 /uni1E01 /uni1E02 /uni1E03 /uni1E04 /uni1E05 /uni1E06 /uni1E07 '+nl+ //00
'/uni1E08 /uni1E09 /uni1E0A /uni1E0B /uni1E0C /uni1E0D /uni1E0E /uni1E0F '+nl+ //08
'/uni1E10 /uni1E11 /uni1E12 /uni1E13 /uni1E14 /uni1E15 /uni1E16 /uni1E17 '+nl+ //10
'/uni1E18 /uni1E19 /uni1E1A /uni1E1B /uni1E1C /uni1E1D /uni1E1E /uni1E1F '+nl+ //18
'/uni1E20 /uni1E21 /uni1E22 /uni1E23 /uni1E24 /uni1E25 /uni1E26 /uni1E27 '+nl+ //20
'/uni1E28 /uni1E29 /uni1E2A /uni1E2B /uni1E2C /uni1E2D /uni1E2E /uni1E2F '+nl+ //28
'/uni1E30 /uni1E31 /uni1E32 /uni1E33 /uni1E34 /uni1E35 /uni1E36 /uni1E37 '+nl+ //30
'/uni1E38 /uni1E39 /uni1E3A /uni1E3B /uni1E3C /uni1E3D /uni1E3E /uni1E3F '+nl+ //38
'/uni1E40 /uni1E41 /uni1E42 /uni1E43 /uni1E44 /uni1E45 /uni1E46 /uni1E47 '+nl+ //40
'/uni1E48 /uni1E49 /uni1E4A /uni1E4B /uni1E4C /uni1E4D /uni1E4E /uni1E4F '+nl+ //48
'/uni1E50 /uni1E51 /uni1E52 /uni1E53 /uni1E54 /uni1E55 /uni1E56 /uni1E57 '+nl+ //50
'/uni1E58 /uni1E59 /uni1E5A /uni1E5B /uni1E5C /uni1E5D /uni1E5E /uni1E5F '+nl+ //58
'/uni1E60 /uni1E61 /uni1E62 /uni1E63 /uni1E64 /uni1E65 /uni1E66 /uni1E67 '+nl+ //60
'/uni1E68 /uni1E69 /uni1E6A /uni1E6B /uni1E6C /uni1E6D /uni1E6E /uni1E6F '+nl+ //68
'/uni1E70 /uni1E71 /uni1E72 /uni1E73 /uni1E74 /uni1E75 /uni1E76 /uni1E77 '+nl+ //70
'/uni1E78 /uni1E79 /uni1E7A /uni1E7B /uni1E7C /uni1E7D /uni1E7E /uni1E7F '+nl+ //78
'/Wgrave /wgrave /Wacute /wacute /Wdieresis /wdieresis /uni1E86 /uni1E87 '+nl+ //80
'/uni1E88 /uni1E89 /uni1E8A /uni1E8B /uni1E8C /uni1E8D /uni1E8E /uni1E8F '+nl+ //88
'/uni1E90 /uni1E91 /uni1E92 /uni1E93 /uni1E94 /uni1E95 /uni1E96 /uni1E97 '+nl+ //90
'/uni1E98 /uni1E99 /uni1E9A /uni1E9B /uni1E9C /uni1E9D /uni1E9E /uni1E9F '+nl+ //98
'/uni1EA0 /uni1EA1 /uni1EA2 /uni1EA3 /uni1EA4 /uni1EA5 /uni1EA6 /uni1EA7 '+nl+ //A0
'/uni1EA8 /uni1EA9 /uni1EAA /uni1EAB /uni1EAC /uni1EAD /uni1EAE /uni1EAF '+nl+ //A8
'/uni1EB0 /uni1EB1 /uni1EB2 /uni1EB3 /uni1EB4 /uni1EB5 /uni1EB6 /uni1EB7 '+nl+ //B0
'/uni1EB8 /uni1EB9 /uni1EBA /uni1EBB /uni1EBC /uni1EBD /uni1EBE /uni1EBF '+nl+ //B8
'/uni1EC0 /uni1EC1 /uni1EC2 /uni1EC3 /uni1EC4 /uni1EC5 /uni1EC6 /uni1EC7 '+nl+ //C0
'/uni1EC8 /uni1EC9 /uni1ECA /uni1ECB /uni1ECC /uni1ECD /uni1ECE /uni1ECF '+nl+ //C8
'/uni1ED0 /uni1ED1 /uni1ED2 /uni1ED3 /uni1ED4 /uni1ED5 /uni1ED6 /uni1ED7 '+nl+ //D0
'/uni1ED8 /uni1ED9 /uni1EDA /uni1EDB /uni1EDC /uni1EDD /uni1EDE /uni1EDF '+nl+ //D8
'/uni1EE0 /uni1EE1 /uni1EE2 /uni1EE3 /uni1EE4 /uni1EE5 /uni1EE6 /uni1EE7 '+nl+ //E0
'/uni1EE8 /uni1EE9 /uni1EEA /uni1EEB /uni1EEC /uni1EED /uni1EEE /uni1EEF '+nl+ //E8
'/uni1EF0 /uni1EF1 /Ygrave /ygrave /uni1EF4 /uni1EF5 /uni1EF6 /uni1EF7 '+nl+ //F0
'/uni1EF8 /uni1EF9 /uni1EFA /uni1EFB /uni1EFC /uni1EFD /uni1EFE /uni1EFF '+nl //F8
  ),
  (
  codepage: $20;
  name: 'E20';         //punctuation, currency
  glyphnames:
'/uni2000 /uni2001 /uni2002 /uni2003 /uni2004 /uni2005 /uni2006 /uni2007 '+nl+ //00
'/uni2008 /uni2009 /uni200A /uni200B /afii61664 /afii301 /afii299 /afii300 '+nl+ //08
'/uni2010 /uni2011 /figuredash /endash /emdash /afii00208 /uni2016 /underscoredbl '+nl+ //10
'/quoteleft /quoteright /quotesinglbase /quotereversed /quotedblleft /quotedblright /quotedblbase /uni201F '+nl+ //18
'/dagger /daggerdbl /bullet /uni2023 /onedotenleader /twodotenleader /ellipsis /uni2027 '+nl+ //20
'/uni2028 /uni2029 /uni202A /uni202B /afii61573 /afii61574 /afii61575 /uni202F '+nl+ //28
'/perthousand /uni2031 /minute /second /uni2034 /uni2035 /uni2036 /uni2037 '+nl+ //30
'/uni2038 /guilsinglleft /guilsinglright /uni203B /exclamdbl /uni203D /uni203E /uni203F '+nl+ //38
'/uni2040 /uni2041 /uni2042 /uni2043 /fraction /uni2045 /uni2046 /uni2047 '+nl+ //40
'/uni2048 /uni2049 /uni204A /uni204B /uni204C /uni204D /uni204E /uni204F '+nl+ //48
'/uni2050 /uni2051 /uni2052 /uni2053 /uni2054 /uni2055 /uni2056 /uni2057 '+nl+ //50
'/uni2058 /uni2059 /uni205A /uni205B /uni205C /uni205D /uni205E /uni205F '+nl+ //58
'/uni2060 /uni2061 /uni2062 /uni2063 /uni2064 /uni2065 /uni2066 /uni2067 '+nl+ //60
'/uni2068 /uni2069 /uni206A /uni206B /uni206C /uni206D /uni206E /uni206F '+nl+ //68
'/uni2070 /uni2071 /uni2072 /uni2073 /uni2074 /uni2075 /uni2076 /uni2077 '+nl+ //70
'/uni2078 /uni2079 /uni207A /uni207B /uni207C /uni207D /uni207E /uni207F '+nl+ //78
'/uni2080 /uni2081 /uni2082 /uni2083 /uni2084 /uni2085 /uni2086 /uni2087 '+nl+ //80
'/uni2088 /uni2089 /uni208A /uni208B /uni208C /uni208D /uni208E /uni208F '+nl+ //88
'/uni2090 /uni2091 /uni2092 /uni2093 /uni2094 /uni2095 /uni2096 /uni2097 '+nl+ //90
'/uni2098 /uni2099 /uni209A /uni209B /uni209C /uni209D /uni209E /uni209F '+nl+ //98
'/uni20A0 /colonmonetary /uni20A2 /franc /lira /uni20A5 /uni20A6 /peseta '+nl+ //A0
'/uni20A8 /uni20A9 /afii57636 /dong /Euro /uni20AD /uni20AE /uni20AF '+nl+ //A8
'/uni20B0 /uni20B1 /uni20B2 /uni20B3 /uni20B4 /uni20B5 /uni20B6 /uni20B7 '+nl+ //B0
'/uni20B8 /uni20B9 /uni20BA /uni20BB /uni20BC /uni20BD /uni20BE /uni20BF '+nl+ //B8
'/uni20C0 /uni20C1 /uni20C2 /uni20C3 /uni20C4 /uni20C5 /uni20C6 /uni20C7 '+nl+ //C0
'/uni20C8 /uni20C9 /uni20CA /uni20CB /uni20CC /uni20CD /uni20CE /uni20CF '+nl+ //C8
'/uni20D0 /uni20D1 /uni20D2 /uni20D3 /uni20D4 /uni20D5 /uni20D6 /uni20D7 '+nl+ //D0
'/uni20D8 /uni20D9 /uni20DA /uni20DB /uni20DC /uni20DD /uni20DE /uni20DF '+nl+ //D8
'/uni20E0 /uni20E1 /uni20E2 /uni20E3 /uni20E4 /uni20E5 /uni20E6 /uni20E7 '+nl+ //E0
'/uni20E8 /uni20E9 /uni20EA /uni20EB /uni20EC /uni20ED /uni20EE /uni20EF '+nl+ //E8
'/uni20F0 /uni20F1 /uni20F2 /uni20F3 /uni20F4 /uni20F5 /uni20F6 /uni20F7 '+nl+ //F0
'/uni20F8 /uni20F9 /uni20FA /uni20FB /uni20FC /uni20FD /uni20FE /uni20FF '+nl //F8
  ),
  (
  codepage: $21;
  name: 'E21';         //letterlike symbols
  glyphnames:
'/uni2100 /uni2101 /uni2102 /uni2103 /uni2104 /afii61248 /uni2106 /uni2107 '+nl+ //00
'/uni2108 /uni2109 /uni210A /uni210B /uni210C /uni210D /uni210E /uni210F '+nl+ //08
'/uni2110 /Ifraktur /uni2112 /afii61289 /uni2114 /uni2115 /afii61352 /uni2117 '+nl+ //10
'/weierstrass /uni2119 /uni211A /uni211B /Rfraktur /uni211D /prescription /uni211F '+nl+ //18
'/uni2120 /uni2121 /trademark /uni2123 /uni2124 /uni2125 /uni2126 /uni2127 '+nl+ //20
'/uni2128 /uni2129 /uni212A /uni212B /uni212C /uni212D /estimated /uni212F '+nl+ //28
'/uni2130 /uni2131 /uni2132 /uni2133 /uni2134 /aleph /uni2136 /uni2137 '+nl+ //30
'/uni2138 /uni2139 /uni213A /uni213B /uni213C /uni213D /uni213E /uni213F '+nl+ //38
'/uni2140 /uni2141 /uni2142 /uni2143 /uni2144 /uni2145 /uni2146 /uni2147 '+nl+ //40
'/uni2148 /uni2149 /uni214A /uni214B /uni214C /uni214D /uni214E /uni214F '+nl+ //48
'/uni2150 /uni2151 /uni2152 /onethird /twothirds /uni2155 /uni2156 /uni2157 '+nl+ //50
'/uni2158 /uni2159 /uni215A /oneeighth /threeeighths /fiveeighths /seveneighths /uni215F '+nl+ //58
'/uni2160 /uni2161 /uni2162 /uni2163 /uni2164 /uni2165 /uni2166 /uni2167 '+nl+ //60
'/uni2168 /uni2169 /uni216A /uni216B /uni216C /uni216D /uni216E /uni216F '+nl+ //68
'/uni2170 /uni2171 /uni2172 /uni2173 /uni2174 /uni2175 /uni2176 /uni2177 '+nl+ //70
'/uni2178 /uni2179 /uni217A /uni217B /uni217C /uni217D /uni217E /uni217F '+nl+ //78
'/uni2180 /uni2181 /uni2182 /uni2183 /uni2184 /uni2185 /uni2186 /uni2187 '+nl+ //80
'/uni2188 /uni2189 /uni218A /uni218B /uni218C /uni218D /uni218E /uni218F '+nl+ //88
'/arrowleft /arrowup /arrowright /arrowdown /arrowboth /arrowupdn /uni2196 /uni2197 '+nl+ //90
'/uni2198 /uni2199 /uni219A /uni219B /uni219C /uni219D /uni219E /uni219F '+nl+ //98
'/uni21A0 /uni21A1 /uni21A2 /uni21A3 /uni21A4 /uni21A5 /uni21A6 /uni21A7 '+nl+ //A0
'/arrowupdnbse /uni21A9 /uni21AA /uni21AB /uni21AC /uni21AD /uni21AE /uni21AF '+nl+ //A8
'/uni21B0 /uni21B1 /uni21B2 /uni21B3 /uni21B4 /carriagereturn /uni21B6 /uni21B7 '+nl+ //B0
'/uni21B8 /uni21B9 /uni21BA /uni21BB /uni21BC /uni21BD /uni21BE /uni21BF '+nl+ //B8
'/uni21C0 /uni21C1 /uni21C2 /uni21C3 /uni21C4 /uni21C5 /uni21C6 /uni21C7 '+nl+ //C0
'/uni21C8 /uni21C9 /uni21CA /uni21CB /uni21CC /uni21CD /uni21CE /uni21CF '+nl+ //C8
'/arrowdblleft /arrowdblup /arrowdblright /arrowdbldown /arrowdblboth /uni21D5 /uni21D6 /uni21D7 '+nl+ //D0
'/uni21D8 /uni21D9 /uni21DA /uni21DB /uni21DC /uni21DD /uni21DE /uni21DF '+nl+ //D8
'/uni21E0 /uni21E1 /uni21E2 /uni21E3 /uni21E4 /uni21E5 /uni21E6 /uni21E7 '+nl+ //E0
'/uni21E8 /uni21E9 /uni21EA /uni21EB /uni21EC /uni21ED /uni21EE /uni21EF '+nl+ //E8
'/uni21F0 /uni21F1 /uni21F2 /uni21F3 /uni21F4 /uni21F5 /uni21F6 /uni21F7 '+nl+ //F0
'/uni21F8 /uni21F9 /uni21FA /uni21FB /uni21FC /uni21FD /uni21FE /uni21FF '+nl //F8
  ),
  (
  codepage: $22;
  name: 'E22';         //mathematical operators
  glyphnames:
'/universal /uni2201 /partialdiff /existential /uni2204 /emptyset /uni2206 /gradient '+nl+ //00
'/element /notelement /uni220A /suchthat /uni220C /uni220D /uni220E /product '+nl+ //08
'/uni2210 /summation /minus /uni2213 /uni2214 /uni2215 /uni2216 /asteriskmath '+nl+ //10
'/uni2218 /uni2219 /radical /uni221B /uni221C /proportional /infinity /orthogonal '+nl+ //18
'/angle /uni2221 /uni2222 /uni2223 /uni2224 /uni2225 /uni2226 /logicaland '+nl+ //20
'/logicalor /intersection /union /integral /uni222C /uni222D /uni222E /uni222F '+nl+ //28
'/uni2230 /uni2231 /uni2232 /uni2233 /therefore /uni2235 /uni2236 /uni2237 '+nl+ //30
'/uni2238 /uni2239 /uni223A /uni223B /similar /uni223D /uni223E /uni223F '+nl+ //38
'/uni2240 /uni2241 /uni2242 /uni2243 /uni2244 /congruent /uni2246 /uni2247 '+nl+ //40
'/approxequal /uni2249 /uni224A /uni224B /uni224C /uni224D /uni224E /uni224F '+nl+ //48
'/uni2250 /uni2251 /uni2252 /uni2253 /uni2254 /uni2255 /uni2256 /uni2257 '+nl+ //50
'/uni2258 /uni2259 /uni225A /uni225B /uni225C /uni225D /uni225E /uni225F '+nl+ //58
'/notequal /equivalence /uni2262 /uni2263 /lessequal /greaterequal /uni2266 /uni2267 '+nl+ //60
'/uni2268 /uni2269 /uni226A /uni226B /uni226C /uni226D /uni226E /uni226F '+nl+ //68
'/uni2270 /uni2271 /uni2272 /uni2273 /uni2274 /uni2275 /uni2276 /uni2277 '+nl+ //70
'/uni2278 /uni2279 /uni227A /uni227B /uni227C /uni227D /uni227E /uni227F '+nl+ //78
'/uni2280 /uni2281 /propersubset /propersuperset /notsubset /uni2285 /reflexsubset /reflexsuperset '+nl+ //80
'/uni2288 /uni2289 /uni228A /uni228B /uni228C /uni228D /uni228E /uni228F '+nl+ //88
'/uni2290 /uni2291 /uni2292 /uni2293 /uni2294 /circleplus /uni2296 /circlemultiply '+nl+ //90
'/uni2298 /uni2299 /uni229A /uni229B /uni229C /uni229D /uni229E /uni229F '+nl+ //98
'/uni22A0 /uni22A1 /uni22A2 /uni22A3 /uni22A4 /perpendicular /uni22A6 /uni22A7 '+nl+ //A0
'/uni22A8 /uni22A9 /uni22AA /uni22AB /uni22AC /uni22AD /uni22AE /uni22AF '+nl+ //A8
'/uni22B0 /uni22B1 /uni22B2 /uni22B3 /uni22B4 /uni22B5 /uni22B6 /uni22B7 '+nl+ //B0
'/uni22B8 /uni22B9 /uni22BA /uni22BB /uni22BC /uni22BD /uni22BE /uni22BF '+nl+ //B8
'/uni22C0 /uni22C1 /uni22C2 /uni22C3 /uni22C4 /dotmath /uni22C6 /uni22C7 '+nl+ //C0
'/uni22C8 /uni22C9 /uni22CA /uni22CB /uni22CC /uni22CD /uni22CE /uni22CF '+nl+ //C8
'/uni22D0 /uni22D1 /uni22D2 /uni22D3 /uni22D4 /uni22D5 /uni22D6 /uni22D7 '+nl+ //D0
'/uni22D8 /uni22D9 /uni22DA /uni22DB /uni22DC /uni22DD /uni22DE /uni22DF '+nl+ //D8
'/uni22E0 /uni22E1 /uni22E2 /uni22E3 /uni22E4 /uni22E5 /uni22E6 /uni22E7 '+nl+ //E0
'/uni22E8 /uni22E9 /uni22EA /uni22EB /uni22EC /uni22ED /uni22EE /uni22EF '+nl+ //E8
'/uni22F0 /uni22F1 /uni22F2 /uni22F3 /uni22F4 /uni22F5 /uni22F6 /uni22F7 '+nl+ //F0
'/uni22F8 /uni22F9 /uni22FA /uni22FB /uni22FC /uni22FD /uni22FE /uni22FF '+nl //F8
  ),
  (
  codepage: $23;
  name: 'E23';         //technical symbols
  glyphnames:
'/uni2300 /uni2301 /house /uni2303 /uni2304 /uni2305 /uni2306 /uni2307 '+nl+ //00
'/uni2308 /uni2309 /uni230A /uni230B /uni230C /uni230D /uni230E /uni230F '+nl+ //08
'/revlogicalnot /uni2311 /uni2312 /uni2313 /uni2314 /uni2315 /uni2316 /uni2317 '+nl+ //10
'/uni2318 /uni2319 /uni231A /uni231B /uni231C /uni231D /uni231E /uni231F '+nl+ //18
'/integraltp /integralbt /uni2322 /uni2323 /uni2324 /uni2325 /uni2326 /uni2327 '+nl+ //20
'/uni2328 /angleleft /angleright /uni232B /uni232C /uni232D /uni232E /uni232F '+nl+ //28
'/uni2330 /uni2331 /uni2332 /uni2333 /uni2334 /uni2335 /uni2336 /uni2337 '+nl+ //30
'/uni2338 /uni2339 /uni233A /uni233B /uni233C /uni233D /uni233E /uni233F '+nl+ //38
'/uni2340 /uni2341 /uni2342 /uni2343 /uni2344 /uni2345 /uni2346 /uni2347 '+nl+ //40
'/uni2348 /uni2349 /uni234A /uni234B /uni234C /uni234D /uni234E /uni234F '+nl+ //48
'/uni2350 /uni2351 /uni2352 /uni2353 /uni2354 /uni2355 /uni2356 /uni2357 '+nl+ //50
'/uni2358 /uni2359 /uni235A /uni235B /uni235C /uni235D /uni235E /uni235F '+nl+ //58
'/uni2360 /uni2361 /uni2362 /uni2363 /uni2364 /uni2365 /uni2366 /uni2367 '+nl+ //60
'/uni2368 /uni2369 /uni236A /uni236B /uni236C /uni236D /uni236E /uni236F '+nl+ //68
'/uni2370 /uni2371 /uni2372 /uni2373 /uni2374 /uni2375 /uni2376 /uni2377 '+nl+ //70
'/uni2378 /uni2379 /uni237A /uni237B /uni237C /uni237D /uni237E /uni237F '+nl+ //78
'/uni2380 /uni2381 /uni2382 /uni2383 /uni2384 /uni2385 /uni2386 /uni2387 '+nl+ //80
'/uni2388 /uni2389 /uni238A /uni238B /uni238C /uni238D /uni238E /uni238F '+nl+ //88
'/uni2390 /uni2391 /uni2392 /uni2393 /uni2394 /uni2395 /uni2396 /uni2397 '+nl+ //90
'/uni2398 /uni2399 /uni239A /uni239B /uni239C /uni239D /uni239E /uni239F '+nl+ //98
'/uni23A0 /uni23A1 /uni23A2 /uni23A3 /uni23A4 /uni23A5 /uni23A6 /uni23A7 '+nl+ //A0
'/uni23A8 /uni23A9 /uni23AA /uni23AB /uni23AC /uni23AD /uni23AE /uni23AF '+nl+ //A8
'/uni23B0 /uni23B1 /uni23B2 /uni23B3 /uni23B4 /uni23B5 /uni23B6 /uni23B7 '+nl+ //B0
'/uni23B8 /uni23B9 /uni23BA /uni23BB /uni23BC /uni23BD /uni23BE /uni23BF '+nl+ //B8
'/uni23C0 /uni23C1 /uni23C2 /uni23C3 /uni23C4 /uni23C5 /uni23C6 /uni23C7 '+nl+ //C0
'/uni23C8 /uni23C9 /uni23CA /uni23CB /uni23CC /uni23CD /uni23CE /uni23CF '+nl+ //C8
'/uni23D0 /uni23D1 /uni23D2 /uni23D3 /uni23D4 /uni23D5 /uni23D6 /uni23D7 '+nl+ //D0
'/uni23D8 /uni23D9 /uni23DA /uni23DB /uni23DC /uni23DD /uni23DE /uni23DF '+nl+ //D8
'/uni23E0 /uni23E1 /uni23E2 /uni23E3 /uni23E4 /uni23E5 /uni23E6 /uni23E7 '+nl+ //E0
'/uni23E8 /uni23E9 /uni23EA /uni23EB /uni23EC /uni23ED /uni23EE /uni23EF '+nl+ //E8
'/uni23F0 /uni23F1 /uni23F2 /uni23F3 /uni23F4 /uni23F5 /uni23F6 /uni23F7 '+nl+ //F0
'/uni23F8 /uni23F9 /uni23FA /uni23FB /uni23FC /uni23FD /uni23FE /uni23FF '+nl //F8
  ),
  (
  codepage: $25;
  name: 'E25';         //box drawing
  glyphnames:
'/SF100000 /uni2501 /SF110000 /uni2503 /uni2504 /uni2505 /uni2506 /uni2507 '+nl+ //00
'/uni2508 /uni2509 /uni250A /uni250B /SF010000 /uni250D /uni250E /uni250F '+nl+ //08
'/SF030000 /uni2511 /uni2512 /uni2513 /SF020000 /uni2515 /uni2516 /uni2517 '+nl+ //10
'/SF040000 /uni2519 /uni251A /uni251B /SF080000 /uni251D /uni251E /uni251F '+nl+ //18
'/uni2520 /uni2521 /uni2522 /uni2523 /SF090000 /uni2525 /uni2526 /uni2527 '+nl+ //20
'/uni2528 /uni2529 /uni252A /uni252B /SF060000 /uni252D /uni252E /uni252F '+nl+ //28
'/uni2530 /uni2531 /uni2532 /uni2533 /SF070000 /uni2535 /uni2536 /uni2537 '+nl+ //30
'/uni2538 /uni2539 /uni253A /uni253B /SF050000 /uni253D /uni253E /uni253F '+nl+ //38
'/uni2540 /uni2541 /uni2542 /uni2543 /uni2544 /uni2545 /uni2546 /uni2547 '+nl+ //40
'/uni2548 /uni2549 /uni254A /uni254B /uni254C /uni254D /uni254E /uni254F '+nl+ //48
'/SF430000 /SF240000 /SF510000 /SF520000 /SF390000 /SF220000 /SF210000 /SF250000 '+nl+ //50
'/SF500000 /SF490000 /SF380000 /SF280000 /SF270000 /SF260000 /SF360000 /SF370000 '+nl+ //58
'/SF420000 /SF190000 /SF200000 /SF230000 /SF470000 /SF480000 /SF410000 /SF450000 '+nl+ //60
'/SF460000 /SF400000 /SF540000 /SF530000 /SF440000 /uni256D /uni256E /uni256F '+nl+ //68
'/uni2570 /uni2571 /uni2572 /uni2573 /uni2574 /uni2575 /uni2576 /uni2577 '+nl+ //70
'/uni2578 /uni2579 /uni257A /uni257B /uni257C /uni257D /uni257E /uni257F '+nl+ //78
'/upblock /uni2581 /uni2582 /uni2583 /dnblock /uni2585 /uni2586 /uni2587 '+nl+ //80
'/block /uni2589 /uni258A /uni258B /lfblock /uni258D /uni258E /uni258F '+nl+ //88
'/rtblock /ltshade /shade /dkshade /uni2594 /uni2595 /uni2596 /uni2597 '+nl+ //90
'/uni2598 /uni2599 /uni259A /uni259B /uni259C /uni259D /uni259E /uni259F '+nl+ //98
'/filledbox /H22073 /uni25A2 /uni25A3 /uni25A4 /uni25A5 /uni25A6 /uni25A7 '+nl+ //A0
'/uni25A8 /uni25A9 /H18543 /H18551 /filledrect /uni25AD /uni25AE /uni25AF '+nl+ //A8
'/uni25B0 /uni25B1 /triagup /uni25B3 /uni25B4 /uni25B5 /uni25B6 /uni25B7 '+nl+ //B0
'/uni25B8 /uni25B9 /triagrt /uni25BB /triagdn /uni25BD /uni25BE /uni25BF '+nl+ //B8
'/uni25C0 /uni25C1 /uni25C2 /uni25C3 /triaglf /uni25C5 /uni25C6 /uni25C7 '+nl+ //C0
'/uni25C8 /uni25C9 /lozenge /circle /uni25CC /uni25CD /uni25CE /H18533 '+nl+ //C8
'/uni25D0 /uni25D1 /uni25D2 /uni25D3 /uni25D4 /uni25D5 /uni25D6 /uni25D7 '+nl+ //D0
'/invbullet /invcircle /uni25DA /uni25DB /uni25DC /uni25DD /uni25DE /uni25DF '+nl+ //D8
'/uni25E0 /uni25E1 /uni25E2 /uni25E3 /uni25E4 /uni25E5 /openbullet /uni25E7 '+nl+ //E0
'/uni25E8 /uni25E9 /uni25EA /uni25EB /uni25EC /uni25ED /uni25EE /uni25EF '+nl+ //E8
'/uni25F0 /uni25F1 /uni25F2 /uni25F3 /uni25F4 /uni25F5 /uni25F6 /uni25F7 '+nl+ //F0
'/uni25F8 /uni25F9 /uni25FA /uni25FB /uni25FC /uni25FD /uni25FE /uni25FF '+nl //F8
  ),
  (
  codepage: $26;
  name: 'E26';         //miscellaneous symbols
  glyphnames:
'/uni2600 /uni2601 /uni2602 /uni2603 /uni2604 /uni2605 /uni2606 /uni2607 '+nl+ //00
'/uni2608 /uni2609 /uni260A /uni260B /uni260C /uni260D /uni260E /uni260F '+nl+ //08
'/uni2610 /uni2611 /uni2612 /uni2613 /uni2614 /uni2615 /uni2616 /uni2617 '+nl+ //10
'/uni2618 /uni2619 /uni261A /uni261B /uni261C /uni261D /uni261E /uni261F '+nl+ //18
'/uni2620 /uni2621 /uni2622 /uni2623 /uni2624 /uni2625 /uni2626 /uni2627 '+nl+ //20
'/uni2628 /uni2629 /uni262A /uni262B /uni262C /uni262D /uni262E /uni262F '+nl+ //28
'/uni2630 /uni2631 /uni2632 /uni2633 /uni2634 /uni2635 /uni2636 /uni2637 '+nl+ //30
'/uni2638 /uni2639 /smileface /invsmileface /sun /uni263D /uni263E /uni263F '+nl+ //38
'/female /uni2641 /male /uni2643 /uni2644 /uni2645 /uni2646 /uni2647 '+nl+ //40
'/uni2648 /uni2649 /uni264A /uni264B /uni264C /uni264D /uni264E /uni264F '+nl+ //48
'/uni2650 /uni2651 /uni2652 /uni2653 /uni2654 /uni2655 /uni2656 /uni2657 '+nl+ //50
'/uni2658 /uni2659 /uni265A /uni265B /uni265C /uni265D /uni265E /uni265F '+nl+ //58
'/spade /uni2661 /uni2662 /club /uni2664 /heart /diamond /uni2667 '+nl+ //60
'/uni2668 /uni2669 /musicalnote /musicalnotedbl /uni266C /uni266D /uni266E /uni266F '+nl+ //68
'/uni2670 /uni2671 /uni2672 /uni2673 /uni2674 /uni2675 /uni2676 /uni2677 '+nl+ //70
'/uni2678 /uni2679 /uni267A /uni267B /uni267C /uni267D /uni267E /uni267F '+nl+ //78
'/uni2680 /uni2681 /uni2682 /uni2683 /uni2684 /uni2685 /uni2686 /uni2687 '+nl+ //80
'/uni2688 /uni2689 /uni268A /uni268B /uni268C /uni268D /uni268E /uni268F '+nl+ //88
'/uni2690 /uni2691 /uni2692 /uni2693 /uni2694 /uni2695 /uni2696 /uni2697 '+nl+ //90
'/uni2698 /uni2699 /uni269A /uni269B /uni269C /uni269D /uni269E /uni269F '+nl+ //98
'/uni26A0 /uni26A1 /uni26A2 /uni26A3 /uni26A4 /uni26A5 /uni26A6 /uni26A7 '+nl+ //A0
'/uni26A8 /uni26A9 /uni26AA /uni26AB /uni26AC /uni26AD /uni26AE /uni26AF '+nl+ //A8
'/uni26B0 /uni26B1 /uni26B2 /uni26B3 /uni26B4 /uni26B5 /uni26B6 /uni26B7 '+nl+ //B0
'/uni26B8 /uni26B9 /uni26BA /uni26BB /uni26BC /uni26BD /uni26BE /uni26BF '+nl+ //B8
'/uni26C0 /uni26C1 /uni26C2 /uni26C3 /uni26C4 /uni26C5 /uni26C6 /uni26C7 '+nl+ //C0
'/uni26C8 /uni26C9 /uni26CA /uni26CB /uni26CC /uni26CD /uni26CE /uni26CF '+nl+ //C8
'/uni26D0 /uni26D1 /uni26D2 /uni26D3 /uni26D4 /uni26D5 /uni26D6 /uni26D7 '+nl+ //D0
'/uni26D8 /uni26D9 /uni26DA /uni26DB /uni26DC /uni26DD /uni26DE /uni26DF '+nl+ //D8
'/uni26E0 /uni26E1 /uni26E2 /uni26E3 /uni26E4 /uni26E5 /uni26E6 /uni26E7 '+nl+ //E0
'/uni26E8 /uni26E9 /uni26EA /uni26EB /uni26EC /uni26ED /uni26EE /uni26EF '+nl+ //E8
'/uni26F0 /uni26F1 /uni26F2 /uni26F3 /uni26F4 /uni26F5 /uni26F6 /uni26F7 '+nl+ //F0
'/uni26F8 /uni26F9 /uni26FA /uni26FB /uni26FC /uni26FD /uni26FE /uni26FF '+nl //F8
  )
 );
{   
 undefmap: encodingty = (
  codepage: -1;
  name: 'Exx';
  glyphnames:
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //00 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //08
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //10 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //18
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //20 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //28
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //30 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //38
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //40 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //48
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //50 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //58
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //60 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //68
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //70 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //78
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //80 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //88
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //90 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //98
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //a0 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //a8
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //b0 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //b8
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //c0 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //c8
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //d0 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //d8
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //e0 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //e8
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //f0 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl       //f8
 );
}
implementation
end.
