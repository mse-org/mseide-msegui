{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestringident;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 {globtypes,}msehash,msestrings,msetypes;

//{$define caseinsensitive}
const
 firstident = 256;
 stridstart = $12345678; //not used
 strid0 = $2468ACF1;
 strid1 = $48D159E3;
 strid2 = $91A2B3C6;
 strid3 = $2345678C;
 strid4 = $468ACF19;
 strid5 = $8D159E33;
 strid6 = $1A2B3C66;
 strid7 = $345678CD;
 strid8 = $68ACF19B;
 strid9 = $D159E337;

type
// keywordty = identty;

 identnamety = record
  offset: int32; //relative to data block
 end;

 identheaderty = record
  ident: identty;
 end;

 pidentheaderty = ^identheaderty;
 identoffsetty = int32;

 identdataty = record
  header:identheaderty;
  keyname: identoffsetty; //
//  keylen: integer;
 end;
 identhashdataty = record
  header: hashheaderty;
  data: identdataty;
 end;
 pidenthashdataty = ^identhashdataty;

 tidenthashdatalist = class(thashdatalist)
  protected
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitem: phashdataty): boolean; override;
   function getrecordsize(): int32 override;
  public
//   constructor create(const asize: int32);
                    //total datasize including identheaderty
   function adduniquedata(const akey: identty;
                                   out adata: pidenthashdataty): boolean;
                              //false if duplicate
 end;

 tstringidents = class;
// tidenthashdatalist = class;

 indexidentdataty = record
  key: identnamety; //index of null terminated string
  data: identty;
 end;
 pindexidentdataty = ^indexidentdataty;
 indexidenthashdataty = record
  header: hashheaderty;
  data: indexidentdataty;
 end;
 pindexidenthashdataty = ^indexidenthashdataty;

 tindexidenthashdatalist = class(thashdatalist)
// {$ifdef mse_debugparser}
  private
   fidents: tidenthashdatalist;
// {$endif}
  protected
   fowner: tstringidents;
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitem: phashdataty): boolean; override;
   function getrecordsize(): int32 override;
  public
   constructor create(const aowner: tstringidents);
   destructor destroy; override;
   procedure clear; override;
   function identname(const aident: identty; out aname: lstringty): boolean;
   function identname(const aident: identty; out aname: identnamety): boolean;
   function getident(const aname: lstringty): pindexidenthashdataty;
 end;

 tstringidents = class
  protected
   fstringident: identty;
   fidentlist: tindexidenthashdatalist;
   fstringindex,fstringlen: identoffsetty;
   fstringdata: pointer;
   procedure nextident();
   function storestring(const astr: lstringty): identnamety;
  public
   constructor create();
   destructor destroy(); override;
   function getident(): identty;
   function getident(const astart,astop: pchar): identty;
   function getident(const aname: lstringty): identty;
   function getident(const aname: pchar; const alen: integer): identty;
   function getident(const aname: string): identty;

   function getidentname(const aident: identty; out name: identnamety): boolean;
                             //true if found
   function getidentname(const aident: identty; out name: lstringty): boolean;
                             //true if found
   function getidentname(const aname: string): identnamety;
   function getidentname(const aident: identty): string;
   function getidentnamel(const aident: identty): lstringty;
   function getidentnamep(const aident: identty): pchar;
//   function getidentnamel(const aeledata: pointer): lstringty;
   function getidentname2(const aident: identty): identnamety;
//   function getidentname2(const aeledata: pointer): identnamety;

   function nametolstring(const aname: identnamety): lstringty; inline;

   procedure clear();
//   procedure init();
 end;

implementation
uses
 mselfsr;

const
 mindatasize = 1024;

type
 identbufferheaderty = record
  len: int32;
 end;
 identbufferty = record
  header: identbufferheaderty;
  data: record //null terminated array of char
  end;
 end;
 pidentbufferty = ^identbufferty;

procedure tstringidents.nextident;
begin
 repeat
  lfsr321(fstringident);
 until fstringident >= firstident;
end;

function tstringidents.getident(): identty;
begin
 result:= fstringident;
 nextident;
end;

function tstringidents.getident(const aname: lstringty): identty;
begin
 result:= fidentlist.getident(aname)^.data.data;
end;

function tstringidents.getident(const aname: pchar;
                                          const alen: integer): identty;
var
 lstr1: lstringty;
begin
 lstr1.po:= aname;
 lstr1.len:= alen;
 result:= fidentlist.getident(lstr1)^.data.data;
end;

function tstringidents.getident(const astart,astop: pchar): identty;
var
 lstr1: lstringty;
begin
 lstr1.po:= astart;
 lstr1.len:= astop-astart;
 result:= fidentlist.getident(lstr1)^.data.data;
end;

function tstringidents.getident(const aname: string): identty;
var
 lstr1: lstringty;
begin
 lstr1.po:= pointer(aname);
 lstr1.len:= length(aname);
 result:= fidentlist.getident(lstr1)^.data.data;
end;

