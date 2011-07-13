{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mserttistat;

{$ifdef FPC}
 {$mode objfpc}{$h+}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}

interface
uses
 classes,mseclasses,msestat,msestatfile,msestrings,typinfo,msetypes,
 msehash;
 
type
 objectinfoty = record
  obj: tobject;
  prefix: string;
 end;
 objectinfoarty = array of objectinfoty;
 
 getobjecteventty = procedure(const sender: tobject;
                                   var aobject: tobject) of object;
 getobjectseventty = procedure(const sender: tobject;
                                   var aobjects: objectinfoarty) of object;

 tcustomrttistat = class(tmsecomponent,istatfile)
  private
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fongetobject: getobjecteventty;
   fongetobjects: getobjectseventty;
   fonstatupdate: statupdateeventty;
   fonstatread: statreadeventty;
   fonstatwrite: statwriteeventty;
   fonstatbeforeread: notifyeventty;
   fonstatafterread: notifyeventty;
  {$ifdef mse_with_ifi}   
   ftargets: tpointeransistringhashdatalist;
  {$endif}
   procedure setstatfile(const avalue: tstatfile);
  protected
    //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   function getobj(out aobj: objectinfoarty): boolean;
  {$ifdef mse_with_ifi}
   function findtarget(const aname: string): tobject;
   procedure scantargets(const aroot: tcomponent);
  {$endif}
  public
   procedure readstat(const areader: tstatreader);
   procedure writestat(const awriter: tstatwriter);
  {$ifdef mse_with_ifi}
   procedure valuestoobj(const sourceroot: tcomponent);
     //reads values from components with matching property-component names
     //or statvarnames
   procedure objtovalues(const destroot: tcomponent);
     //writes values to components with matching property-component names
     //or statvarnames
  {$endif}   
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read fstatvarname write fstatvarname;
   property ongetobject: getobjecteventty read fongetobject write fongetobject;
   property ongetobjects: getobjectseventty read fongetobjects 
                                                        write fongetobjects;
   property onstatupdate: statupdateeventty read fonstatupdate 
                                                        write fonstatupdate;
   property onstatread: statreadeventty read fonstatread 
                                                        write fonstatread;
   property onstatwrite: statwriteeventty read fonstatwrite 
                                                        write fonstatwrite;
   property onstatbeforeread: notifyeventty read fonstatbeforeread
                                                        write fonstatbeforeread;
   property onstatafterread: notifyeventty read fonstatafterread 
                                                        write fonstatafterread;   
 end;

 trttistat = class(tcustomrttistat)
  protected
  published
   property statfile;
   property statvarname;
   property ongetobject;
   property ongetobjects;
   property onstatupdate;
   property onstatread;
   property onstatwrite;
   property onstatbeforeread;
   property onstatafterread;   
 end;

function opentodynarray(const objs: array of tobject;
                     const prefixes: array of string): objectinfoarty;
function getmsestringar(const aobj: tobject;
                           const aprop: ppropinfo): msestringarty;
procedure setmsestringar(const aobj: tobject; const aprop: ppropinfo;
                                                 const avalue: msestringarty);
procedure addobjectinfoitem(var dest: objectinfoarty; const aobj: tobject;
                                            const aprefix: string = '');
                     
implementation
uses
 {$ifdef mse_with_ifi}mseificompglob,{$endif}msedatalist,sysutils;

type
 dynarraysetter = procedure(const avalue: pointerarty) of object;
                                     //dummy type
 dynarraygetter = function: pointerarty of object;
                                     //dummy type

procedure addobjectinfoitem(var dest: objectinfoarty; const aobj: tobject;
                                            const aprefix: string = '');
begin
 setlength(dest,high(dest)+2);
 with dest[high(dest)] do begin
  obj:= aobj;
  prefix:= aprefix;
 end;
end;

function opentodynarray(const objs: array of tobject;
                     const prefixes: array of string): objectinfoarty;
var
 int1: integer;
begin
 setlength(result,length(objs));
 for int1:= 0 to high(result) do begin
  with result[int1] do begin
   obj:= objs[int1];
   if int1 <= high(prefixes) then begin
    prefix:= prefixes[int1];
   end;
  end;
 end;
