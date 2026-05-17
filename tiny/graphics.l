
		
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
	string name
	IntVector2 charSize
	IntVector2 gridSize
	int charsPerRow
	int startChar
	int[] pixels

Color
	int red, green, blue
	string name

Result
	int index
	int difference

Screen
	Vector2 size
	Vector2 activeSize, activeOffset
	dynamic canvas, context
	dynamic pixelData
	int[] pixels
	int[] palette
	bool smoothing
	

	async js void setup
		this.canvas = document.createElement("canvas")
		this.canvas.width = this.size.x
		this.canvas.height = this.size.y
		this.context = this.canvas.getContext("2d")
		this.pixelData = this.context.getImageData(0, 0, this.size.x, this.size.y, {pixelFormat: "rgba-unorm8" })
		this.palette = new Uint8ClampedArray([
			// Pico-8
			0, 0, 0, 255,	// black	0		#000000
			29, 43, 83, 255,	// dark-blue	1		#1D2B53
			126, 37, 83, 255,	// dark-purple	2		#7E2553
			0, 135, 81, 255,	// dark-green	3		#008751
			171, 82, 54, 255,	// brown	4		#AB5236
			95, 87, 79, 255,	// dark-grey	5		#5F574F
			194, 195, 199, 255,	// light-grey	6		#C2C3C7
			255, 241, 232, 255,	// white	7		#FFF1E8
			255, 0, 77, 255,	// red	8		#FF004D
			255, 163, 0, 255,	// orange	9		#FFA300
			255, 236, 39, 255,	// yellow	10		#FFEC27
			0, 228, 54, 255,	// green	11		#00E436
			41, 173, 255, 255,	// blue	12		#29ADFF
			131, 118, 156, 255,	// lavender	13		#83769C
			255, 119, 168, 255,	// pink	14		#FF77A8
			255, 204, 170, 255,	// light-peach	15		#FFCCAA

			// Pico-8 Extended
			41,24,20, 255,	// brownish-black	128 / -16		#291814
			17,29,53, 255,	// darker-blue	129 / -15		#111D35
			66,33,54, 255,	// darker-purple	130 / -14		#422136
			18,83,89, 255,	// blue-green	131 / -13		#125359
			116,47,41, 255,	// dark-brown	132 / -12		#742F29
			73,51,59, 255,	// darker-grey	133 / -11		#49333B
			162,136,121, 255,	// medium-grey	134 / -10		#A28879
			243,239,125, 255,	// light-yellow	135 / -9		#F3EF7D
			190,18,80, 255,	// dark-red	136 / -8		#BE1250
			255,108,36, 255,	// dark-orange	137 / -7		#FF6C24
			168,231,46, 255,	// lime-green	138 / -6		#A8E72E
			0,181,67, 255,	// medium-green	139 / -5		#00B543
			6,90,181, 255,	// true-blue	140 / -4		#065AB5
			117,70,101, 255,	// mauve	141 / -3		#754665
			255,110,89, 255,	// dark-peach	142 / -2		#FF6E59
			255,157,129, 255,	// peach	143 / -1		#FF9D81

			// Commodore 64
			0, 0, 0, 255,	// black	0	#000000
			255, 255, 255, 255,	// white	1	#FFFFFF
			146, 74, 64, 255,	// red	2	#880000
			132, 197, 204, 255,	// cyan	3	#AAFFEE
			147, 81, 182, 255,	// purple	4	#CC44CC
			114, 177, 75, 255,	// green	5	#00CC55
			72, 58, 170, 255,	// blue	6	#0000AA
			213, 223, 124, 255,	// yellow	7	#EEEE77
			153, 105, 45, 255,	// orange	8	#DD8855
			103, 82, 0, 255,	// brown	9	#664400
			193, 129, 120, 255,	// pink	10	#FF7777
			96, 96, 96, 255,	// dark grey	11	#333333
			138, 138, 138, 255,	// grey	12	#777777
			179, 236, 145, 255,	// light green	13	#AAFF66
			134, 122, 222, 255,	// light blue	14	#0088FF
			179, 179, 179, 255,	// light grey	15	#BBBBBB

			// NES
			124,124,124,255,	// 0	#7C7C7C
			0,0,252,255,	// 1	#0000FC
			0,0,188,255,	// 2	#0000BC
			68,40,188,255,	// 3	#4428BC
			148,0,132,255,	// 4	#940084
			168,0,32,255,	// 5	#A80020
			168,16,0,255,	// 6	#A81000
			136,20,0,255,	// 7	#881400
			80,48,0,255,	// 8	#503000
			0,120,0,255,	// 9	#007800
			0,104,0,255,	// 10	#006800
			0,88,0,255,	// 11	#005800
			0,64,88,255,	// 12	#004058
			0,0,0,255,	// 13	#000000
			// 0,0,0,255,	// 14	#000000 x
			// 0,0,0,255,	// 15	#000000 x
			// 188,188,188,255,	// 16	#BCBCBC x
			0,120,248,255,	// 17	#0078F8
			0,88,248,255,	// 18	#0058F8
			104,68,252,255,	// 19	#6844FC
			216,0,204,255,	// 20	#D800CC
			228,0,88,255,	// 21	#DC0058
			248,56,0,255,	// 22	#F83800
			228,92,16,255,	// 23	#DC5C10
			172,124,0,255,	// 24	#AC7C00
			0,184,0,255,	// 25	#00B800
			0,168,0,255,	// 26	#00A800
			// 0,168,68,255,	// 27	#00A844 x
			0,136,136,255,	// 28	#008888
			// 0,0,0,255,	// 29	#000000 x
			// 0,0,0,255,	// 30	#000000 x
			// 0,0,0,255,	// 31	#000000 x
			// 248,248,248,255,	// 32	#F8F8F8 x
			60,188,252,255,	// 33	#3CB8FC
			104,136,252,255,	// 34	#6888FC
			152,120,248,255,	// 35	#9878F8
			248,120,248,255,	// 36	#F878F8
			248,88,152,255,	// 37	#F85898
			248,120,88,255,	// 38	#F87858
			252,160,68,255,	// 39	#FCA044
			248,184,0,255,	// 40	#F8B800
			184,248,24,255,	// 41	#B8F818
			88,216,84,255,	// 42	#58D854
			88,248,152,255,	// 43	#58F898
			0,232,216,255,	// 44	#00E8D8
			// 120,120,120,255,	// 45	#787878 x
			// 0,0,0,255,	// 46	#000000 x
			// 0,0,0,255,	// 47	#000000 x
			// 252,252,252,255,	// 48	#FCFCFC x
			164,228,252,255,	// 49	#A4E4FC
			184,184,248,255,	// 50	#B8B8F8
			216,184,248,255,	// 51	#D8B8F8
			248,184,248,255,	// 52	#F8B8F8
			248,164,192,255,	// 53	#F8A4C0
			// 240,208,176,255,	// 54	#F0D0B0 x
			252,224,168,255,	// 55	#FCE0A8
			248,216,120,255,	// 56	#F8D878
			216,248,120,255,	// 57	#D8F878
			184,248,184,255,	// 58	#B8F8B8
			// 184,248,216,255,	// 59	#B8F8D8 x
			0,252,252,255,	// 60	#00FCFC
			248,216,248,255,	// 61	#F8D8F8
			// 0,0,0,255,	// 62	#000000 x
			// 0,0,0,255,	// 63	#000000 x
		]);

	updateBaseMatrix
		Vector2 ratio = {graphics.windowSize.x / size.x, graphics.windowSize.y / size.y}
		float scale
		if ratio.x < ratio.y then
			scale = ratio.x
			activeOffset = {0, (graphics.windowSize.y - size.y * scale) / 2}
		else
			scale = ratio.y;
			activeOffset = {(graphics.windowSize.x - size.x * scale) / 2, 0}
		activeSize = size * scale

	clear
		for pixels.length
			pixels[i] = 0
			
	finishFrame
		debugger
		if Platform.fastForward then return
		let len = size.x * size.y
		int sourceIndex, targetIndex
		let target = pixelData.data
		while sourceIndex < len
			int paletteIndex = pixels[sourceIndex] shiftLeft 2
			target[targetIndex] = palette[paletteIndex]
			target[targetIndex+1] = palette[paletteIndex+1]
			target[targetIndex+2] = palette[paletteIndex+2]
			target[targetIndex+3] = 255
			sourceIndex++
			targetIndex += 4

		context.putImageData(pixelData, 0, 0)
		graphics.context.imageSmoothingEnabled = smoothing;
		graphics.context.drawImage(canvas, activeOffset.x, activeOffset.y, activeSize.x, activeSize.y)

