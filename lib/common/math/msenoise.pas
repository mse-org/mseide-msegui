{ MSEgui Copyright (c) 2013 by Martin Schreiber

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
 
type
 mwcinfoty = record
  fw,fz: card32; //not 0
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
 
implementation

var
 fw: card32 = $a91b43f5; //"random" seed
 fz: card32 = $730c9a26; //"random" seed

procedure mwcnoiseinit(const w: card32 = 0; const z: card32 = 0);
begin
 fw:= w;
 if fw = 0 then begin
  fw:= random($ffffffff)+1;
 end;
 fz:= z;
 if fz = 0 then begin
  fz:= random($ffffffff)+1;
 end;
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
 if fw = 0 then begin
  fw:= random($ffffffff)+1;
 end;
 fz:= z;
 if fz = 0 then begin
  fz:= random($ffffffff)+1;
 end;
end;

function tmwcnoisegen.next: card32;
begin
 fz:= 36969 * (fz and $ffff) + (fz shr 16);
 fw:= 18000 * (fw and $ffff) + (fw shr 16);
 result:= fz shl 16 + fw;
end;

end.
