enum WallDirection: Horizontal, Vertical

priority:high class Wall
	int x, y
	WallDirection dir
	int stepsToOtherSide

unit maze
	IntVector2 size = {12,8}	
	Wall[][] horizontalWalls
	Wall[][] verticalWalls	
	Wall[] walls
	
	create
		walls.clear
		colliders.clear
		
		// Init walls
		for size.x + 1 as x
			verticalWalls[x] = []
			for size.y as y
				verticalWalls[x][y] = null
		for size.x as x
			horizontalWalls[x] = []
			for size.y + 1 as y
				horizontalWalls[x][y] = null
				
		createMaze
				
	createMaze: int openingsCount = 3
		// Create outside walls
		for size.y as y
			walls.add verticalWalls[0][y] = {x:0, y, dir:Vertical}
			walls.add verticalWalls[size.x][y] = {x:size.x, y, dir:Vertical}
				
		for size.x as x
			walls.add horizontalWalls[x][0] = {x, y:0, dir:Horizontal}
			walls.add horizontalWalls[x][size.y] = {x, y:size.y, dir:Horizontal}
		
		Wall[] potentialWalls
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
			if p.dir == Horizontal	then horizontalWalls[p.x][p.y] = p
			if p.dir == Vertical	then verticalWalls[p.x][p.y] = p
			if !isValid
				if p.dir == Horizontal	then horizontalWalls[p.x][p.y] = null
				if p.dir == Vertical	then verticalWalls[p.x][p.y] = null
			else
				walls.add p
		
		// Remove walls with longest path other side
		for openingsCount
			for walls as w
				AStarNode[] result
				if w.dir == Horizontal and w.y > 0 and w.y < size.y-1
					result = algorithms.findPath startPos:{w.x, w.y-1}, endPos:{w.x, w.y}, size, getNeighbors(grid, x, y), heuristic: a manhattanDistanceTo b
				else
				if w.dir == Vertical and w.x > 0 and w.x < size.x-1
					result = algorithms.findPath startPos:{w.x-1, w.y}, endPos:{w.x, w.y}, size, getNeighbors(grid, x, y), heuristic: a manhattanDistanceTo b
				w.stepsToOtherSide = result.length
			walls.sort a.stepsToOtherSide - b.stepsToOtherSide
			
			Wall w = walls.pop
			if w.dir == Horizontal	then horizontalWalls[w.x][w.y] = null
			if w.dir == Vertical	then verticalWalls  [w.x][w.y] = null
				
	getNeighbors: AStarNode[][] grid, int x, int y
		AStarNode[] neighbors = []
		if not maze.verticalWalls  [x  ][y  ] then neighbors.add grid[x-1][y  ]
		if not maze.verticalWalls  [x+1][y  ] then neighbors.add grid[x+1][y  ]
		if not maze.horizontalWalls[x  ][y  ] then neighbors.add grid[x  ][y-1]
		if not maze.horizontalWalls[x  ][y+1] then neighbors.add grid[x  ][y+1]
		return neighbors
	
	private bool[][] visited
	private int visitedCount
	
	isValid
		for size.x as x
			visited[x] = []
			for size.y as y
				visited[x][y] = false
		visitedCount = 0
		visit
		return visitedCount == size.x * size.y
		
	private void visit: x = 0, y = 0
		visited[x][y] = true
		visitedCount++
		if not verticalWalls  [x+1][y  ] and not visited[x+1][y  ] then visit x+1, y	// Right
		if not verticalWalls  [x  ][y  ] and not visited[x-1][y  ] then visit x-1, y	// Left
		if not horizontalWalls[x  ][y+1] and not visited[x  ][y+1] then visit x,   y+1	// Down
		if not horizontalWalls[x  ][y  ] and not visited[x  ][y-1] then visit x,   y-1	// Up
			
	getWall: IntVector2 from, IntVector2 to
		if from.x == to.x
			if (0 <= from.x < size.x) and (0 <= from.y < size.y+1)
				if to.y > from.y then return horizontalWalls[from.x][from.y+1]
				if to.y < from.y then return horizontalWalls[from.x][from.y  ]
		if from.y == to.y
			if (0 <= from.x < size.x+1) and (0 <= from.y < size.y)
				if to.x > from.x then return verticalWalls[from.x+1][from.y]
				if to.x < from.x then return verticalWalls[from.x  ][from.y]
		return null
				
	getWallCount: IntVector2 from
		int count = 0
		if horizontalWalls[from.x  ][from.y+1]	then count++
		if horizontalWalls[from.x  ][from.y  ]	then count++
		if verticalWalls  [from.x+1][from.y  ]	then count++
		if verticalWalls  [from.x  ][from.y  ]	then count++
		return count