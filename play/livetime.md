---
description: LiveTime Programming Language Examples and Standard Library
globs: *.l
alwaysApply: true
---
# We use the LiveTime programming language.
All methods and static class names are lowercase (for example: math.sin). Place all the code in the file "src/app.l".

# Angles
All angle values in LiveTime are in turns, where .5 is half a rotation and 1 is a full rotation. For example, math.sin(.25) returns 1.

# Avoid unwanted overlaps
Before you start adding anything on the screen, review what's currently on screen and make sure nothing you draw overlaps with something it shouldn't overlap with.

{currentlyOnScreen}

# Example game in the LiveTime programming language
```
enum Phase {
	Playing,
	GameOver
}
static class app {
	const IntVector2 gridSize = new IntVector2(8,8);
	const Vector2 cellSize = new Vector2(128,128);
	const Vector2 cellOffset = cellSize * (gridSize - {1,1}) / -2 + new Vector2(256,0);

	Player currentPlayer;
	List<Piece> pieces = new List<Piece>();
	Phase phase = Phase.Playing;

	// Called when the app starts
	static void start() {
		for(int x = 0; x < gridSize.x; x++) {
			for(int y = 0; y < 3; y++) {
				if((x+y)%2 == 0) {
					pieces.add(new Piece(owner:players[0], gridPos: new IntVector2(x,y)));
					pieces.add(new Piece(owner:players[1], gridPos: new IntVector2(gridSize.x-x-1,gridSize.y-y-1)));
				}
			}
		}
		currentPlayer = players[0];
		phase = Phase.Playing;
	}
	static void nextPlayer() {
		currentPlayer = players[(currentPlayer.index+1)%players.length];
		if(!pieces.any(a => a.owner == currentPlayer)) {
			phase = Phase.GameOver;
		}
	}
	// Called every frame
	static void tick() {
		// In LiveTime, the size of the screen is 1920x1080 with {0, 0} in the center
		// The top-left corner is {-960, -540}, the bottom-right corner is {960, 540}
		// The background is black by default
		for(int x = 0; x < gridSize.x; x++) {
			for(int y = 0; y < gridSize.y; y++) {
				Image image = (x+y)%2 == 0 ? DarkCell : LightCell;
				drawImage(image, getPixelPos(new IntVector2(x,y)), layer:0);
			}
		}
		foreach(piece in pieces) {
			piece.tick();
		}
		foreach(player in players) {
			player.tick();
		}
		if(phase == Phase.GameOver) {
			drawText("Game Over", position:new Vector2(256,0), size:180, color:Black);
		}
	}
	// Called when the player touch.by touches or clicks at touch.position
	static void onTouchDown(Touch touch) {
		if(touch.by != currentPlayer || phase == Phase.GameOver) return;
		var piece = pieces.withMin(a => a.pixelPos.distanceTo(touch.position));
		if(piece?.owner == currentPlayer) piece.onTouchDown(touch);
	}
	// Called when the player touch.by moves their finger or mouse with touch.id to touch.position
	static void onTouchMove(Touch touch) {
		if(touch.by != currentPlayer || phase == Phase.GameOver) return;
		if(!touch.isDown) {
			touch.by.calculatePossibleMoves(getGridPos(touch.position));
		} else {
			var piece = pieces.find(a => a.draggingTouch == touch);
			if(piece) piece.onTouchMove(touch);
		}
	}
	// Called when the player touch.by lifts their finger or mouse button with touch.id at touch.position
	static void onTouchUp(Touch touch) {
		if(touch.by != currentPlayer || phase == Phase.GameOver) return;
		var piece = pieces.find(a => a.draggingTouch == touch);
		if(piece) piece.onTouchUp(touch);
	}
	static Piece getPieceAt(IntVector2 gridPos) {
		return app.pieces.find(a => a.gridPos == gridPos);
	}
	static bool isValidGridPos(IntVector2 gridPos) {
		return gridPos.x >= 0 && gridPos.x < gridSize.x && gridPos.y >= 0 && gridPos.y < gridSize.y;
	}
	static IntVector2 getGridPos(Vector2 pos) {
		let gridPos = ((pos - cellOffset) / cellSize).round();
		if(!isValidGridPos(gridPos)) return IntVector2.None;
		return gridPos;
	}
	static Vector2 getPixelPos(IntVector2 gridPos) {
		return gridPos * cellSize + cellOffset;
	}
}

class Player {
	List<IntVector2> possibleMoves = new List<IntVector2>();
	List<Piece> possibleCaptures = new List<Piece>();
	int moveDirection = index == 0 ? 1 : -1;

	void tick() {
		// Draw player video feed on the left side next to the board
		float radius = 255
		Color outlineColor = app.currentPlayer == this ? color : darkColor
		Vector2 videoPos = new Vector2(-560, -265*moveDirection)
		drawCircle(position:videoPos, size:radius*2, outlineColor:outlineColor, outlineWidth:12)
		drawVideo(player:this, position:videoPos, size:radius*2-75, shape:Circle)

		// Draw score
		Vector2 scorePos = videoPos + math.getVectorForAngle(-45°)*radius
		drawCircle(position:scorePos, color:Black, outlineColor:outlineColor, size:60)
		drawText(score, position:scorePos, size:31)

		foreach(move in possibleMoves) {
			drawImage(Target, position:app.getPixelPos(move), layer:0);
		}
		foreach(capture in possibleCaptures) {
			drawImage(Capture, position:capture.pixelPos, layer:2);
		}
	}
	void calculatePossibleMoves(IntVector2 gridPos) {
		possibleMoves.clear();
		possibleCaptures.clear();
		if(gridPos == IntVector2.None || app.getPieceAt(gridPos)?.owner != this) return;
		var directions = [new IntVector2(1, moveDirection), new IntVector2(-1, moveDirection)];
		foreach(dir in directions) {
			var pos = gridPos;
			var oneStep = pos + dir;
			if(!app.isValidGridPos(oneStep)) continue;
			var twoStep = pos + dir*2;
			var piece = app.getPieceAt(oneStep);
			if(piece == null) {
				pos = oneStep;
				possibleMoves.add(oneStep);
			} else if(piece.owner != this && app.getPieceAt(twoStep) == null) {
				do {
					pos = twoStep;
					oneStep = pos + dir;
					twoStep = pos + dir*2;
					possibleCaptures.add(piece);
					piece = app.getPieceAt(oneStep);
				} while: (piece && piece.owner != this && app.isValidGridPos(twoStep) && app.getPieceAt(twoStep) == null);
				possibleMoves.add(pos);
			}
		}
	}
	void finishMove() {
		foreach(capture in possibleCaptures) {
			app.pieces.remove(capture);
		}
		possibleMoves.clear();
		possibleCaptures.clear();
		app.nextPlayer();
	}
}

class Piece {
	IntVector2 gridPos;
	Vector2 pixelPos;
	Player owner;
	Touch draggingTouch;

	Piece(Player owner, IntVector2 gridPos) {
		this.owner = owner;
		this.gridPos = gridPos;
		this.pixelPos = app.getPixelPos(gridPos);
	}
	void tick() {
		Image image = owner.index == 0 ? WhiteCheckersPiece : BlackCheckersPiece;
		drawImage(image, pixelPos, layer:1);
	}
	void onTouchDown(Touch touch) {
		draggingTouch = touch;
		owner.calculatePossibleMoves(gridPos);
	}
	void onTouchMove(Touch touch) {
		pixelPos = touch.position;
	}
	void onTouchUp(Touch touch) {
		draggingTouch = null;
		var potentialGridPos = app.getGridPos(pixelPos);
		var isPossibleMove = owner.possibleMoves.find(a => a == potentialGridPos);
		if(isPossibleMove) gridPos = potentialGridPos;
		pixelPos = app.getPixelPos(gridPos);
		if(isPossibleMove) owner.finishMove();
	}
}	
```

# Check errors and fix all problems
Always look at the linter errors and fix all problems! Don't stop until all errors are fixed!

# MOST IMPORTANTLY: Always Run, Test and Debug
To test and verify the app, add debug logs using print statements for everything that is happening in the app. For example, print debug logs for all user actions like clicks. Print the position of all moving objects during every frame of an animation to make sure all animations are correct and smooth.

When you are done, use the "Run and Test" MCP server to thoroughly test all possible cases. Make sure you test all the code and all edge cases. Thoroughly review the debug logs and what is currently on screen.

Fix all errors and bugs you encounter.
