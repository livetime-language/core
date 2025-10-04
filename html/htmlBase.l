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
	inline Dimension toAngle() Angle(this, radians)

	inline Angle operator °(float value) Angle(value, degrees)
	
	// One full rotation is 1
	inline Angle turns := Angle(this, turns)
	
	// One full rotation is 2π (about 6.2832)
	inline Angle radians := Angle(this, radians)
		
	// One full rotation is 360
	inline Angle degrees := Angle(this, degrees)
		
	// One full rotation is 400
	inline Angle gradians := Angle(this, gradians)
		
global skipInit unit math
	// Returns the arctangent of the quotient of the given values
	Angle getAngleForVector: Vector2 vector
		return Angle(math.atan2(vector.y, vector.x), radians)
		
	Vector2 getVectorForAngle: Angle angle      // The angle in radians (-pi/2: left, 0: up, pi/2: right, pi: down)
		                       float radius = 1.0
		return new Vector2(math.sin(angle.value)*radius, -math.cos(angle.value)*radius)

struct Angle
	float value          // The value in the specified unit
	Unit unit = radians // The unit of the value (turns, degrees, gradians, or radians)
	
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

class DateTime
	static inline js float now() Date.now()
