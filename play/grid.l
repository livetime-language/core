	
class Grid<T>
	// IntVector2, NOT Vector2: the declared type drives the generated deserializer's
	// fresh-object fallback (new IntVector2), while serialization dispatches on the actual
	// object - and every Grid construction produces an IntVector2 size. With Vector2 declared
	// here, a rewind that had to fresh-create a Grid (its live object was replaced since the
	// pinned snapshot was serialized, e.g. by a replayed restart's unit init) read the size as
	// 2 float64s where 2 int32s were written - the 8-byte misalignment turned the neighboring
	// fields into NaN/null garbage that was then serialized into checksummed snapshots
	// (lifecycle seed 285888347). The 3D engine's Grid always declared IntVector2
	IntVector2 size
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
		for(let i=0, _subject=this.items, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; if(it) do(it, new IntVector2(i%this.size.x, Math.floor(i/this.size.x)), i)}
			
	inline js void each: includeEmpty = false // Include items that are null
		                 inline -> void(
		                     T it,      // The current item of the list we are iterating over with the for-loop
		                     Vector2 pos,
		                     int i      // The index of the current item of the list we are iterating over with the for-loop
		                 ) do           // Do this for each item in a list
		for(let _size=this.size, y=0, _items=this.items; y<_size.y; ++y) for(let x=0; x<_size.x; ++x) do(_items[y*_size.x + x], new Vector2(x,y), i)}

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
		for(let i=0, _subject=subject.items, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; if(it) do(it, new Vector2(i%subject.size.x, Math.floor(i/subject.size.x)), i)}
			
	global inline js void for: Grid<T> subject      // The grid to iterate over
		                       includeEmpty = false // Include items that are null
		                       -> inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           Vector2 pos,
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _size=subject.size, y=0, _items=subject.items; y<_size.y; ++y) for(let x=0; x<_size.x; ++x) do(_items[y*_size.x + x], new IntVector2(x,y), i)
		
struct Vector2
	serialize: Buffer buffer
		buffer.writeFloat64(x)
		buffer.writeFloat64(y)
		
	deserialize: Buffer buffer
		x = buffer.readFloat64
		y = buffer.readFloat64
	
