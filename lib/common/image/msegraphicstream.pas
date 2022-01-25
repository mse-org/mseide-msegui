{ MSEgui Copyright (c) 2006-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegraphicstream;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

{.$define class_bridge} // uncomment to use bridge for BGRABitmap

interface
uses
 sysutils,classes,mclasses,msebitmap,msegraphics,msefpimage,
 msestrings,msetypes;

const
 graphicformatdelimiter = ';';
type
 egraphicformat = class(exception);

 fpreaderclassty = class of tfpcustomimagereader;

 tmsefpmemoryimage = class(tfpmemoryimage)
  private
   fhasalpha: boolean;
   fmonoalpha: boolean;
  public
   procedure assign(source: {$ifdef class_bridge}classes.{$endif}tpersistent); override;
   procedure assignto(dest: {$ifdef class_bridge}classes.{$endif}tpersistent); override;
   procedure writetostream(const dest: tstream;
                   const awriter: tfpcustomimagewriter);
                             //owns the writer
   property hasalpha: boolean read fhasalpha;
   property monoalpha: boolean read fmonoalpha;
 end;

 readgraphicprocty = function(const source: tstream;
                         const dest: tobject; var format: string;
                         const params: array of const): boolean;
 writegraphicprocty = procedure(const dest: tstream;
                               const source: tobject; const format: string;
                               const params: array of const);

function readgraphic(const source: tstream; const dest: tbitmap;
                           const aformatname: string = '';
                           const params: array of const): string; overload;
                           //returns formatname
function readgraphic(const source: tstream; const dest: tmaskedbitmap;
                           const aformatname: string = '';
                           const params: array of const): string; overload;
                           //returns formatname
function readgraphic(const source: tstream;
                                 const dest: timagelist): string; overload;
                           //returns formatname
function tryreadgraphic(const source: tstream; const dest: tbitmap;
                           const aformatname: string = '';
                           const params: array of const): string; overload;
           //returns format name, '' = unknown/not supported
           //exception in case of read error
function tryreadgraphic(const source: tstream; const dest: tmaskedbitmap;
                           const aformatname: string = '';
                           const params: array of const): string; overload;
           //returns format name, '' = unknown/not supported
           //exception in case of read error
function tryreadgraphic(const source: tstream;
                                 const dest: timagelist): string; overload;
           //returns format name, '' = unknown/not supported
           //exception in case of read error

procedure writegraphic(const dest: tstream; const source: tbitmap;
                           const aformatname: string;
                           const params: array of const); overload;
procedure writegraphic(const dest: tstream; const source: tmaskedbitmap;
                           const aformatname: string;
                           const params: array of const); overload;
procedure writegraphic(const dest: tstream; const source: timagelist); overload;
                           //for ico

procedure registergraphicformat(const aformatlabel: string;
                           const areadproc: readgraphicprocty;
                           const awriteproc: writegraphicprocty;
                           const afiltername: msestring;
                           const afilemask: array of msestring);
function graphicformatlabels: stringarty;
function graphicfilemasks: filenamearty;
function graphicfilefilternames: msestringarty;
function graphicfilefiltermasks: msestringarty;
function graphicfilefilterlabel(const index: integer): string;

function readfpgraphic(const source: tstream; const readerclass: fpreaderclassty;
                             const dest: {$ifdef class_bridge}classes.{$endif}tpersistent): boolean;

implementation
uses
{$ifdef mse_dynpo}
 msestockobjects_dynpo,
{$else}
 msestockobjects,
{$endif}
 msegraphutils, msearrayutils;

type
 tmaskedbitmap1 = class(tmaskedbitmap);

 graphicformatinfoty = record
  formatlabel: string;
  readproc: readgraphicprocty;
  writeproc: writegraphicprocty;
  filtername: msestring;
  filemask: msestringarty;
 end;
 graphicformatinfoarty = array of graphicformatinfoty;

var
 formats: graphicformatinfoarty;

function order: integerarty;
var
 ar1: msestringarty;
 int1: integer;
begin
 setlength(ar1,length(formats));
 for int1:= 0 to high(ar1) do begin
  ar1[int1]:= formats[int1].filtername;
 end;
 sortarray(ar1,sms_upi,result);
end;

function graphicformatlabels: stringarty;
var
 ar1: stringarty;
 int1: integer;
begin
 result := nil;
 setlength(ar1,length(formats));
 for int1:= 0 to high(ar1) do begin
  ar1[int1]:= formats[int1].formatlabel;
 end;
 orderarray(order,ar1);
 setlength(result,1);
 result[0]:= '';
 stackarray(ar1,result);
end;

function graphicfilefilterlabel(const index: integer): string;
var
 ar1: stringarty;
begin
 ar1:= graphicformatlabels;
 if (index < 0) or (index > high(ar1)) then begin
  result:= '';
 end
 else begin
  result:= ar1[index];
 end;
end;

function graphicfilefilternames: msestringarty;
var
 ar1: msestringarty;
 int1: integer;
begin
 result := nil;
 setlength(ar1,length(formats));
 for int1:= 0 to high(ar1) do begin
  ar1[int1]:= formats[int1].filtername;
 end;
 orderarray(order,ar1);
 setlength(result,1);
{$ifdef mse_dynpo}
 result[0]:= lang_stockcaption[ord(sc_All)];
{$else}
 result[0]:= sc(sc_All);
{$endif}
 stackarray(ar1,result);
end;

function graphicfilefiltermasks: msestringarty;
var
 ar1: msestringararty;
 int1,int2: integer;
 ar2: msestringarty;
begin
  result := nil;
 setlength(ar1,length(formats));
 for int1:= 0 to high(ar1) do begin
  ar1[int1]:= formats[int1].filemask;
 end;
 orderarray(order,ar1,sizeof(ar1[0]));
 setlength(result,1);
 for int1:= 0 to high(ar1) do begin
  for int2:= 0 to high(ar1[int1]) do begin
   result[0]:= result[0]+'"'+ar1[int1][int2]+'" ';
  end;
 end;
 if result[0] <> '' then begin
  setlength(result[0],length(result[0])-1);
 end;
 setlength(ar2,length(ar1));
 for int1:= 0 to high(ar2) do begin
  if high(ar1[int1]) > 0 then begin
   for int2:= 0 to high(ar1[int1]) do begin
    ar2[int1]:= ar2[int1] + '"' + ar1[int1][int2] + '" ';
   end;
   setlength(ar2[int1],length(ar2[int1])-1);
  end
  else begin
   if ar1[int1] <> nil then begin
    ar2[int1]:= ar1[int1][0];
   end;
  end;
 end;
 setlength(result,1+length(ar2));
 for int1:= 0 to high(ar2) do begin
  result[int1+1]:= ar2[int1];
 end;
end;

function graphicfilemasks: filenamearty;
var
 co: integer;
 int1,int2: integer;
begin
  result := nil;
 co:= 0;
 for int1:= 0 to high(formats) do begin
  for int2:= 0 to high(formats[int1].filemask) do begin
   additem(result,formats[int1].filemask[int2],co);
  end;
 end;
 setlength(result,co);
end;

procedure formaterror(const text,format: string);
var
 str1: string;
begin
 str1:= text;
 if format <> '' then begin
  str1:= str1 + ': '+format;
 end;
 str1:= str1 + '.';
 raise egraphicformat.create(str1);
end;

procedure registergraphicformat(const aformatlabel: string;
                    const areadproc: readgraphicprocty;
                    const awriteproc: writegraphicprocty;
                    const afiltername: msestring;
                    const afilemask: array of msestring);
var
 int1,int2: integer;
begin
 int2:= -1;
 for int1:= 0 to high(formats) do begin
  if formats[int1].formatlabel = aformatlabel then begin
   int2:= int1;
   break;
  end;
 end;
 if int2 < 0 then begin
  setlength(formats,high(formats) + 2);
  int2:= high(formats);
 end;
 with formats[int2] do begin
  formatlabel:= aformatlabel;
  if {$ifndef FPC}@{$endif}areadproc <> nil then begin
   readproc:= areadproc;
  end;
  if {$ifndef FPC}@{$endif}awriteproc <> nil then begin
   writeproc:= awriteproc;
  end;
  filtername:= afiltername;
  setlength(filemask,length(afilemask));
  for int1:= 0 to high(filemask) do begin
   filemask[int1]:= afilemask[int1];
  end;
 end;
end;

function readgraphic1(const atry: boolean; const source: tstream;
                const adest: tobject; const aformatlabel: string;
                const params: array of const): string;
                //index = select image in ico format
var
 int1,int3: integer;
 ar1: stringarty;
 found: boolean;
 str1: string;
begin
 result:= '';
 ar1:= nil; //compiler warning
 if aformatlabel = '' then begin
  found:= high(formats) >= 0;
  for int1:= 0 to high(formats) do begin
   with formats[int1] do begin
    if assigned(readproc) then begin
     str1:= formats[int1].formatlabel;
     if readproc(source,adest,str1,params) then begin
      result:= str1;
      exit;
     end;
     source.position:= 0;
    end;
   end;
  end;
 end
 else begin
  found:= false;
  ar1:= splitstring(aformatlabel,graphicformatdelimiter);
  for int3:= 0 to high(ar1) do begin
   for int1:= 0 to high(formats) do begin
    with formats[int1] do begin
     if (formatlabel = ar1[int3]) then begin
      found:= true;
      if assigned(readproc) then begin
       str1:= formats[int1].formatlabel;
       if readproc(source,adest,str1,params) then begin
        result:= str1;
        exit;
       end;
      end;
      break;
     end;
    end;
   end;
  end;
 end;
 if not atry then begin
  if not found then begin
 {$ifdef mse_dynpo}
  formaterror(
      ansistring(lang_stockcaption[ord(sc_graphic_format_not_supported)]),
                                                              aformatlabel);
  end
  else begin
   formaterror(ansistring(lang_stockcaption[ord(sc_graphic_format_error)]),
                                                                aformatlabel);
{$else}
  formaterror(
      ansistring(sc(sc_graphic_format_not_supported)),
                                                              aformatlabel);
  end
  else begin
   formaterror(ansistring(sc(sc_graphic_format_error)),
                                                                aformatlabel);
{$endif}
  end;
 end;
end;

procedure writegraphic1(const dest: tstream; const asource: tobject;
                 const aformatlabel: string; const params: array of const);
var
 int1,int2: integer;
begin
 int2:= -1;
 for int1:= 0 to high(formats) do begin
  with formats[int1] do begin
   if (formatlabel = aformatlabel) then begin
    if assigned(writeproc) then begin
     int2:= int1;
    end;
    break;
   end;
  end;
 end;
 if int2 < 0 then begin
  formaterror(
{$ifdef mse_dynpo}
        ansistring(lang_stockcaption[ord(sc_graphic_format_not_supported)]),
{$else}
        ansistring(sc(sc_graphic_format_not_supported)),
{$endif}
                                                               aformatlabel);
 end;
 with formats[int2] do begin
  writeproc(dest,asource,aformatlabel,params);
 end;
end;

function readgraphic(const source: tstream; const dest: tbitmap;
                           const aformatname: string = '';
                           const params: array of const): string; overload;
begin
 result:= readgraphic1(false,source,dest,aformatname,params);
end;

function readgraphic(const source: tstream; const dest: tmaskedbitmap;
                           const aformatname: string = '';
                           const params: array of const): string; overload;
                           //index = select image in ico format
begin
 result:= readgraphic1(false,source,dest,aformatname,params);
end;

function readgraphic(const source: tstream;
                            const dest: timagelist): string; overload;
begin
 result:= readgraphic1(false,source,dest,'ico',[-1]);
end;

function tryreadgraphic(const source: tstream; const dest: tbitmap;
                           const aformatname: string = '';
                           const params: array of const): string; overload;
begin
 result:= readgraphic1(true,source,dest,aformatname,params);
end;

function tryreadgraphic(const source: tstream; const dest: tmaskedbitmap;
                           const aformatname: string = '';
                           const params: array of const): string; overload;
                           //index = select image in ico format
begin
 result:= readgraphic1(true,source,dest,aformatname,params);
end;

function tryreadgraphic(const source: tstream;
                            const dest: timagelist): string; overload;
begin
 result:= readgraphic1(true,source,dest,'ico',[-1]);
end;

procedure writegraphic(const dest: tstream; const source: tbitmap;
                           const aformatname: string;
                           const params: array of const); overload;
begin
 writegraphic1(dest,source,aformatname,params);
end;

procedure writegraphic(const dest: tstream; const source: tmaskedbitmap;
                           const aformatname: string;
                           const params: array of const); overload;

begin
 writegraphic1(dest,source,aformatname,params);
end;

procedure writegraphic(const dest: tstream; const source: timagelist); overload;
                           //index = select image in ico format
begin
 writegraphic1(dest,source,'ico',[]);
end;

function readfpgraphic(const source: tstream; const readerclass: fpreaderclassty;
                               const dest: {$ifdef class_bridge}classes.{$endif}tpersistent): boolean;
var
 reader: tfpcustomimagereader;
 img: tmsefpmemoryimage;
 int1: integer;
begin
 result:= false;
 reader:= readerclass.create;
 try
  int1:= source.position;
  if reader.checkcontents(source) then begin
   img:= tmsefpmemoryimage.create(0,0);
   img.usepalette:= false;
   try
    source.position:= int1;
    reader.imageread(source,img);
    dest.assign(img);
    result:= true;
   finally
    img.free;
   end;
  end
  else begin
   source.position:= int1;
  end;
 finally
  reader.free;
 end;
end;

{ tmsefpmemoryimage }

procedure tmsefpmemoryimage.writetostream(const dest: tstream;
                   const awriter: tfpcustomimagewriter);
                             //owns the writer
begin
 try
  savetostream(dest,awriter);
 finally
  awriter.free;
 end;
end;

procedure tmsefpmemoryimage.assign(source: {$ifdef class_bridge}classes.{$endif}tpersistent);
 function to16(const acolor: colorty): tfpcolor;
 var
  rgb1: rgbtriplety;
 begin
  rgb1:= colortorgb(acolor);
  result.red:= rgb1.red + (rgb1.red shl 8);
  result.green:= rgb1.green + (rgb1.green shl 8);
  result.blue:= rgb1.blue + (rgb1.blue shl 8);
  result.alpha:= 0;
 end;
var
 col1,col0,col3: tfpcolor;
 int1,int2: integer;
 wo1: word;
 lwo1: longword;
 masked1: boolean;
 maskkind1: bitmapkindty;
 pimageline,pmaskline: pointer;
 pi,pm: pointer;
 imagestep,maskstep: integer;
begin
 if source is tbitmap then begin
  setsize(0,0); //clear
  masked1:= source is tmaskedbitmap;
  if masked1 then begin
   with tmaskedbitmap(source) do begin
    masked1:= masked;
    if masked1 then begin
     with mask do begin
      maskkind1:= mask.kind;
      fmonoalpha:= maskkind1 = bmk_mono;
      pmaskline:= scanline[0];
      maskstep:= scanlinestep;
     end;
    end;
   end;
  end;
  fhasalpha:= masked1;
  with tbitmap(source) do begin
   pimageline:= scanline[0];
   imagestep:= scanlinestep;
   self.setsize(width,height);
   usepalette:= false;
   col3.alpha:= 0;
   case kind of
    bmk_mono: begin                //mono
     col0:= to16(colorbackground);
     col1:= to16(colorforeground);
     usepalette:= true;
     if masked1 then begin
      case maskkind1 of
       bmk_mono: begin             //mono monmask
        for int1:= 0 to height - 1 do begin
         pi:= pimageline;
         pm:= pmaskline;
         lwo1:= $00000001;
         for int2:= 0 to width-1 do begin
          if plongword(pi)^ and lwo1 <> 0 then begin
           if plongword(pm)^ and lwo1 <> 0 then begin
            col1.alpha:= $ffff;
           end
           else begin
            col1.alpha:= $0000;
           end;
           colors[int2,int1]:= col1;
          end
          else begin
           if plongword(pm)^ and lwo1 <> 0 then begin
            col0.alpha:= $ffff;
           end
           else begin
            col0.alpha:= $0000;
           end;
           colors[int2,int1]:= col0;
          end;
          lwo1:= lwo1 shl 1;
          if lwo1 = 0 then begin
           inc(plongword(pi));
           inc(plongword(pm));
           lwo1:= $00000001;
          end;
         end;
         inc(pimageline,imagestep);
         inc(pmaskline,maskstep);
        end;
       end;
       bmk_gray: begin                     //mono graymask
        for int1:= 0 to height - 1 do begin
         pi:= pimageline;
         pm:= pmaskline;
         lwo1:= $00000001;
         for int2:= 0 to width-1 do begin
          if plongword(pi)^ and lwo1 <> 0 then begin
           wo1:= pbyte(pm)^;
           col1.alpha:= wo1 or (wo1 shl 8);
           colors[int2,int1]:= col1;
          end
          else begin
           wo1:= pbyte(pm)^;
           col1.alpha:= wo1 or (wo1 shl 8);
           colors[int2,int1]:= col0;
          end;
          lwo1:= lwo1 shl 1;
          inc(pbyte(pm));
          if lwo1 = 0 then begin
           inc(plongword(pi));
           lwo1:= $00000001;
          end;
         end;
         inc(pimageline,imagestep);
         inc(pmaskline,maskstep);
        end;
       end;
       else begin                          //mono rgbmask
        for int1:= 0 to height - 1 do begin
         pi:= pimageline;
         pm:= pmaskline;
         lwo1:= $00000001;
         for int2:= 0 to width-1 do begin
          if plongword(pi)^ and lwo1 <> 0 then begin
           wo1:= (word(prgbtriplety(pm)^.red)+
                         word(prgbtriplety(pm)^.green)+
                         word(prgbtriplety(pm)^.blue)) div 3;
           col1.alpha:= wo1 or (wo1 shl 8);
           colors[int1,int2]:= col1;
          end
          else begin
           wo1:= (word(prgbtriplety(pm)^.red)+
                         word(prgbtriplety(pm)^.green)+
                         word(prgbtriplety(pm)^.blue)) div 3;
           col0.alpha:= wo1 or (wo1 shl 8);
           colors[int2,int1]:= col0;
          end;
          lwo1:= lwo1 shl 1;
          if lwo1 = 0 then begin
           inc(plongword(pi));
           lwo1:= $00000001;
          end;
          inc(plongword(pm));
         end;
         inc(pimageline,imagestep);
         inc(pmaskline,maskstep);
        end;
       end;
      end;
     end
     else begin                        //mono unmasked
      for int1:= 0 to height - 1 do begin
       pi:= pimageline;
       lwo1:= $00000001;
       for int2:= 0 to width-1 do begin
        if plongword(pi)^ and lwo1 <> 0 then begin
         colors[int2,int1]:= col1;
        end
        else begin
         colors[int2,int1]:= col0;
        end;
        lwo1:= lwo1 shl 1;
        if lwo1 = 0 then begin
         inc(plongword(pm));
         lwo1:= $00000001;
        end;
       end;
       inc(pimageline,imagestep);
      end;
     end;
    end;
    bmk_gray: begin
     if masked1 then begin
      case maskkind1 of
       bmk_mono: begin                 //gray monomask
        for int1:= 0 to height - 1 do begin
         pi:= pimageline;
         pm:= pmaskline;
         lwo1:= $00000001;
         for int2:= 0 to width - 1 do begin
          wo1:= pbyte(pi)^;
          wo1:= wo1 shl 8;
          col3.red:= wo1;
          col3.green:= wo1;
          col3.blue:= wo1;
          if plongword(pm)^ and lwo1 <> 0 then begin
           col3.alpha:= $ffff;
          end
          else begin
           col3.alpha:= $0000;
          end;
          colors[int2,int1]:= col3;
          inc(pbyte(pi));
          lwo1:= lwo1 shl 1;
          if lwo1 = 0 then begin
           inc(plongword(pm));
           lwo1:= $00000001;
          end;
         end;
         inc(pimageline,imagestep);
         inc(pmaskline,maskstep);
        end;
       end;
       bmk_gray: begin            //gray graymask
        for int1:= 0 to height - 1 do begin
         pi:= pimageline;
         pm:= pmaskline;
         for int2:= 0 to width - 1 do begin
          wo1:= pbyte(pi)^;
          wo1:= wo1 shl 8;
          col3.red:= wo1;
          col3.green:= wo1;
          col3.blue:= wo1;
          wo1:= pbyte(pm)^;
          col3.alpha:= wo1 or (wo1 shl 8);
          colors[int2,int1]:= col3;
          inc(pbyte(pi));
          inc(pbyte(pm));
         end;
         inc(pimageline,imagestep);
         inc(pmaskline,maskstep);
        end;
       end;
       else begin                //gray colormask
        for int1:= 0 to height - 1 do begin
         pi:= pimageline;
         pm:= pmaskline;
         for int2:= 0 to width - 1 do begin
          wo1:= pbyte(pi)^;
          wo1:= wo1 shl 8;
          col3.red:= wo1;
          col3.green:= wo1;
          col3.blue:= wo1;
          wo1:= (prgbtriplety(pm)^.red + prgbtriplety(pm)^.green +
                                prgbtriplety(pm)^.blue) div 3;
          col3.alpha:= wo1 or (wo1 shl 8);
          colors[int2,int1]:= col3;
          inc(pbyte(pi));
          inc(prgbtriplety(pm));
         end;
         inc(pimageline,imagestep);
         inc(pmaskline,maskstep);
        end;
       end;
      end;
     end
     else begin                 //gray unmasked
      for int1:= 0 to height - 1 do begin
       pi:= pimageline;
       for int2:= 0 to width - 1 do begin
        wo1:= pbyte(pi)^;
        wo1:= wo1 shl 8;
        col3.red:= wo1;
        col3.green:= wo1;
        col3.blue:= wo1;
        colors[int2,int1]:= col3;
        inc(pbyte(pi));
       end;
       inc(pimageline,imagestep);
      end;
     end;
    end;
    else begin                       //bmk_rgb
     if masked1 then begin
      case maskkind1 of
       bmk_mono: begin                 //color monomask
        for int1:= 0 to height - 1 do begin
         pi:= pimageline;
         pm:= pmaskline;
         lwo1:= $00000001;
         for int2:= 0 to width - 1 do begin
          wo1:= prgbtriplety(pi)^.red;
          col3.red:= wo1 or wo1 shl 8;
          wo1:= prgbtriplety(pi)^.green;
          col3.green:= wo1 or wo1 shl 8;
          wo1:= prgbtriplety(pi)^.blue;
          col3.blue:= wo1 or wo1 shl 8;
          if plongword(pm)^ and lwo1 <> 0 then begin
           col3.alpha:= $ffff;
          end
          else begin
           col3.alpha:= $0000;
          end;
          colors[int2,int1]:= col3;
          inc(plongword(pi));
          lwo1:= lwo1 shl 1;
          if lwo1 = 0 then begin
           inc(plongword(pm));
           lwo1:= $00000001;
          end;
         end;
         inc(pimageline,imagestep);
         inc(pmaskline,maskstep);
        end;
       end;
       bmk_gray: begin            //color graymask
        for int1:= 0 to height - 1 do begin
         pi:= pimageline;
         pm:= pmaskline;
         for int2:= 0 to width - 1 do begin
          wo1:= (prgbtriplety(pi)^.red);
          col3.red:= wo1 or (wo1 shl 8);
          wo1:= (prgbtriplety(pi)^.green);
          col3.green:= wo1 or (wo1 shl 8);
          wo1:= (prgbtriplety(pi)^.blue);
          col3.blue:= wo1 or (wo1 shl 8);
          wo1:= pbyte(pm)^;
          col3.alpha:= wo1 or (wo1 shl 8);
          colors[int2,int1]:= col3;
          inc(prgbtriplety(pi));
          inc(pbyte(pm));
         end;
         inc(pimageline,imagestep);
         inc(pmaskline,maskstep);
        end;
       end;
       else begin       //color colormask
        for int1:= 0 to height - 1 do begin
         pi:= pimageline;
         pm:= pmaskline;
         for int2:= 0 to width - 1 do begin
          wo1:= (prgbtriplety(pi)^.red);
          col3.red:= wo1 or (wo1 shl 8);
          wo1:= (prgbtriplety(pi)^.green);
          col3.green:= wo1 or (wo1 shl 8);
          wo1:= (prgbtriplety(pi)^.blue);
          col3.blue:= wo1 or (wo1 shl 8);
          wo1:= (prgbtriplety(pm)^.red + prgbtriplety(pm)^.green +
                                prgbtriplety(pm)^.blue) div 3;
          col3.alpha:= wo1 or (wo1 shl 8);
          colors[int2,int1]:= col3;
          inc(prgbtriplety(pi));
          inc(prgbtriplety(pm));
         end;
         inc(pimageline,imagestep);
         inc(pmaskline,maskstep);
        end;
       end;
      end;
     end
     else begin                 //color unmasked
      for int1:= 0 to height - 1 do begin
       pi:= pimageline;
       for int2:= 0 to width - 1 do begin
        wo1:= (prgbtriplety(pi)^.red);
        col3.red:= wo1 or (wo1 shl 8);
        wo1:= (prgbtriplety(pi)^.green);
        col3.green:= wo1 or (wo1 shl 8);
        wo1:= (prgbtriplety(pi)^.blue);
        col3.blue:= wo1 or (wo1 shl 8);
        colors[int2,int1]:= col3;
        inc(prgbtriplety(pi));
       end;
       inc(pimageline,imagestep);
      end;
     end;
    end;
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tmsefpmemoryimage.assignto(dest: {$ifdef class_bridge}classes.{$endif}tpersistent);

var
 grayalpha1: boolean;

 function getmaskdata(ashift: word): boolean;
 var
  int1,int2,int3: integer;
  bo1,bo2: boolean;
//  po1: prgbtripleaty;
  po1: pbyte;
  by1: byte;
 begin
  bo1:= false;
  bo2:= false;
  with tmaskedbitmap1(dest) do begin
   with fmask do begin
    po1:= scanline[0];
    int3:= scanlinestep;
   end;
   for int1:= 0 to height - 1 do begin
    for int2:= 0 to width - 1 do begin
     by1:= colors[int2,int1].alpha shr ashift;
     bo1:= bo1 or ((by1 < 255) and (by1 > 0));
     bo2:= bo2 and (by1 <> 0);
     po1[int2]:= by1;
    {
     with po1^[int2] do begin
      red:= by1;
      green:= by1;
      blue:= by1;
      res:= 0;
     end;
    }
    end;
    inc(po1,int3);
   end;
  end;
  grayalpha1:= bo1;
  result:= bo2;
 end;

var
 int1,int2,int3: integer;
 po1: prgbtripleaty;
 col1: tfpcolor;
 col2: colorty;
 bo1: boolean;
 ismaskedbitmap: boolean;
begin
 if dest is tbitmap then begin
  ismaskedbitmap:= dest is tmaskedbitmap;
  try
   with tbitmap(dest) do begin
    beginupdate();
    if ismaskedbitmap then begin
     tmaskedbitmap(dest).masked:= false;
    end;
    clear();
    kind:= bmk_rgb;
    size:= makesize(self.width,self.height);
    bo1:= false;
    po1:= scanline[0];
    int3:= scanlinestep;
    for int1:= 0 to height - 1 do begin
     for int2:= 0 to width - 1 do begin
      col1:= colors[int2,int1];
      with po1^[int2] do begin
       red:= col1.red shr 8;
       green:= col1.green shr 8;
       blue:= col1.blue shr 8;
       res:= 0;
       bo1:= bo1 or (col1.alpha < $ff00);
      end;
     end;
     inc(pointer(po1),int3);
    end;
    fhasalpha:= bo1;
    fmonoalpha:= false;
    if ismaskedbitmap then begin
     with tmaskedbitmap1(dest) do begin
      if self.hasalpha then begin
       graymask:= true;
       include(foptions,bmo_masked);
       createmask(bmk_gray);
       fmask.size:= size;
       include(fstate,pms_maskvalid);
       if not getmaskdata(8) then begin
        getmaskdata(0); //try 8 bit
       end;
       col2:= maskcolorbackground;
       maskcolorbackground:= 0;
       graymask:= grayalpha1;
       fmonoalpha:= not grayalpha1;
       maskcolorbackground:= col2;
       include(foptions,bmo_masked);
      end;
     end;
    end;
    change;
   end;
  finally
   tmaskedbitmap(dest).endupdate();
  end;
 end;
end;

end.
