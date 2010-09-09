{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

//
//not finished!!!!
//

unit msesignal;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msedatalist,mseclasses,classes,msetypes;
type
 tcustomsignalcomp = class;
 
 tdoubleconn = class(tmsecomponent) 
        //no solution fond to link to streamed tpersistent or tobject,
        //fork of classes.pp necessary. :-(
  protected
//   fowner: tcomponent;
  public
   constructor create(aowner: tcomponent); override;
 end;
 
 tdoubleinputconn = class;
 doubleinputconnarty = array of tdoubleinputconn;
 
 tdoubleoutputconn = class(tdoubleconn)
  protected
   fdestinations: doubleinputconnarty;
//   procedure updatesig(var adata: doublearty);
  public
   constructor create(aowner: tcomponent); override;
 end; 

 tdoubleinputconn = class(tdoubleconn)
  private
   fsource: tdoubleoutputconn;
   procedure setsource(const avalue: tdoubleoutputconn);
//   procedure readsource(reader: treader);
//   procedure writesource(writer: twriter);
  protected
//   procedure updatesig(var adata: doublearty);
//   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property source: tdoubleoutputconn read fsource write setsource;
 end;

 tsigconnection = class(tmsecomponent)
 end;
 
 tsigin = class(tsigconnection)
  private
   foutput: tdoubleoutputconn;
//   procedure setdest(const avalue: tdoubleinputconn);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy;
   procedure setsig(const asig: doublearty);
  published
//   property dest: tdoubleinputconn read fdest write setdest;
 end;
 
 tsigout = class(tsigconnection)
  private
   finput: tdoubleinputconn;
   foutp: doublearty;
   procedure setinput(const avalue: tdoubleinputconn);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property outp: doublearty read foutp;
  published
   property input: tdoubleinputconn read finput write setinput;
 end;
 
 trealcoeff = class(trealdatalist)
  protected
   fowner: tcustomsignalcomp;
   procedure change(const aindex: integer); override;
  public
   constructor create(const aowner: tcustomsignalcomp);
 end; 

 tcomplexcoeff = class(tcomplexdatalist)
  protected
   fowner: tcustomsignalcomp;
   procedure change(const aindex: integer); override;
  public
   constructor create(const aowner: tcustomsignalcomp);
 end; 

 tcustomsignalcomp = class(tmsecomponent)
  protected
   procedure coeffchanged(const sender: tdatalist;
                                 const aindex: integer); virtual;
 end;

 tsignalcomp = class(tcustomsignalcomp)
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
   procedure setinput(const avalue: tdoubleinputconn);
   procedure setoutput(const avalue: tdoubleoutputconn);
  protected
   fzcount: integer;
   fzhigh: integer;
   fdoublez: doublearty;
   fzindex: integer;
   finputindex: integer;
   fdoubleinputdata: doubleararty;
   finput: tdoubleinputconn;
   foutput: tdoubleoutputconn;
   procedure setzcount(const avalue: integer);
   procedure processinout(const acount: integer;
                    var ainp,aoutp: pdouble); virtual; abstract;
   procedure zcountchanged; virtual;
//   procedure createinputs; override;
//   procedure createoutputs; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure clear; override;
   procedure setsig(const source: doublearty);
   procedure getsig1(var dest: doublearty);
   function getsig: doublearty;
   procedure updatesig(var inout: doublearty);
   property zcount: integer read fzcount default 0;
  published
   property input: tdoubleinputconn read finput write setinput;
   property output: tdoubleoutputconn read foutput write setoutput;
 end;

procedure createsigbuffer(var abuffer: doublearty; const asize: integer);
procedure setsourceconn(const sender: tmsecomponent;
              const avalue: tdoubleoutputconn; var dest: tdoubleoutputconn);
 
implementation
uses
 sysutils;
type
 tmsecomponent1 = class(tmsecomponent);
  
procedure createsigbuffer(var abuffer: doublearty; const asize: integer);
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

procedure setsourceconn(const sender: tmsecomponent;
              const avalue: tdoubleoutputconn; var dest: tdoubleoutputconn);
begin
 if dest <> nil then begin
  if csdestroying in dest.componentstate then begin
   dest.fdestinations:= nil;
  end
  else begin
   removeitem(pointerarty(dest.fdestinations),sender);
  end;
 end;
 tmsecomponent1(sender).setlinkedvar(avalue,dest);
 if dest <> nil then begin
  additem(pointerarty(dest.fdestinations),sender);
 end;
end;

{ trealcoeff }

constructor trealcoeff.create(const aowner: tcustomsignalcomp);
begin
 fowner:= aowner;
 inherited create;
end;

procedure trealcoeff.change(const aindex: integer);
begin
 fowner.coeffchanged(self,aindex);
 inherited;
end;

{ tcomplexcoeff }

constructor tcomplexcoeff.create(const aowner: tcustomsignalcomp);
begin
 fowner:= aowner;
 inherited create;
end;

procedure tcomplexcoeff.change(const aindex: integer);
begin
 fowner.coeffchanged(self,aindex);
 inherited;
end;

{ tcustomsignalcomp }

procedure tcustomsignalcomp.coeffchanged(const sender: tdatalist;
               const aindex: integer);
begin
 //dummy
end;

{ tdoublconn }

constructor tdoubleconn.create(aowner: tcomponent);
begin
// fowner:= aowner;
// inherited create(nil);
 inherited;
 setsubcomponent(true);
end;

{ tdoubleoutputconn }

constructor tdoubleoutputconn.create(aowner: tcomponent);
begin
 inherited;
 include (fmsecomponentstate,cs_subcompref);
 name:= 'output';
end;

{ tdoubleinputconn }

constructor tdoubleinputconn.create(aowner: tcomponent);
begin
 inherited;
 name:= 'input';
end;

destructor tdoubleinputconn.destroy;
begin
 source:= nil;
 inherited;
end;

procedure tdoubleinputconn.setsource(const avalue: tdoubleoutputconn);
begin
 setsourceconn(self,avalue,fsource);
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
 finput:= tdoubleinputconn.create(self);
// finput.name:= 'input';
 foutput:= tdoubleoutputconn.create(self);
// foutput.name:= 'output';
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

procedure tdoublezcomp.setsig(const source: doublearty);
begin
 if finputindex > high(fdoubleinputdata) then begin
  setlength(fdoubleinputdata,finputindex+1);
 end;
 fdoubleinputdata[finputindex]:= source;
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

procedure tdoublezcomp.getsig1(var dest: doublearty);
var
 int1,int3: integer;
 po1,po2: pdouble;
begin
 int3:= 0;
 for int1:= 0 to finputindex-1 do begin
  int3:= int3 + high(fdoubleinputdata[int1]);
 end;
 int3:= int3 + finputindex;
 createsigbuffer(dest,int3);
 po2:= pointer(dest);
 for int1:= 0 to finputindex-1 do begin
  po1:= pointer(fdoubleinputdata[int1]);
  processinout(length(fdoubleinputdata[int1]),po1,po2);
 end;  
 for int1:= 0 to finputindex-1 do begin
  fdoubleinputdata[int1]:= nil;
 end;
 finputindex:= 0;
end;

function tdoublezcomp.getsig: doublearty;
begin
 getsig1(result);
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

procedure tdoublezcomp.setinput(const avalue: tdoubleinputconn);
begin
 finput.assign(avalue);
end;

procedure tdoublezcomp.setoutput(const avalue: tdoubleoutputconn);
begin
 foutput.assign(avalue);
end;

{ tsigout }

constructor tsigout.create(aowner: tcomponent);
begin
 finput:= tdoubleinputconn.create(self);
 inherited;
end;

destructor tsigout.destroy;
begin
// source:= nil;
 inherited;
end;

procedure tsigout.setinput(const avalue: tdoubleinputconn);
begin
 finput.assign(avalue);
end;

{ tsigin }

constructor tsigin.create(aowner: tcomponent);
begin
 foutput:= tdoubleoutputconn.create(self);
 inherited;
end;

destructor tsigin.destroy;
begin
 inherited;
// foutput.free;
end;
{
procedure tsigin.setoutput(const avalue: tdoubleoutputconn);
begin
 foutput.assign(avalue);
end;
}
procedure tsigin.setsig(const asig: doublearty);
begin
end;

end.
