unit msegraphicstream;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 sysutils,classes,msebitmap,msegraphics{$ifdef FPC},fpimage{$endif},msestrings,
 msetypes;

const
 graphicformatdelimiter = ';'; 
type
 egraphicformat = class(exception);
 
{$ifdef FPC}
 fpreaderclassty = class of tfpcustomimagereader;
 
 tmsefpmemoryimage = class(tfpmemoryimage)
  public
   procedure assignto(dest: tpersistent); override;
 end;  
{$endif}

 readgraphicprocty = function(const source: tstream; const index: integer; 
                               const dest: tobject): boolean;
 writegraphicprocty = function(const dest: tstream;
                               const source: tobject): boolean;

procedure readgraphic(const source: tstream; const dest: tbitmap;
                           const aformatname: string = '';
                           const index: integer = -1); overload;
                           //index = select image in ico format
procedure readgraphic(const source: tstream; const dest: tmaskedbitmap;
                           const aformatname: string = '';
                           const index: integer = -1); overload;
                           //index = select image in ico format
procedure readgraphic(const source: tstream; const dest: timagelist); overload;
                           //only for ico format
                           
procedure writegraphic(const dest: tstream; const source: tbitmap;
                           const aformatname: string); overload;
procedure writegraphic(const dest: tstream; const source: tmaskedbitmap;
                           const aformatname: string); overload;
procedure writegraphic(const dest: tstream; const source: timagelist); overload;

procedure registergraphicformat(const aformatlabel: string;
                           const areadproc: readgraphicprocty;
                           const awriteproc: writegraphicprocty;
                           const afiltername: msestring;
                           const afilemask: array of msestring);
function graphicformatlabels: stringarty;
function graphicfilefilternames: msestringarty;
function graphicfilemasks: msestringarty;
function graphicfilefilterlabel(const index: integer): string;

{$ifdef FPC}

function readfpgraphic(const source: tstream; const readerclass: fpreaderclassty;
                             const dest: tpersistent): boolean;
{$endif}

implementation
uses
 msestockobjects,msegraphutils,msedatalist;
 
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

function graphicfilemasks: msestringarty;
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
  readproc:= areadproc;
  writeproc:= awriteproc;
  filtername:= afiltername;
  setlength(filemask,length(afilemask));
  for int1:= 0 to high(filemask) do begin
   filemask[int1]:= afilemask[int1];
  end;
 end;
end;

procedure readgraphic1(const source: tstream; const index: integer;
                const adest: tobject; const aformatlabel: string);
                //index = select image in ico format
var
 int1,int3: integer;
 ar1: stringarty;
 found: boolean;
begin
 if aformatlabel = '' then begin
  found:= true;
  for int1:= 0 to high(formats) do begin
   with formats[int1] do begin
    if assigned(readproc) then begin
     if readproc(source,index,adest) then begin
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
                            const aformatlabel: string);
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
  writeproc(dest,asource);
 end;
end;

procedure readgraphic(const source: tstream; const dest: tbitmap;
                           const aformatname: string = '';
                           const index: integer = -1); overload;
                           //index = select image in ico format
begin
 readgraphic1(source,index,dest,aformatname);
end;

procedure readgraphic(const source: tstream; const dest: tmaskedbitmap;
                           const aformatname: string = '';
                           const index: integer = -1); overload;
                           //index = select image in ico format
begin
 readgraphic1(source,index,dest,aformatname);
end;

procedure readgraphic(const source: tstream; const dest: timagelist); overload;
                           //index = select image in ico format
begin
 readgraphic1(source,-1,dest,'ico');
end;
                           
procedure writegraphic(const dest: tstream; const source: tbitmap;
                           const aformatname: string); overload;
                           //index = select image in ico format
begin
 writegraphic1(dest,source,aformatname);
end;

procedure writegraphic(const dest: tstream; const source: tmaskedbitmap;
                           const aformatname: string); overload;
                           //index = select image in ico format
begin
 writegraphic1(dest,source,aformatname);
end;

procedure writegraphic(const dest: tstream; const source: timagelist); overload;
                           //index = select image in ico format
begin
 writegraphic1(dest,source,'ico');
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

procedure tmsefpmemoryimage.assignto(dest: tpersistent);
var
 int1,int2: integer;
 po1: prgbtripleaty;
 col1: tfpcolor;
 hasalpha: boolean;
 coloralpha: boolean;
 by1: byte;
 col2: colorty;
begin
 if dest is tbitmap then begin
  with tbitmap(dest) do begin
   size:= makesize(self.width,self.height);
   hasalpha:= false;
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
      hasalpha:= hasalpha or (col1.alpha < $ff00);
     end;
    end;
   end;
   if hasalpha and (dest is tmaskedbitmap) then begin
    with tmaskedbitmap(dest) do begin
     masked:= true;
     colormask:= true;
     coloralpha:= false;
     for int1:= 0 to height - 1 do begin
      po1:= mask.scanline[int1];
      for int2:= 0 to width - 1 do begin
       by1:= colors[int2,int1].alpha shr 8;
       coloralpha:= coloralpha or ((by1 < 255) and (by1 > 0));
       with po1^[int2] do begin
        red:= by1;      
        green:= by1;      
        blue:= by1;      
        res:= 0;
       end;
      end;
     end;
     col2:= maskcolorbackground;
     maskcolorbackground:= 0;
     colormask:= coloralpha;
     maskcolorbackground:= col2;
    end;
   end;
{$ifdef FPC}{$checkpointer default}{$endif}
   change;
  end;
 end;
end;

{$endif}

end.
