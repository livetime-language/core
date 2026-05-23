// LiveTime Cheatsheet. Important: Only use the following functions and features in your code!
// enum PlayerRole: Warrior, Mage, Archer	// Enums and their values have capitalized names
// Player	// Use capitalized name to define a class. Its members are public by default
//     int index	// Integers are 0 by default
//     float score = 100.0	// Floats are 0.0 by default
//     bool isAlive = true	// Booleans are false by default
//     Vector2 position = {1,2}	// Vectors are {0,0} by default
//     string name	// Strings are "" (the empty string) by default
//     Player[] friends	// Lists are [] (the empty list) by default
//     PlayerRole role = Archer	// You can write "Archer" instead of "PlayerRole.Archer" if the type is known from context
//     Player: int index	// Constructor with parameter. If you don't write a constructor, one is created automatically
//         this.index = index	// Assign member variable
//         position = Vector2(index*8, 0)	// Calls the constructor of Vector2
//         position = {index*8, 0}	// Also calls the constructor of Vector2
// app	// Use lowercase name to define a static class. Access its members with app.players, app.start, etc.
//     Player[] players	// List of players
//     start	// app.start is called once when app starts
//          let a = Player(position:{0,0}, name:"Bob")	// Calls constructor of Player
//          Player b = {position:{8,0}, name:"Alice"}	// You can use object literal syntax to call a constructor if the type is known from context
//          players.add p	// Add to list
//          players.remove p	// Remove from list
//          players.clear	// Clear list
//          if not (0 <= x and x < 10) then print "not between 0 and 10"	// Use "then" in single-line if statements, leave out "then" in multi-line statements
//          if 0 <= x < 10 then print "between 0 and 10"	// Chained comparison
//          randomInteger(0 to 10)	// Random integer between 0 and 10
//          for 0 to 5 as i	// Iterate over integer range with inclusive lower bound and exclusive upper bound
//              print i	// Prints 0 1 2 3 4
//          for players.length	// The lower bound defaults to 0, the iteration variable name defaults to i
//             let player = players[i]	// Get item by index
//          for players.length step -1 as i	// Iterate backwards
//             players.removeAt i 	// Remove item at index
//          for players as p, i	// Iterate over list
//             print "The score of {p.name} is {p.score}"	// String interpolation
//          int period = filename.indexOf(".")	// Get index of character in string
//          string name = filename.substring(0 to period)	// Get substring
//          Player p = players[index mod players.length]	// Modulo operator
//          int sign = x < 0 ? -1 : 1	// Ternary operator
//          randomFloat(0 to 1)	// Random float between 0 and 1
//          floor(3.7)	// The largest integer less than or equal to the given number
//          abs(-5)	// The absolute value of a number
//          players.sortBy .score	// Sort list by score
//          Player winner = players.withMax .score	// Get player with maximum score
//          Player alice = players.find .name == "Alice"	// Find item by condition
//          Player[] topPlayers = players.filter .score > 10	// Get list of items that satisfy condition
//          time.now	// Get current time in milliseconds since 1 January 1970
//          time.ticks	// Get number of frames since the start of the app
//     tick	// app.tick is called every frame (30 times per second by default)
//          drawSprite 0, position:{0,0}	// Draw sprite at position between {0,0} and {192,144} with color between 0 and 15
//          drawText "Hello World", position:{0,0}, color:1	// Draw text at position between {0,0} and {192,144} with color between 0 and 15
//          drawRect position:{0,0}, size:{8,8}, color:2	// Draw filled rectangle
//          if justPressed LeftMouseButton player:0	// Check if player 0 just pressed the left mouse button this frame
//              print "Player 0 clicked at {getPointer player:0}"	// Pointer position of player 0 (mouse, touch or pen)
//          if justPressed A player:1 then print "Player 1 pressed A"	// Available buttons: Up, Down, Left, Right, A, B, X, Y, Start, Select, LeftMouseButton, RightMouseButton
//          if justReleased B player:3 then print "Player 3 released B"	// Check if player 3 just released the B button on their gamepad
//          if isPressed Up player:2 then pos += {0,-1}	// Check if player 2 is currently pressing the Up button on their gamepad
