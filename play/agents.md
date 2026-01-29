---
description: LiveTime Programming Language Examples and Standard Library
globs: *.l
alwaysApply: true
---
# Use the LiveTime programming language
LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation (never spaces). Place all the code in the file "src/app.l".

Always write the shortest, simplest possible and most efficient code.
Avoid code duplication. Do not overengineer. Keep it simple.

# When you are done writing code, test if it is working!
1. Double check you wrote the shortest, simplest possible and most efficient code.

2. Your code should contain print statements that output all relevant information to verify that everything works as specified. In case something isn't working, your print statements need to output everything you need to find the cause of the problem. For example:
Player
	tick
		print "Player {color} moves in {direction} to {position}"

3. Write a unit test function in 'src/tests.l' that simulates user inputs to test all the functionality you implemented. For example:
tests
	playerShouldMoveRight
		setGameController playerIndex:0 leftStick:{1,0}
		wait 500 milliseconds		

4. Use the LiveTime RunTest tool to run the test function you wrote (e.g. 'tests.playerShouldMoveRight') and get the debug logs that your print statements output.

5. Carefully analyze the debug logs and check if everything is working.

6. Fix all problems and repeat until you verified everything works as specified.

# Basics of the LiveTime programming language
enum State
	InProgress
	Done

class Document
	string id
	float created
	State state

static class app
	Color primaryColor = #0000ff
	Document[] documents

	start
		// List (array that grows in size as needed)
		Document[] documents = [
			{created:DateTime.now, state:InProgress}
		]
		Document doc = {id:"002e", created:DateTime.now, state:Done}
		documents.add doc
		documents.remove doc
		documents.orderBy.created
		documents.clear
		let firstTwoItems = documents[..2]
		let lastTwoItems = documents[-2..]

		// Dictionary (hashtable that maps keys to values)
		Document[string] documentsById
		documentsById["002f"] = {id:"002f"}
		documentsById.remove "002f"
		documentsById.clear
		for documents as doc
			documentsById[doc.id] = doc
		for documentsById as doc, id
			print "id:{id} created:{doc.created.toDayMonthYearString}"

		// Conditions
		if documents.length > 0
			print "There are {documents.length} documents."
		else
			print "There are no documents."

		// Iterate over a List
		for documents as doc
			print doc.id

		// Iterate over an integer range
		// Prints 01234
		for 0 to 5 as i
			print i

		// If you leave out the lower bound, it defaults to 0
		// If you leave out the index variable, it defaults to i
		for 5
			print i

		// You can use "." to refer to the current item while iterating
		for documents
			print .

		// Prints 01234
		for 5
			print .
			
		// Use the "backwards" keyword to iterate backwards
		// Prints 43210
		for 5 backwards as i
			print i

		// Iterate over a List by index
		for documents.length as i
			print documents[i].state

		// Iterate over a Dictionary
		for documentsById as value, key
			print "{key}: {value}"

		// If you divide an integer by an integer in LiveTime, you always get a float
		float fraction = 1 / 2

		// Use math.floor after a division if you need an integer
		int flooredInteger = math.floor(1 / 2)

		// Query
		Player[] healthyPlayers = players.where.health > 0
		Player[] top10Players = (players.orderByDescending.score).take 10
		Player[] seniors = (users.where.age > 65).orderBy.age
		Player[] highscoreList = (player.where.isAlive).orderByDescending.score

		// Cast
		string jsonString = "\{value:7\}"
		dynamic config = json.parse(jsonString)
		int value = (int)config.value

		// In LiveTime, the % symbol is used for percentages, like in css, e.g. width:100%
		// To calucate the remainder of a division, use mod or remainder. 
		// mod returns the remainder after a floored division, always producing a result with the same sign as the divisor, like in Python.
		float bufferSize = 100
		let a = 107 mod bufferSize // a = 7
		let b = -1 mod bufferSize  // b = 99
		
# Images
Place images in the "media" folder.  If you place "Example.png" in this folder, you can use "Example" in drawImage. For example:
app
	tick
		drawImage Example, position:{0,0} // draws the image "media/Example.png"

# More information
Read the full LiveTime library documentation "lib/core/play/documentation.md" if you have problems resolving linter errors or you want to find the name of a function.

"lib/core/js/" contains the LiveTime standard libaray (int, float, string, List, Dictionary, etc).
"lib/core/play/" contains the LiveTime graphics and input library (drawImage, drawRectangle, onTouchDown, onTouchUp, player.gameController, etc).

# Example game implementing the board game "Go" in the LiveTime programming language
enum Phase: PlacePiece, GameOver

