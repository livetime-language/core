# Complete example: board game "Go"
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
		for gridPos in grid.size
			grid[gridPos] = Cell(gridPos)
		
		// In LiveTime, the global variable players always contains a list of players
		// We pick a random player as the start player
		currentPlayer = input.players.random
		startTurn

	startTurn
		// Set current player to the next player
		currentPlayer = input.players next currentPlayer

		// Always print the start of the turn in the player's color!
		print "# Turn of {currentPlayer}", type:Headline, color:currentPlayer.playerColor
				
	// Called on every frame (30 times per second)
	tick
		// Call tick function for each cell in the grid
		grid.each.tick
		
		// Call tick function for each player
		input.players.each.tick
						
	finishGame
		Player winner = input.players.withMax.playerScore
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
		if app.currentPlayer == this and justPressed Pointer player:playerIndex
			let cell = app.grid[getPointer(playerIndex).toGridPos]
				if not cell.player
					placePiece cell
				else
					print "Can't place piece at {cell.gridPos} because it's occupied by {cell.player}", type:NoAction
			else
				print "{this} clicked invalid position", type:NoAction
	
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
		for dir in IntVector2.primaryDirections
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
							for cell in surroundedCells
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
			
			for dir in IntVector2.primaryDirections
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
