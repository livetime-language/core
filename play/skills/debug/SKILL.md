---
name: debug
description: Fix a. bug
user-invokable: true
---
# Find and Fix Bugs

1. Analyze the code carefully to find all possible causes of the problem.

2. Think hard and output a list of hypothesis of all possible causes of the problem.

3. Add extensive print statements to the code that help you comfirm or disprove your hypotheses. For example:

Player
	tick
		positon += direction
		print "{this} moved in {direction} to {position}"

4. Write unit tests in the static class "tests" in a new file in the "tests" folder (for example "tests/playerMovement.l"). The tests should use these functions to simulate user input: click, drag, hover, moveLeftStickTo, etc. For example:

tests
	playerShouldMoveRight
		app.createTestLevel
		moveLeftStickTo {1,0} by bluePlayer
		wait 10 frames
		expect bluePlayer.gridPos toBe {1,0}

5. Use the vscode's build-in tool (execute/runTests) or the runTests tool to run the unit tests.

6. Carefully analyze the output of your print statements. The goal is to confirm one of your hypothesis. Repeat steps 1-6 until you can confirm one of your hypothesis.

7. Once you confirmed a hypothesis, fix the problem.

8. Confirm you fixed the problem using the unit tests.