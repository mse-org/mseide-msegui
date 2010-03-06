unit mseprinter;
{$ifdef FPC}{$mode objfpc}{$h+}{$GOTO ON}{$endif}

interface
uses
 mseclasses,msegraphics,msegraphutils,msestrings,msestream,msedrawtext,
 mserichstring,classes,msetypes,msestat,msestatfile,msedataedits,msedropdownlist,
 mseevent,mseglob,mseguiglob,msemenus,mseedit,msegui,sysutils;
 
const
 defaultppmm = 10;
 defaultpagewidth = 210;  //A4 mm
 defaultpageheight = 297; //A4 mm
 defaultframe = 10; //mm
 defaultfontheight = 3.527; //*ppmm -> 10 point 
 
// gcscale = 4096;
 printunit = 25.4/72;    //point
 mmtoprintscale = 1/printunit;
 nulllinewidth = 0.2*mmtoprintscale;
 
type
 stdpagesizety = (sps_user,
 sps_a0,sps_a1,sps_a2,sps_a3,sps_a4,sps_a5,sps_a6,sps_a7,sps_a8,sps_a9,
 sps_b0,sps_b1,sps_b2,sps_b3,sps_b4,sps_b5,sps_b6,sps_b7,sps_b8,sps_b9,sps_b10,
 sps_c5e,sps_comm10e,sps_dle,sps_executive,sps_folio,sps_ledger,sps_legal,
 sps_letter,sps_tabloid);

 stdpagety = record
  name: string;
  width,height: real //mm
 end;
 
const
 stdpagesizes: array[stdpagesizety] of stdpagety = (
  (name: 'User';      width:     0; height:    0),
  (name: 'A0';        width:   841; height: 1189),
  (name: 'A1';        width:   594; height:  841),
  (name: 'A2';        width:   420; height:  594),
  (name: 'A3';        width:   297; height:  420),
  (name: 'A4';        width:   210; height:  297),
  (name: 'A5';        width:   148; height:  210),
  (name: 'A6';        width:   105; height:  148),
  (name: 'A7';        width:    74; height:  105),
  (name: 'A8';        width:    52; height:   74),
  (name: 'A9';        width:    37; height:   52),
  (name: 'B0';        width:  1030; height: 1456),
  (name: 'B1';        width:   728; height: 1030),
  (name: 'B2';        width:   515; height:  728),
  (name: 'B3';        width:   364; height:  515),
  (name: 'B4';        width:   257; height:  364),
  (name: 'B5';        width:   182; height:  257),
  (name: 'B6';        width:   128; height:  182),
  (name: 'B7';        width:    91; height:  128),
  (name: 'B8';        width:    64; height:   91),
  (name: 'B9';        width:    45; height:   64),
  (name: 'B10';       width:    32; height:   45),
  (name: 'C5E';       width:   163; height:  229),
  (name: 'Comm10E';   width:   105; height:  241),
  (name: 'DLE';       width:   110; height:  220),
  (name: 'Executive'; width:   191; height:  254),
  (name: 'Folio';     width:   210; height:  330),
  (name: 'Ledger';    width:   432; height:  279),
  (name: 'Legal';     width:   216; height:  356),
  (name: 'Letter';    width:   216; height:  279),
  (name: 'Tabloid';   width:   279; height:  432)
  );

type
 printeroptionty = (pro_inactivewindow,//win32: start exe with inactive window
                    pro_tempfile);     //use temp file for prolog building
 printeroptionsty = set of printeroptionty;
const
 defaultprinteroptions = [pro_inactivewindow];
type
 tcustomprinter = class;
 tcustomprintercanvas = class;
 tprintercanvas = class;
 printereventty = procedure(const sender: tcustomprinter) of object;

 tprintertabulators = class(tcustomtabulators)
  published
   property defaultdist;
 end;
 colorspacety = (cos_gray,cos_rgb);
 pageorientationty = (pao_portrait,pao_landscape);

 exceptioneventty = procedure(const sender: tobject; var e: exception;
                                             var again: boolean) of object; 

 tcustomprinter = class(tmsecomponent,istatfile)
  private
   fonpagestart: printereventty;
   fonpageend: printereventty;
   fpa_size: stdpagesizety;
   fpa_width: real;
   fpa_height: real;
   fpa_frameleft: real;
   fpa_frametop: real;
   fpa_frameright: real;
   fpa_framebottom: real;
   ftabulators: tprintertabulators;
//   fppmm: real;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fpa_orientation: pageorientationty;
   foptions: printeroptionsty;
   fonerror: exceptioneventty;
   procedure settabulators(const avalue: tprintertabulators);
//   procedure setppmm(const avalue: real);
   procedure setpa_frameleft(const avalue: real);
   procedure setpa_frametop(const avalue: real);
   procedure setpa_frameright(const avalue: real);
   procedure setpa_framebottom(const avalue: real);
   procedure writepa_frameleft(writer: twriter);
   procedure writepa_frametop(writer: twriter);
   procedure writepa_frameright(writer: twriter);
   procedure writepa_framebottom(writer: twriter);
   procedure readpa_frameleft(reader: treader);
   procedure readpa_frametop(reader: treader);
   procedure readpa_frameright(reader: treader);
   procedure readpa_framebottom(reader: treader);
//   function getcolorspace: colorspacety;
//   procedure setcolorspace(const avalue: colorspacety);
   procedure setstatfile(const avalue: tstatfile);
   procedure setpa_size(const avalue: stdpagesizety);
   procedure setpa_width(const avalue: real);
   procedure setpa_height(const avalue: real);
   procedure pagesizechanged;
   procedure setpa_orientation(const avalue: pageorientationty);
   procedure setcanvas(const avalue: tprintercanvas);
  protected
   fcanvas: tprintercanvas;
   fcanceled: boolean;
   function handleexception(const e: exception; out again: boolean): boolean;
                  //true if raise wanted
   procedure loaded; override;
   function getwindowsize: sizety; virtual;
   procedure defineproperties(filer: tfiler); override;
   
   //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;

   property onerror: exceptioneventty read fonerror write fonerror;
                        //call abort for quiet cancel

   //icanvas   
   function getsize: sizety;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   
   procedure endprint; virtual;
   property canvas: tprintercanvas read fcanvas write setcanvas;
   property onpagestart: printereventty read fonpagestart write fonpagestart;
   property onpageend: printereventty read fonpageend write fonpageend;
   property pa_width: real read fpa_width write setpa_width; 
   property pa_height: real read fpa_height write setpa_height;
   property pa_size: stdpagesizety read fpa_size write setpa_size nodefault;
   property pa_orientation: pageorientationty read fpa_orientation 
                              write setpa_orientation default pao_portrait;
  
   property pa_frameleft: real read fpa_frameleft write setpa_frameleft stored false;
                                     //mm, default 10
   property pa_frametop: real read fpa_frametop write setpa_frametop stored false;
                                     //mm, default 10
   property pa_frameright: real read fpa_frameright write setpa_frameright stored false;
                                     //mm, default 10
   property pa_framebottom: real read fpa_framebottom write setpa_framebottom 
                                      stored false; //mm, default 10
   property tabulators: tprintertabulators read ftabulators write settabulators;
