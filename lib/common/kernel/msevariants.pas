{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msevariants;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

function mseVarTypeIsValidArrayType(const aVarType: TVarType): Boolean;
function mseVarArrayCreate(const Bounds: PVarArrayBoundArray; Dims : SizeInt; aVarType: TVarType): Variant;

implementation
uses
 variants,varutils;

//allow int64 arrays

function mseVarTypeIsValidArrayType(const aVarType: TVarType): Boolean;
  begin
    Result:=aVarType in [varSmallInt,varInteger,
{$ifndef FPUNONE}
      varSingle,varDouble,varDate,
{$endif}
      varCurrency,varOleStr,varDispatch,varError,varBoolean,
      varVariant,varUnknown,varShortInt,varByte,varWord,varLongWord,
      varint64];
  end;
 
function mseVarArrayCreate(const Bounds: PVarArrayBoundArray; Dims : SizeInt; aVarType: TVarType): Variant;
  var
    p : pvararray;
  begin
    if not(mseVarTypeIsValidArrayType(aVarType)) then
      VarArrayCreateError;
    finalize(Result);

    p:=SafeArrayCreate(aVarType,Dims,Bounds^);

    if not(assigned(p)) then
      VarArrayCreateError;

    TVarData(Result).vType:=aVarType or varArray;
    TVarData(Result).vArray:=p;
  end;
end.
