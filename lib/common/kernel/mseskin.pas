{ MSEgui Copyright (c) 2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseskin;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseclasses,msegui,msescrollbar,mseedit;
type
 beforeskinupdateeventty = procedure(const sender: tobject; 
                const ainfo: skininfoty; var handled: boolean) of object;

 scrollbarskininfoty = record
  facebu: tfacecomp;
  faceendbu: tfacecomp;
  framebu: tframecomp;
  frameendbu1: tframecomp;
  frameendbu2: tframecomp;
 end;
 widgetskininfoty = record
  fa: tfacecomp;
  fra: tframecomp;
 end;
 buttonskininfoty = record
  wi: widgetskininfoty;
 end;  
 framebuttonskininfoty = record
  fa: tfacecomp;
  fra: tframecomp;
 end;
 tcustomskincontroller = class(tmsecomponent)
  private
   fonbeforeupdate: beforeskinupdateeventty;
   fonafterupdate: skinobjecteventty;
   factive: boolean;
   procedure setactive(const avalue: boolean);
  protected
   procedure setwidgetskin(const instance: twidget;
                                            const awsinfo: widgetskininfoty);
   procedure setscrollbarskin(const instance: tcustomscrollbar; 
                const asbinfo: scrollbarskininfoty);
   procedure setframebuttonskin(const instance: tframebutton;
                const afbuinfo: framebuttonskininfoty);
   procedure handlewidget(const sender: twidget; const ainfo: skininfoty); virtual;
   procedure handlesimplebutton(const sender: twidget; const ainfo: skininfoty); virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure updateskin(const instance: tobject; const ainfo: skininfoty);
  published
   property active: boolean read factive write setactive;
   property onbeforeupdate: beforeskinupdateeventty read fonbeforeupdate
                                 write fonbeforeupdate;
   property onafterupdate: skinobjecteventty read fonafterupdate
                                 write fonafterupdate;
 end;

 tskincontroller = class(tcustomskincontroller)
  private
   fsb_horz: scrollbarskininfoty;
   fsb_vert: scrollbarskininfoty;
   fbutton: buttonskininfoty;
   fframebutton: framebuttonskininfoty;
   procedure setsb_vert_facebutton(const avalue: tfacecomp);
   procedure setsb_vert_faceendbutton(const avalue: tfacecomp);
   procedure setsb_vert_framebutton(const avalue: tframecomp);
   procedure setsb_vert_frameendbutton1(const avalue: tframecomp);
   procedure setsb_vert_frameendbutton2(const avalue: tframecomp);
   procedure setsb_horz_facebutton(const avalue: tfacecomp);
   procedure setsb_horz_faceendbutton(const avalue: tfacecomp);
   procedure setsb_horz_framebutton(const avalue: tframecomp);
   procedure setsb_horz_frameendbutton1(const avalue: tframecomp);
   procedure setsb_horz_frameendbutton2(const avalue: tframecomp);
   procedure setbutton_face(const avalue: tfacecomp);
   procedure setbutton_frame(const avalue: tframecomp);
   procedure setframebutton_face(const avalue: tfacecomp);
   procedure setframebutton_frame(const avalue: tframecomp);
  protected
   procedure handlewidget(const sender: twidget; const ainfo: skininfoty); override;
   procedure handlesimplebutton(const sender: twidget; const ainfo: skininfoty); override;
  published
   property sb_horz_facebutton: tfacecomp read fsb_horz.facebu 
                        write setsb_horz_facebutton;
   property sb_horz_faceendbutton: tfacecomp read fsb_horz.faceendbu 
                        write setsb_horz_faceendbutton;
   property sb_horz_framebutton: tframecomp read fsb_horz.framebu 
                        write setsb_horz_framebutton;
   property sb_horz_frameendbutton1: tframecomp read fsb_horz.frameendbu1 
                        write setsb_horz_frameendbutton1;
   property sb_horz_frameendbutton2: tframecomp read fsb_horz.frameendbu2
                        write setsb_horz_frameendbutton2;
   property sb_vert_facebutton: tfacecomp read fsb_vert.facebu
                        write setsb_vert_facebutton;
   property sb_vert_faceendbutton: tfacecomp read fsb_vert.faceendbu 
                        write setsb_vert_faceendbutton;
   property sb_vert_framebutton: tframecomp read fsb_vert.framebu 
                        write setsb_vert_framebutton;
   property sb_vert_frameendbutton1: tframecomp read fsb_vert.frameendbu1 
                        write setsb_vert_frameendbutton1;
   property sb_vert_frameendbutton2: tframecomp read fsb_vert.frameendbu2 
                        write setsb_vert_frameendbutton2;
   property button_face: tfacecomp read fbutton.wi.fa write setbutton_face;
   property button_frame: tframecomp read fbutton.wi.fra write setbutton_frame;
   property framebutton_face: tfacecomp read fframebutton.fa 
                                              write setframebutton_face;
   property framebutton_frame: tframecomp read fframebutton.fra 
                                              write setframebutton_frame;
 end;
  
implementation
uses
 msewidgets;
 
{ tcustomskincontroller }

constructor tcustomskincontroller.create(aowner: tcomponent);
begin
 inherited;
end;

destructor tcustomskincontroller.destroy;
begin
 active:= false;
 inherited;
end;

procedure tcustomskincontroller.setactive(const avalue: boolean);
{$ifndef FPC}
var
 meth1: skinobjecteventty;
{$endif}
begin
 factive:= avalue;
 if not (csdesigning in componentstate) then begin
  if avalue then begin
   oninitskinobject:= {$ifdef FPC}@{$endif}updateskin;
  end
  else begin
  {$ifdef FPC}
   if oninitskinobject = @updateskin then begin
   {$else}
   meth1:= updateskin;
   if (tmethod(oninitskinobject).code = tmethod(meth1).code) and
                 (tmethod(oninitskinobject).code = tmethod(meth1).code) then begin
   {$endif}
    oninitskinobject:= nil;
   end;
  end;
 end;
end;

procedure tcustomskincontroller.updateskin(const instance: tobject;
               const ainfo: skininfoty);
var
 bo1: boolean;
begin
 if factive then begin
  bo1:= false;
  if assigned(fonbeforeupdate) then begin
   fonbeforeupdate(instance,ainfo,bo1);
  end;
  if not bo1 then begin
   case ainfo.objectkind of 
    sok_widget: handlewidget(twidget(instance),ainfo);
    sok_simplebutton: handlesimplebutton(tactionsimplebutton(instance),ainfo);
   end;
  end;
  if assigned(fonafterupdate) then begin
   fonafterupdate(instance,ainfo);
  end;
 end;
end;

procedure tcustomskincontroller.handlewidget(const sender: twidget;
               const ainfo: skininfoty);
begin
 //dummy
end;

procedure tcustomskincontroller.setwidgetskin(const instance: twidget;
               const awsinfo: widgetskininfoty);
begin
 with instance,awsinfo do begin
  if (fa <> nil) and (face = nil) then begin
   createface;
   face.template:= fa;
  end;
  if (fra <> nil) and (frame = nil) then begin
   createframe;
   frame.template:= fra;
  end;
 end;
end;

procedure tcustomskincontroller.setframebuttonskin(const instance: tframebutton;
               const afbuinfo: framebuttonskininfoty);
begin
 with instance,afbuinfo do begin
  if (fa <> nil) and (face = nil) then begin
   createface;
   face.template:= fa;
  end;
  if (fra <> nil) and (frame = nil) then begin
   createframe;
   frame.template:= fra;
  end;
 end;
end;

procedure tcustomskincontroller.setscrollbarskin(const instance: tcustomscrollbar;
               const asbinfo: scrollbarskininfoty);
begin
 with instance,asbinfo do begin
  if (facebu <> nil) and (facebutton = nil) then begin
   createfacebutton;
   facebutton.template:= facebu;
  end;
  if (faceendbu <> nil) and (faceendbutton = nil) then begin
   createfaceendbutton;
   faceendbutton.template:= faceendbu;
  end;
  if (framebu <> nil) and (framebutton = nil) then begin
   createframebutton;
   framebutton.template:= framebu;
  end;
  if (frameendbu1 <> nil) and (frameendbutton1 = nil) then begin
   createframeendbutton1;
   frameendbutton1.template:= frameendbu1;
  end;
  if (frameendbu2 <> nil) and (frameendbutton2 = nil) then begin
   createframeendbutton2;
   frameendbutton2.template:= frameendbu2;
  end;
 end;
end;

procedure tcustomskincontroller.handlesimplebutton(const sender: twidget;
               const ainfo: skininfoty);
begin
 //dummy
end;

{ tskincontroller }

procedure tskincontroller.setsb_vert_facebutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.facebu));
end;

