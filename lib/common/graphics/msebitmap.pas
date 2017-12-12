{ MSEgui Copyright (c) 1999-2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msebitmap;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 classes,mclasses,msegraphics,msetypes,msestrings,mseinterfaces,
 msegraphutils,mseclasses,mseglob,sysutils,mseguiglob;

const
 defaultimagelistwidth = 16;
 defaultimagelistheight = 16;
 defaultimagelistsize: sizety = (cx: defaultimagelistwidth; 
                                            cy: defaultimagelistheight);

type
{
 imagebufferinfoty = record
  image: imagety;
  mask: imagety;
 end;
}
 tbitmapcomp = class;

 tbitmap = class(tsimplebitmap)
  private
   fimage: imagety;
   fonchange: notifyeventty;
   falignment: alignmentsty;
   fopacity: colorty;
   fnochange: integer;
   function getscanline(index: integer): pointer;
   procedure checkimage(const bgr: boolean);
   procedure getimage;
   procedure putimage;
   function getpixel(const index: pointty): colorty;
   procedure setpixel(const index: pointty; const value: colorty);
   function getpixels(const x,y: integer): colorty;
   procedure setpixels(const x,y: integer; const value: colorty);
   function checkindex(const index: pointty): integer; overload;
   function checkindex(const x,y: integer): integer; overload;
                 //returns index in imagety pixels for bmk_mono and bmk_rgb,
                 //byte offset for bmk_gray
   procedure setalignment(const Value: alignmentsty);
   procedure setopacity(avalue: colorty);
   procedure updatealignment(const dest,source: rectty;
               var alignment: alignmentsty; out newdest,newsource: rectty;
               out tileorigin: pointty);
      //expand copy areas in order to avoid missing pixels by position rounding

   procedure setcolorbackground(const Value: colorty);
   procedure setcolorforeground(const Value: colorty);
   procedure readtransparency(reader: treader);
  protected
   procedure getcanvasimage(const bgr: boolean;
                            var aimage: maskedimagety); override;
   procedure setsize(const Value: sizety); override;
   function getasize: sizety; virtual;
   procedure destroyhandle; override;
   procedure createhandle(copyfrom: pixmapty); override;
   function getsource: tbitmapcomp; virtual;
   procedure assign1(const source: tsimplebitmap; const docopy: boolean); override; 
                    //calls change
   procedure dochange; virtual;
   procedure defineproperties(filer: tfiler); override;
   function getimageref(out aimage: imagety): boolean; 
                                  //true if buffer must be destroyed
   procedure setkind(const avalue: bitmapkindty); override;
  public
//   constructor create(const amonochrome: boolean;
//                              const agdifuncs: pgdifunctionaty = nil);
                                        //nil -> default
   constructor create(const akind: bitmapkindty;
                              const agdifuncs: pgdifunctionaty = nil);
                                        //nil -> default

   procedure savetoimage(out aimage: imagety);
   procedure loadfromimage(const aimage: imagety);
   procedure assign(source: tpersistent); override;
   procedure change;
   procedure beginupdate;
   procedure endupdate;
   procedure loaddata(const asize: sizety; const data: pbyte;
             const msbitfirst: boolean = false; const dwordaligned: boolean = false;
             const bottomup: boolean = false); virtual; //calls change
   function hasimage: boolean;
   procedure paint(const acanvas: tcanvas; const dest: rectty;
                   const asource: rectty; aalignment: alignmentsty = [];
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default;
                      //used for monochrome bitmaps,
                      //cl_default-> acanvas.color, acanvas.colorbackground
                         const aopacity: colorty = cl_default
                      //cl_default-> self.opacity
                   );
                           overload;
   procedure paint(const acanvas: tcanvas; const dest: pointty;
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default;
                         const aopacity: colorty = cl_default
                         ); overload;
                 //useses self.size and self.alignment
   procedure paint(const acanvas: tcanvas; const dest: pointty;
                          const aalignment: alignmentsty;
                          const acolorforeground: colorty = cl_default;
                          const acolorbackground: colorty = cl_default;
                          const aopacity: colorty = cl_default); overload;
                 //useses self.size
   procedure paint(const acanvas: tcanvas; const dest: rectty;
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default;
                         const aopacity: colorty = cl_default); overload;
                 //useses self.size and self.alignment
   procedure paint(const acanvas: tcanvas; const dest: rectty;
                          const aalignment: alignmentsty;
                          const acolorforeground: colorty = cl_default;
                          const acolorbackground: colorty = cl_default;
                          const aopacity: colorty = cl_default); overload;
                 //useses self.size

   procedure init(const acolor: colorty); override;
   function compressdata: longwordarty;
   procedure decompressdata(const asize: sizety; const adata: longwordarty);
   property pixel[const index: pointty]: colorty read getpixel write setpixel;
   property pixels[const x,y: integer]: colorty read getpixels write setpixels;
   property scanline[index: integer]: pointer read getscanline;
   property scanhigh: integer read fscanhigh; 
                          //max index in scanline[0] ???
   property scanlinestep: integer read fscanlinestep; //bytes
   property colorforeground: colorty read fcolorforeground write setcolorforeground default cl_black;
                 //used for monochrome -> color conversion
   property colorbackground: colorty read fcolorbackground write setcolorbackground default cl_white;
                 //used for monochrome -> color conversion,
                 //colorbackground for color -> monochrome conversion
   property alignment: alignmentsty read falignment write setalignment default [];
   property opacity: colorty read fopacity write setopacity default cl_none;
   property onchange: notifyeventty read fonchange write fonchange;
 end;

 imageformatty = (imfor_default);
 imageinfoty = (iminf_monochrome,iminf_masked,iminf_colormask,
                iminf_gray,iminf_graymask);
 imageinfosty = set of imageinfoty;
 imageheaderty = packed record
  format: longword; //imageformatty;
  info: longword;   //imageinfosty;
  width: integer;
  height: integer;
  datasize: integer;
  reserve: array[0..7] of longword;
 end;
{
 tbitmapcanvas = class(tcanvas)
  protected
   function getimage(const bgr: boolean): imagety; override;
  public
   constructor create(const user: tbitmap);
 end;
}
 bitmapoptionty = (bmo_monochrome,bmo_gray,
                   bmo_masked,bmo_graymask,bmo_colormask,
                   bmo_storeorigformat, //needs mseformat*read unit at runtime
                                        //in uses
                   bmo_runtimeformatdata); //do not clear origformatdata after
                                           //load at runtime
 bitmapoptionsty = set of bitmapoptionty;
const
 bmokindoptions = [bmo_monochrome,bmo_gray];
 bmomaskkindoptions = [bmo_graymask,bmo_colormask];

type
 townedbitmap = class(tbitmap)
  private
   fowner: tbitmap;
  protected
   procedure dochange; override;
  public
   constructor create(const aowner: tbitmap; const akind: bitmapkindty;
                              const agdifuncs: pgdifunctionaty = nil);
 end;
 
 tmaskedbitmap = class(tbitmap,iobjectlink)
  private
   ftransparentcolor: colorty;
   fsource: tbitmapcomp;
   fobjectlinker: tobjectlinker;
   fmaskcolorforeground,fmaskcolorbackground: colorty;
   forigformat: string;
   forigformatdata: string;
   fmask_source: tbitmapcomp;
   procedure checkmask();
   procedure freemask();
   procedure settransparentcolor(const Value: colorty);
   procedure setmask(const Value: tbitmap);
   function getobjectlinker: tobjectlinker;
   procedure setsource(const Value: tbitmapcomp);
   function getmasked(): boolean;
   procedure setmasked(const Value: boolean);
   procedure readimage(stream: tstream);
   procedure writeimage(stream: tstream);
   procedure readimagedata(stream: tstream);
   procedure writeimagedata(stream: tstream);
   function getmask1(): tbitmap;
   function getoptions: bitmapoptionsty;
   procedure setoptions(const avalue: bitmapoptionsty);
   function getcolormask(): boolean;
   procedure setcolormask(const avalue: boolean);
   procedure setorigformatdata(const avalue: string);
   function getmaskkind(): bitmapkindty;
   procedure setmaskkind(const avalue: bitmapkindty);
   function getgraymask(): boolean;
   procedure setgraymask(const avalue: boolean);
   procedure setmask_source(const avalue: tbitmapcomp);
   procedure setmaskpos(const avalue: pointty);
   procedure setmask_x(const avalue: int32);
   procedure setmask_y(const avalue: int32);
  protected
   foptions: bitmapoptionsty;
   fmask: tbitmap;
   fmask_pos: pointty;
   procedure setkind(const avalue: bitmapkindty); override;
   function gettranspcolor(): colorty;
//   procedure setmonochrome(const avalue: boolean); override;
   function getasize: sizety; override;
   procedure createmask(const akind: bitmapkindty); virtual;
   function getconverttomonochromecolorbackground: colorty; override;
   procedure destroyhandle; override;
   procedure setsize(const Value: sizety); override;
   function writedata(const ancestor: tmaskedbitmap): boolean;
   procedure defineproperties(filer: tfiler); override;
   procedure objectevent(const sender: tobject; const event: objecteventty);
   function getmask(out apos: pointty): tsimplebitmap; override;
   function getsource: tbitmapcomp; override;
   procedure assign1(const source: tsimplebitmap; const docopy: boolean); override;
   procedure getcanvasimage(const bgr: boolean;
                            var aimage: maskedimagety); override;
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                      ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
   function doloadfromstream(const atry: boolean;
           const stream: tstream;
           const format: string; const params: array of const): string;
   function doloadfromfile(const atry: boolean;
             const filename: filenamety;
             const format: string; const params: array of const): string;
   function doloadfromstring(const atry: boolean;
               const avalue: string;
               const format: string; const params: array of const): string;
  public
   constructor create(const akind: bitmapkindty;
                     const agdifuncs: pgdifunctionaty = nil);
                                        //nil -> default
   destructor destroy; override;
   procedure clear; override;
//   class procedure freeimageinfo(var ainfo: maskedimagety);
   procedure loadfrommaskedimage(const aimage: maskedimagety);
   procedure savetomaskedimage(out aimage: maskedimagety);
//   procedure loadfromimagebuffer(const abuffer: maskedimagety);
//   procedure savetoimagebuffer(out abuffer: maskedimagety);
   function bitmap: tmaskedbitmap; //self if source = nil
   
   procedure releasehandle; override;
   procedure acquirehandle; override;
   procedure initmask;
   procedure stretch(const dest: tmaskedbitmap;
                           const aalignment: alignmentsty = 
                                [al_stretchx,al_stretchy,al_intpol]); overload;
   procedure stretch(const source: rectty; const dest: tmaskedbitmap;
                     const aalignment: alignmentsty = 
                               [al_stretchx,al_stretchy,al_intpol]); overload;
   procedure remask; //recalc mask
   procedure automask; //transparentcolor is bottomright pixel

   
   function loadfromstring(const avalue: string; const format: string;
                                                         //'' = any
                                        const params: array of const): string;
                                         //returns format name
   function loadfromstring(const avalue: string): string;  
                                         //returns format name
   function loadfromstream(const stream: tstream; const format: string;
                                                         //'' = any
                                       const params: array of const): string;
                                         //returns format name
   function loadfromstream(const stream: tstream): string; 
                                         //returns format name

   function loadfromfile(const filename: filenamety; const format: string; 
                                                         //'' = any
                                       const params: array of const): string;
                                         //returns format name
   function loadfromfile(const filename: filenamety): string; 
                                         //returns format name

   function tryloadfromstring(const avalue: string; const format: string;
                                                         //'' = any
                                        const params: array of const): string;
           //returns format name, '' = unknown/not supported
           //exception in case of read error
   function tryloadfromstring(const avalue: string): string;
           //returns format name, '' = unknown/not supported
           //exception in case of read error
   function tryloadfromstream(const stream: tstream; const format: string;
                                                         //'' = any
                                       const params: array of const): string;
           //returns format name, '' = unknown/not supported
           //exception in case of read error
   function tryloadfromstream(const stream: tstream): string;
           //returns format name, '' = unknown/not supported
           //exception in case of read error
   function tryloadfromfile(const filename: filenamety; const format: string; 
                                                         //'' = any
                                       const params: array of const): string;
           //returns format name, '' = unknown/not supported
           //exception in case of read error
   function tryloadfromfile(const filename: filenamety): string; 
           //returns format name, '' = unknown/not supported
           //exception in case of read error
   
   procedure writetostring(out avalue: string; const format: string;
                                  const params: array of const); overload;
   function writetostring(const format: string;
                           const params: array of const): string; overload;
   procedure writetostream(const stream: tstream; const format: string;
                               const params: array of const);
   procedure writetofile(const filename: filenamety; const format: string;
                               const params: array of const);
   property mask: tbitmap read getmask1 write setmask;
   property maskkind: bitmapkindty read getmaskkind 
                                 write setmaskkind default bmk_mono;
   property masked: boolean read getmasked write setmasked default false;
   property graymask: boolean read getgraymask write setgraymask default false;
   property colormask: boolean read getcolormask write setcolormask default false;
   property maskcolorforeground: colorty read fmaskcolorforeground 
                    write fmaskcolorforeground default $ffffff;
                    //used to init colormask
   property maskcolorbackground: colorty read fmaskcolorbackground 
                    write fmaskcolorbackground default $000000; //max transparent
                     //used to convert monchrome mask to colormask
   property mask_pos: pointty read fmask_pos write setmaskpos;
   property origformatdata: string read forigformatdata write setorigformatdata;
  published
   property transparentcolor: colorty read ftransparentcolor 
                              write settransparentcolor default cl_default;
                     //cl_default ->bottom left pixel
   property options: bitmapoptionsty read getoptions write setoptions default [];
   property source: tbitmapcomp read fsource write setsource;
   property mask_source: tbitmapcomp read fmask_source write setmask_source;
   property mask_x: int32 read fmask_pos.x write setmask_x default 0;
   property mask_y: int32 read fmask_pos.y write setmask_y default 0;
   property origformat: string read forigformat write forigformat;
   property colorforeground;
   property colorbackground;
   property alignment;
   property opacity;
 end;

 tcenteredbitmap = class(tmaskedbitmap)
  public
   constructor create(const akind: bitmapkindty;
                     const agdifuncs: pgdifunctionaty = nil);
  published
   property alignment default [al_xcentered,al_ycentered];
 end;
 
 tbitmapcomp = class(tmsecomponent)
  private
   fbitmap: tmaskedbitmap;
   fonchange: notifyeventty;
   procedure setbitmap(const Value: tmaskedbitmap);
   procedure change(const sender: tobject);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property bitmap: tmaskedbitmap read fbitmap write setbitmap;
   property onchange: notifyeventty read fonchange write fonchange;
 end;

 timagelist = class(tmsecomponent)
  private
   fsize: sizety;
   fcolcount,frowcount: integer;
//   fbitmap: tmaskedbitmap;
   fbitmaps: array of tmaskedbitmap;
   fcount: integer;
   fupdating: integer;
   fonchange: notifyeventty;
//   fkind: bitmapkindty;
   findexlookup: msestring;
//   fcornermask: msestring;
   fcornermask_topleft: msestring;
   fcornermask_bottomleft: msestring;
   fcornermask_bottomright: msestring;
   fcornermask_topright: msestring;
   fneedscornermaskcheck: boolean;
   fhascornermask: boolean;
   procedure setsize(const avalue: sizety);
//   function getmonochrome: boolean;
//   procedure setmonochrome(const Value: boolean);
   procedure setcount(const Value: integer);
   function getmasked: boolean;
   procedure setmasked(const Value: boolean);
   function gettransparentcolor: colorty;
   procedure settransparentcolor(avalue: colorty);
   procedure setheight(const Value: integer);
   procedure setwidth(const Value: integer);
//   procedure setbitmap(const Value: tmaskedbitmap);
   procedure copyimages(const image: tmaskedbitmap; const destindex: integer;
                                                 const aversion: int32);
   function getcolormask: boolean;
   procedure setcolormask(const avalue: boolean);
   function getkind: bitmapkindty;
   procedure setkind(const avalue: bitmapkindty);
   procedure setmaskkind(const avalue: bitmapkindty);
   function getmaskkind: bitmapkindty;
   function getgraymask: boolean;
   procedure setgraymask(const avalue: boolean);
   procedure readmasked(reader: treader);
   procedure readcolormask(reader: treader);
   procedure readmonochrome(reader: treader);
   procedure readcornermask(reader: treader);
   function getoptions: bitmapoptionsty;
   procedure setoptions(const avalue: bitmapoptionsty);
   procedure setindexlookup(const avalue: msestring);
   procedure setcornermask_topleft(const avalue: msestring);
   procedure setcornermask_bottomleft(const avalue: msestring);
   procedure setcornermask_bottomright(const avalue: msestring);
   procedure setcornermask_topright(const avalue: msestring);
   function getversioncount: int32;
   procedure setversioncount(const avalue: int32);
   function getbitmap: tmaskedbitmap;
   procedure setversiondefault(avalue: int32);
   function getbitmaps(aindex: int32): tmaskedbitmap;
  protected
   fversionhigh: int32; //versioncount - 1 
   fversiondefault: int32; //use for painting
   fcornermaskmaxtopleft: int32; //biggest value of cornermask
   fcornermaskmaxbottomleft: int32; //biggest value of cornermask
   fcornermaskmaxbottomright: int32; //biggest value of cornermask
   fcornermaskmaxtopright: int32; //biggest value of cornermask
   procedure updateversionindex(var aindex: int32);
   function indextoorg(index: integer): pointty;
   procedure change;
   procedure defineproperties(filer: tfiler); override;
   procedure cornermaskchanged();
   procedure loaded() override;
   procedure writeimage(stream: tstream);
   procedure readimage(stream: tstream);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   procedure beginupdate;
   procedure endupdate;

   procedure clear;
   procedure deleteimage(const index: integer);
   
    //aimage-1 -> use versiondefault
    
   procedure moveimage(const fromindex: integer; const toindex: integer;
                                                       aversion: int32 = -1);
   procedure setimage(index: integer; image: tmaskedbitmap;
         const source: rectty; aalignment: alignmentsty = [];
                                                       aversion: int32 = -1);
   procedure setimage(index: integer; image: tmaskedbitmap; 
                                      //nil -> empty item
                  const aalignment: alignmentsty = []; aversion: int32 = -1);
   procedure getimage(const index: integer; const dest: tmaskedbitmap;
                                                       aversion: int32 = -1);
   function addimage(const image: tmaskedbitmap; //nil -> empty item
                              const aalignment: alignmentsty = []{;
                         const aversion: int32 = 0}): integer;

   procedure clipcornermask(const canvas: tcanvas;
                      const arect: rectty; const ahiddenedges: edgesty);
   procedure paint(const acanvas: tcanvas; const index: integer;
                   const dest: pointty; const acolor: colorty = cl_default;
                   const acolorbackground: colorty = cl_default;
                   const aopacity: colorty = cl_default; aversion: int32 = -1);
   procedure paint(const acanvas: tcanvas; const index: integer;
                   const dest: rectty; const alignment: alignmentsty = [];
                   const acolor: colorty = cl_default;
                   const acolorbackground: colorty = cl_default;
                   const aopacity: colorty = cl_default; aversion: int32 = -1);
   procedure paint(const acanvas: tcanvas; const index: integer;
                   const dest: rectty; source: rectty;
                   const alignment: alignmentsty = [];
                   const acolor: colorty = cl_default;
                   const acolorbackground: colorty = cl_default;
                   const aopacity: colorty = cl_default; aversion: int32 = -1);
   procedure paintlookup(const acanvas: tcanvas; const index: integer;
                   const dest: pointty; const acolor: colorty = cl_default;
                   const acolorbackground: colorty = cl_default;
                   const aopacity: colorty = cl_default; aversion: int32 = -1);
   procedure paintlookup(const acanvas: tcanvas; const index: integer;
                   const dest: rectty; const alignment: alignmentsty = [];
                   const acolor: colorty = cl_default;
                   const acolorbackground: colorty = cl_default;
                   const aopacity: colorty = cl_default; aversion: int32 = -1);
   procedure paintlookup(const acanvas: tcanvas; const index: integer;
                   const dest: rectty; source: rectty;
                   const alignment: alignmentsty = [];
                   const acolor: colorty = cl_default;
                   const acolorbackground: colorty = cl_default;
                   const aopacity: colorty = cl_default; aversion: int32 = -1);
   function lookup(const aindex: int32): int32;

   procedure assign(sender: tpersistent); override;

   property size: sizety read fsize write setsize;
//   property bitmap: tmaskedbitmap read fbitmap write setbitmap;
   property bitmap: tmaskedbitmap read getbitmap;
   property bitmaps[const aindex: int32]: tmaskedbitmap read getbitmaps;

   property kind: bitmapkindty read getkind write setkind default bmk_rgb;
   property maskkind: bitmapkindty read getmaskkind 
                                    write setmaskkind default bmk_mono;
{
   property monochrome: boolean read getmonochrome
                write setmonochrome default false;
}
   property masked: boolean read getmasked write setmasked default true;
   property graymask: boolean read getgraymask write setgraymask default false;
   property colormask: boolean read getcolormask 
                                              write setcolormask default false;
   property hascornermask: boolean read fhascornermask;
  published
   property versioncount: int32 read getversioncount 
                                write setversioncount default 1; //first!
   property versiondefault: int32 read fversiondefault 
                                write setversiondefault default 0;
   property width: integer read fsize.cx
                 write setwidth default defaultimagelistwidth;
   property height: integer read fsize.cy
                   write setheight default defaultimagelistheight;
   property options: bitmapoptionsty read getoptions 
                                      write setoptions default [bmo_masked];
   property transparentcolor: colorty read gettransparentcolor
                         write settransparentcolor default cl_none;
   property count: integer read fcount write setcount default 0;
                 //last!
   property indexlookup: msestring read findexlookup write setindexlookup;
        //array of int16
   property cornermask_topleft: msestring read fcornermask_topleft 
                                                 write setcornermask_topleft;
   property cornermask_bottomleft: msestring read fcornermask_bottomleft 
                                                 write setcornermask_bottomleft;
   property cornermask_bottomright: msestring read fcornermask_bottomright
                                                write setcornermask_bottomright;
   property cornermask_topright: msestring read fcornermask_topright 
                                                 write setcornermask_topright;
        //array of int16, used in tframe for clipping corners of client area
        //cornermask[n] = number of clipped pixels from edge of row n.
   property onchange: notifyeventty read fonchange write fonchange;
 end;

 iimagelistinfo = interface(inullinterface)[miid_iimagelistinfo]
  function getimagelist: timagelist;
 end; 

 tformatstream = class
  private
   fstream: tstream;
   fformatname: string;
   fseekpos: integer;
   procedure setpos(const Value: integer);
  public
   constructor create(stream: tstream; formatname: string);
   procedure formaterror;
   procedure read(var dest; count: integer);
   procedure seek(count: integer);
   procedure resetpos(apos: integer = 0);
   property pos: integer read fseekpos write setpos;
 end;

implementation
uses
 mseguiintf,msebits,msestream,mseevent,msesys,msearrayutils,msegraphicstream,
 rtlconsts
 {$ifndef FPC},classes_del{$endif};

type
 tsimplebitmap1 = class(tsimplebitmap);
 tcanvas1 = class(tcanvas);
 twriter1 = class(twriter);
type
 tbitmap1 = class(tbitmap);

procedure freeimage(var aimage: imagety);
begin
 if aimage.pixels <> nil then begin
  gui_freeimagemem(aimage.pixels);
  fillchar(aimage,sizeof(aimage),0);
 end;
end;

procedure freeimage(var aimage: maskedimagety);
begin
 freeimage(aimage.image);
 freeimage(aimage.mask);
end;

{ tformatstream }

constructor tformatstream.create(stream: tstream; formatname: string);
begin
 fstream:= stream;
 fformatname:= formatname;
end;                                  

procedure tformatstream.formaterror;
begin
 raise egraphicformat.create('Invalid file format '+fformatname);
end;

procedure tformatstream.read(var dest; count: integer);
begin
 inc(fseekpos,count);
 fstream.read(dest,count);
end;

procedure tformatstream.resetpos(apos: integer);
begin
 fseekpos:= apos;
end;

procedure tformatstream.seek(count: integer);
begin
 inc(fseekpos,count);
 fstream.seek(count,sofromcurrent);
end;

procedure tformatstream.setpos(const Value: integer);
begin
 seek(value-fseekpos);
end;

{ tbitmap }

constructor tbitmap.create(const akind: bitmapkindty;
                                  const agdifuncs: pgdifunctionaty = nil);
begin
 fopacity:= cl_none;
 inherited;
end;

procedure tbitmap.assign1(const source: tsimplebitmap; const docopy: boolean);
var
 bo1: boolean;
begin
 if source is tbitmap then begin
  bo1:= tbitmap(source).hasimage and (tbitmap(source).fimage.pixels = nil) and
           (getgdiintf <> tbitmap(source).getgdiintf);
  with tbitmap(source) do begin
   if (fimage.pixels <> nil) or bo1 then begin
    self.clear;
    if bo1 then begin
     savetoimage(self.fimage);
    end
    else begin
     self.fimage:= fimage;
     self.fimage.pixels:= gui_allocimagemem(fimage.length);
     move(fimage.pixels^,self.fimage.pixels^,fimage.length*sizeof(longword));
                         //get a copy
    end;
    self.fsize:= self.fimage.size;
    self.fkind:= fkind;
    {
    if monochrome then begin
     include(self.fstate,pms_monochrome);
    end
    else begin
     exclude(self.fstate,pms_monochrome);
    end;
    }
   end
   else begin
    inherited;
   end;
  end;
 end
 else begin
  inherited;
 end;
 change;
end;

procedure tbitmap.loaddata(const asize: sizety; const data: pbyte;
        const msbitfirst: boolean = false; const dwordaligned: boolean = false;
        const bottomup: boolean = false);
var
 sourcerowstep,rowstep: integer;
 ps,pd: pbyteaty;
 int1,int2,int3: integer;
begin
 if fkind <> bmk_mono then begin
  gdierror(gde_notmonochrome,self);
 end;
 destroyhandle;
 fsize:= asize;
 if (asize.cx > 0) and (asize.cy > 0) then begin
  allocimage(fimage,size,bmk_mono);
  with fimage do begin
//   monochrome:= true;
//   size:= asize;
//   rowstep:= (size.cx+31) div 32; //words
//   length:= size.cy * rowstep;
//   rowstep:= rowstep*4;           //bytes
   rowstep:= linebytes;
//   pixels:= gui_allocimagemem(length);
   if dwordaligned then begin
    sourcerowstep:= rowstep;
   end
   else begin
    sourcerowstep:= (asize.cx+7) div 8;
   end;
   int1:= asize.cy - 1;
   int3:= sourcerowstep - 1;
   if bottomup then begin
    pd:= pointer(pchar(pixels) + int1*rowstep);
    rowstep:= -rowstep;
   end
   else begin
    pd:= pointer(pixels);
   end;
   ps:= pointer(data);
   if msbitfirst then begin
    for int1:= int1 downto 0 do begin
     for int2:= int3 downto 0 do begin
      pd^[int2]:= bitreverse[ps^[int2]];
     end;
     inc(pbyte(ps),sourcerowstep);
     inc(pbyte(pd),rowstep);
    end;
   end
   else begin
    for int1:= int1 downto 0 do begin
     for int2:= int3 downto 0 do begin
      pd^[int2]:= ps^[int2];
     end;
     inc(pbyte(ps),sourcerowstep);
     inc(pbyte(pd),rowstep);
    end;
   end;   
  end;
 end;
// creategc;
 change;
end;

{
procedure tbitmap.loaddata(const asize: sizety; data: pbyte;
             msbitfirst: boolean = false; dwordaligned: boolean = false;
             bottomup: boolean = false);
begin
 if not monochrome then begin
  gdierror(gde_notmonochrome,self);
 end;
 destroyhandle;
 fsize:= asize;
 gdi_lock;
 fhandle:= gui_createbitmapfromdata(asize,data,msbitfirst,dwordaligned,bottomup);
 gdi_unlock;
 if fhandle = 0 then begin
  gdierror(gde_pixmap);
 end;
 creategc;
 change;
end;
}
procedure tbitmap.paint(const acanvas: tcanvas; const dest: rectty;
                  const asource: rectty; aalignment: alignmentsty = [];
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default;
                         const aopacity: colorty = cl_default);
var
 bmp: tbitmap;
 sourcebmp: tbitmapcomp;
 amask: tsimplebitmap;
 maskpos1: pointty;
// maskpx: pixmapty;
// maskgchandle: longword;
 rect1,rect2: rectty;
 po1: pointty;
 col1,col2: colorty;
 opa: colorty;
 canvas2: tcanvas;
 bmp1: tmaskedbitmap;
 po2: prgbtripleaty;
 int1,int2: integer;
begin
 if aopacity = cl_default then begin
  opa:= opacity;
 end
 else begin
  opa:= aopacity;
 end;
 sourcebmp:= getsource;
 amask:= getmask(maskpos1);
 if sourcebmp <> nil then begin
  bmp:= sourcebmp.fbitmap;
//  if amask = nil then begin
//   amask:= sourcebmp.fbitmap.getmask(maskpos1);
//  end; 
 end
 else begin
  bmp:= self;
 end;
 with bmp do begin
  if not isempty then begin
   updatealignment(dest,asource,aalignment,rect1,rect2,po1);
//   amask:= getmask(maskpos1);
//   maskpx:= getmaskhandle(maskgchandle);
   if (al_grayed in aalignment) and ((amask <> nil) or 
                                           (fkind = bmk_mono)) then begin
    if (amask <> nil) and not (amask.kind = bmk_mono) then begin
                     //reduced contrast grayscale
     bmp1:= tmaskedbitmap.create(bmk_rgb);
     bmp1.colormask:= true;
     bmp1.size:= rect2.size;
     bmp1.canvas.copyarea(canvas,rect2,nullpoint);
     bmp1.mask.canvas.copyarea(amask.canvas,rect2,nullpoint);
     po2:= bmp1.scanline[0];
     for int1:= bmp1.scanhigh downto 0 do begin
      with po2^[int1] do begin
       int2:= (red+green+blue) div 8 + $80;
       red:= int2;
       green:= int2;
       blue:= int2;
      end;
     end;
     rect2.pos:= nullpoint;
     tcanvas1(acanvas).internalcopyarea(bmp1.canvas,rect2,
               rect1,acanvas.rasterop,cl_default,bmp1.mask,maskpos1,
                                                       aalignment,po1,opa);
     bmp1.free;     
    end
    else begin //shaddowed mask
     if kind = bmk_mono then begin
      canvas2:= canvas;
     end
     else begin
      canvas2:= amask.canvas;
     end;
     with acanvas do begin
      col1:= colorbackground;
      col2:= color;
      colorbackground:= cl_transparent;
      color:= cl_white;
 //     copyarea(canvas2,rect2,addpoint(rect1.pos,makepoint(1,1)),acanvas.rasterop);
      inc(rect1.x);
      inc(rect1.y);
      inc(po1.x);
      inc(po1.y);
      tcanvas1(acanvas).internalcopyarea(canvas2,rect2,
                rect1,acanvas.rasterop,cl_default,amask,maskpos1,
                                                        aalignment,po1,opa);
      color:= cl_dkgray;
 //     copyarea(canvas2,rect2,rect1.pos,acanvas.rasterop);
      dec(rect1.x);
      dec(rect1.y);
      dec(po1.x);
      dec(po1.y);
      tcanvas1(acanvas).internalcopyarea(canvas2,rect2,
                rect1,acanvas.rasterop,cl_default,amask,maskpos1,
                                                       aalignment,po1,opa);
      color:= col2;
      colorbackground:= col1;
     end;
    end;
   end
   else begin
    if kind = bmk_mono then begin
     col1:= acanvas.color;
     col2:= acanvas.colorbackground;
     if acolorforeground <> cl_default then begin
      acanvas.color:= acolorforeground;
     end
     else begin
      acanvas.color:= self.fcolorforeground;
     end;
     if acolorbackground <> cl_default then begin
      acanvas.colorbackground:= acolorbackground;
     end
     else begin
      acanvas.colorbackground:= self.fcolorbackground;
     end;
     tcanvas1(acanvas).internalcopyarea(bmp.canvas,rect2,
               rect1,acanvas.rasterop,cl_default,amask,maskpos1,
                                                   aalignment,po1,opa);
     acanvas.color:= col1;
     acanvas.colorbackground:= col2;
    end
    else begin
     tcanvas1(acanvas).internalcopyarea(bmp.canvas,rect2,
               rect1,acanvas.rasterop,cl_default,amask,maskpos1,
                                                   aalignment,po1,opa);
    end;
   end;
  end;
 end;
end;

procedure tbitmap.paint(const acanvas: tcanvas; const dest: rectty;
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default;
                         const aopacity: colorty = cl_default);
begin
 with tcanvas1(canvas).fvaluepo^.origin do begin
  paint(acanvas,dest,makerect(makepoint(-x,-y),getasize),falignment,
               acolorforeground,acolorbackground,aopacity);
 end;
end;

procedure tbitmap.paint(const acanvas: tcanvas; const dest: rectty;
                         const aalignment: alignmentsty;
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default;
                         const aopacity: colorty = cl_default);
begin
 with tcanvas1(canvas).fvaluepo^.origin do begin
  paint(acanvas,dest,makerect(makepoint(-x,-y),getasize),aalignment,
               acolorforeground,acolorbackground,aopacity);
 end;
end;

procedure tbitmap.paint(const acanvas: tcanvas; const dest: pointty;
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default;
                         const aopacity: colorty = cl_default);
begin
 with tcanvas1(canvas).fvaluepo^.origin do begin
  paint(acanvas,makerect(dest,fsize),makerect(makepoint(-x,-y),getasize),
            falignment,acolorforeground,acolorbackground,aopacity);
 end;
end;

procedure tbitmap.paint(const acanvas: tcanvas; const dest: pointty;
                         const aalignment: alignmentsty;
                         const acolorforeground: colorty = cl_default;
                         const acolorbackground: colorty = cl_default;
                         const aopacity: colorty = cl_default);
begin
 with tcanvas1(canvas).fvaluepo^.origin do begin
  paint(acanvas,makerect(dest,getasize),makerect(makepoint(-x,-y),getasize),
            aalignment,acolorforeground,acolorbackground,aopacity);
 end;
end;

procedure tbitmap.init(const acolor: colorty);
var
 rgb: longword;
 by1: byte;
 int1: integer;
begin
 if fimage.pixels = nil then begin
  inherited;
 end
 else begin
  rgb:= colortopixel(normalizeinitcolor(acolor));
  case fkind of
   bmk_mono: begin
    if odd(rgb xor colortopixel(cl_0)) then begin
     by1:= $ff;
    end
    else begin
     by1:= $00;
    end;
    fillchar(fimage.pixels^,fimage.length*sizeof(longword),by1);
   end;
   bmk_gray: begin
    by1:= (integer(rgbtriplety(rgb).red)+integer(rgbtriplety(rgb).green)+
                integer(rgbtriplety(rgb).blue)) div 3;
    fillchar(fimage.pixels^,fimage.length*sizeof(longword),by1);
   end;
   else begin
    for int1:= 0 to fimage.length-1 do begin
     fimage.pixels^[int1]:= rgb;
    end;
   end;
  end;
 end;
 change;
end;
{
procedure tbitmap.allocimagemem;
var
 step: integer;
begin
 if fimage.monochrome then begin
  step:= (fsize.cx+31) div 32;
  fimage.length:= step * fsize.cy;
 end
 else begin
  step:= fsize.cx;
  fimage.length:= fsize.cx * fsize.cy;
 end;
 if fimage.length > 0 then begin
  fimage.pixels:= gui_allocimagemem(fimage.length);
 end
 else begin
  fimage.pixels:= nil;
 end;
end;
}
procedure tbitmap.getimage;
var
 info1: drawinfoty;
begin
 if fhandle <> 0 then begin
  if fcanvas <> nil then begin
   with tcanvas1(fcanvas),fdrawinfo.pixmapimage do begin
    fillchar(image,sizeof(image),0);
    pixmap:= fhandle;
    gdi(gdf_pixmaptoimage);
    fimage:= image;
   end;
  end
  else begin
   with info1,pixmapimage do begin
    fillchar(image,sizeof(image),0);
    gc.handle:= 0;
    pixmap:= fhandle;
    gdi_call(gdf_pixmaptoimage,info1,getgdiintf);
    fimage:= image;
   end;    
  end;
  {
  gdi_lock;
  if fcanvas <> nil then begin
   gdierrorlocked(gui_pixmaptoimage(fhandle,fimage,
                           tcanvas1(fcanvas).fdrawinfo.gc.handle));
  end
  else begin
   gdierrorlocked(gui_pixmaptoimage(fhandle,fimage,0));
  end;
  }
 end
 else begin
//  fimage.size:= fsize;
//  fimage.monochrome:= monochrome;
  allocimage(fimage,fsize,kind);
 end;
end;

procedure tbitmap.checkimage(const bgr: boolean);
begin
 if fimage.pixels = nil then begin
  getimage;
  internaldestroyhandle;
 end;
 checkimagebgr(fimage,bgr);
end;

procedure tbitmap.putimage;
var
 info1: drawinfoty;
begin
 checkimagebgr(fimage,false);
 with info1,pixmapimage do begin
  image:= fimage;
  gc.handle:= 0;
  gdi_call(gdf_imagetopixmap,info1,getgdiintf);
  if error = gde_ok then begin
   handle:= pixmap;
//   fkind:= fimage.kind; //???necessary
   {
   if fimage.monochrome then begin
    include(fstate,pms_monochrome);
   end;
   }
   include(fstate,pms_ownshandle);
  end;
 end;    
end;

function tbitmap.checkindex(const index: pointty): integer;
begin
 if (index.x < 0) or (index.y < 0) or
     (index.x >= fsize.cx) or (index.y >= fsize.cy) then begin
  gdierror(gde_invalidindex,self);
 end;
 result:= index.y*fscanlinewords;
 case fkind of
  bmk_mono: begin
   result:= result + index.x div 32;
  end;
  bmk_gray: begin
   result:= result*4 + index.x;
  end;
  else begin
   result:= result + index.x;
  end;
 end;
end;

function tbitmap.checkindex(const x,y: integer): integer;
begin
 if (x < 0) or (y < 0) or
     (x >= fsize.cx) or (y >= fsize.cy) then begin
  gdierror(gde_invalidindex,self);
 end;
 result:= y*fscanlinewords;
 case fkind of
  bmk_mono: begin
   result:= result + x div 32;
  end;
  bmk_gray: begin
   result:= result*4 + x;
  end;
  else begin
   result:= result + x;
  end;
 end;
end;

function tbitmap.getscanline(index: integer): pointer;
begin
 checkimage(false);
 if fkind = bmk_gray then begin
  result:= @pbyte(fimage.pixels)[checkindex(makepoint(0,index))]; //bytes
 end
 else begin
  result:= @fimage.pixels[checkindex(makepoint(0,index))]; 
 end;
end;

function tbitmap.getpixel(const index: pointty): colorty;
var
 int1: integer;
 lwo1: longword;
begin
 int1:= checkindex(index);
 checkimage(false);
 case fkind of
  bmk_mono: begin
   if fimage.pixels^[int1] and bits[index.x and $1f] <> 0 then begin
    result:= cl_1;
   end
   else begin
    result:= cl_0;
   end;
  end;
  bmk_gray: begin
   lwo1:= pbyte(fimage.pixels)[int1];
   result:= lwo1 or (lwo1 shl 8) or (lwo1 shl 16);
  end;
  else begin
   result:= fimage.pixels^[int1] and $ffffff;
  end;
 end;
end;

procedure tbitmap.setpixel(const index: pointty; const value: colorty);
var
 int1: integer;
begin
 int1:= checkindex(index);
 checkimage(false);
 case kind of
  bmk_mono: begin
   if value = 0 then begin
    fimage.pixels^[int1]:= fimage.pixels^[int1] and not bits[index.x and $1f];
   end
   else begin
    fimage.pixels^[int1]:= fimage.pixels^[int1] or bits[index.x and $1f];
   end;
  end;
  bmk_gray: begin
   with rgbtriplety(value) do begin
    pbyte(fimage.pixels)[int1]:= (word(red)+word(green)+word(blue)) div 3;
   end;
  end;
  else begin
   fimage.pixels^[int1]:= value and $ffffff;
  end;
 end;
end;

function tbitmap.getpixels(const x,y: integer): colorty;
var
 int1: integer;
 lwo1: longword;
begin
 int1:= checkindex(x,y);
 checkimage(false);
 case fkind of
  bmk_mono: begin
   if fimage.pixels^[int1] and bits[x and $1f] <> 0 then begin
    result:= cl_1;
   end
   else begin
    result:= cl_0;
   end;
  end;
  bmk_gray: begin
   lwo1:= pbyte(fimage.pixels)[int1];
   result:= lwo1 or (lwo1 shl 8) or (lwo1 shl 16);
  end;
  else begin
   result:= fimage.pixels^[int1] and $ffffff;
  end;
 end;
end;

procedure tbitmap.setpixels(const x,y: integer; const value: colorty);
var
 int1: integer;
begin
 int1:= checkindex(x,y);
 checkimage(false);
 case kind of
  bmk_mono: begin
   if value = 0 then begin
    fimage.pixels^[int1]:= fimage.pixels^[int1] and not bits[x and $1f];
   end
   else begin
    fimage.pixels^[int1]:= fimage.pixels^[int1] or bits[x and $1f];
   end;
  end;
  bmk_gray: begin
   with rgbtriplety(value) do begin
    pbyte(fimage.pixels)[int1]:= (word(red)+word(green)+word(blue)) div 3;
   end;
  end;
  else begin
   fimage.pixels^[int1]:= value and $ffffff;
  end;
 end;
end;

function tbitmap.getasize: sizety;
begin
 result:= fsize;
end;

procedure tbitmap.destroyhandle;
begin
 if fimage.pixels <> nil then begin
  gui_freeimagemem(fimage.pixels);
  fimage.pixels:= nil;
 end;
 inherited;
end;

procedure tbitmap.createhandle(copyfrom: pixmapty);
begin
 if (fhandle = 0) and (fimage.pixels <> nil) then begin
  putimage;
  gui_freeimagemem(fimage.pixels);
  fimage.pixels:= nil;
 end
 else begin
  inherited;
 end;
end;
{
function tbitmap.getimagepo: pimagety;
begin
 result:= @fimage;
end;
}
function tbitmap.getsource: tbitmapcomp;
begin
 result:= nil;
end;

procedure tbitmap.dochange;
begin
 if assigned(fonchange) then begin
  fonchange(self);
 end;
end;

procedure tbitmap.change;
begin
 if (fnochange = 0) then begin
  dochange;
 end;
end;

procedure tbitmap.setalignment(const Value: alignmentsty);
begin
 if falignment <> value then begin
  movealignment(value,falignment);
  change;
 end;
end;

procedure tbitmap.setopacity(avalue: colorty);
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 if fopacity <> avalue then begin
  fopacity:= avalue;
  change;
 end;
end;

procedure tbitmap.updatealignment(const dest,source: rectty;
            var alignment: alignmentsty; out newdest,newsource: rectty;
            out tileorigin: pointty);
     //expand copy areas in order to avoid missing pixels by position rounding
var
 int1: integer;
begin
 newdest:= dest;
 newsource:= source;
 if (al_fit in alignment) or (al_thumbnail in alignment) and 
                     ((dest.cx < source.cx) or (dest.cy < source.cy)) then begin
  exit;
 end;
 int1:= 0;
 if al_xcentered in alignment then begin
  if dest.cx < source.cx then begin
   int1:= -1;
  end;
  newdest.x:= dest.x + (dest.cx - source.cx + int1) div 2
 end
 else begin
  if al_right in alignment then begin
   newdest.x:= dest.x + dest.cx - source.cx;
  end;
 end;
 if al_ycentered in alignment then begin
  if dest.cy < source.cy then begin
   int1:= -1;
  end;
  newdest.y:= dest.y + (dest.cy - source.cy + int1) div 2
 end
 else begin
  if al_bottom in alignment then begin
   newdest.y:= dest.y + dest.cy - source.cy;
  end;
 end;
 alignment:= alignment - [al_right,al_bottom,al_xcentered,al_ycentered];
 tileorigin:= newdest.pos;
 if al_tiled in alignment then begin
  newdest:= dest;
 end
 else begin
  if al_stretchx in alignment then begin
   newdest.x:= dest.x;
   newdest.cx:= dest.cx;
  end
  else begin
   int1:= newdest.x - dest.x;
   if int1 < 0 then begin
    dec(newdest.x,int1);
    dec(newsource.x,int1);
    inc(newsource.cx,int1);
   end;
   int1:=  dest.x + dest.cx - (newdest.x + newsource.cx);
   if int1 < 0 then begin
    inc(newsource.cx,int1);
   end;
   newdest.cx:= newsource.cx;
  end;
  if al_stretchy in alignment then begin
   newdest.y:= dest.y;
   newdest.cy:= dest.cy;
  end
  else begin
   int1:= newdest.y - dest.y;
   if int1 < 0 then begin
    dec(newdest.y,int1);
    dec(newsource.y,int1);
    inc(newsource.cy,int1);
   end;
   int1:=  dest.y + dest.cy - (newdest.y + newsource.cy);
   if int1 < 0 then begin
    inc(newsource.cy,int1);
   end;
   newdest.cy:= newsource.cy;
  end;
 end;
end;

procedure tbitmap.beginupdate;
begin
 inc(fnochange);
end;

procedure tbitmap.endupdate;
begin
 dec(fnochange);
 if fnochange = 0 then begin
  dochange;
 end;
end;

procedure tbitmap.setcolorbackground(const Value: colorty);
begin
 if fcolorbackground <> value then begin
  fcolorbackground := Value;
  change;
 end;
end;

procedure tbitmap.setcolorforeground(const Value: colorty);
begin
 if fcolorforeground <> value then begin
  fcolorforeground := Value;
  change;
 end;
end;

function tbitmap.compressdata: longwordarty;
var
 int1,int2,int3: integer;
 po1: plongword;
 ca1: longword;
begin
 checkimage(false);
 result:= nil;
 allocuninitedarray(fimage.length,sizeof(longword),result); //max
 case fkind of
  bmk_mono,bmk_gray: begin
   move(fimage.pixels^,result[0],fimage.length*sizeof(longword));
  end;
  else begin
   po1:=  @fimage.pixels^[0];
   int2:= 0;                          //msb = run length
   int1:= fimage.length;
   while int1 > 0 do begin
    ca1:= po1^ and $ffffff;
    int3:= 0;
    repeat
     inc(po1);
     inc(int3);
     dec(int1);
    until (po1^ and $ffffff <> ca1) or (int3 = 255) or (int1 = 0);
    result[int2]:= ca1 or longword(int3 shl 24);
    inc(int2);
   end;
   setlength(result,int2);
  end;
 end;
end;

procedure tbitmap.decompressdata(const asize: sizety; const adata: longwordarty);
var
 int1,int2,int3: integer;
 po1: plongword;
 ca1: longword;
begin
 clear;
 fsize:= asize;
// fimage.size:= fsize;
// fimage.monochrome:= monochrome;
 allocimage(fimage,fsize,kind);
 case kind of
  bmk_mono,bmk_gray: begin
   move(adata[0],fimage.pixels^,fimage.Length*sizeof(longword));
  end;
  else begin
   int2:= fimage.length;
   if int2 > 0 then begin
    po1:= @fimage.pixels^[0];
    for int1:= 0 to high(adata) do begin
     ca1:= adata[int1] and $ffffff;
     for int3:= (adata[int1] shr 24) - 1 downto 0 do begin
      po1^:= ca1;
      inc(po1);
      dec(int2);
      if int2 <= 0 then begin
       break;
      end;
     end;
     if int2 <= 0 then begin
      break;
     end;
    end;
   end;
  end;
 end;
end;

procedure tbitmap.assign(source: tpersistent);
begin
 if source is tbitmap then begin
  with tbitmap(source) do begin
   self.fcolorforeground:= colorforeground;
   self.fcolorbackground:= colorbackground;
   self.falignment:= alignment;
   self.fopacity:= opacity;
  end;
 end;
 inherited;
end;

function tbitmap.hasimage: boolean;
var
 bmp1: tbitmapcomp;
begin
 bmp1:= getsource;
 if bmp1 <> nil then begin
  result:= not bmp1.bitmap.isempty;
 end
 else begin
  result:= not isempty;
 end;
end;

procedure tbitmap.setsize(const Value: sizety);
begin
 inherited;
 change;
end;

procedure tbitmap.savetoimage(out aimage: imagety);
begin
 if hasimage then begin
  if fimage.pixels = nil then begin
   getimage;
   aimage:= fimage;
   fimage.pixels:= nil;
  end
  else begin
   aimage:= fimage;
   fimage.pixels:= gui_allocimagemem(fimage.length);
//   allocimagemem;
   move(aimage.pixels^,fimage.pixels^,fimage.length * sizeof(longword));
               //get a copy
  end;
 end
 else begin
  fillchar(aimage,sizeof(aimage),0);
 end;
end;

function tbitmap.getimageref(out aimage: imagety): boolean; 
                                  //true if buffer must be destroyed
begin
 result:= fimage.pixels = nil;
 if result then begin
  savetoimage(aimage);
 end
 else begin
  aimage:= fimage;
 end;
end;

procedure tbitmap.loadfromimage(const aimage: imagety);
begin
 if aimage.pixels = nil then begin
  clear;
 end
 else begin
  size:= aimage.size;
  {
  if aimage.monochrome then begin
   include(fstate,pms_monochrome);
  end
  else begin
   exclude(fstate,pms_monochrome);
  end;
  }
  fimage:= aimage;
  fkind:= fimage.kind;
  putimage;
  fimage.pixels:= nil;  //does not own image
 end;
end;

procedure tbitmap.getcanvasimage(const bgr: boolean; var aimage: maskedimagety);
begin
 checkimage(bgr);
 aimage.image:= fimage;
end;

procedure tbitmap.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('transparency',@readtransparency,nil,false);
end;

procedure tbitmap.readtransparency(reader: treader);
begin
 opacity:= transparencytoopacity(colorty(reader.readinteger));
end;

procedure tbitmap.setkind(const avalue: bitmapkindty);
begin
 if fkind <> avalue then begin
  inherited;
  if not isempty then begin
   change;
  end;
 end;
end;

{ tmaskedbitmap }

constructor tmaskedbitmap.create(const akind: bitmapkindty;
                                    const agdifuncs: pgdifunctionaty = nil);
                                        //nil -> default
begin
 ftransparentcolor:= cl_default;
 fmaskcolorbackground:= $000000; //max transparent
 fmaskcolorforeground:= $ffffff;
 case akind of
  bmk_mono: begin
   include(foptions,bmo_monochrome);
  end;
  bmk_gray: begin
   include(foptions,bmo_gray);
  end;
 end;
 inherited;
end;

destructor tmaskedbitmap.destroy;
begin
 freemask;
 inherited;
 fobjectlinker.free;
end;

procedure tmaskedbitmap.clear;
begin
 forigformatdata:= '';
 inherited;
end;

{
class procedure tmaskedbitmap.freeimageinfo(var ainfo: imagebufferinfoty);
begin
 with ainfo do begin
  if image.pixels <> nil then begin
   gui_freeimagemem(image.pixels);
   image.pixels:= nil;
  end;
  if mask.pixels <> nil then begin
   gui_freeimagemem(mask.pixels);
   mask.pixels:= nil;
  end;
 end;
end;
}
procedure tmaskedbitmap.freemask;
begin
 freeandnil(fmask);
end;

function tmaskedbitmap.getasize: sizety;
begin
 if fsource = nil then begin
  result:= fsize;
 end
 else begin
  result:= fsource.fbitmap.fsize;
 end;
end;
{
procedure tmaskedbitmap.createmask(const acolormask: boolean);
begin
 if fmask = nil then begin
  fmask:= tbitmap.create(true,fgdifuncs);
  with fmask do begin
   fcolorforeground:= fmaskcolorforeground;
   fcolorbackground:= fmaskcolorbackground;
  end;
 end
 else begin
  fmask.clear;
 end;
 fmask.monochrome:= not acolormask;
 exclude(fstate,pms_maskvalid);
end;
}
procedure tmaskedbitmap.createmask(const akind: bitmapkindty);
begin
 if fmask = nil then begin
  fmask:= townedbitmap.create(self,akind,fgdifuncs);
  with fmask do begin
   fcolorforeground:= fmaskcolorforeground;
   fcolorbackground:= fmaskcolorbackground;
  end;
 end
 else begin
  fmask.clear; //todo: gray ???
 end;
// fmask.monochrome:= not acolormask;
 exclude(fstate,pms_maskvalid);
end;

procedure tmaskedbitmap.initmask;
var
 bo1: boolean;
begin
 if fmask <> nil then begin
  bo1:= fmask.fcanvas = nil;
  fmask.size:= fsize;
  if not isnullsize(fsize) then begin
   if fmask.kind = bmk_mono then begin
    fmask.init(cl_1);
   end
   else begin
    fmask.init(fmaskcolorforeground);
   end;
  end;
  if bo1 then begin
   fmask.freecanvas;
  end;
  include(fstate,pms_maskvalid);
 end;
end;

function tmaskedbitmap.gettranspcolor(): colorty;
begin 
 if (ftransparentcolor = cl_default) and not isempty then begin
  result:= pixel[makepoint(0,fsize.cy-1)];
 end
 else begin
  result:= ftransparentcolor;
 end;
end;

function tmaskedbitmap.getconverttomonochromecolorbackground(): colorty;
begin
 result:= gettranspcolor();
 if ftransparentcolor = cl_none then begin
  result:= inherited getconverttomonochromecolorbackground;
 end;
end;

procedure tmaskedbitmap.checkmask();
var
 col1: colorty;
 ki1,ki2: bitmapkindty;
begin
 ki1:= bmk_mono;
 if bmo_colormask in foptions then begin
  ki1:= bmk_rgb;
 end
 else begin
  if bmo_graymask in foptions then begin
   ki1:= bmk_gray;
  end;
 end;
 ki2:= ki1;
 if not(pms_maskvalid in fstate) and  not isempty() then begin
  col1:= gettranspcolor();
  if (col1 <> cl_none) then begin
   ki2:= bmk_mono; //create a stencil mask from transparent color
  end;
 end;
 if fmask = nil then begin
  createmask(ki2);
//  createmask((ftransparentcolor = cl_none) and (bmo_colormask in foptions));
 end
 else begin
  if fmask.kind <> ki2 then begin
   if not (pms_maskvalid in fstate) then begin
    fmask.clear;
   end;
   fmask.kind:= ki2;
  end;
 end;
 if not isempty and not (pms_maskvalid in fstate) then begin
  fmask.size:= fsize;
  if col1 <> cl_none then begin //get mono mask
   if kind = bmk_mono then begin
    if col1 = cl_0 then begin
     fmask.canvas.copyarea(canvas,makerect(nullpoint,fsize),nullpoint,rop_copy);
    end
    else begin
     fmask.canvas.copyarea(canvas,makerect(nullpoint,fsize),nullpoint,rop_notcopy);
    end
   end
   else begin
    fmask.canvas.copyarea(canvas,makerect(nullpoint,fsize),
                                                   nullpoint,rop_copy,col1);
   end;
  end
  else begin
   initmask;
  end;
  include(fstate,pms_maskvalid);
 end;
 fmask.kind:= ki1;
// fmask.monochrome:= not (bmo_colormask in foptions);
end;

function tmaskedbitmap.getmask1(): tbitmap;
begin
 checkmask;
 result:= fmask;
end;

procedure tmaskedbitmap.settransparentcolor(const Value: colorty);
begin
 if ftransparentcolor <> value then begin
  ftransparentcolor:= Value;
  if value <> cl_none then begin
   remask;
  end;
 end;
end;

function tmaskedbitmap.getmasked: boolean;
begin
 result:= fmask <> nil;
end;

procedure tmaskedbitmap.setmasked(const Value: boolean);
begin
 if getmasked <> value then begin
  exclude(fstate,pms_maskvalid);
  if value then begin
   include(foptions,bmo_masked);
   checkmask;
  end
  else begin
   exclude(foptions,bmo_masked);
   freemask;
  end;
  change;
 end;
end;
{
procedure tmaskedbitmap.setmonochrome(const avalue: boolean);
begin
 inherited;
 if avalue xor (bmo_monochrome in foptions) then begin
  updatebit1(longword(foptions),ord(bmo_monochrome),avalue);
  change;
 end;
end;
}
function tmaskedbitmap.getcolormask: boolean;
begin
 result:= bmo_colormask in foptions;
end;

procedure tmaskedbitmap.setcolormask(const avalue: boolean);
begin
 if avalue then begin
  options:= foptions + [bmo_colormask];
 end
 else begin
  options:= foptions - [bmo_colormask];
 end;
end;

function tmaskedbitmap.getgraymask(): boolean;
begin
 result:= bmo_graymask in foptions;
end;

procedure tmaskedbitmap.setgraymask(const avalue: boolean);
begin
 if avalue then begin
  options:= foptions + [bmo_graymask];
 end
 else begin
  options:= foptions - [bmo_graymask];
 end;
end;

procedure tmaskedbitmap.setmask_source(const avalue: tbitmapcomp);
begin
 if avalue <> fmask_source then begin
  getobjectlinker.setlinkedvar(iobjectlink(self),avalue,
                                           tmsecomponent(fmask_source));
 change();
 end;
end;

procedure tmaskedbitmap.setmaskpos(const avalue: pointty);
begin
 fmask_pos:= avalue;
 change();
end;

procedure tmaskedbitmap.setmask_x(const avalue: int32);
begin
 if fmask_pos.x <> avalue then begin
  fmask_pos.x:= avalue;
  change();
 end;
end;

procedure tmaskedbitmap.setmask_y(const avalue: int32);
begin
 if fmask_pos.y <> avalue then begin
  fmask_pos.y:= avalue;
  change();
 end;
end;

function tmaskedbitmap.getoptions: bitmapoptionsty;
begin
 result:= foptions;
 (*
 updatebit({$ifdef FPC}longword{$else}byte{$endif}(result),ord(bmo_monochrome),
                   monochrome);
 updatebit({$ifdef FPC}longword{$else}byte{$endif}(result),ord(bmo_masked),
                   masked);
 *)
end;

procedure tmaskedbitmap.setoptions(const avalue: bitmapoptionsty);
//const
// mask1: bitmapoptionsty = [bmo_colormask];
var
 optbefore,opt2: bitmapoptionsty;
 ki1: bitmapkindty;
begin
 optbefore:= foptions;
 foptions:= bitmapoptionsty(setsinglebit(longword(avalue),longword(foptions),
               [longword([bmo_monochrome,bmo_gray]),
                longword([bmo_colormask,bmo_graymask])]));
 opt2:= foptions >< optbefore;
 if opt2 <> [] then begin
  beginupdate();
  try
   if opt2 * bmokindoptions <> [] then begin
    ki1:= bmk_rgb;
    if bmo_monochrome in foptions then begin
     ki1:= bmk_mono;
    end
    else begin
     if bmo_gray in foptions then begin
      ki1:= bmk_gray;
     end;
    end;
    kind:= ki1;
   end;
   if (opt2 * bmomaskkindoptions <> []) and 
                       (bmo_masked in foptions) and masked then begin
    checkmask;
   end;
   masked:= bmo_masked in foptions;
  finally
   endupdate();
  end;
 end;
(*
 if (longword(foptions) xor longword(avalue)) and
     {$ifdef FPC}longword{$else}byte{$endif}(mask1) <> 0 then begin
  foptions:= avalue;
  if fmask <> nil then begin
   checkmask;
   fmask.monochrome:= not (bmo_colormask in avalue);
   change;
  end;
 end
 else begin
  foptions:= avalue;
 end;
*)
// monochrome:= bmo_monochrome in foptions;
// masked:= bmo_masked in foptions;
end;

function tmaskedbitmap.getmaskkind: bitmapkindty;
begin
 result:= bmk_mono;
 if bmo_graymask in foptions then begin
  result:= bmk_gray;
 end;
 if bmo_colormask in foptions then begin
  result:= bmk_rgb;
 end;
end;

procedure tmaskedbitmap.setmaskkind(const avalue: bitmapkindty);
var
 opt1: bitmapoptionsty;
begin
 opt1:= foptions - bmomaskkindoptions;
 case avalue of
  bmk_gray: begin
   include(opt1,bmo_graymask);
  end;
  bmk_rgb: begin
   include(opt1,bmo_colormask);   
  end;
 end;
 options:= opt1;
end;

procedure tmaskedbitmap.remask;
begin
 if fmask <> nil then begin
  exclude(fstate,pms_maskvalid);
  checkmask;
  change;
 end;
end;

procedure tmaskedbitmap.automask;
begin
 exclude(fstate,pms_maskvalid);
 if not isempty then begin
  transparentcolor:= pixel[makepoint(fsize.cx-1,fsize.cy-1)];
 end;
 masked:= true;
 checkmask;
 change;
end;
{
procedure tmaskedbitmap.savetomaskedimage(out aimage: maskedimagety);
begin
 savetoimage(aimage.image);
 if masked then begin
  fmask.savetoimage(aimage.mask);
 end
 else begin
  freeimage(aimage.mask);
 end;
end;

procedure tmaskedbitmap.loadfrommaskedimage(const aimage: maskedimagety);
begin
 loadfromimage(aimage.image);
 if aimage.mask.pixels <> nil then begin
  if fmask = nil then begin
   createmask(aimage.mask.kind);
  end;
  fmask.loadfromimage(aimage.mask);
//  include(fstate,pms_maskvalid);
 end
 else begin
  masked:= false;
 end;
end;
}
procedure tmaskedbitmap.setmask(const Value: tbitmap);
var
 ki1: bitmapkindty;
begin
 if fmask <> value then begin
  freemask;
  if value <> nil then begin
   ki1:= bmk_mono;
   if bmo_colormask in foptions then begin
    ki1:= bmk_rgb;
   end
   else begin
    if bmo_graymask in foptions then begin
     ki1:= bmk_gray;
    end;
   end;
   createmask(ki1);
   fmask.size:= fsize;
   if sizeisequal(fsize,value.fsize) and 
                                         (value.kind = kind) then begin
    fmask.handle:= value.handle;
   end
   else begin
    case ki1 of 
     bmk_gray,bmk_rgb: begin
      fmask.init(fmaskcolorbackground);
     end;
     else begin
      fmask.init(cl_0);
     end;
    end;
    fmask.copyarea(value,makerect(nullpoint,fsize),nullpoint,rop_copy,false,
             fmaskcolorforeground,fmaskcolorbackground);
   end;
   include(fstate,pms_maskvalid);
  end;
  if masked then begin
   change;
  end;
 end;
end;
{
function tmaskedbitmap.getmaskhandle(var gchandle: longword): pixmapty;
begin
 if fmask <> nil then begin
  result:= tsimplebitmap1(fmask).handle;
  if tsimplebitmap1(fmask).fcanvas <> nil then begin
   gchandle:= tcanvas1(tsimplebitmap1(fmask).fcanvas).fdrawinfo.gc.handle;
  end
  else begin
   gchandle:= 0;
  end;
 end
 else begin
  result:= 0;
 end;
end;
}
function tmaskedbitmap.getmask(out apos: pointty): tsimplebitmap;
begin
 if (fmask_source <> nil) then begin
  result:= fmask_source.bitmap;
 end
 else begin
  if fsource <> nil then begin
   result:= fsource.bitmap.getmask(apos); //apos not used
   if result = nil then begin
    result:= fmask;
   end;
  end
  else begin
   result:= fmask;
  end;
 end;
 apos:= fmask_pos;
end;

procedure tmaskedbitmap.assign1(const source: tsimplebitmap; const docopy: boolean);
begin
 beginupdate;
 try
  if source is tmaskedbitmap then begin
   with tmaskedbitmap(source) do begin
    if source <> nil then begin
     self.source:= source;
    end
    else begin
     inherited;
     self.freemask;
     replacebits1(longword(self.foptions),longword(foptions),
                            longword(bmomaskkindoptions+bmokindoptions));
     if fmask <> nil then begin
      self.fmask:= tbitmap.create(fmask.kind,self.fgdifuncs);
      with self,fmask do begin
       fcolorforeground:= fmaskcolorforeground;
       fcolorbackground:= fmaskcolorbackground;
      end;
{$warnings off}
      tsimplebitmap1(self.fmask).assign1(fmask,docopy);
{$warnings on}
      include(self.fstate,pms_maskvalid);
      include(self.foptions,bmo_masked);
     end
     else begin
      if masked then begin
       include(self.foptions,bmo_masked);
       exclude(self.fstate,pms_maskvalid);
      end
      else begin
       exclude(self.foptions,bmo_masked);
      end;
     end;
     self.ftransparentcolor:= ftransparentcolor;
     self.forigformat:= forigformat;
     self.forigformatdata:= forigformatdata;
    end;
   end;
  end
  else begin
   inherited;
   freemask;
  end;
 finally
  endupdate;
 end;
end;

procedure tmaskedbitmap.releasehandle;
begin
 inherited;
// if fmask <> nil then begin
//  tsimplebitmap1(fmask).releasehandle;
// end;
end;

procedure tmaskedbitmap.acquirehandle;
begin
 inherited;
// if fmask <> nil then begin
//  tsimplebitmap1(fmask).acquirehandle;
// end;
end;

procedure tmaskedbitmap.destroyhandle;
begin
// if fmask <> nil then begin
//  tsimplebitmap1(fmask).destroyhandle;
// end;
 inherited;
end;

function tmaskedbitmap.getobjectlinker: tobjectlinker;
begin
 if fobjectlinker = nil then begin
  createobjectlinker(iobjectlink(self),{$ifdef FPC}@{$endif}objectevent,fobjectlinker);
 end;
 result:= fobjectlinker;
end;

procedure tmaskedbitmap.setsource(const Value: tbitmapcomp);
var
 bmpcomp1: tbitmapcomp;
begin
 if fsource <> value then begin
  bmpcomp1:= value;
  while bmpcomp1 <> nil do begin
   if bmpcomp1.bitmap = self then begin
    raise exception.create('Recursive bitmap source.');
   end;
   bmpcomp1:= bmpcomp1.bitmap.source;
  end; 
  beginupdate;
  try
   clear;
   getobjectlinker.setlinkedvar(iobjectlink(self),value,tmsecomponent(fsource));
  finally
   endupdate;
  end;
 end;
end;

procedure tmaskedbitmap.objectevent(const sender: tobject; const event: objecteventty);
begin
 if sender = fsource then begin
  case event of
//   oe_destroyed: source:= nil;
   oe_changed: change;
  end;
 end;
end;

procedure tmaskedbitmap.link(const source,dest: iobjectlink; valuepo: pointer = nil;
                            ainterfacetype: pointer = nil; once: boolean = false);
begin
 getobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tmaskedbitmap.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
begin
 getobjectlinker.unlink(source,dest,valuepo);
end;

procedure tmaskedbitmap.objevent(const sender: iobjectlink; const event: objecteventty);
begin
 getobjectlinker.objevent(sender,event);
end;

function tmaskedbitmap.getinstance: tobject;
begin
 result:= self;
end;

function tmaskedbitmap.getsource: tbitmapcomp;
begin
 result:= fsource;
end;

procedure tmaskedbitmap.setsize(const Value: sizety);
begin
 inherited;
 initmask;
end;

procedure tmaskedbitmap.stretch(const source: rectty;
                             const dest: tmaskedbitmap;
                           const aalignment: alignmentsty = 
                                [al_stretchx,al_stretchy,al_intpol]);
const
 tfo = bmokindoptions+bmomaskkindoptions+[bmo_masked];
var
 size1: sizety;
 bo1: boolean;
 destrect: rectty;
begin
 dest.beginupdate;
 try
  size1:= dest.size;
  dest.clear;
  dest.options:= (dest.options - tfo) + (options*tfo);
  {
  dest.monochrome:= monochrome;
  dest.colormask:= colormask;
  dest.masked:= masked;
  }
  dest.size:= size1;
  bo1:= (aalignment * [al_stretchx,al_stretchy] <> 
                                   [al_stretchx,al_stretchy]) and
           not (al_tiled in aalignment) and 
                 ((source.cx <> size1.cx) or (source.cy <> size1.cy));
  if bo1 then begin
   dest.init(dest.colorbackground);
  end;
  destrect:= calcrectalignment(mr(nullpoint,size1),source,aalignment);
  tcanvas1(dest.canvas).internalcopyarea(canvas,source,destrect,
                        rop_copy,cl_none,nil,nullpoint,aalignment,
                                                       nullpoint,cl_none);
       
  if masked then begin
   if bo1 then begin
    dest.mask.init(dest.mask.colorbackground);
   end;
   tcanvas1(dest.fmask.canvas).internalcopyarea(mask.canvas,source,
       destrect,rop_copy,cl_none,nil,nullpoint,aalignment,nullpoint,cl_none);
   include(dest.fstate,pms_maskvalid);
  end;
 finally
  dest.endupdate;
 end;
end;

procedure tmaskedbitmap.stretch(const dest: tmaskedbitmap;
      const aalignment: alignmentsty = [al_stretchx,al_stretchy,al_intpol]);
begin
 stretch(mr(nullpoint,size),dest,aalignment);
end;

function tmaskedbitmap.writedata(const ancestor: tmaskedbitmap): boolean;
begin
 result:= (fsource = nil) and not isempty and not (pms_nosave in fstate);
 if result and (ancestor <> nil) then begin
  result:= ((options >< ancestor.options)*
            (bmokindoptions+bmomaskkindoptions+[bmo_masked]) <> []) or
           (size.cx <> ancestor.size.cx) or
           (size.cy <> ancestor.size.cy) or
           (bmo_storeorigformat in options) and 
               (origformatdata <> ancestor.origformatdata);
  if not result then begin
   if masked then begin
    fmask.checkimage(false);
    ancestor.fmask.checkimage(false);
    zeropad(fmask.fimage);
    zeropad(ancestor.fmask.fimage);
    result:= (fmask.fimage.length <> ancestor.fmask.fimage.length) or 
              not comparemem(fmask.fimage.pixels,ancestor.fmask.fimage.pixels,
                         fmask.fimage.length * sizeof(longword));
   end;
   if not result then begin
    checkimage(false);
    ancestor.checkimage(false);
    result:= (fimage.length <> ancestor.fimage.length) or
              not comparemem(fimage.pixels,ancestor.fimage.pixels,
                         fimage.length * sizeof(longword));
   end;
  end;
 end;
end;

procedure tmaskedbitmap.defineproperties(filer: tfiler);
var
 bo1: boolean;
begin
 inherited;
 bo1:= (forigformatdata <> '') and (bmo_storeorigformat in options);
 filer.DefineBinaryProperty('image',{$ifdef FPC}@{$endif}readimage,
                                     {$ifdef FPC}@{$endif}writeimage,
                      not bo1 and writedata(tmaskedbitmap(filer.ancestor)));
 filer.DefineBinaryProperty('imagedata',{$ifdef FPC}@{$endif}readimagedata,
                                     {$ifdef FPC}@{$endif}writeimagedata,
                           bo1 and writedata(tmaskedbitmap(filer.ancestor)));
 if (filer is treader) and not(csdesigning in filer.root.componentstate) and 
                not(bmo_runtimeformatdata in options) then begin
  forigformatdata:= '';
 end;
end;

procedure tmaskedbitmap.writeimage(stream: tstream);
var
 header: imageheaderty;
 int1: integer;
 ar1: longwordarty;
begin
 fillchar(header,sizeof(header),0);
 with header do begin
  width:= fsize.cx;
  height:= fsize.cy;
  case fkind of
   bmk_mono: begin
    setbit1(info,ord(iminf_monochrome));
   end;
   bmk_gray: begin
    setbit1(info,ord(iminf_gray));
   end;
  end;
  if masked then begin
   setbit1(info,ord(iminf_masked));
   case fmask.fkind of
    bmk_gray: begin
     setbit1(info,ord(iminf_graymask));
    end;
    bmk_rgb: begin
     setbit1(info,ord(iminf_colormask));
    end;
   end;
  end;
  ar1:= compressdata;
  datasize:= length(ar1)*4;
  stream.Writebuffer(header,sizeof(header));
  stream.Writebuffer(ar1[0],datasize);
 end;
 if masked then begin
  checkmask;
  ar1:= fmask.compressdata;
  int1:= length(ar1)*4;
  if fmask.kind <> bmk_mono then begin
   stream.WriteBuffer(int1,4);
  end;
  stream.WriteBuffer(ar1[0],int1);
 end;
end;

procedure tmaskedbitmap.readimage(stream: tstream);
var
 header: imageheaderty;
 int1: integer;
 ar1: longwordarty;
 ki1: bitmapkindty;
 
begin
 beginupdate;
 try
  clear;
  stream.readbuffer(header,sizeof(header));
  fkind:= bmk_rgb;
  with header do begin
   if checkbit(info,ord(iminf_monochrome)) then begin
    fkind:= bmk_mono;
//    include(fstate,pms_monochrome);
   end
   else begin
    if checkbit(info,ord(iminf_gray)) then begin
     fkind:= bmk_gray;
    end;
//    exclude(fstate,pms_monochrome);
   end;
   if checkbit(info,ord(iminf_masked)) then begin
//    ftransparentcolor:= cl_none;
    ki1:= bmk_mono;
    if checkbit(info,ord(iminf_colormask)) then begin
     ki1:= bmk_rgb;
    end
    else begin
     if checkbit(info,ord(iminf_graymask)) then begin
      ki1:= bmk_gray;
     end;
    end;
    createmask(ki1);
//    createmask(checkbit(info,ord(iminf_colormask)));
   end
   else begin
    freemask;
   end;
   allocuninitedarray(datasize div 4,4,ar1);
//   setlength(ar1,datasize div 4);
   stream.ReadBuffer(ar1[0],length(ar1)*4);
   decompressdata(makesize(width,height),ar1);
   if masked then begin
    if fmask.kind = bmk_mono then begin
     int1:= ((fsize.cx + 31) div 32) * fsize.cy;
    end
    else begin
     stream.ReadBuffer(int1,sizeof(int1));
     int1:= int1 div 4;
    end;
    setlength(ar1,int1);
    stream.readbuffer(ar1[0],int1*4);
    fmask.decompressdata(fsize,ar1);
    include(fstate,pms_maskvalid);
   end;
  end;
 finally
  endupdate;
 end;
end;

procedure tmaskedbitmap.readimagedata(stream: tstream);
var
 lint1: int64;
 str1: string;
 optionsbefore: bitmapoptionsty;
begin
 stream.readbuffer(lint1,sizeof(lint1));
{$ifdef FPC}
 lint1:= leton(lint1);
{$endif}
 setlength(str1,lint1);
 optionsbefore:= options;
 stream.readbuffer(pchar(pointer(str1))^,lint1);
 origformatdata:= str1;
 options:= optionsbefore; // restore mask options
end;

procedure tmaskedbitmap.writeimagedata(stream: tstream);
var
 lint1: int64;
begin
 lint1:= length(forigformatdata);
{$ifdef FPC}
 stream.writebuffer(lint1,sizeof(ntole(lint1))); 
{$else}
 stream.writebuffer(lint1,sizeof(lint1)); 
{$endif}
 stream.writebuffer(pchar(pointer(forigformatdata))^,lint1);
end;

function tmaskedbitmap.doloadfromstream(const atry: boolean;
           const stream: tstream;
           const format: string; const params: array of const): string;
var
 int1,int2: integer;
begin
 int1:= stream.position;
 if atry then begin
  result:= tryreadgraphic(stream,self,format,params);
 end
 else begin
  result:= readgraphic(stream,self,format,params);
 end;
 int2:= stream.position;
 if bmo_storeorigformat in options then begin
  forigformat:= result;
  int2:= int2-int1;
  setlength(forigformatdata,int2);
  stream.position:= int1;
  stream.readbuffer(pchar(pointer(forigformatdata))^,int2);
 end;
end;

function tmaskedbitmap.doloadfromfile(const atry: boolean;
             const filename: filenamety;
             const format: string; const params: array of const): string;
var
 stream: tmsefilestream;
begin
 stream:= tmsefilestream.create(filename,fm_read);
 try
  result:= doloadfromstream(atry,stream,format,params);
 finally
  stream.free;
 end;
end;

function tmaskedbitmap.doloadfromstring(const atry: boolean;
               const avalue: string;
               const format: string; const params: array of const): string;
var
 stream1: tstringcopystream;
begin
 result:= '';
 if avalue = '' then begin
  clear;
 end
 else begin
  stream1:= tstringcopystream.create(avalue);
  try
   result:= doloadfromstream(atry,stream1,format,params);
  finally
   stream1.free;
  end;
 end;
end;

function tmaskedbitmap.tryloadfromstream(const stream: tstream;
           const format: string; const params: array of const): string;
begin
 result:= doloadfromstream(true,stream,format,params);
end;

function tmaskedbitmap.loadfromstream(const stream: tstream;
           const format: string; const params: array of const): string;
begin
 result:= doloadfromstream(false,stream,format,params);
end;


function tmaskedbitmap.loadfromfile(const filename: filenamety;
             const format: string; const params: array of const): string;
begin
 result:= doloadfromfile(false,filename,format,params);
end;

function tmaskedbitmap.tryloadfromfile(const filename: filenamety;
             const format: string; const params: array of const): string;
begin
 result:= doloadfromfile(true,filename,format,params);
end;

function tmaskedbitmap.loadfromstring(const avalue: string;
               const format: string; const params: array of const): string;
begin
 result:= doloadfromstring(false,avalue,format,params);
end;

function tmaskedbitmap.tryloadfromstring(const avalue: string;
               const format: string; const params: array of const): string;
begin
 result:= doloadfromstring(true,avalue,format,params);
end;

function tmaskedbitmap.loadfromstring(const avalue: string): string;
begin
 result:= loadfromstring(avalue,'',[]);
end;

function tmaskedbitmap.loadfromstream(const stream: tstream): string;
begin
 result:= loadfromstream(stream,'',[]);
end;

function tmaskedbitmap.loadfromfile(const filename: filenamety): string;
begin
 result:= loadfromfile(filename,'',[]);
end;

function tmaskedbitmap.tryloadfromstring(const avalue: string): string;
begin
 result:= tryloadfromstring(avalue,'',[]);
end;

function tmaskedbitmap.tryloadfromstream(const stream: tstream): string;
begin
 result:= tryloadfromstream(stream,'',[]);
end;

function tmaskedbitmap.tryloadfromfile(const filename: filenamety): string;
begin
 result:= tryloadfromfile(filename,'',[]);
end;

procedure tmaskedbitmap.writetostring(out avalue: string; const format: string;
                                  const params: array of const);
var
 stream1: tstringstream;
begin
 stream1:= tstringstream.create('');
 try
  writetostream(stream1,format,params);
  avalue:= stream1.datastring;
 finally
  stream1.free;
 end;
end;

function tmaskedbitmap.writetostring(const format: string;
                                  const params: array of const): string;
begin
 writetostring(result,format,params);
end;

procedure tmaskedbitmap.writetostream(const stream: tstream; const format: string;
                               const params: array of const);
begin
 writegraphic(stream,self,format,params);
end;

procedure tmaskedbitmap.writetofile(const filename: filenamety; const format: string;
                               const params: array of const);
var
 stream1: tmsefilestream;
begin
 stream1:= tmsefilestream.create(filename,fm_create);
 try
  writetostream(stream1,format,params)
 finally
  stream1.free;
 end;
end;

procedure tmaskedbitmap.loadfrommaskedimage(const aimage: maskedimagety);
begin
 loadfromimage(aimage.image);
 if aimage.mask.pixels <> nil then begin
  include(foptions,bmo_masked);
  createmask(aimage.mask.kind);
  fmask.loadfromimage(aimage.mask);
  foptions:= foptions - bmomaskkindoptions;
  case aimage.mask.kind of
   bmk_rgb: begin
    include(foptions,bmo_colormask);
   end;
   bmk_gray: begin
    include(foptions,bmo_graymask);
   end;
  end;
{
  if abuffer.mask.monochrome then begin
   exclude(foptions,bmo_colormask);
  end
  else begin
   include(foptions,bmo_colormask);   
  end;
}
  include(fstate,pms_maskvalid);
 end
 else begin
  freemask;
  exclude(foptions,bmo_masked);
  exclude(fstate,pms_maskvalid);
 end;  
end;

procedure tmaskedbitmap.savetomaskedimage(out aimage: maskedimagety);
begin
 savetoimage(aimage.image);
 if fmask <> nil then begin
  fmask.savetoimage(aimage.mask);
 end
 else begin
  fillchar(aimage.mask,sizeof(aimage.mask),0);
 end;
end;

function tmaskedbitmap.bitmap: tmaskedbitmap;
begin
 if fsource = nil then begin
  result:= self;
 end
 else begin
  result:= fsource.bitmap;
 end;
end;

procedure tmaskedbitmap.getcanvasimage(const bgr: boolean;
               var aimage: maskedimagety);
begin
 inherited;
 if fmask <> nil then begin
  fmask.checkimage(bgr);
  aimage.mask:= fmask.fimage;
 end;
end;

procedure tmaskedbitmap.setorigformatdata(const avalue: string);
begin
 forigformatdata:= avalue;
 if avalue <> '' then begin
  loadfromstring(avalue,forigformat,[]);
 end;
end;

procedure tmaskedbitmap.setkind(const avalue: bitmapkindty);
begin
 foptions:= foptions - bmokindoptions;
 case avalue of
  bmk_gray: begin
   include(foptions,bmo_gray);
  end;
  bmk_mono: begin
   include(foptions,bmo_monochrome);
  end;
 end;
 inherited;
end;

{
procedure tmaskedbitmap.loadfromresourcename(instance: longword;
  const resname: string);
var
 stream: tresourcestream;
 formatstream: tformatstream;
begin
 stream:= tresourcestream.Create(instance,uppercase(resname),RT_BITMAP);
 formatstream:= tformatstream.create(stream,'bmp');
 try
  readbmp(formatstream,0,self);
 finally
  formatstream.Free;
  stream.Free;
 end;
end;
}
{
procedure tmaskedbitmap.readimagefile(const filename: filenamety);
var
 stream: tmsefilestream;
begin
 stream:= tmsefilestream.create(filename,fm_read);
 try
  msebitmap.readimage(stream,self);
 finally
  stream.Free;
 end;
 change;
end;
}
{ tbitmapcomp }

constructor tbitmapcomp.create(aowner: tcomponent);
begin
 inherited;
 fbitmap:= tmaskedbitmap.create(bmk_rgb);
 fbitmap.fonchange:= {$ifdef FPC}@{$endif}change;
end;

destructor tbitmapcomp.destroy;
begin
 inherited;
 fbitmap.Free;
end;

procedure tbitmapcomp.setbitmap(const Value: tmaskedbitmap);
begin
 fbitmap.assign(value);
end;

procedure tbitmapcomp.change(const sender: tobject);
begin
 if fobjectlinker <> nil then begin
  fobjectlinker.sendevent(oe_changed);
 end;
 if assigned(fonchange) then begin
  fonchange(self);
 end;
end;

{ timagelist }

constructor timagelist.create(aowner: tcomponent);
var
 bmp1: tmaskedbitmap;
begin
 fsize:= defaultimagelistsize;
 inherited;
 bmp1:= tmaskedbitmap.create(bmk_rgb);
 bmp1.transparentcolor:= cl_none;
 setlength(fbitmaps,1);
 fbitmaps[0]:= bmp1;
 masked:= true;
end;

destructor timagelist.destroy;
begin
 if fbitmaps <> nil then begin //otherwise exception in constructor
  versioncount:= 1;
  fbitmaps[0].Free;
 end;
 inherited;
end;

function timagelist.getversioncount: int32;
begin
 result:= fversionhigh + 1;
end;

procedure timagelist.setversioncount(const avalue: int32);
var
 i1,i2: int32;
 bmp1,bmp2: tmaskedbitmap;
begin
 i1:= avalue - 1;
 if i1 < 0 then begin
  i1:= 0;
 end;
 if i1 <> fversionhigh then begin
  if i1 < fversionhigh then begin
   for i2:= fversionhigh downto i1 + 1 do begin
    fbitmaps[i2].destroy();
   end;
   setlength(fbitmaps,i1+1);
  end
  else begin
   bmp1:= fbitmaps[0];
   setlength(fbitmaps,avalue);
   for i2:= fversionhigh + 1 to i1 do begin
    bmp2:= tmaskedbitmap.create(bmp1.kind);
    if not (csreading in componentstate) then begin
     bmp2.assign(bmp1);
    end
    else begin
     bmp2.transparentcolor:= bmp1.transparentcolor;
     bmp2.options:= bmp1.options;
     bmp2.size:= bmp1.size;
    end;
    fbitmaps[i2]:= bmp2;
   end;
  end;
  fversionhigh:= i1;
  if fversiondefault > i1 then begin
   fversiondefault:= 0;
  end;
 end;
end;

procedure timagelist.setversiondefault(avalue: int32);
begin
 if (avalue < 0) or (avalue > fversionhigh) then begin
  avalue:= 0;
 end;
 if fversiondefault <> avalue then begin
  fversiondefault:= avalue;
  change();
 end;
end;

procedure timagelist.updateversionindex(var aindex: int32);
begin
 if (aindex < 0) then begin
  aindex:= fversiondefault;
 end
 else begin
  if aindex > fversionhigh then begin
   tlist.Error(SListIndexError, aIndex);
  end;
 end;
end;

function timagelist.getbitmaps(aindex: int32): tmaskedbitmap;
begin
 updateversionindex(aindex);
 result:= fbitmaps[aindex];
end;

function timagelist.getbitmap: tmaskedbitmap;
begin
 result:= fbitmaps[0];
end;

procedure timagelist.clear;
begin
 count:= 0;
end;

procedure timagelist.setsize(const avalue: sizety);
var
 int1: integer;
 bmp1,bmp2: tmaskedbitmap;
 sizebefore: sizety;
 countbefore: integer;
 rect1,rect2: rectty;
 i1: int32;
begin
 if not sizeisequal(fsize,avalue) then begin
  sizebefore:= fsize;
  fsize:= avalue;
  if fcount <> 0 then begin
   beginupdate;
   for i1:= 0 to fversionhigh do begin
    bmp1:= tmaskedbitmap.create(bmk_rgb);
    bmp1.assign(fbitmaps[i1]);
    bmp2:= tmaskedbitmap.create(bmk_rgb);
    bmp2.assign(fbitmaps[i1]); //get mask and color modes
    bmp2.size:= sizebefore;
    fbitmaps[i1].clear;
    countbefore:= fcount;
    count:= 0;
    count:= countbefore;
    rect1:= makerect(nullpoint,fsize);
    rect2:= makerect(nullpoint,sizebefore);
    centerinrect(rect1,rect2);
    for int1:= 0 to count - 1 do begin
     bmp2.canvas.copyarea(bmp1.canvas,rect2,nullpoint);
     if bmp1.mask <> nil then begin
      bmp2.mask.canvas.copyarea(bmp1.mask.canvas,rect2,nullpoint);
     end;
     setimage(int1,bmp2,rect1);
     with rect2 do begin
      inc(x,cx);
      if x >= bmp1.fsize.cx then begin
       x:= 0;
       inc(y,cy);
      end;
     end;
    end;
    bmp1.free;
    bmp2.free;
   end;
   endupdate;
  end;
 end;
end;

function timagelist.indextoorg(index: integer): pointty;
begin
 if (index < 0) or (index >= fcount) then begin
  gdierror(gde_invalidindex);
 end;
 result.x:= (index mod fcolcount) * fsize.cx;
 result.y:= (index div frowcount) * fsize.cy;
end;

function timagelist.getmasked: boolean;
begin
 result:= fbitmaps[0].masked;
end;

procedure timagelist.setmasked(const Value: boolean);
var
 i1: int32;
begin
 for i1:= 0 to fversionhigh do begin
  fbitmaps[i1].masked:= value;
 end;
end;
{
function timagelist.getmonochrome: boolean;
begin
 result:= fbitmap.monochrome;
end;
}
function timagelist.getgraymask: boolean;
begin
 result:= fbitmaps[0].graymask;
end;

procedure timagelist.setgraymask(const avalue: boolean);
var
 i1: int32;
begin
 for i1:= 0 to fversionhigh do begin
  fbitmaps[i1].graymask:= avalue;
 end;
end;

function timagelist.getcolormask: boolean;
begin
 result:= fbitmaps[0].colormask;
end;

procedure timagelist.setcolormask(const avalue: boolean);
var
 i1: int32;
begin
 for i1:= 0 to fversionhigh do begin
  fbitmaps[i1].colormask:= avalue;
 end;
end;
{
procedure timagelist.setmonochrome(const Value: boolean);
begin
 if fbitmap.monochrome <> value then begin
  fbitmap.monochrome:= value;
  change;
 end;
end;
}
procedure timagelist.paint(const acanvas: tcanvas; const index: integer; 
         const dest: rectty;  const alignment: alignmentsty = [];
         const acolor: colorty = cl_default;
         const acolorbackground: colorty = cl_default;
                         const aopacity: colorty = cl_default;
                         aversion: int32 = -1);
begin
 if (index >= 0) and (index < count) then begin
  updateversionindex(aversion);
  fbitmaps[aversion].paint(acanvas,dest,makerect(indextoorg(index),fsize),
                                   alignment,acolor,
                                          acolorbackground,aopacity);
 end;
end;

procedure timagelist.paint(const acanvas: tcanvas; const index: integer; 
         const dest: rectty; source: rectty;
         const alignment: alignmentsty = [];
         const acolor: colorty = cl_default;
         const acolorbackground: colorty = cl_default;
                         const aopacity: colorty = cl_default;
                          aversion: int32 = -1);

begin
 if (index >= 0) and (index < count) then begin
  updateversionindex(aversion);
  addpoint1(source.pos,indextoorg(index));
  fbitmaps[aversion].paint(acanvas,dest,source,alignment,acolor,acolorbackground,
                              aopacity);
 end;
end;

procedure timagelist.paintlookup(const acanvas: tcanvas; const index: integer;
               const dest: pointty; const acolor: colorty = cl_default;
               const acolorbackground: colorty = cl_default;
               const aopacity: colorty = cl_default; aversion: int32 = -1);
begin
 paint(acanvas,lookup(index),dest,acolor,acolorbackground,aopacity,aversion);
end;

procedure timagelist.paintlookup(const acanvas: tcanvas; const index: integer;
               const dest: rectty; const alignment: alignmentsty = [];
               const acolor: colorty = cl_default;
               const acolorbackground: colorty = cl_default;
               const aopacity: colorty = cl_default; aversion: int32 = -1);
begin
 paint(acanvas,lookup(index),dest,alignment,acolor,acolorbackground,aopacity,
                                   aversion);
end;

procedure timagelist.paintlookup(const acanvas: tcanvas; const index: integer;
               const dest: rectty; source: rectty;
               const alignment: alignmentsty = [];
               const acolor: colorty = cl_default;
               const acolorbackground: colorty = cl_default;
               const aopacity: colorty = cl_default; aversion: int32 = -1);
begin
 paint(acanvas,lookup(index),dest,alignment,acolor,acolorbackground,aopacity,
                           aversion);
end;

procedure timagelist.clipcornermask(const canvas: tcanvas;
                      const arect: rectty; const ahiddenedges: edgesty);
var
 rect2,rect3: rectty;
 po1,ps,pe: pint16;
 i1: int32;
begin
 if hascornermask then begin
  rect2.cy:= 1;
  rect3:= arect;
  if ahiddenedges * [edg_top,edg_left] = [] then begin
   po1:= pointer(cornermask_topleft);
   pe:= po1 + length(msestring(pointer(po1)));
   rect2.pos:= rect3.pos;
   ps:= po1;
   while ps < pe do begin
    rect2.cx:= ps^;
    canvas.subcliprect(rect2);
    inc(rect2.y);
    inc(ps);
   end;
  end;
  if ahiddenedges * [edg_left,edg_bottom] = [] then begin
   po1:= pointer(cornermask_bottomleft);
   pe:= po1 + length(msestring(pointer(po1)));
   rect2.x:= rect3.x;
   rect2.y:= rect3.y + rect3.cy - 1;
   ps:= po1;
   while ps < pe do begin
    rect2.cx:= ps^;
    canvas.subcliprect(rect2);
    dec(rect2.y);
    inc(ps);
   end;
  end;
  if ahiddenedges * [edg_bottom,edg_right] = [] then begin
   po1:= pointer(cornermask_bottomright);
   pe:= po1 + length(msestring(pointer(po1)));
   rect2.y:= rect3.y + rect3.cy - 1;
   ps:= po1;
   i1:= arect.x + arect.cx;
   while ps < pe do begin
    rect2.cx:= ps^;
    rect2.x:= i1 - ps^;
    canvas.subcliprect(rect2);
    dec(rect2.y);
    inc(ps);
   end;
  end;
  if ahiddenedges * [edg_right,edg_top] = [] then begin
   po1:= pointer(cornermask_topright);
   pe:= po1 + length(msestring(pointer(po1)));
   rect2.y:= rect3.y;
   ps:= po1;
   i1:= rect3.x + rect3.cx;
   while ps < pe do begin
    rect2.cx:= ps^;
    rect2.x:= i1 - ps^;
    canvas.subcliprect(rect2);
    inc(rect2.y);
    inc(ps);
   end;
  end;
 end;
end;

procedure timagelist.paint(const acanvas: tcanvas; const index: integer;
                   const dest: pointty; const acolor: colorty = cl_default;
                   const acolorbackground: colorty = cl_default;
                         const aopacity: colorty = cl_default;
                         aversion: int32 = -1);
begin
 paint(acanvas,index,makerect(dest,size),[],acolor,acolorbackground,
                              aopacity,aversion);
end;

function timagelist.gettransparentcolor: colorty;
begin
 result:= fbitmaps[0].ftransparentcolor;
end;

procedure timagelist.settransparentcolor(avalue: colorty);
var
 i1: int32;
begin
 if avalue = cl_invalid then begin
  avalue:= cl_none;
 end;
 for i1:= 0 to fversionhigh do begin
  fbitmaps[i1].transparentcolor:= avalue;
 end;
end;

procedure timagelist.setimage(index: integer; image: tmaskedbitmap;
                      const source: rectty; aalignment: alignmentsty = [];
                         aversion: int32 = -1);
var
 rect1,rect2,destrect: rectty;
 bo1: boolean;
 ima1: tmaskedbitmap;
 bmp1: tmaskedbitmap;
begin
 if (al_thumbnail in aalignment) and 
           ((source.cx > fsize.cx) or (source.cy > fsize.cy)) then begin
  include(aalignment,al_fit);
  exclude(aalignment,al_thumbnail);
 end;
 rect2.pos:= indextoorg(index);
 rect2.size:= fsize;
 updateversionindex(aversion);
 bmp1:= fbitmaps[aversion];
 if image = nil then begin
  bmp1.canvas.fillrect(rect2,
                           bmp1.colorbackground);
  if masked then begin
   if bmp1.mask.kind = bmk_mono then begin
    bmp1.mask.canvas.fillrect(rect2,cl_0);
   end
   else begin
    bmp1.mask.canvas.fillrect(
                         rect2,bmp1.fmaskcolorbackground);
   end;
  end;
 end
 else begin
  rect1:= source;
  ima1:= image;
  destrect:= calcrectalignment(rect2,source,aalignment);
  with rect1 do begin
   bo1:= (al_fit in aalignment) or 
               (x < 0) or (y < 0) or (x + cx > ima1.fsize.cx) or 
                  (y + cy > ima1.fsize.cy) or 
                  not(al_stretchx in aalignment) and (cx < fsize.cx) or
                  not(al_stretchy in aalignment) and (cy < fsize.cy);
   if not (al_fit in aalignment) then begin
    if not (al_stretchx in aalignment) and (cx > fsize.cx) then begin
     cx:= fsize.cx;
    end;
    if not (al_stretchy in aalignment) and (cy > fsize.cy) then begin
     cy:= fsize.cy;
    end;
   end;
  end;
  if masked then begin
   bmp1.copyarea(ima1,rect1,rect2,aalignment,rop_copy,false);
   if ima1.masked then begin
    if bo1 then begin
     if bmp1.mask.kind = bmk_mono then begin
      bmp1.mask.canvas.fillrect(rect2,cl_0);
     end
     else begin
      bmp1.mask.canvas.fillrect(rect2,
                     bmp1.fmaskcolorbackground);
     end;
    end;
    bmp1.mask.copyarea(
                  ima1.mask,rect1,rect2,aalignment,rop_copy,false,
                            bmp1.fmaskcolorforeground,
                                   bmp1.fmaskcolorbackground);
   end
   else begin
    if bo1 then begin
     if bmp1.mask.kind = bmk_mono then begin
      bmp1.mask.canvas.fillrect(rect2,cl_0);
     end
     else begin
      bmp1.mask.canvas.fillrect(rect2,
                                   bmp1.fmaskcolorbackground);
     end;
    end;
    if bmp1.mask.kind = bmk_mono then begin
     bmp1.mask.canvas.fillrect(destrect,cl_1);
    end
    else begin
     bmp1.mask.canvas.fillrect(
                         destrect,bmp1.fmaskcolorforeground);
    end;
   end;
  end
  else begin
   if bo1 then begin
    if kind = bmk_mono then begin
     bmp1.canvas.fillrect(rect2,cl_0);
    end
    else begin
     bmp1.canvas.fillrect(rect2,bmp1.fcolorbackground);
    end;
   end;
   bmp1.copyarea(ima1,rect1,rect2,aalignment,rop_copy,false);
  end;
 end;
 change;
end;

procedure timagelist.getimage(const index: integer; const dest: tmaskedbitmap;
                                                          aversion: int32 = -1);
var
 rect1: rectty;
 bmp1: tmaskedbitmap;
begin
 dest.clear;
 if (index >= 0) or (index < fcount) then begin
  updateversionindex(aversion);
  bmp1:= fbitmaps[aversion];
  dest.beginupdate();
  dest.kind:= bmp1.kind;
  dest.masked:= bmp1.masked;
  if dest.masked then begin
   dest.mask.kind:= bmp1.mask.kind;
  end;
  dest.transparentcolor:= bmp1.transparentcolor;
  dest.colorforeground:= bmp1.colorforeground;
  dest.colorbackground:= bmp1.colorbackground;
  rect1.pos:= indextoorg(index);
  rect1.size:= size;
  dest.size:= size;
  dest.copyarea(bmp1,rect1,nullpoint,rop_copy,false);
  if dest.masked then begin
   dest.mask.copyarea(bmp1.fmask,rect1,nullpoint,rop_copy,false);
  end;
  dest.endupdate();
 end;
end;

procedure timagelist.setimage(index: integer; image: tmaskedbitmap;
                                     const aalignment: alignmentsty = [];
                                                        aversion: int32 = -1);
begin
 if image = nil then begin
  setimage(index,nil,makerect(nullpoint,fsize),[],aversion);
 end
 else begin
  setimage(index,image,makerect(nullpoint,image.fsize),aalignment,aversion);
 end;
end;

procedure timagelist.copyimages(const image: tmaskedbitmap; 
                                                 const destindex: integer;
                                                 const aversion: int32);
var
 rect1: rectty;
 int1,int2: integer;
begin
 with image.fsize do begin
  if fsize.cx > cx then begin
   int2:= -(fsize.cx - cx) div 2;
  end
  else begin
   int2:= 0;
  end;
  if fsize.cy > cy then begin
   rect1.y:= -(fsize.cy - cy) div 2;
  end
  else begin
   rect1.y:= 0;
  end;
  rect1.cx:= cx - int2;
  rect1.cy:= cy - rect1.y;
 end;
 int1:= destindex;
 while rect1.y < image.fsize.cy do begin
  rect1.x:= int2;
  while rect1.x < image.fsize.cx do begin
   if int1 >= fcount then begin
    exit;
   end;
   setimage(int1,image,rect1,[],aversion);
   inc(int1);
   inc(rect1.x,fsize.cx);
  end;
  inc(rect1.y,fsize.cy);
 end;
end;

procedure timagelist.setcount(const Value: integer);

var
 int1,int2: integer;
 buffer: tmaskedbitmap;
 bo1: boolean;
 i1: int32;

begin
 if fcount <> value then begin
  fcount := Value;
  if value = 0 then begin
   for i1:= 0 to fversionhigh do begin
    fbitmaps[i1].clear;
   end;
   frowcount:= 0;
   fcolcount:= 0;
  end
  else begin
   int1:= bits[highestbit(fcount) div 2 + 1];
   repeat
    int2:= int1;
    int1:= (int1 * 7) shr 3; //7/8 -> 0.875*0.875 -> 0.765
    if int1 = int2 then begin
     dec(int1);
    end;
   until int1 * int1 < fcount;
   bo1:= (frowcount <> int2) or (fcolcount <> int2);
   frowcount:= int2; //square
   fcolcount:= int2;
   if bo1 then begin
    for i1:= 0 to fversionhigh do begin
     buffer:= tmaskedbitmap.create(kind);
     buffer.assign1(fbitmaps[i1],false);
     fbitmaps[i1].size:= makesize(int2*fsize.cx,int2*fsize.cy);
     if not buffer.isempty then begin
      copyimages(buffer,0,i1);
     end;
     buffer.Free;
    end;
   end;
  end;
  change;
 end;
end;

function timagelist.addimage(const image: tmaskedbitmap;
                            const aalignment: alignmentsty = []{;
                                         const aversion: int32 = 0}): integer;
var
 newcolcount,newrowcount,newcount: integer;
 bmp1: tmaskedbitmap;
 i1: int32;
begin
// checkversionindex(aversion);
 result:= -1;
 if image = nil then begin
  result:= fcount;
  count:= fcount+1;
  for i1:= 0 to fversionhigh do begin
   setimage(result,nil,[],i1);
  end;
 end
 else begin
  if not image.isempty then begin
   result:= fcount;
   beginupdate;
   bmp1:= nil;
   try
    if (fsize.cx = 0) or (fsize.cy = 0) then begin
     if image = nil then begin
      exit;
     end;
     fsize:= image.fsize;
    end;
    if aalignment <> [] then begin
     bmp1:= tmaskedbitmap.create(image.kind);
     bmp1.size:= fsize;
     image.stretch(bmp1,aalignment);
    end
    else begin
     bmp1:= image;
    end;     
    newcolcount:= (bmp1.size.cx + fsize.cx-1) div fsize.cx;
    newrowcount:= (bmp1.size.cy + fsize.cy-1) div fsize.cy;
    newcount:= newcolcount * newrowcount;
    count:= fcount + newcount;
    for i1:= 0 to fversionhigh do begin
     copyimages(bmp1,result,i1);
    end;
   finally
    if bmp1 <> image then begin
     bmp1.free;
    end;
    endupdate;
   end;
  end;
 end;
end;

procedure timagelist.deleteimage(const index: integer);
var
 i1: int32;
begin
 for i1:= 0 to fversionhigh do begin
  moveimage(index,count-1,i1);
 end;
 count:= fcount - 1;
end;

procedure timagelist.moveimage(const fromindex: integer; const toindex: integer;
                                                 aversion: int32 = -1);
var
 bmp1,bmp2: tmaskedbitmap;
 int1: integer;
// i1,i2: int32;
begin
 if fromindex <> toindex then begin
  updateversionindex(aversion);
  beginupdate;
  try
   bmp1:= tmaskedbitmap.create(kind);
   bmp1.maskkind:= fbitmaps[0].maskkind;
   bmp1.masked:= masked;
   bmp2:= tmaskedbitmap.create(kind);
   bmp2.maskkind:= fbitmaps[0].maskkind;
   bmp2.masked:= masked;
//   i2:= fversioncurrent;
   try
//    for i1:= 0 to fversionhigh do begin
//     fversioncurrent:= i1;
     getimage(fromindex,bmp1,aversion);
     if fromindex < toindex then begin
      for int1:= fromindex + 1 to toindex do begin
       getimage(int1,bmp2,aversion);
       setimage(int1-1,bmp2,[],aversion);
      end;
     end
     else begin
      for int1:= fromindex-1 downto toindex do begin
       getimage(int1,bmp2,aversion);
       setimage(int1+1,bmp2,[],aversion);
      end;
     end;
     setimage(toindex,bmp1,[],aversion);
//    end;
   finally
//    fversioncurrent:= i2;
    bmp1.free;
    bmp2.Free;
   end;
  finally
   endupdate;
  end;
 end;
end;

procedure timagelist.setheight(const Value: integer);
begin
 setsize(makesize(fsize.cx,Value));
end;

procedure timagelist.setwidth(const Value: integer);
begin
 setsize(makesize(value,fsize.cy));
end;
{
procedure timagelist.setbitmap(const Value: tmaskedbitmap);
begin
 addimage(fbitmap); //???
end;
}
procedure timagelist.beginupdate;
begin
 inc(fupdating);
end;

procedure timagelist.endupdate;
begin
 dec(fupdating);
 change;
end;

procedure timagelist.change;
begin
 if (fupdating = 0) then begin
  if fobjectlinker <> nil then begin
   fobjectlinker.sendevent(oe_changed);
  end;
  if canevent(tmethod(fonchange)) then begin
   fonchange(self);
  end;
 end;
end;

procedure timagelist.readmasked(reader: treader);
begin
 masked:= reader.readboolean;
end;

procedure timagelist.readcolormask(reader: treader);
begin
 colormask:= reader.readboolean;
end;

procedure timagelist.readmonochrome(reader: treader);
begin
 if reader.readboolean then begin
  kind:= bmk_mono;
 end;
end;

procedure timagelist.readcornermask(reader: treader);
begin
 fcornermask_topleft:= reader.readunicodestring;
 fcornermask_bottomleft:= fcornermask_topleft;
 fcornermask_bottomright:= fcornermask_topleft;
 fcornermask_topright:= fcornermask_topleft;
 cornermaskchanged();
end;

procedure timagelist.writeimage(stream: tstream);
var
 i1: int32;
begin
 for i1:= 0 to fversionhigh do begin
  fbitmaps[i1].writeimage(stream);
 end;
end;

procedure timagelist.readimage(stream: tstream);
var
 i1: int32;
begin
 for i1:= 0 to fversionhigh do begin
  fbitmaps[i1].readimage(stream);
 end;
end;

procedure timagelist.defineproperties(filer: tfiler);

 function checkimage(): boolean;
 var
  i1: int32;
 begin
  with timagelist(filer.ancestor) do begin
   result:= (self.count <> count) or (self.fversionhigh <> fversionhigh) or
         (self.fsize.cx <> fsize.cx) or (self.fsize.cy <> fsize.cy) or
         (self.fbitmaps[0].options <> fbitmaps[0].options);
   if not result then begin
    for i1:= 0 to fversionhigh do begin
     if self.fbitmaps[i1].writedata(fbitmaps[i1]) then begin
      result:= true;
      break;
     end;
    end;
   end;
  end;
 end; //checkimage

var
 ancestorbefore: tpersistent;
begin
 inherited;
 filer.defineproperty('monochrome',@readmonochrome,nil,false);
 filer.defineproperty('masked',@readmasked,nil,false);
 filer.defineproperty('colormask',@readcolormask,nil,false);
 filer.defineproperty('cornermask',@readcornermask,nil,false);
 if fversionhigh = 0 then begin
  ancestorbefore:= filer.ancestor;
  if (ancestorbefore <> nil) then begin
   filer.ancestor:= timagelist(ancestorbefore).fbitmaps[0];
  end;
  fbitmaps[0].defineproperties(filer); //imagedata
  filer.ancestor:= ancestorbefore;
 end
 else begin
  filer.definebinaryproperty('image',@readimage,@writeimage,
                               (filer.ancestor = nil) or checkimage());
 end;
end;

function timagelist.lookup(const aindex: int32): int32;
begin
 result:= aindex;
 if findexlookup <> '' then begin
  result:= -1;
  if (aindex >= 0) and (aindex < length(findexlookup)) then begin
   result:= pint16(findexlookup)[aindex];
  end;
 end;
end;

procedure timagelist.assign(sender: tpersistent);
var
 i1: int32;
begin
 if sender is timagelist then begin
  count:= 0;
  with timagelist(sender) do begin
   self.versioncount:= versioncount;
   self.fsize:= fsize;
   self.fcolcount:= fcolcount;
   self.frowcount:= frowcount;
   self.fcount:= fcount;
   for i1:= 0 to fversionhigh do begin
    self.fbitmaps[i1].assign(fbitmaps[i1]);
   end;
  end;
  change;
 end
 else begin
  inherited;
 end;
end;

function timagelist.getkind: bitmapkindty;
begin
 result:= fbitmaps[0].kind;
end;

procedure timagelist.setkind(const avalue: bitmapkindty);
var
 i1: int32;
begin
 for i1:= 0 to fversionhigh do begin
  fbitmaps[i1].kind:= avalue;
 end;
end;

function timagelist.getmaskkind: bitmapkindty;
begin
 result:= fbitmaps[0].maskkind;
end;

procedure timagelist.setmaskkind(const avalue: bitmapkindty);
var
 i1: int32;
begin
 for i1:= 0 to fversionhigh do begin
  fbitmaps[i1].maskkind:= avalue;
 end;
end;

function timagelist.getoptions: bitmapoptionsty;
begin
 result:= fbitmaps[0].options;
end;

procedure timagelist.setoptions(const avalue: bitmapoptionsty);
var
 i1: int32;
begin
 for i1:= 0 to fversionhigh do begin
  fbitmaps[i1].options:= avalue;
 end;
end;

procedure timagelist.setindexlookup(const avalue: msestring);
begin
 findexlookup:= avalue;
 change;
end;

procedure timagelist.setcornermask_topleft(const avalue: msestring);
begin
 fcornermask_topleft:= avalue;
 cornermaskchanged();
end;

procedure timagelist.setcornermask_bottomleft(const avalue: msestring);
begin
 fcornermask_bottomleft:= avalue;
 cornermaskchanged();
end;

procedure timagelist.setcornermask_bottomright(const avalue: msestring);
begin
 fcornermask_bottomright:= avalue;
 cornermaskchanged();
end;

procedure timagelist.setcornermask_topright(const avalue: msestring);
begin
 fcornermask_topright:= avalue;
 cornermaskchanged();
end;

procedure timagelist.cornermaskchanged();

 procedure check(const avalue: msestring; var maxwidth: int32);
 var
  po1,pe: pint16;
 begin
  maxwidth:= 0;
  if avalue <> '' then begin
   fhascornermask:= true;
   po1:= pointer(avalue);
   pe:= po1 + length(avalue);
   while po1 < pe do begin
    if po1^ > maxwidth then begin
     maxwidth := po1^;
    end;
    inc(po1);
   end;
  end;
 end; //check

begin
 if not (csloading in componentstate) then begin
  fhascornermask:= false;
  check(fcornermask_topleft,fcornermaskmaxtopleft);
  check(fcornermask_bottomleft,fcornermaskmaxbottomleft);
  check(fcornermask_bottomright,fcornermaskmaxbottomright);
  check(fcornermask_topright,fcornermaskmaxtopright);
  change;
 end
 else begin
  fneedscornermaskcheck:= true;
 end;
end;

procedure timagelist.loaded();
begin
 inherited;
 if fneedscornermaskcheck then begin
  cornermaskchanged();
  fneedscornermaskcheck:= false;
 end;
end;

{ tcenteredbitmap }

constructor tcenteredbitmap.create(const akind: bitmapkindty;
                     const agdifuncs: pgdifunctionaty = nil);
begin
 inherited;
 alignment:= [al_xcentered,al_ycentered];
end;

{ tbitmapcanvas }
{
constructor tbitmapcanvas.create(const user: tbitmap);
begin
 inherited create(user,icanvas(user));
end;

function tbitmapcanvas.getimage(const bgr: boolean): imagety;
begin
 with tbitmap(fuser) do begin
  checkimage(bgr);
  result:= fimage;
 end;
end;
}
{ townedbitmap }

constructor townedbitmap.create(const aowner: tbitmap;
            const akind: bitmapkindty; const agdifuncs: pgdifunctionaty = nil);
begin
 fowner:= aowner;
 inherited create(akind,agdifuncs);
end;

procedure townedbitmap.dochange;
begin
 inherited;
 fowner.change();
end;

end.
