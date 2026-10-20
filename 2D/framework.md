		Time.ticks	// Get number of frames since the start of the app
		Cell[8,8] grid	// Grid of type Cell (2-dimensional array with a fixed size)
		grid[3,4] = {cellType:Emtpy}	// Create Cell at position {3,4}
		grid[player.gridPos] = grid[3,4]	// Access grid with IntVector2
		for gridPos, item in grid	// Iterate over grid, gridPos is IntVector2, item is Cell
			print "Cell at {gridPos} is {.cellType}"	// In for loops .cellType is short for item.cellType
		print "# Turn of {p}", type:Headline, color:.playerColor	// Use print type:Headline when a new turn, round or phase started
	move: Player p, Vector2 delta = {0,0}	// Define a function that takes a Player and an optional Vector2 as parameters
		p.pos += delta	// Available Vector2 operators: +, -, *, /, +=, -=, *=, /=, ==, !=, >, <, >=, <=
	tick	// app.tick is called every frame (30 times per second by default)
		move player, delta:{1,0}	// Always use labels unless the argument's purpose is obvious
		if justPressed(Pointer, player:0)	// Check if player 0 just pressed the left mouse button this frame
			print "Player 0 clicked at {getPointer(player:0)}"	// Pointer position of player 0 (mouse, touch or pen)
		if justPressed(A, player:1) then print "Player 1 pressed A"	// Available inputs: Up, Down, Left, Right, A, B, X, Y, Start, Select, Pointer, RightMouseButton
		if justReleased(B, player:2) then print "Player 2 released B"	// Check if player 2 just released the B button on their gamepad
		if isPressed(Up, player:3) then pos += {0,-1}	// Check if player 3 is currently pressing the Up button on their gamepad
		drawImage Example, pos:{0,0}, visibleBy:player[0]	// Draws image "media/Example.png", leave out visibleBy to draw for everyone
		drawVideo player[1], pos:{0,0}, size:435, shape:Circle	// Draw video feed of player 1, available shapes: Rectangle, Square, Circle
		drawRectangle pos, size, outlineColor:Red, outlineWidth:5	// Draw rectangle centered at pos
		drawText "Score: {score}", pos, size:12, color:#00a0a0	// Draw text centered at pos
