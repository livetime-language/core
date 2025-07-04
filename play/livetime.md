---
description: LiveTime Programming Language Examples and Standard Library
globs: *.l
alwaysApply: true
---
# We use the LiveTime programming language.
LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation, never spaces. Place all the code in the file "src/app.l".

# Angles
All angle values in LiveTime are in turns, where .5 is half a rotation and 1 is a full rotation. For example, math.sin(.25) returns 1.

# Avoid unwanted overlaps
Before you start adding anything on the screen, review what's currently on screen and make sure nothing you draw overlaps with something it shouldn't overlap with.

{currentlyOnScreen}

# Example game implementing the board game "Go" in the LiveTime programming language
´´´
enum Phase: PlacePiece, GameOver

app
	// In LiveTime, the total screen size is always {1920, 1080}
	// The background is black by default
	// We need to display the player video at the left and right side of the screen
	// That leave a usable area of {700,700} in the middle of the screen
	const Vector2 totalBoardSize = {700,700}
	const int cellCount = 9
	
	// We use a two dimensional grid of Cell for the cells of the game board
	// We can later access the individual cells with cell[x,y]
	Grid<Cell> cells = {size:{cellCount, cellCount}}
	
	Player currentPlayer
	Phase phase = PlacePiece
	
	// This defines the function "start" of the class "app". All functions need to part of a class.
	// There are no top-level functions in LiveTime.
	// The "start" function is called when the game starts
	start
		graphics.drawingOrder = ItemsDrawnFirstWillBeInTheBack

		// We always need to display the standard menu
		Menu()
		
		// Create empty grid cells
		for cellCount as x
			for cellCount as y
				cells[x,y] = Cell(pos:{x,y}, player:null)
		
		// In LiveTime, the global variable "players" always contains a list of players
		// We pick a random player as the start player
		currentPlayer = players.random
				
	// The "tick" function is called on every frame (30 times per second)
	tick
		// The center of the screen has the coordinates {0,0}
		// The x-coordinate ranges from -960 to 960
		// The y-coordinate ranges from -540 to 540
		// So the top-left corner is {-960,-540}, the bottom-right corner is {960,540}
		// To correctly center the board, we need to offset it by cellSize * (cellCount - 1) / -2
		// Don't make the mistake of multiplying by cellCount / -2 instead of (cellCount - 1) / -2
		Vector2 cellSize = totalBoardSize / cellCount
		Vector2 cellOffset = cellSize * (cellCount - 1) / -2
		for cellCount as x
			for cellCount as y
				IntVector2 gridPos = {x,y}
				Vector2 pixelPos = cellOffset + gridPos * cellSize
				Cell cell = cells[gridPos]
				
				if cell.player
					// Draw a circle with its center at pixelPos
					// The background is black in LiveTime, so we need to make sure we use colors that are different from black.
					drawCircle pixelPos, size:60, color:cell.player.color

					// Draw text with its center at pixelPos
					drawText "{cell.liberties}", pixelPos, size:30					
				else
					drawCircle pixelPos, size:8
					
					// When the current player clicks on an empty cell, place a piece
					// We use "by:currentPlayer" to only consider touches by the current player
					onTouchDown position:pixelPos by:currentPlayer size:cellSize
						placePiece gridPos, cell, player:currentPlayer
		
		// Call the tick function for each player
		players.each.tick
		
	placePiece: IntVector2 gridPos, Cell cell, Player player
		print "Player {player} places a piece at {gridPos}"
		cell.player = player
		captureSurroundedPieces gridPos, player
		
		// Set current player to the next player
		currentPlayer = players next currentPlayer
		
	captureSurroundedPieces: IntVector2 originPos, Player attacker
		for IntVector2.primaryDirections as dir
			IntVector2 neighborPos = originPos + dir
			Cell neighborCell = cells[neighborPos]
			
			if neighborCell and neighborCell.player and neighborCell.player != attacker
				Cell[] surroundesCells = collectSurroundesCells neighborPos, attacker
				if surroundesCells
					print "Player {attacker} surrounded {surroundesCells.length} cells: {surroundesCells.joinToString.pos.toString}"
					surroundesCells.each.player = null
		
	// We write the return type in front of the function.
	// The function collectSurroundesCells takes an integer vector and a player and returns a list of cells
	Cell[] collectSurroundesCells: IntVector2 originPos, Player attacker
		IntVector2[] queue = [ originPos ]
		Cell[] surroundedCells = [ cells[originPos] ]
		
		// For each player, set the visited variable to false
		cells.each.visited = false
		
		while queue
			IntVector2 pos = queue.pop
			Cell cell = cells[pos]
			surroundedCells.add cell
			cell.visited = true
			
			for IntVector2.primaryDirections as dir
				IntVector2 neighborPos = pos + dir
				Cell neighborCell = cells[neighborPos]
				if neighborCell and not neighborCell.visited
					if neighborCell.player == null
						return []
					if neighborCell.player != attacker
						queue.add neighborPos
						
		return surroundedCells
		
	finishGame
		Player winner = players.withMax.score
		print "Player {winner} wins with {winner.score} points."
		ParticleSystem(position:winner.pos)
		
