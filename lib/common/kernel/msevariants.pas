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
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
uses
 msetypes,msestrings;
type
 variantarty = array of variant;
 variantaty = array[0..0] of variant;
 pvariantaty = ^variantaty;
 variantararty = array of variantarty;
 vardataaty = array[0..0] of tvardata;
 pvardataaty = ^vardataaty;

function mseVarTypeIsValidArrayType(const aVarType: TVarType): Boolean;
function mseVarArrayCreate(const Bounds: PVarArrayBoundArray; Dims : SizeInt;
                                                  aVarType: TVarType): Variant;
function vartomsestring(const avalue: variant): msestring;

implementation
uses
 variants,varutils;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

function vartomsestring(const avalue: variant): msestring;
begin
 result:= '';
 if not varisnull(avalue) then begin
  result:= avalue;
 end;
end;

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

function mseVarArrayCreate(const Bounds: PVarArrayBoundArray;
                             Dims : SizeInt; aVarType: TVarType): Variant;
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
