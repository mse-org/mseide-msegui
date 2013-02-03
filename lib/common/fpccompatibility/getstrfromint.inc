  if Width <= 0 then
    exit;

  NegSign := Val < 0;
  Val := Abs(Val);
  // we'll have to store characters backwards first
  I := 0;
  repeat
    Temp[I] := Chr((Val mod 10) + Ord('0'));
    Val := Val div 10;
    Inc(I);
  until (Val = 0) or (I = Width);
  // add spaces
  J := Width - I;
  FillChar(Dst^, J, PadChar);
  // add sign
  if NegSign then
  begin
    if PadChar = '0' then
    begin
      Dst[0] := '-';
    end else begin
      if J = 0 then
      begin
        // need one character for sign, shorten
        Inc(J);
        Dec(I);
      end;
      Dst[J - 1] := '-';
    end;
  end;
  // copy value, stored backwards
  repeat
    Dec(I);
    Dst[J] := Temp[I];
    Inc(J);
  until I = 0;
  // done!
