// ==UserScript==
// @name Autosizer
// @author Arve Bersvendsen 
// @namespace http://virtuelvis.com/ 
// @version 1.0.2
// @description  Enhance image viewing in Opera by adding five
//			different sizing modes to images: "Original",
//			"Shrink to Fit", "Maximize", "Fit to Width" and
//			"Fit to Height".
// @ujs:category browser: enhancements
// @ujs:published 2005-10-22 20:25
// @ujs:modified 2005-10-22 19:53
// @ujs:documentation http://userjs.org/scripts/browser/enhancements/autosizer 
// @ujs:download http://userjs.org/scripts/download/browser/enhancements/autosizer.js
// ==/UserScript==

/* 
 * Copyright © 2005 by Arve Bersvendsen
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 * USA
 */


if ((window.location.href.match(/^.*\.(jpe?g|bmp|gif|png)$/i)) && (document.images.length==1)
  || (window.location.href.match(/^http:\/\/i.imdb.com\/Photos\/.*$/i))) {
  // if the document has more than one child node, it's not an image.
  window.addEventListener("load", function(ev){
    if (document.body.childNodes.length != 1) return; // Not an image
    var ss = document.createElement("style");
    ss.setAttribute("type","text/css");
    ss.innerText = "* { box-sizing: border-box }";
	document.body.appendChild(ss);    
    var d_im = document.createElement("img");
    d_im.src = document.images[0].src;
    var imd = document.createElement("div");
    imd.id="imgDiv";
    imd.style="width:100%;height:100%;position:absolute;max-height:100%";
    imd.appendChild(d_im);

    document.body.replaceChild(imd,document.body.firstChild);

    // begin:user settings
      
    // default mode between 0-4, corresponding to the five items in itemNames
    var default_mode = 1; // Default, 1=Shrink to Fit

    // indicator mode between 0-2
    // 0 = always on
    // 1 = on after mode_switch / page load
    // 2 = always off
    var default_indicator = 1;

    // when indicator mode=1, this setting controls indicator delay in ms
    this.indicator_delay = 750;

    // indicator colors and backgrounds. Uses CSS syntax
    var indicator_color= "#333";
    var indicator_hover_color = "red";
    var indicator_background = "#eee";
    var selector_background = "#f5f5f5";
    var selector_selected_background = "#fff";

    // Allow script to store settings in a cookie: true/false
    var cookie_allowed = true;

    // end:User settings

    // Default cookie lifetime = 24 hours
    var now = new Date();
    var cookieLifetime  = new Date(now.getTime() + 1000 * 60 * 60 * 24);


    var itemNames = ["Original", "Shrink to Fit", "Maximize", "Fit to Width", "Fit to Height"];
    var fit_modes = [
      "cursor:crosshair;display:block; margin:auto auto", // no fit
      "display:block;max-width:100%;max-height:100%;margin:0 auto;padding:0;cursor:crosshair", //fit to window
      "display:block;width:100%;height:auto;margin:0 auto;padding:0;cursor:crosshair", //fit to width
      "display:block;width:auto;height:100%;margin:0 auto;padding:0;cursor:crosshair;" //fit to height
    ]

    default_mode--;

    this.swapDirection = function(){
      self.sizing_mode -= 2;
      if (self.sizing_mode < 0) {
        self.sizing_mode = itemNames.length+self.sizing_mode;
      } 
    }

    this.lastHeight=document.documentElement.offsetHeight;
    this.workerThread = function(){
      if (self.lastHeight != document.documentElement.offsetHeight) {
        self.reCenter();
      }
      self.lastHeight = document.documentElement.offsetHeight
    }

    this.selector_active=false;
    this.showMenu = function(){
      document.getElementById("mode_selector").style.display="block";
      document.getElementById("mode_indicator").style.display="block";
      document.getElementById("mode_indicator").innerHTML="Select";
      self.selector_active=true;
      return;
    }

    this.hideMenu = function(){
      self.selector_active=false;
      document.getElementById("mode_selector").style.display="none";
      document.getElementById("mode_indicator").innerHTML=itemNames[self.sizing_mode];
      if (self.indicator_mode == 1) {
        self.showIndicator();
        setTimeout(self.hideIndicator,self.indicator_delay);
      }
      return;
    }

    this.showIndicator = function(){
      document.getElementById('infopanel').style.display="block";
      document.getElementById("mode_indicator").style.visibility="visible";
      return;
    }

    this.hideIndicator = function(){
      if (!self.selector_active) {
        document.getElementById("mode_indicator").style.visibility="hidden";
      } else {
        setTimeout(self.hideIndicator,self.indicator_delay);
      }
      return;
    }

    this.changeIndicatorMode = function(){
      if (self.indicator_mode++ == 2) {
        self.indicator_mode = 0;
      } 
      self.setCookie('indicatorMode',self.indicator_mode,cookieLifetime ,'/');
      switch (self.indicator_mode) {
        case 0:
          self.showIndicator();
          break;
        case 1:
          self.showIndicator();
          setTimeout(self.hideIndicator,self.indicator_delay);
          break;
        case 2:
          document.getElementsByTagName('infopanel').display="none";
          self.hideIndicator();
          break;
        default:
          break;
      }
    }

    this.setCookie = function(name, value, expires, path, domain, secure){
      // Don't try to set cookie if cookies are disallowed.
      if (!cookie_allowed) return;

      document.cookie = escape(name) + '=' + escape(value)
      + (expires ? '; EXPIRES=' + expires.toGMTString() : '')
      + (path ? '; PATH=' + path : '')
      + (domain ? '; DOMAIN=' + domain : '')
      + (secure ? '; SECURE' : '');
    }

    this.getCookie = function (name){
      var dc = document.cookie;
      var prefix = name + "=";
      var begin = dc.indexOf("; " + prefix);
      if (begin == -1){
        begin = dc.indexOf(prefix);
        if (begin != 0) return null;
      } else {
        begin += 2;
      }
      var end = document.cookie.indexOf(";", begin);
      if (end == -1){
        end = dc.length;
      }
      return unescape(dc.substring(begin + prefix.length, end));
    }   

    // set sizing. 0 <= val <= 4
    this.setSizingMode = function(val){
      var info = document.getElementById("mode_indicator");
      var img = document.images[0];
      info.innerHTML = itemNames[val];
      if (val != 2 ) {
        if (val < 2 ) {
          img.style = fit_modes[val];
          self.reCenter();
        } else {
          img.style = fit_modes[val-1];
          self.reCenter();
        }
      } else {
        while (img.height==0) self.reCenter();
        if ((img.offsetWidth >= window.width) && (img.offsetHeight >= window.innerHeight)) {
          img.style = fit_modes[1];
        } else if ((img.width/img.height) < (window.innerWidth/window.innerHeight)){
          img.style = fit_modes[3];
        } else {
          img.style = fit_modes[2];
        }
        self.reCenter();
      } 
      
      for (var i = itemNames.length-1; i > -1; i--) {
        document.getElementById("mode_selector").childNodes[i].style.background="transparent";
      }
      document.getElementById("mode_selector").childNodes[val].style.background=selector_selected_background;
      self.setCookie('sizingMode',self.sizing_mode,cookieLifetime ,'/');
      if (self.indicator_mode == 1) {
        self.showIndicator();
        setTimeout(self.hideIndicator,self.indicator_delay);
      }
      return;
    }

    this.reCenter = function(){
      // If documentElement.offsetHeight != window.innerHeight we are zoomed
      document.getElementById("imgDiv").style.paddingTop=0;
      if (document.documentElement.offsetHeight > document.images[0].offsetHeight) 
        document.getElementById("imgDiv").style.paddingTop = ((document.documentElement.offsetHeight -document.images[0].offsetHeight)/2);
	      document.body.className = document.body.className;
      return;
    }

    this.changeSizingMode = function(){
      if (++self.sizing_mode > 4) self.sizing_mode = 0;
      self.setCookie('sizingMode',self.sizing_mode,cookieLifetime ,'/');
      self.setSizingMode(self.sizing_mode);
      return;
    }

    document.documentElement.style="text-align:center;vertical-align:middle;display:block;padding: 0;margin: 0 auto;height:100%;width:100%;position:relative;min-height:100%;";
    document.body.style="margin:auto;padding:0;height:100%;width:100%;position:relative;";

    var inf = document.createElement("div");
    inf.id="infopanel";
    inf.style="float:right;line-height:1;width:7.1em;display:block;color:"+indicator_color+";margin:0;padding:0;height: 11.5em; position:fixed;right:0;top:0;font-family:Arial,sans-serif;font-size:11px;";
    var p = document.createElement("h2");
    p.style="float:right;padding:0.25em 0.5em;background:"+indicator_background+";font-weight:bold;font-size:1em;margin:0;text-align:right;width: 100%;";
    p.id="mode_indicator";    
    var selector = document.createElement("ul");
    selector.style="display:none;background:"+selector_background+";margin:0;padding:0.1em;";
    selector.id="mode_selector";
    
    for (var i = itemNames.length-1; i >-1;i--) {
      var item = document.createElement("li");
      item.appendChild(document.createTextNode(itemNames[itemNames.length-i-1]));
      item.style="display:block;margin:0;padding:0.5em;text-indent:none;text-align:left";
      
      item.addEventListener("mouseover",function(ev){
        event.target.style.color = indicator_hover_color;
      },false);
      
      item.addEventListener("mouseout",function(ev){
        event.target.style.color = indicator_color;
      },false);

      item.addEventListener("click",function(ev){
          self.sizing_mode = ev.target.sourceIndex-ev.target.parentElement.sourceIndex-1;
          self.setCookie('sizingMode',self.sizing_mode,cookieLifetime ,'/');
          self.setSizingMode(self.sizing_mode);
          document.getElementById("mode_indicator").innerHTML="Select";
      },false);
      selector.appendChild(item);
    }

    this.sizing_mode = parseInt(this.getCookie('sizingMode'));
    if((isNaN(this.sizing_mode)) || (this.sizing_mode == null)) this.sizing_mode=default_mode;
    
    this.indicator_mode = parseInt(this.getCookie('indicatorMode'));
    if((isNaN(this.indicator_mode)) || (this.indicator_mode == null)) this.indicator_mode=default_indicator;
    
    var self=this;

    if (self.indicator_mode == 2) {
      inf.style.display="none";
    }

    inf.appendChild(p);
    inf.appendChild(selector);  
    
    document.body.appendChild(inf);    
    this.setSizingMode(self.sizing_mode);
    document.images[0].addEventListener("click",function(e){
      if (e.shiftKey) {
        self.swapDirection();
      }
      self.changeSizingMode();
    },false);


    inf.addEventListener("mouseover",function(e){
      self.showMenu();
    },false);

    inf.addEventListener("mouseout",function(e){
      self.hideMenu();
    },false);

    document.addEventListener("resize",function(){
      self.setSizingMode(self.sizing_mode);
    },false);

    document.onkeypress=function(e){
      switch (e.keyCode) {
        // 'b' or 'B': change indicator mode: Always, sometimes, never
        case 66:
        case 98:
          self.changeIndicatorMode();
          break;
        // 'm' or 'M': next sizing mode
        case 77:
        case 109:
          self.changeSizingMode();
          break;
        // 'n' or 'N': previous sizing mode
        case 78:
        case 110:
          self.swapDirection();
          self.changeSizingMode();
          break;
        case 42:
        case 43:
        case 45:
        case 48:
        case 54:
        case 57:
          setTimeout(self.reCenter,1);
          break;
        default:
          break;
      }

    }
    self.lastHeight = document.documentElement.offsetHeight
    var f = setInterval(self.workerThread,50);
  }, false); 
}