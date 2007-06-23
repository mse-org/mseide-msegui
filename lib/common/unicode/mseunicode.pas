unit mseunicode;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msestrings,msegraphics,msegraphutils,mseguiglob;
 
type
 
 tunifont = class(tfont)
  public
   constructor create; override;
   function hasglyph(const achar: unicharty): boolean;
   function createfontwithglyph(const achar: unicharty): tunifont;
                      //nil if none exist
 end;
 unifontarty = array of tunifont;

 tunisubstfont = class(tunifont)
  private
   fbase: tunifont;
  protected
   function getfont(var drawinfo: drawinfoty): boolean; override;
   function gethandle: fontnumty; override;
  public
   constructor create(const base: tunifont; const aglyph: unicharty); reintroduce;
 end;
 
 unitextstatety = (uts_fontmatched);
 unitextstatesty = set of unitextstatety;

 segmentinfoty = record
  charindex: integer; //null based
  fontnum: integer;   //index in ffonts 
 end;
 segmentinfoarty = array of segmentinfoty;
  
 tunitext = class
  private
   ffont: tunifont;
   ftext: msestring;
   fstate: unitextstatesty;
   ffonts: unifontarty;
   fsegments: segmentinfoarty;
   procedure setfont(const avalue: tunifont);
   procedure settext(const avalue: msestring);
   procedure freefonts;
  protected
   procedure fontchanged(const sender: tobject);
   procedure changed;
   procedure checkstate;
   procedure matchfonts;
  public
   constructor create(const atext: msestring = ''; const afont: tfont = nil);
             //afont = nil -> stf_unicode
   destructor destroy; override;
   procedure drawstring(const acanvas: tcanvas; const apos: pointty;
                         const grayed: boolean = false);
   property font: tunifont read ffont write setfont;
   property text: msestring read ftext write settext;
 end;

procedure unidrawstring(const acanvas: tcanvas; const atext: msestring; 
                        const apos: pointty;
                        const afont: tfont = nil; const grayed: boolean = false);
implementation
uses
 mseuniintf,sysutils;
 
procedure unidrawstring(const acanvas: tcanvas; const atext: msestring; 
                        const apos: pointty;
                        const afont: tfont = nil; const grayed: boolean = false);
var
 unitext1: tunitext;
begin
 unitext1:= tunitext.create(atext,afont);
 try
  unitext1.drawstring(acanvas,apos,grayed);
 finally
  unitext1.free;
 end;
end;

{ tunifont }

constructor tunifont.create;
begin
 inherited;
 name:= 'stf_unicode';
end;

function tunifont.hasglyph(const achar: unicharty): boolean;
var
 info: drawinfoty;
begin
 with info,fonthasglyph do begin
  try
   font:= getdatapo^.font;
   unichar:= achar;
   gdi_call(gdi_fonthasglyph,info);
   result:= hasglyph;
  except
   result:= false;
  end;
 end;
end;

function tunifont.createfontwithglyph(const achar: unicharty): tunifont;
begin
 result:= tunisubstfont.create(self,achar);
 if not result.hasglyph(achar) then begin
  freeandnil(result);
 end;
end;

{ tunisubstfont }

constructor tunisubstfont.create(const base: tunifont; const aglyph: unicharty);
begin
 finfo.glyph:= aglyph;
 fbase:= base;
 inherited create;
end;

function tunisubstfont.getfont(var drawinfo: drawinfoty): boolean;
begin
 result:= uni_getfontwithglyph(drawinfo);
 if result then begin
  drawinfo.getfont.basefont:= fbase.getdatapo^.font;
 end;
end;

function tunisubstfont.gethandle: fontnumty;
begin
 if fhandlepo^ = 0 then begin
  fhandlepo^:= getfontforglyph(fbase.getdatapo^.font,finfo.glyph);
 end;
 result:= inherited gethandle;
end;

{ tunitext }

constructor tunitext.create(const atext: msestring = ''; const afont: tfont = nil);
begin
 ftext:= atext;
 ffont:= tunifont.create;
 setlength(ffonts,1);
 ffonts[0]:= ffont;
 if afont <> nil then begin
  ffont.assign(afont);
 end;
 ffont.onchange:= {$ifdef FPC}@{$endif}fontchanged;
end;

destructor tunitext.destroy;
begin
 ffont.free;
 freefonts;
 inherited;
end;

procedure tunitext.setfont(const avalue: tunifont);
begin
 ffont.assign(avalue);
end;

procedure tunitext.fontchanged(const sender: tobject);
begin
 changed;
end;

procedure tunitext.changed;
begin
 exclude(fstate,uts_fontmatched);
end;

procedure tunitext.drawstring(const acanvas: tcanvas; const apos: pointty;
                                               const grayed: boolean = false);
var
 int1,int2,int3: integer;
 pt1: pointty;
 po1: pmsechar;
begin
 checkstate;
 pt1:= apos;
 po1:= pmsechar(ftext);
 for int1:= 0 to high(fsegments) do begin
  with fsegments[int1] do begin
   if int1 < high(fsegments) then begin
    int2:= fsegments[int1+1].charindex - charindex;
    int3:= acanvas.getstringwidth(po1,int2,ffonts[fontnum]);
   end
   else begin
    int2:= length(ftext) - charindex; //rest
    int3:= 0;                         //compiler warning
   end;
   acanvas.drawstring(po1,int2,pt1,ffonts[fontnum]);
   inc(pt1.x,int3);
   inc(po1,int2);
  end;
 end;
end;

procedure tunitext.checkstate;
begin
 if not (uts_fontmatched in fstate) then begin
  matchfonts;
 end;
end;

procedure tunitext.matchfonts;
var
 int1: integer;
 fontnum1: integer;
 first: boolean;
 
 procedure addsegment;
 begin
  if not first then begin
   setlength(fsegments,high(fsegments)+2);
  end;
  with fsegments[high(fsegments)] do begin
   charindex:= int1 - 1;
   fontnum:= fontnum1;   
  end;
 end;
 
var
 int2: integer; 
 fontnum2: integer;
 unich1: unicharty;
 font1: tunifont;
 
begin
 fontnum1:= 0;
 int1:= 1;
 fsegments:= nil;
 first:= false;
 addsegment;
 first:= true;
 while int1 <= length(ftext) do begin
  unich1:= word(ftext[int1]);
  fontnum2:= -1;
  for int2:= 0 to high(ffonts) do begin
   if ffonts[int2].hasglyph(unich1) then begin
    fontnum2:= int2;
    break;
   end;
  end;
  if fontnum2 < 0 then begin
   font1:= ffont.createfontwithglyph(unich1);
   if font1 <> nil then begin
    setlength(ffonts,high(ffonts)+2);
    fontnum2:= high(ffonts);
    ffonts[fontnum2]:= font1;
   end
   else begin
    fontnum2:= 0; //no font with glyph found
   end;
  end;
  if fontnum2 <> fontnum1 then begin
   fontnum1:= fontnum2;
   addsegment;
  end;
  first:= false;
  inc(int1);
 end;
 include(fstate,uts_fontmatched);
end;

procedure tunitext.settext(const avalue: msestring);
begin
 ftext:= avalue;
 changed;
end;

procedure tunitext.freefonts;
var
 int1: integer;
begin
 for int1:= 1 to high(ffonts) do begin
  ffonts[int1].free;
 end;
 setlength(ffonts,1);
end;

end.