end;
{$ifndef FPC}
const
 ptmask = $FF000000;
 ptfield = $FF000000;
 ptvirtual = $FE000000;
{$endif}

function getdynarray(const aobj: tobject; const aprop: ppropinfo): pointer;
var
 getterkind: integer;
 meth1: tmethod;
begin
{$ifdef FPC}
 getterkind:= (aprop^.propprocs) and 3;
{$else}
 getterkind:= ptruint(aprop^.getproc) and ptmask;
{$endif}
 case getterkind of
  ptfield: begin
  {$ifdef FPC}
   result:= ppointer(pointer(aobj) + ptruint(aprop^.getproc))^;
  {$else}
   result:= ppointer(pchar(aobj) + (ptruint(aprop^.getproc) and not ptmask))^;
  {$endif}
   exit;
  end;
  ptvirtual: begin
  {$ifdef FPC}
   meth1.code:= ppointer(pointer(aobj.classtype) +
                                 ptruint(aprop^.getproc))^;
  {$else}
   meth1.code:= ppointer(pchar(aobj) + smallint(ptrint(aprop^.getproc)))^;
  {$endif}
  end;
 {$ifdef FPC}
  ptstatic: begin
 {$else}
  else begin
 {$endif}
   meth1.code:= aprop^.getproc;
  end;
 {$ifdef FPC}
  else begin
   result:= nil;
   exit;
  end;
 {$endif}
 end;
 meth1.data:= aobj;
 result:= pointer(dynarraygetter(meth1)());
end;

function setdynarray(const aobj: tobject; const aprop: ppropinfo;
             const avalue: pointer): pointer;
                   // returns valuebefore for finalize
var
 setterkind: integer;
 meth1: tmethod;
begin
{$ifdef FPC}
 setterkind:= (aprop^.propprocs shr 2) and 3;
{$else}
 setterkind:= ptruint(aprop^.setproc) and ptmask;
{$endif}
 result:= nil;
 case setterkind of
  ptfield: begin
   arrayaddref((@avalue)^);
   result:= getdynarray(aobj,aprop);
  {$ifdef FPC}
   ppointer(pointer(aobj) + ptruint(aprop^.setproc))^:= avalue;
  {$else}
   ppointer(pchar(aobj) + (ptruint(aprop^.setproc) and not ptmask))^:= avalue;
  {$endif}
   exit;
  end;
  ptvirtual: begin
   {$ifdef FPC}
   meth1.code:= ppointer(pointer(aobj.classtype) +
                                 ptruint(aprop^.setproc))^;
   {$else}
   meth1.code:= ppointer(pchar(aobj) + smallint(ptrint(aprop^.setproc)))^;
   {$endif}
  end;
 {$ifdef FPC}
  ptstatic: begin
 {$else}
  else begin
 {$endif}
   meth1.code:= aprop^.setproc;
  end;
 {$ifdef FPC}
  else begin
   result:= nil;
   exit;
  end;
 {$endif}
 end;
 meth1.data:= aobj;
 dynarraysetter(meth1)(avalue);
end;

function getintegerar(const aobj: tobject; const aprop: ppropinfo): integerarty;
begin
 result:= integerarty(getdynarray(aobj,aprop));
end;

procedure setintegerar(const aobj: tobject; const aprop: ppropinfo;
                                                  const avalue: integerarty);
var
 ar1: integerarty;
begin
 pointer(ar1):= setdynarray(aobj,aprop,pointer(avalue));
 ar1:= nil; //finalize
end;

function getint64ar(const aobj: tobject; const aprop: ppropinfo): int64arty;
begin
 result:= int64arty(getdynarray(aobj,aprop));
end;

procedure setint64ar(const aobj: tobject; const aprop: ppropinfo;
                                                  const avalue: int64arty);
var
 ar1: int64arty;
begin
 pointer(ar1):= setdynarray(aobj,aprop,pointer(avalue));
 ar1:= nil; //finalize
end;

function getrealar(const aobj: tobject; const aprop: ppropinfo): realarty;
begin
 result:= realarty(getdynarray(aobj,aprop));