//   property ppmm: real read fppmm write setppmm; //pixel per mm, default 10
//   property colorspace: colorspacety read getcolorspace write setcolorspace;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read fstatvarname write fstatvarname;
   property options: printeroptionsty read foptions write foptions 
                                             default defaultprinteroptions;
 end;

 tprinter = class(tcustomprinter)
  published
   property canvas;
   property onpagestart;
   property onpageend;
   property pa_width; 
   property pa_height;
   property pa_size;
   property pa_orientation;
  
   property pa_frameleft; //mm, default 10
   property pa_frametop;    //mm, default 10
   property pa_frameright;  //mm, default 10
   property pa_framebottom; //mm, default 10
   property tabulators;
//   property ppmm: real read fppmm write setppmm; //pixel per mm, default 10
//   property colorspace: colorspacety read getcolorspace write setcolorspace;
   property statfile;
   property statvarname;
 end;

 tstreamprinter = class;
 updateprinteransistringeventty = procedure(const sender: tstreamprinter;
                                   var avalue: ansistring) of object;
 tstreamprinter = class(tprinter)
  private
   fprintcommand: string;
   fonupdateprintcommand: updateprinteransistringeventty;
   procedure setstream(const avalue: ttextstream);
  protected
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
   procedure doupdateprintcommand(const adata: pointer);
  public
   constructor create(aowner: tcomponent); override;
   procedure beginprint(command: string = ''; const apreamble: string = ''); overload;
   procedure beginprint(const astream: ttextstream; const apreamble: string = ''); overload;
    //printer owns the stream, nil -> dummy mode
   procedure endprint; override;
  published
   property printcommand: string read fprintcommand write fprintcommand;
   property options;
   property onerror;  //call abort for quiet cancel
   property onupdateprintcommand: updateprinteransistringeventty 
                      read fonupdateprintcommand write fonupdateprintcommand;
                      //runs in main thread
 end;

 tprinterfont = class(tcanvasfont)
 end;
 
 pageskindty = (pk_all,pk_even,pk_odd);
 
 pagerangety = record
  first,last: integer;
 end;
 pagerangearty = array of pagerangety;

 printercanvasstatety = (pcs_matrixvalid,pcs_dryrun);
 printercanvasstatesty = set of printercanvasstatety;
 
 tcustomprintercanvas = class(tcanvas)
  private
   fheaderheight: integer;
   ffooterheight: integer;
   fpagenumber: integer;
   findentx: integer;
   findenty: integer;
   fprintorientation: pageorientationty;
   fpagechanging: integer;
   fpages: pagerangearty;
   fpagesstring: msestring;
   fpageskind: pageskindty;
   procedure setcolorspace(const avalue: colorspacety);
   function getliney: integer;
   procedure setprintorientation(const avalue: pageorientationty);
   procedure setliney(const avalue: integer);
   procedure setpages(const avalue: pagerangearty);
  protected
   fpstate: printercanvasstatesty;
   fgcoffsetx: real;
   fgcoffsety: real;
   fgcscale: real;
   foriginx,foriginy: real;
   fscale: real;
   foffset: pointty;
   fclientsize: sizety;
   fpapersize: sizety;
   fboundingbox: framety;
   ftitle: msestring;
   flinenumber: integer;
   fpagelinenumber: integer;
   fliney: integer;
   fprinter: tcustomprinter;
   fcolorspace: colorspacety;
   fpreamble: string;
   function createfont: tcanvasfont; override;
   procedure initprinting(const apreamble: string = '');
   procedure checkgcstate(state: canvasstatesty); override;
   procedure setppmm(avalue: real); override;
   function defaultcliprect: rectty; override;
   procedure updatescale; virtual;
   procedure updateframe;
   procedure beginpage; virtual;
   procedure endpage; virtual;
   procedure dotextout(const text: richstringty; const dest: rectty;
                        const flags: textflagsty;
                        const tabdist: real; afontcolorshadow: colorty);
   procedure textout(const text: richstringty; const dest: rectty;
                        const flags: textflagsty;
                        const tabdist: real); virtual; abstract;
                              //tabdist < 0 -> lastx                 
   procedure begintextclip(const arect: rectty); virtual; abstract;
   procedure endtextclip; virtual; abstract;
   procedure checknextpage;
   procedure internalwriteln(const avalue: richstringty);
   procedure setpagesstring(const avalue: msestring);
   procedure internaldrawtext(var info); override;
                       //info = drawtextinfoty
  public
   constructor create(const user: tcustomprinter; const intf: icanvas);
   procedure initflags(const dest: tcanvas); override;
      
   // if cy of destrect = 0 and tf_ycentered in textflags -> place on baseline
   procedure drawtext(var info: drawtextinfoty); overload; virtual;
   procedure drawtext(const atext: richstringty;
                   const adest: rectty; aflags: textflagsty = [];
                   afont: tfont = nil; atabulators: ttabulators = nil); overload;
   procedure drawtext(const atext: richstringty;
                   const adest,aclip: rectty; aflags: textflagsty = [];
                   afont: tfont = nil; atabulators: ttabulators = nil); overload;
   procedure drawtext(const atext: msestring;
                   const adest: rectty; aflags: textflagsty = [];
                   afont: tfont = nil; atabulators: ttabulators = nil); overload;
   procedure writeln(const avalue: msestring = ''); overload;
   procedure writeln(const avalue: richstringty); overload;
   procedure writelines(const alines: array of msestring); overload;
   procedure writelines(const alines: msestringarty); overload;
   procedure writelines(const alines: richstringarty); overload;
   
   property indentx: integer read findentx write findentx;
                 //pixels
   property indenty: integer read findenty write findenty;
                 //pixels
   property headerheight: integer read fheaderheight write fheaderheight;
                 //pixels
   property footerheight: integer read ffooterheight write ffooterheight;
                 //pixels
   property linenumber: integer read flinenumber;
   property pagelinenumber: integer read fpagelinenumber;
   function remaininglines: integer;
   function liney1: integer; //no checknextpage call
   property liney: integer read getliney write setliney;
   function lineheight: integer; //pixels

   procedure nextpage;
   function active: boolean; 
     //checks pages
      
   property title: msestring read ftitle write ftitle;
                            //used as print job lable
   property clientsize: sizety read fclientsize;
   property colorspace: colorspacety read fcolorspace 
                         write setcolorspace default cos_gray;
   property pagenumber: integer read fpagenumber;
   property pageskind: pageskindty read fpageskind write fpageskind; 
                   //null based
   property pages: pagerangearty read fpages write setpages;
                  //all if nil, null based
   property pagesstring: msestring read fpagesstring write setpagesstring;
                  //one based, example: '1-5,7,9,11-13', all if ''
   
   property printorientation: pageorientationty read fprintorientation 
                write setprintorientation default pao_portrait;   
 end;

 tprintercanvas = class(tcustomprintercanvas)
  published
   property font;
   property printorientation;
   property colorspace;
   property title;
   property ppmm; //default 10
 end;

 tstreamprintercanvas = class(tprintercanvas)
  protected
   fdeststream: ttextstream;
   fpreamblestream: ttextstream;
   fbodystream: ttextstream;
   procedure streamwrite(const atext: string; const apreamble: boolean = false); 
                      //checks fstream = nil
   procedure streamwriteln(const atext: string; const apreamble: boolean = false);
                     //checks fstream = nil
  public
   procedure reset; override;
 end;
  
 tprintervalueselector = class(tcustomselector)
  private
   fprinter: tcustomprinter;
   procedure setprinter(const avalue: tcustomprinter);
   procedure printerchanged; virtual; abstract;
  protected
   procedure objectevent(const sender: tobject; 
                              const event: objecteventty); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property dropdown;
   property printer: tcustomprinter read fprinter write setprinter;
 end;
 
 tpagesizeselector = class(tprintervalueselector)
  private
   function getvalue: stdpagesizety;
   procedure setvalue(const avalue: stdpagesizety);
   procedure printerchanged; override;
  protected
   procedure getdropdowninfo(var aenums: integerarty;
         const names: tdropdowncols); override;
   procedure dochange; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property value: stdpagesizety read getvalue write setvalue default sps_a4;
 end;

 tpageorientationselector = class(tprintervalueselector)
  private
   function getvalue: pageorientationty;
   procedure setvalue(const avalue: pageorientationty);
   procedure printerchanged; override;
  protected
   procedure getdropdowninfo(var aenums: integerarty;
         const names: tdropdowncols); override;
   procedure dochange; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property value: pageorientationty read getvalue 
                   write setvalue default pao_portrait;
 end;
 
