{ MSEgui Copyright (c) 2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit msefilemacros;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msemacros;

function filemacros(): macroinfoarty;

implementation
uses
 msefileutils,msestrings;

var
 ffilemacros: macroinfoarty;

function filemacros(): macroinfoarty;
begin
 result:= ffilemacros;
end;

function file_mse(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  result:= tomsefilepath(params[0]);
 end;
end;

function file_sys(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  result:= tosysfilepath(params[0]);
 end;
end;

function file_path(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  result:= filepath(params[0]);
 end;
end;

function file_file(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
                    //no trailing path delimiter
begin
 result:= '';
 if params <> nil then begin
  result:= filepath(params[0],fk_file,true);
 end;
end;

function file_dir(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  result:= filepath(params[0],fk_dir,true);
 end;
end;

function file_name(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  result:= filename(params[0]);
 end;
end;

function file_namebase(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  result:= filenamebase(params[0]);
 end;
end;

function file_ext(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  result:= fileext(params[0]);
 end;
end;

function file_noname(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  result:= filedir(params[0]);
 end;
end;

function file_noext(const sender: tmacrolist; 
                           const params: msestringarty): msestring;
begin
 result:= '';
 if params <> nil then begin
  result:= removefileext(params[0]);
 end;
end;

const
 filemacroconst: array[0..9] of macroinfoty = (
  (name: 'FILE_MSE'; value: ''; handler: macrohandlerty(@file_mse);
                     expandlevel: 0), //convert to mse format
  (name: 'FILE_SYS'; value: ''; handler: macrohandlerty(@file_sys);
                     expandlevel: 0), //convert to sys format
  (name: 'FILE_PATH'; value: ''; handler: macrohandlerty(@file_path);
                     expandlevel: 0), //absolute path
  (name: 'FILE_FILE'; value: ''; handler: macrohandlerty(@file_FILE);
                     expandlevel: 0), //no trailing path delimiter
  (name: 'FILE_DIR'; value: ''; handler: macrohandlerty(@file_dir);
                     expandlevel: 0), //trailing path delimiter
  (name: 'FILE_NAME'; value: ''; handler: macrohandlerty(@file_name);
                     expandlevel: 0), //no directory part
  (name: 'FILE_NAMEBASE'; value: ''; handler: macrohandlerty(@file_namebase);
                     expandlevel: 0), //no directory and name extension part
  (name: 'FILE_EXT'; value: ''; handler: macrohandlerty(@file_ext);
                     expandlevel: 0), //file name extension
  (name: 'FILE_NONAME'; value: ''; handler: macrohandlerty(@file_noname);
                     expandlevel: 0), //directory part only
  (name: 'FILE_NOEXT'; value: ''; handler: macrohandlerty(@file_noext);
                     expandlevel: 0)  //no file name extension
 );

procedure initfilemacros();
var
 int1: integer;
begin
 setlength(ffilemacros,length(filemacroconst));
 for int1:= 0 to high(filemacroconst) do begin
  ffilemacros[int1]:= filemacroconst[int1];
 end;
end;

initialization
 initfilemacros();
end.
