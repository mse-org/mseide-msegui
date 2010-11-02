{ MSEgui Copyright (c) 1999-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msepointer;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 msegraphics,msegraphutils,msetimer,msetypes,mseglob;

const
 defaultcaretblinkperiodetime = 1000000; //us
 defaultsizingmargin = 3;
type

 cursorshapety = (cr_default,cr_parent,
             cr_none,cr_arrow,cr_cross,cr_wait,cr_ibeam,
             cr_sizever,cr_sizehor,cr_sizebdiag,cr_sizefdiag,cr_sizeall,
             cr_splitv,cr_splith,cr_pointinghand,cr_forbidden,cr_drag,
             cr_topleftcorner,cr_bottomleftcorner,
             cr_bottomrightcorner,cr_toprightcorner,
             cr_res0,cr_res1,cr_res2,cr_res3,cr_res4,cr_res5,cr_res6,cr_res7,
             cr_user);

 sizingkindty = (sik_none,sik_right,sik_topright,sik_top,sik_topleft,
                     sik_left,sik_bottomleft,sik_bottom,sik_bottomright);
const
 sizingcursors: array[sizingkindty] of cursorshapety = 
   (cr_default,cr_sizehor,cr_toprightcorner,cr_sizever,cr_topleftcorner,
    cr_sizehor,cr_bottomleftcorner,cr_sizever,cr_bottomrightcorner);
type
 imouse = interface(inullinterface)
  function getmousewinid: winidty;
 end;

 tmouse = class
  private
   fshape: cursorshapety;
   fwinid: winidty;
   fintf: imouse;
   procedure setshape(const Value: cursorshapety);
   function getpos: pointty;
   procedure setpos(const Value: pointty);
  public
   constructor create(mouseintf: imouse);
   procedure move(const dist: pointty);
   procedure windowdestroyed(const id: winidty);
   property shape: cursorshapety read fshape write setshape;
   property pos: pointty read getpos write setpos;
 end;

 caretstatety = (cas_active,cas_on,cas_showed);
 caretstatesty = set of caretstatety;

 tcaret = class(tnullinterfacedobject{,icaret})
  private
   fcanvas: tcanvas;
   fcliprect: rectty;
   fbounds: rectty;
   forigin: pointty;
   fstate: caretstatesty;
   ftimer: tsimpletimer;
   fbackup: tsimplebitmap;
   fcaret: tsimplebitmap;
   fvisible: integer;
   function getheight: integer;
   procedure setheight(const Value: integer);
   function getpos: pointty;
   procedure setpos(const Value: pointty);
   function getsize: sizety;
   procedure setsize(const Value: sizety);
   function getwidth: integer;
   procedure setwidth(const Value: integer);
   function getx: integer;
   procedure setx(const Value: integer);
   function gety: integer;
   procedure sety(const Value: integer);
   function getbounds: rectty;
   procedure setbounds(const value: rectty);
   function getperiodetime: integer;
   procedure setperiodetime(const Value: integer);
   procedure updatestate;
   procedure restart;
   procedure timerevent(const sender: tobject);
   function getcliprect: rectty;
   procedure setcliprect(const Value: rectty); //no restart of timer
  protected
   procedure scroll(const dist: pointty; const scrollorigin: boolean);
  public
   constructor create{(out intf: pointer)};
   destructor destroy; override;
   procedure link(canvas: tcanvas; const origin: pointty;
                      const acliprect: rectty);
   function islinkedto(canvas: tcanvas): boolean;

   procedure remove;  //recursive
   procedure restore; //recursive
   procedure hide;    //stops timer
   procedure show;    //restarts timer
   procedure move(const dist: pointty);
   function active: boolean;
   function visible: boolean;

   property origin: pointty read forigin;
   property bounds: rectty read getbounds write setbounds;
   property cliprect: rectty read getcliprect write setcliprect;
   property rootcliprect: rectty read fcliprect;
   property x: integer read getx write setx;
   property y: integer read gety write sety;
   property pos: pointty read getpos write setpos;
   property width: integer read getwidth write setwidth;
   property height: integer read getheight write setheight;
   property size: sizety read getsize write setsize;
   property periodetime: integer read getperiodetime write setperiodetime;
 end;

function calcsizingkind(const apos: pointty; const arect: rectty;
                const margin: integer = defaultsizingmargin): sizingkindty;
function adjustsizingrect(const arect: rectty; const kind: sizingkindty;
         const offset: pointty; const cxmin,cxmax,cymin,cymax: integer): rectty;

implementation
uses
 mseguiintf;

function calcsizingkind(const apos: pointty; const arect: rectty;
                const margin: integer = defaultsizingmargin): sizingkindty;
var
 margin2,distright,disttop,distleft,distbottom: integer;
begin
 result:= sik_none;
 distright:= abs(apos.x - (arect.x+arect.cx));
 disttop:= abs(apos.y - (arect.y));
 distleft:= abs(apos.x - (arect.x));
 distbottom:= abs(apos.y - (arect.y+arect.cy));
 margin2:= 2 * margin;
 if disttop < margin then begin
  if distleft < margin2 then begin
   result:= sik_topleft;
  end
  else begin
   if distright < margin2 then begin
    result:= sik_topright;
   end
   else begin
    result:= sik_top;
   end;
  end;
 end
 else begin
  if distbottom < margin then begin
   if distleft < margin2 then begin
    result:= sik_bottomleft;
   end
   else begin
    if distright < margin2 then begin
     result:= sik_bottomright;
    end
    else begin
     result:= sik_bottom;
    end;
   end;
  end
  else begin
   if distleft < margin then begin
    if disttop < margin2 then begin
     result:= sik_topleft;
    end
    else begin
     if distbottom < margin2 then begin
      result:= sik_bottomleft;
     end
     else begin
      result:= sik_left;
     end;
    end
   end
   else  begin
    if distright < margin then begin
     if disttop < margin2 then begin
      result:= sik_topright;
     end
     else begin
      if distbottom < margin2 then begin
       result:= sik_bottomright;
      end
      else begin
       result:= sik_right;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function adjustsizingrect(const arect: rectty; const kind: sizingkindty;
         const offset: pointty; const cxmin,cxmax,cymin,cymax: integer): rectty;
 procedure adjustright;
 begin
  result.cx:= result.cx + offset.x;
  if (cxmax > 0) and (result.cx > cxmax) then begin
   result.cx:= cxmax;
  end;
  if result.cx < cxmin then begin
   result.cx:= cxmin;
  end;
 end;
 procedure adjusttop;
 var
  int1: integer;
 begin
  int1:= offset.y;
  if (cymax <> 0) and (result.cy - int1 > cymax) then begin
   int1:= result.cy - cymax;
  end;
  if result.cy - int1 < cymin then begin
   int1:= result.cy - cymin;
  end;
  result.y:= result.y + int1;
  result.cy:= result.cy - int1;
 end;
 procedure adjustleft;
 var
  int1: integer;
 begin
  int1:= offset.x;
  if (cxmax <> 0) and (result.cx - int1 > cxmax) then begin
   int1:= result.cx - cxmax;
  end;
  if result.cx - int1 < cxmin then begin
   int1:= result.cx - cxmin;
  end;
  result.x:= result.x + int1;
  result.cx:= result.cx - int1;
 end;
 procedure adjustbottom;
 begin
  result.cy:= result.cy + offset.y;
  if (cymax > 0) and (result.cy > cymax) then begin
   result.cy:= cymax;
  end;
  if result.cy < cymin then begin
   result.cy:= cymin;
  end;
 end;
begin
 result:= arect;
 case kind of
  sik_right: adjustright;
  sik_topright: begin adjusttop; adjustright end;
  sik_top: adjusttop;
  sik_topleft: begin adjusttop; adjustleft end;
  sik_left: adjustleft;
  sik_bottomleft: begin adjustbottom; adjustleft end;
  sik_bottom: adjustbottom;
  sik_bottomright: begin adjustbottom; adjustright end;  
 end;
end;

{ tmouse }

constructor tmouse.create(mouseintf: imouse);
begin
 fintf:= mouseintf;
// fwinid:= winidty(-1);
end;

function tmouse.getpos: pointty;
begin
 result:= gui_getpointerpos;
end;

procedure tmouse.setpos(const Value: pointty);
begin
 if not pointisequal(value,getpos) then begin
  gui_setpointerpos(value);
 end;
end;

procedure tmouse.move(const dist: pointty);
begin
 if (dist.x <> 0) or (dist.y <> 0) then begin
  gui_movepointer(dist);
 end;
end;

procedure tmouse.setshape(const Value: cursorshapety);
var
 id1: winidty;
begin
 id1:= fintf.getmousewinid;
 if (fshape <> value) or (id1 <> fwinid) then begin
  fwinid:= id1;
  fshape := Value;
  gui_setcursorshape(id1,value);
 end;
end;

procedure tmouse.windowdestroyed(const id: winidty);
begin
 if id = fwinid then begin
  fwinid:= winidty(-1);
 end;
end;

{ tcaret }

constructor tcaret.create{(out intf: pointer)};
begin
// intf:= pointer(icaret(self));
 ftimer:= tsimpletimer.create(0,{$ifdef FPC}@{$endif}timerevent,false,[]);
 fbackup:= tsimplebitmap.create(false);
 fcaret:= tsimplebitmap.create(false);
 periodetime:= defaultcaretblinkperiodetime;
end;

destructor tcaret.destroy;
begin
 remove;
 ftimer.free;
 fbackup.free;
 fcaret.free;
 inherited;
end;

function tcaret.getperiodetime: integer;
begin
 result:= ftimer.interval * 2;
end;

procedure tcaret.setperiodetime(const Value: integer);
begin
 ftimer.interval:= value div 2;
end;

function tcaret.getbounds: rectty;
begin
 result:= fbounds;
 subpoint1(result.pos,forigin);
end;

procedure tcaret.setbounds(const value: rectty);
begin
 if (value.x + forigin.x <> fbounds.x) or (value.y + forigin.y <> fbounds.y) or
     (value.cx <> fbounds.cx) or (value.cy <> fbounds.cy) then begin
  remove;
  if not sizeisequal(fbounds.size,value.size) then begin
   fbackup.size:= value.size;
   fcaret.size:= value.size;
   if not fcaret.isempty then begin
    fcaret.init(cl_white);
   end;
  end;
  fbounds:= value;
  addpoint1(fbounds.pos,forigin);
  restore;
 end;
end;

function tcaret.getpos: pointty;
begin
 result:= getbounds.pos;
end;

procedure tcaret.setpos(const Value: pointty);
var
 rect1: rectty;
begin                                 
 rect1:= getbounds;
 rect1.pos:= value;
 setbounds(rect1);
end;

function tcaret.getx: integer;
begin
 result:= getbounds.pos.x;
end;

procedure tcaret.setx(const Value: integer);
var
 rect1: rectty;
begin
 rect1:= getbounds;
 rect1.pos.x:= value;
 setbounds(rect1);
end;

function tcaret.gety: integer;
begin
 result:= getbounds.pos.y;
end;

procedure tcaret.sety(const Value: integer);
var
 rect1: rectty;
begin
 rect1:= getbounds;
 rect1.pos.y:= value;
 setbounds(rect1);
end;

function tcaret.getsize: sizety;
begin
 result:= fbounds.size;
end;

procedure tcaret.setsize(const Value: sizety);
var
 rect1: rectty;
begin
 rect1:= getbounds;
 rect1.size:= value;
 setbounds(rect1);
end;

function tcaret.getwidth: integer;
begin
 result:= fbounds.cx;
end;

procedure tcaret.setwidth(const Value: integer);
var
 rect1: rectty;
begin
 rect1:= getbounds;
 rect1.cx:= value;
 setbounds(rect1);
end;

function tcaret.getheight: integer;
begin
 result:= fbounds.cy;
end;

procedure tcaret.setheight(const Value: integer);
var
 rect1: rectty;
begin
 rect1:= getbounds;
 rect1.cy:= value;
 setbounds(rect1);
end;

procedure tcaret.updatestate;
begin
 if fcanvas <> nil then begin
  if (fvisible > 0) and
    (([cas_on,cas_active] * fstate = [cas_on,cas_active])) and
     not (cas_showed in fstate) then begin
        //display caret
   if not fcaret.isempty then begin
    fcanvas.save;
    fcanvas.origin:= nullpoint;
    fcanvas.clipregion:= fcanvas.createregion(fcliprect);
    fbackup.canvas.copyarea(fcanvas,fbounds,nullpoint);
    fcanvas.copyarea(fcaret.canvas,makerect(nullpoint,fbounds.size),
                         fbounds.pos,rop_xor);
    fcanvas.restore;
   end;
   include(fstate,cas_showed);
  end
  else begin
   if (cas_showed in fstate) then begin
    if not fcaret.isempty then begin
         //remove caret
     fcanvas.save;
     fcanvas.origin:= nullpoint;
     fcanvas.clipregion:= fcanvas.createregion(fcliprect);
     fcanvas.copyarea(fbackup.canvas,makerect(nullpoint,
                          fbounds.size),fbounds.pos);
     fcanvas.restore;
     exclude(fstate,cas_showed);
    end;
   end;
  end;
 end;
end;

procedure tcaret.restart;
begin
 updatestate;
 ftimer.interval:= ftimer.interval;
 ftimer.enabled:= true;
end;

procedure tcaret.timerevent(const sender: tobject);
begin
 fstate:= caretstatesty({$ifdef FPC}longword{$else}byte{$endif}(fstate) xor byte(1 shl byte(cas_on)));
 updatestate;
end;

procedure tcaret.remove;
begin
 dec(fvisible);
 updatestate;
end;

procedure tcaret.restore;
begin
 inc(fvisible);
 updatestate;
end;

procedure tcaret.hide;
begin
 fstate:= fstate - [cas_on,cas_active];
 ftimer.enabled:= false;
 updatestate;
end;

procedure tcaret.show;
begin
 fstate:= fstate + [cas_on,cas_active];
 restart;
end;

procedure tcaret.link(canvas: tcanvas; const origin: pointty;
          const acliprect: rectty);
begin
 hide;
 fcanvas:= canvas;
 forigin:= origin;
 fbounds.pos:= origin;
 fcliprect:= moverect(acliprect,origin);
 if fcanvas = nil then begin
  fstate:= [];
 end
 else begin
  fstate:= [cas_active];
 end;
end;

function tcaret.getcliprect: rectty;
begin
 result:= removerect(fcliprect,forigin);
end;

procedure tcaret.setcliprect(const Value: rectty);
begin
 remove;
 fcliprect:= moverect(value,forigin);
 restore;
end;


function tcaret.islinkedto(canvas: tcanvas): boolean;
begin
 result:= (fcanvas <> nil) and (fcanvas = canvas);
end;

procedure tcaret.scroll(const dist: pointty; const scrollorigin: boolean);
begin
 remove;
 addpoint1(fbounds.pos,dist);
 if scrollorigin then begin
  addpoint1(forigin,dist);
  addpoint1(fcliprect.pos,dist);
 end;
 restore;
end;

procedure tcaret.move(const dist: pointty);
begin
 pos:= addpoint(pos,dist);
end;

function tcaret.active: boolean;
begin
 result:= cas_active in fstate;
end;

function tcaret.visible: boolean;
begin
 result:= fvisible > 0;
end;

end.
