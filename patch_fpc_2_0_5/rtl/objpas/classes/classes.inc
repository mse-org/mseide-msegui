{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 1999-2000 by Michael Van Canneyt and Florian Klaempfl

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{**********************************************************************
 *       Class implementations are in separate files.                 *
 **********************************************************************}

var
  ClassList : TThreadlist;
  ClassAliasList : TStringList;

{
 Include all message strings

 Add a language with IFDEF LANG_NAME
 just befor the final ELSE. This way English will always be the default.
}

{$IFDEF LANG_GERMAN}
{$i constsg.inc}
{$ELSE}
{$IFDEF LANG_SPANISH}
{$i constss.inc}
{$ENDIF}
{$ENDIF}

{ Utility routines }
{$i util.inc}

{ TBits implementation }
{$i bits.inc}

{ All streams implementations: }
{ Tstreams THandleStream TFileStream TResourcseStreams TStringStream }
{ TCustomMemoryStream TMemoryStream }
{$i streams.inc}

{ TParser implementation}
{$i parser.inc}

{ TCollection and TCollectionItem implementations }
{$i collect.inc}

{ TList and TThreadList implementations }
{$i lists.inc}

{ TStrings and TStringList implementations }
{$i stringl.inc}

{ TThread implementation }

{ system independend threading code }
var
  { event that happens when gui thread is done executing the method}
  ExecuteEvent: PRtlEvent;
  { event executed by synchronize to wake main thread if it sleeps in CheckSynchronize }
  SynchronizeTimeoutEvent: PRtlEvent;
  { guard for synchronization variables }
  SynchronizeCritSect: TRtlCriticalSection;
  { method to execute }
  SynchronizeMethod: TThreadMethod;
  { should we execute the method? }
  DoSynchronizeMethod: boolean;
  { caught exception in gui thread, to be raised in calling thread }
  SynchronizeException: Exception;


function ThreadProc(ThreadObjPtr: Pointer): PtrInt;
  var
    FreeThread: Boolean;
    Thread: TThread absolute ThreadObjPtr;
  begin
    try
      Thread.Execute;
    except
      Thread.FFatalException := TObject(AcquireExceptionObject);
    end;
    FreeThread := Thread.FFreeOnTerminate;
    Result := Thread.FReturnValue;
    Thread.FFinished := True;
    Thread.DoTerminate;
    if FreeThread then
      Thread.Free;
    EndThread(Result);
  end;

{ system dependend code }
{$i tthread.inc}

class procedure TThread.Synchronize(AThread: TThread; AMethod: TThreadMethod);
  var
    LocalSyncException: Exception;
  begin
    { do we really need a synchronized call? }
    if GetCurrentThreadID=MainThreadID then
      AMethod()
    else
      begin
        System.EnterCriticalSection(SynchronizeCritSect);
        RtlEventStartWait(ExecuteEvent);
        SynchronizeException:=nil;
        SynchronizeMethod:=AMethod;

        { be careful, after this assignment Method could be already executed }
        DoSynchronizeMethod:=true;

        RtlEventSetEvent(SynchronizeTimeoutEvent);

        if assigned(WakeMainThread) then
          WakeMainThread(AThread);

        { wait infinitely }
        RtlEventWaitFor(ExecuteEvent);
        LocalSyncException:=SynchronizeException;
        System.LeaveCriticalSection(SynchronizeCritSect);
        if assigned(LocalSyncException) then
          raise LocalSyncException;
      end;
  end;


procedure TThread.Synchronize(AMethod: TThreadMethod);
  begin
    TThread.Synchronize(self,AMethod);
  end;


procedure CheckSynchronize(timeout : longint=0);
  { assumes being called from GUI thread }
  begin
    { first sanity check }
    if Not IsMultiThread then
      Exit
    { second sanity check }
    else if GetCurrentThreadID<>MainThreadID then
      raise EThread.CreateFmt(SCheckSynchronizeError,[GetCurrentThreadID])
    else
      begin
        if timeout>0 then
          begin
            RtlEventStartWait(SynchronizeTimeoutEvent);
            RtlEventWaitFor(SynchronizeTimeoutEvent,timeout);
          end
         else
           RtlEventResetEvent(SynchronizeTimeoutEvent);

        if DoSynchronizeMethod then
          begin
            try
              SynchronizeMethod;
            except
              SynchronizeException:=Exception(AcquireExceptionObject);
            end;
            DoSynchronizeMethod:=false;
            RtlEventSetEvent(ExecuteEvent);
          end;
      end;
  end;

{ TPersistent implementation }
{$i persist.inc }

{ TComponent implementation }
{$i compon.inc}

{ TBasicAction implementation }
{$i action.inc}

{ TDataModule implementation }
{$i dm.inc}

{ Class and component registration routines }
{$I cregist.inc}



{ Interface related stuff }
{$I intf.inc}

{**********************************************************************
 *       Miscellaneous procedures and functions                       *
 **********************************************************************}

function ExtractStrings(Separators, WhiteSpace: TSysCharSet; Content: PChar; Strings: TStrings): Integer;

var
  Start,P: PChar;
  InQuote: Boolean;
  QC: Char;
  S : string;

begin
  Result:=0;
  if Not (Assigned(Content) and (Content^<>#0)) then
    Exit;
  P:=Content;
  InQuote:=False;
  QC:=#0;
  WhiteSpace:=WhiteSpace+[#10,#13];
  Separators:=Separators+[#0,#10,#13,'''','"'];
  if Assigned(Strings) then
    Strings.BeginUpdate;
  Try
    repeat
      while P^ in WhiteSpace do
        Inc(P); // Not MBCS safe
      Start:=P;
      while True do
        begin
        while (InQuote and not (P^ in [QC, #0])) or
              not (P^ in Separators) do
            Inc(P); // Not MBCS safe
        if P^ in ['''', '"'] then
          begin
          If (QC=#0) then
            QC:=P^
          else if (QC=P^) then
            QC:=#0;
          InQuote:=QC<>#0;
          Inc(P);
          end
        else
          Break;
        end;
      if (Start<>P) then
        begin
        if Assigned(Strings) then
          begin
            SetString(S,Start,P-Start);
            Strings.Add(S);
          end;
        Inc(Result);
        end;
      If (P^<>#0) then
        Inc(P);
    until (P^=#0);
  finally
    if Assigned(Strings) then
      Strings.EndUpdate;
  end;
end;



{ Point and rectangle constructors }

function Point(AX, AY: Integer): TPoint;

begin
  with Result do
  begin
    X := AX;
    Y := AY;
  end;
end;


function SmallPoint(AX, AY: SmallInt): TSmallPoint;

begin
  with Result do
  begin
    X := AX;
    Y := AY;
  end;
end;


function Rect(ALeft, ATop, ARight, ABottom: Integer): TRect;

begin
  with Result do
  begin
    Left := ALeft;
    Top := ATop;
    Right := ARight;
    Bottom := ABottom;
  end;
end;


function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect;

begin
  with Result do
  begin
    Left := ALeft;
    Top := ATop;
    Right := ALeft + AWidth;
    Bottom :=  ATop + AHeight;
  end;
end;


function PointsEqual(const P1, P2: TPoint): Boolean; {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
  begin
    { lazy, but should work }
    result:=QWord(P1)=QWord(P2);
  end;


function PointsEqual(const P1, P2: TSmallPoint): Boolean; {$ifdef CLASSESINLINE}inline;{$endif CLASSESINLINE}
  begin
    { lazy, but should work }
    result:=DWord(P1)=DWord(P2);
  end;

function InvalidPoint(X, Y: Integer): Boolean;
  begin
    result:=(X=-1) and (Y=-1);
  end;


function InvalidPoint(const At: TPoint): Boolean;
  begin
    result:=(At.x=-1) and (At.y=-1);
  end;


function InvalidPoint(const At: TSmallPoint): Boolean;
  begin
    result:=(At.x=-1) and (At.y=-1);
  end;


{ Object filing routines }

var
  IntConstList: TThreadList;

type
  TIntConst = class
    IntegerType: PTypeInfo;             // The integer type RTTI pointer
    IdentToIntFn: TIdentToInt;          // Identifier to Integer conversion
    IntToIdentFn: TIntToIdent;          // Integer to Identifier conversion
    constructor Create(AIntegerType: PTypeInfo; AIdentToInt: TIdentToInt;
      AIntToIdent: TIntToIdent);
  end;

constructor TIntConst.Create(AIntegerType: PTypeInfo; AIdentToInt: TIdentToInt;
  AIntToIdent: TIntToIdent);
begin
  IntegerType := AIntegerType;
  IdentToIntFn := AIdentToInt;
  IntToIdentFn := AIntToIdent;
end;

procedure RegisterIntegerConsts(IntegerType: Pointer; IdentToIntFn: TIdentToInt;
  IntToIdentFn: TIntToIdent);
begin
  IntConstList.Add(TIntConst.Create(IntegerType, IdentToIntFn, IntToIdentFn));
end;

function FindIntToIdent(AIntegerType: Pointer): TIntToIdent;
var
  i: Integer;
begin
  with IntConstList.LockList do
  try
    for i := 0 to Count - 1 do
      if TIntConst(Items[i]).IntegerType = AIntegerType then
        exit(TIntConst(Items[i]).IntToIdentFn);
    Result := nil;
  finally
    IntConstList.UnlockList;
  end;
end;

function FindIdentToInt(AIntegerType: Pointer): TIdentToInt;
var
  i: Integer;
begin
  with IntConstList.LockList do
  try
    for i := 0 to Count - 1 do
      with TIntConst(Items[I]) do
        if TIntConst(Items[I]).IntegerType = AIntegerType then
          exit(IdentToIntFn);
    Result := nil;
  finally
    IntConstList.UnlockList;
  end;
end;

function IdentToInt(const Ident: String; var Int: LongInt;
  const Map: array of TIdentMapEntry): Boolean;
var
  i: Integer;
begin
  for i := Low(Map) to High(Map) do
    if CompareText(Map[i].Name, Ident) = 0 then
    begin
      Int := Map[i].Value;
      exit(True);
    end;
  Result := False;
end;

function IntToIdent(Int: LongInt; var Ident: String;
  const Map: array of TIdentMapEntry): Boolean;
var
  i: Integer;
begin
  for i := Low(Map) to High(Map) do
    if Map[i].Value = Int then
    begin
      Ident := Map[i].Name;
      exit(True);
    end;
  Result := False;
end;

function GlobalIdentToInt(const Ident: String; var Int: LongInt):boolean;
var
  i : Integer;
begin
  with IntConstList.LockList do
    try
      for i := 0 to Count - 1 do
        if TIntConst(Items[I]).IdentToIntFn(Ident, Int) then
          Exit(True);
      Result := false;
    finally
      IntConstList.UnlockList;
    end;
end;

{ TPropFixup }

type
  TPropFixup = class
    FInstance: TPersistent;
    FInstanceRoot: TComponent;
    FPropInfo: PPropInfo;
    FRootName: string;
    FName: string;
    constructor Create(AInstance: TPersistent; AInstanceRoot: TComponent;
      APropInfo: PPropInfo; const ARootName, AName: String);
    function MakeGlobalReference: Boolean;
  end;

var
  GlobalFixupList: TThreadList;

constructor TPropFixup.Create(AInstance: TPersistent; AInstanceRoot: TComponent;
  APropInfo: PPropInfo; const ARootName, AName: String);
begin
  FInstance := AInstance;
  FInstanceRoot := AInstanceRoot;
  FPropInfo := APropInfo;
  FRootName := ARootName;
  FName := AName;
end;

function TPropFixup.MakeGlobalReference: Boolean;
var
  i: Integer;
begin
  i := Pos('.', FName);
  if i = 0 then
    exit(False);
  FRootName := Copy(FName, 1, i - 1);
  FName := Copy(FName, i + 1, Length(FName));
  Result := True;
end;

Type
  TInitHandler = Class(TObject)
    AHandler : TInitComponentHandler;
    AClass : TComponentClass;
  end;

Var
  InitHandlerList : TList;
  FindGlobalComponentList : TList;

procedure RegisterFindGlobalComponentProc(AFindGlobalComponent: TFindGlobalComponent);
  begin
    if not(assigned(FindGlobalComponentList)) then
      FindGlobalComponentList:=TList.Create;
    if FindGlobalComponentList.IndexOf(Pointer(AFindGlobalComponent))<0 then
      FindGlobalComponentList.Add(Pointer(AFindGlobalComponent));
  end;


procedure UnregisterFindGlobalComponentProc(AFindGlobalComponent: TFindGlobalComponent);
  begin
    if assigned(FindGlobalComponentList) then
      FindGlobalComponentList.Remove(Pointer(AFindGlobalComponent));
  end;


function FindGlobalComponent(const Name: string): TComponent;
  var
  	i : sizeint;
  begin
    FindGlobalComponent:=nil;
    if assigned(FindGlobalComponentList) then
      begin
      	for i:=FindGlobalComponentList.Count-1 downto 0 do
      	  begin
      	    FindGlobalComponent:=TFindGlobalComponent(FindGlobalComponentList[i])(name);
      	    if assigned(FindGlobalComponent) then
      	      break;
      	  end;
      end;
  end;


procedure RegisterInitComponentHandler(ComponentClass: TComponentClass;   Handler: TInitComponentHandler);
Var
  I : Integer;
  H: TInitHandler;
begin
  If (InitHandlerList=Nil) then
    InitHandlerList:=TList.Create;
  H:=TInitHandler.Create;
  H.Aclass:=ComponentClass;
  H.AHandler:=Handler;
  try
    With InitHandlerList do
      begin
        I:=0;
        While (I<Count) and not H.AClass.InheritsFrom(TInitHandler(Items[I]).AClass) do
          Inc(I);
        { override? }
        if (I<Count) and (TInitHandler(Items[I]).AClass=H.AClass) then
          begin
            TInitHandler(Items[I]).AHandler:=Handler;
            H.Free;
          end
        else
          InitHandlerList.Insert(I,H);
      end;
   except
     H.Free;
     raise;
  end;
end;


{ all targets should at least include the sysres.inc dummy in the system unit to compile this }
function CreateComponentfromRes(const res : string;Inst : THandle;var Component : TComponent) : Boolean;
  var
    ResStream : TResourceStream;
  begin
    result:=true;

    if Inst=0 then
      Inst:=HInstance;

    try
      ResStream:=TResourceStream.Create(Inst,res,RT_RCDATA);
      try
        Component:=ResStream.ReadComponent(Component);
      finally
        ResStream.Free;
      end;
    except
      on EResNotFound do
        result:=false;
    end;
  end;


function DefaultInitHandler(Instance: TComponent; RootAncestor: TClass): Boolean;

  function doinit(_class : TClass) : boolean;
    begin
      result:=false;
      if (_class.ClassType=TComponent) or (_class.ClassType=RootAncestor) then
        exit;
      result:=doinit(_class.ClassParent);
      result:=CreateComponentfromRes(_class.ClassName,0,Instance) or result;
    end;

  begin
    GlobalNameSpace.BeginWrite;
    try
      result:=doinit(Instance.ClassType);
    finally
      GlobalNameSpace.EndWrite;
    end;
  end;


function InitInheritedComponent(Instance: TComponent; RootAncestor: TClass): Boolean;
Var
  I : Integer;
begin
  I:=0;
  if not Assigned(InitHandlerList) then begin
    Result := True;
    Exit;
  end;
  Result:=False;
  With InitHandlerList do
    begin
    I:=0;
    // Instance is the normally the lowest one, so that one should be used when searching.
    While Not result and (I<Count) do
      begin
      If (Instance.InheritsFrom(TInitHandler(Items[i]).AClass)) then
        Result:=TInitHandler(Items[i]).AHandler(Instance,RootAncestor);
      Inc(I);
      end;
    end;
end;


function InitComponentRes(const ResName: String; Instance: TComponent): Boolean;

begin
  { !!!: Too Win32-specific }
  InitComponentRes := False;
end;


function ReadComponentRes(const ResName: String; Instance: TComponent): TComponent;

begin
  { !!!: Too Win32-specific }
  ReadComponentRes := nil;
end;


function ReadComponentResEx(HInstance: THandle; const ResName: String): TComponent;

begin
  { !!!: Too Win32-specific in VCL }
  ReadComponentResEx := nil;
end;


function ReadComponentResFile(const FileName: String; Instance: TComponent): TComponent;
var
  FileStream: TStream;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead {!!!:or fmShareDenyWrite});
  try
    Result := FileStream.ReadComponentRes(Instance);
  finally
    FileStream.Free;
  end;
end;


procedure WriteComponentResFile(const FileName: String; Instance: TComponent);
var
  FileStream: TStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    FileStream.WriteComponentRes(Instance.ClassName, Instance);
  finally
    FileStream.Free;
  end;
end;


procedure GlobalFixupReferences;
var
  GlobalList, DoneList, ToDoList: TList;
  I, Index: Integer;
  Root: TComponent;
  Instance: TPersistent;
  Reference: Pointer;
begin
  GlobalNameSpace.BeginWrite;
  try
    GlobalList := GlobalFixupList.LockList;
    try
      if GlobalList.Count > 0 then
      begin
        ToDoList := nil;
        DoneList := TList.Create;
        ToDoList := TList.Create;
        try
          i := 0;
          while i < GlobalList.Count do
            with TPropFixup(GlobalList[i]) do
            begin
              Root := FindGlobalComponent(FRootName);
              if Assigned(Root) or (GetOrdProp(FInstance, FPropInfo) <> 0) then
              begin
                if Assigned(Root) then
                begin
                  Reference := FindNestedComponent(Root, FName);
                  SetOrdProp(FInstance, FPropInfo, PtrInt(Reference));
                end;
                // Move component to list of done components, if necessary
                if (DoneList.IndexOf(FInstance) < 0) and
                  (ToDoList.IndexOf(FInstance) >= 0) then
                  DoneList.Add(FInstance);
                GlobalList.Delete(i);
                Free;   // ...the fixup
              end else
              begin
                // Move component to list of components to process, if necessary
                Index := DoneList.IndexOf(FInstance);
                if Index <> -1 then
                  DoneList.Delete(Index);
                if ToDoList.IndexOf(FInstance) < 0 then
                  ToDoList.Add(FInstance);
                Inc(i);
              end;
            end;
            for i := 0 to DoneList.Count - 1 do
            begin
              Instance := TPersistent(DoneList[I]);
              if Instance.InheritsFrom(TComponent) then
                Exclude(TComponent(Instance).FComponentState, csFixups);
            end;
          finally
            ToDoList.Free;
            DoneList.Free;
          end;
        end;
    finally
      GlobalFixupList.UnlockList;
    end;
  finally
    GlobalNameSpace.EndWrite;
  end;
end;


function IsStringInList(const AString: String; AList: TStrings): Boolean;
var
  i: Integer;
begin
  for i := 0 to AList.Count - 1 do
    if CompareText(AList[i], AString) = 0 then
      exit(True);
  Result := False;
end;


procedure GetFixupReferenceNames(Root: TComponent; Names: TStrings);
var
  i: Integer;
  CurFixup: TPropFixup;
begin
  with GlobalFixupList.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        CurFixup := TPropFixup(Items[i]);
        if ((not Assigned(Root)) or (CurFixup.FInstanceRoot = Root)) and
          not IsStringInList(CurFixup.FRootName, Names) then
          Names.Add(CurFixup.FRootName);
      end;
    finally
      GlobalFixupList.UnlockList;
    end;
end;


procedure GetFixupInstanceNames(Root: TComponent;
  const ReferenceRootName: string; Names: TStrings);
var
  i: Integer;
  CurFixup: TPropFixup;
begin
  with GlobalFixupList.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        CurFixup := TPropFixup(Items[i]);
        if (CurFixup.FInstanceRoot = Root) and
          (UpperCase(ReferenceRootName) = UpperCase(CurFixup.FRootName)) and
          not IsStringInList(CurFixup.FName, Names) then
          Names.Add(CurFixup.FName);
      end;
    finally
      GlobalFixupList.UnlockList;
    end;
end;


procedure RedirectFixupReferences(Root: TComponent; const OldRootName,
  NewRootName: string);
var
  i: Integer;
  CurFixup: TPropFixup;
begin
  with GlobalFixupList.LockList do
    try
      for i := 0 to Count - 1 do
      begin
        CurFixup := TPropFixup(Items[i]);
        if ((not Assigned(Root)) or (CurFixup.FInstanceRoot = Root)) and
          (UpperCase(OldRootName) = UpperCase(CurFixup.FRootName)) then
          CurFixup.FRootName := NewRootName;
      end;
      GlobalFixupReferences;
    finally
      GlobalFixupList.Unlocklist;
    end;
end;


procedure RemoveFixupReferences(Root: TComponent; const RootName: string);
var
  i: Integer;
  CurFixup: TPropFixup;
begin
  if not Assigned(GlobalFixupList) then
    exit;

  with GlobalFixupList.LockList do
    try
      for i := Count - 1 downto 0 do
      begin
        CurFixup := TPropFixup(Items[i]);
        if ((not Assigned(Root)) or (CurFixup.FInstanceRoot = Root)) and
          ((Length(RootName) = 0) or
          (UpperCase(RootName) = UpperCase(CurFixup.FRootName))) then
        begin
          Delete(i);
          CurFixup.Free;
        end;
      end;
    finally
      GlobalFixupList.UnlockList;
    end;
end;


procedure RemoveFixups(Instance: TPersistent);
var
  i: Integer;
  CurFixup: TPropFixup;
begin
  if not Assigned(GlobalFixupList) then
    exit;

  with GlobalFixupList.LockList do
    try
      for i := Count - 1 downto 0 do
      begin
        CurFixup := TPropFixup(Items[i]);
        if (CurFixup.FInstance = Instance) then
        begin
          Delete(i);
          CurFixup.Free;
        end;
      end;
    finally
      GlobalFixupList.UnlockList;
    end;
end;


function FindNestedComponent(Root: TComponent; const NamePath: string): TComponent;
var
  Current, Found: TComponent;
  s, p: PChar;
  Name: String;
begin
  Result := nil;
  if Length(NamePath) > 0 then
  begin
    Current := Root;
    p := PChar(NamePath);
    while p[0] <> #0 do
    begin
      s := p;
      while not (p^ in ['.', '-', #0]) do
        Inc(p);
      SetString(Name, s, p - s);
      Found := Current.FindComponent(Name);
      if (not Assigned(Found)) and (UpperCase(Name) = 'OWNER') then
        Found := Current;
      if not Assigned(Found) then exit;

      // Remove the dereference operator from the name
      if p[0] = '.' then
        Inc(P);
      if p[0] = '-' then
        Inc(P);
      if p[0] = '>' then
        Inc(P);

      Current := Found;
    end;
  end;
  Result := Current;
end;

threadvar
  GlobalLoaded, GlobalLists: TList;

procedure BeginGlobalLoading;

begin
  if not Assigned(GlobalLists) then
    GlobalLists := TList.Create;
  GlobalLists.Add(GlobalLoaded);
  GlobalLoaded := TList.Create;
end;


{ Notify all global components that they have been loaded completely }
procedure NotifyGlobalLoading;
var
  i: Integer;
begin
  for i := 0 to GlobalLoaded.Count - 1 do
    TComponent(GlobalLoaded[i]).Loaded;
end;


procedure EndGlobalLoading;
begin
  { Free the memory occupied by BeginGlobalLoading }
  GlobalLoaded.Free;
  GlobalLoaded := TList(GlobalLists.Last);
  GlobalLists.Delete(GlobalLists.Count - 1);
  if GlobalLists.Count = 0 then
  begin
    GlobalLists.Free;
    GlobalLists := nil;
  end;
end;


function CollectionsEqual(C1, C2: TCollection): Boolean;
begin
  // !!!: Implement this
  CollectionsEqual:=false;
end;

function CollectionsEqual(C1, C2: TCollection; Owner1, Owner2: TComponent): Boolean;

  procedure stream_collection(s : tstream;c : tcollection;o : tcomponent);
    var
      w : twriter;
    begin
      w:=twriter.create(s,4096);
      try
        w.root:=o;
        w.flookuproot:=o;
        w.writecollection(c);
      finally
        w.free;
      end;
    end;

  var
    s1,s2 : tmemorystream;
  begin
    result:=false;
    if (c1.classtype<>c2.classtype) or
      (c1.count<>c2.count) then
      exit;

    s1:=tmemorystream.create;
    try
      s2:=tmemorystream.create;
      try
        stream_collection(s1,c1,owner1);
        stream_collection(s2,c2,owner2);
        result:=(s1.size=s2.size) and (CompareChar(s1.memory,s2.memory,s1.size)=0);
      finally
        s2.free;
      end;
    finally
      s1.free;
    end;
  end;


{ Object conversion routines }

type
  CharToOrdFuncty = Function(var charpo: Pointer): Cardinal;

function CharToOrd(var P: Pointer): Cardinal;
begin
  result:= ord(pchar(P)^);
  inc(pchar(P));
end;

function WideCharToOrd(var P: Pointer): Cardinal;
begin
  result:= ord(pwidechar(P)^);
  inc(pwidechar(P));
end;

function Utf8ToOrd(var P:Pointer): Cardinal;
begin
  // Should also check for illegal utf8 combinations
  Result := Ord(PChar(P)^);
  Inc(P);
  if (Result and $80) <> 0 then
    if (Ord(Result) and %11100000) = %11000000 then begin
      Result := ((Result and %00011111) shl 6)
                or (ord(PChar(P)^) and %00111111);
      Inc(P);
    end else if (Ord(Result) and %11110000) = %11100000 then begin
      Result := ((Result and %00011111) shl 12)
                or ((ord(PChar(P)^) and %00111111) shl 6)
                or (ord((PChar(P)+1)^) and %00111111);
      Inc(P,2);
    end else begin
      Result := ((ord(Result) and %00011111) shl 18)
                or ((ord(PChar(P)^) and %00111111) shl 12)
                or ((ord((PChar(P)+1)^) and %00111111) shl 6)
                or (ord((PChar(P)+2)^) and %00111111);
      Inc(P,3);
    end;
end;

procedure ObjectBinaryToText(Input, Output: TStream);

  procedure OutStr(s: String);
  begin
    if Length(s) > 0 then
      Output.Write(s[1], Length(s));
  end;

  procedure OutLn(s: String);
  begin
    OutStr(s + #10);
  end;

  procedure Outchars(P, LastP : Pointer; CharToOrdFunc: CharToOrdFuncty);

  var
    res, NewStr: String;
    w: Cardinal;
    InString, NewInString: Boolean;
  begin
   if p = nil then begin
    res:= '''''';
   end
   else begin
    res := '';
    InString := False;
    while P < LastP do begin
      NewInString := InString;
      w := CharToOrdfunc(P);
      if w = ord('''') then begin //quote char
        if not InString then
         NewInString := True;
        NewStr := '''''';
//        if InString then NewStr := ''''''
//        else NewStr := ''''''''
      end else if (Ord(w) >= 32) and (Ord(w) < 127) then begin //printable ascii
        if not InString then
          NewInString := True;
        NewStr := char(w);
      end else begin //ascii control chars, non ascii
        if InString then
          NewInString := False;
        NewStr := '#' + IntToStr(w);
      end;
      if NewInString <> InString then begin
        NewStr := '''' + NewStr;
        InString := NewInString;
      end;
      res := res + NewStr;
    end;
    if InString then res := res + '''';
   end;
   OutStr(res);
  end;

  procedure OutString(s: String);

  begin
    OutChars(Pointer(S),PChar(S)+Length(S),@CharToOrd);
  end;

  procedure OutWString(W: WideString);

  begin
    OutChars(Pointer(W),pwidechar(W)+Length(W),@WideCharToOrd);
  end;

  procedure OutUtf8Str(s: String);
  begin
    OutChars(Pointer(S),PChar(S)+Length(S),@Utf8ToOrd);
  end;

  function ReadInt(ValueType: TValueType): LongInt;
  begin
    case ValueType of
      vaInt8: Result := ShortInt(Input.ReadByte);
      vaInt16: Result := SmallInt(Input.ReadWord);
      vaInt32: Result := LongInt(Input.ReadDWord);
    end;
  end;

  function ReadInt: LongInt;
  begin
    Result := ReadInt(TValueType(Input.ReadByte));
  end;

  function ReadSStr: String;
  var
    len: Byte;
  begin
    len := Input.ReadByte;
    SetLength(Result, len);
    Input.Read(Result[1], len);
  end;

  function ReadLStr: String;
  var
    len: DWord;
  begin
    len := Input.ReadDWord;
    SetLength(Result, len);
    Input.Read(Result[1], len);
  end;

  function ReadWStr: WideString;
  var
    len: DWord;
  begin
    len := Input.ReadDWord;
    SetLength(Result, len);
    Input.Read(Pointer(@Result[1])^, len*2);
  end;

  procedure ReadPropList(indent: String);

    procedure ProcessValue(ValueType: TValueType; Indent: String);

      procedure Stop(s: String);
      begin
        WriteLn(s);
        Halt;
      end;

      procedure ProcessBinary;
      var
        ToDo, DoNow, i: LongInt;
        lbuf: array[0..31] of Byte;
        s: String;
      begin
        ToDo := Input.ReadDWord;
        OutLn('{');
        while ToDo > 0 do begin
          DoNow := ToDo;
          if DoNow > 32 then DoNow := 32;
          Dec(ToDo, DoNow);
          s := Indent + '  ';
          Input.Read(lbuf, DoNow);
          for i := 0 to DoNow - 1 do
            s := s + IntToHex(lbuf[i], 2);
          OutLn(s);
        end;
        OutLn(indent + '}');
      end;

    var
      s: String;
{      len: LongInt; }
      IsFirst: Boolean;
      ext: Extended;

    begin
      case ValueType of
        vaList: begin
            OutStr('(');
            IsFirst := True;
            while True do begin
              ValueType := TValueType(Input.ReadByte);
              if ValueType = vaNull then break;
              if IsFirst then begin
                OutLn('');
                IsFirst := False;
              end;
              OutStr(Indent + '  ');
              ProcessValue(ValueType, Indent + '  ');
            end;
            OutLn(Indent + ')');
          end;
        vaInt8: OutLn(IntToStr(ShortInt(Input.ReadByte)));
        vaInt16: OutLn( IntToStr(SmallInt(Input.ReadWord)));
        vaInt32: OutLn(IntToStr(LongInt(Input.ReadDWord)));
        vaExtended: begin
            Input.Read(ext, SizeOf(ext));
            OutLn(FloatToStr(ext));
          end;
        vaString: begin
            OutString(ReadSStr);
            OutLn('');
          end;
        vaIdent: OutLn(ReadSStr);
        vaFalse: OutLn('False');
        vaTrue: OutLn('True');
        vaBinary: ProcessBinary;
        vaSet: begin
            OutStr('[');
            IsFirst := True;
            while True do begin
              s := ReadSStr;
              if Length(s) = 0 then break;
              if not IsFirst then OutStr(', ');
              IsFirst := False;
              OutStr(s);
            end;
            OutLn(']');
          end;
        vaLString:
          begin
          OutString(ReadLStr);
          OutLn('');
          end;
        vaWString:
          begin
          OutWString(ReadWStr);
          OutLn('');
          end;
        vaNil:
          OutLn('nil');
        vaCollection: begin
            OutStr('<');
            while Input.ReadByte <> 0 do begin
              OutLn(Indent);
              Input.Seek(-1, soFromCurrent);
              OutStr(indent + '  item');
              ValueType := TValueType(Input.ReadByte);
              if ValueType <> vaList then
                OutStr('[' + IntToStr(ReadInt(ValueType)) + ']');
              OutLn('');
              ReadPropList(indent + '    ');
              OutStr(indent + '  end');
            end;
            OutLn('>');
          end;
        {vaSingle: begin OutLn('!!Single!!'); exit end;
        vaCurrency: begin OutLn('!!Currency!!'); exit end;
        vaDate: begin OutLn('!!Date!!'); exit end;}
        vaUTF8String: begin
            OutUtf8Str(ReadLStr);
            OutLn('');
          end;
        else
          Stop(IntToStr(Ord(ValueType)));
      end;
    end;

  begin
    while Input.ReadByte <> 0 do begin
      Input.Seek(-1, soFromCurrent);
      OutStr(indent + ReadSStr + ' = ');
      ProcessValue(TValueType(Input.ReadByte), Indent);
    end;
  end;

  procedure ReadObject(indent: String);
  var
    b: Byte;
    ObjClassName, ObjName: String;
    ChildPos: LongInt;
  begin
    // Check for FilerFlags
    b := Input.ReadByte;
    if (b and $f0) = $f0 then begin
      if (b and 2) <> 0 then ChildPos := ReadInt;
    end else begin
      b := 0;
      Input.Seek(-1, soFromCurrent);
    end;

    ObjClassName := ReadSStr;
    ObjName := ReadSStr;

    OutStr(Indent);
    if (b and 1) <> 0 then OutStr('inherited')
    else
     if (b and 4) <> 0 then OutStr('inline')
     else OutStr('object');
    OutStr(' ');
    if ObjName <> '' then
      OutStr(ObjName + ': ');
    OutStr(ObjClassName);
    if (b and 2) <> 0 then OutStr('[' + IntToStr(ChildPos) + ']');
    OutLn('');

    ReadPropList(indent + '  ');

    while Input.ReadByte <> 0 do begin
      Input.Seek(-1, soFromCurrent);
      ReadObject(indent + '  ');
    end;
    OutLn(indent + 'end');
  end;

type
  PLongWord = ^LongWord;
const
  signature: PChar = 'TPF0';
begin
  if Input.ReadDWord <> PLongWord(Pointer(signature))^ then
    raise EReadError.Create('Illegal stream image' {###SInvalidImage});
  ReadObject('');
end;


procedure ObjectTextToBinary(Input, Output: TStream);
var
  parser: TParser;

  procedure WriteString(s: String);
  begin
    Output.WriteByte(Length(s));
    if Length(s) > 0 then
      Output.Write(s[1], Length(s));
  end;

  procedure WriteLString(Const s: String);
  begin
    Output.WriteDWord(Length(s));
    if Length(s) > 0 then
      Output.Write(s[1], Length(s));
  end;

  procedure WriteWString(Const s: WideString);
  begin
    Output.WriteDWord(Length(s));
    if Length(s) > 0 then
      Output.Write(s[1], Length(s)*sizeof(widechar));
  end;

  procedure WriteInteger(value: LongInt);
  begin
    if (value >= -128) and (value <= 127) then begin
      Output.WriteByte(Ord(vaInt8));
      Output.WriteByte(Byte(value));
    end else if (value >= -32768) and (value <= 32767) then begin
      Output.WriteByte(Ord(vaInt16));
      Output.WriteWord(Word(value));
    end else begin
      Output.WriteByte(ord(vaInt32));
      Output.WriteDWord(LongWord(value));
    end;
  end;

  procedure ProcessProperty; forward;

  procedure ProcessValue;
  var
    flt: Extended;
    s: String;
    ws: WideString;
    stream: TMemoryStream;
    i: Integer;
    b: Boolean;
  begin
    case parser.Token of
      toInteger:
        begin
          WriteInteger(parser.TokenInt);
          parser.NextToken;
        end;
      toFloat:
        begin
          Output.WriteByte(Ord(vaExtended));
          flt := Parser.TokenFloat;
          Output.Write(flt, SizeOf(flt));
          parser.NextToken;
        end;
      toString:
        begin
          ws := parser.TokenWideString;
          while parser.NextToken = '+' do
          begin
            parser.NextToken;   // Get next string fragment
            parser.CheckToken(toString);
            ws := ws + parser.TokenWideString;
          end;
          b:= false;
          for i:= 1 to length(ws) do begin
            if ord(ws[i]) and $ff00 <> 0 then begin
              b:= true;
              break;
            end;
          end;
          if b then begin
            Output.WriteByte(Ord(vaWstring));
            WriteWString(ws);
            end
          else
	    begin
            setlength(s,length(ws));
            for i:= 1 to length(s) do begin
              s[i]:= ws[i]; //cut msb
            end;
            if (length(S)>255) then begin
            Output.WriteByte(Ord(vaLString));
            WriteLString(S);
            end
            else begin
            Output.WriteByte(Ord(vaString));
            WriteString(s);
            end;
          end;
        end;
      toSymbol:
        begin
          if CompareText(parser.TokenString, 'True') = 0 then
            Output.WriteByte(Ord(vaTrue))
          else if CompareText(parser.TokenString, 'False') = 0 then
            Output.WriteByte(Ord(vaFalse))
          else if CompareText(parser.TokenString, 'nil') = 0 then
            Output.WriteByte(Ord(vaNil))
          else
          begin
            Output.WriteByte(Ord(vaIdent));
            WriteString(parser.TokenComponentIdent);
          end;
          Parser.NextToken;
        end;
      // Set
      '[':
        begin
          parser.NextToken;
          Output.WriteByte(Ord(vaSet));
          if parser.Token <> ']' then
            while True do
            begin
              parser.CheckToken(toSymbol);
              WriteString(parser.TokenString);
              parser.NextToken;
              if parser.Token = ']' then
                break;
              parser.CheckToken(',');
              parser.NextToken;
            end;
          Output.WriteByte(0);
          parser.NextToken;
        end;
      // List
      '(':
        begin
          parser.NextToken;
          Output.WriteByte(Ord(vaList));
          while parser.Token <> ')' do
            ProcessValue;
          Output.WriteByte(0);
          parser.NextToken;
        end;
      // Collection
      '<':
        begin
          parser.NextToken;
          Output.WriteByte(Ord(vaCollection));
          while parser.Token <> '>' do
          begin
            parser.CheckTokenSymbol('item');
            parser.NextToken;
            // ConvertOrder
            Output.WriteByte(Ord(vaList));
            while not parser.TokenSymbolIs('end') do
              ProcessProperty;
            parser.NextToken;   // Skip 'end'
            Output.WriteByte(0);
          end;
          Output.WriteByte(0);
          parser.NextToken;
        end;
      // Binary data
      '{':
        begin
          Output.WriteByte(Ord(vaBinary));
          stream := TMemoryStream.Create;
          try
            parser.HexToBinary(stream);
            Output.WriteDWord(stream.Size);
            Output.Write(Stream.Memory^, stream.Size);
          finally
            stream.Free;
          end;
          parser.NextToken;
        end;
      else
        parser.Error(SInvalidProperty);
    end;
  end;

  procedure ProcessProperty;
  var
    name: String;
  begin
    // Get name of property
    parser.CheckToken(toSymbol);
    name := parser.TokenString;
    while True do begin
      parser.NextToken;
      if parser.Token <> '.' then break;
      parser.NextToken;
      parser.CheckToken(toSymbol);
      name := name + '.' + parser.TokenString;
    end;
    WriteString(name);
    parser.CheckToken('=');
    parser.NextToken;
    ProcessValue;
  end;

  procedure ProcessObject;
  var
    Flags: Byte;
    ObjectName, ObjectType: String;
    ChildPos: Integer;
  begin
    if parser.TokenSymbolIs('OBJECT') then
      Flags :=0  { IsInherited := False }
    else begin
      if parser.TokenSymbolIs('INHERITED') then
        Flags := 1 { IsInherited := True; }
      else begin
        parser.CheckTokenSymbol('INLINE');
        Flags := 4;
      end;
    end;
    parser.NextToken;
    parser.CheckToken(toSymbol);
    ObjectName := '';
    ObjectType := parser.TokenString;
    parser.NextToken;
    if parser.Token = ':' then begin
      parser.NextToken;
      parser.CheckToken(toSymbol);
      ObjectName := ObjectType;
      ObjectType := parser.TokenString;
      parser.NextToken;
      if parser.Token = '[' then begin
        parser.NextToken;
        ChildPos := parser.TokenInt;
        parser.NextToken;
        parser.CheckToken(']');
        parser.NextToken;
        Flags := Flags or 2;
      end;
    end;
    if Flags <> 0 then begin
      Output.WriteByte($f0 or Flags);
      if (Flags and 2) <> 0 then
        WriteInteger(ChildPos);
    end;
    WriteString(ObjectType);
    WriteString(ObjectName);

    // Convert property list
    while not (parser.TokenSymbolIs('END') or
      parser.TokenSymbolIs('OBJECT') or
      parser.TokenSymbolIs('INHERITED') or
      parser.TokenSymbolIs('INLINE')) do
      ProcessProperty;
    Output.WriteByte(0);        // Terminate property list

    // Convert child objects
    while not parser.TokenSymbolIs('END') do ProcessObject;
    parser.NextToken;           // Skip end token
    Output.WriteByte(0);        // Terminate property list
  end;

const
  signature: PChar = 'TPF0';
begin
  parser := TParser.Create(Input);
  try
    Output.Write(signature[0], 4);
    ProcessObject;
  finally
    parser.Free;
  end;
end;


procedure ObjectResourceToText(Input, Output: TStream);
begin
  Input.ReadResHeader;
  ObjectBinaryToText(Input, Output);
end;


procedure ObjectTextToResource(Input, Output: TStream);
var
  StartPos, SizeStartPos, BinSize: LongInt;
  parser: TParser;
  name: String;
begin
  // Get form type name
  StartPos := Input.Position;
  parser := TParser.Create(Input);
  try
    if not parser.TokenSymbolIs('OBJECT') then parser.CheckTokenSymbol('INHERITED');
    parser.NextToken;
    parser.CheckToken(toSymbol);
    parser.NextToken;
    parser.CheckToken(':');
    parser.NextToken;
    parser.CheckToken(toSymbol);
    name := parser.TokenString;
  finally
    parser.Free;
    Input.Position := StartPos;
  end;

  // Write resource header
  name := UpperCase(name);
  Output.WriteByte($ff);
  Output.WriteByte(10);
  Output.WriteByte(0);
  Output.Write(name[1], Length(name) + 1);      // Write null-terminated form type name
  Output.WriteWord($1030);
  SizeStartPos := Output.Position;
  Output.WriteDWord(0);                 // Placeholder for data size
  ObjectTextToBinary(Input, Output);    // Convert the stuff!
  BinSize := Output.Position - SizeStartPos - 4;
  Output.Position := SizeStartPos;
  Output.WriteDWord(BinSize);           // Insert real resource data size
end;



{ Utility routines }

function LineStart(Buffer, BufPos: PChar): PChar;

begin
  Result := BufPos;
  while Result > Buffer do begin
    Dec(Result);
    if Result[0] = #10 then break;
  end;
end;

procedure CommonInit;
begin
  InitCriticalSection(SynchronizeCritSect);
  ExecuteEvent:=RtlEventCreate;
  SynchronizeTimeoutEvent:=RtlEventCreate;
  DoSynchronizeMethod:=false;
  MainThreadID:=GetCurrentThreadID;
  InitHandlerList:=Nil;
  FindGlobalComponentList:=nil;
  IntConstList := TThreadList.Create;
  GlobalFixupList := TThreadList.Create;
  ClassList := TThreadList.Create;
  ClassAliasList := TStringList.Create;
  { on unix this maps to a simple rw synchornizer }
  GlobalNameSpace := TMultiReadExclusiveWriteSynchronizer.Create;
  RegisterInitComponentHandler(TComponent,@DefaultInitHandler);
end;

procedure CommonCleanup;
var
  i: Integer;
begin
  GlobalNameSpace.BeginWrite;
  with IntConstList.LockList do
    try
      for i := 0 to Count - 1 do
        TIntConst(Items[I]).Free;
    finally
      IntConstList.UnlockList;
    end;
    IntConstList.Free;
  ClassList.Free;
  ClassAliasList.Free;
  RemoveFixupReferences(nil, '');
  GlobalFixupList.Free;
  GlobalFixupList := nil;
  GlobalLists.Free;
  ComponentPages.Free;

  { GlobalNameSpace is an interface so this is enough }
  GlobalNameSpace:=nil;

  if (InitHandlerList<>Nil) then
    for i := 0 to InitHandlerList.Count - 1 do
      TInitHandler(InitHandlerList.Items[I]).Free;
  InitHandlerList.Free;
  InitHandlerList:=Nil;
  FindGlobalComponentList.Free;
  FindGlobalComponentList:=nil;
  DoneCriticalSection(SynchronizeCritSect);
  RtlEventDestroy(ExecuteEvent);
  RtlEventDestroy(SynchronizeTimeoutEvent);
end;

{ TFiler implementation }
{$i filer.inc}

{ TReader implementation }
{$i reader.inc}

{ TWriter implementations }
{$i writer.inc}
{$i twriter.inc}


