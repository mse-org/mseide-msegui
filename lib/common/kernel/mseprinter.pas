unit mseprinter;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mseclasses,msegraphics,msegraphutils,msestrings,msestream,msedrawtext,
 mserichstring,classes,msetypes,msestat,msestatfile,msedataedits,msedropdownlist,
 mseevent,mseguiglob;
 
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
 tprinter = class;
 tcustomprintercanvas = class;
 tprintercanvas = class;
 printereventty = procedure(const sender: tprinter) of object;

 tprintertabulators = class(tcustomtabulators)
  published
   property defaultdist;
 end;
 colorspacety = (cos_gray,cos_rgb);
 pageorientationty = (pao_portrait,pao_landscape);
   
 tprinter = class(tmsecomponent,istatfile)
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
   fppmm: real;
   fprintcommand: string;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fpa_orientation: pageorientationty;
   procedure setstream(const avalue: ttextstream);
   procedure settabulators(const avalue: tprintertabulators);
   procedure setppmm(const avalue: real);
   procedure setpa_frameleft(const avalue: real);
   procedure setpa_frametop(const avalue: real);
   procedure setpa_frameright(const avalue: real);
   procedure setpa_framebottom(const avalue: real);
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
   procedure loaded; override;
   
   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;

   //icanvas   
   function getsize: sizety;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure beginprint(command: string = ''); overload;
   procedure beginprint(const astream: ttextstream); overload;
    //printer owns the stream, nil -> dummy mode
   procedure endprint;
  published
   property canvas: tprintercanvas read fcanvas write setcanvas;
   property onpagestart: printereventty read fonpagestart write fonpagestart;
   property onpageend: printereventty read fonpageend write fonpageend;
   property pa_width: real read fpa_width write setpa_width; 
   property pa_height: real read fpa_height write setpa_height;
   property pa_size: stdpagesizety read fpa_size write setpa_size nodefault;
   property pa_orientation: pageorientationty read fpa_orientation write setpa_orientation;
  
   property pa_frameleft: real read fpa_frameleft write setpa_frameleft; //mm, default 10
   property pa_frametop: real read fpa_frametop write setpa_frametop;    //mm, default 10
   property pa_frameright: real read fpa_frameright write setpa_frameright;  //mm, default 10
   property pa_framebottom: real read fpa_framebottom write setpa_framebottom; //mm, default 10
   property tabulators: tprintertabulators read ftabulators write settabulators;
   property ppmm: real read fppmm write setppmm; //pixel per mm, default 10
   property printcommand: string read fprintcommand write fprintcommand;
//   property colorspace: colorspacety read getcolorspace write setcolorspace;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read fstatvarname write fstatvarname;
 end;
 
 tcustomprintercanvas = class(tcanvas)
  private
   fheaderheight: integer;
   ffooterheight: integer;
   ffirstpage: integer;
   flastpage: integer;
   fpagenumber: integer;
   findentx: integer;
   findenty: integer;
   fprintorientation: pageorientationty;
   procedure setcolorspace(const avalue: colorspacety);
   function getliney: integer;
   procedure setprintorientation(const avalue: pageorientationty);
   procedure setliney(const avalue: integer);
  protected
