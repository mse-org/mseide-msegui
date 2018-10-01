{ MSEide Copyright (c) 2010 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit msefft;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

uses
 mseclasses,msetypes,msefftw;
 
type

 fftstatety = (ffs_inited,ffs_windowvalid);
 fftstatesty = set of fftstatety;

 windowfuncty = (wf_rectangular,wf_hann,wf_hamming); 
 
 tfft = class(tmsecomponent)
  private
   fplan: fftw_plan;
   finpreal: pdouble;
   finpcomplex: pcomplexty;
   foutreal: pdouble;
   foutcomplex: pcomplexty;
   finprealar: realarty;
   finpcomplexar: complexarty;
   fn: integer;
   fnout: integer;
   fwindowdata: doublearty;
   fwindowfunc: windowfuncty;
   fwindowfuncpar0: double;
   fwindowfuncpar1: double;
   procedure setinpreal(const avalue: realarty);
   procedure setinpcomplex(const avalue: complexarty);
   function getoutreal: realarty;
   function getoutcomplex: complexarty;
   procedure setwindowfunc(const avalue: windowfuncty);
   procedure setwindowfuncpar0(const avalue: double);
   procedure setwindowfuncpar1(const avalue: double);
  protected
   fstate: fftstatesty;
   procedure checkwindowfunc;
   procedure checkinit;
   procedure resetwindowdata;
  public
   destructor destroy; override;
   procedure clear;
   property inpreal: realarty write setinpreal;
   property inpcomplex: complexarty write setinpcomplex;
   property outreal: realarty read getoutreal;
   property outcomplex: complexarty read getoutcomplex;
  published
   property windowfunc: windowfuncty read fwindowfunc 
                write setwindowfunc default wf_rectangular;
   property windowfuncpar0: double read fwindowfuncpar0 
                                          write setwindowfuncpar0;   
   property windowfuncpar1: double read fwindowfuncpar1 
                                          write setwindowfuncpar1;   
 end;

implementation
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
	 
{ tfft }

destructor tfft.destroy;
begin
 clear;
 if ffs_inited in fstate then begin
  releasefftw;
 end;
 inherited;
end;

procedure tfft.clear;
begin
 if ffs_inited in fstate then begin
  if fplan <> nil then begin
   fftw_destroy_plan(fplan);
   fplan:= nil;
  end;
  fftw_freemem(pointer(finpreal));
  fftw_freemem(pointer(finpcomplex));
  fftw_freemem(pointer(foutreal));
  fftw_freemem(pointer(foutcomplex));
  fn:= 0;
  resetwindowdata;
 end;
end;

procedure tfft.checkwindowfunc;
var
 nminus1: double;
 int1: integer;
begin
 if not (ffs_windowvalid in fstate) then begin
  nminus1:= fn-1;
  setlength(fwindowdata,fn);
  case fwindowfunc of
   wf_hann: begin
    for int1:= 0 to high(fwindowdata) do begin
     fwindowdata[int1]:= 0.5 * (1-cos((2*pi*int1)/nminus1));
    end;    
   end;
   wf_hamming: begin
    for int1:= 0 to high(fwindowdata) do begin
     fwindowdata[int1]:= 0.54 - 0.46 * cos((2*pi*int1)/nminus1);
    end;    
   end;
   else begin
    for int1:= 0 to high(fwindowdata) do begin
     fwindowdata[int1]:= 1;
    end;
   end;
  end;
  include(fstate,ffs_windowvalid);
 end;
end;

function tfft.getoutreal: realarty;
var
 po1: pcomplexty;
 int1: integer;
 do1: double;
 po2: pdouble;
begin
 checkinit;
 if (finpcomplexar <> nil) then begin
  if (foutcomplex <> nil) then begin
   clear;
  end;
  if fn <> (length(finpcomplexar)-1)*2 then begin
   clear;
  end;  //frequ -> time
  if fplan = nil then begin
   fn:= (length(finpcomplexar)-1)*2;
   fftw_getmem(pointer(finpcomplex),(fn div 2 + 1) * sizeof(complexty));
   fftw_getmem(pointer(foutreal),fn * sizeof(double));
   fplan:= fftw_plan_dft_c2r_1d(fn,finpcomplex,foutreal,[fftw_estimate]);
  end;
  move(pointer(finpcomplexar)^,finpcomplex^,(fn div 2 + 1)*sizeof(complexty));
  fftw_execute(fplan);
  setlength(result,fn);
  move(foutreal^,pointer(result)^,fn*sizeof(double));
 end
 else begin //time -> frequ
  if (foutreal <> nil) then begin
   clear;
  end;
  if fn <> length(finprealar) then begin
   clear;
  end;
  result:= nil;
  if finprealar <> nil then begin
   if fplan = nil then begin
    fn:= length(finprealar);
    fftw_getmem(pointer(finpreal),fn * sizeof(double));
    fftw_getmem(pointer(foutcomplex),(fn div 2 + 1) * sizeof(complexty));
    fplan:= fftw_plan_dft_r2c_1d(fn,finpreal,foutcomplex,[fftw_estimate]);
   end;
   move(pointer(finprealar)^,finpreal^,fn*sizeof(double));
   if fwindowfunc <> wf_rectangular then begin
    checkwindowfunc;
    po2:= finpreal;
    for int1:= 0 to high(fwindowdata) do begin
     po2^:= po2^ * fwindowdata[int1];
     inc(po2);
    end;
   end;
   fftw_execute(fplan);
   setlength(result,fn div 2 + 1);
   po1:= foutcomplex;
   do1:= fn/2;
   for int1:= 0 to high(result) do begin 
    result[int1]:= sqrt(po1^.re*po1^.re+po1^.im*po1^.im)/do1;
    inc(po1);
   end;
   result[0]:= result[0]/2; //dc
  end;
 end;
 fnout:= length(result);
end;

function tfft.getoutcomplex: complexarty;
begin
 checkinit;
 if (foutreal <> nil) then begin
  clear;
 end;
 if (finpcomplexar <> nil) then begin
  if fn <> length(finpcomplexar) then begin
   clear;
  end;
 end
 else begin
  if fn <> length(finprealar) then begin
   clear;
  end;
 end;
 result:= nil; //todo
end;

procedure tfft.setinpreal(const avalue: realarty);
begin
 if finpcomplexar <> nil then begin
  clear;
  finpcomplexar:= nil;
 end;
 finprealar:= avalue;
end;

procedure tfft.setinpcomplex(const avalue: complexarty);
begin
 if finprealar <> nil then begin
  clear;
  finprealar:= nil;
 end;
 finpcomplexar:= avalue;
end;

procedure tfft.checkinit;
begin
 if not (ffs_inited in fstate) then begin
  initializefftw([]);
  include(fstate,ffs_inited);
 end;
end;

procedure tfft.setwindowfunc(const avalue: windowfuncty);
begin
 if avalue <> fwindowfunc then begin
  fwindowfunc:= avalue;
  resetwindowdata;
 end;
end;

procedure tfft.setwindowfuncpar0(const avalue: double);
begin
 if avalue <> fwindowfuncpar0 then begin
  fwindowfuncpar0:= avalue;
  resetwindowdata;
 end;
end;

procedure tfft.setwindowfuncpar1(const avalue: double);
begin
 if avalue <> fwindowfuncpar1 then begin
  fwindowfuncpar1:= avalue;
  resetwindowdata;
 end;
end;

procedure tfft.resetwindowdata;
begin
 fwindowdata:= nil;
 exclude(fstate,ffs_windowvalid);
end;

end.