end;

procedure setrealar(const aobj: tobject; const aprop: ppropinfo;
                                                 const avalue: realarty);
var
 ar1: realarty;
begin
 pointer(ar1):= setdynarray(aobj,aprop,pointer(avalue));
 ar1:= nil; //finalize
end;

function getmsestringar(const aobj: tobject;
                           const aprop: ppropinfo): msestringarty;
begin
 result:= msestringarty(getdynarray(aobj,aprop));
end;

function getwidestringar(const aobj: tobject;
                           const aprop: ppropinfo): widestringarty;
begin
 result:= widestringarty(getdynarray(aobj,aprop));
end;

procedure setmsestringar(const aobj: tobject; const aprop: ppropinfo;
                                                 const avalue: msestringarty);
var
 ar1: msestringarty;
begin
 pointer(ar1):= setdynarray(aobj,aprop,pointer(avalue));
 ar1:= nil; //finalize
end;

procedure setwidestringar(const aobj: tobject; const aprop: ppropinfo;
                                                 const avalue: widestringarty);
var
 ar1: widestringarty;
begin
 pointer(ar1):= setdynarray(aobj,aprop,pointer(avalue));
 ar1:= nil; //finalize
end;

function getstringar(const aobj: tobject;
                           const aprop: ppropinfo): stringarty;
begin
 result:= stringarty(getdynarray(aobj,aprop));
end;

procedure setstringar(const aobj: tobject; const aprop: ppropinfo;
                                                 const avalue: stringarty);
var
 ar1: stringarty;
begin
 pointer(ar1):= setdynarray(aobj,aprop,pointer(avalue));
 ar1:= nil; //finalize
end;

function getbooleanar(const aobj: tobject;
                           const aprop: ppropinfo): booleanarty;
begin
 result:= booleanarty(getdynarray(aobj,aprop));
end;

procedure setbooleanar(const aobj: tobject; const aprop: ppropinfo;
                                                 const avalue: booleanarty);
var
 ar1: booleanarty;
begin
 pointer(ar1):= setdynarray(aobj,aprop,pointer(avalue));
 ar1:= nil; //finalize
end;

procedure readobjectstat(const reader: tstatreader; const aobj: objectinfoty);
var
 ar1: propinfopoarty; 
 po1: ppropinfo;
 po2: ptypeinfo;
 po3: ptypedata;
 int1: integer;
 obj1: tobject;
 info1: objectinfoty;
// intf1: istatfile;
// intar: integerarty;
// realar: realarty;
 str1: string;