//   fgcoffset: pointty;
   fgcoffsetx: real;
   fgcoffsety: real;
   fgcscale: real;
   foriginx,foriginy: real;
   fscale: real;
   foffset: pointty;
   fclientsize: sizety;
   fboundingbox: framety;
   ftitle: msestring;
   flinenumber: integer;
   fpagelinenumber: integer;
   fliney: integer;
   fstream: ttextstream;
   fprinter: tprinter;
   fcolorspace: colorspacety;
   procedure initprinting;
   procedure checkgcstate(state: canvasstatesty); override;
   procedure updatescale; virtual;
   procedure updateframe;
   procedure beginpage; virtual;
   procedure endpage; virtual;
   procedure textout(const text: richstringty; const dest: rectty;
                        const flags: textflagsty;
                        const tabdist: real); virtual; abstract;
       //tabdist < 0 -> lastx                 
   procedure begintextclip(const arect: rectty); virtual; abstract;
   procedure endtextclip; virtual; abstract;
   procedure checknextpage;
   procedure internalwriteln(const avalue: richstringty);
   procedure streamwrite(const atext: string); //checks fstream = nil
   procedure streamwriteln(const atext: string); //checks fstream = nil
  public
   constructor create(const user: tprinter; const intf: icanvas);
   
   procedure reset; override;
   
   //if cy of destrect = 0 and tf_ycentered in textflags -> place on baseline
   procedure drawtext(var info: drawtextinfoty); overload;
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
   property liney: integer read getliney write setliney;
   function lineheight: integer; //pixels

   procedure nextpage;
   function active: boolean; //true if firstpage <= pagenumber <= flastpage
      
   property title: msestring read ftitle write ftitle;
                            //used as print job lable
   property clientsize: sizety read fclientsize;
   property colorspace: colorspacety read fcolorspace write setcolorspace;
   property pagenumber: integer read fpagenumber;
   property firstpage: integer read ffirstpage write ffirstpage default 0;
   property lastpage: integer read flastpage write flastpage default bigint;
   
   property printorientation: pageorientationty read fprintorientation 
                write setprintorientation default pao_portrait;
   
   //dashes unit is 0.1mm
 end;

 tprintercanvas = class(tcustomprintercanvas)
  published
   property font;
   property printorientation;
   property colorspace;
   property title;
 end;
 
 tprintervalueselector = class(tcustomselector)
  private
   fprinter: tprinter;
   procedure setprinter(const avalue: tprinter);
   procedure printerchanged; virtual; abstract;
  protected
   procedure objectevent(const sender: tobject; 
                   const event: objecteventty); override;
  published
   property dropdown;
   property printer: tprinter read fprinter write setprinter;
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
 
implementation
uses
 sysutils,mseprocutils,msepipestream,msesysintf;
 
type
 tfont1 = class(tfont);
 
{ tprinter }

constructor tprinter.create(aowner: tcomponent);
begin
 fppmm:= defaultppmm;
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
 fprintcommand:= sys_getprintcommand;
 inherited;
end;

destructor tprinter.destroy;
begin
 endprint;
 fcanvas.free;
 ftabulators.free;
 inherited;
end;

procedure tprinter.loaded;
begin
 inherited;
 pagesizechanged;
 fcanvas.updatescale;
end;

procedure tprinter.beginprint(command: string = '');
var
 pip1: tpipewriter;
begin
 if command = '' then begin
  command:= fprintcommand;
 end;
 if command = '' then begin
  command:= sys_getprintcommand;
 end;
 pip1:= tpipewriter.create;
 try
  execmse2(command,pip1);
 except
  pip1.free;
  raise;
 end;
 beginprint(pip1);
end;

procedure tprinter.beginprint(const astream: ttextstream);
begin
 endprint;
 setstream(astream);
 fcanvas.initprinting;
end;

procedure tprinter.endprint;
begin
 setstream(nil);
end;

procedure tprinter.setstream(const avalue: ttextstream);
begin
 with fcanvas do begin
  try
   unlink;
  except
  end;
  fstream.free;
  fstream:= avalue;
 end;
 {
 with fcanvas do begin
  if fstream <> avalue then begin
   if fstream <> nil then begin
    try
     unlink;
    except
    end;
    fstream.free;
   end;
   fstream:= avalue;
  end;
 end;
 }
end;

procedure tprinter.settabulators(const avalue: tprintertabulators);
begin
 ftabulators.assign(avalue);
end;

procedure tprinter.pagesizechanged;
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

procedure tprinter.setpa_width(const avalue: real);
begin
 fpa_width:= avalue;
 fpa_size:= sps_user;
 pagesizechanged;
end;

procedure tprinter.setpa_height(const avalue: real);
begin
 fpa_height:= avalue;
 fpa_size:= sps_user;
 pagesizechanged;
end;

procedure tprinter.setpa_size(const avalue: stdpagesizety);
begin
 fpa_size:= avalue;
 pagesizechanged;
end;

procedure tprinter.setpa_orientation(const avalue: pageorientationty);
begin
 fpa_orientation:= avalue;
 pagesizechanged;
end;

procedure tprinter.setppmm(const avalue: real);
begin
 fppmm:= avalue;
 ftabulators.ppmm:= avalue;
 fcanvas.updatescale;
end;

procedure tprinter.setpa_frameleft(const avalue: real);
begin
 fpa_frameleft:= avalue;
 fcanvas.updateframe;
end;

procedure tprinter.setpa_frametop(const avalue: real);
begin
 fpa_frametop:= avalue;
 fcanvas.updateframe;
end;

procedure tprinter.setpa_frameright(const avalue: real);
begin
 fpa_frameright:= avalue;
 fcanvas.updateframe;