function stringtopages(const avalue: msestring): pagerangearty;
                  //one based, example: '1-5,7,9,11-13'

implementation
uses
 mseprocutils,msepipestream,msesysintf,msestockobjects,mseconsts;
 
type
 tfont1 = class(tfont);
 tcanvas1 = class(tcanvas);
 
function stringtopages(const avalue: msestring): pagerangearty;
var
 ar1,ar2: msestringarty;
 int1,int2: integer;
 ar3: pagerangearty;
begin
 ar1:= nil; //compiler warning
 ar2:= nil; //compiler warning
 if avalue = '' then begin
  result:= nil;
 end
 else begin
  try
   ar1:= splitstring(avalue,widechar(','));
   setlength(ar3,length(avalue)); //max
   int2:= 0;
   for int1:= high(ar1) downto 0 do begin
    ar2:= splitstring(ar1[int1],widechar('-'));
    if high(ar2) = 1 then begin
     ar3[int2].first:= strtoint(ar2[0]);
     ar3[int2].last:= strtoint(ar2[1]);
    end
    else begin
     if high(ar2) = 0 then begin
      ar3[int2].first:= strtoint(ar2[0]);
      ar3[int2].last:= ar3[int2].first;
     end
     else begin
      raise exception.create('');
     end;
    end;
    with ar3[int2] do begin
     if (first <= 0) or (last <= 0) or (last < first) then begin
      raise exception.create('');
     end;
     dec(first);
     dec(last);
    end;
    inc(int2);
   end;
  except
   raise exception.create('Invalid pages: '''+avalue+'''.'+lineend+
                          'Example: ''1-5,7,9,11-13''');
  end;
  setlength(ar3,int2);
  result:= ar3;
 end;
end;

{ tprintertabulators }

{ tcustomprinter }

constructor tcustomprinter.create(aowner: tcomponent);
begin
// fppmm:= defaultppmm;
 foptions:= defaultprinteroptions;
 fpa_size:= sps_a4;
 with stdpagesizes[fpa_size] do begin
  fpa_width:= width;
  fpa_height:= height;
 end;
 fpa_frameleft:= defaultframe;
 fpa_frametop:= defaultframe;
 fpa_frameright:= defaultframe;
 fpa_framebottom:= defaultframe;
 ftabulators:= tprintertabulators.create;
 inherited;
 fcanvas.ppmm:= defaultppmm;
end;

destructor tcustomprinter.destroy;
begin
 endprint;
 fcanvas.free;
 ftabulators.free;
 inherited;
end;

procedure tcustomprinter.loaded;
begin
 inherited;
 pagesizechanged;
 fcanvas.updatescale;
end;

function tcustomprinter.handleexception(const e: exception;
                                          out again: boolean): boolean;
var
 e1: exception;
begin
 result:= true;
 again:= false;
 if canevent(tmethod(fonerror)) then begin
  e1:= e;
  fcanceled:= true;
  application.lock;
  try
   fonerror(self,e1,again);
  finally
   application.unlock;
  end;
  result:= not again and (e1 = e);
  if not result and not again and (e1 <> nil) then begin
   raise e1;
  end;
  fcanceled:= result;
 end;
end;

function tcustomprinter.getwindowsize: sizety;
var
 rea1: real;
begin
 if pa_width > pa_height then begin //quadratic for landscape/portrait switching
  rea1:= pa_width;
 end
 else begin
  rea1:= pa_height;
 end;
 result.cx:= round(rea1*fcanvas.ppmm);
 result.cy:= result.cx;
end;

procedure tcustomprinter.settabulators(const avalue: tprintertabulators);
begin
 ftabulators.assign(avalue);
end;

procedure tcustomprinter.pagesizechanged;
begin
 if fpa_size <> sps_user then begin
  with stdpagesizes[fpa_size] do begin
   if fpa_orientation = pao_portrait then begin
    fpa_width:= width;
    fpa_height:= height;
   end
   else begin
    fpa_width:= height;
    fpa_height:= width;
   end;
  end;
 end;
 if not (csloading in componentstate) then begin
  sendchangeevent;
  fcanvas.updateframe;
 end;
end;

procedure tcustomprinter.setpa_width(const avalue: real);
begin
 fpa_width:= avalue;
 fpa_size:= sps_user;
 pagesizechanged;
end;

procedure tcustomprinter.setpa_height(const avalue: real);
begin
 fpa_height:= avalue;
 fpa_size:= sps_user;
 pagesizechanged;
end;

procedure tcustomprinter.setpa_size(const avalue: stdpagesizety);
begin
 fpa_size:= avalue;
 pagesizechanged;
end;

procedure tcustomprinter.setpa_orientation(const avalue: pageorientationty);
begin
 fpa_orientation:= avalue;
 pagesizechanged;
