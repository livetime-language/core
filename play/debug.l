skipInit debug
	string[] logs

	start
		try
			Platform.stop
			sendApplicationState
		catch
			Platform.sendErrorToEditor .

	click: int playerIndex, int x, int y
		if playerIndex == int.undefined: playerIndex = 0
		if playerIndex < 0 or playerIndex >= input.internalUsers.length
			print "click: playerIndex out of range"
		else
			input.handleSynteticTouchEvent playerIndex, TouchDown, x, y, TouchType.Left, id:0
			input.handleSynteticTouchEvent playerIndex, TouchUp, x, y, TouchType.Left, id:0
			core.step fastForward:false, draw:true
			sendApplicationState

	drag: int playerIndex, int x, int y, int dragToX, int dragToY
		if playerIndex == int.undefined: playerIndex = 0
		if playerIndex < 0 or playerIndex >= input.internalUsers.length
			print "click: playerIndex out of range"
		else
			input.handleSynteticTouchEvent playerIndex, TouchDown, x, y, TouchType.Left, id:0
			if dragToX != int.undefined and dragToY != int.undefined
				input.handleSynteticTouchEvent playerIndex, TouchMove, dragToX, dragToY, TouchType.Left, id:0
				input.handleSynteticTouchEvent playerIndex, TouchUp, dragToX, dragToY, TouchType.Left, id:0
			else
				input.handleSynteticTouchEvent playerIndex, TouchUp, x, y, TouchType.Left, id:0

			core.step fastForward:false, draw:true
			sendApplicationState

	step: int frames
		if frames <= 1
			print "step: frames out of range"
		else
			for frames
				core.step fastForward:false, draw:i == frames-1
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

		result += "# Screen dimensions topLeft:\{{-graphics.referenceSize.x/2},{-graphics.referenceSize.y/2}\} bottomRight:\{{graphics.referenceSize.x/2},{graphics.referenceSize.y/2}\}\n"
		if graphics.items
			result += "# Currently on screen:\n"
			for graphics.items
				if not .location.file.startsWith("lib/core/")
					result += .description + "\n"
		else
			result += "# Nothing on screen\n\n"

		Platform.sendToEditor {type:"state", value:result}

	sendCurrentlyOnScreen
		string result = "# Screen dimensions topLeft:\{{-graphics.referenceSize.x/2},{-graphics.referenceSize.y/2}\} bottomRight:\{{graphics.referenceSize.x/2},{graphics.referenceSize.y/2}\}\n"
		if graphics.items
			result += "# Currently on screen:\n"
			for graphics.items
				if not .location.file.startsWith("lib/core/")
					result += .description + "\n"
		else
			result += "# Nothing is currently on screen\n\n"

		Platform.sendToEditor {type:"screen", value:result}

			
