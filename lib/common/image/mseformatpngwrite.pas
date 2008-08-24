unit mseformatpngwrite;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
const
 pnglabel = 'png';
 
implementation
uses
 classes,msegraphics,msebitmap,fpwritepng,msegraphicstream,msestockobjects,
 fpimage;

procedure writegraphic(const dest: tstream;
                               const source: tobject;
                               const params: array of const);
                               //[grayscale      (default false),
                               // indexed        (default false),
                               // compressedtext (default true),
                               // wordsized      (default false),
                               // usealpha       (default source): boolean]
var
 ima: tmsefpmemoryimage;
 writer: tfpwriterpng;
 col1: tfpcolor;
begin
 try
  ima:= tmsefpmemoryimage.create(0,0);
  ima.assign(tpersistent(source));
  writer:= tfpwriterpng.create;
  writer.grayscale:= false;
  writer.indexed:= false;
  writer.compressedtext:= true;
  writer.wordsized:= false;
  writer.usealpha:= ima.hasalpha;
  if (length(params) > 0) and (tvarrec(params[0]).vtype = vtboolean) then begin
   writer.grayscale:= tvarrec(params[0]).vboolean;
   if (length(params) > 1) and (tvarrec(params[1]).vtype = vtboolean) then begin
    writer.indexed:= tvarrec(params[1]).vboolean;
    if (length(params) > 2) and (tvarrec(params[2]).vtype = vtboolean) then begin
     writer.compressedtext:= tvarrec(params[2]).vboolean;
     if (length(params) > 3) and (tvarrec(params[3]).vtype = vtboolean) then begin
      writer.wordsized:= tvarrec(params[3]).vboolean;
      if (length(params) > 4) and (tvarrec(params[4]).vtype = vtboolean) then begin
       writer.usealpha:= tvarrec(params[4]).vboolean;
      end;
     end;
    end;
   end;
  end;
  with ima do begin
   if hasalpha and monoalpha then begin
    if (height <> 0) and (width <> 0) then begin
     col1:= colors[0,0];         //force mode 4
     if col1.alpha = 0 then begin
      col1.alpha:= 1;
     end
     else begin
      col1.alpha:= $fffe;
     end;
     colors[0,0]:= col1;
    end;
   end;
  end;
  ima.writetostream(dest,writer);
 finally
  ima.free;
 end;
end;
  
initialization
 registergraphicformat(pnglabel,nil,{$ifdef FPC}@{$endif}writegraphic,
         stockobjects.captions[sc_PNG_Image],['*.png']);
end.
