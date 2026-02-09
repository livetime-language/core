skipInit debug
	string[] logs
	internal int waitUntilFrame

	start
		try
			Platform.stop
			sendApplicationState
		catch
			core.onError .

	click: int playerIndex, int x, int y, int framesToWaitAfterwards
		if playerIndex == int.undefined: playerIndex = 0
		if not framesToWaitAfterwards: framesToWaitAfterwards = 30

		if playerIndex < 0 or playerIndex >= input.internalUsers.length
			print "click: playerIndex out of range"
		else
			input.handleSynteticTouchEvent playerIndex, TouchDown, x, y, TouchType.LeftMouseButton, id:0
			input.handleSynteticTouchEvent playerIndex, TouchUp, x, y, TouchType.LeftMouseButton, id:0
			if framesToWaitAfterwards <= 1
				core.step fastForward:false, draw:true
				sendApplicationState
			else
				wait framesToWaitAfterwards

	drag: int playerIndex, int x, int y, int dragToX, int dragToY
		if playerIndex == int.undefined: playerIndex = 0
		if playerIndex < 0 or playerIndex >= input.internalUsers.length
			print "click: playerIndex out of range"
		else
			input.handleSynteticTouchEvent playerIndex, TouchDown, x, y, TouchType.LeftMouseButton, id:0
			if dragToX != int.undefined and dragToY != int.undefined
				input.handleSynteticTouchEvent playerIndex, TouchMove, dragToX, dragToY, TouchType.LeftMouseButton, id:0
				input.handleSynteticTouchEvent playerIndex, TouchUp, dragToX, dragToY, TouchType.LeftMouseButton, id:0
			else
				input.handleSynteticTouchEvent playerIndex, TouchUp, x, y, TouchType.LeftMouseButton, id:0

			core.step fastForward:false, draw:true
			sendApplicationState

	wait: int frames
		if frames < 1
			print "wait: frames out of range"
			sendApplicationState
		else
			waitUntilFrame = core.frame + frames
			Platform.play

	onWaitFinished
		waitUntilFrame = 0
		Platform.pause
		sendApplicationState

	evaluateExpression: string expression
		Platform.sendToEditor {type:"state", value:eval(expression)}

	js string eval: string expression
		try {
			return eval(expression);
		} catch(e) {
			return e.message;
		}

	sendApplicationState
		string result

		if logs
			result += "# Debug logs:\n"
			for logs: result += . + "\n"
			logs.clear
			result += "\n"
		else
			result += "# No debug logs\n\n"

		result += "# Screen topLeft:\{{-graphics.referenceSize.x/2},{-graphics.referenceSize.y/2}\} bottomRight:\{{graphics.referenceSize.x/2},{graphics.referenceSize.y/2}\} backgroundColor:{graphics.backgroundColor ? graphics.backgroundColor.toString() : "Black"}\n"
		if graphics.items
			result += "# Currently on screen:\n"
			for graphics.items
				if not .location.file.startsWith("lib/core/")
					result += .description + "\n"
		else
			result += "# Nothing on screen\n\n" 

		Platform.sendToEditor {type:"state", value:result}

	sendWhatIsOnScren
		Platform.sendToEditor {type:"screen", value:graphics.getWhatIsOnScreen}

			
