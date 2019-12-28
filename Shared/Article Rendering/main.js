// Here we are making iframes responsive.  Particularly useful for inline Youtube videos.
function wrapFrames() {
	document.querySelectorAll("iframe").forEach(element => {
		var wrapper = document.createElement("div");
		wrapper.classList.add("iframeWrap");
		element.parentNode.insertBefore(wrapper, element);
		wrapper.appendChild(element);
	});
}

// Strip out all styling so that we have better control over layout
function stripStyles() {
	document.getElementsByTagName("body")[0].querySelectorAll("style, link[rel=stylesheet]").forEach(element => element.remove());
	document.getElementsByTagName("body")[0].querySelectorAll("[style]").forEach(element => element.removeAttribute("style"));
}

// Convert all image locations to be absolute
function convertImgSrc() {
	document.querySelectorAll("img").forEach(element => {
		element.src = new URL(element.src, document.baseURI).href;
	});
}

// Wrap tables in an overflow-x: auto; div
function wrapTables() {
	var tables = document.querySelectorAll("div.articleBody")[0].getElementsByTagName("table");

	for (table of tables) {
		var wrapper = document.createElement("div");
		wrapper.className = "nnw-overflow";
		var tableCopy = table.cloneNode(true);
		wrapper.appendChild(tableCopy);
		table.parentNode.replaceChild(wrapper, table);
	}
}

function reloadArticleImage() {
	var image = document.getElementById("nnwImageIcon");
	image.src = "nnwImageIcon://";
}

function error() {
	document.body.innerHTML = "error";
}

function render(data, scrollY) {
	document.getElementsByTagName("style")[0].innerHTML = data.style;
	document.body.innerHTML = data.body;
	
	window.scrollTo(0, scrollY);
	
	wrapFrames()
	wrapTables()
	stripStyles()
	convertImgSrc()
	postRenderProcessing()
}
