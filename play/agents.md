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

2. Your code should contain extensive print statements that describe each action after it happened. Use the past tense. Output all relevant information to verify that everything works as specified. For example:

Player
	tick
		positon += direction
		print "{this} moved in {direction} to {position}"

3. In case something isn't working, come up with a list of hypothesis of all possible causes. Add detailed print statements that help you identify the true cause of the problem and fix it.

4. Write unit tests in the static class "tests" in a new file in the "tests/" folder (for example "tests/playerMovement.l"). The tests should simulate user inputs to test all the functionality you implemented. For example:

tests
	playerShouldMoveRight
		app.createTestLevel
		moveLeftStickTo {1,0} by bluePlayer
		wait 10 frames
		expect bluePlayer.gridPos toBe {1,0}

5. Run the unit test, carefully analyze the output and check if everything is working.

6. Fix all problems and repeat until you verified everything works as specified.

# Screen dimensions and color
In LiveTime, the total screen size is always {1920, 1080}.
The center of the screen is at {0,0}.
The x-coordinate ranges from -960 to 960.
The y-coordinate ranges from -540 to 540.
So the top-left corner is {-960,-540}, the bottom-right corner is {960,540}.
The background is black by default. 

# Library Source Code
When you want to find a name of a function in the standard library or you have problems resolving errors, read the source code in the folders "lib/core/js/", "lib/core/2D/" and "lib/core/play/"

lib/core/js/base.l	Standard Libaray (int, float, string, List, Dictionary, etc).
lib/core/js/time.l	Time Library (Time, Date, etc).
lib/core/2D/graphics.l	Graphics Library (drawImage, drawRectangle, drawCircle, etc).
lib/core/2D/geometry.l	Geometry Library (Vector2, IntVector2, Matrix, etc)
lib/core/play/sound.l	Sound Library (playSound, setVolume, etc)
lib/core/play/tests.l	Unit Test Framework (click, drag, moveLeftStickTo, wait, expect, etc)

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
	
app
	Player currentPlayer
	Item[] items
	start
		items.add {}

	tick
		items.each.tick
		players.each.tick

// Handle input
Player
	string inputText

	onKeyDown: Key key, string character
		if character:	inputText += character
		if key == Backspace:	inputText = inputText[..-1]
		print "{this} pressed {key} ({character})" type:Event

	onKeyUp: Key key
		print "{this} released {key}" type:Event

	onTouchHover: Touch touch
		app.items.each.hoverTouch = touch.position insideRectangle .position, .size ? touch : null
	
	onTouchDown: Touch touch
		let item = app.items.find.hoverTouch == touch
			item.dragTouch = touch
			item.dragOffset = item.position - touch.position
			print "{this} clicked {item.name}" type:Event
	
	onTouchDrag: Touch touch
		let item = app.items.find.dragTouch == touch
			item.position = touch.position + item.dragOffset
			print "{this} dragged {item.name}" type:Event
	
	onTouchUp: Touch touch
		let item = app.items.find.dragTouch == touch
			item.dragTouch = null
			print "{this} dropped {item.name}" type:Event

	tick
		if gameController.leftStick.magnitude > .1
			print "{this} moved their left stick to {gameController.leftStick}" type:Event

		if gameController.a.wasJustPressed
			print "{this} just pressed the A button on their game controller" type:Event

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
// bluePlayer	== players[0]
// redPlayer	== players[1]
// greenPlayer	== players[2]
// yellowPlayer	== players[3]
tests
	playerShouldMoveRight
		setupTestLevel

		// Simulate a click at screen position {250,350} by bluePlayer (players[0])
		click {250,350} by bluePlayer

		// Simulate a drag from {0,0} to {300,0} by redPlayer (players[1])
		drag {0,0} to {300,0} by redPlayer

		// Simulate moving the left stick to {1,0} (right) by greenPlayer (players[2])
		moveLeftStickTo {1,0} by greenPlayer

		// Wait for 3 frames. At 30 ticks per second, this corresponds to 100 milliseconds.
		wait 3 frames

		// Assert
		expect bluePlayer.gridPos toBe {1,0}

		// Use printWhatIsOnScreen to check if the what is shown on screen is correct
		printWhatIsOnScreen

	// Make helper functions that are not tests private
	private setupTestLevel
		app.cells.clear
		app.cells[1,2].isBlocking = true

