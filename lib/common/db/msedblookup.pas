{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedblookup; 
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,mdb,msewidgetgrid,msedataedits,mseeditglob,msestrings,
 msedatalist,
 msedbedit,msedb,msegui,msegrids,msedbdispwidgets,mselookupbuffer,mseclasses,
 mseformatstr,msetypes,mseglob,msemenus,mseguiglob,msebufdataset,
 msegraphics;

const
 defaultlookupoptionsedit = defaultoptionsedit + [oe_readonly];

type
 idblookupdispfieldlink = interface(idbdispfieldlink)
  procedure formatchanged;
  procedure refreshfieldvalue;
 end;
 
 idblookuplbdispfieldlink = interface(idblookupdispfieldlink)
  procedure setlookupvalue(const aindex: integer);
  function lookuptext(const aindex: integer): msestring;
  function getdatalbdatakind: lbdatakindty;
 end;
 
 idblookupdbdispfieldlink = interface(idblookupdispfieldlink)
  procedure setlookupvalue(const aindex: bookmarkdataty);
  function lookuptext(const aindex: bookmarkdataty): msestring;
  function getlookupvaluefieldtypes: fieldtypesty;
 end;
 
 tdblookup32lb = class;
 
 tlookupdispfielddatalink = class(tdispfielddatalink)
  private
   function getdatasource1: tdatasource;
   procedure setwidgetdatasource(const avalue: tdatasource);
   procedure griddatasourcechanged;
  protected
   fowner: tcustomdataedit;
   fdatatype: lookupdatatypety;
   fisnull: boolean;
   procedure lookupchange;
   function datatotext(const data): msestring; virtual; abstract;
   procedure updatelookupvalue; virtual; abstract;
   procedure fieldtovalue; virtual; abstract;
   function getrowdatapo(const alink: tgriddatalink; 
                               const arow: integer): pointer; virtual; abstract;
  public
   constructor create(const aowner: tcustomdataedit;
                           const adatatype: lookupdatatypety;
                                    const intf: idblookupdispfieldlink);
   function msedisplaytext(const aformat: msestring = '';
                          const aedit: boolean = false): msestring; override;
  published
   property datasource: tdatasource read getdatasource1 write setwidgetdatasource;
 end;

 tlookupdbdispfielddatalink = class;
  
 tlookupdatalink = class(tfielddatalink)
  private
   fkeyfield: tfield;
   fkeyfieldname: string;
  protected
   fdisplink: tlookupdbdispfielddatalink;
   fcanlookup: boolean;
   flookupindexnum: integer;
   procedure updatefields; override;
   procedure activechanged; override;
   procedure dataevent(event: tdataevent; info: ptrint); override;
   procedure fieldchanged; override;
 end;
 
 tlookupdbdispfielddatalink = class(tlookupdispfielddatalink)
  private
   flookupdatalink: tlookupdatalink;
   procedure setlookupkeyfield(const avalue: string);
   procedure setlookupvaluefield(const avalue: string);
   function getlookupkeyfield: string;
   function getlookupvaluefield: string;
   function getlookupdatasource: tdatasource;
   procedure setlookupdatasource(const avalue: tdatasource);
  protected
   function getintegerlookupvalue(const abm: bookmarkdataty): integer;
   function getstringlookupvalue(const abm: bookmarkdataty): msestring;
   function getfloatlookupvalue(const abm: bookmarkdataty): double;
   function getdataset(const aindex: integer): tdataset; override;
   procedure getfieldtypes(out apropertynames: stringarty; 
                                     out afieldtypes: fieldtypesarty); override;
  public
   constructor create(const aowner: tcustomdataedit;
                          const adatatype: lookupdatatypety;
                                    const intf: idblookupdbdispfieldlink);
   destructor destroy; override;
  published
   property lookupdatasource: tdatasource read getlookupdatasource
                                                write setlookupdatasource;
   property lookupkeyfield: string read getlookupkeyfield 
                                            write setlookupkeyfield;
   property lookupvaluefield: string read getlookupvaluefield 
                                            write setlookupvaluefield;
 end;

 tlookuplbdispfielddatalink = class(tlookupdispfielddatalink,
                        ilookupbufferfieldinfo,iobjectlink)
  private
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: lookupbufferfieldnoty;
   flookupvaluefieldno: lookupbufferfieldnoty;   
   fobjectlinker: tobjectlinker;
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
   procedure setlookupkeyfieldno(const avalue: lookupbufferfieldnoty);
   procedure setlookupvaluefieldno(const avalue: lookupbufferfieldnoty);
  protected
   function getkeylbdatakind: lbdatakindty; virtual; abstract;
   procedure objectevent(const sender: tobject; const event: objecteventty);
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                   ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
    //ilookupbufferfieldinfo
   function getlbdatakind(const apropname: string): lbdatakindty;
   function getlookupbuffer: tcustomlookupbuffer;
  public
   constructor create(const aowner: tcustomdataedit; 
                           const adatatype: lookupdatatypety;
                                    const intf: idblookuplbdispfieldlink);
   destructor destroy; override;
  published
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer 
                                            write setlookupbuffer;
   property lookupkeyfieldno: lookupbufferfieldnoty read flookupkeyfieldno 
                                            write setlookupkeyfieldno default 0;
   property lookupvaluefieldno: lookupbufferfieldnoty read flookupvaluefieldno
                                            write setlookupvaluefieldno default 0;
 end;
 
 tlookup32lbdispfielddatalink = class(tlookuplbdispfielddatalink)
  protected
   fkey: integer;
   function getkeylbdatakind: lbdatakindty; override;
   procedure updatelookupvalue; override;
   function datatotext(const data): msestring; override;
   procedure fieldtovalue; override;
   function getrowdatapo(const alink: tgriddatalink; 
                           const arow: integer): pointer; override;
 end;
 
 tlookup64lbdispfielddatalink = class(tlookuplbdispfielddatalink)
  protected
   fkey: int64;
   function getkeylbdatakind: lbdatakindty; override;
   procedure updatelookupvalue; override;
   function datatotext(const data): msestring; override;
   procedure fieldtovalue; override;
   function getrowdatapo(const alink: tgriddatalink; 
                               const arow: integer): pointer; override;
 end;
 
 tlookupstrlbdispfielddatalink = class(tlookuplbdispfielddatalink)
  protected
   fkey: msestring;
   function getkeylbdatakind: lbdatakindty; override;
   procedure updatelookupvalue; override;
   function datatotext(const data): msestring; override;
   procedure fieldtovalue; override;
   function getrowdatapo(const alink: tgriddatalink; 
                            const arow: integer): pointer; override;
 end;

 tlookup32dbdispfielddatalink = class(tlookupdbdispfielddatalink)
  protected
   fkey: integer;
   procedure updatelookupvalue; override;
   procedure fieldtovalue; override;
   function datatotext(const data): msestring; override;
   function getrowdatapo(const alink: tgriddatalink; 
                             const arow: integer): pointer; override;
 end;

 tlookup64dbdispfielddatalink = class(tlookupdbdispfielddatalink)
  protected
   fkey: int64;
   procedure updatelookupvalue; override;
   procedure fieldtovalue; override;
   function datatotext(const data): msestring; override;
   function getrowdatapo(const alink: tgriddatalink; 
                             const arow: integer): pointer; override;
 end;
 
 tlookupstrdbdispfielddatalink = class(tlookupdbdispfielddatalink)
  protected
   fkey: msestring;
   procedure updatelookupvalue; override;
   procedure fieldtovalue; override;
   function datatotext(const data): msestring; override;
   function getrowdatapo(const alink: tgriddatalink; 
                             const arow: integer): pointer; override;
 end;
 
 tdblookup1 = class(tcustomdataedit,idblookupdispfieldlink,idbdispfieldlink)
  private
   fdatalink: tlookupdispfielddatalink;
   procedure setdatalink(const avalue: tlookupdispfielddatalink);
   function getisnull: boolean;
  protected
   function createdatalink: tlookupdispfielddatalink; virtual; abstract;
   procedure dochange; override;
   
   function getdatalistclass: datalistclassty; override;
   procedure valuetogrid(row: integer); override;
   procedure griddatasourcechanged; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getoptionsedit: optionseditty; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure setnullvalue; override;

   function internaldatatotext(const data): msestring; override;
   function getrowdatapo(const arow: integer): pointer; override;
 
    //idispfieldlink
   function getfieldlink: tdispfielddatalink;
   procedure fieldtovalue;
   procedure valuetofield;
   procedure getfieldtypes(var afieldtypes: fieldtypesty); virtual;
   procedure refreshfieldvalue;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property isnull: boolean read getisnull;
  published

   property empty_color;
   property empty_font;
   property empty_fontstyle;
   property empty_textflags;
   property empty_text;
   property empty_options;
   property empty_textcolor;
   property empty_textcolorbackground;
   property optionsedit default defaultlookupoptionsedit;
   property font;
   property textflags;
   property textflagsactive;
   property caretwidth;
   property onchange;
   property ongettext;
   property onkeydown;
   property onkeyup;
 end;

 tdblookup = class(tdblookup1)
  private
  protected
  published
   property datalink: tlookupdispfielddatalink read fdatalink write setdatalink;
 end;
 
 tdblookupdb = class(tdblookup,idblookupdbdispfieldlink)
  private
   function getdatalink: tlookupdbdispfielddatalink;
   procedure setdatalink(const avalue: tlookupdbdispfielddatalink);
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); virtual; abstract;
   function lookuptext(const abm: bookmarkdataty): msestring; virtual; abstract;
   function getlookupvaluefieldtypes: fieldtypesty; virtual; abstract;
  public
  published
   property datalink: tlookupdbdispfielddatalink read getdatalink 
                                                    write setdatalink;
 end;
 
 tdblookup32db = class(tdblookupdb,ireccontrol)
  protected  
   function createdatalink: tlookupdispfielddatalink; override;  
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
 end;

 tdblookup64db = class(tdblookupdb,ireccontrol)
  protected  
   function createdatalink: tlookupdispfielddatalink; override;  
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
 end;
 
 tdblookupstrdb = class(tdblookupdb,ireccontrol)
  protected  
   function createdatalink: tlookupdispfielddatalink; override;  
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
 end;
 
 tdblookuplb = class(tdblookup,idblookuplbdispfieldlink)
  private
   procedure readlookupkeyfieldno(reader: treader);
   procedure readlookupvaluefieldno(reader: treader);
   function getlookupbuffer: tcustomlookupbuffer;
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
   function getdatalink: tlookuplbdispfielddatalink;
   procedure setdatalink(const avalue: tlookuplbdispfielddatalink);
  protected
   function getdatalbdatakind: lbdatakindty; virtual; abstract;
   procedure defineproperties(filer: tfiler); override;
   procedure setlookupvalue(const aindex: integer); virtual; abstract;
                  //aindex -1 -> NULL
   function lookuptext(const aindex: integer): msestring; virtual; abstract;
  public
  published
   property datalink: tlookuplbdispfielddatalink read getdatalink 
                                                       write setdatalink;
{
   property lookupbuffer: tcustomlookupbuffer read getlookupbuffer
                                            write setlookupbuffer; deprecated;
                  //use datalink.lookupbuffer
}
 end;
  
 tdblookup32lb = class(tdblookuplb,ireccontrol)
  protected
   function createdatalink: tlookupdispfielddatalink; override;  
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
  public
 end;

 tdblookup64lb = class(tdblookuplb,ireccontrol)
  protected
   function createdatalink: tlookupdispfielddatalink; override;  
    //idbeditfieldlink
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
  public
 end;

 tdblookupstrlb = class(tdblookuplb,ireccontrol)
  protected
   function createdatalink: tlookupdispfielddatalink; override;  
    //idbeditfieldlink
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
  public
 end;

 tdbstringlookuplb = class(tdblookup32lb)
  private
   fvalue: msestring;
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   property value: msestring read fvalue;
 end;

 tdbstringlookup64lb = class(tdblookup64lb)
  private
   fvalue: msestring;
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   property value: msestring read fvalue;
 end;

 tdbstringlookupstrlb = class(tdblookupstrlb)
  private
   fvalue: msestring;
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   property value: msestring read fvalue;
 end;

 tdbstringlookupdb = class(tdblookup32db)
  private
   fvalue: msestring;
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); override;
   function lookuptext(const abm: bookmarkdataty): msestring; override;
   function getlookupvaluefieldtypes: fieldtypesty; override;
  public
   property value: msestring read fvalue;
 end;

 tdbstringlookup64db = class(tdblookup64db)
  private
   fvalue: msestring;
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); override;
   function lookuptext(const abm: bookmarkdataty): msestring; override;
   function getlookupvaluefieldtypes: fieldtypesty; override;
  public
   property value: msestring read fvalue;
 end;

 tdbstringlookupstrdb = class(tdblookupstrdb)
  private
   fvalue: msestring;
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); override;
   function lookuptext(const abm: bookmarkdataty): msestring; override;
   function getlookupvaluefieldtypes: fieldtypesty; override;
  public
   property value: msestring read fvalue;
 end;

 tdbintegerlookuplb = class(tdblookup32lb)
  private
   fbase: numbasety;
   fbitcount: integer;
   fvalue: integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aaowner: tcomponent); override;
   property value: integer read fvalue;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
 end;

 tdbintegerlookup64lb = class(tdblookup64lb)
  private
   fbase: numbasety;
   fbitcount: integer;
   fvalue: integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aaowner: tcomponent); override;
   property value: integer read fvalue;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
 end;

 tdbintegerlookupstrlb = class(tdblookupstrlb)
  private
   fbase: numbasety;
   fbitcount: integer;
   fvalue: integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aaowner: tcomponent); override;
   property value: integer read fvalue;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
 end;

 tdbintegerlookupdb = class(tdblookup32db)
  private
   fbase: numbasety;
   fbitcount: integer;
   fvalue: integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); override;
   function lookuptext(const abm: bookmarkdataty): msestring; override;
   function getlookupvaluefieldtypes: fieldtypesty; override;
  public
   constructor create(aaowner: tcomponent); override;
   property value: integer read fvalue;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
 end;

 tdbintegerlookup64db = class(tdblookup64db)
  private
   fbase: numbasety;
   fbitcount: integer;
   fvalue: integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); override;
   function lookuptext(const abm: bookmarkdataty): msestring; override;
   function getlookupvaluefieldtypes: fieldtypesty; override;
  public
   constructor create(aaowner: tcomponent); override;
   property value: integer read fvalue;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
 end;

 tdbintegerlookupstrdb = class(tdblookupstrdb)
  private
   fbase: numbasety;
   fbitcount: integer;
   fvalue: integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); override;
   function lookuptext(const abm: bookmarkdataty): msestring; override;
   function getlookupvaluefieldtypes: fieldtypesty; override;
  public
   constructor create(aaowner: tcomponent); override;
   property value: integer read fvalue;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
 end;

 tdbreallookuplb = class(tdblookup32lb)
  private
   fformat: msestring;
   fvaluerange: real;
   fvaluestart: real;
   fvalue: real;
   procedure setformat(const avalue: msestring);
   procedure setvaluerange(const avalue: real);
   procedure setvaluestart(const avalue: real);
   procedure readvaluescale(reader: treader);
  protected
   procedure defineproperties(filer: tfiler); override;
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aowner: tcomponent); override;
   property value: real read fvalue;
  published
   property valuerange: real read fvaluerange write setvaluerange;
   property valuestart: real read fvaluestart write setvaluestart;
   property format: msestring read fformat write setformat;
 end;

 tdbreallookup64lb = class(tdblookup64lb)
  private
   fformat: msestring;
   fvaluerange: real;
   fvaluestart: real;
   fvalue: real;
   procedure setformat(const avalue: msestring);
   procedure setvaluerange(const avalue: real);
   procedure setvaluestart(const avalue: real);
   procedure readvaluescale(reader: treader);
  protected
   procedure defineproperties(filer: tfiler); override;
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aowner: tcomponent); override;
   property value: real read fvalue;
  published
   property valuerange: real read fvaluerange write setvaluerange;
   property valuestart: real read fvaluestart write setvaluestart;
   property format: msestring read fformat write setformat;
 end;

 tdbreallookupstrlb = class(tdblookupstrlb)
  private
   fformat: msestring;
   fvaluerange: real;
   fvaluestart: real;
   fvalue: real;
   procedure setformat(const avalue: msestring);
   procedure setvaluerange(const avalue: real);
   procedure setvaluestart(const avalue: real);
   procedure readvaluescale(reader: treader);
  protected
   procedure defineproperties(filer: tfiler); override;
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aowner: tcomponent); override;
   property value: real read fvalue;
  published
   property valuerange: real read fvaluerange write setvaluerange;
   property valuestart: real read fvaluestart write setvaluestart;
   property format: msestring read fformat write setformat;
 end;

 tdbreallookupdb = class(tdblookup32db)
  private
   fformat: msestring;
   fvaluerange: real;
   fvaluestart: real;
   fvalue: real;
   procedure setformat(const avalue: msestring);
   procedure setvaluerange(const avalue: real);
   procedure setvaluestart(const avalue: real);
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); override;
   function lookuptext(const abm: bookmarkdataty): msestring; override;
   function getlookupvaluefieldtypes: fieldtypesty; override;
  public
   constructor create(aowner: tcomponent); override;
   property value: real read fvalue;
  published
   property valuerange: real read fvaluerange write setvaluerange;
   property valuestart: real read fvaluestart write setvaluestart;
   property format: msestring read fformat write setformat;
 end;

 tdbreallookup64db = class(tdblookup64db)
  private
   fformat: msestring;
   fvaluerange: real;
   fvaluestart: real;
   fvalue: real;
   procedure setformat(const avalue: msestring);
   procedure setvaluerange(const avalue: real);
   procedure setvaluestart(const avalue: real);
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); override;
   function lookuptext(const abm: bookmarkdataty): msestring; override;
   function getlookupvaluefieldtypes: fieldtypesty; override;
  public
   constructor create(aowner: tcomponent); override;
   property value: real read fvalue;
  published
   property valuerange: real read fvaluerange write setvaluerange;
   property valuestart: real read fvaluestart write setvaluestart;
   property format: msestring read fformat write setformat;
 end;

 tdbreallookupstrdb = class(tdblookupstrdb)
  private
   fformat: msestring;
   fvaluerange: real;
   fvaluestart: real;
   fvalue: real;
   procedure setformat(const avalue: msestring);
   procedure setvaluerange(const avalue: real);
   procedure setvaluestart(const avalue: real);
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); override;
   function lookuptext(const abm: bookmarkdataty): msestring; override;
   function getlookupvaluefieldtypes: fieldtypesty; override;
  public
   constructor create(aowner: tcomponent); override;
   property value: real read fvalue;
  published
   property valuerange: real read fvaluerange write setvaluerange;
   property valuestart: real read fvaluestart write setvaluestart;
   property format: msestring read fformat write setformat;
 end;

 tdbdatetimelookuplb = class(tdblookup32lb)
  private
   fformat: msestring;
   fkind: datetimekindty;
   fvalue: tdatetime;
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  published
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property format: msestring read fformat write setformat;
   property value: tdatetime read fvalue;
 end;
 
 tdbdatetimelookup64lb = class(tdblookup64lb)
  private
   fformat: msestring;
   fkind: datetimekindty;
   fvalue: tdatetime;
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   property value: tdatetime read fvalue;
  published
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property format: msestring read fformat write setformat;
 end;

 tdbdatetimelookupstrlb = class(tdblookupstrlb)
  private
   fformat: msestring;
   fkind: datetimekindty;
   fvalue: tdatetime;
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   property value: tdatetime read fvalue;
  published
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property format: msestring read fformat write setformat;
 end;
 
 tdbdatetimelookupdb = class(tdblookup32db)
  private
   fformat: msestring;
   fkind: datetimekindty;
   fvalue: tdatetime;
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); override;
   function lookuptext(const abm: bookmarkdataty): msestring; override;
   function getlookupvaluefieldtypes: fieldtypesty; override;
  published
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property format: msestring read fformat write setformat;
   property value: tdatetime read fvalue;
 end;
 
 tdbdatetimelookup64db = class(tdblookup64db)
  private
   fformat: msestring;
   fkind: datetimekindty;
   fvalue: tdatetime;
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); override;
   function lookuptext(const abm: bookmarkdataty): msestring; override;
   function getlookupvaluefieldtypes: fieldtypesty; override;
  published
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property format: msestring read fformat write setformat;
   property value: tdatetime read fvalue;
 end;
 
 tdbdatetimelookupstrdb = class(tdblookupstrdb)
  private
   fformat: msestring;
   fkind: datetimekindty;
   fvalue: tdatetime;
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
  protected
   procedure setlookupvalue(const abm: bookmarkdataty); override;
   function lookuptext(const abm: bookmarkdataty): msestring; override;
   function getlookupvaluefieldtypes: fieldtypesty; override;
  published
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property format: msestring read fformat write setformat;
   property value: tdatetime read fvalue;
 end;
 
