#!/usr/bin/env bash

cd $HOME
rsync --archive --update --verbose \
    --exclude "*cache*" --exclude "vps" --exclude temporary_downloads \
    --exclude thumbnails --exclude images --exclude icons \
    .opera/ opera-$(date +%F)