end;
{
procedure tcustomprinter.setppmm(const avalue: real);
begin
 fppmm:= avalue;
 ftabulators.ppmm:= avalue;
 fcanvas.updatescale;
end;
}
procedure tcustomprinter.setpa_frameleft(const avalue: real);
begin
 fpa_frameleft:= avalue;
 fcanvas.updateframe;
end;

procedure tcustomprinter.setpa_frametop(const avalue: real);
begin
 fpa_frametop:= avalue;
 fcanvas.updateframe;
end;

procedure tcustomprinter.setpa_frameright(const avalue: real);
begin
 fpa_frameright:= avalue;
 fcanvas.updateframe;
end;

procedure tcustomprinter.setpa_framebottom(const avalue: real);
begin
 fpa_framebottom:= avalue;
 fcanvas.updateframe;
end;
{
function tcustomprinter.getcolorspace: colorspacety;
begin
 result:= fcanvas.colorspace;
end;

procedure tcustomprinter.setcolorspace(const avalue: colorspacety);
begin
 fcanvas.colorspace:= avalue;
end;
}
procedure tcustomprinter.dostatread(const reader: tstatreader);
begin
 with reader do begin
  pa_width:= readreal('width',fpa_width);
  pa_height:= readreal('height',fpa_height);
  pa_size:= stdpagesizety(readinteger('size',ord(fpa_size),0,
                   ord(high(stdpagesizety))));
  pa_orientation:= pageorientationty(readinteger('orientation',
             ord(fpa_orientation),0,ord(high(pageorientationty))));
  fpa_frameleft:= readreal('frameleft',fpa_frameleft);
  fpa_frametop:= readreal('frametop',fpa_frametop);
  fpa_frameright:= readreal('frameright',fpa_frameright);
  fpa_framebottom:= readreal('framebottom',fpa_framebottom);
  fcanvas.colorspace:= colorspacety(readinteger('colorspace',
                           ord(fcanvas.colorspace),0,ord(high(colorspacety))));
 end;
end;

procedure tcustomprinter.dostatwrite(const writer: tstatwriter);
begin
 with writer do begin
  writereal('width',fpa_width);
  writereal('height',fpa_height);
  writeinteger('size',ord(fpa_size));
  writeinteger('orientation',ord(fpa_orientation));
  writereal('frameleft',fpa_frameleft);
  writereal('frametop',fpa_frametop);
  writereal('frameright',fpa_frameright);
  writereal('framebottom',fpa_framebottom);
  writeinteger('colorspace',ord(fcanvas.colorspace));
 end;
end;

procedure tcustomprinter.statreading;
begin
 //dummy
end;

procedure tcustomprinter.statread;
begin
 //dummy
end;

function tcustomprinter.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tcustomprinter.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

procedure tcustomprinter.setcanvas(const avalue: tprintercanvas);
begin
 fcanvas.assign(avalue);
end;

function tcustomprinter.getsize: sizety;
begin
 result:= fcanvas.fdrawinfo.gc.paintdevicesize;
end;

procedure tcustomprinter.endprint;
begin
 //dummy
end;

procedure tcustomprinter.writepa_frameleft(writer: twriter);
begin
 writer.writefloat(fpa_frameleft);
end;

procedure tcustomprinter.writepa_frametop(writer: twriter);
begin
 writer.writefloat(fpa_frametop);
end;

procedure tcustomprinter.writepa_frameright(writer: twriter);
begin
 writer.writefloat(fpa_frameright);
end;

procedure tcustomprinter.writepa_framebottom(writer: twriter);
begin
 writer.writefloat(fpa_framebottom);
end;

procedure tcustomprinter.readpa_frameleft(reader: treader);
begin
 fpa_frameleft:= reader.readfloat;
end;

procedure tcustomprinter.readpa_frametop(reader: treader);
begin
 fpa_frametop:= reader.readfloat;
end;

procedure tcustomprinter.readpa_frameright(reader: treader);
begin
 fpa_frameright:= reader.readfloat;
end;

procedure tcustomprinter.readpa_framebottom(reader: treader);
begin
 fpa_framebottom:= reader.readfloat;
end;

procedure tcustomprinter.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('pa_frameleft',{$ifdef FPC}@{$endif}readpa_frameleft,
       {$ifdef FPC}@{$endif}writepa_frameleft,
       (filer.ancestor = nil) and (fpa_frameleft <> defaultframe) or 
       (filer.ancestor <> nil) and 
                    (tcustomprinter(filer.ancestor).fpa_frameleft <> fpa_frameleft));
 filer.defineproperty('pa_frametop',{$ifdef FPC}@{$endif}readpa_frametop,
       {$ifdef FPC}@{$endif}writepa_frametop,
       (filer.ancestor = nil) and (fpa_frametop <> defaultframe) or 
       (filer.ancestor <> nil) and 
       (tcustomprinter(filer.ancestor).fpa_frametop <> fpa_frametop));
 filer.defineproperty('pa_frameright',{$ifdef FPC}@{$endif}readpa_frameright,
       {$ifdef FPC}@{$endif}writepa_frameright,
       (filer.ancestor = nil) and (fpa_frameright <> defaultframe) or 
       (filer.ancestor <> nil) and 
       (tcustomprinter(filer.ancestor).fpa_frameright <> fpa_frameright));
 filer.defineproperty('pa_framebottom',{$ifdef FPC}@{$endif}readpa_framebottom,
       {$ifdef FPC}@{$endif}writepa_framebottom,
       (filer.ancestor = nil) and (fpa_framebottom <> defaultframe) or 
       (filer.ancestor <> nil) and 
       (tcustomprinter(filer.ancestor).fpa_framebottom <> fpa_framebottom));
end;

{ tcustomprintercanvas }

constructor tcustomprintercanvas.create(const user: tcustomprinter; 
                                                       const intf: icanvas);
begin
 fprinter:= user;
 inherited create(user,intf);
 fstate:= fstate+[cs_highresdevice,cs_internaldrawtext];
end;

procedure tcustomprintercanvas.initflags(const dest: tcanvas);
begin
 inherited;
 include(tcanvas1(dest).fdrawinfo.gc.drawingflags,df_highresfont);
end;

function tcustomprintercanvas.createfont: tcanvasfont;
begin
 result:= tprinterfont.create(self);
end;

procedure tcustomprintercanvas.initprinting(const apreamble: string = '');
begin
 fpreamble:= apreamble;
 fpagenumber:= 0;
 fpagelinenumber:= 0;
 fliney:= 0;
 reset;
end;

function tcustomprintercanvas.defaultcliprect: rectty;
begin
 result.pos:= nullpoint;
 result.size:= fdrawinfo.gc.paintdevicesize;
 with result do begin
  if cx > cy then begin 
      //quadratic because of cliprectinit with later orientation switch
   cy:= cx;
  end
  else begin
   cx:= cy;             
  end;
 end;  
