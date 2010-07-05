unit msefftw;
{
   FFTW - Fastest Fourier Transform in the West library

   This interface unit is (C) 2005 by Daniel Mantione
     member of the Free Pascal development team.

   See the file COPYING.FPC, included in this distribution,
   for details about the copyright.

   This file carries, as a independend work calling a well
   documented binary interface, the Free Pascal LGPL license
   with static linking exception.

   Note that the FFTW library itself carries the GPL license
   and can therefore not be used in non-GPL software.
   
   Modified 2010 by Martin Schreiber
}

interface

{$MACRO on}
{$INLINE on}
uses
 msetypes,msestrings;
 
const
{$ifdef mswindows}
 fftwlib: array[0..0] of filenamety = ('fftw3.dll');
{$else}
 fftwlib: array[0..1] of filenamety = ('libfftw3.so.3','libfftw3.so');
{$endif}

{$IFDEF Unix}
//const   
//    fftwlib = 'fftw3f';
{$ELSE}
//const
//    fftwlib = 'libfftw3f';
{$ENDIF}

type  //  complex_single=record
      //    re,im:single;
      //  end;
      //  Pcomplex_single=^complex_single;

 fftw_plan = type pointer;

 fftw_sign = (fftw_forward = -1, fftw_backward = 1);

 fftw_flag = (fftw_measure,            {generated optimized algorithm}
              fftw_destroy_input,      {default}
              fftw_unaligned,          {data is unaligned}
              fftw_conserve_memory,    {needs no explanation}
              fftw_exhaustive,         {search optimal algorithm}
              fftw_preserve_input,     {don't overwrite input}
              fftw_patient,            {generate highly optimized alg.}
              fftw_estimate);          {don't optimize, just use an alg.}
 fftw_flagset = set of fftw_flag;
                   
var
{Complex to complex transformations.}
fftw_plan_dft_1d: function(n: cardinal; i,o: Pcomplexty;
                          sign: fftw_sign; flags: fftw_flagset): fftw_plan; cdecl;
fftw_plan_dft_2d: function(nx,ny: cardinal; i,o: Pcomplexty;
                          sign: fftw_sign; flags: fftw_flagset): fftw_plan; cdecl;
fftw_plan_dft_3d: function(nx,ny,nz: cardinal; i,o: Pcomplexty;
                          sign: fftw_sign; flags: fftw_flagset): fftw_plan; cdecl;

fftw_plan_dft: function(rank: cardinal; n: Pcardinal; i,o: Pcomplexty;
                       sign: fftw_sign; flags: fftw_flagset): fftw_plan; cdecl;

{Real to complex transformations.}
fftw_plan_dft_r2c_1d: function(n: cardinal; i:Pdouble; o: Pcomplexty;
                          flags:fftw_flagset): fftw_plan; cdecl;
fftw_plan_dft_r2c_2d: function(nx,ny: cardinal; i: Pdouble; o:Pcomplexty;
                          flags:fftw_flagset):fftw_plan; cdecl;
fftw_plan_dft_r2c_3d: function(nx,ny,nz: cardinal; i: Psingle; o: Pcomplexty;
                          flags: fftw_flagset): fftw_plan; cdecl;
fftw_plan_dft_r2c: function(rank:cardinal;n:Pcardinal;i:Psingle;o:Pcomplexty;
                       flags:fftw_flagset):fftw_plan; cdecl;

{Complex to real transformations.}
fftw_plan_dft_c2r_1d: function(n: cardinal; i: Pcomplexty; o: Pdouble;
                          flags:fftw_flagset): fftw_plan; cdecl;
fftw_plan_dft_c2r_2d: function(nx,ny:cardinal; i: Pcomplexty; o:Pdouble;
                          flags: fftw_flagset): fftw_plan; cdecl;
fftw_plan_dft_c2r_3d: function(nx,ny,nz: cardinal; i: Pcomplexty; o: Pdouble;
                          flags: fftw_flagset): fftw_plan; cdecl;
fftw_plan_dft_c2r: function(rank: cardinal; n:Pcardinal; i:Pcomplexty; o: Pdouble;
                       flags: fftw_flagset):fftw_plan; cdecl;


fftw_destroy_plan: procedure(plan: fftw_plan); cdecl;
fftw_execute: procedure(plan: fftw_plan); cdecl;

//{$calling register} {Back to normal!}
procedure fftw_getmem(var p: pointer; size: sizeint);
procedure fftw_freemem(var p: pointer);inline;

procedure initializefftw(const sonames: array of filenamety); 
                                     //[] = default
procedure releasefftw;

implementation
uses
 msedynload,msesys,sysutils;
 
var 
 libinfo: dynlibinfoty;

//{$ifndef Windows}
//{$LINKLIB fftw3f}
//{$endif}

{Required libraries by libfftw3}
{ $LINKLIB gcc}
{ $LINKLIB c}
{ $LINKLIB m}

{Better don't use fftw_malloc and fftw_free, but provide Pascal replacements.}

{$IF defined(cpui386) or defined(cpupowerpc)}
  {$DEFINE align:=16}
{$ENDIF}

procedure fftw_getmem(var p:pointer; size: sizeint);

{$IFDEF align}
var
  originalptr:pointer;
begin
  { We allocate additional "align-1" bytes to be able to align.
    And we allocate additional "SizeOf(Pointer)" to always have space to store
    the value of the original pointer. }
  getmem(originalptr,size + align-1 + SizeOf(Pointer));
  ptruint(p):=(ptruint(originalptr) + SizeOf(Pointer));
  ptruint(p):=(ptruint(p)+align-1) and not (align-1);
  PPointer(ptruint(p) - SizeOf(Pointer))^:= originalptr;
{$ELSE}
begin
  getmem(p,size);
{$ENDIF}
end;

procedure fftw_freemem(var p: pointer); inline;

begin
 if p <> nil then begin
{$IFDEF align}
  freemem(PPointer(ptruint(p) - SizeOf(Pointer))^);
{$ELSE}
  freemem(p);
{$ENDIF}
  p:= nil;
 end;
end;

procedure initializefftw(const sonames: array of filenamety); 
                                     //[] = default
const
 funcs: array[0..13] of funcinfoty = (
   (n: 'fftw_plan_dft_1d'; d: @fftw_plan_dft_1d),
   (n: 'fftw_plan_dft_2d'; d: @fftw_plan_dft_2d),
   (n: 'fftw_plan_dft_3d'; d: @fftw_plan_dft_3d),
   (n: 'fftw_plan_dft'; d: @fftw_plan_dft),
   (n: 'fftw_plan_dft_r2c_1d'; d: @fftw_plan_dft_r2c_1d),
   (n: 'fftw_plan_dft_r2c_2d'; d: @fftw_plan_dft_r2c_2d),
   (n: 'fftw_plan_dft_r2c_3d'; d: @fftw_plan_dft_r2c_3d),
   (n: 'fftw_plan_dft_r2c'; d: @fftw_plan_dft_r2c),
   (n: 'fftw_plan_dft_c2r_1d'; d: @fftw_plan_dft_c2r_1d),
   (n: 'fftw_plan_dft_c2r_2d'; d: @fftw_plan_dft_c2r_2d),
   (n: 'fftw_plan_dft_c2r_3d'; d: @fftw_plan_dft_c2r_3d),
   (n: 'fftw_plan_dft_c2r'; d: @fftw_plan_dft_c2r),
   (n: 'fftw_destroy_plan'; d: @fftw_destroy_plan),
   (n: 'fftw_execute'; d: @fftw_execute));


begin
 try
  if length(sonames) = 0 then begin
   initializedynlib(libinfo,fftwlib,funcs,[]);
  end
  else begin
   initializedynlib(libinfo,sonames,funcs,[]);
  end;
 except
  on e: exception do begin
   e.message:= 'Can not load FFTW library. '+e.message;
   raise;
  end;  
 end;
end;

procedure releasefftw;
begin
 releasedynlib(libinfo);
end;

initialization
 initializelibinfo(libinfo);
finalization
 finalizelibinfo(libinfo);
end.
