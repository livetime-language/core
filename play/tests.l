tests
	bluePlayer	:= players[0]
	redPlayer	:= players[1]
	greenPlayer	:= players[2]
	yellowPlayer	:= players[3]

	click: Vector2 position
		   TouchType with = LeftMouseButton
	       nocolon Player by = players[0]
		let internalUser = input.internalUsers[by.id]
		input.touchDown internalUser, player:by, id:0, referencePos:position, type:with, isSmoothPosition:true
		input.touchUp internalUser, player:by, id:0, referencePos:position, type:with, isSmoothPosition:true
		tick

	drag: Vector2 from
	      Vector2 to
		  float duration = 100
		  TouchType with = LeftMouseButton
		  nocolon Player by = players[0]
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

	private hover: Vector2 position
	               TouchType with = LeftMouseButton
	               nocolon Player by = players[0]
		let internalUser = input.internalUsers[by.id]
		input.touchMove internalUser, player:by, id:0, referencePos:position, type:with, isSmoothPosition:true
		tick

	pressKey: Key key
	          string character = ""
		      nocolon Player by = players[0]
		let internalUser = input.internalUsers[by.id]
		input.keyDown internalUser, player:by, key, character
		input.keyUp internalUser, player:by, key
		tick

	moveLeftStickTo: Vector2 direction
	                 nocolon Player by = players[0]
		by.gameController.leftStick.assign(direction)
		print type:GameController "Move left stick to {direction} by {by}"
		tick

	wait: float time
		let targetFrame = core.frame + math.round time * core.ticksPerSecond / 1000
		if core.targetFrame != -1 and targetFrame > core.targetFrame
			targetFrame = core.targetFrame
		System.log "wait until {targetFrame} (frame: {core.frame}, core.targetFrame: {core.targetFrame})"
		while core.frame <= targetFrame
			tick

	private tick
		System.log "### tick core.frame:{core.frame} core.targetFrame:{core.targetFrame} "
		// if core.frame <= core.targetFrame
		Platform.fastForward = core.frame != core.targetFrame
		core.tick draw:core.frame == core.targetFrame

	printWhatIsOnScreen
		print "\n{graphics.getWhatIsOnScreen}"

	// Asserts that an expression is true
	expect: dynamic expression // The assert will fail if this expression is false
			SourceCodeLocation location
		string actualString
		try	actualString = json.stringify(expression)
		catch	actualString = expression?.toString()
		string result = expression ? "+" : "-"
		core.debugLog "expect||{result}|{actualString}|true|{location.file}|{location.start}"

	// Asserts that the application output contains a given string
	expectToPrint: string value // The assert will fail if the application output does not contain this string
		           SourceCodeLocation location
		let result = (core.output.any.contains value) ? "+" : "-"
		core.debugLog "expect|to print|{result}|{value}||{location.file}|{location.start}"
