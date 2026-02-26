---
name: implement-game
description:  Implement the game based on rules
argument-hint: "[rules]"
user-invokable: true
disable-model-invocation: true
---
Step 1: Read "docs/rules.md" carefully. Make sure you have a thorough understanding of the game.

Step 2: Implement the game. If a piece of code implements a specific rule, add the rule in a comment above the piece of code. For example:

// Rule 17: If all players are dead, the game ends
if players.all.dead
	app.endGame

Step 3: Check each rule individually. First, add each rule to your todo list. Then process them one by one. For each rule, check if you implemented it correctly. If not, fix it.

Step 4: Double check you wrote the simplest possible code. Refactor your code until you arrive at the shortest, simplest possible and most efficient code without code duplication.

Step 5: Check if you fixed all diagnostics and linter errors.