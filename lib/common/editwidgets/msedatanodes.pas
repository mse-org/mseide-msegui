{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedatanodes;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 classes,msegraphutils,msedrawtext,msegraphics,msedatalist,mseglob,mseguiglob,
 msebitmap,mseclasses,mseevent,msegrids,msetypes,msestrings,mseinplaceedit,
 msestat,msegridsglob,mselist;

type

 nodestatty = (ns_expanded,ns_selected,ns_readonly,ns_checked,
               ns_subitems,ns_drawemptybox,ns_imagenrfix,
//               ns_destroying,ns_updating,ns_noowner,
               ns_checkbox,ns_showchildchecked,ns_res9,
               ns_nosubnodestat,
               ns_casesensitive,ns_sorted,ns_res13,//ns_captionclipped,
                   ns_res14,ns_res15,
                   ns_useri0,ns_useri1,ns_useri2,ns_useri3,
                          //with invalidate and statsave
                   ns_useri4,ns_useri5,ns_useri6,ns_useri7,
                          //with invalidate, no statsave
                   ns_user0,ns_user1,ns_user2,ns_user3,
                          //without invalidate, with statsave
                   ns_user4,ns_user5,ns_user6,ns_user7);
                          //without invalidate, no statsave

 nodestatesty = set of nodestatty;
 nodestate1ty = (ns1_statechanged,ns1_rootchange,ns1_candrag,
                 ns1_destroying,ns1_updating,ns1_noowner,ns1_captionclipped,
                 ns1_childchecked,ns1_checkboxclicked
                );
 nodestates1ty = set of nodestate1ty;
 
 nodeoptionty = (no_drawemptybox,no_checkbox,
                 no_updatechildchecked //track ns1_childchecked state, slow!
                 );
 nodeoptionsty = set of nodeoptionty;

const
 invalidatestates = [ns_expanded,ns_selected,ns_checked,
                     ns_subitems,ns_drawemptybox,ns_checkbox,
                     ns_useri0..ns_useri7];
 invalidateallstates = [ns_expanded];
 statstates: nodestatesty = [ns_expanded,ns_selected,ns_checked,{ns_checkbox,}
               ns_useri0..ns_useri3,ns_user0..ns_user3];
 defaultlevelstep = 10;

type
 getnodemodety = (gno_matching,gno_allchildren,gno_nochildren);
 listitemlayoutinfoty = record
  cellsize: sizety;
  captionrect: rectty;
  captioninnerrect: rectty;
  imagerect: rectty;
  textflags: textflagsty;
  expandboxrect: rectty;
  checkboxrect: rectty;
  checkboxinnerrect: rectty;
  colorline: colorty;
 end;
 plistitemlayoutinfoty = ^listitemlayoutinfoty;

 nodeactionty = (na_none,na_change,na_expand,na_collapse,na_countchange,na_destroying);
 nodeactioninfoty = record
  case action: nodeactionty of
   na_countchange: (
    treeheightbefore: integer;
   );
 end;
  
 tlistitem = class;

 iitemlist = interface(inullinterface)
  function getlayoutinfo: plistitemlayoutinfoty;
  procedure updatelayout;
  procedure itemcountchanged;
  function getcolorglyph: colorty;
  procedure updateitemvalues(const index: integer; const count: integer);
  function getcomponentstate: tcomponentstate;
 end;

 tcustomitemlist = class;

 tlistitem = class(tnullinterfacedobject)
  private
   procedure setstate(const Value: nodestatesty);
   procedure setimagenr(const Value: integer);
   function getselected: boolean;
   procedure setselected(const Value: boolean);
   function getchecked: boolean;
   function getimagelist: timagelist;
   procedure setimagelist(const Value: timagelist);
   procedure setvaluetext1(const avalue: msestring);
  protected
   fstate: nodestatesty;
   fstate1: nodestates1ty;
   findex: integer;
   fimagelist: timagelist;
   fimagenr: integer;
   fcaption: msestring;
   fowner: tcustomitemlist;
   procedure setchecked(const avalue: boolean); virtual;
   procedure setcaption(const avalue: msestring); virtual;
   function checkaction(aaction: nodeactionty): boolean;
   procedure actionnotification(var ainfo: nodeactioninfoty); virtual;
   function getactimagenr: integer; virtual;
   procedure objectevent(const sender: tobject; const event: objecteventty); virtual;
   procedure setowner(const aowner: tcustomitemlist); virtual;
  public
   tag: integer;
   tagpointer: pointer;
   constructor create(const aowner: tcustomitemlist);
   destructor destroy; override;
   class procedure calcitemlayout(const asize: sizety; const ainnerframe: framety;
                           const list: tcustomitemlist;
                              var info: listitemlayoutinfoty); virtual;

   procedure assign(source: tlistitem); overload; virtual;
   procedure beginupdate;
   procedure endupdate;

   function empty: boolean; virtual;
   procedure change;
   procedure updatecellzone(const pos: pointty; var zone: cellzonety); virtual;
   procedure drawimage(const acanvas: tcanvas); virtual;
   procedure drawcell(const acanvas: tcanvas); virtual;
   procedure mouseevent(var info: mouseeventinfoty); virtual;
   property index: integer read findex;
   procedure setupeditor(const editor: tinplaceedit; const font: tfont); virtual;

   procedure dostatupdate(const filer: tstatfiler);
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;

   function captionclipped: boolean;
   property caption: msestring read fcaption write setcaption;
   property state: nodestatesty read fstate write setstate;
   property state1: nodestates1ty read fstate1;
   property imagelist: timagelist read getimagelist write setimagelist;
                      //nil -> fowner.imagelist
   property imagenr: integer read fimagenr write setimagenr;
   property selected: boolean read getselected write setselected;
   property checked: boolean read getchecked write setchecked;
   property owner: tcustomitemlist read fowner;
   function getvaluetext: msestring; virtual;
   procedure setvaluetext(var avalue: msestring); virtual;
   property valuetext: msestring read getvaluetext write setvaluetext1;
 end;

 plistitem = ^tlistitem;
 listitemclassty = class of tlistitem;
 listitemarty = array of tlistitem;
 listitematy = array[0..0] of tlistitem;
 plistitematy = ^listitematy;

 ttreelistitem = class;
 treelistitemarty = array of ttreelistitem;
 treelistitematy = array[0..0] of ttreelistitem;
 ptreelistitematy = ^treelistitematy;
 
 treelistitemclassty = class of ttreelistitem;
 checktreelistitemprocty = procedure(const sender: ttreelistitem;
                              var delete: boolean) of object;

 ttreelistitem = class(tlistitem)
  private
   function getexpanded: boolean;
   procedure setexpanded(const Value: boolean);
   function getitems(const aindex: integer): ttreelistitem;
   procedure setitems(const aindex: integer; const value: ttreelistitem);
   procedure unsetitem(const aindex: integer);
   procedure internalcheckitems(const checkdelete: checktreelistitemprocty);
   procedure setdestroying;
   function inccount: integer; //returns itemindex
  protected
   fparent: ttreelistitem;
   fparentindex: integer;
   fitems: treelistitemarty;
   fcount: integer;
   ftreelevel: integer;
   procedure statechanged;
   procedure checksort;
   procedure setcaption(const avalue: msestring); override;
   procedure setowner(const aowner: tcustomitemlist); override;
   procedure setchecked(const avalue: boolean); override;
   procedure checkindex(const aindex: integer);
   procedure settreelevel(const value: integer);
   procedure countchange(const atreeheightbefore: integer);
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   function createsubnode: ttreelistitem; virtual;
   procedure swap(const a,b: integer);
   procedure move(const source,dest: integer);
   procedure statreadsubnode(const reader: tstatreader; var anode: ttreelistitem); virtual;
   procedure internalexpandall;
   procedure internalcollapseall;
   procedure internalgetnodes(var aresult: treelistitemarty; var acount: integer;
                       const must: nodestatesty; const mustnot: nodestatesty;
                       const amode: getnodemodety; const addself: boolean);

  public
   constructor create(const aowner: tcustomitemlist = nil;
              const aparent: ttreelistitem = nil); virtual;
   destructor destroy; override;
   class procedure calcitemlayout(const asize: sizety; const ainnerframe: framety;
                           const list: tcustomitemlist;
                              var info: listitemlayoutinfoty); override;

   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;

   procedure updatechildcheckedstate; //updates ancestors
   procedure updatechildcheckedtree; //updates self and descendents
   function parent: ttreelistitem;
   function parentindex: integer;
   function treelevel: integer;
   function levelshift: integer;
   function treeheight: integer; //total hight of children
   function rowheight: integer;  //toatal needed grid rows
   function isroot: boolean;
   function issinglerootrow: boolean; //keyrowmove can be used
   function checkdescendent(node: ttreelistitem): boolean;
                    //true if node is descendent or self
   function checkancestor(node: ttreelistitem): boolean;
                    //true if node is ancestor or self
   function isstatechanged: boolean;
   function candrag: boolean; virtual;
   function candrop(const source: ttreelistitem): boolean; virtual;

   function finditembycaption(const acaption: msestring;
            casesensitive: boolean = false): ttreelistitem; overload;
   function finditembycaption(const acaptions: msestringarty;
            casesensitive: boolean = false): ttreelistitem; overload;
   function rootnode: ttreelistitem;
   function rootpath: treelistitemarty;
             //top-down
   function rootcaptions: msestringarty;
   procedure checkitems(const checkdelete: checktreelistitemprocty);

   procedure updatecellzone(const pos: pointty; var zone: cellzonety); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure drawimage(const acanvas: tcanvas); override;
   procedure addchildren(const aitem: ttreelistitem);
                   //transfers children
   function add(const aitem: ttreelistitem): integer; overload; 
                   //returns index, nil ignored
   procedure add(const aitems: treelistitemarty); overload;
   procedure add(const acount: integer;
                            const itemclass: treelistitemclassty = nil;
                            const defaultstate: nodestatesty = []); overload;
   procedure insert(const aitem: ttreelistitem; const aindex: integer);
   procedure clear; virtual;

   function getnodes(const must: nodestatesty; 
                        const mustnot: nodestatesty;
                        const amode: getnodemodety = gno_matching;
                        const addself: boolean = false): treelistitemarty;
   function getselectednodes(const amode: getnodemodety = gno_matching;
                        const addself: boolean = false): treelistitemarty;
   function getcheckednodes(const amode: getnodemodety = gno_matching;
                        const addself: boolean = false): treelistitemarty;

   procedure expandall;
   procedure collapseall;
   procedure expandtoroot;
   procedure collapsetoroot;
   function remove(const aindex: integer): ttreelistitem;
   procedure sort(const casesensitive: boolean;
                           const recursive: boolean = false); overload;
   procedure sort(const sortfunc: arraysortcomparety;
                           const recursive: boolean = false); overload;
   property count: integer read fcount;
   procedure setupeditor(const editor: tinplaceedit; const font: tfont); override;
   property expanded: boolean read getexpanded write setexpanded;
   property items[const aindex: integer]: ttreelistitem read getitems; default;
 end;

 irecordfield = interface(inullinterface)
  function getfieldtext(const fieldindex: integer): msestring;
  procedure setfieldtext(const fieldindex: integer; var avalue: msestring);
 end;
 
 trecordfielditem = class(ttreelistitem)
  private
   ffieldindex: integer;
   fintf: irecordfield;
  protected
  public
   constructor create(const intf: irecordfield; const afieldindex: integer;
                      const acaption: msestring); reintroduce;
   function getvaluetext: msestring; override;
   procedure setvaluetext(var avalue: msestring); override;
//   property valuetext: msestring read getvaluetext write setvaluetext;
 end;

 ptreelistitem = ^ttreelistitem;

 itemliststatety = (ils_destroying,ils_subnodecountinvalid,ils_subnodecountupdating,
                    ils_freelock);
 itemliststatesty = set of itemliststatety;
 statreaditemeventty = procedure(const sender: tobject; const reader: tstatreader;
                          var aitem: tlistitem) of object;
 statreadtreeitemeventty = procedure(const sender: tobject; const reader: tstatreader;
                          var aitem: ttreelistitem) of object;

 tcustomitemlist = class(tobjectdatalist,iobjectlink)
  private
//   fobjectlinker: tobjectlinker;
   fonstatreaditem: statreaditemeventty;
   fonstatreadtreeitem: statreadtreeitemeventty;
   procedure setimnr_base(const Value: integer);
   procedure setimnr_expanded(const Value: integer);
   procedure setimnr_selected(const Value: integer);
   procedure setimnr_readonly(const Value: integer);
   procedure setimnr_checked(const Value: integer);
   procedure setimnr_subitems(const Value: integer);
//   function getobjectlinker: tobjectlinker;
   procedure objectevent(const sender: tobject;
                          const event: objecteventty); override;
   procedure setimagelist(const Value: timagelist);
   procedure setoptions(const Value: nodeoptionsty);
   procedure setcaptionpos(const Value: captionposty);
   procedure setlevelstep(const Value: integer);
   procedure setimageheight(const Value: integer);
   procedure setimagewidth(const Value: integer);
   procedure setimagesize(const avalue: sizety);
  protected
   fdefaultnodestate: nodestatesty;
   fimagelist: timagelist;
   fimagesize: sizety;
   fimnr_base: integer;
   fimnr_expanded,fimnr_selected,fimnr_readonly,fimnr_checked,
   fimnr_subitems: integer;
   flevelstep: integer;
   fintf: iitemlist;
   foptions: nodeoptionsty;
   fcaptionpos: captionposty;
   fitemstate: itemliststatesty;
   function getitems1(const index: integer): tlistitem;
   procedure setitems(const index: integer; const Value: tlistitem); 
   procedure freedata(var data); override;
   procedure change(const item: tlistitem); reintroduce; overload;
   procedure nodenotification(const sender: tlistitem;
                  var ainfo: nodeactioninfoty); virtual;
   procedure doitemchange(const index: integer); override;
   procedure invalidate; virtual;
   procedure updatelayout; virtual;
   procedure docreateobject(var instance: tobject); override;
   procedure createitem(out item: tlistitem); virtual;
   procedure statreaditem(const reader: tstatreader;
                    var aitem: tlistitem); virtual;
   procedure statreadtreeitem(const reader: tstatreader; const parent: ttreelistitem;
                    var aitem: ttreelistitem); virtual;
//   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
//                       ainterfacetype: pointer = nil; once: boolean = false);
//   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
//   procedure objevent(const sender: iobjectlink; const event: objecteventty);
//   function getinstance: tobject;

   procedure writestate(const writer; const name: msestring); override;
   procedure readstate(const reader; const acount: integer); override;

  public
   constructor create(const intf: iitemlist); reintroduce;
   destructor destroy; override;
   procedure registerobject(const aobject: iobjectlink);
    //call objectevent method of items
   procedure unregisterobject(const aobject: iobjectlink);

   function add(const aitem: tlistitem): integer; overload;
   function add(const aitem: msestring): integer; overload;
   procedure add(const aitems: listitemarty); overload;
   procedure add(const aitems: msestringarty); overload;
   procedure add(const aitems: array of msestring); overload;

   function empty(const index: integer): boolean; override;
   function indexof(const aitem: tlistitem): integer;
   function nodezone(const point: pointty): cellzonety;
   function getitems(const must: nodestatesty; 
                        const mustnot: nodestatesty): listitemarty;
   function getselecteditems: listitemarty;
   function getcheckeditems: listitemarty;
   property items[const index: integer]: tlistitem read getitems1 write setitems;
                    default;
   property imnr_base: integer read fimnr_base write setimnr_base default 0;
   property imnr_expanded: integer read fimnr_expanded write setimnr_expanded default 0;
   property imnr_selected: integer read fimnr_selected write setimnr_selected default 0;
   property imnr_readonly: integer read fimnr_readonly write setimnr_readonly default 0;
   property imnr_checked: integer read fimnr_checked write setimnr_checked default 0;
   property imnr_subitems: integer read fimnr_subitems write setimnr_subitems default 0;
   property imagelist: timagelist read fimagelist write setimagelist;
   property imagewidth: integer read fimagesize.cx write setimagewidth default 0;
   property imageheight: integer read fimagesize.cy write setimageheight default 0;
   property imagesize: sizety read fimagesize write setimagesize;
   property options: nodeoptionsty read foptions write setoptions default [];
   property captionpos: captionposty read fcaptionpos write setcaptionpos default cp_right;
   property levelstep: integer read flevelstep write setlevelstep default defaultlevelstep;
   property defaultnodestate: nodestatesty read fdefaultnodestate write fdefaultnodestate default [];

   property onstatreaditem: statreaditemeventty read fonstatreaditem
                            write fonstatreaditem;
   property onstatreadtreeitem: statreadtreeitemeventty read fonstatreadtreeitem
                            write fonstatreadtreeitem;
 end;

 ttreenode = class;
 treenodeclassty = class of ttreenode;
 treenodearty = array of ttreenode;
 nodeeventty = procedure(const sender: ttreenode) of object;
 treenodefilterfuncty = function(const sender: ttreenode): boolean of object;

 ttreenode = class
  private
   procedure setcount(const value: integer);
   procedure checkindex(const index: integer);
   procedure convertflat(const listitem: ttreelistitem; const filterfunc: treenodefilterfuncty);
   function converttree(const filterfunc: treenodefilterfuncty): ttreelistitem;
  protected
   fitems: treenodearty;
   fcount: integer;
   fparent: ttreenode;
   function getitems(const index: integer): ttreenode;
   procedure setitems(const index: integer; const Value: ttreenode);
   function treenodeclass: treenodeclassty; virtual;
   function listitemclass: treelistitemclassty; virtual;
   procedure nodetoitem(const listitem: ttreelistitem); virtual;
  public
   destructor destroy; override;
   procedure clear; virtual;
   function count: integer;
   function add(const anode: ttreenode): integer;
   procedure iterate(const event: nodeeventty);
   function converttotreelistitem(flat: boolean = false; withrootnode: boolean =  false;
                filterfunc: treenodefilterfuncty = nil): ttreelistitem;
   property items[const index: integer]: ttreenode read getitems
                                                    write setitems; default;
   property parent: ttreenode read fparent;
 end;

 ptreenode = ^ttreenode;

implementation

uses
 msestockobjects,{$ifdef FPCc}rtlconst{$else}rtlconsts{$endif},
           sysutils,msebits,msesysintf;

{ tlistitem }

constructor tlistitem.create(const aowner: tcustomitemlist);
begin
 if aowner <> nil then begin
  setowner(aowner);
 end;
 if (fowner <> nil) then begin
  fstate:= fowner.fdefaultnodestate;
 end;
end;

destructor tlistitem.destroy;
begin
 if not (ns1_destroying in fstate1) then begin
  include(fstate1,ns1_destroying);
  if (fowner <> nil) and not(ils_destroying in fowner.fitemstate) then begin
   checkaction(na_destroying);
  end;
 end;
 inherited;
end;

procedure tlistitem.assign(source: tlistitem);
begin
 beginupdate;
 tag:= source.tag;
 tagpointer:= source.tagpointer;
 caption:= source.fcaption;
 state:= source.fstate;
 imagelist:= source.fimagelist;
 imagenr:= source.fimagenr;
 endupdate;
end;

class procedure tlistitem.calcitemlayout(const asize: sizety;
        const ainnerframe: framety;
        const list: tcustomitemlist; var info: listitemlayoutinfoty);
var
 aimagesize: sizety;
const
 checkboxdist = 1;
begin
 with list do begin
  aimagesize:= fimagesize;
 end;
 with info do begin
  cellsize:= asize;
  captionrect:= makerect(nullpoint,asize);
  imagerect:= captionrect;
  if no_checkbox in list.foptions then begin
   checkboxrect.size.cx:= checkboxsize + 2*checkboxdist;
   checkboxrect.size.cy:= checkboxrect.size.cx;
   aimagesize.cx:= aimagesize.cx + checkboxrect.size.cx;
   if aimagesize.cy < checkboxsize then begin
    aimagesize.cy:= checkboxsize;
   end;
  end
  else begin
   checkboxrect.size:= nullsize;
   checkboxinnerrect.size:= nullsize;
  end;
  textflags:= [tf_xcentered,tf_ycentered];
  case list.fcaptionpos of
   cp_left,cp_lefttop,cp_leftbottom: begin
    dec(captionrect.cx,aimagesize.cx);
    imagerect.x:= captionrect.cx;
    imagerect.cx:= aimagesize.cx;
    case list.fcaptionpos of
     cp_lefttop: textflags:= [tf_right];
     cp_leftbottom: textflags:= [tf_ycentered,tf_right];
     else textflags:= [tf_bottom,tf_right];
    end;
   end;
   cp_right,cp_righttop,cp_rightbottom: begin
    captionrect.x:= aimagesize.cx;
    dec(captionrect.cx,aimagesize.cx);
    imagerect.cx:= aimagesize.cx;
    case list.captionpos of
     cp_righttop: textflags:= [];
     cp_rightbottom: textflags:= [tf_bottom];
     else textflags:= [tf_ycentered];
    end;
   end;
   cp_top,cp_topleft,cp_topright: begin
    dec(captionrect.cy,aimagesize.cy);
    imagerect.y:= captionrect.cy;
    imagerect.cy:= aimagesize.cy;
    case list.captionpos of
     cp_topleft: textflags:= [tf_ycentered];
     cp_topright: textflags:= [tf_ycentered,tf_right];
     else textflags:= [tf_ycentered,tf_xcentered];
    end;
   end;
   cp_bottom,cp_bottomleft,cp_bottomright: begin
    captionrect.y:= aimagesize.cy;
    dec(captionrect.cy,aimagesize.cy);
    imagerect.cy:= aimagesize.cy;
    case list.captionpos of
     cp_bottomleft: textflags:= [tf_ycentered];
     cp_bottomright: textflags:= [tf_ycentered,tf_right];
     else textflags:= [tf_ycentered,tf_xcentered];
    end;
   end;
  end;
  captioninnerrect:= deflaterect(captionrect,ainnerframe);
  checkboxrect.y:= imagerect.y + (imagerect.cy - checkboxrect.cy) div 2;
  checkboxrect.x:= imagerect.x;   
  if no_checkbox in list.foptions then begin
   imagerect.x:= imagerect.x + checkboxrect.cx;
   imagerect.cx:= imagerect.cx - checkboxrect.cx;
   checkboxinnerrect:= inflaterect(checkboxrect,-checkboxdist);
  end
  else begin
   checkboxinnerrect.pos:= checkboxrect.pos;
  end;
 end;
end;

procedure tlistitem.drawimage(const acanvas: tcanvas);
var
 int1: integer;
 aimagelist: timagelist;
 glyphno: stockglyphty;
begin
 aimagelist:= imagelist;
 with fowner,fintf.getlayoutinfo^ do begin
  if (no_checkbox in foptions) and (ns_checkbox in self.fstate) then begin
   glyphno:= stg_checkbox;
   if ns_checked in self.fstate then begin
    glyphno:= stg_checkboxchecked;
   end
   else begin
    if (ns_showchildchecked in self.fstate) and 
                      (ns1_childchecked in self.fstate1) then begin
     glyphno:= stg_checkboxchildchecked;
    end;
   end;
   stockobjects.glyphs.paint(acanvas,ord(glyphno),checkboxrect,
                  [al_xcentered,al_ycentered],fintf.getcolorglyph);
//   acanvas.drawframe(checkboxinnerrect,-2,cl_black);
//   if ns_checked in self.fstate then begin
//    stockobjects.paintglyph(acanvas,stg_checked,checkboxinnerrect,false,cl_black);
//   end;
  end;
  if aimagelist <> nil then begin
   int1:= getactimagenr;
   if (int1 >= 0) and (int1 < aimagelist.count) then begin
    aimagelist.paint(acanvas,int1,imagerect,[al_xcentered,al_ycentered],
                   fintf.getcolorglyph);
   end;
  end;
 end;
end;

procedure tlistitem.drawcell(const acanvas: tcanvas);
var
 info: drawtextinfoty;
 po1: pointty;
begin
 po1:= acanvas.origin;
 drawimage(acanvas); //ttreelistitem shifts origin
 with fowner.fintf.getlayoutinfo^ do begin
  info.text.text:= fcaption;
  info.text.format:= nil;
  info.dest:= captioninnerrect;
  info.flags:= textflags - [tf_clipo];
  info.font:= nil;
  info.tabulators:= nil;
  drawtext(acanvas,info);
  if not rectinrect(info.res,
      moverect(captioninnerrect,subpoint(po1,acanvas.origin))) then begin
   include(fstate1,ns1_captionclipped);
  end
  else begin
   exclude(fstate1,ns1_captionclipped);
  end;
//  drawtext(acanvas,fcaption,captioninnerrect,textflags);
 end;
end;

function tlistitem.captionclipped: boolean;
begin
 result:= ns1_captionclipped in fstate1;
end;

procedure tlistitem.updatecellzone(const pos: pointty; var zone: cellzonety);
begin
 with fowner.fintf.getlayoutinfo^ do begin
  if pointinrect(pos,captionrect) then begin
   zone:= cz_caption;
  end
  else begin
   if (ns_checkbox in fstate) and pointinrect(pos,checkboxinnerrect) then begin
    zone:= cz_checkbox;
   end
   else begin
    if pointinrect(pos,imagerect) then begin
     zone:= cz_image;
    end;
   end;
  end;
 end;
end;

procedure tlistitem.setupeditor(const editor: tinplaceedit; const font: tfont);
begin
 with fowner.fintf.getlayoutinfo^ do begin
  editor.setup(fcaption,editor.curindex,false,captioninnerrect,captionrect,nil,nil,font);
 end;
end;

procedure tlistitem.change;
var
 action: nodeactioninfoty;
begin
 if fowner <> nil {and (fowner.fnochange = 0)} then begin
  action.action:= na_change;
  fowner.nodenotification(self,action);
 end;
end;

procedure tlistitem.setcaption(const avalue: msestring);
begin
 fcaption:= avalue;
 change;
end;

procedure tlistitem.setstate(const Value: nodestatesty);
var
 stat1: nodestatesty;
begin
 stat1:= nodestatesty(longword(fstate) xor longword(value));
 fstate := Value;
 if stat1 * invalidatestates <> [] then begin
  change;
 end;
end;

procedure tlistitem.setimagenr(const Value: integer);
begin
 if fimagenr <> value then begin
  fimagenr := Value;
  change;
 end;
end;

procedure tlistitem.mouseevent(var info: mouseeventinfoty);
var
 bo1: boolean;
begin
 with info do begin
  if eventkind in mouseposevents then begin
   if pointinrect(pos,fowner.fintf.getlayoutinfo^.checkboxinnerrect) then begin
    if (eventkind = ek_buttonrelease) then begin
     if (shiftstate * keyshiftstatesmask = []) and (button = mb_left) and
       (ns1_checkboxclicked in fstate1) then begin
      checked:= not checked;
      include(eventstate,es_processed);
     end;
     exclude(fstate1,ns1_checkboxclicked);
    end
    else begin
     if (eventkind = ek_buttonpress) and
              (shiftstate * keyshiftstatesmask = []) and 
                                (button = mb_left) then begin
      include(fstate1,ns1_checkboxclicked);
     end;
    end;
   end
   else begin
    exclude(fstate1,ns1_checkboxclicked);
   end
  end;
  if eventkind in [ek_mouseleave,ek_clientmouseleave] then begin
   exclude(fstate1,ns1_checkboxclicked);
  end;
 end;
end;

function tlistitem.getselected: boolean;
begin
 result:= ns_selected in fstate;
end;

procedure tlistitem.setselected(const Value: boolean);
begin
 if value then begin
  setstate(fstate + [ns_selected]);
 end
 else begin
  setstate(fstate - [ns_selected]);
 end;
end;

function tlistitem.getchecked: boolean;
begin
 result:= ns_checked in fstate;
end;

procedure tlistitem.setchecked(const avalue: boolean);
begin
 if avalue then begin
  setstate(fstate + [ns_checked]);
 end
 else begin
  setstate(fstate - [ns_checked]);
 end;
end;

function tlistitem.checkaction(aaction: nodeactionty): boolean;
var
 action: nodeactioninfoty;
begin
 action.action:= aaction;
 actionnotification(action);
 result:= action.action = aaction;
end;

procedure tlistitem.actionnotification(var ainfo: nodeactioninfoty);
begin
 if fowner <> nil then begin
  fowner.nodenotification(self,ainfo);
 end;
end;

function tlistitem.getactimagenr: integer;
begin
 result:= fowner.fimnr_base + fimagenr;
 if not (ns_imagenrfix in fstate) then begin
  if ns_expanded in fstate then begin
   inc(result,fowner.fimnr_expanded);
  end;
  if ns_selected in fstate then begin
   inc(result,fowner.fimnr_selected);
  end;
  if ns_readonly in fstate then begin
   inc(result,fowner.fimnr_readonly);
  end;
  if ns_selected in fstate then begin
   inc(result,fowner.fimnr_selected);
  end;
  if ns_subitems in fstate then begin
   inc(result,fowner.fimnr_subitems);
  end;
 end;
end;

procedure tlistitem.setimagelist(const Value: timagelist);
begin
 if fimagelist <> value then begin
  if fowner <> nil then begin
   if (fimagelist <> nil) and (fimagelist <> fowner.imagelist) then begin
    fowner.unregisterobject(ievent(fimagelist));
   end;
   if (value <> nil) and (value <> fowner.fimagelist) then begin
    fowner.registerobject(ievent(value));
   end;
  end;
  fimagelist:= value;
  change;
 end;
end;

function tlistitem.getimagelist: timagelist;
begin
 if fimagelist = nil then begin
  if fowner <> nil then begin
   result:= fowner.fimagelist;
  end
  else begin
   result:= nil;
  end;
 end
 else begin
  result:= fimagelist;
 end;
end;

function tlistitem.getvaluetext: msestring;
begin
 result:= fcaption;
end;

procedure tlistitem.setvaluetext(var avalue: msestring);
begin
 caption:= avalue;
end;

procedure tlistitem.setvaluetext1(const avalue: msestring);
var
 str1: msestring;
begin
 str1:= avalue;
 setvaluetext(str1);
end;

procedure tlistitem.objectevent(const sender: tobject;
  const event: objecteventty);
begin
 if sender = fimagelist then begin
  case event of
   oe_destroyed: begin
    fimagelist:= nil;
    change;
   end;
   oe_changed: begin
    change;
   end;
  end;
 end;
end;

procedure tlistitem.setowner(const aowner: tcustomitemlist);
begin
 if aowner <> fowner then begin
  if (fowner <> nil) and (fimagelist <> nil) then begin
   fowner.unregisterobject(ievent(fimagelist));
  end;
  fowner:= aowner;
  if (fimagelist <> nil) and (fowner <> nil) then begin
   fowner.registerobject(ievent(fimagelist));
  end;
 end;
end;

procedure tlistitem.beginupdate;
begin
 if fowner <> nil then begin
  fowner.beginupdate;
 end;
end;

procedure tlistitem.endupdate;
begin
 if fowner <> nil then begin
  fowner.endupdate;
 end;
end;

procedure tlistitem.dostatread(const reader: tstatreader);
var
 ca1: longword;
begin
 reader.readrecord('a',[@tag,@ca1,@fimagenr,@fcaption],
             [tag,longword(fstate),fimagenr,fcaption]);
 fstate:= nodestatesty(replacebits(ca1,longword(fstate),longword(statstates)));
end;

procedure tlistitem.dostatwrite(const writer: tstatwriter);
begin
 writer.writerecord('a',[tag,longword(fstate),fimagenr,fcaption]);
end;

procedure tlistitem.dostatupdate(const filer: tstatfiler);
begin
 if filer.iswriter then begin
  dostatwrite(tstatwriter(filer));
 end
 else begin
  dostatread(tstatreader(filer));
 end;
end;

function tlistitem.empty: boolean;
begin
 result:= fcaption = '';
end;

{ tcustomitemlist }

constructor tcustomitemlist.create(const intf: iitemlist);
begin
 fintf:= intf;
 fcaptionpos:= cp_right;
 flevelstep:= defaultlevelstep;
 inherited create;
 fitemclass:= tlistitem;
end;

destructor tcustomitemlist.destroy;
begin
 include(fitemstate,ils_destroying);
 inherited;
 fobjectlinker.free;
end;

function tcustomitemlist.indexof(const aitem: tlistitem): integer;
var
 po1: ppointeraty;
 int1: integer;
begin
 result:= -1;
 normalizering;
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if tlistitem(po1^[int1]) = aitem then begin
   result:= int1;
   break;
  end;
 end;
end;

procedure tcustomitemlist.doitemchange(const index: integer);
var
 int1: integer;
 po1: ^tlistitem;
begin
 if index = -1 then begin
  po1:= datapo;
  for int1:= 0 to count - 1 do begin
   if po1^ <> nil then begin
    po1^.findex:= int1;
   end;
   inc(po1);
  end;
 end;
 inherited;
end;

function tcustomitemlist.getitems1(const index: integer): tlistitem;
begin
 result:= tlistitem(inherited items[index]);
end;

procedure tcustomitemlist.setitems(const index: integer;
  const Value: tlistitem);
begin
 inherited items[index]:= value;
end;
(*
function tcustomitemlist.getobjectlinker: tobjectlinker;
begin
 createobjectlinker(self,{$ifdef FPC}@{$endif}objectevent,
              fobjectlinker);
 result:= fobjectlinker;
end;
*)
procedure tcustomitemlist.objectevent(const sender: tobject;
                                                const event: objecteventty);
var
 int1: integer;
 po1: plistitem;
begin
 inherited;
 if event <> oe_connect then begin
  normalizering;
  po1:= plistitem(fdatapo);
  for int1:= 0 to count - 1 do begin
   po1^.objectevent(sender,event);
   inc(po1);
  end;
  if sender = fimagelist then begin
   case event of
 //   oe_destroyed: imagelist:= nil;
    oe_changed: invalidate;
   end;
  end;
 end;
end;

procedure tcustomitemlist.invalidate;
begin
 //dummy
end;

procedure tcustomitemlist.setimageheight(const Value: integer);
begin
 if fimagesize.cy <> value then begin
  fimagesize.cy := Value;
  updatelayout;
//  invalidate;
 end;
end;

procedure tcustomitemlist.setimagewidth(const Value: integer);
begin
 if fimagesize.cx <> value then begin
  fimagesize.cx := Value;
  updatelayout;
//  invalidate;
 end;
end;

procedure tcustomitemlist.setimagesize(const avalue: sizety);
begin
 if (fimagesize.cx <> avalue.cx) or (fimagesize.cy <> avalue.cy) then begin
  fimagesize:= avalue;
  updatelayout;
 end;
end;

procedure tcustomitemlist.setimagelist(const Value: timagelist);
begin
 if fimagelist <> value then begin
  setlinkedcomponent(iobjectlink(self),value,tmsecomponent(fimagelist));
  if (fimagelist <> nil) and (csdesigning in fintf.getcomponentstate) then begin
   fimagesize:= fimagelist.size;
  end;
  updatelayout;
//  invalidate;
 end;
end;

procedure tcustomitemlist.setimnr_base(const Value: integer);
begin
 if fimnr_base <> value then begin
  fimnr_base:= Value;
  invalidate;
 end;
end;

procedure tcustomitemlist.setimnr_expanded(const Value: integer);
begin
 if fimnr_expanded <> value then begin
  fimnr_expanded:= Value;
  invalidate;
 end;
end;

procedure tcustomitemlist.setimnr_selected(const Value: integer);
begin
 if fimnr_selected <> value then begin
  fimnr_selected:= Value;
  invalidate;
 end;
end;

procedure tcustomitemlist.setimnr_readonly(const Value: integer);
begin
 if fimnr_readonly <> value then begin
  fimnr_readonly:= Value;
  invalidate;
 end;
end;

procedure tcustomitemlist.setimnr_checked(const Value: integer);
begin
 if fimnr_checked <> value then begin
  fimnr_checked := Value;
  invalidate;
 end;
end;

procedure tcustomitemlist.setimnr_subitems(const Value: integer);
begin
 if fimnr_subitems <> value then begin
  fimnr_subitems := Value;
  invalidate;
 end;
end;

procedure tcustomitemlist.setoptions(const Value: nodeoptionsty);
var
 optionsbefore: nodeoptionsty;
begin
 if foptions <> value then begin
  optionsbefore:= foptions;
  foptions:= Value;
  if nodeoptionsty({$ifdef FPC}longword{$else}byte{$endif}(foptions) xor
                     {$ifdef FPC}longword{$else}byte{$endif}(optionsbefore)) *
                   [no_checkbox] <> [] then begin
   updatelayout;
  end
  else begin
   invalidate;
  end;
 end;
end;

procedure tcustomitemlist.setcaptionpos(const Value: captionposty);
begin
 if fcaptionpos <> value then begin
  fcaptionpos := Value;
  updatelayout;
 end;
end;

procedure tcustomitemlist.updatelayout;
begin
 fintf.updatelayout;
 invalidate;
end;

procedure tcustomitemlist.docreateobject(var instance: tobject);
begin
 inherited;
 if instance = nil then begin
  createitem(tlistitem(instance));
 end;
end;

procedure tcustomitemlist.createitem(out item: tlistitem);
begin
 item:= listitemclassty(fitemclass).create(self);
end;

procedure tcustomitemlist.statreaditem(const reader: tstatreader;
                              var aitem: tlistitem);
begin
 if aitem = nil then begin
  if assigned(fonstatreaditem) then begin
   fonstatreaditem(self,reader,aitem);
  end
  else begin
   createitem(aitem);
  end;
 end;
end;

procedure tcustomitemlist.statreadtreeitem(const reader: tstatreader; const parent: ttreelistitem;
                    var aitem: ttreelistitem);
begin
 if aitem = nil then begin
  if assigned(fonstatreadtreeitem) then begin
   fonstatreadtreeitem(self,reader,aitem);
  end
  else begin
   if parent <> nil then begin
    aitem:= parent.createsubnode;
   end
   else begin
    createitem(tlistitem(aitem));
   end;
  end;
 end;
end;
{
procedure tcustomitemlist.link(const source,dest: iobjectlink; valuepo: pointer = nil;
                    ainterfacetype: pointer = nil; once: boolean = false);
begin
 getobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tcustomitemlist.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
begin
 getobjectlinker.unlink(source,dest,valuepo);
end;

procedure tcustomitemlist.objevent(const sender: iobjectlink; const event: objecteventty);
begin
 getobjectlinker.objevent(sender,event);
end;

function tcustomitemlist.getinstance: tobject;
begin
 result:= self;
end;
}
function tcustomitemlist.nodezone(const point: pointty): cellzonety;
begin
 result:= cz_default;
 with fintf.getlayoutinfo^ do begin
  if pointinrect(point,captionrect) then begin
   result:= cz_caption;
  end
  else begin
   if pointinrect(point,imagerect) then begin
    result:= cz_image;
   end;
  end;
 end;
end;

procedure tcustomitemlist.nodenotification(const sender: tlistitem;
                     var ainfo: nodeactioninfoty);
begin
 if (ainfo.action = na_change) then begin
  change(sender);
 end;
end;

procedure tcustomitemlist.freedata(var data);
begin
 if (tlistitem(data) <> nil) and 
               not (ns1_destroying in tlistitem(data).fstate1) then begin
  inherited;
 end;
end;

procedure tcustomitemlist.change(const item: tlistitem);
begin
 if item = nil then begin
  change(-1);
 end
 else begin
  change(item.findex);
 end;
end;

procedure tcustomitemlist.setlevelstep(const Value: integer);
begin
 if flevelstep <> value then begin
  flevelstep := Value;
  change(-1);
 end;
end;

procedure tcustomitemlist.registerobject(const aobject: iobjectlink);
begin
 getobjectlinker.link(iobjectlink(self),aobject);
end;

procedure tcustomitemlist.unregisterobject(const aobject: iobjectlink);
begin
 getobjectlinker.unlink(iobjectlink(self),aobject);
end;

function tcustomitemlist.add(const aitem: tlistitem): integer;
begin
 result:= inherited add(aitem);
 aitem.setowner(self);
end;

procedure tcustomitemlist.add(const aitems: array of msestring);
var
 int1,int2: integer;
 po1: plistitem;
begin
 beginupdate;
 try
  int1:= count;
  count:= count + length(aitems);
  po1:= datapo;
  inc(po1,int1);
  for int2:= 0 to high(aitems) do begin
   po1^.caption:= aitems[int2];
   inc(po1);
  end;
 finally
  endupdate;
 end;
end;

procedure tcustomitemlist.add(const aitems: msestringarty);
var
 int1,int2: integer;
 po1: plistitem;
begin
 beginupdate;
 try
  int1:= count;
  count:= count + length(aitems);
  po1:= datapo;
  inc(po1,int1);
  for int2:= 0 to high(aitems) do begin
   po1^.caption:= aitems[int2];
   inc(po1);
  end;
 finally
  endupdate;
 end;
end;

function tcustomitemlist.add(const aitem: msestring): integer;
begin
 add([aitem]);
end;

procedure tcustomitemlist.add(const aitems: listitemarty);
var
 int1: integer;
begin
 beginupdate;
 try
  for int1:= 0 to high(aitems) do begin
   add(aitems[int1]);
  end;
 finally
  endupdate;
 end;
end;

procedure tcustomitemlist.writestate(const writer; const name: msestring);
var
 int1: integer;
begin
 with tstatwriter(writer) do begin
  writeinteger(name,count);
  for int1:= 0 to count - 1 do begin
   beginlist;
   items[int1].dostatwrite(tstatwriter(writer));
   endlist;
  end;
 end;
end;

procedure tcustomitemlist.readstate(const reader; const acount: integer);
var
 int1: integer;
 item1: tlistitem;
begin
 with tstatreader(reader) do begin
  int1:= acount;
  if int1 >= 0 then begin
   beginupdate;
   try
    clear;
    for int1:= 0 to acount - 1 do begin
     beginlist;
     item1:= nil;
     statreaditem(tstatreader(reader),item1);
     if item1 <> nil then begin
      add(item1);
      item1.dostatread(tstatreader(reader));
     end;
     endlist;
    end;
   finally
    endupdate;
   end;
  end;
 end;
end;

function tcustomitemlist.getitems(const must: nodestatesty; 
                        const mustnot: nodestatesty): listitemarty;
var
 int1: integer;
 int2: integer;
 item1: tlistitem;
 po1: ppointeraty;
begin
 result:= nil;
 int2:= 0;
 po1:= datapo;
 for int1:= 0 to count - 1 do begin
  item1:= tlistitem(po1^[int1]);
  with item1 do begin
   if (fstate * must = must) and (fstate * mustnot = []) then begin
    if int2 > high(result) then begin
     setlength(result,10+length(result)*2);
    end;
    result[int2]:= item1;
    inc(int2);
   end;
  end;
 end;
 setlength(result,int2);
end;

function tcustomitemlist.getselecteditems: listitemarty;
begin
 result:= getitems([ns_selected],[]);
end;

function tcustomitemlist.getcheckeditems: listitemarty;
begin
 result:= getitems([ns_checked],[]);
end;

function tcustomitemlist.empty(const index: integer): boolean;
var
 item1: tlistitem;
begin
 item1:= items[index];
 result:= (item1 = nil) or item1.empty;
end;

{ ttreelistitem }

constructor ttreelistitem.create(const aowner: tcustomitemlist = nil;
                      const aparent: ttreelistitem = nil);
begin
 if aparent <> nil then begin
  if aparent <> fparent then begin
   fparent:= aparent;
   fparentindex:= -1;
  end;
 end;
 if fparent = nil then begin
  fparentindex:= -1;
 end;
 inherited create(aowner);
end;

destructor ttreelistitem.destroy;
begin
 if not (ns1_destroying in fstate1) then begin
  include(fstate1,ns1_destroying);
  if (fowner <> nil) and not (ils_destroying in fowner.fitemstate) then begin
   checkaction(na_destroying);
  end;
 end;
 if (fparent <> nil) and not (ns1_destroying in fparent.fstate1)  then begin
  fparent.remove(fparentindex);
 end;
 clear;
 inherited;
end;

procedure ttreelistitem.countchange(const atreeheightbefore: integer);
var
 info1: nodeactioninfoty;
begin
 if (fowner <> nil) then begin
  info1.action:= na_countchange;
  info1.treeheightbefore:= atreeheightbefore;
  fowner.nodenotification(self,info1);
 end;
 if fcount > 0 then begin
  state:= fstate + [ns_subitems];
 end
 else begin
  state:= fstate - [ns_subitems];
 end;
end;

function ttreelistitem.getitems(const aindex: integer): ttreelistitem;
begin
 checkindex(aindex);
 result:= fitems[aindex];
end;

procedure ttreelistitem.setitems(const aindex: integer; const value: ttreelistitem);
 //for internal use
begin
 fitems[aindex]:= value;
 value.fparentindex:= aindex;
 value.fparent:= self;
 value.settreelevel(ftreelevel+1);
 value.setowner(fowner);
 checksort;
end;

procedure ttreelistitem.unsetitem(const aindex: integer);
begin
 with fitems[aindex] do begin
  fparent:= nil;
  fparentindex:= -1;
  setowner(nil);
  settreelevel(0);
 end;
end;

function ttreelistitem.inccount: integer; //returns itemindex
begin
 result:= fcount;
 if fcount > high(fitems) then begin
  setlength(fitems,(fcount*8) div 7 + 16);
 end;
 inc(fcount)
end;

function ttreelistitem.add(const aitem: ttreelistitem): integer;
var
 int1: integer;
begin
 if aitem <> nil then begin
  if aitem.parent = self then begin
   move(aitem.parentindex,fcount-1);
  end
  else begin
   if aitem.fparent <> nil then begin
    aitem.fparent.remove(aitem.fparentindex);
   end;
   int1:= treeheight;
   result:= fcount;
   setitems(inccount,aitem);
   countchange(int1);
  end;
 end;
end;

procedure ttreelistitem.insert(const aitem: ttreelistitem; const aindex: integer);
begin
 if aitem.parent = self then begin
  move(aitem.parentindex,aindex);
 end
 else begin
  move(add(aitem),aindex);
 end;
end;

procedure ttreelistitem.add(const aitems: treelistitemarty);
var
 int1,int2: integer;
begin
 if length(aitems) > 0 then begin
  int2:= treeheight;
  if fcount + length(aitems) >= length(fitems) then begin
   setlength(fitems,fcount + length(aitems));
  end;
  for int1:= 0 to high(aitems) do begin
   setitems(fcount,aitems[int1]);
   inc(fcount);
  end;
  countchange(int2);
 end;
end;

procedure ttreelistitem.addchildren(const aitem: ttreelistitem);
                   //transfers children
begin
 setlength(aitem.fitems,aitem.fcount);
 add(aitem.fitems);
 aitem.fcount:= 0;
end;

function ttreelistitem.createsubnode: ttreelistitem;
begin
 result:= treelistitemclassty(classtype).create(fowner);
end;

procedure ttreelistitem.swap(const a,b: integer);
var
 item1: ttreelistitem;
begin
 checkindex(a);
 checkindex(b);
 item1:= fitems[a];
 item1.fparentindex:= b;
 fitems[a]:= fitems[b];
 fitems[a].fparentindex:= a;
 fitems[b]:= item1;
end;

procedure ttreelistitem.move(const source,dest: integer);
var
 int1: integer;
begin
 checkindex(source);
 checkindex(dest);
 moveitem(pointerarty(fitems),source,dest);
 if source < dest then begin
  for int1:= source to dest do begin
   fitems[int1].fparentindex:= int1;
  end;
 end
 else begin
  for int1:= dest to source do begin
   fitems[int1].fparentindex:= int1;
  end;
 end;
end;

procedure ttreelistitem.add(const acount: integer;
                            const itemclass: treelistitemclassty = nil;
                            const defaultstate: nodestatesty = []);
var
 int1,int2: integer;
begin
 int2:= treeheight;
 if length(fitems) < fcount + acount then begin
  setlength(fitems,fcount + acount);
 end;
 if itemclass <> nil then begin
  for int1:= 0 to acount-1 do begin
   setitems(fcount,itemclass.create);
   if defaultstate <> [] then begin
    fitems[count].fstate:= defaultstate;
   end;
   inc(fcount);
  end;
 end
 else begin
  for int1:= 0 to acount-1 do begin
   setitems(fcount,createsubnode);
   if defaultstate <> [] then begin
    fitems[count].fstate:= defaultstate;
   end;
   inc(fcount);
  end;
 end;
 countchange(int2);
end;

procedure ttreelistitem.setdestroying;
var
 int1: integer;
begin
 include(fstate1,ns1_destroying);
 for int1:= 0 to fcount - 1 do begin
  fitems[int1].setdestroying;
 end;
end;

procedure ttreelistitem.clear;
var
 int1,int2: integer;
 acount: integer;
 aitems: treelistitemarty;
 adestroying: boolean;
begin
 aitems:= nil; //compilerwarning
 if fcount > 0 then begin
  int2:= treeheight;
  adestroying:= ns1_destroying in fstate1;
  if not (ns1_noowner in fstate1) then begin
   setdestroying;
  end;
  aitems:= fitems;
  fitems:= nil;
  acount:= fcount;
  fcount:= 0;
  countchange(int2);
  if not (ns1_noowner in fstate1) then begin
   for int1:= 0 to acount-1 do begin
    with aitems[int1] do begin
     if not adestroying then begin
      setowner(nil);
     end;
     Free;
    end;
   end;
  end;
  if not adestroying then begin
   exclude(fstate1,ns1_destroying);
  end;
 end;
 fitems:= nil; //ev. free unused memory
 exclude(fstate1,ns1_noowner);
end;

procedure ttreelistitem.internalgetnodes(var aresult: treelistitemarty;
                var acount: integer;
                const must: nodestatesty; const mustnot: nodestatesty;
                const amode: getnodemodety; const addself: boolean);

 procedure addchi(anode: ttreelistitem);
 var
  int1: integer;
 begin
  with anode do begin
   for int1:= 0 to fcount - 1 do begin
    if acount > high(aresult) then begin
     setlength(aresult,10+length(aresult)*2);
    end;
    aresult[acount]:= fitems[int1];
    inc(acount);
    addchi(fitems[int1]);
   end;
  end;
 end; //addchi

var
 first: boolean;
 
 procedure check(anode: ttreelistitem);
 var
  int1: integer;
  bo1: boolean;
 begin
  with anode do begin
   if not first then begin
    bo1:= (fstate * must = must) and (fstate * mustnot = []);
    if bo1 then begin
     if acount > high(aresult) then begin
      setlength(aresult,10+length(aresult)*2);
     end;
     aresult[acount]:= anode;
     inc(acount);
    end;
   end
   else begin
    first:= false;
    bo1:= false;
   end;
   case amode of
    gno_nochildren: begin
     if bo1 then begin
      exit;
     end;
    end;
    gno_allchildren: begin
     if bo1 then begin
      addchi(anode);
      exit;
     end;
    end;
   end;
   for int1:= 0 to fcount - 1 do begin
    check(fitems[int1]);
   end;
  end;
 end; //check
 
begin
 first:= not addself;
 check(self);
end;

function ttreelistitem.getnodes(const must: nodestatesty; 
                  const mustnot: nodestatesty; 
                  const amode: getnodemodety = gno_matching;
                  const addself: boolean = false): treelistitemarty;
var
 int2: integer;
begin
 result:= nil;
 int2:= 0;
 internalgetnodes(result,int2,must,mustnot,amode,addself);
 setlength(result,int2);
end;

function ttreelistitem.getselectednodes(
                    const amode: getnodemodety = gno_matching;
                    const addself: boolean = false): treelistitemarty;
begin
 result:= getnodes([ns_selected],[],amode);
end;

function ttreelistitem.getcheckednodes(
                    const amode: getnodemodety = gno_matching;
                    const addself: boolean = false): treelistitemarty;
begin
 result:= getnodes([ns_checked],[],amode,addself);
end;


procedure ttreelistitem.internalcollapseall;
var
 int1: integer;
begin
 expanded:= false;
 for int1:= 0 to count - 1 do begin
  fitems[int1].internalcollapseall;
 end;
end;

procedure ttreelistitem.collapseall;
begin
 beginupdate;
 try
  internalcollapseall;
 finally
  endupdate;
 end;
end;

procedure ttreelistitem.internalexpandall;
var
 int1: integer;
begin
 expanded:= true;
 for int1:= 0 to count - 1 do begin
  fitems[int1].internalexpandall;
 end;
end;

procedure ttreelistitem.expandall;
begin
 beginupdate;
 try
  internalexpandall;
 finally
  endupdate;
 end;
end;

procedure ttreelistitem.expandtoroot;
var
 item1: ttreelistitem;
begin
 item1:= fparent;
 while item1 <> nil do begin
  item1.expanded:= true;
  item1:= item1.fparent;
 end;
end;

procedure ttreelistitem.collapsetoroot;
var
 item1: ttreelistitem;
begin
 item1:= fparent;
 while item1 <> nil do begin
  item1.expanded:= false;
  item1:= item1.fparent;
 end;
end;

procedure ttreelistitem.internalcheckitems(
                 const checkdelete: checktreelistitemprocty);
var
 int1,int2: integer;
 bo1,bo2: boolean;
 ar1: treelistitemarty;
 aitem: ttreelistitem;
begin
 bo1:= false;
 for int1:= 0 to fcount - 1 do begin
  aitem:= fitems[int1];
  aitem.internalcheckitems(checkdelete);
  bo2:= false;
  checkdelete(aitem,bo2);
  if bo2 then begin
   aitem.fparent:= nil;
   aitem.fowner:= nil;
   fitems[int1]:= nil;
   aitem.Free;
   bo1:= true;
  end;
 end;
 if bo1 then begin
  setlength(ar1,fcount);
  int2:= 0;
  for int1:= 0 to fcount -1 do begin
   if fitems[int1] <> nil then begin
    ar1[int2]:= fitems[int1];
    ar1[int2].fparentindex:= int2;
    inc(int2);
   end;
  end;
  setlength(ar1,int2);
  fcount:= int2;
  fitems:= ar1;
 end;
end;

procedure ttreelistitem.checkitems(const checkdelete: checktreelistitemprocty);
var
 int1: integer;
begin
 int1:= treeheight;
 internalcheckitems(checkdelete);
 countchange(int1);
end;

function ttreelistitem.remove(const aindex: integer): ttreelistitem;
var
 int1,int2: integer;
begin
 checkindex(aindex);
 int2:= treeheight;
 result:= fitems[aindex];
 unsetitem(aindex);
 int1:= (fcount-aindex-1)*sizeof(pointer);
 if int1 > 0 then begin
  system.move(fitems[aindex+1],fitems[aindex],int1);
 end;
 dec(fcount);
 for int1:= aindex to fcount-1 do begin
  fitems[int1].fparentindex:= int1;
 end;
 countchange(int2);
end;

function comparetreelistitemcasesensitive(const l,r): integer;
begin
// result:= msecomparetext(ttreelistitem(l).caption,ttreelistitem(r).caption);
 result:= msestringcomp(ttreelistitem(l).caption,ttreelistitem(r).caption);
end;

function comparetreelistitemcaseinsensitive(const l,r): integer;
begin
// result:= msecomparestr(ttreelistitem(l).caption,ttreelistitem(r).caption);
 result:= msestringicomp(ttreelistitem(l).caption,ttreelistitem(r).caption);
end;

procedure ttreelistitem.sort(const casesensitive: boolean;
                                        const recursive: boolean = false);
var
 int1: integer;
begin
 setlength(fitems,fcount);
 if casesensitive then begin
  sortarray(pointerarty(fitems),{$ifdef FPC}@{$endif}comparetreelistitemcasesensitive);
 end
 else begin
  sortarray(pointerarty(fitems),{$ifdef FPC}@{$endif}comparetreelistitemcaseinsensitive);
 end;
 for int1:= 0 to high(fitems) do begin
  fitems[int1].fparentindex:= int1;
 end;
 if recursive then begin
  for int1:= 0 to high(fitems) do begin
   fitems[int1].sort(casesensitive,true);
  end;
 end;
 change;
end;

procedure ttreelistitem.sort(const sortfunc: arraysortcomparety;
                           const recursive: boolean = false);
var
 int1: integer;
begin
 setlength(fitems,fcount);
 sortarray(pointerarty(fitems),sortfunc);
 for int1:= 0 to high(fitems) do begin
  fitems[int1].fparentindex:= int1;
 end;
 if recursive then begin
  for int1:= 0 to high(fitems) do begin
   fitems[int1].sort(sortfunc,true);
  end;
 end;
 change; 
end;

procedure ttreelistitem.checksort;
begin
 if ns_sorted in fstate then begin
  sort(ns_casesensitive in fstate);
 end;
end;

procedure ttreelistitem.setcaption(const avalue: msestring);
begin
 inherited;
 if fparent <> nil then begin
  fparent.checksort;
 end;
end;

procedure ttreelistitem.setowner(const aowner: tcustomitemlist);
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to fcount - 1 do begin
  fitems[int1].setowner(aowner);
 end;
 change;
end;

procedure ttreelistitem.updatechildcheckedstate;
var
 node1: ttreelistitem;
 int1: integer;
begin
 node1:= fparent;
 if ns_checked in fstate then begin
  while (node1 <> nil) and (ns_showchildchecked in node1.fstate) and
                               not (ns1_childchecked in node1.fstate1) do begin
   include(node1.fstate1,ns1_childchecked);
   node1.change;
   node1:= node1.fparent;
  end;
 end
 else begin
  if not (ns_showchildchecked in fstate) or
                     not (ns1_childchecked in fstate1) then begin
   while (node1 <> nil) and (ns_showchildchecked in node1.fstate) and
                                 (ns1_childchecked in node1.fstate1) do begin
    with node1 do begin
     for int1:= 0 to fcount-1 do begin
      with fitems[int1] do begin
       if (ns_checked in fstate) or
                         (ns_showchildchecked in fstate) and
                         (ns1_childchecked in fstate1) then begin
        exit;
       end;
      end;
     end;
     exclude(fstate1,ns1_childchecked);
     change;
     if ns_checked in fstate then begin
      exit;
     end;
     node1:= fparent;
    end;
   end;
  end;
 end;
end;

procedure ttreelistitem.updatechildcheckedtree;
var
 int1: integer;
begin
 updatechildcheckedstate;
 for int1:= 0 to fcount-1 do begin
  with fitems[int1] do begin
   updatechildcheckedtree;
  end;
 end;
end;

procedure ttreelistitem.setchecked(const avalue: boolean);
begin
 if avalue xor (ns_checked in fstate) then begin
  inherited;
  if (fowner <> nil) and (no_updatechildchecked in fowner.foptions) then begin
   updatechildcheckedstate;
  end;
 end;
end;

procedure ttreelistitem.drawimage(const acanvas: tcanvas);
var
 boxno: integer;
 int1: integer;
 {$ifdef mswindows}
 int2: integer;
 {$endif}
 item1: ttreelistitem;
 seg: segmentty;
 lines: segmentarty;
 cellheight{,boxy}: integer;

begin
 if (fcount = 0) and not (ns_subitems in fstate) then begin
  if (ns_drawemptybox in fstate) or (no_drawemptybox in fowner.foptions) then begin
   boxno:= integer(stg_box);
  end
  else begin
   boxno:= -1;
  end;
 end
 else begin
  if ns_expanded in fstate then begin
   boxno:= integer(stg_boxexpanded);
  end
  else begin
   boxno:= integer(stg_boxexpand);
  end;
 end;
 setlength(lines,ftreelevel+2); //last line can be doubled + horz. line
 acanvas.move(makepoint(levelshift,0));
 with fowner,fintf.getlayoutinfo^ do begin
  cellheight:= cellsize.cy;
  seg.a.x:= (expandboxrect.x + expandboxrect.cx) div 2;
  seg.a.y:= 0;
  seg.b.x:= seg.a.x;
  seg.b.y:= cellheight-1;
  item1:= self;
  int1:= 0;
  while item1.fparent <> nil do begin
   if (item1.fparentindex <> item1.fparent.fcount - 1) or (int1 = 0) then begin
    lines[int1]:= seg;
    inc(int1);
   end;
   dec(seg.a.x,flevelstep);
   seg.b.x:= seg.a.x;
   item1:= item1.fparent;
  end;
  if int1 > 0 then begin
   if fparentindex <> fparent.fcount - 1 then begin
    if boxno >= 0 then begin
     lines[0].b.y:= expandboxrect.y-1; //top of splited vert.
     lines[int1]:= lines[0];
     with lines[int1] do begin
      a.y:= b.y + expandboxrect.cy;    //bottom of splited vert.
      b.y:= cellheight-1;
     end;
     inc(int1);
    end;
   end 
   else begin //last vert.
    if boxno >= 0 then begin
     lines[0].b.y:= expandboxrect.y-1; //to top of box
    end
    else begin
     lines[0].b.y:= cellheight div 2;
    end;
   end;
   with lines[int1] do begin
    if boxno >= 0 then begin
     dec(int1);
//     a.x:= expandboxrect.x + expandboxrect.cx;
//     a.x:= lines[0].a.x + 1;
    end
    else begin
     a.y:= cellheight div 2;
     b.y:= a.y;
     a.x:= lines[0].a.x + 1;
//     b.x:= imagerect.x - 1; //horizontal line
     b.x:= checkboxrect.x - 1; //horizontal line
     if b.x < a.x then begin
      dec(int1);
     end;
    end;
   end;
   setlength(lines,int1+1);
   drawdottedlinesegments(acanvas,lines,colorline);
  end;
  if boxno >= 0 then begin
   stockobjects.glyphs.paint(acanvas,boxno,expandboxrect,
                  [al_xcentered,al_ycentered],fintf.getcolorglyph);
  end;
 end;
 inherited;
end;

procedure ttreelistitem.setupeditor(const editor: tinplaceedit; const font: tfont);
var
 str1: msestring;
 rect1,rect2: rectty;
 int1: integer;
begin
 if fowner <> nil then begin
  str1:= fcaption;            //!!!!todo fpcerror 3197
  with fowner.fintf.getlayoutinfo^ do begin
   rect1:= captionrect;
   rect2:= captioninnerrect;
  end;
  int1:= levelshift;
  inc(rect1.x,int1);
  dec(rect1.cx,int1);
  inc(rect2.x,int1);
  dec(rect2.cx,int1);
  editor.setup(str1,editor.curindex,false,rect2,rect1,nil,nil,font);
 end;
end;

class procedure ttreelistitem.calcitemlayout(const asize: sizety; 
                  const ainnerframe: framety; const list: tcustomitemlist;
                                              var info: listitemlayoutinfoty);
var
 boxdist: integer;
begin
 info.colorline:= cl_gray;
 inherited;
 boxdist:= boxsize + 2;
 with info.captionrect do begin
  inc(x,boxdist);
  dec(cx,boxdist);
 end;
 with info.captioninnerrect do begin
  inc(x,boxdist);
  dec(cx,boxdist);
 end;
// if no_checkbox in list.options then begin
  with info.checkboxrect do begin
   inc(x,boxdist);
  end;
  with info.checkboxinnerrect do begin
   inc(x,boxdist);
  end;
// end;
 inc(info.imagerect.x,boxdist);
 with info.expandboxrect do begin
  x:= 0;
  y:= (asize.cy - boxsize) div 2;
  cx:= boxsize;
  cy:= boxsize;
 end;
end;

procedure ttreelistitem.updatecellzone(const pos: pointty; var zone: cellzonety);
var
 po1: pointty;
begin
 po1:= pos;
 dec(po1.x,levelshift);
 inherited updatecellzone(po1,zone);
end;

procedure ttreelistitem.mouseevent(var info: mouseeventinfoty);
begin
 with info do begin
  dec(pos.x,levelshift);
  try
   inherited;
   if (eventkind = ek_buttonpress) and
         (shiftstate * keyshiftstatesmask = []) and (button = mb_left) and
     pointinrect(pos,fowner.fintf.getlayoutinfo^.expandboxrect) then begin
    expanded:= not expanded;
    include(eventstate,es_processed);
   end;
  finally
   inc(pos.x,levelshift);
  end;
 end;
end;

function ttreelistitem.getexpanded: boolean;
begin
 result:= ns_expanded in fstate;
end;

procedure ttreelistitem.statechanged;
begin
 include(fstate1,ns1_statechanged);
 if ns1_rootchange in fstate1 then begin
  include(rootnode.fstate1,ns1_statechanged);
 end;
end;

procedure ttreelistitem.setexpanded(const Value: boolean);
begin
 if value then begin
  if not (ns_expanded in fstate) then begin
   if checkaction(na_expand) then begin
    include(fstate,ns_expanded);
    statechanged;
   end;
  end;
 end
 else begin
  if ns_expanded in fstate then begin
   if checkaction(na_collapse) then begin
    exclude(fstate,ns_expanded);
    statechanged;
   end;
  end;
 end;
end;

procedure ttreelistitem.checkindex(const aindex: integer);
begin
 if (aIndex < 0) or (aIndex >= FCount) then begin
  tlist.Error(SListIndexError, aIndex);
 end;
end;

procedure ttreelistitem.settreelevel(const value: integer);
var
 int1: integer;
begin
 ftreelevel:= value;
 for int1:= 0 to fcount - 1 do begin
  fitems[int1].settreelevel(value+1);
 end;
end;

function ttreelistitem.treelevel: integer;
begin
 result:= ftreelevel;
end;

function ttreelistitem.levelshift: integer;
begin
 if fowner <> nil then begin
  result:= ftreelevel*fowner.flevelstep;
 end
 else begin
  result:= 0;
 end;
end;

function ttreelistitem.treeheight: integer; //total hight of children
var
 int1: integer;
begin
 result:= 0;
 for int1:= 0 to fcount - 1 do begin
  inc(result);
  with ttreelistitem(fitems[int1]) do begin
   if expanded then begin
    result:= result + treeheight;
   end;
  end;
 end;
end;

function ttreelistitem.rowheight: integer;  //total needed grid rows
begin
 if expanded then begin
  result:= treeheight + 1;
 end
 else begin
  result:= 1;
 end;
end;

function ttreelistitem.finditembycaption(const acaption: msestring;
         casesensitive: boolean = false): ttreelistitem;
var
 int1: integer;
 compfunc: function(const a,b: msestring): integer;
begin
 result:= nil;
 if casesensitive then begin
  compfunc:= {$ifdef FPC}@{$endif}msecomparestr;
 end
 else begin
  compfunc:= {$ifdef FPC}@{$endif}msecomparetext;
 end;
 for int1:= 0 to fcount - 1 do begin
  if compfunc(acaption,fitems[int1].fcaption) = 0 then begin
   result:= fitems[int1];
   break;
  end;
 end;
end;

function ttreelistitem.finditembycaption(const acaptions: msestringarty;
         casesensitive: boolean = false): ttreelistitem;
var
 int1: integer;
begin
 result:= self;
 for int1:= 0 to high(acaptions) do begin
  result:= result.finditembycaption(acaptions[int1],casesensitive);
  if result = nil then begin
   break;
  end;
 end;
end;

function ttreelistitem.parent: ttreelistitem;
begin
 result:= fparent;
end;

function ttreelistitem.isroot: boolean;
begin
 result:= fparent = nil;
end;

function ttreelistitem.issinglerootrow: boolean;
begin
 result:= (treelevel = 0) and (not expanded or (count = 0));
end; 

function ttreelistitem.checkdescendent(node: ttreelistitem): boolean;
                    //true if node is descendent or self
begin
 result:= false;
 while node <> nil do begin
  if node = self then begin
   result:= true;
   break;
  end;
  node:= node.parent;
 end;
end;

function ttreelistitem.checkancestor(node: ttreelistitem): boolean;
                    //true if node is ancestor or self
begin
 result:= (node <> nil) and node.checkdescendent(self);
end;

function ttreelistitem.parentindex: integer;
begin
 if fparent <> nil then begin
  result:= fparentindex;
 end
 else begin
  result:= -1;
 end;
end;

function ttreelistitem.rootpath: treelistitemarty;
var
 int1: integer;
 item: ttreelistitem;
begin
 setlength(result,ftreelevel+1);
 int1:= ftreelevel;
 item:= self;
 while int1 >= 0 do begin
  result[int1]:= item;
  item:= item.fparent;
  dec(int1);
 end;
end;

function ttreelistitem.rootnode: ttreelistitem;
begin
 result:= self;
 while result.fparent <> nil do begin
  result:= result.fparent;
 end;
end;

function ttreelistitem.rootcaptions: msestringarty;
var
 int1: integer;
 item: ttreelistitem;
begin
 setlength(result,ftreelevel+1);
 item:= self;
 for int1:= high(result) downto 0 do begin
  result[int1]:= item.fcaption;
  item:= item.fparent;
 end;
end;

procedure ttreelistitem.objectevent(const sender: tobject;
  const event: objecteventty);
var
 int1: integer;
begin
 for int1:= 0 to fcount - 1 do begin
  fitems[int1].objectevent(sender,event);
 end;
 inherited;
end;

procedure ttreelistitem.statreadsubnode(const reader: tstatreader; var anode: ttreelistitem);
begin
 if fowner <> nil then begin
  fowner.statreadtreeitem(reader,self,anode);
 end
 else begin
  if anode = nil then begin
   anode:= createsubnode;
  end;
 end;
end;

procedure ttreelistitem.dostatread(const reader: tstatreader);
var
 int1,int2: integer;
 node1: ttreelistitem;
 bo1: boolean;
begin
 inherited;
 if not (ns_nosubnodestat in fstate) then begin
  clear;
  int1:= reader.readinteger('c',-1,0,bigint);
  if int1 > 0 then begin
   bo1:= ns_sorted in fstate;
   exclude(fstate,ns_sorted);
   for int1:= 0 to int1 - 1 do begin
    if not reader.beginlist then begin
     break;
    end;
    node1:= nil;
    statreadsubnode(reader,node1);
    if node1 <> nil then begin
     setitems(inccount,node1);
     node1.dostatread(reader);
    end;
    reader.endlist;
   end;
   if bo1 then begin
    include(fstate,ns_sorted);
    checksort;
   end;
   countchange(0);
  end;
 end;
 exclude(fstate1,ns1_statechanged);
end;

procedure ttreelistitem.dostatwrite(const writer: tstatwriter);
var
 int1: integer;
begin
 inherited;
 if (fcount > 0) and not (ns_nosubnodestat in fstate) then begin
  writer.writeinteger('c',fcount);
  for int1:= 0 to fcount - 1 do begin
   writer.beginlist;
   fitems[int1].dostatwrite(writer);
   writer.endlist;
  end;
 end;
end;

function ttreelistitem.isstatechanged: boolean;
begin
 result:= ns1_statechanged in fstate1;
end;

function ttreelistitem.candrag: boolean;
begin
 result:= ns1_candrag in fstate1;
end;

function ttreelistitem.candrop(const source: ttreelistitem): boolean;
begin
 result:= false;
end;

{ trecordfielditem }

constructor trecordfielditem.create(const intf: irecordfield;
               const afieldindex: integer; const acaption: msestring);
begin
 fintf:= intf;
 ffieldindex:= afieldindex;
 inherited create;
 fcaption:= acaption;
end;

function trecordfielditem.getvaluetext: msestring;
begin
 if fintf <> nil then begin
  result:= fintf.getfieldtext(ffieldindex);
 end
 else begin
  result:= inherited getvaluetext;
 end;
end;

procedure trecordfielditem.setvaluetext(var avalue: msestring);
begin
 if fintf <> nil then begin
  fintf.setfieldtext(ffieldindex,avalue);
 end
 else begin
  inherited;
 end;
end;

{ ttreenode }

destructor ttreenode.destroy;
begin
 clear;
 inherited;
end;

procedure ttreenode.clear;
var
 int1: integer;
begin
 for int1:= 0 to fcount - 1 do begin
  fitems[int1].Free;
 end;
 fcount:= 0;
 fitems:= nil;
end;

function ttreenode.add(const anode: ttreenode): integer;
begin
 result:= fcount;
 setcount(fcount + 1);
 items[fcount-1]:= anode;
end;

procedure ttreenode.setcount(const value: integer);
begin
 if high(fitems) <= value then begin
  setlength(fitems,(value*8) div 7 + 32);
 end;
 fcount:= value;
end;

function ttreenode.getitems(const index: integer): ttreenode;
begin
 checkindex(index);
 result:= fitems[index];
end;

procedure ttreenode.setitems(const index: integer; const Value: ttreenode);
begin
 checkindex(index);
 fitems[index].Free;
 fitems[index]:= value;
 value.fparent:= self;
end;

procedure ttreenode.checkindex(const index: integer);
begin
 if (index < 0) or (index >= fcount) then begin
  tlist.error(slistindexerror,index);
 end;
end;

procedure ttreenode.iterate(const event: nodeeventty);
var
 int1: integer;
begin
 event(self);
 for int1:= 0 to fcount - 1 do begin
  fitems[int1].iterate(event);
 end;
end;

procedure ttreenode.convertflat(const listitem: ttreelistitem;
  const filterfunc: treenodefilterfuncty);
var
 item1: ttreelistitem;
 int1: integer;
begin
 if assigned(filterfunc) and not filterfunc(self) then begin
  exit;
 end;
 item1:= listitemclass.create;
 nodetoitem(item1);
 listitem.add(item1);
 for int1:= 0 to fcount - 1 do begin
  fitems[int1].convertflat(listitem,filterfunc);
 end;
end;

function ttreenode.converttree(const filterfunc: treenodefilterfuncty): ttreelistitem;
var
 int1: integer;
begin
 if assigned(filterfunc) and not filterfunc(self) then begin
  result:= nil;
 end
 else begin
  result:= listitemclass.create;
  nodetoitem(result);
  for int1:= 0 to fcount - 1 do begin
   result.add(fitems[int1].converttree(filterfunc));
  end;
 end;
end;

function ttreenode.converttotreelistitem(flat: boolean = false; withrootnode: boolean =  false;
                filterfunc: treenodefilterfuncty = nil): ttreelistitem;
var
 int1: integer;
begin
 result:= listitemclass.create; //container
 if withrootnode then begin
  if flat then begin
   convertflat(result,filterfunc);
  end
  else begin
   result.add(converttree(filterfunc));
  end;
 end
 else begin
  for int1:= 0 to fcount - 1 do begin
   if flat then begin
    fitems[int1].convertflat(result,filterfunc);
   end
   else begin
    result.add(fitems[int1].converttree(filterfunc));
   end;
  end;
 end;
end;

{
procedure ttreenode.assigntotreelistitem(const listitem: ttreelistitem);
var
 int1: integer;
 ar1: treelistitemarty;
begin
 nodetoitem(listitem);
 listitem.clear;
 if fcount > 0 then begin
  setlength(ar1,fcount);
  for int1:= 0 to fcount - 1 do begin
   ar1[int1]:= fitems[int1].listitemclass.create;
  end;
  listitem.add(ar1);
  for int1:= 0 to fcount - 1 do begin
   fitems[int1].assigntotreelistitem(ar1[int1]);
  end;
 end;
end;

procedure ttreenode.assigntreelistitem(const listitem: ttreelistitem);
var
 int1: integer;
 ar1: treenodearty;
begin
 itemtonode(listitem);
 clear;
 if listitem.count > 0 then begin
  setlength(ar1,listitem.count);
  for int1:= 0 to listitem.count - 1 do begin
   add(treenodeclass.create);
  end;
  for int1:= 0 to fcount - 1 do begin
   fitems[int1].assigntotreelistitem(listitem[int1]);
  end;
 end;
end;
}
procedure ttreenode.nodetoitem(const listitem: ttreelistitem);
begin
 //dummy
end;
{
procedure ttreenode.itemtonode(const listitem: ttreelistitem);
begin
 //dummy
end;
}
function ttreenode.listitemclass: treelistitemclassty;
begin
 result:= ttreelistitem;
end;

function ttreenode.treenodeclass: treenodeclassty;
begin
 result:= ttreenode;
end;

function ttreenode.count: integer;
begin
 result:= fcount;
end;

end.
