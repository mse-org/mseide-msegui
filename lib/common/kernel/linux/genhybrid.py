#!/usr/bin/env python3
# genhybrid.py - generates the MSEgui hybrid (X11 + Wayland) gui interface.
#
# Run it in this directory (kernel/hybrid):   python3 genhybrid.py
#
# Lives in kernel/linux.
# Reads    ../mseguiintf.inc            (the common gui_* interface)
#          mseguiintfx11.inc            (X11 backend, interface part)
# Writes   mseguiintfhybrid.inc         (dispatcher, unit mseguiintf)
#          mseguiintfhybrid_decl.inc    (interface declarations)
#          mseguiintfhybrid_impl.inc    (forwarders)
#
# The hybrid is the X11 flavour of the common code, compile with -dusehybrid.
# mseguiintf.pas includes mseguiintfhybrid.inc in that case.
import os
import re
import sys

here = os.path.dirname(os.path.abspath(__file__))
kernel = os.path.normpath(os.path.join(here, '..'))
DEFINES = {'usehybrid'}   # usesdl is NOT defined
MANUAL = {'msedisplay', 'msevisual', 'msedefaultscreen',
          'msedefaultscreenno'}                   # forwarded to X11, see below
SKIP = {'gui_init'}                               # written by hand below


def readfile(path):
    with open(path, encoding='utf-8', errors='surrogateescape') as f:
        return f.read()


def writefile(name, text):
    with open(os.path.join(here, name), 'w', encoding='utf-8',
              errors='surrogateescape', newline='\n') as f:
        f.write(text)
    print('written', name)


def cond_eval(expr):
    e = re.sub(r'defined\s*\(\s*(\w+)\s*\)',
               lambda m: 'True' if m.group(1).lower() in DEFINES else 'False',
               expr, flags=re.I)
    e = re.sub(r'\b(not|and|or)\b', lambda m: m.group(1).lower(), e,
               flags=re.I)
    return bool(eval(e, {'__builtins__': {}}, {}))


def clean(text):
    """removes comments, keeps compiler directives as \\x00...\\x01"""
    out = []
    i = 0
    n = len(text)
    while i < n:
        if text.startswith('//', i):
            j = text.find('\n', i)
            i = n if j < 0 else j
        elif text.startswith('(*', i):
            j = text.find('*)', i + 2)
            i = n if j < 0 else j + 2
        elif text[i] == '{':
            j = text.find('}', i)
            body = text[i + 1:j]
            i = j + 1
            if body.startswith('$'):
                out.append('\x00' + body[1:] + '\x01')
        else:
            out.append(text[i])
            i += 1
    return ''.join(out)


def filt(text):
    """evaluates ifdef/ifndef/if/else/endif for the hybrid defines"""
    out = []
    stack = []
    active = True
    for part in re.split(r'(\x00[^\x01]*\x01)', text):
        if part.startswith('\x00'):
            d = part[1:-1].strip().split(None, 1)
            k = d[0].lower()
            arg = d[1] if len(d) > 1 else ''
            if k in ('ifdef', 'ifndef', 'if'):
                if k == 'ifdef':
                    c = arg.strip().lower() in DEFINES
                elif k == 'ifndef':
                    c = arg.strip().lower() not in DEFINES
                else:
                    c = cond_eval(arg)
                stack.append((active, c))
                active = active and c
            elif k == 'else':
                p, c = stack[-1]
                active = p and not c
            elif k == 'endif':
                p, c = stack.pop()
                active = p
            # other directives (include) are ignored
        elif active:
            out.append(part)
    return ''.join(out)


def splitdecls(text):
    res = []
    cur = []
    depth = 0
    for ch in text:
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        if ch == ';' and depth == 0:
            res.append(''.join(cur))
            cur = []
        else:
            cur.append(ch)
    return res


HEAD = re.compile(r'^(function|procedure)\s+(\w+)\s*'
                  r'(?:\((.*)\))?\s*(?::\s*(\w+))?$', re.I)


