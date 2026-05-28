// A 2D vector comprised of an integer x and y coordinate
struct IntVector2
	int x // The x-coordinate of the vector
	int y // The y-coordinate of the vector
	SourceCodeLocation location
	
	// Used to specify that the vector is not set or invalid
	static importance:4 inline IntVector2 none() IntVector2(-9007199254740991, -9007199254740991, null)
		
	// {0,0}
	static importance:4 inline IntVector2 zero() IntVector2(0, 0, null)

	const importance:4 immutable IntVector2 Up     = { 0,-1, location:null} // negative y direction (0,-1)
	const importance:4 immutable IntVector2 Right  = { 1, 0, location:null} // positive x direction (1,0)
	const importance:4 immutable IntVector2 Down   = { 0, 1, location:null} // positive y direction (0,1)
	const importance:4 immutable IntVector2 Left   = {-1, 0, location:null} // negative x direction (-1,0)
	const importance:4 immutable IntVector2 Center = { 0, 0, location:null} // negative x direction (-1,0)
		
	const immutable IntVector2 UpLeft    = {-1,-1, location:null} // negative x, negative y direction (-1,-1)
	const immutable IntVector2 UpRight   = { 1,-1, location:null} // positive x, negative y direction (1,-1)
	const immutable IntVector2 DownRight = { 1, 1, location:null} // positive x, positive y direction (1,1)
	const immutable IntVector2 DownLeft  = {-1, 1, location:null} // negative x, positive y direction (-1,1)
	
	// List of the four primary direction: Right, Down, Left, Up
	const importance:4 immutable IntVector2[] primaryDirections = [Up, Right, Down, Left]
	
	// List of the four diagonals: UpLeft, UpRight, DownLeft, DownRight
	const importance:4 immutable IntVector2[] diagonalDirections = [UpLeft, UpRight, DownRight, DownLeft]
	
	// The two horitontal directions: Left and Right
	const importance:4 immutable IntVector2[] horizontalDirections = [Left, Right]
	
	// The two vertical directions: Up and Down
	const importance:4 immutable IntVector2[] verticalDirections = [Up, Down]
	
	// Directions that form a triangle pointing up: Up, DownRight, DownLeft
	const immutable IntVector2[] trianglePointingUp = [Up, DownRight, DownLeft]
	
	// Directions that form a triangle pointing right: UpLeft, Right, DownLeft
	const immutable IntVector2[] trianglePointingRight = [UpLeft, Right, DownLeft]
	
	// Directions that form a triangle pointing down: UpLeft, UpRight, Down
	const immutable IntVector2[] trianglePointingDown = [UpLeft, UpRight, Down]
	
	// Directions that form a triangle pointing left: Left, UpRight, DownRight
	const immutable IntVector2[] trianglePointingLeft = [Left, UpRight, DownRight]
	
	// List of the primary direction and the diagonals
	const importance:4 immutable IntVector2[] allDirections = [Up, UpRight, Right, DownRight, Down, DownLeft, Left, UpLeft]

	// The center and all surrounding directions (a 3 x 3 around the center)
	const immutable IntVector2[] centerAndAllDirections = [Center, Up, UpRight, Right, DownRight, Down, DownLeft, Left, UpLeft]

	// The center and all horizontal and vertical directions (a cross)
	const immutable IntVector2[] centerAndPrimaryDirections = [Center, Up, Right, Down, Left]
	
	// Creates a copy of the vector with the same values
	importance:4 IntVector2 clone => {x, y, location}
		
	// A string representation of the vector
	importance:4 string toString => "\{{x}, {y}\}"
	
	implicit Vector2 toVector2 => {x, y, location}
	
	// Create a new instance. Useful for data imported from json where the vector might be undefined
	inline js IntVector2 create: int x, int y // Create a new instance with the coordinated of this vector
		(this = new IntVector2(x, y))

	IntVector2 assign IntVector2 other: x = other.x; y = other.y; location = other.location; return this
		
	IntVector2 + IntVector2 other:   return {x + other.x, y + other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 + Vector2 other:         return {x + other.x, y + other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	
	IntVector2 - IntVector2 other:   return {x - other.x, y - other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 - Vector2 other:         return {x - other.x, y - other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	
	IntVector2 * IntVector2 other:   return {x * other.x, y * other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2    * Vector2 other:      return {x * other.x, y * other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	IntVector2 * int other:          return {x * other,   y * other, location}
	Vector2    * float other:        return {x * other,   y * other, location}
	
	Vector2 / IntVector2 other:      return {x / other.x, y / other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 / float other:           return {x / other,   y / other, location}

	IntVector2 % IntVector2 other:   return {(x mod other.x), (y mod other.y), location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	IntVector2 % int other:          return {(x mod other),   (y mod other), location}
		
	IntVector2 += IntVector2 other: x += other.x; y += other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	IntVector2 -= IntVector2 other: x -= other.x; y -= other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	
	IntVector2 *= IntVector2 other: x *= other.x; y *= other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	IntVector2 *= int other:        x *= other;   y *= other; return this
	
	Vector2    /= IntVector2 other: x /= other.x; y /= other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	Vector2    /= float other:      x /= other;   y /= other; return this
	
	bool == IntVector2 other: return x == other.x && y == other.y
	bool != IntVector2 other: return x != other.x || y != other.y
		
	bool <  IntVector2 other: return x <  other.x && y <  other.y
	bool <= IntVector2 other: return x <= other.x && y <= other.y
	bool >  IntVector2 other: return x >  other.x && y >  other.y
	bool >= IntVector2 other: return x >= other.x && y >= other.y
	
	bool <  float length: return math.sqrt(x*x + y*y) <  length
	bool <= float length: return math.sqrt(x*x + y*y) <= length
	bool >  float length: return math.sqrt(x*x + y*y) >  length
	bool >= float length: return math.sqrt(x*x + y*y) >= length
		
	// Returns true if the vector is not equal to IntVector2.none
	inline js bool toBool() (this != null && (this.x != -9007199254740991 || this.y != -9007199254740991))
	inline js bool !() (this == null || (this.x == -9007199254740991 && this.y == -9007199254740991))

	IntVector2 -() return {-this.x, -this.y, this.location}
	
	// The length of the vector
	importance:4 length => math.sqrt(x * x + y * y)
		
	// The length of the vector
	importance:4 magnitude => math.sqrt(x * x + y * y)
	
	// A vector that is orthogonal to the existing vector
	importance:4 orthogonal => IntVector2(x:-y, y:x)
		
	// A vector with the sign of each coordinate flipped
	importance:4 inverse => IntVector2(-x, -y)
		
	// A vector with the absolute value of each coordinate
	importance:4 abs => IntVector2(math.abs(x), math.abs(y))
		
	// The larger of the two coordinates
	max => x > y ? x : y
	
	// The smaller of the two coordinates
	min => x < y ? x : y
	
	clamp: IntVector2 min
		   IntVector2 max
		return IntVector2(
			math.clamp x, min:min.x, max:max.x
			math.clamp y, min:min.y, max:max.y
		)
		
	clamp: IntVector2 max
		return IntVector2(
			math.clamp x, max:max.x
			math.clamp y, max:max.y
		)
		
	clamp: IntVector2 min
		return IntVector2(
			math.clamp x, min:min.x
			math.clamp y, min:min.y
		)
		
	// The distance to another vector
	importance:4 distanceTo: IntVector2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return math.sqrt(x*x + y*y)
		
	// The distance to another vector
	distanceTo: Vector2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return math.sqrt(x*x + y*y)

	// The distance to another vector along axes at right angles
	importance:4 manhattanDistanceTo: IntVector2 value // The second vector
		return math.abs(x - value.x) + math.abs(y - value.y)
		
	// Returns whether the vector is within a given rectangle
	importance:4 isInsideRectangle: IntVector2 center, // The center of the rectangle
		               IntVector2 size,   // The size of the rectangle
		return x >= center.x - size.x/2 && x < center.x + size.x/2
		    && y >= center.y - size.y/2 && y < center.y + size.y/2		

	// The angle to another vector in radians (one full rotation is 2*pi)
	importance:4 angleTo: IntVector2 value // The second vector
		return math.getAngleForVector(value - this)
		
	// A float vector that points in the same direction, but has a length of 1
	normalized
		let len = math.sqrt(x * x + y * y)
		return len != 0 ? Vector2(x / len, y / len) : Vector2(0, 0)
		
	static js TResult[] enumerate: IntVector2 from
	                               IntVector2 to
	                               TResult(IntVector2 it) selector
		let result = []
		for(let y=from.y; y < to.y; ++y)
			for(let x=from.x; x < to.x; ++x)
				result.push(selector(new IntVector2(x,y)))
		return result
		
	inline js TResult[] times: TResult(IntVector2 it) selector
		Vector2.enumerate(new IntVector2(0,0), this, selector)
	
global transient unit System
	global inline js void for: IntVector2 subject  // The exclusive upper bound to iterate towards
		                       -> inline void(
		                           IntVector2 pos, // The current position of the vector we are iterating over with the for-loop
		                           int x,          // The x component of the current position we are iterating over with the for-loop
		                           int y           // The y component of the current position we are iterating over with the for-loop
		                       ) do                // Do this the given number of times
		for(let _size=subject, y=0; y<_size.y; ++y) for(let x=0; x<_size.x; ++x) do(new IntVector2(x,y), x, y)
			
	global inline js void for: IntVector2 subject  // The exclusive upper bound to iterate towards
		                       <- inline void(
		                           IntVector2 pos, // The current position of the vector we are iterating over with the for-loop
		                           int x,          // The x component of the current position we are iterating over with the for-loop
		                           int y           // The y component of the current position we are iterating over with the for-loop
		                       ) do                // Do this the given number of times
		for(let _size=subject, y=_size.y-1; y>=0; --y) for(let x=_size.x-1; x>=0; --x) do(new IntVector2(x,y), x, y)
			
	global inline js TResult[] for: IntVector2 to     // Iterator over both dimensions of the vector towards this exclusive upper bound
		                            TResult(
		                                IntVector2 it // The current position of the vector we are iterating over with the for-loop
		                            ) do              // Select the field or expression to be included in the result
		IntVector2.enumerate(new IntVector2(0,0), to, do)

	global inline js TResult[] for: IntVector2 from     // Iterator over both dimensions of the vector starting from this vector
		                            TResult(
		                                IntVector2 it   // The current position of the vector we are iterating over with the for-loop
		                            ) do                // Select the field or expression to be included in the result
		                            label IntVector2 to // Iterator over both dimensions of the vector towards this exclusive upper bound
		IntVector2.enumerate(from, to, do)

struct int
	inline js IntVector2 * IntVector2 other: new IntVector2(this * other.x, this * other.y, other.location)
