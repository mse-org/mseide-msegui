{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefbutils;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mdb,msqldb,msestrings;
 
procedure fbupdateindexdefs(const sender: tcustomsqlconnection;
                            var indexdefs : tindexdefs;
                               const atablename : string);
implementation
uses
 msesqlresult,dbconst,sysutils;
 
procedure fbupdateindexdefs(const sender: tcustomsqlconnection;
                            var indexdefs : tindexdefs;
                               const atablename : string);
var 
 res: tsqlresult;
 str1: ansistring;
begin
 with sender do begin
  if not assigned(Transaction) then begin
   DatabaseError(SErrConnTransactionnSet);
  end;
  res:= tsqlresult.Create(nil);
  try
   with res do begin
    database:= sender;
    sql.text:= 'select '+
               'ind.rdb$index_name, '+
               'ind.rdb$relation_name, '+
               'ind.rdb$unique_flag, '+
               'ind_seg.rdb$field_name, '+
               'rel_con.rdb$constraint_type '+
             'from '+
               'rdb$index_segments ind_seg, '+
               'rdb$indices ind '+
              'left outer join '+
               'rdb$relation_constraints rel_con '+
              'on '+
               'rel_con.rdb$index_name = ind.rdb$index_name '+
             'where '+
               '(ind_seg.rdb$index_name = ind.rdb$index_name) and '+
               '(ind.rdb$relation_name=''' +  
                         msestring(uppercase(atablename)) +''') '+
             'order by '+
               'ind.rdb$index_name;';
    active:= true;
    while not eof do begin
     with indexdefs.AddIndexDef do begin
      str1:= cols[0].asstring;
      name:= trim(str1);
      fields:= trim(res.cols[3].asstring);
      if cols[4].asstring = 'PRIMARY KEY' then begin
       options:= options + [ixPrimary];
      end;
      if cols[2].asinteger = 1 then begin
       options:= options + [ixUnique];
      end;
      next;
      while  not eof and (str1 = cols[0].asstring) do begin
       fields:= fields + ';' + trim(cols[3].asstring);
       next;
      end;
     end;
    end;
   end;
  finally
   res.free;
  end;
 end;
end;

end.