begin
 with aobj do begin
  ar1:= getpropinfoar(obj);
  for int1 := 0 to high(ar1) do begin
   po1:= ar1[int1];
   with po1^ do begin
    str1:= prefix+name;
    case proptype^.kind of
     tkInteger,tkChar,tkEnumeration,tkWChar,tkSet: begin
      setordprop(obj,po1,reader.readinteger(str1,getordprop(obj,po1)));
     end;
     tkint64: begin
      setint64prop(obj,po1,reader.readint64(str1,getint64prop(obj,po1)));
     end;
     tkfloat: begin
      setfloatprop(obj,po1,reader.readreal(str1,getfloatprop(obj,po1)));
     end;
    {$ifdef FPC}
     tkbool: begin
      setordprop(obj,po1,
         ord(longbool(reader.readboolean(str1,getordprop(obj,po1) <> 0))));
     end;
    {$endif}
     tkwstring: begin
      setwidestrprop(obj,po1,reader.readmsestring(
                                          str1,getwidestrprop(obj,po1)));
     end;
    {$ifdef FPC}
     tkustring: begin
      setunicodestrprop(obj,po1,reader.readmsestring(
                                          str1,getunicodestrprop(obj,po1)));
     end;
    {$endif}
     {$ifdef FPC}tkastring,{$endif}tklstring,tkstring: begin
      setstrprop(obj,po1,reader.readstring(str1,getstrprop(obj,po1)));
     end;
      //how to reach fpc_DecRef?
     tkdynarray: begin
      {$ifdef FPC}
      po2:= pointer(gettypedata(proptype)^.eltype2);
                          //wrong define in ttypedata
      {$else}
      po2:= gettypedata(proptype^)^.eltype2^;
      {$endif}
      po3:= gettypedata(po2);
      case po2^.kind of
       tkinteger: begin
        setintegerar(obj,po1,reader.readarray(str1,getintegerar(obj,po1)));
       end;
       tkint64: begin
        setint64ar(obj,po1,reader.readarray(str1,getint64ar(obj,po1)));
       end;
       tkfloat: begin
        if po3^.floattype = ftdouble then begin
         setrealar(obj,po1,reader.readarray(str1,getrealar(obj,po1)));
        end;
       end;
       tkwstring: begin
        setwidestringar(obj,po1,reader.readarray(str1,getwidestringar(obj,po1)));
       end;
       {$ifdef FPC}tkastring{$else}tklstring{$endif}: begin
        setstringar(obj,po1,reader.readarray(str1,getstringar(obj,po1)));
       end;
      {$ifdef FPC}
       tkustring: begin
        setmsestringar(obj,po1,reader.readarray(str1,getmsestringar(obj,po1)));
       end;
      {$endif}
       {$ifdef FPC}tkbool{$else}tkenumeration{$endif}: begin
        setbooleanar(obj,po1,reader.readarray(str1,getbooleanar(obj,po1)));
       end;
      end;
     end;
     tkclass: begin
      obj1:= tobject(ptruint(getordprop(obj,po1)));
      if obj1 is tdatalist then begin
       reader.readdatalist(str1,tdatalist(obj1));
      end
      else begin
       info1.obj:= obj1;
       info1.prefix:= aobj.prefix;
       readobjectstat(reader,info1);
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure writeobjectstat(const writer: tstatwriter; const aobj: objectinfoty);
var
 ar1: propinfopoarty;
// ar2: array of istatfile;
 po1: ppropinfo;
 po2: ptypeinfo;
 po3: ptypedata;
 int1: integer;
 obj1: tobject;
// intf1: istatfile;
 str1: string;
 info1: objectinfoty;
begin
 with aobj do begin
  ar1:= getpropinfoar(obj);
  for int1 := 0 to high(ar1) do begin
   po1:= ar1[int1];
   with po1^ do begin
    str1:= prefix+name;
    case proptype^.kind of
     tkInteger,tkChar,tkEnumeration,tkWChar,tkSet: begin
      writer.writeinteger(str1,getordprop(obj,po1));
     end;
     tkint64: begin
      writer.writeint64(str1,getint64prop(obj,po1));
     end;
     tkfloat: begin
      writer.writereal(str1,getfloatprop(obj,po1));
     end;
    {$ifdef FPC}
     tkbool: begin
      writer.writeboolean(str1,getordprop(obj,po1) <> 0);
     end;
     tkustring: begin
      writer.writemsestring(str1,getunicodestrprop(obj,po1));
     end;
    {$endif}
     tkwstring: begin
      writer.writemsestring(str1,getwidestrprop(obj,po1));
     end;
     {$ifdef FPC}tkastring,{$endif}tklstring,tkstring: begin
      writer.writestring(str1,getstrprop(obj,po1));
     end;
     tkdynarray: begin
     {$ifdef FPC}
      po2:= pointer(gettypedata(proptype)^.eltype2);
                          //wrong define in ttypedata
     {$else}
      po2:= gettypedata(proptype^)^.eltype2^;
     {$endif}
      po3:= gettypedata(po2);
      case po2^.kind of
       tkinteger: begin
        writer.writearray(str1,getintegerar(obj,po1));
       end;
       tkint64: begin
        writer.writearray(str1,getint64ar(obj,po1));
       end;
       tkfloat: begin
        if po3^.floattype = ftdouble then begin
         writer.writearray(str1,getrealar(obj,po1));
        end;
       end;
      {$ifdef FPC}tkastring{$else}tklstring{$endif}: begin
        writer.writearray(str1,getstringar(obj,po1));
       end;
      {$ifdef FPC}
       tkustring: begin
        writer.writearray(str1,getmsestringar(obj,po1));
       end;
      {$endif}
       {$ifdef FPC}tkbool{$else}tkenumeration{$endif}: begin
        writer.writearray(str1,getbooleanar(obj,po1));
       end;
      end;
     end;
     tkclass: begin
      obj1:= tobject(ptruint(getordprop(obj,po1)));
      if obj1 is tdatalist then begin
       writer.writedatalist(str1,tdatalist(obj1));
      end
      else begin
       info1.obj:= obj1;
       info1.prefix:= aobj.prefix;
       writeobjectstat(writer,info1);
      end;
     end;
    end;
   end;
  end;
 end;
