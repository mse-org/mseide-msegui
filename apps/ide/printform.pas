unit printform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msesimplewidgets,msepostscriptprinter,mseprinter,
 msedataedits,msethreadcomp,msegraphedits,msestrings,msegraphics,msestat,
 msestatfile,msetypes,mseglob,msestringcontainer;

type
 tprintfo = class(tmseform)
   ok: tbutton;
   cancel: tbutton;
   printer: tpostscriptprinter;
   linenum: tbooleanedit;
   fontsize: trealedit;
   colorset: tbooleanedit;
   rotate: tbooleanedit;
   titlefont: tstringedit;
   sourcefont: tstringedit;
   tpageorientationselector1: tpageorientationselector;
   tpagesizeselector1: tpagesizeselector;
   tstatfile1: tstatfile;
   pages: tstringedit;
   c: tstringcontainer;
   procedure pronpagestart(const sender: tcustomprinter);
   procedure printidle(var again: Boolean);
   procedure runonexecute(const sender: TObject);
   procedure cancelexec(const sender: TObject);
   procedure sourcefosetvalue(const sender: TObject; var avalue: msestring;
                  var accept: Boolean);
   procedure titlefosetvalue(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure pagessetvalue(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
  protected
   run,started: boolean;
   rowindex: integer;
   font1: tfont;
 end;
 
procedure print;

implementation
uses
 printform_mfm,main,sourceform,msestream,msesys,msegraphutils,msedrawtext,
 msesettings,msereal,msewidgets,sysutils,projectoptionsform,mserichstring,
 mseguiglob;
type
 stringconsts = (
  page,           //0 Page
  wishcancel      //1 Do you wish to cancel printing?
 );
 
procedure tprintfo.printidle(var again: Boolean);
begin
 try
  with printer,canvas do begin
   if run then begin
    if not started then begin
     pagesstring:= self.pages.value;
     started:= true;
     beginprint(getprintcommand);
     if colorset.value then begin
      colorspace:= cos_rgb;
     end
     else begin
      colorspace:= cos_gray;
     end;
     if rotate.value then begin
      printorientation:= pao_landscape;
     end
     else begin
      printorientation:= pao_portrait;
     end;      
     font.name:= sourcefont.value;
     font.height:= round(fontsize.value);
     headerheight:= round(fontsize.value*5/3);
     if linenum.value then begin
      indentx:= round(4*fontsize.value);
     end;
     font1.assign(font);
     font1.name:= titlefont.value;
    end;
    with sourcefo.activepage.edit do begin
     if rowindex >= datalist.count then begin
      run:= false;
      self.window.modalresult:= mr_ok;
     end
     else begin
      if linenum.value then begin
       drawtext(inttostr(linenumber+1),makerect(0,liney,round(3*fontsize.value),0),
                             [tf_right],font1);
      end;
      writeln(expandtabs(richlines[rowindex],projectoptions.e.tabstops));
      inc(rowindex);
      again:= true;
     end;
    end;
   end;
  end;
 except
  run:= false;
  window.modalresult:= mr_exception;
  raise;
 end;
end;

procedure print;
var
 fo1: tprintfo;
begin
 fo1:= tprintfo.create(nil);
 fo1.font1:= tfont.create;
 try
  fo1.show(true);
 finally
  fo1.font1.free;
  fo1.free;
 end;
end;

procedure tprintfo.pronpagestart(const sender: tcustomprinter);
begin
 with sender.canvas do begin
  save;
  font.name:= titlefont.value;
  drawtext(sourcefo.activepage.filepath,makerect(0,0,clientsize.cx-
                          round(10*fontsize.value),0),[tf_ellipseleft]);
  drawtext(c[ord(page)]+' '+inttostr(pagenumber+1),
                 makerect(clientsize.cx,0,0,0),[tf_right]);
  restore;
 end;
end;

procedure tprintfo.runonexecute(const sender: TObject);
begin
 if window.candefocus then begin
  run:= true;
  ok.enabled:= false;
 end;
end;

procedure tprintfo.cancelexec(const sender: TObject);
begin
 if run then begin
  if askyesno(c[ord(wishcancel)]) then begin
   run:= false;
   window.modalresult:= mr_cancel;
  end;
 end
 else begin
  window.modalresult:= mr_cancel;
 end;
end;

procedure tprintfo.sourcefosetvalue(const sender: TObject; var avalue: msestring;
        var accept: Boolean);
begin
 if avalue = '' then begin
  avalue:= defaultsourceprintfont;
 end;
end;

procedure tprintfo.titlefosetvalue(const sender: TObject; var avalue: msestring;
           var accept: Boolean);
begin
 if avalue = '' then begin
  avalue:= defaulttitleprintfont;
 end;
end;

procedure tprintfo.pagessetvalue(const sender: TObject; var avalue: msestring;
               var accept: Boolean);
begin
 stringtopages(avalue);
end;

end.
