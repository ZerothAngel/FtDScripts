#!/usr/bin/env python3

import sys
import os
import configparser
import io
import subprocess


SCRIPT_DIRECTORIES = [
    'ai',
    'control',
    'incubating',
    'lib',
    'main',
    'missile',
    'utility',
]

OUTPUT_PATTERN = os.path.join('out', '{}.lua')

NL = '\n'


def scan_modules():
    result = {}
    for dir in SCRIPT_DIRECTORIES:
        files = [x for x in os.listdir(dir) if x.endswith('.lua') and
                 not (x.endswith('-header.lua') or x.endswith('-footer.lua'))]
        result.update({os.path.splitext(x)[0]: dir for x in files})
    return result


def create_chunk(fn, strip=False, strip_comments=False, strip_empty=False):
    if os.path.exists(fn):
        with io.StringIO() as out:
            with open(fn, 'r') as content:
                for line in content:
                    if strip:
                        if strip_comments:
                            trail_comment = line.rfind('--')
                            if trail_comment > -1:
                                # Only strip trailing comment if it doesn't have a directive for the checker
                                if 'luacheck' not in line[trail_comment+2:]:
                                    line = line[:trail_comment]
                                    # Fall through and whitespace strip anything else at the end
                        line = line.strip()
                        if line or not strip_empty:
                            if not strip_comments or not line.startswith('--'):
                                if not line.startswith('--!') and not line.startswith('--@') and not line.startswith('--#'):
                                    out.write(line + NL)
                    else:
                        stripped = line.strip()
                        if not stripped.startswith('--!') and not stripped.startswith('--@') and not stripped.startswith('--#'):
                            out.write(line.rstrip() + NL)
                return out.getvalue()


def generate_version_header(version, modules):
    s = """-- Generated from ZerothAngel's FtDScripts version {}""" + NL + \
        """-- Modules: {}""" + NL + NL + \
        """-- MIT licensed. See https://github.com/ZerothAngel/FtDScripts for raw code.""" + NL
    return s.format(version, ', '.join(modules))


def visit_dependencies(modules, dependencies, module):
    if module not in modules:
        for dep in dependencies[module]:
            visit_dependencies(modules, dependencies, dep)
        modules.insert(0, module)


def build_script(version, available_modules, dependencies, root, output,
                 strip=False, verbose=False):
    modules = []
    visit_dependencies(modules, dependencies, root)
    out_path = OUTPUT_PATTERN.format(output)

    if verbose:
        print("{} : {}".format(output, ', '.join(modules)))

    chunks = [generate_version_header(version, modules)]

    if strip:
        chunks.append('-- !!! Leading whitespace stripped to save bytes !!!' + NL)

    # Headers
    for module in modules:
        if module not in available_modules:
            sys.exit("""No such module '{}'""".format(module))
        header_fn = os.path.join(available_modules[module],
                                 module + '-header.lua')
        chunk = create_chunk(header_fn)
        if chunk:
            chunks.append(chunk)

    # Footers (but not really footers)
    footers = list(modules)
    footers.reverse()
    for module in footers:
        footer_fn = os.path.join(available_modules[module],
                                 module + '-footer.lua')
        chunk = create_chunk(footer_fn)
        if chunk:
            chunks.append(chunk)

    chunks.append('-- !!! CODE BEGINS HERE, EDIT AT YOUR OWN RISK !!!' + NL)

    # Finally, the main body
    modules.reverse()
    for module in modules:
        body_fn = os.path.join(available_modules[module],
                               module + '.lua')
        chunk = create_chunk(body_fn, strip=strip, strip_comments=True,
                             strip_empty=True)
        if chunk:
            chunks.append(chunk)

    dirs = os.path.dirname(out_path)
    os.makedirs(dirs, exist_ok=True)
    with open(out_path, 'wt') as out:
        out.write(NL.join(chunks))


def get_metadata(fn):
    output = None
    deps = []
    with open(fn, 'r') as content:
        for line in content:
            line = line.strip()
            # Skip blank lines
            if not line: continue
            # Stop on first non-blank non-comment
            if not line.startswith('--'): break
            if line.startswith('--!'):
                output = line[3:].strip()
            elif line.startswith('--@'):
                new_modules = line[3:].split()
                deps.extend([x.strip() for x in new_modules])
    return output, deps


def main(strip=False, verbose=False):
    # Fetch version
    if os.path.isdir('.git'):
        with subprocess.Popen('git status --porcelain', shell=True, stdout=subprocess.PIPE,
                              close_fds=True) as p:
            out, _ = p.communicate()
        dirty = len(out) > 0
        with subprocess.Popen('git rev-parse --short HEAD', shell=True, stdout=subprocess.PIPE,
                              close_fds=True) as p:
            version, err = p.communicate()
            version = version.decode(sys.getdefaultencoding()).strip()
            if dirty:
                version += '+'
    else:
        version = 'UNKNOWN'

    available_modules = scan_modules()

    roots = []
    dependencies = {}
    for module in available_modules:
        output, deps = get_metadata(os.path.join(available_modules[module],
                                                 module + '.lua'))
        if output is not None:
            roots.append((module, output))
        dependencies[module] = deps

    for module,output in roots:
        build_script(version, available_modules, dependencies, module,
                     output, strip=strip, verbose=verbose)


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Build FtD script from parts')
    parser.add_argument('-w', action='store_true',
                        help='strip leading whitespace',
                        dest='strip')
    parser.add_argument('-v', action='store_true',
                        help='be verbose',
                        dest='verbose')
    parser.add_argument('-a', action='store_true',
                        help='use crlf for eol',
                        dest='dos_eol')
    args = parser.parse_args();

    if args.dos_eol:
        NL = '\r\n'

    main(strip=args.strip, verbose=args.verbose)