end;

procedure tcustomprintercanvas.updatescale;
begin
 if not (csloading in fprinter.componentstate) then begin
  exclude(fstate,cs_origin);
  exclude(fpstate,pcs_matrixvalid);
  with fprinter do begin
//   self.ppmm:= fppmm;
   fgcscale:= mmtoprintscale/ppmm; //map to printerunits

   if fprintorientation = pao_landscape then begin
    fdrawinfo.gc.paintdevicesize.cx:= round(fpa_height * ppmm);
    fdrawinfo.gc.paintdevicesize.cy:= round(fpa_width * ppmm);
    fgcoffsetx:= mmtoprintscale * fpa_frameleft;
    fgcoffsety:= - fpa_frametop*mmtoprintscale;
   end
   else begin
    fdrawinfo.gc.paintdevicesize.cx:= round(fpa_width * ppmm);
    fdrawinfo.gc.paintdevicesize.cy:= round(fpa_height * ppmm);
    fgcoffsetx:= mmtoprintscale * fpa_frameleft;
    fgcoffsety:= (fpa_height-fpa_frametop)*mmtoprintscale;
   end;
   
   if fprintorientation = pao_landscape then begin
    fpapersize.cx:= round((fdrawinfo.gc.paintdevicesize.cy/ppmm)*mmtoprintscale);
    fpapersize.cy:= round((fdrawinfo.gc.paintdevicesize.cx/ppmm)*mmtoprintscale);
    fboundingbox.left:= round(fpa_frametop*mmtoprintscale);
    fboundingbox.bottom:= round(fpa_frameleft*mmtoprintscale);
    fboundingbox.right:= round((fdrawinfo.gc.paintdevicesize.cy/ppmm-fpa_framebottom)*
                                                               mmtoprintscale);
    fboundingbox.top:= round((fdrawinfo.gc.paintdevicesize.cx/ppmm-fpa_frameright)*
                                                               mmtoprintscale);
   end
   else begin
    fpapersize.cx:= round((fdrawinfo.gc.paintdevicesize.cx/ppmm)*mmtoprintscale);
    fpapersize.cy:= round((fdrawinfo.gc.paintdevicesize.cy/ppmm)*mmtoprintscale);
    fboundingbox.left:= round(fpa_frameleft*mmtoprintscale);
    fboundingbox.bottom:= round(fpa_framebottom*mmtoprintscale);
    fboundingbox.right:= round((fdrawinfo.gc.paintdevicesize.cx/ppmm-fpa_frameright)*
                                                               mmtoprintscale);
    fboundingbox.top:= round((fdrawinfo.gc.paintdevicesize.cy/ppmm-fpa_frametop)*
                                                               mmtoprintscale);
   end;
   fclientsize.cx:= fdrawinfo.gc.paintdevicesize.cx - round((fpa_frameleft+fpa_frameright)*
                                                               ppmm);
   fclientsize.cy:= fdrawinfo.gc.paintdevicesize.cy - round((fpa_frametop+fpa_framebottom)*
                                                               ppmm);
  end;
 end;
end;

procedure tcustomprintercanvas.checkgcstate(state: canvasstatesty);
begin
 if not (cs_origin in fstate) then begin
//  with fprinter do begin
   foriginx:= fgcoffsetx + mmtoprintscale * (origin.x/ppmm);
   foriginy:= fgcoffsety - mmtoprintscale * (origin.y/ppmm);
//  end;
 end;
 inherited;
end;

procedure tcustomprintercanvas.updateframe;
begin
 updatescale;
end;

procedure tcustomprintercanvas.beginpage;
begin
 fpagelinenumber:= 0;
 fliney:= 0;
 with fprinter do begin
  if canevent(tmethod(fonpagestart)) then begin
   fonpagestart(fprinter);
  end;
 end;
end;

procedure tcustomprintercanvas.endpage;
begin
 checkgcstate([cs_gc]); //could be an empty page
 with fprinter do begin
  if canevent(tmethod(fonpageend)) then begin
   fonpageend(fprinter);
  end;
 end;
end;

//todo: full support of shadow_*/gloss_*

procedure tcustomprintercanvas.dotextout(const text: richstringty;
               const dest: rectty; const flags: textflagsty;
               const tabdist: real; afontcolorshadow: colorty);
var
 col1: colorty;
begin
 if tf_grayed in flags then begin
  afontcolorshadow:= cl_white;
 end;
 col1:= fdrawinfo.acolorforeground;
 if afontcolorshadow <> cl_none then begin
  fdrawinfo.acolorforeground:= afontcolorshadow;
  checkgcstate([cs_acolorforeground]);
  textout(text,moverect(dest,makepoint(1,1)),flags,tabdist);
  if tf_grayed in flags then begin
   fdrawinfo.acolorforeground:= cl_dkgray;
  end
  else begin
   fdrawinfo.acolorforeground:= col1;
  end;
  checkgcstate([cs_acolorforeground]);
 end;
 textout(text,dest,flags,tabdist);
 if tf_grayed in flags then begin
  fdrawinfo.acolorforeground:= col1;
  checkgcstate([cs_acolorforeground]);
 end;
end;

procedure tcustomprintercanvas.drawtext(var info: drawtextinfoty);
// colorbackground gap filling not supported.
var
 acolorshadow: colorty;
 tab1: tcustomtabulators;
 ar1: richstringarty;
 int1,int2,int3,int4,int5,int6: integer;
 rea1: real;
 flags1,flags2: textflagsty;
 rstr1: richstringty;
 layoutinfo: layoutinfoty;
 rect1,rect2: rectty;
 backup: msestring;
 lihi: integer;
label
 endlab;
begin
 if cs_inactive in fstate then exit;
 save;
 layouttext(self,info,layoutinfo);
 if pcs_dryrun in fpstate then begin
  goto endlab;
 end;
 ar1:= nil; //compiler warning
 with fdrawinfo do begin
  afonthandle1:= tfont1(font).gethandle;
  with {fvaluepo^.}font do begin
   acolorforeground:= color;
   acolorbackground:= colorbackground;
   acolorshadow:= shadow_color;
  end;
  checkgcstate([cs_font,cs_acolorforeground,cs_acolorbackground]);
 end;
 with info do begin
  if tf_clipi in flags then begin
   begintextclip(dest);
  end
  else begin
   if tf_clipo in flags then begin
    begintextclip(clip);
   end;
  end;
  backup:= text.text;
  try
   with layoutinfo do begin
    if tf_softhyphen in flags then begin
     for int1:= 0 to high(lineinfos) do begin
      with lineinfos[int1] do begin
       for int2:= 0 to high(tabchars) do begin
        if text.text[tabchars[int2]] = c_softhyphen then begin
         text.text[tabchars[int2]]:= #0; //will be removed in printing routine
        end;
       end;
      end;
     end;
    end;
    text.text:= replacechar(text.text,c_softhyphen,'-');
    if high(lineinfos) > 0 then begin
     rect1:= dest;
     flags1:= flags;
     flags2:= flags1 - [tf_xcentered,tf_right,tf_xjustify];
     lihi:= font.lineheight;
     int1:= 0;