implementation
uses
 msereal,sysutils;
type
 tcustomdataedit1 = class(tcustomdataedit);
  
{ tlookupdispfielddatalink }

constructor tlookupdispfielddatalink.create(const aowner: tcustomdataedit;
                    const adatatype: lookupdatatypety;
                               const intf: idblookupdispfieldlink);
begin
 fowner:= aowner;
 fdatatype:= adatatype;
 fisnull:= true;
 inherited create(intf);
end;

procedure tlookupdispfielddatalink.setwidgetdatasource(const avalue: tdatasource);
begin
 if not ((csloading in fowner.componentstate) and datasourcefixed or 
                  (fowner.gridintf <> nil)) then begin
  inherited datasource:= avalue;
 end;
end;

procedure tlookupdispfielddatalink.griddatasourcechanged;
var
 dso1: tdatasource;
begin
 with fowner do begin
  dso1:=  tcustomdbwidgetgrid(gridintf.getcol.grid).datalink.datasource;
 end;
 if dso1 <> datasource then begin
  inherited datasource:= dso1;
 end;
end;

function tlookupdispfielddatalink.getdatasource1: tdatasource;
begin
 result:= inherited datasource;
end;

procedure tlookupdispfielddatalink.lookupchange;
begin
 if not (csloading in fowner.componentstate) and active and 
                                            (field <> nil) then begin
  idblookupdispfieldlink(fintf).formatchanged;
  idblookupdispfieldlink(fintf).fieldtovalue;
 end;
