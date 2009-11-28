// ==UserScript==
// @name Flash Block
// @author Lex1
// @version 1.3.9
// @description Blocks Flash and shows images instead. Press Ctrl+Shift+F or Ctrl+Alt+F for permanent unblocking on the site.
// @ujs:documentation http://ruzanow.ru/index/0-5
// @ujs:download http://ruzanow.ru/userjs/FlashBlock.js
// @exclude http://mail.google.com/*
// @exclude http://files.mail.ru/*
// @exclude http://*megaupload.com/*
// @exclude http://*blizzard.com/*
// @exclude http://example.com/*
// ==/UserScript==

(function(){
	var flash = 'data:image/png;base64,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';
	var play = 'data:image/png;base64,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';
	var css = 'object[classid$=":D27CDB6E-AE6D-11cf-96B8-444553540000"],object[classid$=":d27cdb6e-ae6d-11cf-96b8-444553540000"],object[codebase*="swflash.cab"],object[data*=".swf"],embed[type="application/x-shockwave-flash"],embed[src*=".swf"],object[type="application/x-shockwave-flash"],object[codetype="application/x-shockwave-flash"],object[src*=".swf"],iframe[type="application/x-shockwave-flash"],iframe[src*=".swf"],';
//	css += 'object[classid$=":166B1BCA-3F9C-11CF-8075-444553540000"],object[codebase*="sw.cab"],object[data*=".dcr"],embed[type="application/x-director"],embed[src*=".dcr"],object[type="application/x-director"],object[src*=".dcr"],';
//	css += 'object[classid$=":15B782AF-55D8-11D1-B477-006097098764"],object[codebase*="awswaxf.cab"],object[data*=".aam"],embed[type="application/x-authorware-map"],embed[src*=".aam"],object[type="application/x-authorware-map"],object[src*=".aam"],';
	css += 'object[classid*="32C73088-76AE-40F7-AC40-81F62CB2C1DA"],object[type="application/ag-plugin"],object[type="application/x-silverlight"],object[type="application/x-silverlight-2"],object[source*=".xaml"],object[sourceelement*="xaml"],embed[type="application/ag-plugin"],embed[source*=".xaml"]';
	css += '{content: ""; display: inline-block; outline: 1px solid #bbbbbb; min-width: 33px; min-height: 33px; cursor: pointer; background: url("'+flash+'") no-repeat center;}';
	css += 'object[classid$=":D27CDB6E-AE6D-11cf-96B8-444553540000"]:hover,object[classid$=":d27cdb6e-ae6d-11cf-96b8-444553540000"]:hover,object[codebase*="swflash.cab"]:hover,object[data*=".swf"]:hover,embed[type="application/x-shockwave-flash"]:hover,embed[src*=".swf"]:hover,object[type="application/x-shockwave-flash"]:hover,object[codetype="application/x-shockwave-flash"]:hover,object[src*=".swf"]:hover,iframe[type="application/x-shockwave-flash"]:hover,iframe[src*=".swf"]:hover,';
//	css += 'object[classid$=":166B1BCA-3F9C-11CF-8075-444553540000"]:hover,object[codebase*="sw.cab"]:hover,object[data*=".dcr"]:hover,embed[type="application/x-director"]:hover,embed[src*=".dcr"]:hover,object[type="application/x-director"]:hover,object[src*=".dcr"]:hover,';
//	css += 'object[classid$=":15B782AF-55D8-11D1-B477-006097098764"]:hover,object[codebase*="awswaxf.cab"]:hover,object[data*=".aam"]:hover,embed[type="application/x-authorware-map"]:hover,embed[src*=".aam"]:hover,object[type="application/x-authorware-map"]:hover,object[src*=".aam"]:hover,';
	css += 'object[classid*="32C73088-76AE-40F7-AC40-81F62CB2C1DA"]:hover,object[type="application/ag-plugin"]:hover,object[type="application/x-silverlight"]:hover,object[type="application/x-silverlight-2"]:hover,object[source*=".xaml"]:hover,object[sourceelement*="xaml"]:hover,embed[type="application/ag-plugin"]:hover,embed[source*=".xaml"]:hover';
	css += '{background-image: url("'+play+'");}';
	var prefix = 'ujs_flashblock';

	var addStyle = function(css){
		var s = document.createElement('style');
		s.setAttribute('type', 'text/css');
		s.setAttribute('style', 'display: none !important;');
		s.appendChild(document.createTextNode(css));
		return (document.getElementsByTagName('head')[0] || document.documentElement).appendChild(s);
	};

	var setValue = function(name, value, days){
		var date = new Date();
		date.setTime(date.getTime()+((days || 10*365)*24*60*60*1000));
		var curCookie = name+'='+escape(value)+'; expires='+date.toGMTString()+'; path=/';
		if(document.cookie.split(';').length < 20 && document.cookie.length+curCookie.length < 4000){document.cookie = curCookie}else{alert('Cookies is full!')};
	};

	var isValue = function(){
		return document.cookie.indexOf(prefix+'=unblocked') == -1;
	};

	var getVideo = function(flashvars, src){
		var getLink = function(s){var rez = s.match(/[^\s\x22=&?]+\.[^\s\x22=&?\/]*(flv|mp4)/i); return rez ? rez[0] : ''};
		var getQuery = function(s, q){var rez = s.match(new RegExp('[&?]'+q+'=([^&]+)')); return rez ? rez[1] : ''};
		var getURL = function(f, s){return f.match(/^(\w+:\/\/|\/|$)/) ? f : s.replace(/[#?].*$/, '').replace(/[^\/]*$/, f)};

		var flv = decodeURIComponent(flashvars);
		var q = '', url = location.href;

		if( url.indexOf('youtube.com/watch?') != -1 && (q = getQuery(flv, 'video_id')) )return 'http://www.youtube.com/get_video?video_id='+q+'&t='+getQuery(flv, 't')+'&fmt=18';
		if( url.indexOf('video.google.com/videoplay?') != -1 && (q = getQuery(src, 'videoUrl')) )return decodeURIComponent(q);
		if( url.indexOf('metacafe.com/watch/') != -1 && (q = getQuery(flv, 'mediaURL')) )return q+'?__gda__='+getQuery(flv, 'gdaKey');
		if( url.indexOf('dailymotion.com/') != -1 && (q = getQuery(flv, 'video')) )return q.match(/[^@]+/);

		return getURL(getLink(flv) || decodeURIComponent(getLink(src)), src);
	};

	var getParam = function(e, n){
		var v = '', r = new RegExp('^('+n+')$', 'i');
		var param = e.getElementsByTagName('param');
		for(var i = 0, p; p = param[i]; i++){
			if(p.hasAttribute('name') && p.getAttribute('name').match(r)){v = p.getAttribute('value'); break};
		};
		return v;
	};

	var qualifyURL=function(url){
		if(!url)return '';
		var a = document.createElement('a');
		a.href = url;
		return a.href;
	};

	var unblock = function(s){
		s.content = 'normal';
		s.outline = 'none';
		s.backgroundImage = 'none';
		s.minWidth = 0;
		s.minHeight = 0;
	};

	var isBlocked = function(ele){
		var tag = (ele && ele.tagName) ? ele.tagName.toLowerCase() : '';
		return (tag == 'embed' || tag == 'object' || tag == 'iframe') && (ele.currentStyle.content || getComputedStyle(ele, null).content) == '""';
	};

	var unblockFlash = function(e){
		var et = e.target;
		if(isBlocked(et) && !e.shiftKey && !e.altKey){
			e.preventDefault();
			if(e.ctrlKey){
				// Save video with Ctrl+Click
				var v = getVideo(et.getAttribute('flashvars') || getParam(et, 'flashvars'), et.getAttribute('title'));
				if(v)location.href = v;
			}
			else{
				// Unblock flash
				unblock(et.style);
				var em = et.getElementsByTagName('embed')[0];
				if(isBlocked(em))unblock(em.style);
			}
		}
	};

	var showAddress = function(e){
		var et = e.target;
		if(!et.title && isBlocked(et)){
			var src = et.getAttribute('src') || et.getAttribute('source') || et.getAttribute('data') || getParam(et, 'movie|data|src|code|filename|url|source');
			if(src)et.setAttribute('title', qualifyURL(src));
		}
	};

	var loadImages = function(){
		var embed = document.getElementsByTagName('embed');
		var obj = document.getElementsByTagName('object');
		var isShowImagesMode = function(){
			var imgs = document.images;
			var l = imgs && imgs.length;
			return l && imgs[0].complete && imgs[l-1].complete;
		};
		if((embed.length == 0 && obj.length == 0) || isShowImagesMode())return;

		var reloadImage = function(s){
			var f = document.createElement('iframe');
			f.src = s;
			f.width = 0;
			f.height = 0;
			f.frameBorder = 'no';
			f.scrolling = 'no';
			f.onload = function(){
				this.parentNode.removeChild(this);
			};
			document.documentElement.appendChild(f);
		};

		reloadImage(flash);
		reloadImage(play);
	};

	// Blocking
	if(isValue()){
		addStyle(css);
		document.addEventListener('click', unblockFlash, true);
		document.addEventListener('mouseover', showAddress, false);
		document.addEventListener('load', loadImages, false);
	};

	// Unblock for the site with Ctrl+Shift+F or Ctrl+Alt+F
	document.addEventListener('keypress', function(e){
		if(e.keyCode == 70 && e.ctrlKey && (e.shiftKey != e.altKey)){
			if(isValue()){
				var styles = document.getElementsByTagName('style');
				for(var i = 0, s; s = styles[i]; i++){
					if(s.innerHTML == css){s.parentNode.removeChild(s); break}
				};
				document.removeEventListener('click', unblockFlash, true);
				document.removeEventListener('mouseover', showAddress, false);
				setValue(prefix, 'unblocked');
			}
			else{
				addStyle(css);
				document.addEventListener('click', unblockFlash, true);
				document.addEventListener('mouseover', showAddress, false);
				setValue(prefix, 'blocked', -1);
			}
		}
	}, false);
})();
