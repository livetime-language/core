// Full LiveTime API. IMPORTANT: Only use the following functions and features!
// Write the simplest, most efficient code possible. Compile with "npm run compile".
enum PlayerRole: Knight, Archer	// Enums and their values have capitalized names
class Player	// Use capitalized name to define a class. Its members are public by default
	int        index	// Integers are 0 by default
	float      score = 100.0	// Floating point numbers are 0.0 by default
	bool       isAlive = true	// Booleans are false by default
	Vector2    pos = {1.5, 2.5}	// Vectors are {0,0} by default. Its fields x and y are floats.
	string     name	// Strings are "" (the empty string) by default
	Player[]   friends	// Lists are [] (the empty list) by default
	PlayerRole role = Archer	// You can write "Archer" instead of "PlayerRole.Archer" if the type is known from context
	Player: int index	// Constructor with parameter. If you don't write a constructor, one is created automatically
		this.index = index	// Assign member variable
		pos = Vector2(index*8, 0)	// Calls the constructor of Vector2
		pos = {index*8, 0}	// Also calls the constructor of Vector2
app	// Use lowercase name to define a static class. Access its members with app.players, app.start, etc.
	Player[] players	// List of players
	start	// app.start is called once when app starts
		let a = Player(pos:{x,y}, name:"Bob")	// Calls constructor of Player
		Player b = {pos:{8,0}, name:"Alice"}	// You can use object literal syntax to call a constructor if the type is known from context
		players.add p	// Add to list
		players.remove p	// Remove from list
		players.clear	// Clear list
		if not (x < 0 or x >= 10) then print "between 0 and 10"	// Use "then" in single-line if statements, leave out "then" in multi-line statements
		if 0 <= x < 10 then print "between 0 and 10"	// Chained comparison
		randomInteger(0 to 10)	// Random integer between 0 and 10
		for 0 to 5 as i	// Iterate over range with inclusive start 0 and exclusive end 5
			print i	// Prints 0 1 2 3 4
		for players.length	// The lower bound defaults to 0, the iteration variable name defaults to i
			let player = players[i]	// Get item by index
		for players.length backwards as i	// Iterate backwards
			players.removeAt i 	// Remove item at index
		for players as p, i	// Iterate over list
			print "The score of {p.name} is {p.score}"	// String interpolation
		let x = 0, y = 0	// Numbers are floats by default. Use "int x" if you need an integer.
		let max = x > y ? x : y	// Ternary operator
		int level = floor(lineCount / 10)	// Dividing two integers results in a float. Use floor, ceil or round if you need an integer
		int period = filename.indexOf(".")	// Get index of character in string
		string name = filename.substring(0 to period)	// Get substring
		Player p = players[index mod players.length]	// Modulo operator
		randomFloat(0 to 1)	// Random float between 0 and 1
		abs(-5)	// The absolute value of a number
		Vector2 pos = {cos(x*2*pi), sin(y*2*pi)}	// Trigonometric functions: sin, cos, tan, atan
		players.sortBy.score	// Sort list by score
		Player winner = players.withMax(.score)	// Get player with maximum score
		Player alice = players.find(.name == "Alice")	// Find item by condition
		Player[] topPlayers = players.filter(.score > 10).sortBy(.score)	// Filter a list then sort it
		time.now	// Get current time in milliseconds since 1 January 1970
		time.ticks	// Get number of frames since the start of the app
	move: Player p, Vector2 delta = {0,0}	// Define a function that takes a Player and a Vector2 as parameters
		p.pos += delta	// Available Vector2 operators: +, -, *, /, +=, -=, *=, /=, ==, !=, >, <, >=, <=
	getDelta: Player p	// You don't need to specify the return type of a function
		return p.direction * p.speed	// Return a value
    tick	// app.tick is called every frame (30 times per second by default)
		move player, delta:getDelta(player)	// You don't need parenthesis when calling a function that doesn't return anything
		pixels[vector] = color	// Set pixel at position between {0,0} and {224, 168} to color between 0 and 15
		pixels[x,y] = color	// Pixels can also be accessed with a vector or two separate coordinates
		int color = pixels[player.pos]	// Available colors: 0:Black, 1:DarkBlue, 2:DarkPurple, 3:DarkGreen, 4:Brown, 5:DarkGray, 6:LightGray, 7:White, 8:Red, 9:Orange, 10:Yellow, 11:Green, 12:Blue, 13:Indigo, 14:Pink, 15:Peach
		drawSprite sprites.blueCircle, pos:{x:0, y:0}	// Draw sprite
		drawText "Hello World", pos:{x,y}, color:1	// Draw text
		drawRect pos:{x,y}, size:{8,8}, fillColor:2, outlineColor:3	// Draw rectangle, omit fillColor for no fill, omit outlineColor for no outline
		drawCircle pos:{x,y}, radius:8, fillColor:2, outlineColor:3	// Draw circle, radius can be a float or a vector for an ellipse
		clip pos:{x,y}, size:{64,64}	// All drawing functions will be clipped to this rectangle until stopClipping is called
		replaceColor a with:b	// All drawing functions will replace color a with color b until stopReplacingColors is called
		if justPressed(LeftMouseButton, player:0)	// Check if player 0 just pressed the left mouse button this frame
			print "Player 0 clicked at {getPointer(player:0)}"	// Pointer position of player 0 (mouse, touch or pen)
		if justPressed(A, player:1) then print "Player 1 pressed A"	// Available buttons: Up, Down, Left, Right, A, B, X, Y, Start, Select, LeftMouseButton, RightMouseButton
		if justReleased(B, player:2) then print "Player 2 released B"	// Check if player 2 just released the B button on their gamepad
		if isPressed(Up, player:3) then pos += {0,-1}	// Check if player 3 is currently pressing the Up button on their gamepad
		if isPressed(Down, player:3) then pos += {0,1}	// Check if player 3 is currently pressing the Down button on their gamepad
