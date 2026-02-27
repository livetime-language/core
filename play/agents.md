---
description: LiveTime Programming Language Examples and Standard Library
alwaysApply: true
applyTo: '**'
---
# Use the LiveTime programming language
LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation (never spaces). Place all the code in the file "src/app.l".

# Write simple, efficient code
Always write the shortest, simplest possible and most efficient code.
Avoid code duplication.
Analyze the complete code carefully. Check if there are opportunities to simplify the code or extract repeated functionality into functions.

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

lib/core/js/base.l	Standard Libaray (int, float, string, List, Grid, Dictionary, etc).
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
// A contructor is created automatically
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
		// Create an object of type Document
		// Calls the conctructor of the Document class and passes id, created and state
		Document doc = {id:"2f", created:Time.now, state:Done}

		// List (array that grows in size as needed)
		Document[] documents = [
			{created:Time.now, state:InProgress}
		]
		documents.add doc
		documents.remove doc
		documents.orderBy.created
		documents.clear
		let itemsFromIndex3To7 = documents[3 to 7]

		// Grid (2-dimensional array with a fixed size)
		Cell[8,8] grid
		Cell cell = {cellType:Empty}
		grid[6,7] = cell
		IntVector gridPos = {5,4}
		grid[gridPos] = {cellType:Blocker}
		IntVector2 gridSize = grid.size
		for grid as cell, gridPos
			print "At {gridPos} is a cell with type {cell.cellType}"

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

		// Conditions with if in one line
		if not currentPlayer then return

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

		// Print: Use type:Action for actions performed by a player
		print "Piece placed at {cell.gridPos} by {currentPlayer}", type:Action

		// Print: Use type:Reaction for reactions or consequences of an action
		print "Game won with {winner.score} points by {winner}", type:Reaction

		// Print: Use type:Debug for temporary debug messages
		print "Possible moves for {currentPlayer}: {possibleMoves}", type:Debug

		// Print: Use type:Headline when a new turn or round started. Pass in the current player's color.
		print "# Turn of {currentPlayer} started", type:Headline, color:currentPlayer.color
	
app
	Player currentPlayer
	Item[] items
	start
		items.add {}

	tick
		items.each.tick
		players.each.tick


// Handle input
app
	Item[] items

	onTouchHover: Touch touch
		for items as item
			// Important: If isOnlineMultiplayer it true, the touch must be by the owner of the item
			if isOnlineMultiplayer and touch.by != item.owner then continue
			item.hoverTouch = touch.position insideRectangle item.position, item.size ? touch : null
			print item.hoverTouch

	onTouchDown: Touch touch
		let item = app.items.find.hoverTouch == touch
			item.dragTouch = touch
			item.dragOffset = item.position - touch.position
			print "{item.name} clicked by {touch.by}", type:Action
	
	onTouchDrag: Touch touch
		let item = app.items.find.dragTouch == touch
			item.position = touch.position + item.dragOffset
			print "{item.name} dragged by {touch.by}", type:Action
	
	onTouchUp: Touch touch
		let item = app.items.find.dragTouch == touch
			item.dragTouch = null
			print "{item.name} dropped by {touch.by}", type:Action

	tick
		items.each.tick
		players.each.tick

class Player
	string inputText
	Vector2 pos
	const float speed = 8

	onKeyDown: Key key, string character
		if character	then inputText += character
		if key == Backspace	then inputText = inputText[..-1]
		print "{key} ({character}) pressed by {this}", type:Action

	onKeyUp: Key key
		print "{key} released by {this}", type:Action

	// Called on every frame (30 times per second) if a game controller is connected
	onGameController: GameController controller
		pos += controller.leftStick * speed

		if controller.A.wasJustPressed
			print "Button {controller.A.name} just pressed by {this}", type:Action

	tick
		drawCircle pos, color, size:64
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

// Write unit tests in the "tests" static class in the "tests" folder
// Use vscode's built-in test-runner tool execute/runTests or the runTests mcp server to run unit tests
tests
	pos: int x, int y
		return IntVector2(x, y).toScreenPos
		
	// Use the test keyword to declare a unit test. The test name should be in plain English.
	// Before each test, the application is reset and app.start is executed.
	// You can add code to change the state if you need a setup that's different from what app.start sets up.
	test Rule 7: Clicking a cell should place a piece
		app.currentPlayer = players[0]
		app.grid[0,0].player = players[0]
		print "Setup: Placed piece for player 0 at {0,0}", type:Info

		// Simulate a drag from screen position {100,0} to {200,0} by player 0
		drag {100,0} to {200,0} by players[0]

		// Simulate a click at grid position {1,0} by player 1
		click pos(1,0) by players[1]

		// Simulate moving the left stick to {1,0} (right) by player 0
		moveLeftStickTo {1,0} by players[0]

		// If you need to wait for animations to finish before continuing, use wait.
		// Wait for 15 ticks. At 30 ticks per second, this corresponds to 500 milliseconds.
		wait 15 ticks

		// Use printWhatIsOnScreen to check if the what is shown on screen is correct
		printWhatIsOnScreen

