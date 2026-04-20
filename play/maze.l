enum MazeWallDirection: Horizontal, Vertical

priority:high class MazeWall
	int x, y
	MazeWallDirection dir
	int doorId = -1
	int stepsToOtherSide
	int cellsOnBothSidesDifference
	bool[,] areaOnSideA, areaOnSideB

unit maze
	IntVector2 size
	MazeWall[,] horizontalWalls
	MazeWall[,] verticalWalls	
	MazeWall[] walls
	
	create: IntVector2 size
		this.size = size
		walls.clear
		
		// Init walls
		verticalWalls = {size:{size.x + 1, size.y}}
		horizontalWalls = {size:{size.x, size.y + 1}}
		isVisited = {size}
				
		// Create outside walls
		for size.y as y
			walls.add verticalWalls[0,y] = {x:0, y, dir:Vertical}
			walls.add verticalWalls[size.x, y] = {x:size.x, y, dir:Vertical}
				
		for size.x as x
			walls.add horizontalWalls[x, 0] = {x, y:0, dir:Horizontal}
			walls.add horizontalWalls[x, size.y] = {x, y:size.y, dir:Horizontal}
		
		MazeWall[] potentialWalls
		// Vertical
		for 1 to size.x as x
			for size.y as y
				potentialWalls.add {x,y,dir:Vertical}
		// Horizontal
		for size.x as x
			for 1 to size.y as y
				potentialWalls.add {x,y,dir:Horizontal}
				
		// Create perfect maze
		potentialWalls.shuffle
		for potentialWalls as p
			if p.dir == Horizontal	then horizontalWalls[p.x, p.y] = p
			if p.dir == Vertical	then verticalWalls[p.x, p.y] = p
			if !isValid
				if p.dir == Horizontal	then horizontalWalls[p.x, p.y] = null
				if p.dir == Vertical	then verticalWalls[p.x, p.y] = null
			else
				walls.add p
		
		// Remove walls with longest path other side
		// for numberOfOpenings
		// 	for walls as w
		// 		AStarNode[] result
		// 		if w.dir == Horizontal and w.y > 0 and w.y < size.y-1
		// 			result = algorithms.findPath startPos:{w.x, w.y-1}, endPos:{w.x, w.y}, size, getNeighbors(grid, x, y), heuristic: a manhattanDistanceTo b
		// 		else
		// 		if w.dir == Vertical and w.x > 0 and w.x < size.x-1
		// 			result = algorithms.findPath startPos:{w.x-1, w.y}, endPos:{w.x, w.y}, size, getNeighbors(grid, x, y), heuristic: a manhattanDistanceTo b
		// 		w.stepsToOtherSide = result.length
		// 	walls.sort a.stepsToOtherSide - b.stepsToOtherSide		
		// 	MazeWall w = walls.pop
		// 	if w.dir == Horizontal	then horizontalWalls[w.x, w.y] = null
		// 	if w.dir == Vertical	then verticalWalls  [w.x, w.y] = null
				
	getNeighbors: AStarNode[,] grid, int x, int y
		AStarNode[] neighbors = []
		if not maze.verticalWalls  [x  , y  ] then neighbors.add grid[x-1, y  ]
		if not maze.verticalWalls  [x+1, y  ] then neighbors.add grid[x+1, y  ]
		if not maze.horizontalWalls[x  , y  ] then neighbors.add grid[x  , y-1]
		if not maze.horizontalWalls[x  , y+1] then neighbors.add grid[x  , y+1]
		return neighbors
	
	private bool[,] isVisited
	private int visitedCount
	
	isValid
		for size isVisited[.] = false
		visitedCount = 0
		visit
		return visitedCount == size.x * size.y

	getReachableCells: int x, int y
		isVisited = {size}
		for size isVisited[.] = false
		visitedCount = 0
		visit x, y
		return visitedCount

	private void visit: x = 0, y = 0
		isVisited[x, y] = true
		visitedCount++
		if not verticalWalls  [x+1, y  ] and not isVisited[x+1, y  ] then visit x+1, y	// Right
		if not verticalWalls  [x  , y  ] and not isVisited[x-1, y  ] then visit x-1, y	// Left
		if not horizontalWalls[x  , y+1] and not isVisited[x  , y+1] then visit x,   y+1	// Down
		if not horizontalWalls[x  , y  ] and not isVisited[x  , y-1] then visit x,   y-1	// Up
			
	getWall: IntVector2 from, IntVector2 to
		if from.x == to.x
			if (0 <= from.x < size.x) and (0 <= from.y < size.y+1)
				if to.y > from.y then return horizontalWalls[from.x, from.y+1]
				if to.y < from.y then return horizontalWalls[from.x, from.y  ]
		if from.y == to.y
			if (0 <= from.x < size.x+1) and (0 <= from.y < size.y)
				if to.x > from.x then return verticalWalls[from.x+1, from.y]
				if to.x < from.x then return verticalWalls[from.x  , from.y]
		return null
				
	getWallCount: IntVector2 from
		int count = 0
		if horizontalWalls[from.x  , from.y+1]	then count++
		if horizontalWalls[from.x  , from.y  ]	then count++
		if verticalWalls  [from.x+1, from.y  ]	then count++
		if verticalWalls  [from.x  , from.y  ]	then count++
		return count

	IntVector2[] getCellsNextToWall: MazeWall wall
		if wall.dir == Horizontal then	return [{wall.x, wall.y-1}, {wall.x, wall.y}]
		else	return [{wall.x-1, wall.y}, {wall.x, wall.y}]

	MazeWall[] potentialWalls

	placeDoor: int doorId, bool[,] area = null
		potentialWalls.clear
		for 1 to horizontalWalls.size.x-1 as x
			for 1 to horizontalWalls.size.y-1 as y
				if not horizontalWalls[x, y]
				and (area == null or (area[x, y] and area[x, y-1]))
					MazeWall newWall = {x, y, dir:Horizontal, doorId}
					horizontalWalls[x,y] = newWall
					int a = getReachableCells x, y-1;	newWall.areaOnSideA = isVisited
					int b = getReachableCells x, y;	newWall.areaOnSideB = isVisited
					newWall.cellsOnBothSidesDifference = math.abs a - b
					horizontalWalls[x,y] = null
					potentialWalls.add newWall

		for 1 to verticalWalls.size.x-1 as x
			for 1 to verticalWalls.size.y-1 as y
				if not verticalWalls[x, y]
				and (area == null or (area[x, y] and area[x-1, y]))
					MazeWall newWall = {x, y, dir:Vertical, doorId}
					verticalWalls[x,y] = newWall
					int a = getReachableCells x-1, y;	newWall.areaOnSideA = isVisited
					int b = getReachableCells x,   y;	newWall.areaOnSideB = isVisited
					newWall.cellsOnBothSidesDifference = math.abs a - b
					verticalWalls[x,y] = null
					potentialWalls.add newWall

		let wall = potentialWalls.withMin.cellsOnBothSidesDifference
		if wall.dir == Horizontal then	horizontalWalls[wall.x, wall.y] = wall
		else	verticalWalls[wall.x, wall.y] = wall
		return wall

	createOpening: int minStepsToOtherSide = 5, bool[,] area = null
		potentialWalls.clear
		for 1 to horizontalWalls.size.x-1 as x
			for 1 to horizontalWalls.size.y-1 as y
				let wall = horizontalWalls[x, y]
				if wall and (area == null or (area[x, y] and area[x, y-1]))
					let result = algorithms.findPath startPos:{x, y-1}, endPos:{x, y}, size, getNeighbors(grid, x, y), heuristic: a manhattanDistanceTo b
					wall.stepsToOtherSide = result.length
					potentialWalls.add wall

		for 1 to verticalWalls.size.x-1 as x
			for 1 to verticalWalls.size.y-1 as y
				let wall = verticalWalls[x, y]
				if wall and (area == null or (area[x, y] and area[x-1, y]))
					let result = algorithms.findPath startPos:{x-1, y}, endPos:{x, y}, size, getNeighbors(grid, x, y), heuristic: a manhattanDistanceTo b
					wall.stepsToOtherSide = result.length
					potentialWalls.add wall

		let wall = potentialWalls.withMax.stepsToOtherSide
		if wall and wall.stepsToOtherSide >= minStepsToOtherSide
			if wall.dir == Horizontal then	horizontalWalls[wall.x, wall.y] = null
			else	verticalWalls[wall.x, wall.y] = null
		return wall
