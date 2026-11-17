#!/usr/bin/env python3
"""wl2pas.py - generates a Free Pascal binding unit from a Wayland protocol XML.

Usage:
  python3 wl2pas.py --unit waylandcore --out waylandcore.pas \
          /usr/share/wayland/wayland.xml
  python3 wl2pas.py --unit waylandxdgshell --uses waylandcore \
          --out waylandxdgshell.pas \
          /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml

Generated for every interface of the XML file:
  - constants: version, request opcodes (<if>_req_<name>), event opcodes
    (<if>_ev_<name>), enum values (<if>_<enum>_<entry>)
  - the interface table  <if>_interface : twl_interface
  - a listener record type  t<if>_listener  and  <if>_add_listener()
  - one function/procedure per request, <if>_<request>(proxy, ...)
Objects are plain pointers (pwl_proxy). The tables are filled in the
initialization section of the generated unit. The runtime part is in
waylandbase.pas.
"""
import argparse
import sys
import xml.etree.ElementTree as ET

KEYWORDS = set("""and array as asm begin case class const constructor
destructor dispinterface div do downto else end except exports file
finalization finally for function goto if implementation in inherited
initialization inline interface is label library mod nil not object of on
operator or out packed procedure program property raise record repeat
resourcestring set shl shr string then threadvar to try type unit until uses
var while with xor result data proxy iface version""".split())


def ident(name):
    if name in KEYWORDS:
        return name + '_'
    return name


SIG = {'int': 'i', 'uint': 'u', 'fixed': 'f', 'string': 's', 'object': 'o',
       'new_id': 'n', 'array': 'a', 'fd': 'h'}
PTYPE = {'int': 'cint32', 'uint': 'cuint32', 'fixed': 'cint32',
         'string': 'pchar', 'object': 'pointer', 'new_id': 'pointer',
         'array': 'pwl_array', 'fd': 'cint32'}


def pascal_value(text):
    text = text.strip()
    if text.lower().startswith('0x'):
        return '$' + text[2:]
    return text


def message_info(msg):
    """returns (signature, list of interface names or None per type slot)"""
    since = int(msg.get('since', '1'))
    sig = ''
    types = []
    for arg in msg.findall('arg'):
        atype = arg.get('type')
        if atype == 'new_id' and arg.get('interface') is None:
            sig += 'sun'
            types += [None, None, None]
        else:
            if arg.get('allow-null') == 'true':
                sig += '?'
            sig += SIG[atype]
            if atype in ('object', 'new_id'):
                types.append(arg.get('interface'))
            else:
                types.append(None)
    if since > 1:
        sig = str(since) + sig
    return sig, types


