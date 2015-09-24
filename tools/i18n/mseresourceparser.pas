{ MSEtools Copyright (c) 1999-2013 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit mseresourceparser;
{$ifdef FPC}
 {$mode objfpc}{$h+}
{$endif}

interface
uses
 classes,mclasses,msetypes,mselist,msedatanodes,mselistbrowser,mseparser,
 msestrings,msestream,mseclasses;

type

 propinfoty = record
  name: string;
  stringvalue: string;
  msestringvalue: msestring;
  donottranslate: boolean;
  comment: msestring;
  variants: msestringarty;
  case valuetype: tvaluetype of
   vastring,valstring,vautf8string,vawstring:
    (coffset: integer; clen: integer); //filemarker for const units
   vaInt8,vaint16,vaint32: (integervalue: integer);
   vaint64: (int64value: int64);
   vasingle,vacurrency,vaextended,vadate: (realvalue: real);
   vafalse,vatrue: (booleanvalue: boolean);
 end;

 tpropinfonode = class;
 tpropinfoitem = class;

 tpropinfonode = class(ttreeeditnode)
  private
   alang: integer;
  protected
   function getitems(const index: integer): tpropinfonode;
   procedure setitems(const index: integer; const Value: tpropinfonode);
   function treenodeclass: treenodeclassty; override;
   function listitemclass: treelistitemclassty; override;
   procedure nodetoitem(const listitem: ttreelistitem); override;
   procedure dotransferlang(const sender: ttreenode);
   procedure dodeletelang(const sender: ttreenode);
   procedure doinitlang(const sender: ttreenode);
  public
   info: propinfoty;
   procedure clear; override;
   function newnode: tpropinfonode;
   function rootstring(separator: char = '.'; withrootnode: boolean = false): string;
   function valuetext: msestring;
   procedure transferlang(lang: integer);
   procedure deletelang(lang: integer);
   procedure initlang(acount: integer);
   function findsubnode(const nametree: string): tpropinfonode;
   property items[const index: integer]: tpropinfonode read getitems write setitems; default;
 end;

 tpropinfoitem = class(ttreelistedititem)
  public
   node: tpropinfonode;
 end;

const
 identmaxlen = 30;
 identbucketcount = 256;
type
 identstringty = string[identmaxlen+1]; //terminated with #0
 identinfoty = record
  name: identstringty;
  ident: integer;
 end;
 pidentinfoty = ^identinfoty;
 identinfoarty = array of identinfoty;

procedure readprops(const stream: tstream; const node: tpropinfonode);
procedure writeprops(const stream: tstream; const node: tpropinfonode);
procedure writeconsts(const instream,outstream: tstream;
                  const node: tpropinfonode);
procedure writeresources(const instream,outstream: tstream;
                  const node: tpropinfonode);
procedure writefpcresourcestrings(const outstream: ttextstream;
                  const node: tpropinfonode);

implementation
uses
 sysutils,mseformatstr,msearrayutils,typinfo,msebits,msewidgets,msejson,
 msefileutils,msesys;

type
 treader1 = class(treader);
 twriter1 = class(twriter);
 {$ifdef FPC}
 tbinaryobjectwriter1 = class(tbinaryobjectwriter);
 {$endif}

{ tpropinfonode }

function tpropinfonode.getitems(const index: integer): tpropinfonode;
begin
 result:= tpropinfonode(inherited getitems(index));
end;

procedure tpropinfonode.setitems(const index: integer;
  const Value: tpropinfonode);
begin
 inherited setitems(index,value);
end;

function tpropinfonode.listitemclass: treelistitemclassty;
begin
 result:= tpropinfoitem;
end;

function tpropinfonode.treenodeclass: treenodeclassty;
begin
 result:= tpropinfonode;
end;

function tpropinfonode.newnode: tpropinfonode;
begin
 result:= tpropinfonode.Create;
 add(result);
end;

function tpropinfonode.valuetext: msestring;
begin
 case info.valuetype of
  vaint8,vaint16,vaint32: begin
   result:= inttostrmse(info.integervalue);
  end;
  vaint64: begin
   result:= inttostrmse(info.int64value);
  end;
  vaSingle,vaCurrency,vaDate,vaExtended: begin
   result:= realtostrmse(info.realvalue);
  end;
//  vaset,vaident,vastring,valstring: begin
  vaset,vaident: begin
   result:= msestring(info.stringvalue);
  end;
  vastring,valstring,vawstring,vautf8string: begin
   result:= info.msestringvalue;
  end;
  else begin
   result:= '';
  end;
 end;
end;

function tpropinfonode.rootstring(separator: char = '.'; withrootnode: boolean = false): string;
begin
 if (fparent <> nil) or withrootnode then begin
  result:= info.name;
  if fparent <> nil then begin
   if (tpropinfonode(fparent).fparent <> nil) or withrootnode then begin
    result:= tpropinfonode(fparent).rootstring(separator) + separator + result;
   end;
  end;
 end
 else begin
  result:= '';
 end;
end;

function tpropinfonode.findsubnode(const nametree: string): tpropinfonode;
var
 ar1: stringarty;
 anode,anode1: tpropinfonode;
 int1,int2: integer;
begin
 ar1:= nil;
 splitstring(nametree,ar1,',');
 if (high(ar1) >= 0) and (info.name = ar1[0]) then begin
  anode:= self;
  anode1:= self;
  for int1:= 1 to high(ar1) do begin
   anode1:= nil;
   for int2:= 0 to anode.fcount - 1 do begin
    anode1:= tpropinfonode(anode.fitems[int2]);
    if anode1.info.name = ar1[int1] then begin
     break;
    end
    else begin
     anode1:= nil;
    end;
   end;
   if anode1 = nil then begin
    break;
   end
   else begin
    anode:= anode1;
   end;
  end;
  result:= anode1;
 end
 else begin
  result:= nil;
 end;
end;

procedure tpropinfonode.nodetoitem(const listitem: ttreelistitem);
begin
 with tpropinfoitem(listitem) do begin
  fcaption:= msestring(self.info.name);
  node:= self;
 end;
end;
{
procedure tpropinfonode.itemtonode(const listitem: ttreelistitem);
begin
 with tpropinfoitem(listitem) do begin
  self.info:= info;
 end;
end;
}
procedure tpropinfonode.clear;
begin
 inherited;
 finalize(info);
 fillchar(info,sizeof(info),0);
end;

procedure readprops(const stream: tstream; const node: tpropinfonode);

var
 reader: treader;

 procedure readobj(const node: tpropinfonode);
  procedure readpropdat(const node: tpropinfonode);
   procedure readpropval(const node: tpropinfonode);
   var
    str1,str2: string;
    int1,int2: integer;
    aitem: tpropinfonode;
   begin
    with treader1(reader) do begin
     with node.info do begin
      valuetype:= nextvalue;
      case valuetype of
       vaNull,vanil: begin
        readvalue;{ no value field, just an identifier }
       end;
       vaFalse, vaTrue: begin
        readvalue;{ no value field, just an identifier }
        booleanvalue:= valuetype = vatrue;
       end;
       vaBinary: begin
        readvalue;
        {$ifdef FPC}
        stringvalue:= driver.readstring(valstring);
        {$else}
        Read(int1, SizeOf(int1));
        setlength(stringvalue,int1);
        read(pchar(pointer(stringvalue))^,int1);
        {$endif}
       end;
       vaList: begin
        readvalue;
        int1:= 0;
        while not endoflist do begin
         aitem:= node.newnode;
         aitem.info.name:= inttostr(int1)+':';
         readpropval(aitem);
         inc(int1);
        end;
        readlistend;
       end;
       vaInt8,vaint16,vaint32: begin
        integervalue:= readinteger;
       end;
       vaInt64: begin
        int64value:= readint64;
       end;
       vaSingle: begin
        realvalue:= readsingle;
       end;
       vaCurrency: begin
        realvalue:= readcurrency;
       end;
       vaDate: begin
        realvalue:= readdate;
       end;
       vaExtended: begin
        realvalue:= readfloat;
       end;
       vaIdent: begin
        readvalue;
        stringvalue:= {$ifdef FPC}driver.{$endif}readstr;
       end;
       vastring,valstring,vaWString,vautf8string: begin
        msestringvalue:= treader_readmsestring(reader);
       end;
       vaSet: begin
        readvalue;
        str1:= '';
        while true do begin
         str2:= {$ifdef FPC}driver.{$endif}readstr;
         if str2 = '' then begin
          break;
         end;
         str1:= str1 + str2 + ',';
        end;
        stringvalue:= '['+copy(str1,1,length(str1)-1)+']';
       end;
       vaCollection: begin
        readvalue;
        int2:= 0;
        while not EndOfList do begin
         aitem:= node.newnode;
         aitem.info.valuetype:= valist;
         if NextValue in [vaInt8, vaInt16, vaInt32] then begin
          int1:= readinteger;
          aitem.info.name:= inttostr(int1);
         end
         else begin
          if NextValue in [vaident] then begin
           aitem.info.name:= readident;
          end
          else begin
           aitem.info.name:= inttostr(int2)+':';
          end;
         end;
         readlistbegin;
         while not endoflist do begin
          readpropdat(aitem.newnode);
         end;
         readlistend;
         inc(int2);
        end;
        ReadListEnd;
       end;
      end;
     end;
    end;
   end;

  begin //writepropdat
   with treader1(reader) do begin
    {$ifdef FPC}
    node.info.name:= driver.beginproperty;
    {$else}
    node.info.name:= readstr;
    {$endif}
    readpropval(node);
   end;
  end;

 var
  compclass,compname: string;
  flags: tfilerflags;
  pos: integer;

 begin //writeobj
  with treader1(reader) do begin
  {$ifdef FPC}
   driver.begincomponent(flags,pos,compclass,compname);
   {$else}
   pos:= 0;
   ReadPrefix(flags,pos);
   compclass := ReadStr;
   compname := ReadStr;
   {$endif}
   node.info.name:= compname;
   node.info.stringvalue:= compclass;
   node.info.integervalue:= (pos shl 3) or {$ifdef FPC}longword{$else}byte{$endif}(flags) and $07;
   while not endoflist do begin
    readpropdat(node.newnode);
   end;
   ReadListEnd;
   while not EndOfList do begin;
    readobj(node.newnode);
   end;
   ReadListEnd;
  end;
 end;

begin //readprops
 reader:= treader.Create(stream,4096);
 try
  with treader1(reader) do begin
  {$ifdef FPC}
   driver.beginrootcomponent;
  {$else}
   readsignature;
   {$endif}
   readobj(node);
  end;
 finally
  reader.Free;
 end;
end;

procedure writeprops(const stream: tstream; const node: tpropinfonode);

var
 writer: twritermse;

 procedure writeobj(const node: tpropinfonode);
  procedure writepropdat(const node: tpropinfonode);
   procedure writepropval(const node: tpropinfonode);
   type
    setinfoty = record
     kind: ttypekind;
     namelen: byte;
     data: ttypedata;
    end;
   var
    int1,int2: integer;
    ar1: stringarty;
    str1: string;
    {$ifdef FPC}
//    setinfo: setinfoty;
//    po1:  ^setinfoty;
//    po2: ^shortstring;
//    lwo1: longword;
    {$endif}
   begin
   {$ifdef FPC}{$warnings off}{$endif}
    with twriter1(writer) do begin
   {$ifdef FPC}{$warnings on}{$endif}
     with node.info do begin
      case valuetype of
       vaNull: begin
        writeident('Null');
       end;
       vaNil: begin
        writeident('nil');
       end;
       vaFalse: begin
        writeident('False');
       end;
       vaTrue: begin
        writeident('True');
       end;
       vaBinary: begin
       {$ifdef FPC}
        driver.writebinary(stringvalue[1],length(stringvalue));
       {$else}
        writevalue(vabinary);
        int1:= length(stringvalue);
        write(int1, sizeof(int1));
        if int1 <> 0 then begin
         write(stringvalue[1],int1);
        end;
       {$endif}
       end;
       vaList: begin
        writelistbegin;
        for int1:= 0 to node.fcount - 1 do begin
         writepropval(node[int1]);
        end;
        writelistend;
       end;
       vaInt8,vaint16,vaint32: begin
        writeinteger(integervalue);
       end;
       vaInt64: begin
        writeinteger(int64value);
       end;
       vaSingle: begin
        writesingle(realvalue);
       end;
       vaCurrency: begin
        writecurrency(realvalue);
       end;
       vaDate: begin
        writedate(realvalue);
       end;
       vaExtended: begin
        writefloat(realvalue);
       end;
       vaIdent: begin
        writeident(stringvalue);
       end;
       vaString,vaLString,vaWString,vautf8string: begin
        twriter_writemsestring(writer,msestringvalue);
       end;
       vaSet: begin
        ar1:= nil;
        str1:= trim(stringvalue);
        str1:= copy(stringvalue,2,length(str1)-2);
        splitstring(str1,ar1,',',true);
        {$ifdef FPC}
        with tbinaryobjectwriter1(driver) do begin
         writevalue(vaset);
         for int1:= 0 to high(ar1) do begin
          writestr(ar1[int1]);
         end;
         writestr('');
        end;
        {$else}
        writevalue(vaset);
        for int1:= 0 to high(ar1) do begin
         writestr(ar1[int1]);
        end;
        writestr('');
        {$endif}
       end;
       vaCollection: begin
        {$ifdef FPC}
        driver.begincollection;
        {$else}
        writevalue(vacollection);
        {$endif}
        for int1:= 0 to node.fcount - 1 do begin
         with node[int1] do begin
          if (info.name <> '') then begin
           if info.name[1] in ['0'..'9'] then begin
            if (info.name[length(info.name)] <> ':') then begin
             writeinteger(strtoint(info.name));
            end;
           end
           else begin
            writeident(info.name);
           end;
          end;
         end;
         writelistbegin;
         for int2:= 0 to node[int1].fcount-1 do begin
          writepropdat(node[int1][int2]);
         end;
         writelistend;
        end;
        writeListEnd;
       end;
      end;
     end;
    end;
   end;

  begin //writepropdat
   {$ifdef FPC}{$warnings off}{$endif}
   with twriter1(writer) do begin
   {$ifdef FPC}{$warnings on}{$endif}
    {$ifdef FPC}
    driver.beginproperty(node.info.name);
    {$else}
    writestr(node.info.name);
    {$endif}
    writepropval(node);
   end;
  end;

 var
  compclass,compname: string;
  flags: tfilerflags;
  pos: integer;
  int1: integer;
  {$ifdef FPC}
  Prefix: Byte;
  {$endif}
 begin //writeobj
   {$ifdef FPC}{$warnings off}{$endif}
  with twriter1(writer) do begin
   {$ifdef FPC}{$warnings on}{$endif}
   compname:= node.info.name;
   compclass:= node.info.stringvalue;
   flags:= tfilerflags({$ifdef FPC}longword{$else}byte{$endif}(node.info.integervalue and $07));
   pos:= node.info.integervalue shr 3;
  {$ifdef FPC}
   with tbinaryobjectwriter1(driver) do begin
    if not FSignatureWritten then begin
     Write(FilerSignature, SizeOf(FilerSignature));
     FSignatureWritten := True;
    end;
    { Only write the flags if they are needed! }
    if Flags <> [] then begin
     Prefix := Integer(Flags) or $f0;
     Write(Prefix, 1);
     if ffChildPos in Flags then begin
      WriteInteger(pos);
     end;
    end;
    writestr(compclass);
    writestr(compname);
   end;
  {$else}
   writeprefix(flags,pos);
   writestr(compclass);
   writestr(compname);
  {$endif}
   int1:= 0;
   while int1 < node.fcount do begin
    with node[int1] do begin
     if info.valuetype = vanull then begin
      break;
     end;
    end;
    writepropdat(node[int1]);
    inc(int1);
   end;
   writelistend;
   while int1 < node.fcount do begin
    writeobj(node[int1]);
    inc(int1);
   end;
   writeListEnd;
  end;
 end;

begin //writeprops
 writer:= twritermse.Create(stream,4096);
 try
   {$ifdef FPC}{$warnings off}{$endif}
  with twriter1(writer) do begin
   {$ifdef FPC}{$warnings on}{$endif}
  {$ifdef FPC}
//   driver.beginrootcomponent; //signature written by begincomponent
  {$else}
   writesignature;
   {$endif}
   writeobj(node);
  end;
 finally
  writer.Free;
 end;
end;

procedure writeconsts(const instream,outstream: tstream;
                 const node: tpropinfonode);
var
 int1: integer;
 str1: string;
begin
 for int1:= 0 to node.fcount - 1 do begin
  with tpropinfonode(node.fitems[int1]).info do begin
   case valuetype of
//    vaString,vaLString:  begin
//     str1:= stringtopascalstring(stringvalue);
//    end;
    vastring,valstring,vaWString,vautf8string: begin
     str1:= stringtopascalstring(msestringvalue);
    end;
    else begin
     str1:= '';
    end;
   end;
   if str1 <> '' then begin
    if coffset <> instream.Position then begin
     outstream.CopyFrom(instream,coffset-instream.position);
    end;
    instream.Position:= coffset + clen;
    outstream.WriteBuffer(str1[1],length(str1));
   end;
  end;
 end;
 outstream.CopyFrom(instream,instream.Size-instream.position);
end;

function comppos(const l,r): integer;
begin
 result:= tpropinfonode(l).info.coffset - tpropinfonode(r).info.coffset;
end;

procedure writeresources(const instream,outstream: tstream;
                  const node: tpropinfonode);
var
 int1,int2,int3: integer;
 ar1: pointerarty;
 str1: string;
begin
 int2:= 0;
 for int1:= 0 to node.fcount - 1 do begin
  inc(int2,tpropinfonode(node.fitems[int1]).fcount);
 end;
 setlength(ar1,int2);
 int2:= 0;
 for int1:= 0 to node.fcount - 1 do begin
  int3:= tpropinfonode(node.fitems[int1]).fcount;
  if int3 > 0 then begin
   move(tpropinfonode(node.fitems[int1]).fitems[0],ar1[int2],int3 * sizeof(pointer));
   inc(int2,int3);
  end;
 end;
 sortarray(ar1,{$ifdef FPC}@{$endif}comppos);
 for int1:= 0 to high(ar1) do begin
  with tpropinfonode(ar1[int1]).info do begin
   case valuetype of
//    vaString,vaLString:  begin
//     str1:= stringtocstring(stringvalue);
//    end;
    vastring,valstring,vaWString,vautf8string: begin
     str1:= stringtocstring(msestringvalue);
    end;
    else begin
     str1:= '';
    end;
   end;
   if str1 <> '' then begin
    if coffset <> instream.Position then begin
     outstream.CopyFrom(instream,coffset-instream.position);
    end;
    instream.Position:= coffset + clen;
    outstream.WriteBuffer(str1[1],length(str1));
   end;
  end;
 end;
 outstream.CopyFrom(instream,instream.Size-instream.position);
end;

procedure getjsonresourcestrings(var json: jsonvaluety; 
                                               const node: tpropinfonode);
var
 node1,node2: tpropinfonode;
 mstr1: msestring;
 int1: int32;
begin
 for int1:= 0 to node.count - 1 do begin
  node1:= node[int1];
  with node1.info do begin
   if valuetype = vawstring then begin
    node2:= tpropinfonode(node1.fparent);
    mstr1:= msestring(name);
    repeat
     mstr1:= msestring(node2.info.name) + '.' + mstr1;
     node2:= tpropinfonode(node2.fparent);
    until (node2.fparent = nil) or (node2.parent.parent = nil);
    jsonadditems(jsonaddvalues(json,[nil])^,
          ['hash','name','value'],
                         [hash(stringtoutf8ansi(msestringvalue)),mstr1,
                                                               msestringvalue]);
   end
   else begin
    getjsonresourcestrings(json,node1);
   end;
  end;
 end;
end;

procedure writefpcresourcestrings(const outstream: ttextstream;
                  const node: tpropinfonode);
var
 int1: integer;
 node1,node2: tpropinfonode;
 str1,str2: string;
 mstr1: msestring;
 po1: pmsechar;
 i1: int32;
 json: jsonvaluety;
 pj: pjsonvaluety;
begin
 if fileext(outstream.filename) = 'rsj' then begin
  jsonvalueinit(json);
  try
   pj:= jsonadditems(json,['version','strings'],[1,nil]);
   getjsonresourcestrings(pj^,node);
   syserror(jsonencode(json,outstream));
  finally
   jsonvaluefree(json);
  end;
 end
 else begin
  for int1:= 0 to node.count - 1 do begin
   node1:= node[int1];
   with node1.info do begin
    if valuetype = vawstring then begin
     node2:= tpropinfonode(node1.fparent);
     str1:= name;
     repeat
      str1:= node2.info.name + '.' + str1;
      node2:= tpropinfonode(node2.fparent);
     until (node2.fparent = nil) or (node2.parent.parent = nil);
     outstream.writeln('');
     outstream.writeln('# hash value = '+
                      inttostr(hash(ansistring(msestringvalue))));
     str2:= ansistring(msestringvalue);
     setlength(mstr1,length(str2));
     po1:= pmsechar(mstr1);
     for i1:= 1 to length(mstr1) do begin
      po1^:= msechar(byte(str2[i1])); //use locale encoding
      inc(po1);
     end;
     outstream.writeln(str1+'='+stringtopascalstring(mstr1));
    end
    else begin
     writefpcresourcestrings(outstream,node1);
    end;
   end;
  end;
 end;
end;

procedure tpropinfonode.dotransferlang(const sender: ttreenode);

 procedure doerror(mess: string);
 begin
  showmessage(msestring(mess));
 end;

begin
 with tpropinfonode(sender).info do begin
  if not donottranslate and (alang <= high(variants)) then begin
   case valuetype of
//    vaString,vaLString: begin
//     stringvalue:= variants[alang];
//    end;
    vastring,valstring,vaWString,vautf8string: begin
     msestringvalue:= variants[alang];
    end;
    vaint8,vaint16,vaint32: begin
     if variants[alang] <> '' then begin
      try
       integervalue:= strtoint(variants[alang]);
      except
       doerror('Invalid integer');
      end;
     end;
    end;
    vaint64: begin
//     result:= inttostr(info.int64value);
    end;
    vaSingle,vaCurrency,vaDate,vaExtended: begin
//     result:= floattostr(info.realvalue);
    end;
   end;
  end;
 end;
end;

procedure tpropinfonode.transferlang(lang: integer);
begin
 alang:= lang;
 iterate({$ifdef FPC}@{$endif}dotransferlang);
end;

procedure tpropinfonode.dodeletelang(const sender: ttreenode);
begin
 with tpropinfonode(sender).info do begin
  if high(variants) >= alang then begin
   deleteitem(variants,alang);
  end;
 end;
end;

procedure tpropinfonode.deletelang(lang: integer);
begin
 alang:= lang;
 iterate({$ifdef FPC}@{$endif}dodeletelang);
end;

procedure tpropinfonode.doinitlang(const sender: ttreenode);
var
 int1: integer;
begin
 with tpropinfonode(sender).info do begin
  case valuetype of
//   vaString,vaLString: begin
//    setlength(variants,alang);
//    for int1:= 0 to alang - 1 do begin
//     variants[int1]:= stringvalue;
//    end;
//   end;
   vastring,valstring,vaWString,vautf8string: begin
    setlength(variants,alang);
    for int1:= 0 to alang - 1 do begin
     variants[int1]:= msestringvalue;
    end;
   end;
  end;
 end;
end;

procedure tpropinfonode.initlang(acount: integer);
begin
 alang:= acount;
 iterate({$ifdef FPC}@{$endif}doinitlang);
end;


end.