# Images, Sounds and Fonts
Read "src/media.l" for all images, sounds and fonts available in the project. Place new images in the "media/" folder. For instance, if you place "Example.png" in this folder, you can use "Example" in drawImage:

app
	tick
		drawImage Example, position:{0,0} // draws the image "media/Example.png"

# Example: The board game "Go"
enum Phase: PlacePiece, GameOver

app
	// All LiveTime games are online multiplayer games that show the video feed of each player on the screen.
	// The screen size is always {1920, 1080}.
	// We display the videos at the left and right side of the screen, leaving a usable area of about {700,700} in the middle of the screen
	const Vector2 totalBoardSize = {700,700}
	
	// We use a two dimensional grid of Cell for the cells of the game board
	// We can later access the individual cells with cell[x,y] or cell[gridPos]
	Grid<Cell> cells = {size:{9, 9}}
	
	// To correctly center the board, we need to offset it by cellSize * (cells.size - {1,1}) / -2
	// Don't make the mistake of multiplying by cellCount / -2 instead of (cells.size - {1,1}) / -2
	const Vector2 cellSize = totalBoardSize / cells.size
	const Vector2 cellOffset = cellSize * (cells.size - {1,1}) / -2

	Player currentPlayer
	Phase phase = PlacePiece
	
	// Called when the app starts
	start
		graphics.drawingOrder = LastDrawnWillBeInFront

		// We always need to display the standard menu
		Menu()
		
		// Create empty grid cells
		for cells.size as gridPos
			cells[gridPos] = Cell(gridPos)
		
		// In LiveTime, the global variable "players" always contains a list of players
		// We pick a random player as the start player
		currentPlayer = players.random
		print "Started go example"

	// Called when a player touches the screen
	onTouchDown: Touch touch
		let cell = cells[touch.position.toGridPos]
			placePiece cell, player:currentPlayer
				
	// Called on every frame (30 times per second)
	tick
		for cells as cell
			Vector2 screenPos = cell.gridPos.toScreenPos
			
			if cell.player
				// Draw a circle with its center at screenPos
				// The background is black in LiveTime, so we need to make sure we use colors that are different from black.
				drawCircle screenPos, size:60, color:cell.player.color

				// Draw text with its center at screenPos
				drawText "{cell.liberties}", screenPos, size:30					
			else
				drawCircle screenPos, size:8
		
		// Call the tick function for each player
		players.each.tick
		
	placePiece: Cell cell, Player player
		if cell.player: return
		cell.player = player
		captureSurroundedPieces cell.gridPos, player
		print "{player} placed a piece at {cell.gridPos}"
		
		// Set current player to the next player
		currentPlayer = players next currentPlayer
		
	captureSurroundedPieces: IntVector2 originPos, Player attacker
		for IntVector2.primaryDirections as dir
			IntVector2 neighborPos = originPos + dir
			Cell neighborCell = cells[neighborPos]
			
			if neighborCell and neighborCell.player and neighborCell.player != attacker
				Cell[] surroundesCells = collectSurroundesCells neighborPos, attacker
					surroundesCells.each.player = null
					print "{attacker} captured {surroundesCells.length} cells: {surroundesCells.joinToString.gridPos.toString}"
		
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
		ParticleSystem(position:winner.pos)
		print "{winner} won with {winner.score} points"

struct IntVector2
	toScreenPos := app.cellOffset + this * app.cellSize

struct Vector2
	toGridPos := ((this - app.cellOffset) / app.cellSize).round
		
class Cell
	IntVector2 gridPos
	Player player
	int liberties
	bool visited
		
// Each player has the following member variables already declared: index, color and score. Do not declare them again.
class Player
	IntVector2 dir = IntVector2.horizontalDirections[index]
	Vector2 pos = dir * {690,265}
		
	tick
		// In LiveTime, we always show a video feed for each player
		float radius = 255
		drawCircle pos, size:radius*2, outlineColor:color, outlineWidth:12
		drawVideo this, pos, size:radius*2-75, shape:Circle
		
		// Draw the score
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		Vector2 scorePos = pos + math.getVectorForAngle(-45°)*radius
		drawCircle scorePos, color:Black, outlineColor:color, size:60
		drawText score, scorePos, size:31
