{ MSEide Copyright (c) 1999-2006 by Martin Schreiber
   
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
 msegui,mseclasses,mseforms,msetabs,msetextedit,msewidgetgrid,msegrids,msethreadcomp,
 findinfileform,msesimplewidgets,msedispwidgets,msestrings,classes;

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
   procedure foundlistoncellevent(const sender: tobject; var info: celleventinfoty);
   procedure threadonexecute(const sender: tthreadcomp);
   procedure threadonstart(const sender: tthreadcomp);
   procedure threadonterminate(const sender: tthreadcomp);
   procedure cancelonexecute(const sender: tobject);
   procedure closebuonexecute(const sender: TObject);
   procedure againonexecute(const sender: TObject);
   procedure childscaled(const sender: TObject);
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
 msegraphics,msestream,msefileutils,msesys,findinfiledialogform,msegraphutils;
 
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
 filename.value:= '*** CANCELED ***';
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
 str1,str2: string;
begin
 if foundlist <> nil then begin
  application.lock;
  try
   str1:= filename.value+'('+inttostr(linenr+1)+','+inttostr(col+1)+'): ';
   if col > maxfoundpos then begin
    int1:= col - maxcenteredpos;
    str2:= '...'+copy(text,int1,maxfoundlength);
    col:= maxcenteredpos + 3;
    if length(text) > length(str2) + int1 - 4 then begin
     str2:= str2 + '...';
    end;
   end
   else begin
    str2:= copy(text,1,maxfoundlength);
    if length(text) > length(str2) then begin
     str2:= str2 + '...';
    end;
   end;
   int1:= foundlist.appendrow(str1+str2);
   foundcount.value:= foundcount.value + 1;
   updatefontstyle(foundlist.datalist.richitemspo[int1]^.format,length(str1)+col,
               length(finfo.findinfo.text),fs_bold,true);
  finally
   application.unlock;
  end;
 end;
end;

procedure tfindinfilepagefo.threadonexecute(const sender: tthreadcomp);

 procedure searchdirectory(const dir: filenamety);
 var
  stream: ttextstream;
  filelist: tfiledatalist;
  int1: integer;
  str1: string;
 begin
  with sender,tfindinfilepagefo(datapo),finfo do begin
   filelist:= tfiledatalist.create;
   filelist.options:= [flo_sortname];
   try
    if fifo_subdirs in options then begin
     filelist.adddirectory(dir,fil_ext1,'',[fa_dir]);
     for int1:= 0 to filelist.count - 1 do begin
      if terminated then begin
       break;
      end;
      with filelist[int1] do begin
       searchdirectory(dir+'/'+ name);
      end;
     end;
    end;
    filelist.clear;
    filelist.adddirectory(dir,fil_ext1,filemask,[fa_all],[fa_dir]);
    for int1:= 0 to filelist.count - 1 do begin
     if terminated then begin
      break;
     end;
     with filelist[int1] do begin
      try
       stream:= ttextstream.create(dir+'/'+name,fm_read);
       try
//        stream.buflen:= 1024;
        stream.buflen:= 4096;
        with stream do begin
         msesearchtext:= findinfo.text;
         searchoptions:= findinfo.options;
         startfile(filename);
         while searchnext and not terminated do begin
          Position:= searchlinestartpos;
          readln(str1);
          addfoundline(str1,searchlinenumber,searchfoundpos-searchlinestartpos);
         end;
        end;
       finally
        stream.free;
       end;
      except
      end;
     end;
    end;
   finally
    filelist.Free;
   end;
  end;
 end; //searchdirectory

begin
 searchdirectory(filepath(tfindinfilepagefo(sender.datapo).finfo.directory,fk_file));
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
  filename.value:= 'FINISHED';
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

end.
