
struct float
	inline Dimension toDimension() Dimension(this, Html.defaultUnit)
		
	// Pixels
	inline Dimension px()          Dimension(this, pixels)
		
	// Makes the value relative to its parent's value
	inline Dimension percent()     Dimension(this, percent)
		
	// A fraction of the available space
	inline Dimension fr()          Dimension(this, fraction)
		
	// Font size of the parent (for font-size), font size of the element itself (for other properties)
	inline Dimension em()          Dimension(this, em)
		
	// Font size of the root element
	inline Dimension rem()         Dimension(this, rem)
		
	// Percentage of the viewport's width
	inline Dimension vw()          Dimension(this, viewportWidth)
		
	// Percentage of the viewport's height
	inline Dimension vh()          Dimension(this, viewportHeigh)
		
	// Percentage of the small viewport's width (without the address bar on mobile)
	inline Dimension svw()         Dimension(this, smallViewportWidth)
		
	// Percentage of the small viewport's height (without the address bar on mobile)
	inline Dimension svh()         Dimension(this, smallViewportHeight)
		
immutable priority low struct float
	inline Dimension toAngle() Angle(this, turns)

	inline Angle operator °(float value) Angle(value, degrees)
	
	// One full rotation is 1
	inline Angle turns := Angle(this, turns)
	
	// One full rotation is 2π (about 6.2832)
	inline Angle radians := Angle(this, radians)
		
	// One full rotation is 360
	inline Angle degrees := Angle(this, degrees)
		
	// One full rotation is 400
	inline Angle gradians := Angle(this, gradians)

js Array
priority low class List<T>
	inline js T[] sort: Angle(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
		this.sort(comparer)
		
	T[] orderBy: Angle(T a) expression // First order by this expression
		return this.sort(expression(a) - expression(b))

global skipInit priority low unit math
	// Returns the absolute value
	inline js Angle abs: Angle value // The angle to return the absolute value of
		Math.abs(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline js Angle ceil: Angle value // The angle to round up
		Math.ceil(value)
		
	// Returns the largest integer less than or equal to the given value
	inline js Angle floor: Angle value // The angle to round down
		Math.floor(value)
		
	// Returns the given value rounded to the nearest integer
	inline js Angle round: Angle value // The angle to round
		Math.round(value)
		
	// Returns the smallest of the given values
	inline js Angle min: Angle a // The first angle
		                 Angle b // The second angle
		Math.min(a, b)
		
	// Returns the largest of the given values
	inline js Angle max: Angle a // The first angle
		                 Angle b // The second angle
		Math.max(a, b)
	// The ratio of a circle's circumference to its diameter
	const float PI = 3.141592653589793
	
	// The ratio of a circle's radius to its diameter
	const float TwoPI = 6.283185307179586
	
	moveTowards: Angle value
		         Angle targetValue
		         Angle speed = {.1, turns}
		if targetValue > value: return math.min(value + speed, targetValue) else
		if targetValue < value: return math.max(value - speed, targetValue)
			
global skipInit unit math
	// Returns the arctangent of the quotient of the given values
	Angle getAngleForVector: Vector2 vector
		return math.atan2(vector.y, vector.x)
		
	Vector2 getVectorForAngle: Angle angle      // The angle in turns (0: straight up, 1: one full rotation clockwise)
		                       float radius = 1
		return new Vector2(math.sin(angle)*radius, -math.cos(angle)*radius)

struct Angle
	float value       // The value in the specified unit
	Unit unit = turns // The unit of the value (Turns, Degrees, Gradians, or Radians)
	
	float toFloat()   return this.value
	string toString() return "{this.value}{this.unit}"
	
	// Returns true if the angle is not zero
	inline js bool toBool := this.value
	
	Angle assign Angle other: value = other.value; unit = other.unit; return this
	Angle assign float other: value = other; return this

	Angle + Angle other:   return {value + other.value, unit}
	Angle - Angle other:   return {value - other.value, unit}
	Angle * Angle other:   return {value * other.value, unit}
	Angle / Angle other:   return {value / other.value, unit}
	
	Angle + float other:   return {value + other, unit}
	Angle - float other:   return {value - other, unit}
	Angle * float other:   return {value * other, unit}
	Angle / float other:   return {value / other, unit}

	Angle += Angle other:  value += other.value; return this
	Angle -= Angle other:  value -= other.value; return this
		
	Angle += float other:  value += other; return this
	Angle -= float other:  value -= other; return this
		
	bool >  Angle other:   return value >  other.value
	bool >= Angle other:   return value >= other.value
	bool <  Angle other:   return value <  other.value
	bool <= Angle other:   return value <= other.value
	
	Angle operator - (Angle a) Angle(-a.value, a.unit)

