#!/usr/bin/env python

from optparse import OptionParser
from sys import *
import re

def main():
    usage = "usage: %prog [options] key"
    parser = OptionParser(usage)
    parser.add_option("-f", "--file", dest="in_filename", default="stdin",
                      help="Get input from FILE", metavar="FILE")
    parser.add_option("-d", "--decrypt", action="store_false", dest="encrypt_mode", default=True,
                      help="Decrypt input (default is encrypt)")

    (options, args) = parser.parse_args()
    if len(args) != 1:
        parser.error("You must supply a key")

    key = args[0];

    cipher = vigenere_cipher(key)

    if options.in_filename != "stdin":
        in_file = open(options.in_filename, 'r')
    else:
        in_file = stdin
        
    for line in in_file:
        line = lower_alpha(line)
        
        if options.encrypt_mode:
            line = cipher.encrypt_str(line)
        else:
            line = cipher.decrypt_str(line)
            
        print line
        

def lower_alpha(s):
    only_alpha = re.compile(r'[^a-zA-Z]')
    s = only_alpha.sub(r'', s)
    return s.lower()


def alpha2num(s):
    l = []
    for c in s:
        l += [ord(c)-ord('a')]
    return l


def num2alpha(l):
    s = ""
    for i in l:
        s += chr(i + ord('a'))
    return s


class keystream:
    def __init__(self, key):
        self.keylist = alpha2num(lower_alpha(key))
        self.idx = 0

    def get_next(self):
        out = self.keylist[self.idx]
        self.idx += 1
        self.idx %= len(self.keylist)
        return out


class vigenere_cipher:
    def __init__(self, key):
        self.ks = keystream(key)

    def mix_str(self, in_str, multiplier):
        in_lst = alpha2num(in_str)
        out_lst = range(len(in_lst))
        for i in range(len(in_lst)):
            out_lst[i] = (in_lst[i] + multiplier*self.ks.get_next()) % 26
        return num2alpha(out_lst)

    def encrypt_str(self, in_str):
        return self.mix_str(in_str, +1)

    def decrypt_str(self, in_str):
        return self.mix_str(in_str, -1)


if __name__ == "__main__":
    main()
