CompilerSettings
	serializeInternal = false
	serializeExternal = false
	sourceCodeLocation = true
	clone = true
	
class ReferenceSize
	float referenceWidth = 1920
	float forWidthBelow = float.maxValue
	bool isMobile = false
	
enum TickMode: Interval, AnimationFrame
	
skipInit global unit Platform
	public ticksPerSecond = 0
	public TickMode tickMode = Interval
	public resetWhenCodeChanged = true
		
	Vector2 size, nativeSize
	float scale
	float debugScale = 1
	ReferenceSize[] referenceSizes
	
	// Environment
	bool isDebug
	global bool isMobile
	bool electron
	
	// Location
	public inline js string url := location.href
	public inline js string host := location.host
	public inline js string locationHash := location.hash
	public inline js string basePath := _basePath
	public inline js string protocolAndHost() (location.host && !Platform.isDebug ? location.origin : "http://localhost")
	public inline js string referrer := document.referrer
	public inline js dynamic networkInformation() navigator.connection
	public inline js void reload() location.reload(/*forceReload=*/true)
	public inline js int buildVersion() _buildVersion

	// Encode
	public inline js string encodeURIComponent(string value) encodeURIComponent(value)
	public inline js string decodeURIComponent(string value) decodeURIComponent(value)

	private inline js void initMedia
		this.electron = window?.process?.versions?.electron
		audio.init();
		media.init();
		PlainDate.init();
		html.init();
		app.init?.()
		
	private async inline js void initBackend
		if(typeof(backend) != "undefined") {
			await backend.connect2()
			backend.onDataChange = () => html.refresh()
		}

	inline js float startTime := _startTime
			
	async start: bool isDebug
		try
			print Time.preciseTime - startTime
			Time.startTimer
			this.nextHeartbeatTime = 0
			heartbeat "start"
			
			this.isDebug = isDebug
			this.referenceSizes = [
				{1920}
				{960 forWidthBelow:600 isMobile:true}
			]
			this.ticksPerSecond = 0
			this.tickMode = Interval
			this.resetWhenCodeChanged = true
			
			initMedia
			Time.printTimer "initMedia"
			initBackend
			Time.printTimer "initBackend"
			openMedia
				Time.printTimer "openMedia"
				try
					stop
					// We need to call resize again after the first refresh to prevent unwanted scrolling
					html.resize
					Time.printTimer "resize"
					startTickInterval
				catch 
					sendErrorToEditor .
				finally
					sendFinished
		catch 
			sendErrorToEditor .
			sendFinished
		
	js void openMedia: void() success
		let font = new FontFace('OpenSans', `url(${_basePath}OpenSans.woff2)`);
		await font.load();
		document.fonts.add(font);
		success()
		
	js void initAll
		if(window.reset_state != undefined) reset_state()
		init()
		
	async replay
		try
			heartbeat "replay"
			if resetWhenCodeChanged: html.reset
			initMedia
			initBackend
			initAll
			html.resize
			startApp
			refresh
		catch
			sendErrorToEditor .
		finally
			sendFinished

	inline js void resetStateIndex
		if(window.reset_state_index != undefined) reset_state_index()
		
	stop
		html.reset
		replay
		
	private js void startApp
		if(app.start) app.start()
		
	private js void tick
		Platform.heartbeat("tick")
		if(app.tick) app.tick()
		Time.frame++
		
	private js void startTickInterval
		if(window._tickInterval) {
			clearInterval(_tickInterval)
		}
		if(Platform.ticksPerSecond) {
			if(Platform.tickMode == 0) {
				_tickInterval = setInterval(() => Platform.tick(), 1000/Platform.ticksPerSecond)
			} else {
				window.tick = function() {
					Platform.tick();
					window.requestAnimationFrame(window.tick);
				}
				window.tick();
			}
		}
		
	internal inline js void sendErrorToEditor: Error error
		if(window._sendErrorToEditor) _sendErrorToEditor(error)
		else                          console.error(error)
		
	private inline js void sendFinished
		console.log("[app] ----- Finished -----")
		if(Platform.isDebug) _sendToEditor({type:"finished"})
			
	float nextHeartbeatTime = 0
	
	private js void heartbeat: string context
		if(!Platform.isDebug) return
		let now = Date.now();
		if(now > Platform.nextHeartbeatTime) {
			Platform.nextHeartbeatTime = now + 3000;
			_sendStringToEditor("~");
		}
		
	js string generateObjectId
		const timestamp = Math.floor(new Date().getTime() / 1000).toString(16);
		const machineIdentifier = Math.floor(Math.random() * 0xFFFFFF).toString(16).padStart(6, '0');
		const processIdentifier = Math.floor(Math.random() * 0xFFFF).toString(16).padStart(4, '0');
		const counter = Math.floor(Math.random() * 0xFFFFFF).toString(16).padStart(6, '0');
		return (timestamp + machineIdentifier + processIdentifier + counter).toLowerCase();
		
	toggleSmallScreen
		isMobile = !isMobile;
		setLocalStorageString("isMobile", isMobile ? "true" : "false")
		html.resize
		refresh

	inline js void setLocalStorageString: string key, string value
		localStorage.setItem(key, value)
		
	inline js string getLocalStorageString: string key
		(localStorage.getItem(key) || "")
		
	inline js void setLocalStorageObject: string key, dynamic value
		localStorage.setItem(key, JSON.stringify(value))
		
	js dynamic getLocalStorageObject: string key
		                              dynamic defaultValue = null
		let str = localStorage.getItem(key)
		return str ? JSON.parse(str) : defaultValue

	js void removeLocalStorageItem: string key
		localStorage.removeItem(key)
			
	inline js void openLink: string url
		window.open(url)
		
	inline js void redirect: string url
		location.href = url
		
	inline js void copyToClipboard: string text
		navigator.clipboard.writeText(text)
		
	global inline js int delay: float time // The delay in milliseconds
		                        void() do
		setTimeout(do, time)
		
	global inline js async void delay: float time // The delay in milliseconds
		new Promise(resolve => setTimeout(resolve, time))
		
	global inline js int clearDelay: int handle
		clearTimeout(handle)
		
	inline js void onBlur: void() do
		window.onblur = do
		
	inline js void onFocus: void() do
		window.onfocus = do
		
	global inline js int interval: float time // The interval in milliseconds
		                           void() do
		setInterval(do, time)
		
	global inline js int clearInterval: int handle
		clearInterval(handle)
		
	js object stack
		try { _ }
		catch(e) { return e.stack.split("\n").slice(2).join("\n") }
		
	global inline js void debugger() debugger
	
	inline js void pushState: string url
		                      object state = null
		history.pushState(state, "", url);
		
	inline js void replaceState: string url
		                         object state = null
		history.replaceState(state, "", url);
		
	global js void onPopState: void() do
		window.onpopstate = $do
		
	global js void onPaste: void(DateTransfer data) do
		document.onpaste = e => do(e.clipboardData)
		
	inline js void blur() document.activeElement.blur()
	
	js void setMenu: MenuItem[] menuTemplate
		if(!Platform.electron || !document.hasFocus()) return;
		const remote = require('@electron/remote');
		if (process.platform == 'darwin') {
			menuTemplate.unshift({
				label: "",
				submenu: [
					{role: 'about'},
					{type: 'separator'},
					{role: 'hide'},
					{role: 'hideothers'},
					{role: 'unhide'},
					{type: 'separator'},
					{role: 'quit'},
				]
			})
			let menu = remote.Menu.buildFromTemplate(menuTemplate)
			remote.Menu.setApplicationMenu(menu)
		} else {
			let menu = remote.Menu.buildFromTemplate(menuTemplate)
			remote.getCurrentWindow().setMenu(menu)
		}
		
	js async Vector2 getCurrentLocation: enableHighAccuracy = true
		                                 maximumAge = 5000
		                                 timeout = 3000
		return new Promise((resolve, reject) => {
			navigator.geolocation.getCurrentPosition(pos => {
				resolve(new Vector2(pos.coords.longitude, pos.coords.latitude, "geo"))
			}, error => {
				reject(error)
			}, {maximumAge, timeout, enableHighAccuracy})
		})
		
	js async void onDeviceOrientation: void(Angle angle) do
		                               void(string error) else = null
		if(window.ondeviceorientationabsolute !== undefined) {
			window.ondeviceorientationabsolute = e => {
				do(new Angle(e.alpha, "deg"));
			}
		} else {
			try {
				window.ondeviceorientation = e => {
					do(new Angle(e.alpha, "deg"));
				}
			} catch(e) {
				let response = await DeviceOrientationEvent.requestPermission();
				if (response == "granted") {
				} else {
					else?.(response);
				}
				else?.(e.message);
			}
		}
		
	js void onCurrentLocation: void(Vector2 location, Angle heading) do
		                       void(string error) else = null
		                       enableHighAccuracy = true
		                       maximumAge = 5000
		                       timeout = 5000
		try {
			navigator.geolocation.watchPosition(pos => {
				do(new Vector2(pos.coords.longitude, pos.coords.latitude, "geo"), new Angle(pos.coords.heading, "deg"))
			}, e => {
				do(new Vector2(Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY, "geo"), new Angle(float.null, "deg"))
				else?.(e.message)
			}, {maximumAge, timeout, enableHighAccuracy})
		} catch(e) {
			else?.(e.message)
		}
		
