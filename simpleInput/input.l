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
	
enum InputType: None, TouchDown, TouchMove, TouchUp, Scroll, KeyDown, KeyUp, TextInput, Stick, Trigger, Grip, ButtonDown, ButtonUp, ControllerTransform, HeadTransform, DeviceRotation, Join, SetState, Navigate, Gamepad, String, Json, Object

internal transient InternalGamepadButton
	bool pressed, touched
	float value
	
internal transient InternalGamepad
	float[] axes
	InternalGamepadButton[] buttons
	string id, mapping

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

InternalUser
	bool[19] isPressing
	bool[19] wasPressing
	Vector2 pointerPos
	Vector2 scrollDelta
	Vector2 leftStick, rightStick

	finishFrame
		for isPressing.length as i
			wasPressing[i] = isPressing[i]
		scrollDelta = {0,0}

global transient input
	transient visible InternalUser[] internalUsers

	init
		initHandlers

	private js void initHandlers
		window.onpointerdown = e => input.onPointerDown(e.pageX, e.pageY, e.button);
		window.onpointermove = e => input.onPointerMove(e.pageX, e.pageY, e.button);
		window.onpointerup = e => input.onPointerUp(e.pageX, e.pageY, e.button);
		window.oncontextmenu = e => e.preventDefault() // Prevent context menu on right click
		window.onkeydown = e => {
			let keyCode = e.keyCode
			let key = e.key
		}
		window.onkeyup = e => {
		}
		if(!window._isWheelHandlerSet) {
			window._isWheelHandlerSet = true
			window.addEventListener('wheel', e => {
				e.preventDefault();
				e.stopPropagation();
				input.handleWheelEvent(e.pageX, e.pageY, e.deltaX, e.deltaY, e.ctrlKey)
				return false;			
			}, {passive: false})
		}

	internal onPointerDown: float x, float y, int button
		let pos = internalUsers[0].pointerPos
		print type:Touch, "Clicked {pos}, button:{button}"
		internalUsers[0].isPressing[InputButton.LeftMouseButton + button] = true

	internal onPointerMove: float x, float y, int button
		internalUsers[0].pointerPos = graphics.screen.getPixelPos {x, y}
		
	internal onPointerUp: float x, float y, int button
		internalUsers[0].isPressing[InputButton.LeftMouseButton + button] = false

	private handleWheelEvent: float x, float y, float deltaX, float deltaY, bool isPinch
		internalUsers[0].scrollDelta = {deltaX, deltaY}

	internal handleKeyEvent: InputType inputType, Key keyCode, string key

	private inline js InternalGamepad[] getGamepads() navigator.getGamepads()
	internal updateGamepads
		InternalGamepad[] internalGamepads = getGamepads
		if internalGamepads == null or internalGamepads.length == 0 then return
			
		int index
		for internalGamepads as internalGamepad
			if internalGamepad
				let user = internalUsers[index]
				for 16 user.isPressing[i] = internalGamepad.buttons[i].pressed
				user.leftStick	= {x: internalGamepad.axes[0], y: internalGamepad.axes[1]}
				user.rightStick	= {x: internalGamepad.axes[2], y: internalGamepad.axes[3]}
				index++

	// Returns true if the player has just pressed the given button this frame (it was not pressed in the previous frame).
	global justPressed: InputButton button, int player = 0
		if button >= LeftMouseButton then player = 0
		let user = internalUsers[player]
		return user.isPressing[button] and not user.wasPressing[button]

	// Returns true if the player is currently pressing the given button.
	global isPressed: InputButton button, int player = 0
		if button >= LeftMouseButton then player = 0
		let user = internalUsers[player]
		return user.isPressing[button]
	
	// Returns true if the player has just released the given button this frame (it was pressed in the previous frame).
	global justReleased: InputButton button, int player = 0
		if button >= LeftMouseButton then player = 0
		let user = internalUsers[player]
		return not user.isPressing[button] and user.wasPressing[button]

	// Returns the current position of the player's pointer, which can be the mouse cursor, a touch or a pen.
	global getPointer: int player = 0
		player = 0
		return internalUsers[player].pointerPos

	// Returns the current scroll delta of the player's input device.
	global getScrollDelta: int player = 0
		player = 0
		return internalUsers[player].scrollDelta
