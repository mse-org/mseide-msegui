{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mselatex;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestrings,mserichstring,msetypes;
 
function richstringtolatex(const source: richstringty): msestring;

implementation
uses
 msegraphutils,msearrayutils,msegraphics,sysutils;
 
const
 escchars = ['#','$','%','&','{','}','_'];
 
function richstringtolatex(const source: richstringty): msestring;

var
 d: pmsechar;
  
 procedure add(const astr: msestring);
 var
  i1: integer;
 begin
  i1:= length(astr);
  move(pointer(astr)^,d^,i1*sizeof(msechar));
  inc(d,i1);
 end;
 
const
 maxitemlen = 100; //maxlen of escape code + format code
var
 s,e,dend: pmsechar;
 mch1: msechar;
 formatindex: integer;
 styles1: fontstylesty;
 rgb1: rgbtriplety;
 defcolors: rgbtriplearty;
 i1,i2: integer;
begin
 if source.text = '' then begin
  result:= '';
 end
 else begin
  defcolors:= nil; //compiler warning
  setlength(result,2*length(source.text)+maxitemlen);
  d:= pointer(result);
  dend:= d + length(result) - maxitemlen;
  s:= pointer(source.text);
  formatindex:= 0;
  add('{');
//prichstringty(@source)^.format:= nil;
  repeat
   if formatindex > high(source.format) then begin
    e:= pmsechar(pointer(source.text)) + length(source.text);
   end
   else begin
    e:= pmsechar(pointer(source.text)) + source.format[formatindex].index;
   end;
   while s < e do begin
    mch1:= s^;
    if (ord(mch1) < $80) then begin
     if (char(byte(mch1)) in escchars) then begin
      d^:= '\';
      inc(d);
      d^:= mch1;
      inc(d);
     end
     else begin
      case mch1 of
       '\': begin
        add('\textbackslash{}');
       end;
       '^': begin
        add('\textasciicircum{}');
       end;
       '~': begin
        add('\textasciitilde{}');
       end;
       c_return: begin
        inc(d);  //ignore
       end;
       c_linefeed: begin
        add('\newline'+c_return);
  //      d^:= c_return; //paragraph
  //      inc(d);
       end;
       else begin
        d^:= mch1;
        inc(d);
       end;
      end;
     end;
    end
    else begin
     d^:= mch1;
     inc(d);
    end;
    if d >= dend then begin
     dend:= pmsechar(result); //backup
     setlength(result,length(result)*2);
     inc(d,(pmsechar(pointer(result))-dend)); //relocate
     dend:= pmsechar(pointer(result)) + length(result) - maxitemlen;
    end;
    inc(s);
   end;
   if formatindex <= high(source.format) then begin
    with source.format[formatindex] do begin
     styles1:= fontstylesty(newinfos) * style.fontstyle;
     if ni_fontcolor in newinfos then begin
      if style.fontcolor = 0 then begin
       add('\color{black}');
      end
      else begin
       rgb1:= colortorgb(not style.fontcolor);
       i2:= -1;
       for i1:= 0 to high(defcolors) do begin
        if colorty(defcolors[i1]) = colorty(rgb1) then begin
         i2:= i1;
         break;
        end;
       end;
       if i2 < 0 then begin
        additem(longwordarty(defcolors),colorty(rgb1));
        i2:= high(defcolors);
        add('\definecolor{c'+inttostr(i2)+'}{RGB}{'+
                      inttostr(rgb1.red)+','+
                      inttostr(rgb1.green)+','+
                      inttostr(rgb1.blue)+'}');
       end;
       add('\color{c'+inttostr(i2)+'}');
      end;
     end;
     if fs_bold in styles1 then begin
      add('\bfseries{}');
     end
     else begin
      if ni_bold in newinfos then begin
       add('\normalfont{}');
      end;
     end;
     if fs_italic in styles1 then begin
      add('\itshape{}');
     end
     else begin
      if ni_italic in newinfos then begin
       add('\upshape{}');
      end;
     end;
    end;
   end;
   inc(formatindex);
  until formatindex > length(source.format);
  add('}');
  setlength(result,d-pmsechar(pointer(result)));
 end;
end;

end.
