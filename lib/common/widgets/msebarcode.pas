{ MSEgui Copyright (c) 2011-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msebarcode;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,classes,mclasses,msewidgets,msebitmap,msegraphics,mseclasses,
 msegraphutils,
 msestrings,msegui,msemenus,mseguiglob;

type
 barcodestatety = (bcs_bitmapvalid,bcs_layoutvalid,bcs_painting);
 barcodestatesty = set of barcodestatety;
 bitmapnumty = (bmn_1,bmn_2);

 tcustombarcode = class;

 tbarcodefont = class(tfont)
  private
   fowner: tcustombarcode;
  protected
   procedure dochanged(const changed: canvasstatesty;
                                    const nochange: boolean); override;
  public
   constructor create(const aowner: tcustombarcode); reintroduce;
 end;

 barcodeoptionty = (bco_calcchecksum);
 barcodeoptionsty = set of barcodeoptionty;

 tcustombarcode = class(tpublishedwidget)
  private
   fbitmap1: tbitmap;
   fbitmap2: tbitmap;
   fcellcount: integer;
   fcelldata1: pbyte;
   fcelldata2: pbyte;
   fcolorbar: colorty;
   fcolorspace: colorty;
   fvalue: msestring;
   fcode: msestring;
   fcoderect: rectty;
   fsubcliprects: rectarty;
   ffontbar: tbarcodefont;
   fdirection: graphicdirectionty;
   foptions: barcodeoptionsty;
   procedure setcolorbar(const avalue: colorty);
   procedure setcolorspace(const avalue: colorty);
   procedure setvalue(const avalue: msestring);
   procedure setcell1(const adata: pbyte; const aindex: integer;
               const avalue: boolean);
   procedure setfontbar(const avalue: tbarcodefont);
   procedure setdirection(const avalue: graphicdirectionty);
   procedure setoptions(const avalue: barcodeoptionsty);
  protected
   fbarrect1: rectty;
   fbarrect2: rectty;
   fstate: barcodestatesty;
   procedure adjustrect(var arect: rectty);
   procedure checkbitmap;
   procedure calcbitmap; virtual; abstract;
   procedure updatelayout(const asize: sizety); virtual;
   procedure checkvalue; virtual;
   procedure dopaint2(const acanvas: tcanvas); virtual;
   procedure dopaintforeground(const acanvas: tcanvas); override;
   procedure clientrectchanged; override;
   procedure change(const alayout: boolean);
   procedure setcell(const anum: bitmapnumty; const aindex: integer;
                                    const avalue: boolean = true); overload;
   procedure setcell(const anum: bitmapnumty;
                                    const aindex: array of integer); overload;
   procedure subcliprect(const arect: rectty);
   procedure drawtext(const acanvas: tcanvas; const atext: msestring;
                         const adest: rectty; const aheight: integer);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property direction: graphicdirectionty read fdirection
                      write setdirection default gd_right;
   property colorbar: colorty read fcolorbar write setcolorbar
                                               default cl_black;
   property colorspace: colorty read fcolorspace write setcolorspace
                                               default cl_transparent;
   property value: msestring read fvalue write setvalue;
   property fontbar: tbarcodefont read ffontbar write setfontbar;
   property options: barcodeoptionsty read foptions write setoptions default [];
 end;

 barcodekindty = (bk_none,bk_gtin_13,bk_gtin_8);

 tcustombarcode1 = class(tcustombarcode)
  private
   fkind: barcodekindty;
   procedure setkind(const avalue: barcodekindty);
  protected
   ffontheight: integer;
   frect1: rectty;
   frect2: rectty;
   frect3: rectty;
   procedure checkvalue; override;
   procedure calcbitmap; override;
   procedure updatelayout(const asize: sizety); override;
   procedure dopaint2(const acanvas: tcanvas); override;
  public
   property kind: barcodekindty read fkind write setkind default bk_none;
 end;

 tbarcode = class(tcustombarcode1)
  published
   property options;
   property kind;
   property direction;
   property colorbar;
   property colorspace;
   property value;
   property fontbar;
 end;

function encodegtin13(const avalue: int64): msestring; //'' on error
function decodegtin13(const avalue: msestring): int64; //-1 on error

implementation
uses
 rtlconsts,msebits,msedrawtext,mseformatstr;

function gtin13checksum(const avalue: int64): int32;
var
 i1,i2,i3: int32;
 i4: int64;
begin
 i2:= 0;
 i4:= avalue;
 for i1:= 0 to 11 do begin
  i3:= i4 mod 10;
  if odd(i1) then begin
   i2:= i2 + i3;
  end
  else begin
   i2:= i2 + i3*3;
  end;
  i4:= i4 div 10;
 end;
 result:= (10 - i2 mod 10) mod 10;
end;

function encodegtin13(const avalue: int64): msestring; //'' on error
begin
 result:= '';
 if (avalue >= 0) and (avalue <= 999999999999) then begin
  result:= inttostrmse(avalue*10+int64(gtin13checksum(avalue)));
 end;
end;

function decodegtin13(const avalue: msestring): int64; //-1 on error
var
 i1,i2: int64;
begin
 result:= -1;
 if trystrtoint64(avalue,i1) then begin
  i2:= i1 div 10;
  if gtin13checksum(i2) = i1 mod 10 then begin
   result:= i2;
  end;
 end;
end;

type
  patterngtin13ty = (pgt13_l0,pgt13_l1,pgt13_r,pgt13_13);

const
 textflags: array[graphicdirectionty] of textflagsty =
             //gd_right
            ([tf_xcentered,tf_ycentered],
             //gd_up
             [tf_xcentered,tf_ycentered,tf_rotate90],
             //gd_left
             [tf_xcentered,tf_ycentered,tf_rotate180],
             //gd_down
             [tf_xcentered,tf_ycentered,tf_rotate180,tf_rotate90],
             //gd_none
             [tf_xcentered,tf_ycentered]);

 cellcounts: array[barcodekindty] of integer =
  //bk_none,bk_gtin_13,    bk_gtin_8
  (0,       3+6*7+5+6*7+3, 3+4*7+5+4*7+3 );
 framesizes: array[barcodekindty] of integer =
  //bk_none,bk_gtin_13,    bk_gtin_8
  (0,       2*7,           2*7);
 charwidths: array[barcodekindty] of integer =
  //bk_none,bk_gtin_13,    bk_gtin_8
  (0,       7,             7);
  {
 spacecounts: array[barcodekindty] of integer =
  //bk_none,bk_gtin_13
  (0,       3*3+2*7);
 charcounts: array[barcodekindty] of integer =
  //bk_none,bk_gtin_13
  (1,       13);
  }
  patterngtin13: array[patterngtin13ty,0..9] of byte =
//    0       1       2       3       4       5       6       7       8       9
//0001101 0011001 0010011 0111101 0100011 0110001 0101111 0111011 0110111 0001011 _l0
 (($0d,    $19,    $13,    $3d,    $23,    $31,    $2f,    $3b,    $37,    $0b),//_13 0
//0100111 0110011 0011011 0100001 0011101 0111001 0000101 0010001 0001001 0010111 _l1
  ($27,    $33,    $1b,    $21,    $1d,    $39,    $05,    $11,    $09,    $17),//_13 1
//1110010 1100110 1101100 1000010 1011100 1001110 1010000 1000100 1001000 1110100 _r
  ($72,    $66,    $6c,    $42,    $5c,    $4e,    $50,    $44,    $48,    $74),
// 000000  001011  001101  001110  010011  011001  011100  010101  010110  011010 _13
  ($00,    $0b,    $0d,    $0e,    $13,    $19,    $1c,    $15,    $16,    $1a)
     );

 reversemask7: array[0..6] of byte =
 //1000000 0100000 0010000 0001000 0000100 0000010 0000001
 (  $40,    $20,    $10,    $08,    $04,    $02,    $01);
 reversemask6: array[0..5] of byte =
 //0100000 0010000 0001000 0000100 0000010 0000001
 (  $20,    $10,    $08,    $04,    $02,    $01);

{ tcustombarcode }

constructor tcustombarcode.create(aowner: tcomponent);
begin
 fcolorbar:= cl_black;
 fcolorspace:= cl_transparent;
 ffontbar:= tbarcodefont.create(self);
 inherited;
 fbitmap1:= tbitmap.create(bmk_mono{true});
 fbitmap2:= tbitmap.create(bmk_mono{true});
end;

destructor tcustombarcode.destroy;
begin
 fbitmap1.free;
 fbitmap2.free;
 ffontbar.free;
 inherited;
end;

procedure tcustombarcode.checkbitmap;
var
 int1: integer;
begin
 if fstate * [bcs_bitmapvalid,bcs_layoutvalid] <>
                        [bcs_bitmapvalid,bcs_layoutvalid] then begin
  checkvalue;
  if not (bcs_layoutvalid in fstate) then begin
   fsubcliprects:= nil;
   fcellcount:= 0;
   fbarrect1:= mr(nullpoint,fcoderect.size);
   if fdirection in [gd_up,gd_down] then begin
    with fbarrect1 do begin
     int1:= cx;
     cx:= cy;
     cy:= int1;
    end;
   end;
   fbarrect2:= fbarrect1;
   if fdirection in [gd_up,gd_down] then begin
    updatelayout(ms(fcoderect.cy,fcoderect.cx));
   end
   else begin
    updatelayout(fcoderect.size);
   end;
   adjustrect(fbarrect1);
   adjustrect(fbarrect2);
   for int1:= 0 to high(fsubcliprects) do begin
    adjustrect(fsubcliprects[int1]);
   end;
  end;
  fcelldata1:= nil;
  fcelldata2:= nil;
  if (fcode = '') or (fcellcount <= 0) then begin
   fbitmap1.clear;
   fbitmap2.clear;
  end
  else begin
   if fdirection in [gd_up,gd_down] then begin
    fbitmap1.size:= ms(1,fcellcount);
    fbitmap2.size:= ms(1,fcellcount);
    fcelldata1:= fbitmap1.scanline[0];
    fcelldata2:= fbitmap2.scanline[0];
    fillchar(fcelldata1^,fcellcount*4,0);
    fillchar(fcelldata2^,fcellcount*4,0);
   end
   else begin
    fbitmap1.size:= ms(fcellcount,1);
    fbitmap2.size:= ms(fcellcount,1);
    fcelldata1:= fbitmap1.scanline[0];
    fcelldata2:= fbitmap2.scanline[0];
    fillchar(fcelldata1^,((fcellcount+31) div 32) * 4,0);
    fillchar(fcelldata2^,((fcellcount+31) div 32) * 4,0);
   end;
   calcbitmap;
  end;
  fstate:= fstate + [bcs_bitmapvalid,bcs_layoutvalid];
 end;
end;

procedure tcustombarcode.dopaintforeground(const acanvas: tcanvas);
var
 reg1: regionty;
 int1: integer;
begin
 inherited;
 checkbitmap;
 if fsubcliprects <> nil then begin
  reg1:= acanvas.copyclipregion;
  for int1:= 0 to high(fsubcliprects) do begin
   acanvas.subcliprect(fsubcliprects[int1]);
  end;
 end;
 fbitmap1.paint(acanvas,fbarrect1,[al_stretchx,al_stretchy,al_or],
                    fcolorbar,fcolorspace);
 fbitmap2.paint(acanvas,fbarrect2,[al_stretchx,al_stretchy,al_or],
                    fcolorbar,cl_transparent);
 if fsubcliprects <> nil then begin
  acanvas.clipregion:= reg1;
 end;
 include(fstate,bcs_painting);
 try
  dopaint2(acanvas);
 finally
  exclude(fstate,bcs_painting);
 end;
end;

procedure tcustombarcode.change(const alayout: boolean);
begin
 exclude(fstate,bcs_bitmapvalid);
 if alayout then begin
  exclude(fstate,bcs_layoutvalid);
 end;
 invalidate;
end;

procedure tcustombarcode.setcell1(const adata: pbyte; const aindex: integer;
               const avalue: boolean);
var
 po1: pbyte;
 int1: integer;
begin
 if (aindex < 0) or (aindex >= fcellcount) then begin
  tlist.error(slistindexerror,aindex);
 end;
 int1:= aindex;
 if fdirection in [gd_left,gd_up] then begin
  int1:= fcellcount-aindex-1;
 end;
 if fdirection in [gd_right,gd_left] then begin
  po1:= pbyte(pchar(adata)+(int1 div 8));
  if avalue then begin
   po1^:= po1^ or bits[int1 and $07];
  end
  else begin
   po1^:= po1^ and not bits[int1 and $07];
  end;
 end
 else begin
  po1:= pbyte(pchar(adata)+(int1 * 4));
  if avalue then begin
   plongword(po1)^:= $ffffffff;
  end
  else begin
   po1^:= 0;
  end;
 end;
end;

procedure tcustombarcode.setcell(const anum: bitmapnumty; const aindex: integer;
               const avalue: boolean = true);
begin
 if anum = bmn_1 then begin
  setcell1(fcelldata1,aindex,avalue);
 end
 else begin
  setcell1(fcelldata2,aindex,avalue);
 end;
end;

procedure tcustombarcode.setcell(const anum: bitmapnumty;
                                     const aindex: array of integer);
var
 int1: integer;
 po1: pbyte;
begin
 po1:= fcelldata2;
 if anum = bmn_1 then begin
  po1:= fcelldata1;
 end;
 for int1:= 0 to high(aindex) do begin
  setcell1(po1,aindex[int1],true);
 end;
end;

procedure tcustombarcode.setcolorbar(const avalue: colorty);
begin
 if fcolorbar <> avalue then begin
  fcolorbar:= avalue;
  invalidate;
 end;
end;

procedure tcustombarcode.setcolorspace(const avalue: colorty);
begin
 if fcolorspace <> avalue then begin
  fcolorspace:= avalue;
  invalidate;
 end;
end;

procedure tcustombarcode.setvalue(const avalue: msestring);
begin
 if fvalue <> avalue then begin
  fvalue:= avalue;
//  checkvalue;
  change(false);
 end;
end;

procedure tcustombarcode.checkvalue;
begin
 fcode:= fvalue;
end;

procedure tcustombarcode.updatelayout(const asize: sizety);
begin
 //dummy
end;

procedure tcustombarcode.clientrectchanged;
begin
 inherited;
 fcoderect:= innerclientrect;
 change(true);
end;

procedure tcustombarcode.subcliprect(const arect: rectty);
begin
 setlength(fsubcliprects,high(fsubcliprects)+2);
 fsubcliprects[high(fsubcliprects)]:= arect;
end;

procedure tcustombarcode.drawtext(const acanvas: tcanvas;
               const atext: msestring; const adest: rectty;
               const aheight: integer);
var
 int1: integer;
begin
 int1:= ffontbar.height;
 ffontbar.height:= aheight;
 msedrawtext.drawtext(acanvas,atext,adest,textflags[fdirection],ffontbar);
 ffontbar.height:= int1;
end;

procedure tcustombarcode.setfontbar(const avalue: tbarcodefont);
begin
 ffontbar.assign(avalue);
end;

procedure tcustombarcode.dopaint2(const acanvas: tcanvas);
begin
 //dummy
end;

procedure tcustombarcode.setdirection(const avalue: graphicdirectionty);
begin
 if fdirection <> avalue then begin
  if not (csreading in componentstate) then begin
   changedirection(avalue,fdirection);
  end
  else begin
   fdirection:= avalue;
  end;
  change(true);
 end;
end;

procedure tcustombarcode.adjustrect(var arect: rectty);
var
 pt1: pointty;
 int1: integer;
begin
 pt1:= arect.pos;
 with arect do begin
  case fdirection of
   gd_up: begin
    pt1.x:= y + fcoderect.x;
    pt1.y:= fcoderect.y + fcoderect.cy - x - cx;
    int1:= arect.cx;
    arect.cx:= arect.cy;
    arect.cy:= int1;
   end;
   gd_left: begin
    pt1.x:= fcoderect.x + fcoderect.cx - x - cx;
    pt1.y:= fcoderect.y + fcoderect.cy - y - cy;
   end;
   gd_down: begin
    pt1.x:= fcoderect.x + fcoderect.cx - y - cy;
    pt1.y:= fcoderect.y + x;
    int1:= arect.cx;
    arect.cx:= arect.cy;
    arect.cy:= int1;
   end;
   else begin //gd_right
    pt1.x:= fcoderect.x + x;
    pt1.y:= fcoderect.y + y;
   end;
  end;
 end;
 arect.pos:= pt1;
end;

procedure tcustombarcode.setoptions(const avalue: barcodeoptionsty);
begin
 if foptions <> avalue then begin
  foptions:= avalue;
  change(false);
//  checkvalue;
 end;
end;

{ tcustombarcode1 }

procedure tcustombarcode1.calcbitmap;
var
 cellindex: integer;

 procedure putcells(const apattern: byte);
 var
  int1: integer;
 begin
  for int1:= 0 to high(reversemask7) do begin
   if apattern and reversemask7[int1] <> 0 then begin
    setcell(bmn_2,cellindex);
   end;
   inc(cellindex);
  end;
 end;

var
 int1: integer;
 digits: array[0..11] of byte;
 by2: byte;
 pat1: patterngtin13ty;
begin
 case fkind of
  bk_gtin_8: begin
   setcell(bmn_1,[0,2,32,34,64,66]); //start, center, stop
   for int1:= 6 to 13 do begin
    digits[int1-6]:= ord(fcode[int1])-ord('0');
   end;
   cellindex:= 3;
   for int1:= 0 to 3 do begin
    putcells(patterngtin13[pgt13_l0,digits[int1]]);
   end;
   cellindex:= 36;
   for int1:= 4 to 7 do begin
    putcells(patterngtin13[pgt13_r,digits[int1]]);
   end;
  end;
  bk_gtin_13: begin
   setcell(bmn_1,[0,2,46,48,92,94]); //start, center, stop
   for int1:= 2 to 13 do begin
    digits[int1-2]:= ord(fcode[int1])-ord('0');
   end;
   by2:= patterngtin13[pgt13_13,ord(fcode[1])-ord('0')];
   cellindex:= 3;
   for int1:= 0 to 5 do begin
    pat1:= pgt13_l0;
    if by2 and reversemask6[int1] <> 0 then begin
     pat1:= pgt13_l1;
    end;
    putcells(patterngtin13[pat1,digits[int1]]);
   end;
   cellindex:= 50;
   for int1:= 6 to 11 do begin
    putcells(patterngtin13[pgt13_r,digits[int1]]);
   end;
  end;
   else; // For case statment added to make compiler happy.
 end;
end;

procedure tcustombarcode1.setkind(const avalue: barcodekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  change(true);
 end;
end;

procedure tcustombarcode1.checkvalue;
var
 int1,int2,int3: integer;
 by1: byte;
 po1: pmsechar;
 mch1: msechar;
begin
 inherited;
 if fcode <> '' then begin
  case fkind of
   bk_gtin_13,bk_gtin_8: begin
    int2:= length(fcode);
    setlength(fcode,13); //unique instance
    po1:= pointer(fcode);
    for int1:= 0 to int2-1 do begin
     mch1:= (po1+int1)^;
     if (mch1 < '0') or (mch1 > '9') then begin
      (po1+int1)^:= '0';
     end;
    end;
    if int2 < 13 then begin
     move(po1^,(po1+13-int2)^,int2*sizeof(msechar));
     for int1:= 0 to 12-int2 do begin
      (po1+int1)^:= '0';
     end;
    end;
    if bco_calcchecksum in foptions then begin
     int2:= 0;
     int3:= 0;
     for int1:= 12 downto 1 do begin
      if odd(int1) then begin
       int2:= int2 + ord((po1+int1)^) - ord('0');  //*1
      end
      else begin
       int3:= int3 + ord((po1+int1)^) - ord('0');  //*3
      end;
     end;
     by1:= (3*int3+int2) mod 10;
     if by1 <> 0 then begin
      by1:= (10-by1) mod 10;         //controllsum
     end;
     move((po1+1)^,po1^,12*sizeof(msechar));
     (po1+12)^:= msechar(by1+ord('0'));
    end;
   end;
    else; // For case statment added to make compiler happy.
  end;
 end;
end;

procedure tcustombarcode1.updatelayout(const asize: sizety);
var
 cellsize1: real;
 charwidth1: real;
 framesize1: integer;
 int1: integer;
begin
 fcellcount:= cellcounts[fkind];
 if fcellcount > 0 then begin
  framesize1:= framesizes[fkind];
  cellsize1:= asize.cx / (fcellcount+framesize1);
  charwidth1:= charwidths[fkind]*cellsize1;
  with fbarrect1 do begin //center barrect
   cx:= round(fcellcount*cellsize1);
   x:= (asize.cx-cx) div 2;
  end;
  fbarrect2:= fbarrect1;
  if ffontbar.height = 0 then begin
   ffontheight:= round(charwidth1*1.5);
  end
  else begin
   ffontheight:= ffontbar.height;
  end;
  fbarrect2.cy:= fbarrect2.cy - round(ffontheight*1.2);

  case fkind of
   bk_gtin_13,bk_gtin_8: begin
    with frect1 do begin
     int1:= round(charwidth1);
     x:= fbarrect1.x - int1;
     y:= asize.cy - ffontheight;
     cx:= int1;
     cy:= ffontheight;
    end;
    with frect2 do begin
     y:= frect1.y;
     cy:= frect1.cy;
     x:= fbarrect1.x + round(3*cellsize1);
     int1:= 6;
     if fkind = bk_gtin_8 then begin
      int1:= 4;
     end;
     cx:= round(int1*charwidth1);
    end;
    frect3:= frect2;
    with frect3 do begin
     x:= fbarrect1.x + round((3+int1*7+5)*cellsize1);
    end;
    adjustrect(frect1);
    adjustrect(frect2);
    adjustrect(frect3);
   end;
    else; // For case statment added to make compiler happy.
  end;
 end;
end;

procedure tcustombarcode1.dopaint2(const acanvas: tcanvas);
begin
 inherited;
 if fcode <> '' then begin
  case fkind of
   bk_gtin_13: begin
    drawtext(acanvas,fcode[1],frect1,ffontheight);
    drawtext(acanvas,copy(fcode,2,6),frect2,ffontheight);
    drawtext(acanvas,copy(fcode,8,6),frect3,ffontheight);
   end;
   bk_gtin_8: begin
    drawtext(acanvas,copy(fcode,6,4),frect2,ffontheight);
    drawtext(acanvas,copy(fcode,10,4),frect3,ffontheight);
   end;
    else; // For case statment added to make compiler happy.
  end;
 end;
end;

{ tbarcodefont }

constructor tbarcodefont.create(const aowner: tcustombarcode);
begin
 fowner:= aowner;
 inherited create;
end;

procedure tbarcodefont.dochanged(const changed: canvasstatesty;
               const nochange: boolean);
begin
 inherited;
 if not nochange and not(bcs_painting in fowner.fstate) then begin
  fowner.change(cs_font in changed);
 end;
end;

end.
