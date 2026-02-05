---
description: LiveTime Programming Language Examples and Standard Library
applyTo: "*.l"
---
# Use the LiveTime programming language
LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation (never spaces). Place all the code in the file "src/app.l".

Always write the shortest, simplest possible and most efficient code.
Avoid code duplication. Do not overengineer. Keep it simple.

# When you are done writing code, test if it is working
1. Check if you wrote the simplest possible code. Refactor your code until you arrive at the shortest, simplest possible and most efficient code.

2. Your code should contain print statements that output all relevant information to verify that everything works as specified. For example:

Player
	tick
		positon += direction
		print "Player {index} moves in {direction} to {position}"

3. In case something isn't working, come up with a list of hypothesis of all possible causes. Add print statements that help you identify the true cause of the problem and fix it.

4. Write unit tests in the static class "tests" in a new file in the "tests/" folder (for example "tests/playerMovement.l"). The tests should simulate user inputs to test all the functionality you implemented. For example:

tests
	playerShouldMoveRight
		app.createTestLevel
		setGameController playerIndex:0 leftStick:{1,0}
		wait 500 milliseconds
		expect players[0].gridPos toBe {1,0}
		printWhatIsOnScreen

5. Use printWhatIsOnScreen in your tests to check if the screen content is correct and nothing overlaps that shouldn't overlap. 

6. Use the runTests tool to run the unit test. Carefully analyze the output and check if everything is working.

7. Fix all problems and repeat until you verified everything works as specified.

# Basics of the LiveTime programming language
enum State
	InProgress
	Done

// Defines the class Document
// Classes have uppercase names. All members are public by default.
class Document
	string id
	float created
	State state

// Defines the static class app, the main class of every application.
// Static classes have lowercase names. Their members are public and static by default.
// You can access their members from anywhere like this: app.primaryColor, app.start, app.tick, ...
app
	Color primaryColor = #0000ff
	Document[] documents
	Player currentPlayer

	// Defines the member function start of the class app. 
	// All functions need to be part of a class. There are no top-level functions in LiveTime.
	// app.start is the entry point of the application.
	start
		// List (array that grows in size as needed)
		Document[] documents = [
			{created:DateTime.now, state:InProgress}
		]
		Document doc = {id:"2f", created:DateTime.now, state:Done}
		documents.add doc
		documents.remove doc
		documents.orderBy.created
		documents.clear
		let firstTwoItems = documents[..2]
		let lastTwoItems = documents[-2..]

		// Dictionary (hashtable that maps keys to values)
		Document[string] documentsById
		documentsById["2f"] = {id:"2f"}
		documentsById.remove "2f"
		documentsById.clear
		for documents as doc
			documentsById[doc.id] = doc
		for documentsById as doc, id
			print "id:{id} created:{doc.created.toDayMonthYearString}"

		// Find
		let doc = documents.find.id == "2f"

		// Conditions with if
		if documents.length > 0
			print "There are {documents.length} documents."
		else
			print "There are no documents."

		// Conditions with let
		let mike = players.find.name == "Mike"
			print "Found player with name Mike, his score is {mike.score}"
		else
			print "Did not find player with name Mike"

		// Iterate over a List
		for documents as doc
			print doc.id

		// Iterate over an integer range
		// Prints "01234", the upper bound is exclusive 
		for 0 to 5 as i
			print i

		// If you leave out the lower bound, it defaults to 0
		// If you leave out the declaration of the index variable, it defaults to i
		for 5
			print i

		// You can use "." to refer to the current item while iterating
		for documents
			print .

		// Prints "01234"
		for 5
			print .
			
		// Use the "backwards" keyword to iterate backwards
		// Prints "43210"
		for 5 backwards as i
			print i

		// Iterate over a List by index
		for documents.length as i
			print documents[i].state

		// Iterate over a Dictionary
		for documentsById as value, key
			print "{key}: {value}"

		// If you divide an integer by an integer in LiveTime, you always get a float
		float fraction = 1 / 2	// fraction = 0.5

		// Use math.floor after a division if you need an integer
		int flooredInteger = math.floor(1 / 2)

		// Query
		Player[] healthyPlayers	= players.where.health > 0
		Player[] top10Players	= (players.orderByDescending.score).take 10
		Player[] seniors	= (users.where.age > 65).orderBy.age
		Player[] highscoreList	= (player.where.isAlive).orderByDescending.score

		// Cast
		string jsonString	= "\{value:7\}"
		dynamic config	= json.parse(jsonString)
		int value	= (int)config.value

		// In LiveTime, the % symbol is used for percentages, like in css.
		div width:100%

		// To calucate the remainder of a division, use mod or remainder. 
		// mod returns the remainder after a floored division, like in Python.
		// A negative value mod a positive value will always be positive.
		let a = 107 mod 100	// a = 7
		let b =  -1 mod 100	// b = 99
		let c =  -1 remainder 100	// c = -1
	