end;

{$ifdef mse_with_ifi}
type
 findtargetty = function(const aname: string): tobject of object;

procedure valuestoobject(const dest: objectinfoty;
                                        const findtarget: findtargetty);
var
 comp1: tobject;
 ar1: propinfopoarty; 
 po1,po4: ppropinfo;
 po2: ptypeinfo;
// po3: ptypedata;
 int1: integer;
 intf1: iifidatalink;
 obj1: tobject;
 info1: objectinfoty;
 bo1: boolean;
 list1: tdatalist;
// arpo: pointer;
begin
 ar1:= getpropinfoar(dest.obj);
 for int1 := 0 to high(ar1) do begin
  po1:= ar1[int1];
  with po1^ do begin
   bo1:= true;
   if po1^.proptype^.kind = tkclass then begin
    obj1:= tobject(ptruint(getordprop(dest.obj,po1)));
    if not (obj1 is tdatalist) then begin
     bo1:= false;
     info1.obj:= obj1;
     info1.prefix:= dest.prefix;
     valuestoobject(info1,findtarget);
    end;
   end;
   if bo1 then begin
    comp1:= findtarget(dest.prefix+name);
    if (comp1 <> nil) and 
      mseclasses.getcorbainterface(comp1,typeinfo(iifidatalink),
                                                       intf1)  then begin
     po4:= intf1.getvalueprop;
     if po4 <> nil then begin
      case proptype^.kind of
       tkInteger,tkChar,tkEnumeration,tkWChar,tkSet: begin
        if po4^.proptype^.kind in 
              [tkInteger,tkChar,tkEnumeration,tkWChar,tkSet] then begin
         setordprop(dest.obj,po1,getordprop(comp1,po4));
        end;
       end;
       tkint64: begin
        if po4^.proptype^.kind in
              [tkint64] then begin
         setint64prop(dest.obj,po1,getint64prop(comp1,po4));
        end;
       end;
       tkfloat: begin
        if po4^.proptype^.kind in 
              [tkfloat] then begin
         setfloatprop(dest.obj,po1,getfloatprop(comp1,po4));
        end;
       end;
      {$ifdef FPC}
       tkbool: begin
        if po4^.proptype^.kind in
              [tkbool] then begin
         setordprop(dest.obj,po1,getordprop(comp1,po4));
        end;
       end;
       tkustring: begin
        if po4^.proptype^.kind in [tkustring] then begin
         setunicodestrprop(dest.obj,po1,getunicodestrprop(comp1,po4));
        end;
       end;
      {$endif}
       tkwstring: begin
       {$ifdef FPC}
        if po4^.proptype^.kind = tkustring then begin
         setwidestrprop(dest.obj,po1,getunicodestrprop(comp1,po4));
        end;
       {$else}
        if po4^.proptype^.kind = tkwstring then begin
         setwidestrprop(dest.obj,po1,getwidestrprop(comp1,po4));
        end;
       {$endif}
       end;
       {$ifdef FPC}tkastring,{$endif}tklstring,tkstring: begin
       {$ifdef FPC}
        if po4^.proptype^.kind = tkustring then begin
         setstrprop(dest.obj,po1,getunicodestrprop(comp1,po4));
        end;
       {$else}
        if po4^.proptype^.kind = tkwstring then begin
         setstrprop(dest.obj,po1,getwidestrprop(comp1,po4));
        end;
       {$endif}
       end;
       tkclass: begin