end;

procedure tprinter.setpa_framebottom(const avalue: real);
begin
 fpa_framebottom:= avalue;
 fcanvas.updateframe;
end;
{
function tprinter.getcolorspace: colorspacety;
begin
 result:= fcanvas.colorspace;
end;

procedure tprinter.setcolorspace(const avalue: colorspacety);
begin
 fcanvas.colorspace:= avalue;
end;
}
procedure tprinter.dostatread(const reader: tstatreader);
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
  printcommand:= readstring('printcommand',printcommand);
 end;
end;

procedure tprinter.dostatwrite(const writer: tstatwriter);
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
  writestring('printcommand',printcommand);
 end;
end;

procedure tprinter.statreading;
begin
end;

procedure tprinter.statread;
begin
end;

function tprinter.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tprinter.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

procedure tprinter.setcanvas(const avalue: tprintercanvas);
begin
 fcanvas.assign(avalue);
end;

function tprinter.getsize: sizety;
begin
 result:= fcanvas.fsize;
end;

{ tcustomprintercanvas }

constructor tcustomprintercanvas.create(const user: tprinter; const intf: icanvas);
begin
 fprinter:= user;
 flastpage:= bigint;
 inherited create(user,intf);
end;

procedure tcustomprintercanvas.initprinting;
begin
 fpagenumber:= 0;
 fpagelinenumber:= 0;
 fliney:= 0;
 reset;
end;

procedure tcustomprintercanvas.reset;
begin
 restore(1); //do not change the streamed values
 save;
 clipregion:= 0;
 origin:= nullpoint;
end;

procedure tcustomprintercanvas.updatescale;
begin
 if not (csloading in fprinter.componentstate) then begin
  exclude(fstate,cs_origin);
  with fprinter do begin
   fgcscale:= mmtoprintscale/fppmm; //map to printerunits

   if fprintorientation = pao_landscape then begin
    fsize.cx:= round(fpa_height * fppmm);
    fsize.cy:= round(fpa_width * fppmm);
    fgcoffsetx:= mmtoprintscale * fpa_frameleft;
    fgcoffsety:= - fpa_frametop*mmtoprintscale;
   end
   else begin
    fsize.cx:= round(fpa_width * fppmm);
    fsize.cy:= round(fpa_height * fppmm);
    fgcoffsetx:= mmtoprintscale * fpa_frameleft;
    fgcoffsety:= (fpa_height-fpa_frametop)*mmtoprintscale;
   end;
   
   if fprintorientation = pao_landscape then begin
    fboundingbox.left:= round(fpa_frametop*mmtoprintscale);
    fboundingbox.bottom:= round(fpa_frameleft*mmtoprintscale);
    fboundingbox.right:= round((fsize.cy/fppmm-fpa_framebottom)*mmtoprintscale);
    fboundingbox.top:= round((fsize.cx/fppmm-fpa_frameright)*mmtoprintscale);
   end
   else begin
    fboundingbox.left:= round(fpa_frameleft*mmtoprintscale);
    fboundingbox.bottom:= round(fpa_framebottom*mmtoprintscale);
    fboundingbox.right:= round((fsize.cx/fppmm-fpa_frameright)*mmtoprintscale);
    fboundingbox.top:= round((fsize.cy/fppmm-fpa_frametop)*mmtoprintscale);
   end;
   fclientsize.cx:= fsize.cx - round((fpa_frameleft+fpa_frameright)*fppmm);
   fclientsize.cy:= fsize.cy - round((fpa_frametop+fpa_framebottom)*fppmm);
  end;
 end;
end;

procedure tcustomprintercanvas.checkgcstate(state: canvasstatesty);
begin
 if not (cs_origin in fstate) then begin
  with fprinter do begin
   foriginx:= fgcoffsetx + mmtoprintscale * (origin.x/fppmm);
   foriginy:= fgcoffsety - mmtoprintscale * (origin.y/fppmm);
  end;
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
 with fprinter do begin
  if canevent(tmethod(fonpageend)) then begin
   fonpageend(fprinter);
  end;
 end;
end;

procedure tcustomprintercanvas.drawtext(var info: drawtextinfoty);
var
 afontnum: integer;
 tab1: tcustomtabulators;
 ar1: richstringarty;
 int1,int2: integer;
 rea1: real;
 aflags: textflagsty;
 mstr1: msestring;
 rstr1: richstringty;
