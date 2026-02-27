---
name: test-game
description: Write unit test for each rule of the game
user-invokable: true
---
# Analyze Code and Rules
Analyze the code and "docs/rules.md" carefully. Make sure you have a deep understanding of the rules and the code. Add each rule to your todo list individually. Then process them one by one.

# For each rule, perform the following steps
1. To verify the rule, write one or more unit tests in the file "tests/tests.l". Make sure you test every aspect and every edge case of the rule. The tests should use these functions to simulate user input: click, drag, hover, moveLeftStickTo, etc. For example:

tests
	test Rule 7: Clicking a cell should place a piece
		app.currentPlayer = players[0]
		app.grid[0,0].player = players[0]
		print "Setup: Placed piece for player 0 at {0,0}", type:Info

		click {200,400} by players[1]
		// If you need to wait for animations to finish before continuing, use wait.
		// Wait for 15 ticks. At 30 ticks per second, this corresponds to 500 milliseconds.
		wait 15 ticks

		// Use printWhatIsOnScreen to check if the what is shown on screen is correct
		printWhatIsOnScreen
2. Use vscode's build-in tool (execute/runTests) or the runTests tool to run the unit tests.

3. If something is not working as expected, analyze the output of the tests and fix the problem.

4. If it is still not working as expected, add more print statements to the code to help you identify the true cause of the problem and fix it.

5. Repeat until you verified that all aspects and all edge cases of the rule are implemented correctly.

6. Mark the rule as done and proceed to the next rule in your todo list.