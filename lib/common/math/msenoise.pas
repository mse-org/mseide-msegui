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
 tmwcnoisegen = class
  private
   fw: uint32;
   fz: uint32;
  public
   constructor create;
   procedure init(const w: uint32 = 0; const z: uint32 = 0); 
   function next: uint32;
 end;

function mwcnoise: uint32;
procedure mwcnoiseinit(const w: uint32 = 0; const z: uint32 = 0);
 
implementation

var
 fw: uint32 = $a91b43f5; //"random" seed
 fz: uint32 = $730c9a26; //"random" seed

procedure mwcnoiseinit(const w: uint32 = 0; const z: uint32 = 0);
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

function mwcnoise: uint32;
begin
 fz:= 36969 * (fz and $ffff) + (fz shr 16);
 fw:= 18000 * (fw and $ffff) + (fw shr 16);
 result:= fz shl 16 + fw;
end;

{ tmwcnoisegen }

constructor tmwcnoisegen.create;
begin
 init;
end;

procedure tmwcnoisegen.init(const w: uint32 = 0; const z: uint32 = 0);
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

function tmwcnoisegen.next: uint32;
begin
 fz:= 36969 * (fz and $ffff) + (fz shr 16);
 fw:= 18000 * (fw and $ffff) + (fw shr 16);
 result:= fz shl 16 + fw;
end;

end.