# Write extensive print statements
Write extensive print statements that describe each action after it happened. Use the past tense. Use type:Action for actions performed by a player, use type:Reaction for reactions or consequences of an action. For example:

app
	tick
		drawStandardButton "Swap"
			print "Swap button clicked by {touch.by}", type:Action
			players[0].pos swapWith players[1].pos
			print "Positions swapped, player 0: {players[0].pos}, player 1: {players[1].pos}", type:Reaction

# Images, Sounds and Fonts
Read "src/media.l" for all images, sounds and fonts available in the project. Place new images in the "media/" folder. For instance, if you place "Example.png" in this folder, you can use "Example" in drawImage:

app
	tick
		drawImage Example, position:{0,0} // draws the image "media/Example.png"

# Example: The board game "Go"
enum Phase: PlacePiece, GameOver

app
	// The screen size is always {1920, 1080}.
	// All LiveTime games are online multiplayer games. You must show the video feed of each player on the screen.
	// We display the videos at the left and right side of the screen, leaving a usable area of about {700,700} in the middle of the screen.
	const Vector2 totalBoardSize = {700,700}
	
	// We create a object of type Grid (a 2D array) with a size of 9x9 to hold the cells of type Cell
	Cell[9, 9] grid
	
	// To correctly center the board, we need to offset it by cellSize * (grid.size - {1,1}) / -2
	// Don't make the mistake of multiplying by cellCount / -2
	const Vector2 cellSize = totalBoardSize / grid.size
	const Vector2 cellOffset = cellSize * (grid.size - {1,1}) / -2

	Player currentPlayer
	Phase phase = PlacePiece
	
	// Called when the app starts
	start
		graphics.drawingOrder = LastDrawnWillBeInFront

		// We always need to display the standard menu
		Menu()
		
		// Create empty grid of cells
		for grid.size as gridPos
			grid[gridPos] = Cell(gridPos)
		
		// In LiveTime, the global variable players always contains a list of players
		// We pick a random player as the start player
		currentPlayer = players.random
		startTurn

	startTurn
		// Set current player to the next player
		currentPlayer = players next currentPlayer

		// Always print the start of the turn in the player's color!
		print "# Turn of {currentPlayer} started", type:Headline, color:currentPlayer.color

	// Called when a player touches the screen
	onTouchDown: Touch touch
		// Important: If isOnlineMultiplayer it true, the touch must be by the current player
		if isOnlineMultiplayer and touch.by != currentPlayer then return
		
		let cell = app.grid[touch.position.toGridPos]
			if not cell.player
				currentPlayer.placePiece cell
			else
				print "Invalid cell {cell.gridPos} occupied by {cell.player} clicked", type:Error
				
	// Called on every frame (30 times per second)
	tick
		// Call tick function for each cell in the grid
		grid.each.tick
		
		// Call tick function for each player
		players.each.tick
						
	finishGame
		Player winner = players.withMax.score
		ParticleSystem(position:winner.pos)
		print "Game won with {winner.score} points by {winner}", type:Reaction

struct IntVector2
	toScreenPos => app.cellOffset + this * app.cellSize

struct Vector2
	toGridPos => ((this - app.cellOffset) / app.cellSize).round
		
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

	placePiece: Cell cell
		if cell.player then return
		cell.player = this
		print "Piece placed at {cell.gridPos} by {this}", type:Action
		captureSurroundedPieces cell.gridPos
		app.startTurn
				
	captureSurroundedPieces: IntVector2 originPos
		for IntVector2.primaryDirections as dir
			IntVector2 neighborPos = originPos + dir
			Cell neighborCell = app.grid[neighborPos]
			
			if neighborCell and neighborCell.player and neighborCell.player != this
				Cell[] surroundesCells = collectSurroundesCells neighborPos
					surroundesCells.each.player = null
					print "{surroundesCells.length} cells captued by {this}: {surroundesCells.joinToString.gridPos.toString}", type:Reaction
	
	// We can specify the return type in front of the name of a function
	Cell[] collectSurroundesCells: IntVector2 originPos
		IntVector2[] queue = [ originPos ]
		Cell[] surroundedCells = [ app.grid[originPos] ]
		
		// For each player, set the visited variable to false
		app.grid.each.visited = false
		
		while queue
			IntVector2 pos = queue.pop
			Cell cell = app.grid[pos]
			surroundedCells.add cell
			cell.visited = true
			
			for IntVector2.primaryDirections as dir
				IntVector2 neighborPos = pos + dir
				Cell neighborCell = app.grid[neighborPos]
				if neighborCell and not neighborCell.visited
					if neighborCell.player == null
						return []
					if neighborCell.player != this
						queue.add neighborPos
						
		return surroundedCells
