unit findmessage;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
 msetypes,msegrids,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,
 msemenus,msegui,msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,
 mseforms,msesimplewidgets,mseact,msedataedits,msedropdownlist,mseedit,
 mseificomp,mseificompglob,mseifiglob,msestatfile,msestream,SysUtils,
 msegraphedits,msescrollbar;

type
  tfindmessagefo = class(tmseform)
    tbutton3: TButton;
    tbutton2: TButton;
    findtext: thistoryedit;
    casesensitive: tbooleanedit;
    tbutton4: TButton;
    tbutton5: TButton;
   copytoclip: tbooleanedit;
    procedure onfindnext(const Sender: TObject);
    procedure onexit(const Sender: TObject);
    procedure onreset(const Sender: TObject);
    procedure onfindall(const Sender: TObject);
   procedure onclose(const sender: TObject);
  end;

var
  findmessagefo: tfindmessagefo;
  imessages: integer = 0;

implementation

uses
  messageform,
  findmessage_mfm;

procedure tfindmessagefo.onfindnext(const Sender: TObject);
var
  found: Boolean = False;
  gridcoo: gridcoordty;
begin

  gridcoo.col := 0;
  gridcoo.row := 0;

  if findtext.Value <> '' then
  begin
    while (imessages < messagefo.Messages.rowcount) and (found = False) do
    begin
      if not casesensitive.Value then
      begin
        if system.pos(lowercase(findtext.Value), lowercase(messagefo.Messages[0][imessages])) > 0 then
        begin
          found       := True;
          gridcoo.row := imessages;
        end;
      end
      else if system.pos(findtext.Value, messagefo.Messages[0][imessages]) > 0 then
      begin
        found       := True;
        gridcoo.row := imessages;
      end;

      Inc(imessages);
    end;

    if found then
      messagefo.Messages.selectcell(gridcoo, csm_select, False)
    else
      showerror('        ' + findtext.Value + ' not found.' + '        ', 'Warning');
  end;
  //close;
end;

procedure tfindmessagefo.onexit(const Sender: TObject);
begin
   Close;
end;

procedure tfindmessagefo.onreset(const Sender: TObject);
begin
  imessages := 0;
  messagefo.Messages.defocuscell;
  messagefo.Messages.datacols.clearselection;
end;

procedure tfindmessagefo.onfindall(const Sender: TObject);
var
  found: Boolean = False;
  gridcoo: gridcoordty;
begin

  onreset(Sender);
  gridcoo.col := 0;
  gridcoo.row := 0;

  if findtext.Value <> '' then
  begin
    while (imessages < messagefo.Messages.rowcount) do
    begin
      if not casesensitive.Value then
      begin
        if system.pos(lowercase(findtext.Value), lowercase(messagefo.Messages[0][imessages])) > 0 then
        begin
          found       := True;
          gridcoo.row := imessages;
          messagefo.Messages.selectcell(gridcoo, csm_select, False);
        end;
      end
      else if system.pos(findtext.Value, messagefo.Messages[0][imessages]) > 0 then
      begin
        found       := True;
        gridcoo.row := imessages;
        messagefo.Messages.selectcell(gridcoo, csm_select, False);
      end;

      Inc(imessages);
    end;

    if not found then
      showerror('        ' + findtext.Value + ' not found.' + '        ', 'Warning');
  end;

end;

procedure tfindmessagefo.onclose(const sender: TObject);
begin
  imessages := 0;
 if copytoclip.value then messagefo.messages.copyselection;
end;

end.

