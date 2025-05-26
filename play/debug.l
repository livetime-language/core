class DebugClick
	int playerIndex
	int x
	int y
	int dragToX
	int dragToY

skipInit debug
	string[] logs

	start
		try
			Platform.stop
			sendApplicationState
		catch
			Platform.sendErrorToEditor .

	testApplication: bool restartApp, DebugClick[] clicks, string[] expressionsToEvaluate
		if restartApp
			Platform.stop
			
		for clicks
			if .playerIndex == int.undefined: .playerIndex = 0
			if .playerIndex < 0 or .playerIndex >= input.internalUsers.length
				print "click: playerIndex out of range"
			else
				input.handleSynteticTouchEvent .playerIndex, TouchDown, .x, .y, TouchType.Left, id:0
				if .dragToX != int.undefined and .dragToY != int.undefined
					input.handleSynteticTouchEvent .playerIndex, TouchMove, .dragToX, .dragToY, TouchType.Left, id:0
					input.handleSynteticTouchEvent .playerIndex, TouchUp, .dragToX, .dragToY, TouchType.Left, id:0
				else
					input.handleSynteticTouchEvent .playerIndex, TouchUp, .x, .y, TouchType.Left, id:0

				core.step fastForward:false, draw:true

		sendApplicationState expressionsToEvaluate

	js string evaluateExpression: string expression
		try {
			return eval(expression);
		} catch(e) {
			return e.message;
		}

	step: int frames
		if frames <= 1
			print "step: frames out of range"
		else
			for frames
				core.step fastForward:false, draw:i == frames-1
		sendApplicationState

	sendApplicationState: string[] expressionsToEvaluate = null
		string result

		if logs
			result += "# Printed to console:\n"
			for logs: result += . + "\n"
			logs.clear
			result += "\n"
		else
			result += "# Nothing printed to console\n\n"

		if graphics.items
			result += "# Currently on screen:\n"
			for graphics.items: result += .description + "\n"
			result += "\n"
		else
			result += "# Nothing on screen\n\n"

		if expressionsToEvaluate
			result += "# Evaluating expressions:\n"
			for expressionsToEvaluate: result += "{.}: {evaluateExpression(.)}\n"
			result += "\n"

		Platform.sendToEditor {type:"state", value:result}

			
