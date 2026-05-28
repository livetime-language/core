enum Direction: Up, Right, Down, Left

// A 2D vector comprised of an x and y coordinate
struct Vector2
	float x // The x-coordinate of the vector
	float y // The y-coordinate of the vector
	SourceCodeLocation location
	
	// Used to specify that the vector is not set or invalid
	static importance:4 inline Vector2 none() Vector2(float.infinity, float.infinity, null)
	
	// {float.minValue, float.minValue}
	static importance:4 inline Vector2 minValue() Vector2(float.minValue, float.minValue, null)
	
	// {float.maxValue, float.maxValue}
	static importance:4 inline Vector2 maxValue() Vector2(float.maxValue, float.maxValue, null)
	
	// {0,0}
	static importance:4 inline Vector2 zero() Vector2(0, 0, null)
		
	// A string representation of the vector
	importance:4 string toString => "\{{x.format(maxFractionDigits:1)}, {y.format(maxFractionDigits:1)}\}"
	
	// Creates a copy of the vector with the same values
	importance:4 Vector2 clone => {x, y, location}
		
	// Create a new instance. Useful for data imported from json where the vector might be undefined
	inline js Vector2 create: float x // The x-coordinate of the vector to create
		                      float y // The y-coordinate of the vector to create
		                      SourceCodeLocation location
		(this = new Vector2(x, y, location))
		
	// Create a new instance. Useful for data imported from json where the vector might be undefined
	inline js Vector2 create: Vector2 value  // Create a new instance with the coordinated of this vector
		(this = new Vector2(value.x, value.y, value.location))
		
	// ------------------------------------------------------- Operators -------------------------------------------------------
	
	Vector2 assign Vector2 other: x = other.x; y = other.y; location = other.location; return this
		
	Vector2 + Vector2 other:   return {x + other.x, y + other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 - Vector2 other:   return {x - other.x, y - other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	
	Vector2 * Vector2 other:   return {x * other.x, y * other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 * float other:     return {x * other,   y * other,   location}
	
	Vector2 / Vector2 other:   return {x / other.x, y / other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 / float other:     return {x / other,   y / other,   location}
				
	Vector2 % Vector2 other:   return {(x mod other.x), (y mod other.y), location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 % float other:     return {(x mod other),   (y mod other),   location}
		
	Vector2 += Vector2 other: x += other.x; y += other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	Vector2 -= Vector2 other: x -= other.x; y -= other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	
	Vector2 *= Vector2 other: x *= other.x; y *= other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	Vector2 *= float other:   x *= other;   y *= other; return this
	
	Vector2 /= Vector2 other: x /= other.x; y /= other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	Vector2 /= float other:   x /= other;   y /= other; return this
	
	bool == Vector2 other: return x == other.x && y == other.y
	bool != Vector2 other: return x != other.x || y != other.y
		
	bool <  Vector2 other: return x <  other.x && y <  other.y
	bool <= Vector2 other: return x <= other.x && y <= other.y
	bool >  Vector2 other: return x >  other.x && y >  other.y
	bool >= Vector2 other: return x >= other.x && y >= other.y
	
	bool <  float length: return math.sqrt(x*x + y*y) <  length
	bool <= float length: return math.sqrt(x*x + y*y) <= length
	bool >  float length: return math.sqrt(x*x + y*y) >  length
	bool >= float length: return math.sqrt(x*x + y*y) >= length
		
	// Returns true if the vector is not equal to Vector2.none
	inline js bool toBool() (this != null && (this.x != Number.POSITIVE_INFINITY || this.y != Number.POSITIVE_INFINITY))
	inline js bool !() (this == null || (this.x == Number.POSITIVE_INFINITY && this.y == Number.POSITIVE_INFINITY))

	Vector2 -() return {-this.x, -this.y, this.location}
	
	// The length of the vector
	importance:4 length => math.sqrt(x * x + y * y)
		
	// The length of the vector
	importance:4 magnitude => math.sqrt(x * x + y * y)

	// The square of the length of the vector
	importance:4 lengthSquared => x * x + y * y
		
	// The sign of each coordinate
	importance:4 sign => Vector2(math.sign(x), math.sign(y))
		
	// Make the vector orthogonal to the existing vector
	importance:4 orthogonal => {-y, x}
		
	// Flip the sign of each coordinate
	importance:4 invert
		x = -x
		y = -y
		return this
		
	// Round each coordinate to the closest integer value
	importance:4 Vector2 round => Vector2(math.round(x), math.round(y))
	
	// Round each coordinate down to an integer value
	importance:4 Vector2 floor => Vector2(math.floor(x), math.floor(y))
		
	// Round each coordinate up to an integer value
	importance:4 Vector2 ceil => Vector2(math.ceil(x), math.ceil(y))
		
	// Return a new vector with each coordinate positive
	importance:4 abs
		return {math.abs(x), math.abs(y)}

	// The larger of the two coordinates
	max => x > y ? x : y
	
	// The smaller of the two coordinates
	min => x < y ? x : y
	
	// Move the vector
	move: Vector2 delta // The vector to move by
		this.x += delta.x
		this.y += delta.y
		return this
	
	// Move the vector	
	move: float x // Move horizontally by this value
		  float y // Move vertically by this value
		this.x += x
		this.y += y
		return this
		
	// Rotate the vector by a given angle
	rotate: float angle // The angle in radians (one full rotation is 2*pi)
		let x = this.x, y = this.y
		let sn = math.sin(angle)
		let cs = math.cos(angle)
		this.x = x * cs - y * sn;
		this.y = x * sn + y * cs;
		return this
		
	// The distance to another vector
	importance:4 distanceTo: Vector2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return math.sqrt(x*x + y*y)

	// The distance to another vector along axes at right angles
	importance:4 manhattanDistanceTo: Vector2 value // The second vector
		return math.abs(x - value.x) + math.abs(y - value.y)

	// The angle to another vector in radians (one full rotation is 2*pi)
	importance:4 angleTo: Vector2 value // The second vector
		return math.getAngleForVector(value - this)

	// Ensure the vector has a length of 1
	importance:4 normalize
		let len = math.sqrt(x * x + y * y)
		if len != 0 then x = x / len; y = y / len
		return this

	js Vector2 swapWith: Vector2 other
		let temp = this.x
		this.x = other.x
		other.x = temp
		temp = this.y
		this.y = other.y
		other.y = temp
		return this

	// A vector that points in the same direction, but has a length of 1
	normalized => this.clone.normalize
	
	// Moves the vector towards the given target by the given distance	
	importance:4 moveTowards: Vector2 targetPosition // The target to move towards
		         float speed = 30       // The distance to move by
		         void() onReachedTarget = null
		let delta = targetPosition - this
		if delta.x != 0 || delta.y != 0
			delta = delta.normalize * speed
			if delta.x > 0 then	x = math.min(x + delta.x, targetPosition.x)
			else	x = math.max(x + delta.x, targetPosition.x)
			if delta.y > 0 then	y = math.min(y + delta.y, targetPosition.y)
			else	y = math.max(y + delta.y, targetPosition.y)
		else
		if onReachedTarget != null
			onReachedTarget
		
	// Returns whether the vector is within a given rectangle
	importance:4 insideRectangle: Vector2 center // The center of the rectangle
		                          Vector2 size   // The size of the rectangle
		let halfSizeX = size.x/2, halfSizeY = size.y/2
		return x >= center.x - halfSizeX && x < center.x + halfSizeX
		    && y >= center.y - halfSizeY && y < center.y + halfSizeY
		
	// Returns whether the vector is within a given polygon
	importance:4 insidePolygon: Vector2[] poly // A list of points that make up the polygon
		let c = false, i = -1, l = poly.length, j = l - 1
		while ++i < l
			((poly[i].y <= this.y && this.y < poly[j].y) || (poly[j].y <= this.y && this.y < poly[i].y))
			&& (this.x < (poly[j].x - poly[i].x) * (this.y - poly[i].y) / (poly[j].y - poly[i].y) + poly[i].x)
			&& (c = !c)
			j = i
		return c
		
	importance:4 in: Rect rectangle
		return x >= rectangle.position.x - rectangle.size.x/2 && x < rectangle.position.x + rectangle.size.x/2
		    && y >= rectangle.position.y - rectangle.size.y/2 && y < rectangle.position.y + rectangle.size.y/2
	
	// The dot product
	importance:4 dot: Vector2 value // The value to calculate the dot procut with
		return x * value.x + y * value.y
		
	// The cross product
	importance:4 cross: Vector2 value // The value to calculate the cross procut with
		return x*value.y - y*value.x
		
	static getPathLength: Vector2[] path
		float length
		forPairs path
			length += .distanceTo next
		return length
				
js String
immutable class string
	Vector2 toVector2
		let mid = this.indexOf " "
		return Vector2(cast this[..mid], cast this[mid+1..]) 
		
PositionAndVector
	Vector2 position
	Vector2 vector
	
Path
	Vector2[] nodes
	float[] segmentLengths
	float length
	
	Vector2 first	=> nodes ? nodes.first : Vector2.none
	Vector2 last	=> nodes ? nodes.last  : Vector2.none
	int count	=> nodes.length
	inline Vector2 get(int index) this.nodes[index]
	
	Path
		update
		
	update
		length = 0
		forPairs nodes
			let x = next.x - .x
			let y = next.y - .y
			length += segmentLengths[i] = math.sqrt(x*x + y*y)
		
	Vector2 getPosition: float distance
		if nodes.length == 0 then return Vector2.none
		if nodes.length == 1 then return nodes[0]
			
		float travelledSoFar
		forPairs nodes
			let segmentLength = segmentLengths[i]
			let travelledAfterSegment = travelledSoFar + segmentLength
			if  travelledAfterSegment >= distance
				let factor = (distance - travelledSoFar) / segmentLength
				return {.x + (next.x - .x)*factor, .y + (next.y - .y)*factor}
				// return .interpolateTo next progress:distance travelledSoFar..travelledAfterSegment
			travelledSoFar = travelledAfterSegment
		return nodes.last
		
	PositionAndVector getPositionAndVector: float distance
		if nodes.length == 0 then return { position:Vector2.none }
		if nodes.length == 1 then return { position:nodes[0] }
			
		float travelledSoFar
		forPairs nodes
			let segmentLength = segmentLengths[i]
			let travelledAfterSegment = travelledSoFar + segmentLength
			if  travelledAfterSegment >= distance
				let factor = (distance - travelledSoFar) / segmentLength
				return {
					position:{.x + (next.x - .x)*factor, .y + (next.y - .y)*factor}
					vector: next - .
				}
				// return .interpolateTo next progress:distance travelledSoFar..travelledAfterSegment
			travelledSoFar = travelledAfterSegment
			
		let lastPos = nodes.last
		return {position:lastPos, vector:lastPos - nodes[nodes.length-2]}
	
struct float
	inline js Vector2 * Vector2 other: new Vector2(this * other.x, this * other.y, other.location)

struct int
	inline js Vector2 * Vector2 other: new Vector2(this * other.x, this * other.y, other.location)

global transient unit System
	global inline js void for: Vector2 subject  // The exclusive upper bound to iterate towards
		                       -> inline void(
		                           Vector2 pos, // The current position of the vector we are iterating over with the for-loop
		                           int x,          // The x component of the current position we are iterating over with the for-loop
		                           int y           // The y component of the current position we are iterating over with the for-loop
		                       ) do                // Do this the given number of times
		for(let _size=subject, y=0; y<_size.y; ++y) for(let x=0; x<_size.x; ++x) do(new Vector2(x,y), x, y)
			
	global inline js void for: Vector2 subject  // The exclusive upper bound to iterate towards
		                       <- inline void(
		                           Vector2 pos, // The current position of the vector we are iterating over with the for-loop
		                           int x,          // The x component of the current position we are iterating over with the for-loop
		                           int y           // The y component of the current position we are iterating over with the for-loop
		                       ) do                // Do this the given number of times
		for(let _size=subject, y=_size.y-1; y>=0; --y) for(let x=_size.x-1; x>=0; --x) do(new Vector2(x,y), x, y)
