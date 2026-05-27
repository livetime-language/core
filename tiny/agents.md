# Use the LiveTime programming language
LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation (never spaces). Place all the code in the file "src/app.l".

# Simple code
Always write the shortest, simplest possible code.
Write the fastest, most efficient code possible.

# Compile and test
Run "npm run compile" to compile.

# LiveTime Cheatsheet
# Important: Only use the following functions and features
# Implementation: lib/core/tiny/
enum PlayerRole: Knight, Archer	// Enums and their values have capitalized names
Player	// Use capitalized name to define a class. Its members are public by default
	int index	// Integers are 0 by default
	float score = 100.0	// Floats are 0.0 by default
	bool isAlive = true	// Booleans are false by default
	Vector2 pos = {1,2}	// Vectors are {0,0} by default
	string name	// Strings are "" (the empty string) by default
	Player[] friends	// Lists are [] (the empty list) by default
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
		for 0 to 5 as i	// Iterate over integer range with inclusive lower bound and exclusive upper bound
			print i	// Prints 0 1 2 3 4
		for players.length	// The lower bound defaults to 0, the iteration variable name defaults to i
			let player = players[i]	// Get item by index
		for players.length step -1 as i	// Iterate backwards
			players.removeAt i 	// Remove item at index
		for players as p, i	// Iterate over list
			print "The score of {p.name} is {p.score}"	// String interpolation
		int period = filename.indexOf(".")	// Get index of character in string
		string name = filename.substring(0 to period)	// Get substring
		Player p = players[index mod players.length]	// Modulo operator
		int max = a > b ? a : b	// Ternary operator
		randomFloat(0 to 1)	// Random float between 0 and 1
		let roundedDown = floor(3.7), roundedUp = ceil(3.7)	// floor, ceil and round
		abs(-5)	// The absolute value of a number
		Vector p = {cos(a*2*pi), sin(a*2*pi)}	// Trigonometric functions: sin, cos, tan, asin, acos, atan
		players.sortBy.score	// Sort list by score
		Player winner = players.withMax.score	// Get player with maximum score
		Player alice = players.find.name == "Alice"	// Find item by condition
		Player[] topPlayers = (players.filter.score > 10).sortBy.score	// Filter a list then sort it
		time.now	// Get current time in milliseconds since 1 January 1970
		time.ticks	// Get number of frames since the start of the app
		setSprite 0, [	// Set the pixels of a 8x8 sprite. Each character represents a pixel on the pico8 palette: SPACE:Black, 1:DarkBlue, 2:DarkPurple, 3:DarkGreen, 4:Brown, 5:DarkGray, 6:LightGray, 7:White, 8:Red, 9:Orange, a:Yellow, b:Green, c:Blue, d:Indigo, e:Pink, f:Peach
			"        "
			"        "
			"   a    "
			"  abb   "
			" abbb3  "
			"  bb3   "
			"   3    "
			"        "
			"        "
			"        "
			"        "
		]
    tick	// app.tick is called every frame (30 times per second by default)
		pixels[vector] = color	// Set pixel at position between {0,0} and {224, 168} to color between 0 and 15
		pixels[x,y] = color	// Pixels can also be accessed with a vector or two separate coordinates
		int color = pixels[player.pos]	// Available colors: 0:Black, 1:DarkBlue, 2:DarkPurple, 3:DarkGreen, 4:Brown, 5:DarkGray, 6:LightGray, 7:White, 8:Red, 9:Orange, 10:Yellow, 11:Green, 12:Blue, 13:Indigo, 14:Pink, 15:Peach
		drawSprite 0, pos:{x,y}, numberOfSprites:{2,1}	// Draw sprite, numberOfSprites defaults to {1,1}
		drawText "Hello World", pos:{x,y}, color:1	// Draw text
		drawRect pos:{x,y}, size:{8,8}, fillColor:2, outlineColor:3	// Draw rectangle, omit fillColor for no fill, omit outlineColor for no outline
		drawCircle pos:{x,y}, radius:8, fillColor:2, outlineColor:3	// Draw circle, radius can be a float or a vector for an ellipse
		clip pos:{x,y}, size:{64,64}	// All drawing functions will be clipped to this rectangle until stopClipping is called
		replaceColor a with b	// All drawing functions will replace color a with color b until stopReplacingColors is called
		if justPressed LeftMouseButton player:0	// Check if player 0 just pressed the left mouse button this frame
			print "Player 0 clicked at {getPointer player:0}"	// Pointer position of player 0 (mouse, touch or pen)
		if justPressed A player:1 then print "Player 1 pressed A"	// Available buttons: Up, Down, Left, Right, A, B, X, Y, Start, Select, LeftMouseButton, RightMouseButton
		if justReleased B player:2 then print "Player 2 released B"	// Check if player 2 just released the B button on their gamepad
		if isPressed Up player:3 then pos += {0,-1}	// Check if player 3 is currently pressing the Up button on their gamepad
		if isPressed Up player:3 then pos += {0,-1}	// Check if player 3 is currently pressing the Up button on their gamepad