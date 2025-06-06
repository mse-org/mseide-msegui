{ MSEgui Copyright (c) 1999-2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedrawtext;
{$ifdef FPC}{$mode objfpc}{$h+}{$GOTO ON}{$interfaces corba}{$endif}

//todo: optimize speed

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
 classes,mclasses,msegraphics,mserichstring,
  msegraphutils,
  msearrayprops,mseclasses,msestrings,msetypes,mseguiglob;

const
 defaulttabwidth = 20; //mm
 textellipse = msestring('...');

type
 textflagty = (tf_left,tf_xcentered,tf_right,tf_xjustify,
               tf_top,tf_ycentered,tf_bottom,
                //order fix, used in msepostscriptprinter
                  //tf_left and tf_right can be combined with tf_xcentered,
                  //tf_top and tf_bottom can be combined with tf_ycentered
                  //for limitting centering to avalable space

               tf_rotate90,tf_rotate180,
//               tf_forcealignment, //do not use default alignment for buttons
               tf_clipi,tf_clipo,
               tf_grayed,tf_wordbreak,tf_softhyphen,
               tf_noselect,tf_underlineselect,
               tf_ellipseleft,{tf_ellipsemid,}tf_ellipseright,
               tf_tabtospace,tf_showtabs,tf_glueimage, //used in button captions
               tf_force);
 textflagsty = set of textflagty;
const
 ellipsemask: textflagsty = [tf_ellipseleft,{tf_ellipsemid,}tf_ellipseright];
 textalignments = [tf_left,tf_xcentered,tf_right,tf_xjustify,
                   tf_top,tf_ycentered,tf_bottom];

type

 tabulatorkindty = (tak_left,tak_right,tak_centered,tak_decimal,tak_nil);
 tabulatorty = record
  index: integer;
  tabkind: tabulatorkindty;
  linepos: integer;
  textpos: integer;
  width: integer;
  cellwidth: integer;
 end;
 tabulatorarty = array of tabulatorty;
 tabulatorstatety = (tas_editactive);
 tabulatorstatesty = set of tabulatorstatety;

 ttabulatoritem = class(townedpersistent)
  private
   fkind: tabulatorkindty;
   fpos: real;
   procedure setkind(const avalue: tabulatorkindty);
   procedure setdistleft(const avalue: real);
   procedure setdistright(const avalue: real);
  protected
   fstate: tabulatorstatesty;
   fdistleft: real;
   fdistright: real;
   function getenabled(): boolean virtual;
   procedure setpos(const avalue: real); virtual;
   property distleft: real read fdistleft write setdistleft; //mm
   property distright: real read fdistright write setdistright; //mm
  public
  published
   property kind: tabulatorkindty read fkind write setkind default tak_left;
   property pos: real read fpos write setpos; //mm
 end;
 tabulatoritemclassty = class of ttabulatoritem;

 tcustomtabulators = class(townedpersistentarrayprop)
  private
   fppmm: real;
   fuptodate: boolean;
   fdefaultdist: real;
   procedure setppmm(const avalue: real);
   function gettabs: tabulatorarty;
   function getitems(const index: integer): ttabulatoritem;
   procedure setitems(const index: integer; const avalue: ttabulatoritem);
   procedure setdefaultdist(const avalue: real);
   function getpos(const index: integer): integer;
   function getlinepos(const index: integer): integer;
   procedure setlinepos(const index: integer; const avalue: integer);
  protected
   ftabs: tabulatorarty;
   procedure checkuptodate;
   procedure dochange(const index: integer); override;
   procedure changed(const sender: ttabulatoritem);
   class function getitemclass: tabulatoritemclassty; virtual;
  public
   constructor create; reintroduce;
   class function getitemclasstype: persistentclassty; override;
   procedure assign(source: tpersistent); override;
   procedure add(const apos: real; const akind: tabulatorkindty);
   procedure setdefaulttabs(const awidth: real = 20; const acount: integer = 20;
                         const akind: tabulatorkindty = tak_left);
   property tabs: tabulatorarty read gettabs;
   property ppmm: real read fppmm write setppmm;
      //pixel per millimeter
   property defaultdist: real read fdefaultdist write setdefaultdist; //0 -> none
   property items[const index: integer]: ttabulatoritem read getitems
                       write setitems; default;
   property pos[const index: integer]: integer read getpos;
   property linepos[const index: integer]: integer read getlinepos write setlinepos;
 end;

 ttabulators = class(tcustomtabulators)
  published
   property ppmm;
   property defaultdist;
 end;

 drawtextinfoty = record
  text: richstringty;
  dest,clip: rectty;
  flags: textflagsty;
  font: tfont;
  tabulators: tcustomtabulators;
  res: rectty;
 end;

 tabinfoty = record
  index: integer;
  kind: tabulatorkindty;
  linepos: integer;
 end;
 tabinfoarty = array of tabinfoty;

 textlineinfoty = record
  liindex,licount: integer;
  liy: integer;
  listartx: integer;
  liwidth: integer;
  tabchars: tabinfoarty;
  justifychars: tabinfoarty;
  linebreak: boolean;  //true if newline sequence detected
 end;
 textlineinfoarty = array of textlineinfoty;

 layoutinfoty = record
  charwidths: integerarty;
  lineinfos: textlineinfoarty;
  ascent,descent,lineheight,
  underline,strikeout: integer;
  starty: integer;
  height: integer;
  xyswapped: boolean;
  reversed: boolean;
 end;

function checktextflags(old,new: textflagsty): textflagsty;

procedure drawtext(const canvas: tcanvas; var info: drawtextinfoty); overload;
procedure drawtext(const canvas: tcanvas; const text: richstringty;
                   const dest: rectty; flags: textflagsty = [];
                   font: tfont = nil; tabulators: tcustomtabulators = nil); overload;
procedure drawtext(const canvas: tcanvas; const text: richstringty;
                   const dest,clip: rectty; flags: textflagsty = [];
                   font: tfont = nil; tabulators: tcustomtabulators = nil); overload;
procedure drawtext(const canvas: tcanvas; const text: msestring;
                   const dest,clip: rectty; flags: textflagsty = [];
                   font: tfont = nil; tabulators: tcustomtabulators = nil); overload;
procedure drawtext(const canvas: tcanvas; const text: msestring;
                   const dest: rectty; flags: textflagsty = [];
                   font: tfont = nil; tabulators: tcustomtabulators = nil); overload;
procedure layouttext(const canvas: tcanvas; var info: drawtextinfoty;
                               out layoutinfo: layoutinfoty); overload;
function breaklines(const canvas: tcanvas;
                         var info: drawtextinfoty): richstringarty; overload;
function breaklines(const canvas: tcanvas; const text: richstringty;
                   const width: integer; font: tfont = nil): richstringarty; overload;
function breaklines(const canvas: tcanvas; const text: msestring;
                   const width: integer; font: tfont = nil): msestringarty; overload;

procedure textrect(const canvas: tcanvas; var info: drawtextinfoty); overload;
                         //result in info.res
function textrect(const canvas: tcanvas; const text: richstringty;
                   const dest: rectty; flags: textflagsty = [];
                   font: tfont = nil; tabulators: tcustomtabulators = nil): rectty; overload;
function textrect(const canvas: tcanvas; const text: richstringty;
                   flags: textflagsty = []; font: tfont = nil;
                    tabulators: tcustomtabulators = nil): rectty; overload;
function textrect(const canvas: tcanvas; const text: msestring;
                   const dest: rectty; flags: textflagsty = [];
                   font: tfont = nil; tabulators: tcustomtabulators = nil): rectty; overload;
function textrect(const canvas: tcanvas; const text: msestring;
                   flags: textflagsty = []; font: tfont = nil;
                   tabulators: tcustomtabulators = nil): rectty; overload;
function textclipped(const canvas: tcanvas; var info: drawtextinfoty): boolean;

function postotextindex(const canvas: tcanvas; var info: drawtextinfoty;
                             const pos: pointty; out aindex: integer): boolean;
    //false if out of text
function textindextopos(const canvas: tcanvas; var info: drawtextinfoty;
                                 aindex: integer): pointty;

implementation
uses
 mseguiintf,msebits,msearrayutils,{$ifdef FPC}math{$else}Math{$endif},msereal,
 sysutils,msefont,mseformatstr;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

type
 tcanvas1 = class(tcanvas);

function checktextflags(old,new: textflagsty): textflagsty;
const
// xmask: textflagsty = [tf_xcentered,tf_right];
 xmask: textflagsty = [tf_left,tf_right];
// ymask: textflagsty = [tf_ycentered,tf_bottom];
 ymask: textflagsty = [tf_top,tf_bottom];
begin
 result:= new;
 result:= textflagsty(setsinglebit({$ifdef FPC}longword{$else}longword{$endif}(result),
              {$ifdef FPC}longword{$else}longword{$endif}(old),
              {$ifdef FPC}longword{$else}longword{$endif}(ymask)));
 result:= textflagsty(setsinglebit({$ifdef FPC}longword{$else}longword{$endif}(result),
              {$ifdef FPC}longword{$else}longword{$endif}(old),
              {$ifdef FPC}longword{$else}longword{$endif}(xmask)));
 result:= textflagsty(setsinglebit({$ifdef FPC}longword{$else}longword{$endif}(result),
              {$ifdef FPC}longword{$else}longword{$endif}(old),
              {$ifdef FPC}longword{$else}longword{$endif}(ellipsemask)));
// if tf_default in result then begin
//  result:= [tf_default];
// end;
end;

procedure additem(var dest: tabinfoarty; const value: integer);
begin
 setlength(dest,high(dest)+2);
 with dest[high(dest)] do begin
  index:= value;
  //kind:= tabulatorkindty(-1); //invalid
  kind:= tak_nil;
 end;
end;

procedure addtabchar(var dest: tabinfoarty; const aindex: integer;
                      const akind: tabulatorkindty; const alinepos: integer);
 procedure setdata(const ind: integer);
 begin
  with dest[ind] do begin
   index:= aindex;
   kind:= akind;
   linepos:= alinepos;
  end;
 end;

var
 int1: integer;
begin
 for int1:= 0 to high(dest) do begin
  if dest[int1].index = aindex then begin
   exit;
  end;
  if dest[int1].index > aindex then begin
   setlength(dest,high(dest) + 2);
   move(dest[aindex],dest[aindex+1],(high(dest)-aindex) * sizeof(dest[0]));
   setdata(int1);
   exit;
  end;
 end;
 setlength(dest,high(dest) + 2);
 setdata(high(dest));
end;

function comparetabinfo(const l,r): integer;
begin
 result:= tabinfoty(l).index-tabinfoty(r).index;
end;

function mergearray(const a,b: tabinfoarty): tabinfoarty;
         //result is sorted without duplicates
var
 int1,int2: integer;
 ar1: integerarty;
begin
 setlength(result,length(a)+length(b));
 if result <> nil then begin
  move(a[0],result[0],length(a)*sizeof(result[0]));
  move(b[0],result[length(a)],length(b)*sizeof(result[0]));
  mergesortarray(result,sizeof(result[0]),length(result),
                                        @comparetabinfo,ar1,true);
  int2:= 0;
  for int1:= 1 to high(result) do begin
   if result[int2].index <> result[int1].index then begin
    inc(int2);
    result[int2]:= result[int1];
   end;
  end;
  setlength(result,int2+1);
 end;
end;

procedure layouttext(const canvas: tcanvas; var info: drawtextinfoty;
                              out layoutinfo: layoutinfoty);
var
 drawinfo: drawinfoty;
 awidth: integer;
 resultpo1: pinteger;
 text1: pmsechar;
 highresfo: boolean;

 procedure getcharwidths(acount: integer);
 var
  fontmetrics1: fontmetricsty;
  int1: integer;
 begin
  if acount <= 0 then begin
   exit;
  end;
  if fs_blank in canvas.font.style then begin
   for int1:= 0 to acount-1 do begin
   {$ifdef FPC}
    resultpo1[int1]:= 0;
   {$else}
    pinteger(pchar(pointer(resultpo1))+int1*sizeof(integer))^:= 0;
   {$endif}
   end;
  end
  else begin
   with drawinfo.getchar16widths do begin
    fontdata:= getfontdata(canvas.font.handle);
    resultpo:= resultpo1;
    text:= text1;
    count:= acount;
    if highresfo then begin
     checkhighresfont(fontdata,tcanvas1(canvas).fdrawinfo);
    end;
    getchar16widths(drawinfo);
   end;
   if tf_tabtospace in info.flags then begin
    with drawinfo.getfontmetrics do begin
     fontdata:= drawinfo.getchar16widths.fontdata;
     char:= ord(' ');
     resultpo:= @fontmetrics1;
     getfontmetrics({datapo,}drawinfo);
    end;
    for int1:= 0 to acount-1 do begin
     if (text1+int1)^ = c_tab then begin
      pintegeraty(resultpo1)^[int1]:= fontmetrics1.width;
     end;
    end;
   end;
  end;
  inc(text1,acount);
  inc(resultpo1,acount);
 end;

 function checklinebreak(var aindex: integer): boolean;
 var
  ch1: msechar;
 begin
  ch1:= info.text.text[aindex];
  result:= (ch1 = c_return) or (ch1 = c_linefeed);
  if result then begin
   with layoutinfo do begin
    with lineinfos[high(lineinfos)] do begin
     licount:= aindex - liindex;
     liwidth:= awidth;
     linebreak:= true;
    end;
    inc(aindex);
    if (ch1 = c_return) and (aindex <= length(info.text.text)) and
            (info.text.text[aindex] = c_linefeed) then begin
     inc(aindex);
    end;
    setlength(lineinfos,high(lineinfos) + 2);
    with lineinfos[high(lineinfos)] do begin
     liindex:= aindex;
    end;
   end;
  end;
 end;
//{$define mswindows}
 function tabitemwidth(const charindex: integer;
                       const stopchar: msechar): integer;
 var
  po1: pinteger;
  po2: pmsechar;
 begin
  result:= 0;
  po1:= @{pointer}(layoutinfo.charwidths[charindex]);
  po2:= @info.text.text[charindex+1];
  while true do begin
   case po2^ of
    ' ',c_tab,c_return,c_linefeed,#0: begin
     break;
    end;
    else begin
     if po2^ = stopchar then begin
      break;
     end;
     result:= result + po1^;
     inc(po1);
     inc(po2);
    end;
   end;
  end;
 end;
var
 int1,int2,int3,int4: integer;
 textlen: integer;
 style1: fontstylesty;
 nexttab: integer;
 rea1,rea2: real;
 tabs: tabulatorarty;
 po1: pmsecharaty;
 bo1: boolean;
 wch1: widechar;

 procedure checksofthyphen(const alineinfo: integer);
 begin
  if tf_softhyphen in info.flags then begin
   with layoutinfo do begin
    if (int2 > 0) and (info.text.text[int2] = c_softhyphen) then begin
     charwidths[int2-1]:= 0;
     additem(lineinfos[alineinfo].tabchars,int2);
    end;
   end;
  end;
 end;

var
 y1,orig1,int5: integer;
 fontmetrics1: fontmetricsty;
 hasitaliccomp: boolean;
{$ifdef mswindows}
 italicsafetymargin: int32;
{$endif}

begin
 tabs:= nil; //compiler warning
 if info.font <> nil then begin
  canvas.font:= info.font;
 end;
 try
  gdi_lock;
  with info,tcanvas1(canvas),layoutinfo do begin
   if tf_rotate90 in flags then begin
    swapxy1(dest);
   end;
   checkgcstate([cs_gc]);
   highresfo:= df_highresfont in fdrawinfo.gc.drawingflags;
   canvas.initdrawinfo(drawinfo);
   ascent:= font.ascent;
   descent:= font.descent;
   lineheight:= font.lineheight;
   textlen:= length(text.text);
   setlength(charwidths,textlen);
   text1:= pointer(info.text.text);
   resultpo1:= pointer(charwidths);
   if text.format = nil then begin
    getcharwidths(textlen);
   end
   else begin
    int2:= 0;
    style1:= font.style;
    for int1:= 0 to high(text.format) do begin
     with text.format[int1] do begin
      if newinfos * fontlayoutflags <> [] then begin
       if index > textlen then begin
        getcharwidths(textlen-int2);
       end
       else begin
        getcharwidths(index-int2);
       end;
       int2:= index;
       font.style:= style.fontstyle;
      end;
     end;
    end;
    if int2 < length(text.text) then begin
     getcharwidths(length(text.text)-int2);
    end;
    font.style:= style1;
   end;
   setlength(lineinfos,1);
   lineinfos[0].liindex:= 1;
   int1:= 1;
   awidth:= 0; //textwidth
   if tf_wordbreak in flags then begin
    int2:= 0;
    while int1 <= textlen do begin
     int2:= 0; //index of last whitespace
     int3:= 0; //textwidth of last whitespace
     awidth:= 0; //textwidth
     while int1 <= textlen do begin
      wch1:= text.text[int1];
      if (wch1 = ' ') or
         ((wch1 = '-') and (int1 > 1) and (text.text[int1-1] <> ' ') or
         (wch1 = c_softhyphen)) and
             (awidth + charwidths[int1-1] <= info.dest.cx) then begin
       checksofthyphen(high(lineinfos));
       int2:= int1;
       int3:= awidth;
      end
      else begin
       if checklinebreak(int1) then begin
        checksofthyphen(high(lineinfos)-1);
        break;
       end;
      end;
      if (wch1 <> c_softhyphen) or not (tf_softhyphen in flags) then begin
       inc(awidth,charwidths[int1-1]);
      end;
      if (awidth > info.dest.cx) and (awidth > charwidths[int1-1]) then begin
                            //min one char on line
       with lineinfos[high(lineinfos)] do begin
        if (int2 > 0) then begin //use last whitespace for break
         if text.text[int2] <> ' ' then begin
          inc(int3,charwidths[int2-1]); //'-'
          licount:= int2 - liindex + 1;
         end
         else begin
          licount:= int2 - liindex;
         end;
         liwidth:= int3;
         int1:= int2 + 1;
        end
        else begin
         licount:= int1 - liindex; //no whitespace to break
         liwidth:= awidth - charwidths[int1-1];
        end;
       end;
       setlength(lineinfos,high(lineinfos) + 2);
       with lineinfos[high(lineinfos)] do begin
        liindex:= int1;
       end;
       break;
      end;
      inc(int1);
     end;
     checksofthyphen(high(lineinfos));
    end;
    with lineinfos[high(lineinfos)] do begin
     if textlen > 0 then begin
      licount:= textlen - liindex + 1;
     end;
     liwidth:= awidth;
    end;
   end
   else begin //no linebreak
    if (info.tabulators = nil) or
      (info.tabulators.count = 0) and (info.tabulators.defaultdist = 0) or
                                      (tf_tabtospace in flags) then begin
     while int1 <= textlen do begin
      if (tf_softhyphen in info.flags) and (info.text.text[int1] = c_softhyphen) then begin
       charwidths[int1-1]:= 0;
       additem(lineinfos[high(lineinfos)].tabchars,int1);
      end;
      if not checklinebreak(int1) then begin
       inc(awidth,charwidths[int1-1]);
       inc(int1);
      end
      else begin
       awidth:= 0;
      end;
     end;
    end
    else begin //with tabulators
     tabs:= info.tabulators.tabs;
     rea1:= info.tabulators.defaultdist * info.tabulators.ppmm;
     nexttab:= -1;
     while int1 <= textlen do begin
      if (tf_softhyphen in info.flags) and
                       (info.text.text[int1] = c_softhyphen) then begin
       charwidths[int1-1]:= 0;
       additem(lineinfos[high(lineinfos)].tabchars,int1);
      end;
      if not checklinebreak(int1) then begin
       if info.text.text[int1] = c_tab then begin
        if tabs <> nil then begin
         inc(nexttab);
         if nexttab < info.tabulators.count then begin
          case tabs[nexttab].tabkind of
           tak_right: begin
            charwidths[int1-1]:= tabs[nexttab].textpos - awidth -
                                    tabitemwidth(int1,#0);
           end;
           tak_centered: begin
            charwidths[int1-1]:= tabs[nexttab].textpos - awidth -
                                    tabitemwidth(int1,#0) div 2;
           end;
           tak_decimal: begin
            charwidths[int1-1]:= tabs[nexttab].textpos - awidth -
                                  tabitemwidth(int1,
                                    defaultformatsettingsmse.decimalseparator);
           end;
           else begin //tak_left
            charwidths[int1-1]:= tabs[nexttab].textpos - awidth;
           end;
          end;
          with tabs[nexttab] do begin
           addtabchar(lineinfos[high(lineinfos)].tabchars,int1,tabkind,linepos);
          end;
         end
         else begin
          if rea1 > 0 then begin
           int5:= round(ceil(awidth / rea1)*rea1);
           charwidths[int1-1]:= int5 - awidth;
           addtabchar(lineinfos[high(lineinfos)].tabchars,int1,tak_left,int5);
          end;
         end;
        end
        else begin
         if rea1 > 0 then begin
          int5:= round(floor((awidth+rea1+0.1)/rea1)*rea1);
          charwidths[int1-1]:= int5 - awidth;
          addtabchar(lineinfos[high(lineinfos)].tabchars,int1,tak_left,int5);
         end;
        end;
       end;
       inc(awidth,charwidths[int1-1]);
       inc(int1);
      end
      else begin
       awidth:= 0;
       nexttab:= -1;
      end;
     end;
    end;
    with lineinfos[high(lineinfos)] do begin
     liwidth:= awidth;
     licount:= int1-liindex;
    end;
   end;
   if high(lineinfos) >= 0 then begin
    height:= lineheight*high(lineinfos)+ascent+descent;
   end
   else begin
    height:= 0;
   end;
   res.y:= info.dest.y;
   if tf_ycentered in flags then begin
    if info.dest.cy < height then begin
     if tf_bottom in flags then begin
      res.y:= res.y + info.dest.cy - height;
     end
     else begin
      if not (tf_top in flags) then begin
       res.y:= res.y + (info.dest.cy - height -1) div 2;
      end;
     end;
    end
    else begin
     res.y:= res.y + (info.dest.cy - height) div 2;
    end;
   end
   else begin
    if tf_bottom in flags then begin
     res.y:= res.y + info.dest.cy - height;
    end;
   end;
   y1:= res.y + ascent; //layoutinfo
   starty:= y1;
   res.x:= bigint;
   res.cy:= height;
   res.cx:= 0;
   hasitaliccomp:= (text.format = nil) and font.italic;
   if hasitaliccomp then begin
    with drawinfo.getfontmetrics do begin
     fontdata:= getfontdata(canvas.font.handle);
     resultpo:= @fontmetrics1;
  {$ifdef mswindows}
     italicsafetymargin:= (lineheight+10) div 20;
  {$endif}
    end;
   end;
   for int3:= 0 to high(lineinfos) do begin
    with layoutinfo.lineinfos[int3] do begin
     liy:= y1;
     y1:= y1 + lineheight;
     listartx:= info.dest.x;
     if hasitaliccomp and (licount > 0) then begin
      with drawinfo.getfontmetrics do begin
       char:= getucs4char(text.text,liindex);
       msefont.getfontmetrics({datapo,}drawinfo);
       listartx:= listartx - fontmetrics1.leftbearing
                                {$ifdef mswindows} + 1{$endif};
       liwidth:= liwidth - fontmetrics1.leftbearing;
       char:= getucs4char(text.text,liindex+licount-1);
       msefont.getfontmetrics({datapo,}drawinfo);
       liwidth:= liwidth-fontmetrics1.rightbearing
                  {$ifdef mswindows}+ 1 + italicsafetymargin{$endif};
      end;
     end;
     if tf_xcentered in flags then begin
      if info.dest.cx < liwidth then begin
       if tf_right in flags then begin
        listartx:= listartx + info.dest.cx - liwidth;
       end
       else begin
        if not (tf_left in flags) then begin
         listartx:= listartx + (info.dest.cx - liwidth - 1) div 2;
        end;
       end;
      end
      else begin
       listartx:= listartx + (info.dest.cx - liwidth) div 2;
      end;
     end
     else begin
      if tf_right in flags then begin
       listartx:= listartx + info.dest.cx - liwidth;
      end;
     end;
     if res.x > listartx then begin
      res.x:= listartx;
     end;
     if res.cx < liwidth then begin
      res.cx:= liwidth;
     end;
    end;
   end;
   if (tf_xjustify in flags) and (dest.cx > 0) then begin
    po1:= pointer(info.text.text);
    bo1:= false;
    int3:= high(lineinfos);
    if tf_wordbreak in flags then begin
     dec(int3);
    end;
    for int3:= 0 to int3 do begin
     with lineinfos[int3] do begin
      if not linebreak then begin
       bo1:= true;
       int4:= 0;
       setlength(justifychars,licount); //max
       for int1:= liindex-1 to liindex + licount - 2 do begin
        if po1^[int1] = ' ' then begin
         with justifychars[int4] do begin
          index:= int1+1;
         end;
         inc(int4);
        end;
       end;
       setlength(justifychars,int4);
       if (int4 > 0) and not (cs_internaldrawtext in fstate) then begin
        rea1:= (dest.cx - liwidth) / int4;
        rea2:= 0;
        int2:= 0;
        for int1:= 0 to high(justifychars) do begin
         rea2:= rea2 + rea1;
         int4:= round(rea2) - int2;
         inc(charwidths[justifychars[int1].index-1],int4);
         inc(int2,int4);
        end;
        listartx:= dest.x;
        if tabchars <> nil then begin
         tabchars:= mergearray(tabchars,justifychars);
        end
        else begin
         tabchars:= justifychars;
        end;
        justifychars:= nil;
       end;
      end;
     end;
    end;
    if bo1 then begin
     if res.cx <= dest.cx then begin
      res.x:= dest.x;
      res.cx:= dest.cx;
     end;
    end;
   end;
   underline:= descent div 2 + 1;
   if underline = 0 then begin
    underline:= 1;
   end;
   if underline >= descent then begin
    underline:= descent - 1;
   end;
   strikeout:= - (ascent div 3);
   xyswapped:= false;
   reversed:= false;
   if flags * [tf_rotate90,tf_rotate180] <> [] then begin
    if (tf_rotate90 in flags) xor (tf_rotate180 in flags) then begin //mirror x
     orig1:= dest.x + dest.x + dest.cx;
     res.x:= orig1 - res.x - res.cx;
     for int1:= 0 to high(lineinfos) do begin
      with lineinfos[int1] do begin
       listartx:= orig1-listartx;
      end;
     end;
     for int1:= 0 to high(charwidths) do begin
      charwidths[int1]:= - charwidths[int1];
     end;
    end;
    reversed:= (tf_rotate180 in flags);
    if reversed then begin //mirror y
     ascent:= -ascent;
     descent:= -descent;
     lineheight:= -lineheight;
     underline:= -underline;
     strikeout:= -strikeout;
     orig1:= dest.y + dest.y + dest.cy;
     res.y:= orig1 - res.y - res.cy;
     starty:= orig1 - starty;
     for int1:= 0 to high(lineinfos) do begin
      with lineinfos[int1] do begin
       liy:= orig1-liy;
      end;
     end;
    end;
    xyswapped:= tf_rotate90 in flags;
    if xyswapped then begin
     swapxy1(dest);
     swapxy1(res);
    end;
   end;
  end;
 finally
  gdi_unlock;
 end;
end;

function breaklines(const canvas: tcanvas;
                        var info: drawtextinfoty): richstringarty;
var
 la1: layoutinfoty;
 int1: integer;
begin
 layouttext(canvas,info,la1);
 setlength(result,length(la1.lineinfos));
 for int1:= 0 to high(result) do begin
  with la1.lineinfos[int1] do begin
   result[int1]:= richcopy(info.text,liindex,licount);
  end;
 end;
end;

function breaklines(const canvas: tcanvas; const text: richstringty;
                   const width: integer; font: tfont = nil): richstringarty;
var
 info: drawtextinfoty;
begin
 info.text:= text;
 info.dest.pos:= nullpoint;
 info.dest.cx:= width;
 info.dest.cy:= bigint;
 info.flags:= [tf_wordbreak];
 info.font:= font;
 info.tabulators:= nil;
 result:= breaklines(canvas,info);
end;

function breaklines(const canvas: tcanvas; const text: msestring;
                   const width: integer; font: tfont = nil): msestringarty;
var
 rstr1: richstringty;
 ar1: richstringarty;
 int1: integer;
begin
 rstr1.format:= nil;
 rstr1.text:= text;
 ar1:= breaklines(canvas,rstr1,width,font);
 setlength(result,length(ar1));
 for int1:= 0 to high(ar1) do begin
  result[int1]:= ar1[int1].text;
 end;
end;

procedure adjustellipse(const acanvas: tcanvas; const info: drawtextinfoty;
                           const layoutinfo: layoutinfoty;
                           const line: integer; var startx: integer;
                           out startindex: integer; out endindex: integer);
var
 ellipsewidth,ellipsewidthsum: integer;
 int1: integer;
begin
 with info,layoutinfo,lineinfos[line] do begin
  startindex:= liindex;
  endindex:= liindex + licount - 1;
  if (liwidth > dest.cx) and (flags * ellipsemask <> []) then begin
   ellipsewidth:= acanvas.getstringwidth(textellipse);
   ellipsewidthsum:= liwidth + ellipsewidth;
   if tf_ellipseleft in flags then begin
    startindex:= licount;
    for int1:= liindex-1 to liindex+licount-2 do begin
     dec(ellipsewidthsum,charwidths[int1]);
     if ellipsewidthsum < dest.cx then begin
      startindex:= int1+2;
      break;
     end;
    end;
    startx:= startx + ellipsewidth;
   end
   else begin
    for int1:= liindex+licount-2 downto liindex-1 do begin
     dec(ellipsewidthsum,charwidths[int1]);
     if ellipsewidthsum < dest.cx then begin
      endindex:= int1;
      break;
     end;
    end;
   end;
   if tf_right in flags then begin
    startx:= startx + (liwidth-ellipsewidthsum);
   end
   else begin
    if tf_xcentered in flags then begin
     startx:= startx + (liwidth-ellipsewidthsum) div 2;
    end;
   end;
  end;
 end;
end;

function postotextindex(const canvas: tcanvas; var info: drawtextinfoty;
                           const pos: pointty; out aindex: integer): boolean;
    //false if out of text
var
 layoutinfo: layoutinfoty;
 int1,int2: integer;
 startindex,endindex: integer;
begin
 result:= true;
 with info,canvas,layoutinfo do begin
  if text.text = '' then begin
   result:= false;
   aindex:= 0;
   exit;
  end;
  layouttext(canvas,info,layoutinfo);
  if pos.y < res.y then begin
   result:= false;
   aindex:= 0;
  end
  else begin
   if pos.y >= res.y + height then begin
    aindex:= length(text.text);
    result:= false;
   end
   else begin
    int1:= (pos.y-starty+ascent) div lineheight;
    if int1 > high(lineinfos) then begin
     int1:= high(lineinfos); //last line is ascent+descent
    end;
    with lineinfos[int1] do begin
     int2:= listartx;
     adjustellipse(canvas,info,layoutinfo,int1,int2,startindex,endindex);
//     int3:= liindex + licount - 1;
     aindex:= endindex;
     result:= false;
//     for int1:= liindex-1 to liindex+licount-2 do begin
     for int1:= startindex-1 to endindex-1 do begin
      inc(int2,charwidths[int1]);
      if int2 >= pos.x then begin
       aindex:= int1;
       result:= true;
       break;
      end;
     end;
     if aindex < endindex then begin
      if int2 - pos.x < charwidths[aindex] div 2 then begin
       inc(aindex);
      end;
     end;
    end;
   end;
  end;
 end;
end;

function textindextopos(const canvas: tcanvas; var info: drawtextinfoty;
                                                    aindex: integer): pointty;
var
 layoutinfo: layoutinfoty;
 int1,int2,int3: integer;
 startindex,endindex: integer;
begin
 with info,layoutinfo do begin
  layouttext(canvas,info,layoutinfo);
  if aindex > length(text.text) then begin
   aindex:= length(text.text);
  end
  else begin
   if aindex < 0 then begin
    aindex:= 0;
   end;
  end;
  int3:= 0; //compiler warning
  for int1:= 0 to high(lineinfos) do begin
   with lineinfos[int1] do begin
    if liindex + licount > aindex then begin
     int3:= int1;
     break;
    end;
   end;
  end;
  result.y:= starty + int3 * lineheight;
  with lineinfos[int3] do begin
   int2:= listartx;
   adjustellipse(canvas,info,layoutinfo,int3,int2,startindex,endindex);
//   for int1:= liindex-1 to aindex-1 do begin
   for int1:= startindex-1 to aindex-1 do begin
    inc(int2,charwidths[int1]);
   end;
   result.x:= int2;
  end;
 end;
end;

procedure drawtext(const canvas: tcanvas; var info: drawtextinfoty);
const
 stopmask = [ni_bold,ni_italic,ni_blank,ni_underline,ni_strikeout,ni_selected,
             ni_fontcolor,ni_colorbackground];
 fonthandlemask = [ni_bold,ni_italic];
 fontstylemask = [ni_bold,ni_italic,ni_blank,ni_underline,ni_strikeout];

var
 layoutinfo: layoutinfoty;
 pos: pointty;
 infoindexbefore,charindexbefore: integer;
 last: boolean;
 count: integer;
 defaultcolor,defaultcolorbackground: colorty;
 afontstyle,fontstylebefore,overridefontstyle: fontstylesty;
 grayed: boolean;
 formatactive: boolean;
 endindex: integer;
 ellipsewidthsum: integer;
 rot: real;

 procedure drawsubstring(const row,astart,acount: integer);
 var
  int2,int3,int4,int5,int6: integer;
  xbefore: integer;
  x: integer;
  co1: colorty;
 begin
  if acount > 0 then begin
   if layoutinfo.xyswapped then begin
    x:= pos.y;
   end
   else begin
    x:= pos.x;
   end;
   xbefore:= x;

   with info,tcanvas1(canvas),layoutinfo,lineinfos[row] do begin
    if tabchars = nil then begin
     drawstring(@text.text[astart],acount,pos,nil,grayed,rot);
     for int2:= astart - 1 to astart + acount - 2 do begin
      inc(x,charwidths[int2]);
     end;
    end
    else begin
     int2:= astart - 1;
     for int4:= 0 to high(tabchars) do begin
      if (tabchars[int4].index >= astart) and
                             (tabchars[int4].index < astart + acount) then begin
       drawstring(@text.text[int2+1],tabchars[int4].index - int2 - 1,pos,nil,
                                                                  grayed,rot);
       for int2:= int2 to tabchars[int4].index - 1 do begin
        inc(x,charwidths[int2]);
       end;
       int3:= charwidths[tabchars[int4].index - 1];
       co1:= font.colorbackground;
       if (co1 <> cl_transparent) and (co1 <> cl_default) then begin
        if xyswapped then begin
         if reversed then begin
          fillrect(makerect(pos.x-font.descent,x - int3,
                       font.ascent+font.descent,int3),font.colorbackground);
         end
         else begin
          fillrect(makerect(pos.x-font.ascent,x - int3 - 1,
                       font.ascent+font.descent,int3),font.colorbackground);
         end;
        end
        else begin
         if reversed then begin
          fillrect(makerect(x - int3 - 1,pos.y-font.descent,int3,
                      font.ascent+font.descent),font.colorbackground);
         end
         else begin
          fillrect(makerect(x - int3,pos.y-font.ascent,int3,
                      font.ascent+font.descent),font.colorbackground);
         end;
        end;
       end;
       with tabchars[int4] do begin
        int2:= index;
        int5:= pos.y - font.ascent div 2;
        int6:= x - int3 div 2 + 1;
        if (tf_showtabs in flags) and (kind <> tabulatorkindty(tak_nil)) and
                                    not xyswapped and not reversed then begin
         drawline(mp(int6 - 3,int5),mp(int6,int5),font.color);
         drawlines([mp(int6,int5-1),mp(int6+1,int5),
                                mp(int6,int5+1)],true,font.color);
        {
         case kind of
          tak_left: begin
           drawlines([mp(linepos,int5-2),mp(linepos,int5),
                      mp(linepos+2,int5)],false,font.color);
          end;
          tak_right: begin
           drawlines([mp(linepos,int5-2),mp(linepos,int5),
                      mp(linepos-2,int5)],false,font.color);
          end;
          tak_centered,tak_decimal: begin
           drawlinesegments([mg(mp(linepos,int5-2),mp(linepos,int5)),
                   mg(mp(linepos-2,int5),mp(linepos+2,int5))],font.color);
          end;
         end;
        }
        end;
       end;
       if xyswapped then begin
        pos.y:= x;
       end
       else begin
        pos.x:= x;
       end;
      end;
     end;
     int3:= acount - int2 + astart - 1;
     drawstring(@text.text[int2+1],int3,pos,nil,grayed,rot);
     for int2:= int2 to int2 + int3 - 1 do begin
      inc(x,charwidths[int2]);
     end;
    end;
    if not grayed then begin
     if fs_underline in canvas.font.style then begin
      if xyswapped then begin
       drawfontline(makepoint(pos.x+underline,xbefore),
                makepoint(pos.x+underline,x-1));
      end
      else begin
       drawfontline(makepoint(xbefore,pos.y+underline),
                makepoint(x-1,pos.y+underline));
      end;
     end;
     if fs_strikeout in font.style then begin
      if xyswapped then begin
       drawfontline(makepoint(pos.x+layoutinfo.strikeout,xbefore),
                 makepoint(pos.x+layoutinfo.strikeout,x-1));
      end
      else begin
       drawfontline(makepoint(xbefore,pos.y+layoutinfo.strikeout),
                 makepoint(x-1,pos.y+layoutinfo.strikeout));
      end;
     end;
    end;
    if layoutinfo.xyswapped then begin
     pos.y:= x;
    end
    else begin
     pos.x:= x;
    end;
   end;
  end;
 end;

 procedure adjustellipsepos(delta: integer);
 begin
  if tf_right in info.flags then begin
   pos.x:= pos.x - delta;
  end
  else begin
   if tf_xcentered in info.flags then begin
    pos.x:= pos.x - delta div 2;
   end;
  end;
 end;

 procedure updatefont(const aformat: formatinfoty);
 begin
  with aformat,info,canvas do begin
   if newinfos * fontstylemask <> [] then begin
    afontstyle:= afontstyle * fontstylesty(
       not {$ifdef FPC}longword({$else}byte(word{$endif}(newinfos))) +
                                                           style.fontstyle;
    font.style:= afontstyle + overridefontstyle;
   end;
   if (ni_selected in newinfos) and not (tf_noselect in flags)then begin
    if tf_underlineselect in flags then begin
     if not (fs_underline in style.fontstyle) then begin
      if fs_selected in style.fontstyle then begin
       font.style:= font.style + [fs_underline];
      end
      else begin
       font.style:= font.style - [fs_underline];
      end;
     end;
    end
    else begin
     if (fs_selected in style.fontstyle) then begin
      if font.colorselect = cl_default then begin
       font.color:= cl_selectedtext;
      end
      else begin
       font.color:= font.colorselect;
      end;
      if font.colorselectbackground = cl_default then begin
       font.colorbackground:= cl_selectedtextbackground;
      end
      else begin
       font.colorbackground:= font.colorselectbackground;
      end;
     end
     else begin
      if style.fontcolor = 0 then begin
       font.color:= defaultcolor;
      end
      else begin
       font.color:= not style.fontcolor;
      end;
      if style.colorbackground = 0 then begin
       font.colorbackground:= defaultcolorbackground;
      end
      else begin
       font.colorbackground:= not style.colorbackground;
      end;
     end;
    end;
   end;
   if not (fs_selected in style.fontstyle) or
                                  (tf_underlineselect in flags) then begin
    if ni_fontcolor in newinfos then begin
     if style.fontcolor = 0 then begin
      font.color:= defaultcolor;
     end
     else begin
      font.color:= not style.fontcolor;
     end;
    end;
    if ni_colorbackground in newinfos then begin
     if style.colorbackground = 0 then begin
      font.colorbackground:= defaultcolorbackground;
     end
     else begin
      font.colorbackground:= not style.colorbackground;
     end;
    end;
   end;
  end;
 end;

var
 row: integer;
 ellipsewidth: integer;
 int1,int3{,int4}: integer;
 lastover: boolean;
 textbackup: msestring;
 formatbackup: formatinfoarty;

 endlab :boolean = false;

begin                  //drawtext
 with info,tcanvas1(canvas) do begin
  if tf_rotate90 in flags then begin
   if tf_rotate180 in flags then begin
    rot:= 1.5*pi;
   end
   else begin
    rot:= 0.5*pi;
   end;
  end
  else begin
   if tf_rotate180 in flags then begin
    rot:= pi;
   end
   else begin
    rot:= 0;
   end;
  end;
  if tf_tabtospace in flags then begin
   textbackup:= text.text; //backup
   replacechar1(text.text,msechar(c_tab),msechar(' '));
  end;
  if flags * ellipsemask <> [] then begin
   formatbackup:= text.format;
   text.format:= nil;          //no format handling with ellipse
  end;
  try
   if cs_internaldrawtext in fstate then begin
    internaldrawtext(info);
    exit;
   end;
   save;
   if tf_clipi in flags then begin
    intersectcliprect(dest);
   end;
   if tf_clipo in flags then begin
    intersectcliprect(clip);
   end;
   if text.text = '' then begin
    info.res:= nullrect;
    endlab := true;
   end;
   if endlab = false then
   begin
   layouttext(canvas,info,layoutinfo);
   defaultcolor:= font.color;
   defaultcolorbackground:= font.colorbackground;
   fontstylebefore:= font.style;
   afontstyle:= fontstylebefore;
   overridefontstyle:= afontstyle * [fs_bold,fs_italic,fs_underline];
   grayed:= tf_grayed in flags;
   if info.text.format <> nil then begin
    infoindexbefore:= -1;
    int1:= 0; //format index
    row:= 0; //layoutinfo row index
    lastover:= false;
    while row <= high(layoutinfo.lineinfos) do begin
     with layoutinfo.lineinfos[row] do begin
      if layoutinfo.xyswapped then begin
       pos.x:= liy;
       pos.y:= listartx;
      end
      else begin
       pos.y:= liy;
       pos.x:= listartx;
      end;
      charindexbefore:= liindex-1;
      endindex:= charindexbefore + licount;
     end;
     while true do begin
      with text.format[int1] do begin
       formatactive:= (index < endindex);
       last:= (int1 >= high(text.format)) or not formatactive;
       if last or (newinfos * stopmask <> []) then begin
        if infoindexbefore >= 0 then begin
         updatefont(text.format[infoindexbefore]);
        end;
        if formatactive and not lastover then begin
         count:= text.format[int1].index - charindexbefore;
         if count > 0 then begin
          drawsubstring(row,charindexbefore+1,count);
          inc(charindexbefore,count);
         end;
         infoindexbefore:= int1;
         if last then begin
          updatefont(text.format[int1]);
          count:= endindex - charindexbefore;
          drawsubstring(row,charindexbefore+1,count);
          inc(charindexbefore,count);
          lastover:= true;
          break;
         end;
        end
        else begin
         drawsubstring(row,charindexbefore+1,endindex - charindexbefore);
         break;
        end;
       end;
      end;
      inc(int1);
     end;
     inc(row);
    end;
    font.color:= defaultcolor;
    font.colorbackground:= defaultcolorbackground;
    font.style:= fontstylebefore;
   end
   else begin
    for row:= 0 to high(layoutinfo.lineinfos) do begin
     with layoutinfo.lineinfos[row] do begin
      if layoutinfo.xyswapped then begin
       pos.x:= liy;
       pos.y:= listartx;
      end
      else begin
       pos.y:= liy;
       pos.x:= listartx;
      end;
      if (liwidth > dest.cx) and (flags * ellipsemask <> []) then begin
       ellipsewidth:= getstringwidth(textellipse);
       ellipsewidthsum:= liwidth + ellipsewidth;
       int1:= liindex;
       if tf_ellipseleft in flags then begin
        int3:= liindex + licount;
        while int1 < int3 do begin
         dec(ellipsewidthsum,layoutinfo.charwidths[int1-1]);
         inc(int1);
         if ellipsewidthsum <= dest.cx then begin
          break;
         end;
        end;
        adjustellipsepos(ellipsewidthsum -liwidth);
        drawstring(textellipse,pos,nil,tf_grayed in flags);
        inc(pos.x,ellipsewidth);
        dec(licount,int1-liindex);
        liindex:= int1;
        drawsubstring(row,liindex,licount);
       end
       else begin
        if tf_ellipseright in flags then begin
         int1:= int1 + licount;
         while int1 > liindex do begin
          dec(int1);
          dec(ellipsewidthsum,layoutinfo.charwidths[int1-1]);
          if ellipsewidthsum <= dest.cx then begin
           break;
          end;
         end;
        end;
        licount:= int1 - liindex;
        adjustellipsepos(ellipsewidthsum -liwidth);
        drawsubstring(row,liindex,licount);
        drawstring(textellipse,pos,nil,tf_grayed in flags);
       end;
      end
      else begin
       drawsubstring(row,liindex,licount);
      end;
      inc(pos.y,layoutinfo.lineheight);
     end;
    end;
   end;
   end;
 // if endlab then
  restore;
  finally
   if tf_tabtospace in flags then begin
    text.text:= textbackup;
   end;
   if flags * ellipsemask <> [] then begin
    text.format:= formatbackup;
   end;
  end;
 end;
end;

procedure drawtext(const canvas: tcanvas; const text: richstringty;
                        const dest: rectty; flags: textflagsty = [];
                        font: tfont = nil; tabulators: tcustomtabulators = nil);
var
 info: drawtextinfoty;
begin
 info.text:= text;
 info.dest:= dest;
 info.flags:= flags - [tf_clipo];
 info.font:= font;
 info.tabulators:= tabulators;
 drawtext(canvas,info);
end;

procedure drawtext(const canvas: tcanvas; const text: richstringty;
                        const dest,clip: rectty; flags: textflagsty = [];
                        font: tfont = nil; tabulators: tcustomtabulators = nil);
var
 info: drawtextinfoty;
begin
// info.canvas:= canvas;
 info.text:= text;
 info.dest:= dest;
 info.clip:= clip;
 info.flags:= flags;
 info.font:= font;
 info.tabulators:= tabulators;
 drawtext(canvas,info);
end;

procedure drawtext(const canvas: tcanvas; const text: msestring;
                        const dest,clip: rectty; flags: textflagsty = [];
                        font: tfont = nil; tabulators: tcustomtabulators = nil);
var
 info: drawtextinfoty;
begin
// info.canvas:= canvas;
 info.text.format:= nil;
 info.text.text:= text;
 info.dest:= dest;
 info.clip:= clip;
 info.flags:= flags;
 info.font:= font;
 info.tabulators:= tabulators;
 drawtext(canvas,info);
end;

procedure drawtext(const canvas: tcanvas; const text: msestring;
                        const dest: rectty; flags: textflagsty = [];
                        font: tfont = nil; tabulators: tcustomtabulators = nil);
var
 ristr1: richstringty;
begin
 ristr1.text:= text;
 ristr1.format:= nil;
 drawtext(canvas,ristr1,dest,flags,font,tabulators);
end;

procedure textrect(const canvas: tcanvas; var info: drawtextinfoty);
var
 layoutinfo: layoutinfoty;
begin
 layouttext(canvas,info,layoutinfo);
end;

function textclipped(const canvas: tcanvas; var info: drawtextinfoty): boolean;
begin
 textrect(canvas,info);
 result:= not rectinrect(info.res,info.dest);
end;

function textrect(const canvas: tcanvas; const text: richstringty;
                   const dest: rectty; flags: textflagsty = [];
                   font: tfont = nil; tabulators: tcustomtabulators = nil): rectty;
var
 info: drawtextinfoty;
begin
 info.text:= text;
 info.dest:= dest;
// info.clip:= dest;
 info.flags:= flags - [tf_clipo];
 info.font:= font;
 info.tabulators:= tabulators;
 textrect(canvas,info);
 result:= info.res;
end;

function textrect(const canvas: tcanvas; const text: richstringty;
                   flags: textflagsty = []; font: tfont = nil;
                   tabulators: tcustomtabulators = nil): rectty; overload;
begin
 flags:= flags - [tf_right,tf_bottom,tf_xcentered,tf_ycentered];
 result:= textrect(canvas,text,makerect(0,0,bigint,bigint),flags,font,tabulators);
end;

function textrect(const canvas: tcanvas; const text: msestring;
                   const dest: rectty; flags: textflagsty = [];
                   font: tfont = nil; tabulators: tcustomtabulators = nil): rectty;
var
 str1: richstringty;
begin
 str1.text:= text;
 result:= textrect(canvas,str1,dest,flags,font,tabulators);
end;

function textrect(const canvas: tcanvas; const text: msestring;
                   flags: textflagsty = []; font: tfont = nil;
                   tabulators: tcustomtabulators = nil): rectty;
var
 str1: richstringty;
begin
 str1.text:= text;
 result:= textrect(canvas,str1,flags,font,tabulators);
end;

{ ttabulatoritem }

procedure ttabulatoritem.setkind(const avalue: tabulatorkindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  tcustomtabulators(fowner).changed(self);
 end;
end;

procedure ttabulatoritem.setpos(const avalue: real);
begin
 if fpos <> avalue then begin
  fpos:= avalue;
  tcustomtabulators(fowner).changed(self);
 end;
end;

procedure ttabulatoritem.setdistleft(const avalue: real);
begin
 if fdistleft <> avalue then begin
  fdistleft:= avalue;
  tcustomtabulators(fowner).changed(self);
 end;
end;

procedure ttabulatoritem.setdistright(const avalue: real);
begin
 if fdistright <> avalue then begin
  fdistright:= avalue;
  tcustomtabulators(fowner).changed(self);
 end;
end;

function ttabulatoritem.getenabled(): boolean;
begin
 result:= true;
end;

{ tcustomtabulators }

constructor tcustomtabulators.create;
begin
 fppmm:= defaultppmm;
 inherited create(self,getitemclass);
end;

class function tcustomtabulators.getitemclasstype: persistentclassty;
begin
 result:= getitemclass;
end;

procedure tcustomtabulators.assign(source: tpersistent);
var
 int1: integer;
begin
 if source is tcustomtabulators then begin
  beginupdate;
  with tcustomtabulators(source) do begin
   self.count:= count;
   for int1:= 0 to high(fitems) do begin
    ttabulatoritem(self.fitems[int1]).fkind:= ttabulatoritem(fitems[int1]).fkind;
    ttabulatoritem(self.fitems[int1]).fpos:= ttabulatoritem(fitems[int1]).fpos;
   end;
   self.fdefaultdist:= fdefaultdist;
  end;
  endupdate;
 end
 else begin
  inherited;
 end;
end;

class function tcustomtabulators.getitemclass: tabulatoritemclassty;
begin
 result:= ttabulatoritem;
end;

procedure tcustomtabulators.changed(const sender: ttabulatoritem);
begin
 dochange(-1);
end;

procedure tcustomtabulators.dochange(const index: integer);
begin
 fuptodate:= false;
 inherited;
end;

procedure tcustomtabulators.add(const apos: real; const akind: tabulatorkindty);
begin
 beginupdate;
  count:= count + 1;
  with ttabulatoritem(fitems[high(fitems)]) do begin
   fpos:= apos;
   fkind:= akind;
  end;
 endupdate;
end;

procedure tcustomtabulators.setdefaulttabs(const awidth: real;
  const acount: integer; const akind: tabulatorkindty);
var
 int1: integer;
begin
 beginupdate;
 count:= acount;
 for int1:= 0 to high(fitems) do begin
  with ttabulatoritem(fitems[int1]) do begin
   fpos:= (int1+1)*awidth;
   fkind:= akind;
  end;
 end;
 endupdate;
end;

procedure tcustomtabulators.setppmm(const avalue: real);
begin
 if fppmm <> avalue then begin
  fppmm:= avalue;
  changed(nil);
 end;
end;

function cmptab(const l,r): integer;
begin
 result:= tabulatorty(l).linepos - tabulatorty(r).linepos;
end;

procedure tcustomtabulators.checkuptodate;
var
 int1: integer;
 prevtab,nexttab: int32;
begin
 if not fuptodate then begin
  setlength(ftabs,count);
  for int1:= 0 to high(ftabs) do begin
   with ftabs[int1] do begin
    index:= int1;
    with ttabulatoritem(fitems[int1]) do begin
     tabkind:= fkind;
     linepos:= round(fpos*fppmm);
     case kind of
      tak_left: begin
       textpos:= round((fpos + fdistleft)*fppmm);
      end;
      tak_right{,tak_decimal}: begin
       textpos:= round((fpos - fdistright)*fppmm);
      end;
      else begin //tak_center
//       textpos:= round((fpos + (fdistleft - fdistright))*fppmm);
       textpos:= linepos;
      end;
     end;
    end;
   end;
  end;
  sortarray(ftabs,sizeof(ftabs[0]),{$ifdef FPC}@{$endif}cmptab);
  for int1:= 0 to high(ftabs) do begin
   with ftabs[int1],ttabulatoritem(fitems[index]) do begin
    prevtab:= int1-1;
    while (prevtab >= 0) and
           not ttabulatoritem(fitems[ftabs[prevtab].index]).getenabled do begin
     dec(prevtab);
    end;
    nexttab:= int1+2;
    while (nexttab <= high(fitems)) and
           not ttabulatoritem(fitems[ftabs[nexttab].index]).getenabled do begin
     inc(nexttab);
    end;
    if nexttab <= high(ftabs) then begin
     cellwidth:= ftabs[nexttab].linepos - linepos;
    end
    else begin
     cellwidth:= 0;
    end;
    case tabkind of
     tak_right,tak_decimal: begin
      width:= -round(fdistleft*fppmm);
      if prevtab >= 0 then begin
       width:= textpos - ftabs[prevtab].linepos + width;
      end
      else begin
       width:= textpos + width;
      end;
     end;
     tak_centered: begin
      width:= -round((fdistright+fdistleft)*fppmm);
      if (prevtab >= 0) and (nexttab <= high(ftabs)) then begin
       width:= ftabs[nexttab].linepos - ftabs[prevtab].linepos + width;
      end
      else begin
       width:= 2 * linepos + width;
      end;
     end;
     else begin //tak_left
      width:= -round((fdistright)*fppmm);
      if nexttab <= high(ftabs) then begin
       width:= ftabs[nexttab].linepos - textpos + width
      end;
     end;
    end;
   end;
  end;
  fuptodate:= true;
 end;
end;

function tcustomtabulators.gettabs: tabulatorarty;
begin
 checkuptodate;
 result:= ftabs;
end;

function tcustomtabulators.getitems(const index: integer): ttabulatoritem;
begin
 result:= ttabulatoritem(inherited getitems(index));
end;

procedure tcustomtabulators.setitems(const index: integer; const avalue: ttabulatoritem);
begin
 getitems(index).assign(avalue);
end;

procedure tcustomtabulators.setdefaultdist(const avalue: real);
begin
 fdefaultdist:= avalue;
 if fdefaultdist < 0 then begin
  fdefaultdist:= 0;
 end;
 dochange(-1);
end;

function tcustomtabulators.getpos(const index: integer): integer;
var
 int1: integer;
begin
 checkuptodate;
 if index <= high(ftabs) then begin
  result:= ftabs[index].textpos;
 end
 else begin
  if length(ftabs) > 0 then begin
   if fdefaultdist > 0 then begin
    int1:= trunc(ftabs[high(ftabs)].linepos/fdefaultdist);
   end
   else begin
    result:= ftabs[high(ftabs)].textpos;
    exit;
   end;
  end
  else begin
   int1:= 0;
  end;
  result:= round((int1 + index - high(ftabs)) * fdefaultdist);
 end;
end;

function tcustomtabulators.getlinepos(const index: integer): integer;
var
 int1: integer;
begin
 checkuptodate;
 if index <= high(ftabs) then begin
  result:= ftabs[index].linepos;
 end
 else begin
  if length(ftabs) > 0 then begin
   if fdefaultdist > 0 then begin
    int1:= trunc(ftabs[high(ftabs)].linepos/fdefaultdist);
   end
   else begin
    result:= ftabs[high(ftabs)].linepos;
    exit;
   end;
  end
  else begin
   int1:= 0;
  end;
  result:= round((int1 + index - high(ftabs)) * fdefaultdist);
 end;
end;

procedure tcustomtabulators.setlinepos(const index: integer;
               const avalue: integer);
begin
 checkuptodate;
 checkindex(index);
 ttabulatoritem(fitems[ftabs[index].index]).pos:= avalue / ppmm;
end;

end.
