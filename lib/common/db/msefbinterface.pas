{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
//
// specialised api interfaces
//
unit msefbinterface;
{$ifdef FPC}{$mode delphi}{$h+}{$endif}
interface
uses
 firebird,msetypes,msefbconnection,mdb,msedb;
type

 paraminfoty = record
  _type: card32;
  subtype: int32;
  scale: int32;
  _length: card32;
  offset: card32;
  nulloffset: card32;
  _isnull: boolean;
 end;
 paraminfoarty = array of paraminfoty;
 
 tparamdata = class(imessagemetadataimpl)
  private
   frefcount: int32;
   fparambuffer: pointer;
   fitems: paraminfoarty;
   fcount: int32;
   fmessagelength: int32;
  public
   constructor create(const cursor: tfbcursor; const params: tmseparams);
   destructor destroy(); override;
   procedure addRef() override;
   function release(): Integer override;
   function getCount(status: IStatus): Cardinal override;
   function getField(status: IStatus; index: Cardinal): PAnsiChar override;
   function getRelation(status: IStatus; index: Cardinal): PAnsiChar override;
   function getOwner(status: IStatus; index: Cardinal): PAnsiChar override;
   function getAlias(status: IStatus; index: Cardinal): PAnsiChar override;
   function getType(status: IStatus; index: Cardinal): Cardinal override;
   function isNullable(status: IStatus; index: Cardinal): Boolean override;
   function getSubType(status: IStatus; index: Cardinal): Integer override;
   function getLength(status: IStatus; index: Cardinal): Cardinal override;
   function getScale(status: IStatus; index: Cardinal): Integer override;
   function getCharSet(status: IStatus; index: Cardinal): Cardinal override;
   function getOffset(status: IStatus; index: Cardinal): Cardinal override;
   function getNullOffset(status: IStatus; index: Cardinal): Cardinal override;
   function getBuilder(status: IStatus): IMetadataBuilder override;
   function getMessageLength(status: IStatus): Cardinal override;
   property parambuffer: pointer read fparambuffer;
 end;

implementation
uses
 msefirebird,dbconst,sysutils,msedate;
 
type
 tfbcursor1 = class(tfbcursor);
 tfbconnection1 = class(tfbconnection);
 
{ tparamdata }

constructor tparamdata.create(const cursor: tfbcursor;
                                                  const params: tmseparams);
var
 i1: int32;
 data: stringarty;
 sqltype,sqllen: card32;
 po1: pointer;
 totsize1: int32;
 align1: int32;
 str1,str2: string;
 dt1: tdatetime;
 
begin
 inherited create();
 addref();
 with tfbcursor1(cursor) do begin
  fcount:= length(fparambinding);
  totsize1:= 0;
  if fcount > 0 then begin
   setlength(fitems,fcount);
   setlength(data,fcount); //string buffer
   for i1:= 0 to fcount-1 do begin
    sqltype:= 0;
    sqllen:= 0;
    align1:= 0;
    with params[fparambinding[i1]],fitems[i1] do begin
     _isnull:= isnull;
     scale:= 0;
     case datatype of
      ftunknown: begin
       if isnull then begin
        sqltype:= SQL_NULL;
       end;
      end;
      ftboolean: begin
       sqltype:= SQL_BOOLEAN+1;
       sqllen:= 1;
      end;
      ftinteger,ftsmallint,ftword: begin
       sqltype:= SQL_LONG+1;
       sqllen:= 4;
       align1:= 3;
      end;
      ftlargeint,ftbcd: begin
       sqltype:= SQL_INT64+1;
       sqllen:= 8;
       if datatype = ftbcd then begin
        scale:= -4;
       end;
       case blobkind of
        bk_binary: begin
         subtype:= isc_blob_untyped;
         align1:= 3; //sizeof(SLONG), SLONG always 32 bit
        end;
        bk_text: begin
         subtype:= isc_blob_text;
         align1:= 3; //sizeof(SLONG), SLONG always 32 bit
        end;
        else begin
         align1:= 7;
        end;
       end;
      end;
      ftfloat: begin
       sqltype:= SQL_DOUBLE+1;
       sqllen:= sizeof(double);
       align1:= FB_DOUBLE_ALIGN-1;
      end;
      fttime,ftdate,ftdatetime: begin
       sqltype:= SQL_TIMESTAMP+1;
       sqllen:= sizeof(ISC_TIMESTAMP);
       align1:= sizeof(ISC_DATE)-1;
      end;
      ftstring,ftwidestring,ftmemo,ftwidememo: begin
       sqltype:= SQL_TEXT+1;
       if not isnull then begin
        data[i1]:= params.asdbstring(fparambinding[i1]);
        sqllen:= length(data[i1]);
       end;
      end;
      ftblob,ftgraphic: begin
       sqltype:= SQL_TEXT+1;
       if not isnull then begin
        data[i1]:= asstring;
        sqllen:= length(data[i1]);
       end;
       {
       sqllen:= 8;                
       align1:= 3; //sizeof(SLONG), SLONG always 32 bit
       sqltype:= SQL_BLOB+1;
       subtype:= isc_blob_untyped;
       }
      end;
      {
      ftmemo,ftwidememo: begin //null
       sqllen:= 8;                
       align1:= 3; //sizeof(SLONG), SLONG always 32 bit
       sqltype:= SQL_BLOB+1;
       subtype:= isc_blob_text;
      end;
      }
     end;
     if sqltype = 0 then begin
      databaseerrorfmt(sunsupportedparameter,[fieldtypenames[datatype]],
                                                                 fconnection);
     end;
     _type:= sqltype;
     _length:= sqllen;
     totsize1:= (totsize1 + align1) and not align1;
     offset:= totsize1;
     totsize1:= totsize1 + sqllen;
     totsize1:= (totsize1 + 1) and not 1;
     nulloffset:= totsize1;
     totsize1:= totsize1 + 2;
    end;
   end;
   getmem(fparambuffer,totsize1);
   fmessagelength:= totsize1;
   for i1:= 0 to fcount-1 do begin
    with fitems[i1] do begin
     if _type <> SQL_NULL then begin
      po1:= fparambuffer + offset;
      with params[i1] do begin
       pisc_short(fparambuffer+nulloffset)^:= card8(_isnull);
       if _isnull then begin
        if blobkind <> bk_none then begin
         _type:= SQL_BLOB+1;
        end;
       end
       else begin
        case _type of
         SQL_BOOLEAN+1: begin
          pcard8(po1)^:= card8(asboolean);
         end;
         SQL_LONG+1: begin
          pint32(po1)^:= asinteger;
         end;
         SQL_INT64+1: begin
          if blobkind <> bk_none then begin
           _type:= SQL_BLOB+1;
           pisc_quad(po1)^:= ISC_QUAD(aslargeint);
          end
          else begin
           if scale = -4 then begin
            pcurrency(po1)^:= ascurrency;
           end
           else begin
            pint64(po1)^:= aslargeint;
           end;
          end;         
         end;
         SQL_DOUBLE+1: begin
          pdouble(po1)^:= asfloat;
         end;
         SQL_TIMESTAMP+1: begin
          dt1:= asdatetime;
          pisc_timestamp(po1)^.timestamp_date:= trunc(dt1) - fbdatetimeoffset;
          dt1:= abs(frac(dt1));
          pisc_timestamp(po1)^.timestamp_time:= 
                    round(dt1*3600*24*ISC_TIME_SECONDS_PRECISION);
         end;
         SQL_TEXT+1: begin
          move(pointer(data[i1])^,po1^,length(data[i1]));
         end;
         SQL_BLOB+1: begin
          if subtype = isc_blob_text then begin
           str1:= params.asdbstring(i1);
          end
          else begin
           str1:= asstring;
          end;
          tfbconnection1(fconnection).writeblobdata(cursor.ftrans,'',nil,
                                      pointer(str1),length(str1),nil,nil,str2);
          pisc_quad(po1)^:= pisc_quad(pointer(str2))^;
         end;
         else begin
          raise exception.create('Internal error 20160908A');
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

destructor tparamdata.destroy();
begin
 inherited;
 if fparambuffer <> nil then begin
  freemem(fparambuffer);
 end;
end;

procedure tparamdata.addRef();
begin
 inc(frefcount);
end;

function tparamdata.release(): Integer;
begin
 dec(frefcount);
 result:= frefcount;
 if frefcount = 0 then begin
  destroy();
 end;
end;

function tparamdata.getCount(status: IStatus): Cardinal;
begin
 result:= fcount;
end;

function tparamdata.getField(status: IStatus;
               index: Cardinal): PAnsiChar;
begin
 result:= nil;
end;

function tparamdata.getRelation(status: IStatus;
               index: Cardinal): PAnsiChar;
begin
 result:= nil;
end;

function tparamdata.getOwner(status: IStatus;
               index: Cardinal): PAnsiChar;
begin
 result:= nil;
end;

function tparamdata.getAlias(status: IStatus;
               index: Cardinal): PAnsiChar;
begin
 result:= nil;
end;

function tparamdata.getType(status: IStatus;
               index: Cardinal): Cardinal;
begin
 result:= fitems[index]._type;
end;

function tparamdata.isNullable(status: IStatus;
               index: Cardinal): Boolean;
begin
 result:= fitems[index]._type and 1 <> 0;
end;

function tparamdata.getSubType(status: IStatus;
               index: Cardinal): Integer;
begin
 result:= fitems[index].subtype;
end;

function tparamdata.getLength(status: IStatus;
               index: Cardinal): Cardinal;
begin
 result:= fitems[index]._length;
end;

function tparamdata.getScale(status: IStatus;
               index: Cardinal): Integer;
begin
 result:= fitems[index].scale;
end;

function tparamdata.getCharSet(status: IStatus;
               index: Cardinal): Cardinal;
begin
 result:= 0;
end;

function tparamdata.getOffset(status: IStatus;
               index: Cardinal): Cardinal;
begin
 result:= fitems[index].offset;
end;

function tparamdata.getNullOffset(status: IStatus;
               index: Cardinal): Cardinal;
begin
 result:= fitems[index].nulloffset;
end;

function tparamdata.getBuilder(status: IStatus): IMetadataBuilder;
begin
 result:= nil;
end;

function tparamdata.getMessageLength(status: IStatus): Cardinal;
begin
 result:= fmessagelength;
end;

end.
