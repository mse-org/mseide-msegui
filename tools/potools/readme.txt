
Demo to dynamic load po lang files in your msegui application.
It does not use the mseconst_xx.pas of each language and so does not bloat up your application.

User may add new po files without the need to recompile the application.

Here how to do:

There are 2 files to adapt: "mseconst_dynpo.pas" for the default data and "msestockobjects_dynpo.pas" for the enums.
Those files are in /mseide-msegui/lib/common/lang_dynpo/, just copy all the files of that directory into the root source directory of your application.

This are the arrays needed by msegui himself:
lang_stockcaption, lang_modalresult, lang_modalresultnoshortcut : array of msestring;
   
There is a lang_mainform array in "mseconsts_dynpo.pas"  that can be used by the application,  you may adapt it as you want.
His enum is  in "msestockobjects_dynpo.pas".

All the translated po files are in directory /potools/lang.

The arrays must be filled at init of your application.
It is done with the procedure setlangdemo(TheLang) from po2arrays.pas unit, if TheLang = '' then the default consts are used.

For compilation add this parameter: -dmse_dynpo.
