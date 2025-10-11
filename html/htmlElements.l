global static class html
	// Render a html element within the draw function. It renders a div by default, but you can specify a different tag.
	// In addition to the listed parameters, you can also specify html attributes and css styles. 
	// You can use all members of the Styles class as parameters to apply css styles to the element. 
	// You can use all members of the Attributes class as parameters to apply html attributes to the element. 
	// You can render the children of the element in an indented block of code underneath the div.
	// Example:
	//     app
	//         draw
	//             div display:Flex, flexDirection:Column, gap:30, fontSize:60, margin:{top:80 left:80}
	//                 div tag:"h1", text:"Todo List"
	//                 for items as item
	//     		           div text:item.text, fontStyle:Italic
	importance:5
	global div: string text = null                // The text content of the element 
		        string tag = "div"                // The tag of element, defaults to "div"
		        expand Attributes attributes = {} // The attributes of the element
		        expand Style style = null         // Apply this css style to the element
		        dynamic data = {}                 // The data attributes of the element
		        Style onHover = null              // Apply this css style to the element when the user moves their mouse over the element
		        void() children = null            // A block of code that renders the children of the element
		        SourceCodeLocation location
		Node node, nextNode
		string sourceLocation = location?.toString
		string key = attributes?.key
		
		if key
			// If a key is specified, we store all nodes in a map on the parent object
			if not parentNode.childrenByKey: parentNode.childrenByKey = {}
			node = parentNode.childrenByKey[key]
			if not node
				// Create new node (with key)
				node = Node.create tag
				parentNode.childrenByKey[key] = node
				nextNode = currentNode
				if nextNode: parentNode.insertBefore node, nextNode
				else         parentNode.appendChild node
				nodesCreated++
			else
				// Resuse existing node (with key)
				nextNode = currentNode ? currentNode.nextSibling : null
				nodesUpdated++
			node.used = true
			
		else	
			if !currentNode or (currentNode.tagName?.toLowerCase != tag or currentNode.sourceLocation != sourceLocation)
				// Create new node
				node = Node.create tag
				nextNode = currentNode
				if nextNode: parentNode.insertBefore node, nextNode
				else         parentNode.appendChild node
				nodesCreated++
			else
				// Resuse existing node
				node = currentNode
				nextNode = currentNode.nextSibling
				nodesUpdated++
		
		setStyle node, style
		setDataAttributes node, data
		
		if attributes != null
			if attributes.id and attributes.id != node.id:           node.id = attributes.id
			if attributes.class and attributes.class != node.class:  node.class = attributes.class
			if attributes.title and attributes.title != node.title:  node.title = attributes.title
			
			if attributes.onClick != null:      node.onclick = attributes.onClick
			if attributes.onLeftClick != null:  node.onclick = attributes.onLeftClick
			if attributes.onRightClick != null: node.oncontextmenu = attributes.onRightClick
			if attributes.onKeyDown != null:    node.onkeydown = attributes.onKeyDown
			if attributes.onKeyUp != null:      node.onkeyup = attributes.onKeyUp
			if attributes.tabIndex:             node.set("tabindex", attributes.tabIndex.toString)
			
		node.sourceLocation = sourceLocation
		if onHover != null
			Style unHover = getStyleToRevert originalStyle:style, onHover
			node.onpointerover = setStyle(node, onHover)
			node.onpointerout  = setStyle(node, unHover)
		
		if text != null
			if node.shadowInnerHtml != text
				node.innerHTML = text
				node.shadowInnerHtml = text
		else
		if children != null or node.hasChildren
			node.shadowInnerHtml = null
			let prevParentNode = parentNode
			parentNode = node
			currentNode = node.firstChild
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
			
		node.hasChildren = children != null
		currentNode = nextNode
		return node
	
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
		let node = div tag:"img", attributes, style, data, location
		node.onclick = onClick
		return node

	// Render an external image html element within the draw function. 
	// Example:
	//     User
	//         string name
	//         string profilePicture
	//         drawProfile
	//             div name
	//             img profilePicture
	//     app
	//         User currentUser
	//         draw
	//             currentUser.drawProfile
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
		           void(HtmlEvent ev) onClick = null // Called when the user clicks the button
		           expand Attributes attributes = {} // The attributes of the HTML element
		           expand Style style = null         // The css style of the HTML element
		           SourceCodeLocation location
		let node = div text, tag:"button", attributes, style, location
		node.onclick = onClick
		return node
		
	importance:5
	global button: string text = null                // The text to display on the button
		           bool(HtmlEvent ev) onClick = null // Called when the user clicks the button
		           expand Attributes attributes = {} // The attributes of the HTML element
		           expand Style style = null         // The css style of the HTML element
		           bool disableAfterClick = false    // Disable the button after the user clicks it
		           SourceCodeLocation location
		let node = div text, tag:"button", attributes, style, location
		if disableAfterClick
			node.disabled = false
			node.onclick = let success = onClick(.); if not object.isEqualAndSameType(success, false): node.disabled = true
		else
			node.onclick = onClick(.)
		return node

	// Render a html div element with a flex layout and a flex direction of "Row"
	// Example:
	//     app
	//         drawToolbar
	//             row gap:8, alignItems:Center, justifyContent:SpaceBetween
	//                 img OpenIcon, size:{32,32}
	//                 img SaveIcon, size:{32,32}
	importance:4
	global row: expand Attributes attributes = null // The attributes of the HTML element
		        expand Style style = {}             // The css style of the HTML element
		        void() children = null              // The children of the HTML element
		        SourceCodeLocation location
		style.display = Flex
		style.flexDirection = Row
		return div attributes, style, children, location

	// Render a html div element with a flex layout and a flex direction of "Column"
	// Example:
	//     app
	//         drawSidebar
	//             column gap:8, alignItems:FlexEnd, justifyContent:FlexStart
	//                 for sidebarItems as item
	//                     div item.text, color:#808080
	importance:4
	global column: expand Attributes attributes = null // The attributes of the HTML element
		           expand Style style = {}             // The css style of the HTML element
		           void() children = null              // The children of the HTML element
		           SourceCodeLocation location
		style.display = Flex
		style.flexDirection = Column
		return div attributes, style, children, location

	// Render a html div element with a grid layout
	importance:4
	global grid: expand Attributes attributes = null // The attributes of the HTML element
		         expand Style style = {}             // The css style of the HTML element
		         float[] gridTemplateColumns         // The sizes of the columns
		         void() children = null              // The children of the HTML element
		         SourceCodeLocation location
		style.display = Grid
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
		let node = div text, tag:"a", attributes, style, location
		node.href = href
		return node

	// Render a html span element to display text
	importance:5
	global span: string text = null                // The text to display within the span
		         expand Attributes attributes = {} // The attributes of the HTML element
		         expand Style style = null         // The css style of the HTML element
		         SourceCodeLocation location
		return div text, tag:"span", attributes, style, location
	
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
		let node = div tag:"img", attributes, style, data, location
		node.style.opacity = model == value ? 1 : .3
		node.src = Platform.basePath + image.src
		node.onclick = model = value; changeHandler; refresh

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
		let node = div tag:"img", attributes, style, data, location
		node.style.opacity = model == value ? 1 : .3
		node.src = Platform.basePath + image.src
		node.onclick = model = value; onInput; changeHandler; refresh

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
		let node = div tag:"img", attributes, style, data, location
		node.src = Platform.basePath + images[model ? 1 : 0].src
		node.onclick = model = !model; changeHandler; refresh

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
		let node = div tag:"img", attributes, style, data, location
		node.src = Platform.basePath + images[model ? 1 : 0].src
		node.onclick = model = !model; onInput; changeHandler; refresh

	// ---------------------------------------- Input & TextArea ----------------------------------------
	
	int focusTabIndex = 0
	
	// Render a html input element in the draw function.
	// The model variable you pass in will be updated automatically after every keystroke.
	importance:4
	global inline void field: string model = ""                 // The variable that holds the value. This will be updated when the user changed the text
		                      bool focused = false              // Whether the cursor should be placed in the field
		                      expand Attributes attributes = {} // The attributes of the HTML element
		                      expand Style style = null         // The css style of the HTML element
		                      dynamic data = {}                 // The data attributes of the element
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"input", attributes, style, data, location
		node.value = model
		node.oninput = model = node.value; changeHandler
		if focused: node.focus
	
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
		let node = div tag:"input", attributes, style, location
		node.value = model
		node.oninput = model = node.value; changeHandler
		node.onkeydown = if(ev.keyCode == Enter) onEnter()
		if focused or focusTabIndex == attributes.tabIndex: node.focus
		
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
		let node = div tag:"input", attributes, style, location
		node.value = text or ""
		if updateWithEveryKeystroke: node.oninput = onChange(node.value); changeHandler
		else         node.onchange = onChange(node.value); changeHandler
		if focused or focusTabIndex == attributes.tabIndex: node.focus
			
	// Render a html file input element in the draw function. 
	// The onChange handler will be called when the user selects a file.
	importance:4 fileInput: string accept = "image/*"
		       string capture = "environment"
		       bool multiple = false
		       void(Node node) onChange = null
		       expand Style style = null
		       SourceCodeLocation location
		dynamic data = {type:"file" accept capture}
		if multiple: data.multiple = true
		let node = div tag:"input", data, style, location
		node.onchange = onChange(node)
		node.setAttribute("capture", "environment")
		return node
		
	private js Promise<string> getDataUrlForFile: File file
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
		let node = div attributes, style, data, location
		if model != node.innerText: node.innerText = model
		node.contentEditable = "plaintext-only"
		let prevModel = model
		if updateWithEveryKeystroke
			node.oninput = model = node.innerText; onChanged(model); changeHandler
		else         
			node.onblur = model = node.innerText; if model != prevModel: onChanged(model); changeHandler
		if focusTabIndex == tabIndex: delay 100: node.focus

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
		let node = div attributes, style, data, location
		if model != node.innerText: node.innerText = model
		node.onclick = onClick
		node.contentEditable = "plaintext-only"
		let prevModel = model
		if updateWithEveryKeystroke
			node.oninput = model = node.innerText; onChanged(model); changeHandler
		else         
			node.onblur = model = node.innerText; if model != prevModel: onChanged(model); changeHandler
		if focusTabIndex == tabIndex: delay 100: node.focus

	// Render a html textarea element in the draw function.
	// The model variable you pass in will be updated automatically after every keystroke.
	importance:4
	global inline void textarea: string model = ""                 // The variable that holds the value. This will be updated when the user changed the text
		                         bool focused = false              // Whether the cursor should be placed in the field
		                         expand Attributes attributes = {} // The attributes of the HTML element
		                         expand Style style = null         // The css style of the HTML element
		                         SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"textarea", attributes, style, location
		node.value = model
		node.style.minHeight = 16px
		node.style.overflow = Scroll; node.style.height = 1px; node.style.height = node.scrollHeight px; node.style.overflow = Hidden
		node.oninput = model = node.value; node.style.overflow = Scroll; node.style.height = 1px; node.style.height = node.scrollHeight px; node.style.overflow = Hidden; changeHandler
		if focused or focusTabIndex == attributes.tabIndex: node.focus

	// ---------------------------------------- Canvas ----------------------------------------
	
	dynamic currentContext
	
	// Render a html canvas element in the draw function. 
	// You can draw on the canvas in an indented block of code underneath the canvas.
	// Example:
	//     app
	//         draw
	//             canvas size:{100,100}
	//                 drawRectangle pos:{0,0}, size:{100,100}, color:Red
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
	//                 drawRectangle pos:{0,0}, size:{100,100}, color:Red
	importance:4
	global drawRectangle: Vector2 pos
		                  Vector2 size
		                  Color color = Black
		currentContext.fillStyle = color.colorString
		currentContext.fillRect(pos.x, pos.y, size.x, size.y)
		
	// Draw text on the canvas in an indented block of code underneath the canvas.
	// Example:
	//     app
	//         draw
	//             canvas size:{100,100}
	//                 drawText text:"Hello, world!", pos:{0,0}, size:30, color:Red
	importance:4
	global drawText: implicit string text
		             Vector2 pos
		             float size = 30
		             Font font = null
		             Color color = Black
		currentContext.fillStyle = color.colorString
		string effectiveFont = font ? font.name : "Open Sans"
		currentContext.font = "{size}px {effectiveFont}"
		currentContext.fillText(text, pos.x, pos.y)
	
	// ---------------------------------------- Misc ----------------------------------------

	// Render a html script element
	importance:4 script: string src
			dynamic data = {}
		let node = div tag:"script", data
		if !node.src.endsWith(src): node.src = src
		node.onload = refresh
		
	// Render a html link element to include a css stylesheet file
	importance:4 css: string src
		dynamic node = cast div tag:"link"
		node.rel = "stylesheet" 
		if !node.href.endsWith(src): node.href = Platform.basePath + src
		
	// Render a html style element to include a css style
	importance:4 style: string text
		return div tag:"style" text
		
	// Render a html video element to display a video
	video: string src                        // The file of the video to display 
		   expand Attributes attributes = {} // The attributes of the HTML element 
		   expand Style style = {}           // The css style of the HTML element 
		   SourceCodeLocation location
		style.position = Absolute
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
		let node = div tag:"iframe", attributes, style, data, location
		if node.src != src: node.src = src
		return node

	// Render a electron webview element to display a web page
	webview: string initialUrl = ""              // The url of the content to display
		            expand Attributes attributes = {} // The attributes of the HTML element
		            expand Style style = null         // The css style of the HTML element
		            dynamic data = null               // The data attributes of the element
		            void(string url) onNavigate = null
		            SourceCodeLocation location
		WebView node = cast div tag:"webview", attributes, style, data, location
		node.onWillNavigate = onNavigate
		if not node.src: node.src = initialUrl
		if !node.hasHandlers
			node.hasHandlers = true
			node.on "will-navigate": if node.onWillNavigate != null: node.onWillNavigate(event.url)
		return node

	global body: expand Attributes attributes = {} // The attributes of the element
		         expand Style style = null         // Apply this css style to the element
		         void() children
		         nocolon void() header
		         SourceCodeLocation location
		let node = div attributes, style, children, location
		let prevParentNode = parentNode
		let prevCurrentNode = currentNode
		parentNode = node
		currentNode = node.firstChild
		header
		parentNode = prevParentNode
		currentNode = prevCurrentNode

	global overlay: expand Attributes attributes = {} // The attributes of the element
		            expand Style style = null         // Apply this css style to the element
		            void() children = null            // The children of the element
		            SourceCodeLocation location
		Node node, nextNode
		string sourceLocation = location?.toString
		
		if !currentOverlay or currentOverlay.sourceLocation != sourceLocation
			node = Node.create "div"
			nextNode = currentOverlay
			if nextNode: documentBody.parentNode.insertBefore node, nextNode
			else         documentBody.parentNode.appendChild node
		else
			node = currentOverlay
			nextNode = currentOverlay.nextSibling
		
		if style == null: style = {}	
		if not style.inset:           style.inset = {0,0,0,0}
		if not style.position:        style.position = Fixed
		setStyle node, style
		
		if attributes != null
			if attributes.id != null:           node.id = attributes.id
			if attributes.class != null:        node.class = attributes.class
			if attributes.onClick != null:      node.onclick = attributes.onClick
			if attributes.onRightClick != null: node.oncontextmenu = attributes.onRightClick
				
		let prevParentNode = parentNode
		let prevCurrentNode = currentNode
		parentNode = node
		currentNode = node.firstChild
		children()
		while currentNode
			let next = currentNode.nextSibling
			currentNode.remove
			currentNode = next
		parentNode = prevParentNode
		currentNode = prevCurrentNode
		
		currentOverlay = nextNode
		return node
		