enum lowercase string DataTransferItemKind: String, File
		
interface DataTransferItem
	DataTransferItemKind kind // The kind of drag item, string or file
	string type               // The data item's type, typically a MIME type
	
	inline js async string getAsString
		new Promise(resolve => this.getAsString(a => resolve(a)))
		
	inline js File getAsFile
		this.getAsFile()
		
interface DateTransfer
	DataTransferItem[] items
	
	
MenuItem
	string label
	string accelerator
	native void() click
	string type = null
	string role = null
	MenuItem[] submenu = null
	bool checked
	
global transient unit System
	// Prints a message to the console
	global js void print: logstring text // The text, variables or expressions to print
		                  SourceCodeLocation location
		console.log(text)
		if(Platform.isDebug) {
			var stringValue = typeof text === "string" ? text : JSON.stringify(text);
			if(stringValue) _sendToEditor({type:"log", value:stringValue, location:location?.start, file:location?.file});
		}
	
global skipInit unit math
	// Generates a random integer
	global js int randomInteger: int min // The inclusive lower bound of the random integer
		                         int max // The exclusive upper bound of the random integer
		return min + Math.floor(Math.random() * (max-min))
	
	global js int randomInteger: int max = 2147483647 // The exclusive upper bound of the random integer
		return Math.floor(Math.random() * max)
	
	// Generates a random float
	global inline js int randomFloat
		Math.random()