//        obj1:= tobject(ptruint(getordprop(dest.obj,po1)));
//        if (obj1 is tdatalist) then begin
         list1:= intf1.getgriddata;
         if list1 <> nil then begin
          tdatalist(obj1).assign(list1);
         end;
//        end;
       end;
       tkdynarray: begin
        list1:= intf1.getgriddata;
        if list1 <> nil then begin
 //        arpo:= pointer(ptruint(getordprop(dest.obj,po1)));
        {$ifdef FPC}
         po2:= pointer(gettypedata(proptype)^.eltype2);
                             //wrong define in ttypedata
        {$else}
         po2:= gettypedata(proptype^)^.eltype2^;
        {$endif}
 //        po3:= gettypedata(po2);
         case po2^.kind of
          tkinteger: begin
           if list1 is tintegerdatalist then begin
            setintegerar(dest.obj,po1,tintegerdatalist(list1).asarray);
           end;
          end;
          tkint64: begin
           if list1 is tint64datalist then begin
            setint64ar(dest.obj,po1,tint64datalist(list1).asarray);
           end;
          end;
          tkfloat: begin
           if list1 is trealdatalist then begin
            setrealar(dest.obj,po1,trealdatalist(list1).asarray);
           end;
          end;
          {$ifdef FPC}tkustring{$else}tkwstring{$endif}: begin
           if list1 is tpoorstringdatalist then begin
            setmsestringar(dest.obj,po1,tpoorstringdatalist(list1).asarray);
           end;
          end;
          {$ifdef FPC}tkastring{$else}tklstring{$endif}: begin
           if list1 is tansistringdatalist then begin
            setstringar(dest.obj,po1,tansistringdatalist(list1).asarray);
           end;
          end;
          {$ifdef FPC}tkbool{$else}tkenumeration{$endif}: begin
           if list1 is tintegerdatalist then begin
            setbooleanar(dest.obj,po1,tintegerdatalist(list1).asbooleanarray);
           end;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure objecttovalues(const source: objectinfoty; 
                                  const findtarget: findtargetty);
var
 comp1: tobject;
 ar1: propinfopoarty; 
 po1,po4: ppropinfo;
 po2: ptypeinfo;
 po3: ptypedata;
 int1: integer;
 intf1: iifidatalink;
 obj1: tobject;
 list1: tdatalist;
 bo1: boolean;
 info1: objectinfoty;
