#!/usr/bin/env python3

import sys
import os

def print_help():
    print("Usage: %s <directory>\n\n" % sys.argv[0])
    print("Searches the entire directory tree below <directory> for files named\n"
          "'.gitignore', then converts the data in these files to a .hgignore\n"
          "file in <directory>.")
    exit(1)    

try:
    if sys.argv[1] in ["-h", "--help", "-H"]:
        print_help()
    else:
        topdir = sys.argv[1]
except IndexError:
    topdir = os.getcwd()

out = sys.stdout

out.write("# Mercurial ignore list, autogenerated from .gitignore files.\n")
out.write("syntax: glob\n\n")
# out.write(".gitignore\n")
# out.write(".hgignore\n\n")

prune_dirs = {".hg"}

for dirpath,dirnames,filenames in os.walk(topdir):
    # prune .hg and .git dirs
    if ".git" in dirnames:
        dirnames.remove(".git")
        if dirpath != topdir:
            continue

    if prune_dirs.intersection(dirnames):
        for d in prune_dirs:
            try:
                dirnames.remove(d)
            except ValueError:
                pass

    if ".gitignore" in filenames:
        reldirpath = os.path.relpath(dirpath, start=topdir)
        out.write("#"*72 + "\n# %s\n\n"
                  % os.path.join(reldirpath, ".gitignore"))

        with open(os.path.join(dirpath, ".gitignore"), "r") as f:
            for line in f.readlines():
                line = line.strip()

                # whitespace
                if line == "":
                    pass # no-op
                # comment
                elif line.startswith("#"):
                    pass # no-op
                # rooted
                elif line.startswith("/"):
                    line = "glob:" + os.path.join(reldirpath, line[1:])
                # other
                else:
                    # not sure if changing * to ** is correct, but
                    # with out it git ignores more files than
                    # mercurial
                    line = os.path.join(reldirpath, line.replace("*", "**"))
                    
                out.write(line + "\n")

            out.write("\n")
        
out.close()        
