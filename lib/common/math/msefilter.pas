{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

//
//experimental
//

unit msefilter;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseclasses,msedatalist,classes,msetypes,msesignal,msearrayprops,msereal,
 msegui;
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

 tdoubleconnection = class(tmsecomponent) 
        //no solution fond to link to streamed tpersistent or tobject,
        //fork of classes.pp necessary. :-(
  protected
//   fowner: tcomponent;
  public
   constructor create(aowner: tcomponent); override;
 end;
 tdoubleoutput = class(tdoubleconnection)
  protected
//   procedure updatesig(var adata: doublearty);
  public
   constructor create(aowner: tcomponent); override;
 end; 

 tdoubleinput = class(tdoubleconnection)
  private
   fsource: tdoubleoutput;
ftestvar: twidget;
   procedure setsource(const avalue: tdoubleoutput);
//   procedure readsource(reader: treader);
//   procedure writesource(writer: twriter);
  protected
//   procedure updatesig(var adata: doublearty);
//   procedure defineproperties(filer: tfiler); override;
  published
   property source: tdoubleoutput read fsource write setsource;
   property testvar: twidget read ftestvar write ftestvar;
 end;
 {
 tconnections = class(tmsecomponentarrayprop)
 end;
 tinputs = class(tconnections)
 end;
 toutputs = class(tconnections)
 end;
 
 tdoublesingleinputs = class(tinputs)  
  public
   constructor create; reintroduce;
 end;
 tdoublesingleoutputs = class(toutputs)
  public
   constructor create; reintroduce;
 end;
 }
 tdoublesignalcomp = class(tsignalcomp)
  private
//   procedure setinputs(const avalue: tinputs);
//   procedure setoutputs(const avalue: toutputs);
  protected
//   finputs: tinputs;
//   foutputs: toutputs;
//   procedure createinputs; virtual; abstract;
//   procedure createoutputs; virtual; abstract;
//   property inputs: tinputs read finputs write setinputs;
//   property outputs: toutputs read foutputs write setoutputs;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear; virtual;
  published
 end;
 
 tdoublezcomp = class(tdoublesignalcomp) //single input, single output
  private
   fzcount: integer;
   fzhigh: integer;
   fdoublez: doublearty;
   fzindex: integer;
   finputindex: integer;
   fdoubleinputdata: doubleararty;
   procedure setzcount(const avalue: integer);
   procedure setinput(const avalue: tdoubleinput);
   procedure setoutput(const avalue: tdoubleoutput);
  protected
   finput: tdoubleinput;
   foutput: tdoubleoutput;
   procedure processinout(const acount: integer;
                    var ainp,aoutp: pdouble); virtual; abstract;
   procedure zcountchanged; virtual;
//   procedure createinputs; override;
//   procedure createoutputs; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear; override;
   procedure writesig(const adata: doublearty);
   procedure readsig1(var adata: doublearty);
   function readsig: doublearty;
   procedure updatesig(var inout: doublearty);
   property zcount: integer read fzcount default 0;
  published
   property input: tdoubleinput read finput write setinput;
   property output: tdoubleoutput read foutput write setoutput;
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
 tfirfilter = class(tdoublefiltercomp)
  private
   function getcoeff: trealcoeff;
   procedure setcoeff(const avalue: trealcoeff);
  protected
   procedure createcoeff; override;
   procedure processinout(const acount: integer;
                    var ainp,aoutp: pdouble); override;
  published
   property coeff: trealcoeff read getcoeff write setcoeff;
 end;
//     +---------+---------+---------+--->
//     |       -a1       -a2       -aN-1
//     +---(z)<--+---(z)<--+---(z)<--+
//     b0       b1        b2        bN-1
// >---+---------+---------+---------+
//
 tiirfilter = class(tdoublefiltercomp)
  private
   function getcoeff: tcomplexcoeff;
   procedure setcoeff(const avalue: tcomplexcoeff);
  protected
   procedure createcoeff; override;
   procedure processinout(const acount: integer;
                    var ainp,aoutp: pdouble); override;
  published
   property coeff: tcomplexcoeff read getcoeff write setcoeff;
 end;
 
implementation
uses
 sysutils;

procedure createbuffer(var abuffer: doublearty; const asize: integer);
begin
 if (length(abuffer) < asize) or 
         (psizeint(pchar(pointer(abuffer))-2*sizeof(sizeint))^ > 1) then begin
  abuffer:= nil;
  allocuninitedarray(asize,sizeof(double),abuffer);
 end
 else begin
  setlength(abuffer,asize);
 end;
end;
(*
{ tdoublesingleinputs }

constructor tdoublesingleinputs.create;
begin
 inherited create(tdoubleinput);
 count:= 1;
end;

{ tdoublesingleoutputs }

constructor tdoublesingleoutputs.create;
begin
 inherited create(tdoubleoutput);
 count:= 1;
end;
*)
{ tdoublesignalcomp }

constructor tdoublesignalcomp.create(aowner: tcomponent);
begin
// createinputs;
// createoutputs;
 inherited;
end;
 
destructor tdoublesignalcomp.destroy;
begin
 clear;
 inherited;
// finputs.free;
// foutputs.free;
end;
{
procedure tdoublesignalcomp.setinputs(const avalue: tinputs);
begin
 finputs.assign(avalue);
end;

procedure tdoublesignalcomp.setoutputs(const avalue: toutputs);
begin
 foutputs.assign(avalue);
end;
}
procedure tdoublesignalcomp.clear;
begin
 //dummy
end;

{ tdoublezcomp }

constructor tdoublezcomp.create(aowner: tcomponent);
begin
 fzhigh:= -1;
 finput:= tdoubleinput.create(self);
 finput.name:= 'input';
 foutput:= tdoubleoutput.create(self);
 foutput.name:= 'output';
 inherited;
end;

destructor tdoublezcomp.destroy;
begin
 inherited;
// finput.free;
// foutput.free;
end;

procedure tdoublezcomp.zcountchanged;
begin
 //dummy
end;

procedure tdoublezcomp.clear;
begin
 inherited;
 fdoubleinputdata:= nil;
 finputindex:= 0;
 fillchar(pointer(fdoublez)^,fzcount*sizeof(double),0);
 fzindex:= 0; 
end;

procedure tdoublezcomp.writesig(const adata: doublearty);
begin
 if finputindex > high(fdoubleinputdata) then begin
  setlength(fdoubleinputdata,finputindex+1);
 end;
 fdoubleinputdata[finputindex]:= adata;
 inc(finputindex);
end;

procedure tdoublezcomp.updatesig(var inout: doublearty);
var
 po1,po2: pdouble;
begin
 po1:= pointer(inout);
 po2:= po1;
 processinout(length(inout),po1,po2);
end;

procedure tdoublezcomp.readsig1(var adata: doublearty);
var
 int1,int3: integer;
 po1,po2: pdouble;
begin
 int3:= 0;
 for int1:= 0 to finputindex-1 do begin
  int3:= int3 + high(fdoubleinputdata[int1]);
 end;
 int3:= int3 + finputindex;
 createbuffer(adata,int3);
 po2:= pointer(adata);
 for int1:= 0 to finputindex-1 do begin
  po1:= pointer(fdoubleinputdata[int1]);
  processinout(length(fdoubleinputdata[int1]),po1,po2);
 end;  
 for int1:= 0 to finputindex-1 do begin
  fdoubleinputdata[int1]:= nil;
 end;
 finputindex:= 0;
end;

function tdoublezcomp.readsig: doublearty;
begin
 readsig1(result);
end;

procedure tdoublezcomp.setzcount(const avalue: integer);
begin
 if fzcount <> avalue then begin
  if avalue < 0 then begin
   raise exception.create('Invalid coeffcount.');
  end;
  clear;
  fzcount:= avalue;
  fzhigh:= avalue - 1;
  setlength(fdoublez,avalue);
  zcountchanged;
 end;
end;

procedure tdoublezcomp.setinput(const avalue: tdoubleinput);
begin
 finput.assign(avalue);
end;

procedure tdoublezcomp.setoutput(const avalue: tdoubleoutput);
begin
 finput.assign(avalue);
end;
{
procedure tdoublezcomp.createinputs;
begin
 if finputs = nil then begin
  finputs:= tdoublesingleinputs.create;
  finput:= tdoubleinput(finputs.fitems[0]);
 end;
end;

procedure tdoublezcomp.createoutputs;
begin
 if foutputs = nil then begin
  foutputs:= tdoublesingleoutputs.create;
  foutput:= tdoubleoutput(foutputs.fitems[0]);
 end;
end;
}
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

{ tfirfilter }

procedure tfirfilter.createcoeff;
begin
 fcoeff:= trealcoeff.create(self);
 trealcoeff(fcoeff).defaultzero:= true;
 trealcoeff(fcoeff).min:= -bigreal;
end;

function tfirfilter.getcoeff: trealcoeff;
begin
 result:= trealcoeff(fcoeff);
end;

procedure tfirfilter.setcoeff(const avalue: trealcoeff);
begin
 inherited setcoeff(avalue);
end;

procedure tfirfilter .processinout(const acount: integer; var ainp, aoutp: pdouble);
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

{ tiirfilter }

procedure tiirfilter.createcoeff;
begin
 fcoeff:= tcomplexcoeff.create(self);
 tcomplexcoeff(fcoeff).defaultzero:= true;
 tcomplexcoeff(fcoeff).min:= -bigreal;
end;

function tiirfilter.getcoeff: tcomplexcoeff;
begin
 result:= tcomplexcoeff(fcoeff);
end;

procedure tiirfilter.setcoeff(const avalue: tcomplexcoeff);
begin
 inherited setcoeff(avalue);
end;

procedure tiirfilter.processinout(const acount: integer; var ainp: pdouble;
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
//   inc(po1);
//   fdoublez[fcoeffhigh-1]:=             i*po1^.im - o*po1^.re;
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

{ tdoublconnection }

constructor tdoubleconnection.create(aowner: tcomponent);
begin
// fowner:= aowner;
// inherited create(nil);
 inherited;
 setsubcomponent(true);
end;

{ tdoubleoutput }

constructor tdoubleoutput.create(aowner: tcomponent);
begin
 inherited;
 include (fmsecomponentstate,cs_subcompref);
end;

{ tdoubleinput }

procedure tdoubleinput.setsource(const avalue: tdoubleoutput);
begin
 setlinkedvar(avalue,fsource);
end;
(*
procedure tdoubleinput.writesource(writer: twriter);
begin
 writer.writeident('fir.output');
end;

procedure tdoubleinput.defineproperties(filer: tfiler);
begin
 filer.defineproperty('source',nil,{$ifdef FPC}@{$endif}writesource,
                                                             fsource <> nil);
end;
*)

end.