media
	inline js Image getImage(string name) (media[name])

transient skipInit global unit graphics
	private dynamic canvas
	internal dynamic context
	Vector2 windowSize
	float pixelRatio = 1
	bool showVideos = false
	BitmapFont font

	Screen screen
	Screen[] screens

	int[] tiles

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

	async setup
		// screen = {size: {160,128}}	
		screen = {size: {192,144}}	
		// screen = {size: {200,152}}
		// screen = {size: {256,192}}
		// screen = {size: {320,240}}
		// screen = {size: {384,288}}
		screens = [screen]
		// font = {name: "commodore", gridSize: {8,8}, charSize: {8,8}, charsPerRow: 16, startChar: 32 }
		font = {name: "monogram", gridSize: {6,12}, charSize:{5,9}, charsPerRow: 16, startChar: 32 }
		for screens .setup

	updateBaseMatrix
		for screens .updateBaseMatrix()

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

	openTiles: Image image
		int[] pixels = graphics.getPixelsOfImage(image)
		for image.size.x * image.size.y
			int index = i*4
			int red = pixels[index]
			int green = pixels[index+1]
			int blue = pixels[index+2]
			int minDifference = 999999
			int closestColorIndex = 0
			for 16
				let difference = math.abs(screen.palette[i*4] - red) + math.abs(screen.palette[i*4+1] - green) + math.abs(screen.palette[i*4+2] - blue)
				if difference < minDifference then
					minDifference = difference
					closestColorIndex = i
			tiles[i] = closestColorIndex
			// print "{i}: {red},{green},{blue} -> {closestColorIndex} ({palette[closestColorIndex].name}) difference: {minDifference}"

	openFont: Image image
		int[] pixels = graphics.getPixelsOfImage(image)
		int[] font
		for image.size.x*image.size.y
			int index = i*4
			int red = pixels[index]
			int green = pixels[index+1]
			int blue = pixels[index+2]
			font[i] = red or green or blue ? 1 : 0
		return font	

	startFrame
		if Platform.fastForward then return
		if not tiles then graphics.openTiles(media.tiles)
		if font and not font.pixels then font.pixels = openFont(media.getImage(font.name))
		screen.clear

	finishFrame
		
		screen.finishFrame

	isDrawingDebugInfo = false
	clearDebugInfo
	finishDrawingDebugInfo

	global drawSprite: int sprite, Vector2 position
		if Platform.fastForward then return
		int stride = screen.size.x.round
		int tileStride = 256
		int tileOffset = ((sprite mod 32) + math.floor(sprite / 32) * tileStride) * 8
		int screenOffset = position.x + position.y*stride
		int[] source = graphics.tiles, target = screen.pixels
		for 8 as y
			for 8 as x
				let value = source[tileOffset + x]
				if value then target[screenOffset + x] = value
			screenOffset += stride
			tileOffset += tileStride

	global drawText: string text, Vector2 position, int color = 6
		if Platform.fastForward then return
		int stride = screen.size.x.round
		int fontStride = font.charsPerRow * font.gridSize.x
		debugger
		for text.length
			int char = text.getCharCodeAt(i) - 32
			int tileOffset = (char mod 16) * font.gridSize.x + math.floor(char / 16) * fontStride * font.gridSize.y
			int screenOffset = position.x + position.y*stride
			for font.charSize.y as y
				for font.charSize.x as x
					if font.pixels[tileOffset + x] then screen.pixels[screenOffset + x] = color
				screenOffset += stride
				tileOffset += fontStride
			position.x += font.gridSize.x
			if position.x >= screen.size.x
				position.x = 0
				position.y += font.gridSize.y

	global drawRect: IntVector2 position, Vector2 size, int color
		if Platform.fastForward then return
		int stride = screen.size.x.round
		int screenOffset = position.x + position.y*stride
		for size.y as y
			for size.x as x
				screen.pixels[screenOffset + x] = color
			screenOffset += stride
gizmo
	clear
	init
	internal onTouch: InputType inputType, int id, Vector2 pixelPos, Vector2 referencePos, shift = false, alt = false, cmdOrCtrl = false	