class Gen:
    def __init__(self, unitname, uses, source):
        self.unitname = unitname
        self.uses = uses
        self.source = source
        self.const = []
        self.types = []
        self.vars = []
        self.decl = []
        self.impl = []
        self.init = []

    def interface(self, iface):
        iname = iface.get('name')
        iver = iface.get('version', '1')
        requests = iface.findall('request')
        events = iface.findall('event')

        # constants
        self.const.append('  %s_version = %s;' % (iname, iver))
        for i, m in enumerate(requests):
            self.const.append('  %s_req_%s = %d;' % (iname, m.get('name'), i))
        for i, m in enumerate(events):
            self.const.append('  %s_ev_%s = %d;' % (iname, m.get('name'), i))
        for enum in iface.findall('enum'):
            for entry in enum.findall('entry'):
                self.const.append('  %s_%s_%s = %s;' % (
                    iname, enum.get('name'), entry.get('name'),
                    pascal_value(entry.get('value'))))

        # tables
        self.vars.append('  %s_interface: twl_interface;' % iname)
        if requests:
            self.vars.append('  wlm_%s_req: array[0..%d] of twl_message;' %
                             (iname, len(requests) - 1))
        if events:
            self.vars.append('  wlm_%s_ev: array[0..%d] of twl_message;' %
                             (iname, len(events) - 1))

        for kind, msgs, arr in (('req', requests, 'req'), ('ev', events, 'ev')):
            for i, m in enumerate(msgs):
                sig, types = message_info(m)
                tname = 'wlt_%s_%s_%s' % (iname, kind, m.get('name'))
                tptr = 'nil'
                if types:
                    self.vars.append('  %s: array[0..%d] of pwl_interface;' %
                                     (tname, len(types) - 1))
                    for k, t in enumerate(types):
                        if t is None:
                            self.init.append('  %s[%d]:= nil;' % (tname, k))
                        else:
                            self.init.append('  %s[%d]:= @%s_interface;' %
                                             (tname, k, t))
                    tptr = '@%s[0]' % tname
                self.init.append(
                    "  wl_setmessage(wlm_%s_%s[%d],'%s','%s',%s);" %
                    (iname, arr, i, m.get('name'), sig, tptr))
        rptr = 'nil'
        eptr = 'nil'
        if requests:
            rptr = '@wlm_%s_req[0]' % iname
        if events:
            eptr = '@wlm_%s_ev[0]' % iname
        self.init.append("  wl_setinterface(%s_interface,'%s',%s,%d,%s,%d,%s);" %
                         (iname, iname, iver, len(requests), rptr,
                          len(events), eptr))

        # listener
        if events:
            self.types.append('  p%s_listener = ^t%s_listener;' % (iname, iname))
            self.types.append('  t%s_listener = record' % iname)
            for m in events:
                params = ['data: pointer', 'proxy: pointer']
                for arg in m.findall('arg'):
                    params.append('%s: %s' % (ident(arg.get('name')),
                                              PTYPE[arg.get('type')]))
                self.types.append('   %s: procedure(%s); cdecl;' % (
                    ident(m.get('name')), '; '.join(params)))
            self.types.append('  end;')
            self.decl.append(
                'function %s_add_listener(proxy: pointer; '
                'const listener: p%s_listener; data: pointer): cint;' %
                (iname, iname))
            self.impl.append(
                'function %s_add_listener(proxy: pointer; '
                'const listener: p%s_listener; data: pointer): cint;\n'
                'begin\n'
                ' result:= wl_proxy_add_listener(proxy,listener,data);\n'
                'end;\n' % (iname, iname))
            # libwayland aborts on an event whose listener slot is nil
            self.decl.append(
                'procedure %s_noop_listener(var listener: t%s_listener);' %
                (iname, iname))
            self.impl.append(
                'procedure %s_noop_listener(var listener: t%s_listener);\n'
                'begin\n'
                ' wl_fillnoop(listener,sizeof(listener));\n'
                'end;\n' % (iname, iname))

        # requests
        for i, m in enumerate(requests):
            self.request(iname, i, m)

    def request(self, iname, opcode, m):
        rname = m.get('name')
        params = ['proxy: pointer']
        callargs = []
        retiface = None
        untyped = False
        for arg in m.findall('arg'):
            atype = arg.get('type')
            if atype == 'new_id':
                if arg.get('interface'):
                    retiface = arg.get('interface')
                    callargs.append('pointer(nil)')
                else:
                    untyped = True
                    params.append('iface: pwl_interface')
                    params.append('version: cuint32')
                    callargs += ['iface^.name', 'version', 'pointer(nil)']
            else:
                params.append('%s: %s' % (ident(arg.get('name')), PTYPE[atype]))
                callargs.append(ident(arg.get('name')))
        if untyped:
            ifaceexpr = 'iface'
            verexpr = 'version'
        elif retiface:
            ifaceexpr = '@%s_interface' % retiface
            verexpr = 'wl_proxy_get_version(proxy)'
        else:
            ifaceexpr = 'nil'
            verexpr = 'wl_proxy_get_version(proxy)'
        if m.get('type') == 'destructor':
            flags = '1'
        else:
            flags = '0'
        call = 'wl_proxy_marshal_flags(proxy,%s_req_%s,%s,%s,%s' % (
            iname, rname, ifaceexpr, verexpr, flags)
        if callargs:
            call += ',' + ','.join(callargs)
        call += ')'
        fname = '%s_%s' % (iname, rname)
        if retiface or untyped:
            head = 'function %s(%s): pointer;' % (fname, '; '.join(params))
            body = ' result:= %s;' % call
        else:
            head = 'procedure %s(%s);' % (fname, '; '.join(params))
            body = ' %s;' % call
        self.decl.append(head)
        self.impl.append('%s\nbegin\n%s\nend;\n' % (head, body))

    def text(self):
        out = []
        out.append('unit %s;' % self.unitname)
        out.append('{ GENERATED by wl2pas.py from %s - do not edit by hand. }' %
                   self.source)
        out.append('{$mode objfpc}{$h+}')
        out.append('')
        out.append('interface')
        out.append('uses')
        out.append('  ctypes,waylandbase%s;' %
                   ''.join(',' + u for u in self.uses))
        out.append('')
        out.append('const')
        out += self.const
        out.append('')
        if self.types:
            out.append('type')
            out += self.types
            out.append('')
        out.append('var')
        out += self.vars
        out.append('')
        out += self.decl
        out.append('')
        out.append('implementation')
        out.append('')
        out += self.impl
        out.append('procedure wlinit;')
        out.append('begin')
        out += self.init
        out.append('end;')
        out.append('')
        out.append('initialization')
        out.append(' wlinit;')
        out.append('end.')
        return '\n'.join(out) + '\n'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--unit', required=True)
    ap.add_argument('--uses', default='')
    ap.add_argument('--out', required=True)
    ap.add_argument('xml')
    args = ap.parse_args()
    uses = [u for u in args.uses.split(',') if u]
    root = ET.parse(args.xml).getroot()
    gen = Gen(args.unit, uses, args.xml.split('/')[-1])
    for iface in root.findall('interface'):
        gen.interface(iface)
    with open(args.out, 'w') as f:
        f.write(gen.text())
    print('wrote', args.out, '-', len(root.findall('interface')), 'interfaces')


if __name__ == '__main__':
    sys.exit(main())
