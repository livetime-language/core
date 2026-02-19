tests
	// The first player (players[0])
	bluePlayer	=> players[0]	
	
	// The second player (players[1])
	redPlayer	=> players[1]	

	// The third player (players[2])
	greenPlayer	=> players[2]

	// The fourth player (players[3])
	yellowPlayer	=> players[3]

	// Simulate a click by a given player.
	// Always test that each player can only interact with items they are allowed to interact with.
	// Example:
	//     click {250,350} by bluePlayer
	importance:5
	void click: Vector2 position	// The screen position to click
		        TouchType with = LeftMouseButton	// LeftMouseButton, MiddleMouseButton, RightMouseButton, Finger, Pen
	            nocolon Player by = players[0]	// The player to click
		let internalUser = input.internalUsers[by.id]
		input.touchDown internalUser, player:by, id:0, referencePos:position, type:with, isSmoothPosition:true
		input.touchUp internalUser, player:by, id:0, referencePos:position, type:with, isSmoothPosition:true
		tick

	// Simulate a drag by a given player.
	// Always test that each player can only interact with items they are allowed to interact with.
	// Example:
	//     drag {0,0} to {300,0} by redPlayer
	importance:5
	void drag: Vector2 from	// The screen position to drag from
	           Vector2 to	// The screen position to drag to
		       float duration = 100	// The duration of the drag in milliseconds
		       TouchType with = LeftMouseButton	// LeftMouseButton, MiddleMouseButton, RightMouseButton, Finger, Pen
		       nocolon Player by = players[0]	// The player to drag
		let internalUser = input.internalUsers[by.id]

		// Down
		let message = "Drag {from} to {to} by {by}"
		input.touchDown internalUser, player:by, id:0, referencePos:from, type:with, isSmoothPosition:true, message
		tick

		// Move
		int frames = math.round(duration * core.ticksPerSecond / 1000)
		for frames
			Vector2 pos = from interpolateTo target:to, progress: (i+1) / frames
			input.touchMove internalUser, player:by, id:0, referencePos:pos, type:with, isSmoothPosition:true
			tick

		// Up
		input.touchUp internalUser, player:by, id:0, referencePos:to, type:with, isSmoothPosition:true
		tick

	// Simulate a moving the mouse to given screen position without clicking by a given player.
	// Always test that each player can only interact with items they are allowed to interact with.
	// Example:
	//     hover {250,350} by bluePlayer
	importance:5
	void hover: Vector2 position	// The screen position to hover over
	            TouchType with = LeftMouseButton	// LeftMouseButton, MiddleMouseButton, RightMouseButton, Finger, Pen
	            nocolon Player by = players[0]	// The player to hover over the given screen position
		let internalUser = input.internalUsers[by.id]
		input.touchMove internalUser, player:by, id:0, referencePos:position, type:with, isSmoothPosition:true
		tick

	// Simulate pressing a key or typing a character by a given player
	// Example:
	//     pressKey Space by bluePlayer
	importance:5
	void pressKey: Key key	// The key to press
	               string character = ""	// The character to type
		           nocolon Player by = players[0]	// The player
		let internalUser = input.internalUsers[by.id]
		input.keyDown internalUser, player:by, key, character
		input.keyUp internalUser, player:by, key
		tick

	// Simulate moving the left stick of a game controller by a given player
	// Example:
	//     moveLeftStickTo {1,0} by redPlayer
	importance:5
	void moveLeftStickTo: Vector2 direction	// The direction to move the left stick to
	                      nocolon Player by = players[0]	// The player
		by.gameController.leftStick.assign(direction)
		print type:GameController "Move left stick to {direction} by {by}"
		tick

	// Wait for a given amount of time
	// Example:
	//     wait 3 frames
	importance:5
	void wait: float time	// The time to wait
		let targetFrame = core.frame + math.round time * core.ticksPerSecond / 1000
		if core.targetFrame != -1 and targetFrame > core.targetFrame
			targetFrame = core.targetFrame
		System.log "wait until {targetFrame} (frame: {core.frame}, core.targetFrame: {core.targetFrame})"
		while core.frame <= targetFrame
			tick

	// Use printWhatIsOnScreen to check if the what is shown on screen is correct
	importance:5
	void printWhatIsOnScreen
		print "\n{graphics.getWhatIsOnScreen}"

	// Asserts that an expression is true
	// Example:
	//     expect bluePlayer.gridPos == {1,0}
	importance:5
	void expect: dynamic expression // The assert will fail if this expression is false
			     SourceCodeLocation location
		string actualString
		try	actualString = json.stringify(expression)
		catch	actualString = expression?.toString()
		string result = expression ? "+" : "-"
		core.debugLog "expect||{result}|{actualString}|true|{location.file}|{location.start}"

	// Asserts that the application output contains a given string at any point
	// Example:
	//     expectToPrint "Cell {2,3} clicked by blue player"
	importance:5
	void expectToPrint: string value // The assert will fail if the application output does not contain this string
		                SourceCodeLocation location
		let result = (core.output.any.contains value) ? "+" : "-"
		core.debugLog "expect|to print|{result}|{value}||{location.file}|{location.start}"
