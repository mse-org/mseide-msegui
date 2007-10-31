unit beeport;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
{$asmmode intel}

(***************************************************************
  beeport version 1.0 (freeware)
  by: beesoft(tm)

  this unit contains two components:
    - tbyteport: this components access general parallel ports.
    - tppi8255 : this components access multipurposes parallel
                 port on ppi8255 card from intel.

  with these components, there'll be no more assembler inline
  codes to access hardware port. just drop the component onto
  your form, set the port properties, and go! see the details
  in readme.txt file.
  any bugs report, comments, suggestions or regards, send 'em
  to: bisma@mailcity.com - and feel free to do it!

  last update: may 12, 1999 on malang, indonesia
  this unit modified to msegui to use in windows and linux by Sri Wahono
****************************************************************)

interface

uses
  msewidgets,{$ifdef mswindows}windows{$else}ports{$endif}, sysutils, classes, strutils;
{$ifdef linux}
var
	port:tport;
{$endif}
type
  { new type declarations }
  tbytebitindex  = 0..7;
  tportiomode    = (alloutput, allinput, hioutloin, hiinloout);

  tppi_iomode    = (basic, strobed, bidirectional);
  tppi_ioset     = (ioaoutput, ioboutput, iochioutput, ioclooutput);
  tppi_iocontrol = set of tppi_ioset;

  pportdata = ^tportdata;
  tportdata = record
     address: word;
     iomode: tportiomode;
     value: byte;
  end;

  tvaluechangeevent = procedure(sender: tobject; var newvalue: byte) of object;

  { event generator thread }
  tportmonitor = class(tthread)
    private
      foldport: tportdata;
      fnewport: pportdata;
      faddrchange, fiomodechange, fvaluechange: tnotifyevent;
    protected
      procedure execute; override;
    public
      constructor create(var portobj: tportdata);
      property onaddressdiffer: tnotifyevent read faddrchange;
      property oniomodediffer: tnotifyevent read fiomodechange;
      property onvaluediffer: tnotifyevent read fvaluechange;
  end;

  { tbyteport class declarations }
  tbyteport = class(tcomponent)
    private
      fbytevalue: byte;
      faddress: word;
      fiomode: tportiomode;
      fvaluechange: tvaluechangeevent;
    protected
      function  getbyte: byte;
      function  getbit(bitnumber: tbytebitindex): boolean;
      procedure setbyte(value: byte);
      procedure setbit(bitnumber: tbytebitindex; bitvalue: boolean);
    public
      constructor create(aowner: tcomponent); override;
      destructor  destroy; override;
      property bitvalue[bitindex: tbytebitindex]: boolean read getbit write setbit;
    published
      property iomode: tportiomode read fiomode write fiomode default alloutput;
      property address: word read faddress write faddress default $300;
      property bytevalue: byte read getbyte write setbyte default 0;

      property onvaluechange: tvaluechangeevent read fvaluechange write fvaluechange;
  end;

  { tppi8255 class declarations }
  tppi8255 = class(tcomponent)
    private
      //fmonitorport: tportmonitor;
      fiomode: tppi_iomode;
      fiocontrol: tppi_iocontrol;
      fporta, fportb, fportc, fportr: tportdata;
      fportaresult , fportbresult, fportcresult: string;
      faddresschange, fcontrolchange, finitppi: tnotifyevent;
      fpachange, fpbchange, fpcchange: tvaluechangeevent;

      function  getbaseaddress: word;
      function  getctrlword: byte;
      function  getportavalue: byte;
      function  getportbvalue: byte;
      function  getportcvalue: byte;
      procedure setbaseaddress(ppiaddr: word);
      procedure setctrlword(ppicw: byte);
      procedure setiomode(ppiiomode: tppi_iomode);
      procedure setiocontrol(ppiioctrl: tppi_iocontrol);
      procedure setportavalue(pavalue: byte);
      procedure setportbvalue(pbvalue: byte);
      procedure setportcvalue(pcvalue: byte);
      procedure analyzeiocontrol;
    public
      constructor create(aowner: tcomponent); override;
      destructor destroy; override;
      procedure initializeppi;
	  procedure onoff(lineno : byte; status : byte);
    published
      property baseaddress: word read getbaseaddress write setbaseaddress;
      property controlword: byte read getctrlword write setctrlword;
      property iomode: tppi_iomode read fiomode write setiomode;
      property iocontrol: tppi_iocontrol read fiocontrol write setiocontrol;
      property portavalue: byte read getportavalue write setportavalue;
      property portbvalue: byte read getportbvalue write setportbvalue;
      property portcvalue: byte read getportcvalue write setportcvalue;

      property oniocontrolchange: tnotifyevent read fcontrolchange write fcontrolchange;
      property onaddresschange: tnotifyevent read faddresschange write faddresschange;
      property oninitializeppi: tnotifyevent read finitppi write finitppi;
      property onpavaluechange: tvaluechangeevent read fpachange write fpachange;
      property onpbvaluechange: tvaluechangeevent read fpbchange write fpbchange;
      property onpcvaluechange: tvaluechangeevent read fpcchange write fpcchange;
  end;

