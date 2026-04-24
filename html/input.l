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

	Gamepad[] gamepads = [{}]

	Gamepad[] queryGamepads
		InternalGamepad[] internalGamepads = getGamepads
		if internalGamepads == null or internalGamepads.length == 0 then return
		for internalGamepads as internalGamepad
			if internalGamepad
				let gp = gamepads[i]
				if not gp then gamepads[i] = gp = {}

				gp.id	= .id
				gp.leftStick	= {x: internalGamepad.axes[0], y: internalGamepad.axes[1]}
				gp.inMotion	= gp.leftStick.length > Gamepad.deadZone
				gp.type	= internalGamepad.id.contains("054c") or internalGamepad.id.contains("810") ? PlayStation : internalGamepad.id.contains("retro") ? Nintendo : Xbox

				// Controller button names
				switch gp.type
					Nintendo
						gp.A.assign index:0	name:"A" image:ButtonA
						gp.B.assign index:1	name:"B" image:ButtonB
						gp.X.assign index:2	name:"X" image:ButtonX
						gp.Y.assign index:3	name:"Y" image:ButtonY
						
						// gp.A.assign index:1	name:"B" image:ButtonB
						// gp.B.assign index:0	name:"A" image:ButtonA
						// gp.X.assign index:3	name:"Y" image:ButtonY
						// gp.Y.assign index:2	name:"X" image:ButtonX

					PlayStation
						gp.A.assign index:0	name:"X"	image:ButtonCross
						gp.B.assign index:1	name:"O"	image:ButtonCircle
						gp.X.assign index:2	name:"SQUARE"	image:ButtonSquare
						gp.Y.assign index:3	name:"TRIANGLE"	image:ButtonTriangle

					Xbox
						gp.A.assign index:0	name:"A" image:ButtonA
						gp.B.assign index:1	name:"B" image:ButtonB
						gp.X.assign index:2	name:"X" image:ButtonX
						gp.Y.assign index:3	name:"Y" image:ButtonY

				// Update button states
				gp.buttons.each.wasPreviouslyPressed = .isPressed
				for gp.buttons
					.isPressed = internalGamepad.buttons[.index].pressed

		return gamepads
	
internal DigitalButton
	string name
	int index
	Key key
	Image image
	
	bool isPressed
	bool wasJustPressed	=> isPressed and not wasPreviouslyPressed
	bool wasJustReleased	=> not isPressed and wasPreviouslyPressed
	internal bool wasPreviouslyPressed
	
	toString => name

	internal assign: int index, string name, Image image
		this.index = index
		this.name = name
		this.image = image
	
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
	
enum GamepadButton: A, B, X, Y, LeftBumper, RightBumper, LeftTrigger, RightTrigger, Select, Start, LeftStickButton, RightStickButton, Up, Down, Left, Right
	
enum GamepadType: Keyboard, Xbox, PlayStation, Nintendo
internal Gamepad
	const deadZone = .1
	
	// Sticks
	Vector2 leftStick
	Vector2 rightStick
	
	// Buttons
	DigitalButton A	= {name:"A"	index:0	image:ButtonA}
	DigitalButton B	= {name:"B"	index:1	image:ButtonB}
	DigitalButton X	= {name:"X"	index:2	image:ButtonX}
	DigitalButton Y	= {name:"Y"	index:3	image:ButtonY}
	DigitalButton LeftBumper	= {name:"LeftBumper"	index:4}
	DigitalButton RightBumper	= {name:"RightBumper"	index:5}
	DigitalButton LeftTrigger 	= {name:"LeftTrigger"	index:6}
	DigitalButton RightTrigger 	= {name:"RightTrigger"	index:7}
	DigitalButton start	= {name:"Start"	index:8}
	DigitalButton select	= {name:"Select"	index:9}
	DigitalButton leftStickButton	= {name:"Left Stick"	index:10}
	DigitalButton rightStickButton	= {name:"Right Stick"	index:11}
	DigitalButton up	= {name:"Up"	index:12}
	DigitalButton down	= {name:"Down"	index:13}
	DigitalButton left	= {name:"Left"	index:14}
	DigitalButton right	= {name:"Right"	index:15}
	
	DigitalButton[] buttons = [
		A, B, X, Y,
		LeftBumper, RightBumper, LeftTrigger, RightTrigger,
		start, select,
		leftStickButton, rightStickButton,
		up, right, down, left
	]
	
	bool inMotion
	GamepadType type
	string id
	