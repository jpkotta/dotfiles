/**
 * UserJS to alter Opera's image resizing behavior
 **/

/*
Copyright (c) 2008, Arve Bersvendsen 

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.


* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

* Neither the name of Arve Bersvendsen nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

if (window.location.href.match(/^http:\/\/0.0.0.0\/img/i))
{
  (function(){

    var now = new Date();
    var cookieLifetime  = new Date(now.getTime() + 60*60*24*1000*10);

    var self = this;

    var postCookie = function()
    {
      if (window.parent){
        if (window.postMessage)
        {
          window.parent.postMessage(getCookie('img_size'));
        }
        else
        {
          window.parent.document.postMessage(getCookie('img_size'))
        }
      }

    }

   var setCookie = function(name, value, expires, path, domain, secure){
      document.cookie = escape(name) + '=' + escape(value)
      + (expires ? '; EXPIRES=' + expires.toGMTString() : '')
      + (path ? '; PATH=' + path : '')
      + (domain ? '; DOMAIN=' + domain : '')
      + (secure ? '; SECURE' : '');
    }

    var getCookie = function (name){
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

    var cookieListener = function(ev)
    {
      if (ev.data == "true")
      {
        setCookie("img_size","true",cookieLifetime,"/")
      }
      else if (ev.data == "false")
      {
        setCookie("img_size","false",cookieLifetime,"/");
      }
      else if (ev.data == "getpref")
      {
        postCookie();
      }
    }
   document.addEventListener('message', cookieListener , false);
   setInterval(postCookie,300);
  })()
}


if ((window.location.href.match(/^.*\.(jpe?g|bmp|gif|png)$/i)) && (document.images.length==1)
  || (window.location.href.match(/^http:\/\/i.imdb.com\/Photos\/.*$/i))) {
  window.addEventListener("DOMContentLoaded", function(ev)
  {
    if (document.body.childNodes.length != 1) return; // Not an image


    var iframe = document.createElement('iframe');
    iframe.src="http://0.0.0.0/img";
    iframe.style="visibility:hidden;position:absolute;width:0;height:0;"

    var postMsg = function(value)
    {
      if (window.postMessage)
      {
        iframe.contentWindow.postMessage(value);
      }
      else
      {
        iframe.document.postMessage(value);
      }
    };
    var getPreference = function()
    {
      postMsg("getpref");
    }
    iframe.onload = getPreference;


    // if the document has more than one child node, it's not an image.
    var img = document.getElementsByTagName('img')[0];
    var should_resize = false;

    var cookieListener = function(ev)
    {
      if (ev.data == "true")
      {
        should_resize = true;
      }
      else
      {
        should_resize = false;
      }
      measureZoom();
      setSize();
    }

    // set up x-domain listener
    document.addEventListener('message', cookieListener, false);


    document.documentElement.appendChild(iframe);

    var zoom_ele = document.createElement('div');
    document.documentElement.appendChild(zoom_ele);

    var width = 0;
    var height = 0;
    var old_zoom = 1;

    var setPreference = function(value)
    {
      postMsg(value);
      should_resize = value;
    }

    var setSize = function()
    {
      if (should_resize)
      {
        img.style="max-width:"+width+"px;max-height:"+(height-4)+"px";
      }
      else
      {
        img.style = "";
      }
    }

    var toggleMode = function()
    {
      setPreference(!should_resize)
      setSize();
    }

    var measureZoom = function()
    {
      zoom_ele.style="display:block;position:fixed;left:-65536px;top:0;height:100%;z-index:-32";
      var zoom = window.innerHeight/zoom_ele.offsetHeight;
      width = Math.floor(window.innerWidth/zoom);
      height = Math.floor(window.innerHeight/zoom);
      if (old_zoom != zoom) setSize();
    }

    window.addEventListener('click', toggleMode, false);
    window.addEventListener('resize', setSize, false);
    setInterval(measureZoom,60);
  },false);
}