end;

function tlookupdispfielddatalink.msedisplaytext(const aformat: msestring = '';
               const aedit: boolean = false): msestring;
var
 i1: int32;
 li1: int64;
 s1: msestring;
begin
 if fowner <> nil then begin
  result:= '';
  if (field <> nil) and not field.isnull then begin
   case fdatatype of
    ldt_int32: begin
     i1:= field.asinteger;
     result:= tcustomdataedit1(fowner).internaldatatotext(i1);
    end;
    ldt_int64: begin
     li1:= field.aslargeint;
     result:= tcustomdataedit1(fowner).internaldatatotext(li1);
    end;
    ldt_string: begin
     s1:= field.asunicodestring;
     result:= tcustomdataedit1(fowner).internaldatatotext(s1);
    end;
   end;
  end;
 end
 else begin
  result:= inherited msedisplaytext(aformat,aedit);
 end;
end;

{ tdblookup1 }

constructor tdblookup1.create(aowner: tcomponent);
begin
 if fdatalink = nil then begin
  fdatalink:= createdatalink;
 end;
 inherited;
 foptionsedit:= defaultlookupoptionsedit;
end;

destructor tdblookup1.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdblookup1.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit + [oe_readonly];
end;

procedure tdblookup1.setnullvalue;
begin
 inherited;
 fdatalink.fisnull:= true;
 changed;
end;

procedure tdblookup1.texttovalue(var accept: boolean; const quiet: boolean);
begin
 fdatalink.fisnull:= text = '';
end;

procedure tdblookup1.valuetofield;
begin
 //dummy
end;