class Cell
	IntVector2 pos
	Player player
	int liberties
	bool visited
		
class Player
	// In LiveTime, each player always has an "index", a "color" and a "score" by default. We don't need to declare them.

	IntVector2 dir = IntVector2.horizontalDirections[index]
	Vector2 pos = dir * {690,265}
		
	tick
		IntVector2 a = {0,0}

		// In LiveTime, we always show a video feed for each player. Each LiveTime game need to contain this code.
		float radius = 255
		drawCircle pos, size:radius*2, outlineColor:color, outlineWidth:12
		drawVideo me, pos, size:radius*2-75, shape:Circle
		
		// Draw the score
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		Vector2 scorePos = pos + math.getVectorForAngle(-45°)*radius
		drawCircle scorePos, color:Black, outlineColor:color, size:60
		drawText score, scorePos, size:31

´´´



# Another example game in the LiveTime programming language
´´´
app
	int round
	Player currentPlayer
	Phase phase
	
	init
		graphics.drawingOrder = ItemsDrawnFirstWillBeInTheBack
		
	// List of words
	const string[] words = ["Apple", "Banana", "Orange"]
	Box[] boxes
	Item[] items
		
	startGame
		print "Starting game"
		for IntVector2.diagonalDirections as dir
			boxes.add {rect:{position:{220,280} * dir, size:{420,440}}}
		nextRound

		// When assigning an enum value to a variable, the enum name must be omitted
		// Write "phase = DrawItems" instead of "phase = Phase.DrawItems"
		phase = DragItems
		
	nextRound
		round++
		print "Starting round {round}"
		boxes.each.itemInBox = null
		words.shuffle
		items.clear
		
		Box[] top3OpenBoxes = boxes.where.isOpen | orderBy.rect.position.y | take 3
		
		string[] namesOfAlivePlayers = players.where.alive | orderBy.score | select.name

		// Create item for each word, center them at {0,10} with {400,0} pixels between them
		forPositions words, center:{0,10}, delta:{400,0}
			items.add {position:pos, word:.}
			
		// Make the next player the current player
		currentPlayer = players next currentPlayer
			
	tick
		items.each.tick
		boxes.each.tick
		players.each.tick
		
		switch phase
			DragItems
				// If all items are dropped into boxes, show "Next Round button"
				if items.all.droppedInBox != null
					drawButton "Next Round", image:Button, position:{0,0}, visibleFor:currentPlayer
						print "Player {touch.by} clicked 'Next Round'."
						phase = Reveal
						nextRound
			Reveal
				// Draw yellow text centered at {0,0} that's visible for everybody
				drawText "Reveal", position:{0,0}, size:32, Color("#ffff00"), visibleFor:everybody
				
			GameOver
				tickGameOver
				
				// Draw green text centered at {0,0} that's visible only for the first player
				drawText "Game Over", position:{0,0}, size:32, Color("#00ff00"), visibleFor:players[0]
				
	tickGameOver
		phase = GameOver
		
		Player offencePlayer = players.find.role == Offence
			print "Found offence player: {offencePlayer}"
		else
			print "No offence player"
		
		Player defencePlayer = players.find.role == Defence
			print "Found defence player: {defencePlayer}"
		else
			print "No defence player"
		
		// Order players by score
		players.orderBy.score order:Descending

// Always put classes, structs and enums outside of classes. You can't put them inside a class like "app".
enum Role: Offence, Defence
enum Phase: DragItems, Reveal, GameOver