app
	// In LiveTime, the total screen size is always {1920, 1080}
	// The background is black by default
	// We need to display the player video at the left and right side of the screen
	// That leave a usable area of {700,700} in the middle of the screen
	const Vector2 totalBoardSize = {700,700}
	const int cellCount = 9
	
	// We use a two dimensional grid of Cell for the cells of the game board
	// We can later access the individual cells with cell[x,y]
	Grid<Cell> cells = {size:{cellCount, cellCount}}
	
	Player currentPlayer
	Phase phase = PlacePiece
	
	// This defines the function "start" of the class "app". All functions need to part of a class.
	// There are no top-level functions in LiveTime.
	// The "start" function is called when the game starts
	start
		graphics.drawingOrder = ItemsDrawnFirstWillBeInTheBack

		// We always need to display the standard menu
		Menu()
		
		// Create empty grid cells
		for cellCount as x
			for cellCount as y
				cells[x,y] = Cell(pos:{x,y}, player:null)
		
		// In LiveTime, the global variable "players" always contains a list of players
		// We pick a random player as the start player
		currentPlayer = players.random
				
	// The "tick" function is called on every frame (30 times per second)
	tick
		// The center of the screen has the coordinates {0,0}
		// The x-coordinate ranges from -960 to 960
		// The y-coordinate ranges from -540 to 540
		// So the top-left corner is {-960,-540}, the bottom-right corner is {960,540}
		// To correctly center the board, we need to offset it by cellSize * (cellCount - 1) / -2
		// Don't make the mistake of multiplying by cellCount / -2 instead of (cellCount - 1) / -2
		Vector2 cellSize = totalBoardSize / cellCount
		Vector2 cellOffset = cellSize * (cellCount - 1) / -2
		for cellCount as x
			for cellCount as y
				IntVector2 gridPos = {x,y}
				Vector2 pixelPos = cellOffset + gridPos * cellSize
				Cell cell = cells[gridPos]
				
				if cell.player
					// Draw a circle with its center at pixelPos
					// The background is black in LiveTime, so we need to make sure we use colors that are different from black.
					drawCircle pixelPos, size:60, color:cell.player.color

					// Draw text with its center at pixelPos
					drawText "{cell.liberties}", pixelPos, size:30					
				else
					drawCircle pixelPos, size:8
					
					// When the current player clicks on an empty cell, place a piece
					// We use "by:currentPlayer" to only consider touches by the current player
					onTouchDown position:pixelPos by:currentPlayer size:cellSize
						placePiece gridPos, cell, player:currentPlayer
		
		// Call the tick function for each player
		players.each.tick
		
	placePiece: IntVector2 gridPos, Cell cell, Player player
		print "Player {player} places a piece at {gridPos}"
		cell.player = player
		captureSurroundedPieces gridPos, player
		
		// Set current player to the next player
		currentPlayer = players next currentPlayer
		
	captureSurroundedPieces: IntVector2 originPos, Player attacker
		for IntVector2.primaryDirections as dir
			IntVector2 neighborPos = originPos + dir
			Cell neighborCell = cells[neighborPos]
			
			if neighborCell and neighborCell.player and neighborCell.player != attacker
				Cell[] surroundesCells = collectSurroundesCells neighborPos, attacker
				if surroundesCells
					print "Player {attacker} surrounded {surroundesCells.length} cells: {surroundesCells.joinToString.pos.toString}"
					surroundesCells.each.player = null
		
	// We write the return type in front of the function.
	// The function collectSurroundesCells takes an integer vector and a player and returns a list of cells
	Cell[] collectSurroundesCells: IntVector2 originPos, Player attacker
		IntVector2[] queue = [ originPos ]
		Cell[] surroundedCells = [ cells[originPos] ]
		
		// For each player, set the visited variable to false
		cells.each.visited = false
		
		while queue
			IntVector2 pos = queue.pop
			Cell cell = cells[pos]
			surroundedCells.add cell
			cell.visited = true
			
			for IntVector2.primaryDirections as dir
				IntVector2 neighborPos = pos + dir
				Cell neighborCell = cells[neighborPos]
				if neighborCell and not neighborCell.visited
					if neighborCell.player == null
						return []
					if neighborCell.player != attacker
						queue.add neighborPos
						
		return surroundedCells
		
	finishGame
		Player winner = players.withMax.score
		print "Player {winner} wins with {winner.score} points."
		ParticleSystem(position:winner.pos)
		
class Cell
	IntVector2 pos
	Player player
	int liberties
	bool visited
		
class Player
	// In LiveTime, each player always has an "index", a "color" and a "score" by default. We don't need to declare them.

	IntVector2 dir = IntVector2.horizontalDirections[index]
	Vector2 pos = dir * {690,265}
		
	tick
		IntVector2 a = {0,0}

		// In LiveTime, we always show a video feed for each player. Each LiveTime game need to contain this code.
		float radius = 255
		drawCircle pos, size:radius*2, outlineColor:color, outlineWidth:12
		drawVideo me, pos, size:radius*2-75, shape:Circle
		
		// Draw the score
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		Vector2 scorePos = pos + math.getVectorForAngle(-45°)*radius
		drawCircle scorePos, color:Black, outlineColor:color, size:60
		drawText score, scorePos, size:31

