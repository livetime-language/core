enum GamepadType: Keyboard, Xbox, PlayStation, Nintendo
internal transient class InternalUser
	// Modern Input
	visible int[] pressedAtFrame, releasedAtFrame
	int[] handledAtFrame
	Vector2 pointerPosition, scrollDelta
	string focus, prevFocus
	GamepadType gamepadType
	
internal transient immutable InternalGamepadButton
	bool pressed, touched
	float value
	
internal transient immutable InternalGamepad
	ImmutableList<float> axes
	ImmutableList<InternalGamepadButton> buttons
	string id, mapping
		
enum InputType: Keyboard, Pointer, Gamepad

class Input
	InputType type
	string code
	string character
	string name, alternativeName
	Input parent
	int index
	
	Input
		if not name then name = character or code.toLowerCase

	inline string toString() this.character

	// Gamepad
	global const A	= {type:Gamepad,	code:"A",	name:"gamepada"}
	global const B	= {type:Gamepad,	code:"B",	name:"gamepadb"}
	global const X	= {type:Gamepad,	code:"X",	name:"gamepadx"}
	global const Y	= {type:Gamepad,	code:"Y",	name:"gamepady"}
	global const LeftBumper	= {type:Gamepad,	code:"LeftBumper"}
	global const RightBumper	= {type:Gamepad,	code:"RightBumper"}
	global const LeftTrigger	= {type:Gamepad,	code:"LeftTrigger"}
	global const RightTrigger	= {type:Gamepad,	code:"RightTrigger"}
	global const Select	= {type:Gamepad,	code:"Select"}
	global const Start	= {type:Gamepad,	code:"Start"}
	global const LeftStickButton	= {type:Gamepad,	code:"LeftStickButton"}
	global const RightStickButton	= {type:Gamepad,	code:"RightStickButton"}
	global const Up	= {type:Gamepad,	code:"Up",	name:"gamepadup"}
	global const Down	= {type:Gamepad,	code:"Down",	name:"gamepaddown"}
	global const Left	= {type:Gamepad,	code:"Left",	name:"gamepadleft"}
	global const Right	= {type:Gamepad,	code:"Right",	name:"gamepadright"}
	
	// Pointer
	global const Input Pointer	= {type:Pointer}
	global const LeftMouseButton	= {type:Pointer,	code:"LeftMouseButton", parent:Pointer}
	global const MiddleMouseButton	= {type:Pointer,	code:"MiddleMouseButton"}
	global const RightMouseButton	= {type:Pointer,	code:"RightMouseButton"}

	// Function row
	global const Escape	= {type:Keyboard,	code:"Escape", name:"esc", alternativeName:"escape"}
	global const F1	= {type:Keyboard,	code:"F1"}
	global const F2	= {type:Keyboard,	code:"F2"}
	global const F3	= {type:Keyboard,	code:"F3"}
	global const F4	= {type:Keyboard,	code:"F4"}
	global const F5	= {type:Keyboard,	code:"F5"}
	global const F6	= {type:Keyboard,	code:"F6"}
	global const F7	= {type:Keyboard,	code:"F7"}
	global const F8	= {type:Keyboard,	code:"F8"}
	global const F9	= {type:Keyboard,	code:"F9"}
	global const F10	= {type:Keyboard,	code:"F10"}
	global const F11	= {type:Keyboard,	code:"F11"}
	global const F12	= {type:Keyboard,	code:"F12"}
	const PrintScreen	= {type:Keyboard,	code:"PrintScreen"}
	const ScrollLock	= {type:Keyboard,	code:"ScrollLock"}
	const Pause	= {type:Keyboard,	code:"Pause"}

	// Number row
	const Backquote	= {type:Keyboard,	code:"Backquote",	character:"`", alternativeName:"backquote"}
	const Digit1	= {type:Keyboard,	code:"Digit1",	character:"1"}
	const Digit2	= {type:Keyboard,	code:"Digit2",	character:"2"}
	const Digit3	= {type:Keyboard,	code:"Digit3",	character:"3"}
	const Digit4	= {type:Keyboard,	code:"Digit4",	character:"4"}
	const Digit5	= {type:Keyboard,	code:"Digit5",	character:"5"}
	const Digit6	= {type:Keyboard,	code:"Digit6",	character:"6"}
	const Digit7	= {type:Keyboard,	code:"Digit7",	character:"7"}
	const Digit8	= {type:Keyboard,	code:"Digit8",	character:"8"}
	const Digit9	= {type:Keyboard,	code:"Digit9",	character:"9"}
	const Digit0	= {type:Keyboard,	code:"Digit0",	character:"0"}
	const Minus	= {type:Keyboard,	code:"Minus",	character:"-", alternativeName:"minus"}
	const Equal	= {type:Keyboard,	code:"Equal",	character:"=", alternativeName:"equal"}
	global const Backspace	= {type:Keyboard,	code:"Backspace"}

	// Top letter row
	global const Tab	= {type:Keyboard,	code:"Tab",	character:"\t", name:"tab", alternativeName:"tabulator"}
	const KeyQ	= {type:Keyboard,	code:"KeyQ",	character:"q"}
	const KeyW	= {type:Keyboard,	code:"KeyW",	character:"w"}
	const KeyE	= {type:Keyboard,	code:"KeyE",	character:"e"}
	const KeyR	= {type:Keyboard,	code:"KeyR",	character:"r"}
	const KeyT	= {type:Keyboard,	code:"KeyT",	character:"t"}
	const KeyY	= {type:Keyboard,	code:"KeyY",	character:"y"}
	const KeyU	= {type:Keyboard,	code:"KeyU",	character:"u"}
	const KeyI	= {type:Keyboard,	code:"KeyI",	character:"i"}
	const KeyO	= {type:Keyboard,	code:"KeyO",	character:"o"}
	const KeyP	= {type:Keyboard,	code:"KeyP",	character:"p"}
	const BracketLeft	= {type:Keyboard,	code:"BracketLeft",	character:"[",	alternativeName:"bracketleft"}
	const BracketRight	= {type:Keyboard,	code:"BracketRight",	character:"]",	alternativeName:"bracketright"}
	const Backslash	= {type:Keyboard,	code:"Backslash",	character:"\\",	alternativeName:"backslash"}

	// Home row
	global const CapsLock	= {type:Keyboard,	code:"CapsLock"}
	const KeyA	= {type:Keyboard,	code:"KeyA",	character:"a"}
	const KeyS	= {type:Keyboard,	code:"KeyS",	character:"s"}
	const KeyD	= {type:Keyboard,	code:"KeyD",	character:"d"}
	const KeyF	= {type:Keyboard,	code:"KeyF",	character:"f"}
	const KeyG	= {type:Keyboard,	code:"KeyG",	character:"g"}
	const KeyH	= {type:Keyboard,	code:"KeyH",	character:"h"}
	const KeyJ	= {type:Keyboard,	code:"KeyJ",	character:"j"}
	const KeyK	= {type:Keyboard,	code:"KeyK",	character:"k"}
	const KeyL	= {type:Keyboard,	code:"KeyL",	character:"l"}
	const Semicolon	= {type:Keyboard,	code:"Semicolon",	character:";",	alternativeName:"semicolon"}
	const Quote	= {type:Keyboard,	code:"Quote",	character:"'",	alternativeName:"quote"}
	global const Enter	= {type:Keyboard,	code:"Enter",	character:"\n", name:"enter", alternativeName:"return"}

	// Bottom letter row
	global const Shift	= {type:Keyboard}
	const ShiftLeft	= {type:Keyboard,	code:"ShiftLeft",	parent:Shift}
	const IntlBackslash	= {type:Keyboard,	code:"IntlBackslash"} // The extra key European (ISO) keyboards have between the left Shift and Z
	const KeyZ	= {type:Keyboard,	code:"KeyZ",	character:"z"}
	const KeyX	= {type:Keyboard,	code:"KeyX",	character:"x"}
	const KeyC	= {type:Keyboard,	code:"KeyC",	character:"c"}
	const KeyV	= {type:Keyboard,	code:"KeyV",	character:"v"}
	const KeyB	= {type:Keyboard,	code:"KeyB",	character:"b"}
	const KeyN	= {type:Keyboard,	code:"KeyN",	character:"n"}
	const KeyM	= {type:Keyboard,	code:"KeyM",	character:"m"}
	const Comma	= {type:Keyboard,	code:"Comma",	character:",",	alternativeName:"comma"}
	const Period	= {type:Keyboard,	code:"Period",	character:".",	alternativeName:"period"}
	const Slash	= {type:Keyboard,	code:"Slash",	character:"/",	alternativeName:"slash"}
	const ShiftRight	= {type:Keyboard,	code:"ShiftRight",	parent:Shift}

	// Bottom row
	global const CmdOrCtrl	= {type:Keyboard,	name:"cmdorctrl",	alternativeName:"commandorcontrol"}
	global const Ctrl	= {type:Keyboard,	name:"ctrl",	alternativeName:"control"}
	global const Meta	= {type:Keyboard,	name:"meta",	alternativeName:"super"}
	global const Alt	= {type:Keyboard,	name:"alt",	alternativeName:"option"}
	const CtrlLeft	= {type:Keyboard,	code:"ControlLeft",	alternativeName:"ctrlleft",	parent:Ctrl}
	const MetaLeft	= {type:Keyboard,	code:"MetaLeft",	alternativeName:"metaleft",	parent:Meta}
	const AltLeft	= {type:Keyboard,	code:"AltLeft",	alternativeName:"altleft",	parent:Alt}
	global const Space	= {type:Keyboard,	code:"Space",	character:" ", name:"space"}
	const AltRight	= {type:Keyboard,	code:"AltRight",	alternativeName:"altright",	parent:Alt}
	const MetaRight	= {type:Keyboard,	code:"MetaRight",	alternativeName:"metaright",	parent:Meta}
	const ContextMenu	= {type:Keyboard,	code:"ContextMenu"}
	const CtrlRight	= {type:Keyboard,	code:"ControlRight",	alternativeName:"ctrlright",	parent:Ctrl}

	// Navigation
	const Insert	= {type:Keyboard,	code:"Insert"}
	const Home	= {type:Keyboard,	code:"Home"}
	const PageUp	= {type:Keyboard,	code:"PageUp"}
	const Delete	= {type:Keyboard,	code:"Delete"}
	const End	= {type:Keyboard,	code:"End"}
	const PageDown	= {type:Keyboard,	code:"PageDown"}
	global const ArrowUp	= {type:Keyboard,	code:"ArrowUp",	name:"up",	alternativeName:"arrowup"}
	global const ArrowLeft	= {type:Keyboard,	code:"ArrowLeft",	name:"left",	alternativeName:"arrowleft"}
	global const ArrowDown	= {type:Keyboard,	code:"ArrowDown",	name:"down",	alternativeName:"arrowdown"}
	global const ArrowRight	= {type:Keyboard,	code:"ArrowRight",	name:"right",	alternativeName:"arrowright"}

	// Numpad
	const NumLock	= {type:Keyboard,	code:"NumLock"}
	const NumpadDivide	= {type:Keyboard,	code:"NumpadDivide",	character:"/", name:"numpaddivide",	alternativeName:"numpadslash"}
	const NumpadMultiply	= {type:Keyboard,	code:"NumpadMultiply",	character:"*", name:"numpadmultiply",	alternativeName:"numpadasterisk"}
	const NumpadSubtract	= {type:Keyboard,	code:"NumpadSubtract",	character:"-", name:"numpadsubtract",	alternativeName:"numpadminus"}
	const Numpad7	= {type:Keyboard,	code:"Numpad7",	character:"7", name:"numpad7"}
	const Numpad8	= {type:Keyboard,	code:"Numpad8",	character:"8", name:"numpad8"}
	const Numpad9	= {type:Keyboard,	code:"Numpad9",	character:"9", name:"numpad9"}
	const NumpadAdd	= {type:Keyboard,	code:"NumpadAdd",	character:"+", name:"numpadadd",	alternativeName:"numpadplus"}
	const Numpad4	= {type:Keyboard,	code:"Numpad4",	character:"4", name:"numpad4"}
	const Numpad5	= {type:Keyboard,	code:"Numpad5",	character:"5", name:"numpad5"}
	const Numpad6	= {type:Keyboard,	code:"Numpad6",	character:"6", name:"numpad6"}
	const Numpad1	= {type:Keyboard,	code:"Numpad1",	character:"1", name:"numpad1"}
	const Numpad2	= {type:Keyboard,	code:"Numpad2",	character:"2", name:"numpad2"}
	const Numpad3	= {type:Keyboard,	code:"Numpad3",	character:"3", name:"numpad3"}
	const NumpadEnter	= {type:Keyboard,	code:"NumpadEnter",	character:"\n", name:"numpadenter",	alternativeName:"numpadreturn"}
	const Numpad0	= {type:Keyboard,	code:"Numpad0",	character:"0", name:"numpad0"}
	const NumpadDecimal	= {type:Keyboard,	code:"NumpadDecimal",	character:".", name:"numpaddecimal",	alternativeName:"numpadperiod"}

	static Input[] items
	inline js static dynamic keysObject => Input
	init
		int i
		forDynamic keysObject
			items.add .
			.index = i++
			
