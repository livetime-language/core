enum Key
	None         =   0
	Backspace    =   8
	Tab          =   9
	Enter        =  13
	Shift        =  16
	Ctrl         =  17
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
	
KeyListener
	Key key
	void(Key key) do
	
// Phase of a touch or a click
enum TouchPhase: Still, Down, Move, Up, Canceled
		
enum TouchType: Left, Middle, Right, Touch, Pen

// A touch or a click
class Touch
	int id            // A unique identifier for the pointer causing the event (for example, a finger)
	TouchPhase phase  // Still, Down, Move, Up
	TouchType type    // Left, Middle, Right, Touch, Pen
	Vector2 position  // The position of the touch reletive to the page
	string touchedId  // The id of the touched html element
	bool shiftKey     // Is the shift key down?
	bool altKey       // Is the alt key down?
	bool ctrlKey      // Is the control key down?
	bool metaKey      // Is the meta key ("Command" on Mac, "Windows" on Windows) down?
	
unit html
	KeyListener[] keyDownListeners
	void() defaultButtonToTriggerWithEnterKey = null
		
	js void initGlobalEventHandlers
		document.onkeydown = ev => {
			if(ev.key == "F10") { 
				Platform.toggleSmallScreen();
			} else if(ev.key == "Enter" && html.defaultButtonToTriggerWithEnterKey != null) {
				html.defaultButtonToTriggerWithEnterKey.invoke(ev)
				ev.preventDefault();
				ev.stopPropagation();
				return false;
			}
			for(let listener of html.keyDownListeners) {
				if(ev.keyCode == listener.key) {
					listener.do.invoke(ev.keyCode)
					ev.preventDefault();
					ev.stopPropagation();
					return false;
				}
			}
		}

	clearGlobalEventHandlers
		if(!keyDownListeners) keyDownListeners = []
		keyDownListeners.clear
	
	onKeyDown: Key key
		       stored void(Key key) do
		keyDownListeners.add {key, do}

	private inline js InternalGamepad[] getGamepads() navigator.getGamepads()

	Gamepad[] gamepads

	Gamepad[] queryGamepads
		InternalGamepad[] internalGamepads = getGamepads
		if internalGamepads == null or internalGamepads.length == 0 then return
		for internalGamepads as internalGamepad
			if internalGamepad
				let gp = gamepads[i]
				if not gp then gamepads[i] = gp = {}
				gp.buttons.each.wasPreviouslyPressed = .isPressed

				gp.leftStick = {x: internalGamepad.axes[0], y: internalGamepad.axes[1]}
				gp.A.isPressed	= internalGamepad.buttons[0].pressed
				gp.B.isPressed	= internalGamepad.buttons[1].pressed
				gp.X.isPressed	= internalGamepad.buttons[2].pressed
				gp.Y.isPressed	= internalGamepad.buttons[3].pressed
				gp.L1.isPressed	= internalGamepad.buttons[4].pressed
				gp.R1.isPressed	= internalGamepad.buttons[5].pressed
				gp.L2.isPressed	= internalGamepad.buttons[6].pressed
				gp.R2.isPressed	= internalGamepad.buttons[7].pressed
				gp.select.isPressed	= internalGamepad.buttons[8].pressed
				gp.start.isPressed	= internalGamepad.buttons[9].pressed
				gp.leftStickButton.isPressed	= internalGamepad.buttons[10].pressed
				gp.rightStickButton.isPressed	= internalGamepad.buttons[11].pressed
				gp.up.isPressed	= internalGamepad.buttons[12].pressed
				gp.down.isPressed	= internalGamepad.buttons[13].pressed
				gp.left.isPressed	= internalGamepad.buttons[14].pressed
				gp.right.isPressed	= internalGamepad.buttons[15].pressed
				gp.type	= internalGamepad.id.contains("054c") or internalGamepad.id.contains("810") ? PlayStation : Xbox
				gp.inMotion	= gp.leftStick.length > Gamepad.deadZone

				// Controller button names
				if gp.type == Xbox
					gp.A.name = "A"
					gp.B.name = "B"
					gp.X.name = "X"
					gp.Y.name = "Y"
				else
					gp.A.name = "X"
					gp.B.name = "O"
					gp.X.name = "SQUARE"
					gp.Y.name = "TRIANGLE"
		return gamepads
	
internal DigitalButton
	string name
	Key key
	
	bool isPressed
	bool wasJustPressed	=> isPressed and not wasPreviouslyPressed
	bool wasJustReleased	=> not isPressed and wasPreviouslyPressed
	internal bool wasPreviouslyPressed
	
	toString => name
	
internal transient immutable struct ControllerButtonPlayerAndIndex
	int userId
	int buttonIndex
	
internal transient immutable InternalGamepadButton
	bool pressed, touched
	float value
	
internal transient immutable InternalGamepad
	ImmutableList<float> axes
	ImmutableList<InternalGamepadButton> buttons
	string id, mapping
	
enum GamepadButton: A, B, X, Y, L1, R1, L2, R2, Select, Start, LeftStickButton, RightStickButton, Up, Down, Left, Right
	
enum GamepadType: Keyboard, Xbox, PlayStation
internal Gamepad
	const deadZone = .1
	
	// Sticks
	Vector2 leftStick
	Vector2 rightStick
	
	// Buttons
	DigitalButton A = {}
	DigitalButton B = {}
	DigitalButton X = {}
	DigitalButton Y = {}

	DigitalButton L1 = {name:"L1"}
	DigitalButton R1 = {name:"R1"}
	DigitalButton L2 = {name:"L2"}
	DigitalButton R2 = {name:"R2"}
	
	DigitalButton start	= {name:"Start"}
	DigitalButton select	= {name:"Select"}

	DigitalButton leftStickButton	= {name:"Left Stick"}
	DigitalButton rightStickButton	= {name:"Right Stick"}
	
	// DPad
	DigitalButton up	= {name:"Up"}
	DigitalButton right	= {name:"Right"}
	DigitalButton down	= {name:"Down"}
	DigitalButton left	= {name:"Left"}
	
	DigitalButton[] buttons = [
		A, B, X, Y,
		L1, R1, L2, R2,
		start, select,
		leftStickButton, rightStickButton,
		up, right, down, left
	]
	
	bool inMotion
	GamepadType type
	