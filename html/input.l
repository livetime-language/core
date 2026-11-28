enum KeyCode
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
	KeyCode key
	void(KeyCode key) do
	bool whileEditingText = true

KeyboardShortcut
	void() do
	void(bool cancelled) release = null
	bool whileEditingText = true
	
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
	KeyboardShortcut[string] keyboardShortcuts	// By accelerator as normalizeAccelerator writes it
	dynamic pressedShortcut = null	// The shortcut with a release whose key is down: {shortcut, code, cancelled}
	void() defaultButtonToTriggerWithEnterKey = null
		
	js void initGlobalEventHandlers
		document.onkeydown = ev => {
			if(ev.key == "F10") { 
				system.toggleSmallScreen();
			} else if(ev.key == "Enter" && html.defaultButtonToTriggerWithEnterKey != null) {
				html.defaultButtonToTriggerWithEnterKey.invoke(ev)
				ev.preventDefault();
				ev.stopPropagation();
				return false;
			}
			// The element the key was pressed in, also if its own key handler has blurred or removed it (Enter that ends editing)
			const keyTarget = ev.target;
			const editingText = ev.isComposing || keyTarget.isContentEditable || keyTarget.contentEditable == "true" || keyTarget.contentEditable == "plaintext-only" || keyTarget.tagName == "INPUT" || keyTarget.tagName == "TEXTAREA";
			const key = ev.key || "";
			// Another key while a shortcut is held makes it a combination (Right Option and L type "@" on a German Mac keyboard)
			const pressed = html.pressedShortcut;
			if(pressed && ev.code != pressed.code) pressed.cancelled = true;
			// A modifier key alone is named after its side ("rightalt"), whatever else is held (AltGr is Ctrl and Right Alt on Windows).
			// It types nothing, so it is also handled while editing text, and keeps its default action for the keys that follow
			const side = /^(Alt|Control|Shift|Meta)(Left|Right)$/.exec(ev.code);
			if(side || !editingText || ev.ctrlKey || ev.altKey || ev.metaKey || /^(F\d+|Escape)$/.test(key)) {
				const shortcut = html.keyboardShortcuts.get(side ? side[2].toLowerCase() + {Alt:"alt", Control:"ctrl", Shift:"shift", Meta:"meta"}[side[1]] : html.pressedAccelerator(ev));
				if(shortcut && (shortcut.whileEditingText || !editingText)) {
					// A shortcut with a release is pressed once until its key goes up: repeats of the held key don't count
					if(!shortcut.release) shortcut.do.invoke()
					else if(!ev.repeat) {
						html.releaseShortcut(true)
						html.pressedShortcut = {shortcut, code:ev.code, cancelled:false}
						shortcut.do.invoke()
					}
					if(side) return;
					ev.preventDefault();
					ev.stopPropagation();
					return false;
				}
			}
			for(let listener of html.keyDownListeners) {
				if(ev.keyCode == listener.key && (listener.whileEditingText || !editingText)) {
					listener.do.invoke(ev.keyCode)
					ev.preventDefault();
					ev.stopPropagation();
					return false;
				}
			}
		}

		// The back and forward buttons of the mouse ("MouseBack", "MouseForward", also with modifiers) run their shortcut when they are
		// pressed, also while the user edits text. None of their events gets to the page then (its pointer handlers would act on them as on
		// clicks, the browser would go back in its history)
		for(const type of ["pointerdown", "pointerup", "mousedown", "mouseup", "auxclick"]) addEventListener(type, ev => {
			const button = {3:"mouseback", 4:"mouseforward"}[ev.button];
			const shortcut = button && html.keyboardShortcuts.get(html.pressedAccelerator(ev) + button);
			if(!shortcut) return;
			ev.preventDefault();
			ev.stopPropagation();
			if(type == "pointerdown") shortcut.do.invoke();
		}, true);

		// The key of a held shortcut or a modifier went up (on a Mac, keys that are released while Cmd is held send no keyup)
		document.onkeyup = ev => {
			const pressed = html.pressedShortcut;
			if(!pressed || ev.code != pressed.code && !/^(Alt|Control|Shift|Meta)/.test(ev.code)) return;
			html.releaseShortcut(pressed.cancelled);
			if(!pressed.cancelled) ev.preventDefault();
		}
		// Keys released in another window send no keyup
		window.addEventListener("blur", () => html.releaseShortcut(true));

	// Ends the press of the held shortcut: calls its release
	private js void releaseShortcut: bool cancelled
		const pressed = html.pressedShortcut;
		if(!pressed) return;
		html.pressedShortcut = null;
		pressed.shortcut.release.invoke(cancelled);

	// Calls handler once, when the pointer that is down now is released (or the window loses the focus): e.g. in onPointerDown, to see
	// how long a button was held
	js void onPointerRelease: stored void() handler
		const release = () => {
			removeEventListener("pointerup", release, true);
			removeEventListener("pointercancel", release, true);
			removeEventListener("blur", release);
			handler.invoke();
		}
		addEventListener("pointerup", release, true);
		addEventListener("pointercancel", release, true);
		addEventListener("blur", release);

	clearGlobalEventHandlers
		if(!keyDownListeners) keyDownListeners = []
		keyDownListeners.clear
		if(!keyboardShortcuts) keyboardShortcuts = {}
		keyboardShortcuts.clear
	
	onKeyDown: KeyCode key
		       bool whileEditingText = true	// Handle the key also while the user edits text in a text field (with false, the key keeps its default action there, e.g. Backspace deletes a character)
		       stored void(KeyCode key) do
		keyDownListeners.add {key, do, whileEditingText}

	// Calls do when the user presses the keys of an accelerator in the syntax of Electron, e.g. "CmdOrCtrl+Shift+P", "Alt+Left" or "F5"
	// (https://www.electronjs.org/docs/latest/api/accelerator), a modifier key of one side alone ("RightAlt", "RightCmd", "LeftShift",
	// "RightCtrl") or the back and forward buttons of the mouse ("MouseBack", "Alt+MouseForward"). CmdOrCtrl is Cmd on Apple devices and
	// Ctrl everywhere else. Modifier keys alone and mouse buttons can't be accelerators of Electron's menus.
	// While the user edits text, only accelerators with Ctrl, Alt or Cmd, function keys, Escape and modifier keys alone are handled: all
	// other keys type. Register accelerators in app.start. An accelerator has one listener, the last one registered
	onKeyboardShortcut: string accelerator
		          stored void() do
		          stored void(bool cancelled) release = null	// Called when the keys are released (keyup of the key or a modifier, or the window lost the focus). With it, do isn't called for repeats of the held key. cancelled: another key was pressed meanwhile (a combination, e.g. Right Option and L type "@") or the window lost the focus
		          bool whileEditingText = true	// Handle the accelerator also while the user edits text in a text field (with false, the keys keep their default action there: on a Mac Alt+L types "@" on a German keyboard and Ctrl+A moves the caret to the start of the line)
		keyboardShortcuts[normalizeAccelerator(accelerator)] = {do, release, whileEditingText}

	// Removes the listener of an accelerator (onKeyboardShortcut), so its keys keep their default action
	removeKeyboardShortcut: string accelerator
		keyboardShortcuts.remove normalizeAccelerator(accelerator)

	// The keys of a keydown event as normalizeAccelerator writes accelerators. Keys that type another character with Alt or Shift (on a Mac
	// Alt+T is "†" and Alt+E a dead key, Shift+1 is "!", Shift+- is "_") are named after the letter, digit or punctuation they type without
	// modifiers (keyCode follows the keyboard layout)
	private js string pressedAccelerator: dynamic ev
		const key = ev.key || "", modifiers = (ev.ctrlKey ? "ctrl+" : "") + (ev.altKey ? "alt+" : "") + (ev.shiftKey ? "shift+" : "") + (ev.metaKey ? "meta+" : "");
		const typesOther = key == "Dead" || key.length == 1 && !/[a-z0-9]/i.test(key);
		const punctuation = ev.altKey || ev.shiftKey ? {186:";", 187:"=", 188:",", 189:"-", 190:".", 191:"/", 192:"`", 219:"[", 220:"\\", 221:"]", 222:"'"}[ev.keyCode] : null;
		const unmodified = ev.keyCode >= 48 && ev.keyCode <= 57 || ev.keyCode >= 65 && ev.keyCode <= 90 ? String.fromCharCode(ev.keyCode) : punctuation;
		return modifiers + (typesOther && unmodified ? unmodified : key).toLowerCase();

	// Whether a keydown event (also of an element's own listener) has the keys of an accelerator (onKeyboardShortcut). Not for a modifier key alone
	js bool isAcceleratorPressed: dynamic ev, string accelerator
		return html.pressedAccelerator(ev) == html.normalizeAccelerator(accelerator);

	// The accelerator as the keydown listener names the pressed keys: lowercase, the modifiers ctrl, alt, shift and meta in this order
	private js string normalizeAccelerator: string accelerator
		const meta = html.isAppleDevice() ? "meta" : "ctrl";
		const names = {commandorcontrol:meta, cmdorctrl:meta, command:"meta", cmd:"meta", super:"meta", control:"ctrl", option:"alt", altgr:"alt",
			return:"enter", esc:"escape", up:"arrowup", down:"arrowdown", left:"arrowleft", right:"arrowright", space:" ", plus:"+",
			rightoption:"rightalt", leftoption:"leftalt", rightcommand:"rightmeta", leftcommand:"leftmeta", rightcmd:"rightmeta", leftcmd:"leftmeta",
			rightsuper:"rightmeta", leftsuper:"leftmeta", rightcontrol:"rightctrl", leftcontrol:"leftctrl"};
		const parts = accelerator.toLowerCase().split("+").map(part => names[part.trim()] || part.trim());
		const key = parts.pop();
		return ["ctrl", "alt", "shift", "meta"].filter(modifier => parts.includes(modifier)).map(modifier => modifier + "+").join("") + key;

	// An accelerator as menus show it: "⇧⌘P" on Apple devices, "Ctrl+Shift+P" everywhere else. A modifier key alone: "Right ⌥", "Right Alt"
	js string acceleratorLabel: string accelerator
		const apple = html.isAppleDevice();
		const names = apple ? {commandorcontrol:"⌘", cmdorctrl:"⌘", command:"⌘", cmd:"⌘", super:"⌘", meta:"⌘", control:"⌃", ctrl:"⌃", alt:"⌥", option:"⌥", altgr:"⌥", shift:"⇧",
			return:"↩", enter:"↩", esc:"⎋", escape:"⎋", backspace:"⌫", delete:"⌦", tab:"⇥", up:"↑", down:"↓", left:"←", right:"→", plus:"+", mouseback:"Mouse Back", mouseforward:"Mouse Forward"}
			: {commandorcontrol:"Ctrl", cmdorctrl:"Ctrl", command:"Meta", cmd:"Meta", super:"Meta", meta:"Meta", control:"Ctrl", ctrl:"Ctrl", alt:"Alt", option:"Alt", shift:"Shift", return:"Enter", esc:"Escape", plus:"+", mouseback:"Mouse Back", mouseforward:"Mouse Forward"};
		const name = part => {
			const side = /^(left|right)(.+)$/i.exec(part)
			return side && names[side[2].toLowerCase()] ? side[1][0].toUpperCase() + side[1].slice(1).toLowerCase() + " " + names[side[2].toLowerCase()] : names[part.toLowerCase()] || (part.length == 1 ? part.toUpperCase() : part)
		}
		const parts = accelerator.split("+").map(part => name(part.trim()));
		// Apple shows the modifiers in the order Control, Option, Shift, Command
		const rank = part => ("⌃⌥⇧⌘".indexOf(part) + 5) % 5;
		return apple ? parts.sort((a, b) => rank(a) - rank(b)).join("") : parts.join("+");

	js bool isAppleDevice
		return /Mac|iPhone|iPad|iPod/.test(navigator.platform);

	// Runs an editing command (undo, redo, cut, copy, paste, delete, duplicate, selectAll) on the text field that has the focus (input,
	// textarea or contentEditable) and returns true. Without a selection, cut, copy, delete and duplicate act on the caret's line, like
	// in code editors: cut and delete remove it with its line break, duplicate inserts a copy below it. Duplicate inserts a copy of the
	// selected text after it. The other commands are the browser's (system.runEditingCommand), so they are in the field's undo history.
	// A focus outside the page (a webview, an iframe, another window) and Copy of text selected outside of text fields also get the
	// command of the browser. Returns false otherwise, if no text field has the focus: the command is the app's, e.g. for the items it selects
	js bool editText: string command
		const element = document.activeElement, selection = getSelection()
		if(!document.hasFocus() || element?.tagName == "IFRAME" || element?.tagName == "WEBVIEW") {
			system.runEditingCommand(command)
			return true
		}
		const field = element?.tagName == "INPUT" || element?.tagName == "TEXTAREA"
		if(!field && !element?.isContentEditable) {
			// Text selected outside of text fields is copied by the browser
			if(command != "copy" || selection.isCollapsed) return false
			system.runEditingCommand(command)
			return true
		}
		const insert = text => document.execCommand("insertText", false, text)
		// Inputs without a selection (number, email) and passwords only get the browser's commands
		const ownCommand = ["cut", "copy", "delete", "duplicate"].includes(command) && !(field && (element.selectionStart == null || element.type == "password"))
		const collapsed = field ? element.selectionStart == element.selectionEnd : selection.isCollapsed
		if(!ownCommand || !collapsed && command != "duplicate") system.runEditingCommand(command)
		else if(!collapsed) {
			if(field) {
				const start = element.selectionStart, end = element.selectionEnd
				element.setSelectionRange(end, end)
				insert(element.value.substring(start, end))
				element.setSelectionRange(end, end + end - start)
			} else {
				const text = selection.toString()
				selection.collapseToEnd()
				insert(text)
			}
		} else if(field) {
			const value = element.value, caret = element.selectionStart
			const start = caret > 0 ? value.lastIndexOf("\n", caret - 1) + 1 : 0
			const end = value.indexOf("\n", caret) < 0 ? value.length : value.indexOf("\n", caret)
			const line = value.substring(start, end), multiline = element.tagName == "TEXTAREA"
			if(command == "cut" || command == "copy") navigator.clipboard.writeText(multiline ? line + "\n" : line)
			if(command == "duplicate") {
				if(!multiline) return true
				element.setSelectionRange(end, end)
				insert("\n" + line)
				element.setSelectionRange(caret + line.length + 1, caret + line.length + 1)
			} else if(command != "copy") {
				// The last line goes with the line break before it
				const last = end == value.length
				element.setSelectionRange(last && start > 0 ? start - 1 : start, last ? end : end + 1)
				document.execCommand("delete")
			}
		} else {
			// The paragraph of the caret (Firefox only knows lines as they are wrapped)
			const unit = /Firefox/.test(navigator.userAgent) ? "lineboundary" : "paragraphboundary"
			const node = selection.focusNode, offset = selection.focusOffset
			selection.modify("move", "backward", unit)
			selection.modify("extend", "forward", unit)
			const line = selection.toString()
			if(command == "cut" || command == "copy") navigator.clipboard.writeText(line)
			if(command == "copy") selection.collapse(node, offset)
			else if(command == "duplicate") {
				selection.collapseToEnd()
				insert("\n" + line)
			} else {
				// With the line break after it. An empty last paragraph: delete removes the line break before it
				selection.modify("extend", "forward", "character")
				document.execCommand("delete")
			}
		}
		return true
