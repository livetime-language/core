// The internal state of a user that isn't serialized and shoudn't be accessed by the app
internal transient class InternalUser
	int id              // This id stays the same when a user reconnects
	bool local          // Is this the local user?
	int connectionId    // The connectionId increases with every connection, even if the same user reconnects
	int index
	string _id          // User account id
	string name         // User account name
	
	// Event Stream
	bool collectInputs          // When we are done pinging, we add a join event and start collecting inputs
	int inputFrame = -1         // We received all inputs from this player up to and including this frame (their claim)
	int receivedMyInputsUpToPos // We received all inputs from this player up to this pos
	int[] lastTouchMoveIndex
	Buffer inputs = {}          // The stream of inputs of this user
	int storedInputsUpTo        // This user's stream is persisted to IndexedDB up to this pos (see core.storeInputsToDB)
	int storedClaim = -1        // The claim persisted in this user's IndexedDB meta row (see core.storeInputsToDB)
	int sentInputsUpToPos       // Local user only: our stream bytes below this pos may already be on the wire and must never be mutated in place (see the TouchMove patch guard in input.handleTouchEvent)
	int epoch                   // The epoch of this user's input stream: a new value means the user restarted with a fresh session (0 = unknown, see PeerNetwork.onTick)
	int storedEpoch             // The epoch persisted with this user's IndexedDB meta row: the lineage our restored copy of their stream belongs to (0 = unknown, see PeerNetwork.onTick's dead-lineage cut)
	int restoredFromDBUpTo      // How much of this user's stream came from OUR IndexedDB restore rather than the live mesh - only those bytes are lineage-suspect (see PeerNetwork.onTick's dead-lineage cut)
	int epochStartPos           // Local user only: bytes below this pos were restored after a rejoin, our own new bytes start here
	int historyTotalLength = -1 // While we restore our stream after a rejoin: how many bytes of it this peer reported to hold (-1 = no reply yet, see PeerNetwork.tickRestore)
	float lastStreamSentTime    // Last Removed notice sent to this user (rate limit, see PeerNetwork.sendRemovedNotice)
	float[int] lastStreamSentTimeByUserId // Last stream answer per requested user id (rate limit without starving parallel recoveries)

	// Removal (deterministic, driven by a RemoveUser event in the host's input stream)
	bool removed                // This user was removed from the game
	int removedAfterFrame = int.maxValue // Inputs of a removed user are only parsed up to and including this frame
	int storedRemovedAfterFrame = int.maxValue // The removal cut persisted in this user's IndexedDB meta row (see core.storeInputsToDB)
	float removalGossipStart    // When the host started collecting this silent user's stream from all peers (0 = not started)
	bool removalEventWritten    // The host wrote the RemoveUser event for this user
	int[] gossipAnswered = []   // Peers that answered the removal gossip with a stream answer we fully cover (host only, see PeerNetwork.removalGossipComplete)
	float removedFetchStallStart // Removed-but-incomplete stream: since when the fetch made no progress (0 = not stalled, see PeerNetwork's amend logic)
	int removedFetchProgressPos // The writePos at the last fetch progress (stall detection baseline)

	// Diagnostics (only used for logging)
	int droppedTickCount        // Ticks from this user that were dropped as non-contiguous (packet loss indicator)
	float lastDropLogTime       // Rate limit for logging dropped Ticks
	int lastTickTransport       // 0: nothing sent yet, 1: data channel, 2: server relay (logged on change)
	
	// List of inputs filled by parseInput and used by onTouchDown, onWheel, onKeyDown, ...
	visible Touch[] downTouches, movingTouches, upTouches
	visible ScrollEvent[] wheelEvents
	visible Key[] downKeys, upKeys
	visible string[] pressedKeys, textInputs, textCompositions
	visible string[] navigations

	// Modern Input
	visible bool[] justPressed, isPressed, justReleased
	Vector2 pointerPosition, scrollDelta

	// Video + Audio
	object mediaStream
	object[] videoElements
	object audioElement
	int videoElementIndex = 0
	
	// Connection
	dynamic peerConnection
	dynamic[] dataChannels
	dynamic latestDataChannel // The channel created with the current offer; may still be connecting (dataChannels only lists open ones)
	dynamic[] pendingIceCandidates // ICE candidates that arrived before the remote description was set
	bool settingRemoteDescription  // A received offer/answer is being applied; queue ICE candidates until setRemoteDescription resolved
	string connectionType
	bool offerByMe
	bool receivedAnswer
	bool connected
	int connectionTries
	int silentPeriods // Consecutive silence periods without any incoming data channel message; relayed messages don't count (see PeerNetwork.tick)
	// Consecutive channel-silence reconnects with no channel message in between. Grows the silence
	// timeout so a high-latency link gets enough time to finish signaling+ICE+DTLS before the
	// watchdog kills the almost-complete connection again (see PeerNetwork.tick)
	int channelReconnects
	string connectionState
	bool hidden                    // The user's tab is hidden: it is throttled and may fall silent, tolerate a longer silence (F6, see PeerNetwork.tick)
	bool leaving                   // The user's page is closing or navigating away: don't burn reconnect attempts; cleared by any incoming message (F6)
	bool reconnectNotified         // app.onTryingToReconnectTo was called for the current silence (cleared by any incoming message)
	bool presentOnServer           // The server listed this user as currently connected in the JoinResponse
	dynamic logConnectionTypeTimer // Pending connection-type report, cancelled when the connection is recreated (F30, see PeerNetwork.logConnectionType)

	float startToConnectTime = float.maxValue
	float startDataChannelTime = float.maxValue
	float lastIncomingMessageTime = float.maxValue // Last message on any transport (drives reconnect notifications and removal)
	float lastTickReceivedTime                     // Last accepted Tick - proof this user counts us as a live player (0 = never, drives the Removed-notice arbitration, see PeerNetwork.onRemovedMessage)
	float lastIncomingChannelTime = float.maxValue // Last message on the data channel (drives P2P connection repair)
	float lastChannelMessageTime = float.maxValue  // Last message on the data channel; never reset by the repair watchdog (drives the silent-channel relay mirror, see PeerNetwork.channelSuspect)
	float lastAckProgressTime = float.maxValue     // Last time this user acked new bytes of our stream or had nothing outstanding (drives the silent-channel relay mirror)
	
	// Statistics
	private int[] aheadHistory    // Rolling buffer of ahead values, used to calculate bufferFrames
	private int[] maxAheadHistory // Rolling buffer of maxAhead values
	visible int bufferFrames      // The average of all maxAhead values
	visible int smoothFrame = int.maxValue
	
	int certainFrame
	int prevCertainFrame

	InternalUser
		// Modern Input
		for input.inputButtonCount
			isPressed[i] = false
	
	startInputFrame: int index
		lastTouchMoveIndex.clear
		inputFrame = index
	
	clearEvent:
		downTouches.clear
		movingTouches.clear
		upTouches.clear
		wheelEvents.clear
		textCompositions.clear
		textInputs.clear
		downKeys.clear
		upKeys.clear
		pressedKeys.clear
		navigations.clear

		// Modern Input
		for input.inputButtonCount
			justPressed[i] = false
			justReleased[i] = false
		scrollDelta = {0,0}
		
	collectStatistics: int frame
		int ahead = frame - inputFrame
		
		// Get the maximum number of frames we were ahead in the last 10 seconds
		if ahead < 50 then aheadHistory.add ahead, maxLength:10*core.ticksPerSecond
		// int maxAhead = aheadHistory.max .
		int maxAhead = aheadHistory.percentile 80
		
		// Calculate a rolling average of the last 10 minutes
		maxAheadHistory.add maxAhead maxLength:10*60*core.ticksPerSecond
		bufferFrames = math.ceil(maxAheadHistory.average)
		smoothFrame = frame - bufferFrames
		
		prevCertainFrame = certainFrame
		certainFrame = math.min inputFrame, smoothFrame
		
	simulateRollback: int frame
		bufferFrames = 5
		smoothFrame = frame - bufferFrames		
		
priority class Player
	int	playerIndex	// The index of the player in the players list
	Color	playerColor	// Use this color to draw an outline around the current player (blue, red, green, yellow by default)
	Color	playerDarkColor	// Use this colorto draw an outline around players who are not the current player (darker version of playerColor)
	int	playerScore	// The score that will be shown in the leaderboard

	string	playerName
	string	playerEmail
	Language	playerLanguage

	int	id
	string	_id	// User account id
	int[]	colorPreferences
	
	internal Player cloneBaseData => {_id, playerLanguage, playerEmail, playerName, colorPreferences, id, playerIndex}
	toString => playerName ? "{playerName} (Player {playerIndex})" : "Player {playerIndex}"
	highlightPerspectiveColor => input.showPerspectiveOf == null or input.showPerspectiveOf == this ? this.playerColor : this.playerDarkColor
	
	// Touch input
	internal Touch[] touches
	internal Touch[] downTouches
	internal bool enableTouch = true
	Vector2 pointerPosition
	
	// Text input
	internal string textInput
	internal Key[] keysCurrentlyDown
	
	// Controller input
	visible Gamepad gamepad = {by:this}
	internal int[] controllerKeyDownFrame = [0, 0, 0, 0, 0, 0]
	
	internal bool isReadyInLobby
	
	// The current player instance, equivalent to "this"
	inline js Player me() this
	
	
	// Evaluate: Set isDown directly in input.touchDown instead of in player.postprocessEvents #easier-to-reason-about #evaluate
	// Called in core.step at the end of each step
	// onTouchMove is commonly used to check what the pointer is hovering over and highlight it.
	// Since on touch screens we often don't get a touchMove event when the user touches something, we can set 
	// triggeredOnTouchDown to "true" to ensure we always get a touchMove event right before the touchDown.
	// This is why isDown is only set to true *after* the events are handled in tick.
	// This way, onTouchMove can check isDown, determine what we are hovering over and onTouchDown can then act on it.
	// internal postprocessEvents
	// 	bool hasTouch = touches.any.type == Finger
	// 	for touches backwards
	// 		switch .phase
	// 			Down
	// 				.phase = Still
	// 				.isDown = true
	// 			Up
	// 				if .type >= Finger or (hasTouch and .type != Finger): touches.removeAt i
	// 				else                                                .phase = Still
	// 				downTouches.remove .
	// 				.isDown = false
				
internal UserAccount
	string _id
	Language language
	string email
	string name
	string colorPreferences
	
