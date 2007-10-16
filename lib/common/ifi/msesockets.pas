unit msesockets;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 libc,msesys,msestrings;
 
type
 datarecty = record
  //dummy
 end;
 
 locsockaddrty = record
                  sa_family: sa_family_t;
                  sa_data: datarecty;
                 end;
 plocsockaddrty = ^locsockaddrty;

procedure bindlocalsocket(const asocket: integer; const filename: filenamety);
procedure connectlocalsocket(const asocket: integer; const filename: filenamety);
procedure checksyserror(const aresult: integer);

implementation
uses
 msefileutils,msesysintf;
  
procedure checksyserror(const aresult: integer);
begin
 if aresult <> 0 then begin
  syserror(syelasterror);
 end;
end;

procedure bindlocalsocket(const asocket: integer; const filename: filenamety);
var
 str1: string;
 po1: plocsockaddrty;
 int1,int2: integer;
begin
 str1:= tosysfilepath(filepath(filename));
 int1:= sizeof(locsockaddrty)+length(str1)+1;
 po1:= getmem(int1);
 try
  po1^.sa_family:= af_local;
  move(str1[1],po1^.sa_data,length(str1));
  pchar(@po1^.sa_data)[length(str1)]:= #0;
  int2:= bind(asocket,pointer(po1),int1);
  if (int2 <> 0) and (sys_getlasterror = EADDRINUSE) then begin
   libc.unlink(pchar(str1));
   int2:= bind(asocket,pointer(po1),int1);
  end;
  checksyserror(int2);
 finally
  freemem(po1);
 end;
end;

procedure connectlocalsocket(const asocket: integer; const filename: filenamety);
var
 str1: string;
 po1: plocsockaddrty;
 int1,int2: integer;
begin
 str1:= tosysfilepath(filepath(filename));
 int1:= sizeof(locsockaddrty)+length(str1)+1;
 po1:= getmem(int1);
 try
  po1^.sa_family:= af_local;
  move(str1[1],po1^.sa_data,length(str1));
  pchar(@po1^.sa_data)[length(str1)]:= #0;
  int2:= connect(asocket,pointer(po1),int1);
  checksyserror(int2);
 finally
  freemem(po1);
 end;
end;

end.
