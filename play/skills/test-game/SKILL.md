---
name: test-game
description: Write unit tests for each rule of the game
user-invokable: true
---
# Analyze Code and Rules
Analyze the code and "docs/rules.md" carefully. Make sure you have a deep understanding of the rules and the code. Add each rule to your todo list. Then process them individually one after the other.

# For each rule
1. Get the next rule from your todo list.

2. Write as many unit tests as needed to verify every aspect of the rule. Make sure you test every variation and every edge case of the rule. The tests should use these functions to simulate user input: click, drag, hover, moveLeftStickTo, etc. For example:

tests
	pos: int x, int y
		return IntVector2(x, y).toScreenPos

	test Rule 7: Clicking a cell should place a pawn
		app.grid[0,0].pieceType = Pawn
		print "Setup: Placed starting piece for player 0 at {0,0}", type:Info

		click pos(1,0) by players[0]
		expect app.grid[1,0].pieceType == Pawn

3. Use vscode's built-in test-runner tool execute/runTests or the runTests tool to run the unit tests for the current rule.

4. If something is not working as expected, analyze the output of the tests and fix the problem.

5. If it is still not working as expected, add more print statements to the code to help you identify the true cause of the problem and fix it.

6. Repeat until you verified that all aspects and all edge cases of the rule are implemented correctly.

7. Mark the rule as done and proceed with the next rule.