//     int2:= lihi;
     if reversed then begin
      lihi:= - lihi;
      int1:= lihi;
//      int2:= 0;
     end;
     if xyswapped then begin
      rect1.cx:= font.lineheight;
      if tf_ycentered in flags then begin
       rect1.x:= dest.x + (dest.cx - length(lineinfos) * lihi) div 2 + int1;
      end
      else begin
       if tf_bottom in flags then begin
        if reversed then begin
         rect1.x:= dest.x - high(lineinfos) * lihi;
        end
        else begin
         rect1.x:= dest.x + dest.cx - length(lineinfos) * lihi;
        end;
       end;
      end;
     end
     else begin
      rect1.cy:= font.lineheight;
      if tf_ycentered in flags then begin
       rect1.y:= dest.y + (dest.cy - length(lineinfos) * lihi) div 2 + int1;
      end
      else begin
       if tf_bottom in flags then begin
        if reversed then begin
         rect1.y:= dest.y - high(lineinfos) * lihi;
        end
        else begin
         rect1.y:= dest.y + dest.cy - length(lineinfos) * lihi;
        end;
       end;
      end;
     end;
     for int1:= 0 to high(lineinfos) do begin
      with lineinfos[int1] do begin
       if (tf_xjustify in flags) and (high(justifychars) >= 0) and 
                   (int1 < high(lineinfos)) then begin
        rstr1:= richcopy(text,liindex,justifychars[0]-liindex);
        dotextout(rstr1,rect1,flags2,0,acolorshadow); //first word
        rea1:= (dest.cx - liwidth + getstringwidth(' ') * length(justifychars)) /
                         length(justifychars); //gap width
        rect2:= rect1;        //x justify text
        if xyswapped then begin
         rect2.cy:= 0;                                    
         int3:= dest.y;
        end
        else begin
         rect2.cx:= 0;                                    
         int3:= dest.x;
        end;
        for int2:= liindex - 1 to justifychars[0] - 2 do begin
         inc(int3,charwidths[int2]);            //end of first word
        end;
        for int2:= 0 to high(justifychars) - 1 do begin
         int5:= 0;
         for int4:= justifychars[int2] to justifychars[int2+1] - 2 do begin
          inc(int5,charwidths[int4]); //width of actual word
         end;
         int6:= round(int3 + (int2 + 1) * rea1 + int5 div 2);
         if xyswapped then begin
          rect2.y:= int6;
         end
         else begin
          rect2.x:= int6;
         end;
         int3:= int3 + int5;
         rstr1:= richcopy(text,justifychars[int2]+1,justifychars[int2+1] - 
                                                         justifychars[int2] - 1);
         dotextout(rstr1,rect2,flags2 + [tf_xcentered],0,acolorshadow);
        end;
        rstr1:= richcopy(text,justifychars[high(justifychars)]+1,
                           liindex+licount-justifychars[high(justifychars)]-1);
        dotextout(rstr1,rect1,flags2+[tf_right],0,acolorshadow); //last word
       end
       else begin
        rstr1:= richcopy(text,liindex,licount);
        dotextout(rstr1,rect1,flags1,0,acolorshadow);
       end;
       if xyswapped then begin
        inc(rect1.x,lihi);
       end
       else begin
        inc(rect1.y,lihi);
       end;
      end;
     end;
    end
    else begin //single line
     if countchars(text.text,c_tab) = 0 then begin
      dotextout(text,dest,flags,0,acolorshadow);
     end
     else begin
      if tabulators = nil then begin
       tab1:= fprinter.ftabulators;
      end
      else begin
       tab1:= tabulators;
      end;
      if tab1.count = 0 then begin
       if tab1.defaultdist = 0 then begin      //has no tabs
        replacechar(text.text,c_tab,' ');
        dotextout(text,dest,flags,0,acolorshadow);
       end
       else begin
        ar1:= splitrichstring(text,c_tab);
        dotextout(ar1[0],dest,flags,0,acolorshadow);
        rea1:= tab1.defaultdist*mmtoprintscale;
        for int1:= 1 to high(ar1) do begin     
         dotextout(ar1[int1],dest,flags,rea1,acolorshadow);
        end;
       end;
      end
      else begin
       ar1:= splitrichstring(text,c_tab);
       dotextout(ar1[0],dest,flags,0,acolorshadow);
       for int1:= 1 to high(ar1) do begin     
        if int1 > tab1.count then begin
         rstr1.text:= ' ';
         rstr1.format:= nil;
         rstr1:= richconcat(rstr1,ar1[int1]);
         for int2:= int1+1 to high(ar1) do begin
          rstr1:= richconcat(rstr1,' ');
          rstr1:= richconcat(rstr1,ar1[int2]);
         end;
         dotextout(rstr1,dest,flags-[tf_right,tf_xcentered],-1,acolorshadow); 
                        //print rest of string
         break;
        end;
        flags1:= flags - [tf_xcentered,tf_right];
        with tab1[int1-1] do begin
         case kind of
          tak_right,tak_decimal: flags1:= flags1 + [tf_right];
          tak_centered: flags1:= flags1 + [tf_xcentered];
         end;
         if kind = tak_decimal then begin
          int2:= msestrrscan(ar1[int1].text,widechar(decimalseparator));
          if int2 > 0 then begin
           dotextout(richcopy(ar1[int1],1,int2-1),
                   makerect(round(pos*ppmm),dest.y,0,
                     dest.cy),flags1,0,acolorshadow); //int
           dotextout(richcopy(ar1[int1],int2,bigint),makerect(0,dest.y,0,
                     dest.cy),flags1-[tf_right],-1,acolorshadow); //frac
          end
          else begin
           dotextout(ar1[int1],makerect(round(pos*ppmm),dest.y,0,
                     dest.cy),flags1,0,acolorshadow); //no frac
          end;
         end
         else begin
          dotextout(ar1[int1],makerect(round(pos*ppmm),dest.y,0,dest.cy),flags1,
                      0,acolorshadow);
         end;
        end;
       end;
      end;
     end;
    end;
   end;       //with layoutinfo
  finally
   text.text:= backup;
   if flags * [tf_clipi,tf_clipo] <> [] then begin
    endtextclip;
   end;
  end;
 end;
endlab:
 restore;
end;

procedure tcustomprintercanvas.drawtext(const atext: richstringty;
                   const adest: rectty; aflags: textflagsty = [];
                   afont: tfont = nil; atabulators: ttabulators = nil);
var
 info: drawtextinfoty;
