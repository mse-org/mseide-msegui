{ MSEgui Copyright (c) 2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseinterfaces;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

//Interface UID's for MSEide+MSEgui
type
 mseinterfacenumbers = (
min_iformdesigner,
min_idbeditfieldlink,
min_idbevent,
min_isqlpropertyeditor,
min_imasterlink,
min_imselocate,
min_idbdata,
min_idbeditinfo,
min_ireccontrol,
min_ipersistentfieldsinfo,
min_idatasetsum,
min_ifieldcomponent,
min_imsefield,
min_igetdscontroller,
min_idbcontroller,
min_ilookupbufferfieldinfo,
min_idbparaminfo,
min_idbcolinfo,
min_iblobconnection,
min_igridwidget,
min_iimagelistinfo,
//min_iimagelistinfo,
min_iifilink,
min_iifiexeclink,
min_iififormlink,
min_iifidialoglink,
min_iifidatalink,
min_iifigridlink,
min_iififieldinfo,
min_iififieldsource,
min_iififieldlinksource,
min_iifidataconnection,
min_iifidbdataconnection,
min_iificlient,
min_iificommand,
min_iifitxaction,
min_iifimodulelink,
min_iactionlink,
min_iactivatorclient,
min_istatfile,
min_ibandparent,
min_idocktarget,
min_itabpage,
min_iassistiveclient,
min_iassistiveserver,
min_irecordfield,
min_irecordvaluefield,
mim_idockcontroller,
min_iassistiveclientgrid,
min_iassistiveclientmenu,
min_irichstringprop);

const
 miid_iformdesigner =          'AA.mse';{0}
 miid_idbeditfieldlink =       'gA.mse';{1}
 miid_idbevent =               'QA.mse';{2}
 miid_isqlpropertyeditor =     'wA.mse';{3}
 miid_imasterlink =            'IA.mse';{4}
 miid_imselocate =             'oA.mse';{5}
 miid_idbdata =                'YA.mse';{6}
 miid_idbeditinfo =            '4A.mse';{7}
 miid_ireccontrol =            'EA.mse';{8}
 miid_ipersistentfieldsinfo =  'kA.mse';{9}
 miid_idatasetsum =            'UA.mse';{10}
 miid_ifieldcomponent =        '0A.mse';{11}
 miid_imsefield =              'MA.mse';{12}
 miid_igetdscontroller =       'sA.mse';{13}
 miid_idbcontroller =          'cA.mse';{14}
 miid_ilookupbufferfieldinfo = '8A.mse';{15}
 miid_idbparaminfo =           'CA.mse';{16}
 miid_idbcolinfo =             'iA.mse';{17}
 miid_iblobconnection =        'SA.mse';{18}
 miid_igridwidget =            'yA.mse';{19}
 miid_iimagelistinfo =         'KA.mse';{20}
// miid_iimagelistinfo =         'qA.mse';{21}
 miid_iifilink =               'aA.mse';{22}
 miid_iifiexeclink =           '6A.mse';{23}
 miid_iififormlink =           'GA.mse';{24}
 miid_iifidialoglink =         'mA.mse';{25}
 miid_iifidatalink =           'WA.mse';{26}
 miid_iifigridlink =           '2A.mse';{27}
 miid_iififieldinfo =          'OA.mse';{28}
 miid_iififieldsource =        'uA.mse';{29}
 miid_iififieldlinksource =    'eA.mse';{30}
 miid_iifidataconnection =     '+A.mse';{31}
 miid_iifidbdataconnection =   'BA.mse';{32}
 miid_iificlient =             'hA.mse';{33}
 miid_iificommand =            'RA.mse';{34}
 miid_iifitxaction =           'xA.mse';{35}
 miid_iifimodulelink =         'JA.mse';{36}
 miid_iactionlink =            'pA.mse';{37}
 miid_iactivatorclient =       'ZA.mse';{38}
 miid_istatfile =              '5A.mse';{39}
 miid_ibandparent =            'FA.mse';{40}
 miid_idocktarget =            'lA.mse';{41}
 miid_itabpage =               'VA.mse';{42}
 miid_idbdispfieldlink =       '1A.mse';{43}
 miid_iassistiveclient =       'NA.mse';{44}
 miid_iassistiveserver =       'tA.mse';{45}
 miid_irecordfield =           'dA.mse';{46}
 miid_irecordvaluefield =      '9A.mse';{47}
 miid_idockcontroller =        'DA.mse';{48}
 miid_iassistiveclientgrid =   'jA.mse';{49}
 miid_iassistiveclientmenu =   'TA.mse';{50}
 miid_irichstringprop =        'zA.mse';{51}
  
implementation
end.
