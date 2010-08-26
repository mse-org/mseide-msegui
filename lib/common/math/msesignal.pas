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
 msedatalist,mseclasses;
type
 tcustomsignalcomp = class;
 
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
 
implementation

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

end.
