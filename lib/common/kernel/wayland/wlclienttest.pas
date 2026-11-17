program wlclienttest;
{ Test of waylandclient.pas.
  Build (from kernel/wayland, with the generated units and xkbcommon.pas):
   fpc -Mobjfpc -FUunits -B -Fu../../graphics wlclienttest.pas
  Run:
   WAYLAND_DISPLAY=wayland-1 ./wlclienttest

  Window: blue bar = move, red square = close, grey grip = resize.
  Right button: opens a popup (a real xdg_popup placed at the pointer);
  click outside of it or click in it closes it.
  Esc closes the program. Keys and wheel are logged. Holding a key repeats. }
{$mode objfpc}{$h+}

uses
 ctypes,BaseUnix,msesoftsurface,waylandclient,waylandxdgshell;

const
 titleheight = 30;
 gripsize = 24;
 closesize = 20;

var
 main,popupwin: twlwindow;
 quit: boolean;
 mx,my: integer;
 haspointer: boolean;

procedure drawmain;
var
 s: psoftsurfacety;
begin
 s:= main.back;
 softclear(s,$E8E8E8);
 softfillrect(s,softrect(0,0,main.width,titleheight),$2040A0,255);
 softfillrect(s,softrect(main.width - closesize - 6,5,closesize,closesize),
                                                              $C03030,255);
 softfillrect(s,softrect(main.width - gripsize,main.height - gripsize,
                                       gripsize,gripsize),$606060,255);
 softdrawline(s,0,titleheight,main.width - 1,titleheight,$000000,255);
 softdrawline(s,0,titleheight + 1,main.width - 1,main.height - 1,$80A080,255);
 softdrawline(s,0,main.height - 1,main.width - 1,titleheight + 1,$80A080,255);
 if haspointer then begin
  softdrawline(s,0,my,main.width - 1,my,$000000,80);
  softdrawline(s,mx,0,mx,main.height - 1,$000000,80);
  softfillrect(s,softrect(mx - 8,my - 8,16,16),$FF0000,128);
 end;
 wlc_present(main);
end;

procedure drawpopup;
var
 s: psoftsurfacety;
begin
 s:= popupwin.back;
 softclear(s,$FFFF99);
 softfillrect(s,softrect(0,0,popupwin.width,1),$000000,255);
 softfillrect(s,softrect(0,popupwin.height - 1,popupwin.width,1),$000000,255);
 softfillrect(s,softrect(0,0,1,popupwin.height),$000000,255);
 softfillrect(s,softrect(popupwin.width - 1,0,1,popupwin.height),$000000,255);
 softfillrect(s,softrect(10,10,popupwin.width - 20,20),$40A040,255);
 softfillrect(s,softrect(10,40,popupwin.width - 20,20),$A04040,255);
 wlc_present(popupwin);
end;

procedure closepopup;
begin
 if popupwin <> nil then begin
  wlc_destroywindow(popupwin);
  popupwin:= nil;
 end;
end;

procedure handle(const ev: twlevent);
begin
 case ev.kind of
  wle_configure: begin
   writeln('configure ',ev.x,'x',ev.y);
  end;
  wle_expose: begin
   if ev.window = main then begin
    drawmain;
   end
   else begin
    if ev.window = popupwin then begin
     drawpopup;
    end;
   end;
  end;
  wle_close: begin
   if ev.window = main then begin
    quit:= true;
   end;
  end;
  wle_popupdone: begin
   writeln('popup done');
   if ev.window = popupwin then begin
    closepopup;
   end;
  end;
  wle_pointerenter: begin
   if ev.window = main then begin
    haspointer:= true;
    mx:= ev.x;
    my:= ev.y;
    drawmain;
   end;
  end;
  wle_pointerleave: begin
   if ev.window = main then begin
    haspointer:= false;
    drawmain;
   end;
  end;
  wle_pointermotion: begin
   if ev.window = main then begin
    mx:= ev.x;
    my:= ev.y;
    drawmain;
   end;
  end;
  wle_button: begin
   writeln('button ',hexstr(ev.button,3),' pressed ',ev.pressed,' at ',
                                  ev.x,',',ev.y,' window main ',ev.window = main);
   if ev.pressed then begin
    if ev.window = popupwin then begin
     writeln('click in the popup');
     closepopup;
    end
    else begin
     if ev.window = main then begin
      if ev.button = BTN_LEFT then begin
       if (mx >= main.width - gripsize) and (my >= main.height - gripsize) then
       begin
        wlc_resize(main,xdg_toplevel_resize_edge_bottom_right);
       end
       else begin
        if my < titleheight then begin
         if mx >= main.width - closesize - 6 then begin
          quit:= true;
         end
         else begin
          wlc_move(main);
         end;
        end;
       end;
      end
      else begin
       if (ev.button = BTN_RIGHT) and (popupwin = nil) then begin
        popupwin:= wlc_createwindow(wlk_popup,main,mx,my,160,100);
        wlc_show(popupwin);
        writeln('popup requested at ',mx,',',my);
       end;
      end;
     end;
    end;
   end;
  end;
  wle_axis: begin
   writeln('axis ',ev.axis,' value ',ev.value:0:2);
  end;
  wle_axisdiscrete: begin
   writeln('axis discrete ',ev.axis,' steps ',ev.value:0:0);
  end;
  wle_key: begin
   writeln('key ',ev.key,' ',ev.pressed,' repeated ',ev.repeated,' utf8 "',
                                     ev.utf8,'" sym $',hexstr(ev.keysym,4));
   if ev.pressed and (ev.key = 1) then begin
    quit:= true;
   end;
  end;
  wle_keyboardenter: begin
   writeln('keyboard enter');
  end;
  wle_keyboardleave: begin
   writeln('keyboard leave');
  end;
  else begin
  end;
 end;
end;

var
 ev: twlevent;
 pfd: tpollfd;
 n: cint;
 sw,sh: integer;

begin
 if not wlc_connect then begin
  writeln('cannot connect or missing globals, is WAYLAND_DISPLAY set?');
  halt(1);
 end;
 wlc_screensize(sw,sh);
 writeln('screen ',sw,'x',sh);
 main:= wlc_createwindow(wlk_toplevel,nil,0,0,640,480);
 wlc_settitle(main,'MSEgui wayland client test');
 wlc_show(main);

 while not quit do begin
  while wlc_nextevent(ev) do begin
   handle(ev);
  end;
  if quit then begin
   break;
  end;
  pfd.fd:= wlc_pollprepare;
  pfd.events:= POLLIN;
  pfd.revents:= 0;
  if wlc_hasevents then begin
   wlc_pollfinish(false);
  end
  else begin
   n:= fpPoll(@pfd,1,wlc_timeout(1000));
   wlc_pollfinish((n > 0) and ((pfd.revents and POLLIN) <> 0));
  end;
  wlc_timers;
 end;
 writeln('exit');
 wlc_disconnect;
end.
