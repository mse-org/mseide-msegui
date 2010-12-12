{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

//
// experimental
//

unit msefilter;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseclasses,msedatalist,classes,msetypes,msesignal,msearrayprops,msereal;
type

 tdoublefiltercomp = class;
 
 tsections = class(tintegerarrayprop)
  protected
   fowner: tdoublefiltercomp;
   function calccoeffcount: integer;
   procedure dochange(const aindex: integer); override;
   procedure updatecoeffcount;
  public
   constructor create(const aowner: tdoublefiltercomp);
 end;

 tdoublefiltercomp = class(tdoublezcomp)
  private
   fsections: tsections;
   procedure setcoeff(const avalue: tdatalist);
   procedure setsections(const avalue: tsections);
  protected
   fcoeff: tdatalist;
   procedure coeffchanged(const sender: tdatalist;
                                 const aindex: integer); override;
   procedure createcoeff; virtual; abstract;
   procedure zcountchanged; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property sections: tsections read fsections write setsections;
            //array of coeffcount
 end;
 
// >---+-->(z)---+-->(z)---+-->(z)---+
//     b0       b1        b2        bN-1
//     +---------+---------+---------+--->
//
 tsigfir = class(tdoublefiltercomp)
  private
   function getcoeff: trealcoeff;
   procedure setcoeff(const avalue: trealcoeff);
  protected
   procedure createcoeff; override;
//   procedure processinout(const acount: integer;
//                    var ainp,aoutp: pdouble); override;
   function getzcount: integer; override;
    //isigclient
   function gethandler: sighandlerprocty; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
  published
   property coeff: trealcoeff read getcoeff write setcoeff;
 end;
//     +---------+---------+---------+--->
//     |       -a1       -a2       -aN-1
//     +---(z)<--+---(z)<--+---(z)<--+
//     b0       b1        b2        bN-1
// >---+---------+---------+---------+
//
 tsigiir = class(tdoublefiltercomp)
  private
   function getcoeff: tcomplexcoeff;
   procedure setcoeff(const avalue: tcomplexcoeff);
  protected
   procedure createcoeff; override;
//   procedure processinout(const acount: integer;
//                    var ainp,aoutp: pdouble); override;
   function getzcount: integer; override;
    //isigclient
   function gethandler: sighandlerprocty; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
  published
   property coeff: tcomplexcoeff read getcoeff write setcoeff;
 end;

 sigfilterkindty = (sfk_lp1bilinear,sfk_lp1impulseinvariant,
                    sfk_lp2bilinear,sfk_bp2bilinear);
 
 tsigfilter = class(tdoublesiginoutcomp) //todo: prewarp
  private
   finppo: pdouble;
   fcutofffrequpo: pdouble;
   fcutofffrequ: tdoubleinputconn;
   fqfactorpo: pdouble;
   fz1: double;
   fz2: double;
   fb0: double;
   fb1: double;
   fb2: double;
   fa1: double;
   fa2: double;
   fcutoffbefore: double;
   fqfactorbefore: double;
   fqfactor: tdoubleinputconn;
   fkind: sigfilterkindty;
   procedure setcutofffrequ(const avalue: tdoubleinputconn);
   procedure setqfactor(const avalue: tdoubleinputconn);
   procedure setkind(const avalue: sigfilterkindty);
  protected
   procedure sighandlerlp1inv(const ainfo: psighandlerinfoty);
   procedure sighandlerlp1bi(const ainfo: psighandlerinfoty);
   procedure sighandlerlp2bi(const ainfo: psighandlerinfoty);
   procedure sighandlerbp2bi(const ainfo: psighandlerinfoty);
   
    //isigclient
   function getinputar: inputconnarty; override;
   function gethandler: sighandlerprocty; override;
   procedure clear; override;
   procedure initmodel; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property cutofffrequ: tdoubleinputconn read fcutofffrequ 
                                                 write setcutofffrequ;   
   property qfactor: tdoubleinputconn read fqfactor 
                                                 write setqfactor;   
   property kind: sigfilterkindty read fkind write setkind 
                                                 default sfk_lp1bilinear;
 end;
 
implementation
uses
 sysutils;
type
 tdoubleinputconn1 = class(tdoubleinputconn);

{ tdoublefiltercomp }

constructor tdoublefiltercomp.create(aowner: tcomponent);
begin
 fsections:= tsections.create(self);
 createcoeff;
 inherited; 
end;

destructor tdoublefiltercomp.destroy;
begin
 inherited;
 fcoeff.free;
 fsections.free;
end;

procedure tdoublefiltercomp.zcountchanged;
begin
 inherited;
 fcoeff.count:= fzcount;
end;

procedure tdoublefiltercomp.setcoeff(const avalue: tdatalist);
begin
 fcoeff.assign(avalue);
end;

procedure tdoublefiltercomp.coeffchanged(const sender: tdatalist;
               const aindex: integer);
begin
 if aindex < 0 then begin
  setzcount(sender.count);
  fsections.updatecoeffcount;
 end;
end;

procedure tdoublefiltercomp.setsections(const avalue: tsections);
begin
 fsections.assign(avalue);
end;

{ tsigfir }

procedure tsigfir.createcoeff;
begin
 fcoeff:= trealcoeff.create(self);
 trealcoeff(fcoeff).defaultzero:= true;
 trealcoeff(fcoeff).min:= -bigreal;
end;

function tsigfir.getcoeff: trealcoeff;
begin
 result:= trealcoeff(fcoeff);
end;

procedure tsigfir.setcoeff(const avalue: trealcoeff);
begin
 inherited setcoeff(avalue);
end;
(*
procedure tsigfir.processinout(const acount: integer; var ainp, aoutp: pdouble);
var                             //todo: optimize
 int1,int2,int3: integer;
 ar1: doublearty;
 i,o: double;
 po1: pdouble;
 inp1,outp1: pdouble;
 startindex1,endindex1,endindex2: integer;
begin
 if fzcount > 0 then begin
  inp1:= ainp;
  outp1:= aoutp;
  for int1:= acount-1 downto 0 do begin
   po1:= fcoeff.datapo;
   i:= ainp^;
   startindex1:= fzindex;
   for int3:= 0 to high(fsections.fitems) do begin
    endindex1:= startindex1 + fsections.fitems[int3] - 1;
    if endindex1 > fzhigh then begin
     endindex2:= endindex1-fzhigh-1;
     endindex1:= fzhigh;
    end
    else begin
     endindex2:= -1;
    end;
    
    fdoublez[startindex1]:= i;
    o:= 0;
    for int2:= startindex1 to endindex1 do begin
     o:= o + fdoublez[int2] * po1^;
     inc(po1);
    end;
    for int2:= 0 to endindex2 do begin
     o:= o + fdoublez[int2] * po1^;
     inc(po1);
    end;
    startindex1:= startindex1 + fsections.fitems[int3];
    if startindex1 >= fzcount then begin
     startindex1:= startindex1 - fzcount;
    end;
    i:= o;
   end;
   outp1^:= o;
   dec(fzindex);
   if fzindex < 0 then begin
    fzindex:= fzhigh;
   end;
   inc(outp1);
   inc(inp1);
  end;
  ainp:= inp1;
  aoutp:= outp1;
 end
 else begin
  inc(ainp,acount);
  inc(aoutp,acount);
 end;
end;
*)
function tsigfir.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigfir.sighandler(const ainfo: psighandlerinfoty);
var                             //todo: optimize
 int1,int2,int3: integer;
 ar1: doublearty;
 i,o: double;
 po1: pdouble;
 inp1,outp1: pdouble;
 startindex1,endindex1,endindex2: integer;
begin
 po1:= fcoeff.datapo;
 i:= finput.value;
 startindex1:= fzindex;
 for int3:= 0 to high(fsections.fitems) do begin
  endindex1:= startindex1 + fsections.fitems[int3] - 1;
  if endindex1 > fzhigh then begin
   endindex2:= endindex1-fzhigh-1;
   endindex1:= fzhigh;
  end
  else begin
   endindex2:= -1;
  end;
  
  fdoublez[startindex1]:= i;
  o:= 0;
  for int2:= startindex1 to endindex1 do begin
   o:= o + fdoublez[int2] * po1^;
   inc(po1);
  end;
  for int2:= 0 to endindex2 do begin
   o:= o + fdoublez[int2] * po1^;
   inc(po1);
  end;
  startindex1:= startindex1 + fsections.fitems[int3];
  if startindex1 >= fzcount then begin
   startindex1:= startindex1 - fzcount;
  end;
  i:= o;
 end;
 ainfo^.dest^:= o;
 dec(fzindex);
 if fzindex < 0 then begin
  fzindex:= fzhigh;
 end;
end;

function tsigfir.getzcount: integer;
var
 int1,int2,int3: integer;
begin
 result:= 0;
 int3:= 0;
 for int1:= 0 to fsections.count -1 do begin
  for int2:= 0 to fsections[int1]-1 do begin
   if coeff[int3] = 0 then begin
    inc(result);
    inc(int3);
   end
   else begin
    int3:= int3 + fsections[int1]-int2;
    break;
   end;
  end;
 end;
end;

{ tsigiir }

procedure tsigiir.createcoeff;
begin
 fcoeff:= tcomplexcoeff.create(self);
 tcomplexcoeff(fcoeff).defaultzero:= true;
 tcomplexcoeff(fcoeff).min:= -bigreal;
end;

function tsigiir.getcoeff: tcomplexcoeff;
begin
 result:= tcomplexcoeff(fcoeff);
end;

procedure tsigiir.setcoeff(const avalue: tcomplexcoeff);
begin
 inherited setcoeff(avalue);
end;
(*
procedure tsigiir.processinout(const acount: integer; var ainp: pdouble;
               var aoutp: pdouble);
var 
 int1,int2,int3: integer;
 inp1,outp1: pdouble;
 i,o: double;
 po0: pcomplexty;
 po1: pcomplexty;          //todo: optimize
begin
 if fzcount > 0 then begin
  inp1:= ainp;
  outp1:= aoutp;
  po0:= fcoeff.datapo;
  for int1:= acount-1 downto 0 do begin
   po1:= po0;
   i:= inp1^;
   o:= i*po1^.im+fdoublez[0];
   int3:= 0;
   for int2:= 1 to fzhigh do begin
    inc(po1);
    if int2 = fsections.fitems[int3] then begin
     i:= o;
     o:= i*po1^.im+fdoublez[int2];
    end
    else begin
     fdoublez[int2-1]:= fdoublez[int2] + i*po1^.im - o*po1^.re;
    end;
   end;
   outp1^:= o;
   inc(outp1);
   inc(inp1);
  end;
  ainp:= inp1;
  aoutp:= outp1;
 end
 else begin
  inc(ainp,acount);
  inc(aoutp,acount);
 end;
end;
*)
function tsigiir.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigiir.sighandler(const ainfo: psighandlerinfoty);
var 
 int1,int2,int3,int4: integer;
 inp1,outp1: pdouble;
 i,o: double;
 po1: pcomplexty;          //todo: optimize
begin
 po1:= fcoeff.datapo;
 i:= finput.value;
 o:= i*po1^.im+fdoublez[0];
 int3:= 0;
 int4:= fsections.fitems[0];
 for int2:= 1 to fzhigh do begin
  inc(po1);
  if int2 = int4 then begin //next section
   inc(int3);
   int4:= int4 + fsections.fitems[int3];
   i:= o;
   o:= i*po1^.im+fdoublez[int2];
  end
  else begin
   fdoublez[int2-1]:= fdoublez[int2] + i*po1^.im - o*po1^.re;
  end;
 end;
 ainfo^.dest^:= o;
end;

function tsigiir.getzcount: integer;
var
 int1,int2,int3: integer;
begin
 result:= 0;
 int3:= 0;
 for int1:= 0 to fsections.count -1 do begin
  for int2:= 0 to fsections[int1]-1 do begin
   if coeff[int3].im = 0 then begin
    inc(result);
    inc(int3);
   end
   else begin
    int3:= int3 + fsections[int1]-int2;
    break;
   end;
  end;
 end;
end;

{ tsections }

constructor tsections.create(const aowner: tdoublefiltercomp);
begin
 fowner:= aowner;
 inherited create;
end;

function tsections.calccoeffcount: integer;
var
 int1: integer;
begin
 result:= 0;
 for int1:= 0 to high(fitems) do begin
  result:= result + fitems[int1];
 end;
end;

procedure tsections.dochange(const aindex: integer);
begin
 fowner.setzcount(calccoeffcount);
end;

procedure tsections.updatecoeffcount;
var
 int1: integer;
begin
 if not (csloading in fowner.componentstate) then begin
  int1:= fowner.zcount-calccoeffcount;
  if int1 <> 0 then begin
   beginupdate;
   try
    if int1 > 0 then begin
     if fitems = nil then begin
      setlength(fitems,1);
     end;
     fitems[high(fitems)]:= fitems[high(fitems)] + int1;
    end
    else begin
     while int1 < 0 do begin
      fitems[high(fitems)]:= fitems[high(fitems)] + int1;
      if fitems[high(fitems)] > 0 then begin
       break;
      end;
      int1:= fitems[high(fitems)];
      setlength(fitems,high(fitems));
     end;
    end;
   finally
    endupdate;
   end;
  end;
 end;
end;

{ tsigfilter }

constructor tsigfilter.create(aowner: tcomponent);
begin
 fcutofffrequ:= tdoubleinputconn.create(self,isigclient(self));
 fcutofffrequ.name:= 'cutofffrequ';
 fqfactor:= tdoubleinputconn.create(self,isigclient(self));
 fqfactor.name:= 'qfactor';
 fqfactor.value:= 1;
 inherited;
end;

function tsigfilter.gethandler: sighandlerprocty;
begin
 case fkind of
  sfk_lp1impulseinvariant: begin
   result:= @sighandlerlp1inv;
  end;
  sfk_lp2bilinear: begin
   result:= @sighandlerlp2bi;
  end;
  sfk_bp2bilinear: begin
   result:= @sighandlerbp2bi;
  end;
  else begin //sfk_lp1bilinear
   result:= @sighandlerlp1bi;
  end;
 end;
end;

procedure tsigfilter.sighandlerlp1inv(const ainfo: psighandlerinfoty);
var
 do1: double;
begin
 if fcutofffrequpo^ <> fcutoffbefore then begin
  fcutoffbefore:= fcutofffrequpo^;
  fb0:= 2*pi*fcutoffbefore;
  fa1:= exp(-fb0);
 end;
 do1:= finppo^*fb0 + fz1*fa1;
 ainfo^.dest^:= do1;
 fz1:= do1;
end;

//     +---------+---------+---------+--->
//     |       -a1       -a2       -aN-1
//     +---(z)<--+---(z)<--+---(z)<--+
//     b0       b1        b2        bN-1
// >---+---------+---------+---------+
//

procedure tsigfilter.sighandlerlp1bi(const ainfo: psighandlerinfoty);
var
 do1: double;
begin
 if fcutofffrequpo^ <> fcutoffbefore then begin
  fcutoffbefore:= fcutofffrequpo^;
  do1:= 2*pi*fcutoffbefore;
  fb0:= do1/(do1+2);
  fb1:= fb0;
  fa1:= (do1-2)/(do1+2);
 end;
 do1:= finppo^*fb0 + fz1;
 ainfo^.dest^:= do1;
 fz1:= finppo^*fb1-fa1*do1;
end;

procedure tsigfilter.sighandlerlp2bi(const ainfo: psighandlerinfoty);
var
 QfT_4,fT2_4,den: double;
 i,o: double;
begin
 if (fcutofffrequpo^ <> fcutoffbefore) or 
                     (fqfactorpo^ <> fqfactorbefore) then begin
  fcutoffbefore:= fcutofffrequpo^;
  fqfactorbefore:= fqfactorpo^;
  fT2_4:= fcutoffbefore*2*pi;        // fT
  QfT_4:= 4/(fqfactorbefore*fT2_4);  // 4/(Q*fT)
  fT2_4:= 4/(fT2_4*fT2_4);           // 4/fT^2
  den:= 1 + QfT_4 + fT2_4;           // 1 + 4/(Q*fT) + 4/fT^2
  fb0:= 1/den;
  fb1:= 2*fb0;
  fb2:= fb0;
  fa1:= 2*(1-fT2_4)/den;
  fa2:= (1-QfT_4+fT2_4)/den;
 end;
 i:= finppo^;
 o:= fz1+i*fb0;
 fz1:= fz2-o*fa1+i*fb1;
 fz2:= i*fb2-o*fa2;
 ainfo^.dest^:= o;
end;

procedure tsigfilter.sighandlerbp2bi(const ainfo: psighandlerinfoty);
var
 fT,QfT_4,fT2_4,den: double;
 i,o: double;
begin
 if (fcutofffrequpo^ <> fcutoffbefore) or 
                     (fqfactorpo^ <> fqfactorbefore) then begin
  fcutoffbefore:= fcutofffrequpo^;
  fqfactorbefore:= fqfactorpo^;
  fT:= fcutoffbefore*2*pi;           // fT
  QfT_4:= 4/(fqfactorbefore*fT);     // 4/(Q*fT)
  fT2_4:= 4/(fT*fT);                 // 4/fT^2
  den:= 1 + QfT_4 + fT2_4;           // 1 + 4/(Q*fT) + 4/fT^2
  fb0:= 4/(den*fT*fqfactorbefore);
  fb1:= 0;
  fb2:= -fb0;
  fa1:= 2*(1-fT2_4)/den;
  fa2:= (1-QfT_4+fT2_4)/den;
 end;
 i:= finppo^;
 o:= fz1+i*fb0;
 fz1:= fz2-o*fa1+i*fb1;
 fz2:= i*fb2-o*fa2;
 ainfo^.dest^:= o;
end;

procedure tsigfilter.clear;
begin
 inherited;
 fcutoffbefore:= -1;
 fqfactorbefore:= -1;
end;

procedure tsigfilter.initmodel;
begin
 finppo:= @tdoubleinputconn1(finput).fvalue;
 fcutofffrequpo:= @tdoubleinputconn1(fcutofffrequ).fvalue;
 fqfactorpo:= @tdoubleinputconn1(fqfactor).fvalue;
 inherited;
end;

procedure tsigfilter.setcutofffrequ(const avalue: tdoubleinputconn);
begin
 fcutofffrequ.assign(avalue);
end;

function tsigfilter.getinputar: inputconnarty;
begin
 setlength(result,2);
 result[0]:= fcutofffrequ;
 result[1]:= fqfactor;
 stackarray(pointerarty(inherited getinputar),pointerarty(result));
end;

procedure tsigfilter.setqfactor(const avalue: tdoubleinputconn);
begin
 fqfactor.assign(avalue);
end;

procedure tsigfilter.setkind(const avalue: sigfilterkindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  modelchange;
 end;
end;

end.
