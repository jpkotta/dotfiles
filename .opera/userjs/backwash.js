// ==UserScript==
// @name Backwash, Opera edition
// @author Anonymous
// @version 1.2b
// @description  Displays posts in their own hovering window when moving the mouse over quotes. Originally by tkirby, aeosynth, VIPPER for Firefox.
// @ujs:documentation http://sector-5.net/archives/4chan-backwash-for-opera/
// @ujs:download http://files.sector-5.net/4chan-backwash.js
// ==/UserScript==


if (window.location.href.search('^http://[^\.]+\.4chan.org/[^\.]') != -1) {
	
	// Pack everything into an anonymous function block to avoid functions and 
	// variables from leaking out.
	(function() {
		
	const VIEW_X_OFFSET = 45, VIEW_Y_OFFSET = 120;

	/// Adds event listeners to all quotes for mouseover and mouseout
	function addListenerToQuotes(root) {
		if (root.getElementsByClassName) {
			// Find all quotes
			var quotes = root.getElementsByClassName('quotelink');

			for (var i = 0; i < quotes.length; ++i) {
				quotes[i].onmouseover = showQuote;
				quotes[i].onmouseout = hideQuote;
			}
		}
	}

	/// Creates the viewport for displaying quoted posts
	/// and adds it to the document.
	function setupViewport() {
		var container = document.createElement('div');
		container.id = 'backwash-viewport';
		container.style.position = 'absolute';
		container.style.border = '1px solid black'
		container.style.display = 'none';
		container.style.backgroundColor = 'white';

		var table = document.createElement('table');
		container.appendChild(table)

		var row = document.createElement('tr');
		table.appendChild(row);

		document.body.appendChild(container);
	}

	/// Shows the quote viewport
	function showQuote(event) {
		var quotedId = event.currentTarget.textContent;
		if (quotedId.search(/^>>\d/) != -1) {
			var quotedPost = document.getElementById(quotedId.substring(2));
			if (quotedPost != null) {
				var viewport = document.getElementById('backwash-viewport');

				var row = viewport.firstChild.firstChild;

				// Add new content
				row.appendChild(quotedPost.cloneNode(true));
				row.firstChild.id = '';

				// Calculate viewport position
				moveViewport(event, viewport);
				viewport.style.display = 'block';
			}
			else {
				// The quoted ID was not found, check if the opening post matches the ID
				// First, find the appropriate parent element. This should be <table> for replies.
				var container = event.currentTarget.parentNode;
				while (container != null) {
					if (container.tagName == 'TABLE') break;
					else container = container.parentNode;
				}
				
				// Quoted link was indeed inside a reply; now find out the thread id
				if (container != null) {
					var threadId = null;
					var sibling = container.previousSibling;
					while (sibling != null && sibling.tagName != 'HR') {
						if (sibling.tagName == 'SPAN' && sibling.hasAttribute('id') && sibling.getAttribute('id').indexOf('nothread') == 0) {
							threadId = sibling.getAttribute('id').substring(8);
							break;
						}
						else
							sibling = sibling.previousSibling;
					}
					
					if (quotedId.substring(2) == threadId) {
						// Create our own post replica
						var tableCell = document.createElement('tr');
						tableCell.setAttribute('class', 'reply');
						// sibling will now be the <span id="nothread..."> tag, append all previous siblings up until <hr>
						var previousNode = sibling;
						while (previousNode != null) {
							if (previousNode.tagName == 'HR') break;
							else {
								// The filesize line should appear last
								if (previousNode.tagName == 'SPAN' && previousNode.hasAttribute('class') && previousNode.getAttribute('class') == 'filesize') {
									tableCell.appendChild(document.createElement('br'));
									tableCell.appendChild(previousNode.cloneNode(true))
								}
								// Skip <br> tags
								else if (previousNode.tagName == 'BR')
									;
								else
									tableCell.insertBefore(previousNode.cloneNode(true), tableCell.firstChild);
								
								previousNode = previousNode.previousSibling;
							}
						}
						// Add the actual text
						tableCell.appendChild(sibling.nextSibling.nextSibling.cloneNode(true));
						
						// Make viewport visible
						var viewport = document.getElementById('backwash-viewport');
						var row = viewport.firstChild.firstChild;
						row.appendChild(tableCell);
						moveViewport(event, viewport);
						viewport.style.display = 'block';
					}
				}	
			}
		}
	}

	/// Hides the quote viewport
	function hideQuote(event) {
		var viewport = document.getElementById('backwash-viewport');
		viewport.style.display = 'none';

		var row = viewport.firstChild.firstChild;
		// Empty the viewport
		while (row.hasChildNodes())
			row.removeChild(row.firstChild);
	}

	/// Positions the quoted post.
	/// From the original /b/ackwash script; God, I hate positioning.
	function moveViewport(event, viewport) {
		const viewportHeight = parseInt(
				document.defaultView.getComputedStyle(
					viewport, '').getPropertyValue('height'));
		const cursorRelY = event.pageY - window.scrollY;
		const viewportAbsBottom = event.pageY - VIEW_Y_OFFSET + 
			viewportHeight;

		const windowHeight = window.innerHeight;
		const windowBottom = window.scrollY + windowHeight;

		viewport.style.top = 
			(cursorRelY < VIEW_Y_OFFSET || viewportHeight > windowHeight) ? 
			event.pageY -  cursorRelY :
			(viewportAbsBottom > windowBottom) ? 
				event.pageY - VIEW_Y_OFFSET - (viewportAbsBottom - windowBottom) :
				event.pageY - VIEW_Y_OFFSET + 'px';

		viewport.style.left = event.pageX + VIEW_X_OFFSET + 'px';
	}

	document.addEventListener('DOMContentLoaded', function(e) {
		// Add event listeners to quotes
		addListenerToQuotes(document);
		// Create the viewport
		setupViewport();
	}, false);


	document.addEventListener('DOMNodeInserted', function(e) {
		// Re-add event listener to any quotes
		addListenerToQuotes(e.target);

		// If the viewport was removed, re-create it.
		if (document.getElementById('backwash-viewport') == null)
			setupViewport();
	}, false);
	
	})();
}