{ public routines declarations }
function  readbit(srcvalue: byte; bitindex: tbytebitindex): boolean;
function  writebit(srcvalue: byte; bitindex: tbytebitindex; bitvalue: boolean): byte;
function  rotatebit(srcvalue: byte): byte;
function pangkat(x:integer; y:integer) : integer;
function bytetobin(value: byte): string;
{$ifdef mswindows}
procedure outport(addr:word;data:byte);stdcall;external 'inpout32.dll' name 'Out32' ;
function inport(addr:word):byte;stdcall;external 'inpout32.dll' name 'Inp32';
{$endif}
procedure register;

implementation

function readbit(srcvalue: byte; bitindex: tbytebitindex): boolean;
var
  dbyte, dbit: byte;
begin
  dbit := 1;
  dbit := dbit shl bitindex;
  dbyte := srcvalue;
  dbyte := dbyte and dbit;
  result := (dbyte <> 0);
end;

function writebit(srcvalue: byte; bitindex: tbytebitindex; bitvalue: boolean): byte;
var
  dbyte, dbit: byte;
begin
  dbit := 1;
  dbit := dbit shl bitindex;
  dbyte := srcvalue;
  if not bitvalue then
  begin
    dbit := not dbit;
    dbyte := dbyte and dbit;
  end
  else
    dbyte := dbyte or dbit;
  result := dbyte;
end;

function rotatebit(srcvalue: byte): byte;
var
  i: integer;
  swapval: byte;
begin
  swapval := 0;
  for i := 0 to 7 do swapval := writebit(swapval,i,readbit(srcvalue,7-i));
  rotatebit := swapval;
end;

function bytetobin(value: byte): string;
var
 po: byte;
 int1: integer;
 binres : string;
begin
	po:=value mod 2;
	value:=value div 2;
	binres := inttostr(po);
	while value>0 do begin
		po:=value mod 2;
		value:=value div 2;
		binres:=inttostr(po) + binres;
 	end;
 	if length(binres)<8 then begin
 		for int1:=1 to 8-length(binres) do begin
  			binres:='0' + binres
  		end;
 	end;
 	result := binres;
end;

function bintobyte(value: string): byte;
var
 po: byte;
 int1: integer;
 byteres : byte;
begin
	byteres := 0;
	for int1:=1 to length(value) do begin
		po:=strtoint(value[int1]);
		byteres:=byteres + (po * pangkat(2,(8-int1)));
	end;
 	result := byteres;
end;

function pangkat(x:integer; y:integer) : integer;
var
	i : integer;
	res : integer;
begin
	res:=1;
	for i:=1 to y do begin
		res:=res * x;
	end;
	result := res;
end;

{ = event generator routines = }

