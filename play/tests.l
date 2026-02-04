tests
	setGameController: int playerIndex
	                   Vector2 leftStick
		let player = input.players[playerIndex]
		player.gameController.leftStick.assign(leftStick)

	wait: float time
		let targetFrame = core.frame + time * core.ticksPerSecond / 1000
		if core.replayUntilFrame != -1 and targetFrame > core.replayUntilFrame
			targetFrame = core.replayUntilFrame
		while core.frame < targetFrame
			Time.now = core.serverStartTime + math.round(core.frame * core.frameTime)
			core.tick draw:false
			core.frame++

	printWhatIsOnScreen
		print "\n{graphics.getWhatIsOnScreen}"

	js void expect: T value
		    nocolon T toBe = object.undefined
			SourceCodeLocation location
		let a = value?.toString()
		let b = toBe?.toString()
		if(a != b) core.debugLog(`assert|${a}|${b}|${location.file}|${location.start}`)