begin
 fillchar(info,sizeof(info),0);
 with info do begin
  text:= atext;
  dest:= adest;
  flags:= aflags;
  font:= afont;
  tabulators:= atabulators;
 end;
 drawtext(info);
end;

procedure tcustomprintercanvas.drawtext(const atext: richstringty;
                   const adest,aclip: rectty; aflags: textflagsty = [];
                   afont: tfont = nil; atabulators: ttabulators = nil);
var
 info: drawtextinfoty;
begin
 fillchar(info,sizeof(info),0);
 with info do begin
  text:= atext;
  dest:= adest;
  clip:= aclip;
  flags:= aflags;
  font:= afont;
  tabulators:= atabulators;
 end;
 drawtext(info);
end;

procedure tcustomprintercanvas.drawtext(const atext: msestring;
                   const adest: rectty; aflags: textflagsty = [];
                   afont: tfont = nil; atabulators: ttabulators = nil);
var
 info: drawtextinfoty;
begin
 fillchar(info,sizeof(info),0);
 with info do begin
  text.text:= atext;
  dest:= adest;
  flags:= aflags;
  font:= afont;
  tabulators:= atabulators;
 end;
 drawtext(info);
end;

procedure tcustomprintercanvas.checknextpage;
begin
 if fpagechanging = 0 then begin
  if remaininglines <= 0 then begin
   inc(fpagechanging);
   try
    nextpage;
   finally
    dec(fpagechanging);
   end;
  end;
 end;
end;

procedure tcustomprintercanvas.writeln(const avalue: msestring = '');
var
 rstr1: richstringty;
begin
 rstr1.format:= nil;
 rstr1.text:= avalue;
 writeln(rstr1);
end;

procedure tcustomprintercanvas.internalwriteln(const avalue: richstringty);
begin
 checknextpage;
 if avalue.text <> '' then begin
  drawtext(avalue,makerect(findentx,fliney + fheaderheight + findenty,0,0));
 end;
 inc(fpagelinenumber);
 inc(flinenumber);
 fliney:= fliney + lineheight;
end;

procedure tcustomprintercanvas.writeln(const avalue: richstringty);
var
 ar1: richstringarty;
 int1: integer;
begin
 ar1:= breakrichlines(avalue);
 for int1:= 0 to high(ar1) do begin
  internalwriteln(ar1[int1]);
 end;
end;

procedure tcustomprintercanvas.writelines(const alines: array of msestring);
var
 int1: integer;
 rstr1: richstringty;
begin
 rstr1.format:= nil;
 for int1:= 0 to high(alines) do begin
  rstr1.text:= alines[int1];
  internalwriteln(rstr1);
 end;
end;

procedure tcustomprintercanvas.writelines(const alines: msestringarty);
var
 int1: integer;
 rstr1: richstringty;
begin
 rstr1.format:= nil;
 for int1:= 0 to high(alines) do begin
  rstr1.text:= alines[int1];
  internalwriteln(rstr1);
 end;
end;

procedure tcustomprintercanvas.writelines(const alines: richstringarty);
var
 int1: integer;
begin
 for int1:= 0 to high(alines) do begin
  internalwriteln(alines[int1]);
 end;
end;

function tcustomprintercanvas.lineheight: integer;
begin
 result:= font.height;
 if result = 0 then begin
  result:= round(defaultfontheight*ppmm);
 end;
 result:= result + font.extraspace;
end;

function tcustomprintercanvas.remaininglines: integer;
begin
 checkgcstate([cs_gc]); //init all values
 result:= (fclientsize.cy - fheaderheight - ffooterheight - fliney - findenty -
                            origin.y) div lineheight;
end;

procedure tcustomprintercanvas.nextpage;
begin
 endpage;
 inc(fpagenumber);
 beginpage;
end;

procedure tcustomprintercanvas.setcolorspace(const avalue: colorspacety);
begin
 if fcolorspace <> avalue then begin
  fcolorspace:= avalue;
  exclude(fstate,cs_acolorforeground);
//  valueschanged([cs_color,cs_colorbackground]);
 end;
end;

function tcustomprintercanvas.active: boolean;
var
 int1: integer;
begin
 result:= fpages = nil;
 if not result then begin
  for int1:= high(fpages) downto 0 do begin
   with fpages[int1] do begin
    if (fpagenumber >= first) and (fpagenumber <= last) then begin
     result:= true;
     break;
    end;
   end;
  end;
 end;
 if result then begin
  result:= (fpageskind = pk_all) or ((fpageskind = pk_even) xor odd(fpagenumber));
 end;
end;

function tcustomprintercanvas.liney1: integer;
begin
 result:= fliney + fheaderheight;
end;

function tcustomprintercanvas.getliney: integer;
begin
 checknextpage;
 result:= liney1;
end;

procedure tcustomprintercanvas.setliney(const avalue: integer);
begin
 checknextpage;
 fliney:= avalue - fheaderheight;
end;

procedure tcustomprintercanvas.setprintorientation(
                                             const avalue: pageorientationty);
begin
 if avalue <> fprintorientation then begin
  fprintorientation:= avalue;
  updatescale;
 end;
end;

procedure tcustomprintercanvas.setppmm(avalue: real);
begin
 inherited;
 fprinter.ftabulators.ppmm:= avalue;
 updatescale;
end;

procedure tcustomprintercanvas.setpages(const avalue: pagerangearty);
begin
 fpages:= copy(avalue);
end;

procedure tcustomprintercanvas.setpagesstring(const avalue: msestring);
begin
 pages:= stringtopages(avalue);
 fpagesstring:= avalue;
end;

procedure tcustomprintercanvas.internaldrawtext(var info);
begin
 drawtext(drawtextinfoty(info));
end;

{ tprintervalueselector }

constructor tprintervalueselector.create(aowner: tcomponent);
begin
 inherited;
 dropdown.cols.nostreaming:= true;
end;

procedure tprintervalueselector.setprinter(const avalue: tcustomprinter);
begin
 setlinkedvar(avalue,tmsecomponent(fprinter));
 printerchanged;
end;

procedure tprintervalueselector.objectevent(const sender: tobject; 
               const event: objecteventty);
begin
 inherited;
 if (event = oe_changed) and (sender = fprinter) then begin
  printerchanged;
 end;
end;

{ tpagesizeselector }

constructor tpagesizeselector.create(aowner: tcomponent);
var
 pa1: stdpagesizety;
begin
 inherited;
 for pa1:= low(stdpagesizety) to high(stdpagesizety) do begin
  addrow([stdpagesizes[pa1].name]);
 end;
 inherited value:= integer(sps_a4);
end;

procedure tpagesizeselector.getdropdowninfo(var aenums: integerarty; 
                              const names: tdropdowncols);
var
 pa1: stdpagesizety;