constructor tportmonitor.create(var portobj: tportdata);
begin
  foldport := portobj;
  fnewport := @portobj;
  freeonterminate := true;
  inherited create(false);
end;

procedure tportmonitor.execute;
begin
  if terminated then exit;
  if fnewport^.address <> foldport.address then
  begin
    if assigned(onaddressdiffer) then onaddressdiffer(self);
    foldport := fnewport^;
  end;
  if fnewport^.iomode <> foldport.iomode then
  begin
    if assigned(oniomodediffer) then oniomodediffer(self);
    foldport := fnewport^;
  end;
  if fnewport^.value <> foldport.value then
  begin
    if assigned(onvaluediffer) then onvaluediffer(self);
    foldport := fnewport^;
  end;
end;

{ = tbyteport routines = }

constructor tbyteport.create(aowner: tcomponent);
begin
  inherited create(aowner);
  fiomode := alloutput;
  faddress := $300;
  fbytevalue := 0;
  {$ifdef mswindows}
  outport(faddress, fbytevalue);
  {$else}
  port[faddress]:=fbytevalue;
  {$endif}
end;

destructor tbyteport.destroy;
begin
  inherited destroy;
end;

procedure tbyteport.setbyte(value: byte);
begin
  if fbytevalue <> value then
     if assigned(onvaluechange) then onvaluechange(self, value);
  if fiomode <> allinput then
  begin
    fbytevalue := value;
    {$ifdef mswindows}
    outport(faddress, fbytevalue);
    {$else}
    port[faddress]:=fbytevalue;
    {$endif}
  end;
end;

function tbyteport.getbyte: byte;
var
  value: byte;
begin
  if fiomode <> alloutput then
  begin
  	{$ifdef mswindows}
    value := inport(faddress);
    {$else}
    value := port[faddress];
    {$endif}
    if fbytevalue <> value then
       if assigned(onvaluechange) then onvaluechange(self, value);
    fbytevalue := value;
  end;
  result := fbytevalue;
end;

procedure tbyteport.setbit(bitnumber: tbytebitindex; bitvalue: boolean);
begin
  writebit(fbytevalue,bitnumber,bitvalue);
end;

function tbyteport.getbit(bitnumber: tbytebitindex): boolean;
begin
  result := readbit(fbytevalue,bitnumber);
end;

{ = tppi8255 routines = }

constructor tppi8255.create(aowner: tcomponent);
begin
  inherited create(aowner);
  fportr.address := $303;
  fportr.iomode := alloutput;
  fportr.value := $80;
  analyzeiocontrol;
  initializeppi;
end;

destructor tppi8255.destroy;
begin
  {$ifdef mswindows}	
  outport(fportr.address, $80);
  {$else}
  port[fportr.address]:=$80;
  {$endif}
  inherited destroy;
end;

procedure tppi8255.onoff(lineno : byte; status : byte);
begin
	if status>1 then status:=1;
	if status<0 then status:=0;
	case lineno of
	1..8 :
		begin
			lineno:=8-lineno+1;
			fportaresult:=leftstr(fportaresult,lineno-1) + inttostr(status) + rightstr(fportaresult,8-lineno);
			setportavalue(bintobyte(fportaresult));
			setportbvalue(bintobyte(fportbresult));
			setportcvalue(bintobyte(fportcresult));
		end;
	9..16 :
		begin
			lineno:=16-lineno+1;
			fportbresult:=leftstr(fportbresult,lineno-1) + inttostr(status) + rightstr(fportbresult,8-lineno);
			setportavalue(bintobyte(fportaresult));
			setportbvalue(bintobyte(fportbresult));
			setportcvalue(bintobyte(fportcresult));
		end;
	17..24 :
		begin
			lineno:=24-lineno+1;
			fportcresult:=leftstr(fportcresult,lineno-1) + inttostr(status) + rightstr(fportcresult,8-lineno);
			setportavalue(bintobyte(fportaresult));
			setportbvalue(bintobyte(fportbresult));
			setportcvalue(bintobyte(fportcresult));
		end;
	end;