// Handle input
Player
	string inputText

	onKeyDown: Key key, string character
		if character:	inputText += character
		if key == Backspace:	inputText = inputText[..-1]
		print "{this} presses {key} ({character})"

	onKeyUp: Key key
		print "{this} releases {key}"

	onTouchHover: Touch touch
		app.items.each.hoverTouch = touch.position insideRectangle .position, .size ? touch : null
	
	onTouchDown: Touch touch
		let item = app.items.find.hoverTouch == touch
			item.dragTouch = touch
			item.dragOffset = item.position - touch.position
			print "{this} clicks {item.name}"
	
	onTouchDrag: Touch touch
		let item = app.items.find.dragTouch == touch
			item.position = touch.position + item.dragOffset
			print "{this} drags {item.name}"
	
	onTouchUp: Touch touch
		let item = app.items.find.dragTouch == touch
			item.dragTouch = null
			print "{this} drops {item.name}"

	tick
		if gameController.leftStick.magnitude > .1
			print "{this} holds their left stick in this direction: {gameController.leftStick}"

		if gameController.a.wasJustPressed
			print "{this} just pressed the A button on their game controller"

		// Draw input text
		drawText inputText+"_", position:IntVector2.horizontalDirections[index] * {800,0}

class Item
	string name = "Item"
	Vector2 size = {240,60}
	Vector2 position
	Touch hoverTouch, dragTouch
	Vector2 dragOffset
	
	tick
		// Draw item					
		drawRectangle position, size, color:hoverTouch ? #808080 : #404040, outlineColor:Color("#ffffff"), outlineWidth:5

// Write units tests in the static class "tests" in a file in the "tests/" folder
tests
	playerShouldMoveRight
		// Simulate player 0 moving the left stick to {1,0} (right)
		setGameController playerIndex:0 leftStick:{1,0}

		// Wait for 300 milliseonds. At 30 ticks per second, this will execute app.tick 10 times
		wait 300 milliseconds

		// Assert
		expect players[0].gridPos toBe {1,0}

		// Use printWhatIsOnScreen in your test and check if the what is shown on screen is correct
		printWhatIsOnScreen

# Images, Sounds, Fonts
Read "src/media.l" for all images, sounds and fonts available in the project. Place new images in the "media" folder. If you place "Example.png" in this folder, you can use "Example" in drawImage, like this:

app
	tick
		drawImage Example, position:{0,0} // draws the image "media/Example.png"

# More information
When you want to find a name of a function in the standard library or you have problems resolving errors, read the source code in the folders "lib/core/js/" and "lib/core/play/".

"lib/core/js/" contains the LiveTime standard libaray (int, float, string, List, Dictionary, etc).

"lib/core/play/" contains the LiveTime graphics and input library (drawImage, drawRectangle, onTouchDown, onTouchUp, player.gameController, etc).

"lib/core/play/tests.l" contains the LiveTime unit test framework (setGameController, wait, expect, etcs)

