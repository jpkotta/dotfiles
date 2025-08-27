#!/usr/bin/env bash

#set -o xtrace
set -o errexit -o nounset -o pipefail -o errtrace
IFS=$'\n\t'

(
    cd /tmp
    for i in pikaur ; do
        curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/$i.tar.gz
        tar xf $i.tar.gz
        (cd $i ; makepkg -sif)
    done
)

(
    cd /var/cache/pacman
    if [ ! -d aur ] ; then
        sudo mkdir -p aur
        sudo chgrp wheel aur
        sudo chmod g+rwx aur
    fi
)