class Player
	bool alive
	Role role
	
	visible IntVector2 dir = IntVector2.horizontalDirections[index]
	visible Vector2 videoPos = dir * {700,270}
	
	tick
		// In LiveTime, we always show a video feed for each player. Each LiveTime game need to contain this code.
		float radius = 255
		drawCircle videoPos, size:radius*2, outlineColor:color, outlineWidth:12
		drawVideo me, videoPos, size:radius*2-75, shape:Circle
		
		// Draw the score
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		Vector2 scorePos = videoPos + math.getVectorForAngle(-45°)*radius
		drawCircle scorePos, color:Black, outlineColor:color, size:60
		drawText score, scorePos, size:31

		
		// Draw yellow player name that's visible the current player instance
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		drawText name, size:32, Color("#ffff00"), visibleFor:me
	
class Item
	const Vector2 size = {300,60}
	bool moveable = true
	Vector2 position, originalPosition
	Touch moveTouch
	Vector2 touchOffset
	Box droppedInBox
	string word
	
	tick
		switch app.phase
			DragItems
				// The current player can drag item around with the mouse
				// Use "by:app.currentPlayer" to ensure only the current player can drag items
				onTouchDown position, size, by:app.currentPlayer
					// Start dragging
					print "Player {touch.by} started dragging {word} at {touch.position}"
					Player playerWhoClicked = touch.by
					moveTouch = .
					originalPosition = position
					touchOffset = position - .position
					if droppedInBox
						droppedInBox.itemInBox = null
						droppedInBox = null
						
				onTouchMove moveTouch
					// Drag item
					position = .position + touchOffset
					
				onTouchUp moveTouch
					// Drop item
					print "Player {touch.by} dropped {word} at {touch.position}"
					Box droppedInBox = app.boxes.find.rect.contains position
					if droppedInBox and droppedInBox.itemInBox == null
						this.droppedInBox = droppedInBox
						droppedInBox.itemInBox = this
						position = droppedInBox.rect.position
					else
						// Box is full, revert to original position
						position = originalPosition
					moveTouch = null
					
			GameOver
				// Draw red text centered at position
				// The background is black in LiveTime, so we need to make sure we use colors that are different from black.
				drawText "Game Over", position, size:40, Color("#ff0000"), font:OpenSans
				
		// Draw blue circle with a radius of 200 with a green outline
		drawCircle position, size:400, Color("#0000ff"), outlineColor:Color("#00ff00"), outlineWidth:5
		
class Box
	Rect rect
	Item itemInBox
	bool isOpen
	
	tick
		// Draw blue box with white outline
		drawRectangle rect.position, rect.size, Color("#0000ff"), outlineColor:Color("#ffffff"), outlineWidth:5
´´´