procedure tskincontroller.setsb_vert_faceendbutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.faceendbu));
end;

procedure tskincontroller.setsb_vert_framebutton(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.framebu));
end;

procedure tskincontroller.setsb_vert_frameendbutton1(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.frameendbu1));
end;

procedure tskincontroller.setsb_vert_frameendbutton2(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_vert.frameendbu2));
end;

procedure tskincontroller.setsb_horz_facebutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.facebu));
end;

procedure tskincontroller.setsb_horz_faceendbutton(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.faceendbu));
end;

procedure tskincontroller.setsb_horz_framebutton(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.framebu));
end;

procedure tskincontroller.setsb_horz_frameendbutton1(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.frameendbu1));
end;

procedure tskincontroller.setsb_horz_frameendbutton2(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fsb_horz.frameendbu2));
end;

procedure tskincontroller.setbutton_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fbutton.wi.fa));
end;

procedure tskincontroller.setbutton_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fbutton.wi.fra));
end;

procedure tskincontroller.setframebutton_face(const avalue: tfacecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fframebutton.fa));
end;

procedure tskincontroller.setframebutton_frame(const avalue: tframecomp);
begin
 setlinkedvar(avalue,tmsecomponent(fframebutton.fra));
end;

procedure tskincontroller.handlewidget(const sender: twidget;
               const ainfo: skininfoty);
var
 int1: integer;
begin
 if sender.frame <> nil then begin
  if sender.frame is tcustomscrollframe then begin
   setscrollbarskin(tcustomscrollframe(sender.frame).sbvert,fsb_vert);
   setscrollbarskin(tcustomscrollframe(sender.frame).sbhorz,fsb_horz);
  end
  else begin
   if sender.frame is tcustombuttonframe then begin
    with tcustombuttonframe(sender.frame) do begin
     for int1:= 0 to buttons.count - 1 do begin
      setframebuttonskin(buttons[int1],fframebutton);
     end;
    end;
   end;
  end; 
 end;
end;

procedure tskincontroller.handlesimplebutton(const sender: twidget;
               const ainfo: skininfoty);
begin
 setwidgetskin(sender,fbutton.wi)
end;

end.
