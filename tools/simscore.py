#! /usr/bin/env python3

import gzip
import sys

def snarf_file(filename):
    "Get a file content or empty string if nothing there."
    try:
        with open(filename, 'r', encoding='utf-8') as fdin:
            return fdin.read()
    except:
        return('')

def z(s):
    return len(gzip.compress(bytes(s, 'utf-8')))

def simscore(t1, t2):
    if len(t1) == 0 or len(t2) == 0:
        return 1
    base = z(t1) + z(t2)
    minsize = min(z(' '.join([t1, t2])),
                  z(' '.join([t2, t1])),
                  base)
    return round(minsize/base, 3)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("usage: %s [file1] [file2]" % sys.argv[0])
        sys.exit(1)
    t1 = snarf_file(sys.argv[1])
    t2 = snarf_file(sys.argv[2])
    print(simscore(t1, t2))
