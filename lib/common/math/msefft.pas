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
uses
 mseclasses,msetypes,msefftw;
 
type

 fftstatety = (ffs_inited);
 fftstatesty = set of fftstatety;
 
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
   procedure setinpreal(const avalue: realarty);
   procedure setinpcomplex(const avalue: complexarty);
   function getoutreal: realarty;
   function getoutcomplex: complexarty;
  protected
   fstate: fftstatesty;
   procedure checkinit;
  public
   destructor destroy; override;
   procedure clear;
   property inpreal: realarty write setinpreal;
   property inpcomplex: complexarty write setinpcomplex;
   property outreal: realarty read getoutreal;
   property outcomplex: complexarty read getoutcomplex;
 end;

implementation
 
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
  fftw_freemem(finpreal);
  fftw_freemem(finpcomplex);
  fftw_freemem(foutreal);
  fftw_freemem(foutcomplex);
  fn:= 0;
 end;
end;

function tfft.getoutreal: realarty;
var
 po1: pcomplexty;
 int1: integer;
 do1: double;
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
   fftw_getmem(finpcomplex,(fn div 2 + 1) * sizeof(complexty));
   fftw_getmem(foutreal,fn * sizeof(double));
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
    fftw_getmem(finpreal,fn * sizeof(double));
    fftw_getmem(foutcomplex,(fn div 2 + 1) * sizeof(complexty));
    fplan:= fftw_plan_dft_r2c_1d(fn,finpreal,foutcomplex,[fftw_estimate]);
   end;
   move(pointer(finprealar)^,finpreal^,fn*sizeof(double));
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

end.