# The LiveTime programming language
```
app	
	int[] getNumbers: int start, int end
		int[] list
		// In for loops and lambdas, use . to access the current value
		for start to end
			if . % 2 == 0: list.add .
		return list
		
	// We write the return type in front of the function.
	// The function getSum takes a list of integers and returns an integer
	int getSum: int[] list
		int sum
		for list
			sum += .
		return sum

	samples
		// If you divide an integer by an integer in LiveTime, you always get a float
		float fraction = 1 / 2

		// Use math.floor after a division if you need an integer
		int flooredInteger = math.floor(1 / 2)
		
		// If you divide an IntVector2 (interger vector) by a value, you always get a Vector2 (float vector)
		IntVector2 gridPos = {0,0}
		Vector2 startPos = gridPos / 2
		
		// Use round to round an integer vector (IntVector2) to a float vector (Vector2)
		// You can also use floor or ceil
		Direction dir = Up
		IntVector2 centerGridPos = (startPos - dir.vector * (cellCount.x - 1) / 2).round
		
		// Use a "for" loop to iterate over a list
		// Use "." to get the current item while iterating
		// Use "i" to get the index of the current item while iterating
		// In LiveTime, each player always has an "index", a "color" and a "score" by default.
		for players
			print "The Player with the index {i} has the color {.color} and the score {.score}"

		// In a for loop, we can also specify the lower inclusiv bound and the upper exclusive bound. This will iterate from 0 to 7:
		for 0 to 8 as i
			print i

		// In a for loop, the lower bound is 0 by default, and the current index is named "i" by default, so we can leave them out. This will iterate from 0 to 7:
		for 8
			print i

		// This iterates from -1 (inclusive) to 2 (exclusiv), so it prints -1, 0, 1,
		for -1 to 2
			print "{i}, "

		// We can slice a list like this
		Player[] theFirstTwoPlayers = players[..2]
		Player[] theLastThreePlayers = players[-3..]
		
		// We can order a list like this
		Player[] playersOrderedByScore = players.orderBy.score

		// If you need a IntVector2, you need to declare the type, otherwise you will get a IntVector2
		IntVector2 originGridPos = {0,0}

		// Vector2 and IntVector2 are structs and therefore value types, so they can't be null. But you can set them to Vector2.None or IntVector2.none
		IntVector2 currentGridPos = IntVector2.none

		// Set enum value 
		phase = PlacePiece

		// Time.now returns the current time in milliseconds
		Time halfASecondFromNow = Time.now + 500 milliseconds

		// Print name and score of first 2 players
		for 2
			Player player = players[.]
			print "{player.name}: {player.score}"
			
		// Create a list of all scores of all players
		int[] listOfScores = players.select.score
		
		// Are all players alive?
		bool areAllPlayersAlive = players.all.alive
		
		// Iterate players in reverse order and print player names
		for players backwards
			print .name
			
		// Create a list of all number between 10 and 100
		int[] numbers = for 10..100 .
		
		// Get players with even index and a score more than 3
		Player[] evenPlayers = players.where.index % 2 == 0 and .score > 3
		
		int totalScoreOfAlivePlayer = players.where.alive | total.score
		
		// Find player with highest score
		Player winner = players.withMax.score
		
		int maxScore = math.max players[0].score, players[1].score
		
		Player[] firstThreePlayers = players[..3]
		
		Player[] lastFourPlayers = players[-4..]
		
		Player[] top3Players = players.orderBy.score | take 3

		// Does any player have a score of 10?
		// "any" require an argument, don't make the mistake of writing just "players.any"
		bool hasAnybodyAScoreOf10 = players.any.score == 10

		// Are all players alive?
		bool areAllPlayersAlive = players.all.alive
		
		delay 1 seconds
			print "1 second later"
			
	// The "tick" function is called on every frame (30 times per second)
	tick
		// In LiveTime, all drawing functions center the subject at the given position

		// Draw a filled rectangle centered at {10,20} with a size of {100,100}
		drawRectangle position:{10,20}, size:{100,100}, color:currentPlayer.color

		// Draw a rectangle outline centered at {30,40} with a line width of 10
		drawRectangle position:{30,40}, size:{100,100}, outlineColor:currentPlayer.color, outlineWidth:10

		// If you put the images "Cat0.png" and "Cat1.png" in the media folder, you get the image Cat with 2 frames
		// Draw frame 0 of the Cat image and center it at {5,5}
		drawImage Cat, positon:{5,5}, frame:0

		// Draw frame 1 of the Cat image mirrored horizontally
		drawImage Cat, positon:{5,5}, frame:1, flipX:true

```



