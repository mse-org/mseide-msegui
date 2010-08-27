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
 mseclasses,msedatalist,classes,msetypes,msesignal,msearrayprops,msereal;
type

 tdoublesignalcomp = class;
 
 tsections = class(tintegerarrayprop)
  protected
   fowner: tdoublesignalcomp;
   function calccoeffcount: integer;
   procedure dochange(const aindex: integer); override;
   procedure updatecoeffcount;
  public
   constructor create(const aowner: tdoublesignalcomp);
 end;
 
 tdoublesignalcomp = class(tsignalcomp)
  private
   fdoublez: doublearty;
   fzindex: integer;
   finputindex: integer;
   fdoubleinputdata: doubleararty;
   fcoeffcount: integer;
   fcoeffhigh: integer;
   fsections: tsections;
   procedure setcoeff(const avalue: tdatalist);
   procedure setcoeffcount(const avalue: integer);
   procedure setsections(const avalue: tsections);
  protected
   fcoeff: tdatalist;
   procedure coeffchanged(const sender: tdatalist;
                                 const aindex: integer); override;
   procedure process(const acount: integer;
                    var ainp,aoutp: pdouble); virtual; abstract;
   procedure createcoeff; virtual; abstract;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear;
   procedure input(const adata: doublearty);
   procedure output1(var adata: doublearty);
   function output: doublearty;
   procedure update(var inout: doublearty);
   property coeffcount: integer read fcoeffcount default 0;
  published
   property sections: tsections read fsections write setsections;
            //array of coeffcount
 end;

// >---+-->(z)---+-->(z)---+-->(z)---+
//     b0       b1        b2        bN-1
//     +---------+---------+---------+--->
//
 tfirfilter = class(tdoublesignalcomp)
  private
   function getcoeff: trealcoeff;
   procedure setcoeff(const avalue: trealcoeff);
  protected
   procedure createcoeff; override;
   procedure process(const acount: integer;
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
 tiirfilter = class(tdoublesignalcomp)
  private
   function getcoeff: tcomplexcoeff;
   procedure setcoeff(const avalue: tcomplexcoeff);
  protected
   procedure createcoeff; override;
   procedure process(const acount: integer;
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
 
{ tdoublesignalcomp }

constructor tdoublesignalcomp.create(aowner: tcomponent);
begin
 fsections:= tsections.create(self);
 fcoeffhigh:= -1;
 createcoeff;
 inherited; 
end;

destructor tdoublesignalcomp.destroy;
begin
 clear;
 inherited;
 fcoeff.free;
 fsections.free;
end;

procedure tdoublesignalcomp.setcoeff(const avalue: tdatalist);
begin
 fcoeff.assign(avalue);
end;

procedure tdoublesignalcomp.setcoeffcount(const avalue: integer);
begin
 if fcoeffcount <> avalue then begin
  if avalue < 0 then begin
   raise exception.create('Invalid coeffcount.');
  end;
  clear;
  fcoeffcount:= avalue;
  fcoeffhigh:= avalue - 1;
  fcoeff.count:= avalue;
  setlength(fdoublez,avalue);
 end;
end;

procedure tdoublesignalcomp.clear;
begin
 fdoubleinputdata:= nil;
 finputindex:= 0;
 fillchar(pointer(fdoublez)^,fcoeffcount*sizeof(double),0);
 fzindex:= 0; 
end;

procedure tdoublesignalcomp.input(const adata: doublearty);
begin
 if finputindex > high(fdoubleinputdata) then begin
  setlength(fdoubleinputdata,finputindex+1);
 end;
 fdoubleinputdata[finputindex]:= adata;
 inc(finputindex);
end;

procedure tdoublesignalcomp.update(var inout: doublearty);
var
 po1,po2: pdouble;
begin
 po1:= pointer(inout);
 po2:= po1;
 process(length(inout),po1,po2);
end;

procedure tdoublesignalcomp.output1(var adata: doublearty);
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
  process(length(fdoubleinputdata[int1]),po1,po2);
 end;  
 for int1:= 0 to finputindex-1 do begin
  fdoubleinputdata[int1]:= nil;
 end;
 finputindex:= 0;
end;

function tdoublesignalcomp.output: doublearty;
begin
 output1(result);
end;

procedure tdoublesignalcomp.coeffchanged(const sender: tdatalist;
               const aindex: integer);
begin
 if aindex < 0 then begin
  setcoeffcount(sender.count);
  fsections.updatecoeffcount;
 end;
end;

procedure tdoublesignalcomp.setsections(const avalue: tsections);
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

procedure tfirfilter .process(const acount: integer; var ainp, aoutp: pdouble);
var                             //todo: optimize
 int1,int2,int3: integer;
 ar1: doublearty;
 i,o: double;
 po1: pdouble;
 inp1,outp1: pdouble;
 startindex1,endindex1,endindex2: integer;
begin
 if fcoeffcount > 0 then begin
  inp1:= ainp;
  outp1:= aoutp;
  for int1:= acount-1 downto 0 do begin
   po1:= fcoeff.datapo;
   i:= ainp^;
   startindex1:= fzindex;
   for int3:= 0 to high(fsections.fitems) do begin
    endindex1:= startindex1 + fsections.fitems[int3] - 1;
    if endindex1 > fcoeffhigh then begin
     endindex2:= endindex1-fcoeffhigh-1;
     endindex1:= fcoeffhigh;
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
    if startindex1 >= fcoeffcount then begin
     startindex1:= startindex1 - fcoeffcount;
    end;
    i:= o;
   end;
   outp1^:= o;
   dec(fzindex);
   if fzindex < 0 then begin
    fzindex:= fcoeffhigh;
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

procedure tiirfilter.process(const acount: integer; var ainp: pdouble;
               var aoutp: pdouble);
var 
 int1,int2,int3: integer;
 inp1,outp1: pdouble;
 i,o: double;
 po0: pcomplexty;
 po1: pcomplexty;          //todo: optimize
begin
 if fcoeffcount > 0 then begin
  inp1:= ainp;
  outp1:= aoutp;
  po0:= fcoeff.datapo;
  for int1:= acount-1 downto 0 do begin
   po1:= po0;
   i:= inp1^;
   o:= i*po1^.im+fdoublez[0];
   int3:= 0;
   for int2:= 1 to fcoeffhigh do begin
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

constructor tsections.create(const aowner: tdoublesignalcomp);
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
 fowner.setcoeffcount(calccoeffcount);
end;

procedure tsections.updatecoeffcount;
var
 int1: integer;
begin
 if not (csloading in fowner.componentstate) then begin
  int1:= fowner.coeffcount-calccoeffcount;
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

end.
