js HTMLElement
class Node
	string id // A unique string to indentify a specic element, often used to style a single element
	
	// A string to assign a class to one or more elements, often used to style several elements
	inline js string class() this.className
	
	// A string to assign a class to one or more elements, often used to style several elements
	inline js string class(string value) this.className = value
	
	string tagName
	string title
	Style style
	string innerHTML
	string innerText
	string shadowInnerHtml
	string value
	string src
	any srcObject
	Node firstChild
	Node nextSibling
	Node parentNode
	float scrollHeight
	string href
	
	bool muted
	bool autoplay
	bool disabled
	int tabindex
	string contentEditable
	dynamic context
	float width
	float height
	
	string sourceLocation
	bool hasChildren
	File[] files
	bool complete // Is the resouce completely loaded?
	
	Node[string] childrenByKey
	bool used
		
	inline js Node remove() this.remove()
	inline js void appendChild(Node node) this.appendChild(node)
	inline js void insertBefore(Node newNode, Node referenceNode) this.insertBefore(newNode, referenceNode)
	inline js void setSelectionRange(int from, int to) this.setSelectionRange(from, to)
	inline js void select() this.select()
	inline js void setCursorPosition(int index) Html.setCursorPosition(this, index)
	inline js void focus() this.focus()
	inline js void scrollToBottom() this.scrollTo(0, this.scrollHeight)
	inline js void scrollIntoView() this.scrollIntoView()
	inline js void on(string eventName, void(dynamic event) listener) this.addEventListener(eventName, listener)
	inline js dynamic getContext(string type) this.getContext(type)
	inline js void setAttribute(string name, string value) this.setAttribute(name, value)
		
	native void(HtmlEvent ev) onclick
	native void(HtmlEvent ev) oncontextmenu
	native void(PointerEvent ev) onpointerdown
	native void(PointerEvent ev) onpointermove
	native void(PointerEvent ev) onpointerup
	native void(PointerEvent ev) onpointerover
	native void(PointerEvent ev) onpointerout
	native void(PointerEvent ev) onpointercancel
	
	native void(HtmlKeyboardEvent ev) onkeydown
	native void(HtmlKeyboardEvent ev) onkeyup
	native void(HtmlEvent ev) oninput
	native void(HtmlEvent ev) onchange
	native void(HtmlEvent ev) onload
	native void(HtmlEvent ev) onblur
	
	inline js void set(string name, string value) this.setAttribute(name, value)
	inline js void get(string name) this.getAttribute(name)
	
	static inline js Node create(string tagName = "div") document.createElement(tagName);
	inline js void click() this.click()
	
	inline js void animate: Style from
		                    Style to
		                    Time duration = 1 seconds
		                    AnimationFill fill = Forwards
		                    easing = "linear"
		this.animate([Html.expandStyle(from), Html.expandStyle(to)], {@duration:duration, @fill:fill, @easing:easing})
		
	Touch[] touches
	
	onTouchDown: void(Touch touch, Touch[] touches, Node node, PointerEvent event) do
		this.onpointerdown = {
			if this.touches == null: this.touches = []
			TouchType type
			if ev.pointerType == Mouse: type = cast ev.button.limit(0..2); else
			if ev.pointerType == Touch: type = Touch; else
				                        type = Pen
			Touch touch = {phase:Down, id:ev.pointerId, type, position:new Vector2(ev.pageX/Platform.scale, ev.pageY/Platform.scale, pixels)}
			touch.shiftKey = ev.shiftKey
			touch.ctrlKey = ev.ctrlKey
			touch.altKey = ev.altKey
			touch.metaKey = ev.metaKey
			this.touches.add touch
			do(touch, touches, this, ev)
		}
	
	onTouchMove: void(Touch touch, Touch[] touches, Node node, PointerEvent event) do
		this.onpointermove = {
			if this.touches == null: this.touches = []
			Touch touch = this.touches.find.id == ev.pointerId
			if touch
				touch.phase = Move
				touch.position.x = ev.pageX/Platform.scale
				touch.position.y = ev.pageY/Platform.scale
				do(touch, touches, this, ev)
		}
	
	onTouchUp: void(Touch touch, Touch[] touches, Node node, PointerEvent event) do
		this.onpointerup = {
			if this.touches == null: this.touches = []
			int index = this.touches.indexWhere.id == ev.pointerId
			if index != -1
				let touch = this.touches[index]
				touch.phase = Up
				touch.position.x = ev.pageX/Platform.scale
				touch.position.y = ev.pageY/Platform.scale
				touch.shiftKey = ev.shiftKey
				touch.ctrlKey = ev.ctrlKey
				touch.altKey = ev.altKey
				touch.metaKey = ev.metaKey
				Node touchedNode = Html.getNodeAt(ev.pageX, ev.pageY)
				touch.touchedId = touchedNode ? touchedNode.id : ""
				this.touches.removeAt(index)
				do(touch, touches, this, ev)
		}
		
	onTouchCancel: void(Touch touch, Touch[] touches, Node node, PointerEvent event) do
		this.onpointercancel = {
			if this.touches == null: this.touches = []
			int index = this.touches.indexWhere.id == ev.pointerId
			if index != -1
				let touch = this.touches[index]
				touch.phase = Canceled
				this.touches.removeAt(index)
				do(touch, touches, this, ev)
		}
		
	js void onScroll: void(Vector2 position, Vector2 delta, bool isPinch) do
		this.onwheel = ev => {
			ev.preventDefault();
			ev.stopPropagation();
			let isPinch = ev.ctrlKey || ev.deltaX === -0		
			do(new Vector2(ev.clientX/Platform.scale, ev.clientY/Platform.scale, "px"), new Vector2(-ev.deltaX, ev.deltaY, "px"), isPinch);
		}
		
	inline js void captureTouch(Touch touch) this.setPointerCapture(touch.id)

