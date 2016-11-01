{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
//
// under construction
//
unit mserepps;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,msereport,msestrings,msepostscriptprinter,msegraphics,mclasses,
 msegraphutils;
type
 optionpsty = (ops_noheadercomments,ops_noshowpage);
 optionspsty = set of optionpsty;
const
 defaultoptionsps = [ops_noheadercomments,ops_noshowpage];
 psalignments = [al_left,al_xcentered,al_right,al_top,al_ycentered,al_bottom,
                 al_stretchx,al_stretchy,al_fit];
 
type 
 treppsdisp = class(tcustomrepvaluedisp)
  private
   fpsfile: filenamety;
   foptionsps: optionspsty;
   falignment: alignmentsty;
   procedure setalignment(const avalue: alignmentsty);
  protected
   procedure render(const acanvas: tcanvas; var empty: boolean) override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property psfile: filenamety read fpsfile write fpsfile;
   property optionsps: optionspsty read foptionsps write foptionsps
                                                 default defaultoptionsps;
   property alignment: alignmentsty read falignment 
                                    write setalignment default [];
//   property value: msestring read fvalue write setvalue;
   property font;
//   property tabs;
//   property datasource;
   property textflags;
   property options;
   property optionsshow;
   property optionsscale;
   property visidatasource;
   property visidatafield;
   property visigroupfield;
   property zebra_color;
   property zebra_start;
   property zebra_height;
   property zebra_step;
   property zebra_options;
   property onfontheightdelta;
   property onlayout;

   property onbeforerender;
   property onbeforepaint;
   property onpaint;
   property onafterpaint;
   property onafterrender;
   property ongettext;
 end;
 
implementation
uses
 msestream,msesys,mseformatstr;
 
{ treppsdisp }

constructor treppsdisp.create(aowner: tcomponent);
begin
 foptionsps:= defaultoptionsps;
 inherited;
end;

procedure treppsdisp.setalignment(const avalue: alignmentsty);
begin
 movealignment(avalue * psalignments,falignment);
end;

procedure treppsdisp.render(const acanvas: tcanvas; var empty: boolean);
const
 nl = lineend;
var
 stream1: ttextstream;
 as1: ansistring;
 b1,b2,inheader,hasbb: boolean;
 ar1: stringarty;
 bb1: rectty;
begin
 inherited;
 if (fpsfile <> '') and (acanvas is tpostscriptcanvas) then begin
  stream1:= ttextstream.create(fpsfile,fm_read);
  try
   with tpostscriptcanvas(acanvas) do begin
    pscommandbegin();
    inheader:= true;
    hasbb:= false;
    repeat
     b1:= stream1.readstrln(as1);
     b2:= (length(as1) >= 2) and (as1[1] = '%') and 
                                ((as1[2] = '%') or (as1[2] = '!'));
     if inheader then begin
      if b2 then begin
       if startsstr(pchar('BoundingBox:'),pchar(pointer(as1))+2) then begin
        ar1:= splitstring(as1,' ',true);
        if high(ar1) >= 4 then begin
         if trystrtoint(ar1[1],bb1.x) and trystrtoint(ar1[2],bb1.y) and
            trystrtoint(ar1[3],bb1.cx) and trystrtoint(ar1[4],bb1.cy) then begin
          hasbb:= true;
         end;
        end;
       end;
       if (ops_noheadercomments in foptionsps) then begin
        continue; //skip headercomment
       end;
      end
      else begin
       inheader:= false;
       pscommandwrite('gsave'+nl);
       if ops_noshowpage in foptionsps then begin
        pscommandwrite('/showpage_orig /showpage load def'+nl);
        pscommandwrite('/showpage {} bind def'+nl);
                                    //disable showpage command
        if hasbb then begin
        end;
       end;
      end;
     end
     else begin
      if b2 and (ops_noheadercomments in foptionsps) then begin
       continue;
      end;
     end;
     pscommandwrite(as1+c_return+c_linefeed);
    until not b1;
    if (ops_noshowpage in foptionsps) and not inheader then begin
     pscommandwrite('/showpage /showpage_orig load def'+nl);
                                         //restore showpage command
    end;
    pscommandwrite('grestore'+nl);
    pscommandend();
   end;
  finally
   stream1.destroy();
  end;
 end
 else begin
  empty:= true;
 end;
end;

end.
