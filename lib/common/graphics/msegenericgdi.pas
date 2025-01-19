{ MSEgui Copyright (c) 2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegenericgdi;
//
// under construction
// 
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
//{$checkpointer on}
uses
 mseguiglob,msegraphics,msetypes,msegraphutils 
{$ifdef usesdl},sdl4msegui{$endif};
type
 rectextentty = integer;
 prectextentty = ^rectextentty;
 rectextentaty = array[0..0] of rectextentty;
 prectextentaty = ^rectextentaty;

 rectdataty = record
  gap: rectextentty;
  width: rectextentty;
 end;
 prectdataty = ^rectdataty;
 rectdataaty = array[0..0] of rectdataty;
 prectdataaty = ^rectdataaty;
  
 stripedataty = record //aray[n] of rectdataty
 end;

 stripeheaderty = record
  height: rectextentty; 
  rectcount: rectextentty;
 end;

 stripety = record
  header: stripeheaderty;
  data: stripedataty;    
 end;                  
 pstripety = ^stripety;

 regiondataty = record 
 end;

 regioninfoty = record
  buffersize: ptruint;
  datasize: ptruint;
  rectcount: integer;
  stripecount: integer;
  stripestart: rectextentty;
  stripeend: rectextentty;
  rectstart: rectextentty;    //minint = invalid
  rectend: rectextentty;      //maxint = invalid
  datapo: pstripety;
 end;
 pregioninfoty = ^regioninfoty;

 pointsfprocty = procedure(const gc: gcty; const points: pfpointty;
                                 const count: integer; const close: boolean);
 
procedure gdinotimplemented;
function gdi_regiontorects(const aregion: regionty): rectarty;

procedure gdi_createemptyregion(var drawinfo: drawinfoty);
procedure gdi_createrectregion(var drawinfo: drawinfoty);
procedure gdi_createrectsregion(var drawinfo: drawinfoty);
procedure gdi_destroyregion(var drawinfo: drawinfoty);
procedure gdi_copyregion(var drawinfo: drawinfoty);
procedure gdi_moveregion(var drawinfo: drawinfoty);
procedure gdi_regionisempty(var drawinfo: drawinfoty);
procedure gdi_regionclipbox(var drawinfo: drawinfoty);
procedure gdi_regsubrect(var drawinfo: drawinfoty);
procedure gdi_regsubregion(var drawinfo: drawinfoty);
procedure gdi_regaddrect(var drawinfo: drawinfoty);
procedure gdi_regaddregion(var drawinfo: drawinfoty);
procedure gdi_regintersectrect(var drawinfo: drawinfoty);
procedure gdi_regintersectregion(var drawinfo: drawinfoty);

procedure segmentellipsef(var drawinfo: drawinfoty;
                      const segmentsproc: pointsfprocty);
                      
{$ifdef mse_debugregion}
procedure dumpregion(const atext: string; const aregion: regionty;
                        const nocheck: boolean = false);
{$endif}

implementation
//todo: optimize, especially memory handling, use changebuffer
uses
 msesysutils,sysutils,math{$ifdef mse_debugregion},typinfo,mseformatstr{$endif}
;
 
type
 regopty = (reop_add,reop_sub,reop_intersect);
 
 regionrectstripety = record
  header: stripeheaderty;
  data: rectdataty;
 end;
 regionemptystripety = record
  header: stripeheaderty;
 end;

const
 rowheadersize = 2*sizeof(rectextentty);      //height, colstart
 celldatasize = 2*sizeof(rectextentty);       //width, gap or 0
 
{$ifdef mse_debugregion}

procedure dodumpstripes(po1: pstripety; const stripecount: rectextentty; 
                       s1: rectextentty; out stripeheight: integer);
var
 int1,int2,int3: integer;
 c1: rectextentty;
begin
 stripeheight:= s1;
 for int1:= 0 to stripecount - 1 do begin
  with po1^.header do begin
   debugwriteln(' stripe'+inttostr(int1)+' $'+hextostr(po1)+
                     ' start: '+inttostr(s1)+
                     ' height: '+inttostr(height)+
                     ' end: ' + inttostr(s1+height)+
                     ' rectcount: '+ inttostr(rectcount)
                     );
   int2:= rectcount;
   s1:= s1 + height;
  end;
  inc(po1);
  c1:= 0;
  for int3:= 0 to int2-1 do begin
   c1:= c1+prectextentty(po1)^;
   inc(prectextentty(po1));
   debugwriteln('  '+inttostr(int3)+' start: '+inttostr(c1)+' width: '+
                 inttostr(prectextentty(po1)^));
   c1:= c1+prectextentty(po1)^;
   inc(prectextentty(po1));
  end;
 end;
 stripeheight:= s1-stripeheight;
end;

procedure dumpstripes(const atext: string; const astripe: pstripety;
                           const stripecount: rectextentty;
                           const stripestart: rectextentty);
var
 int1: integer;
begin
 if astripe = nil then begin
  debugwriteln('****'+atext+' NIL');
 end
 else begin
  debugwriteln('****'+atext+' '+
                    'stripecount: '+inttostr(stripecount)+
                    ' stripestart: '+inttostr(stripestart));
  dodumpstripes(astripe,stripecount,stripestart,int1);
 end;
end;

procedure dumpregion(const atext: string; const aregion: regionty;
                                   const nocheck: boolean = false);
var
 stripeheight: integer;
begin
 if aregion = 0 then begin
  debugwriteln('*****'+atext+' NIL');
 end
 else begin
  with pregioninfoty(aregion)^ do begin
   debugwriteln('*****'+atext+' '+
                    'stripecount: '+inttostr(stripecount)+
                    ' stripestart: '+inttostr(stripestart)+
                    ' stripeend: '+inttostr(stripeend)+
                    ' rectstart: '+inttostr(rectstart)+
                    ' rectend: '+inttostr(rectend)+
                    ' rectcount: '+ inttostr(rectcount)+
                    ' datasize: '+inttostr(datasize)+
                    ' buffersize: '+inttostr(buffersize)
                    );
   dodumpstripes(datapo,stripecount,stripestart,stripeheight);
   if not nocheck and (stripeheight <> stripeend-stripestart) then begin
    debugwriteln('     *** ERROR *** stripeheight expected '+
      inttostr(stripeheight)+' stripeend '+inttostr(stripeheight+stripestart));
   end;
  end;
 end;
end;

procedure dumpstripe(const atext: string; const astripe: pstripety);
var
 int1: integer;
 c1: rectextentty;
 po1: prectextentty;
begin
 with astripe^.header do begin
  debugwriteln('***'+atext+' height: '+inttostr(height)+
                  ' rectcount: '+inttostr(rectcount));
  po1:= @astripe^.data;
  c1:= 0;
  for int1:= 0 to rectcount - 1 do begin
   c1:= c1+po1^;
   inc(po1);
   debugwriteln('  '+inttostr(int1)+' start: '+inttostr(c1)+' width: '+
                   inttostr(po1^));
   inc(po1);
  end;
 end;
end;

{$endif}

procedure gdinotimplemented;
begin
 guierror(gue_notimplemented);
end;

function calcdatasize(const rowcount,rectcount: integer): ptruint;
                                             {$ifdef FPC} inline;{$endif}
begin
 result:= rowcount*rowheadersize + rectcount*celldatasize;
end;

function stripesize(const astripe: pstripety): integer;
begin
 result:= sizeof(stripeheaderty)+
                astripe^.header.rectcount*sizeof(rectdataty)
end;

procedure incstripe(var astripe: pstripety); {$ifdef FPC} inline;{$endif}
begin
 astripe:= pstripety(pchar(astripe)+sizeof(stripeheaderty)+
                astripe^.header.rectcount*sizeof(rectdataty));
end;

function nextstripe(const astripe: pstripety):pstripety; 
                                            {$ifdef FPC} inline;{$endif}
begin
 result:= pstripety(pchar(astripe)+sizeof(stripeheaderty)+
                astripe^.header.rectcount*sizeof(rectdataty));
end;

function getregmem(const astripecount,arectcount: integer): pregioninfoty;
begin
 getmem(result,sizeof(regioninfoty));
 with result^ do begin
  stripecount:= astripecount;
  rectcount:= arectcount;
  buffersize:=  calcdatasize(stripecount,rectcount);
  datasize:= buffersize;
  rectstart:= maxint;
  rectend:= minint;
  if buffersize > 0 then begin
   getmem(datapo,buffersize);
  end
  else begin
   datapo:= nil;
  end;
 end;
end;

procedure checkbuffersize(var reg: regioninfoty; const sizedelta: ptruint;
                                 var refpointer: pointer);
var
 po1: pointer;
begin
 with reg do begin  
  datasize:= datasize + sizedelta;
  if datasize > buffersize then begin
   buffersize:= 2*buffersize + sizedelta;
   po1:= datapo;
   reallocmem(datapo,buffersize);
   refpointer:= refpointer + (pchar(datapo) - pchar(po1));
  end;
 end;
end;

procedure checkbuffersize(var reg: regioninfoty;
        const stripechange,rectchange: integer; var refpointer: pointer);
begin
 with reg do begin
  checkbuffersize(reg,calcdatasize(stripechange,rectchange),refpointer);
  stripecount:= stripecount + stripechange;
  rectcount:= rectcount + rectchange;
 end;
end;

procedure insertmem(var reg: regioninfoty; const size: ptruint;
                                        var refpointer: pointer);
begin
 checkbuffersize(reg,size,refpointer);
 move(refpointer^,(pchar(refpointer)+size)^,
                reg.datasize-size-(pchar(refpointer)-pchar(reg.datapo)));
end;

procedure insertemptystripe(var reg: regioninfoty;
               const stripe: pstripety; const astart,aheight: rectextentty; 
                                        out start: pstripety);
var
// po1: pointer;
 ext1: rectextentty;
begin
 with reg do begin
//  po1:= datapo;
  start:= stripe;
  insertmem(reg,sizeof(regionemptystripety),start);
  start^.header.height:= aheight;
  start^.header.rectcount:= 0;
  if (stripecount = 0) or (astart < stripestart) then begin
   stripestart:= astart;
   if stripecount = 0 then begin
    stripeend:= astart+aheight;
   end;
  end;
  inc(stripecount);
  ext1:= astart + aheight;
  if ext1 > stripeend then begin
   stripeend:= ext1;
  end;
 end;
end;

procedure copystripe(var reg: regioninfoty;
                           const stripe: pstripety; out start,stop: pstripety);
var
// po1: pointer;
 pui1: ptruint;
 int1: integer;
begin
 with reg do begin
//  po1:= datapo;
  start:= stripe;
  int1:= stripe^.header.rectcount;
  pui1:= sizeof(stripeheaderty) + sizeof(rectdataty)*int1;  
  insertmem(reg,pui1,start);
  stop:= pstripety(pchar(start) + pui1);
  move(stop^,start^,pui1);
  inc(stripecount);
  rectcount:= rectcount + int1;
 end;
end;

function findstripe(const reg: regioninfoty; const start: rectextentty;
                         out astripestart: rectextentty;
                         out below: pstripety): pstripety;
var
 ext1: rectextentty;
 po1: pstripety;
begin
 result:= nil;
 below:= nil;
 astripestart:= 0;
 with reg do begin
  if stripecount > 0 then begin
   ext1:= stripestart;
   if (ext1 <= start) and (start < stripeend) then begin
    po1:= datapo;
    while true do begin
     ext1:= ext1 + po1^.header.height;
     if ext1 > start then begin
      ext1:= ext1-po1^.header.height;
      break;
     end;
     below:= po1;
     inc(pchar(po1),sizeof(stripeheaderty)+
                      po1^.header.rectcount*sizeof(rectdataty));
    end; 
    astripestart:= ext1;
    result:= po1;
   end;
  end;
 end;
end;

procedure splitstripes(var reg: regioninfoty; 
             const astripestart: rectextentty; const astripe: pstripety;
        out start: pstripety; out belowref: ptrint;
        out splitstripecount,splitrectcount: integer);
        //start = first deststripe from astripe
        //belowref = distance datapo to above last deststripe from astripe
var
 po1,po2,po3: pstripety;
 ext1,ext2,ext3: rectextentty;
 stripeend1: rectextentty;
 pui1: ptruint;
 bo1: boolean;
 int1: integer;
begin
 with reg do begin
  belowref:= -1;
  splitstripecount:= 1;
  stripeend1:= astripestart+astripe^.header.height;
  if (stripecount = 0) or (astripestart <= stripestart) then begin
   ext1:= stripestart;
   bo1:= (stripecount = 0) or (stripeend1 < ext1);
   if bo1 then begin
    ext2:= astripe^.header.height;
   end
   else begin
    ext2:= stripestart-astripestart;
   end;
   if (astripestart = stripestart) and (stripecount > 0) then begin
    start:= datapo;
   end
   else begin
    insertemptystripe(reg,datapo,astripestart,ext2,start);
   end;
   if bo1 and (stripecount > 1) then begin
    po1:= datapo;
    ext2:= astripestart+astripe^.header.height;
    insertemptystripe(reg,
          pstripety(pchar(start)+sizeof(regionemptystripety)),
                                                       ext2,ext1-ext2,po2);
    pui1:= pchar(datapo)-pchar(po1); //follow reallocmem
    start:= pstripety(pchar(start)+pui1);
   end;
  end
  else begin
   if astripestart >= stripeend then begin
    if astripestart = stripeend then begin
     po1:= datapo;
     for int1:= stripecount-2 downto 0 do begin
      incstripe(po1);
     end;             //current last
     belowref:= pchar(po1)-pchar(datapo);
     insertemptystripe(reg,
            pstripety(pchar(datapo)+calcdatasize(stripecount,rectcount)),
                  astripestart,astripe^.header.height,start);
    end
    else begin
     insertemptystripe(reg,
            pstripety(pchar(datapo)+calcdatasize(stripecount,rectcount)),
                  stripeend,astripestart-stripeend,po1);
     insertemptystripe(reg,
            pstripety(pchar(datapo)+calcdatasize(stripecount,rectcount)),
                  astripestart,astripe^.header.height,start);
    end;
   end
   else begin
    start:= findstripe(reg,astripestart,ext1,po1);
    if ext1 <> astripestart then begin
     belowref:= pchar(start)-pchar(datapo);
     ext2:= astripestart-ext1;
     ext3:= start^.header.height-ext2;
     start^.header.height:= ext2;
     copystripe(reg,start,po1,start);
     start^.header.height:= ext3;
    end
    else begin
     if po1 <> nil then begin
      belowref:= pchar(po1)-pchar(datapo);
     end;
    end;
   end;
  end;
  po1:= start;
  ext1:= astripestart;
  splitrectcount:= 0;
  while true do begin         //find end of range
   splitrectcount:= splitrectcount + po1^.header.rectcount;
   ext1:= ext1 + po1^.header.height;
   if (ext1 >= stripeend1) or (ext1 >= stripeend) then begin
    break;
   end;
   inc(splitstripecount);
   po1:= pstripety(pchar(po1)+sizeof(stripeheaderty)+
                                po1^.header.rectcount*sizeof(rectdataty));
  end;
  if ext1 < stripeend1 then begin
   po1:= datapo;
   insertemptystripe(reg,
            pstripety(pchar(datapo)+calcdatasize(stripecount,rectcount)),
                  stripeend,stripeend1-ext1,po2);
   start:= pstripety(pchar(start)+(pchar(datapo)-pchar(po1)));
   inc(splitstripecount);
  end
  else begin
   if ext1 <> stripeend1 then begin
    ext2:= ext1-stripeend1;
    ext3:= po1^.header.height-ext2;
    po1^.header.height:= ext3;
    po2:= datapo;
    copystripe(reg,po1,po3,po3);
    start:= pstripety(pchar(start)+(pchar(datapo)-pchar(po2)));    
    po3^.header.height:= ext2; 
   end;
  end;
 end;
end;

function getbuffer(var reg: regioninfoty;
                      const stripecount,rectcount: integer;
                      const additionalbuffer: integer): pstripety;
var
 pui1,pui2: ptruint;
begin
 pui1:= calcdatasize(stripecount,rectcount);
 with reg do begin
  pui2:= datasize + pui1 + additionalbuffer;
  if buffersize < pui2 then begin
   reallocmem(datapo,pui2);
   buffersize:= pui2;
  end;
  result:= pstripety(pchar(datapo)+buffersize-pui1);
 end;
end;

type
 regopdataty = record
  counta: rectextentty; //new
  countb: rectextentty; //existing
 end;

function addop(var data: regopdataty): boolean;
begin
 with data do begin
  result:= odd(counta) or odd(countb);
 end;
end;

function subop(var data: regopdataty): boolean;
begin
 with data do begin
  result:= not odd(counta) and odd(countb);
 end;
end;

function intersectop(var data: regopdataty): boolean;
begin
 with data do begin
  result:= odd(counta) and odd(countb);
 end;
end;

type
 regopprocty = function (var data: regopdataty): boolean;
 
const
 regops: array[regopty] of regopprocty = (@addop,@subop,@intersectop);
 
procedure stripeop(var reg: regioninfoty;
                             const astripestart: rectextentty; 
                             const stripe: pstripety; const op: regopty);
var
 d: regopdataty;
 po1,po6,psa1,psb,psb1,psbb1,pd,pd1,pd2: pstripety;
 lastdeststripe: pstripety;
 psbbelowref: ptrint;
 po2,po3: prectextentaty;
// po4: pointer;
// po5: ppointer;
 stripeco,rectco: integer;
 posa,posb,startb,startd,endb: rectextentty;
 ext1,ext2,ext3: rectextentty;
 int1,{int2,}int3: integer;
 bo1: boolean;
 pui1,pui2: ptruint;
 opproc: regopprocty;
 don: boolean;
 dpos: rectextentty;
 dstripeco,drectco: rectextentty;
 pendingmovecount: integer;
 moves,moved: pointer;
const
 endmark = maxint-1; 
begin
{$ifdef mse_debugregion}
 debugwriteln('');
 debugwriteln('********* stripeop '+getenumname(typeinfo(regopty),ord(op)));
 dumpstripes('sourcestripe',stripe,1,astripestart);
 dumpregion('region before split ',ptruint(@reg));
{$endif}
 splitstripes(reg,astripestart,stripe,psb,psbbelowref,stripeco,rectco);
 with reg do begin
  po1:= reg.datapo;
  pd:= getbuffer(reg,stripeco,stripeco*(rectco+stripe^.header.rectcount),
                         stripeco*stripe^.header.rectcount*sizeof(rectdataty));
                              //max
 {$ifdef mse_debugregion}
  dumpregion('region after split ',ptruint(@reg));
  debugwriteln('* stripeco: '+inttostr(stripeco)+' rectco: '+inttostr(rectco));
 {$endif}
  pd1:= pd;
  psb:= pstripety(pchar(psb)+(pchar(datapo)-(pchar(po1))));//follow reallocmem
  psb1:= psb;     //first touched
  opproc:= regops[op];
  drectco:= 0;
  for int1:= stripeco-1 downto 0 do begin
   psa1:= stripe;                                              //new
   pd1^.header.height:= psb1^.header.height;
   pd2:= pd1;   //header backup
   pd1:= @pd1^.data;
   posa:= endmark;
   posb:= endmark;
   dpos:= 0;
   don:= false;
   d.counta:= psa1^.header.rectcount * 2;
   psa1:= @psa1^.data;
   if d.counta > 0 then begin
    posa:= prectextentty(psa1)^;
   end;
   d.countb:= psb1^.header.rectcount * 2;
   psb1:= @psb1^.data;
   if d.countb > 0 then begin
    posb:= prectextentty(psb1)^;
   end;
   startb:= posb;
   startd:= endmark;
   while (d.counta > 0) or (d.countb > 0) do begin
    while posb < posa do begin        //existing
     dec(d.countb);
     if opproc(d) <> don then begin
      don:= not don;
      prectextentty(pd1)^:= posb-dpos;
      dpos:= posb;
      if startd = endmark then begin
       startd:= posb;
      end;
      inc(prectextentty(pd1));
     end;
     inc(prectextentty(psb1));
     if (d.countb = 0) then begin
      endb:= posb;
      posb:= endmark;
      break;
     end;
     posb:= posb + prectextentty(psb1)^;
    end;
    while posa <= posb do begin           //new
     if posb = posa then begin
      if posa = endmark then begin
       break;
      end;
      dec(d.countb);
      inc(prectextentty(psb1));
      if d.countb = 0 then begin
       endb:= posb;
       posb:= endmark;
      end
      else begin
       posb:= posb + prectextentty(psb1)^;
      end;
     end;
     dec(d.counta);
     if opproc(d) <> don then begin
      don:= not don;
      prectextentty(pd1)^:= posa-dpos;
      dpos:= posa;
      if startd = endmark then begin
       startd:= posa;
      end;
      inc(prectextentty(pd1));
     end;
     inc(prectextentty(psa1));
     if (d.counta = 0) then begin
      posa:= endmark;
      break;
     end;
     posa:= posa + prectextentty(psa1)^;
    end;
   end;
   pd2^.header.rectcount:= ((pchar(pd1)-pchar(pd2))-sizeof(stripeheaderty)) 
                                                       div sizeof(rectdataty);
   drectco:= drectco + pd2^.header.rectcount;
   if startd <> endmark then begin  //has result rects
    if startd <= rectstart then begin
     rectstart:= startd;
    end
    else begin
     if startb = rectstart then begin   //higher
      rectstart:= minint; //invalid
     end;
    end;
    if dpos >= rectend then begin
     rectend:= dpos;
    end
    else begin
     if endb = rectend then begin      //lower
      rectend:= maxint; //invalid
     end;
    end;
   end
   else begin        //no result rects
    if startb = rectstart then begin
     rectstart:= minint; //invalid
    end;
    if endb = rectend then begin
     rectend:= maxint;
    end;
   end;
  end;
 {$ifdef mse_debugregion}
  dumpstripes('dest after operation ',pd,stripeco,astripestart);
//  dumpregion('region after operation ',ptruint(@reg));
 {$endif}
         
         //merge stripes in block
         
  psb1:= pd;           //dest
  psbb1:= pd;          //dest buffer
  psa1:= pd;           //init last stripe
  po1:= nextstripe(pd);//source
  int1:= stripeco;
  dstripeco:= int1;
  dec(int1);
  pendingmovecount:= 0;
  moves:= nil; //compiler warning
  moved:= nil; //compiler warning
  while int1 <> 0 do begin             //pack similar stripes
//   psa1:= po1; //backup last stripe
   psa1:= psb1; //backup last stripe
   while (int1 <> 0) and 
                  (po1^.header.rectcount = psbb1^.header.rectcount) do begin
    po2:= @po1^.data;
    po3:= @psbb1^.data;
    bo1:= false;
    for int3:= psbb1^.header.rectcount*2-1 downto 0 do begin
     if po2^[int3] <> po3^[int3] then begin
      bo1:= true; //different
      break;
     end;
    end;
    if bo1 then begin
     break;
    end;
    dec(dstripeco);
    drectco:= drectco - psbb1^.header.rectcount; //merge stripe
    psbb1^.header.height:= psbb1^.header.height + po1^.header.height;
    incstripe(po1);
    dec(int1);
   end;
   if int1 <> 0 then begin
    if pendingmovecount <> 0 then begin
     move(moves^,moved^,pendingmovecount);
    end;
    incstripe(psb1);
    if psb1 <> po1 then begin
     pendingmovecount:= stripesize(po1);
     psbb1:= po1;
     moves:= po1;
     moved:= psb1;
//     move(po1^,psb1^,stripesize(po1)); //first of next group
    end
    else begin
     pendingmovecount:= 0;
     psbb1:= psb1;
    end;
    incstripe(po1);
    dec(int1);
   end
   else begin
    if pendingmovecount <> 0 then begin
     move(moves^,moved^,pendingmovecount);
    end;
   end;
  end;
  lastdeststripe:= psb1;
 {$ifdef mse_debugregion}
  dumpstripes('dest after pack ',pd,dstripeco,astripestart);
//  dumpregion('region after pack',ptruint(@reg));
 {$endif}

  if op <> reop_intersect then begin 
         //merge stripe above
         
   pui1:= calcdatasize(stripeco,rectco);  //old size
   po1:= pstripety(pchar(psb) + pui1);    //first stripe after touched block
   if (pchar(po1) < (pchar(datapo) + datasize)) and 
            (po1^.header.rectcount = psa1^.header.rectcount) then begin
    po3:= @psa1^.data;                     //last stripe in new block
    po2:= @po1^.data;
    bo1:= false;
    for int1:= 0 to psa1^.header.rectcount*2-1 do begin
     if po2^[int1] <> po3^[int1] then begin
      bo1:= true;
      break;
     end;
    end;
    if not bo1 then begin
     psa1^.header.height:= psa1^.header.height + po1^.header.height;
//     po1^.header.height:= psa1^.header.height + po1^.header.height;
       //merge to existing
     dec(stripecount);
     rectcount:= rectcount-psa1^.header.rectcount;
 {$ifdef mse_debugregion}
     dumpstripes('dest after merge above ',pd,dstripeco,astripestart);
     debugwriteln('* stripecoount: '+
                      inttostr(stripecount)+' rectcount: '+inttostr(rectcount));
 {$endif}
     incstripe(po1);
    end;
   end;
 
         //merge stripe below
 
   if (psbbelowref >= 0) then begin
    po6:= pstripety(pchar(datapo)+psbbelowref); //stripe below touched block
    if po6^.header.rectcount = pd^.header.rectcount then begin
     bo1:= false;
     po3:= @pd^.data;         //first stripe in new block
     po2:= @po6^.data;
     for int1:= 0 to pd^.header.rectcount*2-1 do begin
      if po2^[int1] <> po3^[int1] then begin
       bo1:= true;
       break;
      end;
     end;
     if not bo1 then begin
      pd^.header.height:= pd^.header.height + po6^.header.height;
      dec(stripecount);
      rectcount:= rectcount-pd^.header.rectcount;
      psb:= po6;
     end;
    end;
   end;
  {$ifdef mse_debugregion}
   dumpstripes('dest after merge below ',pd,dstripeco,0);
   debugwriteln('* stripecoount: '+
                      inttostr(stripecount)+' rectcount: '+inttostr(rectcount));
  {$endif}
  end
  else begin
   psb:= datapo; //intersect
   stripestart:= astripestart;
   stripeend:= stripestart + stripe^.header.height;
  end;
  if psb = datapo then begin //first stripe
   int1:= 0;
   po6:= pd;
   while (po6^.header.rectcount = 0) and (int1 < dstripeco) do begin
    stripestart:= stripestart + po6^.header.height;
    inc(int1);          
    inc(po6);
   end;
   inc(pd,int1);      //remove leading empty stripes
   dstripeco:= dstripeco-int1;
  end;
  pui2:= calcdatasize(dstripeco,drectco); //new size
  if op = reop_intersect then begin
   datasize:= pui2;
   stripecount:= dstripeco;
   rectcount:= drectco;
   move(pd^,psb^,pui2);  //new data
  end
  else begin
   psb1:= pstripety(pchar(psb)+ pui2);     //new block end
   move(po1^,psb1^,datasize-(pchar(po1)-pchar(datapo)));
                         //existing data
   move(pd^,psb^,pui2);  //new data
   rectcount:= rectcount - rectco + drectco;
   stripecount:= stripecount - stripeco + dstripeco;
   datasize:= calcdatasize(stripecount,rectcount);
 
  {$ifdef mse_debugregion}
   dumpregion('region after move',ptruint(@reg));
  {$endif}
   
  end;
  if (lastdeststripe^.header.rectcount = 0) and 
                     ((pchar(psb)-pchar(datapo))+pui2 = datasize) then begin
                   //changed last stripe
   po1:= pd;
   ext1:= 0;
   ext2:= 0;
   ext3:= 0; 
   for int1:= dstripeco-1 downto 0 do begin
    ext1:= ext1+po1^.header.height;
    inc(ext3); //empty stripes
    if po1^.header.rectcount > 0 then begin
     ext3:= 0;
     ext2:= ext1;
    end;
    incstripe(po1);
   end;
   stripeend:= stripeend-ext1+ext2;     //remove trailing empty stripes
   stripecount:= stripecount-ext3;
   datasize:= datasize-ext3*sizeof(stripeheaderty);
  end;
 end;
{$ifdef mse_debugregion}
 dumpregion('afterstripeop ',ptruint(@reg));
{$endif}
end;

procedure regionop(const source: regioninfoty; var dest: regioninfoty;
                                                          const op: regopty);
var
 int1: integer;
 ext1: rectextentty;
 po1: pstripety;
begin
 with source do begin
  po1:= datapo;
  ext1:= stripestart;
  for int1:= stripecount - 1 downto 0 do begin
   stripeop(dest,ext1,po1,op);
   ext1:= ext1 + po1^.header.height;
   incstripe(po1);
  end;
 end;
end;

function recttostripe(const rect: rectty; out stripestart: rectextentty;
                          out stripe: regionrectstripety): boolean;
begin
 result:= (rect.cx > 0) and (rect.cy > 0);
 if result then begin
  stripestart:= rect.y;
  with stripe do begin
   header.height:= rect.cy;
   header.rectcount:= 1;
   data.gap:= rect.x;
   data.width:= rect.cx;
  end;
 end;
end;

function regextents(var reg: regioninfoty): rectty;
var
 mi,ma: rectextentty;
 po1,po2: pstripety;
 int1: rectextentty;
 ext1: rectextentty;
begin
 with reg do begin
  if rectcount = 0 then begin
   result:= nullrect;
  end
  else begin
   if rectend = maxint then begin //invalid
    mi:= maxint;
    ma:= minint;
    po1:= datapo;
    po2:= pstripety(pchar(po1)+datasize);
    repeat
     int1:= po1^.header.rectcount;
     po1:= @po1^.data;
     if int1 > 0 then begin
      ext1:= prectextentty(po1)^;
      if ext1 < mi then begin
       mi:= ext1
      end;
      for int1:= int1*2-2 downto 0 do begin
       inc(prectextentty(po1));
       ext1:= ext1 + prectextentty(po1)^;
      end;
      inc(prectextentty(po1));
      if ext1 > ma then begin
       ma:= ext1;
      end;
     end;
    until po1 >= po2;
    rectstart:= mi;
    rectend:= ma;
   end
   else begin
    if rectstart = minint then begin //invalid
     mi:= maxint;
     po1:= datapo;
     po2:= pstripety(pchar(po1)+datasize);
     repeat
      int1:= po1^.header.rectcount;
      if int1 > 0 then begin
       ext1:= prectdataty(@po1^.data)^.gap;
       if ext1 < mi then begin
        mi:= ext1;
       end;
      end;
      po1:= pstripety(pchar(po1) + sizeof(stripeheaderty) +
                                                sizeof(rectdataty)*int1);
     until po1 >= po2;
     rectstart:= mi;
    end;
   end;
   result.x:= rectstart;
   result.y:= stripestart;
   result.cx:= rectend-rectstart;
   result.cy:= stripeend-stripestart;
  end;
 end;
end;

function gdi_regiontorects(const aregion: regionty): rectarty;
var
 po1: prectextentty;
 po2: prectty;
 int1,int2: integer;
 c1,s1,h1: rectextentty;
begin
 if aregion = 0 then begin
  result:= nil;
  exit;
 end;
 with pregioninfoty(aregion)^ do begin
  setlength(result,rectcount);
  po1:= pointer(datapo);
  po2:= pointer(result);
  s1:= stripestart;
  for int1:= stripecount-1 downto 0 do begin
   h1:= po1^;       //rowheight
   inc(po1);
   c1:= 0;
   for int2:= po1^-1 downto 0 do begin
    inc(po1);       //gap
    c1:= c1+po1^;
    po2^.x:= c1;
    inc(po1);       //width
    c1:= c1+po1^;
    po2^.cx:= po1^;
    po2^.y:= s1;
    po2^.cy:= h1;
    inc(po2);
   end;
   s1:= s1 + h1;     //next row
   inc(po1);     
  end;
 end;
end;

procedure gdi_createemptyregion(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.regionoperation do begin
  pointer(dest):= getregmem(0,0);  
 end;
end;

procedure gdi_createrectsregion(var drawinfo: drawinfoty); //gdifunc
var
 stri1: regionrectstripety;
 int1: integer;
begin
 gdi_createemptyregion(drawinfo);
 with drawinfo.regionoperation do begin
  stri1.header.rectcount:= 1;
  for int1:= rectscount - 1 downto 0 do begin
   with rectspo^[int1] do begin
    stri1.header.height:= cy;
    stri1.data.gap:= x;
    stri1.data.width:= cx;
    stripeop(pregioninfoty(dest)^,y,@stri1,reop_add);
   end;
  end;
 end;
end;

procedure gdi_createrectregion(var drawinfo: drawinfoty); //gdifunc
//var
// int1: ptruint;
begin
 with drawinfo.regionoperation do begin
  if (rect.cx = 0) or (rect.cy = 0) then begin
   gdi_createemptyregion(drawinfo);
  end
  else begin
   pointer(dest):= getregmem(1,1);
   with pregioninfoty(dest)^ do begin
    stripestart:= rect.y;
    stripeend:= rect.y + rect.cy;
    stripecount:= 1;
    rectcount:= 1;
    rectstart:= rect.x;
    rectend:= rect.x + rect.cx;
    with datapo^ do begin
     header.height:= rect.cy;
     header.rectcount:= 1;
     with prectdataty(@data)^ do begin
      gap:= rect.x;
      width:= rect.cx;
     end;
    end;
   end;
  end;
 end;
end;

procedure gdi_destroyregion(var drawinfo: drawinfoty); //gdifunc
begin
 with drawinfo.regionoperation do begin
  if source <> 0 then begin
   with pregioninfoty(source)^ do begin
    if buffersize > 0 then begin
     freemem(datapo);
    end;
   end;
   freemem(pointer(source));
  end;
{$ifdef usesdl}//SDL_RenderSetViewport(drawinfo.gc.handle,nil);
{$endif}
 end;
end;

procedure gdi_copyregion(var drawinfo: drawinfoty); //gdifunc
var
// int1: integer;
 {$ifdef usesdl}rect1: SDL_Rect;{$endif}

begin
 with drawinfo.regionoperation do begin
  getmem(pointer(dest),sizeof(regioninfoty));
  move(pointer(source)^,pointer(dest)^,sizeof(regioninfoty));
  with pregioninfoty(dest)^ do begin
   if datasize > 0 then begin
    getmem(datapo,datasize);
    move(pregioninfoty(source)^.datapo^,datapo^,datasize);
   end
   else begin
    datapo:= nil;
   end;
   buffersize:= datasize;
  end;
 {$ifdef usesdl}
  rect1.x:= rect.x;
  rect1.y:= rect.y;
  rect1.w:= rect.cx;
  rect1.h:= rect.cy;
  //SDL_RenderSetViewport(drawinfo.gc.handle,@rect1);
{$endif}
 end;
end;

procedure gdi_moveregion(var drawinfo: drawinfoty); //gdifunc
var
 int1,int2: integer;
 po1: pstripety;
{$ifdef usesdl}
 rect1: SDL_Rect;
{$endif}
begin
 with drawinfo.regionoperation do begin
  with pregioninfoty(dest)^ do begin
   stripestart:= stripestart + rect.y;
   stripeend:= stripeend + rect.y;
   if rect.x <> 0 then begin
    if rectstart <> minint then begin
     rectstart:= rectstart + rect.x;
    end;
    if rectend <> maxint then begin
     rectend:= rectend + rect.x;
    end;
    po1:= datapo;
    for int1:= stripecount - 1 downto 0 do begin
     int2:= po1^.header.rectcount;
     inc(po1);
     if int2 <> 0 then begin
      prectextentty(po1)^:= prectextentty(po1)^+rect.x;
      inc(prectdataty(po1),int2);
     end;
    end;
   end;
  end;
{$ifdef usesdl}
  rect1.x:= rect.x;
  rect1.y:= rect.y;
  rect1.w:= rect.cx;
  rect1.h:= rect.cy;
  //SDL_RenderSetViewport(drawinfo.gc.handle,@rect1);
{$endif}
 end;
end;

procedure gdi_regionisempty(var drawinfo: drawinfoty); //gdifunc
begin
 with pregioninfoty(drawinfo.regionoperation.source)^ do begin
  drawinfo.regionoperation.dest:= 0;
  if rectcount = 0 then begin
   drawinfo.regionoperation.dest:= 1;
  end;
 end;
end;

procedure gdi_regionclipbox(var drawinfo: drawinfoty); //gdifunc
{$ifdef usesdl}
var
 rect1: SDL_Rect;
{$endif}
begin
 with drawinfo.regionoperation do begin
  rect:= regextents(pregioninfoty(source)^);
{$ifdef usesdl}
  rect1.x:= rect.x;
  rect1.y:= rect.y;
  rect1.w:= rect.cx;
  rect1.h:= rect.cy;
  //SDL_RenderSetViewport(drawinfo.gc.handle,@rect1);
{$endif} 
end;
end;

procedure gdi_regsubrect(var drawinfo: drawinfoty); //gdifunc
var
 stri1: regionrectstripety;
 ext1: rectextentty;
begin
 with drawinfo.regionoperation do begin
  if recttostripe(rect,ext1,stri1) then begin
   stripeop(pregioninfoty(dest)^,ext1,@stri1,reop_sub);
  end;
 end;
end;

procedure gdi_regsubregion(var drawinfo: drawinfoty); //gdifunc
{$ifdef usesdl}
var
 rect1: SDL_Rect;
{$endif}
begin
 with drawinfo.regionoperation do begin
  regionop(pregioninfoty(source)^,pregioninfoty(dest)^,reop_sub);
{$ifdef usesdl}
  rect1.x:= rect.x;
  rect1.y:= rect.y;
  rect1.w:= rect.cx;
  rect1.h:= rect.cy;
  SDL_RenderSetViewport(drawinfo.gc.handle,@rect1);
{$endif}
 end;
end;

procedure gdi_regaddrect(var drawinfo: drawinfoty); //gdifunc
var
 stri1: regionrectstripety;
 ext1: rectextentty;
begin
 with drawinfo.regionoperation do begin
  if recttostripe(rect,ext1,stri1) then begin
   stripeop(pregioninfoty(dest)^,ext1,@stri1,reop_add);
  end;
 end;
end;

procedure gdi_regaddregion(var drawinfo: drawinfoty); //gdifunc
{$ifdef usesdl}
var
 rect1: SDL_Rect;
{$endif}

begin
 with drawinfo.regionoperation do begin
  regionop(pregioninfoty(source)^,pregioninfoty(dest)^,reop_add);
{$ifdef usesdl} 
 rect1.x:= rect.x;
  rect1.y:= rect.y;
  rect1.w:= rect.cx;
  rect1.h:= rect.cy;
  //SDL_RenderSetViewport(drawinfo.gc.handle,@rect1);
{$endif}
 end;
end;

procedure gdi_regintersectrect(var drawinfo: drawinfoty); //gdifunc
var
 stri1: regionrectstripety;
 ext1: rectextentty;
{$ifdef usesdl}
 rect1: SDL_Rect;
{$endif}
begin
 with drawinfo.regionoperation do begin
  if recttostripe(rect,ext1,stri1) then begin
   stripeop(pregioninfoty(dest)^,ext1,@stri1,reop_intersect);
  end;
{$ifdef usesdl}
  rect1.x:= rect.x;
  rect1.y:= rect.y;
  rect1.w:= rect.cx;
  rect1.h:= rect.cy;
  //SDL_RenderSetViewport(drawinfo.gc.handle,@rect1);
{$endif} 
end;
end;

procedure gdi_regintersectregion(var drawinfo: drawinfoty); //gdifunc
{$ifdef usesdl}
var
 rect1: SDL_Rect;
{$endif}
begin
 with drawinfo.regionoperation do begin
  regionop(pregioninfoty(source)^,pregioninfoty(dest)^,reop_intersect);
{$ifdef usesdl}
  rect1.x:= rect.x;
  rect1.y:= rect.y;
  rect1.w:= rect.cx;
  rect1.h:= rect.cy;
  //SDL_RenderSetViewport(drawinfo.gc.handle,@rect1);
{$endif}
 end;
end;

procedure segmentellipsef(var drawinfo: drawinfoty;
                      const segmentsproc: pointsfprocty);
var
 count: integer;
 po1: pfpointty;
 ox,oy,x1,y1,si,co,a: double;
 do1: double;
 int1: integer;
begin
 po1:= nil; //compilerwarning
 with drawinfo,drawinfo.rect.rect^ do begin
  count:= 2;
  if cx = 0 then begin
   allocbuffer(buffer,2*sizeof(po1^));
   po1:= buffer.buffer;
   po1^.x:= x;
   po1^.y:= y;
   inc(po1);
   po1^.x:= x;
   po1^.y:= y+cy;
  end
  else begin
   if cy = 0 then begin
    allocbuffer(buffer,2*sizeof(po1^));
    po1:= buffer.buffer;
    po1^.x:= x;
    po1^.y:= y;
    inc(po1);
    po1^.x:= x+cx;
    po1^.y:= y;
   end
   else begin
    int1:= abs(cx);
    if abs(cy) > int1 then begin
     int1:= abs(cy);
    end;
    count:= ceil((0.5*pi)/arccos((int1-1)/int1))*4; //one pixel resolution
    if count = 0 then begin
     count:= 4;
    end;
    allocbuffer(buffer,count*sizeof(po1^));
    a:= cy/cx;
    oy:= y+cy/2;
    do1:= cx/2;
    x1:= do1;
    y1:= 0;
    ox:= x+do1;
    do1:= 2*pi/count;
    si:= sin(do1);
    co:= cos(do1);
    po1:= buffer.buffer;
    po1^.x:= x1+ox;
    po1^.y:= oy;
    for int1:= count-2 downto 0 do begin
     do1:= x1*co - y1*si;
     y1:= y1*co + x1*si;
     x1:= do1;
     inc(po1);
     po1^.x:= x1+ox;
     po1^.y:= y1*a+oy;   
    end;
   end;
  end;
  segmentsproc(gc,buffer.buffer,count,true);
 end;
end;                      

end.