end;

procedure tppi8255.initializeppi;
var
	i:byte;
begin
  {$ifdef mswindows}
  outport(fportr.address, fportr.value);
  {$else}
  port[fportr.address]:=fportr.value;
  {$endif}
  fportaresult:='00000000';
  fportbresult:='00000000';
  fportcresult:='00000000';
  if assigned(oninitializeppi) then oninitializeppi(self);
end;

procedure tppi8255.analyzeiocontrol;
begin
  { analyze port address }
  fporta.address := fportr.address - 3;
  fportb.address := fportr.address - 2;
  fportc.address := fportr.address - 1;
  { analyze ppi mode }
  if readbit(fportr.value, 2) then fiomode := strobed else fiomode := basic;
  if not readbit(fportr.value, 6) and not readbit(fportr.value, 5) then fiomode := basic;
  if not readbit(fportr.value, 6) and readbit(fportr.value, 5) then fiomode := strobed;
  if readbit(fportr.value, 6) then fiomode := bidirectional;
  { analyze porta io }
  if readbit(fportr.value, 4) then
  begin
    fporta.iomode := allinput;
    fiocontrol := fiocontrol - [ioaoutput];
  end
    else
    begin
      fporta.iomode := alloutput;
      fiocontrol := fiocontrol + [ioaoutput];
    end;
  { analyze portb io }
  if readbit(fportr.value, 1) then
  begin
    fportb.iomode := allinput;
    fiocontrol := fiocontrol - [ioboutput];
  end
    else
    begin
      fportb.iomode := alloutput;
      fiocontrol := fiocontrol + [ioboutput];
    end;
  { analyze portc io }
  if readbit(fportr.value, 0) and readbit(fportr.value, 3) then
  begin
    fportc.iomode := allinput;
    fiocontrol := fiocontrol - [iochioutput] - [ioclooutput];
  end
    else if not readbit(fportr.value, 0) and readbit(fportr.value, 3) then
    begin
      fportc.iomode := hiinloout;
      fiocontrol := fiocontrol - [iochioutput] + [ioclooutput];
    end
       else if readbit(fportr.value, 0) and not readbit(fportr.value, 3) then
       begin
         fportc.iomode := hioutloin;
         fiocontrol := fiocontrol + [iochioutput] - [ioclooutput];
       end
          else
          begin
            fportc.iomode := alloutput;
            fiocontrol := fiocontrol + [iochioutput] + [ioclooutput];
          end;
end;

function tppi8255.getbaseaddress: word;
begin
  result := fportr.address - 3;
end;

procedure tppi8255.setbaseaddress(ppiaddr: word);
begin
  fportr.address := ppiaddr + 3;
  fporta.address := fportr.address - 3;
  fportb.address := fportr.address - 2;
  fportc.address := fportr.address - 1;
  if assigned(onaddresschange) then onaddresschange(self);
  initializeppi;
end;

function tppi8255.getctrlword: byte;
begin
  result := fportr.value;
end;

procedure tppi8255.setctrlword(ppicw: byte);
begin
  fportr.value := ppicw;
  if not readbit(fportr.value, 7) then fportr.value := writebit(fportr.value, 7, true);
  if assigned(oniocontrolchange) then oniocontrolchange(self);
  analyzeiocontrol;
  initializeppi;
end;

procedure tppi8255.setiomode(ppiiomode: tppi_iomode);
begin
  fiomode := ppiiomode;
  case fiomode of
    basic        : begin
                     fportr.value := writebit(fportr.value,6,false);
                     fportr.value := writebit(fportr.value,5,false);
                     fportr.value := writebit(fportr.value,2,false);
                   end;
    strobed      : begin
                     fportr.value := writebit(fportr.value,6,false);
                     fportr.value := writebit(fportr.value,5,true);
                     fportr.value := writebit(fportr.value,2,true);
                   end;
    bidirectional: fportr.value := writebit(fportr.value,6,true);
  end;
  if assigned(oniocontrolchange) then oniocontrolchange(self);
