{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msethemesdialog;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msegui,mseclasses,mseforms,msegraphedits,msewidgets,msesimplewidgets,
 msedataedits,msegraphics,mseguiglob,msedialog,classes,msetypes,msedropdownlist,
 msestrings,mseedit,msestat,msestatfile,msedatalist,mseevent,mseformatstr,
 mseinplaceedit,msewidgetgrid,msedrawtext,msegraphutils,
 msebitmap,mserichstring, mseglob;

const
 themesdialogstatname = 'themesdialog.sta';
 
type
 tthemesdialogfo = class(tmseform)
   blue: tintegeredit;
   bright: tintegeredit;
   cancel: tbutton;
   colorarea: tpaintbox;
   colorareabefore: tpaintbox;
   defcolorlist: tenumedit;
   green: tintegeredit;
   hue: tintegeredit;
   ok: tbutton;
   red: tintegeredit;
   sat: tintegeredit;
   sliderblue: tslider;
   sliderbright: tslider;
   slidergreen: tslider;
   sliderhue: tslider;
   sliderred: tslider;
   slidersat: tslider;
   tgroupbox1: tgroupbox;
   tstatfile1: tstatfile;
   usecolor: tbutton;
   procedure hueonsetvalue(const sender: TObject; var avalue: realty; var accept: Boolean);
   procedure satonsetvalue(const sender: TObject; var avalue: realty; var accept: Boolean);
   procedure brightonsetvalue(const sender: TObject; var avalue: realty; var accept: Boolean);
   procedure hsbchange(const sender: TObject);
   procedure redonsetvalue(const sender: TObject; var avalue: realty; var accept: Boolean);
   procedure greenonsetvalue(const sender: TObject; var avalue: realty; var accept: Boolean);
   procedure blueonsetvalue(const sender: TObject; var avalue: realty; var accept: Boolean);
   procedure rgbchange(const sender: TObject);
   procedure filldefcolor(const sender: TObject);
   procedure usethiscolor(const sender: TObject);
   procedure changecolorbefore(const sender: TObject);
  private
   fupdating: boolean;
 end;
 
 tthemesedit = class(tmsecomponent,istatfile)
  private
   fstatfile: tstatfile;
   fstatvarname: msestring;
   procedure setstatfile(const Value: tstatfile);
  protected
   procedure statdataread; virtual;
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;

   procedure readstatvalue(const reader: tstatreader); virtual;
   procedure readstatstate(const reader: tstatreader); virtual;
   procedure readstatoptions(const reader: tstatreader); virtual;
   procedure writestatvalue(const writer: tstatwriter); virtual;
   procedure writestatstate(const writer: tstatwriter); virtual;
   procedure writestatoptions(const writer: tstatwriter); virtual;
   
  public
   constructor create(aowner: tcomponent); override;
   procedure showdialog;
   fdefcolor: msestringarty;
  published
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
 end;

implementation
uses
 msethemesdialog_mfm,msestockobjects;
const
 valuevarname = 'color';
 
{ tthemesedit }

constructor tthemesedit.create(aowner: tcomponent);
begin
 inherited;
end;

procedure tthemesedit.statdataread;
begin
 //dummy
end;

procedure tthemesedit.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

procedure tthemesedit.dostatread(const reader: tstatreader);
begin
  readstatvalue(reader);
  readstatstate(reader);
  readstatoptions(reader);
end;

procedure tthemesedit.dostatwrite(const writer: tstatwriter);
begin
  writestatvalue(writer);
  writestatstate(writer);
  writestatoptions(writer);
end;

procedure tthemesedit.statreading;
begin
 //dummy
end;

procedure tthemesedit.statread;
begin
 //dummy
end;

procedure tthemesedit.readstatoptions(const reader: tstatreader);
begin
 //dummy
end;

procedure tthemesedit.readstatstate(const reader: tstatreader);
begin
 //dummy
end;

procedure tthemesedit.readstatvalue(const reader: tstatreader);
var
 ar1: msestringarty;
 int1: integer;
 defcolorar: msestringarty;
 anewcolor: msestringarty;
begin
 ar1:= nil;
 ar1:= reader.readarray(valuevarname+'ar',ar1);
 fdefcolor:= ar1;
 if high(fdefcolor)>0 then begin
  for int1:=0 to high(fdefcolor) do begin
   anewcolor:= nil;
   setlength(anewcolor,2);
   splitstring(fdefcolor[int1],anewcolor,'=',true);
   setcolormapvalue(stringtocolor(anewcolor[0]),stringtocolor(anewcolor[1]));
   //setcolormapvalue(anewcolor[0],stringtocolor(anewcolor[1]));
  end;
 end;
 application.invalidate;
end;

procedure tthemesedit.writestatoptions(const writer: tstatwriter);
begin
 //dummy
end;

procedure tthemesedit.writestatstate(const writer: tstatwriter);
begin
 //dummy
end;

procedure tthemesedit.writestatvalue(const writer: tstatwriter);
var
 ar1: msestringarty;
begin
 ar1:= fdefcolor;
 writer.writearray(valuevarname+'ar',ar1);
end;

function tthemesedit.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tthemesedit.showdialog;
var
 fo: tthemesdialogfo;
 result: modalresultty;
 int1: integer;
begin
 fo:= tthemesdialogfo.create(nil);
 try
  result:= fo.show(true);
  if result = mr_ok then begin
   fdefcolor := nil;
   setlength(fdefcolor,fo.defcolorlist.dropdown.valuelist.count);
   for int1:=0 to fo.defcolorlist.dropdown.valuelist.count-1 do begin
    fdefcolor[int1]:= fo.defcolorlist.dropdown.valuelist.items[int1] + '=' + colortostring(fo.defcolorlist.enums[int1]);
    setcolormapvalue(stringtocolor(fo.defcolorlist.dropdown.valuelist.items[int1]),fo.defcolorlist.enums[int1]);
    //setcolormapvalue(fo.defcolorlist.dropdown.valuelist.items[int1],fo.defcolorlist.enums[int1]);
   end;
   application.invalidate;
  end;
 finally
  fo.free;
 end;
end;

{ tthemesdialogfo }

procedure tthemesdialogfo.hueonsetvalue(const sender: TObject;
                               var avalue: realty; var accept: Boolean);
begin
 hue.value:= round(avalue * 360);
end;

procedure tthemesdialogfo.satonsetvalue(const sender: TObject;
                               var avalue: realty; var accept: Boolean);
begin
 sat.value:= round(avalue * 100);
end;

procedure tthemesdialogfo.brightonsetvalue(const sender: TObject;
                               var avalue: realty; var accept: Boolean);
begin
 bright.value:= round(avalue * 100);
end;

procedure tthemesdialogfo.hsbchange(const sender: TObject);
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

procedure tthemesdialogfo.blueonsetvalue(const sender: TObject;
                 var avalue: realty; var accept: Boolean);
begin
 blue.value:= round(avalue * 255);
end;

procedure tthemesdialogfo.greenonsetvalue(const sender: TObject;
                var avalue: realty; var accept: Boolean);
begin
 green.value:= round(avalue * 255);
end;

procedure tthemesdialogfo.redonsetvalue(const sender: TObject;
               var avalue: realty; var accept: Boolean);
begin
 red.value:= round(avalue * 255);
end;

procedure tthemesdialogfo.rgbchange(const sender: TObject);

type
 colorsegmentty = (cs_red,cs_green,cs_blue);
var
 min,max: integer;
 br,sa,hu: real;
 segment: colorsegmentty;

 function calchue(l,c,r: integer): real;
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

procedure tthemesdialogfo.filldefcolor(const sender: TObject);
begin
 defcolorlist.dropdown.valuelist.asarray:= getcolornames;
 defcolorlist.enums:= integerarty(getcolorvalues);
 defcolorlist.min:= minint;
 //defcolorlist.base:= nb_hex;
 defcolorlist.valuedefault:= cl_background;
 defcolorlist.value:= defcolorlist.valuedefault;
end;

procedure tthemesdialogfo.usethiscolor(const sender: TObject);
begin
 defcolorlist.enums[defcolorlist.dropdown.itemindex]:= colorarea.frame.colorclient;
end;

procedure tthemesdialogfo.changecolorbefore(const sender: TObject);
var
 int1: integer;
begin
 colorareabefore.frame.colorclient:= defcolorlist.enums[defcolorlist.dropdown.itemindex]; 
 colorarea.frame.colorclient:= defcolorlist.enums[defcolorlist.dropdown.itemindex]; 
 red.value:= colortorgb(defcolorlist.enums[defcolorlist.dropdown.itemindex]).red; 
 green.value:= colortorgb(defcolorlist.enums[defcolorlist.dropdown.itemindex]).green; 
 blue.value:= colortorgb(defcolorlist.enums[defcolorlist.dropdown.itemindex]).blue; 
end;
end.
