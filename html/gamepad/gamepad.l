unit html
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
	