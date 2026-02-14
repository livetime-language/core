---
description: LiveTime Programming Language Examples and Standard Library
applyTo: "*.l"
---
# Use the LiveTime programming language
LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation (never spaces). Place all the code in the file "src/app.l".

Always write the shortest, simplest possible and most efficient code.
Avoid code duplication. Do not overengineer. Keep it simple.

# Show the player's video
LiveTime games are online multiplayer games. You must draw the video feed of each player. For example:

class Player
	tick
		drawVideo this, pos, size:435, shape:Circle

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
	// All functions, variables and constants need to be part of a class. There are no top-level functions, variables or constants in LiveTime.
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

// Use these member functions of the Player class to handle input. 
// These functions must be members of the Player class. That way, you know which player triggered an event. 
class Player
	string inputText

	// Important: Always make sure each player can only interact with their own items (or items they are allowed to interact with)
	onTouchHover: Touch touch
		app.items.each.hoverTouch = .owner == this and touch.position insideRectangle .position, .size ? touch : null
	
	onTouchDown: Touch touch
		let item = app.items.find.hoverTouch == touch
			item.dragTouch = touch
			item.dragOffset = item.position - touch.position
			print "{item.name} clicked by {this}"
	
	onTouchDrag: Touch touch
		let item = app.items.find.dragTouch == touch
			item.position = touch.position + item.dragOffset
			print "{item.name} dragged by {this}"
	
	onTouchUp: Touch touch
		let item = app.items.find.dragTouch == touch
			item.dragTouch = null
			print "{item.name} dropped by {this}"

	onKeyDown: Key key, string character
		if character:	inputText += character
		if key == Backspace:	inputText = inputText[..-1]
		print "{key} ({character}) pressed by {this}"

	onKeyUp: Key key
		print "{key} released by {this}"

	tick
		if gameController.leftStick.magnitude > .1
			print "Left stick moved to {gameController.leftStick} by {this}"

		if gameController.A.wasJustPressed
			print "Button A was just pressed by {this}"

		// Draw input text
		drawText inputText+"_", position:IntVector2.horizontalDirections[index] * {800,0}

class Item
	string name = "Item"
	Vector2 size = {240,60}
	Vector2 position
	Touch hoverTouch, dragTouch
	Vector2 dragOffset
	Player owner
	
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
		app.cells.each.reset
		app.cells[1,2].isBlocking = true

# Images, Sounds and Fonts
Read "src/media.l" for all images, sounds and fonts available in the project. Place new images in the "media/" folder. For instance, if you place "Example.png" in this folder, you can use "Example" in drawImage:

app
	tick
		drawImage Example, position:{0,0} // draws the image "media/Example.png"

# Example: The board game "Go"
enum Phase: PlacePiece, GameOver

app
	// The screen size is always {1920, 1080}.
	// All LiveTime games are online multiplayer games that show the video feed of each player on the screen.
	// We display the videos at the left and right side of the screen, leaving a usable area of about {700,700} in the middle of the screen.
	const Vector2 totalBoardSize = {700,700}
	
	// We use a two dimensional grid of Cell for the cells of the game board
	// We can access the individual cells with cell[x,y] or cell[gridPos]
	Grid<Cell> cells = {size:{9, 9}}
	
	// To correctly center the board, we need to offset it by cellSize * (cells.size - {1,1}) / -2
	// Don't make the mistake of multiplying by cellCount / -2
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
		
		// In LiveTime, the global variable players always contains a list of players
		// We pick a random player as the start player
		currentPlayer = players.random
		nextTurn

	nextTurn
		// Set current player to the next player
		currentPlayer = players next currentPlayer
		print color:currentPlayer.color, "# Turn of {currentPlayer} started"
				
	// Called on every frame (30 times per second)
	tick
		// Call tick function for each cell
		cells.each.tick
		
		// Call tick function for each player
		players.each.tick
						
	finishGame
		Player winner = players.withMax.score
		ParticleSystem(position:winner.pos)
		print "Game won with {winner.score} points by {winner}"

struct IntVector2
	toScreenPos := app.cellOffset + this * app.cellSize

struct Vector2
	toGridPos := ((this - app.cellOffset) / app.cellSize).round
		
