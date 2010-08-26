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
 mseclasses,msedatalist,classes,msetypes,msesignal;
type

 tdoublesignalcomp = class(tsignalcomp)
  private
   fdoublez: doublearty;
   fzindex: integer;
   finputindex: integer;
   fdoubleinputdata: doubleararty;
   forder: integer;
   forderhigh: integer;
   procedure setcoeff(const avalue: tdatalist);
   procedure setorder(const avalue: integer);
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
  published
   property order: integer read forder write setorder default 0;
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
 forderhigh:= -1;
 createcoeff;
 inherited; 
end;

destructor tdoublesignalcomp.destroy;
begin
 clear;
 inherited;
 fcoeff.free;
end;

procedure tdoublesignalcomp.setcoeff(const avalue: tdatalist);
begin
 fcoeff.assign(avalue);
end;

procedure tdoublesignalcomp.setorder(const avalue: integer);
begin
 if forder <> avalue then begin
  if order < 0 then begin
   raise exception.create('Invalid order value.');
  end;
  clear;
  forder:= avalue;
  forderhigh:= avalue - 1;
  fcoeff.count:= avalue;
  setlength(fdoublez,avalue);
 end;
end;

procedure tdoublesignalcomp.clear;
begin
 fdoubleinputdata:= nil;
 finputindex:= 0;
 fillchar(pointer(fdoublez)^,forder*sizeof(double),0);
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
  order:= sender.count;
 end;
end;

{ tfirfilter }

procedure tfirfilter.createcoeff;
begin
 fcoeff:= trealcoeff.create(self);
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
var
 int1,int2: integer;
 ar1: doublearty;
 do1,sum: double;
 po1: pdouble;
 inp1,outp1: pdouble;
begin
 inp1:= ainp;
 outp1:= aoutp;
 for int1:= acount-1 downto 0 do begin
  sum:= 0;
  po1:= fcoeff.datapo;
  fdoublez[fzindex]:= inp1^;
  for int2:= fzindex to forderhigh do begin
   sum:= sum + fdoublez[int2] * po1^;
   inc(po1);
  end;
  for int2:= 0 to fzindex-1 do begin
   sum:= sum + fdoublez[int2] * po1^;
   inc(po1);
  end;
  inc(fzindex);
  if fzindex >= forder then begin
   fzindex:= 0;
  end;
  outp1^:= sum;
  inc(outp1);
  inc(inp1);
 end;
 ainp:= inp1;
 aoutp:= outp1;
end;

{ tiirfilter }

procedure tiirfilter.createcoeff;
begin
 fcoeff:= tcomplexcoeff.create(self);
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
 int1,int2: integer;
 inp1,outp1: pdouble;
 i,o: double;
 po0: pcomplexty;
 po1: pcomplexty;          //todo: optimize
begin
 if forder > 0 then begin
  inp1:= ainp;
  outp1:= aoutp;
  po0:= fcoeff.datapo;
  for int1:= acount-1 downto 0 do begin
   po1:= po0;
   i:= inp1^;
   o:= i*po1^.im+fdoublez[0];
   for int2:= 0 to forderhigh - 2 do begin
    inc(po1);
    fdoublez[int2]:= fdoublez[int2+1] + i*po1^.im - o*po1^.re;
   end;
   inc(po1);
   fdoublez[forderhigh-1]:=             i*po1^.im - o*po1^.re;
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

end.
