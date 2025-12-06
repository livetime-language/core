js HTMLElement
class HTMLElement
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
	int rows
	string placeholder
	InputType type
	bool readOnly
	string src
	dynamic srcObject
	HTMLElement firstChild
	HTMLElement nextSibling
	HTMLElement parentNode
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
	
	HTMLElement[string] childrenByKey
	bool used
		
	inline js HTMLElement remove() this.remove()
	inline js void appendChild(HTMLElement element) this.appendChild(element)
	inline js void insertBefore(HTMLElement newNode, HTMLElement referenceNode) this.insertBefore(newNode, referenceNode)
	inline js void setSelectionRange(int from, int to) this.setSelectionRange(from, to)
	inline js void select() this.select()
	inline js void setCursorPosition(int index) html.setCursorPosition(this, index)
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

	native void(FocusEvent ev) onblur
	native void(FocusEvent ev) onfocus
	
	inline js void set(string name, string value) this.setAttribute(name, value)
	inline js void get(string name) this.getAttribute(name)
	
	static inline js HTMLElement create(string tagName = "div") document.createElement(tagName);
	inline js void click() this.click()
	
	inline js void animate: Style from
		                    Style to
		                    float duration = 1 seconds
		                    AnimationFill fill = forwards
		                    easing = "linear"
		this.animate([html.expandStyle(from), html.expandStyle(to)], {@duration:duration, @fill:fill, @easing:easing})
		
	Touch[] touches
	
	onTouchDown: void(Touch touch, Touch[] touches, HTMLElement element, PointerEvent event) do
		this.onpointerdown = {
			if this.touches == null: this.touches = []
			TouchType type
			if ev.pointerType == Mouse: type = cast ev.button.clamp(0 to 2); else
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
	
	onTouchMove: void(Touch touch, Touch[] touches, HTMLElement element, PointerEvent event) do
		this.onpointermove = {
			if this.touches == null: this.touches = []
			Touch touch = this.touches.find.id == ev.pointerId
			if touch
				touch.phase = Move
				touch.position.x = ev.pageX/Platform.scale
				touch.position.y = ev.pageY/Platform.scale
				do(touch, touches, this, ev)
		}
	
	onTouchUp: void(Touch touch, Touch[] touches, HTMLElement element, PointerEvent event) do
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
				HTMLElement touchedNode = html.getElementAt(ev.pageX, ev.pageY)
				touch.touchedId = touchedNode ? touchedNode.id : ""
				this.touches.removeAt(index)
				do(touch, touches, this, ev)
		}
		
	onTouchCancel: void(Touch touch, Touch[] touches, HTMLElement element, PointerEvent event) do
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

interface FocusEvent
	HTMLElement target        // The element that triggered the event
	HTMLElement currentTarget // The element to the event handler is attached to
	HTMLElement relatedTarget // The element that the focus moved to

importance:5 dynamic Attributes
	string id    // A unique string to indentify a specic element, often used to style a single element
	string class // A string to assign a class to one or more elements, often used to style several elements
	string key   // A unique identifier used to find the html element that should be reused
	string title
	
	native void() onClick = null                       // Execute this code when the user releases the left mouse button on the HTML element
	native void(HtmlEvent ev) onRightClick = null      // Execute this code when the user releases the right mouse button on the HTML element
	
	native void(PointerEvent ev) onPointerDown = null  // Execute this code when the user presses down the left mouse button on the HTML element
	native void(PointerEvent ev) onPointerOver = null  // Execute this code when the pointer hovers over the element
	native void(PointerEvent ev) onPointerOut = null   // Execute this code when the pointer stops hovering over the element
	
	native void(HtmlKeyboardEvent ev) onKeyDown = null // Execute this code when the user presses a key on the keyboard
	native void(HtmlKeyboardEvent ev) onKeyUp = null   // Execute this code when the user releases a key on the keyboard
	
	native void(FocusEvent ev) onBlur = null           // Execute this code when the element loses focus
	native void(FocusEvent ev) onFocus = null          // Execute this code when the element gains focus

	int tabIndex = 0

