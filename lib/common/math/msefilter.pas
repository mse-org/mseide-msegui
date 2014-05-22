{ MSEgui Copyright (c) 2010-2013 by Martin Schreiber

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
 mseclasses,msedatalist,classes,mclasses,msetypes,msesignal,msearrayprops,
 msereal;
type

 tdoublefiltercomp = class;
 
 tsections = class(tintegerarrayprop)
  protected
   fowner: tdoublefiltercomp;
   function calccoeffcount: integer;
   procedure dochange(const aindex: integer); override;
//   procedure updatecoeffcount;
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
   fcoeffchecking: boolean;
   procedure coeffchanged(const sender: tdatalist;
                                 const aindex: integer); override;
   procedure createcoeff; virtual; abstract;
   procedure zcountchanged; override;
   procedure checkcoeffs; virtual;
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
//   function getzcount: integer; override;
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
   fcoeffsetting: boolean;
   forigcoeff: tcomplexdatalist;
   function getcoeff: tcomplexcoeff;
   procedure setcoeff(const avalue: tcomplexcoeff);
   procedure origcoeffchanged(const sender: tobject);
   procedure setorigcoeff(const avalue: tcomplexdatalist);
  protected
   procedure createcoeff; override;
   procedure checkcoeffs; override;
   procedure defineproperties(filer: tfiler); override;
//   procedure processinout(const acount: integer;
//                    var ainp,aoutp: pdouble); override;
//   function getzcount: integer; override;
    //isigclient
   function gethandler: sighandlerprocty; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
   property origcoeff: tcomplexdatalist read forigcoeff write setorigcoeff;
  published
   property coeff: tcomplexcoeff read getcoeff write setcoeff;
 end;

 sigfilterkindty = (sfk_lp1bilinear,sfk_lp1impulseinvariant,
                    sfk_lp2bilinear,sfk_bp2bilinear,sfk_bs2bilinear);
 sigfilteroptionty = (sfo_passgainfix,sfo_noprewarp);
 sigfilteroptionsty = set of sigfilteroptionty;
 
 tsigfilter = class(tsigmultiinpout) //todo: speed optimized prewarp
  private
   ffrequencypo: psigvaluety;
   ffrequfactpo: psigvaluety;
   fqfactorpo: psigvaluety;
   famplitudepo: psigvaluety;
   fgain: double;
   fz1: double;
   fz2: double;
   fb0: double;
   fb1: double;
   fb2: double;
   fa1: double;
   fa2: double;
   ffrequency: tdoubleinputconn;
   fqfactor: tdoubleinputconn;
   fkind: sigfilterkindty;
   foptions: sigfilteroptionsty;
   famplitude: tdoubleinputconn;
   ffrequfact: tdoubleinputconn;
   procedure setfrequency(const avalue: tdoubleinputconn);
   procedure setqfactor(const avalue: tdoubleinputconn);
   procedure setkind(const avalue: sigfilterkindty);
   procedure setoptions(const avalue: sigfilteroptionsty);
   procedure setamplitude(const avalue: tdoubleinputconn);
   procedure setfrequfact(const avalue: tdoubleinputconn);
  protected
   procedure sighandlerlp1inv(const ainfo: psighandlerinfoty);
   procedure sighandlerlp1bi(const ainfo: psighandlerinfoty);
   procedure sighandlerlp2bi(const ainfo: psighandlerinfoty);
   procedure sighandlerb2bi;
   procedure sighandlerbp2bi(const ainfo: psighandlerinfoty);
   procedure sighandlerbs2bi(const ainfo: psighandlerinfoty);
   
    //isigclient
   function getinputar: inputconnarty; override;
   function gethandler: sighandlerprocty; override;
   procedure initmodel; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure clear; override;
  published
   property frequency: tdoubleinputconn read ffrequency 
                                                 write setfrequency;   
   property frequfact: tdoubleinputconn read ffrequfact write setfrequfact;
   property qfactor: tdoubleinputconn read fqfactor 
                                                 write setqfactor;   
   property amplitude: tdoubleinputconn read famplitude 
                                                 write setamplitude;   
   property kind: sigfilterkindty read fkind write setkind 
                                                 default sfk_lp1bilinear;
   property options: sigfilteroptionsty read foptions 
                                             write setoptions default [];
 end;

 tfilterbanksection = class(townedpersistent)
  private
   ffrequfact: tdoubleinputconn;
   fqfactor: tdoubleinputconn;
   famplitude: tdoubleinputconn;
   procedure setfrequfact(const avalue: tdoubleinputconn);
   procedure setqfactor(const avalue: tdoubleinputconn);
   procedure setamplitude(const avalue: tdoubleinputconn);
  public
   constructor create(aowner: tobject); override;
   destructor destroy; override;
  published
   property frequfact: tdoubleinputconn read ffrequfact 
                                                 write setfrequfact;   
   property qfactor: tdoubleinputconn read fqfactor 
                                                 write setqfactor;   
   property amplitude: tdoubleinputconn read famplitude 
                                                 write setamplitude;   
 end;
 
 tfilterbanksections = class(townedpersistentarrayprop)
  private
  protected
   procedure getinputar(var inputs: inputconnarty);
   procedure dosizechanged; override;
  public
   constructor create(const aowner: tcomponent); reintroduce;
   class function getitemclasstype: persistentclassty; override;
               //used in dumpunitgroups
  published
 end;

 filterinfoty = record
  ffrequfactpo: psigvaluety;
  fqfactorpo: psigvaluety;
  famplitudepo: psigvaluety;
  fa1: double;
  fa2: double;
  fb0: double;
  fb1: double;
  fb2: double;
  z1: double;
  z2: double;
 end;
 pfilterinfoty = ^filterinfoty;
 filterinfoarty = array of filterinfoty;
  
 tsigfilterbank = class(tsigmultiinpout) //todo: speed optimized prewarp
  private
   fsections: tfilterbanksections;
   ffrequency: tdoubleinputconn;
   foptions: sigfilteroptionsty;
   finfos: filterinfoarty;
   finfohigh: integer;
   fz1: double;
   fz2: double;
   ffrequencypo: psigvaluety;
   famplitudepo: psigvaluety;
   fbaseamplitudepo: psigvaluety;
   famplitude: tdoubleinputconn;
   fbaseamplitude: tdoubleinputconn;
   procedure setfrequency(const avalue: tdoubleinputconn);
   procedure setoptions(const avalue: sigfilteroptionsty);
   procedure setsections(const avalue: tfilterbanksections);
   procedure setamplitude(const avalue: tdoubleinputconn);
   procedure setbaseamplitude(const avalue: tdoubleinputconn);
  protected
    //isigclient
   procedure initmodel; override;
   function getinputar: inputconnarty; override;
   function gethandler: sighandlerprocty; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear; override;
  published
   property frequency: tdoubleinputconn read ffrequency write setfrequency;
   property amplitude: tdoubleinputconn read famplitude write setamplitude;
   property baseamplitude: tdoubleinputconn read fbaseamplitude 
                                            write setbaseamplitude;
   property options: sigfilteroptionsty read foptions 
                                             write setoptions default [];
   property sections: tfilterbanksections read fsections write setsections;
 end;
 
implementation
uses
 sysutils,math,msearrayutils;
type
 tdoubleinputconn1 = class(tdoubleinputconn);
 tdatalist1 = class(tdatalist);

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
 if not fcoeffchecking and (aindex < 0) then begin
  fcoeffchecking:= true;
  try
   sender.count:= fzcount;
   checkcoeffs;
  finally
   fcoeffchecking:= false;
  end;
//  setzcount(sender.count);
//  fsections.updatecoeffcount;
 end;
end;

procedure tdoublefiltercomp.setsections(const avalue: tsections);
begin
 fsections.assign(avalue);
end;

procedure tdoublefiltercomp.checkcoeffs;
begin
 //dummy
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
 {int1,}int2,int3: integer;
// ar1: doublearty;
 i,o: double;
 po1: pdouble;
// inp1,outp1: pdouble;
 startindex1,endindex1,endindex2: integer;
begin
 po1:= fcoeff.datapo;
 i:= finput.value;
 startindex1:= fzindex; //ringbuffer
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
 foutputpo^:= o;
 dec(fzindex);
 if fzindex < 0 then begin
  fzindex:= fzhigh;
 end;
end;
{
function tsigfir.getzcount: integer;
var
 int1,int2,int3: integer;
begin
 result:= 0;
 int3:= 0;
 for int1:= 0 to fsections.count -1 do begin
  for int2:= 0 to fsections[int1]-1 do begin
   if int3 >= coeff.count then begin
    exit;
   end;
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
}
{ tsigiir }

constructor tsigiir.create(aowner: tcomponent);
begin
 forigcoeff:= tcomplexdatalist.create;
 forigcoeff.onchange:= @origcoeffchanged;
 inherited;
end;

destructor tsigiir.destroy;
begin
 inherited;
 forigcoeff.free;
end;

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

procedure tsigiir.origcoeffchanged(const sender: tobject);
var
 int1,int2: integer;
 norm: double;
 ps,pd: pcomplexty;
begin
 if not fcoeffsetting then begin
  ps:= forigcoeff.datapo;
  pd:= fcoeff.datapo;
  for int1:= 0 to fsections.count-1 do begin
   norm:= ps^.re;
   if norm = 0 then begin
    ps^.re:= 1.0;
    norm:= 1.0;
   end;
   for int2:= 0 to fsections.fitems[int1]-1 do begin
    pd^.re:= ps^.re/norm;
    pd^.im:= ps^.im/norm;
    inc(ps);
    inc(pd);
   end;
  end;
 end;
end;

procedure tsigiir.setorigcoeff(const avalue: tcomplexdatalist);
begin
 forigcoeff.assign(avalue);
end;

procedure tsigiir.defineproperties(filer: tfiler);
begin
 inherited;
 tdatalist1(forigcoeff).defineproperties('origcoeff',filer);
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
 {int1,}int2,int3,int4: integer;
// inp1,outp1: pdouble;
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
 foutputpo^:= o;
end;

procedure tsigiir.checkcoeffs;
var
 int1,int2: integer;
 po1: pcomplexty;
begin
 int2:= 0;
 po1:= fcoeff.datapo;
 for int1:= 0 to fsections.count-1 do begin
  po1[int2].re:= 1.0;
  int2:= int2 + fsections.fitems[int1];
 end;
 if not fcoeffsetting then begin
  fcoeffsetting:= true;
  try
   forigcoeff.assign(fcoeff);
  finally
   fcoeffsetting:= false;
  end;
 end;
end;

{
function tsigiir.getzcount: integer;
var
 int1,int2,int3: integer;
begin
 result:= 0;
 int3:= 0;
 for int1:= 0 to fsections.count -1 do begin
  for int2:= 0 to fsections[int1]-1 do begin
   if int3 >= coeff.count then begin
    exit;
   end;
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
}
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
{
procedure tsections.updatecoeffcount;
var
 int1: integer;
begin
 if not (csloading in fowner.componentstate) then begin
  int1:= fowner.zcount-calccoeffcount;
  if int1 <> 0 then begin
   beginupdate;
   try
    if int1 > 0 then begin            //add
     if fitems = nil then begin
      setlength(fitems,1);
     end;
     fitems[high(fitems)]:= fitems[high(fitems)] + int1;
    end
    else begin
     while int1 < 0 do begin          //remove
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
}
{ tsigfilter }

constructor tsigfilter.create(aowner: tcomponent);
begin
 ffrequency:= tdoubleinputconn.create(self,isigclient(self));
 ffrequency.name:= 'frequeny';
 ffrequency.value:= 0.01;
 ffrequfact:= tdoubleinputconn.create(self,isigclient(self));
 ffrequfact.name:= 'frequfact';
 ffrequfact.value:= 1;
 fqfactor:= tdoubleinputconn.create(self,isigclient(self));
 fqfactor.name:= 'qfactor';
 fqfactor.value:= 1;
 famplitude:= tdoubleinputconn.create(self,isigclient(self));
 famplitude.name:= 'amplitude';
 famplitude.value:= 1;
 inherited;
end;

function tsigfilter.gethandler: sighandlerprocty;
begin
 case fkind of
  sfk_lp1impulseinvariant: begin
   result:= {$ifdef FPC}@{$endif}sighandlerlp1inv;
  end;
  sfk_lp2bilinear: begin
   result:= {$ifdef FPC}@{$endif}sighandlerlp2bi;
  end;
  sfk_bp2bilinear: begin
   result:= {$ifdef FPC}@{$endif}sighandlerbp2bi;
  end;
  sfk_bs2bilinear: begin
   result:= {$ifdef FPC}@{$endif}sighandlerbs2bi;
  end;
  else begin //sfk_lp1bilinear
   result:= {$ifdef FPC}@{$endif}sighandlerlp1bi;
  end;
 end;
end;

//     +---------+---------+---------+---> o
//     |       -a1       -a2       -aN-1
//     +---(z)<--+---(z)<--+---(z)<--+
//     b0       b1        b2        bN-1
// i >---+---------+---------+---------+
//

procedure tsigfilter.sighandlerlp1inv(const ainfo: psighandlerinfoty);
var
 i,o,do1: double;
 int1: integer;
begin
 if (ffrequencypo^.changed <> []) or (ffrequfactpo^.changed <> []) then begin
  exclude(ffrequencypo^.changed,sic_value);
  exclude(ffrequfactpo^.changed,sic_value);
  do1:= ffrequencypo^.value*ffrequfactpo^.value;
  if do1 > 0 then begin
   fb0:= 2*pi*do1;
   fa1:= exp(-fb0);
  end;
 end;
 i:= 0;
 for int1:= 0 to finphigh do begin
  i:= i+finps[int1]^.value;
 end;
 o:= i*fb0 + fz1;
 foutputpo^:= o*famplitudepo^.value;
 fz1:= o*fa1;
end;

procedure tsigfilter.sighandlerlp1bi(const ainfo: psighandlerinfoty);
var
 i,o: double;
 do1: double;
 int1: integer;
begin
 if (ffrequencypo^.changed <> []) or (ffrequfactpo^.changed <> []) then begin
  exclude(ffrequencypo^.changed,sic_value);
  exclude(ffrequfactpo^.changed,sic_value);
  do1:= ffrequencypo^.value*ffrequfactpo^.value;
  if do1 > 0 then begin
   do1:= 2*pi*do1;
   fb0:= do1/(do1+2);
   fb1:= fb0;
   fa1:= (do1-2)/(do1+2);
  end;
 end;
 i:= 0;
 for int1:= 0 to finphigh do begin
  i:= i+finps[int1]^.value;
 end;
 o:= i*fb0 + fz1;
 foutputpo^:= o*famplitudepo^.value;
 fz1:= i*fb1-fa1*o;
end;

procedure tsigfilter.sighandlerlp2bi(const ainfo: psighandlerinfoty);
var
 QfT_4,fT2_4,den: double;
 i,o,do1: double;
 int1: integer;
begin
 if (ffrequencypo^.changed <> []) or (ffrequfactpo^.changed <> []) or
                   (fqfactorpo^.changed <> []) then begin
  exclude(ffrequencypo^.changed,sic_value);
  exclude(ffrequfactpo^.changed,sic_value);
  exclude(fqfactorpo^.changed,sic_value);
  do1:= ffrequencypo^.value*ffrequfactpo^.value;
  if do1 > 0 then begin
//  if (fqfactorpo^ <> fqfactorbefore) or (do1 <> ffrequencybefore) then begin
//   ffrequencybefore:= do1;
//   fqfactorbefore:= fqfactorpo^;
   fT2_4:= do1*2*pi;        // fT
   if not (sfo_noprewarp in foptions) then begin
    fT2_4:= 2*tan(0.5*fT2_4);
   end;
   if sfo_passgainfix in foptions then begin
    fgain:= 1;
   end
   else begin
    fgain:= (1/sqrt(sqrt(2)))/sqrt(fqfactorpo^.value);
   end;
   QfT_4:= 4/(fqfactorpo^.value*fT2_4);  // 4/(Q*fT)
   fT2_4:= 4/(fT2_4*fT2_4);           // 4/fT^2
   den:= 1 + QfT_4 + fT2_4;           // 1 + 4/(Q*fT) + 4/fT^2
   fb0:= fgain/den;
   fb1:= 2*fb0;
   fb2:= fb0;
   fa1:= 2*(1-fT2_4)/den;
   fa2:= (1-QfT_4+fT2_4)/den;
  end;
 end;
 i:= 0;
 for int1:= 0 to finphigh do begin
  i:= i+finps[int1]^.value;
 end;
 o:= fz1+i*fb0;
 fz1:= fz2-o*fa1+i*fb1;
 fz2:= i*fb2-o*fa2;
 foutputpo^:= o*famplitudepo^.value;
end;

procedure tsigfilter.sighandlerb2bi;
var
 fT,QfT_4,fT2_4,den,do1: double;
begin
 if (ffrequencypo^.changed <> []) or (ffrequfactpo^.changed <> []) or
                   (fqfactorpo^.changed <> []) then begin
  exclude(ffrequencypo^.changed,sic_value);
  exclude(ffrequfactpo^.changed,sic_value);
  exclude(fqfactorpo^.changed,sic_value);
  do1:= ffrequencypo^.value*ffrequfactpo^.value;
  if do1 > 0 then begin
// do1:= ffrequencypo^*ffrequfactpo^;
// if do1 > 0 then begin
//  if (fqfactorpo^ <> fqfactorbefore) or (do1 <> ffrequencybefore) then begin
//   ffrequencybefore:= do1;
//   fqfactorbefore:= fqfactorpo^;
   fT:= do1*2*pi;           // fT
   if not (sfo_noprewarp in foptions) then begin
    fT:= 2*tan(0.5*fT);
   end;
   if (sfo_passgainfix in foptions) or (fkind = sfk_bs2bilinear) then begin
    fgain:= 4/(fT*fqfactorpo^.value);
   end
   else begin
    fgain:= 4/(fT*sqrt(fqfactorpo^.value));
   end;
   QfT_4:= 4/(fqfactorpo^.value*fT);     // 4/(Q*fT)
   fT2_4:= 4/(fT*fT);                 // 4/fT^2
   den:= 1 + QfT_4 + fT2_4;           // 1 + 4/(Q*fT) + 4/fT^2
   fb0:= fgain/den;
   fb1:= 0;
   fb2:= -fb0;
   fa1:= 2*(1-fT2_4)/den;
   fa2:= (1-QfT_4+fT2_4)/den;
  end;
 end;
end;

procedure tsigfilter.sighandlerbp2bi(const ainfo: psighandlerinfoty);
var
 i,o: double;
 int1: integer;
begin
 sighandlerb2bi;
 i:= 0;
 for int1:= 0 to finphigh do begin
  i:= i+finps[int1]^.value;
 end;
 o:= fz1+i*fb0;
 fz1:= fz2-o*fa1+i*fb1;
 fz2:= i*fb2-o*fa2;
 foutputpo^:= o*famplitudepo^.value;
end;

procedure tsigfilter.sighandlerbs2bi(const ainfo: psighandlerinfoty);
var
 i,o: double;
 int1: integer;
begin
 sighandlerb2bi;
 i:= 0;
 for int1:= 0 to finphigh do begin
  i:= i+finps[int1]^.value;
 end;
 o:= fz1+i*fb0;
 fz1:= fz2-o*fa1+i*fb1;
 fz2:= i*fb2-o*fa2;
 foutputpo^:= (i-o)*famplitudepo^.value;
end;

procedure tsigfilter.clear;
begin
 inherited;
// ffrequencybefore:= -1;
// fqfactorbefore:= -1;
end;

procedure tsigfilter.initmodel;
begin
// finppo:= @tdoubleinputconn1(finput).fvalue;
 ffrequencypo:= @tdoubleinputconn1(ffrequency).fv;
 ffrequfactpo:= @tdoubleinputconn1(ffrequfact).fv;
 fqfactorpo:= @tdoubleinputconn1(fqfactor).fv;
 famplitudepo:= @tdoubleinputconn1(famplitude).fv;
 inherited;
end;

procedure tsigfilter.setfrequency(const avalue: tdoubleinputconn);
begin
 ffrequency.assign(avalue);
end;

function tsigfilter.getinputar: inputconnarty;
begin
 setlength(result,4);
 result[0]:= ffrequency;
 result[1]:= ffrequfact;
 result[2]:= fqfactor;
 result[3]:= famplitude;
 stackarray(pointerarty(inherited getinputar),pointerarty(result));
end;

procedure tsigfilter.setqfactor(const avalue: tdoubleinputconn);
begin
 fqfactor.assign(avalue);
end;

procedure tsigfilter.setkind(const avalue: sigfilterkindty);
begin
 if fkind <> avalue then begin
  lock;
  fkind:= avalue;
  modelchange;
  unlock;
 end;
end;

procedure tsigfilter.setoptions(const avalue: sigfilteroptionsty);
begin
 if foptions <> avalue then begin
  lock;
  foptions:= avalue;
  modelchange;
  unlock;
 end;
end;

procedure tsigfilter.setamplitude(const avalue: tdoubleinputconn);
begin
 famplitude.assign(avalue);
end;

procedure tsigfilter.setfrequfact(const avalue: tdoubleinputconn);
begin
 ffrequfact.assign(avalue);
end;

{ tfilterbanksection }

constructor tfilterbanksection.create(aowner: tobject);
begin
 inherited;
 ffrequfact:= tdoubleinputconn.create(nil,isigclient(tsigfilterbank(aowner)));
 ffrequfact.name:= 'frequfact';
 ffrequfact.value:= 1;
 fqfactor:= tdoubleinputconn.create(nil,isigclient(tsigfilterbank(aowner)));
 fqfactor.name:= 'qfactor';
 fqfactor.value:= 1;
 famplitude:= tdoubleinputconn.create(nil,isigclient(tsigfilterbank(aowner)));
 famplitude.name:= 'amplitude';
 famplitude.value:= 1;
end;

destructor tfilterbanksection.destroy;
begin
 ffrequfact.free;
 fqfactor.free;
 famplitude.free;
 inherited;
end;

procedure tfilterbanksection.setfrequfact(const avalue: tdoubleinputconn);
begin
 ffrequfact.assign(avalue);
end;

procedure tfilterbanksection.setqfactor(const avalue: tdoubleinputconn);
begin
 fqfactor.assign(avalue);
end;

procedure tfilterbanksection.setamplitude(const avalue: tdoubleinputconn);
begin
 famplitude.assign(avalue);
end;

{ tfilterbanksections }

constructor tfilterbanksections.create(const aowner: tcomponent);
begin
 inherited create(aowner,tfilterbanksection);
end;

procedure tfilterbanksections.getinputar(var inputs: inputconnarty);
var
 int1,int2{,int3}: integer;
begin
 int1:= length(inputs);
 setlength(inputs,int1+count*3);
 for int2:= 0 to count - 1 do begin
  with tfilterbanksection(fitems[int2]) do begin
   inputs[int1]:= ffrequfact;
   inc(int1);
   inputs[int1]:= fqfactor;
   inc(int1);
   inputs[int1]:= famplitude;
   inc(int1);
  end;
 end;
end;

procedure tfilterbanksections.dosizechanged;
begin
 inherited;
 tsigfilterbank(fowner).modelchange;
end;

class function tfilterbanksections.getitemclasstype: persistentclassty;
begin
 result:= tfilterbanksection;
end;

{ tsigfilterbank }

constructor tsigfilterbank.create(aowner: tcomponent);
begin
 fsections:= tfilterbanksections.create(self);
 ffrequency:= tdoubleinputconn.create(nil,isigclient(self));
 ffrequency.name:= 'frequency';
 ffrequency.value:= 0.01;
 famplitude:= tdoubleinputconn.create(nil,isigclient(self));
 famplitude.name:= 'amplitude';
 famplitude.value:= 1;
 fbaseamplitude:= tdoubleinputconn.create(nil,isigclient(self));
 fbaseamplitude.name:= 'baseamplitude';
 fbaseamplitude.value:= 1;
 inherited;
end;

destructor tsigfilterbank.destroy;
begin
 inherited;
 fsections.free;
 ffrequency.free;
 famplitude.free;
 fbaseamplitude.free;
end;

procedure tsigfilterbank.setsections(const avalue: tfilterbanksections);
begin
 fsections.assign(avalue);
end;

procedure tsigfilterbank.setfrequency(const avalue: tdoubleinputconn);
begin
 ffrequency.assign(avalue);
end;

procedure tsigfilterbank.setoptions(const avalue: sigfilteroptionsty);
begin
 if foptions <> avalue then begin
  lock;
  foptions:= avalue;
  modelchange;
  unlock;
 end;
end;

function tsigfilterbank.getinputar: inputconnarty;
begin
 result:= inherited getinputar;
 setlength(result,high(result)+4);
 result[high(result)-2]:= ffrequency;
 result[high(result)-1]:= famplitude;
 result[high(result)]:= fbaseamplitude;
 fsections.getinputar(result);
end;

function tsigfilterbank.gethandler: sighandlerprocty;
begin
  result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigfilterbank.sighandler(const ainfo: psighandlerinfoty);

 procedure setupparams(const asection: pfilterinfoty);
 var
  fT,QfT_4,fT2_4,den,do1,fgain: double;
 begin
  with asection^ do begin
   exclude(ffrequfactpo^.changed,sic_value);
   exclude(fqfactorpo^.changed,sic_value);
   do1:= ffrequencypo^.value*ffrequfactpo^.value;
   if do1 > 0 then begin
    fT:= do1*2*pi;           // fT
    if not (sfo_noprewarp in foptions) then begin
     fT:= 2*tan(0.5*fT);
    end;
//     if (sfo_passgainfix in foptions) or (fkind = sfk_bs2bilinear) then begin
    fgain:= 4/(fT*fqfactorpo^.value);
//     end
//     else begin
//      fgain:= 4/(fT*sqrt(fqfactorpo^.value));
//     end;
    QfT_4:= 4/(fqfactorpo^.value*fT);     // 4/(Q*fT)
    fT2_4:= 4/(fT*fT);                 // 4/fT^2
    den:= 1 + QfT_4 + fT2_4;           // 1 + 4/(Q*fT) + 4/fT^2
    fb0:= fgain/den;
    fb1:= 0;
    fb2:= -fb0;
    fa1:= 2*(1-fT2_4)/den;
    fa2:= (1-QfT_4+fT2_4)/den;
   end;
  end;
 end; //setupparams()

var
 i,o,ot: double;
 int1: integer;
 po1: pfilterinfoty;
begin
 if (ffrequencypo^.changed <> []) then begin
  exclude(ffrequencypo^.changed,sic_value);
  po1:= pointer(finfos);
  for int1:= finfohigh downto 0 do begin
   setupparams(po1);
   inc(po1);
  end;
 end;
 i:= 0;
 for int1:= 0 to finphigh do begin
  i:= i+finps[int1]^.value;
 end;
 ot:= 0;
 po1:= pointer(finfos);
 for int1:= finfohigh downto 0 do begin
  with po1^ do begin
   if (ffrequfactpo^.changed <> []) or (fqfactorpo^.changed <> []) then begin
    setupparams(po1);
   end;
   o:= i*fb0+fz1*fb1+fz2*fb2-z1*fa1-z2*fa2;
   z2:= z1;
   z1:= o;
   ot:= ot+o*famplitudepo^.value;
  end;
  inc(po1);
 end;
 fz2:= fz1;
 fz1:= i;
 foutputpo^:= (i*fbaseamplitudepo^.value+ot)*famplitudepo^.value; 
end;

procedure tsigfilterbank.initmodel;
var
 int1: integer;
begin
 inherited;
 ffrequencypo:= @tdoubleinputconn1(ffrequency).fv;
 famplitudepo:= @tdoubleinputconn1(famplitude).fv;
 fbaseamplitudepo:= @tdoubleinputconn1(fbaseamplitude).fv;
 setlength(finfos,fsections.count);
 finfohigh:= high(finfos);
 for int1:= finfohigh downto 0 do begin
  with finfos[int1],tfilterbanksection(fsections.fitems[int1]) do begin
   ffrequfactpo:= @tdoubleinputconn1(ffrequfact).fv;
   fqfactorpo:= @tdoubleinputconn1(fqfactor).fv;
   famplitudepo:= @tdoubleinputconn1(famplitude).fv;
  end;
 end;
end;

procedure tsigfilterbank.clear;
var
 int1: integer;
begin
 inherited;
 fz1:= 0;
 fz2:= 0;
 for int1:= high(finfos) downto 0 do begin
  with finfos[int1] do begin
   z1:= 0;
   z2:= 0;
  end;
 end;
end;

procedure tsigfilterbank.setamplitude(const avalue: tdoubleinputconn);
begin
 famplitude.assign(avalue);
end;

procedure tsigfilterbank.setbaseamplitude(const avalue: tdoubleinputconn);
begin
 fbaseamplitude.assign(avalue);
end;

end.
