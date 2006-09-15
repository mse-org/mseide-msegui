unit mseunicodeps;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface

uses
 msestrings;
 
type
 unicodepagety = (ucp_00,ucp_01,ucp_02,ucp_03,ucp_04,ucp_1e,
                  ucp_20,ucp_21,ucp_22,ucp_25);
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
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //00
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //08
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //10
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //18
'/space /exclam /quotedbl /numbersign /dollar /percent /ampersand /quoteright '+nl+ //20
'/parenleft /parenright /asterisk /plus /comma /minus /period /slash '+nl+          //28
'/zero /one /two /three /four /five /six /seven '+nl+                               //30
'/eight /nine /colon /semicolon /less /equal /greater /question '+nl+               //38
'/at /A /B /C /D /E /F /G '+nl+                                                     //40
'/H /I /J /K /L /M /N /O '+nl+                                                      //48
'/P /Q /R /S /T /U /V /W '+nl+                                                      //50
'/X /Y /Z /bracketleft /backslash /bracketright /asciicircum /underscore '+nl+      //58
'/quoteleft /a /b /c /d /e /f /g '+nl+                                              //60
'/h /i /j /k /l /m /n /o '+nl+                                                      //68
'/p /q /r /s /t /u /v /w '+nl+                                                      //70
'/x /y /z /braceleft /bar /braceright /asciitilde /.notdef '+nl+                    //78
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //80 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //88
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //90 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+      //98
'/space /exclamdown /cent /sterling /currency /yen /brokenbar /section '+nl+        //a0
'/dieresis /copyright /ordfeminine /guillemotleft /logicalnot /hyphen /registered /macron'+nl+ 
                                                                                    //a8
'/degree /plusminus /twosuperior /threesuperior /acute /mu /paragraph /bullet '+nl+ //b0
'/cedilla /onesuperior /ordmasculine /guillemotright /onequarter /onehalf /threequarters /questiondown '+nl+
                                                                                    //b8
'/Agrave /Aacute /Acircumflex /Atilde /Adieresis /Aring /AE /Ccedilla '+nl+         //c0
'/Egrave /Eacute /Ecircumflex /Edieresis /Igrave /Iacute /Icircumflex /Idieresis '+nl+ 
                                                                                    //c8
'/Eth /Ntilde /Ograve /Oacute /Ocircumflex /Otilde /Odieresis /multiply '+nl+       //d0
'/Oslash /Ugrave /Uacute /Ucircumflex /Udieresis /Yacute /Thorn /germandbls '+nl+   //d8
'/agrave /aacute /acircumflex /atilde /adieresis /aring /ae /ccedilla '+nl+         //e0
'/egrave /eacute /ecircumflex /edieresis /igrave /iacute /icircumflex /idieresis '+nl+ 
                                                                                    //e8
