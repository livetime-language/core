# Keep up to date information
Keep all information above, memory and code comments up to date. Use "memory/" to read and write important information about project. All memories must be in this folder.

# Fast, efficient, simple code
Write fast, efficient, elegant code. Keep code simple and easy to reason about.
Avoid small, trivial functions. Avoid too many small functions.

# LiveTime Programming Language
LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation (never spaces).

# Compile
Check your code with "livetime check", build with "livetime build".

# Basics of LiveTime
{prefix.md}

// The following is a complete example game: the board game "Go"
// File: classes/sprites.l
Sprite emptyCell = Sprite([
	"        "
	"        "
	"        "
	"   dd   "
	"   dd   "
	"        "
	"        "
	"        "		
])
Sprite blackPiece = Sprite([
	"        "
	"   ww   "
	"  w  w  "
	" w    w "
	" w    w "
	"  w  w  "
	"   ww   "
	"        "
])
Sprite whitePiece = Sprite([
	"        "
	"   ww   "
	"  wwww  "
	" wwwwww "
	" wwwwww "
	"  wwww  "
	"   ww   "
	"        "
])

// File: classes/app.l
enum Phase: PlacePiece, GameOver

Vector2 boardSize = {9, 9}
Vector2 boardOffset = ({224, 168} - boardSize*8) / 2 // Centers the board on the 224x168 screen

Cell[] cells
Player[] players
Player currentPlayer
Phase phase = PlacePiece

start
	for x to boardSize.x
		for y to boardSize.y
			cells[y*boardSize.x + x] = new Cell(gridPos:{x,y}, player:null)
	
	players = [{index:0}, {index:1}]
	currentPlayer = players[0]

nextTurn
	currentPlayer = players[(currentPlayer.index + 1) mod players.length]
			
tick
	cells.each.tick
	currentPlayer.tick
	
finishGame
	Player winner = players.withMax.score
	print "Player {winner.index} wins with {winner.score} points."

// File: classes/Cell.l		
Vector2 gridPos
Player player
int liberties
bool visited

tick
	Vector2 pos = app.boardOffset + gridPos*8
	if player
		drawSprite player.index ? sprites.blackPiece : sprites.whitePiece, pos
	else
		drawSprite sprites.emptyCell, pos
		
// File: classes/Player.l
int index
int score

tick
	if justPressed(LeftMouseButton, player:index)
		Vector2 gridPos = ((getPointer(player:index) - app.boardOffset) / 8).floor
		if {0.0, 0.0} <= gridPos < app.boardSize
			placePiece gridPos

placePiece: Vector2 gridPos
	print "Player {index} places a piece at {gridPos}"
	Cell cell = app.cells[gridPos.y * app.boardSize.x + gridPos.x]
	cell.player = this
	captureSurroundedPieces gridPos
	app.nextTurn

const Vector2[] directions = [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]

captureSurroundedPieces: Vector2 originPos
	for dir in directions
		Vector2 neighborPos = originPos + dir
		Cell neighborCell = app.cells[neighborPos.y * app.boardSize.x + neighborPos.x]
		
		if neighborCell and neighborCell.player and neighborCell.player != this
			Cell[] surroundesCells = collectSurroundesCells neighborPos, this
			if surroundesCells
				print "Player {index} surrounded {surroundesCells.length} cells"
				surroundesCells.each.player = null
	
Cell[] collectSurroundesCells: Vector2 originPos, Player attacker
	Vector2[] queue = [ originPos ]
	Cell[] surroundedCells = [ app.cells[originPos.y * app.boardSize.x + originPos.x] ]
	
	for cell in app.cells
		cell.visited = false
	
	while queue
		Vector2 pos = queue.pop
		Cell cell = app.cells[pos.y * app.boardSize.x + pos.x]
		surroundedCells.add cell
		cell.visited = true
		
		for dir in directions
			Vector2 neighborPos = pos + dir
			Cell neighborCell = app.cells[neighborPos.y * app.boardSize.x + neighborPos.x]
			if neighborCell and not neighborCell.visited
				if neighborCell.player == null
					return []
				if neighborCell.player != attacker
					queue.add neighborPos
					
	return surroundedCells