enum lowercase string PointerType: Mouse, Pen, Touch
	
immutable HtmlEvent PointerEvent
	HTMLElement target        // The element that triggered the event
	HTMLElement currentTarget // The element to the event handler is attached to
	int pointerId             // A unique identifier for the pointer causing the event (for example, a finger)
	PointerType pointerType   // Mouse, Pen, or Touch
	int button                // The mouse button that was pressed to trigger the event
	stopPropagation           // Mark the event as handled and prevent its parent elements from receiving the event
	preventDefault            // Prevent the default action (for example, showing the context menu on a right click)
	int pageX                 // The X coordinate of the pointer relative to the whole document
	int pageY                 // The Y coordinate of the pointer relative to the whole document
	bool shiftKey             // Is the shift key down?
	bool altKey               // Is the alt key down?
	bool ctrlKey              // Is the control key down?
	bool metaKey              // Is the meta key ("Command" on Mac, "Windows" on Windows) down?
	
	// The position of the pointer relative to the whole document
	inline js Vector2 position() new Vector2(this.pageX/Platform.scale, this.pageY/Platform.scale)

immutable HtmlEvent
	HTMLElement target        // The element that triggered the event
	HTMLElement currentTarget // The element to the event handler is attached to
	int button                // The mouse button that was pressed to trigger the event
	stopPropagation           // Mark the event as handled and prevent its parent elements from receiving the event
	preventDefault            // Prevent the default action (for example, showing the context menu on a right click)
		
	inline Vector2 relativeTouchPosition() html.getRelativeMousePosition(this, this.currentTarget)
	inline js Vector2 touchPosition() new Vector2(this.clientX/Platform.scale, this.clientY/Platform.scale)

immutable HtmlKeyboardEvent
	Key keyCode               // A system and implementation dependent numerical code identifying the unmodified pressed key
	HTMLElement target        // The element that triggered the event
	HTMLElement currentTarget // The element to the event handler is attached to
	stopPropagation           // Mark the event as handled and prevent its parent elements from receiving the event
	preventDefault            // Prevent the default action (for example, showing the context menu on a right click)

skipInit class Image
	string previewSrc
	string src
	string basePath = Platform.basePath
	
	toString := "url({basePath}{src})"
	
skipInit class Font
	string name
	string src
	
HTMLElement WebView
	string url
	
	native void(string url) onWillNavigate
	bool hasHandlers
	
	inline js void downloadURL(string url) this.downloadURL(url)
	inline js void goBack() this.goBack()

struct float
	inline Dimension toDimension
		Dimension(this, html.defaultUnit)
		
	// Pixels
	inline Dimension px
		Dimension(this, pixels)
		
	// Makes the value relative to its parent's value
	inline Dimension %
		Dimension(this, percent)
		
	// A fraction of the available space
	inline Dimension fr
		Dimension(this, fraction)
		
	// Font size of the parent (for font-size), font size of the element itself (for other properties)
	inline Dimension em
		Dimension(this, em)
		
	// Font size of the root element
	inline Dimension rem
		Dimension(this, rem)
		
	// Percentage of the viewport's width
	inline Dimension vw
		Dimension(this, viewportWidth)
		
	// Percentage of the viewport's height
	inline Dimension vh
		Dimension(this, viewportHeigh)
		
	// Percentage of the small viewport's width (without the address bar on mobile)
	inline Dimension svw
		Dimension(this, smallViewportWidth)
		
	// Percentage of the small viewport's height (without the address bar on mobile)
	inline Dimension svh
		Dimension(this, smallViewportHeight)
		
immutable priority low struct float
	inline Dimension toAngle() Angle(this, radians)

	inline Angle ° := Angle(this, degrees)
	
	// Turns: One full rotation is 1
	inline Angle turn := Angle(this, turns)
	
	// Radians: One full rotation is 2π (about 6.2832)
	inline Angle rad := Angle(this, radians)
		
	// Degrees: One full rotation is 360
	inline Angle deg := Angle(this, degrees)
		
	// Gradians: One full rotation is 400
	inline Angle grad := Angle(this, gradians)
		