procedure tdblookup1.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdblookup1.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdblookup1.setdatalink(const avalue: tlookupdispfielddatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdblookup1.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

function tdblookup1.getdatalistclass: datalistclassty;
begin
 result:= tnonedatalist;
end;

procedure tdblookup1.valuetogrid(row: integer);
begin
 //dummy
end;

procedure tdblookup1.refreshfieldvalue;
begin
 valuetotext;
 changed;
end;

procedure tdblookup1.fieldtovalue;
begin
 fdatalink.fieldtovalue;
 exclude(fstate,des_dbnull);
 refreshfieldvalue;
end;

procedure tdblookup1.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 //dummy
end;

procedure tdblookup1.dochange;
begin
 fdatalink.updatelookupvalue;
 inherited;
end;

function tdblookup1.internaldatatotext(const data): msestring;
begin
 result:= fdatalink.datatotext(data);
end;

function tdblookup1.getisnull: boolean;
begin
 result:= fdatalink.fisnull;
end;

function tdblookup1.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= fdatalink.getrowdatapo(tgriddatalink(fgriddatalink),arow);
 end
 else begin
  result:= nil;
 end;
end;

function tdblookup1.getfieldlink: tdispfielddatalink;
begin
 result:= fdatalink;
end;

{ tdblookuplb }

{ tdblookup32lb }

procedure tdblookup32lb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

function tdblookup32lb.createdatalink: tlookupdispfielddatalink;
begin
 result:= tlookup32lbdispfielddatalink.create(self,ldt_int32,
                                      idblookuplbdispfieldlink(self));
end;

procedure tdblookup64lb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

function tdblookup64lb.createdatalink: tlookupdispfielddatalink;
begin
 result:= tlookup64lbdispfielddatalink.create(self,ldt_int64,
                                      idblookuplbdispfieldlink(self));
end;

procedure tdblookupstrlb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= textfields;
end;

function tdblookupstrlb.createdatalink: tlookupdispfielddatalink;
begin
 result:= tlookupstrlbdispfielddatalink.create(self,ldt_string,
                                      idblookuplbdispfieldlink(self));
end;

{ tdbstringlookuplb }

procedure tdbstringlookuplb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= '';
 end
 else begin
  with tlookuplbdispfielddatalink(fdatalink) do begin
   fvalue:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
  end;
 end;
end;

function tdbstringlookuplb.lookuptext(const aindex: integer): msestring;
begin
 with tlookuplbdispfielddatalink(fdatalink) do begin
  result:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
 end;
end;

function tdbstringlookuplb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_text;
end;

{ tdbstringlookupdb }

procedure tdbstringlookupdb.setlookupvalue(const abm: bookmarkdataty);
begin
 fvalue:= tlookupdbdispfielddatalink(fdatalink).getstringlookupvalue(abm);
end;

function tdbstringlookupdb.lookuptext(const abm: bookmarkdataty): msestring;
begin
 result:= tlookupdbdispfielddatalink(fdatalink).getstringlookupvalue(abm);
end;

function tdbstringlookupdb.getlookupvaluefieldtypes: fieldtypesty;
begin
 result:= charfields;
end;

{ tdbstringlookup64db }

procedure tdbstringlookup64db.setlookupvalue(const abm: bookmarkdataty);
begin
 fvalue:= tlookupdbdispfielddatalink(fdatalink).getstringlookupvalue(abm);
end;

function tdbstringlookup64db.lookuptext(const abm: bookmarkdataty): msestring;
begin
 result:= tlookupdbdispfielddatalink(fdatalink).getstringlookupvalue(abm);
end;

function tdbstringlookup64db.getlookupvaluefieldtypes: fieldtypesty;
begin
 result:= charfields;
end;

{ tdbstringlookupstrdb }

procedure tdbstringlookupstrdb.setlookupvalue(const abm: bookmarkdataty);
begin
 fvalue:= tlookupdbdispfielddatalink(fdatalink).getstringlookupvalue(abm);
end;

function tdbstringlookupstrdb.lookuptext(const abm: bookmarkdataty): msestring;
begin
 result:= tlookupdbdispfielddatalink(fdatalink).getstringlookupvalue(abm);
end;

function tdbstringlookupstrdb.getlookupvaluefieldtypes: fieldtypesty;
begin
 result:= charfields;
end;

{ tdbintegerlookuplb }

constructor tdbintegerlookuplb.create(aaowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
end;

procedure tdbintegerlookuplb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= 0;
 end
 else begin
  with tlookuplbdispfielddatalink(fdatalink) do begin
   fvalue:= flookupbuffer.integervaluephys(flookupvaluefieldno,aindex);
  end;
 end;
end;

function tdbintegerlookuplb.lookuptext(const aindex: integer): msestring;
begin
 with tlookuplbdispfielddatalink(fdatalink) do begin
  result:= msestring(intvaluetostr(flookupbuffer.integervaluephys(
                        flookupvaluefieldno,aindex),fbase,fbitcount));
 end;
end;

procedure tdbintegerlookuplb.setbase(const avalue: numbasety);
begin
 if fbase <> avalue then begin
  fbase := avalue;
  formatchanged;
 end;
end;

procedure tdbintegerlookuplb.setbitcount(const avalue: integer);
begin
 if fbitcount <> avalue then begin
  fbitcount := avalue;
  formatchanged;
 end;
end;

function tdbintegerlookuplb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_integer;
end;

{ tdbintegerlookupdb }

constructor tdbintegerlookupdb.create(aaowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
end;

procedure tdbintegerlookupdb.setlookupvalue(const abm: bookmarkdataty);
begin
 fvalue:= tlookupdbdispfielddatalink(fdatalink).getintegerlookupvalue(abm);
end;

function tdbintegerlookupdb.lookuptext(const abm: bookmarkdataty): msestring;
begin
 result:= msestring(intvaluetostr(
           tlookupdbdispfielddatalink(fdatalink).getintegerlookupvalue(abm),
                        fbase,fbitcount));
end;

procedure tdbintegerlookupdb.setbase(const avalue: numbasety);
begin
 if fbase <> avalue then begin
  fbase := avalue;
  formatchanged;
 end;
end;

procedure tdbintegerlookupdb.setbitcount(const avalue: integer);
begin
 if fbitcount <> avalue then begin
  fbitcount := avalue;
  formatchanged;
 end;
end;

function tdbintegerlookupdb.getlookupvaluefieldtypes: fieldtypesty;
begin
 result:= int32fields;
end;

{ tdbintegerlookup64db }

constructor tdbintegerlookup64db.create(aaowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
end;

procedure tdbintegerlookup64db.setlookupvalue(const abm: bookmarkdataty);
begin
 fvalue:= tlookupdbdispfielddatalink(fdatalink).getintegerlookupvalue(abm);
end;

function tdbintegerlookup64db.lookuptext(const abm: bookmarkdataty): msestring;
begin
 result:= msestring(intvaluetostr(
           tlookupdbdispfielddatalink(fdatalink).getintegerlookupvalue(abm),
                        fbase,fbitcount));
end;

procedure tdbintegerlookup64db.setbase(const avalue: numbasety);
begin
 if fbase <> avalue then begin
  fbase := avalue;
  formatchanged;
 end;
end;

procedure tdbintegerlookup64db.setbitcount(const avalue: integer);
begin
 if fbitcount <> avalue then begin
  fbitcount := avalue;
  formatchanged;
 end;
end;

function tdbintegerlookup64db.getlookupvaluefieldtypes: fieldtypesty;
begin
 result:= int32fields;
end;

{ tdbintegerlookupstrdb }

constructor tdbintegerlookupstrdb.create(aaowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
end;

procedure tdbintegerlookupstrdb.setlookupvalue(const abm: bookmarkdataty);
begin
 fvalue:= tlookupdbdispfielddatalink(fdatalink).getintegerlookupvalue(abm);
end;

function tdbintegerlookupstrdb.lookuptext(const abm: bookmarkdataty): msestring;
begin
 result:= msestring(intvaluetostr(
           tlookupdbdispfielddatalink(fdatalink).getintegerlookupvalue(abm),
                        fbase,fbitcount));
end;

procedure tdbintegerlookupstrdb.setbase(const avalue: numbasety);
begin
 if fbase <> avalue then begin
  fbase := avalue;
  formatchanged;
 end;
end;

procedure tdbintegerlookupstrdb.setbitcount(const avalue: integer);
begin
 if fbitcount <> avalue then begin
  fbitcount := avalue;
  formatchanged;
 end;
end;

function tdbintegerlookupstrdb.getlookupvaluefieldtypes: fieldtypesty;
begin
 result:= int32fields;
end;

{ tdbreallookuplb }

constructor tdbreallookuplb.create(aowner: tcomponent);
begin
 fvaluerange:= 1;
 inherited;
end;

procedure tdbreallookuplb.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

procedure tdbreallookuplb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= emptyreal;
 end
 else begin
  with tlookuplbdispfielddatalink(fdatalink) do begin
   fvalue:= reapplyrange(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                           valuerange,valuestart);
  end;
 end;
end;

function tdbreallookuplb.lookuptext(const aindex: integer): msestring;
begin
 with tlookuplbdispfielddatalink(fdatalink) do begin
  result:= realtytostr(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                                                   fformat);
 end;
end;

procedure tdbreallookuplb.setvaluerange(const avalue: real);
begin
 fvaluerange:= avalue;
 formatchanged;
end;

procedure tdbreallookuplb.setvaluestart(const avalue: real);
begin
 fvaluestart:= avalue;
 formatchanged;
end;

procedure tdbreallookuplb.readvaluescale(reader: treader);
begin
 valuerange:= valuescaletorange(reader);
end;

procedure tdbreallookuplb.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('valuescale',{$ifdef FPC}@{$endif}readvaluescale,nil,false);
end;

function tdbreallookuplb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_float;
end;

{ tdbreallookupdb }

constructor tdbreallookupdb.create(aowner: tcomponent);
begin
 fvaluerange:= 1;
 inherited;
end;

procedure tdbreallookupdb.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

procedure tdbreallookupdb.setlookupvalue(const abm: bookmarkdataty);
begin
 if abm.recordpo = nil then begin
  fvalue:= emptyreal;
 end
 else begin
  with tlookupdbdispfielddatalink(fdatalink) do begin
   fvalue:= reapplyrange(getfloatlookupvalue(abm),valuerange,valuestart);
  end;
 end;
end;

function tdbreallookupdb.lookuptext(const abm: bookmarkdataty): msestring;
begin
 with tlookupdbdispfielddatalink(fdatalink) do begin
  result:= realtytostr(getfloatlookupvalue(abm),fformat);
 end;
end;

procedure tdbreallookupdb.setvaluerange(const avalue: real);
begin
 fvaluerange:= avalue;
 formatchanged;
end;

procedure tdbreallookupdb.setvaluestart(const avalue: real);
begin
 fvaluestart:= avalue;
 formatchanged;
end;

function tdbreallookupdb.getlookupvaluefieldtypes: fieldtypesty;
begin
 result:= doublefields;
end;

{ tdbreallookup64db }

constructor tdbreallookup64db.create(aowner: tcomponent);
begin
 fvaluerange:= 1;
 inherited;
end;

procedure tdbreallookup64db.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

procedure tdbreallookup64db.setlookupvalue(const abm: bookmarkdataty);
begin
 if abm.recordpo = nil then begin
  fvalue:= emptyreal;
 end
 else begin
  with tlookupdbdispfielddatalink(fdatalink) do begin
   fvalue:= reapplyrange(getfloatlookupvalue(abm),valuerange,valuestart);
  end;
 end;
end;

function tdbreallookup64db.lookuptext(const abm: bookmarkdataty): msestring;
begin
 with tlookupdbdispfielddatalink(fdatalink) do begin
  result:= realtytostr(getfloatlookupvalue(abm),fformat);
 end;
end;

procedure tdbreallookup64db.setvaluerange(const avalue: real);
begin
 fvaluerange:= avalue;
 formatchanged;
end;

procedure tdbreallookup64db.setvaluestart(const avalue: real);
begin
 fvaluestart:= avalue;
 formatchanged;
end;

function tdbreallookup64db.getlookupvaluefieldtypes: fieldtypesty;
begin
 result:= doublefields;
end;

{ tdbreallookupstrdb }

constructor tdbreallookupstrdb.create(aowner: tcomponent);
begin
 fvaluerange:= 1;
 inherited;
end;

procedure tdbreallookupstrdb.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

procedure tdbreallookupstrdb.setlookupvalue(const abm: bookmarkdataty);
begin
 if abm.recordpo = nil then begin
  fvalue:= emptyreal;
 end
 else begin
  with tlookupdbdispfielddatalink(fdatalink) do begin
   fvalue:= reapplyrange(getfloatlookupvalue(abm),valuerange,valuestart);
  end;
 end;
end;

function tdbreallookupstrdb.lookuptext(const abm: bookmarkdataty): msestring;
begin
 with tlookupdbdispfielddatalink(fdatalink) do begin
  result:= realtytostr(getfloatlookupvalue(abm),fformat);
 end;
end;

procedure tdbreallookupstrdb.setvaluerange(const avalue: real);
begin
 fvaluerange:= avalue;
 formatchanged;
end;

procedure tdbreallookupstrdb.setvaluestart(const avalue: real);
begin
 fvaluestart:= avalue;
 formatchanged;
end;

function tdbreallookupstrdb.getlookupvaluefieldtypes: fieldtypesty;
begin
 result:= doublefields;
end;

{ tdatetimelookuplb }

procedure tdbdatetimelookuplb.setformat(const avalue: msestring);
begin
 format:= avalue;
 formatchanged;
end;

procedure tdbdatetimelookuplb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= emptydatetime;
 end
 else begin
  with tlookuplbdispfielddatalink(fdatalink) do begin
   fvalue:= flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex);
  end;
 end;
end;

function tdbdatetimelookuplb.lookuptext(const aindex: integer): msestring;
var
 dat1: tdatetime;
begin
 with tlookuplbdispfielddatalink(fdatalink) do begin
  dat1:= flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex);
 end;
 if fkind = dtk_time then begin
  result:= mseformatstr.timetostring(dat1,fformat);
 end
 else begin
  result:= mseformatstr.datetimetostring(dat1,fformat);
 end;
end;

procedure tdbdatetimelookuplb.setkind(const avalue: datetimekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  formatchanged;
 end;
end;

function tdbdatetimelookuplb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_float;
end;

{ tdatetimelookupdb }

procedure tdbdatetimelookupdb.setformat(const avalue: msestring);
begin
 format:= avalue;
 formatchanged;
end;

procedure tdbdatetimelookupdb.setlookupvalue(const abm: bookmarkdataty);
begin
 if abm.recordpo = nil then begin
  fvalue:= emptydatetime;
 end
 else begin
  with tlookupdbdispfielddatalink(fdatalink) do begin
   fvalue:= getfloatlookupvalue(abm);
  end;
 end;
end;

function tdbdatetimelookupdb.lookuptext(const abm: bookmarkdataty): msestring;
var
 dat1: tdatetime;
begin
 with tlookupdbdispfielddatalink(fdatalink) do begin
  dat1:= getfloatlookupvalue(abm);
 end;
 if fkind = dtk_time then begin
  result:= mseformatstr.timetostring(dat1,fformat);
 end
 else begin
  result:= mseformatstr.datetimetostring(dat1,fformat);
 end;
end;

procedure tdbdatetimelookupdb.setkind(const avalue: datetimekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  formatchanged;
 end;
end;

function tdbdatetimelookupdb.getlookupvaluefieldtypes: fieldtypesty;
begin
 result:= datetimefields;
end;

{ tdatetimelookup64db }

procedure tdbdatetimelookup64db.setformat(const avalue: msestring);
begin
 format:= avalue;
 formatchanged;
end;

procedure tdbdatetimelookup64db.setlookupvalue(const abm: bookmarkdataty);
begin
 if abm.recordpo = nil then begin
  fvalue:= emptydatetime;
 end
 else begin
  with tlookupdbdispfielddatalink(fdatalink) do begin
   fvalue:= getfloatlookupvalue(abm);
  end;
 end;
end;

function tdbdatetimelookup64db.lookuptext(const abm: bookmarkdataty): msestring;
var
 dat1: tdatetime;
begin
 with tlookupdbdispfielddatalink(fdatalink) do begin
  dat1:= getfloatlookupvalue(abm);
 end;
 if fkind = dtk_time then begin
  result:= mseformatstr.timetostring(dat1,fformat);
 end
 else begin
  result:= mseformatstr.datetimetostring(dat1,fformat);
 end;
end;

procedure tdbdatetimelookup64db.setkind(const avalue: datetimekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  formatchanged;
 end;
end;

function tdbdatetimelookup64db.getlookupvaluefieldtypes: fieldtypesty;
begin
 result:= datetimefields;
end;

{ tdatetimelookupstrdb }

procedure tdbdatetimelookupstrdb.setformat(const avalue: msestring);
begin
 format:= avalue;
 formatchanged;
end;

procedure tdbdatetimelookupstrdb.setlookupvalue(const abm: bookmarkdataty);
begin
 if abm.recordpo = nil then begin
  fvalue:= emptydatetime;
 end
 else begin
  with tlookupdbdispfielddatalink(fdatalink) do begin
   fvalue:= getfloatlookupvalue(abm);
  end;
 end;
end;

function tdbdatetimelookupstrdb.lookuptext(const abm: bookmarkdataty): msestring;
var
 dat1: tdatetime;
begin
 with tlookupdbdispfielddatalink(fdatalink) do begin
  dat1:= getfloatlookupvalue(abm);
 end;
 if fkind = dtk_time then begin
  result:= mseformatstr.timetostring(dat1,fformat);
 end
 else begin
  result:= mseformatstr.datetimetostring(dat1,fformat);
 end;
end;

procedure tdbdatetimelookupstrdb.setkind(const avalue: datetimekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  formatchanged;
 end;
end;

function tdbdatetimelookupstrdb.getlookupvaluefieldtypes: fieldtypesty;
begin
 result:= datetimefields;
end;

{ tdbstringlookup64lb }

procedure tdbstringlookup64lb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= '';
 end
 else begin
  with tlookuplbdispfielddatalink(fdatalink) do begin
   fvalue:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
  end;
 end;
end;

function tdbstringlookup64lb.lookuptext(const aindex: integer): msestring;
begin
 with tlookuplbdispfielddatalink(fdatalink) do begin
  result:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
 end; 
end;

function tdbstringlookup64lb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_text;
end;

{ tdbintegerlookup64lb }

constructor tdbintegerlookup64lb.create(aaowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
end;

procedure tdbintegerlookup64lb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= 0;
 end
 else begin
  with tlookuplbdispfielddatalink(fdatalink) do begin
   fvalue:= flookupbuffer.integervaluephys(flookupvaluefieldno,aindex);
  end;
 end;
end;

function tdbintegerlookup64lb.lookuptext(const aindex: integer): msestring;
begin
 with tlookuplbdispfielddatalink(fdatalink) do begin
  result:= msestring(intvaluetostr(flookupbuffer.integervaluephys(
                        flookupvaluefieldno,aindex),fbase,fbitcount));
 end;
end;

procedure tdbintegerlookup64lb.setbase(const avalue: numbasety);
begin
 if fbase <> avalue then begin
  fbase := avalue;
  formatchanged;
 end;
end;

procedure tdbintegerlookup64lb.setbitcount(const avalue: integer);
begin
 if fbitcount <> avalue then begin
  fbitcount := avalue;
  formatchanged;
 end;
end;

function tdbintegerlookup64lb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_integer;
end;

{ tdbreallookup64lb }

constructor tdbreallookup64lb.create(aowner: tcomponent);
begin
 fvaluerange:= 1;
 inherited;
end;

procedure tdbreallookup64lb.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

procedure tdbreallookup64lb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= emptyreal;
 end
 else begin
  with tlookuplbdispfielddatalink(fdatalink) do begin
   fvalue:= reapplyrange(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                        valuerange,valuestart);
  end;
 end;
end;

function tdbreallookup64lb.lookuptext(const aindex: integer): msestring;
begin
 with tlookuplbdispfielddatalink(fdatalink) do begin
  result:= realtytostr(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                                                   fformat);
 end;
end;

procedure tdbreallookup64lb.setvaluerange(const avalue: real);
begin
 fvaluerange:= avalue;
 formatchanged;
end;

procedure tdbreallookup64lb.setvaluestart(const avalue: real);
begin
 fvaluestart:= avalue;
 formatchanged;
end;

procedure tdbreallookup64lb.readvaluescale(reader: treader);
begin
 valuerange:= valuescaletorange(reader);
end;

procedure tdbreallookup64lb.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('valuescale',{$ifdef FPC}@{$endif}readvaluescale,nil,false);
end;


function tdbreallookup64lb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_float;
end;

{ tdatetimelookup64lb }

procedure tdbdatetimelookup64lb.setformat(const avalue: msestring);
begin
 format:= avalue;
 formatchanged;
end;

procedure tdbdatetimelookup64lb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= emptydatetime;
 end
 else begin
  with tlookuplbdispfielddatalink(fdatalink) do begin
   fvalue:= flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex);
  end;
 end;
end;

function tdbdatetimelookup64lb.lookuptext(const aindex: integer): msestring;
var
 dat1: tdatetime;
begin
 with tlookuplbdispfielddatalink(fdatalink) do begin
  dat1:= flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex);
 end;
 if fkind = dtk_time then begin
  result:= mseformatstr.timetostring(dat1,fformat);
 end
 else begin
  result:= mseformatstr.datetimetostring(dat1,fformat);
 end;
end;

procedure tdbdatetimelookup64lb.setkind(const avalue: datetimekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  formatchanged;
 end;
end;

function tdbdatetimelookup64lb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_float;
end;

{ tdbstringlookupstrlb }

function tdbstringlookupstrlb.lookuptext(const aindex: integer): msestring;
begin
 with tlookuplbdispfielddatalink(fdatalink) do begin
  result:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
 end;
end;

procedure tdbstringlookupstrlb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= '';
 end
 else begin
  with tlookuplbdispfielddatalink(fdatalink) do begin
   fvalue:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
  end;
 end;
end;

function tdbstringlookupstrlb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_text;
end;

{ tdbintegerlookupstrlb }

constructor tdbintegerlookupstrlb.create(aaowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
end;

procedure tdbintegerlookupstrlb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= 0;
 end
 else begin
  with tlookuplbdispfielddatalink(fdatalink) do begin
   fvalue:= flookupbuffer.integervaluephys(flookupvaluefieldno,aindex);
  end;
 end;
end;

function tdbintegerlookupstrlb.lookuptext(const aindex: integer): msestring;
begin
 with tlookuplbdispfielddatalink(fdatalink) do begin
  result:= msestring(intvaluetostr(flookupbuffer.integervaluephys(
                        flookupvaluefieldno,aindex),fbase,fbitcount));
 end;
end;

procedure tdbintegerlookupstrlb.setbase(const avalue: numbasety);
begin
 if fbase <> avalue then begin
  fbase := avalue;
  formatchanged;
 end;
end;

procedure tdbintegerlookupstrlb.setbitcount(const avalue: integer);
begin
 if fbitcount <> avalue then begin
  fbitcount := avalue;
  formatchanged;
 end;
end;

function tdbintegerlookupstrlb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_integer;
end;

{ tdbreallookupstrlb }

constructor tdbreallookupstrlb.create(aowner: tcomponent);
begin
 fvaluerange:= 1;
 inherited;
end;

procedure tdbreallookupstrlb.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

procedure tdbreallookupstrlb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= emptyreal;
 end
 else begin
  with tlookuplbdispfielddatalink(fdatalink) do begin
   fvalue:= reapplyrange(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                     valuerange,valuestart);
  end;
 end;
end;

function tdbreallookupstrlb.lookuptext(const aindex: integer): msestring;
begin
 with tlookuplbdispfielddatalink(fdatalink) do begin
  result:= realtytostr(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                                                   fformat);
 end;
end;

procedure tdbreallookupstrlb.setvaluerange(const avalue: real);
begin
 fvaluerange:= avalue;
 formatchanged;
end;

procedure tdbreallookupstrlb.setvaluestart(const avalue: real);
begin
 fvaluestart:= avalue;
 formatchanged;
end;

procedure tdbreallookupstrlb.readvaluescale(reader: treader);
begin
 valuerange:= valuescaletorange(reader);
end;

procedure tdbreallookupstrlb.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('valuescale',{$ifdef FPC}@{$endif}readvaluescale,nil,false);
end;

function tdbreallookupstrlb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_float;
end;

{ tdatetimelookupstrlb }

procedure tdbdatetimelookupstrlb.setformat(const avalue: msestring);
begin
 format:= avalue;
 formatchanged;
end;

procedure tdbdatetimelookupstrlb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= emptydatetime;
 end
 else begin
  with tlookuplbdispfielddatalink(fdatalink) do begin
   fvalue:= flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex);
  end;
 end;
end;

function tdbdatetimelookupstrlb.lookuptext(const aindex: integer): msestring;
var
 dat1: tdatetime;
begin
 with tlookuplbdispfielddatalink(fdatalink) do begin
  dat1:= flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex);
 end;
 if fkind = dtk_time then begin
  result:= mseformatstr.timetostring(dat1,fformat);
 end
 else begin
  result:= mseformatstr.datetimetostring(dat1,fformat);
 end;
end;

procedure tdbdatetimelookupstrlb.setkind(const avalue: datetimekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  formatchanged;
 end;
end;

function tdbdatetimelookupstrlb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_float;
end;

{ tdblookupdb }
{
constructor tdblookupdb.create(aowner: tcomponent);
begin
 inherited;
end;
}
function tdblookupdb.getdatalink: tlookupdbdispfielddatalink;
begin
 result:= tlookupdbdispfielddatalink(fdatalink);
end;

procedure tdblookupdb.setdatalink(const avalue: tlookupdbdispfielddatalink);
begin
 inherited setdatalink(avalue);
end;

{ tlookupdatalink }

procedure tlookupdatalink.updatefields;
var
 int1: integer;
begin
 inherited;
 fcanlookup:= false;
 if active and (fkeyfieldname <> '') then begin
  fkeyfield:= datasource.dataset.fieldbyname(fkeyfieldname);
  flookupindexnum:= -1;
  if dataset is tmsebufdataset then begin
   with tmsebufdataset(dataset).indexlocal do begin
    for int1:= 0 to count-1 do begin
     with items[int1] do begin
      if (fields.count > 0) and 
             sametext(fields[0].fieldname,fkeyfieldname) then begin
       flookupindexnum:= int1;
       break;
      end;
     end;
    end;
   end;
  end;  
  if flookupindexnum < 0 then begin
   databaseerror(dataset.name+': no loookup index for keyfield "'+
                         fkeyfield.fieldname+'".');
  end;
  fcanlookup:= true;
 end
 else begin
  fkeyfield:= nil;
 end;
end;

procedure tlookupdatalink.activechanged;
begin
 if not active then begin
  fcanlookup:= false;
 end;
 inherited;
 fdisplink.lookupchange;
end;

procedure tlookupdatalink.dataevent(event: tdataevent; info: ptrint);
begin
 inherited;
 if event = tdataevent(de_modified) then begin
  fdisplink.lookupchange;
 end;
end;

procedure tlookupdatalink.fieldchanged;
begin
 inherited;
 fdisplink.lookupchange;
end;

{ tlookupdbdispfielddatalink }

constructor tlookupdbdispfielddatalink.create(
           const aowner: tcustomdataedit; const adatatype: lookupdatatypety;
                                         const intf: idblookupdbdispfieldlink);
begin
 flookupdatalink:= tlookupdatalink.create;
 flookupdatalink.fdisplink:= self;
 inherited create(aowner,adatatype,intf);
end;

destructor tlookupdbdispfielddatalink.destroy;
begin
 flookupdatalink.free;
 inherited;
end;

procedure tlookupdbdispfielddatalink.setlookupkeyfield(const avalue: string);
begin
 with flookupdatalink do begin
  if fkeyfieldname <> avalue then begin
   fkeyfieldname:=  avalue;
   updatefields;
   lookupchange;
  end;
 end;
end;

procedure tlookupdbdispfielddatalink.setlookupvaluefield(const avalue: string);
begin
 flookupdatalink.fieldname:= avalue;
end;

function tlookupdbdispfielddatalink.getlookupkeyfield: string;
begin
 result:= flookupdatalink.fkeyfieldname;
end;

function tlookupdbdispfielddatalink.getlookupvaluefield: string;
begin
 result:= flookupdatalink.fieldname;
end;

function tlookupdbdispfielddatalink.getlookupdatasource: tdatasource;
begin
 result:= flookupdatalink.datasource;
end;

procedure tlookupdbdispfielddatalink.setlookupdatasource(const avalue: tdatasource);
begin
 flookupdatalink.datasource:= avalue;
end;

function tlookupdbdispfielddatalink.getintegerlookupvalue(
                                      const abm: bookmarkdataty): integer;
begin
 result:= 0;
 with flookupdatalink do begin
  if (abm.recordpo <> nil) and fieldactive and fcanlookup then begin
   result:= tmsebufdataset(dataset).currentbmasinteger[field,abm];
  end;
 end;
end;

function tlookupdbdispfielddatalink.getstringlookupvalue(
                                         const abm: bookmarkdataty): msestring;
begin
 result:= '';
 with flookupdatalink do begin
  if (abm.recordpo <> nil) and fieldactive and fcanlookup then begin
   result:= tmsebufdataset(dataset).currentbmasmsestring[field,abm];
  end;
 end;
end;

function tlookupdbdispfielddatalink.getfloatlookupvalue(
                                        const abm: bookmarkdataty): double;
begin
 result:= emptyreal;
 with flookupdatalink do begin
  if (abm.recordpo <> nil) and fieldactive and fcanlookup then begin
   result:= tmsebufdataset(dataset).currentbmasfloat[field,abm];
  end;
 end;
end;

function tlookupdbdispfielddatalink.getdataset(const aindex: integer): tdataset;
begin
 result:= nil;
 case aindex of
  0: begin
   result:= inherited getdataset(aindex);
  end;
  1,2: begin
   result:= flookupdatalink.dataset;
  end;
 end;
end;

procedure tlookupdbdispfielddatalink.getfieldtypes(out apropertynames: stringarty;
               out afieldtypes: fieldtypesarty);
begin
 inherited;
 setlength(apropertynames,3);
 apropertynames[1]:= 'lookupkeyfield';
 apropertynames[2]:= 'lookupvaluefield';
 setlength(afieldtypes,3);
 afieldtypes[1]:= afieldtypes[0]; //same as datafield
 afieldtypes[2]:= idblookupdbdispfieldlink(fintf).getlookupvaluefieldtypes;
end;

{ tdblookup32db }

procedure tdblookup32db.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= int32fields;
end;

function tdblookup32db.createdatalink: tlookupdispfielddatalink;
begin
 result:= tlookup32dbdispfielddatalink.create(self,ldt_int32,
                                          idblookupdbdispfieldlink(self));
end;

{ tdblookup64db }

procedure tdblookup64db.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= int64fields;
end;

function tdblookup64db.createdatalink: tlookupdispfielddatalink;
begin
 result:= tlookup64dbdispfielddatalink.create(self,ldt_int64,
                                          idblookupdbdispfieldlink(self));
end;

{ tdblookupstrdb }

procedure tdblookupstrdb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= charfields;
end;

function tdblookupstrdb.createdatalink: tlookupdispfielddatalink;
begin
 result:= tlookupstrdbdispfielddatalink.create(self,ldt_string,
                                          idblookupdbdispfieldlink(self));
end;

{ tdblookup }

{ tlookup32dbdispfielddatalink }

function tlookup32dbdispfielddatalink.datatotext(const data): msestring;

 procedure lookup(const akey: integer);
 var
  bm1: bookmarkdataty;
 begin
  result:= '';
  with flookupdatalink do begin
   if fcanlookup and (field <> nil) and
     tmsebufdataset(dataset).indexlocal[flookupindexnum].
                         find([akey],[],bm1,false,false,true) then begin
    result:= idblookupdbdispfieldlink(fintf).lookuptext(bm1);
   end;
  end;
 end; //lookup

begin
 result:= '';
 if (@data = nil) and fisnull then begin
 end
 else begin
  if @data = nil then begin
   lookup(fkey);
  end
  else begin
   lookup(integer(data));
  end;
 end;
end;

procedure tlookup32dbdispfielddatalink.updatelookupvalue;
var
 bm1: bookmarkdataty;
begin
 bm1.recordpo:= nil;
 with flookupdatalink do begin
  if fcanlookup then begin
   if not tmsebufdataset(dataset).indexlocal[flookupindexnum].
                              find([fkey],[],bm1,false,false,true) then begin
    bm1.recordpo:= nil;
   end;
  end;
 end;
 idblookupdbdispfieldlink(fintf).setlookupvalue(bm1);
end;

function tlookup32dbdispfielddatalink.getrowdatapo(const alink: tgriddatalink; 
                                                const arow: integer): pointer;
begin
 result:= alink.getintegerbuffer(field,arow);
end;

procedure tlookup32dbdispfielddatalink.fieldtovalue;
begin
 fisnull:= false;
 fkey:= field.asinteger;
end;

{ tlookup64dbdispfielddatalink }

function tlookup64dbdispfielddatalink.datatotext(const data): msestring;

 procedure lookup(const akey: int64);
 var
  bm1: bookmarkdataty;
 begin
  result:= '';
  with flookupdatalink do begin
   if fcanlookup and (field <> nil) and
     tmsebufdataset(dataset).indexlocal[flookupindexnum].
                            find([akey],[],bm1,false,false,true) then begin
    result:= idblookupdbdispfieldlink(fintf).lookuptext(bm1);
   end;
  end;
 end; //lookup
  
begin
 result:= '';
 if (@data = nil) and fisnull then begin
 end
 else begin
  if @data = nil then begin
   lookup(fkey);
  end
  else begin
   lookup(int64(data));
  end;
 end;
end;

procedure tlookup64dbdispfielddatalink.updatelookupvalue;
var
 bm1: bookmarkdataty;
begin
 bm1.recordpo:= nil;
 with flookupdatalink do begin
  if not fisnull and fcanlookup then begin
   if not tmsebufdataset(dataset).indexlocal[flookupindexnum].
                            find([fkey],[],bm1,false,false,true) then begin
    bm1.recordpo:= nil;
   end;
  end;
 end;
 idblookupdbdispfieldlink(fintf).setlookupvalue(bm1);
end;

function tlookup64dbdispfielddatalink.getrowdatapo(const alink: tgriddatalink; 
                                                const arow: integer): pointer;
begin
 result:= alink.getint64buffer(field,arow);
end;

procedure tlookup64dbdispfielddatalink.fieldtovalue;
begin
 fisnull:= false;
 fkey:= field.aslargeint;
end;

{ tlookupstrdbdispfielddatalink }

function tlookupstrdbdispfielddatalink.datatotext(const data): msestring;

 procedure lookup(const akey: msestring);
 var
  bm1: bookmarkdataty;
 begin
  result:= '';
  with flookupdatalink do begin
   if fcanlookup and (field <> nil) and
     tmsebufdataset(dataset).indexlocal[flookupindexnum].
                           find([akey],[],bm1,false,false,true) then begin
    result:= idblookupdbdispfieldlink(fintf).lookuptext(bm1);
   end;
  end;
 end; //lookup
  
begin
 result:= '';
 if (@data = nil) and fisnull then begin
 end
 else begin
  if @data = nil then begin
   lookup(fkey);
  end
  else begin
   lookup(msestring(data));
  end;
 end;
end;

procedure tlookupstrdbdispfielddatalink.updatelookupvalue;
var
 bm1: bookmarkdataty;
begin
 bm1.recordpo:= nil;
 with flookupdatalink do begin
  if not fisnull and fcanlookup then begin
   if not tmsebufdataset(dataset).indexlocal[flookupindexnum].
                          find([fkey],[],bm1,false,false,true) then begin
    bm1.recordpo:= nil;
   end;
  end;
 end;
 idblookupdbdispfieldlink(fintf).setlookupvalue(bm1);
end;

function tlookupstrdbdispfielddatalink.getrowdatapo(const alink: tgriddatalink; 
                                                const arow: integer): pointer;
begin
 result:= alink.getstringbuffer(field,arow);
end;

procedure tlookupstrdbdispfielddatalink.fieldtovalue;
begin
 fisnull:= false;
 fkey:= asmsestring;
end;

{ tlookuplbdispfielddatalink }

constructor tlookuplbdispfielddatalink.create(const aowner: tcustomdataedit;
                           const adatatype: lookupdatatypety;
                                         const intf: idblookuplbdispfieldlink);
begin
 fobjectlinker:= tobjectlinker.create(iobjectlink(self),
                                {$ifdef FPC}@{$endif}objectevent);
 inherited create(aowner,adatatype,intf);
end;

destructor tlookuplbdispfielddatalink.destroy;
begin
 fobjectlinker.free;
 inherited;
end;

function tlookuplbdispfielddatalink.getlbdatakind(const apropname: string): lbdatakindty;
begin
 if apropname = 'lookupkeyfieldno' then begin
  result:= getkeylbdatakind;
 end
 else begin
  result:= idblookuplbdispfieldlink(fintf).getdatalbdatakind;
 end;
end;

function tlookuplbdispfielddatalink.getlookupbuffer: tcustomlookupbuffer;
begin
 result:= flookupbuffer;
end;

procedure tlookuplbdispfielddatalink.setlookupbuffer(const avalue: tcustomlookupbuffer);
begin
 if avalue <> flookupbuffer then begin
  fobjectlinker.setlinkedvar(iobjectlink(self),avalue,
                tmsecomponent(flookupbuffer));
  lookupchange;
 end;
end;

procedure tlookuplbdispfielddatalink.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event in [oe_changed,oe_connect]) and (sender = flookupbuffer) then begin
  lookupchange;
 end;
end;

procedure tlookuplbdispfielddatalink.link(const source: iobjectlink;
               const dest: iobjectlink; valuepo: pointer = nil;
               ainterfacetype: pointer = nil; once: boolean = false);
begin
 fobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tlookuplbdispfielddatalink.unlink(const source: iobjectlink;
               const dest: iobjectlink; valuepo: pointer = nil);
begin
 fobjectlinker.unlink(source,dest,valuepo);
end;

procedure tlookuplbdispfielddatalink.objevent(const sender: iobjectlink;
               const event: objecteventty);
begin
 fobjectlinker.objevent(sender,event);
end;

function tlookuplbdispfielddatalink.getinstance: tobject;
begin
 result:= self;
end;

procedure tlookuplbdispfielddatalink.setlookupkeyfieldno(const avalue: lookupbufferfieldnoty);
begin
 if flookupkeyfieldno <> avalue then begin
  flookupkeyfieldno:= avalue;
  lookupchange;
 end;
end;

procedure tlookuplbdispfielddatalink.setlookupvaluefieldno(const avalue: lookupbufferfieldnoty);
begin
 if flookupvaluefieldno <> avalue then begin
  flookupvaluefieldno:= avalue;
  lookupchange;
 end;
end;

{ tlookup32lbdispfielddatalink }

procedure tlookup32lbdispfielddatalink.updatelookupvalue;
var
 int1: integer;
begin
 int1:= -1;
 if not fisnull and (flookupbuffer <> nil) then begin
  flookupbuffer.findphys(flookupkeyfieldno,fkey,int1);
 end;
 idblookuplbdispfieldlink(fintf).setlookupvalue(int1);
end;

function tlookup32lbdispfielddatalink.datatotext(const data): msestring;

 procedure lookup(const akey: integer);
 var
  int1: integer;
 begin
  result:= '';
  if flookupbuffer <> nil then begin
   if flookupbuffer.findphys(flookupkeyfieldno,akey,int1) then begin
    result:= idblookuplbdispfieldlink(fintf).lookuptext(int1);
   end;
  end;
 end; //lookup
  
begin
 result:= '';
 if (@data = nil) and fisnull then begin
 end
 else begin
  if @data = nil then begin
   lookup(fkey);
  end
  else begin
   lookup(integer(data));
  end;
 end;
end;

function tlookup32lbdispfielddatalink.getkeylbdatakind: lbdatakindty;
begin
 result:= lbdk_integer;
end;

procedure tlookup32lbdispfielddatalink.fieldtovalue;
begin
 fisnull:= false;
 fkey:= field.asinteger;
end;

function tlookup32lbdispfielddatalink.getrowdatapo(const alink: tgriddatalink; 
                                                 const arow: integer): pointer;
begin
 result:= alink.getintegerbuffer(field,arow);
end;

{ tlookup64lbdispfielddatalink }

procedure tlookup64lbdispfielddatalink.updatelookupvalue;
var
 int1: integer;
begin
 int1:= -1;
 if not fisnull and (flookupbuffer <> nil) then begin
  flookupbuffer.findphys(flookupkeyfieldno,fkey,int1);
 end;
 idblookuplbdispfieldlink(fintf).setlookupvalue(int1);
end;

function tlookup64lbdispfielddatalink.datatotext(const data): msestring;

 procedure lookup(const akey: int64);
 var
  int1: integer;
 begin
  result:= '';
  if flookupbuffer <> nil then begin
   if flookupbuffer.findphys(flookupkeyfieldno,akey,int1) then begin
    result:= idblookuplbdispfieldlink(fintf).lookuptext(int1);
   end;
  end;
 end; //lookup
  
begin
 result:= '';
 if (@data = nil) and fisnull then begin
 end
 else begin
  if @data = nil then begin
   lookup(fkey);
  end
  else begin
   lookup(int64(data));
  end;
 end;
end;

function tlookup64lbdispfielddatalink.getkeylbdatakind: lbdatakindty;
begin
 result:= lbdk_int64;
end;

procedure tlookup64lbdispfielddatalink.fieldtovalue;
begin
 fisnull:= false;
 fkey:= field.aslargeint;
end;

function tlookup64lbdispfielddatalink.getrowdatapo(const alink: tgriddatalink; 
                                        const arow: integer): pointer;
begin
 result:= alink.getint64buffer(field,arow);
end;

{ tlookupstrlbdispfielddatalink }

procedure tlookupstrlbdispfielddatalink.updatelookupvalue;
var
 int1: integer;
begin
 int1:= -1;
 if not fisnull and (flookupbuffer <> nil) then begin
  flookupbuffer.findphys(flookupkeyfieldno,fkey,int1,false);
 end;
 idblookuplbdispfieldlink(fintf).setlookupvalue(int1);
end;

function tlookupstrlbdispfielddatalink.datatotext(const data): msestring;

 procedure lookup(const akey: msestring);
 var
  int1: integer;
 begin
  result:= '';
  if flookupbuffer <> nil then begin
   if flookupbuffer.findphys(flookupkeyfieldno,akey,int1,true) then begin
    result:= idblookuplbdispfieldlink(fintf).lookuptext(int1);
   end;
  end;
 end; //lookup
  
begin
 result:= '';
 if (@data = nil) and fisnull then begin
 end
 else begin
  if @data = nil then begin
   lookup(fkey);
  end
  else begin
   lookup(msestring(data));
  end;
 end;
end;

function tlookupstrlbdispfielddatalink.getkeylbdatakind: lbdatakindty;
begin
 result:= lbdk_text;
end;

procedure tlookupstrlbdispfielddatalink.fieldtovalue;
begin
 fisnull:= false;
 fkey:= asmsestring;
end;

function tlookupstrlbdispfielddatalink.getrowdatapo(const alink: tgriddatalink; 
                                                  const arow: integer): pointer;
begin
 result:= alink.getstringbuffer(field,arow);
end;

{ tdblookuplb }

procedure tdblookuplb.readlookupkeyfieldno(reader: treader);
begin
 tlookuplbdispfielddatalink(fdatalink).lookupkeyfieldno:= reader.readinteger;
end;

procedure tdblookuplb.readlookupvaluefieldno(reader: treader);
begin
 tlookuplbdispfielddatalink(fdatalink).lookupvaluefieldno:= reader.readinteger;
end;

procedure tdblookuplb.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('lookupkeyfieldno',
                      {$ifdef FPC}@{$endif}readlookupkeyfieldno,nil,false);
 filer.defineproperty('lookupvaluefieldno',
                      {$ifdef FPC}@{$endif}readlookupvaluefieldno,nil,false);
end;


function tdblookuplb.getlookupbuffer: tcustomlookupbuffer;
begin
 result:= nil;
end;

procedure tdblookuplb.setlookupbuffer(const avalue: tcustomlookupbuffer);
begin
 tlookuplbdispfielddatalink(fdatalink).lookupbuffer:= avalue;
end;

function tdblookuplb.getdatalink: tlookuplbdispfielddatalink;
begin
 result:= tlookuplbdispfielddatalink(fdatalink);
end;

procedure tdblookuplb.setdatalink(const avalue: tlookuplbdispfielddatalink);
begin
 inherited setdatalink(avalue);
end;

end.
