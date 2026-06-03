BitmapFont
	string name
	Vector2 charSize
	Vector2 gridSize
	float charsPerRow
	float startChar
	float[] pixels

class PaletteEntry
	string letter
	float red
	float green
	float blue
	float alpha
	string name
	float originalIndex
	string hex
	string category
	float index

Screen
	Vector2 size
	Vector2 activeSize, activeOffset
	float scale
	dynamic canvas, context
	dynamic pixelData
	Grid<float> pixels
	bool smoothing
	float clipX1, clipY1, clipX2, clipY2
	
	js void setup: Vector2 size
		this.size = size
		this.canvas = document.createElement("canvas")
		this.canvas.width = this.size.x
		this.canvas.height = this.size.y
		this.context = this.canvas.getContext("2d")
		this.pixelData = this.context.getImageData(0, 0, this.size.x, this.size.y, {pixelFormat: "rgba-unorm8" })
		this.pixels = new Grid(this.size, []);
		this.clear();

	onResize
		Vector2 ratio = {graphics.windowSize.x / size.x, graphics.windowSize.y / size.y}
		if ratio.x < ratio.y then
			scale = ratio.x
			activeOffset = {0, (graphics.windowSize.y - size.y * scale) / 2}
		else
			scale = ratio.y;
			activeOffset = {(graphics.windowSize.x - size.x * scale) / 2, 0}
		activeSize = size * scale

	getPixelPos: Vector2 pos
		return {
			x: ((pos.x*graphics.pixelRatio - activeOffset.x) / scale).clamp(0, size.x-1).floor,
			y: ((pos.y*graphics.pixelRatio - activeOffset.y) / scale).clamp(0, size.y-1).floor
		}

	clear
		clipX1 = 0
		clipY1 = 0
		clipX2 = size.x.floor
		clipY2 = size.y.floor
		float[] target = this.pixels.items
		float len = (size.x * size.y).floor
		for len
			target[i] = 0
			
	finishFrame
		if Platform.fastForward then return
		let len = size.x * size.y
		float sourceIndex, targetIndex
		let target = pixelData.data
		let pixels = this.pixels.items
		while sourceIndex < len
			float paletteIndex = pixels[sourceIndex] * 4
			target[targetIndex] = graphics.palette[paletteIndex]
			target[targetIndex+1] = graphics.palette[paletteIndex+1]
			target[targetIndex+2] = graphics.palette[paletteIndex+2]
			target[targetIndex+3] = 255
			sourceIndex++
			targetIndex += 4

		context.putImageData(pixelData, 0, 0)
		graphics.context.imageSmoothingEnabled = smoothing;
		graphics.context.drawImage(canvas, activeOffset.x, activeOffset.y, activeSize.x, activeSize.y)

dynamic TileCollection
	string Author
	string Source
	string Tags
	string License
	float startY, sizeY