global skipInit unit math
	// Returns the arctangent of the quotient of the given values
	Angle getAngleForVector: Vector2 vector
		return Angle(math.atan2(vector.y, vector.x), radians)
		
	Vector2 getVectorForAngle: Angle angle      // The angle in radians (-pi/2: left, 0: up, pi/2: right, pi: down)
		                       float radius = 1.0
		return new Vector2(math.sin(angle.value)*radius, -math.cos(angle.value)*radius)

struct Angle
	float value         // The value in the specified unit
	Unit unit = radians // The unit of the value (turn, degrees, gradians, or radians)
	
	float toFloat()   return this.value
	string toString() return "{this.value}{this.unit}"
	
	// Returns true if the angle is not zero
	inline js bool toBool := this.value
	
	Angle assign Angle other: value = other.value; unit = other.unit; return this
	Angle assign float other: value = other; return this

	Angle + Angle other:   return {value + other.value, unit}
	Angle - Angle other:   return {value - other.value, unit}
	Angle * Angle other:   return {value * other.value, unit}
	Angle / Angle other:   return {value / other.value, unit}
	
	Angle + float other:   return {value + other, unit}
	Angle - float other:   return {value - other, unit}
	Angle * float other:   return {value * other, unit}
	Angle / float other:   return {value / other, unit}

	Angle += Angle other:  value += other.value; return this
	Angle -= Angle other:  value -= other.value; return this
		
	Angle += float other:  value += other; return this
	Angle -= float other:  value -= other; return this
		
	bool >  Angle other:   return value >  other.value
	bool >= Angle other:   return value >= other.value
	bool <  Angle other:   return value <  other.value
	bool <= Angle other:   return value <= other.value
	
	Angle operator - (Angle a) Angle(-a.value, a.unit)

// In LiveTime, the term "time" always means the number of milliseconds since 1 January 1970
static class Time
	// The number of milliseconds elapsed since 1 January 1970
	importance:5 static inline js float now() Date.now()
	
