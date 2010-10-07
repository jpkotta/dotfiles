# fixcase.py - pull and merge remote changes
#
# Copyright 2008 Andrei Vermel <andrei.vermel@gmail.com>
#
# This software may be used and distributed according to the terms
# of the GNU General Public License, incorporated herein by reference.

from mercurial.i18n import _
from mercurial.node import *
from mercurial import commands, cmdutil, hg, node, util
import os

def fixcase(ui, repo, *pats, **opts):
    '''Revert case changes in filenames'''

    all = None
    node1, node2 = cmdutil.revpair(repo, None)

    unknown = repo.status(node1, node2, cmdutil.match(repo, pats, opts),
                       None, None, True)[4]
                             
    file_map={} 
    for cp in repo[None].parents():
      node=cp.node()                        
      m = repo.changectx(node).manifest()
      files = m.keys()
      for file in files:
      	file_map[file.lower()]=file
      	
    for file in unknown:
      file_lower=file.lower()
      if file_lower in file_map:
      	ui.status(_('Reverted %s to %s\n') % (file, 
      	  file_map[file_lower]))
      	os.rename(repo.wjoin(file), repo.wjoin(file_map[file_lower]))     	

cmdtable = {
    'fixcase':
        (fixcase,
         commands.walkopts,
        _('hg fixcase [SOURCE]')),
}
