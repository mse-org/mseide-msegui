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

unit msesigfft;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesignal,msefft,classes,msetypes,mseglob;
 
type

 tbufferdoublesigcomp = class;
 
 sigbuffereventty = procedure of object;
 
 tbufferdoubleoutputconn = class(tdoubleoutputconn)
  private
   fonoutputburst: sigoutbursteventty;
   procedure setsamplecount(avalue: integer);
  protected
   fsignal: doublearty;
   fsamplecount: integer;
   findex: integer;
   procedure clear;
   property samplecount: integer read fsamplecount 
                                           write setsamplecount default 1;
  public
   constructor create(const aowner: tcomponent;
                     const asigintf: isigclient); override;
  published
   property onoutputburst: sigoutbursteventty read fonoutputburst 
                                              write fonoutputburst;
 end;
  
 tbufferdoubleinputconn = class(tdoubleinputconn)
  private
   fonsigbufferfull: sigbuffereventty;
   procedure setsamplecount(avalue: integer);
  protected
   foutput: tbufferdoubleoutputconn;
   fsignal: doublearty;
   fsamplecount: integer;
   findex: integer;
   procedure sighandler(const ainfo: psighandlerinfoty);
   procedure clear;
   property samplecount: integer read fsamplecount
                                          write setsamplecount default 1;
  public
   constructor create(const aowner: tbufferdoublesigcomp;
                      const aonsigbufferfull: sigbuffereventty); reintroduce;
 end;

 tbufferdoublesigcomp = class(tdoublesigcomp)
  private
   finput: tbufferdoubleinputconn;
   foutput: tbufferdoubleoutputconn;
   procedure setoutput(const avalue: tbufferdoubleoutputconn);
   procedure setinput(const avalue: tbufferdoubleinputconn);
   function getonoutputburst: sigoutbursteventty;
   procedure setonoutputburst(const avalue: sigoutbursteventty);
  protected
   procedure sigbufferfull; virtual;
    //isigclient
   function getinputar: inputconnarty; override;
   function getoutputar: outputconnarty; override;
   function gethandler: sighandlerprocty; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure clear; override;
   property output: tbufferdoubleoutputconn read foutput write setoutput;
  published
   property input: tbufferdoubleinputconn read finput write setinput;
   property onoutputburst: sigoutbursteventty read getonoutputburst 
                                              write setonoutputburst;
 end;
 
 tsigfft = class(tbufferdoublesigcomp)
  private
   ffft: tfft;
   fsamplecount: integer;
   procedure setsamplecount(avalue: integer);
   function getwindowfunc: windowfuncty;
   procedure setwindowfunc(const avalue: windowfuncty);
   function getwindowfuncpar0: double;
   procedure setwindowfuncpar0(const avalue: double);
   function getwindowfuncpar1: double;
   procedure setwindowfuncpar1(const avalue: double);
  protected
   procedure sigbufferfull; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property samplecount: integer read fsamplecount 
                                          write setsamplecount default 256;
   property windowfunc: windowfuncty read getwindowfunc 
                write setwindowfunc default wf_rectangular;
   property windowfuncpar0: double read getwindowfuncpar0 
                                          write setwindowfuncpar0;   
   property windowfuncpar1: double read getwindowfuncpar1 
                                          write setwindowfuncpar1;   
 end;
 
implementation

{ tbufferdoubleinputconn }

constructor tbufferdoubleinputconn.create(const aowner: tbufferdoublesigcomp;
                                      const aonsigbufferfull: sigbuffereventty);
begin
 samplecount:= 1;
 fonsigbufferfull:= aonsigbufferfull;
 foutput:= aowner.foutput;
 inherited create(aowner,isigclient(aowner));
end;

procedure tbufferdoubleinputconn.sighandler(const ainfo: psighandlerinfoty);
begin
 fsignal[findex]:= fvalue;
 inc(findex);
 if findex = fsamplecount then begin
  findex:= 0;
  fonsigbufferfull;
  with foutput do begin
   findex:= 0;
   if assigned(fonoutputburst) then begin
    fonoutputburst(self,realarty(fsignal));
   end;
  end;
 end;
 with foutput do begin
  ainfo^.dest^:= fsignal[findex];
  inc(findex);
  if findex = fsamplecount then begin
   dec(findex);
  end;
 end;
