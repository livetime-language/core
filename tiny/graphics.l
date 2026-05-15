
		
// A texture that can be loaded into video memory
immutable Texture
	string file
	Vector2 size
	transient dynamic imageOrCanvas, context
	
	Texture
		if Platform.engineStarted and file
			open
			
	internal js bool ensureIsAvailable()
		if(!this.imageOrCanvas && this.file) {
			this.imageOrCanvas = _htmlImageCache[this.file]
		}
		return this.imageOrCanvas != null

	js bool isAvailable
		return this.imageOrCanvas != null
	
	internal js void open
		if(!window._htmlImageCache) _htmlImageCache = {}
		let image = _htmlImageCache[this.file]
		if(!image) {
			return new Promise((resolve, reject) => {
				image = new Image()
				image.onload = e => {
					this.imageOrCanvas = image
					window._htmlImageCache[this.file] = image
					this.size = new Vector2(image.width, image.height, null)
					resolve(this);
				}
				image.onerror = e => {
					console.log("Error loading image: ", this.file, e)
					reject(e)
				}
				image.src = Platform.getAbsoluteUrl(this.file)
			})
		} else {
			this.imageOrCanvas = image
			this.size = new Vector2(image.width, image.height, null)
			return this
		}


// A single frame of an animated image
internal immutable struct ImageFrame
	float x1, y1, x2, y2, w, h

// An image that can be drawn on the screen and can have several frames of animation
skipInit immutable Image
	string name
	string file
	Texture texture
	Vector2 size
	ImmutableList<ImageFrame> frames
		
enum HorizontalAlignment: Left, Center, Right
enum VerticalAlignment: Top, Middle, Bottom
	
BitmapFont
	IntVector2 charSize = {6,12}
	int charsPerRow = 16
	int startChar = 32

Color
	int red, green, blue
	string name