// A color comprised of a red, green, blue and alpha component
class Color
	global const Color white       = {"#ffffff", "White"}
	global const Color black       = {"#000000", "Black"}
	global const Color red         = {"#ef476f", "Red"}
	global const Color yellow      = {"#ffd166", "Yellow"}
	global const Color green       = {"#06d6a0", "Green"}
	global const Color blue        = {"#118ab2", "Blue"}
	global const Color gray        = {"#3d3d3d", "Gray"}
	global const Color transparent = {"#00000000", "Transparent"}
		
	const Color transparentRed     = {"#ff000080", "Transparent Red"}
	
	string colorString
	string name
	
	string toString := colorString
	
	Color: string colorString = ""
		let firstChar = colorString[0]
		if ("0" <= firstChar <= "9") or ("a" <= firstChar <= "f") or ("A" <= firstChar <= "F")
			colorString = "#" + colorString
		this.colorString = colorString

	Color: int red = 0
		   int green = 0
		   int blue = 0
		   int alpha = 255
		this.colorString = "#" + componentToHex(red) + componentToHex(green) + componentToHex(blue) + componentToHex(alpha)
			
	// Creates a color from an hue and a saturation and lightness percentage
	// Example:
	//     const primaryColor = Color.hsl(34, 95%, 55%)
	static Color hsl: float hue            // A value between 0 and 360, e.g. 34
		              Dimension saturation // A value between 0 and 100 followed by a "%" sign, e.g. 50%
		              Dimension lightness  // A value between 0 and 100 followed by a "%" sign, e.g. 50%
		return new Color(colorString:"hsl(" + hue.toString + ", " + saturation.toString + ", " + lightness.toString + ")")

	// Creates a color from an hue and a saturation and lightness percentage and an alpha value
	// Example:
	//     const primaryColor = Color.hsla(34, 95%, 55%, 0.5)
	static Color hsla: float hue            // A value between 0 and 360, e.g. 34
		               Dimension saturation // A value between 0 and 100 followed by a "%" sign, e.g. 50%
		               Dimension lightness  // A value between 0 and 100 followed by a "%" sign, e.g. 50%
		               float alpha          // A value between 0 and 1, e.g. 0.5 (0: fully transparent, 1: fully opaque)
		return new Color(colorString:"hsla(" + hue.toString + ", " + saturation.toString + ", " + lightness.toString + ", " + alpha.toString + ")")

	static js string componentToHex: int c
		var hex = c.toString(16);
		return hex.length == 1 ? "0" + hex : hex;
		
	inline js bool == Color other: this?.colorString == other?.colorString
	inline js bool != Color other: this?.colorString != other?.colorString
	
	Color withAlpha: float alpha
		return {colorString[1..7]+componentToHex(math.floor(alpha*255))}

immutable class string
	implicit Color toColor() return Color(this)
