{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msecolordialog;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msegui,mseclasses,mseforms,msegraphedits,msewidgets,msesimplewidgets,
 msedataedits,msegraphics,mseglob,mseguiglob,msedialog,classes,mclasses,
 msetypes,msedropdownlist,msegrids,msestrings,mseedit,msestat,msestatfile,
 msegraphutils,msemenus,mseevent,mseificomp,mseificompglob,mseifiglob,
 msesplitter,msedispwidgets,mserichstring,msescrollbar;

const
 colordialogstatname = 'colordialog.sta';
 
type
 
 setcoloreventty = procedure(const sender: tobject; var avalue: colorty;
                          var accept: boolean) of object;               

 tellipsedropdownbuttonframe = class(tdropdownbuttonframe)
  private
   function getbuttonellipse: tdropdownbutton;
   procedure setbuttonellipse(const avalue: tdropdownbutton);
  public
   constructor create(const intf: icaptionframe;
                                     const buttonintf: ibutton); override;                                                  
  published
   property buttonellipse: tdropdownbutton read getbuttonellipse 
                                                    write setbuttonellipse;
 end;
                          
 tcustomcoloredit = class(tcustomenumedit)
  private
   function getvalue: colorty;
   procedure setvalue(avalue: colorty);
   function getvaluedefault: colorty;
   procedure setvaluedefault(avalue: colorty);
   
   function getonsetvalue: setcoloreventty;
   procedure setonsetvalue(const avalue: setcoloreventty);
   function getframe: tellipsedropdownbuttonframe;
   procedure setframe(const avalue: tellipsedropdownbuttonframe);
   function getgridvalue(const index: integer): colorty;
   procedure setgridvalue(const index: integer; const avalue: colorty);
   function getgridvalues: colorarty;
   procedure setgridvalues(const avalue: colorarty);
  protected
   function internaldatatotext1(
                 const avalue: integer): msestring; virtual;
   function internaldatatotext(const data): msestring; override;
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure paintimage(const canvas: tcanvas); override;
   function geteditframe: framety; override;
   procedure buttonaction(var action: buttonactionty;
                    const buttonindex: integer); override;
   procedure dochange; override;
  public
   constructor create(aowner: tcomponent); override;
   property value: colorty read getvalue write setvalue default cl_none;
   property valuedefault: colorty read getvaluedefault
                     write setvaluedefault default cl_none;
   property onsetvalue: setcoloreventty read getonsetvalue write setonsetvalue;
   property frame: tellipsedropdownbuttonframe read getframe write setframe;
   property gridvalue[const index: integer]: colorty
        read getgridvalue write setgridvalue; default;
   property gridvalues: colorarty read getgridvalues write setgridvalues;
 end;

 tcoloredit = class(tcustomcoloredit)
  published
   property value;
   property valuedefault;
{$ifdef mse_with_ifi}
   property ifilink;
{$endif}
   property dropdown;
   property onsetvalue;
   property frame;
 end;
  
 tcolordialogfo = class(tmseform)
   tstatfile1: tstatfile;
   tlayouter1: tlayouter;
   blue: tintegeredit;
   green: tintegeredit;
   red: tintegeredit;
   bright: tintegeredit;
   sat: tintegeredit;
   hue: tintegeredit;
   tlayouter2: tlayouter;
   cancel: tbutton;
   ok: tbutton;
   colored: tcoloredit;
   rgbed: tintegeredit;
   tlayouter3: tlayouter;
   sliderblue: tslider;
   slidergreen: tslider;
   sliderred: tslider;
   sliderbright: tslider;
   slidersat: tslider;
   sliderhue: tslider;
   gb: tgroupbox;
   colorareabefore: tpaintbox;
   colorarea: tpaintbox;
   colorpibu: tbutton;
   procedure hueonsetvalue(const sender: TObject; var avalue: realty;
                                                         var accept: Boolean);
   procedure satonsetvalue(const sender: TObject; var avalue: realty;
                                                         var accept: Boolean);
   procedure brightonsetvalue(const sender: TObject; var avalue: realty;
                                                         var accept: Boolean);
   procedure hsbchange(const sender: TObject);
   procedure redonsetvalue(const sender: TObject; var avalue: realty;
                                                         var accept: Boolean);
   procedure greenonsetvalue(const sender: TObject; var avalue: realty;
                                                         var accept: Boolean);
   procedure blueonsetvalue(const sender: TObject; var avalue: realty; 
                                                         var accept: Boolean);
   procedure rgbchange(const sender: TObject);
   procedure componentsdataentered(const sender: TObject);
   procedure layoutexe(const sender: TObject);
   procedure rgbeddataentered(const sender: TObject);
   procedure coloreddataentered(const sender: TObject);
   procedure loadedexe(const sender: TObject);
   procedure colorpickexe(const sender: TObject);
   procedure mouseeventexe(const sender: twidget; var ainfo: mouseeventinfoty);
   procedure shortcutexe(const sender: twidget; var ainfo: keyeventinfoty);
  private
   fupdating: boolean;
   procedure updatecomponents;
  protected
   fcolorpicking: boolean;
   fcolorbefore: colorty;
   procedure begincolorpick();
   procedure endcolorpick();
 end;

 tcolordropdowncontroller = class(tnocolsdropdownlistcontroller)
  protected
   fcolorvalues: colorarty;
   function getbuttonframeclass: dropdownbuttonframeclassty; override;
   function getfixcolclass: dropdownfixcolclassty; override;
  public
   constructor create(const intf: idropdownlist);
 end;
 
function colordialog(var acolor: colorty): modalresultty;
//threadsafe
procedure paintcolorimage(const sender: twidget; const canvas: tcanvas;
                                                    const acolor: colorty);
procedure paintcolorrect(const canvas: tcanvas; const arect: rectty;
                                   const acolor: colorty);

implementation
uses
 msecolordialog_mfm,msestockobjects,mseformatstr,sysutils,msepointer,
 msekeyboard,mseguiintf;
type
 twidget1 = class(twidget);
 
 tcolorfixcol = class(tdropdownfixcol)
  protected
   ficonrect: rectty;
   procedure drawcell(const canvas: tcanvas); override;
  public
   constructor create(const agrid: tcustomgrid;
              const aowner: tgridarrayprop;
                const acontroller: tcustomdropdownlistcontroller); override;
 end;
 
function colordialog(var acolor: colorty): modalresultty;
var
 fo: tcolordialogfo;
 col1: rgbtriplety;
begin
 application.lock;
 try
  fo:= tcolordialogfo.create(nil);
  try
   try
    col1:= colortorgb(acolor);
    fo.colored.value:= acolor;
   except
    fillchar(col1,sizeof(col1),0);
    fo.colored.value:= 0;
   end;
   fo.rgbed.value:= integer(col1);
   fo.colorareabefore.frame.colorclient:= colorty(col1);
   fo.red.value:= col1.red;
   fo.green.value:= col1.green;
   fo.blue.value:= col1.blue;
   result:= fo.show(true);
   if result = mr_ok then begin
    acolor:= fo.colored.value;
//    acolor:= rgbtocolor(fo.red.value,fo.green.value,fo.blue.value);
   end;
  finally
   fo.free;
  end;
 finally
  application.unlock;
 end;
end;

{ tellipsedropdownbuttonframe }

constructor tellipsedropdownbuttonframe.create(const intf: icaptionframe;
               const buttonintf: ibutton);
begin
 inherited;
 buttons.count:= 2;
 buttons[1].assign(buttons[0]);
 buttons[1].imagenr:= ord(stg_ellipsesmall);
 buttons[0].imagenr:= ord(stg_arrowdownsmall);
 activebutton:= 0;
end;

function tellipsedropdownbuttonframe.getbuttonellipse: tdropdownbutton;
begin
 result:= tdropdownbutton(buttons[1]);
end;

procedure tellipsedropdownbuttonframe.setbuttonellipse(
                                              const avalue: tdropdownbutton);
begin
 buttons[1].assign(avalue);
end;

{ tcolorfixcol }

constructor tcolorfixcol.create(const agrid: tcustomgrid;
               const aowner: tgridarrayprop;
               const acontroller: tcustomdropdownlistcontroller);
begin
 inherited;
 width:= agrid.datarowheight;
 ficonrect.x:= 1;
 ficonrect.y:= 1;
 ficonrect.cy:= width - 2;
 ficonrect.cx:= ficonrect.cy;
end;

procedure tcolorfixcol.drawcell(const canvas: tcanvas);
begin
 inherited;
 with cellinfoty(canvas.drawinfopo^) do begin
  paintcolorrect(canvas,ficonrect,
          tcolordropdowncontroller(fcontroller).fcolorvalues[cell.row]);
 end;
end;

{ tcolordropdowncontroller }

constructor tcolordropdowncontroller.create(const intf: idropdownlist);
//var
// int1: integer;
begin
 inherited;
 valuelist.asarray:= getcolornames;
 fcolorvalues:= getcolorvalues;
 {
 for int1:= 0 to high(fcolorvalues) do begin
  fcolorvalues[int1]:= colorty(colortorgb(fcolorvalues[int1]));
 end;
 }
 options:= [deo_autodropdown,deo_keydropdown];
end;

function tcolordropdowncontroller.getbuttonframeclass():
                                            dropdownbuttonframeclassty;
begin
 result:= tellipsedropdownbuttonframe;
end;

function tcolordropdowncontroller.getfixcolclass: dropdownfixcolclassty;
begin
 result:= tcolorfixcol;
end;

{ tcustomcoloredit }

constructor tcustomcoloredit.create(aowner: tcomponent);
begin
 inherited;
 enums:= integerarty(getcolorvalues);
 min:= minint;
 base:= nb_hex;
 valuedefault:= cl_none;
 value:= valuedefault;
end;

function tcustomcoloredit.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tcolordropdowncontroller.create(idropdownlist(self));
end;

procedure tcustomcoloredit.texttovalue(var accept: boolean;
                                                   const quiet: boolean);
var
 co1: colorty;
 int1: integer;
 mstr1: msestring;
begin
 if trim(text) = '' then begin
  co1:= valuedefault;
 end
 else begin
  int1:= tdropdownlistcontroller(fdropdown).itemindex;
  if (int1 >= 0) and (int1 <= high(enums)) then begin
   co1:= enums[int1];
  end
  else begin
   mstr1:= feditor.text;
   checktext(mstr1,accept);
   if not accept then begin
    exit;
   end;
   if not trystringtocolor(mstr1,co1) then begin
    accept:= false;
    formaterror(quiet);
   end;
  end;
 end;
 if accept then begin
  if not quiet and canevent(tmethod(fonsetvalue1)) then begin
   fonsetvalue1(self,integer(co1),accept);
  end;
  if accept then begin
   value:= co1;
  end;
 end;
end;

procedure tcustomcoloredit.buttonaction(var action: buttonactionty;
            const buttonindex: integer);
var
 co1: colorty;
begin
 if buttonindex = 1 then begin
  case action of
   ba_buttonpress: begin
    if canfocus then begin
     setfocus;
    end;
   end;
   ba_click: begin
    if focused then begin
     co1:= value;
     if colordialog(co1) = mr_ok then begin
      tcolordropdowncontroller(fdropdown).resetselection; 
      text:= colortostring(co1);
      checkvalue;  
     end;
    end;
   end;
  end;
 end;
end;

function tcustomcoloredit.internaldatatotext1(const avalue: integer): msestring;
begin
 result:= colortostring(avalue);
end;

function tcustomcoloredit.internaldatatotext(const data): msestring;
var
 int1: integer;
begin
 if @data = nil then begin
  int1:= fvalue1;
 end
 else begin
  int1:= integer(data);
 end;
 result:= internaldatatotext1(int1);
end;

function tcustomcoloredit.getvalue: colorty;
begin
 result:= inherited value;
end;

procedure tcustomcoloredit.setvalue(avalue: colorty);
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 inherited value:= avalue;
end;

function tcustomcoloredit.getvaluedefault: colorty;
begin
 result:= inherited valuedefault;
end;

procedure tcustomcoloredit.setvaluedefault(avalue: colorty);
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 inherited valuedefault:= avalue;
end;
{
function tcustomcoloredit.getbuttonellipse: tdropdownbutton;
begin
 with tdropdownbuttonframe(fframe) do begin
  result:= tdropdownbutton(buttons[0]);
 end;
end;

procedure tcustomcoloredit.setbuttonellipse(const avalue: tdropdownbutton);
begin
 with tdropdownbuttonframe(fframe) do begin
  tdropdownbutton(buttons[0]).assign(avalue);
 end;
end;
}
function tcustomcoloredit.getonsetvalue: setcoloreventty;
begin
 result:= setcoloreventty(inherited onsetvalue);
end;

procedure tcustomcoloredit.setonsetvalue(const avalue: setcoloreventty);
begin
 inherited onsetvalue:= setintegereventty(avalue);
end;

function tcustomcoloredit.getframe: tellipsedropdownbuttonframe;
begin
 result:= tellipsedropdownbuttonframe(inherited frame);
end;

procedure tcustomcoloredit.setframe(const avalue: tellipsedropdownbuttonframe);
begin
 inherited frame:= avalue;
end;

function tcustomcoloredit.getgridvalue(const index: integer): colorty;
begin
 result:= inherited gridvalue[index];
end;

procedure tcustomcoloredit.setgridvalue(const index: integer;
                                               const avalue: colorty);
begin
 inherited gridvalue[index]:= avalue; 
end;

function tcustomcoloredit.getgridvalues: colorarty;
begin
 result:= colorarty(inherited gridvalues);
end;

procedure tcustomcoloredit.setgridvalues(const avalue: colorarty);
begin
 inherited gridvalues:= integerarty(avalue);
end;

function tcustomcoloredit.geteditframe: framety;
begin
 result.left:= innerclientsize.cy + 1;
 result.right:= 0;
 result.top:= 0;
 result.bottom:= 0;
end;

procedure paintcolorrect(const canvas: tcanvas; const arect: rectty;
                                   const acolor: colorty);
var
 co1: colorty;
begin
 canvas.fillrect(arect,colorty(colortorgb(acolor)));
 co1:= cl_black;
 if acolor and speccolormask = cl_functional then begin
  co1:= cl_gray;
 end;
 canvas.drawrect(arect,co1);
end;

procedure paintcolorimage(const sender: twidget; const canvas: tcanvas;
                                                      const acolor: colorty);
var
 rect1: rectty;
begin
 with sender do begin
  if canvas.drawinfopo <> nil then begin
   with cellinfoty(canvas.drawinfopo^) do begin
    rect1:= innerrect;
   end;
  end
  else begin
   rect1:= innerclientrect;
  end;
  rect1.x:= 1;
  dec(rect1.cy);
  rect1.cx:= rect1.cy;
  paintcolorrect(canvas,rect1,acolor);
  {
  canvas.fillrect(rect1,colorty(colortorgb(acolor)));
  co1:= cl_black;
  if acolor and speccolormask = cl_functional then begin
   co1:= cl_gray;
  end;
  canvas.drawrect(rect1,co1);
  }
 end;
end;

procedure tcustomcoloredit.paintimage(const canvas: tcanvas);
var
 co1: colorty;
begin
 if canvas.drawinfopo <> nil then begin
  with cellinfoty(canvas.drawinfopo^) do begin
   co1:= pcolorty(datapo)^;
  end;
 end
 else begin
  co1:= value;
 end;
 paintcolorimage(self,canvas,co1);
end;

procedure tcustomcoloredit.dochange;
begin
 inherited;
 invalidate;
end;

{ tcolordialogfo }

procedure tcolordialogfo.hueonsetvalue(const sender: TObject;
                               var avalue: realty; var accept: Boolean);
begin
 hue.value:= round(avalue * 360);
end;

procedure tcolordialogfo.satonsetvalue(const sender: TObject;
                               var avalue: realty; var accept: Boolean);
begin
 sat.value:= round(avalue * 100);
end;

procedure tcolordialogfo.brightonsetvalue(const sender: TObject;
                               var avalue: realty; var accept: Boolean);
begin
 bright.value:= round(avalue * 100);
end;

procedure tcolordialogfo.hsbchange(const sender: TObject);
var
 r,g,b: real;
 r1,g1,b1: integer;
 int1: integer;
 rea1,rea2: real;
begin
 int1:= hue.value;
 r:= 0;
 g:= 0;
 b:= 0;
 if int1 < 60 then begin
  r:= 60;
  g:= int1;
 end
 else begin
  if int1 < 120 then begin
   r:= 120 - int1;
   g:= 60;
  end
  else begin
   if int1 < 180 then begin
    g:= 60;
    b:= int1 - 120;
   end
   else begin
    if int1 < 240 then begin
     g:= 240 - int1;
     b:= 60
    end
    else begin
     if int1 < 300 then begin
      b:= 60;
      r:= int1 - 240;
     end
     else begin
      b:= 360 - int1;
      r:= 60;
     end;
    end;
   end;
  end;
 end;
 r1:= round(r*255/60);
 g1:= round(g*255/60);
 b1:= round(b*255/60);
 slidersat.scrollbar.face.fade_color[1]:= rgbtocolor(r1,g1,b1);
 rea1:= sat.value / 100;
 rea2:= 1-rea1;
 rea1:= rea1 / 60;
 r:= r * rea1 + rea2;
 g:= g * rea1 + rea2;
 b:= b * rea1 + rea2;
 r1:= round(r*255);
 g1:= round(g*255);
 b1:= round(b*255);
 sliderbright.scrollbar.face.fade_color[1]:= rgbtocolor(r1,g1,b1);
 rea1:= bright.value / 100;
 r:= r*rea1;
 g:= g*rea1;
 b:= b*rea1;
 sliderhue.value:= hue.value/360;
 slidersat.value:= sat.value/100;
 sliderbright.value:= bright.value/100;
 if not fupdating then begin
  fupdating:= true;
  red.value:= round(r*255);
  green.value:= round(g*255);
  blue.value:= round(b*255);
  fupdating:= false;
 end;
end;

procedure tcolordialogfo.blueonsetvalue(const sender: TObject;
                 var avalue: realty; var accept: Boolean);
begin
 blue.value:= round(avalue * 255);
end;

procedure tcolordialogfo.greenonsetvalue(const sender: TObject;
                var avalue: realty; var accept: Boolean);
begin
 green.value:= round(avalue * 255);
end;

procedure tcolordialogfo.redonsetvalue(const sender: TObject;
               var avalue: realty; var accept: Boolean);
begin
 red.value:= round(avalue * 255);
end;


procedure tcolordialogfo.rgbchange(const sender: TObject);

type
 colorsegmentty = (cs_red,cs_green,cs_blue);
var
 min,max: integer;
// r1,g1,b1: integer;
 br,sa,hu: real;
 segment: colorsegmentty;

 function calchue(l,c,r: integer): real;     //range -1 .. +1, 0-> center
 begin
  if c > min then begin
   if l > r then begin
    result:= -(l-min)/(c-min);
   end
   else begin
    result:= (r-min)/(c-min);
   end;
  end
  else begin
   result:= 0;
  end;
 end;

begin
 colorarea.frame.colorclient:= rgbtocolor(red.value,green.value,blue.value);
 sliderred.value:= red.value / 255;
 slidergreen.value:= green.value / 255;
 sliderblue.value:= blue.value / 255;
 if not fupdating then begin
  fupdating:= true;
  max:= 0;
  segment:= cs_red;
  if red.value > max then begin
   max:= red.value;
  end;
  if green.value > max then begin
   max:= green.value;
   segment:= cs_green;
  end;
  if blue.value > max then begin
   max:= blue.value;
   segment:= cs_blue;
  end;
  min:= 255;
  if red.value < min then begin
   min:= red.value;
  end;
  if green.value < min then begin
   min:= green.value;
  end;
  if blue.value < min then begin
   min:= blue.value;
  end;
  br:= max/255;
  if br > 0 then begin
   sa:= 1-min/(255*br);
   if sa < 0 then begin
    sa:= 0;
   end;
  end
  else begin
   sa:= 0
  end;
  bright.value:= round(br*100);
  sat.value:= round(sa*100);
  case segment of
   cs_red: begin
    hu:= calchue(blue.value,red.value,green.value);
    hue.value:= (round(hu*60)+360) mod 360;
   end;
   cs_green: begin
    hu:= calchue(red.value,green.value,blue.value);
    hue.value:= round(hu*60) + 120;
   end;
   cs_blue: begin
    hu:= calchue(green.value,blue.value,red.value);
    hue.value:= (round(hu*60) + 240) mod 360;
   end;
  end;
  fupdating:= false;
 end;
end;

procedure tcolordialogfo.updatecomponents;
var
 rgb1: rgbtriplety;
begin
 if not fupdating then begin
  fupdating:= true;
  rgb1:= rgbtriplety(rgbed.value);
  red.value:= rgb1.red;
  green.value:= rgb1.green;
  blue.value:= rgb1.blue;
  fupdating:= false;
  rgbchange(nil);
 end;
end;

procedure tcolordialogfo.componentsdataentered(const sender: TObject);
begin
 rgbed.value:= integer(rgbtocolor(red.value,green.value,blue.value));
 colored.value:= rgbed.value;
end;

procedure tcolordialogfo.layoutexe(const sender: TObject);
begin
 gb.height:= sliderhue.height;
 colorareabefore.frameheight:= gb.height;
 colorarea.frameheight:= gb.height;
 aligny(wam_center,[hue,colorpibu]);
end;

procedure tcolordialogfo.rgbeddataentered(const sender: TObject);
begin
 colored.value:= colorty(rgbed.value);
 updatecomponents;
end;

procedure tcolordialogfo.coloreddataentered(const sender: TObject);
begin
 rgbed.value:= integer(colortorgb(colored.value));
 updatecomponents;
end;

procedure tcolordialogfo.loadedexe(const sender: TObject);
begin
 colored.activate;
end;

procedure tcolordialogfo.colorpickexe(const sender: TObject);
begin
 begincolorpick();
end;

procedure tcolordialogfo.begincolorpick();
begin
 fcolorbefore:= colored.value;
 capturemouse(true);
 application.cursorshape:= cr_pointinghand;
 fcolorpicking:= true; 
end;

procedure tcolordialogfo.endcolorpick();
begin
 releasemouse(true);
 fcolorpicking:= false;
 application.cursorshape:= cr_default;
end;

procedure tcolordialogfo.mouseeventexe(const sender: twidget;
               var ainfo: mouseeventinfoty);
var
 px1: pixelty;
 co1: colorty;
begin
 if fcolorpicking then begin
  if (ainfo.eventkind in [ek_buttonpress,ek_mousemove]) and
             (ainfo.shiftstate * buttonshiftstatesmask = [ss_left]) then begin
   if gui_getpixel(gui_getrootwindow(window.winid),
       translatewidgetpoint(ainfo.pos,self,nil),px1) = gue_ok then begin
    co1:= gui_pixeltorgb(px1);
    if colored.value <> co1 then begin
     colored.value:= co1;
     colored.checkvalue();
    end;
   end;
  end
  else begin
   if (ainfo.eventkind = ek_buttonrelease) then begin
    endcolorpick();
   end;
  end;
 end;
end;

procedure tcolordialogfo.shortcutexe(const sender: twidget;
               var ainfo: keyeventinfoty);
begin
 if fcolorpicking then begin
  if ainfo.key = key_escape then begin
   endcolorpick();
   colored.value:= fcolorbefore;
   colored.checkvalue();
  end;
  include(ainfo.eventstate,es_processed);
 end;
end;

end.