begin
 ar1:= getpropinfoar(source.obj);
 for int1 := 0 to high(ar1) do begin
  po1:= ar1[int1];
  with po1^ do begin
   bo1:= true;
   if po1^.proptype^.kind = tkclass then begin
    obj1:= tobject(ptruint(getordprop(source.obj,po1)));
    if not (obj1 is tdatalist) then begin
     bo1:= false;
     info1.obj:= obj1;
     info1.prefix:= source.prefix;
     objecttovalues(info1,findtarget);
    end;
   end;
   if bo1 then begin
    comp1:= findtarget(source.prefix+name);
    if (comp1 <> nil) and
      mseclasses.getcorbainterface(comp1,typeinfo(iifidatalink),
                                                       intf1)  then begin
     po4:= intf1.getvalueprop;
     if po4 <> nil then begin
      case proptype^.kind of
       tkInteger,tkChar,tkEnumeration,tkWChar,tkSet: begin
        if po4^.proptype^.kind in 
              [tkInteger,tkChar,tkEnumeration,tkWChar,tkSet] then begin
         setordprop(comp1,po4,getordprop(source.obj,po1));
        end;
       end;
       tkint64: begin
        if po4^.proptype^.kind in
              [tkint64] then begin
         setint64prop(comp1,po4,getint64prop(source.obj,po1));
        end;
       end;
       tkfloat: begin
        if po4^.proptype^.kind in
              [tkfloat] then begin
         setfloatprop(comp1,po4,getfloatprop(source.obj,po1));
        end;
       end;
       {$ifdef FPC}
       tkbool: begin
        if po4^.proptype^.kind in
              [tkbool] then begin
         setordprop(comp1,po4,getordprop(source.obj,po1));
        end;
       end;
       tkustring: begin
        if po4^.proptype^.kind in [tkustring] then begin
         setunicodestrprop(comp1,po4,getunicodestrprop(source.obj,po1));
        end;
       end;
       {$endif}
       tkwstring: begin
       {$ifdef FPC}
        if po4^.proptype^.kind = tkustring then begin
         setunicodestrprop(comp1,po4,getwidestrprop(source.obj,po1));
        end;
       {$else}
        if po4^.proptype^.kind = tkwstring then begin
         setwidestrprop(comp1,po4,getwidestrprop(source.obj,po1));
        end;
       {$endif}
       end;
       {$ifdef FPC}tkastring,{$endif}tklstring,tkstring: begin
      {$ifdef FPC}
        if po4^.proptype^.kind = tkustring then begin
         setunicodestrprop(comp1,po4,getstrprop(source.obj,po1));
        end;
       {$else}
        if po4^.proptype^.kind = tkwstring then begin
         setwidestrprop(comp1,po4,getstrprop(source.obj,po1));
        end;
       {$endif}
       end;
       tkdynarray: begin
        list1:= intf1.getgriddata;
        if list1 <> nil then begin
        {$ifdef FPC}
         po2:= pointer(gettypedata(proptype)^.eltype2);
                             //wrong define in ttypedata
        {$else}
         po2:= gettypedata(proptype^)^.eltype2^;
        {$endif}
         po3:= gettypedata(po2);
         case po2^.kind of
          tkinteger: begin
           if list1 is tintegerdatalist then begin
            tintegerdatalist(list1).asarray:= getintegerar(source.obj,po1);
           end;
          end;
          tkint64: begin
           if list1 is tint64datalist then begin
            tint64datalist(list1).asarray:= getint64ar(source.obj,po1);
           end;
          end;
          tkfloat: begin
           if (po3^.floattype = ftdouble) and (list1 is trealdatalist) then begin
            trealdatalist(list1).asarray:=  getrealar(source.obj,po1);
           end;
          end;
          {$ifdef FPC}tkustring{$else}tkwstring{$endif}: begin
           if list1 is tpoorstringdatalist then begin
            tpoorstringdatalist(list1).asarray:= getmsestringar(source.obj,po1);
           end;
          end;
          {$ifdef FPC}tkastring{$else}tklstring{$endif}: begin
           if list1 is tansistringdatalist then begin
            tansistringdatalist(list1).asarray:= getstringar(source.obj,po1);
           end;
          end;
          {$ifdef FPC}tkbool{$else}tkenumeration{$endif}: begin
           if list1 is tintegerdatalist then begin
            tintegerdatalist(list1).asbooleanarray:= getbooleanar(source.obj,po1);
           end;
          end;
         end;
        end;
       end;
       tkclass: begin
//        obj1:= tobject(ptruint(getordprop(source.obj,po1)));
//        if (obj1 is tdatalist) then begin
         list1:= intf1.getgriddata;
         if list1 <> nil then begin
          list1.assign(tdatalist(obj1));
         end;
//        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

{$endif}

{ tcustomrttistat }

procedure tcustomrttistat.statreading;
var
 ar1: objectinfoarty;
 intf1: istatfile;
 int1: integer;
begin
 if assigned(fonstatbeforeread) then begin
  fonstatbeforeread(self);
 end;
 if getobj(ar1) then begin
  for int1:= 0 to high(ar1) do begin
   if mseclasses.getcorbainterface(ar1[int1].obj,typeinfo(istatfile),
                                                          intf1) then begin
    intf1.statreading;
   end;
  end;
 end;
end;

procedure tcustomrttistat.statread;
var
 ar1: objectinfoarty;
 intf1: istatfile;
 int1: integer;
begin
 if assigned(fonstatafterread) then begin
  fonstatafterread(self);
 end;
 if getobj(ar1) then begin
  for int1:= 0 to high(ar1) do begin
   if mseclasses.getcorbainterface(ar1[int1].obj,typeinfo(istatfile),
                                                            intf1) then begin
    intf1.statread;
   end;
  end;
 end;
end;

function tcustomrttistat.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

function tcustomrttistat.getobj(out aobj: objectinfoarty): boolean;
var
 obj1: tobject;