def parse_inc():
    text = filt(clean(readfile(os.path.join(kernel, 'mseguiintf.inc'))))
    funcs = []
    for d in splitdecls(text):
        d = ' '.join(d.split())
        if d == '' or d.lower() in ('overload', 'export'):
            continue
        m = HEAD.match(d)
        if not m:
            print('WARNING: not understood:', d)
            continue
        kind = m.group(1).lower()
        name = m.group(2)
        params = m.group(3)
        if params is not None and not params.strip():
            params = None
        res = m.group(4)
        sparams = None
        args = []
        if params is not None:
            sparams = re.sub(r'\s*=\s*[^;]+', '', params)
            for grp in sparams.split(';'):
                names = grp.split(':')[0]
                names = re.sub(r'^\s*(const|var|out)\s+', '', names,
                               flags=re.I)
                args += [n.strip() for n in names.split(',') if n.strip()]
        funcs.append(dict(kind=kind, name=name, decl=d + ';',
                          params=params, sparams=sparams, res=res,
                          args=args))
    return funcs


def header(f, sparams=True):
    s = f['kind'] + ' ' + f['name']
    if f['sparams'] is not None:
        s += '(' + f['sparams'] + ')'
    if f['res']:
        s += ': ' + f['res']
    return s


def procvartype(f):
    s = f['kind']
    if f['sparams'] is not None:
        s += '(' + f['sparams'] + ')'
    if f['res']:
        s += ': ' + f['res']
    return s + ';'


def rel_includes(text, srcdir):
    """rewrites include file names relative to this directory"""
    def fix(m):
        name = m.group(2).strip("'\"")
        if os.path.isabs(name):
            return m.group(0)
        absname = os.path.normpath(os.path.join(srcdir, name))
        if os.path.exists(absname):
            name = os.path.relpath(absname, here).replace(os.sep, '/')
        return '{$' + m.group(1) + ' ' + name + '}'
    return re.sub(r'\{\$(include|i)\s+([^\s}]+)\s*\}', fix, text,
                  flags=re.I)


def backend(srcsub, unitname):
    src = os.path.join(kernel, srcsub, 'mseguiintf.pas')
    text = readfile(src)
    text, n = re.subn(r'^(\s*unit\s+)mseguiintf(\s*;)',
                      r'\1' + unitname + r'\2', text, count=1,
                      flags=re.I | re.M)
    if n != 1:
        sys.exit('no unit line in ' + src)
    text = rel_includes(text, os.path.dirname(src))
    # share the dispatcher's syseventty (it is a distinct 'type txevent')
    text, n = re.subn(r'^(\s*)syseventty\s*=\s*type\s+\w+\s*;',
                      r'\1syseventty = mseguiintf.syseventty;', text,
                      count=1, flags=re.I | re.M)
    if n:
        text = re.sub(r'^(uses[ \t]*\n)', r'\1 mseguiintf,\n', text,
                      count=1, flags=re.I | re.M)
    return ('{ GENERATED by genhybrid.py from ' + srcsub +
            '/mseguiintf.pas, do not edit }\n' + text)


