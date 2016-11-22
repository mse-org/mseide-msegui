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
function fbgetschemainfosql(const sender: tcustomsqlconnection;
                schematype: tschematype;
                schemaobjectname,schemapattern: msestring): msestring;

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

function fbgetschemainfosql(const sender: tcustomsqlconnection;
                schematype: tschematype;
                schemaobjectname,schemapattern: msestring): msestring;
var 
 s : msestring;

begin
 with sender do begin
  s:= '';
  case SchemaType of
    stTables     : s := 'select '+
                          'rdb$relation_id          as recno, '+
                          '''' + msestring(DatabaseName) +
                           ''' as catalog_name, '+
                          '''''                     as schema_name, '+
                          'rdb$relation_name        as table_name, '+
                          '0                        as table_type '+
                        'from '+
                          'rdb$relations '+
                        'where '+
                          '(rdb$system_flag = 0 or rdb$system_flag is null) ' + // and rdb$view_blr is null
                        'order by rdb$relation_name';

    stSysTables  : s := 'select '+
                          'rdb$relation_id          as recno, '+
                          '''' + msestring(DatabaseName) + 
                          ''' as catalog_name, '+
                          '''''                     as schema_name, '+
                          'rdb$relation_name        as table_name, '+
                          '0                        as table_type '+
                        'from '+
                          'rdb$relations '+
                        'where '+
                          '(rdb$system_flag > 0) ' + // and rdb$view_blr is null
                        'order by rdb$relation_name';

    stProcedures : s := 'select '+
                           'rdb$procedure_id        as recno, '+
                          '''' + msestring(DatabaseName) +
                          ''' as catalog_name, '+
                          '''''                     as schema_name, '+
                          'rdb$procedure_name       as proc_name, '+
                          '0                        as proc_type, '+
                          'rdb$procedure_inputs     as in_params, '+
                          'rdb$procedure_outputs    as out_params '+
                        'from '+
                          'rdb$procedures '+
                        'WHERE '+
                          '(rdb$system_flag = 0 or rdb$system_flag is null)';
    stColumns    : s := 'select '+
                           'rdb$field_id            as recno, '+
                          '''' + msestring(DatabaseName) +
                          ''' as catalog_name, '+
                          '''''                     as schema_name, '+
                          'rdb$relation_name        as table_name, '+
                          'rdb$field_name           as column_name, '+
                          'rdb$field_position       as column_position, '+
                          '0                        as column_type, '+
                          '0                        as column_datatype, '+
                          '''''                     as column_typename, '+
                          '0                        as column_subtype, '+
                          '0                        as column_precision, '+
                          '0                        as column_scale, '+
                          '0                        as column_length, '+
                          '0                        as column_nullable '+
                        'from '+
                          'rdb$relation_fields '+
                        'WHERE '+
                        '(rdb$system_flag = 0 or rdb$system_flag is null) and'+
      ' (rdb$relation_name = ''' + Uppercase(SchemaObjectName) + ''') ' +
                        'order by rdb$field_name';
  else
    DatabaseError(SMetadataUnavailable)
  end; {case}
  result := s;
 end;
end;

end.