transient global skipInit graphics
	const Vector2 tileSize
	const float tilesPerRow, tilesStride

	private dynamic canvas
	internal dynamic context
	Vector2 windowSize
	float pixelRatio
	bool showVideos

	BitmapFont font
	Screen screen
	Screen[] screens
	
	float[] palette
	float[] colorReplacements
	bool enableColorReplacements
	PaletteEntry[string] paletteEntries

	float[] tiles
	TileCollection[] tileCollections

	js void initHandlers
		window.onresize = () => this.onResize()
		this.onResize()

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
		for(let screen of graphics.screens) screen.onResize()

	js void initPalette: float size
		graphics.palette = new Uint8ClampedArray(size)

	setup
		this.tileSize.create(8,8)
		this.tilesPerRow = 16
		this.tilesStride = floor(tilesPerRow * tileSize.x)

		screen = {}
		screens = [screen]

		// font = {name: "commodore", gridSize: {8,8}, charSize: {8,8}, charsPerRow: 16, startChar: 32 }
		font = {name: "monogram", gridSize: {6,12}, charSize:{5,9}, charsPerRow: 16, startChar: 32 }

		setZoom 1
		initHandlers

		this.paletteEntries = {
			"0": new PaletteEntry("0",	0, 0, 0, 255,	"black",	0,	"#000000", "pico-8"),
			"1": new PaletteEntry("1",	29, 43, 83, 255,	"dark blue",	1,	"#1D2B53", "pico-8"),
			"2": new PaletteEntry("2",	126, 37, 83, 255,	"dark purple",	2,	"#7E2553", "pico-8"),
			"3": new PaletteEntry("3",	0, 135, 81, 255,	"dark green",	3,	"#008751", "pico-8"),
			"4": new PaletteEntry("4",	171, 82, 54, 255,	"brown",	4,	"#AB5236", "pico-8"),
			"5": new PaletteEntry("5",	95, 87, 79, 255,	"dark grey",	5,	"#5F574F", "pico-8"),
			"6": new PaletteEntry("6",	194, 195, 199, 255,	"light grey",	6,	"#C2C3C7", "pico-8"),
			"7": new PaletteEntry("7",	255, 241, 232, 255,	"white",	7,	"#FFF1E8", "pico-8"),
			"8": new PaletteEntry("8",	255, 0, 77, 255,	"red",	8,	"#FF004D", "pico-8"),
			"9": new PaletteEntry("9",	255, 163, 0, 255,	"orange",	9,	"#FFA300", "pico-8"),
			"a": new PaletteEntry("a",	255, 236, 39, 255,	"yellow",	10,	"#FFEC27", "pico-8"),
			"b": new PaletteEntry("b",	0, 228, 54, 255,	"green",	11,	"#00E436", "pico-8"),
			"c": new PaletteEntry("c",	41, 173, 255, 255,	"blue",	12,	"#29ADFF", "pico-8"),
			"d": new PaletteEntry("d",	131, 118, 156, 255,	"lavender",	13,	"#83769C", "pico-8"),
			"e": new PaletteEntry("e",	255, 119, 168, 255,	"pink",	14,	"#FF77A8", "pico-8"),
			"f": new PaletteEntry("f",	255, 204, 170, 255,	"light peach",	15,	"#FFCCAA", "pico-8"),
			"g": new PaletteEntry("g",	41,24,20, 255,	"brownish black",	-16,	"#291814", "pico-8 extended"),
			"h": new PaletteEntry("h",	17,29,53, 255,	"darker blue",	-15,	"#111D35", "pico-8 extended"),
			"i": new PaletteEntry("i",	66,33,54, 255,	"darker purple",	-14,	"#422136", "pico-8 extended"),
			"j": new PaletteEntry("j",	18,83,89, 255,	"blue green",	-13,	"#125359", "pico-8 extended"),
			"k": new PaletteEntry("k",	116,47,41, 255,	"dark brown",	-12,	"#742F29", "pico-8 extended"),
			"l": new PaletteEntry("l",	73,51,59, 255,	"darker grey",	-11,	"#49333B", "pico-8 extended"),
			"m": new PaletteEntry("m",	162,136,121, 255,	"medium grey",	-10,	"#A28879", "pico-8 extended"),
			"n": new PaletteEntry("n",	243,239,125, 255,	"light yellow",	-9,	"#F3EF7D", "pico-8 extended"),
			"o": new PaletteEntry("o",	190,18,80, 255,	"dark red",	-8,	"#BE1250", "pico-8 extended"),
			"p": new PaletteEntry("p",	255,108,36, 255,	"dark orange",	-7,	"#FF6C24", "pico-8 extended"),
			"q": new PaletteEntry("q",	168,231,46, 255,	"lime green",	-6,	"#A8E72E", "pico-8 extended"),
			"r": new PaletteEntry("r",	0,181,67, 255,	"medium green",	-5,	"#00B543", "pico-8 extended"),
			"s": new PaletteEntry("s",	6,90,181, 255,	"true blue",	-4,	"#065AB5", "pico-8 extended"),
			"t": new PaletteEntry("t",	117,70,101, 255,	"mauve",	-3,	"#754665", "pico-8 extended"),
			"u": new PaletteEntry("u",	255,110,89, 255,	"dark peach",	-2,	"#FF6E59", "pico-8 extended"),
			"v": new PaletteEntry("v",	255,157,129, 255,	"peach",	-1,	"#FF9D81", "pico-8 extended"),
			"A": new PaletteEntry("A",	0, 0, 0, 255,	"black",	0,	"#000000", "c64"),
			"B": new PaletteEntry("B",	255, 255, 255, 255,	"white",	1,	"#FFFFFF", "c64"),
			"C": new PaletteEntry("C",	146, 74, 64, 255,	"red",	2,	"#880000", "c64"),
			"D": new PaletteEntry("D",	132, 197, 204, 255,	"cyan",	3,	"#AAFFEE", "c64"),
			"E": new PaletteEntry("E",	147, 81, 182, 255,	"purple",	4,	"#CC44CC", "c64"),
			"F": new PaletteEntry("F",	114, 177, 75, 255,	"green",	5,	"#00CC55", "c64"),
			"G": new PaletteEntry("G",	72, 58, 170, 255,	"blue",	6,	"#0000AA", "c64"),
			"H": new PaletteEntry("H",	213, 223, 124, 255,	"yellow",	7,	"#EEEE77", "c64"),
			"I": new PaletteEntry("I",	153, 105, 45, 255,	"orange",	8,	"#DD8855", "c64"),
			"J": new PaletteEntry("J",	103, 82, 0, 255,	"brown",	9,	"#664400", "c64"),
			"K": new PaletteEntry("K",	193, 129, 120, 255,	"pink",	10,	"#FF7777", "c64"),
			"L": new PaletteEntry("L",	96, 96, 96, 255,	"dark grey",	11,	"#333333", "c64"),
			"M": new PaletteEntry("M",	138, 138, 138, 255,	"grey",	12,	"#777777", "c64"),
			"N": new PaletteEntry("N",	179, 236, 145, 255,	"light green",	13,	"#AAFF66", "c64"),
			"O": new PaletteEntry("O",	134, 122, 222, 255,	"light blue",	14,	"#0088FF", "c64"),
			"P": new PaletteEntry("P",	179, 179, 179, 255,	"light grey",	15,	"#BBBBBB", "c64"),
			"Q": new PaletteEntry("Q",	0,0,252,255,	"",	1,	"#0000fc","nes"),	// Closest color: 28 (difference: 167)
			"R": new PaletteEntry("R",	216,0,204,255,	"",	20,	"#d800cc","nes"),	// Closest color: 8 (difference: 166)
			"S": new PaletteEntry("S",	0,232,216,255,	"",	44,	"#00e8d8","nes"),	// Closest color: 12 (difference: 139)
			"T": new PaletteEntry("T",	0,252,252,255,	"",	60,	"#00fcfc","nes"),	// Closest color: 12 (difference: 123)
			"U": new PaletteEntry("U",	104,68,252,255,	"",	19,	"#6844fc","nes"),	// Closest color: 46 (difference: 114)
			"V": new PaletteEntry("V",	164,228,252,255,	"",	49,	"#a4e4fc","nes"),	// Closest color: 35 (difference: 111)
			"W": new PaletteEntry("W",	88,248,152,255,	"",	43,	"#58f898","nes"),	// Closest color: 45 (difference: 110)
			"X": new PaletteEntry("X",	148,0,132,255,	"",	4,	"#940084","nes"),	// Closest color: 2 (difference: 108)
			"Y": new PaletteEntry("Y",	168,16,0,255,	"",	6,	"#a81000","nes"),	// Closest color: 24 (difference: 104)
			"Z": new PaletteEntry("Z",	0,104,0,255,	"",	10,	"#006800","nes"),	// Closest color: 0 (difference: 104)
			"w": new PaletteEntry("w",	0,0,188,255,	"",	2,	"#0000bc","nes"),	// Closest color: 28 (difference: 103)
			"x": new PaletteEntry("x",	0,120,248,255,	"",	17,	"#0078f8","nes"),	// Closest color: 12 (difference: 101)
			"y": new PaletteEntry("y",	0,120,0,255,	"",	9,	"#007800","nes"),	// Closest color: 3 (difference: 96)
			"z": new PaletteEntry("z",	248,56,0,255,	"",	22,	"#f83800","nes"),	// Closest color: 25 (difference: 95)
			"!": new PaletteEntry("!",	168,0,32,255,	"",	5,	"#a80020","nes"),	// Closest color: 24 (difference: 88)
			"#": new PaletteEntry("#",	136,20,0,255,	"",	7,	"#881400","nes"),	// Closest color: 20 (difference: 88)
			"$": new PaletteEntry("$",	0,88,0,255,	"",	11,	"#005800","nes"),	// Closest color: 0 (difference: 88)
			"%": new PaletteEntry("%",	248,120,248,255,	"",	36,	"#f878f8","nes"),	// Closest color: 14 (difference: 88)
			"&": new PaletteEntry("&",	172,124,0,255,	"",	24,	"#ac7c00","nes"),	// Closest color: 40 (difference: 83)
			"'": new PaletteEntry("'",	216,184,248,255,	"",	51,	"#d8b8f8","nes"),	// Closest color: 6 (difference: 82)
			"(": new PaletteEntry("(",	0,168,0,255,	"",	26,	"#00a800","nes"),	// Closest color: 27 (difference: 80)
			")": new PaletteEntry(")",	248,184,248,255,	"",	52,	"#f8b8f8","nes"),	// Closest color: 7 (difference: 80)
			"*": new PaletteEntry("*",	184,248,216,255,	"",	59,	"#b8f8d8","nes"),	// Closest color: 6 (difference: 80)
			"+": new PaletteEntry("+",	0,88,248,255,	"",	18,	"#0058f8","nes"),	// Closest color: 28 (difference: 75)
			",": new PaletteEntry(",",	104,136,252,255,	"",	34,	"#6888fc","nes"),	// Closest color: 46 (difference: 74)
			"-": new PaletteEntry("-",	88,216,84,255,	"",	42,	"#58d854","nes"),	// Closest color: 37 (difference: 74)
			".": new PaletteEntry(".",	0,184,0,255,	"",	25,	"#00b800","nes"),	// Closest color: 27 (difference: 70)
			"/": new PaletteEntry("/",	184,184,248,255,	"",	50,	"#b8b8f8","nes"),	// Closest color: 6 (difference: 70)
			":": new PaletteEntry(":",	248,164,192,255,	"",	53,	"#f8a4c0","nes"),	// Closest color: 15 (difference: 69)
			";": new PaletteEntry(";",	252,160,68,255,	"",	39,	"#fca044","nes"),	// Closest color: 31 (difference: 67)
			"<": new PaletteEntry("<",	228,92,16,255,	"",	23,	"#e45c10","nes"),	// Closest color: 25 (difference: 63)
			"=": new PaletteEntry("=",	80,48,0,255,	"",	8,	"#503000","nes"),	// Closest color: 41 (difference: 57)
			">": new PaletteEntry(">",	0,136,136,255,	"",	28,	"#008888","nes"),	// Closest color: 3 (difference: 56)
			"?": new PaletteEntry("?",	184,248,184,255,	"",	58,	"#b8f8b8","nes"),	// Closest color: 45 (difference: 56)
			"@": new PaletteEntry("@",	184,248,24,255,	"",	41,	"#b8f818","nes"),	// Closest color: 26 (difference: 55)
			"[": new PaletteEntry("[",	248,88,152,255,	"",	37,	"#f85898","nes"),	// Closest color: 14 (difference: 54)
			"]": new PaletteEntry("]",	120,120,120,255,	"",	45,	"#787878","nes"),	// Closest color: 13 (difference: 49)
			"^": new PaletteEntry("^",	248,216,248,255,	"",	61,	"#f8d8f8","nes"),	// Closest color: 7 (difference: 48)
			"_": new PaletteEntry("_",	152,120,248,255,	"",	35,	"#9878f8","nes"),	// Closest color: 46 (difference: 46)
			"\{": new PaletteEntry("\{",	124,124,124,255,	"",	0,	"#7c7c7c","nes"),	// Closest color: 44 (difference: 42)
			"|": new PaletteEntry("|",	68,40,188,255,	"",	3,	"#4428bc","nes"),	// Closest color: 38 (difference: 40)
			"\}": new PaletteEntry("\}",	0,64,88,255,	"",	12,	"#004058","nes"),	// Closest color: 19 (difference: 38)
			"~": new PaletteEntry("~",	228,0,88,255,	"",	21,	"#e40058","nes"),	// Closest color: 8 (difference: 38)
		};
		float index, paletteIndex
		initPalette size:paletteEntries.length*4
		for paletteEntries as entry
			entry.index = index++
			graphics.palette[paletteIndex++] = entry.red
			graphics.palette[paletteIndex++] = entry.green
			graphics.palette[paletteIndex++] = entry.blue
			graphics.palette[paletteIndex++] = 255
		colorReplacements = []
		for paletteEntries.length
			colorReplacements[i] = i
		enableColorReplacements = false
		openTiles
		openFonts

	inline js string fontsData => (typeof _data_fonts === "string" ? _data_fonts : "")
	inline js string tilesData => (typeof _data_tiles === "string" ? _data_tiles : "")

	private openTiles
		tiles = []
		tileCollections = []
		TileCollection collection, prevCollection
		float index = 0
		for tilesData.split("\n") as line
			if line.startsWith "#"
				float colonIndex = line.indexOf ":"
				string key = line.substring(1, colonIndex).trim.toLowerCase
				string value = line.substring(colonIndex+1).trim
				if not collection then collection = {}
				collection[key] = value
			else
			if line.length > 0
				for line.length as i
					PaletteEntry entry = paletteEntries[line[i]]
					tiles[index + i] = entry ? entry.index : 0
				index += tilesStride

	private openFonts
		float index = 0
		for fontsData.split("\n") as line
			float pixelOffset = floor(i*font.gridSize.x*font.charsPerRow)
			for line.length as i
				if line[i] != "0" then font.pixels[pixelOffset + i] = 1

	global setSprite: float spriteIndex, string[] pixelsAsStrings
		let index = floor(spriteIndex / tilesPerRow) * tileSize.y * tilesStride + (spriteIndex mod tilesPerRow) * tileSize.x
		for pixelsAsStrings as line
			for line.length as i
				PaletteEntry entry = paletteEntries[line[i]]
				tiles[index + i] = entry ? entry.index : 0
			index += tilesStride

	startFrame
		if Platform.fastForward then return
		screen.clear

	finishFrame
		screen.finishFrame

	global Grid<float> pixels
	global Vector2 screenSize
	global Vector2 screenGridSize

	setZoom: float factor
		screen.setup {224,168}*factor
		// screen.setup {192,144}*factor
		pixels = screen.pixels
		screenSize.create screen.size
		screenGridSize.create screen.size / tileSize

	global void setPixel: Vector2 pos, float color
		if Platform.fastForward then return
		if screen.clipX1 <= pos.x < screen.clipX2 and screen.clipY1 <= pos.y < screen.clipY2
			screen.pixels.items[(pos.y * screen.size.x + pos.x).floor] = color

	global float getPixel: Vector2 pos
		if Platform.fastForward then return
		if 0 <= pos.x < screen.size.x and 0 <= pos.y < screen.size.y
			return screen.pixels.items[(pos.y * screen.size.x + pos.x).floor]
		return 0

	copy: float[] source, float sourceStride, float sourceIndex, Vector2 pos = {0,0}, Vector2 size = {8,8}
		if Platform.fastForward then return
		float positionX = pos.x.floor, positionY = pos.y.floor
		float startX = positionX
		float endX = positionX + size.x.floor
		float startY = positionY
		float endY = positionY + size.y.floor
		float targetStride = screen.size.x.floor
		if startX < screen.clipX1 then startX = screen.clipX1
		if endX > screen.clipX2 then endX = screen.clipX2
		if startY < screen.clipY1 then startY = screen.clipY1
		if endY > screen.clipY2 then endY = screen.clipY2
		if startX >= endX or startY >= endY then return
		float sourceOffset = floor(((sourceIndex mod tilesPerRow) + math.floor(sourceIndex / tilesPerRow) * tilesStride) * tileSize.x)
		sourceOffset += (startY - positionY) * tilesStride + startX - positionX
		float start = sourceOffset
		float end = start + endX - startX
		float offsetToTarget = startY * targetStride + startX - start
		float[] target = screen.pixels.items

		if not enableColorReplacements
			for startY to endY as y
				for start to end as i
					let sourceValue = source[i]
					if sourceValue then target[i + offsetToTarget] = sourceValue
				start += tilesStride
				end += tilesStride
				offsetToTarget += targetStride - tilesStride
		else
			for startY to endY as y
				for start to end as i
					let sourceValue = colorReplacements[source[i]]
					if sourceValue then target[i + offsetToTarget] = sourceValue
				start += tilesStride
				end += tilesStride
				offsetToTarget += targetStride - tilesStride

	global drawSprite: Sprite sprite, Vector2 pos = {0,0}, void() onClick = null
		if Platform.fastForward then return
		float positionX = pos.x.floor, positionY = pos.y.floor
		float startX = positionX
		float endX = positionX + sprite.size.x.floor
		float startY = positionY
		float endY = positionY + sprite.size.y.floor
		float targetStride = screen.size.x.floor
		if startX < screen.clipX1 then startX = screen.clipX1
		if endX > screen.clipX2 then endX = screen.clipX2
		if startY < screen.clipY1 then startY = screen.clipY1
		if endY > screen.clipY2 then endY = screen.clipY2
		if startX >= endX or startY >= endY then return
		float spriteStride = sprite.stride
		float start = (startY - positionY) * spriteStride + startX - positionX
		float end = start + endX - startX
		float offsetToTarget = startY * targetStride + startX - start
		float[] source = sprite.pixels, target = screen.pixels.items

		if not enableColorReplacements
			for startY to endY as y
				for start to end as i
					let sourceValue = source[i]
					if sourceValue then target[i + offsetToTarget] = sourceValue
				start += spriteStride
				end += spriteStride
				offsetToTarget += targetStride - spriteStride
		else
			for startY to endY as y
				for start to end as i
					let sourceValue = colorReplacements[source[i]]
					if sourceValue then target[i + offsetToTarget] = sourceValue
				start += spriteStride
				end += spriteStride
				offsetToTarget += targetStride - spriteStride
		
		if onClick != null and justPressed LeftMouseButton
			let pointerPos = getPointer()
			if pos <= pointerPos < pos + sprite.size
				onClick()

	global drawText: string text, Vector2 pos = {0,0}, float color = 6
		if Platform.fastForward then return
		float stride = floor(screen.size.x)
		float fontStride = floor(font.charsPerRow * font.gridSize.x)
		let target = screen.pixels.items
		for text.length
			float char = text.getCharCodeAt(i) - 32
			float tileOffset = floor((char mod 16) * font.gridSize.x + math.floor(char / 16) * fontStride * font.gridSize.y)
			float screenOffset = floor(pos.x + pos.y*stride)
			for font.charSize.y as y
				for font.charSize.x as x
					if font.pixels[tileOffset + x] then target[screenOffset + x] = color
				screenOffset += stride
				tileOffset += fontStride
			pos.x += font.gridSize.x
			if pos.x >= screen.size.x
				pos.x = 0
				pos.y += font.gridSize.y

	global void drawRect: Vector2 pos = {0,0}, implicit Vector2 size = {8,8}, float fillColor = -1, float outlineColor = -1, float outlineWidth = 1
		if Platform.fastForward then return
		let x = pos.x.floor, y = pos.y.floor
		let sizeX = size.x.ceil, sizeY = size.y.ceil
		let target = screen.pixels.items
		if fillColor == -1 and outlineColor == -1 then fillColor = 6
		if fillColor != -1
			float stride = floor(screen.size.x)
			float screenOffset = floor(x + y*stride)
			for sizeY as y
				for sizeX as x
					target[screenOffset + x] = fillColor
				screenOffset += stride
		if outlineColor != -1 and outlineWidth > 0 and outlineColor != fillColor
			drawRect {x,y}, {sizeX, outlineWidth}, fillColor:outlineColor
			drawRect {x, y + sizeY - outlineWidth}, {sizeX, outlineWidth}, fillColor:outlineColor
			drawRect {x, y}, {outlineWidth, sizeY}, fillColor:outlineColor
			drawRect {x + sizeX - outlineWidth, y}, {outlineWidth, sizeY}, fillColor:outlineColor

	global void drawCircle: Vector2 pos = {0,0}, Vector2 radius, float fillColor = -1, float outlineColor = -1, float outlineWidth = 1
		if Platform.fastForward then return
		if fillColor == -1 and outlineColor == -1 then fillColor = 6
		// TODO: Implement draw circle

	global void drawCircle: Vector2 pos = {0,0}, float radius = 8, float fillColor = -1, float outlineColor = -1, float outlineWidth = 1
		drawCircle pos, radius:{radius, radius}, fillColor, outlineColor, outlineWidth

	global clip: Vector2 pos = {0,0}, Vector2 size = {0,0}
		screen.clipX1 = pos.x.floor
		screen.clipY1 = pos.y.floor
		screen.clipX2 = (pos.x + size.x).floor
		screen.clipY2 = (pos.y + size.y).floor

	global stopClipping
		screen.clipX1 = 0
		screen.clipY1 = 0
		screen.clipX2 = screen.size.x.floor
		screen.clipY2 = screen.size.y.floor

	global replaceColor: float color, nocolon float with
		colorReplacements[color] = with
		enableColorReplacements = true

	global stopReplacingColors
		for colorReplacements.length
			colorReplacements[i] = i
		enableColorReplacements = false

Sprite
	float[] pixels
	Vector2 size
	float frames = 1
	float framesPerSecond = 15
	float stride
	Vector2 sourcePos

	Sprite: string[] pixelsAsStrings = null
		if not pixelsAsStrings then return
		let maxWidth = pixelsAsStrings.max.length
		pixels = []
		size.create(maxWidth, pixelsAsStrings.length)
		if frames == float.undefined then frames = 1
		if framesPerSecond == float.undefined then framesPerSecond = 15
		stride = maxWidth
		float index
		for pixelsAsStrings as line
			for line.length as i
				PaletteEntry entry = graphics.paletteEntries[line[i]]
				pixels[index + i] = entry ? entry.index : 0
			index += maxWidth

	copyFromSource
		// NEXT: Copy from graphics.tiles at sourcePos with size and frames, use in spriteEditor and tilePanel
