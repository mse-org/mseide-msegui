{ MSEide Copyright (c) 2007-2013 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit msefadepropedit;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msepropertyeditors;
 
type
 tfacefadecoloreditor = class(tcolorarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
 end;

 tfacefadeposeditor = class(trealarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override; 
 end;
 
 tfacetemplatefadecoloreditor = class(tcolorarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
 end;

 tfacetemplatefadeposeditor = class(trealarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override; 
 end;

 tfacefadeopacoloreditor = class(tcolorarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
 end;

 tfacefadeopaposeditor = class(trealarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override; 
 end;
 
 tfacetemplatefadeopacoloreditor = class(tcolorarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override;
 end;

 tfacetemplatefadeopaposeditor = class(trealarraypropertyeditor)
  protected
   function getdefaultstate: propertystatesty; override;
  public
   procedure edit; override; 
 end;

implementation
uses
 msegraphutils,msearrayprops,msegui,msefadeedit,mseglob;
 
type
 tpropertyeditor1 = class(tpropertyeditor);

procedure editfacefade(const aproperty: tpropertyeditor; const opa: boolean);
var
 direct: graphicdirectionty;
 fadepos,fadeopapos: trealarrayprop;
 fadecolor,fadeopacolor: tcolorarrayprop;
 int1: integer;
begin
 with tcustomface(tpropertyeditor1(aproperty).instance) do begin
  direct:= fade_direction; 
  fadepos:= fade_pos;
  fadeopapos:= fade_opapos;
  fadecolor:= fade_color;
  fadeopacolor:= fade_opacolor;
  if editfade(direct,opa,fade_pos,fade_opapos,
                               fade_color,fade_opacolor) = mr_ok then begin
   fade_direction:= direct;
   with tpropertyeditor1(aproperty) do begin
    for int1:= 1 to count - 1 do begin
     with tcustomface(tpropertyeditor1(aproperty).instance(int1)) do begin
      fade_direction:= direct;
      if opa then begin
       fade_opapos.assign(fadeopapos);
       fade_opacolor.assign(fadeopacolor);
      end
      else begin
       fade_opapos.assign(fadepos);
       fade_opacolor.assign(fadecolor);
      end;
     end;
    end;    
    modified;
   end;
  end;
 end;
end;

procedure editfacetemplatefade(const aproperty: tpropertyeditor;
                                                   const opa: boolean);
var
 direct: graphicdirectionty;
 fadepos,fadeopapos: trealarrayprop;
 fadecolor,fadeopacolor: tcolorarrayprop;
 int1: integer;
begin
 with tfacetemplate(tpropertyeditor1(aproperty).instance) do begin
  direct:= fade_direction; 
  fadepos:= fade_pos;
  fadeopapos:= fade_opapos;
  fadecolor:= fade_color;
  fadeopacolor:= fade_opacolor;
  if editfade(direct,opa,fade_pos,fade_opapos,
                               fade_color,fade_opacolor) = mr_ok then begin
   fade_direction:= direct;
   with tpropertyeditor1(aproperty) do begin
    for int1:= 1 to count - 1 do begin
     with tfacetemplate(tpropertyeditor1(aproperty).instance(int1)) do begin
      fade_direction:= direct;
      if opa then begin
       fade_opapos.assign(fadeopapos);
       fade_opacolor.assign(fadeopacolor);
      end
      else begin
       fade_opapos.assign(fadepos);
       fade_opacolor.assign(fadecolor);
      end;
     end;
    end;    
    modified;
   end;
  end;
 end;
end;

{ tfacefadecoloreditor }

function tfacefadecoloreditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacefadecoloreditor.edit;
begin
 editfacefade(self,false);
end;

{ tfacefadeposeditor }

function tfacefadeposeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacefadeposeditor.edit;
begin
 editfacefade(self,false);
end;

{ tfacetemplatefadecoloreditor }

function tfacetemplatefadecoloreditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacetemplatefadecoloreditor.edit;
begin
 editfacetemplatefade(self,false);
end;

{ tfacetemplatefadeposeditor }

function tfacetemplatefadeposeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacetemplatefadeposeditor.edit;
begin
 editfacetemplatefade(self,false);
end;

{ tfacefadeopacoloreditor }

function tfacefadeopacoloreditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacefadeopacoloreditor.edit;
begin
 editfacefade(self,true);
end;

{ tfacefadeopaposeditor }

function tfacefadeopaposeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacefadeopaposeditor.edit;
begin
 editfacefade(self,true);
end;

{ tfacetemplatefadeopacoloreditor }

function tfacetemplatefadeopacoloreditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacetemplatefadeopacoloreditor.edit;
begin
 editfacetemplatefade(self,true);
end;

{ tfacetemplatefadeopaposeditor }

function tfacetemplatefadeopaposeditor.getdefaultstate: propertystatesty;
begin
 result:= inherited getdefaultstate + [ps_dialog];
end;

procedure tfacetemplatefadeopaposeditor.edit;
begin
 editfacetemplatefade(self,true);
end;

end.
