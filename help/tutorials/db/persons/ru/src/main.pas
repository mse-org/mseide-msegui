unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msepqconnection,msesqldb,msedb,msedbedit,mseactions,
 msesimplewidgets,msemenus,db,msegrids,planetseditform,continentseditform,
 countrieseditform,featureseditform, occupationseditform;
 
type
 tmainfo = class(tmseform)
   dsPersons: tmsedatasource;
   conn: tmsepqconnection;
   qryPersons: tmsesqlquery;
   actExit: taction;
   btnExit: tbutton;
   grdPersons: tdbstringgrid;
   mnuMain: tmainmenu;
   btnEdit: tbutton;
   btnAdd: tbutton;
   btnDelete: tbutton;
   actEdit: taction;
   actAdd: taction;
   actDelete: taction;
   ftMainMenuItem: tframecomp;
   fldName1: tmsestringfield;
   fldCountry1: tmsestringfield;
   fldOccupation1: tmsestringfield;
   fldFeature1: tmsestringfield;
   fldSexPotention: tmsefloatfield;
   fldHappy: tmsebooleanfield;
   fldCountryId: tmselongintfield;
   fldOccupationId: tmselongintfield;
   fldFeatureId: tmselongintfield;
   pupPersons: tpopupmenu;
   fldPersonId: tmselongintfield;
   fldDateOfBirth: tmsedatefield;
   ftButtons: tframecomp;
   actPlanetsEdit: taction;
   actContinentsEdit: taction;
   actCountriesEdit: taction;
   actFeaturesEdit: taction;
   actOccupationsEdit: taction;
   actShowAbout: taction;
   ftMainMenuPopupItem: tframecomp;
   fldName: tmsememofield;
   fldCountry: tmsememofield;
   fldOccupation: tmsememofield;
   fldFeature: tmsememofield;
   trans: tmsesqltransaction;
   procedure appexit(const sender: TObject);
   procedure editformshow(const sender: TObject);
   procedure addformshow(const sender: TObject);
   procedure deleterecord(const sender: TObject);
   procedure personsupdate(const sender: tmsesqlquery;
                   const updatekind: TUpdateKind; var asql: AnsiString;
                   var done: Boolean);
   procedure shownamehint(const sender: tdatacol; const arow: Integer;
                   var info: hintinfoty);
   procedure personsevent(const sender: TObject; var info: celleventinfoty);
   procedure planetseditexecute(const sender: TObject);
   procedure continentseditexecute(const sender: TObject);
   procedure countrieseditexecute(const sender: TObject);
   procedure featureseditexecute(const sender: TObject);
   procedure occupationseditexecute(const sender: TObject);
   procedure showaboutexecute(const sender: TObject);
 end;
var
 mainfo: tmainfo;

implementation
uses
  main_mfm,
  editform,
  msewidgets, // for askyesno,
  msestrings
;

var
  prevkey: integer;

procedure tmainfo.appexit(const sender: TObject);
begin
  application.terminated:= true;
end;

procedure tmainfo.editformshow (const sender: TObject);
begin
  try
    with qryPersons do begin
      prevkey:= fldPersonId.asinteger; 
      edit;
      application.createform(teditfo,editfo);
      editfo.caption:= ' Editing a person => '+ fldName.asstring;
     
      case editfo.show(true) of 
        mr_ok: begin
          applyupdates; 
		  trans.commit; 
		  active:= true;
		  locate(prevkey, fldPersonId);
        end else begin
          cancel;
        end;
      end;
      
    end;
  finally
    editfo.free;
  end;
end;

procedure tmainfo.addformshow(const sender: TObject);
begin
  try
    with qryPersons do begin
      prevkey:= fldPersonId.asinteger;  
      append;
      application.createform(teditfo,editfo);
      editfo.caption:= ' Adding a new person';

      case editfo.show(true) of 
        mr_ok: begin
          applyupdates; 
		  trans.commit; 
		  active:= true;
		  last;
        end else begin
          cancel;
          locate(prevkey, fldPersonId);  
        end;
      end;
      
    end;
  finally
    editfo.free;
  end;
end;

procedure tmainfo.deleterecord(const sender: TObject);
var
  recnum: integer;
begin
  if askyesno('Are you a nut ???','Deletion request',mr_no,200) then begin
    with qryPersons do begin
      recnum:= recno;
      delete; 
      applyupdates; 
      trans.commit; 
      active:= true;

      if recnum > 0 then
      	recnum:= recnum - 1;
      
      recno:= recnum; // 1 upper is now the new position
    end;
  end;
