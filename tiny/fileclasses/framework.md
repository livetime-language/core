	Time.ticks	// Get number of frames since the start of the app
move: Player p, Vector2 delta = {0,0}	// Define a function that takes a Player and an optional Vector2 as parameters
	p.pos += delta	// Available Vector2 operators: +, -, *, /, +=, -=, *=, /=, ==, !=, >, <, >=, <=
tick	// app.tick is called every frame (30 times per second by default)
	move player, delta:{1,0}	// You don't need parenthesis when calling a function that doesn't return anything
	setPixel {x,y}, color:LightGray	// Colors: Black, DarkGray, LightGray, White, Blue, Red, Green, Yellow, Earth, Sand, Pink, Violet, DarkBlue, DarkRed, DarkGreen, Orange
	drawText "Hello World", pos:{x,y}, color:DarkGray	// Draw text
	drawRectangle pos:{x,y}, size:{8,8}, color:Red, outlineColor:Green	// Draw rectangle, leave out color for no fill, leave out outlineColor for no outline
	drawCircle center:{x,y}, radius:8, color:Blue, outlineColor:Yellow	// Draw circle around center, radius can also be a Vector2 for an ellipse
	drawLine {0,0} to {8,8}, color:Orange	// Draw line
	drawSprite sprites.blueCircle, pos:{x, y}, transparentColor:Black	// Draw sprite with optional transparent color (Black if left out)
	drawSprite sprites.blueCircle, frame:0, flipX:true, flipY:true	// Draw sprite with optional mirroring and animation frame (0 if left out)
	drawSprite sprites.blueCircle, replaceColor:Blue with:DarkBlue	// Draw sprite with optional color replacement (none if left out)
	drawTilemap tilemaps.level, pos:{0,0}, sourcePos:{0,0}, size:{32,32}	// Draw tilemap with optional sourcePos (in tiles) and size (in tiles, full tilemap if left out)
	Sprite sprite = tilemaps.level.tiles[x + y * size.x]	// Get tile of a tilemap
	sprite.hasTag("movable")	// Check if a sprite has a tag
	clip pos:{x,y}, size:{64,64}	// All drawing functions will be clipped to this rectangle until stopClipping is called
	if justPressed(Pointer, player:0)	// Check if player 0 just pressed the left mouse button this frame
		print "Player 0 clicked at {getPointer(player:0)}"	// Pointer position of player 0 (mouse, touch or pen)
	if justPressed(A, player:1) then print "Player 1 pressed A"	// Available inputs: Up, Down, Left, Right, A, B, X, Y, Start, Select, Pointer, RightMouseButton
	if justReleased(B, player:2) then print "Player 2 released B"	// Check if player 2 just released the B button on their gamepad
	if isPressed(Down, player:3) then pos += {0,1}	// Check if player 3 is currently pressing the Down button on their gamepad
	playSound sounds.explosion, channel:2, startIndex:0, length:64	// Play sound with optional channel (0-3), startIndex (0-31) and length (0-31)
	stopSound channel:3	// Stop sound with optional channel (all if left out)
	playMusic music.intro, startPattern:0, fadeInDuration:1000	// Play music with optional startPattern (0-63) and fadeInDuration (in milliseconds)
	stopMusic fadeOutDuration:500	// Stop the music with optional fade out (in milliseconds)
	setVolume 0.5	// Set the master volume (0 to 1)
js void navigateTo: string url	// js keyword indicates that function body is in JavaScript. Return type is required.
	location.href = url;	// JavaScript code. Do not use nested functions.
// File: classes/sprites.l	// Contains available sprites. Add sprites as needed.
redSquare = Sprite(frames:3, [	// Sprites can have multiple animation frames next to each other	
	"rrrrrrrr                "	// The sprite "redSquare" has 3 frames, each 8x8 pixels
	"r      r rrrrrr         "	// Sprites can have a string with comma separated tags
	"r      r r    r   rrrr  "	// Each letter represets a color:
	"r      r r    r   r  r  "	//   Black
	"r      r r    r   rrrr  "	// d DarkGray
	"r      r r    r         "	// l LightGray
	"r      r rrrrrr         "	// w White
	"rrrrrrrr                "	// b Blue
])	// r Red
blueCircle = Sprite(tags:"blocking,hazard", [	// g Green
	"  bbbb  "	// y Yellow
	" b    b "	// e Earth
	"b      b"	// s Sand
	"b      b"	// p Pink
	"b      b"	// v Violet
	"b      b"	// B DarkBlue
	" b    b "	// R DarkRed
	"  bbbb  "	// G DarkGreen
])	// o Orange