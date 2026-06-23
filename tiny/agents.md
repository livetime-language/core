// Full LiveTime API. IMPORTANT: Only use the following functions and features!
// Write simple, short, efficient code. Create beautiful sprites in "classes/sprites.l". Compile with "livetime compile".
// File: classes/Player.l	// Create file "classes/Player.l" to declare class Player. Members are public by default
enum PlayerRole: Knight, Archer	// Enums are global and can be accessed from anywhere
int        index	// Member variable of class Player. Integers are 0 by default
float      score = 100.0	// Floating point numbers are 0.0 by default
bool       isAlive = true	// Booleans are false by default
Vector2    pos = {1.5, 2.5}	// Vectors are {0,0} by default. Its fields x and y are floats.
string     name	// Strings are "" (the empty string) by default
Player[]   friends	// Lists are [] (the empty list) by default
PlayerRole role = Archer	// You can write "Archer" instead of "PlayerRole.Archer" if the type is known from context
Player: int index	// Constructor of class Player. If you don't write a constructor, one is created automatically
	this.index = index	// Assign member variable
	pos = {index*8, 0}	// Call constructor of Vector2
// File: classes/app.l	// Create file "classes/app.l" to declare static class app. Lowercase name makes it static. Access its members with app.players, app.start, etc.
Player[] players	// List of players
start	// app.start is called once when the app starts
	let a = Player(pos:{x,y}, name:"Alice")	// Call constructor of Player
	Player b = {pos:{8,0}, name:"Bob"}	// You can use object literal syntax to call constructor if the type is known from context
	players.add a	// Add to list
	players.remove a	// Remove from list
	players.clear	// Remove all items from list
	if not (x < 0 or x >= 10) then print "between 0 and 10"	// Use "then" in single-line if statements, leave out "then" in multi-line statements
	if 0 <= x < 10 then print "between 0 and 10"	// Chained comparison
	for 0 to 5 as i	// Iterate over range with inclusive start 0 and exclusive end 5
		print i	// Prints 0 1 2 3 4
	for players.length	// Start index is 0 if left out, iteration variable is . if left out
		let player = players[.]	// Get item by index
	for players.length backwards as i	// Iterate backwards
		print i	// Prints 4 3 2 1 0
		players.removeAt i 	// Remove item at index
	for players as p	// Iterate over list
		print "The score of {p.name} is {p.score}"	// String interpolation
	let max = x > y ? x : y	// Ternary operator
	int dot = filename.indexOf(".")	// Get index of character in string
	string name = filename.substring(0 to dot)	// Get substring
	Player p = players[index mod players.length]	// Modulo operator
	randomInteger(0 to 10), randomFloat(0 to 1)	// Random values
	abs(-5)	// Absolute value
	floor(3.1), ceil(3.9), round(3.5)	// Use floor, ceil or round to convert floats to integers
	Vector2 pos = {cos(x*2*pi), sin(y*2*pi)}	// Trigonometric functions: sin, cos, tan, atan
	players.sortBy.score	// Sort list by score
	Player winner = players.withMax(.score)	// Get player with maximum score
	Player alice = players.find(.name == "Alice")	// Find item by condition
	Player[] topPlayers = players.filter(.score > 10).sortBy(.score)	// Filter a list then sort it
	Time.now	// Get current time in milliseconds since 1 January 1970
	Time.ticks	// Get number of frames since the start of the app
move: Player p, Vector2 delta = {0,0}	// Define a function that takes a Player and an optional Vector2 as parameters
	p.pos += delta	// Available Vector2 operators: +, -, *, /, +=, -=, *=, /=, ==, !=, >, <, >=, <=
tick	// app.tick is called every frame (30 times per second by default)
	move player, delta:{1,0}	// You don't need parenthesis when calling a function that doesn't return anything
	setPixel {x,y}, color:LightGray	// Colors: Black, DarkGrey, LightGrey, White, Blue, Red, Green, Yellow, Earth, Sand, Pink, Violet, DarkBlue, DarkRed, DarkGreen, Orange
	drawSprite sprites.blueCircle, pos:{x, y}	// Draw sprite
	drawText "Hello World", pos:{x,y}, color:DarkGray	// Draw text
	drawRect pos:{x,y}, size:{8,8}, fillColor:Red, outlineColor:Green	// Draw rectangle, leave out fillColor for no fill, leave out outlineColor for no outline
	drawCircle pos:{x,y}, radius:8, fillColor:Blue, outlineColor:Yellow	// Draw circle, radius can also be a Vector2 for an ellipse
	clip pos:{x,y}, size:{64,64}	// All drawing functions will be clipped to this rectangle until stopClipping is called
	replaceColor Black with:White	// All drawing functions will replace color a with color b until stopReplacingColors is called
	if justPressed(LeftMouseButton, player:0)	// Check if player 0 just pressed the left mouse button this frame
		print "Player 0 clicked at {getPointer(player:0)}"	// Pointer position of player 0 (mouse, touch or pen)
	if justPressed(A, player:1) then print "Player 1 pressed A"	// Available buttons: Up, Down, Left, Right, A, B, X, Y, Start, Select, LeftMouseButton, RightMouseButton
	if justReleased(B, player:2) then print "Player 2 released B"	// Check if player 2 just released the B button on their gamepad
	if isPressed(Up, player:3) then pos += {0,-1}	// Check if player 3 is currently pressing the Up button on their gamepad
	if isPressed(Down, player:3) then pos += {0,1}	// Check if player 3 is currently pressing the Down button on their gamepad
js void navigateTo: string url	// js keyword indicates that function body is in JavaScript. Return type is required.
	location.href = url;	// JavaScript code
// File: classes/sprites.l	// Contains available sprites. Add sprites as needed.
blueCircle = Sprite [	// Each letter represets a color:
	"  bbbb  "	//   Black
	" b    b "	// d DarkGrey
	"b      b"	// l LightGrey
	"b      b"	// w White
	"b      b"	// b Blue
	"b      b"	// r Red
	" b    b "	// g Green
	"  bbbb  "	// y Yellow
]	// e Earth
redSquare = Sprite [	// s Sand
	"rrrrrrrr"	// p Pink
	"r      r"	// v Violet
	"r      r"	// B DarkBlue
	"r      r"	// R DarkRed
	"r      r"	// G DarkGreen
	"r      r"	// o Orange
	"r      r"
	"rrrrrrrr"
]
// This is the full APT. Do not use any other functions!

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
	for boardSize.x as x
		for boardSize.y as y
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
	for directions as dir
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
	
	for app.cells as cell
		cell.visited = false
	
	while queue
		Vector2 pos = queue.pop
		Cell cell = app.cells[pos.y * app.boardSize.x + pos.x]
		surroundedCells.add cell
		cell.visited = true
		
		for directions as dir
			Vector2 neighborPos = pos + dir
			Cell neighborCell = app.cells[neighborPos.y * app.boardSize.x + neighborPos.x]
			if neighborCell and not neighborCell.visited
				if neighborCell.player == null
					return []
				if neighborCell.player != attacker
					queue.add neighborPos
					
	return surroundedCells
