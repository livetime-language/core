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
	playerShouldMoveRight
		click {250,350} by players[0]
		expect players[0].gridPos == {1,0}

2. Use vscode's build-in tool (execute/runTests) or the runTests tool to run the unit tests.

3. If something is not working as expected, analyze the output of the tests and fix the problem.

4. If it is still not working as expected, add more print statements to the code to help you identify the true cause of the problem and fix it.

5. Repeat until you verified that all aspects and all edge cases of the rule are implemented correctly.

6. Mark the rule as done and proceed to the next rule in your todo list.