class Cell
	IntVector2 gridPos
	Player player
	int liberties
	bool visited

	tick
		Vector2 screenPos = gridPos.toScreenPos
		
		if player
			// Draw a circle with its center at screenPos
			// The background is black in LiveTime, so we need to make sure we use colors that are different from black.
			drawCircle screenPos, size:60, color:player.color

			// Draw text with its center at screenPos
			drawText "{liberties}", screenPos, size:30					
		else
			drawCircle screenPos, size:8
		
// The Player class automatically has the following member variables: index, color and score. Do not declare them again.
class Player
	IntVector2 dir = IntVector2.horizontalDirections[index]
	Vector2 pos = dir * {690,265}
		
	tick
		// You must draw the video feed of each player.
		float radius = 255
		drawCircle pos, size:radius*2, outlineColor:color, outlineWidth:12
		drawVideo this, pos, size:radius*2-75, shape:Circle
		
		// Draw the score
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		Vector2 scorePos = pos + math.getVectorForAngle(-45°)*radius
		drawCircle scorePos, color:Black, outlineColor:color, size:60
		drawText score, scorePos, size:31

	// Called when the player touches the screen
	// Important: Only the current player is can make a move
	onTouchDown: Touch touch
		if app.currentPlayer != this: return
		let cell = app.cells[touch.position.toGridPos]
			if cell.player:	print "Cell {cell.gridPos} occupied by {cell.player} clicked by {this}"
			else	print "Empty cell {cell.gridPos} clicked by {this}"
			placePiece cell

	placePiece: Cell cell
		if cell.player: return
		cell.player = this
		captureSurroundedPieces cell.gridPos
		print "Piece placed at {cell.gridPos} by {this}"
		app.nextTurn
				
	captureSurroundedPieces: IntVector2 originPos
		for IntVector2.primaryDirections as dir
			IntVector2 neighborPos = originPos + dir
			Cell neighborCell = app.cells[neighborPos]
			
			if neighborCell and neighborCell.player and neighborCell.player != this
				Cell[] surroundesCells = collectSurroundesCells neighborPos
					surroundesCells.each.player = null
					print "{surroundesCells.length} cells captued by {this}: {surroundesCells.joinToString.gridPos.toString}"
	
	// We can specify the return type in front of the name of a function
	Cell[] collectSurroundesCells: IntVector2 originPos
		IntVector2[] queue = [ originPos ]
		Cell[] surroundedCells = [ app.cells[originPos] ]
		
		// For each player, set the visited variable to false
		app.cells.each.visited = false
		
		while queue
			IntVector2 pos = queue.pop
			Cell cell = app.cells[pos]
			surroundedCells.add cell
			cell.visited = true
			
			for IntVector2.primaryDirections as dir
				IntVector2 neighborPos = pos + dir
				Cell neighborCell = app.cells[neighborPos]
				if neighborCell and not neighborCell.visited
					if neighborCell.player == null
						return []
					if neighborCell.player != this
						queue.add neighborPos
						
		return surroundedCells

# When you are done writing code, test if it is working
1. Check if you wrote the simplest possible code. Refactor your code until you arrive at the shortest, simplest possible and most efficient code.

2. Make sure you fixed all linter errors.

3. Your code should contain extensive print statements that describe each action after it happened. Use the past tense. Output all relevant information to verify that everything works as specified. For example:

Player
	tick
		positon += direction
		print "{this} moved in {direction} to {position}"

4. In case something isn't working, come up with a list of hypothesis of all possible causes. Add detailed print statements that help you identify the true cause of the problem and fix it.

5. Write unit tests in the static class "tests" in a new file in the "tests" folder (for example "tests/playerMovement.l"). The tests should simulate user inputs with click, drag, moveLeftStickTo, etc to test the complete code and all edge cases. For example:

tests
	playerShouldMoveRight
		app.createTestLevel
		moveLeftStickTo {1,0} by bluePlayer
		wait 10 frames
		expect bluePlayer.gridPos toBe {1,0}

6. Use the vscode's build-in tool (execute/runTests) or the runTests tool to run the unit tests.

7. Carefully analyze the output and check if everything is working.

8. Fix all problems and repeat until you verified everything works as specified.
