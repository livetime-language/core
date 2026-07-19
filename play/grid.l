	
class Grid<T>
	Vector2 size
	T[] items
	transient void(T item, Vector2 pos)[string] itemForCharacter = null
	
	Grid
		for size.x * size.y
			items.add null
	
	get: Vector2 position // The vector to get the value from
		return 0.0 <= position.x < size.x and 0.0 <= position.y < size.y ? items[floor(position.y)*size.x + position.x] : null
	
	get: float x // The column to get the value from
		 float y // The row to get the value from
		return 0.0 <= x < size.x and 0.0 <= y < size.y ? items[floor(y)*size.x + x] : null
	
	get: int x // The column to get the value from
		 int y // The row to get the value from
		return 0 <= x < size.x and 0 <= y < size.y ? items[y*size.x + x] : null
	
	T set: Vector2 position // The grid position of the value to set
		   T value             // The value to set
		return items[floor(position.y)*size.x + position.x] = value

	T set: float x   // The column of the value to set
		   float y   // The row of the value to set
		 T value // The value to set
		return items[floor(y)*size.x + x] = value
	
	T set: int x   // The column of the value to set
		   int y   // The row of the value to set
		 T value // The value to set
		return items[y*size.x + x] = value
	
	map: string character
		 stored void(T item, Vector2 pos) to
		if not itemForCharacter then itemForCharacter = {}
		itemForCharacter.set(character, to)

	create: string[] strings
		for strings as line, y
			for line as char, x
				let itemFunction = itemForCharacter.get(char)
					itemFunction(items[y*size.x + x], {x, y})
		
	// Do something for each item in the grid
	inline js void each: inline -> void(
		                     T it,      // The current item of the list we are iterating over with the for-loop
		                     Vector2 pos,
		                     int i      // The index of the current item of the list we are iterating over with the for-loop
		                 ) do           // Do this for each item in a list
		for(let _i=0, _subject=this.items, _len=_subject.length; _i<_len; ++_i) { let it = _subject[_i]; if(it) do(it, new IntVector2(_i%this.size.x, Math.floor(_i/this.size.x)), _i)}
			
	inline js void each: includeEmpty = false // Include items that are null
		                 inline -> void(
		                     T it,      // The current item of the list we are iterating over with the for-loop
		                     Vector2 pos,
		                     int i      // The index of the current item of the list we are iterating over with the for-loop
		                 ) do           // Do this for each item in a list
		for(let _size=this.size, _y=0, _items=this.items; _y<_size.y; ++_y) for(let _x=0; _x<_size.x; ++_x) do(_items[_y*_size.x + _x], new Vector2(_x,_y), _y*_size.x + _x)

	// The amount of items in the grid	
	importance:4 inline int length() this.items.length

	// Return a list that includes the selected field or expression for each item
	importance:4 inline js TValue[] select: TValue(T it) selector
		this.items.map(selector)
		
	// Get the selected field or expression for each item and flattens the result
	inline js TValue[] flatten: TValue[](T it) selector
		this.items.flatMap(selector)
		
	// Returns true if the given condition is true for all items in the list
	inline js bool all
		this.items.every(a => a)
		
	// Returns true if the given condition is true for any item in the list
	inline js bool any
		this.items.some(a => a)
		
	// Returns true if the given condition is true for any item in the list
	importance:4 inline js bool any: bool(T a) predicate // The condition to check
		this.items.some(predicate)
		
	importance:4 inline js T[] filter: bool(T a) predicate // The condition to check
		this.items.filter(predicate)
		
	int count: bool(T a) predicate // The condition to check
		int count = 0
		for items
			if predicate(.)
				count++
		return count
		
	// Returns true if the given condition is true for all items in the list
	importance:4 inline js bool all: bool(T a) predicate // The condition to check
		this.items.every(predicate)
		
	importance:4 bool isValid: Vector2 pos
		return 0.0 <= pos.x < size.x and 0.0 <= pos.y < size.y

	importance:4 withMin: float(T a) selector
		               float threshold = float.maxValue
		float resultValue = threshold
		T resultItem
		for items
			let value = selector(.)
			if value < resultValue
				resultValue = value
				resultItem = .
		return resultValue != threshold ? resultItem : null

	insertRows: int count = 1, int y = -1
		if y == -1 then y = floor(size.y)
		size.y += count
		let baseIndex = y * size.x
		for size.x * count
			items.insert null index:floor(baseIndex + .)
	
	insertColumns: int count = 1, int x = -1
		if x == -1 then x = floor(size.x)
		size.x += count
		for size.y as y
			let rowIndex = y * size.x
			for count
				items.insert null index:floor(rowIndex + x + .)
	
global transient skipInit unit system
	global inline js void for: Grid<T> subject    // The grid to iterate over
		                       -> inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           Vector2 pos,
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _i=0, _subject=subject.items, _len=_subject.length; _i<_len; ++_i) { let it = _subject[_i]; if(it) do(it, new Vector2(_i%subject.size.x, Math.floor(_i/subject.size.x)), _i)}
			
	global inline js void for: Grid<T> subject      // The grid to iterate over
		                       includeEmpty = false // Include items that are null
		                       -> inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           Vector2 pos,
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _size=subject.size, _y=0, _items=subject.items; _y<_size.y; ++_y) for(let _x=0; _x<_size.x; ++_x) do(_items[_y*_size.x + _x], new IntVector2(_x,_y), _y*_size.x + _x)
		
struct Vector2
	serialize: Buffer buffer
		buffer.writeFloat64(x)
		buffer.writeFloat64(y)
		
	deserialize: Buffer buffer
		x = buffer.readFloat64
		y = buffer.readFloat64
	