def main():
    funcs = parse_inc()
    print(len(funcs), 'functions in the interface')

    # declarations
    decl = ['{ GENERATED by genhybrid.py, do not edit }\n']
    for f in funcs:
        decl.append(f['decl'] + '\n')
    writefile('mseguiintfhybrid_decl.inc', ''.join(decl))

    # forwarders
    impl = ['{ GENERATED by genhybrid.py, do not edit }\n\ntype\n']
    for f in funcs:
        impl.append(' tfp_%s = %s\n' % (f['name'], procvartype(f)))
    impl.append('\nvar\n')
    for f in funcs:
        impl.append(' fp_%s: tfp_%s;\n' % (f['name'], f['name']))
    impl.append('\n')
    for f in funcs:
        if f['name'] in SKIP:
            continue
        call = 'fp_%s(%s)' % (f['name'], ', '.join(f['args']))
        impl.append(header(f) + ';\nbegin\n ')
        if f['res']:
            impl.append('result:= ')
        impl.append(call + ';\nend;\n\n')
    for sel, unit in (('selectx11', 'mseguiintfx11'),
                      ('selectwayland', 'mseguiintfwl')):
        impl.append('procedure %s;\nbegin\n' % sel)
        for f in funcs:
            if f['name'] in SKIP:
                continue
            impl.append(' fp_%s:= tfp_%s(@%s.%s);\n' %
                        (f['name'], f['name'], unit, f['name']))
        impl.append('end;\n\n')
    writefile('mseguiintfhybrid_impl.inc', ''.join(impl))

    # dispatcher: interface of the X11 unit, common part from the .inc
    xsrc = os.path.join(here, 'mseguiintfx11.inc')
    xtext = readfile(xsrc)
    m = re.search(r'^\s*implementation\b', xtext, flags=re.I | re.M)
    if not m:
        sys.exit('no implementation in ' + xsrc)
    intf = xtext[:m.start()]
    intf, n = re.subn(r'\{\$(include|i)\s+[^}]*mseguiintf\.inc\s*\}',
                      '{$include mseguiintfhybrid_decl.inc}', intf,
                      flags=re.I)
    if n != 1:
        sys.exit('mseguiintf.inc include not found in interface of ' + xsrc)
    intf = rel_includes(intf, os.path.dirname(xsrc))
    # private callback of the X11 backend, not part of the dispatcher
    intf = re.sub(r'^[ \t]*function\s+CustomErrorHandler[^\n]*cdecl;[ \t]*\n',
                  '', intf, flags=re.I | re.M)
    # other routines in the interface, not covered by the .inc
    names = {f['name'].lower() for f in funcs}
    for mm in re.finditer(r'^\s*(?:function|procedure)\s+(\w+)([^\n]*)', intf,
                          flags=re.I | re.M):
        if 'cdecl' in mm.group(2).lower():
            continue                      # external X11 calls, copied as is
        if mm.group(1).lower() not in names | MANUAL:
            print('NOTE: interface of X11 unit also declares', mm.group(1),
                  '- needs a forwarder by hand')
    dispatcher = '{ GENERATED by genhybrid.py, do not edit }\n' + intf + r'''
implementation
uses
 sysutils,mseguiintfx11,mseguiintfwl;

{$include mseguiintfhybrid_impl.inc}

//X11 only state, nil/0 under Wayland
function msedisplay: pdisplay;
begin
 result:= mseguiintfx11.msedisplay;
end;

function msevisual: pvisual;
begin
 result:= mseguiintfx11.msevisual;
end;

function msedefaultscreen: pscreen;
begin
 result:= mseguiintfx11.msedefaultscreen;
end;

function msedefaultscreenno: integer;
begin
 result:= mseguiintfx11.msedefaultscreenno;
end;

var
 usingwayland: boolean;

function waylandsocketexists: boolean;
var
 d,path: string;
begin
 d:= getenvironmentvariable('WAYLAND_DISPLAY');
 if d = '' then begin
  d:= 'wayland-0';
 end;
 if d[1] = '/' then begin
  path:= d;
 end
 else begin
  path:= getenvironmentvariable('XDG_RUNTIME_DIR')+'/'+d;
 end;
 result:= fileexists(path);
end;

procedure selectbackend;
var
 mode: string;
begin
 //MSEGUIBACKEND = x11 | wayland, default: wayland if available, else x11
 mode:= lowercase(getenvironmentvariable('MSEGUIBACKEND'));
 usingwayland:= (mode = 'wayland') or
                  (mode <> 'x11') and waylandsocketexists;
 if usingwayland then begin
  selectwayland;
 end
 else begin
  selectx11;
 end;
end;

function gui_init: guierrorty;
var
 saveflush,savesoft: boolean;
begin
 if usingwayland then begin
  saveflush:= flushgdi;
  savesoft:= guisoftbackend;
  result:= mseguiintfwl.gui_init;
  if (result = gue_ok) or
        (lowercase(getenvironmentvariable('MSEGUIBACKEND')) = 'wayland') then begin
   exit;
  end;
  flushgdi:= saveflush;       //connection failed, fall back to X11
  guisoftbackend:= savesoft;
  usingwayland:= false;
  selectx11;
 end;
 result:= mseguiintfx11.gui_init;
end;

initialization
 selectbackend;
end.
'''
    writefile('mseguiintfhybrid.inc', dispatcher)


main()