dynamic Attributes
	string id    // A unique string to indentify a specic element, often used to style a single element
	string class // A string to assign a class to one or more elements, often used to style several elements
	string key   // A unique identifier used to find the node that should be reused
	string title
	
	native void() onClick = null                       // Execute this code when the user clicks the HTML element
	native void(HtmlEvent ev) onLeftClick = null       // Execute this code when the user clicks the HTML element
	native void(HtmlEvent ev) onRightClick = null      // Execute this code when the user clicks the HTML element with the right mouse button
	native void(HtmlKeyboardEvent ev) onKeyDown = null // Execute this code when the user presses a key on the keyboard
	native void(HtmlKeyboardEvent ev) onKeyUp = null   // Execute this code when the user releases a key on the keyboard
	
	int tabIndex = 0

enum lowercase string PointerType: Mouse, Pen, Touch
	
immutable PointerEvent
	Node target             // The element that triggered the event
	Node currentTarget      // The element to the event handler is attached to
	int pointerId           // A unique identifier for the pointer causing the event (for example, a finger)
	PointerType pointerType // Mouse, Pen, or Touch
	int button              // The mouse button that was pressed to trigger the event
	stopPropagation         // Mark the event as handled and prevent its parent elements from receiving the event
	preventDefault          // Prevent the default action (for example, showing the context menu on a right click)
	int pageX               // The X coordinate of the pointer relative to the whole document
	int pageY               // The Y coordinate of the pointer relative to the whole document
	bool shiftKey           // Is the shift key down?
	bool altKey             // Is the alt key down?
	bool ctrlKey            // Is the control key down?
	bool metaKey            // Is the meta key ("Command" on Mac, "Windows" on Windows) down?
	
	// The position of the pointer relative to the whole document
	inline js Vector2 position() new Vector2(this.pageX/Platform.scale, this.pageY/Platform.scale)

