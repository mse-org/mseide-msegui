{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msecolordialog;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msegui,mseclasses,mseforms,msegraphedits,msewidgets,msesimplewidgets,
 msedataedits,msegraphics,mseglob,mseguiglob,msedialog,
 classes,msetypes,msedropdownlist,
 msestrings,mseedit,msestat,msestatfile,msegraphutils,msemenus,mseevent;

const
 colordialogstatname = 'colordialog.sta';
 
type
 tcolordialogfo = class(tmseform)
   cancel: tbutton;
   ok: tbutton;
   sliderred: tslider;
   slidergreen: tslider;
   sliderblue: tslider;
   red: tintegeredit;
   green: tintegeredit;
   blue: tintegeredit;
   colorarea: tpaintbox;
   sliderhue: tslider;
   slidersat: tslider;
   sliderbright: tslider;
   hue: tintegeredit;
   sat: tintegeredit;
   bright: tintegeredit;
   colorareabefore: tpaintbox;
   tgroupbox1: tgroupbox;
   tstatfile1: tstatfile;
   procedure hueonsetvalue(const sender: TObject; var avalue: realty; var accept: Boolean);
   procedure satonsetvalue(const sender: TObject; var avalue: realty; var accept: Boolean);
   procedure brightonsetvalue(const sender: TObject; var avalue: realty; var accept: Boolean);
   procedure hsbchange(const sender: TObject);
   procedure redonsetvalue(const sender: TObject; var avalue: realty; var accept: Boolean);
   procedure greenonsetvalue(const sender: TObject; var avalue: realty; var accept: Boolean);
   procedure blueonsetvalue(const sender: TObject; var avalue: realty; var accept: Boolean);
   procedure rgbchange(const sender: TObject);
  private
   fupdating: boolean;
 end;
 
 setcoloreventty = procedure(const sender: tobject; var avalue: colorty; 
                          var accept: boolean) of object;               

 tellipsedropdownbuttonframe = class(tdropdownbuttonframe)
  private
   function getbuttonellipse: tdropdownbutton;
   procedure setbuttonellipse(const avalue: tdropdownbutton);
  public
   constructor create(const intf: icaptionframe; const buttonintf: ibutton); override;                                                  
  published
   property buttonellipse: tdropdownbutton read getbuttonellipse write setbuttonellipse;
 end;
                          
 tcustomcoloredit = class(tcustomenumedit)
  private
   function getvalue: colorty;
   procedure setvalue(avalue: colorty);
   function getvaluedefault: colorty;
   procedure setvaluedefault(avalue: colorty);
//   function getbuttonellipse: tdropdownbutton;
//   procedure setbuttonellipse(const avalue: tdropdownbutton);
   
   function getonsetvalue: setcoloreventty;
   procedure setonsetvalue(const avalue: setcoloreventty);
   function getframe: tellipsedropdownbuttonframe;
   procedure setframe(const avalue: tellipsedropdownbuttonframe);
  protected
   function internaldatatotext(
                 const avalue: integer): msestring; virtual;
   function datatotext(const data): msestring; override;
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure buttonaction(var action: buttonactionty; 
                    const buttonindex: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   property value: colorty read getvalue write setvalue default cl_none;
   property valuedefault: colorty read getvaluedefault 
                     write setvaluedefault default cl_none;
   property dropdown;
   property onsetvalue: setcoloreventty read getonsetvalue write setonsetvalue;
   property frame: tellipsedropdownbuttonframe read getframe write setframe;
 end;

 tcoloredit = class(tcustomcoloredit)
  published
   property value;
   property valuedefault;
   property dropdown;
   property onsetvalue;
   property frame;
 end;
  
 tcolordropdowncontroller = class(tnocolsdropdownlistcontroller)
  protected
   function getbuttonframeclass: dropdownbuttonframeclassty; override;
  public
   constructor create(const intf: idropdownlist);
//   procedure createframe; override;
 end;
 
function colordialog(var acolor: colorty): modalresultty;
//threadsave

implementation
uses
 msecolordialog_mfm,msestockobjects,mseformatstr,sysutils;
type
 twidget1 = class(twidget);
 
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
   except
    fillchar(col1,sizeof(col1),0);
   end;
   fo.colorareabefore.frame.colorclient:= colorty(col1);
   fo.red.value:= col1.red;
   fo.green.value:= col1.green;
   fo.blue.value:= col1.blue;
   result:= fo.show(true);
   if result = mr_ok then begin
    acolor:= rgbtocolor(fo.red.value,fo.green.value,fo.blue.value);
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

procedure tellipsedropdownbuttonframe.setbuttonellipse(const avalue: tdropdownbutton);
begin
 buttons[1].assign(avalue);
end;

{ tcolordropdowncontroller }

constructor tcolordropdowncontroller.create(const intf: idropdownlist);
begin
 inherited;
 valuelist.asarray:= getcolornames;
 options:= [deo_autodropdown,deo_keydropdown];
end;
{
procedure tcolordropdowncontroller.createframe;
begin
 inherited;
 with tcustomdropdownbuttonframe(twidget1(fintf.getwidget).fframe) do begin
  buttons.count:= 2;
  buttons[1].assign(buttons[0]);
  buttons[1].imagenr:= ord(stg_ellipsesmall);
  buttons[0].imagenr:= ord(stg_arrowdownsmall);
  activebutton:= 0;
 end;
end;
}
function tcolordropdowncontroller.getbuttonframeclass: dropdownbuttonframeclassty;
begin
 result:= tellipsedropdownbuttonframe;
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

procedure tcustomcoloredit.texttovalue(var accept: boolean; const quiet: boolean);
var
 co1: colorty;
 int1: integer;
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
   try
    co1:= strtointvalue(feditor.text,base);
   except
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
 if (action = ba_click) and (buttonindex = 1) then begin
  co1:= value;
  if colordialog(co1) = mr_ok then begin
   tcolordropdowncontroller(fdropdown).clearitemindex; 
   text:= colortostring(co1);
   checkvalue;  
  end;
 end;
end;

function tcustomcoloredit.internaldatatotext(const avalue: integer): msestring;
begin
 result:= colortostring(avalue);
end;

function tcustomcoloredit.datatotext(const data): msestring;
var
 int1: integer;
begin
 if @data = nil then begin
  int1:= fvalue1;
 end
 else begin
  int1:= integer(data);
 end;
 result:= internaldatatotext(int1);
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

end.
