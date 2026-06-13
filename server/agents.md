---
description: LiveTime Programming Language Examples and Standard Library
alwaysApply: true
applyTo: '**'
---
# Use the LiveTime programming language
LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation (never spaces). Place all the code in the file "src/app.l".

# Write simple, fast code
Write simple, fast, efficient code.

# Descriptive names, no abbreviations
Use readable and descriptive variable and function names. Do not use abbreviations. For example, use "verticalCollision" instead of "vCol".

# Basics of the LiveTime programming language
enum State
	InProgress
	Done

// Defines the class Document
// Classes have uppercase names. All members are public by default.
// A contructor is created automatically
class Document
	string	id
	float	created
	State	state

// Defines the static class app, the main class of every application.
// Static classes have lowercase names. Their members are public and static by default.
// You can access their members from anywhere like this: app.primaryColor, app.start, app.tick, ...
app
	const Color	primaryColor = #0000ff
	Document[]	documents
	Player	currentPlayer

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
		print "Placed piece at {cell.gridPos} by {currentPlayer}", type:Action

		// Print: Use type:Reaction for reactions or consequences of an action. For example, when a piece is captured as  a result of a player's move.
		print "Game won with {winner.score} points by {winner}", type:Reaction

		// Print: Use type:NoAction when no action was performed. For example, if isOnlineMultiplayer is true and the click is not by the current player. Or if the state or user input is invalid.
		print "Play clicked by {touch.by}, but we are already playing", type:NoAction

		// Print: Use type:Debug for temporary debug messages
		print "Possible moves for {currentPlayer}: {possibleMoves}", type:Debug

		// Print: Use type:Headline when a new turn, round or phase started. Keep the text short. Pass in the current player's color.
		print "# Turn of {currentPlayer}", type:Headline, color:currentPlayer.color
	
app
	Player	currentPlayer
	Item[]	items

	start
		items.add {}

	tick
		items.each.tick
		players.each.tick

# Write extensive print statements
Write extensive print statements that describe each action after it happened. Use the past tense. Use type:Action for actions performed by a player, use type:Reaction for reactions or consequences of an action. For example:

app
	tick
		drawStandardButton "Swap"
			print "Swap button clicked by {touch.by}", type:Action
			players[0].pos swapWith players[1].pos
			print "Positions swapped, player 0: {players[0].pos}, player 1: {players[1].pos}", type:Reaction

# Example: The board game "Go"
enum Phase: PlacePiece, GameOver

app
	// The screen size is always {1920, 1080}.
	// All LiveTime games are online multiplayer games. You must show the video feed of each player on the screen.
	// We display the videos at the left and right side of the screen, leaving a usable area of about {700,700} in the middle of the screen.
	const Vector2	totalBoardSize	= {700,700}
	
	// We create a object of type Grid (a 2D array) with a size of 9x9 to hold the cells of type Cell
	Cell[9, 9]	grid
	
	// To correctly center the board, we need to offset it by cellSize * (grid.size - {1,1}) / -2
	// Don't make the mistake of multiplying by cellCount / -2
	const Vector2	cellSize	= totalBoardSize / grid.size
	const Vector2	cellOffset	= cellSize * (grid.size - {1,1}) / -2

	Player	currentPlayer
	Phase	phase = PlacePiece
	
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
		print "# Turn of {currentPlayer}", type:Headline, color:currentPlayer.playerColor

	// Called when a player touches the screen
	onTouchDown: Touch touch
		// Important: If isOnlineMultiplayer it true, the touch must be by the current player
		if isOnlineMultiplayer and touch.by != currentPlayer
			print "Click by {touch.by} ignored because it's {currentPlayer}'s turn", type:NoAction
			return
			
		let cell = app.grid[touch.position.toGridPos]
			if not cell.player
				currentPlayer.placePiece cell
			else
				print "Can't place piece at {cell.gridPos} because it's occupied by {cell.player}", type:NoAction
		else
			print "Can't place piece because there's no valid cell at {touch.position}", type:NoAction
				
	// Called on every frame (30 times per second)
	tick
		// Call tick function for each cell in the grid
		grid.each.tick
		
		// Call tick function for each player
		players.each.tick
						
	finishGame
		Player winner = players.withMax.playerScore
		ParticleSystem(position:winner.videoPos)
		print "Game won with {winner.playerScore} points by {winner}", type:Reaction

