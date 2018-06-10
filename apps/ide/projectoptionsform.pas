{ MSEide Copyright (c) 1999-2018 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit projectoptionsform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

{$ifndef mse_no_ifi}
  {$define mse_with_ifi}        
     //MSEide needs mse_with_ifi, switch for compiling test only
{$endif}

interface
uses
 mseforms,msefiledialog,mseapplication,msegui,msestat,msestatfile,msetabs,
 msesimplewidgets,msetypes,msestrings,msedataedits,msetextedit,msegraphedits,
 msewidgetgrid,msegrids,msesplitter,msemacros,msegdbutils,msedispwidgets,msesys,
 mseclasses,msegraphutils,mseevent,msetabsglob,msearrayutils,msegraphics,
 msedropdownlist,mseformatstr,mseinplaceedit,msedatanodes,mselistbrowser,
 msebitmap,msecolordialog,msedrawtext,msewidgets,msepointer,mseguiglob,
 msepipestream,msemenus,sysutils,mseglob,mseedit,msedialog,msescrollbar,
 msememodialog,msecodetemplates,mseifiglob,msestream,msestringcontainer,
 mserttistat,mseificomp,mseificompglob,msedragglob,mseeditglob,mseact;

const
 defaultsourceprintfont = 'Courier';
 defaulttitleprintfont = 'Helvetica';
 defaultprintfontsize = 35.2778; //10 point
 maxdefaultmake = $40-1;
 defaultxtermcommand = 'xterm -S${PTSN}/${PTSH}';
 optaftermainfilemask = $40000000;
 
type
 settinggroupty = (sg_editor,sg_debugger,sg_make,sg_templates,
                   sg_macros,sg_fontalias,sg_usercolors,
                   sg_formatmacros,sg_tools,sg_storage,
                   sg_state);
 settinggroupsty = set of settinggroupty;
 
 findinfoty = record
  text: msestring;
  options: searchoptionsty;
  selectedonly: boolean;
  history: msestringarty;
 end;
 
 replaceinfoty = record
  find: findinfoty;
  replacetext: msestring;
  prompt: boolean;
 end; 
 
 sigsetinfoty = record
  num: integer;
  numto: integer;
  flags: sigflagsty;
 end;
 sigsetinfoarty = array of sigsetinfoty;

 ttexttoolsoptions = class(toptions)
  private
   ftoolmenus: msestringarty;
   ftoolfiles: msestringarty;
   ftoolparams: msestringarty;
  published
   property toolmenus: msestringarty read ftoolmenus write ftoolmenus;
   property toolfiles: msestringarty read ftoolfiles write ftoolfiles;
   property toolparams: msestringarty read ftoolparams write ftoolparams;
 end;

 ttoolsoptions = class(toptions)
  private
   ft: ttexttoolsoptions;
   ftexp: ttexttoolsoptions;
   ftoolsave: longboolarty;
   ftoolhide: longboolarty;
   ftoolparse: longboolarty;
   ftoolmessages: longboolarty;
   ftoolshortcuts: integerarty;
  protected
   function gett: tobject; override;
   function gettexp: tobject; override;
  public
   constructor create;
   property texp: ttexttoolsoptions read ftexp;
  published
   property t: ttexttoolsoptions read ft;
   property toolsave: longboolarty read ftoolsave write ftoolsave;
   property toolhide: longboolarty read ftoolhide write ftoolhide;
   property toolparse: longboolarty read ftoolparse write ftoolparse;
   property toolmessages: longboolarty read ftoolmessages write ftoolmessages;
   property toolshortcuts: integerarty read ftoolshortcuts write ftoolshortcuts;
 end;

 ttexttemplatesoptions = class(toptions)
  private
   fscriptbeforecopy: msestring;
   fscriptaftercopy: msestring;
   fnewprojectfiles: filenamearty;
   fnewprojectfilesdest: filenamearty;
   fnewfinames: msestringarty;
   fnewfifilters: msestringarty;
   fnewfiexts: msestringarty;
   fnewfisources: filenamearty;
   fnewfonames: msestringarty;
   fnewfonamebases: msestringarty;
   fnewfoformsuffixes: msestringarty;
   fnewfosources: msestringarty;
   fnewfoforms: msestringarty;
  published
   property scriptbeforecopy: msestring read fscriptbeforecopy
                                               write fscriptbeforecopy;
   property scriptaftercopy: msestring read fscriptaftercopy 
                                           write fscriptaftercopy;
   property newprojectfiles: filenamearty read fnewprojectfiles
                                               write fnewprojectfiles;
   property newprojectfilesdest: filenamearty read fnewprojectfilesdest
                                                  write fnewprojectfilesdest;
   property newfinames: msestringarty read fnewfinames write fnewfinames;
   property newfifilters: msestringarty read fnewfifilters
                                              write fnewfifilters;
   property newfiexts: msestringarty read fnewfiexts write fnewfiexts;
   property newfisources: filenamearty read fnewfisources write fnewfisources;
  
   property newfonames: msestringarty read fnewfonames write fnewfonames;
   property newfonamebases: msestringarty read fnewfonamebases
                                                   write fnewfonamebases;
   property newfoformsuffixes: msestringarty read fnewfoformsuffixes
                                                   write fnewfoformsuffixes;
   property newfosources: msestringarty read fnewfosources 
                                        write fnewfosources;
   property newfoforms: msestringarty read fnewfoforms write fnewfoforms;
 end;
 
 ttemplatesoptions = class(toptions)
  private
   ft: ttexttemplatesoptions;
   ftexp: ttexttemplatesoptions;
   fexpandprojectfilemacros: longboolarty;
   floadprojectfile: longboolarty;
   fnewinheritedforms: longboolarty;
  protected
   function gett: tobject; override;
   function gettexp: tobject; override;
  public
   constructor create;
   property texp: ttexttemplatesoptions read ftexp;
  published
   property t: ttexttemplatesoptions read ft;
   property expandprojectfilemacros: longboolarty read fexpandprojectfilemacros
                                               write fexpandprojectfilemacros;
   property loadprojectfile: longboolarty read floadprojectfile 
                                                 write floadprojectfile;
   property newinheritedforms: longboolarty read fnewinheritedforms
                                              write fnewinheritedforms;
 end;
 
 ttexteditoptions = class(toptions)
  private
   fsourcefilemasks: msestringarty;
   fsyntaxdeffiles: msestringarty;
   ffilemasknames: msestringarty;
   ffilemasks: msestringarty;
  public
   fcodetemplatedirs: msestringarty;
  published
   property sourcefilemasks: msestringarty read fsourcefilemasks 
                                                write fsourcefilemasks;
   property syntaxdeffiles: msestringarty read fsyntaxdeffiles 
                                                write fsyntaxdeffiles;
   property filemasknames: msestringarty read ffilemasknames 
                                                  write ffilemasknames;
   property filemasks: msestringarty read ffilemasks write ffilemasks;
   property codetemplatedirs: msestringarty read fcodetemplatedirs write
                                                            fcodetemplatedirs;
 end;

 teditoptions = class(toptions)
  private
   ft: ttexteditoptions;
   ftexp: ttexteditoptions;
   
   fshowgrid: boolean;
   fsnaptogrid: boolean;
   fmoveonfirstclick: boolean;
   fgridsizex: integer;
   fgridsizey: integer;
   fautoindent: boolean;
   fblockindent: integer;
   flinenumberson: boolean;
   frightmarginon: boolean;
   frightmarginchars: integer;
   fscrollheight: integer;
   ftabstops: integer;
   fspacetabs: boolean;
   fshowtabs: boolean;
   ftabindent: boolean;
   feditfontname: msestring;
   feditfontheight: integer;
   feditfontwidth: integer;
   feditfontextraspace: integer;
   feditfontcolor: integer;
   feditbkcolor: integer;
   fstatementcolor: integer;
   feditfontantialiased: boolean;
   feditmarkbrackets: boolean;
   feditmarkpairwords: boolean;
   fbackupfilecount: integer;
   fencoding: integer;
   feolstyle: integer;
   fnoformdesignerdocking: boolean;
   ftrimtrailingwhitespace: boolean;
   fpairmarkcolor: integer;
   fpairmaxrowcount: integer;
   fcomponenthints: boolean;
   function limitgridsize(const avalue: integer): integer;
   procedure setgridsizex(const avalue: integer);
   procedure setgridsizey(const avalue: integer);
//   function getcodetemplatedirs: msestringarty;
//   procedure setcodetemplatedirs(const avalue: msestringarty);
  protected
   function gett: tobject; override;
   function gettexp: tobject; override;
  public
   constructor create;
   property texp: ttexteditoptions read ftexp;
  published
   property t: ttexteditoptions read ft;

   property showgrid: boolean read fshowgrid write fshowgrid;
   property snaptogrid: boolean read fsnaptogrid write fsnaptogrid;
   property moveonfirstclick: boolean read fmoveonfirstclick 
                                         write fmoveonfirstclick;
   property noformdesignerdocking: boolean read fnoformdesignerdocking
                                         write fnoformdesignerdocking;
   property componenthints: boolean read fcomponenthints
                                         write fcomponenthints;
   property gridsizex: integer read fgridsizex write setgridsizex;
   property gridsizey: integer read fgridsizey write setgridsizey;
   property autoindent: boolean read fautoindent write fautoindent;
   property blockindent: integer read fblockindent write fblockindent;
   property linenumberson: boolean read flinenumberson write flinenumberson;
   property rightmarginon: boolean read frightmarginon write frightmarginon;
   property rightmarginchars: integer read frightmarginchars 
                                                    write frightmarginchars;
   property scrollheight: integer read fscrollheight write fscrollheight;
   property tabstops: integer read ftabstops write ftabstops;
   property spacetabs: boolean read fspacetabs write fspacetabs;
   property showtabs: boolean read fshowtabs write fshowtabs;
   property tabindent: boolean read ftabindent write ftabindent;
   property editfontname: msestring read feditfontname write feditfontname;
   property editfontheight: integer read feditfontheight write feditfontheight;
   property editfontwidth: integer read feditfontwidth write feditfontwidth;
   property editfontextraspace: integer read feditfontextraspace 
                                                      write feditfontextraspace;
   property editfontcolor: integer read feditfontcolor write feditfontcolor;
   property editbkcolor: integer read feditbkcolor write feditbkcolor;
   property statementcolor: integer read fstatementcolor write fstatementcolor;
   property pairmarkcolor: integer read fpairmarkcolor 
                                             write fpairmarkcolor;
   property pairmaxrowcount: integer read fpairmaxrowcount 
                                             write fpairmaxrowcount;
   
   property editfontantialiased: boolean read feditfontantialiased 
                                              write feditfontantialiased;
   property editmarkbrackets: boolean read feditmarkbrackets 
                                              write feditmarkbrackets;
   property editmarkpairwords: boolean read feditmarkpairwords 
                                              write feditmarkpairwords;
   property backupfilecount: integer read fbackupfilecount 
                                              write fbackupfilecount;
   property encoding: integer read fencoding write fencoding;
   property eolstyle: integer read feolstyle write feolstyle;
   property trimtrailingwhitespace: boolean read ftrimtrailingwhitespace
                                                write ftrimtrailingwhitespace;
//   property codetemplatedirs: msestringarty read getcodetemplatedirs write
//                  setcodetemplatedirs;
 end;

 ttextdebugoptions = class(toptions)
  private
   fdebugcommand: filenamety;
   fdebugoptions: msestring;
   fdebugtarget: filenamety;
   fruncommand: filenamety;
   fremoteconnection: msestring;
   fuploadcommand: filenamety;
   fgdbprocessor: msestring;
   fgdbservercommand: filenamety;
   fgdbservercommandattach: filenamety;
   fbeforeload: filenamety;
   fafterload: filenamety;
   fbeforerun: filenamety;
   fsourcedirs: msestringarty;
   fdefines: msestringarty;

   fprogparameters: msestring;
   fprogworkingdirectory: filenamety;
   fenvvarnames: msestringarty;
   fenvvarvalues: msestringarty;
   fbeforeconnect: filenamety;
   fafterconnect: filenamety;
   fxtermcommand: msestring;
   fsourcebase: msestring;
  protected
  public
   constructor create;
  published
   property debugcommand: filenamety read fdebugcommand write fdebugcommand;
   property debugoptions: msestring read fdebugoptions write fdebugoptions;
   property debugtarget: filenamety read fdebugtarget write fdebugtarget;
   property runcommand: filenamety read fruncommand write fruncommand;
   property xtermcommand: msestring read fxtermcommand write fxtermcommand;
   property remoteconnection: msestring read fremoteconnection 
                                        write fremoteconnection;
   property uploadcommand: filenamety read fuploadcommand 
                                            write fuploadcommand;
   property gdbprocessor: msestring read fgdbprocessor write fgdbprocessor;
   property gdbservercommand: filenamety read fgdbservercommand
                                              write fgdbservercommand;
   property gdbservercommandattach: filenamety read fgdbservercommandattach
                                                write fgdbservercommandattach;
   property beforeconnect: filenamety read fbeforeconnect write fbeforeconnect;
   property afterconnect: filenamety read fafterconnect write fafterconnect;
   property beforeload: filenamety read fbeforeload write fbeforeload;
   property afterload: filenamety read fafterload write fafterload;
   property beforerun: filenamety read fbeforerun write fbeforerun;
   property sourcebase: msestring read fsourcebase write fsourcebase;
   property sourcedirs: msestringarty read fsourcedirs write fsourcedirs;
   property defines: msestringarty read fdefines write fdefines;

   property progparameters: msestring read fprogparameters 
                                   write fprogparameters;
   property progworkingdirectory: filenamety read fprogworkingdirectory 
                                               write fprogworkingdirectory;
   property envvarnames: msestringarty read fenvvarnames write fenvvarnames;
   property envvarvalues: msestringarty read fenvvarvalues write fenvvarvalues;
 end;
 
 tdebugoptions = class(toptions)
  private
   ft: ttextdebugoptions;
   ftexp: ttextdebugoptions;
   fdefineson: longboolarty;
   fstoponexception: boolean;
   fvaluehints: boolean;
   factivateonbreak: boolean;
   fshowconsole: boolean;
   fexternalconsole: boolean;
   fgdbdownload: boolean;
   fdownloadalways: boolean;
   fstartupbkpt: integer;
   fstartupbkpton: boolean;
   fgdbsimulator: boolean;
   fgdbserverwait: real;
   fexceptclassnames: msestringarty;
   fexceptignore: booleanarty;
   fnogdbserverexit: boolean;
   fgdbservertty: boolean;
   fnodebugbeginend: boolean;
   fsettty: boolean;
   fgdbserverstartonce: boolean;
   fraiseonbreak: boolean;
   fgdbloadtimeout: realty;
   ffpcgdbworkaround: boolean;
  protected
   function gett: tobject; override;
   function gettexp: tobject; override;
  public
   constructor create;
   property texp: ttextdebugoptions read ftexp;
  published
   property t: ttextdebugoptions read ft;
   property defineson: longboolarty read fdefineson write fdefineson;
   property stoponexception: boolean read fstoponexception write fstoponexception;
   property valuehints: boolean read fvaluehints write fvaluehints;
   property activateonbreak: boolean read factivateonbreak write factivateonbreak;
   property raiseonbreak: boolean read fraiseonbreak write fraiseonbreak;
   property showconsole: boolean read fshowconsole write fshowconsole;
   property externalconsole: boolean read fexternalconsole write fexternalconsole;
   property settty: boolean read fsettty write fsettty;
   property gdbdownload: boolean read fgdbdownload write fgdbdownload;
   property downloadalways: boolean read fdownloadalways write fdownloadalways;
   property startupbkpt: integer read fstartupbkpt write fstartupbkpt;
   property startupbkpton: boolean read fstartupbkpton write fstartupbkpton;
   property gdbsimulator: boolean read fgdbsimulator write fgdbsimulator;
   property gdbserverstartonce: boolean read fgdbserverstartonce 
                            write fgdbserverstartonce;
   property gdbloadtimeout: real read fgdbloadtimeout write fgdbloadtimeout;
   property gdbserverwait: real read fgdbserverwait write fgdbserverwait;
   property nogdbserverexit: boolean read fnogdbserverexit 
                                                   write fnogdbserverexit;
   property gdbservertty: boolean read fgdbservertty 
                                                   write fgdbservertty;
   property exceptclassnames: msestringarty read fexceptclassnames 
                                                 write fexceptclassnames;
   property exceptignore: booleanarty read fexceptignore 
                                                 write fexceptignore;
   property nodebugbeginend: boolean read fnodebugbeginend 
                                          write fnodebugbeginend;
   property fpcgdbworkaround: boolean read ffpcgdbworkaround 
                                                   write ffpcgdbworkaround;
 end;

 tmacrooptions = class(toptions)
  private
   fmacroon: integerarty;
   fmacronames: msestringarty;
   fmacrovalues: msestringarty;
   fgroupcomments: msestringarty;
  published
   property macroon: integerarty read fmacroon write fmacroon;
   property macronames: msestringarty read fmacronames write fmacronames;
   property macrovalues: msestringarty read fmacrovalues write fmacrovalues;
   property groupcomments: msestringarty read fgroupcomments
                                                     write fgroupcomments;
 end;

 ttextprojectstate = class(toptions)
  private
   fmessageoutputfile: filenamety;
  published
   property messageoutputfile: filenamety read fmessageoutputfile
                                               write fmessageoutputfile;
 end;
 
 tprojectstate = class(toptions)
  private
   ft: ttextprojectstate;
   ftexp: ttextprojectstate;
   
   fmodulenames: msestringarty;
   fmoduletypes: msestringarty;
   fmodulefiles: filenamearty;
   fmacrogroup: integer;

   fforcezorder: longbool;
   fstripmessageesc: boolean;
   fcopymessages: boolean;
   fcheckmethods: boolean;
   fclosemessages: boolean;
   fcolorerror: colorty;
   fcolorwarning: colorty;
   fcolornote: colorty;
//   fsettingsautoload: boolean;
//   fsettingsautosave: boolean;
   procedure setforcezorder(const avalue: longbool);
  protected
   function gett: tobject; override;
   function gettexp: tobject; override;
  public
   constructor create();
   property texp: ttextprojectstate read ftexp;
  published
   property t: ttextprojectstate read ft;
   property modulenames: msestringarty read fmodulenames write fmodulenames;
   property moduletypes: msestringarty read fmoduletypes write fmoduletypes;
   property modulefiles: filenamearty read fmodulefiles write fmodulefiles;
   property macrogroup: integer read fmacrogroup write fmacrogroup;

   property forcezorder: longbool read fforcezorder write setforcezorder;
   property stripmessageesc: boolean read fstripmessageesc 
                                             write fstripmessageesc;
   property copymessages: boolean read fcopymessages write fcopymessages;
   property closemessages: boolean read fclosemessages write fclosemessages;
   property checkmethods: boolean read fcheckmethods write fcheckmethods;
   property colorerror: colorty read fcolorerror write fcolorerror;
   property colorwarning: colorty read fcolorwarning write fcolorwarning;
   property colornote: colorty read fcolornote write fcolornote;
{
   property settingsautoload: boolean read fsettingsautoload
                                          write fsettingsautoload;
   property settingsautosave: boolean read fsettingsautosave
                                          write fsettingsautosave;
}
 end;
    
 ttextfontaliasoptions = class(toptions)
  private
   ffontalias: msestringarty;
   ffontnames: msestringarty;
   ffontancestors: msestringarty;
   ffontoptions: msestringarty;
  published
   property fontalias: msestringarty read ffontalias write ffontalias;
   property fontnames: msestringarty read ffontnames write ffontnames;
   property fontancestors: msestringarty read ffontancestors 
                                         write ffontancestors;
   property fontoptions: msestringarty read ffontoptions write ffontoptions;
 end;

 tfontaliasoptions = class(toptions)
  private
   ft: ttextfontaliasoptions;
   ftexp: ttextfontaliasoptions;
   ffontheights: integerarty;
   ffontwidths: integerarty;
   ffontxscales: realarty;
  protected
   function gett: tobject; override;
   function gettexp: tobject; override;
  public
   constructor create();
   property texp: ttextfontaliasoptions read ftexp;
  published
   property t: ttextfontaliasoptions read ft;
   property fontheights: integerarty read ffontheights write ffontheights;
   property fontwidths: integerarty read ffontwidths write ffontwidths;
   property fontxscales: realarty read ffontxscales write ffontxscales;

 end;

 ttextusercoloroptions = class(toptions)
 end;

 tusercoloroptions = class(toptions)
  private
   ft: ttextusercoloroptions;
   ftexp: ttextusercoloroptions;
   fusercolors: colorarty;
   fusercolorcomment: msestringarty;
  protected
   function gett: tobject; override;
   function gettexp: tobject; override;
  public
   constructor create();
   property texp: ttextusercoloroptions read ftexp;
  published
   property t: ttextusercoloroptions read ft;
   property usercolors: colorarty read fusercolors write fusercolors;
   property usercolorcomment: msestringarty read fusercolorcomment 
                                                 write fusercolorcomment;
 end;

 ttextformatmacrooptions = class(toptions)
  private
   fformatmacronames: msestringarty;
   fformatmacrovalues: msestringarty;
  published
   property formatmacronames: msestringarty read fformatmacronames 
                                                       write fformatmacronames;
   property formatmacrovalues: msestringarty read fformatmacrovalues
                                                   write fformatmacrovalues;
 end;
 
 tformatmacrooptions = class(toptions)
  private
   ft: ttextformatmacrooptions;
   ftexp: ttextformatmacrooptions;
  protected
   function gett: tobject; override;
   function gettexp: tobject; override;
  public
   constructor create();
   property texp: ttextformatmacrooptions read ftexp;
  published
   property t: ttextformatmacrooptions read ft;
 end;

 tstorageoptions = class(toptions)
  private
   fsettingsfile: filenamety;
   fsettingseditor: boolean;
   fsettingsdebugger: boolean;
   fsettingsmake: boolean;
   fsettingsmacros: boolean;
   fsettingsfontalias: boolean;
   fsettingsusercolors: boolean;
   fsettingsformatmacros: boolean;
   fsettingstemplates: boolean;
   fsettingstools: boolean;
   fsettingsstorage: boolean;
   fsettingscomponentstore: boolean;
   fsettingsprojecttree: boolean;
   fsettingslayout: boolean;
   fsettingsautoload: boolean;
   fsettingsautosave: boolean;
  public
   constructor create();
  published
   property settingsfile: filenamety read fsettingsfile write fsettingsfile;
   property settingsautoload: boolean read fsettingsautoload
                                          write fsettingsautoload;
   property settingsautosave: boolean read fsettingsautosave
                                          write fsettingsautosave;
   property settingseditor: boolean read fsettingseditor write fsettingseditor;
   property settingsdebugger: boolean read fsettingsdebugger 
                                               write fsettingsdebugger;
   property settingsmake: boolean read fsettingsmake 
                                               write fsettingsmake;
   property settingsmacros: boolean read fsettingsmacros 
                                               write fsettingsmacros;
   property settingsfontalias: boolean read fsettingsfontalias 
                                               write fsettingsfontalias;
   property settingsusercolors: boolean read fsettingsusercolors 
                                               write fsettingsusercolors;
   property settingsformatmacros: boolean read fsettingsformatmacros 
                                               write fsettingsformatmacros;
   property settingstemplates: boolean read fsettingstemplates 
                                               write fsettingstemplates;
   property settingstools: boolean read fsettingstools 
                                               write fsettingstools;
   property settingsstorage: boolean read fsettingsstorage 
                                               write fsettingsstorage;
   property settingscomponentstore: boolean read fsettingscomponentstore 
                                               write fsettingscomponentstore;
   property settingsprojecttree: boolean read fsettingsprojecttree 
                                               write fsettingsprojecttree;
   property settingslayout: boolean read fsettingslayout 
                                               write fsettingslayout;
 end;
 
 ttextmakeoptions = class(toptions)
  private
   fmainfile: filenamety;
   ftargetfile: filenamety;
   fmakecommand: filenamety;
   fmakedir: filenamety;
   funitdirs: msestringarty;
   funitpref: msestring;
   fincpref: msestring;
   flibpref: msestring;
   fobjpref: msestring;
   ftargpref: msestring;
   fbefcommand: msestringarty;
   faftcommand: msestringarty;
   fmakeoptions: msestringarty;
//   ffontnames: msestringarty;
  public
//   fcodetemplatedirs: msestringarty;
  published
   property mainfile: filenamety read fmainfile write fmainfile;
   property targetfile: filenamety read ftargetfile write ftargetfile;
   property makecommand: filenamety read fmakecommand write fmakecommand;
   property makedir: filenamety read fmakedir write fmakedir;
   property unitdirs: msestringarty read funitdirs write funitdirs;
   property unitpref: msestring read funitpref write funitpref;
   property incpref: msestring read fincpref write fincpref;
   property libpref: msestring read flibpref write flibpref;
   property objpref: msestring read fobjpref write fobjpref;
   property targpref: msestring read ftargpref write ftargpref;
  
   property befcommand: msestringarty read fbefcommand write fbefcommand;
   property aftcommand: msestringarty read faftcommand write faftcommand;
   property makeoptions: msestringarty read fmakeoptions write fmakeoptions;

//   property codetemplatedirs: msestringarty read fcodetemplatedirs
//                                                     write fcodetemplatedirs;
 end;

 tmakeoptions = class(toptions)
  private
   ft: ttextmakeoptions;
   ftexp: ttextmakeoptions;
   
//   fusercolors: colorarty;
//   fusercolorcomment: msestringarty;

//   fformatmacronames: msestringarty;
//   fformatmacrovalues: msestringarty;
{   
   fsettingsfile: filenamety;
   fsettingseditor: boolean;
   fsettingsdebugger: boolean;
   fsettingsmake: boolean;
   fsettingsmacros: boolean;
   fsettingsfontalias: boolean;
   fsettingsusercolors: boolean;
   fsettingsformatmacros: boolean;
   fsettingstemplates: boolean;
   fsettingstools: boolean;
   fsettingsstorage: boolean;
   fsettingscomponentstore: boolean;
   fsettingsprojecttree: boolean;
   fsettingslayout: boolean;
   fsettingsautoload: boolean;
   fsettingsautosave: boolean;
}
//   fmoduleoptions: integerarty;
   fmakeoptpurpose: msestringarty;
   fbefcommandon: integerarty;
   fmakeoptionson: integerarty;
   faftcommandon: integerarty;
   funitdirson: integerarty;
{
   ffontalias: msestringarty;
   ffontancestors: msestringarty;
   ffontheights: integerarty;
   ffontwidths: integerarty;
   ffontoptions: msestringarty;
   ffontxscales: realarty;
 }  
   fuid: integer;
   freversepathorder: boolean;
  protected
   function gett: tobject; override;
   function gettexp: tobject; override;
  public
   constructor create;
   property texp: ttextmakeoptions read ftexp;
  published
   property t: ttextmakeoptions read ft;

   property reversepathorder: boolean read freversepathorder 
                                                  write freversepathorder;

   property makeoptpurpose: msestringarty read fmakeoptpurpose 
                                                    write fmakeoptpurpose;
   property befcommandon: integerarty read fbefcommandon write fbefcommandon;
   property makeoptionson: integerarty read fmakeoptionson write fmakeoptionson;
   property aftcommandon: integerarty read faftcommandon write faftcommandon;
   property unitdirson: integerarty read funitdirson write funitdirson;

   property uid: integer read fuid write fuid;   //for insert UID
 end;
{
 ttextprojectoptions = class(toptions)
 end;
 
 tprojectoptions = class(toptions)
  private
   ft: ttextprojectoptions;
   ftexp: ttextprojectoptions;
  protected
   function gett: tobject; override;
   function gettexp: tobject; override;
  public
   constructor create();
   property texp: ttextprojectoptions read ftexp;
  published
   property t: ttextprojectoptions read ft;
 end;
}
{$M-}
 
 projectoptionsty = record
  disabled: settinggroupsty;
//  o: tprojectoptions;
  e: teditoptions;
  d: tdebugoptions;
  k: tmakeoptions;
  m: tmacrooptions;
  a: tfontaliasoptions;
  u: tusercoloroptions;
  f: tformatmacrooptions;
  p: ttemplatesoptions;
  t: ttoolsoptions;
  r: tstorageoptions;
  s: tprojectstate;
  modified: boolean;
  savechecked: boolean;
  ignoreexceptionclasses: stringarty;
  projectfilename: filenamety;
  projectdir: filenamety;
  defaultmake: integer;
  sigsettings: sigsetinfoarty;
  progparamhistory: msestringarty;
  workdirparamhistory: msestringarty;
  envvarons: longboolarty;
  findreplaceinfo: replaceinfoty;
  targetconsolefindinfo: findinfoty;
 end;

 tprojectoptionsfo = class(tmseform)
   statfile1: tstatfile;
   tlayouter9: tlayouter;
   tlayouter8: tlayouter;
   cancel: tbutton;
   ok: tbutton;
   tabwidget: ttabwidget;
   editorpage: ttabpage;
   debuggerpage: ttabpage;
   debugcommand: tfilenameedit;
   debugoptions: tmemodialogedit;
   ttabwidget1: ttabwidget;
   ttabpage6: ttabpage;
   sourcedirgrid: twidgetgrid;
   sourcedirs: tfilenameedit;
   ttabpage9: ttabpage;
   twidgetgrid2: twidgetgrid;
   defineson: tbooleanedit;
   defines: tstringedit;
   ttabpage7: ttabpage;
   signalgrid: twidgetgrid;
   sigstop: tbooleanedit;
   sighandle: tbooleanedit;
   signum: tintegeredit;
   signumto: tintegeredit;
   signame: tselector;
   ttabpage8: ttabpage;
   exceptionsgrid: twidgetgrid;
   exceptignore: tbooleanedit;
   exceptclassnames: tstringedit;
   ttabpage16: ttabpage;
   remoteconnection: tstringedit;
   tlayouter3: tlayouter;
   gdbprocessor: tdropdownlistedit;
   gdbsimulator: tbooleanedit;
   gdbdownload: tbooleanedit;
   tlayouter4: tlayouter;
   beforeconnect: tfilenameedit;
   tsplitter7: tsplitter;
   beforeload: tfilenameedit;
   tlayouter5: tlayouter;
   afterconnect: tfilenameedit;
   tsplitter8: tsplitter;
   tlayouter1: tlayouter;
   externalconsole: tbooleanedit;
   showconsole: tbooleanedit;
   stoponexception: tbooleanedit;
   activateonbreak: tbooleanedit;
   makepage: ttabpage;
   tspacer2: tspacer;
   defaultmake: tenumedit;
   mainfile: tfilenameedit;
   targetfile: tfilenameedit;
   makecommand: tfilenameedit;
   showcommandline: tbutton;
   messageoutputfile: tfilenameedit;
   copymessages: tbooleanedit;
   closemessages: tbooleanedit;
   checkmethods: tbooleanedit;
   makegroupbox: ttabwidget;
   ttabpage12: ttabpage;
   makeoptionsgrid: twidgetgrid;
   makeon: tbooleanedit;
   buildon: tbooleanedit;
   make1on: tbooleanedit;
   make2on: tbooleanedit;
   make3on: tbooleanedit;
   make4on: tbooleanedit;
   makeoptions: tmemodialogedit;
   ttabpage11: ttabpage;
   unitdirgrid: twidgetgrid;
   dmakeon: tbooleanedit;
   dbuildon: tbooleanedit;
   dmake1on: tbooleanedit;
   dmake2on: tbooleanedit;
   dmake3on: tbooleanedit;
   dmake4on: tbooleanedit;
   duniton: tbooleanedit;
   dincludeon: tbooleanedit;
   dlibon: tbooleanedit;
   dobjon: tbooleanedit;
   unitdirs: tfilenameedit;
   tspacer1: tspacer;
   targpref: tstringedit;
   makedir: tfilenameedit;
   tsplitter1: tsplitter;
   tsplitter2: tsplitter;
   tsplitter4: tsplitter;
   tsplitter5: tsplitter;
   ttabpage1: ttabpage;
   macrogrid: twidgetgrid;
   e0: tbooleanedit;
   e1: tbooleanedit;
   e2: tbooleanedit;
   e3: tbooleanedit;
   e4: tbooleanedit;
   e5: tbooleanedit;
   macronames: tstringedit;
   macrovalues: tmemodialogedit;
   selectactivegroupgrid: twidgetgrid;
   activemacroselect: tbooleaneditradio;
   groupcomment: tstringedit;
   macrosplitter: tsplitter;
   fontaliaspage: ttabpage;
   fontaliasgrid: twidgetgrid;
   fontalias: tstringedit;
   fontname: tstringedit;
   fontheight: tintegeredit;
   ttabpage10: ttabpage;
   tlayouter7: tlayouter;
   tbutton1: tbutton;
   colgrid: twidgetgrid;
   coldi: tpointeredit;
   usercolors: tcoloredit;
   usercolorcomment: tstringedit;
   ttabpage2: ttabpage;
   newfile: ttabwidget;
   ttabpage3: ttabpage;
   copygrid: twidgetgrid;
   loadprojectfile: tbooleanedit;
   expandprojectfilemacros: tbooleanedit;
   newprojectfiles: tfilenameedit;
   newprojectfilesdest: tstringedit;
   ttabpage4: ttabpage;
   ttabpage5: ttabpage;
   ttabpage15: ttabpage;
   twidgetgrid3: twidgetgrid;
   toolsave: tbooleanedit;
   toolparse: tbooleanedit;
   toolhide: tbooleanedit;
   toolmenus: tstringedit;
   toolfiles: tfilenameedit;
   toolparams: tstringedit;
   downloadalways: tbooleanedit;
   startupbkpt: tintegeredit;
   startupbkpton: tbooleanedit;
   valuehints: tbooleanedit;
   debugtarget: tfilenameedit;
   debugtargetsplitter: tsplitter;
   fontwidth: tintegeredit;
   fontoptions: tstringedit;
   fontxscale: trealedit;
   twidgetgrid4: twidgetgrid;
   newfonames: tstringedit;
   newfosources: tfilenameedit;
   newfoforms: tfilenameedit;
   scriptbeforecopy: tfilenameedit;
   scriptaftercopy: tfilenameedit;
   newinheritedforms: tbooleanedit;
   newfonamebases: tstringedit;
   twidgetgrid1: twidgetgrid;
   newfinames: tstringedit;
   newfisources: tfilenameedit;
   newfifilters: tstringedit;
   newfiexts: tstringedit;
   fontancestors: tstringedit;
   ttabpage17: ttabpage;
   ttabpage18: ttabpage;
   befcommandgrid: twidgetgrid;
   befmakeon: tbooleanedit;
   befbuildon: tbooleanedit;
   befmake1on: tbooleanedit;
   befmake2on: tbooleanedit;
   befmake3on: tbooleanedit;
   befmake4on: tbooleanedit;
   befcommand: tmemodialogedit;
   aftcommandgrid: twidgetgrid;
   aftmakeon: tbooleanedit;
   aftbuildon: tbooleanedit;
   aftmake1on: tbooleanedit;
   aftmake2on: tbooleanedit;
   aftmake3on: tbooleanedit;
   aftmake4on: tbooleanedit;
   aftcommand: tmemodialogedit;
   ttabpage20: ttabpage;
   settingseditor: tbooleanedit;
   settingsautoload: tbooleanedit;
   settingsautosave: tbooleanedit;
   tlayouter6: tlayouter;
   savebu: tbutton;
   loadbu: tbutton;
   settingsfile: tfilenameedit;
   settingsdebugger: tbooleanedit;
   settingsstorage: tbooleanedit;
   settingsprojecttree: tbooleanedit;
   nodebugbeginend: tbooleanedit;
   toolmessages: tbooleanedit;
   settty: tbooleanedit;
   tsplitter9: tsplitter;
   beforerun: tfilenameedit;
   afterload: tfilenameedit;
   tsplitter10: tsplitter;
   ttabpage21: ttabpage;
   formatmacrogrid: twidgetgrid;
   formatmacronames: tstringedit;
   formatmacrovalues: tstringedit;
   colorerror: tcoloredit;
   tspacer5: tspacer;
   colorwarning: tcoloredit;
   tspacer6: tspacer;
   colornote: tcoloredit;
   c: tstringcontainer;
   xtermcommand: tmemodialogedit;
   debugsplitter: tsplitter;
   tspacer4: tspacer;
   stripmessageesc: tbooleanedit;
   raiseonbreak: tbooleanedit;
   runcommand: tfilenameedit;
   sourcebase: tfilenameedit;
   tspacer7: tspacer;
   toolshortcuts: tenumedit;
   toolsc: tstringedit;
   toolscalt: tstringedit;
   fpcgdbworkaround: tbooleanedit;
   ttabwidget3: ttabwidget;
   ttabpage22: ttabpage;
   componenthints: tbooleanedit;
   noformdesignerdocking: tbooleanedit;
   moveonfirstclick: tbooleanedit;
   gridsizey: tintegeredit;
   gridsizex: tintegeredit;
   tintegeredit2: tintegeredit;
   snaptogrid: tbooleanedit;
   showgrid: tbooleanedit;
   ttabpage23: ttabpage;
   ttabwidget2: ttabwidget;
   ttabpage13: ttabpage;
   filefiltergrid: tstringgrid;
   ttabpage14: ttabpage;
   twidgetgrid6: twidgetgrid;
   syntaxdeffile: tfilenameedit;
   syntaxdeffilemask: tmemodialogedit;
   ttabpage19: ttabpage;
   twidgetgrid5: twidgetgrid;
   codetemplatedirs: tfilenameedit;
   tlayouter13: tlayouter;
   dispgrid: twidgetgrid;
   fontdisp: ttextedit;
   tlayouter12: tlayouter;
   editfontextraspace: tintegeredit;
   editfontwidth: tintegeredit;
   editfontheight: tintegeredit;
   editfontname: tstringedit;
   editfontcolor: tcoloredit;
   editbkcolor: tcoloredit;
   editfontantialiased: tbooleanedit;
   tlayouter11: tlayouter;
   tlayouter14: tlayouter;
   rightmarginon: tbooleanedit;
   linenumberson: tbooleanedit;
   editmarkbrackets: tbooleanedit;
   editmarkpairwords: tbooleanedit;
   tlayouter15: tlayouter;
   pairmarkcolor: tcoloredit;
   statementcolor: tcoloredit;
   scrollheight: tintegeredit;
   rightmarginchars: tintegeredit;
   tlayouter10: tlayouter;
   spacetabs: tbooleanedit;
   blockindent: tintegeredit;
   autoindent: tbooleanedit;
   tabindent: tbooleanedit;
   tabstops: tintegeredit;
   showtabs: tbooleanedit;
   tlayouter16: tlayouter;
   eolstyle: tenumtypeedit;
   trimtrailingwhitespace: tbooleanedit;
   encoding: tenumedit;
   backupfilecount: tintegeredit;
   tlayouter17: tlayouter;
   objpref: tstringedit;
   libpref: tstringedit;
   incpref: tstringedit;
   unitpref: tstringedit;
   reversepathorder: tbooleanedit;
   settingsmacros: tbooleanedit;
   settingstools: tbooleanedit;
   settingstemplates: tbooleanedit;
   tsimplewidget1: tsimplewidget;
   settingscomponentstore: tbooleanedit;
   settingslayout: tbooleanedit;
   tlabel1: tlabel;
   settingsmake: tbooleanedit;
   settingsusercolors: tbooleanedit;
   settingsformatmacros: tbooleanedit;
   settingsfontalias: tbooleanedit;
   makeoptpurpose: tstringedit;
   pairmaxrowcount: tintegeredit;
   newfoformsuffixes: tstringedit;
   downloadlayouter: tlayouter;
   gdbservercommand: tfilenameedit;
   gdbservercommandattach: tfilenameedit;
   uploadcommand: tfilenameedit;
   texpandingwidget1: texpandingwidget;
   gdbloadtimeout: trealedit;
   serverla: tlayouter;
   gdbserverwait: trealedit;
   gdbserverstartonce: tbooleanedit;
   tlayouter2: tlayouter;
   nogdbserverexit: tbooleanedit;
   gdbservertty: tbooleanedit;
   tstringedit1: tstringedit;
   optafter: tbooleanedit;
   procedure acttiveselectondataentered(const sender: TObject);
   procedure colonshowhint(const sender: tdatacol; const arow: Integer; 
                      var info: hintinfoty);
   procedure hintexpandedmacros(const sender: TObject; var info: hintinfoty);
   procedure selectactiveonrowsmoved(const sender: tcustomgrid; 
                const fromindex: Integer; const toindex: Integer;
                const acount: Integer);
   procedure expandfilename(const sender: TObject; var avalue: mseString; 
                var accept: Boolean);
   procedure showcommandlineonexecute(const sender: TObject);
   procedure signameonsetvalue(const sender: TObject; var avalue: integer;
                var accept: Boolean);
   procedure signumonsetvalue(const sender: TObject; var avalue: integer;
                var accept: Boolean);
   procedure signumtoonsetvalue(const sender: TObject; var avalue: Integer;
                var accept: Boolean);
   procedure fontondataentered(const sender: TObject);
   procedure makepageonchildscaled(const sender: TObject);
   procedure debuggerlayoutexe(const sender: TObject);
   procedure macronchildscaled(const sender: TObject);
   procedure formtemplateonchildscaled(const sender: TObject);
   procedure encodingsetvalue(const sender: TObject; var avalue: integer;
                   var accept: Boolean);
   procedure createexe(const sender: TObject);
   procedure drawcol(const sender: tpointeredit; const acanvas: tcanvas;
                   const avalue: Pointer; const arow: Integer);
   procedure colsetvalue(const sender: TObject; var avalue: colorty;
                   var accept: Boolean);
   procedure copycolorcode(const sender: TObject);
   procedure downloadchange(const sender: TObject);
   procedure processorchange(const sender: TObject);
   procedure copymessagechanged(const sender: TObject);
   procedure updatedebugenabled(const sender: TObject);
   procedure newprojectchildscaled(const sender: TObject);
   procedure saveexe(const sender: TObject);
   procedure settingsdataent(const sender: TObject);
   procedure loadexe(const sender: TObject);
//   procedure extconschangeexe(const sender: TObject);
   procedure setxtermcommandexe(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure activateonbreakset(const sender: TObject; var avalue: Boolean;
                   var accept: Boolean);
   procedure sourcedirhint(const sender: TObject; var info: hintinfoty);
   procedure toolshortcutdropdown(const sender: TObject);
   procedure toolsrowdatachanged(const sender: tcustomgrid;
                   const acell: gridcoordty);
   procedure colorhint(const sender: TObject; var info: hintinfoty);
   procedure initeolstyleexe(const sender: tenumtypeedit);
   procedure debugtargetlayoutev(const sender: TObject);
  private
   procedure activegroupchanged;
 end;

function readprojectoptions(const filename: filenamety): boolean;
         //true if ok
procedure saveprojectoptions(filename: filenamety = '');
procedure initprojectoptions;
function editprojectoptions: boolean;
    //true if not aborted
function getprojectmacros: macroinfoarty;
procedure expandprojectmacros;
function expandprmacros(const atext: msestring): msestring;
procedure expandprmacros1(var atext: msestring);
function projecttemplatedir: filenamety;
function projectfiledialog(var aname: filenamety; save: boolean): modalresultty;
procedure projectoptionsmodified;
function checkprojectloadabort: boolean; //true on load abort

function getsigname(const anum: integer): string;
procedure projectoptionstofont(const afont: tfont);
function objpath(const aname: filenamety): filenamety;
function sourcepath(const aname: filenamety): filenamety;
function gettargetfile: filenamety;
function getmacros: tmacrolist;
procedure hintmacros(const sender: tcustomedit; var info: hintinfoty);

var
 projectoptions: projectoptionsty;
 projecthistory: filenamearty;
 windowlayoutfile: filenamety;
 windowlayouthistory: filenamearty;
 codetemplates: tcodetemplates;

implementation
uses
 projectoptionsform_mfm,breakpointsform,sourceform,msereal,
 objectinspector,msebits,msefileutils,msedesignintf,guitemplates,
 watchform,stackform,main,projecttreeform,findinfileform,
 selecteditpageform,programparametersform,sourceupdate,mseimagelisteditor,
 msesysenvmanagereditor,targetconsole,actionsmodule,mseactions,
 msefilemacros,mseenvmacros,msemacmacros,mseexecmacros,msestrmacros,
 msedesigner,panelform,watchpointsform,commandlineform,messageform,
 componentpaletteform,mserichstring,msesettings,formdesigner,
 msestringlisteditor,msetexteditor,msepropertyeditors,mseshapes,
 componentstore,cpuform,msesysutils,msecomptree,msefont,typinfo
 {$ifndef mse_no_db}{$ifdef FPC},msedbfieldeditor{$endif}{$endif}
 {$ifndef mse_no_ifi}{$ifdef FPC},mseificomponenteditors,
 mseififieldeditor{$endif}{$endif};

var
 projectoptionsfo: tprojectoptionsfo;
type

 stringconststy = (
  wrongencoding,    //0 Wrong encoding can damage your source files.
  wishsetencoding,  //1 Do you wish to set encoding to
  warning,          //2 *** WARNING ***
  c_SIGHUP,         //3 Hangup
  c_SIGINT,         //4 Interrupt
  c_SIGQUIT,        //5 Quit
  c_SIGILL,         //6 Illegal instruction
  c_SIGTRAP,        //7 Trace trap
  c_SIGABRT,        //8 Abort
  c_SIGBUS,         //9 BUS error
  c_SIGFPE,         //10 Floating-point exception
  c_SIGKILL,        //11 Kill
  c_SIGUSR1,        //12 User-defined signal 1
  c_SIGSEGV,        //13 Segmentation violation
  c_SIGUSR2,        //14 User-defined signal 2
  c_SIGPIPE,        //15 Broken pipe
  c_SIGALRM,        //16 Alarm clock
  c_SIGTERM,        //17 Termination
  c_SIGSTKFLT,      //18 Stack fault
  c_SIGCHLD,        //19 Child status has changed
  c_SIGCONT,        //20 Continue
  c_SIGSTOP,        //21 Stop, unblockable
  c_SIGTSTP,        //22 Keyboard stop
  c_SIGTTIN,        //23 Background read from tty
  c_SIGTTOU,        //24 Background write to tty
  c_SIGURG,         //25 Urgent condition on socket
  c_SIGXCPU,        //26 CPU limit exceeded
  c_SIGXFSZ,        //27 File size limit exceeded
  c_SIGTALRM,       //28 Virtual alarm clock
  c_SIGPROF,        //29 Profiling alarm clock
  c_SIGWINCH,       //30 Window size change
  c_SIGIO,          //31 I/O now possible
  c_SIGPWR          //32 Power failure restart
 );
const
 firstsiginfocomment = c_sighup;
 lastsiginfocomment = c_sigpwr;
 
type 
 signalinfoty = record
  num: integer;
  flags: sigflagsty;
  name: string;
  comment: string;
 end;

const
 findinfiledialogstatname =  'findinfiledialogfo.sta';
 finddialogstatname =        'finddialogfo.sta';
 replacedialogstatname =     'replacedialogfo.sta';
 optionsstatname =           'optionsfo.sta';
 settaborderstatname =       'settaborderfo.sta';
 setcreateorderstatname =    'setcreateorderfo.sta';
 programparametersstatname = 'programparametersfo.sta';
 settingsstatname =          'settingsfo.sta';
 printerstatname =           'printer.sta';
 imageselectorstatname =     'imageselector.sta';
 fadeeditorstatname =        'fadeeditor.sta';
 codetemplateselectstatname ='templselect.sta';
 codetemplateparamstatname = 'templparam.sta';
 codetemplateeditstatname =  'templedit.sta';
 cornermaskeditstatname =  'cornermask.sta';
 memodialogstatname =  'memodialog.sta';
 richmemodialogstatname =  'richmemodialog.sta';
 fontformatdialogstatname =  'fontformatdialog.sta';
 taborderoverridedialogstatname =  'taborderoverrideeditor.sta';
 
 siginfocount = 30;
var
 siginfos: array[0..siginfocount-1] of signalinfoty = (
  (num:  1; flags: [sfl_stop]; name: 'SIGHUP'; comment: 'Hangup'),
  (num:  2; flags: [sfl_stop,sfl_internal,sfl_handle]; name: 'SIGINT'; comment: 'Interrupt'),
  (num:  3; flags: [sfl_stop]; name: 'SIGQUIT'; comment: 'Quit'),
  (num:  4; flags: [sfl_stop]; name: 'SIGILL'; comment: 'Illegal instruction'),
  (num:  5; flags: [sfl_stop,sfl_internal,sfl_handle]; name: 'SIGTRAP'; comment: 'Trace trap'),
  (num:  6; flags: [sfl_stop]; name: 'SIGABRT'; comment: 'Abort'),
  (num:  7; flags: [sfl_stop]; name: 'SIGBUS'; comment: 'BUS error'),
  (num:  8; flags: [sfl_stop]; name: 'SIGFPE'; comment: 'Floating-point exception'),
  (num:  9; flags: [sfl_stop]; name: 'SIGKILL'; comment: 'Kill, unblockable'),
  (num: 10; flags: [sfl_stop]; name: 'SIGUSR1'; comment: 'User-defined signal 1'),
  (num: 11; flags: [sfl_stop]; name: 'SIGSEGV'; comment: 'Segmentation violation'),
  (num: 12; flags: [sfl_stop]; name: 'SIGUSR2'; comment: 'User-defined signal 2'),
  (num: 13; flags: [sfl_stop]; name: 'SIGPIPE'; comment: 'Broken pipe'),
  (num: 14; flags: [sfl_internal]; name: 'SIGALRM'; comment: 'Alarm clock'),
  (num: 15; flags: [sfl_stop]; name: 'SIGTERM'; comment: 'Termination'),
  (num: 16; flags: [sfl_stop]; name: 'SIGSTKFLT'; comment: 'Stack fault'),
  (num: 17; flags: [{sfl_stop}]; name: 'SIGCHLD'; comment: 'Child status has changed'),
  (num: 18; flags: [sfl_stop]; name: 'SIGCONT'; comment: 'Continue'),
  (num: 19; flags: [sfl_stop]; name: 'SIGSTOP'; comment: 'Stop, unblockable'),
  (num: 20; flags: [sfl_stop]; name: 'SIGTSTP'; comment: 'Keyboard stop'),
  (num: 21; flags: [sfl_stop]; name: 'SIGTTIN'; comment: 'Background read from tty'),
  (num: 22; flags: [sfl_stop]; name: 'SIGTTOU'; comment: 'Background write to tty'),
  (num: 23; flags: [sfl_stop]; name: 'SIGURG'; comment: 'Urgent condition on socket'),
  (num: 24; flags: [sfl_stop]; name: 'SIGXCPU'; comment: 'CPU limit exceeded'),
  (num: 25; flags: [sfl_stop]; name: 'SIGXFSZ'; comment: 'File size limit exceeded'),
  (num: 26; flags: [sfl_stop]; name: 'SIGTALRM'; comment: 'Virtual alarm clock'),
  (num: 27; flags: [sfl_stop]; name: 'SIGPROF'; comment: 'Profiling alarm clock'),
  (num: 28; flags: [sfl_stop]; name: 'SIGWINCH'; comment: 'Window size change'),
  (num: 29; flags: [sfl_stop]; name: 'SIGIO'; comment: 'I/O now possible'),
  (num: 30; flags: [sfl_stop]; name: 'SIGPWR'; comment: 'Power failure restart')
  );

function getsigname(const anum: integer): string;
var
 int1: integer;
begin
 result:= '';
 for int1:= 0 to high(siginfos) do begin
  if siginfos[int1].num = anum then begin
   result:= siginfos[int1].name;
   break;
  end;
 end;
 if result = '' then begin
  result:= 'SIG'+inttostr(anum);
 end;
end;

function objpath(const aname: filenamety): filenamety;
begin
 result:= '';
 if aname <> '' then begin
  result:= filepath(projectoptions.k.texp.makedir,aname);
 end;
end;

function sourcepath(const aname: filenamety): filenamety;
begin
 result:= '';
 if aname <> '' then begin
  if projectoptions.d.t.sourcebase <> '' then begin
   result:= filepath(projectoptions.d.texp.sourcebase,aname);
  end
  else begin
   result:= objpath(aname);
  end;
 end;
end;

function getprojectmacros: macroinfoarty;
var
 int1,int2: integer;
begin
 setlength(result,6);
 with projectoptions,k do begin
  with result[0] do begin
   name:= 'PROJECTNAME';
   value:= removefileext(filename(projectfilename))
  end;
  with result[1] do begin
   name:= 'PROJECTDIR';
   value:= tosysfilepath(getcurrentdirmse)+pathdelim;
  end;
  with result[2] do begin
   name:= 'MAINFILE';
   if projectoptionsfo = nil then begin
    value:= t.mainfile;
   end
   else begin
    value:= projectoptionsfo.mainfile.value;
   end;
  end;
  with result[3] do begin
   name:= 'TARGETFILE';
   if projectoptionsfo = nil then begin
    value:= t.targetfile;
   end
   else begin
    value:= projectoptionsfo.targetfile.value;
   end;
  end;
  with result[4] do begin
   name:= 'TARGETENV';
   int2:= high(envvarons);
   if int2 > high(d.t.envvarnames) then begin
    int2:= high(d.t.envvarnames);
   end;
   if int2 > high(d.t.envvarvalues) then begin
    int2:= high(d.t.envvarvalues);
   end;
   for int1:= 0 to int2 do begin
    if envvarons[int1] then begin
     value:= value+d.t.envvarnames[int1]+'='+d.t.envvarvalues[int1]+' ';
    end
    else begin
     value:= value+'--unset='+d.t.envvarnames[int1]+' ';
    end;
   end;
  end;
  with result[5] do begin
   name:= 'TARGETPARAMS';
   value:= d.t.progparameters;
  end;
 end;
 result:= initmacros([result,macmacros,filemacros,envmacros,execmacros,
                      strmacros]);
end;

procedure hintmacros(const sender: tcustomedit; var info: hintinfoty);
begin
 info.caption:= tcustomedit(sender).text;
 expandprmacros1(info.caption);
 include(info.flags,hfl_show); //show empty caption
end;

function gettargetfile: filenamety;
begin
 with projectoptions,d.texp do begin
  if trim(debugtarget) <> '' then begin
   result:= objpath(debugtarget);
  end
  else begin
   result:= objpath(k.texp.targetfile);
  end;
 end;
end;

procedure projectoptionstofont(const afont: tfont);
begin
 with projectoptions,afont do begin
  name:= ansistring(e.editfontname);
  height:= e.editfontheight;
  width:= e.editfontwidth;
  extraspace:= e.editfontextraspace;
  if e.editfontantialiased then begin
   options:= options + [foo_antialiased2];
  end
  else begin
   options:= options + [foo_nonantialiased];
  end;
  color:= e.editfontcolor;
 end;
end;

function checkprojectloadabort: boolean;
begin
 result:= false;
 if exceptobject is exception then begin
  if showmessage(msestring(exception(exceptobject).Message),
      actionsmo.c[ord(ac_error)],[mr_skip,mr_cancel]) <> mr_skip then begin
   result:= true;
  end;
 end
 else begin
  raise exception.create(ansistring(actionsmo.c[ord(ac_invalidexception)]));
 end;
end;

function projectfiledialog(var aname: filenamety; save: boolean): modalresultty;
begin
 with mainfo.projectfiledia.controller do begin
  filename:= projectoptions.projectfilename;
  history:= projecthistory;
  if save then begin
   result:= execute(fdk_save,[fdo_save,fdo_checkexist]);
  end
  else begin
   result:= execute(fdk_open,[fdo_checkexist]);
  end;
  aname:= filename;
  projecthistory:= history;
 end;
end;

function getmacros: tmacrolist;
var
 ar1: macroinfoarty;
 int1,int2: integer;
 mask: integer;
 
begin
 with projectoptions.m do begin
  result:= tmacrolist.create([mao_caseinsensitive]);
  result.add(getsettingsmacros);
  result.add(getcommandlinemacros);
  result.add(getprojectmacros);
  mask:= bits[projectoptions.s.macrogroup];
  setlength(fmacrovalues,length(macronames));
  setlength(ar1,length(macronames)); //max
  int2:= 0;
  for int1:= 0 to high(ar1) do begin
   if macroon[int1] and mask <> 0 then begin
    ar1[int2].name:= macronames[int1];
    ar1[int2].value:= macrovalues[int1];
    inc(int2);
   end;
  end;
  setlength(ar1,int2);
  result.add(ar1);
 end;
end;

procedure expandprmacros1(var atext: msestring);
var
 li: tmacrolist;
begin
 li:= getmacros;
 li.expandmacros1(atext);
 li.Free;
end;

function projecttemplatedir: filenamety;
begin
 result:= expandprmacros('${TEMPLATEDIR}');
end;

function expandprmacros(const atext: msestring): msestring;
begin
 result:= atext;
 expandprmacros1(result);
end;

var
 initfontaliascount: integer;
 
procedure expandprojectmacros;
var
 li: tmacrolist;
 int1,int2: integer;
 bo1: boolean;
 item1: tmenuitem;
 act1: taction;
begin
 li:= getmacros;
 with projectoptions do begin
//  o.expandmacros(li);
  e.expandmacros(li);
  d.expandmacros(li);
  m.expandmacros(li);
  k.expandmacros(li);
  a.expandmacros(li);
  u.expandmacros(li);
  f.expandmacros(li);
  p.expandmacros(li);
  t.expandmacros(li);
  r.expandmacros(li);
  s.expandmacros(li);
  with a,texp do begin
   if initfontaliascount = 0 then begin
    initfontaliascount:= fontaliascount;
   end;
   setfontaliascount(initfontaliascount);
   int2:= high(fontalias);
   int1:= high(fontancestors);
   setlength(ffontancestors,int2+1); //additional field
   for int1:= int1+1 to int2 do begin
    fontancestors[int1]:= 'sft_default';
   end;
   if int2 > high(fontnames) then begin
    int2:= high(fontnames);
   end;
   if int2 > high(fontheights) then begin
    int2:= high(fontheights);
   end;
   if int2 > high(fontwidths) then begin
    int2:= high(fontwidths);
   end;
   if int2 > high(fontoptions) then begin
    int2:= high(fontoptions);
   end;
   if int2 > high(fontxscales) then begin
    int2:= high(fontxscales);
   end;
   for int1:= 0 to int2 do begin
    try
     registerfontalias(ansistring(fontalias[int1]),
                ansistring(fontnames[int1]),fam_overwrite,
                fontheights[int1],fontwidths[int1],
                fontoptioncharstooptions(ansistring(fontoptions[int1])),
                fontxscales[int1],ansistring(fontancestors[int1]));
    except
     application.handleexception;
    end;
   end;
   if sourceupdater <> nil then begin
    sourceupdater.maxlinelength:= e.rightmarginchars;
   end;
   fontaliasnames:= fontalias;
  end;
  with s,texp do begin
   with sourcefo.syntaxpainter do begin
    bo1:= not cmparray(defdefs.asarraya,e.texp.sourcefilemasks) or
       not cmparray(defdefs.asarrayb,e.texp.syntaxdeffiles);
    defdefs.asarraya:= e.texp.sourcefilemasks;
    defdefs.asarrayb:= e.texp.syntaxdeffiles;
    if bo1 then begin
     sourcefo.syntaxpainter.clear;
     try
      for int1:= 0 to sourcefo.count - 1 do begin
       sourcefo.items[int1].edit.setsyntaxdef(sourcefo.items[int1].edit.filename);
      end;
     except
      application.handleexception;
     end;
    end;
   end;
   for int1:= 0 to sourcefo.count - 1 do begin
    sourcefo.items[int1].updatestatvalues;
   end;
   with mainfo.openfile.controller.filterlist do begin
    asarraya:= e.texp.filemasknames;
    asarrayb:= e.texp.filemasks;
   end;
   item1:= mainfo.mainmenu1.menu.itembynames(['file','new']);
   item1.submenu.count:= 1;
   with p.texp do begin
    item1.submenu.count:= length(newfinames)+1;
    for int1:= 0 to high(newfinames) do begin
     with item1.submenu[int1+1] do begin
      caption:= newfinames[int1];
      tag:= int1;
      onexecute:= {$ifdef FPC}@{$endif}mainfo.newfileonexecute;
     end;
    end;
 
    item1:= mainfo.mainmenu1.menu.itembynames(['file','new','form']);
    item1.submenu.count:= 0;
    item1.submenu.count:= length(newfonames)+1;
    int2:= 0;
    for int1:= 0 to high(newfonames) do begin
     if not p.newinheritedforms[int1] then begin
      with item1.submenu[int2] do begin
       caption:= newfonames[int1];
       tag:= int1;
       onexecute:= {$ifdef FPC}@{$endif}mainfo.newformonexecute;
      end;
      inc(int2);
     end;
    end;
    item1.submenu[int2].options:= [mao_separator];
    inc(int2);
    for int1:= 0 to high(newfonames) do begin
     if p.newinheritedforms[int1] then begin
      with item1.submenu[int2] do begin
       caption:= newfonames[int1];
       tag:= int1;
       onexecute:= {$ifdef FPC}@{$endif}mainfo.newformonexecute;
      end;
      inc(int2);
     end;
    end;
   end;
   with mainfo.mainmenu1.menu.submenu do begin
    item1:= itembyname('tools');
    with projectoptions.t,texp do begin
     if toolmenus <> nil then begin
      if item1 = nil then begin
       item1:= tmenuitem.create;
       item1.name:= 'tools';
       item1.caption:= actionsmo.c[ord(ac_tools)];
       insert(itemindexbyname('settings'),item1);
      end;
      with item1.submenu do begin
       clear;
       for int1:= 0 to high(toolmenus) do begin
        if (int1 > high(toolfiles)) or (int1 > high(toolparams)) then begin
         break;
        end;
        int2:= insert(bigint,[toolmenus[int1]],
                   [[mao_asyncexecute,mao_shortcutcaption]],
                                [],[{$ifdef FPC}@{$endif}mainfo.runtool]);
        if (int1 <= high(toolshortcuts)) and 
            actionsmo.gettoolshortcutaction(toolshortcuts[int1],act1) then begin
         with items[int2] do begin
          shortcuts:= act1.shortcuts;
          shortcuts1:= act1.shortcuts1;
         end;
        end;
       end;
      end;
     end
     else begin
      if item1 <> nil then begin
       delete(item1.index);
      end;
     end;
    end;
   end;
  end;
  ignoreexceptionclasses:= nil;
  for int1:= 0 to high(d.exceptignore) do begin
   if int1 > high(d.exceptclassnames) then begin
    break;
   end;
   if d.exceptignore[int1] then begin
    additem(ignoreexceptionclasses,ansistring(d.exceptclassnames[int1]));
   end;
  end;
  for int1:= 0 to usercolorcount - 1 do begin
   if int1 > high(u.usercolors) then begin
    break;
   end;
   setcolormapvalue(cl_user + longword(int1),u.usercolors[int1]);
  end;
  clearformatmacros;
  for int1:= 0 to high(f.texp.formatmacronames) do begin
   if int1 > high(f.texp.formatmacrovalues) then begin
    break;
   end;
   formatmacros.add(f.texp.formatmacronames[int1],f.texp.formatmacrovalues[int1],[]);
  end;
  
  codetemplates.scan(e.texp.codetemplatedirs);
 end;
 li.free;
 mainfo.updatesigsettings;
end;

function defaultsigsettings: sigsetinfoarty;
var
 int1,int2: integer;
begin
 setlength(result,siginfocount);
 int2:= 0;
 for int1:= 0 to siginfocount - 1 do begin
  with result[int2] do begin
   if not (sfl_internal in siginfos[int1].flags) then begin
    num:= siginfos[int1].num;
    numto:= num;
    flags:= siginfos[int1].flags;
    inc(int2);
   end;
  end;
 end;
 setlength(result,int2);
end;

procedure freeoptions();
begin
// projectoptions.o.free();
 projectoptions.e.free();
 projectoptions.d.free();
 projectoptions.k.free();
 projectoptions.m.free();
 projectoptions.a.free();
 projectoptions.u.free();
 projectoptions.f.free();
 projectoptions.t.free();
 projectoptions.r.free();
 projectoptions.p.free();
 projectoptions.s.free();
end;

procedure createoptions();
begin
// projectoptions.o:= tprojectoptions.create();
 projectoptions.e:= teditoptions.create();
 projectoptions.d:= tdebugoptions.create();
 projectoptions.k:= tmakeoptions.create();
 projectoptions.m:= tmacrooptions.create();
 projectoptions.a:= tfontaliasoptions.create();
 projectoptions.u:= tusercoloroptions.create();
 projectoptions.f:= tformatmacrooptions.create();
 projectoptions.t:= ttoolsoptions.create();
 projectoptions.r:= tstorageoptions.create();
 projectoptions.p:= ttemplatesoptions.create();
 projectoptions.s:= tprojectstate.create();
end;

procedure initpr(const expand: boolean);
const 
 alloptionson = 1+2+4+8+16+32;
 unitson = 1+2+4+8+16+32+$10000;
 allon = unitson+$20000+$40000;
var
 int1: integer;
begin
 freeoptions();
 codetemplates.clear();
 finalize(projectoptions);
 fillchar(projectoptions,sizeof(projectoptions),0);
 createoptions();
 with projectoptions,k,t do begin
  if expand then begin
   deletememorystatstream(findinfiledialogstatname);
   deletememorystatstream(finddialogstatname);
   deletememorystatstream(replacedialogstatname);
   deletememorystatstream(optionsstatname);
   deletememorystatstream(settaborderstatname);
   deletememorystatstream(setcreateorderstatname);
   deletememorystatstream(programparametersstatname);
   deletememorystatstream(printerstatname);
   deletememorystatstream(imageselectorstatname);
   deletememorystatstream(stringlisteditorstatname);
   deletememorystatstream(texteditorstatname);
   deletememorystatstream(colordialogstatname);
   deletememorystatstream(compnamedialogstatname);
   deletememorystatstream(bmpfiledialogstatname);
   deletememorystatstream(fadeeditorstatname);
   deletememorystatstream(codetemplateselectstatname);
   deletememorystatstream(codetemplateparamstatname);
   deletememorystatstream(codetemplateeditstatname);
   deletememorystatstream(cornermaskeditstatname);
   deletememorystatstream(memodialogstatname);
   deletememorystatstream(richmemodialogstatname);
   deletememorystatstream(fontformatdialogstatname);
   deletememorystatstream(taborderoverridedialogstatname);
   {$ifndef mse_no_db}{$ifdef FPC}
   deletememorystatstream(dbfieldeditorstatname);
   {$endif}{$endif}
   {$ifndef mse_no_ifi}{$ifdef FPC}
   deletememorystatstream(ificlienteditorstatname);
   deletememorystatstream(ififieldeditorstatname);
   {$endif}{$endif}
   modified:= false;
   savechecked:= false;
   findreplaceinfo.find.options:= [so_caseinsensitive];
   targetconsolefindinfo.options:= [so_caseinsensitive];
  end;
  sigsettings:= defaultsigsettings;
  ignoreexceptionclasses:= nil;

  additem(fmakeoptions,'-l -Mobjfpc -Sh -Fcutf8');
  additem(fmakeoptions,'-gl -O-');
  additem(fmakeoptions,'-B');
  additem(fmakeoptions,'-O2 -XX -CX -Xs');
  setlength(fmakeoptionson,length(fmakeoptions));
  for int1:= 0 to high(fmakeoptionson) do begin
   fmakeoptionson[int1]:= alloptionson;
  end;
  fmakeoptionson[1]:= alloptionson and not bits[5]; 
                     //all but make 4
  fmakeoptionson[2]:= bits[1] or bits[5]; //build + make 4
  fmakeoptionson[3]:= bits[5]; //make 4
  defaultmake:= 1; //make
  additem(funitdirs,'${MSELIBDIR}*/');
//  additem(funitdirs,'${MSELIBDIR}kernel/');
  additem(funitdirs,'${MSELIBDIR}kernel/$TARGETOSDIR/');
  setlength(funitdirson,length(unitdirs));
  for int1:= 0 to high(funitdirson) do begin
   funitdirson[int1]:= unitson;
  end;
//  funitdirson[1]:= unitson + $20000; //kernel include
  unitdirs:= reversearray(unitdirs);
  unitdirson:= reversearray(unitdirson);
  unitpref:= '-Fu';
  incpref:= '-Fi';
  libpref:= '-Fl';
  objpref:= '-Fo';
  targpref:= '-o';
  makecommand:= '${COMPILER}';
  with p,t do begin
   setlength(fnewfinames,3);
   setlength(fnewfifilters,3);
   setlength(fnewfiexts,3);
   setlength(fnewfisources,3);
   
   newfinames[0]:= actionsmo.c[ord(ac_program)];
   newfifilters[0]:= '"*.pas" "*.pp"';
   newfiexts[0]:= 'pas';
   newfisources[0]:= '${TEMPLATEDIR}default/program.pas';
 
   newfinames[1]:= actionsmo.c[ord(ac_unit)];
   newfifilters[1]:= '"*.pas" "*.pp"';
   newfiexts[1]:= 'pas';
   newfisources[1]:= '${TEMPLATEDIR}default/unit.pas';
 
   newfinames[2]:= actionsmo.c[ord(ac_textfile)];
   newfifilters[2]:= '';
   newfiexts[2]:= '';
   newfisources[2]:= '';
   
   setlength(fnewfonames,12);
   setlength(fnewfonamebases,12);
   setlength(fnewfoformsuffixes,12);
   setlength(p.fnewinheritedforms,12);
   setlength(fnewfosources,12);
   setlength(fnewfoforms,12);
 
   newfonames[0]:= actionsmo.c[ord(ac_mainform)];
   newfonamebases[0]:= 'form';
   newfoformsuffixes[0]:= 'fo';
   newinheritedforms[0]:= false;
   newfosources[0]:= '${TEMPLATEDIR}default/mainform.pas';
   newfoforms[0]:= '${TEMPLATEDIR}default/mainform.mfm';
  
   newfonames[1]:= actionsmo.c[ord(ac_simpleform)];
   newfonamebases[1]:= 'form';
   newfoformsuffixes[1]:= 'fo';
   newinheritedforms[1]:= false;
   newfosources[1]:= '${TEMPLATEDIR}default/simpleform.pas';
   newfoforms[1]:= '${TEMPLATEDIR}default/simpleform.mfm';
  
   newfonames[2]:= actionsmo.c[ord(ac_dockingform)];
   newfonamebases[2]:= 'form';
   newfoformsuffixes[2]:= 'fo';
   newinheritedforms[2]:= false;
   newfosources[2]:= '${TEMPLATEDIR}default/dockingform.pas';
   newfoforms[2]:= '${TEMPLATEDIR}default/dockingform.mfm';
  
   newfonames[3]:= actionsmo.c[ord(ac_sizingform)];
   newfonamebases[3]:= 'form';
   newfoformsuffixes[3]:= 'fo';
   newinheritedforms[3]:= false;
   newfosources[3]:= '${TEMPLATEDIR}default/sizingform.pas';
   newfoforms[3]:= '${TEMPLATEDIR}default/sizingform.mfm';
  
   newfonames[4]:= actionsmo.c[ord(ac_datamodule)];
   newfonamebases[4]:= 'module';
   newfoformsuffixes[4]:= 'mo';
   newinheritedforms[4]:= false;
   newfosources[4]:= '${TEMPLATEDIR}default/datamodule.pas';
   newfoforms[4]:= '${TEMPLATEDIR}default/datamodule.mfm';
  
   newfonames[5]:= actionsmo.c[ord(ac_subform)];
   newfonamebases[5]:= 'form';
   newfoformsuffixes[5]:= 'fo';
   newinheritedforms[5]:= false;
   newfosources[5]:= '${TEMPLATEDIR}default/subform.pas';
   newfoforms[5]:= '${TEMPLATEDIR}default/subform.mfm';
 
   newfonames[6]:= actionsmo.c[ord(ac_scrollboxform)];
   newfonamebases[6]:= 'form';
   newfoformsuffixes[6]:= 'fo';
   newinheritedforms[6]:= false;
   newfosources[6]:= '${TEMPLATEDIR}default/scrollboxform.pas';
   newfoforms[6]:= '${TEMPLATEDIR}default/scrollboxform.mfm';
 
   newfonames[7]:= actionsmo.c[ord(ac_tabform)];
   newfonamebases[7]:= 'form';
   newfoformsuffixes[7]:= 'fo';
   newinheritedforms[7]:= false;
   newfosources[7]:= '${TEMPLATEDIR}default/tabform.pas';
   newfoforms[7]:= '${TEMPLATEDIR}default/tabform.mfm';
  
   newfonames[8]:= actionsmo.c[ord(ac_dockpanel)];
   newfonamebases[8]:= 'form';
   newfoformsuffixes[8]:= 'fo';
   newinheritedforms[8]:= false;
   newfosources[8]:= '${TEMPLATEDIR}default/dockpanelform.pas';
   newfoforms[8]:= '${TEMPLATEDIR}default/dockpanelform.mfm';
 
   newfonames[9]:= actionsmo.c[ord(ac_report)];
   newfonamebases[9]:= 'report';
   newfoformsuffixes[9]:= 're';
   newinheritedforms[9]:= false;
   newfosources[9]:= '${TEMPLATEDIR}default/report.pas';
   newfoforms[9]:= '${TEMPLATEDIR}default/report.mfm';
  
   newfonames[10]:= actionsmo.c[ord(ac_scriptform)];
   newfonamebases[10]:= 'script';
   newfoformsuffixes[10]:= 'sc';
   newinheritedforms[10]:= false;
   newfosources[10]:= '${TEMPLATEDIR}default/pascform.pas';
   newfoforms[10]:= '${TEMPLATEDIR}default/pascform.mfm';
 
   newfonames[11]:= actionsmo.c[ord(ac_inheritedform)];
   newfonamebases[11]:= 'form';
   newfoformsuffixes[11]:= 'fo';
   newinheritedforms[11]:= true;
   newfosources[11]:= '${TEMPLATEDIR}default/inheritedform.pas';
   newfoforms[11]:= '${TEMPLATEDIR}default/inheritedform.mfm';
  end;
 
 end;
 with projectoptions,e,t do begin
  
  additem(fsourcefilemasks,'"*.pas" "*.dpr" "*.lpr" "*.pp" "*.inc"');
  additem(fsyntaxdeffiles,'${SYNTAXDEFDIR}pascal.sdef');
  additem(fsourcefilemasks,'"*.c" "*.cc" "*.h"');
  additem(fsyntaxdeffiles,'${SYNTAXDEFDIR}cpp.sdef');
  additem(fsourcefilemasks,'"*.mfm"');
  additem(fsyntaxdeffiles,'${SYNTAXDEFDIR}objecttext.sdef');

  additem(ffilemasknames,actionsmo.c[ord(ac_source)]);
  additem(ffilemasks,'"*.pp" "*.pas" "*.inc" "*.dpr" "*.lpr"');
  additem(ffilemasknames,actionsmo.c[ord(ac_forms)]);
  additem(ffilemasks,'*.mfm');
  additem(ffilemasknames,actionsmo.c[ord(ac_allfiles)]);
  additem(ffilemasks,'*');

 end;
 with projectoptions,d,t do begin
  debugcommand:= '${DEBUGGER}';
  gdbprocessor:= 'auto';
  additem(fsourcedirs,'./');
  additem(fsourcedirs,'${MSELIBDIR}*/');
  additem(fsourcedirs,'${MSELIBDIR}kernel/$TARGETOSDIR/');
  sourcedirs:= reversearray(sourcedirs);
 end;
 if expand then begin 
  expandprojectmacros;
 end;
end;

procedure initprojectoptions;
begin
 initpr(true);
end;

procedure projectoptionsmodified;
begin
 projectoptions.modified:= true;
 projectoptions.savechecked:= false;
end;

procedure setsignalinfocount(const count: integer);
begin
 if count = 0 then begin
  projectoptions.sigsettings:= defaultsigsettings;
 end
 else begin
  setlength(projectoptions.sigsettings,count);
 end;
end;

procedure storesignalinforec(const index: integer;
          const avalue: msestring);
var
 stop,handle: boolean;
begin
 with projectoptions.sigsettings[index] do begin
  decoderecord(avalue,[@num,@numto,@stop,@handle],'iibb');
  updatebit({$ifdef FPC}longword{$else}byte{$endif}(flags),ord(sfl_stop),stop);
  updatebit({$ifdef FPC}longword{$else}byte{$endif}(flags),ord(sfl_handle),handle);
 end;
end;

function getsignalinforec(const index: integer): msestring;
var
 stop,handle: boolean;
begin
 with projectoptions.sigsettings[index] do begin
  stop:= sfl_stop in flags;
  handle:= sfl_handle in flags;
  result:= encoderecord([num,numto,stop,handle]);
 end;
end;

procedure updateprojectsettings(const statfiler: tstatfiler;
                                    const disabledoptions: settinggroupsty);
var
 int1: integer;
 i2: int32;
begin
 with statfiler,projectoptions,s,t do begin
  
  if iswriter then begin
   mainfo.statoptions.writestat(tstatwriter(statfiler));
  end
  else begin
   mainfo.statoptions.readstat(tstatreader(statfiler));
   with projectoptions.t do begin
    setlength(ftoolmessages,length(ftoolsave));
   end;
  end;
  if not (sg_debugger in disabledoptions) then begin
   if iswriter then begin
    with tstatwriter(statfiler) do begin
     writerecordarray('sigsettings',length(sigsettings),
                      {$ifdef FPC}@{$endif}getsignalinforec);
    end;
   end
   else begin
    with tstatreader(statfiler) do begin
     readrecordarray('sigsettings',{$ifdef FPC}@{$endif}setsignalinfocount,
              {$ifdef FPC}@{$endif}storesignalinforec);
    end;
   end;
  end;
  if not (sg_state in disabledoptions) then begin
   updatevalue('defaultmake',defaultmake,1,maxdefaultmake+1);
  end;
  with p,t do begin
   if not iswriter then begin
    int1:= length(newfinames);
    if int1 > length(newfifilters) then begin
     int1:= length(newfifilters);
    end;
    if int1 > length(newfiexts) then begin
     int1:= length(newfiexts);
    end;
    if int1 > length(newfisources) then begin
     int1:= length(newfisources);
    end;
    setlength(fnewfinames,int1);
    setlength(fnewfifilters,int1);
    setlength(fnewfiexts,int1);
    setlength(fnewfisources,int1);
   end;
     
   if not iswriter then begin
    int1:= length(newfonames);
    if int1 > length(newfonamebases) then begin
     int1:= length(newfonamebases);
    end;
    if high(newfoformsuffixes) <> high(newfonamebases) then begin
                      //probably old statfile
     setlength(fnewfoformsuffixes,length(newfonamebases));
     for i2:= 0 to high(fnewfoformsuffixes) do begin
      fnewfoformsuffixes[i2]:= copy(fnewfonamebases[i2],1,2)
     end;
    end;
    if int1 > length(newfoformsuffixes) then begin
     int1:= length(newfoformsuffixes);
    end;
    if int1 > length(newinheritedforms) then begin
     int1:= length(newinheritedforms);
    end;
    if int1 > length(newfosources) then begin
     int1:= length(newfosources);
    end;
    if int1 > length(newfoforms) then begin
     int1:= length(newfoforms);
    end;
    setlength(fnewfonames,int1);
    setlength(fnewfonamebases,int1);
    setlength(fnewfoformsuffixes,int1);
    setlength(fnewinheritedforms,int1);
    setlength(fnewfosources,int1);
    setlength(fnewfoforms,int1);
   end;
  end;
 end;
end;

procedure doloadexe(const sender: tprojectoptionsfo); forward;
procedure dosaveexe(const sender: tprojectoptionsfo); forward;

function getdisabledoptions: settinggroupsty;
begin
 result:= [sg_state];
 with projectoptions do begin
  if not r.settingseditor then begin
   include(result,sg_editor);
  end;
  if not r.settingsdebugger then begin
   include(result,sg_debugger);
  end;
  if not r.settingsmake then begin
   include(result,sg_make);
  end;
  if not r.settingsmacros then begin
   include(result,sg_macros);
  end;
  if not r.settingsfontalias then begin
   include(result,sg_fontalias);
  end;
  if not r.settingsusercolors then begin
   include(result,sg_usercolors);
  end;
  if not r.settingsformatmacros then begin
   include(result,sg_formatmacros);
  end;
  if not r.settingstemplates then begin
   include(result,sg_templates);
  end;
  if not r.settingstools then begin
   include(result,sg_tools);
  end;
  if not r.settingsstorage then begin
   include(result,sg_storage);
  end;
 end;
end;

procedure updateprojectoptions(const statfiler: tstatfiler;
                  const afilename: filenamety);
var
 int1,int2,int3: integer;
 b1: boolean;
 modulenames1: msestringarty;
 moduletypes1: msestringarty;
 
 modulefiles1: filenamearty;
// moduledock1: msestringarty;
begin
 with statfiler,projectoptions do begin
  if iswriter then begin
   projectdir:= getcurrentdirmse;
   with mainfo,mainmenu1.menu.itembyname('view') do begin
    int3:= formmenuitemstart;
    int2:= count - int3;
    setlength(modulenames1,int2);
    setlength(moduletypes1,int2);
    setlength(modulefiles1,int2);
//    setlength(moduledock1,int2);
    for int1:= 0 to high(modulenames1) do begin
     with pmoduleinfoty(submenu[int1+int3].tagpointer)^ do begin
      modulenames1[int1]:= msestring(struppercase(instance.name));
      moduletypes1[int1]:= msestring(struppercase(string(moduleclassname)));
      modulefiles1[int1]:= filename;
     end;
    end;
    s.modulenames:= modulenames1;
    s.moduletypes:= moduletypes1;
    s.modulefiles:= modulefiles1;
   end;
  end;
  registeredcomponents.updatestat(statfiler);
  setsection('projectoptions');
  updatevalue('projectdir',projectdir);
  updatevalue('projectfilename',projectfilename);
  projectfilename:= afilename;
  updatememorystatstream('findinfiledialog',findinfiledialogstatname);
  updatememorystatstream('finddialog',finddialogstatname);
  updatememorystatstream('replacedialog',replacedialogstatname);
  updatememorystatstream('options',optionsstatname);
  updatememorystatstream('settaborder',settaborderstatname);
  updatememorystatstream('setcreateorder',setcreateorderstatname);
  updatememorystatstream('programparameters',programparametersstatname);
  updatememorystatstream('settings',settingsstatname);
  updatememorystatstream('printer',printerstatname);
  updatememorystatstream('imageselector',imageselectorstatname);
  updatememorystatstream('fadeeditor',fadeeditorstatname);
  updatememorystatstream('stringlisteditor',stringlisteditorstatname);
  updatememorystatstream('imagelisteditor',imagelisteditorstatname);
  updatememorystatstream('sysenvmanagereditor',sysenvmanagereditorstatname);
  updatememorystatstream('texteditor',texteditorstatname);
  updatememorystatstream('colordialog',colordialogstatname);
  updatememorystatstream('compnamedialog',compnamedialogstatname);
  updatememorystatstream('bmpfiledialog',bmpfiledialogstatname);
  updatememorystatstream('codetemplateselect',codetemplateselectstatname);
  updatememorystatstream('codetemplateparam',codetemplateparamstatname);
  updatememorystatstream('codetemplateedit',codetemplateeditstatname);
  updatememorystatstream('cornermaskedit',cornermaskeditstatname);
  updatememorystatstream('memodialog',memodialogstatname);
  updatememorystatstream('richmemodialog',richmemodialogstatname);
  updatememorystatstream('fontformatdialog',fontformatdialogstatname);
  updatememorystatstream('taborderoverridedialog',
                                            taborderoverridedialogstatname);
{$ifndef mse_no_db}{$ifdef FPC}
  updatememorystatstream('dbfieldeditor',dbfieldeditorstatname);
{$endif}{$endif}
{$ifndef mse_no_ifi}{$ifdef FPC}
  updatememorystatstream('ificlienteditor',ificlienteditorstatname);
  updatememorystatstream('ififieldeditor',ififieldeditorstatname);
{$endif}{$endif}

  updateprojectsettings(statfiler,[]);
  b1:= projecttree.updatestat(statfiler) or statfiler.iswriter;
  breakpointsfo.updatestat(statfiler);
  panelform.updatestat(statfiler); //uses section breakpoints!
  if not b1 then begin
   projecttree.updatestat(statfiler); //backward compatibility with section
                                      //breakpoints
  end;
  componentstorefo.updatestat(statfiler);

  setsection('components');
  selecteditpageform.updatestat(statfiler);
  programparametersform.updatestat(statfiler);
  projectoptionstofont(textpropertyfont);

  if not iswriter then begin
   if guitemplatesmo.sysenv.getintegervalue(int1,
                                             ord(env_vargroup),1,6) then begin
    s.macrogroup:= int1-1;
   end;
   expandprojectmacros;
   projecttree.updatelist;
  end;

  beginpanelplacement();
  try
   sourcefo.updatestat(statfiler);   //needs actual fontalias
   setsection('layout');
   mainfo.projectstatfile.updatestat('windowlayout',statfiler);
  finally
   endpanelplacement();
  end;
  setsection('targetconsole');
  targetconsole.updatestat(statfiler);

  modified:= false;
  savechecked:= false;

  if iswriter then begin
   if r.settingsautosave then begin
    dosaveexe(nil);
   end;
  end
  else begin
   if r.settingsautoload then begin
    doloadexe(nil);
   end;
  end;
 end;
end;

procedure projectoptionstoform(fo: tprojectoptionsfo);
var
 int1,int2: integer;
begin
 fo.optafter.tag:= optaftermainfilemask;
 with projectoptions do begin
  int1:= length(t.toolshortcuts);
  setlength(t.ftoolshortcuts,length(t.t.toolmenus));
  for int2:= int1 to high(t.toolshortcuts) do begin
   t.toolshortcuts[int2]:= -1; //init for backward compatibility
  end;
 end;
 {$ifdef mse_with_ifi}
 mainfo.statoptions.objtovalues(fo);
 {$endif}
 fo.colgrid.rowcount:= usercolorcount;
 fo.colgrid.fixcols[-1].captions.count:= usercolorcount;
 with fo,projectoptions do begin
  for int1:= 0 to colgrid.rowhigh do begin
   colgrid.fixcols[-1].captions[int1]:= 
                   msestring(colortostring(cl_user+longword(int1)));
  end;
 end;
 with fo.signame do begin
  setlength(enums,siginfocount);
  int2:= 0;
  for int1:= 0 to siginfocount - 1 do begin
   with siginfos[int1] do begin
    if not (sfl_internal in flags) then begin
     enums[int2]:= num;
     dropdownitems.addrow([msestring(name),msestring(comment)]);
     dropdown.cols.addrow([msestring(comment)+ ' ('+msestring(name)+')']);
     inc(int2);
    end;
   end;
  end;
  setlength(enums,int2);
 end;
 with projectoptions{,t} do begin
  fo.signalgrid.rowcount:= length(sigsettings);
  for int1:= 0 to high(sigsettings) do begin
   with sigsettings[int1] do begin
    fo.signum[int1]:= num;
    fo.signumto[int1]:= numto;
    if num = numto then begin
     fo.signame[int1]:= num;
    end
    else begin
     fo.signame[int1]:= -1;
    end;
    fo.sigstop[int1]:= sfl_stop in flags;
    fo.sighandle[int1]:= sfl_handle in flags;
   end;
  end;
  fo.fontondataentered(nil);
  fo.defaultmake.value:= lowestbit(defaultmake);
  for int1:= 0 to fo.makeoptionsgrid.rowhigh do begin
   if int1 > high(k.makeoptionson) then begin
    break;
   end;
   fo.makeon.gridupdatetagvalue(int1,k.makeoptionson[int1]);
   fo.buildon.gridupdatetagvalue(int1,k.makeoptionson[int1]);
   fo.make1on.gridupdatetagvalue(int1,k.makeoptionson[int1]);
   fo.make2on.gridupdatetagvalue(int1,k.makeoptionson[int1]);
   fo.make3on.gridupdatetagvalue(int1,k.makeoptionson[int1]);
   fo.make4on.gridupdatetagvalue(int1,k.makeoptionson[int1]);
   fo.optafter.gridupdatetagvalue(int1,k.makeoptionson[int1]);
  end;

  for int1:= 0 to fo.befcommandgrid.rowhigh do begin
   if int1 > high(k.befcommandon) then begin
    break;
   end;
   fo.befmakeon.gridupdatetagvalue(int1,k.befcommandon[int1]);
   fo.befbuildon.gridupdatetagvalue(int1,k.befcommandon[int1]);
   fo.befmake1on.gridupdatetagvalue(int1,k.befcommandon[int1]);
   fo.befmake2on.gridupdatetagvalue(int1,k.befcommandon[int1]);
   fo.befmake3on.gridupdatetagvalue(int1,k.befcommandon[int1]);
   fo.befmake4on.gridupdatetagvalue(int1,k.befcommandon[int1]);
  end;

  for int1:= 0 to fo.aftcommandgrid.rowhigh do begin
   if int1 > high(k.aftcommandon) then begin
    break;
   end;
   fo.aftmakeon.gridupdatetagvalue(int1,k.aftcommandon[int1]);
   fo.aftbuildon.gridupdatetagvalue(int1,k.aftcommandon[int1]);
   fo.aftmake1on.gridupdatetagvalue(int1,k.aftcommandon[int1]);
   fo.aftmake2on.gridupdatetagvalue(int1,k.aftcommandon[int1]);
   fo.aftmake3on.gridupdatetagvalue(int1,k.aftcommandon[int1]);
   fo.aftmake4on.gridupdatetagvalue(int1,k.aftcommandon[int1]);
  end;

  fo.unitdirs.gridvalues:= reversearray(k.t.unitdirs);
  int2:= high(k.t.unitdirs);
  for int1:= 0 to int2 do begin
   if int1 > high(k.unitdirson) then begin
    break;
   end;
   fo.dmakeon.gridupdatetagvalue(int2,k.unitdirson[int1]);
   fo.dbuildon.gridupdatetagvalue(int2,k.unitdirson[int1]);
   fo.dmake1on.gridupdatetagvalue(int2,k.unitdirson[int1]);
   fo.dmake2on.gridupdatetagvalue(int2,k.unitdirson[int1]);
   fo.dmake3on.gridupdatetagvalue(int2,k.unitdirson[int1]);
   fo.dmake4on.gridupdatetagvalue(int2,k.unitdirson[int1]);
   fo.duniton.gridupdatetagvalue(int2,k.unitdirson[int1]);
   fo.dincludeon.gridupdatetagvalue(int2,k.unitdirson[int1]);
   fo.dlibon.gridupdatetagvalue(int2,k.unitdirson[int1]);
   fo.dobjon.gridupdatetagvalue(int2,k.unitdirson[int1]);
   dec(int2);
  end;
  fo.activemacroselect[s.macrogroup]:= true;
  fo.activegroupchanged;
  setlength(m.fgroupcomments,6);
  fo.groupcomment.gridvalues:= m.groupcomments;

  for int1:= 0 to fo.macrogrid.rowhigh do begin
   if int1 > high(m.macroon) then begin
    break;
   end;
   fo.e0.gridupdatetagvalue(int1,m.macroon[int1]);
   fo.e1.gridupdatetagvalue(int1,m.macroon[int1]);
   fo.e2.gridupdatetagvalue(int1,m.macroon[int1]);
   fo.e3.gridupdatetagvalue(int1,m.macroon[int1]);
   fo.e4.gridupdatetagvalue(int1,m.macroon[int1]);
   fo.e5.gridupdatetagvalue(int1,m.macroon[int1]);
  end;

  fo.sourcedirs.gridvalues:= reversearray(d.t.sourcedirs);
  fo.syntaxdeffile.gridvalues:= e.t.syntaxdeffiles;
  fo.syntaxdeffilemask.gridvalues:= e.t.sourcefilemasks;
//  fo.grid[0].datalist.asarray:= e.t.syntaxdeffiles;
//  fo.grid[1].datalist.asarray:= e.t.sourcefilemasks;
  fo.filefiltergrid[0].datalist.asarray:= e.t.filemasknames;
  fo.filefiltergrid[1].datalist.asarray:= e.t.filemasks;
  fo.settingsdataent(nil);
  
 end;
end;

procedure storemacros(fo: tprojectoptionsfo);
var
 int1: integer;
begin
 with projectoptions,m do begin
  macronames:= fo.macronames.gridvalues;
  macrovalues:= fo.macrovalues.gridvalues;
  setlength(fmacroon,fo.macrogrid.rowcount);
  for int1:= 0 to high(macroon) do begin
   macroon[int1]:= fo.e0.gridvaluetag(int1,0) or fo.e1.gridvaluetag(int1,0) or
                    fo.e2.gridvaluetag(int1,0) or fo.e3.gridvaluetag(int1,0) or
                    fo.e4.gridvaluetag(int1,0) or fo.e5.gridvaluetag(int1,0);
  end;
  groupcomments:= fo.groupcomment.gridvalues;
 end;
end;

procedure formtoprojectoptions(fo: tprojectoptionsfo);
var
 int1: integer;
begin
{$ifdef mse_with_ifi}
 mainfo.statoptions.valuestoobj(fo);
{$endif}
 fo.optafter.tag:= optaftermainfilemask;
 with projectoptions do begin
  setlength(sigsettings,fo.signalgrid.rowcount);
  for int1:= 0 to high(sigsettings) do begin
   with sigsettings[int1] do begin
    num:= fo.signum[int1];
    numto:= fo.signumto[int1];
    updatebit({$ifdef FPC}longword{$else}byte{$endif}(flags),ord(sfl_stop),
                                fo.sigstop[int1]);
    updatebit({$ifdef FPC}longword{$else}byte{$endif}(flags),ord(sfl_handle),
                                fo.sighandle[int1]);
   end;
  end;
  
  for int1:= high(a.fontxscales) downto 0 do begin
   if a.fontxscales[int1] = emptyreal then begin
    a.fontxscales[int1]:= 1.0;
   end;   
  end;

  defaultmake:= 1 shl fo.defaultmake.value;
  setlength(k.fmakeoptionson,fo.makeoptionsgrid.rowcount);
  for int1:= 0 to high(k.fmakeoptionson) do begin
   k.fmakeoptionson[int1]:=
      fo.makeon.gridvaluetag(int1,0) or fo.buildon.gridvaluetag(int1,0) or
      fo.make1on.gridvaluetag(int1,0) or fo.make2on.gridvaluetag(int1,0) or
      fo.make3on.gridvaluetag(int1,0) or fo.make4on.gridvaluetag(int1,0) or
      fo.optafter.gridvaluetag(int1,0);
  end;

  setlength(k.fbefcommandon,fo.befcommandgrid.rowcount);
  for int1:= 0 to high(k.fbefcommandon) do begin
   k.fbefcommandon[int1]:=
      fo.befmakeon.gridvaluetag(int1,0) or fo.befbuildon.gridvaluetag(int1,0) or
      fo.befmake1on.gridvaluetag(int1,0) or fo.befmake2on.gridvaluetag(int1,0) or
      fo.befmake3on.gridvaluetag(int1,0) or fo.befmake4on.gridvaluetag(int1,0);
  end;
  setlength(k.faftcommandon,fo.aftcommandgrid.rowcount);
  for int1:= 0 to high(k.faftcommandon) do begin
   k.faftcommandon[int1]:=
      fo.aftmakeon.gridvaluetag(int1,0) or fo.aftbuildon.gridvaluetag(int1,0) or
      fo.aftmake1on.gridvaluetag(int1,0) or fo.aftmake2on.gridvaluetag(int1,0) or
      fo.aftmake3on.gridvaluetag(int1,0) or fo.aftmake4on.gridvaluetag(int1,0);
  end;

  k.t.unitdirs:= reversearray(fo.unitdirs.gridvalues);
  setlength(k.funitdirson,length(k.t.unitdirs));
  for int1:= 0 to high(k.funitdirson) do begin
   k.funitdirson[high(k.funitdirson)-int1]:=
      fo.dmakeon.gridvaluetag(int1,0) or fo.dbuildon.gridvaluetag(int1,0) or
      fo.dmake1on.gridvaluetag(int1,0) or fo.dmake2on.gridvaluetag(int1,0) or
      fo.dmake3on.gridvaluetag(int1,0) or fo.dmake4on.gridvaluetag(int1,0) or
      fo.duniton.gridvaluetag(int1,0) or fo.dincludeon.gridvaluetag(int1,0) or
      fo.dlibon.gridvaluetag(int1,0) or fo.dobjon.gridvaluetag(int1,0);
  end;
  storemacros(fo);
  d.t.sourcedirs:= reversearray(fo.sourcedirs.gridvalues);
  e.t.syntaxdeffiles:= fo.syntaxdeffile.gridvalues;
  e.t.sourcefilemasks:= fo.syntaxdeffilemask.gridvalues;
//  e.t.syntaxdeffiles:= fo.grid[0].datalist.asarray;
//  e.t.sourcefilemasks:= fo.grid[1].datalist.asarray;
  e.t.filemasknames:= fo.filefiltergrid[0].datalist.asarray;
  e.t.filemasks:= fo.filefiltergrid[1].datalist.asarray;
 end;
 expandprojectmacros;
end;

procedure projectoptionschanged;
var
 int1: integer;
begin
 projecttree.updatelist;
 createcpufo;
 mainfo.gdb.fpcworkaround:= projectoptions.d.fpcgdbworkaround;
 sourceupdater.unitchanged;
 for int1:= 0 to designer.modules.count - 1 do begin
  tformdesignerfo(designer.modules[int1]^.designform).updateprojectoptions();
 end;
 messagefo.updateprojectoptions;
end;

function readprojectoptions(const filename: filenamety): boolean;
var
 statreader: tstatreader;
begin
 result:= false;
 try
  statreader:= tstatreader.create(filename,ce_utf8);
  try
   application.beginwait;
   updateprojectoptions(statreader,filename);
  finally
   statreader.free;
   application.endwait;
   projectoptionschanged;
  end;
  result:= true;
 except
  on e: exception do begin
   showerror(actionsmo.c[ord(ac_cannotreadproject)]+' "'+filename+'".'+
                   lineend+msestring(e.message),actionsmo.c[ord(ac_error)]);
  end;
 end;
end;

procedure saveprojectoptions(filename: filenamety = '');
var
 statwriter: tstatwriter;
begin
 if filename = '' then begin
  filename:= projectoptions.projectfilename;
 end;
 statwriter:= tstatwriter.create(filename,ce_utf8,true);
 try
  updateprojectoptions(statwriter,filename);
 finally
  statwriter.free;
 end;
end;

function editprojectoptions: boolean;
var
 fo: tprojectoptionsfo;
begin
 fo:= tprojectoptionsfo.create(nil);
 projectoptionstoform(fo);
 try
  projectoptionsfo:= fo;
  result:= fo.show(true,nil) = mr_ok;
  projectoptionsfo:= nil;
  if result then begin
   with mainfo.gdb do begin
    if not started then begin
     closegdb;
    end;
   end;
   fo.window.nofocus; //remove empty grid lines
   formtoprojectoptions(fo);
   projectoptionsmodified;
   projectoptionschanged;
  end;
 finally
  projectoptionsfo:= nil;
  fo.Free;
 end;
end;

procedure tprojectoptionsfo.activegroupchanged;
var
 int1,int2: integer;
begin
 int2:= 0;
 for int1:= 0 to selectactivegroupgrid.rowcount-1 do begin
  if activemacroselect[int1] then begin
   int2:= int1;
   break;
  end;
 end;
 for int1:= 0 to 5 do begin
  if int1 = int2 then begin
   macrogrid.datacols[int1].color:= cl_infobackground;
  end
  else begin
   macrogrid.datacols[int1].color:= cl_default;
  end;
 end;
 projectoptions.s.macrogroup:= int2;
end;

procedure tprojectoptionsfo.acttiveselectondataentered(const sender: TObject);
var
 int1: integer;
begin
 for int1:= 0 to selectactivegroupgrid.rowcount-1 do begin
  activemacroselect[int1]:= false;
 end;
 tbooleaneditradio(sender).value:= true;
 activegroupchanged;
 projectoptions.s.macrogroup:= selectactivegroupgrid.row;
end;

procedure tprojectoptionsfo.colonshowhint(const sender: tdatacol; 
                const arow: Integer; var info: hintinfoty);
begin
 storemacros(self);
 if sender is twidgetcol then begin
  info.caption:= tcustomstringedit(twidgetcol(sender).editwidget).gridvalue[arow];
 end
 else begin
  info.caption:= tstringcol(sender)[arow];
 end;
 expandprmacros1(info.caption);
 include(info.flags,hfl_show); //show empty caption
end;

procedure tprojectoptionsfo.hintexpandedmacros(const sender: TObject;
                           var info: hintinfoty);
begin
 storemacros(self);
 hintmacros(tcustomedit(sender),info);
end;

procedure tprojectoptionsfo.selectactiveonrowsmoved(const sender: tcustomgrid;
       const fromindex: Integer; const toindex: Integer; const acount: Integer);
var
 ar1: array of longboolarty;
 int1: integer;
begin
 setlength(ar1,selectactivegroupgrid.rowcount);
 with macrogrid do begin
  beginupdate;
  for int1:= 0 to high(ar1) do begin
   ar1[int1]:= tbooleanedit(datacols[int1].editwidget).gridvalues;
  end;
  moveitem(pointerarty(ar1),fromindex,toindex);
  for int1:= 0 to high(ar1) do begin
   tbooleanedit(datacols[int1].editwidget).gridvalues:= ar1[int1];
  end;
  endupdate;
 end;
 activegroupchanged;
end;

procedure tprojectoptionsfo.expandfilename(const sender: TObject;
                     var avalue: mseString; var accept: Boolean);
begin
 expandprmacros1(avalue);
end;

procedure tprojectoptionsfo.showcommandlineonexecute(const sender: TObject);
var
 info1: projectoptionsty;
begin
 info1:= projectoptions;
 formtoprojectoptions(self);
 commandlineform.showcommandline;
 projectoptions:= info1;
end;

procedure tprojectoptionsfo.signameonsetvalue(const sender: TObject; var avalue: LongInt; var accept: Boolean);
begin
 signum.value:= avalue;
 signumto.value:= avalue;
end;

procedure tprojectoptionsfo.signumonsetvalue(const sender: TObject; var avalue: LongInt; var accept: Boolean);
begin
 signame.value:= avalue;
 signumto.value:= avalue;
end;

procedure tprojectoptionsfo.signumtoonsetvalue(const sender: TObject; var avalue: Integer; var accept: Boolean);
begin
 if avalue <= signum.value then begin
  signum.value:= avalue;
  signame.value:= avalue;
 end
 else begin
  signame.value:= -1;
 end;
end;

procedure tprojectoptionsfo.fontondataentered(const sender: TObject);
const
 teststring = 'ABCDEFGabcdefgy0123WWWiii ';
var
 format1: formatinfoarty;
begin
 with fontdisp.font do begin
  name:= ansistring(editfontname.value);
  height:= editfontheight.value;
  width:= editfontwidth.value;
  extraspace:= editfontextraspace.value;
  color:= editfontcolor.value;
  dispgrid.frame.colorclient:= editbkcolor.value;
  if editfontantialiased.value then begin
   options:= options + [foo_antialiased2];
  end
  else begin
   options:= options + [foo_nonantialiased];
  end;
  dispgrid.datarowheight:= lineheight;
  fontdisp[0]:= teststring+teststring+teststring+teststring;
  format1:= nil;
  updatefontstyle1(format1,length(teststring),length(teststring),fs_bold,true);
  updatefontstyle1(format1,2*length(teststring),2*length(teststring),fs_italic,true);
  updatefontstyle1(format1,3*length(teststring),length(teststring),fs_bold,true);
  fontdisp.richformats[0]:= format1;
  fontdisp[1]:= 
    'Ascent: '+inttostrmse(ascent)+' Descent: '+inttostrmse(descent)+
    ' Linespacing: '+inttostrmse(lineheight);
 end;
 dispgrid.rowcolorstate[1]:= 0;
 dispgrid.rowcolors[0]:= statementcolor.value;
end;

procedure tprojectoptionsfo.makepageonchildscaled(const sender: TObject);
var
 int1: integer;
begin
 placeyorder(0,[0,0,0,15],[mainfile,makecommand,colorerror,
                    defaultmake,makegroupbox],0);
 aligny(wam_center,[mainfile,targetfile,targpref]);
 aligny(wam_center,[makecommand,makedir,messageoutputfile]);
 int1:= aligny(wam_center,[colorerror,colorwarning,colornote,stripmessageesc]);
 with copymessages do begin
  bounds_y:= int1 - bounds_cy - 2;
 end;
 with stripmessageesc do begin
  pos:= makepoint(copymessages.bounds_x,int1);
 end;
 
 placexorder(defaultmake.bounds_x,[10-defaultmake.frame.outerframe.right,10],
             [defaultmake,showcommandline,checkmethods]);
 int1:= aligny(wam_center,[defaultmake,showcommandline]);
 with checkmethods do begin
  bounds_y:= int1 - bounds_cy - 2;
 end;
 with closemessages do begin
  pos:= makepoint(checkmethods.bounds_x,int1);
 end;
end;

procedure tprojectoptionsfo.debuggerlayoutexe(const sender: TObject);
begin
//{$ifdef mswindows}
 placeyorder(2,[0,0,10],[runcommand,debugcommand,debugtarget,tlayouter1]);
//{$else}
// placeyorder(0,[0,0,2],[debugcommand,debugoptions,debugtarget,tlayouter1]);
//{$endif}
 aligny(wam_center,[debugcommand,debugoptions]);
 aligny(wam_center,[debugtarget,xtermcommand]);
end;

procedure tprojectoptionsfo.macronchildscaled(const sender: TObject);
var
 int1: integer;
begin
 int1:= macrosplitter.bounds_y;
 placeyorder(0,[0],[selectactivegroupgrid,macrosplitter,macrogrid],0);
 macrosplitter.move(makepoint(0,int1-macrosplitter.bounds_y));
end;


procedure tprojectoptionsfo.formtemplateonchildscaled(const sender: TObject);
begin
{
 placeyorder(0,[0],[mainfosource,mainfoform,simplefosource,simplefoform,
       dockingfosource,dockingfoform,datamodsource,datamodform,
       subfosource,subfoform,reportsource,reportform,
       inheritedsource,inheritedform]);
}
end;

procedure tprojectoptionsfo.encodingsetvalue(const sender: TObject;
               var avalue: LongInt; var accept: Boolean);
var
 mstr1: msestring;
begin
 mstr1:= encoding.dropdown.valuelist[avalue];
 accept:= askyesno(c[ord(wrongencoding)]+lineend+
             c[ord(wishsetencoding)]+' '+mstr1+'?',c[ord(warning)]);
end;

procedure tprojectoptionsfo.createexe(const sender: TObject);
var
 int1: integer;
begin
 {$ifdef mswindows}
// externalconsole.visible:= true;
 {$else}
 settty.visible:= true;
// xtermoptions.visible:= true;
 {$endif}
 for int1:= ord(firstsiginfocomment) to ord(lastsiginfocomment) do begin
  siginfos[int1-ord(firstsiginfocomment)].comment:= ansistring(c[int1]);
 end;
end;

procedure tprojectoptionsfo.drawcol(const sender: tpointeredit;
               const acanvas: tcanvas; const avalue: Pointer;
               const arow: Integer);
begin
 with pcellinfoty(acanvas.drawinfopo)^ do begin
  acanvas.fillrect(innerrect,usercolors[arow]);
 end;
end;

procedure tprojectoptionsfo.colsetvalue(const sender: TObject;
               var avalue: colorty; var accept: Boolean);
begin
 colgrid.invalidaterow(colgrid.row);
end;

procedure tprojectoptionsfo.copycolorcode(const sender: TObject);
var
 str1: msestring;
 int1: integer;
begin
 str1:= '';
 for int1:= 0 to colgrid.rowhigh do begin
  if usercolors[int1] <> 0 then begin
   str1:= str1 + ' setcolormapvalue('+
             msestring(colortostring(cl_user+longword(int1)))+','+
               msestring(colortostring(usercolors[int1]))+');';
   if usercolorcomment[int1] <> '' then begin
    str1:= str1 + ' //'+usercolorcomment[int1];
   end;
   str1:= str1+lineend;
  end;
 end;
 copytoclipboard(str1);
end;

procedure tprojectoptionsfo.downloadchange(const sender: TObject);
begin
 uploadcommand.enabled:= not gdbdownload.value and not gdbsimulator.value;
 beforeload.enabled:= gdbdownload.value and not gdbsimulator.value;
 afterload.enabled:= gdbdownload.value and not gdbsimulator.value;
 gdbservercommand.enabled:= not gdbsimulator.value;
 gdbservercommandattach.enabled:= not gdbsimulator.value;
 gdbserverwait.enabled:= not gdbsimulator.value;
 nogdbserverexit.enabled:= gdbserverwait.enabled;
 gdbservertty.enabled:= not gdbsimulator.value;
 remoteconnection.enabled:= not gdbsimulator.value;
 gdbdownload.enabled:= not gdbsimulator.value;
 downloadalways.enabled:= not gdbsimulator.value;
 startupbkpt.enabled:= startupbkpton.value;
end;

procedure tprojectoptionsfo.processorchange(const sender: TObject);
begin
 mainfo.gdb.processorname:= ansistring(gdbprocessor.value);
 if not (mainfo.gdb.processor in simulatorprocessors) then begin
  gdbsimulator.value:= false;
  gdbsimulator.enabled:= false;
 end
 else begin
  gdbsimulator.enabled:= true;
 end;
end;

procedure tprojectoptionsfo.copymessagechanged(const sender: TObject);
begin
 messageoutputfile.enabled:= copymessages.value;
end;

procedure tprojectoptionsfo.updatedebugenabled(const sender: TObject);
var
 bo1: boolean;
begin
 bo1:= runcommand.value = '';
 debugcommand.enabled:= bo1;
 debugoptions.enabled:= bo1;
 debugtarget.enabled:= bo1;
{$ifndef mswindows}
 xtermcommand.enabled:= bo1 and externalconsole.value;
{$endif}
 activateonbreak.enabled:= bo1;
 raiseonbreak.enabled:= bo1;
 nodebugbeginend.enabled:= bo1;
 stoponexception.enabled:= bo1;
 stoponexception.enabled:= bo1;
 showconsole.enabled:= not externalconsole.value;
 settty.enabled:= bo1;
end;

procedure tprojectoptionsfo.newprojectchildscaled(const sender: TObject);
begin
 placeyorder(4,[4,4],[scriptbeforecopy,scriptaftercopy,copygrid],0);
end;

type
 valuebufferty = record
  settingsfile: filenamety;
  settingseditor: boolean;
  settingsdebugger: boolean;
  settingsmake: boolean;
  settingsmacros: boolean;
  settingsfontalias: boolean;
  settingsusercolors: boolean;
  settingsformatmacros: boolean;
  settingstemplates: boolean;
  settingstools: boolean;
  settingsstorage: boolean;
  settingscomponentstore: boolean;
  settingsprojecttree: boolean;
  settingslayout: boolean;
//  settingsautoload: boolean;
//  settingsautosave: boolean;
  projectfilename: filenamety;
  projectdir: filenamety;
 end;

procedure savesettingsvalues(fo: tprojectoptionsfo; out buffer: valuebufferty);
begin
 with buffer do begin
  projectfilename:= projectoptions.projectfilename;
  projectdir:= projectoptions.projectdir;
  if fo <> nil then begin
   settingsfile:= fo.settingsfile.value;
   settingseditor:= fo.settingseditor.value;
   settingsdebugger:= fo.settingsdebugger.value;
   settingsmake:= fo.settingsmake.value;
   settingsmacros:= fo.settingsmacros.value;
   settingsfontalias:= fo.settingsfontalias.value;
   settingsusercolors:= fo.settingsusercolors.value;
   settingsformatmacros:= fo.settingsformatmacros.value;
   settingstemplates:= fo.settingstemplates.value;
   settingstools:= fo.settingstools.value;
   settingsstorage:= fo.settingsstorage.value;
   settingscomponentstore:= fo.settingscomponentstore.value;
   settingsprojecttree:= fo.settingsprojecttree.value;
   settingslayout:= fo.settingslayout.value;
//   settingsautoload:= fo.settingsautoload.value; 
//   settingsautosave:= fo.settingsautosave.value; 
  end
  else begin
   settingsfile:= projectoptions.r.settingsfile;
   settingseditor:= projectoptions.r.settingseditor;
   settingsdebugger:= projectoptions.r.settingsdebugger;
   settingsmake:= projectoptions.r.settingsmake;
   settingsmacros:= projectoptions.r.settingsmacros;
   settingsfontalias:= projectoptions.r.settingsfontalias;
   settingsusercolors:= projectoptions.r.settingsusercolors;
   settingsformatmacros:= projectoptions.r.settingsformatmacros;
   settingstemplates:= projectoptions.r.settingstemplates;
   settingstools:= projectoptions.r.settingstools;
   settingsstorage:= projectoptions.r.settingsstorage;
   settingscomponentstore:= projectoptions.r.settingscomponentstore;
   settingsprojecttree:= projectoptions.r.settingsprojecttree;
   settingslayout:= projectoptions.r.settingslayout;
//   settingsautoload:= projectoptions.r.settingsautoload; 
//   settingsautosave:= projectoptions.r.settingsautosave; 
  end;
 end;
end;

procedure restoresettingsvalues(fo: tprojectoptionsfo;
                                               const buffer: valuebufferty);
begin
 with buffer do begin
  projectoptions.projectfilename:= projectfilename;
  projectoptions.projectdir:= projectdir;
  if fo <> nil then begin
   if not settingsstorage then begin
    fo.settingsfile.value:= settingsfile;
    fo.settingseditor.value:= settingseditor; 
    fo.settingsdebugger.value:= settingsdebugger; 
    fo.settingsmake.value:= settingsmake; 
    fo.settingsmacros.value:= settingsmacros; 
    fo.settingsfontalias.value:= settingsfontalias; 
    fo.settingsusercolors.value:= settingsusercolors; 
    fo.settingsformatmacros.value:= settingsformatmacros; 
    fo.settingstemplates.value:= settingstemplates; 
    fo.settingstools.value:= settingstools; 
    fo.settingsstorage.value:= settingsstorage; 
    fo.settingscomponentstore.value:= settingscomponentstore; 
    fo.settingsprojecttree.value:= settingsprojecttree; 
    fo.settingslayout.value:= settingslayout; 
//    fo.settingsautoload.value:= settingsautoload; 
//    fo.settingsautosave.value:= settingsautosave; 
   end;
   fo.fontondataentered(nil);
   fo.settingsdataent(nil);
  end
  else begin
   if not settingsstorage then begin
    projectoptions.r.settingsfile:= settingsfile;
    projectoptions.r.settingseditor:= settingseditor; 
    projectoptions.r.settingsdebugger:= settingsdebugger; 
    projectoptions.r.settingsmake:= settingsmake; 
    projectoptions.r.settingsmacros:= settingsmacros; 
    projectoptions.r.settingsfontalias:= settingsfontalias; 
    projectoptions.r.settingsusercolors:= settingsusercolors; 
    projectoptions.r.settingsformatmacros:= settingsformatmacros; 
    projectoptions.r.settingstemplates:= settingstemplates; 
    projectoptions.r.settingstools:= settingstools; 
    projectoptions.r.settingsstorage:= settingsstorage; 
    projectoptions.r.settingscomponentstore:= settingscomponentstore; 
    projectoptions.r.settingsprojecttree:= settingsprojecttree; 
    projectoptions.r.settingslayout:= settingslayout;
//    projectoptions.r.settingsautoload:= settingsautoload; 
//    projectoptions.r.settingsautosave:= settingsautosave; 
   end;
  end;
 end;
end;

procedure savestat(out astream: ttextstream);
var
 write1: tstatwriter;
begin
 astream:= ttextstream.create; //memory stream
 write1:= tstatwriter.create(astream,ce_utf8);
 try
  write1.setsection('projectoptions');
  updateprojectsettings(write1,[]); //save projectoptions state
 finally
  write1.free;
 end;
end;

procedure restorestat(var astream: ttextstream);
var
 read1: tstatreader;
begin
 astream.position:= 0;
 read1:= tstatreader.create(astream,ce_utf8);
 try
  read1.setsection('projectoptions');
  updateprojectsettings(read1,[]); //restore projectoptions state
 finally
  read1.free;
  astream.free;
 end;
end;

procedure doloadexe(const sender: tprojectoptionsfo);
var
 read1: tstatreader;
 buffer: valuebufferty;
 stream1: ttextstream;
 fname1: filenamety;
begin
 if (sender <> nil) then begin
  storemacros(sender);
  fname1:= sender.settingsfile.value;
  expandprmacros1(fname1);
  if not askyesno(actionsmo.c[ord(ac_replacesettings)]+lineend+
                                        '"'+fname1+'"?',
                                actionsmo.c[ord(ac_warning)]) then begin
   exit;
  end;
 end
 else begin
  fname1:= projectoptions.r.settingsfile;
  expandprmacros1(fname1);
 end;
 if fname1 <> '' then begin
  savesettingsvalues(sender,buffer);
  savestat(stream1);
  if sender <> nil then begin //manual
   formtoprojectoptions(sender);
  end;
  projectoptions.disabled:= getdisabledoptions;
  try
   read1:= tstatreader.create(fname1,ce_utf8);
   try
    if projectoptions.r.settingscomponentstore then begin
     componentstorefo.updatestat(read1);
    end;
    if projectoptions.r.settingslayout then begin
     mainfo.loadwindowlayout(read1);
    end;
    read1.setsection('projectoptions');
    if projectoptions.r.settingsprojecttree then begin
     projecttree.updatestat(read1);
     projecttree.updatelist;
    end;
    updateprojectsettings(read1,[]);
   finally
    read1.free;
   end;
   if sender <> nil then begin
    projectoptionstoform(sender);
   end;
   restoresettingsvalues(sender,buffer);
  except
   application.handleexception;
  end;
  projectoptions.disabled:= [];
  if sender <> nil then begin //manual
   restorestat(stream1);
  end
  else begin
   stream1.free;
   expandprojectmacros;
  end;
 end;
end;

procedure tprojectoptionsfo.loadexe(const sender: TObject);
begin
 doloadexe(self);
end;

procedure dosaveexe(const sender: tprojectoptionsfo);
var
 stat1: tstatwriter;
 stream1: ttextstream;
 fname1: filenamety;
begin
 if sender <> nil then begin //manual save
  storemacros(sender);
  fname1:= sender.settingsfile.value;
  expandprmacros1(fname1);
  if findfile(fname1) and not askyesno(actionsmo.c[ord(ac_file)]+fname1+
                    actionsmo.c[ord(ac_exists)]+lineend+
    actionsmo.c[ord(ac_wantoverwrite)],actionsmo.c[ord(ac_warning)]) then begin
   exit;
  end;
 end
 else begin
  fname1:= projectoptions.r.settingsfile;
  expandprmacros1(fname1);
 end;
 if fname1 <> '' then begin
  stat1:= tstatwriter.create(fname1,ce_utf8,true);
  with projectoptions do begin
   try
    savestat(stream1);
    if sender <> nil then begin
     formtoprojectoptions(sender);
    end;
    disabled:= getdisabledoptions;
    if r.settingscomponentstore then begin
     componentstorefo.updatestat(stat1);
    end;
    if r.settingslayout then begin
     mainfo.savewindowlayout(stat1);
    end;
    stat1.setsection('projectoptions');
    if r.settingsprojecttree then begin
     projecttree.updatestat(stat1);
    end;
    if not r.settingsstorage then begin
     r.settingsfile:= '';
     r.settingseditor:= false; 
     r.settingsdebugger:= false; 
     r.settingsmake:= false; 
     r.settingsmacros:= false; 
     r.settingsfontalias:= false; 
     r.settingsusercolors:= false; 
     r.settingsformatmacros:= false; 
     r.settingstemplates:= false; 
     r.settingstools:= false; 
     r.settingsstorage:= false; 
     r.settingscomponentstore:= false; 
     r.settingsprojecttree:= false; 
     r.settingslayout:= false; 
//     r.settingsautoload:= false; 
//     r.settingsautosave:= false; 
    end;
    updateprojectsettings(stat1,disabled);
   finally
    disabled:= [];
    stat1.free;
    restorestat(stream1);
   end;
  end;
 end;
end;

procedure tprojectoptionsfo.saveexe(const sender: TObject);
begin
 dosaveexe(self);
end;

procedure tprojectoptionsfo.settingsdataent(const sender: TObject);
var
 bo1: boolean;
begin
 bo1:= settingsfile.value <> '';
 savebu.enabled:= bo1;
 loadbu.enabled:= bo1;
end;
(*
procedure tprojectoptionsfo.extconschangeexe(const sender: TObject);
begin
{$ifndef mswindows}
 xtermcommand.enabled:= externalconsole.value;
{$endif}
end;
*)
procedure tprojectoptionsfo.setxtermcommandexe(const sender: TObject;
               var avalue: msestring; var accept: Boolean);
begin
 if avalue = '' then begin
  avalue:= defaultxtermcommand;
 end;
end;

procedure tprojectoptionsfo.activateonbreakset(const sender: TObject;
               var avalue: Boolean; var accept: Boolean);
begin
 raiseonbreak.enabled:= avalue;
end;

procedure tprojectoptionsfo.sourcedirhint(const sender: TObject;
               var info: hintinfoty);
begin
 if tcustomedit(sender).text = '' then begin
  hintexpandedmacros(makedir,info);
 end
 else begin
  hintexpandedmacros(sender,info);
 end;
end;

procedure tprojectoptionsfo.toolshortcutdropdown(const sender: TObject);
var
 i1: int32;
 act1: taction;
begin
 with toolshortcuts.dropdown do begin
  for i1:= 0 to valuelist.count-1 do begin
   if actionsmo.gettoolshortcutaction(i1,act1) then begin
    with act1 do begin
     cols[1][i1]:= encodeshortcutname(shortcuts);
     cols[2][i1]:= encodeshortcutname(shortcuts1);
    end;
   end;
  end;
 end;
end;

procedure tprojectoptionsfo.toolsrowdatachanged(const sender: tcustomgrid;
               const acell: gridcoordty);
var
 act1: taction;
begin
 if actionsmo.gettoolshortcutaction(toolshortcuts[acell.row],act1) then begin
  with act1 do begin
   toolsc[acell.row]:= encodeshortcutname(shortcuts);
   toolscalt[acell.row]:= encodeshortcutname(shortcuts1);
  end;
 end;
end;

procedure tprojectoptionsfo.colorhint(const sender: TObject;
               var info: hintinfoty);
begin
 info.caption:= tcustomedit(sender).text + lineend + info.caption;
end;

procedure tprojectoptionsfo.initeolstyleexe(const sender: tenumtypeedit);
begin
 sender.typeinfopo:= typeinfo(eolstylety);
end;

procedure tprojectoptionsfo.debugtargetlayoutev(const sender: TObject);
begin
 serverla.width:= serverla.width + uploadcommand.width-gdbservercommand.width;
end;
(*
{ tprojectoptions }

constructor tprojectoptions.create;
begin
 ft:= ttextprojectoptions.create;
 ftexp:= ttextprojectoptions.create;
 inherited;
end;

function tprojectoptions.gett: tobject;
begin
 result:= ft;
end;

function tprojectoptions.gettexp: tobject;
begin
 result:= ftexp;
end;
*)
{ teditoptions }

constructor teditoptions.create;
var
 ar1: msestringarty;
begin
 ft:= ttexteditoptions.create;
 ftexp:= ttexteditoptions.create;

 showgrid:= true;
 snaptogrid:= true;
 moveonfirstclick:= true;
 componenthints:= true;
 gridsizex:= defaultgridsizex;
 gridsizey:= defaultgridsizey;
 encoding:= 1; //utf8n
 eolstyle:= 1; //eol_system
 autoindent:= true;
 blockindent:= 1;
 rightmarginon:= true;
 rightmarginchars:= 80;
 tabstops:= 4;
 editfontname:= 'mseide_source';
 editfontcolor:= integer(cl_text);
 editbkcolor:= integer(cl_foreground);
 statementcolor:= $E0FFFF;
// pairmarkcolor:= int32(cl_ltyellow);
 pairmarkcolor:= int32(cl_none);
 pairmaxrowcount:= 100;
 editfontantialiased:= true;
 editmarkbrackets:= true;
// editmarkpairwords:= true;
 backupfilecount:= 2;
 setlength(ar1,1);
 ar1[0]:= '${TEMPLATEDIR}';
 ft.codetemplatedirs:= ar1;
 inherited;
end;

function teditoptions.limitgridsize(const avalue: integer): integer;
begin
 result:= avalue;
 if result < 1 then begin
  result:= 1;
 end;
 if result > 1000 then begin
  result:= 1000;
 end;
end;

procedure teditoptions.setgridsizex(const avalue: integer);
begin
 fgridsizex:= limitgridsize(avalue);
end;

procedure teditoptions.setgridsizey(const avalue: integer);
begin
 fgridsizey:= limitgridsize(avalue);
end;
{
function teditoptions.getcodetemplatedirs: msestringarty;
begin
 result:= projectoptions.k.t.codetemplatedirs;
end;

procedure teditoptions.setcodetemplatedirs(const avalue: msestringarty);
begin
 projectoptions.k.t.codetemplatedirs:= avalue;
end;
}
function teditoptions.gett: tobject;
begin
 result:= ft;
end;

function teditoptions.gettexp: tobject;
begin
 result:= ftexp;
end;

{ tdebugoptions }

constructor tdebugoptions.create;
begin
 ft:= ttextdebugoptions.create;
 ftexp:= ttextdebugoptions.create;

 valuehints:= true;
 activateonbreak:= true;
 raiseonbreak:= true;
 settty:= true;
 additem(fexceptclassnames,'EconvertError');
 additem(fexceptignore,false);
 fgdbloadtimeout:= emptyreal;
 fpcgdbworkaround:= true;
 inherited;
end;

function tdebugoptions.gett: tobject;
begin
 result:= ft;
end;

function tdebugoptions.gettexp: tobject;
begin
 result:= ftexp;
end;

{ ttextdebugoptions }

constructor ttextdebugoptions.create;
begin
 fxtermcommand:= defaultxtermcommand;
end;

{ tmakeoptions }

constructor tmakeoptions.create;
begin
 ft:= ttextmakeoptions.create;
 ftexp:= ttextmakeoptions.create;
 inherited;
end;

function tmakeoptions.gett: tobject;
begin
 result:= ft;
end;

function tmakeoptions.gettexp: tobject;
begin
 result:= ftexp;
end;

{ ttoolsoptions }

constructor ttoolsoptions.create;
begin
 ft:= ttexttoolsoptions.create();
 ftexp:= ttexttoolsoptions.create();
 inherited;
end;

function ttoolsoptions.gett: tobject;
begin
 result:= ft;
end;

function ttoolsoptions.gettexp: tobject;
begin
 result:= ftexp;
end;

{ ttemplatesoptions }

constructor ttemplatesoptions.create;
begin
 ft:= ttexttemplatesoptions.create();
 ftexp:= ttexttemplatesoptions.create();
 inherited;
end;

function ttemplatesoptions.gett: tobject;
begin
 result:= ft;
end;

function ttemplatesoptions.gettexp: tobject;
begin
 result:= ftexp;
end;

{ tprojectstate }

constructor tprojectstate.create();
begin
 ft:= ttextprojectstate.create();
 ftexp:= ttextprojectstate.create();
 closemessages:= true;
 checkmethods:= true;
 fcolorerror:= cl_ltyellow;
 fcolorwarning:= cl_ltred;
 fcolornote:= cl_ltgreen;
 inherited;
end;

procedure tprojectstate.setforcezorder(const avalue: longbool);
begin
 fforcezorder:= avalue;
 application.forcezorder:= avalue;
end;

function tprojectstate.gett: tobject;
begin
 result:= ft;
end;

function tprojectstate.gettexp: tobject;
begin
 result:= ftexp;
end;

{ tfontaliasoptions }

constructor tfontaliasoptions.create();
begin
 ft:= ttextfontaliasoptions.create();
 ftexp:= ttextfontaliasoptions.create();
 inherited;
end;

function tfontaliasoptions.gett: tobject;
begin
 result:= ft;
end;

function tfontaliasoptions.gettexp: tobject;
begin
 result:= ftexp;
end;

{ tusercoloroptions }

constructor tusercoloroptions.create();
begin
 ft:= ttextusercoloroptions.create();
 ftexp:= ttextusercoloroptions.create();
 inherited;
end;

function tusercoloroptions.gett: tobject;
begin
 result:= ft;
end;

function tusercoloroptions.gettexp: tobject;
begin
 result:= ftexp;
end;

{ tformatmacrooptions }

constructor tformatmacrooptions.create();
begin
 ft:= ttextformatmacrooptions.create();
 ftexp:= ttextformatmacrooptions.create();
 inherited;
end;

function tformatmacrooptions.gett: tobject;
begin
 result:= ft;
end;

function tformatmacrooptions.gettexp: tobject;
begin
 result:= ftexp;
end;

{ ttextfontaliasoptions }

{ tstorageoptions }

constructor tstorageoptions.create();
begin
 fsettingsmake:= true;
 inherited;
end;

{ ttexttemplatesoptions }

initialization
 codetemplates:= tcodetemplates.create;
finalization
 freeoptions();
{
 projectoptions.o.free();
 projectoptions.e.free();
 projectoptions.d.free();
 projectoptions.m.free();
 projectoptions.a.free();
 projectoptions.u.free();
 projectoptions.f.free();
 projectoptions.p.free();
 projectoptions.t.free();
 projectoptions.r.free();
 projectoptions.s.free();
}
 freeandnil(codetemplates);
end.
