		


immutable priority low struct float
	inline float ° => (this/180*math.pi)
	
	// Turns: One full rotation is 1
	inline float turn => (this*math.twoPi)
	
	// Radians: One full rotation is 2π (about 6.2832)
	inline float rad => this
		
	// Degrees: One full rotation is 360
	inline float deg => (this/180*math.pi)
		
	// Gradians: One full rotation is 400
	inline float grad => (this/200*math.pi)
			
global skipInit unit math
	// Returns the arctangent of the quotient of the given values
	importance:4 float getAngleForVector: Vector2 vector
		return math.atan2(vector.y, vector.x)
		
	importance:4 Vector2 getVectorForAngle: float angle      // The angle in radians (-pi/2: left, 0: up, pi/2: right, pi: down)
		                                 float radius = 1.0
		return new Vector2(math.sin(angle)*radius, -math.cos(angle)*radius)
		
	importance:4 Vector2 intersectLines: Vector2 startA
		                    Vector2 endA
		                    Vector2 startB
		                    Vector2 endB
		                    LineType typeA = Segment
		                    LineType typeB = Segment
		
		let x1    = startA.x, y1 = startA.y
		let x2    = endA.x,   y2 = endA.y
		let x3    = startB.x, y3 = startB.y
		let x4    = endB.x,   y4 = endB.y
		
		// Check if none of the lines are of length 0
		if (x1 == x2 && y1 == y2) || (x3 == x4 && y3 == y4) return Vector2.none

		// compute line params
		let denominator = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)
		if (denominator == 0) return Vector2.none // lines are parallel
		let ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator
		let ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator

		// is the intersection along the segments
		if (typeA >= Ray && ua < 0) || (typeA == Segment && ua > 1)
		|| (typeB >= Ray && ub < 0) || (typeB == Segment && ub > 1)
			return Vector2.none
			
		// Return a object with the x and y coordinates of the intersection
		return new Vector2(x1 + ua * (x2 - x1), y1 + ua * (y2 - y1))
		
	projectPointOnLine: Vector2 from, Vector2 to, LineType type = Segment, Vector2 point
		let lineVector = to - from
		let pointVector = point - from
		let scalar = (pointVector dot lineVector) / lineVector.lengthSquared
		if type >= Ray     and scalar < 0 then return Vector2.none
		if type == Segment and scalar > 1 then return Vector2.none
		return from + lineVector * scalar
	
	closestPointOnLine: Vector2 from, Vector2 to, LineType type = Segment, Vector2 point
		let lineVector = to - from
		let pointVector = point - from
		let scalar = (pointVector dot lineVector) / lineVector.lengthSquared
		if type >= Ray     and scalar < 0 then scalar = 0
		if type == Segment and scalar > 1 then scalar = 1
		return from + lineVector * scalar
	
