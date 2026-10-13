# LiveTime syntax and core library
enum PlayerRole: Knight, Archer	// Enums are global and can be accessed from anywhere
class Player	// Classes have capitalized names. Their members are public by default
	int        index	// Member variable of class Player. Integers are 0 by default
	float      score = 100.0	// Floating point numbers are 0.0 by default
	bool       isAlive = true	// Booleans are false by default
	Vector2    pos = {1.5, 2.5}	// Vectors are {0,0} by default. Its fields x and y are floats.
	IntVector2  gridPos = {5,4}	// IntVectors are {0,0} by default. Its fields x and y are integers.
	string     name	// Strings are "" (the empty string) by default
	Player[]   friends	// Lists are [] (the empty list) by default
	PlayerRole role = Archer	// You can write "Archer" instead of "PlayerRole.Archer" if the type is known from context
	Player: int index = -1	// Constructor of class Player. If you don't write a constructor, one is created automatically
		this.index = index	// Assign member variable
		pos = {index*8, 0}	// Call constructor of Vector2
app	// Use lowercase name to declare static class. Access members with app.with app.players, app.start, etc.
	Player[] players	// List of players
	start	// app.start is called once when the app starts
		let alice = Player(pos:{x,y}, name:"Alice")	// Call constructor of Player
		Player bob = {pos:{8,0}, name:"Bob"}	// You can use object literal syntax to call constructor if the type is known from context
		players.add alice	// Add to list
		players.remove alice	// Remove from list
		players.clear	// Remove all items from list
		for p in players	// Iterate over list
			print "The score of {p.name} is {p.score}"	// String interpolation
		for i = 0 to 5	// Iterate over range with inclusive start 0 and exclusive end 5
			print i	// Prints 0 1 2 3 4
		for players.length	// Start index is 0 if left out, iteration variable is . if left out
			let player = players[.]	// Get item by index
		for i to players.length step -1	// Reverse order
			print i	// Prints 4 3 2 1 0
			players.removeAt i 	// Remove item at index
		if not (x < 0 or x >= 10) then print "between 0 and 10"	// Use "then" in single-line if statements, leave out "then" in multi-line statements
		if 0 <= x < 10 then print "between 0 and 10"	// Chained comparison
		max := x > y ? x : y	// Declare local variable with := (alternative to "let")
		fraction := 1/2	// 1/2 creates a float with value 0.5
		int wholeNumber = 10/3	// Floats are rounded down when assigned to int (wholeNumber is 3)
		floor(3.1); ceil(3.9); round(3.5)	// Rounds down with floor, round up with ceil
		abs(-5)	// Absolute value
		randomInteger(0 to 10); randomFloat(0 to 1)	// Random values
		int dot = filename.indexOf(".")	// Find index of string
		filename = filename.substring(0 to dot)	// Substring
		nextPlayer := players[(index+1) mod players.length]	// a mod b is always between 0 and b (-1 mod 10 == 9)
		Vector2 pos = {cos(x*2*pi), sin(y*2*pi)}	// Trigonometric functions: sin, cos, tan, atan
		players.sortBy.score	// Sort list by score
		winner := players.withMax.score	// Get player with maximum score
		charlie := players.find.name == "Charlie"	// Find item by condition
		topPlayers := (players.filter.score > 10).sortBy.score	// Filter a list then sort it
		players.each.tick	// Call tick for each player in list
		dynamic config = json.parse(jsonString)	// Parse JSON to dynamic object, convert back with json.stringify
		IntVector2 gridPos = (IntVector2)pos	// Cast to Player	
		Player[string] playersByName	// Dictionary (hashtable) mapping string keys to Player values
		playersByName["Alice"] = alice	// Add to dictionary
		playersByName.remove "Alice"	// Remove from dictionary
		playersByName.clear	// Remove all items from dictionary
		for name, player in playersByName	// Iterate over dictionary
			print "{name} moved to {.gridPos}", type:Action	// Use print type:Action for actions performed by a player
			print "{name} won", type:Reaction	// Use print type:Reaction for reactions or consequences of an action
		Time.now	// Get current time in milliseconds since 1 January 1970