# The LiveTime Standard Library
These are the available classes and functions. NEVER call any other functions!
```
class int
	const int maxValue
	const int minValue
	int remainder: int value
	string toString:
	string format: int minIntegerDigits, bool grouping
	int abs:
	int shiftLeft: int count
	int shiftRight: int count
	int bitwiseOr: int value
	int bitwiseAnd: int value
	int limit: int from, int to
	int atLeast: int value
	int atMost: int value

class float
	static float maxValue:
	static float minValue:
	static float infinity:
	float remainder: float value
	string toString:
	string format: int fractionDigits, int minIntegerDigits, bool grouping
	float abs:
	float sign:
	int ceil:
	int floor:
	int round:
	float atLeast: float value
	float atMost: float value
	bool isApproximately: float value, float epsilon
	float moveTowards: float value, float speed

class string
	int length:
	string toUpperCase:
	string toLowerCase:
	int toInt:
	int toFloat:
	dynamic parseJson:
	int parseInt: int radix
	string[] split: string seperator
	bool startsWith: string str
	bool endsWith: string str
	int indexOf: string str
	int indexOf: string str, int startPos
	int lastIndexOf: string str
	int lastIndexOf: string str, int startPos
	bool contains: string str
	string substring: int from
	string substring: int from, int to
	string trim:
	string capitalize:

class List<T>
	void add: T item
	void addRange: T[] items
	void insert: T item, int index
	void insert: T item, T after
	void remove: T item
	void removeAt: int index
	void removeRange: int from, int to
	void removeWhere: bool(T a) condition
	T removeFirstWhere: bool(T a) condition
	void ensure: T item
	void ensure: T[] items
	bool contains: T item
	bool containsAny: T[] list
	bool containsNone: T[] list
	int indexOf: T item
	T pop:
	T popAt: int index
	T popWhere: bool(T a) condition
	T popFirst:
	void clear:
	T random:
	T randomWhere: bool(T a) condition
	T popRandom:
	T popRandomWhere: bool(T a) condition
	T[] reverse:
	void moveToBack: T item
	void moveToFront: T item
	T[] orderBy: float(T a) expression
	T[] orderBy: float(T it) expression, string(T it) thenBy
	T[] orderBy: float(T a) expression, SortingOrder order
	bool any: bool(T a) predicate
	bool none: bool(T a) predicate
	bool all: bool(T a) predicate
	TValue[] select: TValue(T it, int i) selector
	T find: bool(T a) condition
	int indexWhere: bool(T a) condition, int startIndex
	T[] where: bool(T a) condition
	T[] take: int count
	int total: int(T it) selector
	T[] shuffle:
	float min: float(T a) selector, float threshold, float default
	float max: float(T a) selector, float threshold, float default
	int minIndex: float(T a) selector, int startIndex, float threshold
	int maxIndex: float(T a) selector, int startIndex, float threshold
	T withMin: float(T a) selector, float threshold
	T withMax: float(T a) selector, float threshold
	T[] intersectWith: T[] other
	T first:
	T last:

class Map<TKey, TValue>
	void remove: TKey key
	bool has: TKey key
	void clear:
	int length:
	void removeWhere: bool(TValue it) condition

class object
	static string toJson: any value

class Set<T>
	void add: T value
	void remove: T value
	bool has: T value
	void clear:
	int length:

static class math
	static float abs: float value
	static float sign: float value
	static float sqrt: float value
	static float moveTowards: float value, float targetValue, float speed
	static int floor: float value
	static int ceil: float value
	static int round: float value
	static float min: float a, float b
	static float max: float a, float b
	static float sin: Angle angleInTurns
	static float cos: Angle angleInTurns
	static float tan: Angle angleInTurns
	static Angle atan2: float y, float x
	static float log: float value
	static float log2: float value
	static float log10: float value
	static float pow: float base, float exponent
	static float exp: float exponent
	static Angle getAngleForVector: Vector2 vector
	static Vector2 getVectorForAngle: Angle angleInTurns, float radius
	static Vector2 intersectLines: Vector2 startA, Vector2 endA, Vector2 startB, Vector2 endB, LineType typeA, LineType typeB

class Time
	static int now // The time in milliseconds
	static int frame // The time in frames (30 frames per second)

class Vector2
	static Vector2 None:
	static Vector2 MinValue:
	static Vector2 MaxValue:
	static Vector2 Zero:
	string toString:
	Vector2 clone:
	float length:
	Vector2 sign:
	float lengthSquared:
	Vector2 orthogonal:
	Vector2 invert:
	IntVector2 round:
	IntVector2 floor:
	IntVector2 ceil:
	Vector2 abs:
	float distanceTo: Vector2 value
	float manhattanDistanceTo: Vector2 value
	Angle angleTo: Vector2 value
	Vector2 normalize:
	void moveTowards: Vector2 targetPosition, float speed, void() onReachedTarget
	bool isInsideRectangle: Vector2 center, Vector2 size
	bool isInsidePolygon: Vector2[] poly
	bool in: Rect rectangle
	float dot: Vector2 value
	float cross: Vector2 value

class Color
	string hex

static class audio
	global void playSound: Sound sound, Time delay, bool needsToBeCertain
	global void playSound: Sound sound, Time at, bool needsToBeCertain

class IntVector2
	static IntVector2 None:
	static IntVector2 Zero:
	const IntVector2 Up
	const IntVector2 Right
	const IntVector2 Down
	const IntVector2 Left
	const IntVector2 Center
	const IntVector2[] primaryDirections
	const IntVector2[] diagonalDirections
	const IntVector2[] horizontalDirections
	const IntVector2[] verticalDirections
	const IntVector2[] allDirections
	IntVector2 clone:
	string toString:
	float length:
	IntVector2 orthogonal:
	IntVector2 inverse:
	IntVector2 abs:
	float distanceTo: IntVector2 value
	int manhattanDistanceTo: IntVector2 value
	bool isInsideRectangle: IntVector2 center, IntVector2 size
	Angle angleTo: IntVector2 value

// An angle in turns
class Angle
	Angle rotateTowards: Angle angleInTurns, Angle speed
	Angle normalize:

class Rect
	Vector2 position
	Vector2 size
	bool contains: Vector2 position
	bool intersectsWith: Vector2 position, Vector2 size

class Grid<T>
	TValue[] select: TValue(T it) selector
	bool all: bool(T a) predicate
	bool any: bool(T a) predicate
	T[] where: bool(T a) predicate
	bool isValid: IntVector2 pos

static class graphics
	static DrawingOrder drawingOrder
	global void drawImage: Image image, Vector2 position, Vector2 size, Player[] visibleFor, Player[] clickableBy, int frame, int layer, float alpha, Color color, Angle angle, bool flipX, bool flipY, Vector2 clickableMargin, bool showClickableArea, Key hotkey, void(Touch touch) onClick
	global float drawText: string text, Vector2 position, Vector2 size, Color color, HorizontalAlignment align, VerticalAlignment valign, FontStyle style, Font font, Color outlineColor, int outlineWidth, int layer, float alpha, Angle angle, Player[] visibleFor, Player[] clickableBy, Vector2 clickableMargin, bool showClickableArea, Key hotkey, TextOverflow overflow, float maxWidth, float lineHeight, void(Touch touch) onClick
	global void drawRectangle: Vector2 position, Vector2 size, Color color, Color outlineColor, int outlineWidth, Player[] visibleFor, int layer, float alpha, HorizontalAlignment align, VerticalAlignment valign
	global void drawRoundedRectangle: Vector2 position, Vector2 size, int radius, Color color, Color outlineColor, int outlineWidth, Player[] visibleFor, int layer, float alpha, HorizontalAlignment align, VerticalAlignment valign
	global void drawCircle: Vector2 position, Vector2 size, Color color, Color outlineColor, int outlineWidth, Angle startAngle, Angle angle, RotationDirection direction, Player[] visibleFor, int layer, float alpha
	global void drawLine: Vector2 from, Vector2 to, Color color, int width, Player[] visibleFor, int layer, float alpha
	global void drawLines: Vector2[] points, Vector2 position, Color color, int width, bool smooth, Player[] visibleFor, int layer, float alpha
	global void drawPolygon: Vector2[] points, Vector2 position, Color color, Color outlineColor, int outlineWidth, bool smooth, Player[] visibleFor, int layer, float alpha
	global void drawVideo: Player player, Vector2 position, Vector2 size, VideoShape shape, Player[] visibleFor

class Touch
	Player by
	bool isDown
	Vector2 position:
	void markAsHandled:

static class input
	global void onTouchDown: Vector2 position, Vector2 size, Player[] by, Cursor cursor, bool showClickableArea, bool markAsHandled, HorizontalAlignment align, VerticalAlignment valign, void(Touch touch) do
	global void onTouchDown: Vector2 position, float radius, Player[] by, Cursor cursor, bool showClickableArea, bool markAsHandled, void(Touch touch) do
	global void onTouchOver: Vector2 position, Vector2 size, Player[] by, Cursor cursor, bool showClickableArea, bool markAsHandled, HorizontalAlignment align, VerticalAlignment valign, void(Touch touch) do
	global void onTouchMove: Touch touch, bool triggeredOnTouchDown, void(Touch touch) do
	global void onTouchUp: Touch touch, bool markAsHandled, void(Touch touch) do

```



# Check errors and fix all problems
Always look at the linter errors and fix all problems! Don't stop until all errors are fixed!

# MOST IMPORTANTLY: Always Run, Test and Debug
To test and verify the app, add debug logs using print statements for everything that is happening in the app. For example, print debug logs for all user actions like clicks. Print the position of all moving objects during every frame of an animation to make sure all animations are correct and smooth.

When you are done, use the "Run and Test" MCP server to thoroughly test all possible cases. Make sure you test all the code and all edge cases. Thoroughly review the debug logs and what is currently on screen.

Fix all errors and bugs you encounter.
