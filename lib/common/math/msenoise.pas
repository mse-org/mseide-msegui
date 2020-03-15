{ MSEgui Copyright (c) 2013-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msenoise;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes;
const
 defaultmwcseedw = 521288629;
 defaultmwcseedz = 362436069;
type
 mwcinfoty = record
  fw,fz: card32; //call checkmwcseed() after init
 end;

 tmwcnoisegen = class
  private
   fw: card32;
   fz: card32;
  public
   constructor create;
   procedure init(const w: card32 = 0; const z: card32 = 0);
   function next: card32;
 end;

function mwcnoise(var state: mwcinfoty): card32; overload;
function mwcnoise: card32; overload;
procedure mwcnoiseinit(const w: card32 = 0; const z: card32 = 0);
procedure checkmwcseed(var w: card32; var z: card32);
                   //0 -> use random
procedure checkmwcseed(var state: mwcinfoty);

implementation

var
 fw: card32 = defaultmwcseedw; //"random" seed
 fz: card32 = defaultmwcseedz; //"random" seed

procedure checkmwcseed(var w: card32; var z: card32);
begin
 if w = 0 then begin
  w:= random($9068fffe)+1;
 end
 else begin
  if w mod $9068ffff = 0 then begin
   w:= (w xor $ffffffff) mod $9068ffff;
  end;
 end;
 if z = 0 then begin
  z:= random($464ffffe)+1;
 end
 else begin
  if z mod $464fffff = 0 then begin
   z:= (z xor $ffffffff) mod $464fffff;
  end;
 end;
end;

procedure checkmwcseed(var state: mwcinfoty);
begin
 checkmwcseed(state.fw,state.fz);
end;

procedure mwcnoiseinit(const w: card32 = 0; const z: card32 = 0);
begin
 fw:= w;
 fz:= z;
 checkmwcseed(fw,fz);
end;

function mwcnoise: card32;
begin
 fz:= 36969 * (fz and $ffff) + (fz shr 16);
 fw:= 18000 * (fw and $ffff) + (fw shr 16);
 result:= fz shl 16 + fw;
end;

function mwcnoise(var state: mwcinfoty): card32;
begin
 with state do begin
  fz:= 36969 * (fz and $ffff) + (fz shr 16);
  fw:= 18000 * (fw and $ffff) + (fw shr 16);
  result:= fz shl 16 + fw;
 end;
end;

{ tmwcnoisegen }

constructor tmwcnoisegen.create;
begin
 init;
end;

procedure tmwcnoisegen.init(const w: card32 = 0; const z: card32 = 0);
begin
 fw:= w;
 fz:= z;
 checkmwcseed(fw,fz);
end;

function tmwcnoisegen.next: card32;
begin
 fz:= 36969 * (fz and $ffff) + (fz shr 16);
 fw:= 18000 * (fw and $ffff) + (fw shr 16);
 result:= fz shl 16 + fw;
end;

end.