transient skipInit global unit graphics
	private dynamic canvas
	internal dynamic context
	IntVector2 sizeWithVideos = {384,288}, pixelSize = {384,288}
	// IntVector2 sizeWithVideos = {192,144}, pixelSize = {192, 144}
	Vector2 windowSize, activeSize, activeOffset
	float pixelRatio = 1

	int[] screen
	int[] tiles
	int[] font
	int[] palette
	// Color[] palette = {
	// 	{0, 0, 0	"black"}
	// 	{29, 43, 83	"dark-blue"}
	// 	{126, 37, 83	"dark-purple"}
	// 	{0, 135, 81	"dark-green"}
	// 	{171, 82, 54	"brown"}
	// 	{95, 87, 79	"dark-grey"}
	// 	{194, 195, 199	"light-grey"}
	// 	{255, 241, 232	"white"}
	// 	{255, 0, 77	"red"}
	// 	{255, 163, 0	"orange"}
	// 	{255, 236, 39	"yellow"}
	// 	{0, 228, 54	"green"}
	// 	{41, 173, 255	"blue"}
	// 	{131, 118, 156	"lavender"}
	// 	{255, 119, 168	"pink"}
	// 	{255, 204, 170	"light-peach"}
	// }
	
	dynamic pixelCanvas
	dynamic pixelContext
	dynamic pixelData
	bool showVideos = false

	async js void setup: Vector2 size
		graphics.pixelCanvas = document.createElement("canvas")
		graphics.pixelCanvas.width = graphics.pixelSize.x
		graphics.pixelCanvas.height = graphics.pixelSize.y
		graphics.pixelContext = graphics.pixelCanvas.getContext("2d")
		graphics.pixelData = graphics.pixelContext.getImageData(0, 0, graphics.pixelSize.x, graphics.pixelSize.y, {pixelFormat: "rgba-unorm8" })
		graphics.palette = new Uint8ClampedArray([
			0, 0, 0, 255,
			29, 43, 83, 255,
			126, 37, 83, 255,
			0, 135, 81, 255,
			171, 82, 54, 255,
			95, 87, 79, 255,
			194, 195, 199, 255,
			255, 241, 232, 255,
			255, 0, 77, 255,
			255, 163, 0, 255,
			255, 236, 39, 255,
			0, 228, 54, 255,
			41, 173, 255, 255,
			131, 118, 156, 255,
			255, 119, 168, 255,
			255, 204, 170, 255,
		]);

	internal js void onResize
		graphics.canvas = document.querySelector("canvas");
		if(!graphics.canvas) {
			graphics.canvas = document.createElement("canvas");
			document.body.append(graphics.canvas)
		}
		graphics.pixelRatio = window.devicePixelRatio;
		graphics.windowSize = new Vector2(window.innerWidth*graphics.pixelRatio, window.innerHeight*graphics.pixelRatio, null);
		graphics.canvas.style.width = window.innerWidth + "px";
		graphics.canvas.style.height = window.innerHeight + "px";
		graphics.canvas.width = graphics.windowSize.x;
		graphics.canvas.height = graphics.windowSize.y;
		graphics.canvas.imageSmoothingQuality = "high";
		graphics.context = graphics.canvas.getContext("2d");
		graphics.updateBaseMatrix()

	updateBaseMatrix
		Vector2 size = showVideos ? sizeWithVideos : pixelSize
		Vector2 ratio = {windowSize.x / size.x, windowSize.y / size.y}
		float scale
		if ratio.x < ratio.y then
			scale = ratio.x
			activeOffset = {0, (windowSize.y - size.y * scale) / 2}
		else
			scale = ratio.y;
			activeOffset = {(windowSize.x - size.x * scale) / 2, 0}
		activeSize = pixelSize * scale

	string getWhatIsOnScreen:
	Vector2 getReferencePos: float x, float y
		return {0,0}

	js int[] getPixelsOfImage: Image image
		let canvas = document.createElement("canvas")
		canvas.width = image.size.x
		canvas.height = image.size.y
		let context = canvas.getContext("2d")
		let w = image.frames[0].w
		let h = image.frames[0].h
		context.drawImage(image.texture.imageOrCanvas, image.frames[0].x1, image.frames[0].y1, image.frames[0].w, image.frames[0].h, 0, 0, w, h)
		return context.getImageData(0, 0, w, h).data

	openTiles
		int[] pixels = graphics.getPixelsOfImage(media.tiles)
		for (pixelSize.x*pixelSize.y).round
			int index = i*4
			int red = pixels[index]
			int green = pixels[index+1]
			int blue = pixels[index+2]
			int minDifference = 999999
			int closestColorIndex = 0
			for 16
				let difference = math.abs(palette[i*4] - red) + math.abs(palette[i*4+1] - green) + math.abs(palette[i*4+2] - blue)
				if difference < minDifference then
					minDifference = difference
					closestColorIndex = i
			tiles[i] = closestColorIndex
			// print "{i}: {red},{green},{blue} -> {closestColorIndex} ({palette[closestColorIndex].name}) difference: {minDifference}"

	openFont: Image image
		int[] pixels = graphics.getPixelsOfImage(image)
		int[] font
		for (pixelSize.x*pixelSize.y).round
			int index = i*4
			int red = pixels[index]
			int green = pixels[index+1]
			int blue = pixels[index+2]
			font[i] = red or green or blue ? 1 : 0
		return font		

	startFrame
		if Platform.fastForward then return
		if not tiles then graphics.openTiles()
		if not font then font = openFont(media.monogram)
		for (sizeWithVideos.x*sizeWithVideos.y).round
			screen[i] = 0

	finishFrame
		if Platform.fastForward then return
		graphics.context.imageSmoothingEnabled = false;
		int len = (graphics.pixelSize.x*graphics.pixelSize.y).round
		int sourceIndex, targetIndex
		let target = graphics.pixelData.data
		while sourceIndex < len
			int paletteIndex = screen[sourceIndex] shiftLeft 2
			target[targetIndex] = palette[paletteIndex]
			target[targetIndex+1] = palette[paletteIndex+1]
			target[targetIndex+2] = palette[paletteIndex+2]
			target[targetIndex+3] = 255
			sourceIndex++
			targetIndex += 4

			// Color color = palette[screen[i]]
			// graphics.pixelData.data[index] = color.red
			// graphics.pixelData.data[index+1] = color.green
			// graphics.pixelData.data[index+2] = color.blue
			// graphics.pixelData.data[index+3] = 255
		graphics.pixelContext.putImageData(graphics.pixelData, 0, 0)
		graphics.context.drawImage(graphics.pixelCanvas, graphics.activeOffset.x, graphics.activeOffset.y, graphics.activeSize.x, graphics.activeSize.y)

	isDrawingDebugInfo = false
	clearDebugInfo
	finishDrawingDebugInfo

	global drawTile: int tile, IntVector2 position
		if Platform.fastForward then return
		int stride = pixelSize.x
		int tileStride = 256
		int tileOffset = ((tile mod 32) + math.floor(tile / 32) * tileStride) * 8
		int screenOffset = position.x + position.y*stride
		for 8 as y
			for 8 as x
				let value = graphics.tiles[tileOffset + x]
				if value then screen[screenOffset + x] = value
			screenOffset += stride
			tileOffset += tileStride

	global drawText: string text, IntVector2 position, int color = 6
		if Platform.fastForward then return
		int stride = pixelSize.x
		int fontStride = 96
		for text.length
			int char = text.getCharCodeAt(i) - 32
			int tileOffset = (char mod 16) * 6 + math.floor(char / 16) * fontStride * 12
			int screenOffset = position.x + position.y*stride
			for 9 as y
				for 5 as x
					if font[tileOffset + x] then screen[screenOffset + x] = color
				screenOffset += stride
				tileOffset += fontStride
			position.x += 6
			if(position.x >= pixelSize.x) {
				position.x = 0
				position.y += 12
			}
gizmo
	clear
	init
	internal onTouch: InputType inputType, int id, Vector2 pixelPos, Vector2 referencePos, shift = false, alt = false, cmdOrCtrl = false	