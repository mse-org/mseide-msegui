{ MSEgui Copyright (c) 2016-2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mserepps;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,msereport,msestrings,msepostscriptprinter,msegraphics,mclasses,
 msegraphutils,msegui,msemenus,mseguiglob;
type
 optionpsty = (ops_noheadercomments,ops_noshowpage);
 optionspsty = set of optionpsty;
 layoutflagty = (la_right,la_bottom,la_xcentered,la_ycentered,
                 la_stretchx,la_stretchy,la_fit,
                 la_mirrorx,la_mirrory,la_rotate90,la_rotate180);
 layoutflagsty = set of layoutflagty;
 
const
 defaultoptionsps = [ops_noheadercomments,ops_noshowpage];
 
type
//
//todo: use ps text from datafield
//
 treppsdisp = class(tcustomrecordband)
  private
   fpsfile: filenamety;
   foptionsps: optionspsty;
   flayout: layoutflagsty;
   fscale: flo64;
   fshifthorz: flo64;
   fshiftvert: flo64;
   procedure setlayout(const avalue: layoutflagsty);
  protected
   procedure render(const acanvas: tcanvas; var empty: boolean) override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property anchors default [an_left,an_top];
   property psfile: filenamety read fpsfile write fpsfile;
   property optionsps: optionspsty read foptionsps write foptionsps
                                                 default defaultoptionsps;
   property layout: layoutflagsty read flayout 
                                    write setlayout default [];
   property scale: flo64 read fscale write fscale;
   property shifthorz: flo64 read fshifthorz write fshifthorz; //mm
   property shiftvert: flo64 read fshiftvert write fshiftvert; //mm
//   property value: msestring read fvalue write setvalue;
   property font;
//   property tabs;
//   property datasource;
//   property textflags;
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
//   property ongettext;
 end;
 
implementation
uses
 msestream,msesys,mseformatstr,msebits,mseprinter;
 
{ treppsdisp }

constructor treppsdisp.create(aowner: tcomponent);
begin
 foptionsps:= defaultoptionsps;
 fscale:= 1;
 inherited;
 fanchors:= [an_left,an_top];
end;

procedure treppsdisp.setlayout(const avalue: layoutflagsty);
begin
 flayout:= layoutflagsty(
            setsinglebit(card32(avalue),card32(flayout),
         [card32([la_xcentered,la_right]),card32([la_ycentered,la_bottom]),
          card32([la_fit,la_stretchx]),card32([la_fit,la_stretchy])]
            )
           );
end;

procedure treppsdisp.render(const acanvas: tcanvas; var empty: boolean);
const
 nl = lineend;
var
 stream1: ttextstream;
 as1: ansistring;
 b1,b2,inheader,hasbb: boolean;
 ar1: stringarty;
 bbll,bbur: pspointty;
 destll,destur: pspointty;
 pt1,pt2: pspointty;
 destpos: pointty;
 destsize: sizety;
 mat1,mat2: psmatrixty;
 f1,f2: flo64;
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
         if trystrtodouble(ar1[1],bbll.x,'.') and 
                    trystrtodouble(ar1[2],bbll.y,'.') and
                            trystrtodouble(ar1[3],bbur.x,'.') and 
                                  trystrtodouble(ar1[4],bbur.y,'.') then begin
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
       pscommandwrite('save'+nl);
       if ops_noshowpage in foptionsps then begin
//        pscommandwrite('/showpage_orig /showpage load def'+nl);
        pscommandwrite('/showpage {} bind def'+nl);
                                    //disable showpage command
        mat1:= psunitymatrix;
        if hasbb then begin
         destpos:= addpoint(rootpos,innerclientwidgetpos);
         destsize:= innerclientsize;
         destll:= devpos(mp(destpos.x,destpos.y+destsize.cy));
         destur:= devpos(mp(destpos.x+destsize.cx,destpos.y));
         if la_mirrorx in flayout then begin
          mat1[0,0]:= -1.0;
          bbll.x:= -bbll.x;
          bbur.x:= -bbur.x;
         end;
         if la_mirrory in flayout then begin
          mat1[1,1]:= -1.0;
          bbll.y:= -bbll.y;
          bbur.y:= -bbur.y;
         end;
         f1:= 0;
         if la_rotate90 in flayout then begin
          f1:= f1 + pi/2;
         end;
         if la_rotate180 in flayout then begin
          f1:= f1 + pi;
         end;
         if f1 <> 0.0 then begin
          psrotate(mat1,f1);
          mat2:= psunitymatrix;
          psrotate(mat2,f1);
          bbll:= pstransform(mat2,bbll);
          bbur:= pstransform(mat2,bbur);
         end;
         psnormalizerect(bbll,bbur);
         if la_fit in flayout then begin
          f1:= bbur.x - bbll.x;
          if f1 <> 0 then begin
           f1:= (destur.x-destll.x) / f1;
           f2:= bbur.y - bbll.y;
           if f2 <> 0 then begin
            f2:= (destur.y-destll.y) / f2;
            if f2 < f1 then begin
             f1:= f2;
            end;
            psscale(mat1,f1);
            bbll.x:= bbll.x * f1;
            bbll.y:= bbll.y * f1;
            bbur.x:= bbur.x * f1;
            bbur.y:= bbur.y * f1;
           end;
          end;
         end
         else begin
          if la_stretchx in flayout then begin
           f1:= bbur.x - bbll.x;
           if f1 <> 0 then begin
            f2:= destur.x - destll.x;
            f1:= f2/f1;
            psscalex(mat1,f1);
            bbll.x:= bbll.x * f1;
            bbur.x:= bbur.x * f1;
           end;
          end;
          if la_stretchy in flayout then begin
           f1:= bbur.y - bbll.y;
           if f1 <> 0 then begin
            f2:= destur.y - destll.y;
            f1:= f2/f1;
            psscaley(mat1,f1);
            bbll.y:= bbll.y * f1;
            bbur.y:= bbur.y * f1;
           end;
          end;
         end;
         if la_right in flayout then begin
          pt1.x:= bbur.x;
          pt2.x:= destur.x;
         end
         else begin
          if la_xcentered in flayout then begin
           pt1.x:= (bbll.x + bbur.x) / 2;
           pt2.x:= (destll.x + destur.x) / 2;
          end
          else begin
           pt1.x:= bbll.x;
           pt2.x:= destll.x;
          end;
         end;
         if la_bottom in flayout then begin
          pt1.y:= bbll.y;
          pt2.y:= destll.y;
         end
         else begin
          if la_ycentered in flayout then begin
           pt1.y:= (bbll.y + bbur.y) / 2;
           pt2.y:= (destll.y + destur.y) / 2;
          end
          else begin
           pt1.y:= bbur.y;
           pt2.y:= destur.y;
          end;
         end;
         pstranslate(mat1,psdist(pt1,pt2));
         psscale(mat1,fscale);
         if la_right in flayout then begin
          pt1.x:= destur.x * (1-fscale); //right
         end
         else begin
          if flayout * [la_stretchx,la_xcentered,la_fit] <> [] then begin
           pt1.x:= ((destll.x + destur.x) * (1-fscale)) / 2;
          end
          else begin //left
           pt1.x:= destll.x * (1-fscale);
          end;
         end;
         if flayout * [la_stretchy,la_ycentered,
                                        la_fit,la_bottom] = [] then begin
          pt1.y:= destur.y * (1-fscale); //top
         end
         else begin
          if not (la_bottom in flayout) then begin
           pt1.y:= ((destll.y + destur.y) * (1-fscale)) / 2;
          end
          else begin //bottom
           pt1.y:= destll.y * (fscale - 1);
          end;
         end;
         pt1.x:= pt1.x + mmtoprintscale* fshifthorz;
         pt1.y:= pt1.y + mmtoprintscale* fshiftvert;
        end
        else begin
         psscale(mat1,fscale);
         pt1.x:= mmtoprintscale* fshifthorz;
         pt1.y:= mmtoprintscale* fshiftvert;
        end;
        pstranslate(mat1,pt1);
        pscommandwrite(psrealtostr(destll.x)+' '+psrealtostr(destll.y) + ' '+
                        psrealtostr(destur.x-destll.x)+' '+
                        psrealtostr(destur.y-destll.y)+' rectclip'+nl);
        pscommandwrite(matrixstring(mat1)+' concat'+nl);
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
//    if (ops_noshowpage in foptionsps) and not inheader then begin
//     pscommandwrite('/showpage /showpage_orig load def'+nl);
//                                         //restore showpage command
//    end;
    pscommandwrite('restore'+nl);
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