core
	int frame

html
	private inline js InternalGamepad[] getGamepads() navigator.getGamepads()
	InternalUser user = {}
	bool active = true

	updateGamepads: string ignore = null
		core.frame++
		InternalGamepad[] internalGamepads = getGamepads
		if internalGamepads == null or internalGamepads.length == 0 then return
		int index
		for internalGamepads as internalGamepad
			if internalGamepad and (not ignore or not internalGamepad.id.includes(ignore))
				// Modern input
				for inputIndex to 16
					let pressed = internalGamepad.buttons[inputIndex].pressed
					if not (user.pressedAtFrame[inputIndex] >= -2) then user.pressedAtFrame[inputIndex] = -2
					if not (user.releasedAtFrame[inputIndex] >= -2) then user.releasedAtFrame[inputIndex] = -1
					if user.pressedAtFrame[inputIndex] >= user.releasedAtFrame[inputIndex]
						if not pressed then user.releasedAtFrame[inputIndex] = core.frame
					else
						if pressed then user.pressedAtFrame[inputIndex] = core.frame
							
				user.gamepadType = internalGamepad.id.includes("054c") or internalGamepad.id.includes("810") ? PlayStation : internalGamepad.id.includes("retro") ? Nintendo : Xbox

		
	int keyRepeatAfter = 0
	int keyRepeatEvery = 0

	setRepeat: int after = 0, int every = 0
		keyRepeatAfter = after
		keyRepeatEvery = every

	// Returns true if the player has just pressed the given button this frame.
	// player is honored for EVERY input type: in a multi-user session each user has their own
	// keyboard and pointer, and their events land in their own stream (the old behavior forced
	// player 0 for non-gamepad items, which made every other user's keyboard invisible)
	global bool justPressed: Input item, int player = 0
		if not active or not user or user.handledAtFrame[item.index] == core.frame then return false

		// Pressed this frame?
		int pressedAtFrame = user.pressedAtFrame[item.index]
		int framesSincePress = core.frame - pressedAtFrame
		if framesSincePress == 0 then return true

		// Repeating?
		if keyRepeatEvery == 0 then return false
		int releasedAtFrame = user.releasedAtFrame[item.index]
		return pressedAtFrame > releasedAtFrame and framesSincePress >= keyRepeatAfter and (framesSincePress - keyRepeatAfter) mod keyRepeatEvery == 0

	global bool justPressed: string keyCombination, int player = 0
		if not active or not keyCombination then return false
		if  not user then return false
		let keyStrings = keyCombination.toLowerCase.split("+")
		bool anyPressedThisFrame = false
		for keyStrings
			let name = .trim
			if not name then return false
				
			let item = Input.items.find.name == name or .alternativeName == name
			if not item or user.handledAtFrame[item.index] == core.frame then return false
			
			let pressedAtFrame = user.pressedAtFrame[item.index]
			let releasedAtFrame = user.releasedAtFrame[item.index]
			if pressedAtFrame < releasedAtFrame then return false
				
			if pressedAtFrame == core.frame then anyPressedThisFrame = true
			
		return anyPressedThisFrame

	// Returns true if the player is currently pressing the given button
	// (false if it was pressed and released in the same frame, then only justPressed and justReleased are true)
	global bool isPressed: Input item, int player = 0
		if not active or not user then return false
		return user.pressedAtFrame[item.index] > user.releasedAtFrame[item.index]

	// Returns true if the player has just released the given button this frame (and it wasn't marked as handled since it was pressed, the release may come frames later)
	global bool justReleased: Input item, int player = 0
		if not active or not user then return false
		return user.releasedAtFrame[item.index] == core.frame and user.handledAtFrame[item.index] < user.pressedAtFrame[item.index]

	const Image[string][GamepadType] gamepadImages = {
		Xbox: {
			"A": ButtonA
			"B": ButtonB
			"X": ButtonX
			"Y": ButtonY
		}
		Nintendo: {
			"A": ButtonA
			"B": ButtonB
			"X": ButtonX
			"Y": ButtonY
		}
		PlayStation: {
			"A": ButtonCross
			"B": ButtonCircle
			"X": ButtonSquare
			"Y": ButtonTriangle
		}
	}

	Image getInputImage: Input item
		return gamepadImages[user.gamepadType || Xbox][item.code]