# Example: The board game "Go"
enum Phase: PlacePiece, GameOver

app
	// In LiveTime, the total screen size is always {1920, 1080}
	// The background is black by default
	// All LiveTime games are online multiplayer games that show the video feed of each player on the screen
	// We display the videos at the left and right side of the screen, leaving a usable area of {700,700} in the middle of the screen
	const Vector2 totalBoardSize = {700,700}
	const int cellCount = 9
	
	// We use a two dimensional grid of Cell for the cells of the game board
	// We can later access the individual cells with cell[x,y]
	Grid<Cell> cells = {size:{cellCount, cellCount}}
	
	Player currentPlayer
	Phase phase = PlacePiece
	
	// The "start" function is called when the game starts
	start
		print "Starting go example"
		graphics.drawingOrder = LastDrawnWillBeInFront

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

		// In LiveTime, we always show a video feed for each player.
		float radius = 255
		drawCircle pos, size:radius*2, outlineColor:color, outlineWidth:12
		drawVideo this, pos, size:radius*2-75, shape:Circle
		
		// Draw the score
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		Vector2 scorePos = pos + math.getVectorForAngle(-45°)*radius
		drawCircle scorePos, color:Black, outlineColor:color, size:60
		drawText score, scorePos, size:31

# Example: Drag and Drop
app
	int round
	Player currentPlayer
	Phase phase
	
	init
		graphics.drawingOrder = LastDrawnWillBeInFront
		
	// List of words
	const string[] words = ["Apple", "Banana", "Orange"]
	Box[] boxes
	Item[] items
		
	start
		print "Starting drag-and-drop example game"
		for IntVector2.diagonalDirections as dir
			boxes.add {rect:{position:{220,260} * dir, size:{400,400}}}
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

		// Create item for each word, center them at {0,0} with {260,0} pixels between them
		forPositions words, center:{0,0}, delta:{260,0}
			items.add {position:pos, word:.}
		print words.length
			
		// Make the next player the current player
		currentPlayer = players next currentPlayer
			
	tick
		players.each.tick
		boxes.each.tick
		items.each.tick
		
		switch phase
			DragItems
				// If all items are dropped into boxes, show "Next Round button"
				if items.all.droppedInBox != null
					drawStandardButton "Next Round", position:{0,0}, visibleFor:currentPlayer
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

// Always put an enum, class or struct outside of classes. You can not nest them inside a class like "app".
enum Role: Offence, Defence
enum Phase: DragItems, Reveal, GameOver

class Player
	bool alive
	Role role
	
	visible IntVector2 dir = IntVector2.horizontalDirections[index]
	visible Vector2 videoPos = dir * {700,270}
	
	tick
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		// In LiveTime, we always show a video feed for each player.
		float radius = 255
		drawCircle videoPos, size:radius*2, outlineColor:color, outlineWidth:12
		drawVideo this, videoPos, size:radius*2-75, shape:Circle
		
		// Draw the score
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		Vector2 scorePos = videoPos + math.getVectorForAngle(-45°)*radius
		drawCircle scorePos, color:Black, outlineColor:color, size:60
		drawText score, scorePos, size:31

		// Draw information that's only visible to the current player
		drawText "Your color: {color}", position:{0,-500}, size:32, color:this.color, visibleFor:this
	
class Item
	const Vector2 size = {240,60}
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
					// Start dragging item
					print "Player {touch.by} started dragging {word} at {touch.position}"
					Player player = touch.by
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
				
		// Draw gray box with a white outline that's 5 pixels wide
		drawRectangle position, size, Color("#404040"), outlineColor:Color("#ffffff"), outlineWidth:5
		drawText word, position, size:28, Color("#ffffff"), font:OpenSans, align:Center
		
class Box
	Rect rect
	Item itemInBox
	bool isOpen
	
	tick
		drawRectangle rect.position, rect.size, Color("#303030"), outlineColor:Color("#ffffff"), outlineWidth:5