enum InputType: None, TouchDown, TouchMove, TouchUp, Scroll, KeyDown, KeyUp, TextInput, Stick, Trigger, Grip, ButtonDown, ButtonUp, ControllerTransform, HeadTransform, DeviceRotation, Join, SetState, Navigate, Gamepad, String, Json, Object, RemoveUser
		
// Phase of a touch or a click
enum TouchPhase: Still, Down, Move, Up
		
enum TouchType: LeftMouseButton, MiddleMouseButton, RightMouseButton, Finger, Pen

// A touch or a click
Touch
	int id
	importance:4 Player by
	TouchPhase phase
	TouchType type
	Vector2 position
	Vector2 startPosition
	Vector2 smoothPosition
	importance:4 bool isDown
	bool handled
	int startFrame
	
	importance:4 markAsHandled() handled = true
	
internal transient ScrollEvent
	immutable int userId
	immutable Vector2 delta
	immutable bool isPinch
	immutable Vector2 position
	bool handled
	
	markAsHandled() handled = true
	
enum Key
	None         =   0
	Backspace    =   8
	Tab          =   9
	Enter        =  13
	Shift        =  16
	Ctrl         =  17
	CmdOrCtrl    =  17
	Alt          =  18
	Pause        =  19
	CapsLock     =  20
	Escape       =  27
	Space        =  32
	PageUp       =  33
	PageDown     =  34
	End          =  35
	Home         =  36
	Left         =  37
	Up           =  38
	Right        =  39
	Down         =  40
	Insert       =  45
	Delete       =  46
	Number0      =  48
	Number1      =  49
	Number2      =  50
	Number3      =  51
	Number4      =  52
	Number5      =  53
	Number6      =  54
	Number7      =  55
	Number8      =  56
	Number9      =  57
	A            =  65
	B            =  66
	C            =  67
	D            =  68
	E            =  69
	F            =  70
	G            =  71
	H            =  72
	I            =  73
	J            =  74
	K            =  75
	L            =  76
	M            =  77
	N            =  78
	O            =  79
	P            =  80
	Q            =  81
	R            =  82
	S            =  83
	T            =  84
	U            =  85
	V            =  86
	W            =  87
	X            =  88
	Y            =  89
	Z            =  90
	LeftMetaKey  =  91
	RightMetaKey =  92
	Select       =  93
	Numpad0      =  96
	Numpad1      =  97
	Numpad2      =  98
	Numpad3      =  99
	Numpad4      = 100
	Numpad5      = 101
	Numpad6      = 102
	Numpad7      = 103
	Numpad8      = 104
	Numpad9      = 105
	Multiply     = 106
	Add          = 107
	Subtract     = 109
	DecimalPoint = 110
	Divide       = 111
	F1           = 112
	F2           = 113
	F3           = 114
	F4           = 115
	F5           = 116
	F6           = 117
	F7           = 118
	F8           = 119
	F9           = 120
	F10          = 121
	F11          = 122
	F12          = 123
	F13          = 124
	F14          = 125
	F15          = 126
	F16          = 127
	F17          = 128
	F18          = 129
	F19          = 130
	F20          = 131
	F21          = 132
	F22          = 133
	F23          = 134
	F24          = 135
	NumLock      = 144
	ScrollLock   = 145
	SemiColon    = 186
	EqualSign    = 187
	Comma        = 188
	Dash         = 189
	Period       = 190
	ForwardSlash = 191
	GraveAccent  = 192
	OpenBracket  = 219
	BackSlash    = 220
	CloseBraket  = 221
	SingleQuote  = 222
	
enum Cursor
	Pointer = "pointer" // The cursor is a pointer that indicates a link, typically an image of a pointing hand
	Default = "default" // The platform-dependent default cursor, typically an arrow
	Grab = "grab" // Something can be grabbed (dragged to be moved)
	Grabbing = "grabbing" // Something is being grabbed (dragged to be moved)
	NoDrop = "no-drop" // An item may not be dropped at the current location
	NotAllowed = "not-allowed" // The requested action will not be carried out
	Move = "move" // Something is to be moved
	Copy = "copy" // Something is to be copied
	ContextMenu = "context-menu" // A context menu is available
	Help = "help" // Help information is available
	Progress = "progress" // The program is busy in the background, but the user can still interact with the interface
	Wait = "wait" // The program is busy, and the user can't interact with the interface
	Cell = "cell" // The table cell or set of cells can be selected
	Crosshair = "crosshair" // Cross cursor, often used to indicate selection in a bitmap
	Text = "text" // The text can be selected Typically the shape of an I-beam
	VerticalText = "vertical-text" // The vertical text can be selected, typically the shape of a sideways I-beam
	Alias = "alias" // An alias or shortcut is to be created
	AllScroll = "all-scroll" // Something can be scrolled in any direction (on Windows, all-scroll is the same as move)
		
	ResizeCol = "col-resize" // The column can be resized horizontally, typically an left-right arrow with a vertial line
	ResizeRow = "row-resize" // The row can be resized vertically, typically an up-down arrow with a horizontal line
	ResizeN = "n-resize" // The top of of box can be moved
	ResizeE = "e-resize" // The right of of box can be moved
	ResizeS = "s-resize" // The bottom of of box can be moved
	ResizeW = "w-resize" // The left of of box can be moved
	ResizeNE = "ne-resize" // The top right corner of a box can be moved
	ResizeNW = "nw-resize" // The top left corner of a box can be moved
	ResizeSE = "se-resize" // The bottom right corner of a box can be moved
	ResizeSW = "sw-resize" // The bottom left corner of a box can be moved
	ResizeEW = "ew-resize" // Something can be moved left and right
	ResizeNS = "ns-resize" // Something can be moved up and down
	ResizeNESW = "nesw-resize" // Something can be moved diagonally from the bottom left to the top right
	ResizeNWSE = "nwse-resize" // Something can be moved diagonally from the top left to the bottom right
	
	ZoomIn = "zoom-in" // Something can be zoomed in
	ZoomOut = "zoom-out" // Something can be zoomed out	
	
	Auto = "auto" // The cursor will be based on the current context, for example "text" when hovering text
	None = "none" // No cursor is rendered
	
internal DigitalButton
	string name
	int index
	Key key
	
	bool isPressed
	bool wasJustPressed	=> isPressed and not wasPreviouslyPressed
	bool wasJustReleased	=> not isPressed and wasPreviouslyPressed
	internal bool wasPreviouslyPressed
	
	toString => name
	
	internal assign: string name, Key key
		this.name = name
		this.key = key
		isPressed = false
		wasPreviouslyPressed = false
	
	internal startFrame
		wasPreviouslyPressed = isPressed
		isPressed = false
		
internal transient immutable struct ControllerButtonPlayerAndIndex
	int userId
	int buttonIndex
	
internal transient immutable InternalGamepadButton
	bool pressed, touched
	float value
	
internal transient immutable InternalGamepad
	ImmutableList<float> axes
	ImmutableList<InternalGamepadButton> buttons
	string id
	
enum ControllerButton: None, Up, Right, Down, Left, A, B, X, Y, L, R, leftTrigger, rightTrigger, Select, Start, Menu
	
enum GamepadType: Keyboard, Xbox, PlayStation
internal Gamepad
	Player by
	const deadZone = .1
	
	// Sticks
	Vector2 leftStick
	Vector2 rightStick
	
	// Buttons
	DigitalButton A	= {name:"A"	index:0}
	DigitalButton B	= {name:"B"	index:1}
	DigitalButton X	= {name:"X"	index:2}
	DigitalButton Y	= {name:"Y"	index:3}
	DigitalButton leftBumper	= {name:"Left Bumper"	index:4}
	DigitalButton rightBumper	= {name:"Right Bumper"	index:5}
	DigitalButton leftTrigger 	= {name:"Left Trigger"	index:6}
	DigitalButton rightTrigger 	= {name:"Right Trigger"	index:7}
	DigitalButton select	= {name:"Select"	index:8}
	DigitalButton start	= {name:"Start"	index:9}
	DigitalButton leftStickButton	= {name:"Left Stick"	index:10}
	DigitalButton rightStickButton	= {name:"Right Stick"	index:11}
	DigitalButton up	= {name:"Up"	index:12}
	DigitalButton down	= {name:"Down"	index:13}
	DigitalButton left	= {name:"Left"	index:14}
	DigitalButton right	= {name:"Right"	index:15}
	
	DigitalButton[] buttons = [
		A, B, X, Y,
		leftBumper, rightBumper, leftTrigger, rightTrigger,
		start, select,
		leftStickButton, rightStickButton,
		up, right, down, left
	]
	
	bool inMotion
	GamepadType type
	string id
	
	internal startFrame
		leftStick.x = 0
		leftStick.y = 0
		rightStick.x = 0
		rightStick.y = 0
		buttons.each.startFrame
	
enum ShowPointersMode
	None	// Don't show the mouse pointers or draw them manually
	Local	// Show the mouse pointer only for the local player
	Remote	// Show the mouse pointer only for remote players
	LocalAndRemote	// Show the mouse pointers of all players
	WhenDown	// Show the mouse pointers of all players, but only when they are down (clicking or touching)
	
// A networkData callback answer (storage.get / http.*) that resolved while input recording
// was blocked; kept until recording resumes so the app still hears back (see input.handleObject)
internal transient PendingObjectRecord
	immutable int id
	immutable string data

