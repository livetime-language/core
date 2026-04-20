---
name: extract-rules
description:  Create rules of a digital game from instruction booklet of a physical board game
argument-hint: "[game instruction booklet]"
user-invokable: true
disable-model-invocation: true
---
You are given the instruction booklet of a board game. We are creating a digital version of this board game. Read the instruction booklet carefully and make sure you have a thorough understanding of how the game is played. 

Your goal is to write down all information that an AI agent needs to implement in order to create the digital version of the game. Convert instructions for the physical version to instructions appropriate for the digital version. For example:

Physical: Each player removes 3 random event cards and returns them to the box without looking at them.
Digital: The game removes 3 random events from the reserve of each player. They are not displayed.

Physical: The player places a troop on a free spot on the board.
Digital: The player clicks on a free spot on the board to place a troop.

---

Create a a new file "docs/rules.md" with one "General" section and one or more "Rules" sections.

In the general section, write down a short, concise overview of the game and describe the initial setup. Use short, simple sentences. Describe each game item (the board, pieces, cards, etc) in great detail. If a deck of cards or pieces is used, describe which cards or pieces are in the deck (if possible). For example:

Physical: Each player takes the 12 troop cards out of the box, shuffles them, and places them in a facedown reserve.
Digital: Each player has 12 troops: 3x Skully (strength 1), 3x Captain (strength 2), 3x Jumbo (strength 3), 3x Kwak (joker). The game shuffles them. They are not displayed.

---

In the rules sections, write down each rule that an AI agent needs to implement. Each rule must contain all information an AI agent needs to implement the rule. Each rule should be a single sentence and start with "Rule {number}:". Do NOT write too much information in a single rule, split them up instead. The rules should be as short and simple as possible. Most importantly: Do NOT write general rules that are not testable. Each rule must be concrete and testable with a simple unit test!

---

Example rules.md:

# General
The game starts with an empty 9x9 grid. Each player has an infinate supply of pieces. Players take turns to place a piece on the board. Surrounded pieces are captured.

# Rules
Rule 1: On their turn, a player clicks on an empty cell on the board to place a piece.
Rule 2: When a player completely surrounds a group of opponent pieces, the opponent pieces are removed from the board.