immutable HtmlEvent
	Node target        // The element that triggered the event
	Node currentTarget // The element to the event handler is attached to
	int button         // The mouse button that was pressed to trigger the event
	stopPropagation    // Mark the event as handled and prevent its parent elements from receiving the event
	preventDefault     // Prevent the default action (for example, showing the context menu on a right click)
		
	inline Vector2 relativeTouchPosition() Html.getRelativeMousePosition(this, this.currentTarget)
	inline js Vector2 touchPosition() new Vector2(this.clientX/Platform.scale, this.clientY/Platform.scale)

immutable HtmlKeyboardEvent
	Key keyCode        // A system and implementation dependent numerical code identifying the unmodified pressed key
	Node target        // The element that triggered the event
	Node currentTarget // The element to the event handler is attached to
	stopPropagation    // Mark the event as handled and prevent its parent elements from receiving the event
	preventDefault     // Prevent the default action (for example, showing the context menu on a right click)

skipInit class Image
	string previewSrc
	string src
	string basePath = Platform.basePath
	
	toString := "url({basePath}{src})"
	
skipInit class Font
	string name
	string src
	
Node WebView
	string url
	
	native void(string url) onWillNavigate
	bool hasHandlers
	
	inline js void downloadURL(string url) this.downloadURL(url)
	inline js void goBack() this.goBack()
	