// Collect user input
skipInit global unit input
	transient visible InternalUser[] internalUsers
	transient InternalUser localUser
	transient internal Player localPlayer
	transient bool isCertain
	transient ControllerButtonPlayerAndIndex[Key] controllerButtonMap
	transient PendingObjectRecord[] pendingObjectRecords
	
	// A list of all players
	Player[] players
		
	bool active = true
		
	// The player hosting the current session
	Player host
		
	// Do something for every player
	inline js void everybody: void(Player it) do
		for(let i=0, _len=input.players.length; i<_len; ++i) { let it = input.players[i]; do()}
		
	// Returns true if the given condition is true for every player
	inline js bool everybody: bool(Player it) predicate
		input.players.every(predicate)
		
	// Returns true if the given condition is true for any player
	inline js bool anybody: bool(Player it) predicate
		input.players.some(predicate)
		
	// Returns true if the given condition is true for no player
	inline js bool nobody: bool(Player it) predicate
		!input.players.some(predicate)
		
	// All players
	inline js Player[] everybody() input.players
		
	Player showPerspectiveOf
		
	// Show the perspective of this player
	switchPerspectiveTo: Player player
		watch "Switching to {player}"
		showPerspectiveOf = player
		if system.playMode == Play or system.playMode == Pause or system.playMode == Stop then core.switchToPlayer player
		
	internal Player[] playersById
	Cursor cursor
	
	bool showPointers = true
	ShowPointersMode showPointersMode = Remote
	ShowPointersMode showPointersModeInEditor = None
	ShowPointersMode showPointersDuringPlayback = LocalAndRemote
	
	bool enableClickingWithAltKey
	bool ignoreFirstClick
	
	string textInput
		let localPlayer = playersById[input.localUser.id]
		return localPlayer.textInput
	
	internal init
		initHandlers
	
	internal js Vector2 logicalToPixelPosition: Vector2 pos
		let p = pos.getTransformed(graphics.totalMatrix)
		return new Vector2(p.x/system.pixelRatio, p.y/system.pixelRatio, null)

	private js void initHandlers
		if(system.isHeadless) return
		let pointerX = 0, pointerY = 0, clickWithAltKeyX = 0, clickWithAltKeyY = 0
		window.onpointerdown = e => {
			if(e.button == 0 && system.playMode <= 1 /*Stop,Pause*/) {
				system.record();
				if(input.ignoreFirstClick) return;
			}
			input.handleTouchEvent(1, e.pageX, e.pageY, e.pointerType, e.pointerId, e.button, e.shiftKey, e.altKey, e.ctrlKey || e.metaKey);
		}
		window.onpointermove = e => {
			pointerX = e.pageX; pointerY = e.pageY;
			input.handleTouchEvent(2, e.pageX, e.pageY, e.pointerType, e.pointerId, e.button, e.shiftKey, e.altKey, e.ctrlKey || e.metaKey);
		}
		window.onpointerup = e => {
			input.handleTouchEvent(3, e.pageX, e.pageY, e.pointerType, e.pointerId, e.button, e.shiftKey, e.altKey, e.ctrlKey || e.metaKey);
		}
		window.oncontextmenu = e => {
			e.preventDefault();
			e.stopPropagation();
			return false;
		}
		window.onkeydown = e => {
			let keyCode = e.keyCode
			let key = e.key
			let ctrlOrCmd = e.ctrlKey || e.metaKey
			if(window.require && key == "t" && e.metaKey && e.shiftKey)
				system.openDevTools();
			else
			if(ctrlOrCmd && key == "s") {
				// Save event steam
				core.saveEventStream();
				e.preventDefault();
			}
			else
			if(ctrlOrCmd && key == "o") {
				// Open event stream or state
				if(system.isDebug) core.openEventStream();
				else                 core.openState();
				e.preventDefault();
			}
			else
			if(ctrlOrCmd && key == "l") {
				// Save logs
				statistics.saveStatistics()
				core.saveLogs();
				e.preventDefault();
			}
			else
			if((key == "F1" || key == "F2" || key == "F3" || key == "F4") && !ctrlOrCmd && system.isDebug) {
				let index = key[1] - "1"
				core.switchToPlayer(input.players[index]);
				e.preventDefault();
			}
			else
			if((key >= "1" && key <= "0") && (e.altKey || e.ctrlKey)) {
				let index = key - "0"
				if(e.altKey)  { core.save(index); e.preventDefault(); } else
				if(e.ctrlKey) { core.restore(index); e.preventDefault(); }
			}
			else
			if(key == "F5" && system.isDebug) {
				system.stop();
				e.preventDefault();
			} else if(key == "F7" && system.isDebug) {
				system.togglePlay();
				e.preventDefault();
			} else if(key == "F9") {
				if(e.shiftKey) { core.saveLogs(); }
				else           { system.toggleDebugInfo(); }
				e.preventDefault();
			} else if(key == "F10") { 
				system.toggleSmallScreen();
			} else if(key == "F11") { 
				graphics.copyScreenshotToClipboard();
			} else if(key == "Alt" && input.enableClickingWithAltKey) {
				clickWithAltKeyX = pointerX; clickWithAltKeyY = pointerY;
				input.handleTouchEvent(1, clickWithAltKeyX, clickWithAltKeyY, "touch", /*pointerId*/127, /*button*/0, /*shift*/false, /*alt*/false, /*ctrl*/false);
			} else {
				let typedKey = key && key.length == 1  && !e.ctrlKey && !e.metaKey && !e.altKey? key : ""
				input.handleKeyEvent(5, keyCode, typedKey)
				if(keyCode == 9) e.preventDefault();
			}
		}
		window.onkeyup = e => {
			if(e.key == "Alt" && input.enableClickingWithAltKey) {
				input.handleTouchEvent(3, clickWithAltKeyX, clickWithAltKeyY, "touch", /*pointerId*/127, /*button*/0, /*shift*/false, /*alt*/false, /*ctrl*/false);
			} else {
				input.handleKeyEvent(6, e.keyCode)
			}
		}
			
		// Handles navigating back or forward in the browser	
		window.onpopstate = e => {
			input.handleNavigate(location.pathname);
		}
		if(!window._isWheelHandlerSet) {
			window._isWheelHandlerSet = true
			window.addEventListener('wheel', e => {
				e.preventDefault();
				e.stopPropagation();
				if(e.button == 0 && system.playMode == 0) system.record();
				input.handleWheelEvent(e.pageX, e.pageY, e.deltaX, e.deltaY, e.ctrlKey)
				return false;			
			}, {passive: false})
		}
		
		if(window._input) window._input.value = ""
		
	private setLastTouchMoveIndex: int id, int index
		let lastMoveIndex = localUser.lastTouchMoveIndex
		let i = 0
		while i < lastMoveIndex.length
			if lastMoveIndex[i] == id
				lastMoveIndex[i+1] = index
				return
			i += 2
		lastMoveIndex.add id
		lastMoveIndex.add index
	
	private getLastTouchMoveIndex: int id
		let lastMoveIndex = localUser.lastTouchMoveIndex
		let i = 0
		while i < lastMoveIndex.length
			if lastMoveIndex[i] == id then return lastMoveIndex[i+1]
			i += 2
		return 0
		
	private handleTextInput: InputType type, string text
		if core.mode == None || system.playMode != Record || !localUser || !localUser.collectInputs || core.inputRecordingPaused then return
		let inputs = localUser.inputs
		
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast type
		inputs.writeString text
			
	internal handleKeyEvent: InputType inputType, Key keyCode, string key
		if core.mode == None || system.playMode != Record || !localUser || !localUser.collectInputs || core.inputRecordingPaused then return
		let inputs = localUser.inputs
		int composite = cast inputType // inputType:   0 - 31 (5 bit)
		
		let controllerButton = controllerButtonMap[keyCode]
			composite += controllerButton.buttonIndex shiftLeft 5 // buttonIndex: 0 - 15 (4 bit)
			if core.mode == Local and not core.simulateConnection
				inputs = internalUsers[controllerButton.userId].inputs
			
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt32 cast keyCode
		if inputType == KeyDown then inputs.writeString key
		
	internal handleTouchEvent: InputType inputType, float x, float y, string pointerType, int pointerId, int button, shift = false, alt = false, cmdOrCtrl = false
		int touchType, id
		switch pointerType
			"mouse"	touchType = button.clamp(0 to 2)
			"touch"	touchType = 3; id = pointerId
			default	touchType = 4
		
		Vector2 pixelPos = {x*graphics.pixelRatio, y*graphics.pixelRatio}
		Vector2 referencePos = graphics.getPixelPos(x, y)
		gizmo.onTouch inputType, id, pixelPos, referencePos, shift, alt, cmdOrCtrl
		
		if core.mode == None || system.playMode != Record || !localUser || !localUser.collectInputs || core.inputRecordingPaused then return		
		let inputs = localUser.inputs

		if inputType == TouchMove
			int index = getLastTouchMoveIndex id
			// Coalescing patches the previous move record of this input frame IN PLACE. Mutating
			// stream bytes is only safe while they have never left this device: normally
			// core.onFrame clears lastTouchMoveIndex (startInputFrame) before it transmits
			// (PeerNetwork.sendInputs), so a patchable record is always younger than the last
			// transmission. But the stream can also be sent between animation frames
			// (onHeartbeat while hidden, stream answers to a restoring rejoiner) - patching an
			// already-sent record would fork the copy the receiver holds into a permanent
			// checksum desync, so in that case append a fresh record instead
			if index and index < localUser.sentInputsUpToPos
				core.log "TouchMove record at {index} was already sent (sent up to {localUser.sentInputsUpToPos}) - appending a new record instead of patching sent bytes"
				index = 0
			if index
				// We already moved the pointer this input frame, so just update the last move
				inputs.setInt16 index, math.round(referencePos.x)
				inputs.setInt16 index+2, math.round(referencePos.y)
				return
			else
				setLastTouchMoveIndex id, inputs.writePos+6
			
		int composite = cast(inputType)	// inputType: 0 -  31 (5 bit)
					+ (touchType shiftLeft 5)	// touchType: 0 -   7 (3 bit)
					+ ((math.floor(math.abs(id)) mod 128) shiftLeft 8)	// id:        0 - 127 (7 bit)
		
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt16 math.round(referencePos.x)
		inputs.writeInt16 math.round(referencePos.y)

	internal handleSynteticTouchEvent: int playerIndex, InputType inputType, float x, float y, TouchType touchType, int id
		let inputs = internalUsers[playerIndex]?.inputs
		if !inputs then return
		int composite = cast(inputType)	// inputType: 0 -  31 (5 bit)
		              + (cast touchType shiftLeft 5)	// touchType: 0 -   7 (3 bit)
		              + ((math.floor(math.abs(id)) mod 128) shiftLeft 8)	// id:        0 - 127 (7 bit)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt16 math.round(x)
		inputs.writeInt16 math.round(y)
	
	internal handleUpdateTouchAfterSwitchingUser: int id, Vector2 referencePos
		let inputs = localUser.inputs
		int composite = cast(InputType.TouchMove)	// inputType: 0 -  31 (5 bit)
		              + (cast TouchType.LeftMouseButton shiftLeft 5)	// touchType: 0 -   7 (3 bit)
		              + ((math.floor(math.abs(id)) mod 128) shiftLeft 8)	// id:        0 - 127 (7 bit)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt16 math.round(referencePos.x)
		inputs.writeInt16 math.round(referencePos.y)
		
	private handleWheelEvent: float x, float y, float deltaX, float deltaY, bool isPinch
		if core.mode == None || system.playMode != Record || !localUser || !localUser.collectInputs || core.inputRecordingPaused then return
		let inputs = localUser.inputs
		
		int composite = cast(InputType.Scroll)	// inputType: 0 -  31 (5 bit)
		              + ((isPinch ? 1:0) shiftLeft 5)	// isPinch:   0 -   1 (1 bit)
		
		Vector2 referencePos = graphics.getPixelPos(x, y)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt16 math.round(referencePos.x)
		inputs.writeInt16 math.round(referencePos.y)
		inputs.writeInt16 math.round(deltaX)
		inputs.writeInt16 math.round(deltaY)
		
	internal handleSetState: Buffer buffer
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast InputType.SetState
		inputs.writeBuffer buffer
		
	internal handleJoin: int frame, UserAccount account
		let inputs = localUser.inputs
		inputs.writeInt32 frame
		inputs.writeInt16 cast InputType.Join
		inputs.writeString account._id
		inputs.writeInt8 cast account.language
		inputs.writeString account.name
		inputs.writeString account.email
		inputs.writeString account.colorPreferences
				
	// Handles navigating back or forward in the browser	
	internal handleNavigate: string url
		if core.mode == None || system.playMode != Record || !localUser || !localUser.collectInputs || core.inputRecordingPaused then return
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.Navigate
		inputs.writeString url
		
	internal handleString: int id, string data
		if !data || core.mode == None || core.frames > core.frame || !localUser || !localUser.collectInputs || core.inputRecordingPaused then return
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.String
		inputs.writeInt id
		inputs.writeString data
		
	internal handleJson: int id, string data
		if !data || core.mode == None || core.frames > core.frame || !localUser || !localUser.collectInputs || core.inputRecordingPaused then return
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.Json
		inputs.writeInt id
		inputs.writeString data
		
	// Callback delivery for the async networkData APIs (storage.get, http.get/post/put/delete).
	// Guarded like handleString/handleJson, with two differences: an empty answer is still a
	// valid delivery (storage.get answers "" for a missing key), and a blocked delivery must
	// not be dropped - the record is what fires the app's callback on every client, so dropping
	// it would mean the app never hears back. While recording is not possible (catch-up replay,
	// holding-confirmation gate, no local user yet) the delivery is queued and flushed from
	// core.onFrame once recording resumes
	internal handleObject: int id, string data
		if core.mode == None || core.frames > core.frame || !localUser || !localUser.collectInputs || core.inputRecordingPaused
			pendingObjectRecords.add {id:id, data:data}
			return
		writeObjectRecord id, data

	private writeObjectRecord: int id, string data
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.Object
		inputs.writeInt id
		inputs.writeString data

	// Deliver the networkData callbacks that resolved while input recording was blocked.
	// Called from core.onFrame after the step loop, so the records are stamped with the
	// current monotonic inputFrame and travel with the next Tick
	internal flushPendingObjectRecords
		if !pendingObjectRecords.length then return
		if core.mode == None || core.frames > core.frame || !localUser || !localUser.collectInputs || core.inputRecordingPaused then return
		core.log "Flushing {pendingObjectRecords.length} networkData callback records that resolved while input recording was blocked"
		for pendingObjectRecords
			writeObjectRecord .id, .data
		pendingObjectRecords.clear

	// A snapshot restore may create FRESH Player objects instead of reusing the live ones (the
	// serializer's object-reuse stamps only match the most recently serialized snapshot, and
	// checksum serializations restamp the graph between rewind passes). players/playersById/host
	// are part of the restored state and stay consistent, but localPlayer is a transient pointer
	// into that graph - re-derive it after every deserialize, or it keeps pointing at a dead
	// object whose fields (playerIndex!) are frozen at their last live values (lifecycle seed
	// 946832364: the veteran's ready clicks landed on another player's lobby slot forever)
	internal refreshLocalPlayer
		if localUser
			let player = playersById[localUser.id]
			if player then localPlayer = player

	// Write a RemoveUser event into our own input stream: the removal of a player becomes part
	// of the deterministic timeline and is applied by every client when the event is parsed.
	// lastFrame is the last frame of the removed user's stream that still counts - the host
	// merged the streams of all living peers first, so it covers everything any client committed
	internal handleRemoveUser: int userId, int lastFrame
		if core.mode == None || !localUser || !localUser.collectInputs then return
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.RemoveUser
		inputs.writeInt userId
		inputs.writeInt lastFrame
		print "Removing player {userId}, their inputs count up to frame {lastFrame}", type:Action
		
	// Returns a "GamepadList" (which doesn't have the functions of a LiveTime list)
	private inline js dynamic getGamepads() navigator.getGamepads()
	
	internal updateGamepads
		// Gamepad state is only recorded during a live Record step. Replay steps (the rollback
		// replay in core.checkRewindAndReplayState, debug timeline navigation) run with
		// system.fastForward and inputFrame does not advance there - recording would append a
		// duplicate record with the same stamp on every replayed step, bloating the stream by
		// the replay window on every animation frame. Catch-up steps run with fastForward:false
		// and monotonic stamps, so they keep recording intentionally - they carry the live stick
		// state (which is why this doesn't check core.inputRecordingPaused, true during a catch-up)
		if system.fastForward or system.playMode != Record then return
		// Gamepad records must not be appended while a rejoin's holding confirmations are
		// pending, like the DOM input handlers
		if PeerNetwork.holdingConfirmationPending then return
		let gamepads = getGamepads
		if gamepads == null then return
		InternalGamepad gp = gamepads[0]
		if !gp or gp.axes.length < 2 then return
			
		let isPlayStation = gp.id.includes("54c") or gp.id.includes("810")
		
		// Controller axis
		let axes = gp.axes
		let leftStickX = axes[0]
		let leftStickY = axes[1]
		
		// Controller buttons
		let buttons = (gp.buttons[ 0].pressed ?     1:0) // A
		            + (gp.buttons[ 1].pressed ?     2:0) // B
		            + (gp.buttons[ 2].pressed ?     4:0) // X
		            + (gp.buttons[ 3].pressed ?     8:0) // Y
		
		            + (gp.buttons[ 4].pressed ?    16:0) // L1
		            + (gp.buttons[ 5].pressed ?    32:0) // R1
		            + (gp.buttons[ 6].pressed ?    64:0) // L2
		            + (gp.buttons[ 7].pressed ?   128:0) // R2

		            + (gp.buttons[ 8].pressed ?   256:0) // Select
		            + (gp.buttons[ 9].pressed ?   512:0) // Start
		
		            + (gp.buttons[10].pressed ?  1024:0) // Left Stick Button
		            + (gp.buttons[11].pressed ?  2048:0) // Right Stick Button

		            + (gp.buttons[12].pressed ?  4096:0) // Up
		            + (gp.buttons[13].pressed ?  8192:0) // Down	
		            + (gp.buttons[14].pressed ? 16384:0) // Left
		            + (gp.buttons[15].pressed ? 32768:0) // Right

		            // + (isPlayStation          ? 16384:0)

		// Write to event stream
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.Gamepad
		inputs.writeFloat32 math.abs(leftStickX) > Gamepad.deadZone ? leftStickX : 0
		inputs.writeFloat32 math.abs(leftStickY) > Gamepad.deadZone ? leftStickY : 0
		inputs.writeUnsignedInt16 buttons
			
	internal parseInputs: int frame
		for internalUsers as internalUser if internalUser
			// Events are normally cleared at the end of core.tick, but when an exception aborts
			// the step after parsing, stale events survive in these transient lists. Clear them
			// here so a frame that is stepped again after a rewind can't apply an event twice.
			internalUser.clearEvent
			let inputs = internalUser.inputs
			let userId = internalUser.id
			let player = playersById[userId]
			// A removed user's Player leaves the game at the first frame past removedAfterFrame:
			// all their records have been parsed by then, so the recreate-on-first-record path
			// below can't resurrect them (see removeUserDeterministically)
			if player and internalUser.removed and frame > internalUser.removedAfterFrame
				removeRemovedPlayer userId, frame
				player = null
			player?.gamepad.startFrame
			
			while true
				int nextFrame = inputs.canRead ? inputs.peekInt32 : int.maxValue
				if nextFrame > frame then break
				// Only parse records that are covered by the sender's claim: claimed records are
				// guaranteed to be complete in the buffer (a chunked transfer can end mid-record)
				// and identical on every client. Our own records are always complete
				if not internalUser.local and nextFrame > internalUser.inputFrame then break
				// A removed user's stream ends deterministically after removedAfterFrame:
				// clients may have received different amounts from a dead user, but every client
				// parses exactly the records up to this frame
				if internalUser.removed and nextFrame > internalUser.removedAfterFrame then break
				inputs.readPos += 4
				
				// We create the player as soon as we receive the first input from that player,
				// which is typically the "Join" message that is sent in "startConnected",
				// but could also be a player reconnecting that was previously kicked out
				if not player
					if core.verbose and not internalUser.local then core.log "<{internalUser.id}> Received first message from new user"
					
					players.add player = {id:userId, playerIndex:players.length}
					playersById[userId] = player
					if internalUser.local then localPlayer = player
					updatePlayers
				
				let value = inputs.readUnsignedInt16
				InputType inputType = cast(value mod 32)
				
				if inputType >= TouchDown && inputType <= Scroll
					if !player then core.log " ERROR: userId {userId} not in playersById"
					TouchType type = cast((value shiftRight 5) mod 8)
					int id = (value shiftRight 8) mod 128
					Vector2 referencePos = {inputs.readInt16, inputs.readInt16}
					bool isSmoothPosition = !core.smoothTouchPosition or internalUser.local or frame <= internalUser.smoothFrame
					
					if inputType == TouchDown
						touchDown internalUser:internalUser, player:player, id:id, type:type, referencePos:referencePos, isSmoothPosition:isSmoothPosition
					else
					if inputType == TouchMove
						touchMove internalUser:internalUser, player:player, id:id, type:type, referencePos:referencePos, isSmoothPosition:isSmoothPosition
					else
					if inputType == TouchUp
						touchUp internalUser:internalUser, player:player, id:id, type:type, referencePos:referencePos, isSmoothPosition:isSmoothPosition
					else
					if inputType == Scroll
						Vector2 delta = {inputs.readInt16, inputs.readInt16}
						bool isPinch = (value shiftRight 5) == 1
						scroll internalUser:internalUser, player:player, delta:delta, isPinch:isPinch, referencePosition:referencePos
				else
				if inputType == TextInput
					let textInput = inputs.readString
					player.textInput = textInput
					internalUser.textInputs.add textInput
				else
				if inputType == KeyDown
					keyDown internalUser, player, key:cast inputs.readInt32, character: inputs.readString
					int controllerButtonIndex = cast((value shiftRight 5) mod 16)
					player.controllerKeyDownFrame[controllerButtonIndex] = frame
				else
				if inputType == KeyUp
					keyUp internalUser, player, key:cast inputs.readInt32
					int controllerButtonIndex = cast((value shiftRight 5) mod 16)
						player.controllerKeyDownFrame[controllerButtonIndex] = 0
				else
				if inputType == Navigate
					internalUser.navigations.add inputs.readString
				else
				if inputType == Gamepad
					Gamepad c = player.gamepad
					
					// Controller axix
					c.leftStick.x = inputs.readFloat32
					c.leftStick.y = inputs.readFloat32
					
					// Controller buttons
					let buttons	= inputs.readUnsignedInt16
					c.A.isPressed	= (buttons bitwiseAnd 1) != 0
					c.B.isPressed	= (buttons bitwiseAnd 2) != 0
					c.X.isPressed	= (buttons bitwiseAnd 4) != 0
					c.Y.isPressed	= (buttons bitwiseAnd 8) != 0
					c.leftBumper.isPressed	= (buttons bitwiseAnd 16) != 0
					c.rightBumper.isPressed	= (buttons bitwiseAnd 32) != 0
					c.leftTrigger.isPressed	= (buttons bitwiseAnd 64) != 0
					c.rightTrigger.isPressed	= (buttons bitwiseAnd 128) != 0
					c.select.isPressed	= (buttons bitwiseAnd 256) != 0
					c.start.isPressed	= (buttons bitwiseAnd 512) != 0
					c.leftStickButton.isPressed	= (buttons bitwiseAnd 1024) != 0
					c.rightStickButton.isPressed	= (buttons bitwiseAnd 2048) != 0
					c.up.isPressed	= (buttons bitwiseAnd 4096) != 0
					c.down.isPressed	= (buttons bitwiseAnd 8192) != 0
					c.left.isPressed	= (buttons bitwiseAnd 16384) != 0
					c.right.isPressed	= (buttons bitwiseAnd 32768) != 0

					// c.type = (buttons bitwiseAnd 16384) != 0 ? PlayStation : Xbox
					
					// Controller button names
					if c.type == Xbox
						c.A.name = "A"
						c.B.name = "B"
						c.X.name = "X"
						c.Y.name = "Y"
					else
						c.A.name = "X"
						c.B.name = "O"
						c.X.name = "SQUARE"
						c.Y.name = "TRIANGLE"

					// Modern input
					int bit = 1
					for 16
						bool isPressed = (buttons bitwiseAnd bit) != 0
						bool wasPressed = internalUser.isPressed[i]
						internalUser.isPressed[i] = isPressed
						internalUser.justPressed[i] = isPressed and not wasPressed
						internalUser.justReleased[i] = not isPressed and wasPressed
						bit = bit shiftLeft 1
				else
				if inputType == String
					int id = inputs.readInt
					string valueString = inputs.readString
					networkData.call id, valueString
					if system.waitingForInitialData > 0 then system.waitingForInitialData--
				else
				if inputType == Json
					int id = inputs.readInt
					string valueString = inputs.readString
					dynamic object = valueString ? valueString.parseJson : null
					networkData.call id, object
					if system.waitingForInitialData > 0 then system.waitingForInitialData--
				else
				if inputType == Object
					int id = inputs.readInt
					string valueString = inputs.readString
					dynamic object = valueString ? valueString.parseJson : null
					networkData.call id, object
					if system.waitingForInitialData > 0 then system.waitingForInitialData--
				else
				if inputType == SetState
					// Set state
					core.snapshotBuffer.reset
					inputs.readBuffer core.snapshotBuffer
					Snapshot.deserialize core.snapshotBuffer
					math.recreateRandomValues
					
					// Match users
					playersById.clear
					let availableUsers = clone input.internalUsers
					for players as player
						let user = availableUsers.popWhere.name == player.playerName
						if not user then user = availableUsers.popWhere.index == player.playerIndex
						if not user then availableUsers.pop
						player.id = user.id
						
						user._id = player._id
						user.index = player.playerIndex
						user.name = player.playerName
						playersById[player.id] = player
					refreshLocalPlayer

				else
				if inputType == Join
					player._id = internalUser._id = inputs.readString
					player.playerLanguage = cast inputs.readInt8
					player.playerName = internalUser.name = inputs.readString
					player.playerEmail = inputs.readString
					string colorPreferencesString = inputs.readString
					player.colorPreferences = colorPreferencesString.split(",").map.toInt
					print "Player {userId} joined at frame {frame}", type:Reaction
					app.onJoin??(userId)
				else
				if inputType == RemoveUser
					int removeUserId = inputs.readInt
					int lastFrame = inputs.readInt
					removeUserDeterministically removeUserId, lastFrame, frame
	
		// for players
		// 	let internalUser = internalUsers[.id]
		// 	if frame <= internalUser.inputFrame
		// 		let right = .controllerKeyDownFrame[0]
		// 		let down  = .controllerKeyDownFrame[1]
		// 		let left  = .controllerKeyDownFrame[2]
		// 		let up    = .controllerKeyDownFrame[3]
		// 		if right or left: .gamepad.leftStick.x = right >= left ? 1 : -1
		// 		if down  or up:   .gamepad.leftStick.y = down  >= up   ? 1 : -1
		// 		if .controllerKeyDownFrame[4]: .gamepad.a.state = true
		// 		if .controllerKeyDownFrame[5]: .gamepad.b.state = true
		// 		if .controllerKeyDownFrame[6]: .gamepad.x.state = true
		// 		if .controllerKeyDownFrame[7]: .gamepad.y.state = true
		// 		.gamepad.inMotion = math.abs(.gamepad.leftStick.x) >= Gamepad.deadZone
		// 		                    or math.abs(.gamepad.leftStick.y) >= Gamepad.deadZone
				
		for players as p
			// Left stick
			let right = .controllerKeyDownFrame[ControllerButton.Right]
			let down  = .controllerKeyDownFrame[ControllerButton.Down]
			let left  = .controllerKeyDownFrame[ControllerButton.Left]
			let up    = .controllerKeyDownFrame[ControllerButton.Up]
			if right or left	then .gamepad.leftStick.x = right >= left ? 1 : -1
			if down  or up	then .gamepad.leftStick.y = down  >= up   ? 1 : -1
			.gamepad.inMotion = math.abs(.gamepad.leftStick.x) >= Gamepad.deadZone
			                        or math.abs(.gamepad.leftStick.y) >= Gamepad.deadZone
			
			// Buttons
			for .gamepad.buttons
				if p.controllerKeyDownFrame[i]
					.isPressed = true

			app.onGamepad??(p.gamepad)
			p.onGamepad??(p.gamepad)
					
		if system.receivedInitialData
			system.waitingForInitialData -= system.receivedInitialData
			system.receivedInitialData = 0

	internal touchDown: InternalUser internalUser
	                    Player player
	                    int id
						Vector2 referencePos
						TouchType type
						bool isSmoothPosition
						string message = null
		let touch = player.touches.find.id == id
		if touch
			// Update the touch in player.touches
			touch.phase = Down
			touch.position = referencePos
			touch.startPosition = referencePos
			touch.startFrame = core.frame
			touch.type = type

			// Evaluate: Set isDown directly instead of in player.postprocessEvents #easier-to-reason-about #evaluate
			touch.isDown = true

			// When we touch down, we start a new touch and reset the "handled" flag
			// This flag is preserved throughout "TouchMove" and "TouchUp", so if we mark the touch
			// as handled at any point, the flags stays set to "true" until we touch down again
			touch.handled = false
			if isSmoothPosition then touch.smoothPosition = referencePos
		else
			// Evaluate: Set isDown directly instead of in player.postprocessEvents #easier-to-reason-about #evaluate
			touch = {id, player, Down, type, referencePos, referencePos, referencePos, isDown:true}
			player.touches.add touch
				
		player.downTouches.ensure touch
		player.pointerPosition = referencePos
		internalUser.downTouches.add touch
		print type:Touch message or "Click {referencePos} by {player}", input.isCertain

		// Call handlers
		app.onTouchHover??(touch);
		player.onTouchHover??(touch);
		app.onTouchDown??(touch)
		player.onTouchDown??(touch)

		// Modern Input
		int buttonIndex = InputButton.LeftMouseButton + type
		internalUser.justPressed[buttonIndex] = true
		internalUser.isPressed[buttonIndex] = true
		internalUser.pointerPosition = referencePos

	internal touchMove: InternalUser internalUser
	                    Player player
	                    int id
					    Vector2 referencePos
					    TouchType type
					    bool isSmoothPosition
		let touch = player.touches.find.id == id
		if touch
			// Update the touch in player.touches
			if touch.phase == Still then touch.phase = Move
			touch.position = referencePos
			touch.type = type
			if isSmoothPosition then touch.smoothPosition = referencePos
		else
			touch = {id, player, Move, type, referencePos, startPosition:Vector2.none, referencePos, isDown:false}
			player.touches.add touch
				
		player.pointerPosition = referencePos
		internalUser.movingTouches.add touch
		cursor = Auto

		// Call handlers
		if not touch.isDown
			app.onTouchHover??(touch);
			player.onTouchHover??(touch);
		else
			app.onTouchDrag??(touch);
			player.onTouchDrag??(touch);

		// Modern Input
		internalUser.pointerPosition = referencePos

	internal touchUp: InternalUser internalUser
	                  Player player
	                  int id
					  Vector2 referencePos
					  TouchType type
					  bool isSmoothPosition
		let touch = player.touches.find.id == id
		if touch
			// Update the touch in player.touches
			touch.phase = Up
			touch.position = referencePos
			touch.type = type
			touch.isDown = false
			if isSmoothPosition then touch.smoothPosition = referencePos
		else
			touch = {id, player, Up, type, referencePos, startPosition:Vector2.none, referencePos, isDown:false}
			player.touches.add touch
		
		player.pointerPosition = referencePos
		internalUser.upTouches.add touch

		// Call handlers
		app.onTouchUp??(touch)
		player.onTouchUp??(touch)

		// Log
		if player == input.localPlayer
			let length = referencePos distanceTo touch.startPosition
			let playerVariable = "players[{player.playerIndex}]"
			if length < 8
				core.addOutput "code|click {touch.startPosition} by {playerVariable}|{touch.startFrame}|{core.frame}"
			else
				core.addOutput "code|drag {touch.startPosition} to {referencePos} by {playerVariable}|{touch.startFrame}|{core.frame}"

		// Modern Input
		int buttonIndex = InputButton.LeftMouseButton + type
		internalUser.justReleased[buttonIndex] = true
		internalUser.isPressed[buttonIndex] = false
		internalUser.pointerPosition = referencePos

	internal scroll: InternalUser internalUser
	                 Player player
					 Vector2 delta
					 bool isPinch
					 Vector2 referencePosition
		internalUser.wheelEvents.add {player.id, delta, isPinch, referencePosition}

		// Call handlers
		app.onScroll??(delta, isPinch, referencePosition)
		player.onScroll??(delta, isPinch, referencePosition)

		// Modern Input
		internalUser.scrollDelta += delta

	internal keyDown: InternalUser internalUser
	                  Player player
					  Key key
					  string character
		internalUser.downKeys.add key
		player.keysCurrentlyDown.ensure key
		if character
			internalUser.pressedKeys.add character
			print type:Key "Press key {character} by {player}"
		else
			print type:Key "Press key {key} by {player}"
		app.onKeyDown??(key, character)
		player.onKeyDown??(key, character)

	internal keyUp: InternalUser internalUser
	                Player player
					Key key
		internalUser.upKeys.add key
		player.keysCurrentlyDown.remove key
		app.onKeyUp??(key)
		player.onKeyUp??(key)
						
	internal updatePlayers
		players.sortBy.id
		for players
			.playerIndex = i
			// More players than palette entries must wrap, not read out of bounds: an undefined
			// playerColor throws in the draw path, and that caught error used to poison this
			// client's replays (churn desync, seed 339031744 - a removed user's arriving stream
			// transiently resurrects their player, so the count can exceed the palette)
			.playerColor = graphics.defaultColors[i mod graphics.defaultColors.length]
			.playerDarkColor = graphics.darkDefaultColors[i mod graphics.darkDefaultColors.length]
			internalUsers[.id].index = i
			
		if core.mode == Local and not core.simulateConnection
			if players.length >= 1
				Gamepad c = players[0].gamepad
				if c.type == Keyboard
					c.up.assign    "↑"	Up
					c.right.assign "→"	Right
					c.down.assign  "↓"	Down
					c.left.assign  "←"	Left
					c.A.assign     "Shift"	Shift
					c.B.assign     "Control"	Ctrl
			
			if players.length >= 2
				Gamepad c = players[1].gamepad
				if c.type == Keyboard
					c.up.assign    "W"	W
					c.right.assign "D"	D
					c.down.assign  "S"	S
					c.left.assign  "A"	A
					c.A.assign     "F"	F
					c.B.assign     "G"	G
			
			if players.length >= 3
				Gamepad c = players[2].gamepad
				if c.type == Keyboard
					c.up.assign    "I"	I
					c.right.assign "L"	L
					c.down.assign  "K"	K
					c.left.assign  "J"	J
					c.A.assign     "O"	O
					c.B.assign     "P"	P
			
			controllerButtonMap.clear
			for players as player
				player.controllerKeyDownFrame.clear
				for .gamepad.buttons
					controllerButtonMap[.key] = {userId:player.id, buttonIndex:i}
					player.controllerKeyDownFrame.add 0
		else
			controllerButtonMap.clear
			for players
				Gamepad c = .gamepad
				if c.type == Keyboard
					c.up.assign    "↑"	Up
					c.right.assign "→"	Right
					c.down.assign  "↓"	Down
					c.left.assign  "←"	Left
					c.A.assign     "Shift"	Shift
					c.B.assign     "Control"	Ctrl
			
			controllerButtonMap.clear
			// TODO: Research why this is sometimes called before we have a local player
			if localPlayer
				for localPlayer.gamepad.buttons
					controllerButtonMap[.key] = {userId:localPlayer.id, buttonIndex:i}
				
			controllerButtonMap[W] = {userId:localUser.id, buttonIndex:1}
			controllerButtonMap[D] = {userId:localUser.id, buttonIndex:2}
			controllerButtonMap[S] = {userId:localUser.id, buttonIndex:3}
			controllerButtonMap[A] = {userId:localUser.id, buttonIndex:4}
			
	private getTargetedPlayers: Player[] by
		return by and by.length > 0 and by[0] and not core.everybodyCanClickForEverybody ? by : players
		

	// Remove a player deterministically: writes a RemoveUser event into the local input stream,
	// so the same player is removed at the same frame on all clients
	removePlayer: Player player
		if not player then return
		let user = internalUsers[player.id]
		if not user or user.removed then return
		handleRemoveUser player.id, user.local ? user.inputFrame : math.max(user.inputFrame, 0)

	// Applies a parsed RemoveUser event. Runs during live play and again during replays after a
	// rewind, so everything here must be idempotent. The InternalUser and its input bytes are kept
	// (snapshots and replays reference them), only the Player leaves the game
	internal removeUserDeterministically: int removeUserId, int lastFrame, int atFrame
		let user = internalUsers[removeUserId]
		if not user then return
		if not user.removed
			user.removed = true
			user.removedAfterFrame = lastFrame
			// The removal changes certainty and the snapshot pin for past frames - conservatively
			// rewind the next pass to the pinned snapshot (runs once, the flag is idempotent)
			core.markRemoteChange 0
			PeerNetwork.onUserRemoved user
			checkRemovalCutBelowPin user, lastFrame
		else
		if lastFrame < user.removedAfterFrame
			// Amended removal: the original event's cut referenced stream bytes the mesh no longer
			// holds (every storage wiped between the removal and a reload storm) - a permanent
			// certainFrame deadlock, since a removed user only stops binding certainty once their
			// bytes reach removedAfterFrame. The host detects the stalled fetch and re-removes with
			// the cut it actually holds (PeerNetwork tick); applying is lower-only, so replays that
			// re-parse the ORIGINAL event after this one can't raise the cut back (lifecycle seed
			// 246528788). Safe to apply at any time: while the deadlock lasts, every client's
			// snapshot pin is held at frame 0 by the same missing claim, so the conservative
			// rewind below replays the amended timeline from the start
			user.removedAfterFrame = lastFrame
			core.markRemoteChange 0
			print "Removal of player {removeUserId} amended: their inputs now count up to frame {lastFrame}", type:Reaction
			checkRemovalCutBelowPin user, lastFrame
		// The Player only leaves once the removed user's stream has deterministically ended. After
		// a room clock reset the RemoveUser event can land at a frame BEFORE removedAfterFrame (the
		// event is re-based onto the reset timeline, the removed user's old stream stamps are not):
		// removing the Player here while their records are still being parsed would resurrect them
		// as a fresh Player in parseInputs - a permanent ghost no removal ever cleans up again
		// (lifecycle seed 167873016). parseInputs removes the Player once frame > removedAfterFrame
		if atFrame > lastFrame
			removeRemovedPlayer removeUserId, atFrame

	// A removal cut below inputs we already applied AND below the pinned snapshot - the only
	// valid rewind root - means our certified timeline includes inputs the removal just
	// discarded. The conservative rewind above can't reach below the pin, so parsing on would
	// keep the phantom inputs baked in for good: a permanent silent desync against every client
	// whose copy of the removed stream ends at the cut (lifecycle seeds 170692360, 485951509 -
	// the host's gossip merge prevents this for LIVING clients, but a client that applied the
	// tail while partitioned, or restored it from an old stored copy, can still get here).
	// Rebuild from the mesh instead: the reload replays every stream from frame 0 with the
	// persisted cut applied up front (core.applyStoredStream), landing us on the group timeline
	// with our identity and inputs intact
	private checkRemovalCutBelowPin: InternalUser user, int lastFrame
		if user.inputFrame <= lastFrame then return                            // We hold nothing past the cut
		if core.snapshotFrame == -1 or core.snapshotFrame <= lastFrame + 1 then return // The rewind reaches the cut - the replay heals us
		core.log "#fork <{user.id}> Removal cut {lastFrame} lies below their applied claim {user.inputFrame} and the snapshot pin {core.snapshotFrame}: our timeline may include discarded inputs -> rebuilding from the mesh"
		core.rebuildPending = PeerNetwork.forkRecoveryReload "user {user.id}'s removal cut {lastFrame} is below the snapshot pin {core.snapshotFrame}"

	// The deterministic end of a removal: the Player leaves the game. Called when the parse frame
	// is past removedAfterFrame, so no records of the removed user can still follow. Idempotent -
	// replays after a rewind run it again
	private removeRemovedPlayer: int removeUserId, int atFrame
		let player = playersById[removeUserId]
		if not player then return
		players.remove player
		playersById[removeUserId] = null
		updatePlayers
		print "Player {removeUserId} removed at frame {atFrame}", type:Reaction

	// ---------------------------------------------- Touch Down ----------------------------------------------
	
	// Do something when the player touches or clicks within a given area.
	//
	// Example: Draw an OK button and print "Clicked OK" when the user touches it.
	//     app
	//         tick
	//             drawText "OK", position:{0,0}, size:40, color:White
	//             drawRoundedRectangle position:{0,0}, size:{300,100}, color:Blue
	//             
	//             onTouchDown position:{0,0}, size:{300,100}
	//                 print "Clicked OK"
	// Image: onTouchDown1.png
	global importance:0 onTouchDown: Vector2 position                    // The center of the touch area
		                Vector2 size                        // The size of the rectangular touch area
		                implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players  
		                Cursor cursor = Auto                // Change the mouse cursor image when hovering over this area
		                bool showClickableArea = false      // Highlight the clickable area for debugging
		                bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		                HorizontalAlignment align = Center  // The horizontal alignment of the touch area
		                VerticalAlignment valign = Middle   // The vertical alignment of the touch area
		                void(Touch touch) do                // Do this for each touch or click
		if not active then return
		let sizeX = size.x
		let sizeY = size.y || size.x
		let x = align == Left ? position.x : align  == Center ? position.x-sizeX/2 : position.x-sizeX
		let y = valign == Top ? position.y : valign == Middle ? position.y-sizeY/2 : position.y-sizeY
		
		for getTargetedPlayers(by) as player
			for internalUsers[player.id].downTouches as touch
				if !touch.handled and (player.enableTouch or touch.type != Finger)
				and x <= touch.position.x < x + sizeX and y <= touch.position.y < y + sizeY
					do touch
					if markAsHandled then touch.handled = true
						
		if cursor != Auto
			for localUser.movingTouches as touch
				if !touch.handled && x <= touch.position.x < x + sizeX and y <= touch.position.y < y + sizeY
					this.cursor = cursor
				
		// if showClickableArea then drawRectangle position, size, color:{"#ff000080"}, align, valign, layer:10000000

	// Do something when the player touches or clicks within a given circle.
	//
	// Example: Draw the image "Ball" and print "Clicked ball" when the player touches it.
	//     Ball
	//         Vector2 pos
	//         tick
	//             drawImage Ball, pos, size:100
	//             onTouchDown pos, radius:50
	//                 print "Clicked ball"
	// Image: onTouchDown3.png
	global importance:0 onTouchDown: Vector2 position                    // The center of the circle
		                float radius                        // The radius of the circle
		                implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players  
		                Cursor cursor = Auto                // Change the mouse cursor image when hovering over this circle
		                bool showClickableArea = false      // Highlight the clickable area for debugging
		                bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		                void(Touch touch) do                // Do this for each touch or click
		if not active then return
		for getTargetedPlayers(by) as player
			for internalUsers[player.id].downTouches as touch
				if !touch.handled and (player.enableTouch or touch.type != Finger)
				and (touch.position distanceTo position) <= radius
					do touch
					if markAsHandled then touch.handled = true
						
			if cursor != Auto
				for localUser.movingTouches as touch
					if !touch.handled && (touch.position distanceTo position) <= radius
						this.cursor = cursor
				
		// if showClickableArea then drawCircle position, radius*2, color:{"#ff0000b0"}, layer:10000000

	// Do something when the player touches or clicks within a given polygon.
	//
	// Example: Draw a polygon and print "Clicked OK" when the player touches it.
	//     app
	//         tick
	//             let polygon = [{-200,-50}, {-250,50}, {200,50}, {250,-50}]
	//             
	//             drawText "OK", size:50
	//             drawPolygon polygon, color:Blue
	//             
	//             onTouchDown polygon
	//                 print "Clicked OK"
	// Image: onTouchDown4.png
	global importance:0 onTouchDown: Vector2[] points                    // The points that define the clickable polygon
		                Vector2 position = {0,0}            // The position all polygon points are relative to
		                implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players  
		                Cursor cursor = Auto                // Change the mouse cursor image when hovering over this polygon
		                bool showClickableArea = false      // Highlight the clickable area for debugging
		                bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		                void(Touch touch) do                // Do this for each touch or click
		if not active then return			
		for getTargetedPlayers(by) as player
			for internalUsers[player.id].downTouches as touch
				if !touch.handled and (player.enableTouch or touch.type != Finger)
				and touch.position.insidePolygon(points)
					do touch
					if markAsHandled then touch.handled = true
						
			if cursor != Auto
				for localUser.movingTouches as touch
					if !touch.handled && touch.position.insidePolygon(points)
						this.cursor = cursor
				
		// if showClickableArea then drawPolygon position, points, color:{"#ff0000b0"}, layer:10000000
			
	// Do something when the player touches or clicks anywhere on the screen.
	//
	// Example: When the current player instance touches the screen, we print out the exact touch position.
	//     Player
	//         tick
	//             onTouchDown by me
	//                 print "Click at {touch.position}"
	// Image: onTouchDown0.png
	global importance:0 onTouchDown: implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players
		                bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		                void(Touch touch) do                // Do this for each touch or click
		for getTargetedPlayers(by) as player
			for internalUsers[player.id].downTouches as touch
				if !touch.handled and (player.enableTouch or touch.type != Finger)
					do touch
					if markAsHandled then touch.handled = true

	// Do something when the player touches or clicks, even if the event is already handled.
	//
	// Image: onTouchDown0.png
	global importance:0 onTouchDownAny: implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players
		                   void(Touch touch) do                // Do this for each touch or click, even those that are already marked as handled
		if not active then return
		for getTargetedPlayers(by) as player
			for internalUsers[player.id].downTouches as touch
				if player.enableTouch or touch.type != Finger
					do touch

	// ---------------------------------------------- Touch Over ----------------------------------------------
	
	// Do something when the mouse moves over a given area.
	//
	// Example: Draw a blue rectangle. When the current player instance hovers over the rectangle with the mouse, we draw a black outline around it.
	//     Player
	//         tick
	//             let pos = {0,0}
	//             let size = {200,100}
	//             
	//             drawRectangle pos, size, color:Blue
	//             onTouchOver pos, size, by:me
	//                 drawRectangle pos, size+{32,32}, outlineColor:Black, outlineWidth:8
	// Image: onTouchOver.png
	global importance:0 onTouchOver: Vector2 position                    // The center of the touch area
		                Vector2 size                        // The size of the rectangular touch area
		                implicit nocolon Player[] by = null // Only consider the mouse from this player  
		                Cursor cursor = Auto                // Change the mouse cursor image when hovering over this area
		                bool showClickableArea = false      // Highlight the area for debugging
		                bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		                HorizontalAlignment align = Center  // The horizontal alignment of the touch area
		                VerticalAlignment valign = Middle   // The vertical alignment of the touch area
		                void(Touch touch) do                // Do this for each mouse that is hovering over the given area
		if not active then return
		let sizeX = size.x
		let sizeY = size.y || size.x
		let x = align == Left ? position.x : align  == Center ? position.x-sizeX/2 : position.x-sizeX
		let y = valign == Top ? position.y : valign == Middle ? position.y-sizeY/2 : position.y-sizeY
		
		for getTargetedPlayers(by) as player
			for player.touches as touch
				if x <= touch.position.x < x + sizeX and y <= touch.position.y < y + sizeY
					do touch
					
			if cursor != Auto
				for localUser.movingTouches as touch
					if !touch.handled && x <= touch.position.x < x + sizeX and y <= touch.position.y < y + sizeY
						this.cursor = cursor
				
		// if showClickableArea then drawRectangle position, size, color:{"#ff000080"}

			
	// ---------------------------------------------- Touch Move ----------------------------------------------
	
	// Do something when a touch or click moves.
	//
	// onTouchMove is commonly used to check what the pointer is hovering over and highlight it.
	// Since on touch screens we often don't get a touchMove event when the user touches something, we can set 
	// triggeredOnTouchDown to "true" to ensure we always get a touchMove event right before the touchDown.
	// Example: The players can drag PuzzlePieces around with support for multi-touch and multiple players
	//     PuzzlePiece
	//         private Vector2 pos
	//         private Vector2 moveOffset
	//         private Touch moveTouch
	//     	
	//         tick
	//             onTouchDown pos, app.pieceSize
	//                 moveTouch = touch
	//                 moveOffset = pos - touch.position
	//             
	//             onTouchMove moveTouch
	//                 pos = touch.position + moveOffset
	//             	
	//             onTouchUp moveTouch
	//                 moveTouch = null
	// Image: onTouchDown0.png
	global importance:0 onTouchMove: Touch touch                 // Only consider this particular touch or click
		                triggeredOnTouchDown = true // Ensure we also get a touchMove before the touchDown event on touch screens
		                void(Touch touch) do        // Do this for each touch or click
		if not touch or not active then return
		let touchId = touch.id
		let user = internalUsers[touch.by.id]
			if triggeredOnTouchDown
				for user.downTouches
					if .id == touchId
						do .
			for user.movingTouches
				if .id == touchId
					do .
	
	// Do something when a touch or click of the given player moves.
	//
	// Example: Print the touch or mouse position of the current player instance everytime it moves
	//     Player
	//         trick
	//             onTouchMove by me
	//                 print "Touch moved to {touch.position}"
	// Image: onTouchDown0.png
	global importance:0 onTouchMove: implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players
		                triggeredOnTouchDown = true         // Ensure we also get a touchMove before the touchDown event on touch screens
		                void(Touch touch) do                // Do this for each touch or click
		if not active then return
		for getTargetedPlayers(by)
			let user = internalUsers[.id]
				if triggeredOnTouchDown
					for user.downTouches
						do .
				for user.movingTouches
					do .
					
	// ---------------------------------------------- Touch Up ----------------------------------------------
	
	// Do something when a touch or click ends.
	//
	// Example: The players can drag PuzzlePieces around with support for multi-touch and multiple players
	//     PuzzlePiece
	//         private Vector2 pos
	//         private Vector2 moveOffset
	//         private Touch moveTouch
	//     	
	//         tick
	//             onTouchDown pos, app.pieceSize
	//                 moveTouch = touch
	//                 moveOffset = pos - touch.position
	//             
	//             onTouchMove moveTouch
	//                 pos = touch.position + moveOffset
	//             	
	//             onTouchUp moveTouch
	//                 moveTouch = null
	// Image: onTouchDown0.png
	global importance:0 onTouchUp: Touch touch          // Only consider this particular touch or click
		              markAsHandled = true // Mark the touch as handled so it won't trigger more touch events
		              void(Touch touch) do // Do this for each touch or click
		if not touch or not active then return
		let touchId = touch.id
		let user = internalUsers[touch.by.id]
			for user.upTouches
				if .id == touchId
					do .
					Snapshot.autoSave
					if markAsHandled then .handled = true
				
	// Do something when a given player ends a touch or click.
	//
	// Example: Print the touch or mouse position of the current player instance when the touch ends or the mouse button is released
	//     Player
	//         trick
	//             onTouchUp by me
	//                 print "Touch ended at {touch.position}"
	// Image: onTouchDown0.png
	global importance:0 onTouchUp: implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players
		              bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		              void(Touch touch) do                // Do this for each touch or click
		if not active then return
		for getTargetedPlayers(by)
			for internalUsers[.id].upTouches
				if !.handled
					do .
					Snapshot.autoSave
					
	// Do something when the player ends a touch or click within a given area
	//
	// Example: Draw an OK button and print "Clicked OK" when the player ends a touch or releases the mouse button over this button
	//     app
	//         tick
	//             drawText "OK", position:{0,0}, size:40, color:White
	//             drawRoundedRectangle position:{0,0}, size:{300,100}, color:Blue
	//             
	//             onTouchUp position:{0,0}, size:{300,100}
	//                 print "Clicked OK"
	// Image: onTouchDown1.png
	global importance:0 onTouchUp: Vector2 position                    // The center of the touch area
		              Vector2 size                        // The size of the rectangular touch area
		              implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players
		              bool showClickableArea = false      // Highlight the clickable area for debugging
		              bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		              void(Touch touch) do                // Do this for each touch or click
		if not active then return
		for getTargetedPlayers(by) as player
			for internalUsers[player.id].upTouches as touch
				if !touch.handled and position.x <= touch.position.x < position.x + size.x and position.y <= touch.position.y < position.y + size.y
					do touch
					if markAsHandled then touch.handled = true
					Snapshot.autoSave
						
		// if showClickableArea then drawRectangle position, size, color:{"#ff000080"}

	// Do something when the player ends a touch or click within a given circle.
	//
	// Example: Draw the image "Ball" and print "Clicked ball" when the player ends a touch or releases the mouse button over this button
	//     Ball
	//         Vector2 pos
	//         tick
	//             drawImage Ball, pos, size:100
	//             onTouchUp pos, radius:50
	//                 print "Clicked ball"
	// Image: onTouchDown3.png
	global importance:0 onTouchUp: Vector2 position                    // The center of the circle
		              float radius                        // The radius of the circle
		              implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players  
		              Cursor cursor = Auto                // Change the mouse cursor image when hovering over this area
		              bool showClickableArea = false      // Highlight the clickable area for debugging
		              bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		              void(Touch touch) do                // Do this for each touch or click
		if not active then return
		for getTargetedPlayers(by) as player
			for internalUsers[player.id].upTouches as touch
				if !touch.handled && (touch.position distanceTo position) <= radius
					do touch
					if markAsHandled then touch.handled = true
					Snapshot.autoSave
					
			if cursor != Auto
				for localUser.movingTouches as touch
					if !touch.handled && (touch.position distanceTo position) <= radius
						this.cursor = cursor
				
		// if showClickableArea then drawCircle position, radius*2, color:{"#ff000080"}
						
	// ---------------------------------------------- Scroll ----------------------------------------------
	
	// Do something when a player scrolls with the touch pad or mouse wheel
	global onScroll: implicit nocolon Player[] by = null // Only consider events by this player or list of players
		             void(ScrollEvent event) do          // Do this for each event
		if not active then return
		for getTargetedPlayers(by)
			for internalUsers[.id].wheelEvents
				do .
	
	// Do something when a player scrolls with the touch pad or mouse wheel over a rectangle
	global onScrolllWithin: Vector2 position                    // The center of the rectangle
		                    Vector2 size                        // The size of the rectangle
		                    implicit nocolon Player[] by = null // Only consider events by this player or list of players
		                    bool showClickableArea = false      // Highlight the rectangle for debugging
		                    bool markAsHandled = true           // Mark the touch as handled so it won't trigger more events
		                    void(ScrollEvent event) do          // Do this for each event
		if not active then return
		for getTargetedPlayers(by)
			for internalUsers[.id].wheelEvents
				if !.handled and position.x <= .position.x < position.x + size.x and position.y <= .position.y < position.y + size.y
					do .
					if markAsHandled then .markAsHandled
						
		// if showClickableArea then drawRectangle position, size, Red
			
	// ---------------------------------------------- Text Input ----------------------------------------------
	
	visible bool isTextInputActive = false
	
	private js object getOrCreateInputField
		if(!window._input) {
			window._input = document.createElement("input")
			_input.type = "text"
			_input.style.position = "absolute"
			_input.style.left = "-10000px" 
			_input.style.width = "1px"
			_input.style.height = "1px"
			_input.style.fontSize = "1px"
			_input.style.backgroundColor = "#000000"
			_input.oninput = e => input.handleTextInput(7, _input.value)
			_input.onblur = e => {
				if(input.isTextInputActive) {
					_input.focus()
				}
			}
			document.body.appendChild(_input)
		}
		return _input
				
	js void startTextInput: string initalValue = null, int forUser = -1
		if(forUser == -1 || input.localUser?.id == forUser) {
			let field = input.getOrCreateInputField()
			if(initalValue != null) { 
				field.value = initalValue
			}
			_input.focus()
			field.isTextInputActive = true
		}
		
	js void stopTextInput
		input.isTextInputActive = false
		
	js void setTextInput: string value
		let field = input.getOrCreateInputField()
		field.value = value
		field.handleTextInput(7, value)
		
	js void updateCursor
		// document.body.style.cursor = (input.showPointers == 2 && system.playMode == 4 ? "none" : input.cursor)
		document.body.style.cursor = input.cursor

	onTextComposition: void(string characters) do
		for internalUsers as user if user
			for user.textCompositions as characters
				do characters
				
	onTextInput: implicit nocolon Player[] by = null // Only consider keys pressed by this player or list of players
		         void(string textInput) do           // Do this for each key that is pressed
		for getTargetedPlayers(by)
			for internalUsers[.id].textInputs as textInput
				do textInput
				
	// ---------------------------------------------- Keys ----------------------------------------------
	
	// Do something when a player presses a key
	global importance:0 onKeyDown: Key modifier 
		              Key key                             // The key that will trigger the event
		              implicit nocolon Player[] by = null // Only consider keys pressed by this player or list of players
		              void(Key key, Player pressedBy, bool cmdOrCtrl, bool alt, bool shift) do  // Do this for each key that is pressed
		for getTargetedPlayers(by) as player
			for internalUsers[.id].downKeys
				if . == key
					bool actualCmdOrCtrl, actualShift, actualAlt
					for player.keysCurrentlyDown
						switch .
							LeftMetaKey:  actualCmdOrCtrl = true
							RightMetaKey: actualCmdOrCtrl = true
							Ctrl:         actualCmdOrCtrl = true
							Alt:          actualAlt = true
							Shift:        actualShift = true
								
					if (modifier == CmdOrCtrl and actualCmdOrCtrl and !actualShift and !actualAlt)  
					or (modifier == Shift     and actualShift and !actualCmdOrCtrl and !actualAlt)
					or (modifier == Alt       and actualAlt and !actualCmdOrCtrl and !actualShift)
						do key, player, actualCmdOrCtrl, actualAlt, actualShift
				
	// Do something when a player presses a key
	global importance:0 onKeyDown: Key key                             // The key that will trigger the event
		              bool cmdOrCtrl = false
		              bool alt = false
		              bool shift = false
		              implicit nocolon Player[] by = null // Only consider keys pressed by this player or list of players
		              void(Key key, Player pressedBy, bool cmdOrCtrl, bool alt, bool shift) do  // Do this for each key that is pressed
		for getTargetedPlayers(by) as player
			for internalUsers[.id].downKeys
				if . == key
					bool actualCmdOrCtrl, actualShift, actualAlt
					for player.keysCurrentlyDown
						switch .
							LeftMetaKey:  actualCmdOrCtrl = true
							RightMetaKey: actualCmdOrCtrl = true
							Ctrl:         actualCmdOrCtrl = true
							Alt:          actualAlt = true
							Shift:        actualShift = true
								
					if actualCmdOrCtrl == cmdOrCtrl and actualShift == shift and actualAlt == alt
						do key, player, actualCmdOrCtrl, actualAlt, actualShift
				
	// Do something when a player presses a key
	global importance:0 onKeyDown: implicit nocolon Player[] by = null // Only consider keys pressed by this player or list of players
		              void(Key key, Player pressedBy, bool cmdOrCtrl, bool alt, bool shift) do  // Do this for each key that is pressed
		for getTargetedPlayers(by) as player
			for internalUsers[.id].downKeys as key
				bool actualCmdOrCtrl, actualShift, actualAlt
				for player.keysCurrentlyDown
					switch .
						LeftMetaKey:  actualCmdOrCtrl = true
						RightMetaKey: actualCmdOrCtrl = true
						Ctrl:         actualCmdOrCtrl = true
						Alt:          actualAlt = true
						Shift:        actualShift = true
				do key, player, actualCmdOrCtrl, actualAlt, actualShift
				
	// Do something when a player releases a key
	global importance:0 onKeyUp: implicit nocolon Player[] by = null // Only consider keys released by this player or list of players
		            void(Key key, Player pressedBy) do  // Do this for each key that is released
		for getTargetedPlayers(by) as player
			for internalUsers[.id].upKeys as key
				do key, player
					
	// Do something when a player types a character
	global importance:0 onType: implicit nocolon Player[] by = null         // Only consider characters typed by this player or list of players
		           void(string character, Player pressedBy) do // Do this for each character that is typed
		for getTargetedPlayers(by) as player
			for internalUsers[.id].pressedKeys as character
				do character, player
			
	// Returns true if a given key is currently held down
	isKeyDown: Key key          // The key to check
		       Player by = null // Only consider keys pressed by this player 
		if (core.mode == Connected || core.simulateConnection) && by
			let player = playersById[by.id]
				return player.keysCurrentlyDown.includes key
		else
			return players.any.keysCurrentlyDown.includes key
		return false
		
	// ---------------------------------------------- Navigate ----------------------------------------------
	
	// Do something when the user navigates back or forward in the browser	
	global onNavigate: implicit nocolon Player[] by = null // Only consider events by this player or list of players
		               void(string url) do                 // Do this for each event
		for getTargetedPlayers(by) as player
			for internalUsers[.id].navigations as url
				do url

