# Basics of the LiveTime programming language
enum PlayerRole: Knight, Archer	// Enums are global and can be accessed from anywhere
class Player	// Classes have capitalized names. Their members are public by default
	int        index	// Member variable of class Player. Integers are 0 by default
	float      score = 100.0	// Floating point numbers are 0.0 by default
	bool       isAlive = true	// Booleans are false by default
	Vector2    pos = {1.5, 2.5}	// Vectors are {0,0} by default. Its fields x and y are floats.
	IntVector  gridPos = {5,4}	// IntVectors are {0,0} by default. Its fields x and y are integers.
	string     name	// Strings are "" (the empty string) by default
	Player[]   friends	// Lists are [] (the empty list) by default
	PlayerRole role = Archer	// You can write "Archer" instead of "PlayerRole.Archer" if the type is known from context
	Player: int index	// Constructor of class Player. If you don't write a constructor, one is created automatically
		this.index = index	// Assign member variable
		pos = {index*8, 0}	// Call constructor of Vector2
// File: classes/app.l	// Create file "classes/app.l" to declare class app. Lowercase name makes it static. Access members with app.players, app.start, etc.
Player[] players	// List of players
start	// app.start is called once when the app starts
	let alice = Player(pos:{x,y}, name:"Alice")	// Call constructor of Player
	Player bob = {pos:{8,0}, name:"Bob"}	// You can use object literal syntax to call constructor if the type is known from context
	players.add alice	// Add to list
	players.remove alice	// Remove from list
	players.clear	// Remove all items from list
	if not (x < 0 or x >= 10) then print "between 0 and 10"	// Use "then" in single-line if statements, leave out "then" in multi-line statements
	if 0 <= x < 10 then print "between 0 and 10"	// Chained comparison
	for i = 0 to 5	// Iterate over range with inclusive start 0 and exclusive end 5
		print i	// Prints 0 1 2 3 4
	for players.length	// Start index is 0 if left out, iteration variable is . if left out
		let player = players[.]	// Get item by index
	for i to players.length step -1	// Reverse order
		print i	// Prints 4 3 2 1 0
		players.removeAt i 	// Remove item at index
	for p in players	// Iterate over list
		print "The score of {p.name} is {p.score}"	// String interpolation
	let max = x > y ? x : y	// Ternary operator
	int dot = filename.indexOf(".")	// Get index of character in string
	string name = filename.substring(0 to dot)	// Get substring
	Player p = players[index mod players.length]	// negative mod positive is positive (-1 mod 10 == 9)
	float fraction = 1 / 2	// Integer division create float
	floor(3.1), ceil(3.9), round(3.5)	// Use floor, ceil or round to convert float to integer
	abs(-5)	// Absolute value
	randomInteger(0 to 10), randomFloat(0 to 1)	// Random values
	Vector2 pos = {cos(x*2*pi), sin(y*2*pi)}	// Trigonometric functions: sin, cos, tan, atan
	players.sortBy.score	// Sort list by score
	Player winner = players.withMax.score	// Get player with maximum score
	Player alice = players.find.name == "Alice"	// Find item by condition
	Player[] topPlayers = (players.filter.score > 10).sortBy.score	// Filter a list then sort it
	Time.now	// Get current time in milliseconds since 1 January 1970
	Time.ticks	// Get number of frames since the start of the app
	players.each.tick	// Call tick for each player in list
	dynamic config = json.parse(jsonString)	// Parse JSON to dynamic object, convert back with json.stringify
	int value = (int)config.value	// Cast to int
	Cell[8,8] grid	// Grid of type Cell (2-dimensional array with a fixed size)
	grid[3,4] = {cellType:Emtpy}	// Create Cell at position {3,4}
	grid[player.gridPos] = grid[3,4]	// Access grid with IntVector2
	for gridPos, item in grid	// Iterate over grid, gridPos is IntVector2, item is Cell
		print "Cell at {gridPos} is {.cellType}"	// In for loops .cellType is short for item.cellType
	Player[string] playersByName	// Dictionary (hashtable) mapping string keys to Player values
	playersByName["Alice"] = alice	// Add to dictionary
	playersByName.remove "Alice"	// Remove from dictionary
	playersByName.clear	// Remove all items from dictionary
	for name, player in playersByName	// Iterate over dictionary
		print "{name} moved to {.gridPos}", type:Action	// Use print type:Action for actions performed by a player
		print "{name} won", type:Reaction	// Use print type:Reaction for reactions or consequences of an action
	print "# Turn of {p}", type:Headline, color:.playerColor	// Use print type:Headline when a new turn, round or phase started
move: Player p, Vector2 delta = {0,0}	// Define a function that takes a Player and an optional Vector2 as parameters
	p.pos += delta	// Available Vector2 operators: +, -, *, /, +=, -=, *=, /=, ==, !=, >, <, >=, <=
tick	// app.tick is called every frame (30 times per second by default)
	move player, delta:{1,0}	// You don't need parenthesis when calling a function that doesn't return anything
	if justPressed(Pointer, player:0)	// Check if player 0 just pressed the left mouse button this frame
		print "Player 0 clicked at {getPointer(player:0)}"	// Pointer position of player 0 (mouse, touch or pen)
	if justPressed(A, player:1) then print "Player 1 pressed A"	// Available inputs: Up, Down, Left, Right, A, B, X, Y, Start, Select, Pointer, RightMouseButton
	if justReleased(B, player:2) then print "Player 2 released B"	// Check if player 2 just released the B button on their gamepad
	if isPressed(Up, player:3) then pos += {0,-1}	// Check if player 3 is currently pressing the Up button on their gamepad
	drawImage Example, position:{0,0}, visibleBy:player[0]	// Draws image "media/Example.png", leave out visibleBy to draw for everyone
	drawVideo player[1], pos:{0,0}, size:435, shape:Circle	// Draw video feed of player 1, available shapes: Rectangle, Square, Circle
	drawRectangle pos, size, outlineColor:Red, outlineWidth:5	// Draw rectangle centered at pos
	drawText "Score: {score}", pos, size:12, color:#00a0a0	// Draw text centered at pos