'/eth /ntilde /ograve /oacute /ocircumflex /otilde /odieresis /divide '+nl+         //f0
'/oslash /ugrave /uacute /ucircumflex /udieresis /yacute /thorn /ydieresis '+nl    //f8
  ),
  (
  codepage: $01;
  name: 'E01';         //latin extended A
  glyphnames:
'/Amacron /amacron /Abreve /abreve /Aogonek /aogonek /Cacute /cacute /Ccircumflex'+nl+//00
'/ccircumflex /Cdotaccent /cdotaccent /Ccaron /ccaron /Dcaron /dcaron'+nl+//08
'/Dcroat /dcroat /Emacron /emacron /Ebreve /ebreve /Edotaccent /edotaccent'+nl+//10
'/Eogonek /eogonek /Ecaron /ecaron /Gcircumflex /gcircumflex /Gbreve /gbreve'+nl+//18
'/Gdotaccent /gdotaccent /Gcommaaccent /gcommaaccent /Hcircumflex /hcircumflex /Hbar /hbar'+nl+//20
'/Itilde /itilde /Imacron /imacron /Ibreve /ibreve /Iogonek /iogonek'+nl+//28
'/Idotaccent /dotlessi /IJ /ij /Jcircumflex /jcircumflex /Kcommaaccent/kcommaaccent'+nl+//30
'/kgreenlandic /Lacute /lacute /Lcommaaccent /lcommaaccent /Lcaron /lcaron /Ldot'+nl+//38
'/ldot /Lslash /lslash /Nacute /nacute /Ncommaaccent /ncommaaccent /Ncaron'+nl+//40
'/ncaron /napostrophe /Eng /eng /Omacron /omacron /Obreve /obreve'+nl+//48
'/Ohungarumlaut /ohungarumlaut /OE /oe /Racute /racute /Rcommaaccent /rcommaaccent'+nl+//50
'/Rcaron /rcaron /Sacute /sacute /Scircumflex /scircumflex /Scedilla /scedilla'+nl+//58
'/Scaron /scaron /uni0162 /uni0163 /Tcaron /tcaron /Tbar /tbar'+nl+//60
'/Utilde /utilde /Umacron /umacron /Ubreve /ubreve /Uring /uring'+nl+//68
'/Uhungarumlaut /uhungarumlaut /Uogonek /uogonek /Wcircumflex /wcircumflex /Ycircumflex /ycircumflex'+nl+//70
'/Ydieresis /Zacute /zacute /Zdotaccent /zdotaccent /Zcaron /zcaron /longs'+nl+//78
'/uni0180 /uni0181 /uni0182 /uni0183 /uni0184 /uni0185 /uni0186 /uni0187'+nl+//80
'/uni0188 /uni0189 /uni018A /uni018B /uni018C /uni018D /uni018E /uni018F'+nl+//88
'/uni0190 /uni0191 /florin /uni0193 /uni0194 /uni0195 /uni0196 /uni0197'+nl+//90
'/uni0198 /uni0199 /uni019A /uni019B /uni019C /uni019D /uni019E /uni019F'+nl+//98
'/Ohorn /ohorn /uni01A2 /uni01A3 /uni01A4 /uni01A5 /uni01A6 /uni01A7'+nl+//a0
'/uni01A8 /uni01A9 /uni01AA /uni01AB /uni01AC /uni01AD /uni01AE /Uhorn'+nl+//a8
'/uhorn /uni01B1 /uni01B2 /uni01B3 /uni01B4 /uni01B5 /uni01B6 /uni01B7'+nl+//b0
'/uni01B8 /uni01B9 /uni01BA /uni01BB /uni01BC /uni01BD /uni01BE /uni01BF'+nl+//b8
'/uni01C0 /uni01C1 /uni01C2 /uni01C3 /uni01C4 /uni01C5 /uni01C6 /uni01C7'+nl+//c0
'/uni01C8 /uni01C9 /uni01CA /uni01CB /uni01CC /uni01CD /uni01CE /uni01CF'+nl+//c8
'/uni01D0 /uni01D1 /uni01D2 /uni01D3 /uni01D4 /uni01D5 /uni01D6 /uni01D7'+nl+//d0
'/uni01D8 /uni01D9 /uni01DA /uni01DB /uni01DC /uni01DD /uni01DE /uni01DF'+nl+//d8
'/uni01E0 /uni01E1 /uni01E2 /uni01E3 /uni01E4 /uni01E5 /Gcaron /gcaron'+nl+//e0
'/uni01E8 /uni01E9 /uni01EA /uni01EB /uni01EC /uni01ED /uni01EE /uni01EF'+nl+//e8
'/uni01F0 /uni01F1 /uni01F2 /uni01F3 /uni01F4 /uni01F5 /uni01F6 /uni01F7'+nl+//f0
'/uni01F8 /uni01F9 /Aringacute /aringacute /AEacute /aeacute /Oslashacute /oslashacute'+nl//f8
  ),
  (
  codepage: $02;
  name: 'E02';         //latin extended B
  glyphnames:
'/uni0200 /uni0201 /uni0202 /uni0203 /uni0204 /uni0205 /uni0206 /uni0207'+nl+//00
'/uni0208 /uni0209 /uni020A /uni020B /uni020C /uni020D /uni020E /uni020F'+nl+//08
'/uni0210 /uni0211 /uni0212 /uni0213 /uni0214 /uni0215 /uni0216 /uni0217'+nl+//10
'/Scommaaccent /scommaaccent /Tcommaaccent /tcommaaccent /uni021C /uni021D /uni021E /uni021F'+nl+ //18
'/uni0220 /uni0221 /uni0222 /uni0223 /uni0224 /uni0225 /uni0226 /uni0227'+nl+//20
'/uni0228 /uni0229 /uni022A /uni022B /uni022C /uni022D /uni022E /uni022F'+nl+//28
'/uni0230 /uni0231 /uni0232 /uni0233 /uni0234 /uni0235 /uni0236 /uni0237'+nl+//30
'/uni0238 /uni0239 /uni023A /uni023B /uni023C /uni023D /uni023E /uni023F'+nl+//38
'/uni0240 /uni0241 /uni0242 /uni0243 /uni0244 /uni0245 /uni0246 /uni0247'+nl+//40
'/uni0248 /uni0249 /uni024A /uni024B /uni024C /uni024D /uni024E /uni024F'+nl+//48
'/uni0250 /uni0251 /uni0252 /uni0253 /uni0254 /uni0255 /uni0256 /uni0257'+nl+//50
'/uni0258 /uni0259 /uni025A /uni025B /uni025C /uni025D /uni025E /uni025F'+nl+//58
'/uni0260 /uni0261 /uni0262 /uni0263 /uni0264 /uni0265 /uni0266 /uni0267'+nl+//60
'/uni0268 /uni0269 /uni026A /uni026B /uni026C /uni026D /uni026E /uni026F'+nl+//68
'/uni0270 /uni0271 /uni0272 /uni0273 /uni0274 /uni0275 /uni0276 /uni0277'+nl+//70
'/uni0278 /uni0279 /uni027A /uni027B /uni027C /uni027D /uni027E /uni027F'+nl+//78
'/uni0280 /uni0281 /uni0282 /uni0283 /uni0284 /uni0285 /uni0286 /uni0287'+nl+//80
'/uni0288 /uni0289 /uni028A /uni028B /uni028C /uni028D /uni028E /uni028F'+nl+//88
'/uni0290 /uni0291 /uni0292 /uni0293 /uni0294 /uni0295 /uni0296 /uni0297'+nl+//90
'/uni0298 /uni0299 /uni029A /uni029B /uni029C /uni029D /uni029E /uni029F'+nl+//98
'/uni02A0 /uni02A1 /uni02A2 /uni02A3 /uni02A4 /uni02A5 /uni02A6 /uni02A7'+nl+//a0
'/uni02A8 /uni02A9 /uni02AA /uni02AB /uni02AC /uni02AD /uni02AE /uni02AF'+nl+//a8
'/uni02B0 /uni02B1 /uni02B2 /uni02B3 /uni02B4 /uni02B5 /uni02B6 /uni02B7'+nl+//b0
'/uni02B8 /uni02B9 /uni02BA /uni02BB /afii57929 /afii64937 /uni02BE /uni02BF'+nl+//b8
'/uni02C0 /uni02C1 /uni02C2 /uni02C3 /uni02C4 /uni02C5 /circumflex /caron'+nl+//c0
'/uni02C8 /uni02C9 /uni02CA /uni02CB /uni02CC /uni02CD /uni02CE /uni02CF'+nl+//c8
'/uni02D0 /uni02D1 /uni02D2 /uni02D3 /uni02D4 /uni02D5 /uni02D6 /uni02D7'+nl+//d0
'/breve /dotaccent /ring /ogonek /tilde /hungarumlaut /uni02DE /uni02DF'+nl+//d8
'/uni02E0 /uni02E1 /uni02E2 /uni02E3 /uni02E4 /uni02E5 /uni02E6 /uni02E7'+nl+//e0
'/uni02E8 /uni02E9 /uni02EA /uni02EB /uni02EC /uni02ED /uni02EE /uni02EF'+nl+//e8
'/uni02F0 /uni02F1 /uni02F2 /uni02F3 /uni02F4 /uni02F5 /uni02F6 /uni02F7'+nl+//f0
'/uni02F8 /uni02F9 /uni02FA /uni02FB /uni02FC /uni02FD /uni02FE /uni02FF'+nl //f8
  ),
  (
  codepage: $03;
  name: 'E03';         //greek
  glyphnames:
'/gravecomb /acutecomb /uni0302 /tildecomb /uni0304 /uni0305 /uni0306 /uni0307'+nl+//00
'/uni0308 /hookabovecomb /uni030A /uni030B /uni030C /uni030D /uni030E /uni030F'+nl+//08
'/uni0310 /uni0311 /uni0312 /uni0313 /uni0314 /uni0315 /uni0316 /uni0317'+nl+//10
'/uni0318 /uni0319 /uni031A /uni031B /uni031C /uni031D /uni031E /uni031F'+nl+//18
'/uni0320 /uni0321 /uni0322 /dotbelowcomb /uni0324 /uni0325 /uni0326 /uni0327'+nl+//20
'/uni0328 /uni0329 /uni032A /uni032B /uni032C /uni032D /uni032E /uni032F'+nl+//28
'/uni0330 /uni0331 /uni0332 /uni0333 /uni0334 /uni0335 /uni0336 /uni0337'+nl+//30
'/uni0338 /uni0339 /uni033A /uni033B /uni033C /uni033D /uni033E /uni033F'+nl+//38
'/uni0340 /uni0341 /uni0342 /uni0343 /uni0344 /uni0345 /uni0346 /uni0347'+nl+//40
'/uni0348 /uni0349 /uni034A /uni034B /uni034C /uni034D /uni034E /uni034f'+nl+//48
'/uni0350 /uni0351 /uni0352 /uni0353 /uni0354 /uni0355 /uni0356 /uni0357'+nl+//50
'/uni0358 /uni0359 /uni035A /uni035B /uni035C /uni035D /uni035E /uni035F'+nl+//58
'/uni0360 /uni0361 /uni0362 /uni0363 /uni0364 /uni0365 /uni0366 /uni0367'+nl+//60
'/uni0368 /uni0369 /uni036A /uni036B /uni036C /uni036D /uni036E /uni036F'+nl+//68
'/uni0370 /uni0371 /uni0372 /uni0373 /uni0374 /uni0375 /uni0376 /uni0377'+nl+//70
'/uni0378 /uni0379 /uni037A /uni037B /uni037C /uni037D /uni037E /uni037F'+nl+//78
'/uni0380 /uni0381 /uni0382 /uni0383 /tonos /dieresistonos /Alphatonos /anoteleia'+nl+//80
'/Epsilontonos /Etatonos /Iotatonos /uni038B /Omicrontonos /uni038D /Upsilontonos /Omegatonos'+nl+//88
'/iotadieresistonos /Alpha /Beta /Gamma /uni0394 /Epsilon /Zeta /Eta'+nl+//90
'/Theta /Iota /Kappa /Lambda /Mu /Nu /Xi /Omicron'+nl+//98
'/Pi /Rho /uni03 /Sigma /Tau /Upsilon /Phi /Chi'+nl+//a0
'/Psi /uni03A9 /Iotadieresis /Upsilondieresis /alphatonos /epsilontonos /etatonos /iotatonos'+nl+//a8
'/upsilondieresistonos /alpha /beta /gamma /delta /epsilon /zeta /eta'+nl+//b0
'/theta /iota /kappa /lambda /uni03BC /nu /xi /omicron'+nl+//b8
'/pi /rho /sigma1 /sigma /tau /upsilon /phi /chi'+nl+//c0
'/psi /omega /iotadieresis /upsilondieresis /omicrontonos /upsilontonos /omegatonos /uni03CF'+nl+//c8
'/uni03D0 /theta1 /Upsilon1 /uni03D3 /uni03D4 /phi1 /omega1 /uni03D7'+nl+//d0
'/uni03D8 /uni03D9 /uni03DA /uni03DB /uni03DC /uni03DD /uni03DE /uni03DF'+nl+//d8
'/uni03E0 /uni03E1 /uni03E2 /uni03E3 /uni03E4 /uni03E5 /uni03E6 /uni03E7'+nl+//e0
'/uni03E8 /uni03E9 /uni03EA /uni03EB /uni03EC /uni03ED /uni03EE /uni03EF'+nl+//e8
'/uni03F0 /uni03F1 /uni03F2 /uni03F3F3 /uni03F4 /uni03F5 /uni03F6 /uni03F7'+nl+//f0
'/uni03F8 /uni03F9 /uni03FA /uni03FB /uni03FC /uni03FD /uni03FE /uni03FF'+nl//f8
  ),
  (
  codepage: $04;
  name: 'E04';         //cyrillic
  glyphnames:
'/uni0400 /afii10023 /afii10051 /afii10052 /afii10053 /afii10054 /afii10055 /afii10056'+nl+ //00
'/afii10057 /afii10058 /afii10059 /afii10060 /afii10061 /uni040D /afii10062 /afii10145'+nl+ //08
'/afii10017 /afii10018 /afii10019 /afii10020 /afii10021 /afii10022 /afii10024 /afii10025'+nl+//10
'/afii10026 /afii10027 /afii10028 /afii10029 /afii10030 /afii10031 /afii10032 /afii10033'+nl+//18
'/afii10034 /afii10035 /afii10036 /afii10037 /afii10038 /afii10039 /afii10040 /afii10041'+nl+//20
'/afii10042 /afii10043 /afii10044 /afii10045 /afii10046 /afii10047 /afii10048 /afii10049'+nl+//28
'/afii10065 /afii10066 /afii10067 /afii10068 /afii10069 /afii10070 /afii10072 /afii10073'+nl+//30
'/afii10074 /afii10075 /afii10076 /afii10077 /afii10078 /afii10079 /afii10080 /afii10081'+nl+//38
'/afii10082 /afii10083 /afii10084 /afii10085 /afii10086 /afii10087 /afii10088 /afii10089'+nl+//40
'/afii10090 /afii10091 /afii10092 /afii10093 /afii10094 /afii10095 /afii10096 /afii10097'+nl+//48
'/uni0450 /afii10071 /afii10099 /afii10100 /afii10101 /afii10102 /afii10103 /afii10104'+nl+//50
'/afii10105 /afii10106 /afii10107 /afii10108 /afii10109 /uni045D /afii10110 /afii10193'+nl+//58
'/uni0460 /uni0461 /afii10146 /afii10194 /uni0464 /uni0465 /uni0466 /uni0467'+nl+//60
'/uni0468 /uni0469 /uni046A /uni046B /uni046C /uni046D /uni046E /uni046F'+nl+//68
'/uni0470 /uni0471 /afii10147 /afii10195 /afii10148 /afii10196 /uni0476 /uni0477'+nl+//70
'/uni0478 /uni0479 /uni047A /uni047B /uni047C /uni047D /uni047E /uni047F'+nl+//78
'/uni0480 /uni0481 /uni0482 /uni0483 /uni0484 /uni0485 /uni0486 /uni0486'+nl+//80
'/uni0488 /uni0489 /uni048A /uni048B /uni048C /uni048D /uni048E /uni048F'+nl+//88
'/afii10050 /afii10098 /uni0492 /uni0493 /uni0494 /uni0495 /uni0496 /uni0497'+nl+//90
'/uni0498 /uni0499 /uni049A /uni049B /uni049C /uni049D /uni049E /uni049F'+nl+//98
'/uni04A0 /uni04A1 /uni04A2 /uni04A3 /uni04A4 /uni04A5 /uni04A6 /uni04A7'+nl+//a0
'/uni04A8 /uni04A9 /uni04AA /uni04AB /uni04AC /uni04AD /uni04AE /uni04AF'+nl+//a8
'/uni04B0 /uni04B1 /uni04B2 /uni04B3 /uni04B4 /uni04B5 /uni04B6 /uni04B7'+nl+//b0
'/uni04B8 /uni04B9 /uni04BA /uni04BB /uni04BC /uni04BD /uni04BE /uni04BF'+nl+//b8
'/uni04C0 /uni04C1 /uni04C2 /uni04C3 /uni04C4 /uni04C5 /uni04C6 /uni04C7'+nl+//c0
'/uni04C8 /uni04C9 /uni04CA /uni04CB /uni04CC /uni04CD /uni04CE /uni04CF'+nl+//c8
'/uni04D0 /uni04D1 /uni04D2 /uni04D3 /uni04D4 /uni04D5 /uni04D6 /uni04D7'+nl+//d0
'/uni04D8 /afii10846 /uni04DA /uni04DB /uni04DC /uni04DD /uni04DE /uni04DF'+nl+//d8
'/uni04E0 /uni04E1 /uni04E2 /uni04E3 /uni04E4 /uni04E5 /uni04E6 /uni04E7'+nl+//e0
'/uni04E8 /uni04E9 /uni04EA /uni04EB /uni04EC /uni04ED /uni04EE /uni04EF'+nl+//e8
'/uni04F0 /uni04F1 /uni04F2 /uni04F3 /uni04F4 /uni04F5 /uni04F6 /uni04F7'+nl+//f0
'/uni04F8 /uni04F9 /uni04FA /uni04FB /uni04FC /uni04FD /uni04FE /uni04FF'+nl //f8
  
   ),                                                                                     
  (
  codepage: $1E;
  name: 'E1E';         //latin extended additional
  glyphnames:
'/uni1E00 /uni1E01 /uni1E02 /uni1E03 /uni1E04 /uni1E05 /uni1E06 /uni1E07'+nl+//00
'/uni1E08 /uni1E09 /uni1E0A /uni1E0B /uni1E0C /uni1E0D /uni1E0E /uni1E0F'+nl+//08
'/uni1E10 /uni1E11 /uni1E12 /uni1E13 /uni1E14 /uni1E15 /uni1E16 /uni1E17'+nl+//10
'/uni1E18 /uni1E19 /uni1E1A /uni1E1B /uni1E1C /uni1E1D /uni1E1E /uni1E1F'+nl+//18
'/uni1E20 /uni1E21 /uni1E22 /uni1E23 /uni1E24 /uni1E25 /uni1E26 /uni1E27'+nl+//20
'/uni1E28 /uni1E29 /uni1E2A /uni1E2B /uni1E2C /uni1E2D /uni1E2E /uni1E2F'+nl+//28
'/uni1E30 /uni1E31 /uni1E32 /uni1E33 /uni1E34 /uni1E35 /uni1E36 /uni1E37'+nl+//30
'/uni1E38 /uni1E39 /uni1E3A /uni1E3B /uni1E3C /uni1E3D /uni1E3E /uni1E3F'+nl+//38
'/uni1E40 /uni1E41 /uni1E42 /uni1E43 /uni1E44 /uni1E45 /uni1E46 /uni1E47'+nl+//40
'/uni1E48 /uni1E49 /uni1E4A /uni1E4B /uni1E4C /uni1E4D /uni1E4E /uni1E4F'+nl+//48
'/uni1E50 /uni1E51 /uni1E52 /uni1E53 /uni1E54 /uni1E55 /uni1E56 /uni1E57'+nl+//50
'/uni1E58 /uni1E59 /uni1E5A /uni1E5B /uni1E5C /uni1E5D /uni1E5E /uni1E5F'+nl+//58
'/uni1E60 /uni1E61 /uni1E62 /uni1E63 /uni1E64 /uni1E65 /uni1E66 /uni1E67'+nl+//60
'/uni1E68 /uni1E69 /uni1E6A /uni1E6B /uni1E6C /uni1E6D /uni1E6E /uni1E6F'+nl+//68
'/uni1E70 /uni1E71 /uni1E72 /uni1E73 /uni1E74 /uni1E75 /uni1E76 /uni1E77'+nl+//70
'/uni1E78 /uni1E79 /uni1E7A /uni1E7B /uni1E7C /uni1E7D /uni1E7E /uni1E7F'+nl+//78
'/Wgrave /wgrave /Wacute /wacute /Wdieresis /wdieresis /uni1E86 /uni1E87'+nl+//80
'/uni1E88 /uni1E89 /uni1E8A /uni1E8B /uni1E8C /uni1E8D /uni1E8E /uni1E8F'+nl+//88
'/uni1E90 /uni1E91 /uni1E92 /uni1E93 /uni1E94 /uni1E95 /uni1E96 /uni1E97'+nl+//90
'/uni1E98 /uni1E99 /uni1E9A /uni1E9B /uni1E9C /uni1E9D /uni1E9E /uni1E9F'+nl+//98
'/uni1EA0 /uni1EA1 /uni1EA2 /uni1EA3 /uni1EA4 /uni1EA5 /uni1EA6 /uni1EA7'+nl+//a0
'/uni1EA8 /uni1EA9 /uni1EAA /uni1EAB /uni1EAC /uni1EAD /uni1EAE /uni1EAF'+nl+//a8
'/uni1EB0 /uni1EB1 /uni1EB2 /uni1EB3 /uni1EB4 /uni1EB5 /uni1EB6 /uni1EB7'+nl+//b0
'/uni1EB8 /uni1EB9 /uni1EBA /uni1EBB /uni1EBC /uni1EBD /uni1EBE /uni1EBF'+nl+//b8
'/uni1EC0 /uni1EC1 /uni1EC2 /uni1EC3 /uni1EC4 /uni1EC5 /uni1EC6 /uni1EC7'+nl+//c0
'/uni1EC8 /uni1EC9 /uni1ECA /uni1ECB /uni1ECC /uni1ECD /uni1ECE /uni1ECF'+nl+//c8
'/uni1ED0 /uni1ED1 /uni1ED2 /uni1ED3 /uni1ED4 /uni1ED5 /uni1ED6 /uni1ED7'+nl+//d0
'/uni1ED8 /uni1ED9 /uni1EDA /uni1EDB /uni1EDC /uni1EDD /uni1EDE /uni1EDF'+nl+//d8
'/uni1EE0 /uni1EE1 /uni1EE2 /uni1EE3 /uni1EE4 /uni1EE5 /uni1EE6 /uni1EE7'+nl+//e0
'/uni1EE8 /uni1EE9 /uni1EEA /uni1EEB /uni1EEC /uni1EED /uni1EEE /uni1EEF'+nl+//e8
'/uni1EF0 /uni1EF1 /Ygrave /ygrave /uni1EF4 /uni1EF5 /uni1EF6 /uni1EF7'+nl+//f0
'/uni1EF8 /uni1EF9 /uni1EFA /uni1EFB /uni1EFC /uni1EFD /uni1EFE /uni1EFF'+nl //f8
  ),
  (
  codepage: $20;
  name: 'E20';         //punctuation, currency
  glyphnames:
'/.notdef /.notdef /enspace /.notdef /.notdef /.notdef /.notdef /.notdef'+nl+        //00
'/.notdef /.notdef /.notdef /zerowidthspace /zerowidthnonjoiner /afii301 /afii299 /afii300'+nl+
                                                                                     //08
'/hyphentwo	/.notdef /figuredash /endash /emdash /horizontalbar /dblverticalbar /underscoredbl'+nl+
                                                                                     //10
'/quoteleft /quoteright /quotesinglbase /quoteleftreversed /quotedblleft /quotedblright /quotedblbase /.notdef'+nl+
                                                                                     //18
'/dagger /daggerdbl /bullet /.notdef /onedotenleader /twodotleader /ellipsis /.notdef'+nl+ 
                                                                                     //20
'/.notdef /.notdef /.notdef /.notdef /afii61573 /afii61574 /afii61575 /.notdef'+nl+  //28
'/perthousand /.notdef /minute /second /.notdef /primereversed /.notdef /.notdef'+nl+//30
'/.notdef /guilsinglleft /guilsinglright /referencemark /exclamdbl /.notdef /overline /.notdef'+nl+
                                                                                     //38
'/.notdef /.notdef /asterism /.notdef /fraction /.notdef /.notdef /.notdef'+nl+      //40 
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //48
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //50
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //58
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //60
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //68
'/zerosuperior /.notdef /.notdef /.notdef /foursuperior /fivesuperior /sixsuperior /sevensuperior'+nl+
                                                                                     //70
'/eightsuperior /ninesuperior /plussuperior /.notdef /equalsuperior /parenleftsuperior /parenrightsuperior /nsuperior'+nl+
                                                                                     //78
'/zeroinferior /oneinferior /twoinferior /threeinferior /fourinferior /fiveinferior /sixinferior /seveninferior'+nl+
                                                                                     //80
'/eightinferior /nineinferior /.notdef /.notdef /.notdef /parenleftinferior /parenrightinferior /.notdef'+nl+
                                                                                     //88
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //90
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //98

'/.notdef /colonmonetary /cruzeiro /franc /lira /.notdef/.notdef /peseta'+nl+        //a0 

'/.notdef /won /sheqel /dong /Euro /.notdef /.notdef /.notdef'+nl+                   //a8
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //b0
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //b8
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //c0
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //c8
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //d0
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //d8
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //e0
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //e8
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl+       //fo
'/.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef /.notdef '+nl        //f8
  ),
  (
  codepage: $21;
  name: 'E21';         //letterlike symbols
  glyphnames:
'/uni2100 /uni2101 /uni2102 /centigrade /uni2104 /afii61248 /uni2106 /uni2107 '+nl+ //00
'/uni2108 /fahrenheit /uni210A /uni210B /uni210C /uni210D /uni210E /uni210F '+nl+ //08
'/uni2110 /Ifraktur /uni2112 /afii61289 /uni2114 /uni2115 /afii61352 /uni2117 '+nl+ //10
'/weierstrass /uni2119 /uni211A /uni211B /Rfraktur /uni211D /prescription /uni211F '+nl+ //18
'/uni2120 /telephone /trademark /uni2123 /uni2124 /uni2125 /Omega /uni2127 '+nl+ //20
'/uni2128 /uni2129 /uni212A /angstrom /uni212C /uni212D /estimated /uni212F '+nl+ //28
'/uni2130 /uni2131 /uni2132 /uni2133 /uni2134 /aleph /uni2136 /uni2137 '+nl+ //30
'/uni2138 /uni2139 /uni213A /uni213B /uni213C /uni213D /uni213E /uni213F '+nl+ //38
'/uni2140 /uni2141 /uni2142 /uni2143 /uni2144 /uni2145 /uni2146 /uni2147 '+nl+ //40
'/uni2148 /uni2149 /uni214A /uni214B /uni214C /uni214D /uni214E /uni214F '+nl+ //48
'/uni2150 /uni2151 /uni2152 /onethird /twothirds /uni2155 /uni2156 /uni2157 '+nl+ //50
'/uni2158 /uni2159 /uni215A /oneeighth /threeeighths /fiveeighths /seveneighths /uni215F '+nl+ //58
'/Oneroman /Tworoman /Threeroman /Fourroman /Fiveroman /Sixroman /Sevenroman /Eightroman '+nl+ //60
'/Nineroman /Tenroman /Elevenroman /Twelveroman /uni216C /uni216D /uni216E /uni216F '+nl+ //68
'/oneroman /tworoman /threeroman /fourroman /fiveroman /sixroman /sevenroman /eightroman '+nl+ //70
'/nineroman /tenroman /elevenroman /twelveroman /uni217C /uni217D /uni217E /uni217F '+nl+ //78
'/uni2180 /uni2181 /uni2182 /uni2183 /uni2184 /uni2185 /uni2186 /uni2187 '+nl+ //80
'/uni2188 /uni2189 /uni218A /uni218B /uni218C /uni218D /uni218E /uni218F '+nl+ //88
'/arrowleft /arrowup /arrowright /arrowdown /arrowboth /arrowupdn /arrowupleft /arrowupright '+nl+ //90
'/arrowdownright /arrowdownleft /uni219A /uni219B /uni219C /uni219D /uni219E /uni219F '+nl+ //98
'/uni21A0 /uni21A1 /uni21A2 /uni21A3 /uni21A4 /uni21A5 /uni21A6 /uni21A7 '+nl+ //A0
'/arrowupdownbase /uni21A9 /uni21AA /uni21AB /uni21AC /uni21AD /uni21AE /uni21AF '+nl+ //A8
'/uni21B0 /uni21B1 /uni21B2 /uni21B3 /uni21B4 /carriagereturn /uni21B6 /uni21B7 '+nl+ //B0
'/uni21B8 /uni21B9 /uni21BA /uni21BB /harpoonleftbarbup /uni21BD /uni21BE /uni21BF '+nl+ //B8
'/harpoonrightbarbup /uni21C1 /uni21C2 /uni21C3 /arrowrightoverleft /arrowupleftofdown /arrowleftoverright /uni21C7 '+nl+ //C0
'/uni21C8 /uni21C9 /uni21CA /uni21CB /uni21CC /arrowleftdblstroke /uni21CE /arrowrightdblstroke '+nl+ //C8
'/arrowleftdbl /arrowdblup /dblarrowright /arrowdbldown /dblarrowleft /uni21D5 /uni21D6 /uni21D7 '+nl+ //D0
'/uni21D8 /uni21D9 /uni21DA /uni21DB /uni21DC /uni21DD /pageup /pagedown '+nl+ //D8
'/arrowdashleft /arrowdashup /arrowdashright /arrowdashdown /arrowtableft /arrowtabright /arrowleftwhite /arrowupwhite '+nl+ //E0
'/arrowrightwhite /arrowdownwhite /capslock /uni21EB /uni21EC /uni21ED /uni21EE /uni21EF '+nl+ //E8
'/uni21F0 /uni21F1 /uni21F2 /uni21F3 /uni21F4 /uni21F5 /uni21F6 /uni21F7 '+nl+ //F0
'/uni21F8 /uni21F9 /uni21FA /uni21FB /uni21FC /uni21FD /uni21FE /uni21FF '+nl //F8
  ),
  (
  codepage: $22;
  name: 'E22';         //mathematical operators
  glyphnames:
'/universal /uni2201 /partialdiff /thereexists /uni2204 /emptyset /increment /nabla '+nl+ //00
'/element /notelementof /uni220A /suchthat /notcontains /uni220D /uni220E /product '+nl+ //08
'/uni2210 /summation /minus /minusplus /uni2214 /divisionslash /uni2216 /asteriskmath '+nl+ //10
'/uni2218 /bulletoperator /radical /uni221B /uni221C /proportional /infinity /rightangle '+nl+ //18
'/angle /uni2221 /uni2222 /divides /uni2224 /parallel /notparallel /logicaland '+nl+ //20
'/logicalor /intersection /union /integral /dblintegral /uni222D /contourintegral /uni222F '+nl+ //28
'/uni2230 /uni2231 /uni2232 /uni2233 /therefore /because /ratio /proportion '+nl+ //30
'/uni2238 /uni2239 /uni223A /uni223B /tildeoperator /reversedtilde /uni223E /uni223F '+nl+ //38
'/uni2240 /uni2241 /uni2242 /asymptoticallyequal /uni2244 /congruent /uni2246 /uni2247 '+nl+ //40
'/approxequal /uni2249 /uni224A /uni224B /allequal /uni224D /uni224E /uni224F '+nl+ //48
'/approaches /geometricallyequal /approxequalorimage /imageorapproximatelyequal /uni2254 /uni2255 /uni2256 /uni2257 '+nl+ //50
'/uni2258 /uni2259 /uni225A /uni225B /uni225C /uni225D /uni225E /uni225F '+nl+ //58
'/notequal /equivalence /notidentical /uni2263 /lessequal /greaterequal /lessoverequal /greateroverequal '+nl+ //60
'/uni2268 /uni2269 /muchless /muchgreater /uni226C /uni226D /notless /notgreater '+nl+ //68
'/notlessnorequal /notgreaternorequal /lessorequivalent /greaterorequivalent /uni2274 /uni2275 /lessorgreater /greaterorless '+nl+ //70
'/uni2278 /notgreaternorless /precedes /succeeds /uni227C /uni227D /uni227E /uni227F '+nl+ //78
'/notprecedes /notsucceeds /subset /superset /notsubset /notsuperset /subsetorequal /supersetorequal '+nl+ //80
'/uni2288 /uni2289 /subsetnotequal /supersetnotequal /uni228C /uni228D /uni228E /uni228F '+nl+ //88
'/uni2290 /uni2291 /uni2292 /uni2293 /uni2294 /pluscircle /minuscircle /timescircle '+nl+ //90
'/uni2298 /circleot /uni229A /uni229B /uni229C /uni229D /uni229E /uni229F '+nl+ //98
'/uni22A0 /uni22A1 /uni22A2 /tackleft /tackdown /perpendicular /uni22A6 /uni22A7 '+nl+ //A0
'/uni22A8 /uni22A9 /uni22AA /uni22AB /uni22AC /uni22AD /uni22AE /uni22AF '+nl+ //A8
'/uni22B0 /uni22B1 /uni22B2 /uni22B3 /uni22B4 /uni22B5 /uni22B6 /uni22B7 '+nl+ //B0
'/uni22B8 /uni22B9 /uni22BA /uni22BB /uni22BC /uni22BD /uni22BE /righttriangle '+nl+ //B8
'/uni22C0 /uni22C1 /uni22C2 /uni22C3 /uni22C4 /dotmath /uni22C6 /uni22C7 '+nl+ //C0
'/uni22C8 /uni22C9 /uni22CA /uni22CB /uni22CC /uni22CD /curlyor /curlyand '+nl+ //C8
'/uni22D0 /uni22D1 /uni22D2 /uni22D3 /uni22D4 /uni22D5 /uni22D6 /uni22D7 '+nl+ //D0
'/uni22D8 /uni22D9 /lessequalorgreater /greaterequalorless /uni22DC /uni22DD /uni22DE /uni22DF '+nl+ //D8
'/uni22E0 /uni22E1 /uni22E2 /uni22E3 /uni22E4 /uni22E5 /uni22E6 /uni22E7 '+nl+ //E0
'/uni22E8 /uni22E9 /uni22EA /uni22EB /uni22EC /uni22ED /ellipsisvertical /uni22EF '+nl+ //E8
'/uni22F0 /uni22F1 /uni22F2 /uni22F3 /uni22F4 /uni22F5 /uni22F6 /uni22F7 '+nl+ //F0
'/uni22F8 /uni22F9 /uni22FA /uni22FB /uni22FC /uni22FD /uni22FE /uni22FF '+nl //F8
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
'/rtblock /shadelight /shademedium /shadedark /uni2594 /uni2595 /uni2596 /uni2597 '+nl+ //90
'/uni2598 /uni2599 /uni259A /uni259B /uni259C /uni259D /uni259E /uni259F '+nl+ //98
'/filledbox /whitesquare /uni25A2 /squarewhitewithsmallblack /squarehorizontalfill /squareverticalfill /squareorthogonalcrosshatchfill /squareupperlefttolowerrightfill '+nl+ //A0
'/squareupperrighttolowerleftfill /squarediagonalcrosshatchfill /H18543 /whitesmallsquare /filledrect /uni25AD /uni25AE /uni25AF '+nl+ //A8
'/uni25B0 /uni25B1 /triagup /whiteuppointingtriangle /blackuppointingsmalltriangle /whiteuppointingsmalltriangle /blackrightpointingtriangle /whiterightpointingtriangle '+nl+ //B0
'/uni25B8 /whiterightpointingsmalltriangle /triagrt /uni25BB /triagdn /whitedownpointingtriangle /uni25BE /whitedownpointingsmalltriangle '+nl+ //B8
'/blackleftpointingtriangle /whiteleftpointingtriangle /uni25C2 /whiteleftpointingsmalltriangle /triaglf /uni25C5 /blackdiamond /whitediamond '+nl+ //C0
'/whitediamondcontainingblacksmalldiamond /fisheye /lozenge /whitecircle /dottedcircle /uni25CD /bullseye /H18533 '+nl+ //C8
'/circlewithlefthalfblack /circlewithrighthalfblack /uni25D2 /uni25D3 /uni25D4 /uni25D5 /uni25D6 /uni25D7 '+nl+ //D0
'/invbullet /whitecircleinverse /uni25DA /uni25DB /uni25DC /uni25DD /uni25DE /uni25DF '+nl+ //D8
'/uni25E0 /uni25E1 /blacklowerrighttriangle /blacklowerlefttriangle /blackupperlefttriangle /blackupperrighttriangle /whitebullet /uni25E7 '+nl+ //E0
'/uni25E8 /uni25E9 /uni25EA /uni25EB /uni25EC /uni25ED /uni25EE /largecircle '+nl+ //E8
'/uni25F0 /uni25F1 /uni25F2 /uni25F3 /uni25F4 /uni25F5 /uni25F6 /uni25F7 '+nl+ //F0
'/uni25F8 /uni25F9 /uni25FA /uni25FB /uni25FC /uni25FD /uni25FE /uni25FF '+nl //F8
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