begin
 if fstream = nil then begin
  exit;
 end;
 ar1:= nil; //compiler warning
 info.res:= nullrect;
 save;
 if info.font <> nil then begin //foreign font
  font:= info.font;
 end;
 with fdrawinfo do begin
  afonthandle1:= tfont1(font).gethandle;
//   afonthandle:= tfont1(font).getdatapo^.font;
  with fvaluepo^.font do begin
   acolorforeground:= color;
   acolorbackground:= colorbackground;
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
  if countchars(text.text,c_tab) = 0 then begin
   textout(text,dest,flags,0);
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
     mstr1:= text.text;
     try
      replacechar(text.text,c_tab,' ');
      textout(text,dest,flags,0);
     finally
      text.text:= mstr1;
     end;
    end
    else begin
     ar1:= splitrichstring(text,c_tab);
     textout(ar1[0],dest,flags,0);
     rea1:= tab1.defaultdist*mmtoprintscale;
     for int1:= 1 to high(ar1) do begin     
      textout(ar1[int1],dest,flags,rea1);
     end;
    end;
   end
   else begin
    ar1:= splitrichstring(text,c_tab);
    textout(ar1[0],dest,flags,0);
    for int1:= 1 to high(ar1) do begin     
     if int1 > tab1.count then begin
      rstr1.text:= ' ';
      rstr1.format:= nil;
      rstr1:= richconcat(rstr1,ar1[int1]);
      for int2:= int1+1 to high(ar1) do begin
       rstr1:= richconcat(rstr1,' ');
       rstr1:= richconcat(rstr1,ar1[int2]);
      end;
      textout(rstr1,dest,flags-[tf_right,tf_xcentered],-1); //print rest of string
      break;
     end;
     aflags:= flags - [tf_xcentered,tf_right];
     with tab1[int1-1] do begin
      case kind of
       tak_right,tak_decimal: aflags:= aflags + [tf_right];
       tak_centered: aflags:= aflags + [tf_xcentered];
      end;
      if kind = tak_decimal then begin
       int2:= msestrrscan(ar1[int1].text,widechar(decimalseparator));
       if int2 > 0 then begin
        textout(richcopy(ar1[int1],1,int2-1),makerect(round(pos*fprinter.fppmm),dest.y,0,
                  dest.cy),aflags,0); //int
        textout(richcopy(ar1[int1],int2,bigint),makerect(0,dest.y,0,
                  dest.cy),aflags-[tf_right],-1); //frac
       end
       else begin
        textout(ar1[int1],makerect(round(pos*fprinter.fppmm),dest.y,0,
                  dest.cy),aflags,0); //no frac
       end;
      end
      else begin
       textout(ar1[int1],makerect(round(pos*fprinter.fppmm),dest.y,0,dest.cy),aflags,0);
      end;
     end;
    end;
   end;
  end;
  if flags * [tf_clipi,tf_clipo] <> [] then begin
   endtextclip;
  end;
 end;
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
 if remaininglines <= 0 then begin
  nextpage;
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
  result:= round(defaultfontheight*fprinter.fppmm);
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
begin
 result:= (fpagenumber >= ffirstpage) and (fpagenumber <= flastpage);
end;

function tcustomprintercanvas.getliney: integer;
begin
 checknextpage;
 result:= fliney + fheaderheight;
end;

procedure tcustomprintercanvas.setliney(const avalue: integer);
begin
 checknextpage;
 fliney:= avalue - fheaderheight;
end;

procedure tcustomprintercanvas.setprintorientation(const avalue: pageorientationty);
begin
 if avalue <> fprintorientation then begin
  fprintorientation:= avalue;
  updatescale;
 end;
end;

procedure tcustomprintercanvas.streamwrite(const atext: string);
begin
 if fstream <> nil then begin
  fstream.write(atext);
 end;
end;

procedure tcustomprintercanvas.streamwriteln(const atext: string);
begin
 if fstream <> nil then begin
  fstream.writeln(atext);
 end;
end;

{ tprintervalueselector }

procedure tprintervalueselector.setprinter(const avalue: tprinter);
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
 addrow(['Portrait']);
 addrow(['Landscape']);
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
 names.addrow(['Portrait']);
 names.addrow(['Landscape']);
end;

procedure tpageorientationselector.dochange;
begin
 if fprinter <> nil then begin
  fprinter.pa_orientation:= value;
 end;
 inherited;
end;

end.