struct IntVector2
	toScreenPos => app.cellOffset + this * app.cellSize

struct Vector2
	toGridPos => ((this - app.cellOffset) / app.cellSize).round
		
class Cell
	IntVector2	gridPos
	Player	player
	int	liberties
	bool	visited

	tick
		Vector2 screenPos = gridPos.toScreenPos
		
		if player
			// Draw a circle with its center at screenPos
			// The background is black in LiveTime, so we need to make sure we use colors that are different from black.
			drawCircle screenPos, size:60, color:player.playerColor

			// Draw text with its center at screenPos
			drawText "{liberties}", screenPos, size:30					
		else
			drawCircle screenPos, size:8
		
// The Player class automatically has the following member variables: playerIndex, playerColor, playerDarkColor and playerScore. Do not declare them again.
class Player
	Vector2	videoPos = IntVector2.horizontalDirections[playerIndex] * {690,265}
	int	capturedPiecesCount
		
	tick
		// You must draw the video feed of each player.
		float radius = 255
		Color color = app.currentPlayer == this ? playerColor : playerDarkColor
		drawCircle videoPos, size:radius*2, outlineColor:color, outlineWidth:12
		drawVideo this, videoPos, size:radius*2-75, shape:Circle
		
		// Draw captured pieces count
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		Vector2 scorePos = videoPos + math.getVectorForAngle(-45°)*radius
		drawCircle scorePos, color:Black, outlineColor:color, size:60
		drawText capturedPiecesCount, scorePos, size:31

	placePiece: Cell cell
		if cell.player then return
		cell.player = this
		print "Piece placed at {cell.gridPos} by {this}", type:Action
		captureSurroundedPieces cell.gridPos
		whenAnimationsFinished
			app.startTurn
				
	captureSurroundedPieces: IntVector2 originPos
		for IntVector2.primaryDirections as dir
			IntVector2 neighborPos = originPos + dir
			Cell neighborCell = app.grid[neighborPos]
				Player opponent = neighborCell.player			
				if neighborCell and opponent and opponent != this
					Cell[] surroundedCells = collectsurroundedCells neighborPos
						surroundedCells.each.player = null
						print "{surroundedCells.length} pieces captued by {this}: {surroundedCells.joinToString.gridPos.toString}", type:Reaction
						
						// Animate the captured pieces to the player's video feed
						animate duration:500 milliseconds
							// Called on every tick of the animation, passing in the progress ranging from 0 to 1
							for surroundedCells as cell
								let pos = cell.gridPos.toScreenPos interpolateTo videoPos, progress
								drawCircle pos, size:60, color:opponent.playerColor
						then
							// Called when the animation finished
							capturedPiecesCount += surroundedCells.length
							print "Finished animation", type:Reaction
	
	// We can specify the return type in front of the name of a function
	Cell[] collectsurroundedCells: IntVector2 originPos
		IntVector2[] queue = [ originPos ]
		Cell[] surroundedCells = [ app.grid[originPos] ]
		
		// For each player, set the visited variable to false
		app.grid.each.visited = false
		surroundedCells[0].visited = true
		
		while queue
			IntVector2 pos = queue.pop
			Cell cell = app.grid[pos]
			
			for IntVector2.primaryDirections as dir
				IntVector2 neighborPos = pos + dir
				Cell neighborCell = app.grid[neighborPos]
				if neighborCell and not neighborCell.visited
					if neighborCell.player == null
						return []
					if neighborCell.player != this
						surroundedCells.add neighborCell
						neighborCell.visited = true
						queue.add neighborPos
						
		return surroundedCells
