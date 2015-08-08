{ MSEide Copyright (c) 1999-2013 by Martin Schreiber
   
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
unit findinfilepage;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msegui,mseclasses,mseforms,msetabs,msetextedit,msewidgetgrid,msegrids,
 msethreadcomp,findinfileform,msesimplewidgets,msedispwidgets,msestrings,
 classes,mclasses,msestringcontainer;

type 

 tfindinfilepagefo = class(ttabform)
   cancel: tbutton;
   filename: tstringdisp;
   foundcount: tintegerdisp;
   foundlist: ttextedit;
   grid: twidgetgrid;
   again: tbutton;
   thread: tthreadcomp;
   closepage: tstockglyphbutton;
   c: tstringcontainer;
   procedure foundlistoncellevent(const sender: tobject; var info: celleventinfoty);
   procedure threadonexecute(const sender: tthreadcomp);
   procedure threadonstart(const sender: tthreadcomp);
   procedure threadonterminate(const sender: tthreadcomp);
   procedure cancelonexecute(const sender: tobject);
   procedure closebuonexecute(const sender: TObject);
   procedure againonexecute(const sender: TObject);
   procedure childscaled(const sender: TObject);
   procedure formdestroy(const sender: TObject);
  private
   finfo: findinfileinfoty;
   procedure dorun;
  protected
   procedure addfoundline(const text: string; const linenr: integer; col: integer);
   procedure startfile(const afilename: filenamety);
  public
   constructor create(const aowner: tcomponent; 
                     const findinfo: findinfileinfoty); reintroduce;
   procedure cancelsearch;
 end;
 
implementation
uses
 findinfilepage_mfm,sourcepage,sourceform,mseeditglob,sysutils,mserichstring,
 msegraphics,msestream,msefileutils,msesys,findinfiledialogform,msegraphutils,
 projectoptionsform,msesystypes,mseformatstr;

type
 stringconsts = (
  canceled,           //0 *** CANCELED ***
  finished            //1 FINISHED
 );
 
{ tfindinfilepagefo}
 
constructor tfindinfilepagefo.create(const aowner: tcomponent; 
                              const findinfo: findinfileinfoty);
begin
 finfo:= findinfo;
 inherited create(aowner);
 name:= '';
 dorun;
end;

procedure tfindinfilepagefo.foundlistoncellevent(const sender: tobject;
  var info: celleventinfoty);
var
 page: tsourcepage;
begin
 if iscellclick(info,[ccr_dblclick]) then begin
  locateerrormessage(foundlist[info.cell.row],page);
  if page <> nil then begin
   with page.edit do begin
    setselection(editpos,makegridcoord(editpos.col + length(finfo.findinfo.text),
           editpos.row),true);
   end;
  end;
 end;
end;

procedure tfindinfilepagefo.cancelsearch;
begin
 thread.terminate;
 thread.waitfor;
 filename.value:= c[ord(canceled)];
end;

procedure tfindinfilepagefo.startfile(const afilename: filenamety);
begin
 application.lock;
 try
  filename.value:= afilename;
 finally
  application.unlock;
 end;
end;

procedure tfindinfilepagefo.addfoundline(const text: string;
               const linenr: integer; col: integer);
const
 maxfoundpos = 80;
 maxcenteredpos = maxfoundpos div 2;
 maxfoundlength = maxfoundpos + maxcenteredpos;
var
 int1: integer;
 str1,str2: msestring;
begin
 if foundlist <> nil then begin
  application.lock;
  try
   str1:= filename.value+'('+inttostrmse(linenr+1)+','+inttostrmse(col+1)+'): ';
   if col > maxfoundpos then begin
    int1:= col - maxcenteredpos;
    str2:= '...'+msestring(copy(text,int1,maxfoundlength));
    col:= maxcenteredpos + 3;
    if length(text) > length(str2) + int1 - 4 then begin
     str2:= str2 + '...';
    end;
   end
   else begin
    str2:= msestring(copy(text,1,maxfoundlength));
    if length(text) > length(str2) then begin
     str2:= str2 + '...';
    end;
   end;
   int1:= foundlist.appendrow(str1+str2);
   foundcount.value:= foundcount.value + 1;
   updatefontstyle1(foundlist.datalist.richitemspo[int1]^.format,length(str1)+col,
               length(finfo.findinfo.text),fs_bold,true);
  finally
   application.unlock;
  end;
 end;
end;

procedure tfindinfilepagefo.threadonexecute(const sender: tthreadcomp);

 procedure searchstream(const stream: ttextstream; const afilename: filenamety);
 var
  str1: string;
 begin
  case projectoptions.e.encoding of
   1: begin
    stream.encoding:= ce_utf8n;
   end;
   2: begin
    stream.encoding:= ce_iso8859_1;
   end;   
  end;
  with sender,tfindinfilepagefo(datapo),finfo do begin
   stream.buflen:= 4096;
   with stream do begin
    msesearchtext:= findinfo.text;
    searchoptions:= findinfo.options;
    startfile(afilename);
    while searchnext and not terminated do begin
     Position:= searchlinestartpos;
     readln(str1);
     addfoundline(str1,searchlinenumber,searchfoundpos-searchlinestartpos);
    end;
   end;
  end;
 end;

 procedure searchdirectory(const adir: filenamety);
 var
  stream1: ttextstream;
  filelist: tfiledatalist;
  int1,int2: integer;
  ar1: filenamearty;
 begin
  with sender,tfindinfilepagefo(datapo),finfo do begin
   filelist:= tfiledatalist.create;
   filelist.options:= [flo_sortname];
   try
    unquotefilename(adir,ar1);
    for int2:= 0 to high(ar1) do begin
     ar1[int2]:= filepath(ar1[int2],fk_file);
     if fifo_subdirs in options then begin
     {$ifndef FPC}
      if filelist.adddirectory2(ar1[int2],fil_ext1,'',
                              [fa_dir],[],[],nil,true) then begin
     {$else}
      if filelist.adddirectory(ar1[int2],fil_ext1,'',
                              [fa_dir],[],[],nil,true) then begin
     {$endif}
       for int1:= 0 to filelist.count - 1 do begin
        if terminated then begin
         break;
        end;
        with filelist[int1] do begin
         searchdirectory(ar1[int2]+'/'+ name);
        end;
       end;
      end;
     end;
     filelist.clear;
    {$ifndef FPC}
     if filelist.adddirectory2(ar1[int2],fil_ext1,filemask,
                                [fa_all],[fa_dir],[],nil,true) then begin
    {$else}
     if filelist.adddirectory(ar1[int2],fil_ext1,filemask,
                                [fa_all],[fa_dir],[],nil,true) then begin
    {$endif}
      for int1:= 0 to filelist.count - 1 do begin
       if terminated then begin
        break;
       end;
       with filelist[int1] do begin
        try
         if ttextstream.trycreate(
                  stream1,ar1[int2]+'/'+name,fm_read) = sye_ok then begin
          try
           searchstream(stream1,stream1.filename);
          finally
           stream1.free;
          end;
         end;
        except
        end;
       end;
      end;
     end;
    end;
   finally
    filelist.Free;
   end;
  end;
 end; //searchdirectory

var
 int1: integer;
 stream1: ttextstream;
 bo1: boolean;
 mstr1: filenamety;
  
begin
 if finfo.source = fs_inopenfiles then begin
  int1:= 0;
  with sender,tfindinfilepagefo(datapo),finfo do begin
   while not terminated do begin
    bo1:= false;
    application.lock;
    try
     if int1 < sourcefo.count then begin
      with sourcefo.items[int1] do begin
       if fileloaded then begin
        stream1:= ttextstream.create; //memorystream
        edit.savetostream(stream1,false);        
       end
       else begin
        stream1:= ttextstream.create(filepath);
       end;
       application.unlock;
       bo1:= true;
       try
        searchstream(stream1,filepath);
       finally
        stream1.free;
       end;
      end;
     end
     else begin
      break;
     end;
    finally
     if not bo1 then begin
      application.unlock;
     end;
    end;
    inc(int1);
   end;
  end;
 end
 else begin
  mstr1:= tfindinfilepagefo(sender.datapo).finfo.directory;
  application.lock;
  expandprmacros1(mstr1);
  application.unlock;
  searchdirectory(mstr1);
 end;
end;

procedure tfindinfilepagefo.threadonstart(const sender: tthreadcomp);
begin
 cancel.enabled:= true;
 again.enabled:= false;
end;

procedure tfindinfilepagefo.threadonterminate(const sender: tthreadcomp);
begin
 if not application.terminated then begin
  cancel.enabled:= false;
  again.enabled:= true;
  filename.value:= c[ord(finished)];
 end;
end;

procedure tfindinfilepagefo.childscaled(const sender: TObject);
begin
 placeyorder(0,[1],[cancel,grid],0);
 aligny(wam_center,[cancel,filename,foundcount,again,closepage]);
end;

procedure tfindinfilepagefo.closebuonexecute(const sender: TObject);
begin
 release;
end;

procedure tfindinfilepagefo.cancelonexecute(const sender: tobject);
begin
 cancelsearch;
end;

procedure tfindinfilepagefo.dorun;
begin 
 caption:= finfo.findinfo.text;
 foundlist.clear;
 foundcount.value:= 0;
 thread.run(self);
end;

procedure tfindinfilepagefo.againonexecute(const sender: TObject);
begin
 findinfilefo.show;
 if findinfiledialogexecute(finfo,true) then begin
  dorun;
 end;
end;

procedure tfindinfilepagefo.formdestroy(const sender: TObject);
begin
 thread.terminate;
 thread.waitfor;
end;

end.
