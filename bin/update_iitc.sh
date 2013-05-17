#!/usr/bin/env bash

dest=~/.opera/userjs

base_url="http://iitc.jonatkins.com/release"
base_plugin_url="$base_url/plugins"

urls=(
    "$base_url/total-conversion-build.user.js"
    
    "$base_plugin_url/ap-list.user.js"
    "$base_plugin_url/compute-ap-stats.user.js"
    "$base_plugin_url/draw-tools.user.js"
    #"$base_plugin_url/force-https.user.js"
    "$base_plugin_url/guess-player-levels.user.js"
    "$base_plugin_url/ipas-link.user.js"
    "$base_plugin_url/keys-on-map.user.js"
    "$base_plugin_url/keys.user.js"
    "$base_plugin_url/max-links.user.js"
    #"$base_plugin_url/pan-control.user.js"
    "$base_plugin_url/player-tracker.user.js"
    "$base_plugin_url/portal-counts.user.js"
    "$base_plugin_url/portal-level-numbers.user.js"
    "$base_plugin_url/portals-list.user.js"
    "$base_plugin_url/privacy-view.user.js"
    "$base_plugin_url/render-limit-increase.user.js"
    "$base_plugin_url/reso-energy-pct-in-portal-detail.user.js"
    "$base_plugin_url/resonator-display-zoom-level-decrease.user.js"
    "$base_plugin_url/scale-bar.user.js"
    "$base_plugin_url/scoreboard.user.js"
    "$base_plugin_url/show-address.user.js"
    "$base_plugin_url/show-linked-portals.user.js"
    "$base_plugin_url/show-portal-weakness.user.js"
    #"$base_plugin_url/zoom-slider.user.js"
)

mkdir -p $dest
cd $dest

for url in ${urls[@]} ; do
    curl -O "$url"
done
