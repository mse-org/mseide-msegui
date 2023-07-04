program demo;
uses
  {$ifdef unix}cthreads, {$endif} sysutils, classes, mseapplication, msegui,mseforms,main;



{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
 Type
    TMyThread = class(TThread)
    protected
      procedure Execute; override;
    public
      Constructor Create(CreateSuspended : boolean);
    end;

 constructor TMyThread.Create(CreateSuspended : boolean);
  begin
    inherited Create(CreateSuspended);
    FreeOnTerminate := True;
  end;

  
 procedure TMyThread.Execute;
    begin
    application.createform(tmainfo,mainfo);
    application.run;
    SetCurrentDir('/home/fred/');
    end;
 

 var
    MyThread : TMyThread;

begin
  MyThread := TMyThread.Create(true); // This way it doesn't start automatically
  MyThread.Start;
   sleep(10000);
end.
