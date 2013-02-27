{ MSEgui Copyright (c) 2006-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegraphicstream;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 sysutils,classes,mclasses,msebitmap,msegraphics{$ifdef FPC},fpimage{$endif},
 msestrings,msetypes;

const
 graphicformatdelimiter = ';'; 
type
 egraphicformat = class(exception);
 
{$ifdef FPC}
 fpreaderclassty = class of tfpcustomimagereader;
 
 tmsefpmemoryimage = class(tfpmemoryimage)
  private
   fhasalpha: boolean;
   fmonoalpha: boolean;
  public
   procedure assign(source: tpersistent); override;
   procedure assignto(dest: tpersistent); override;
   procedure writetostream(const dest: tstream; 
                   const awriter: tfpcustomimagewriter);
                             //owns the writer
   property hasalpha: boolean read fhasalpha;
   property monoalpha: boolean read fmonoalpha;
 end;  
{$endif}

 readgraphicprocty = function(const source: tstream; const index: integer; 
                               const dest: tobject): boolean;
 writegraphicprocty = procedure(const dest: tstream;
                               const source: tobject;
                               const params: array of const);

function readgraphic(const source: tstream; const dest: tbitmap;
                           const aformatname: string = '';
                           const index: integer = -1): string; overload;
                           //returns formatname
                           //index = select image in ico format
function readgraphic(const source: tstream; const dest: tmaskedbitmap;
                           const aformatname: string = '';
                           const index: integer = -1): string; overload;
                           //index = select image in ico format
function readgraphic(const source: tstream;
                                 const dest: timagelist): string; overload;
                           //only for ico format
                           
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

{$ifdef FPC}

function readfpgraphic(const source: tstream; const readerclass: fpreaderclassty;
                             const dest: tpersistent): boolean;
{$endif}

implementation
uses
 msestockobjects,msegraphutils,msearrayutils;
 
type
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
 setlength(ar1,length(formats));
 for int1:= 0 to high(ar1) do begin
  ar1[int1]:= formats[int1].filtername;
 end;
 orderarray(order,ar1);
 setlength(result,1);
 result[0]:= stockobjects.captions[sc_All];
 stackarray(ar1,result);
end;

function graphicfilefiltermasks: msestringarty;
var
 ar1: msestringararty;
 int1,int2: integer;
 ar2: msestringarty;
begin
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

function readgraphic1(const source: tstream; const index: integer;
                const adest: tobject; const aformatlabel: string): string;
                //index = select image in ico format
var
 int1,int3: integer;
 ar1: stringarty;
 found: boolean;
begin
 result:= '';
 ar1:= nil; //compiler warning
 if aformatlabel = '' then begin
  found:= true;
  for int1:= 0 to high(formats) do begin
   with formats[int1] do begin
    if assigned(readproc) then begin
     if readproc(source,index,adest) then begin
      result:= formats[int1].formatlabel;
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
       if readproc(source,index,adest) then begin
        result:= formats[int1].formatlabel;
        exit;
       end;
      end;
      break;
     end;
    end;
   end;
  end;
 end;
 if not found then begin
  formaterror(stockobjects.captions[sc_graphic_format_not_supported],aformatlabel);
 end
 else begin
  formaterror(stockobjects.captions[sc_graphic_format_error],aformatlabel);
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
  formaterror(stockobjects.captions[sc_graphic_format_not_supported],aformatlabel);
 end;
 with formats[int2] do begin
  writeproc(dest,asource,params);
 end;
end;

function readgraphic(const source: tstream; const dest: tbitmap;
                           const aformatname: string = '';
                           const index: integer = -1): string; overload;
                           //index = select image in ico format
begin
 result:= readgraphic1(source,index,dest,aformatname);
end;

function readgraphic(const source: tstream; const dest: tmaskedbitmap;
                           const aformatname: string = '';
                           const index: integer = -1): string; overload;
                           //index = select image in ico format
begin
 result:= readgraphic1(source,index,dest,aformatname);
end;

function readgraphic(const source: tstream;
                            const dest: timagelist): string; overload;
                           //index = select image in ico format
begin
 result:= readgraphic1(source,-1,dest,'ico');
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

{$ifdef FPC}

function readfpgraphic(const source: tstream; const readerclass: fpreaderclassty;
                               const dest: tpersistent): boolean;
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

procedure tmsefpmemoryimage.assign(source: tpersistent);
var
 col1,col2,col3: tfpcolor;
 po1,po3: plongword;
 po2,po4: prgbtriplety;
 int1,int2{,int3}: integer;
 lwo1: longword;
 masked1: boolean;
 colormask1: boolean;
begin
 if source is tbitmap then begin
  masked1:= source is tmaskedbitmap;
  if masked1 then begin
   with tmaskedbitmap(source) do begin
    masked1:= masked;
    colormask1:= colormask;
    fmonoalpha:= not colormask1;
   end;
  end;
  fhasalpha:= masked1;
  with tbitmap(source) do begin
   col1.red:= 0;
   col1.green:= 0;
   col1.blue:= 0;
   col1.alpha:= 0;
   col2.red:= $ffff;
   col2.green:= $ffff;
   col2.blue:= $ffff;
   col2.alpha:= 0;
   col3.alpha:= 0;
   if monochrome then begin                //mono
    usepalette:= true;
    self.setsize(size.cx,size.cy);
    if masked1 then begin
     if colormask1 then begin              //mono colormask
      for int1:= 0 to height - 1 do begin
       po1:= scanline[int1];
       po4:= tmaskedbitmap(source).mask.scanline[int1];
       int2:= 0;
       lwo1:= $00000001;
       for int2:= 0 to width-1 do begin
        if po1^ and lwo1 <> 0 then begin
         col1.alpha:= (word(po4^.red)+word(po4^.green)+word(po4^.blue)) div 3;
         col1.alpha:= col1.alpha + col1.alpha shl 8;
         colors[int1,int2]:= col1;
        end
        else begin
         col2.alpha:= (word(po4^.red)+word(po4^.green)+word(po4^.blue)) div 3;
         col2.alpha:= col1.alpha + col1.alpha shl 8;
         colors[int2,int1]:= col2;
        end;
        lwo1:= lwo1 shl 1;
        if lwo1 = 0 then begin
         inc(po1);
         lwo1:= $00000001;
        end;
        inc(po4);
       end;
      end;
     end
     else begin                          //mono monomask
      for int1:= 0 to height - 1 do begin
       po3:= tmaskedbitmap(source).mask.scanline[int1];
       po1:= scanline[int1];
       int2:= 0;
       lwo1:= $00000001;
       for int2:= 0 to width-1 do begin
        if po1^ and lwo1 <> 0 then begin
         if po3^ and lwo1 <> 0 then begin
          col1.alpha:= $ffff;
         end
         else begin
          col1.alpha:= $0000;
         end;
         colors[int1,int2]:= col1;
        end
        else begin
         if po3^ and lwo1 <> 0 then begin
          col2.alpha:= $ffff;
         end
         else begin
          col2.alpha:= $0000;
         end;
         colors[int2,int1]:= col2;
        end;
        lwo1:= lwo1 shl 1;
        if lwo1 = 0 then begin
         inc(po1);
         inc(po3);
         lwo1:= $00000001;
        end;
       end;
      end;
     end;
    end
    else begin                        //mono unmasked
     for int1:= 0 to height - 1 do begin
      po1:= scanline[int1];
      int2:= 0;
      lwo1:= $00000001;
      for int2:= 0 to width-1 do begin
       if po1^ and lwo1 <> 0 then begin
        colors[int1,int2]:= col1;
       end
       else begin
        colors[int2,int1]:= col2;
       end;
       lwo1:= lwo1 shl 1;
       if lwo1 = 0 then begin
        inc(po1);
        lwo1:= $00000001;
       end;
      end;
     end;
    end;
   end
   else begin                       //color
    usepalette:= false;
    self.setsize(size.cx,size.cy);
    if masked1 then begin
     if colormask1 then begin       //color colormask
      for int1:= 0 to height - 1 do begin
       po4:= tmaskedbitmap(source).mask.scanline[int1];
       po2:= scanline[int1];
       for int2:= 0 to width - 1 do begin
        col3.red:= word(po2^.red)+(word(po2^.red) shl word(8));
        col3.green:= word(po2^.green)+(word(po2^.green) shl word(8));
        col3.blue:= word(po2^.blue)+(word(po2^.blue) shl word(8));
        col3.alpha:= (word(po4^.red)+word(po4^.green)+word(po4^.blue)) div 3;
        col3.alpha:= col3.alpha + col3.alpha shl 8;
        colors[int2,int1]:= col3;
        inc(po2);
        inc(po4);
       end;
      end
     end
     else begin                  //color monomask
      for int1:= 0 to height - 1 do begin
       po1:= tmaskedbitmap(source).mask.scanline[int1];
       int2:= 0;
       lwo1:= $00000001;
       po2:= scanline[int1];
       for int2:= 0 to width - 1 do begin
        col3.red:= word(po2^.red)+(word(po2^.red) shl word(8));
        col3.green:= word(po2^.green)+(word(po2^.green) shl word(8));
        col3.blue:= word(po2^.blue)+(word(po2^.blue) shl word(8));
        if po1^ and lwo1 <> 0 then begin
         col3.alpha:= $ffff;
        end
        else begin
         col3.alpha:= $0000;
        end;
        colors[int2,int1]:= col3;
        inc(po2);
        lwo1:= lwo1 shl 1;
        if lwo1 = 0 then begin
         inc(po1);
         lwo1:= $00000001;
        end;
       end;
      end;
     end;
    end
    else begin                 //color unmasked
     for int1:= 0 to height - 1 do begin
      po2:= scanline[int1];
      for int2:= 0 to width - 1 do begin
       col3.red:= word(po2^.red)+(word(po2^.red) shl word(8));
       col3.green:= word(po2^.green)+(word(po2^.green) shl word(8));
       col3.blue:= word(po2^.blue)+(word(po2^.blue) shl word(8));
       colors[int2,int1]:= col3;
       inc(po2);
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

procedure tmsefpmemoryimage.assignto(dest: tpersistent);

var
 coloralpha1: boolean;
 
 function getmask(ashift: word): boolean;
 var
  int1,int2: integer;
  bo1,bo2: boolean;
  po1: prgbtripleaty;
  by1: byte;
 begin
  bo1:= false;
  bo2:= false;
  with tmaskedbitmap(dest) do begin
   for int1:= 0 to height - 1 do begin
    po1:= mask.scanline[int1];
    for int2:= 0 to width - 1 do begin
     by1:= colors[int2,int1].alpha shr ashift;
     bo1:= bo1 or ((by1 < 255) and (by1 > 0));
     bo2:= bo2 and (by1 <> 0);
     with po1^[int2] do begin
      red:= by1;      
      green:= by1;      
      blue:= by1;      
      res:= 0;
     end;
    end;
   end;
  end;
  coloralpha1:= bo1;
  result:= bo2;
 end;
  
var
 int1,int2: integer;
 po1: prgbtripleaty;
 col1: tfpcolor;
// by1: byte;
 col2: colorty;
 bo1: boolean;
begin
 if dest is tbitmap then begin
  with tbitmap(dest) do begin
   size:= makesize(self.width,self.height);
   bo1:= false;
{$ifdef FPC}{$checkpointer off}{$endif} 
//scanline is not in heap on win32
   for int1:= 0 to height - 1 do begin
    po1:= scanline[int1];
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
   end;
   fhasalpha:= bo1;
   fmonoalpha:= false;
   if dest is tmaskedbitmap then begin
    with tmaskedbitmap(dest) do begin
     if hasalpha then begin
      masked:= true;
      colormask:= true;
      if not getmask(8) then begin
       getmask(0); //try 8 bit
      end;
      col2:= maskcolorbackground;
      maskcolorbackground:= 0;
      colormask:= coloralpha1;
      fmonoalpha:= not coloralpha1;
      maskcolorbackground:= col2;
     end
     else begin
      masked:= false;
     end;
    end;
   end;
{$ifdef FPC}{$checkpointer default}{$endif}
   change;
  end;
 end;
end;

{$endif}

end.
