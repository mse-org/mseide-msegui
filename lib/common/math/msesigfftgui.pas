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

unit msesigfftgui;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesignal,msechart,classes,msesigfft;
 
type
 tsigscopefft = class;
 tscopesamplerfft = class(tsigsamplerfft)
  private
   fscope: tsigscopefft;
  protected
   procedure dobufferfull; override;
  public
   constructor create(const aowner: tsigscopefft); reintroduce;
 end;

 tsigscopefft = class(tchart)
  private
   fsampler: tscopesamplerfft;
   ffftfirst: integer;
   ffftcount: integer;
   procedure setsampler(const avalue: tscopesamplerfft);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property sampler: tscopesamplerfft read fsampler write setsampler;
   property fftfirst: integer read ffftfirst write ffftfirst default 0;
   property fftcount: integer read ffftcount write ffftcount default 0;
                               //0 -> all
 end;
 
implementation

{ tsigscopefft }

constructor tsigscopefft.create(aowner: tcomponent);
begin
 fsampler:= tscopesamplerfft.create(self);
 inherited;
end;

destructor tsigscopefft.destroy;
begin
 fsampler.free;
 inherited;
end;

procedure tsigscopefft.setsampler(const avalue: tscopesamplerfft);
begin
 fsampler.assign(avalue);
end;

{ tscopesamplerfft }

constructor tscopesamplerfft.create(const aowner: tsigscopefft);
begin
 fscope:= aowner;
 inherited create(aowner);
 setsubcomponent(true);
 name:= 'sampler';
end;

procedure tscopesamplerfft.dobufferfull;
var
 buf1: samplerbufferty;
 int1: integer;
begin
 inherited;
 if sso_fftmag in options then begin
  with fscope do begin
   if (ffftfirst = 0) and (ffftcount = 0) then begin
    buf1:= ffftbuffer;
   end
   else begin
    setlength(buf1,length(ffftbuffer));
    for int1:= 0 to high(buf1) do begin
     buf1[int1]:= copy(ffftbuffer[int1],fftfirst,ffftcount);
    end;
   end;
  end;
 end
 else begin
  buf1:= copy(fsigbuffer);
 end;
 lockapplication;
 try
  with fscope.traces do begin
   for int1:= 0 to high(buf1) do begin
    if int1 >= count then begin
     break;
    end;
    items[int1].ydata:= buf1[int1];
   end;
  end;
 finally
  unlockapplication;
 end;
end;

end.
