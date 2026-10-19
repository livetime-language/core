	draw	// Render html (on startup and when refresh is called)
		div "Hello World",color:#ff0000, border:{width:1px, style:solid, color:black}	// Html elements use inline styles
		div tag:"h1", text:"Title", width:100%	// Headline
		div boxShadow:{offset:{4,4}, blur:16, spread:4, color:#c0c0c0}	// Shadow
		coloum	// Short for: div display:flex, flexDirection:column
			for doc in documents	// Indent to specify children
				div doc.name, margin:{top:10%, right:auto, bottom:10%, left:auto}	// All styles: lib/core/html/cssStyles.l (add additional if needed)
		field model:name	// All elements: lib/core/html/htmlElements.l (add additional if needed)
		row backgroundColor:app.buttonColor	// Put constants in app class
			img SaveIcon, width:64px	// Put images in media/ folder and add to src/media.l
			div "Save", fontSize:64, color:white	// Values are in pixels if no unit is given
		onClick:	// Click listener for row
			print "Saving", type:Action	// Print types: Action, Reaction, Info, Warning, Error
		div "Counter: {counter}"	// String interpolation
		button "Increment counter", onClick:counter++; refresh	// Call refresh to re-render the html after you changed any data
		button "Submit name", onClick:http.post "/api/name", body:{name}; refresh	// Button
		div width:"calc(100% - 16px)"	// You can use a css string instead of a number. Always specify units is css
	js void navigateTo: string url	// Use js keyword to write function body in JavaScript for low-level interop. Return type is required.
		location.href = url;	// JavaScript code. Do not use nested functions.

# HTML Framework
Elements that are grouped together visually should be in the same function.