end;

procedure tppi8255.setiocontrol(ppiioctrl: tppi_iocontrol);
begin
  fiocontrol := ppiioctrl;
  if fiocontrol * [ioaoutput] = [ioaoutput] then
     fportr.value := writebit(fportr.value,4,false)
  else
     fportr.value := writebit(fportr.value,4,true);
  if fiocontrol * [ioboutput] = [ioboutput] then
     fportr.value := writebit(fportr.value,1,false)
  else
     fportr.value := writebit(fportr.value,1,true);
  if fiocontrol * [iochioutput] = [iochioutput] then
     fportr.value := writebit(fportr.value,3,false)
  else
     fportr.value := writebit(fportr.value,3,true);
  if fiocontrol * [ioclooutput] = [ioclooutput] then
     fportr.value := writebit(fportr.value,0,false)
  else
     fportr.value := writebit(fportr.value,0,true);
  if assigned(oniocontrolchange) then oniocontrolchange(self);
end;

function tppi8255.getportavalue: byte;
begin
  if fporta.iomode <> alloutput then
  begin
  	{$ifdef mswindows}
    fporta.value := inport(fporta.address);
    {$else}
    fporta.value := port[fporta.address];
    {$endif}
    if assigned(onpavaluechange) then onpavaluechange(self, fporta.value);
  end;
  result := fporta.value;
end;

procedure tppi8255.setportavalue(pavalue: byte);
begin
  if fporta.iomode <> allinput then
  begin
    if fporta.value <> pavalue then
       if assigned(onpavaluechange) then onpavaluechange(self, pavalue);
    fporta.value := pavalue;
    fportaresult:=bytetobin(fporta.value);
    {$ifdef mswindows}
    outport(fporta.address, fporta.value);
    {$else}
    port[fporta.address]:=fporta.value;
    {$endif}
  end;
end;

function tppi8255.getportbvalue: byte;
begin
  if fportb.iomode <> alloutput then
  begin
  	{$ifdef mswindows}
    fportb.value := inport(fportb.address);
    {$else}
    fportb.value := port[fportb.address];
    {$endif}
    if assigned(onpbvaluechange) then onpbvaluechange(self, fportb.value);
  end;
  result := fportb.value;
end;

procedure tppi8255.setportbvalue(pbvalue: byte);
begin
  if fportb.iomode <> allinput then
  begin
    if fportb.value <> pbvalue then
       if assigned(onpbvaluechange) then onpbvaluechange(self, pbvalue);
    fportb.value := pbvalue;
    fportbresult:=bytetobin(fportb.value);
    {$ifdef mswindows}
    outport(fportb.address, fportb.value);
    {$else}
    port[fportb.address]:=fportb.value;
    {$endif}
  end;
end;

function tppi8255.getportcvalue: byte;
begin
  if fportc.iomode <> alloutput then
  begin
  	{$ifdef mswindows}
    fportc.value := inport(fportc.address);
    {$else}
    fportc.value := port.pp [fportc.address];
    {$endif}
    if assigned(onpcvaluechange) then onpcvaluechange(self, fportc.value);
  end;
  result := fportc.value;
end;

procedure tppi8255.setportcvalue(pcvalue: byte);
begin
  if fportc.iomode <> allinput then
  begin
    if fportc.value <> pcvalue then
       if assigned(onpcvaluechange) then onpcvaluechange(self, pcvalue);
    fportc.value := pcvalue;
    fportcresult:=bytetobin(fportc.value);
    {$ifdef mswindows}
    outport(fportc.address, fportc.value);
    {$else}
    port[fportc.address]:=fportc.value;
    {$endif}
  end;
end;

{ ========= registration routines ========== }

procedure register;
begin
  registercomponents('wahono', [tbyteport]);
  registercomponents('wahono', [tppi8255]);
end;

end.

