global static class html
	// Render a html element within the draw function. It renders a div by default, but you can specify a different tag.
	// In addition to the listed parameters, you can also specify html attributes and css styles. 
	// You can use all members of the Styles class as parameters to apply css styles to the element. 
	// You can use all members of the Attributes class as parameters to apply html attributes to the element. 
	// You can render the children of the element in an indented block of code underneath the div.
	// Example:
	//     app
	//         draw
	//             column gap:30, fontSize:60, margin:{top:80 left:80}, width:100%
	//                 div tag:"h1", text:"Todo List"
	//                 for items as item
	//     		           div text:item.text, fontStyle:italic
	importance:5
	global div: string text = null                // The text content of the element 
		        string tag = "div"                // The tag of element, defaults to "div"
		        expand Attributes attributes = {} // The attributes of the element
		        expand Style style = null         // Apply this css style to the element
		        dynamic data = {}                 // The data attributes of the element
		        Style styleWhenHovering = null    // The css style that should be applied to the element when the user moves their pointer over the element
		        Style styleWhenFocused = null     // The css style that should be applied to the element when it is focused
				bool focusInitially = false       // Focus the element when its first created. It will not be focused again when the page is refreshed.
		        void() children = null            // A block of code that renders the children of the element
		        SourceCodeLocation location
		HTMLElement element, nextNode
		string sourceLocation = location?.toString
		string key = attributes?.key
		
		if key
			// If a key is specified, we store all nodes in a dictionary on the parent object
			if not parentNode.childrenByKey: parentNode.childrenByKey = {}
			element = parentNode.childrenByKey[key]
			if not element
				// Create new element (with key)
				element = HTMLElement.create tag
				parentNode.childrenByKey[key] = element
				nextNode = currentNode
				if nextNode: parentNode.insertBefore element, nextNode
				else         parentNode.appendChild element
				nodesCreated++
			else
				// Resuse existing element (with key)
				nextNode = currentNode ? currentNode.nextSibling : null
				nodesUpdated++
			element.used = true
			
		else	
			if !currentNode or (currentNode.tagName?.toLowerCase != tag or currentNode.sourceLocation != sourceLocation)
				// Create new element
				element = HTMLElement.create tag
				nextNode = currentNode
				if nextNode: parentNode.insertBefore element, nextNode
				else         parentNode.appendChild element
				// TEMP: TO THINK ABOUT
				if focusInitially
					delay 0: element.focus
				nodesCreated++
			else
				// Resuse existing element
				element = currentNode
				nextNode = currentNode.nextSibling
				nodesUpdated++
		
		setStyle element, style
		setDataAttributes element, data
		
		if attributes != null
			if attributes.id and attributes.id != element.id:           element.id = attributes.id
			if attributes.class and attributes.class != element.class:  element.class = attributes.class
			if attributes.title and attributes.title != element.title:  element.title = attributes.title
			if attributes.tabIndex:                                     element.set("tabindex", attributes.tabIndex.toString)
			
			if attributes.onClick != null:      element.onclick = attributes.onClick
			if attributes.onRightClick != null: element.oncontextmenu = attributes.onRightClick
			if attributes.onPointerDown != null:element.onpointerdown = attributes.onPointerDown
			if attributes.onPointerOver != null:element.onpointerover = attributes.onPointerOver
			if attributes.onPointerOut != null: element.onpointerout  = attributes.onPointerOut

			if attributes.onKeyDown != null:    element.onkeydown = attributes.onKeyDown
			if attributes.onKeyUp != null:      element.onkeyup = attributes.onKeyUp

			if styleWhenFocused == null
				if attributes.onBlur != null:   element.onblur = attributes.onBlur
				if attributes.onFocus != null:  element.onfocus = attributes.onFocus
			
		element.sourceLocation = sourceLocation
		if styleWhenHovering != null
			Style styleWhenNotHovering = getStyleToRevert originalStyle:style, styleWhenHovering
			element.onpointerover = setStyle(element, styleWhenHovering)
			element.onpointerout  = setStyle(element, styleWhenNotHovering)
		
		if styleWhenFocused != null
			Style styleWhenNotFocused = getStyleToRevert originalStyle:style, styleWhenFocused
			element.onfocus = print "#div onfocus"; setStyle(element, styleWhenFocused); if attributes?.onFocus != null: attributes.onFocus(.)
			element.onblur  = print "#div onblur"; setStyle(element, styleWhenNotFocused); if attributes?.onBlur != null: attributes.onBlur(.)
			if html.activeElement == element: setStyle(element, styleWhenFocused)

		if text != null
			if element.shadowInnerHtml != text
				element.innerHTML = text
				element.shadowInnerHtml = text
		else
		if children != null or element.hasChildren
			element.shadowInnerHtml = null
			let prevParentNode = parentNode
			parentNode = element
			currentNode = element.firstChild
			if parentNode.childrenByKey
				for parentNode.childrenByKey
					.used = false
			children()
			
			// Remove all children that are no longer used
			if parentNode.childrenByKey
				// If the children have keys, removed all nodes that are not marked as "used"
				for parentNode.childrenByKey
					if not .used
						.remove
						parentNode.childrenByKey.remove key
			else
				// If the chidren don't have keys, remove all remaining nodes, that haven't been reused
				while currentNode
					let next = currentNode.nextSibling
					currentNode.remove
					currentNode = next
			parentNode = prevParentNode
			
		element.hasChildren = children != null
		currentNode = nextNode
		return element
	
	// Render an image html element within the draw function. 
	// Place an image in the folder "assets/pb_public/media" and it will automatically show up in the auto completions (without the file extension).
	// 
	// Example: We place the image "OkButton.png" in "assets/pb_public/media".
	//     app
	//         int clicks = 0
	//         draw
	//             div "You clicked {clicks} times."
	//             img OkButton, onClick:clicks++; refresh
	// Example: We place the images "On.png" and "Off.png" in "assets/pb_public/media".
	//     app
	//         bool isOn = true
	//         draw
	//             img isOn ? On : Off, onClick:isOn = not isOn; refresh
	importance:5
	global img: Image image                       // The image to display
		        void(HtmlEvent ev) onClick = null // Called when the user clicks the image
		        expand Attributes attributes = {} // The attributes of the HTML element
		        expand Style style = null         // The css style of the HTML element
		        dynamic data = null               // The data attributes of the element
		        bool visible = true
		        SourceCodeLocation location
		if not visible: return
		if data == null: data = {}
		data.src = Platform.basePath + image.src
		let element = div tag:"img", attributes, style, data, location
		element.onclick = onClick
		return element

	// Render an external image html element within the draw function. 
	// Example:
	//     User
	//         string name
	//         string profilePicture
	//         drawProfile
	//             div name
	//             img profilePicture
	//     app
	//         User user
	//         draw
	//             user.drawProfile
	importance:5
	global img: string src                        // The file of the image to display
		        expand Attributes attributes = {} // The attributes of the HTML element
		        expand Style style = null         // The css style of the HTML element
		        SourceCodeLocation location
		return div tag:"img", attributes, style, data:{src:src.startsWith("http") or src.startsWith("data:") or src.startsWith("blob:") ? src : Platform.basePath + src}, location
		
	global img: string src                        // The file of the image to display
		        expand Attributes attributes = {} // The attributes of the HTML element
		        expand Style style = null         // The css style of the HTML element
		        dynamic data                      // The data attributes of the element
		        SourceCodeLocation location
		if data == null: data = {}
		data.src = src.startsWith("http") or src.startsWith("data:") or src.startsWith("blob:") ? src : Platform.basePath + src
		return div tag:"img", attributes, style, data, location

	// Render a html button element within the draw function.
	// You can specify the onClick handler in an indented block of code underneath the button.
	// Example:
	//     app
	//         int clicks = 0
	//         draw
	//             button "You clicked {clicks} times."
	//                 clicks++
	//                 refresh
	importance:5
	global button: string text = null                // The text to display on the button
		           void() onClick = null // Called when the user clicks the button
		           expand Attributes attributes = {} // The attributes of the HTML element
		           expand Style style = null         // The css style of the HTML element
				   bool triggerWithEnterKey = false  // Make this the default button that triggers the onClick handler when the user presses the enter key
		           SourceCodeLocation location
		let element = div text, tag:"button", attributes, style, location
		if triggerWithEnterKey: html.defaultButtonToTriggerWithEnterKey = onClick
		element.onpointerdown = onClick
		return element
		
	importance:5
	global button: string text = null                // The text to display on the button
		           bool(HtmlEvent ev) onClick = null // Called when the user clicks the button
		           expand Attributes attributes = {} // The attributes of the HTML element
		           expand Style style = null         // The css style of the HTML element
		           bool disableAfterClick = false    // Disable the button after the user clicks it
		           SourceCodeLocation location
		let element = div text, tag:"button", attributes, style, location
		if disableAfterClick
			element.disabled = false
			element.onpointerdown = let success = onClick(.); if not object.isEqualAndSameType(success, false): element.disabled = true
		else
			element.onpointerdown = onClick(.)
		return element

	// Render a html div element with a flex layout and a flex direction of row
	// Convenience shortcut for: div display:flex, flexDirection:row
	// Example:
	//     app
	//         drawToolbar
	//             row gap:8, alignItems:center, justifyContent:spaceBetween, width:100%
	//                 img OpenIcon, size:{32,32}
	//                 img SaveIcon, size:{32,32}
	importance:5
	global row: expand Attributes attributes = null // The attributes of the HTML element
		        expand Style style = {}             // The css style of the HTML element
		        void() children = null              // The children of the HTML element
		        SourceCodeLocation location
		style.display = flex
		style.flexDirection = row
		return div attributes, style, children, location

	// Render a html div element with a flex layout and a flex direction of column. 
	// Convenience shortcut for: div display:flex, flexDirection:column
	// Example:
	//     app
	//         drawSidebar
	//             column gap:8, alignItems:end, justifyContent:start, width:100%
	//                 for sidebarItems as item
	//                     div item.text, color:#808080
	importance:5
	global column: expand Attributes attributes = null // The attributes of the HTML element
		           expand Style style = {}             // The css style of the HTML element
		           void() children = null              // The children of the HTML element
		           SourceCodeLocation location
		style.display = flex
		style.flexDirection = column
		return div attributes, style, children, location

	// Render a html div element with a grid layout
	importance:4
	global grid: expand Attributes attributes = null // The attributes of the HTML element
		         expand Style style = {}             // The css style of the HTML element
		         float[] gridTemplateColumns         // The sizes of the columns
		         void() children = null              // The children of the HTML element
		         SourceCodeLocation location
		style.display = grid
		string gridTemplateColumnsString
		for gridTemplateColumns
			gridTemplateColumnsString += "{.}fr "
		style.gridTemplateColumns = gridTemplateColumnsString
		return div attributes, style, children, location

	// Render a html anchor element to link to a url
	importance:5
	global link: string text = null
		         string href = "#"
		         expand Attributes attributes = {} // The attributes of the HTML element
		         expand Style style = null         // The css style of the HTML element
		         SourceCodeLocation location
		let element = div text, tag:"a", attributes, style, location
		element.href = href
		return element

	// Render a html span element to display text
	importance:5
	global span: string text = null                // The text to display within the span
		         expand Attributes attributes = {} // The attributes of the HTML element
		         expand Style style = null         // The css style of the HTML element
		         SourceCodeLocation location
		return div text, tag:"span", attributes, style, location

	// Render a html input element in the draw function
	importance:5
	global HTMLElement input: string value = ""                 // The value to display in the field
		                      string placeholder = ""           // The placeholder text to display in the field
							  bool readOnly = false             // Whether the field should be read only
							  void(string value) onInput = null // Called immediately after every keystroke
		                      expand Attributes attributes = {} // The attributes of the HTML element
		                      expand Style style = null         // The css style of the HTML element
		                      dynamic data = {}                 // The data attributes of the element
							  bool focusInitially = false       // Focus the element when its first created. It will not be focused again when the page is refreshed.
							  Style styleWhenFocused = null         // The css style to apply when the element is focused
		                      SourceCodeLocation location
		let element = div tag:"input", attributes, style, data, focusInitially, styleWhenFocused, location
		element.value = value
		element.placeholder = placeholder
		element.readOnly = readOnly
		element.oninput = onInput(element.value)
		return element

	// ---------------------------------------- Radio & Toggle ----------------------------------------
	
	// Render a html radio buttom element in the draw function.
	// The model variable you pass in will be updated when the user clicks the radio button.
	importance:4
	global inline void radio: int model                         // The variable that holds the value. This will be updated when the user clicks the radio button
		                      int value                         // The value of this state of the radio button
		                      Image image                       // The image to display
		                      expand Attributes attributes = {} // The attributes of the HTML element
		                      expand Style style = null         // The css style of the HTML element
		                      dynamic data = null               // The data attributes of the element
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let element = div tag:"img", attributes, style, data, location
		element.style.opacity = model == value ? 1 : .3
		element.src = Platform.basePath + image.src
		element.onclick = model = value; changeHandler; refresh

	// Render a html radio buttom element in the draw function.
	// The model variable you pass in will be updated when the user clicks the radio button.
	importance:4
	global inline void radio: int model                         // The variable that holds the value. This will be updated when the user clicks the radio button
		                      int value                         // The value of this state of the radio button
		                      Image image                       // The image to display
		                      inline void() onInput             // Called when the user clicks the radio button
		                      expand Attributes attributes = {} // The attributes of the HTML element
		                      expand Style style = null         // The css style of the HTML element
		                      dynamic data = null               // The data attributes of the element
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let element = div tag:"img", attributes, style, data, location
		element.style.opacity = model == value ? 1 : .3
		element.src = Platform.basePath + image.src
		element.onclick = model = value; onInput; changeHandler; refresh

	// Render a html element in the draw function that toggles between two images when the user click it.
	// The model variable you pass in will be updated when the user clicks the toggle button.
	importance:4
	global inline void toggle: bool model                        // The variable that holds the value. This will be updated when the user clicks the toggle button
		                       Image[] images                    // A list with one image per state of the toggle
		                       expand Attributes attributes = {} // The attributes of the HTML element
		                       expand Style style = null         // The css style of the HTML element
		                       dynamic data = null               // The data attributes of the element
		                       SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let element = div tag:"img", attributes, style, data, location
		element.src = Platform.basePath + images[model ? 1 : 0].src
		element.onclick = model = !model; changeHandler; refresh

	// Render a html element in the draw function that toggles between two images when the user click it.
	// The model variable you pass in will be updated when the user clicks the toggle button.
	importance:4
	global inline void toggle: bool model                        // The variable that holds the value. This will be updated when the user clicks the toggle button
		                       Image[] images                    // A list with one image per state of the toggle
		                       inline void() onInput             // Called when the user clicks the toggle button
		                       expand Attributes attributes = {} // The attributes of the HTML element
		                       expand Style style = null         // The css style of the HTML element
		                       dynamic data = null               // The data attributes of the element
		                       SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let element = div tag:"img", attributes, style, data, location
		element.src = Platform.basePath + images[model ? 1 : 0].src
		element.onclick = model = !model; onInput; changeHandler; refresh

	// ---------------------------------------- Input & TextArea ----------------------------------------
	
	int focusTabIndex = 0
	
	// Render a html input element in the draw function.
	// The model variable you pass in will be updated automatically after every keystroke.
	importance:4
	global inline void field: string model = ""                 // The variable that holds the value. This will be updated when the user changed the text
		                      string placeholder = ""           // The placeholder text to display in the field
		                      InputType type = text            // The type of the input field
		                      bool focused = false              // Whether the cursor should be placed in the field
		                      expand Attributes attributes = {} // The attributes of the HTML element
		                      expand Style style = null         // The css style of the HTML element
		                      dynamic data = {}                 // The data attributes of the element
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let element = div tag:"input", attributes, style, data, location
		element.value = model
		element.placeholder = placeholder
		element.type = type
		element.oninput = model = element.value; changeHandler
		if focused: element.focus
	
	// Render a html input element in the draw function.
	// The model variable you pass in will be updated automatically after every keystroke.
	importance:4
	global inline void field: string model = ""                 // The variable that holds the value. This will be updated when the user changed the text
		                      bool focused = false              // Whether the cursor should be placed in the field
		                      inline void() onEnter = null      // Called when the user presses the enter key
		                      expand Attributes attributes = {} // The attributes of the HTML element
		                      expand Style style = null         // The css style of the HTML element
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let element = div tag:"input", attributes, style, location
		element.value = model
		element.oninput = model = element.value; changeHandler
		element.onkeydown = if(ev.keyCode == Enter) onEnter()
		if focused or focusTabIndex == attributes.tabIndex: element.focus
		
	// Render a manual html input element in the draw function. 
	// If you specify a onChange handler, the model won't be updated automatically.
	importance:4
	global inline void field: string text = ""                     // The variable that holds the value. This will be updated when the user changed the text
		                      bool focused = false                 // Whether the cursor should be placed in the field
		                      inline void(string value) onChange   // If you specify a onChange handler, the model won't be updated automatically
		                      expand Attributes attributes = {}    // The attributes of the HTML element
		                      expand Style style = null            // The css style of the HTML element
		                      bool updateWithEveryKeystroke = true // Should onChange be called with every keystroke?
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let element = div tag:"input", attributes, style, location
		element.value = text or ""
		if updateWithEveryKeystroke: element.oninput = onChange(element.value); changeHandler
		else         element.onchange = onChange(element.value); changeHandler
		if focused or focusTabIndex == attributes.tabIndex: element.focus
			
	// Render a html file input element in the draw function. 
	// The onChange handler will be called when the user selects a file.
	importance:4 fileInput: string accept = "image/*"
		       string capture = "environment"
		       bool multiple = false
		       void(HTMLElement element) onChange = null
		       expand Style style = null
		       SourceCodeLocation location
		dynamic data = {type:"file" accept capture}
		if multiple: data.multiple = true
		let element = div tag:"input", data, style, location
		element.onchange = onChange(element)
		element.setAttribute("capture", "environment")
		return element
		
	js Promise<string> getDataUrlForFile: File file
		return new Promise((resolve, reject) => {
			const reader = new FileReader();
			reader.onload = e => resolve(e.target.result);
			reader.readAsDataURL(file);	
		})
	
	// Render a html editable text element in the draw function.
	// The model variable you pass in will be updated automatically.
	importance:4
	global inline void editableText: string model = ""                          // The variable that holds the value. This will be updated when the user changed the text
		                             inline void(string value) onChanged = null // Called after the model changed
		                             int tabIndex = -1
		                             expand Attributes attributes = {}          // The attributes of the HTML element
		                             expand Style style = null                  // The css style of the HTML element
		                             dynamic data = {}                          // The data attributes of the element
		                             bool updateWithEveryKeystroke = false      // Should onChange be called with every keystroke?
		                             SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let element = div attributes, style, data, location
		if model != element.innerText: element.innerText = model
		element.contentEditable = "plaintext-only"
		let prevModel = model
		if updateWithEveryKeystroke
			element.oninput = model = element.innerText; onChanged(model); changeHandler
		else         
			element.onblur = model = element.innerText; if model != prevModel: onChanged(model); changeHandler
		if focusTabIndex == tabIndex: delay 100: element.focus

	// Render a html editable text element in the draw function.
	// The model variable you pass in will be updated automatically.
	importance:4
	global inline void editableText: string model = ""                          // The variable that holds the value. This will be updated when the user changed the text
		                             inline void(string value) onChanged = null // Called after the model changed
		                             inline void() onClick = null
		                             int tabIndex = -1
		                             expand Attributes attributes = {}          // The attributes of the HTML element
		                             expand Style style = null                  // The css style of the HTML element
		                             dynamic data = {}                          // The data attributes of the element
		                             bool updateWithEveryKeystroke = false      // Should onChange be called with every keystroke?
		                             SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let element = div attributes, style, data, location
		if model != element.innerText: element.innerText = model
		element.onclick = onClick
		element.contentEditable = "plaintext-only"
		let prevModel = model
		if updateWithEveryKeystroke
			element.oninput = model = element.innerText; onChanged(model); changeHandler
		else         
			element.onblur = model = element.innerText; if model != prevModel: onChanged(model); changeHandler
		if focusTabIndex == tabIndex: delay 100: element.focus

	// Render a html textarea element in the draw function.
	// The model variable you pass in will be updated automatically after every keystroke.
	importance:4
	global inline void textarea: string model = ""                 // The variable that holds the value. This will be updated when the user changed the text
		                         bool focused = false              // Whether the cursor should be placed in the field
		                         expand Attributes attributes = {} // The attributes of the HTML element
		                         expand Style style = null         // The css style of the HTML element
		                         SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let element = div tag:"textarea", attributes, style, location
		element.value = model
		element.style.minHeight = 16px
		element.style.overflow = scroll; element.style.height = 1px; element.style.height = element.scrollHeight px; element.style.overflow = hidden
		element.oninput = model = element.value; element.style.overflow = scroll; element.style.height = 1px; element.style.height = element.scrollHeight px; element.style.overflow = hidden; changeHandler
		if focused or focusTabIndex == attributes.tabIndex: element.focus

	// ---------------------------------------- Canvas ----------------------------------------
	
	dynamic currentContext
	
	// Render a html canvas element in the draw function. 
	// You can draw on the canvas in an indented block of code underneath the canvas.
	// Example:
	//     app
	//         draw
	//             canvas size:{100,100}
	//                 drawRectangle pos:{0,0}, size:{100,100}, color:red
	importance:4
	global canvas: Vector2 size
		           expand Attributes attributes = {} // The attributes of the HTML element
		           expand Style style = null         // The css style of the HTML element
		           void() draw
		           SourceCodeLocation location
		if style == null: style = {}
		style.width = {size.x}
		style.height = {size.y}
		let canvas = div tag:"canvas", attributes, style, location
		canvas.width = size.x
		canvas.height = size.y 
		currentContext = canvas.context
		if currentContext == null: currentContext = canvas.context = canvas.getContext("2d")
		currentContext.clearRect(0,0,style.width,style.height)
		draw()
		return canvas
		
	// Draw a rectangle on the canvas in an indented block of code underneath the canvas.
	// Example:
	//     app
	//         draw
	//             canvas size:{100,100}
	//                 drawRectangle pos:{0,0}, size:{100,100}, color:red
	importance:4
	global drawRectangle: Vector2 pos
		                  Vector2 size
		                  Color color = black
		currentContext.fillStyle = color.colorString
		currentContext.fillRect(pos.x, pos.y, size.x, size.y)
		
	// Draw text on the canvas in an indented block of code underneath the canvas.
	// Example:
	//     app
	//         draw
	//             canvas size:{100,100}
	//                 drawText text:"Hello, world!", pos:{0,0}, size:30, color:red
	importance:4
	global drawText: implicit string text
		             Vector2 pos
		             float size = 30
		             Font font = null
		             Color color = black
		currentContext.fillStyle = color.colorString
		string effectiveFont = font ? font.name : "Open Sans"
		currentContext.font = "{size}px {effectiveFont}"
		currentContext.fillText(text, pos.x, pos.y)
	
	// ---------------------------------------- Misc ----------------------------------------

	// Render a html script element
	importance:4 script: string src
			dynamic data = {}
		let element = div tag:"script", data
		if !element.src.endsWith(src): element.src = src
		element.onload = refresh
		
	// Render a html link element to include a css stylesheet file
	importance:4 css: string src
		dynamic element = cast div tag:"link"
		element.rel = "stylesheet" 
		if !element.href.endsWith(src): element.href = Platform.basePath + src
		
	// Render a html style element to include a css style
	importance:4 style: string text
		return div tag:"style" text
		
	// Render a html video element to display a video
	video: string src                        // The file of the video to display 
		   expand Attributes attributes = {} // The attributes of the HTML element 
		   expand Style style = {}           // The css style of the HTML element 
		   SourceCodeLocation location
		style.position = absolute
		style.zIndex = -1000
		let element = div tag:"video", attributes, style, location, data:{src}
		element.muted = true
		element.autoplay = true
		
	// Render a html iframe element to display a web page
	iframe: string src                        // The url of the content to display
		           expand Attributes attributes = {} // The attributes of the HTML element
		           expand Style style = null         // The css style of the HTML element
		           dynamic data = {}                 // The data attributes of the element
		           int frameborder = 0
		           string allow = ""
		           string referrerpolicy = ""
		           bool allowfullscreen = true
		           SourceCodeLocation location
		data.frameborder = frameborder
		data.allow = allow
		data.referrerpolicy = referrerpolicy
		data.allowfullscreen = allowfullscreen
		let element = div tag:"iframe", attributes, style, data, location
		if element.src != src: element.src = src
		return element

	// Render a electron webview element to display a web page
	webview: string initialUrl = ""              // The url of the content to display
		            expand Attributes attributes = {} // The attributes of the HTML element
		            expand Style style = null         // The css style of the HTML element
		            dynamic data = null               // The data attributes of the element
		            void(string url) onNavigate = null
		            SourceCodeLocation location
		WebView element = cast div tag:"webview", attributes, style, data, location
		element.onWillNavigate = onNavigate
		if not element.src: element.src = initialUrl
		if !element.hasHandlers
			element.hasHandlers = true
			element.on "will-navigate": if element.onWillNavigate != null: element.onWillNavigate(event.url)
		return element

	global body: expand Attributes attributes = {} // The attributes of the element
		         expand Style style = null         // Apply this css style to the element
		         void() children
		         nocolon void() header
		         SourceCodeLocation location
		let element = div attributes, style, children, location
		let prevParentNode = parentNode
		let prevCurrentNode = currentNode
		parentNode = element
		currentNode = element.firstChild
		header
		parentNode = prevParentNode
		currentNode = prevCurrentNode

	global overlay: expand Attributes attributes = {} // The attributes of the element
		            expand Style style = null         // Apply this css style to the element
		            void() children = null            // The children of the element
		            SourceCodeLocation location
		HTMLElement element, nextNode
		string sourceLocation = location?.toString
		
		if !currentOverlay or currentOverlay.sourceLocation != sourceLocation
			element = HTMLElement.create "div"
			nextNode = currentOverlay
			if nextNode: documentBody.parentNode.insertBefore element, nextNode
			else         documentBody.parentNode.appendChild element
		else
			element = currentOverlay
			nextNode = currentOverlay.nextSibling
		
		if style == null: style = {}	
		if not style.inset:           style.inset = {0,0,0,0}
		if not style.position:        style.position = fixed
		setStyle element, style
		
		if attributes != null
			if attributes.id != null:           element.id = attributes.id
			if attributes.class != null:        element.class = attributes.class
			if attributes.onClick != null:      element.onclick = attributes.onClick
			if attributes.onRightClick != null: element.oncontextmenu = attributes.onRightClick
				
		let prevParentNode = parentNode
		let prevCurrentNode = currentNode
		parentNode = element
		currentNode = element.firstChild
		children()
		while currentNode
			let next = currentNode.nextSibling
			currentNode.remove
			currentNode = next
		parentNode = prevParentNode
		currentNode = prevCurrentNode
		
		currentOverlay = nextNode
		return element
		
