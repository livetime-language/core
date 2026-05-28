global transient unit System
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
