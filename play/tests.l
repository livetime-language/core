tests
	setGameController: Vector2 leftStick
	                   int playerIndex = 0
		let player = input.players[playerIndex]
		player.gameController.leftStick.assign(leftStick)

	click: Vector2 position
	       int playerIndex = 0
		   TouchType type = Left
		let player = input.players[playerIndex]
		let internalUser = input.internalUsers[player.id]
		input.touchDown internalUser, player, id:0, referencePos:position, type, isSmoothPosition:true
		input.touchUp internalUser, player, id:0, referencePos:position, type, isSmoothPosition:true

	drag: Vector2 from
	      Vector2 to
	      int playerIndex = 0
		  float duration = 100
		  TouchType type = Left
		let player = input.players[playerIndex]
		let internalUser = input.internalUsers[player.id]

		// Down
		input.touchDown internalUser, player, id:0, referencePos:from, type, isSmoothPosition:true
		
		// Move
		int frames = math.round(duration * core.ticksPerSecond / 1000)
		for frames
			core.tick draw:false
			Vector2 pos = from interpolateTo target:to, progress: (i+1) / frames
			input.touchMove internalUser, player, id:0, referencePos:pos, type, isSmoothPosition:true

		// Up
		input.touchUp internalUser, player, id:0, referencePos:to, type, isSmoothPosition:true

	wait: float time
		let targetFrame = core.frame + time * core.ticksPerSecond / 1000
		if core.replayUntilFrame != -1 and targetFrame > core.replayUntilFrame
			targetFrame = core.replayUntilFrame
		while core.frame < targetFrame
			core.tick draw:false

	js void expect: T value
		    nocolon T toBe = object.undefined
			SourceCodeLocation location
		let a = value?.toString()
		let b = toBe?.toString()
		if(a != b) core.debugLog(`assert|${a}|${b}|${location.file}|${location.start}`)