# Another example game in the LiveTime programming language
app
	int round
	Player currentPlayer
	Phase phase
	
	init
		graphics.drawingOrder = ItemsDrawnFirstWillBeInTheBack
		
	// List of words
	const string[] words = ["Apple", "Banana", "Orange"]
	Box[] boxes
	Item[] items
		
	startGame
		print "Starting game"
		for IntVector2.diagonalDirections as dir
			boxes.add {rect:{position:{220,280} * dir, size:{420,440}}}
		nextRound

		// When assigning an enum value to a variable, the enum name must be omitted
		// Write "phase = DrawItems" instead of "phase = Phase.DrawItems"
		phase = DragItems
		
	nextRound
		round++
		print "Starting round {round}"
		boxes.each.itemInBox = null
		words.shuffle
		items.clear
		
		Box[] top3OpenBoxes = boxes.where.isOpen | orderBy.rect.position.y | take 3
		
		string[] namesOfAlivePlayers = players.where.alive | orderBy.score | select.name

		// Create item for each word, center them at {0,10} with {400,0} pixels between them
		forPositions words, center:{0,10}, delta:{400,0}
			items.add {position:pos, word:.}
			
		// Make the next player the current player
		currentPlayer = players next currentPlayer
			
	tick
		items.each.tick
		boxes.each.tick
		players.each.tick
		
		switch phase
			DragItems
				// If all items are dropped into boxes, show "Next Round button"
				if items.all.droppedInBox != null
					drawButton "Next Round", image:Button, position:{0,0}, visibleFor:currentPlayer
						print "Player {touch.by} clicked 'Next Round'."
						phase = Reveal
						nextRound
			Reveal
				// Draw yellow text centered at {0,0} that's visible for everybody
				drawText "Reveal", position:{0,0}, size:32, Color("#ffff00"), visibleFor:everybody
				
			GameOver
				tickGameOver
				
				// Draw green text centered at {0,0} that's visible only for the first player
				drawText "Game Over", position:{0,0}, size:32, Color("#00ff00"), visibleFor:players[0]
				
	tickGameOver
		phase = GameOver
		
		Player offencePlayer = players.find.role == Offence
			print "Found offence player: {offencePlayer}"
		else
			print "No offence player"
		
		Player defencePlayer = players.find.role == Defence
			print "Found defence player: {defencePlayer}"
		else
			print "No defence player"
		
		// Order players by score
		players.orderByDescending.score

// Always put classes, structs and enums outside of classes. You can't put them inside a class like "app".
enum Role: Offence, Defence
enum Phase: DragItems, Reveal, GameOver

class Player
	bool alive
	Role role
	
	visible IntVector2 dir = IntVector2.horizontalDirections[index]
	visible Vector2 videoPos = dir * {700,270}
	
	tick
		// In LiveTime, we always show a video feed for each player. Each LiveTime game need to contain this code.
		float radius = 255
		drawCircle videoPos, size:radius*2, outlineColor:color, outlineWidth:12
		drawVideo me, videoPos, size:radius*2-75, shape:Circle
		
		// Draw the score
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		Vector2 scorePos = videoPos + math.getVectorForAngle(-45°)*radius
		drawCircle scorePos, color:Black, outlineColor:color, size:60
		drawText score, scorePos, size:31

		
		// Draw yellow player name that's visible the current player instance
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		drawText name, size:32, Color("#ffff00"), visibleFor:me
	
class Item
	const Vector2 size = {300,60}
	bool moveable = true
	Vector2 position, originalPosition
	Touch moveTouch
	Vector2 touchOffset
	Box droppedInBox
	string word
	
	tick
		switch app.phase
			DragItems
				// The current player can drag item around with the mouse
				// Use "by:app.currentPlayer" to ensure only the current player can drag items
				onTouchDown position, size, by:app.currentPlayer
					// Start dragging
					print "Player {touch.by} started dragging {word} at {touch.position}"
					Player playerWhoClicked = touch.by
					moveTouch = .
					originalPosition = position
					touchOffset = position - .position
					if droppedInBox
						droppedInBox.itemInBox = null
						droppedInBox = null
						
				onTouchMove moveTouch
					// Drag item
					position = .position + touchOffset
					
				onTouchUp moveTouch
					// Drop item
					print "Player {touch.by} dropped {word} at {touch.position}"
					Box droppedInBox = app.boxes.find.rect.contains position
					if droppedInBox and droppedInBox.itemInBox == null
						this.droppedInBox = droppedInBox
						droppedInBox.itemInBox = this
						position = droppedInBox.rect.position
					else
						// Box is full, revert to original position
						position = originalPosition
					moveTouch = null
					
			GameOver
				// Draw red text centered at position
				// The background is black in LiveTime, so we need to make sure we use colors that are different from black.
				drawText "Game Over", position, size:40, Color("#ff0000"), font:OpenSans
				
		// Draw blue circle with a radius of 200 with a green outline
		drawCircle position, size:400, Color("#0000ff"), outlineColor:Color("#00ff00"), outlineWidth:5
		
class Box
	Rect rect
	Item itemInBox
	bool isOpen
	
	tick
		// Draw blue box with white outline
		drawRectangle rect.position, rect.size, Color("#0000ff"), outlineColor:Color("#ffffff"), outlineWidth:5
