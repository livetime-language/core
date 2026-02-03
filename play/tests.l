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

	expect: T value
		    nocolon T toBe
			SourceCodeLocation location
		if value != toBe
			core.debugLog "assert|{value}|{toBe}|{location.file}|{location.start}"