end;

procedure tmainfo.personsupdate(const sender: tmsesqlquery;
               const updatekind: TUpdateKind; var asql: AnsiString;
               var done: Boolean);
begin
  with qryPersons do begin

    case updatekind of
  
      ukModify: begin
        asql:= 'update persons set '+
          'descr=' + fldName.assql +
          ',country_id=' +  fldCountryId.assql +
          ',feature_id=' + fldFeatureId.assql +
          ',occupation_id=' + fldOccupationId.assql +
          ',sexual_potention=' + fldSexPotention.assql +
          ',if_happy=' + fldHappy.assql + 
          ',dateofbirth=' + fldDateOfBirth.assql + 
          ' where id='+ fldPersonId.assql + ';';
      end;
  
      ukInsert: begin
        asql:= 'insert into persons (' +
                 'id' +
                 ',descr' +
                 ',country_id' +
                 ',feature_id' +
                 ',occupation_id' +
                 ',sexual_potention' +
                 ',if_happy' +
                 ',dateofbirth' + 
               ') values (' + 
                 'nextval('+ #39 + 'person_id_seq' + #39 + ')' +
                 ',' + fldName.assql +
                 ',' + fldCountryId.assql +
                 ',' + fldFeatureId.assql +
                 ',' + fldOccupationId.assql +
                 ',' + fldSexPotention.assql + 
                 ',' + fldHappy.assql + 
                 ',' + fldDateOfBirth.assql + 
               ')';
      end;
  
      ukDelete: begin
        asql:= 'delete from persons where id=' + fldPersonId.assql;
      end;
      
    end;

  end;
end;

procedure tmainfo.shownamehint(const sender: tdatacol; const arow: Integer;
               var info: hintinfoty);
begin
 info.caption:= grdPersons[sender.colindex][arow];
end;


procedure tmainfo.personsevent(const sender: TObject;
               var info: celleventinfoty);
begin
  if iscellclick(info,[ccr_dblclick]) then begin
   actEdit.execute;
  end;
end;

procedure tmainfo.planetseditexecute(const sender: TObject);
begin
  try
    application.createform(tplanetseditfo, planetseditfo);
    if planetseditfo.show(true) = mr_windowclosed then begin
      qryPersons.active:= true;
    end;
  finally
    planetseditfo.free;
  end;
end;

procedure tmainfo.continentseditexecute(const sender: TObject);
begin
  try
    application.createform(tcontinentseditfo, continentseditfo);
    if continentseditfo.show(true) = mr_windowclosed then begin
      qryPersons.active:= true;
    end;
  finally
    continentseditfo.free;
  end;
end;

procedure tmainfo.countrieseditexecute(const sender: TObject);
begin
  try
    application.createform(tcountrieseditfo, countrieseditfo);
    if countrieseditfo.show(true) = mr_windowclosed then begin
      qryPersons.active:= true;
    end;
  finally
    countrieseditfo.free;
  end;
end;

procedure tmainfo.featureseditexecute(const sender: TObject);
begin
  try
    application.createform(tfeatureseditfo, featureseditfo);
    if featureseditfo.show(true) = mr_windowclosed then begin
      qryPersons.active:= true;
    end;
  finally
    featureseditfo.free;
  end;
end;

procedure tmainfo.occupationseditexecute(const sender: TObject);
begin
  try
    application.createform(toccupationseditfo, occupationseditfo);
    if occupationseditfo.show(true) = mr_windowclosed then begin
      qryPersons.active:= true;
    end;
  finally
    occupationseditfo.free;
  end;
end;

procedure tmainfo.showaboutexecute(const sender: TObject);
begin
  showmessage(
    lineend +
    'The Galaxy Data Keeper'+ #174 +
    lineend + lineend + 
    'This extremely useful program is designed' + lineend +
    'for keeping data on creatures widely-known' + lineend + 
    'in our galaxy.' + lineend +
    lineend + 
    'Authors:' + lineend +
    lineend +
    '  Bill Mad,' + lineend +
    '  Susan Bitch,' + lineend +
    '  Freddie Krugger' + lineend +
    lineend +
    '2006, Almalyk city, UZ'+ lineend,
    'About program',
    [mr_ok],
    mr_ok,
    [],
    150
  );
end;

end.
