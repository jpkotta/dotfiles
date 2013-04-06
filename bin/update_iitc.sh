#!/usr/bin/env bash

dest=~/.opera/userjs

urls=(
    "http://iitc.jonatkins.com/release/total-conversion-build.user.js"
    "http://iitc.jonatkins.com/release/plugins/ap-list.user.js"
    "http://iitc.jonatkins.com/release/plugins/compute-ap-stats.user.js"
    "http://iitc.jonatkins.com/release/plugins/draw-tools.user.js"
    "http://iitc.jonatkins.com/release/plugins/guess-player-levels.user.js"
    "http://iitc.jonatkins.com/release/plugins/ipas-link.user.js"
    "http://iitc.jonatkins.com/release/plugins/keys-on-map.user.js"
    "http://iitc.jonatkins.com/release/plugins/keys.user.js"
    "http://iitc.jonatkins.com/release/plugins/max-links.user.js"
    "http://iitc.jonatkins.com/release/plugins/pan-control.user.js"
    "http://iitc.jonatkins.com/release/plugins/player-tracker.user.js"
    "http://iitc.jonatkins.com/release/plugins/portal-counts.user.js"
    "http://iitc.jonatkins.com/release/plugins/portals-list.user.js"
    "http://iitc.jonatkins.com/release/plugins/privacy-view.user.js"
    "http://iitc.jonatkins.com/release/plugins/render-limit-increase.user.js"
    "http://iitc.jonatkins.com/release/plugins/reso-energy-pct-in-portal-detail.user.js"
    "http://iitc.jonatkins.com/release/plugins/resonator-display-zoom-level-decrease.user.js"
    "http://iitc.jonatkins.com/release/plugins/scale-bar.user.js"
    "http://iitc.jonatkins.com/release/plugins/scoreboard.user.js"
    "http://iitc.jonatkins.com/release/plugins/show-address.user.js"
    "http://iitc.jonatkins.com/release/plugins/show-linked-portals.user.js"
    "http://iitc.jonatkins.com/release/plugins/show-portal-weakness.user.js"
    "http://iitc.jonatkins.com/release/plugins/zoom-slider.user.js"
)

mkdir -p $dest
cd $dest

for url in ${urls[@]} ; do
    curl -O "$url"
done