global priority low skipInit static class html
	Overflow overflow = scroll
	Unit defaultUnit = pixels
	private HTMLElement parentNode
	private HTMLElement currentNode
	private HTMLElement currentOverlay

	// Call refresh to re-render the html after you changed any data.
	// Example:
	//     app
	//     	   int counter = 0
	//         draw
	//             button "You clicked this button {counter} times", onClick:counter++; refresh
	global void refresh
		Platform.resetStateIndex
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
		// if not overlayNode
		// 	overlayNode = div style:{position:Fixed top:0 left:0 right:0 bottom:0, backgroundColor:Black, opacity:.5}
		// 	body.parentNode.appendChild overlayNode
		
	inline js Vector2 scrollPosition() new Vector2(window.pageXOffset, window.pageYOffset/Platform.scale)
	inline js void scrollToTop() window.scrollTo(0,0)
	inline js void scrollTo(float x = 0, float y = 0) window.scrollTo(x,y)
	inline js HTMLElement get(string id) document.getElementById(id)
	inline js HTMLElement documentBody() document.body
	inline js HTMLElement activeElement() document.activeElement
	
	js HTMLElement getElementAt(float x, float y) 
		let element = document.elementFromPoint(x, y)
		while(!element.id && element.parentElement)
			element = element.parentElement
		return element
	
	init
		initHandlers
		initGlobalEventHandlers
	
	private js void initHandlers
		window.onresize = e => {
			html.resize();
			html.refresh();
		}

	internal js void reset
		while(document.body.nextSibling) 
			document.body.nextSibling.remove();
		document.body.innerHTML = "";
		html.clearGlobalEventHandlers();
	
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
		} else {
			Platform.isMobile = localStorage.getItem("isMobile") == "true"
			Platform.scale = Platform.isDebug ? Platform.debugScale : 1
			body.style.zoom = Platform.scale
		}
		body.style = "background-color: white; color: black; font:12px OpenSans"
		body.className = Platform.isMobile ? "mobile" : ""
		body.style.touchAction = "none"
		body.style.overflow = html.overflow
	
	enableScrolling: bool value
		let style = documentBody.style
		if value
			style.overflow = visible
			style.position = static
		else
			style.overflow = hidden
			style.position = fixed
			style.top = {0}
			style.bottom = {0}

	private js void setDataAttributes: HTMLElement element, dynamic attributes
		if(attributes) {
			let shadowAttributes = element.shadowAttributes || (element.shadowAttributes = new Map)
			for(let key in attributes) {
				let value = attributes[key].toString();
				if(shadowAttributes.get(key) != value) {
					element.setAttribute(key, attributes[key]);
					shadowAttributes.set(key, value);
				}
			}
		}
		
	static private js Style expandStyle: Style style
		if(style.size) { 
			style.width  = style.size.x+"px"; 
			style.height = style.size.y+"px";
		}
		if(style.overlay) {
			let rect = document.body.getBoundingClientRect()
			style.position = "fixed"; style.top = 0; style.left = 0; style.width = (window.innerWidth/Platform.scale)+"px"; style.height = (document.body.scrollHeight)+"px"  
		}
		return style 

	js async dynamic getUserMedia
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
	
	private js void setStyle: HTMLElement element, dynamic style
		// We shouldn't need this because the same line of code can't output less styles than previously
		// A code change always triggers a complete refresh
		// element.style = ""
		if(style) {
			// Always set style (slowest)
			// for(let key in html.expandStyle(style))
			// 	element.style[key] = style[key]
				
			// Set style if it changed (slow)
			// for(let key in html.expandStyle(style)) {
			// 	let value = style[key].toString();
			// 	if(element.style[key] != value) {
			// 		element.style[key] = value
			// 	}
			// }
			
			// Check if style has changed using a shadow copy (fastest)
			let shadowStyle = element.shadowStyle || (element.shadowStyle = new Map)
			for(let key in html.expandStyle(style)) {
				let value = style[key].toString();
				if(shadowStyle.get(key) != value) {
					element.style[key] = value;
					shadowStyle.set(key, value);
				}
			}
				
			// Temporary Backfill. Starting from Chrome 104, Safari 14.1 this is no longer needed.
			// let translate = style.translate
			// if(translate) element.style.transform += "translate("+translate+") "
			// let rotate = style.rotate
			// if(rotate) element.style.transform += "rotate("+rotate+"turn) "
				
			// if(style.targetTranslate || style.targetSize) {
			// 	setTimeout(() => {
			// 		element.style.transform = "translate("+style.targetTranslate+") "
			// 	}, 1000)
			// }
		} else {
			element.shadowStyle = null
		}
		
	private js Style getStyleToRevert: Style originalStyle, Style onHover
		let styleToRevert = {}
		for(let key in onHover) {
			styleToRevert[key] = originalStyle[key] || "" 
		}
		return styleToRevert
				
	js Vector2 getRelativeMousePosition: HtmlEvent event, HTMLElement element
		let rect = element.getBoundingClientRect()
		return new Vector2((event.clientX - rect.left)/Platform.scale, (event.clientY - rect.top)/Platform.scale)

	js void setCursorPosition: HTMLElement element, int position
		const range = document.createRange();
		const selection = window.getSelection();
		range.setStart(element.childNodes[0], position);
		range.collapse(true);
		selection.removeAllRanges();
		selection.addRange(range);
	
	int nodesCreated
	int nodesUpdated
	void() currentChangeHandler
	
	global void onChange: stored void() onChange
		                  void() do
		stored void() prevChangeHandler = currentChangeHandler
		currentChangeHandler = onChange
		do
		currentChangeHandler = prevChangeHandler