{ MSEgui Copyright (c) 2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit dumpunitgroups;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
procedure dumpunitgr;
implementation
uses
 msedesigner,msedesignintf,typinfo,mseclasses,pascaldesignparser,msearrayutils,
 sourceupdate,msestrings,msearrayprops,msetypes,msedatalist,msedesignparser;

procedure dumpunitgr;
const
 systypes: array[0..9] of string = ('Boolean','Integer','AnsiString',
          'Pointer','LongInt','LongWord','Variant','Int64','QWord','Currency');
type
 unitnamety = record
  name: string;
  uppername: string;
 end;
 unitnamearty = array of unitnamety;
 unitgroupty = record
  group: unitnamety;
  units: unitnamearty;
 end;
 punitgroupty = ^unitgroupty;
 unitgrouparty = array of unitgroupty;
var
 groupar: unitgrouparty;

 function findgroup(const unitname: string): punitgroupty;
 var
  str1: string;
  int1,int2: integer;
 begin
  str1:= struppercase(unitname);
  int2:= length(groupar);
  for int1:= 0 to int2 - 1 do begin
   if str1 = groupar[int1].group.uppername then begin
    int2:= int1;
    break;
   end;
  end;
  if int2 > high(groupar) then begin
   setlength(groupar,int2+1);
   with groupar[int2] do begin
    group.name:= unitname;
    group.uppername:= struppercase(unitname);
   end;
  end;
  result:= @groupar[int2];
 end;

 procedure adddependency(const agroup: punitgroupty; const unitname: string);
 var
  str1: string;
  int1,int2: integer;
 begin
  str1:= struppercase(unitname);
  if str1 <> 'SYSTEM' then begin
   with agroup^do begin
    if str1 <> group.uppername then begin
     int2:= length(units);
     for int1:= 0 to int2 - 1 do begin
      if units[int1].uppername = str1 then begin
       int2:= int1;
       break;
      end;
     end;
     if int2> high(units) then begin
      setlength(units,int2+1);
      with units[int2] do begin
       name:= unitname;
       uppername:= str1;
      end;
     end;
    end;
   end;
  end;
 end;

var
 classn: string;
 parsedclasses: classarty;
 po6: punitgroupty;

 function isnotparsed(const aclass: tclass): boolean;
 var
  int1: integer;
 begin
  for int1:= 0 to high(parsedclasses) do begin
   if parsedclasses[int1] = aclass then begin
    result:= false;
    exit;
   end;
  end;
  additem(pointerarty(parsedclasses),aclass);
  result:= true;
 end;

 procedure dumpclass(po2: ptypeinfo);
 var
  po4: punitinfoty;
  ar1: propinfopoarty;
  int2,int3,int4: integer;
  bo1: boolean;
  defunitna,propna,typena,unitn: string;
  po5: pdefinfoty;
  methinfo: methodparaminfoty;
  po3: ptypeinfo;
  class1: tclass;
 begin
  if po2 = nil then begin
   exit;
  end;
  unitn:= gettypedata(po2)^.unitname;
  po4:= sourceupdater.updateunitinterface(unitn);
  if po4 <> nil then begin
   ar1:= getpropinfoar(po2);
   for int2:= 0 to high(ar1) do begin
    po2:= ar1[int2]^.proptype;
    if po2^.kind = tkmethod then begin
     getmethodparaminfo(po2,methinfo);
     propna:= ar1[int2]^.name;
 //       writeln(' ',propna);
     for int3:= 0 to high(methinfo.params) do begin
      typena:= methinfo.params[int3].typename;
      bo1:= false;
      for int4:= 0 to high(systypes) do begin
       bo1:= typena = systypes[int4];
       if bo1 then begin
        break;
       end;
      end;
      if not bo1 then begin
       po5:= sourceupdater.finddef(po4,typena);
       if po5 <> nil then begin
        defunitna:= po5^.owner.rootlist.unitinfopo^.origunitname;
        adddependency(po6,defunitna);
 //         writeln('  ',typena,' ',defunitna);
       end
       else begin
        if typena = 'Exception' then begin
         adddependency(po6,'sysutils');
        end
        else begin
         writeln(unitn,'.',classn,'.',propna,' "',typena+'" def unit not found.');
        end;
       end;
      end;
     end;
    end
    else begin
     if po2^.kind = tkclass then begin
      class1:= gettypedata(po2)^.classtype;
      if class1 = nil then begin
       writeln(unitn,'.',classn,'.',propna,
                            ' "',typena+' '+po2^.name+'" typedata nil.');
      end
      else begin
       if isnotparsed(class1) then begin
        po3:= class1.classinfo;
        dumpclass(po3);
        if class1.inheritsfrom(tpersistentarrayprop) then begin
         class1:= persistentarraypropclassty(class1).getitemclasstype;
         if class1 = nil then begin
          writeln(unitn,'.',classn,'.',propna,
                               ' "',typena+' '+po3^.name+'" itemclasstype nil.');
         end
         else begin
          po3:= class1.classinfo;
          dumpclass(po3);
         end;
        end;
       end;
      end;
     end;
    end;
   end;
  end
  else begin
   writeln('"'+unitn+'"'+'for '+'"'+classn+'" not found.');
  end;
 end; //dumpclass

var
 int1,int2: integer;
 po1: pcomponentclassinfoty;
 po2: ptypeinfo;
// po3: ptypedata;

begin
 parsedclasses:= nil;
 with registeredcomponents do begin
  if count > 0 then begin
   po1:= itempo(0);
   for int1:= 0 to count - 1 do begin
    classn:= po1^.classtyp.classname;
//    writeln(classn);
    po2:= po1^.classtyp.classinfo;
    if isnotparsed(po1^.classtyp) then begin
     po6:= findgroup(gettypedata(po2)^.unitname);
     dumpclass(po2);
    end;
    inc(po1);
   end;
  end;
 end;
 writeln;
 for int1:= 0 to high(groupar) do begin
  with groupar[int1] do begin
   if high(units) >= 0 then begin
    write(' registerunitgroup(['''+group.name+'''],[');
    for int2:= 0 to high(units) do begin
     write(''''+units[int2].name+'''');
     if int2 = high(units) then begin
      write(']);');
     end
     else begin
      write(',');
     end;
    end;
    writeln;
   end;
  end;
 end;
end;

end.