begin
 setlength(aenums,ord(high(stdpagesizety)));
 names.clear;
 for pa1:= stdpagesizety(1) to high(stdpagesizety) do begin
  with stdpagesizes[pa1] do begin
   names.addrow([name+' ('+formatfloat('0',width)+'*'+formatfloat('0',height)+' mm2)']); 
  end;
  aenums[ord(pa1)-1]:= ord(pa1);
 end;
end;

procedure tpagesizeselector.dochange;
begin
 if fprinter <> nil then begin
  fprinter.pa_size:= value;
 end;
 inherited;
end;

function tpagesizeselector.getvalue: stdpagesizety;
begin
 result:= stdpagesizety(inherited value);
end;

procedure tpagesizeselector.setvalue(const avalue: stdpagesizety);
begin
 if value <> avalue then begin
  inherited setvalue(integer(avalue));
 end;
end;

procedure tpagesizeselector.printerchanged;
begin
 if fprinter <> nil then begin
  value:= fprinter.pa_size;
 end;
end;

{ tpageorientationselector }

constructor tpageorientationselector.create(aowner: tcomponent);
begin
 inherited;
 addrow([stockcaptions(sc_portrait)]);
 addrow([stockcaptions(sc_landscape)]);
end;

function tpageorientationselector.getvalue: pageorientationty;
begin
 result:= pageorientationty(inherited value);
end;

procedure tpageorientationselector.setvalue(const avalue: pageorientationty);
begin
 if value <> avalue then begin
  inherited setvalue(integer(avalue));
 end;
end;

procedure tpageorientationselector.printerchanged;
begin
 if fprinter <> nil then begin
  value:= fprinter.pa_orientation;
 end;
end;

procedure tpageorientationselector.getdropdowninfo(var aenums: integerarty; 
    const names: tdropdowncols);
begin
 names.clear;
 names.addrow([stockcaptions(sc_portrait)]);
 names.addrow([stockcaptions(sc_landscape)]);
end;

procedure tpageorientationselector.dochange;
begin
 if fprinter <> nil then begin
  fprinter.pa_orientation:= value;
 end;
 inherited;
end;

{ tstreamprinter }

constructor tstreamprinter.create(aowner: tcomponent);
begin
// fprintcommand:= sys_getprintcommand;
 inherited;
end;

procedure tstreamprinter.doupdateprintcommand(const adata: pointer);
begin
 if canevent(tmethod(fonupdateprintcommand)) then begin
  fonupdateprintcommand(self,pstring(adata)^);
 end;
end;

procedure tstreamprinter.beginprint(command: string = ''; 
                                            const apreamble: string = '');
var
 pip1: tpipewriter;
begin
 if command = '' then begin
  command:= fprintcommand;
 end;
 if command = '' then begin
  command:= sys_getprintcommand;
 end;
 if canevent(tmethod(fonupdateprintcommand)) then begin
  application.synchronize({$ifdef FPC}@{$endif}doupdateprintcommand,@command);
 end;
 pip1:= tpipewriter.create;
 try
  execmse2(command,pip1,nil,nil,false,-1,pro_inactivewindow in foptions);
 except
  pip1.free;
  raise;
 end;
 beginprint(pip1,apreamble);
end;

procedure tstreamprinter.beginprint(const astream: ttextstream;
                                          const apreamble: string = '');
begin
 with tstreamprintercanvas(fcanvas) do begin
  if astream = nil then begin
   include(fpstate,pcs_dryrun);
  end
  else begin
   exclude(fpstate,pcs_dryrun);
  end;
  endprint;
  setstream(astream);
  initprinting(apreamble);
 end;
end;

procedure tstreamprinter.endprint;
begin
 try
  setstream(nil);
 finally
  fcanceled:= false;
 end;
end;

procedure tstreamprinter.setstream(const avalue: ttextstream);
var
 fna1: filenamety;
begin
 with tstreamprintercanvas(fcanvas) do begin
  try
   unlink;
  except
  end;
  try
   if (fdeststream <> fpreamblestream) and (fpreamblestream <> nil) then begin
    fna1:= fpreamblestream.filename;
    fpreamblestream.position:= 0;
    fdeststream.copyfrom(fpreamblestream,0);
    freeandnil(fpreamblestream);
    sys_deletefile(fna1);
   end;
   if (fdeststream <> fbodystream) and (fbodystream <> nil) then begin
    fna1:= fbodystream.filename;
    fbodystream.position:= 0;
    fdeststream.copyfrom(fbodystream,0);
    freeandnil(fbodystream);
    sys_deletefile(fna1);
   end;
   freeandnil(fdeststream);
   fdeststream:= avalue;
   if (pro_tempfile in foptions) and (avalue <> nil) then begin
    fpreamblestream:= ttextstream.createtempfile('msepspreamble',fna1);
    fbodystream:= ttextstream.createtempfile('msepsbody',fna1);
    fpreamblestream.usewritebuffer:= true;
    fbodystream.usewritebuffer:= true;
   end
   else begin   
    if avalue <> nil then begin
     avalue.usewritebuffer:= true;
    end;
    fpreamblestream:= avalue;
    fbodystream:= avalue;
   end;
  except
   if fdeststream <> fpreamblestream then begin
    freeandnil(fpreamblestream);
    freeandnil(fbodystream);
   end;
   freeandnil(fdeststream);
   raise;
  end;
 end;
end;

procedure tstreamprinter.dostatread(const reader: tstatreader);
begin
 inherited;
 with reader do begin
  printcommand:= readstring('printcommand',printcommand);
 end;
end;

procedure tstreamprinter.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 with writer do begin
  writestring('printcommand',printcommand);
 end;
end;

{ tstreamprintercanvas }

procedure tstreamprintercanvas.reset;
begin
 restore(1); //do not change the streamed values
 save;
 clipregion:= 0;
 origin:= nullpoint;
end;

procedure tstreamprintercanvas.streamwrite(const atext: string;
                                  const apreamble: boolean = false);
var
 bo1: boolean;
begin
 if (fdeststream <> nil) and not fprinter.fcanceled then begin
  bo1:= false;
  repeat
   try
    if apreamble then begin
     fpreamblestream.write(atext);
    end
    else begin
     fbodystream.write(atext);
    end;
   except
    on e: exception do begin
     if fprinter.handleexception(e,bo1) then begin
      raise;
     end;
    end;
   end;
  until not bo1;
 end;
end;

procedure tstreamprintercanvas.streamwriteln(const atext: string;
                                            const apreamble: boolean = false);
var
 bo1: boolean;
begin
 if (fdeststream <> nil) and not fprinter.fcanceled then begin
  bo1:= false;
  repeat
   try
    if apreamble then begin
     fpreamblestream.writeln(atext);
    end
    else begin
     fbodystream.writeln(atext);
    end;
   except
    on e: exception do begin
     if fprinter.handleexception(e,bo1) then begin
      raise;
     end;
    end;
   end;
  until not bo1;
 end;
end;

end.