function tstringidents.nametolstring(const aname: identnamety): lstringty;
var
 po1: pidentbufferty;
begin
 po1:= pointer(fstringdata) + aname.offset;
 result.len:= po1^.header.len;
 result.po:=  @po1^.data;
end;

function tstringidents.getidentname(const aident: identty;
                                           out name: lstringty): boolean;
                             //true if found
begin
 result:= fidentlist.identname(aident,name);
end;

function tstringidents.getidentname(const aname: string): identnamety;
begin
 result:= fidentlist.getident(stringtolstring(aname))^.data.key;
end;

function tstringidents.getidentname(const aident: identty;
                                          out name: identnamety): boolean;
                             //true if found
begin
 result:= fidentlist.identname(aident,name);
end;

function tstringidents.getidentname(const aident: identty): string;
var
 lstr1: lstringty;
begin
 if getidentname(aident,lstr1) then begin
  result:= lstringtostring(lstr1);
 end
 else begin
  result:= '°';
 end;
end;

function tstringidents.getidentnamel(const aident: identty): lstringty;
begin
{$ifdef mse_checkinternalerror}
 if not
{$endif}
 getidentname(aident,result)
{$ifdef mse_checkinternalerror} then begin
  internalerror(ie_parser,'20151111A');
 end;
{$else}
 ;
{$endif}
end;

(*
function tstringidents.getidentnamel(const aeledata: pointer): lstringty;
begin
{$ifdef mse_checkinternalerror}
 if not
{$endif}
 getidentname(datatoele(aeledata)^.header.name,result)
{$ifdef mse_checkinternalerror} then begin
  internalerror(ie_parser,'20151124A');
 end;
{$else}
 ;
{$endif}
end;
*)
function tstringidents.getidentname2(const aident: identty): identnamety;
begin
{$ifdef mse_checkinternalerror}
 if not
{$endif}
 getidentname(aident,result)
{$ifdef mse_checkinternalerror} then begin
  internalerror(ie_parser,'20151111B');
 end;
{$else}
 ;
{$endif}
end;

function tstringidents.getidentnamep(const aident: identty): pchar;
begin
 result:= getidentnamel(aident).po;
end;

(*
function tstringidents.getidentname2(const aeledata: pointer): identnamety;
begin
{$ifdef mse_checkinternalerror}
 if not
{$endif}
 getidentname(datatoele(aeledata)^.header.name,result)
{$ifdef mse_checkinternalerror} then begin
  internalerror(ie_parser,'20151111C');
 end;
{$else}
 ;
{$endif}
end;
*)
const
 hashmask: array[0..7] of longword =
  (%10101010101010100101010101010101,
   %01010101010101011010101010101010,
   %11001100110011000011001100110011,
   %00110011001100111100110011001100,
   %01100110011001111001100110011000,
   %10011001100110000110011001100111,
   %11100110011001100001100110011001,
   %00011001100110011110011001100110
   );

function hashkey1(const akey: lstringty): hashvaluety;
var
 int1: integer;
 wo1: word;
 by1: byte;
 po1: pchar;
begin
 result:= 0;
 if akey.len > 0 then begin
  wo1:= hashmask[0];
  po1:= akey.po;
  for int1:= 0 to akey.len-1 do begin
  {$ifdef caseinsensitive}
   by1:= byte(lowerchars[po1[int1]]);
  {$else}
   by1:= byte(po1[int1]);
  {$endif}
   wo1:= ((wo1 + by1) xor by1);
  end;
  wo1:= (wo1 xor wo1 shl 7);
  result:= (wo1 or (longword(wo1) shl 16)) xor hashmask[akey.len and $7];
 end;
end;

function tstringidents.storestring(const astr: lstringty): identnamety;
                                                   //offset from stringdata
var
 int1,int2: integer;
 po1: pidentbufferty;
begin
 int1:= fstringindex;
 int2:= astr.len;
 fstringindex:= (fstringindex + int2 + 1 + sizeof(identbufferheaderty) + 3)
                                                    and not 3;        //align 4
 if fstringindex >= fstringlen then begin
  fstringlen:= fstringindex*2+mindatasize;
  reallocmem(fstringdata,fstringlen);
  fillchar((pchar(pointer(fstringdata))+int1)^,fstringlen-int1,0);
                 //for terminating 0
 end;
 po1:= fstringdata + int1;
 po1^.header.len:= int2;
 move(astr.po^,po1^.data,int2);
 result.offset:= int1;
 nextident();
end;

constructor tstringidents.create();
begin
 fidentlist:= tindexidenthashdatalist.create(self);
 clear();
end;

destructor tstringidents.destroy();
begin
 clear();
 fidentlist.free();
end;

procedure tstringidents.clear();
begin
 fidentlist.clear;
 if fstringdata <> nil then begin
  freemem(fstringdata);
  fstringdata:= nil;
 end;
 fstringindex:= 0;
 fstringlen:= 0;
 fstringident:= strid9;
 nextident();