sprites	// src/sprites.l contains all available sprites and colors. Add additional sprites as needed.
	blueCircle = Sprite [	// SPACE:Black, 1:DarkBlue, 2:DarkPurple, 3:DarkGreen, 4:Brown, 5:DarkGray, 6:LightGray, 7:White, 8:Red, 9:Orange, a:Yellow, b:Green, c:Blue, d:Indigo, e:Pink, f:Peach
		"  cccc  "
		" c    c "
		"c      c"
		"c      c"
		"c      c"
		"c      c"
		" c    c "
		"  cccc  "
	]
// This is the full APT. Do not use any other functions!
// The following is a complete example game: the board game "Go"
sprites
	Sprite emptyCell = Sprite([
		"        "
		"        "
		"        "
		"   66   "
		"   66   "
		"        "
		"        "
		"        "		
	])
	Sprite blackPiece = Sprite([
		"        "
		"   77   "
		"  7  7  "
		" 7    7 "
		" 7    7 "
		"  7  7  "
		"   77   "
		"        "
	])
	Sprite whitePiece = Sprite([
		"        "
		"   77   "
		"  7777  "
		" 777777 "
		" 777777 "
		"  7777  "
		"   77   "
		"        "
	])

enum Phase: PlacePiece, GameOver
app
	Vector2 boardSize = {9, 9}
	Vector2 boardOffset = ({224, 168} - boardSize*8) / 2 // Centers the board on the 224x168 screen
	
	Cell[] cells
	Player[] players
	Player currentPlayer
	Phase phase = PlacePiece
	
	start
		for boardSize.x as x
			for boardSize.y as y
				cells[y*boardSize.x + x] = new Cell(pos:{x,y}, player:null)
		
		players = [{index:0}, {index:1}]
		currentPlayer = players[0]
				
	tick
		for boardSize.y as y
			for boardSize.x as x
				Cell cell = cells[y*boardSize.x + x]
				Vector2 pos = boardOffset + {x,y}*8
				if cell.player
					drawSprite cell.player.index ? sprites.blackPiece : sprites.whitePiece, pos
				else
					drawSprite sprites.emptyCell, pos

		if justPressed(LeftMouseButton, player:currentPlayer.index)
			Vector2 gridPos = ((getPointer(player:currentPlayer.index) - boardOffset) / 8).floor
			placePiece gridPos, player:currentPlayer
		
	placePiece: Vector2 gridPos, Player player
		print "Player {player.index} places a piece at {gridPos}"
		Cell cell = cells[gridPos.y * boardSize.x + gridPos.x]
		cell.player = player
		captureSurroundedPieces gridPos, player
		
		// Set current player to the next player
		currentPlayer = players[(currentPlayer.index + 1) mod players.length]

	const Vector2[] directions = [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]

	captureSurroundedPieces: Vector2 originPos, Player attacker
		for directions as dir
			Vector2 neighborPos = originPos + dir
			Cell neighborCell = cells[neighborPos.y * boardSize.x + neighborPos.x]
			
			if neighborCell and neighborCell.player and neighborCell.player != attacker
				Cell[] surroundesCells = collectSurroundesCells neighborPos, attacker
				if surroundesCells
					print "Player {attacker.index} surrounded {surroundesCells.length} cells"
					surroundesCells.each.player = null
		
	Cell[] collectSurroundesCells: Vector2 originPos, Player attacker
		Vector2[] queue = [ originPos ]
		Cell[] surroundedCells = [ cells[originPos.y * boardSize.x + originPos.x] ]
		
		for cells as cell
			cell.visited = false
		
		while queue
			Vector2 pos = queue.pop
			Cell cell = cells[pos.y * boardSize.x + pos.x]
			surroundedCells.add cell
			cell.visited = true
			
			for directions as dir
				Vector2 neighborPos = pos + dir
				Cell neighborCell = cells[neighborPos.y * boardSize.x + neighborPos.x]
				if neighborCell and not neighborCell.visited
					if neighborCell.player == null
						return []
					if neighborCell.player != attacker
						queue.add neighborPos
						
		return surroundedCells
		
	finishGame
		Player winner = players.withMax.score
		print "Player {winner.index} wins with {winner.score} points."
		
class Cell
	Vector2 pos
	Player player
	int liberties
	bool visited
		
class Player
	int index
	int score
