// mseprintintf.inc

type
  printerpropertiesty = record
    printername: string;
    drivername: string;
    location: string;
    description: string;
    isdefault: boolean;
    isshared: boolean;
    islocal: boolean;
  end;

function pri_getprinterlist: msestringarty;
function pri_getdefaultprinter: msestring;
function pri_getprinterproperties(const printername: msestring;
            var properties: printerpropertiesty): boolean;
