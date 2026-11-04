Canvas
	dynamic element
	dynamic context
	float pixelRatio
	
	// Draw a rectangle
	drawRectangle: Vector2 pos
		           Vector2 size
		           Color color = black
		context.fillStyle = color.colorString
		context.fillRect(pos.x, pos.y, size.x, size.y)
		
	// Draw text
	drawText: implicit string text
		      Vector2 pos
		      float size = 30
		      Font font = null
		      Color color = black
		context.fillStyle = color.colorString
		string effectiveFont = font ? font.name : "OpenSans"
		context.font = "{size*pixelRatio}px {effectiveFont}"
		context.fillText(text, pos.x, pos.y)