end;
{
procedure tstringidents.init();
begin
 fstringident:= idstart; //invalid
 nextident();
end;
}
{ tidenthashdatalist }
{
constructor tidenthashdatalist.create(const asize: int32);
begin
 inherited create(asize);
end;
}
function tidenthashdatalist.hashkey(const akey): hashvaluety;
begin
 result:= identty(akey);
end;

function tidenthashdatalist.checkkey(const akey;
                            const aitem: phashdataty): boolean;
begin
 result:= identty(akey) = pidenthashdataty(aitem)^.data.header.ident;
end;

function tidenthashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(identhashdataty);
end;

function tidenthashdatalist.adduniquedata(const akey: identty;
                                         out adata: pidenthashdataty): boolean;
begin
 adata:= pidenthashdataty(internalfind(akey));
 result:= adata = nil;
 if result then begin
  adata:= pidenthashdataty(internaladd(akey));
  adata^.data.header.ident:= akey;
// end
// else begin
//  inc(adata,sizeof(hashheaderty));
 end;
end;

{ tindexidenthashdatalist }

constructor tindexidenthashdatalist.create(const aowner: tstringidents);
begin
 fowner:= aowner;
 inherited create();
 fidents:= tidenthashdatalist.create();
end;

destructor tindexidenthashdatalist.destroy;
begin
 inherited;
 fidents.free;
end;

function tindexidenthashdatalist.getrecordsize(): int32;
begin
 result:= sizeof(indexidenthashdataty);
end;

procedure tindexidenthashdatalist.clear;
begin
 inherited;
 fidents.clear;
end;

function tindexidenthashdatalist.identname(const aident: identty;
                   out aname: lstringty): boolean;
var
 po1: pidenthashdataty;
 po2: pidentbufferty;
begin
 po1:= pidenthashdataty(fidents.internalfind(aident,aident));
 if po1 <> nil then begin
  result:= true;
  po2:= pointer(fowner.fstringdata)+po1^.data.keyname;
  aname.len:= po2^.header.len;
  aname.po:= @po2^.data;
 end
 else begin
  result:= false;
  aname.po:= nil;
  aname.len:= 0;
 end;
end;

function tindexidenthashdatalist.identname(const aident: identty;
               out aname: identnamety): boolean;
var
 po1: pidenthashdataty;
begin
 po1:= pidenthashdataty(fidents.internalfind(aident,aident));
 if po1 <> nil then begin
  result:= true;
  aname.offset:= po1^.data.keyname;
 end
 else begin
  result:= false;
  aname.offset:= -1;
 end;
end;

function tindexidenthashdatalist.getident(const aname: lstringty):
                                                     pindexidenthashdataty;
var
 po1: pindexidenthashdataty;
 ha1: hashvaluety;
begin
{
 if aname.len > maxidentlen then begin
  errormessage(err_identtoolong,[lstringtostring(aname)]);
  result:= nil;
  exit;
 end;
}
 ha1:= hashkey1(aname);
 po1:= pointer(internalfind(aname,ha1));
 if po1 = nil then begin
  po1:= pointer(internaladdhash(ha1));
  with po1^.data do begin
   data:= fowner.fstringident;
   key:= fowner.storestring(aname);
   with pidenthashdataty(fidents.internaladdhash(data))^.data do begin
    header.ident:= data;
    keyname:= key.offset;
   end;
  end;
 end;
 result:= po1;
// result:= po1^.data.data;
end;

function tindexidenthashdatalist.hashkey(const akey): hashvaluety;
var
 po1,po2: pchar;
 wo1: word;
 by1: byte;
begin
 with indexidentdataty(akey) do begin
  po1:= fowner.fstringdata + key.offset + sizeof(identbufferheaderty);
  po2:= po1;
  wo1:= hashmask[0];
  while true do begin
  {$ifdef caseinsensitive}
   by1:= byte(lowerchars[po1^]);
  {$else}
   by1:= byte(po1^);
  {$endif}
   if by1 = 0 then begin
    break;
   end;
   wo1:= ((wo1 + by1) xor by1);
  end;
  wo1:= (wo1 xor wo1 shl 7);
  result:= (wo1 or (longword(wo1) shl 16)) xor hashmask[(po1-po2) and $7];
 end;
end;

function tindexidenthashdatalist.checkkey(const akey;
                                const aitem: phashdataty): boolean;
var
 po1,po2: pchar;
 int1: integer;
begin
 result:= false;
 with lstringty(akey) do begin
  po1:= po;
  po2:= fowner.fstringdata + pindexidenthashdataty(aitem)^.data.key.offset +
                                                  sizeof(identbufferty);
  for int1:= 0 to len-1 do begin
  {$ifdef caseinsensitive}
   if lowerchars[po1[int1]] <> lowerchars[po2[int1]] then begin
  {$else}
   if po1[int1] <> po2[int1] then begin
  {$endif}
    exit;
   end;
  end;
  result:= po2[len] = #0;
 end;
end;

end.