end;

procedure tbufferdoubleinputconn.clear;
begin
end;

procedure tbufferdoubleinputconn.setsamplecount(avalue: integer);
begin
 if avalue < 1 then begin
  avalue:= 1;
 end;
 fsamplecount:= avalue;
 findex:= 0;
 setlength(fsignal,avalue);
end;

{ tbufferdoubleoutputconn }

constructor tbufferdoubleoutputconn.create(const aowner: tcomponent;
                     const asigintf: isigclient);
begin
 samplecount:= 1;
 inherited;
end;

procedure tbufferdoubleoutputconn.clear;
begin
end;

procedure tbufferdoubleoutputconn.setsamplecount(avalue: integer);
begin
 if avalue < 1 then begin
  avalue:= 1;
 end;
 fsamplecount:= avalue;
 findex:= 0;
 setlength(fsignal,avalue);
end;

{ tbufferdoublesigcomp }

constructor tbufferdoublesigcomp.create(aowner: tcomponent);
begin
 foutput:= tbufferdoubleoutputconn.create(self,isigclient(self));
 finput:= tbufferdoubleinputconn.create(self,{$ifdef FPC}@{$endif}sigbufferfull);
 inherited;
end;

function tbufferdoublesigcomp.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}finput.sighandler;
end;

procedure tbufferdoublesigcomp.setoutput(const avalue: tbufferdoubleoutputconn);
begin
 foutput.assign(avalue);
end;

procedure tbufferdoublesigcomp.setinput(const avalue: tbufferdoubleinputconn);
begin
 finput.assign(avalue);
end;

function tbufferdoublesigcomp.getinputar: inputconnarty;
begin
 setlength(result,1);
 result[0]:= finput;
end;

function tbufferdoublesigcomp.getoutputar: outputconnarty;
begin
 setlength(result,1);
 result[0]:= foutput;
end;

procedure tbufferdoublesigcomp.sigbufferfull;
begin
 //dummy
end;

procedure tbufferdoublesigcomp.clear;
begin
 inherited;
 finput.clear;
 foutput.clear;
end;

function tbufferdoublesigcomp.getonoutputburst: sigoutbursteventty;
begin
 result:= foutput.onoutputburst;
end;

procedure tbufferdoublesigcomp.setonoutputburst(const avalue: sigoutbursteventty);
begin
 foutput.onoutputburst:= avalue;
end;

{ tsigfft }

constructor tsigfft.create(aowner: tcomponent);
begin
 ffft:= tfft.create(nil);
 inherited;
 samplecount:= 256;
end;

destructor tsigfft.destroy;
begin
 ffft.free;
 inherited;
end;

procedure tsigfft.setsamplecount(avalue: integer);
begin
 if avalue < 2 then begin
  avalue:= 2;
 end;
 if fsamplecount <> avalue then begin
  fsamplecount:= avalue;
  finput.samplecount:= avalue;
  foutput.samplecount:= avalue div 2 + 1;
 end;
end;

procedure tsigfft.sigbufferfull;
begin
 ffft.inpreal:= realarty(finput.fsignal);
 foutput.fsignal:= doublearty(ffft.outreal);
end;

function tsigfft.getwindowfunc: windowfuncty;
begin
 result:= ffft.windowfunc;
end;

procedure tsigfft.setwindowfunc(const avalue: windowfuncty);
begin
 ffft.windowfunc:= avalue;
end;

function tsigfft.getwindowfuncpar0: double;
begin
 result:= ffft.windowfuncpar0;
end;

procedure tsigfft.setwindowfuncpar0(const avalue: double);
begin
 ffft.windowfuncpar0:= avalue;
end;

function tsigfft.getwindowfuncpar1: double;
begin
 result:= ffft.windowfuncpar1;
end;

procedure tsigfft.setwindowfuncpar1(const avalue: double);
begin
 ffft.windowfuncpar1:= avalue;
end;

end.