global unit Html
	Unit defaultUnit = pixels
	
	private Node parentNode
	private Node currentNode
	private Node currentOverlay
	
	inline js Vector2 scrollPosition() new Vector2(window.pageXOffset, window.pageYOffset/Platform.scale)
	inline js void scrollTo(float x, float y) window.scrollTo(x,y)
	inline js Node get(string id) document.getElementById(id)
	inline js Node documentBody() document.body
	
	js Node getNodeAt(float x, float y) 
		let node = document.elementFromPoint(x, y)
		while(!node.id && node.parentElement)
			node = node.parentElement
		return node
	
	init
		initHandlers
	
	js void initHandlers
		window.onresize = e => {
			Html.resize();
			Html.refresh();
		}

	internal js void reset
		while(document.body.nextSibling) 
			document.body.nextSibling.remove()
		document.body.innerHTML = ""
		input.clear
	
	internal js void resize
		let body = document.body
		if(Platform.referenceSizes?.length > 0) {
			let screenWidth = localStorage.getItem("isMobile") == "true" ? 0 : screen.width
			Platform.referenceSizes.sort((a,b) => a.forWidthBelow - b.forWidthBelow)
			let referenceWidth = 0
			for(let entry of Platform.referenceSizes) {
				if(screenWidth < entry.forWidthBelow) {
					referenceWidth = entry.referenceWidth
					Platform.isMobile = entry.isMobile
					break;
				}
			}
			Platform.scale = window.innerWidth / referenceWidth
			Platform.nativeSize = new Vector2(window.innerWidth, window.innerHeight)
			Platform.size = new Vector2(referenceWidth, referenceWidth * window.innerHeight/window.innerWidth)
			body.style = "background-color: white; color: black; font:32px OpenSans"
			body.style.transform = 'none !important'
			body.style.marginRight = '0 !important'
			body.style.marginBottom = '0 !important'
			body.style.width = Platform.size.x+"px"
			const width = body.clientWidth
			const height = body.clientHeight
			body.style.transform = `scale(${Platform.scale})`
			body.style.transformOrigin = '0 0'
			const pullUp = height - height * Platform.scale
			const pullLeft = width - width * Platform.scale
			body.style.marginBottom = `${-pullUp}px`
			body.style.marginRight = `${-pullLeft}px`
			body.className = Platform.isMobile ? "mobile" : ""
			body.style.touchAction = "none"
		} else {
			Platform.isMobile = localStorage.getItem("isMobile") == "true"
			Platform.scale = Platform.isDebug ? Platform.debugScale : 1
			body.style.zoom = Platform.scale
			body.style.font = "32px OpenSans"
			body.className = Platform.isMobile ? "mobile" : ""
			body.style.touchAction = "none"
		}
	
	enableScrolling: bool value
		let style = documentBody.style
		if value
			style.overflow = Visible
			style.position = Static
		else
			style.overflow = Hidden
			style.position = Fixed
			style.top = {0}
			style.bottom = {0}

	private js void setDataAttributes: Node node, dynamic attributes
		if(attributes) {
			let shadowAttributes = node.shadowAttributes || (node.shadowAttributes = new Map)
			for(let key in attributes) {
				let value = attributes[key].toString();
				if(shadowAttributes.get(key) != value) {
					node.setAttribute(key, attributes[key]);
					shadowAttributes.set(key, value);
				}
			}
		}
		
	static js Style expandStyle: Style style
		if(style.size) { 
			style.width  = style.size.x+"px"; 
			style.height = style.size.y+"px";
		}
		if(style.overlay) {
			let rect = document.body.getBoundingClientRect()
			style.position = "fixed"; style.top = 0; style.left = 0; style.width = (window.innerWidth/Platform.scale)+"px"; style.height = (document.body.scrollHeight)+"px"  
		}
		return style 

	js async any getUserMedia
		let userMedia = await navigator.mediaDevices.getUserMedia({
			video:{
				facingMode: "environment"
			}
		})
		let log = ""
		let devices = await navigator.mediaDevices.enumerateDevices()
		for(let device of devices) {
			log += device.label + " " + device.deviceId + "\n"
		}
		alert(log)

		return userMedia
	
	private js void setStyle: Node node, dynamic style
		// We shouldn't need this because the same line of code can't output less styles than previously
		// A code change always triggers a complete refresh
		// node.style = ""
		if(style) {
			// Always set style (slowest)
			// for(let key in Html.expandStyle(style))
			// 	node.style[key] = style[key]
				
			// Set style if it changed (slow)
			// for(let key in Html.expandStyle(style)) {
			// 	let value = style[key].toString();
			// 	if(node.style[key] != value) {
			// 		node.style[key] = value
			// 	}
			// }
			
			// Check if style has changed using a shadow copy (fastest)
			let shadowStyle = node.shadowStyle || (node.shadowStyle = new Map)
			for(let key in Html.expandStyle(style)) {
				let value = style[key].toString();
				if(shadowStyle.get(key) != value) {
					node.style[key] = value;
					shadowStyle.set(key, value);
				}
			}
				
			// Temporary Backfill. Starting from Chrome 104, Safari 14.1 this is no longer needed.
			// let translate = style.translate
			// if(translate) node.style.transform += "translate("+translate+") "
			// let rotate = style.rotate
			// if(rotate) node.style.transform += "rotate("+rotate+"turn) "
				
			// if(style.targetTranslate || style.targetSize) {
			// 	setTimeout(() => {
			// 		node.style.transform = "translate("+style.targetTranslate+") "
			// 	}, 1000)
			// }
		} else {
			node.shadowStyle = null
		}
		
	private js Style getStyleToRevert: Style originalStyle, Style onHover
		let styleToRevert = {}
		for(let key in onHover) {
			styleToRevert[key] = originalStyle[key] || "" 
		}
		return styleToRevert
				
	js Vector2 getRelativeMousePosition: HtmlEvent event, Node node
		let rect = node.getBoundingClientRect()
		return new Vector2((event.clientX - rect.left)/Platform.scale, (event.clientY - rect.top)/Platform.scale)

	js void setCursorPosition: Node element, int position
		const range = document.createRange();
		const selection = window.getSelection();
		range.setStart(element.childNodes[0], position);
		range.collapse(true);
		selection.removeAllRanges();
		selection.addRange(range);
	
	int nodesCreated
	int nodesUpdated
	
	global void refresh
		// Time.startTimer
		nodesCreated = nodesUpdated = 0
		parentNode = documentBody
		currentNode = parentNode.firstChild
		currentOverlay = documentBody.nextSibling
		app.draw
		while currentNode
			let next = currentNode.nextSibling
			currentNode.remove
			currentNode = next
		while currentOverlay
			let next = currentOverlay.nextSibling
			currentOverlay.remove
			currentOverlay = next
		focusTabIndex = int.minValue
		// Time.printTimer "refresh: {nodesCreated} created, {nodesUpdated} updated"
		// if not overlayNode
		// 	overlayNode = div style:{position:Fixed top:0 left:0 right:0 bottom:0, backgroundColor:Black, opacity:.5}
		// 	body.parentNode.appendChild overlayNode
		
	script: string src
			dynamic data = {}
		let node = div tag:"script", data
		if !node.src.endsWith(src): node.src = src
		node.onload = refresh
		
	css: string src
		dynamic node = cast div tag:"link"
		node.rel = "stylesheet" 
		if !node.href.endsWith(src): node.href = Platform.basePath + src
		
	style: string text
		return div tag:"style" text
		
	// Lays outs its children in a horizontal row				
	global row: expand Attributes attributes = null // The attributes of the HTML element
		        expand Style style = {}             // The css style of the HTML element
		        void() children = null              // The children of the HTML element
		        SourceCodeLocation location
		style.display = Flex
		style.flexDirection = Row
		return div attributes, style, children, location

	// Lays out its children in a vertical column
	global column: expand Attributes attributes = null // The attributes of the HTML element
		           expand Style style = {}             // The css style of the HTML element
		           void() children = null              // The children of the HTML element
		           SourceCodeLocation location
		style.display = Flex
		style.flexDirection = Column
		return div attributes, style, children, location

	// Lays out its children in a grid
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

	global link: string text = null
		         string href = "#"
		         expand Attributes attributes = {} // The attributes of the HTML element
		         expand Style style = null         // The css style of the HTML element
		         SourceCodeLocation location
		let node = div text, tag:"a", attributes, style, location
		node.href = href
		return node

	global span: string text = null
		         expand Attributes attributes = {} // The attributes of the HTML element
		         expand Style style = null         // The css style of the HTML element
		         SourceCodeLocation location
		return div text, tag:"span", attributes, style, location
		
	global button: string text = null
		           void(HtmlEvent ev) onClick = null // Called when the user clicks the button
		           expand Attributes attributes = {} // The attributes of the HTML element
		           expand Style style = null         // The css style of the HTML element
		           SourceCodeLocation location
		let node = div text, tag:"button", attributes, style, location
		node.onclick = onClick
		return node
		
	global button: string text = null
		           bool(HtmlEvent ev) onClick = null // Called when the user clicks the button
		           expand Attributes attributes = {} // The attributes of the HTML element
		           expand Style style = null         // The css style of the HTML element
		           bool disableAfterClick = false
		           SourceCodeLocation location
		let node = div text, tag:"button", attributes, style, location
		if disableAfterClick
			node.disabled = false
			node.onclick = let success = onClick(.); if not object.isEqualAndSameType(success, false): node.disabled = true
		else
			node.onclick = onClick(.)
		return node
	
	video: string src                        // The file of the video to display 
		   expand Attributes attributes = {} // The attributes of the HTML element 
		   expand Style style = {}           // The css style of the HTML element 
		   SourceCodeLocation location
		style.position = Absolute
		style.zIndex = -1000
		let element = div tag:"video", attributes, style, location, data:{src}
		element.muted = true
		element.autoplay = true
		
	global iframe: string src                        // The url of the content to display
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

	global webview: string initialUrl = ""              // The url of the content to display
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

	global div: string text = null                // The text content of the element 
		        string tag = "div"                // The tag of element
		        expand Attributes attributes = {} // The attributes of the element
		        expand Style style = null         // Apply this css style to the element
		        dynamic data = {}                 // The data attributes of the element
		        Style onHover = null              // Apply this css style to the element when the user moves their mouse over the element
		        void() children = null            // The children of the element
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
		
	// -------------------------------------- Fields with change handlers --------------------------------------
		
	void() currentChangeHandler
	
	global void onChange: stored void() onChange
		                  void() do
		stored void() prevChangeHandler = currentChangeHandler
		currentChangeHandler = onChange
		do
		currentChangeHandler = prevChangeHandler
		
	// ---------- Radio & Toggle ----------
	
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

	// ---------- Input & TextArea ----------
	
	int focusTabIndex = 0
	
	// Automatic Text Input: Updates the model automatically in with every keystroke
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
		
	// Automatic Text Input: Updates the model automatically in with every keystroke
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
		
	// Manual Text Input: If you specify a onChange handler, the model won't be updated automatically
	global inline void field: string model = ""                  // The variable that holds the value. This will be updated when the user changed the text
		                      bool focused = false               // Whether the cursor should be placed in the field
		                      inline void(string value) onChange // If you specify a onChange handler, the model won't be updated automatically
		                      expand Attributes attributes = {}  // The attributes of the HTML element
		                      expand Style style = null          // The css style of the HTML element
		                      bool realtime = true               // Should onChange be called with every keystroke?
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"input", attributes, style, location
		node.value = model or ""
		if realtime: node.oninput = onChange(node.value); changeHandler
		else         node.onchange = onChange(node.value); changeHandler
		if focused or focusTabIndex == attributes.tabIndex: node.focus
			
	fileInput: string accept = "image/*"
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
		
	js Promise<string> getDataUrlForFile: File file
		return new Promise((resolve, reject) => {
			const reader = new FileReader();
			reader.onload = e => resolve(e.target.result);
			reader.readAsDataURL(file);	
		})
	
	// Automatic Editable Text: Updates the model automatically in with every keystroke
	global inline void editableText: string model = ""                          // The variable that holds the value. This will be updated when the user changed the text
		                             inline void(string value) onChanged = null // Called after the model changed
		                             int tabIndex = -1
		                             expand Attributes attributes = {}          // The attributes of the HTML element
		                             expand Style style = null                  // The css style of the HTML element
		                             dynamic data = {}                          // The data attributes of the element
		                             bool realtime = false                      // Should onChange be called with every keystroke?
		                             SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div attributes, style, data, location
		if model != node.innerText: node.innerText = model
		node.contentEditable = "plaintext-only"
		let prevModel = model
		if realtime
			node.oninput = model = node.innerText; onChanged(model); changeHandler
		else         
			node.onblur = model = node.innerText; if model != prevModel: onChanged(model); changeHandler
		if focusTabIndex == tabIndex: delay 100: node.focus

	// Automatic Editable Text: Updates the model automatically in with every keystroke
	global inline void editableText: string model = ""                          // The variable that holds the value. This will be updated when the user changed the text
		                             inline void(string value) onChanged = null // Called after the model changed
		                             inline void() onClick = null
		                             int tabIndex = -1
		                             expand Attributes attributes = {}          // The attributes of the HTML element
		                             expand Style style = null                  // The css style of the HTML element
		                             dynamic data = {}                          // The data attributes of the element
		                             bool realtime = false                      // Should onChange be called with every keystroke?
		                             SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div attributes, style, data, location
		if model != node.innerText: node.innerText = model
		node.onclick = onClick
		node.contentEditable = "plaintext-only"
		let prevModel = model
		if realtime
			node.oninput = model = node.innerText; onChanged(model); changeHandler
		else         
			node.onblur = model = node.innerText; if model != prevModel: onChanged(model); changeHandler
		if focusTabIndex == tabIndex: delay 100: node.focus

	// Automatic Text Area: Updates the model automatically in with every keystroke
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

	// ---------- Canvas ----------
	
	dynamic currentContext
	
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
		
	global drawRectangle: Vector2 pos
		                  Vector2 size
		                  Color color = Black
		currentContext.fillStyle = color.hex
		currentContext.fillRect(pos.x, pos.y, size.x, size.y)
		
	global drawText: implicit string text
		             Vector2 pos
		             float size = 30
		             Font font = null
		             Color color = Black
		currentContext.fillStyle = color.hex
		string effectiveFont = font ? font.name : "Open Sans"
		currentContext.font = "{size}px {effectiveFont}"
		currentContext.fillText(text, pos.x, pos.y)
	

