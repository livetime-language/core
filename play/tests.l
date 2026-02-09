tests
	bluePlayer	:= players[0]
	redPlayer	:= players[1]
	greenPlayer	:= players[2]
	yellowPlayer	:= players[3]

	setGameController: Vector2 leftStick
	                   nocolon Player by = players[0]
		if  core.frame > core.replayUntilFrame or core.outputId > core.replayUntilOutputId: return
		by.gameController.leftStick.assign(leftStick)

	click: Vector2 position
		   TouchType with = LeftMouseButton
	       nocolon Player by = players[0]
		if  core.frame > core.replayUntilFrame or core.outputId > core.replayUntilOutputId: return
		let internalUser = input.internalUsers[by.id]
		input.touchDown internalUser, player:by, id:0, referencePos:position, type:with, isSmoothPosition:true
		input.touchUp internalUser, player:by, id:0, referencePos:position, type:with, isSmoothPosition:true

	drag: Vector2 from
	      Vector2 to
		  float duration = 100
		  TouchType with = LeftMouseButton
		  nocolon Player by = players[0]
		if  core.frame > core.replayUntilFrame or core.outputId > core.replayUntilOutputId: return
		let internalUser = input.internalUsers[by.id]

		// Down
		input.touchDown internalUser, player:by, id:0, referencePos:from, type:with, isSmoothPosition:true
		
		// Move
		int frames = math.round(duration * core.ticksPerSecond / 1000)
		for frames
			core.tick draw:false
			Vector2 pos = from interpolateTo target:to, progress: (i+1) / frames
			input.touchMove internalUser, player:by, id:0, referencePos:pos, type:with, isSmoothPosition:true

		// Up
		input.touchUp internalUser, player:by, id:0, referencePos:to, type:with, isSmoothPosition:true

	wait: float time
		let targetFrame = (core.frame + math.round time * core.ticksPerSecond / 1000) atMost core.replayUntilFrame
		while core.frame < targetFrame
			core.tick draw:false

	printWhatIsOnScreen
		print "\n{graphics.getWhatIsOnScreen}"

	js void expect: T value
		    nocolon T toBe = object.undefined
			SourceCodeLocation location
		let a = value?.toString()
		let b = toBe?.toString()
		if(a != b) core.debugLog(`assert|${a}|${b}|${location.file}|${location.start}`)