begin
 obj1:= nil;
 aobj:= nil;
 if assigned(fongetobject) then begin
  fongetobject(self,obj1);
 end;
 if assigned(fongetobjects) then begin
  fongetobjects(self,aobj);
 end;
 if obj1 <> nil then begin
  setlength(aobj,high(aobj)+2);
  aobj[high(aobj)].obj:= obj1;
 end;
 result:= aobj <> nil; 
end;

procedure tcustomrttistat.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

procedure tcustomrttistat.dostatread(const reader: tstatreader);
var
 obj1: objectinfoarty;
 intf1: istatfile;
 int1: integer;
begin
 if getobj(obj1) then begin
  for int1:= 0 to high(obj1) do begin
   readobjectstat(reader,obj1[int1]);
   if mseclasses.getcorbainterface(obj1[int1].obj,typeinfo(istatfile),
                                                           intf1) then begin
    intf1.dostatread(reader);
   end;
  end;
 end;
 if assigned(fonstatupdate) then begin
  fonstatupdate(self,reader);
 end;
 if assigned(fonstatread) then begin
  fonstatread(self,reader);
 end;
end;

procedure tcustomrttistat.dostatwrite(const writer: tstatwriter);
var
 obj1: objectinfoarty;
 int1: integer;
 intf1: istatfile;
begin
 if getobj(obj1) then begin
  for int1:= 0 to high(obj1) do begin
   writeobjectstat(writer,obj1[int1]);
   if mseclasses.getcorbainterface(obj1[int1].obj,typeinfo(istatfile),
                                                             intf1) then begin
    intf1.dostatwrite(writer);
   end;
  end;
 end;
 if assigned(fonstatupdate) then begin
  fonstatupdate(self,writer);
 end;
 if assigned(fonstatwrite) then begin
  fonstatwrite(self,writer);
 end;
end;

procedure tcustomrttistat.readstat(const areader: tstatreader);
begin
 dostatread(areader);
end;

procedure tcustomrttistat.writestat(const awriter: tstatwriter);
begin
 dostatwrite(awriter);
end;

{$ifdef mse_with_ifi}

function tcustomrttistat.findtarget(const aname: string): tobject;
begin
 ftargets.find(aname,pointer(result));
end;

procedure tcustomrttistat.scantargets(const aroot: tcomponent);
 procedure addcomps(const acomp: tcomponent; prefix: string);
 var
  intf1: istatfile;
  str1: string;
  int1: integer;
 begin
  if acomp <> aroot then begin
   if prefix <> '' then begin
    prefix:= prefix + '_';
   end;
   prefix:= prefix + acomp.name;
  end;
  for int1:= 0 to acomp.componentcount - 1 do begin
   addcomps(acomp.components[int1],prefix);
  end;
  if (acomp <> aroot) and mseclasses.getcorbainterface(acomp,
                                        typeinfo(istatfile),intf1) then begin
   str1:= intf1.getstatvarname;
   if str1 = '' then begin
    str1:= prefix;
   end;    
   ftargets.add(str1,acomp);
  end;
 end; //addcomps

begin
 ftargets:= tpointeransistringhashdatalist.create;
 addcomps(aroot,'');
end;

procedure tcustomrttistat.valuestoobj(const sourceroot: tcomponent);
var
 obj1: objectinfoarty;
 int1: integer;
begin
 if getobj(obj1) then begin
  scantargets(sourceroot);
  try
   for int1:= 0 to high(obj1) do begin
    valuestoobject(obj1[int1],{$ifdef FPC}@{$endif}findtarget);
   end;
  finally
   freeandnil(ftargets);
  end;
 end;
end;

procedure tcustomrttistat.objtovalues(const destroot: tcomponent);
var
 obj1: objectinfoarty;
 int1: integer;
begin
 if getobj(obj1) then begin
  scantargets(destroot);
  try
   for int1:= 0 to high(obj1) do begin
    objecttovalues(obj1[int1],{$ifdef FPC}@{$endif}findtarget);
   end;
  finally
   freeandnil(ftargets);
  end;
 end;
end;

{$endif}

{ trttistat }

end.