global transient unit System
	global inline js void forPositions: int to                            // The exclusive upper bound to iterate towards
		                                Vector2 start = {0,0}             // Left or top align items at this position
		                                implicit Vector2 delta = {300,0}  // Distance between items
		                                inline -> void(
		                                    Vector2 pos,                  // The position of the current item
		                                    int i                         // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _start = start, _delta = delta, _len=to, _x = _start.x, _y= _start.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) do(new Vector2(_x, _y, _start.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _start.location, _delta.location) : null), i)

	global inline js void forPositions: int to                            // The exclusive upper bound to iterate towards
		                                Vector2 center = {0,0}            // Center items at this position
		                                implicit Vector2 delta = {300,0}  // Distance between items
		                                inline -> void(
		                                    Vector2 pos,                  // The position of the current item
		                                    int i,                        // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _center = center, _delta = delta, _len=to, _x = _center.x-(_len-1)*_delta.x/2, _y=_center.y-(_len-1)*_delta.y/2; i<_len; ++i, _x += _delta.x, _y += _delta.y) do(new Vector2(_x, _y, _center.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _center.location, _delta.location) : null), i)

	global inline js void forPositions: int to                            // The exclusive upper bound to iterate towards
		                                Vector2 end = {0,0}               // Center items at this position
		                                implicit Vector2 delta = {300,0}  // Distance between items
		                                inline -> void(
		                                    Vector2 pos,                  // The position of the current item
		                                    int i,                        // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _end = end, _delta = delta, _len=to, _x = _end.x-(_len-1)*_delta.x, _y=_end.y-(_len-1)*_delta.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) do(new Vector2(_x, _y, _end.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _end.location, _delta.location) : null), i)

	global inline js void forPositions: T[] subject                       // The list to iterate over
		                                Vector2 start = {0,0}             // Left or top align items at this position
		                                implicit Vector2 delta = {300,0}  // Distance between items
		                                inline -> void(
		                                    T it,                         // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,                  // The position of the current item
		                                    int i                         // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _subject=subject, _start = start, _delta = delta, _len=_subject.length, _x = _start.x, _y= _start.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) do(_subject[i], new Vector2(_x, _y, _start.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _start.location, _delta.location) : null), i)

	global inline js void forPositions: T[] subject                       // The list to iterate over
		                                Vector2 start = {0,0}             // Left or top align items at this position
		                                implicit Vector2 delta = {300,300} // Distance between items
		                                float width                       // Wrap to the next row when we reach this width
		                                inline -> void(
		                                    T it,                         // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,                  // The position of the current item
		                                    int i                         // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _subject=subject, _start = start, _delta = delta, _width = width, _len=_subject.length, _x = _start.x, _y= _start.y; i<_len; ++i, _x += _delta.x) { if(_x >= _start.x+_width) {_x = _start.x; _y += _delta.y} do(_subject[i], new Vector2(_x, _y, _start.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _start.location, _delta.location) : null), i)}

	global inline js void forPositions: T[] subject                       // The list to iterate over
		                                Vector2 center = {0,0}            // Center items at this position
		                                implicit Vector2 delta = {300,0}  // Distance between items
		                                inline -> void(
		                                    T it,                         // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,                  // The position of the current item
		                                    int i                         // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _subject=subject, _center = center, _delta = delta, _len=_subject.length, _x = _center.x-(_len-1)*_delta.x/2, _y=_center.y-(_len-1)*_delta.y/2; i<_len; ++i, _x += _delta.x, _y += _delta.y) do(_subject[i], new Vector2(_x, _y, _center.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _center.location, _delta.location) : null), i)

	global inline js void forPositions: T[] subject                       // The list to iterate over
		                                Vector2 end = {0,0}               // Right or bottom align items at this position
		                                implicit Vector2 delta = {300,0}  // Distance between items
		                                inline -> void(
		                                    T it,                         // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,                  // The position of the current item
		                                    int i                         // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _subject=subject, _end = end, _delta = delta, _len=_subject.length, _x = _end.x-(_len-1)*_delta.x, _y=_end.y-(_len-1)*_delta.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) do(_subject[i], new Vector2(_x, _y, _end.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _end.location, _delta.location) : null), i)
	
	global inline js void forPositions: T[] subject                        // The list to iterate over
		                                IntVector2 grid                    // Align items in a grid with this size
		                                Vector2 center = {0,0}             // Center items at this position
		                                implicit Vector2 delta = {300,300} // Distance between items
		                                inline -> void(
		                                    T it,                          // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,                   // The position of the current item
		                                    int i                          // The index of the current item of the list we are iterating over with forCentered
		                                ) do                               // Do this for each item in a list
		for(let i=0, _subject=subject, _center = center, _delta = delta, _grid=grid, _y=0, _yPos=_center.y-(_grid.y-1)*_delta.y/2; _y<_grid.y; ++_y, _yPos += _delta.y) for(let _x=0, _xPos = _center.x-(_grid.x-1)*_delta.x/2; _x < _grid.x && i < _subject.length; ++_x, _xPos += _delta.x, i++) {do(_subject[i], new Vector2(_xPos, _yPos, _center.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _center.location, _delta.location) : null), i)}
	
	global inline js void forPositions: int to                             // The exclusive upper bound to iterate towards
		                                IntVector2 grid                    // Align items in a grid with this size
		                                Vector2 center = {0,0}             // Center items at this position
		                                implicit Vector2 delta = {300,300} // Distance between items
		                                inline -> void(
		                                    T it,                          // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,                   // The position of the current item
		                                    int i                          // The index of the current item of the list we are iterating over with forCentered
		                                ) do                               // Do this for each item in a list
		for(let i=0, _center = center, _delta = delta, _grid=grid, _y=0, _yPos=_center.y-(_grid.y-1)*_delta.y/2; _y<_grid.y; ++_y, _yPos += _delta.y) for(let _x=0, _xPos = _center.x-(_grid.x-1)*_delta.x/2; _x < _grid.x && i < to; ++_x, _xPos += _delta.x, i++) {do(i, new Vector2(_xPos, _yPos, _center.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _center.location, _delta.location) : null), i)}

// Converts positions within an isomatic grid with the origin in the north
// Tilt your head slighly to the right to visualize the directions
// World space (northwest is up)
//
//      Left   Top             
//           x               🡷 🡶
//    Bottom   Right        y     x
//
// Screen space (north is up)
//
//          Top              🡺 x
//     Left  +  Right      🡻 
//        Bottom            y
//
class IsometicGrid
	IntVector2 size            // The amount of cells in the grid
	Vector2 cellSize      // The size of each cell
	Vector2 topFaceOffset // The position of the top face within the cell
	
	visible Vector2 xOffset = cellSize / 2
	visible Vector2 yOffset = {-xOffset.x, xOffset.y}
	visible Vector2 basePos = {0,-yOffset.y*(size.y-1)}
	
	// Convert world position (northwest is up) to screen position (north is up)
	getScreenPosition: Vector2 worldPos // The world position
		return basePos + xOffset*worldPos.x + yOffset*worldPos.y
		
	// Convert screen position (north is up) to world position (northwest is up)
	getWorldPosition: Vector2 screenPos // The screen position
		              bool allowOutside = false
		Vector2 t = screenPos - basePos + topFaceOffset
		let x = (xOffset.x*t.y + xOffset.y*t.x) / (2*xOffset.x*xOffset.y)
		let y = (xOffset.x*t.y - xOffset.y*t.x) / (2*xOffset.x*xOffset.y)
		if allowOutside or (x >= 0 and x < size.x and y >= 0 and y < size.y) then	return Vector2(x,y)
		else	return Vector2.none
		
	// Convert screen pos (north is up) to rounded world pos (northwest is up)
	getGridPosition: Vector2 screenPos // The screen position
		             bool allowOutside = false
		Vector2 t = screenPos - basePos + topFaceOffset
		let x = math.round((xOffset.x*t.y + xOffset.y*t.x) / (2*xOffset.x*xOffset.y))
		let y = math.round((xOffset.x*t.y - xOffset.y*t.x) / (2*xOffset.x*xOffset.y))
		if allowOutside or (x >= 0 and x < size.x and y >= 0 and y < size.y) then	return IntVector2(x,y)
		else	return IntVector2.none
		
	isValid: IntVector2 pos
		return pos >= {0,0} and pos < size
		
	limitToInside: IntVector2 position
		return IntVector2(
			math.clamp position.x, min:0, max:size.x-1
			math.clamp position.y, min:0, max:size.y-1
		)
		
	getScreenVector: Vector2 worldVector
		return xOffset*worldVector.x + yOffset*worldVector.y
		
enum RotationDirection: Clockwise, CounterClockwise
	
enum LineType: Line, Ray, Segment
	
Line
	Vector2 start, end
	LineType type
	
	length
		return type == Segment ? (start distanceTo end) : float.infinity
	
	Vector2 intersectionWith: Line other
		let x1    = start.x,       y1 = start.y
		let x2    = end.x,         y2 = end.y
		let typeA = type
		let x3    = other.start.x, y3 = other.start.y
		let x4    = other.end.x,   y4 = other.end.y
		let typeB = other.type
		
		// Check if none of the lines are of length 0
		if (x1 == x2 && y1 == y2) || (x3 == x4 && y3 == y4) return Vector2.none

		// compute line params
		let denominator = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)
		if (denominator == 0) return Vector2.none // lines are parallel
		let ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator
		let ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator

		// is the intersection along the segments
		if (typeA >= Ray && ua < 0) || (typeA == Segment && ua > 1)
		|| (typeB >= Ray && ub < 0) || (typeB == Segment && ub > 1)
			return Vector2.none
			
		// Return a object with the x and y coordinates of the intersection
		return new Vector2(x1 + ua * (x2 - x1), y1 + ua * (y2 - y1))
		
	toString => "\{{start.x.format(maxFractionDigits:2)}, {start.y.format(maxFractionDigits:2)\} -> \{{end.x.format(maxFractionDigits:2)}, {end.y.format(maxFractionDigits:2)}\}"

immutable Rect
	importance:4 Vector2 position, size
	
	float left	=> position.x - size.x/2
	float right	=> position.x + size.x/2
	float top	=> position.y - size.y/2
	float bottom	=> position.y + size.y/2
	
	importance:4 bool includes: Vector2 position
		return this.position - this.size/2 <=  position < this.position + this.size/2
	
	importance:4 bool intersectsWith: Vector2 position
		                 Vector2 size
		return this.position - this.size/2 - size/2 <=  position < this.position + this.size/2 + size/2

global transient unit System
	global inline js void for: Grid<T> subject    // The grid to iterate over
		                       -> inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           IntVector2 pos,
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let i=0, _subject=subject.items, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; if(it) do(it, new IntVector2(i%subject.size.x, Math.floor(i/subject.size.x)), i)}
			
	global inline js void for: Grid<T> subject      // The grid to iterate over
		                       includeEmpty = false // Include items that are null
		                       -> inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           IntVector2 pos,
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _size=subject.size, y=0, _items=subject.items; y<_size.y; ++y) for(let x=0; x<_size.x; ++x) do(_items[y*_size.x + x], new IntVector2(x,y), i)

		