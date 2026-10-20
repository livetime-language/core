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


# Show the player's video
LiveTime games are online multiplayer games. You must draw the video feed of each player. For example:

## File: classes/Player.l
tick
	drawVideo this, pos, size:435, shape:Circle

# Screen dimensions
In LiveTime, the total screen size is always {1920, 1080}.
Center of the screen is at {0,0}, top-left corner is {-960,-540}, bottom-right corner is {960,540}.
The background is black by default. 

# Print debug info
Always print all the information you will need to find and fix bugs in your code (client and server)!
Use type:Action for actions by the user.
Use type:Reaction for consequences of an action.
Use type:Error for errors.
Example:
tick
	drawStandardButton "Swap"
		print "Swap button clicked by {touch.by}", type:Action
		players[0].pos swapWith players[1].pos
		print "Positions swapped, player 0: {players[0].pos}, player 1: {players[1].pos}", type:Reaction

# Images, Sounds and Fonts
Read "src/media.l" for all images, sounds and fonts available in the project. Place new images in the "media/" folder. For instance, if you place "Example.png" in this folder, you can use "Example" in drawImage:

tick
	drawImage Example, pos:{0,0} // draws the image "media/Example.png"

# Unit Tests
Write unit tests that cover the complete specification and all edges cases.
Put tests in static test class "tests" in "tests" folder. Mark test functions with "test" keyword. Use any character in their name.
Test classes have access to all members of all classes (including private).
Use 'livetime test' to run tests.
Use 'livetime test --output-passing-tests --filter="Menu:"' to check the output of specific tests.

static test class tests
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

		// Wait for 15 ticks. At 30 ticks per second, this corresponds to 500 milliseconds.
		wait 15 ticks

		// Wait for all animation to finish
		waitForAnimationsToFinish
		
		// Use printWhatIsOnScreen to check if the what is shown on screen is correct
		printWhatIsOnScreen

		// Assert
		expect app.grid[1,0].player == players[1]

# JavaScript interop
js keyword indicates that function body is in JavaScript. Return type is required. Use only when absolutely necessary. Do not use nested functions.

js void navigateTo: string url
	location.href = url;

# Library Source Code
"lib/core/" contains the LiveTime standard library as a git submodule. You can improve code and fix bugs, but be careful with project specific changes that might break other projects.

lib/core/js/base.l	int, float, string, List, Grid, Dictionary, ...
lib/core/js/time.l	Date, TimeString, ...
lib/core/2D/system.l	system.start, system.runHeadlessTests, ...
lib/core/2D/graphics.l	drawImage, drawText, drawRectangle, drawCircle, ...
lib/core/2D/geometry.l	Vector2, IntVector2, Matrix, ...
lib/core/2D/animation.l	animate, delay, whenAnimationsFinished, ...
lib/core/play/sound.l	playSound, setVolume, ...
lib/core/play/tests.l	click, drag, moveLeftStickTo, wait, waitForAnimationsToFinish, expect, ...