// ---------------------------------------------- Modern Input ----------------------------------------------

enum InputButton
	A
	B
	X
	Y

	LeftBumper
	RightBumper
	LeftTrigger
	RightTrigger
	Select
	Start
	LeftStickButton
	RightStickButton

	Up
	Down
	Left
	Right

	LeftMouseButton
	MiddleMouseButton
	RightMouseButton
		
input
	const int inputButtonCount = 19

	// Returns true if the player has just pressed the given button this frame (it was not pressed in the previous frame).
	global justPressed: InputButton button, int player = 0
		if button >= LeftMouseButton then player = 0
		return internalUsers[player].justPressed[button]

	// Returns true if the player is currently pressing the given button.
	global isPressed: InputButton button, int player = 0
		if button >= LeftMouseButton then player = 0
		return internalUsers[player].isPressed[button]
	
	// Returns true if the player has just released the given button this frame (it was pressed in the previous frame).
	global justReleased: InputButton button, int player = 0
		if button >= LeftMouseButton then player = 0
		return internalUsers[player].justReleased[button]

	// Returns the current position of the player's pointer, which can be the mouse cursor, a touch or a pen.
	// player is the playerIndex; pointer positions are part of the synced input stream, so remote
	// players' pointers are available and deterministic
	global Vector2 getPointer: int player = 0
		let requestedPlayer = players[player]
			return requestedPlayer.pointerPosition
		return {0,0}

	// Returns the current scroll delta of the player's input device. player is the playerIndex
	global Vector2 getScrollDelta: int player = 0
		let requestedPlayer = players[player]
			return internalUsers[requestedPlayer.id].scrollDelta
		return {0,0}
