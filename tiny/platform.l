CompilerSettings
	logSerialize = false
	serializeInternal = false
	serializeExternal = false

enum TickMode: Interval, AnimationFrame

transient skipInit unit Platform
	public ticksPerSecond = 0
	public TickMode tickMode = Interval
	bool isDebug
	bool fastForward
	int userCount

	// This is called when the application starts for the first time	
	private start: bool isDebug
		this.isDebug = isDebug
		this.ticksPerSecond = 30
		this.tickMode = Interval
		this.fastForward = false
		this.userCount = 1

		math.setRandomSeed math.generateRandomSeed 
		Time.ticks = 0
		graphics.setup
		initAll
		for userCount input.internalUsers.add {}
		app??.start()
		startInterval
				
	// This is called after every code change to replay all inputs with the new code
	private async replay: bool updateMedia
		Time.ticks = 0
		initAll
		app??.start()
			
	dynamic interval
	private js void startInterval
		if(Platform.interval) clearInterval(Platform.interval)
		if(window.tick) return
			
		if(Platform.tickMode == 0) {
			Platform.interval = setInterval(() => Platform.tick(), 1000/Platform.ticksPerSecond)
		} else {
			window.tick = function() {
				Platform.tick();
				window.requestAnimationFrame(window.tick);
			}
			window.tick();
		}
	
	// This is called every animation frame
	private tick
		Time.startFrame
		graphics.startFrame
		input.updateGamepads
		app??.tick()
		graphics.finishFrame
		input.internalUsers.each.finishFrame
		Time.ticks++
					
	js void initAll
		init();
		if(typeof _initJavaScriptApp === "function") {
			try {
				app = {
					tick: _initJavaScriptApp(),
					start: () => {}
				}
			} catch (error) {
				console.error("Error initializing JavaScript app:", error);
			}
		}
	
	internal home
	internal clearHomeAndGoToEnd
	internal goToFrame: int targetFrame, int interrruptAtOutputIndex, bool saveHome = false
	internal stop
	internal pause
	internal record
	internal play
	internal togglePlay

	inline js void sendToEditor: dynamic message
		if(Platform.isDebug) _sendToEditor(message)
		
	internal inline js void sendStringToEditor: string message
		if(Platform.isDebug) _sendStringToEditor(message)

// In LiveTime, the term "time" always means the number of milliseconds since 1 January 1970
skipInit static class Time
	// The number of milliseconds elapsed since 1 January 1970
	static importance:5 float now
	
	// The total amount of ticks passed since the app started (by default, there are 30 ticks per second)
	static importance:5 int ticks

	js void startFrame
		now = Date.now()

global transient unit System
	// Prints a message to the console
	global js void print: logstring text	// The text, variables or expressions to print
	                      PrintType type = Info	// Action: Action performed by a player, Reaction: Consequence of an action, Debug: Temporary debug information, Info: Information, Error: Error, Warning: Warning
		                  SourceCodeLocation location
		console.log(text)
		if(Platform.isDebug && location) {
			_sendStringToEditor(`${type}|${text}|${location.file}|${location.start}|`)
		}