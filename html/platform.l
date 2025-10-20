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
	public targetFps = 0
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
	
	// Info
	public inline js string url := location.href
	public inline js string host := location.host
	public inline js string basePath := _basePath
	public inline js string protocolAndHost() (location.host && !Platform.isDebug ? location.origin : "http://localhost")
	public inline js string referrer := document.referrer
	public inline js string encodeURIComponent(string value) encodeURIComponent(value)
	public inline js string decodeURIComponent(string value) decodeURIComponent(value)
	public inline js dynamic networkInformation() navigator.connection

	private inline js void initMedia
		this.electron = window?.process?.versions?.electron
		$Image.init?.();
		Font.init?.();
		Sound.init?.();
		audio.init();
		DateTime.localTimezoneOffset = new Date().getTimezoneOffset() * 60000
		app.init?.()
		
	private async inline js void initDatabase
		if(typeof(pocketBase) != "undefined") await pocketBase.connect2()
			
	async start: bool isDebug
		try
			this.nextHeartbeatTime = 0
			heartbeat "start"
			
			this.isDebug = isDebug
			this.referenceSizes = [
				{1920}
				{960 forWidthBelow:600 isMobile:true}
			]
			this.targetFps = 0
			this.tickMode = Interval
			this.resetWhenCodeChanged = true
			
			initMedia
			initDatabase
			openMedia
				try
					stop
					// We need to call resize again after the first refresh to prevent unwanted scrolling
					html.resize
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
		if(window._reset_state != undefined) _reset_state()
		init()
		
	async replay
		try
			heartbeat "replay"
			if resetWhenCodeChanged: html.reset
			initMedia
			initDatabase
			initAll
			html.resize
			startApp
			refresh
		catch
			sendErrorToEditor .
		finally
			sendFinished

	inline js void resetStateIndex
		if(window._reset_state_index != undefined) _reset_state_index()
		
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
		if(Platform.targetFps) {
			if(Platform.tickMode == 0) {
				_tickInterval = setInterval(() => Platform.tick(), 1000/Platform.targetFps)
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
		
	inline js void setLocalStorageObject: string key, any value
		localStorage.setItem(key, JSON.stringify(value))
		
	js any getLocalStorageObject: string key
		                          any defaultValue = null
		let str = localStorage.getItem(key)
		return str ? JSON.parse(str) : defaultValue
		
	// Shows a dialog box with a given message
	inline js void alert: implicit string message // The message to show
		alert(message)
	
	inline js void openLink: string url
		window.open(url)
		
	inline js void redirect: string url
		location.href = url
		
	inline js void pushState: string url
		                      object state = null
		history.pushState(state, "", url);
		
	inline js void replaceState: string url
		                         object state = null
		history.replaceState(state, "", url);
		
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
		try      { _ }
		catch(e) { return e.stack }
		
	inline js void debugger() debugger
	
	global js void onNavigate: void(string url) do
		window.onpopstate = e => do(location.pathname)
		
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
			window.ondeviceorientationabsolute = e => do(new Angle(1 - (e.alpha || 0)/360, "turn"));
		} else {
			try {
				let response = await DeviceOrientationEvent.requestPermission();
				if (response == "granted") {
					window.ondeviceorientation = e => do(new Angle(1 - (e.webkitCompassHeading || e.alpha || 0)/360, "turn"));
				} else {
					else?.(response);
				}
			} catch(e) {
				else?.(e.message);
			}
		}
		
	js void onCurrentLocation: void(Vector2 location) do
		                       void(string error) else = null
		                       enableHighAccuracy = true
		                       maximumAge = 5000
		                       timeout = 5000
		navigator.geolocation.watchPosition(pos => {
			do(new Vector2(pos.coords.longitude, pos.coords.latitude, "geo"))
		}, e => {
			do(new Vector2(Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY, "geo"))
			else?.(e.message)
		}, {maximumAge, timeout, enableHighAccuracy})
		
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
			
	global static Color hsl: float hue
		                            float saturation
		                            float lightness
		return new Color(colorString:"hsl(" + hue + ", " + saturation + "%, " + lightness + "%)")

	static js string componentToHex: int c
		var hex = c.toString(16);
		return hex.length == 1 ? "0" + hex : hex;
		
	inline js bool == Color other: this?.colorString == other?.colorString
	inline js bool != Color other: this?.colorString != other?.colorString
	
	Color withAlpha: float alpha
		return {colorString[1..7]+componentToHex(math.floor(alpha*255))}

immutable class string
	implicit Color toColor() return Color(this)
