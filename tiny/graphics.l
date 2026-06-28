static skipInit class Colors
	global const Color Black 	= { "#000000", " ", 0 }
	global const Color DarkGrey 	= { "#5F574F", "d", 5 }
	global const Color LightGrey 	= { "#C2C3C7", "l", 6 }
	global const Color White 	= { "#FFF1E8", "w", 7 }
	global const Color Blue 	= { "#29ADFF", "b", 12 }
	global const Color Red 	= { "#FF004D", "r", 8 }
	global const Color Green 	= { "#00E436", "g", 11 }
	global const Color Yellow 	= { "#FFEC27", "y", 10 }

	global const Color Earth 	= { "#AB5236", "e", 4 }
	global const Color Sand 	= { "#FFCCAA", "s", 15 }
	global const Color Pink 	= { "#FF77A8", "p", 14 }
	global const Color Violet 	= { "#83769C", "v", 13 }
	global const Color DarkBlue 	= { "#1D2B53", "B", 1 }
	global const Color DarkRed 	= { "#7E2553", "R", 2 }
	global const Color DarkGreen 	= { "#008751", "G", 3 }
	global const Color Orange 	= { "#FFA300", "o", 9 }

	global const Color BrownishBlack 	= { "#291814", "k", -16 }
	global const Color DarkerBlue 	= { "#111D35", "D", -15 }
	global const Color DarkerPurple 	= { "#422136", "u", -14 }
	global const Color BlueGreen 	= { "#125359", "c", -13 }
	global const Color DarkBrown 	= { "#742F29", "n", -12 }
	global const Color DarkerGrey 	= { "#49333B", "a", -11 }
	global const Color MediumGrey 	= { "#A28879", "m", -10 }
	global const Color LightYellow 	= { "#F3EF7D", "Y", -9 }

	global const Color DarkerRed 	= { "#BE1250", "E", -8 }
	global const Color DarkOrange 	= { "#FF6C24", "O", -7 }
	global const Color LimeGreen 	= { "#A8E72E", "L", -6 }
	global const Color MediumGreen 	= { "#00B543", "M", -5 }
	global const Color TrueBlue 	= { "#065AB5", "T", -4 }
	global const Color Mauve 	= { "#754665", "V", -3 }
	global const Color DarkPeach 	= { "#FF6E59", "H", -2 }
	global const Color Peach 	= { "#FF9D81", "P", -1 }

	// 	"A": new PaletteEntry("A",	0, 0, 0, 255,	"black",	0,	"#000000", "c64"),
	// 	"B": new PaletteEntry("B",	255, 255, 255, 255,	"white",	1,	"#FFFFFF", "c64"),
	// 	"C": new PaletteEntry("C",	146, 74, 64, 255,	"red",	2,	"#880000", "c64"),
	// 	"D": new PaletteEntry("D",	132, 197, 204, 255,	"cyan",	3,	"#AAFFEE", "c64"),
	// 	"E": new PaletteEntry("E",	147, 81, 182, 255,	"purple",	4,	"#CC44CC", "c64"),
	// 	"F": new PaletteEntry("F",	114, 177, 75, 255,	"green",	5,	"#00CC55", "c64"),
	// 	"G": new PaletteEntry("G",	72, 58, 170, 255,	"blue",	6,	"#0000AA", "c64"),
	// 	"H": new PaletteEntry("H",	213, 223, 124, 255,	"yellow",	7,	"#EEEE77", "c64"),
	// 	"I": new PaletteEntry("I",	153, 105, 45, 255,	"orange",	8,	"#DD8855", "c64"),
	// 	"J": new PaletteEntry("J",	103, 82, 0, 255,	"brown",	9,	"#664400", "c64"),
	// 	"K": new PaletteEntry("K",	193, 129, 120, 255,	"pink",	10,	"#FF7777", "c64"),
	// 	"L": new PaletteEntry("L",	96, 96, 96, 255,	"dark grey",	11,	"#333333", "c64"),
	// 	"M": new PaletteEntry("M",	138, 138, 138, 255,	"grey",	12,	"#777777", "c64"),
	// 	"N": new PaletteEntry("N",	179, 236, 145, 255,	"light green",	13,	"#AAFF66", "c64"),
	// 	"O": new PaletteEntry("O",	134, 122, 222, 255,	"light blue",	14,	"#0088FF", "c64"),
	// 	"P": new PaletteEntry("P",	179, 179, 179, 255,	"light grey",	15,	"#BBBBBB", "c64"),
	// 	"Q": new PaletteEntry("Q",	0,0,252,255,	"",	1,	"#0000fc","nes"),	// Closest color: 28 (difference: 167)
	// 	"R": new PaletteEntry("R",	216,0,204,255,	"",	20,	"#d800cc","nes"),	// Closest color: 8 (difference: 166)
	// 	"S": new PaletteEntry("S",	0,232,216,255,	"",	44,	"#00e8d8","nes"),	// Closest color: 12 (difference: 139)
	// 	"T": new PaletteEntry("T",	0,252,252,255,	"",	60,	"#00fcfc","nes"),	// Closest color: 12 (difference: 123)
	// 	"U": new PaletteEntry("U",	104,68,252,255,	"",	19,	"#6844fc","nes"),	// Closest color: 46 (difference: 114)
	// 	"V": new PaletteEntry("V",	164,228,252,255,	"",	49,	"#a4e4fc","nes"),	// Closest color: 35 (difference: 111)
	// 	"W": new PaletteEntry("W",	88,248,152,255,	"",	43,	"#58f898","nes"),	// Closest color: 45 (difference: 110)
	// 	"X": new PaletteEntry("X",	148,0,132,255,	"",	4,	"#940084","nes"),	// Closest color: 2 (difference: 108)
	// 	"Y": new PaletteEntry("Y",	168,16,0,255,	"",	6,	"#a81000","nes"),	// Closest color: 24 (difference: 104)
	// 	"Z": new PaletteEntry("Z",	0,104,0,255,	"",	10,	"#006800","nes"),	// Closest color: 0 (difference: 104)
	// 	"w": new PaletteEntry("w",	0,0,188,255,	"",	2,	"#0000bc","nes"),	// Closest color: 28 (difference: 103)
	// 	"x": new PaletteEntry("x",	0,120,248,255,	"",	17,	"#0078f8","nes"),	// Closest color: 12 (difference: 101)
	// 	"y": new PaletteEntry("y",	0,120,0,255,	"",	9,	"#007800","nes"),	// Closest color: 3 (difference: 96)
	// 	"z": new PaletteEntry("z",	248,56,0,255,	"",	22,	"#f83800","nes"),	// Closest color: 25 (difference: 95)
	// 	"!": new PaletteEntry("!",	168,0,32,255,	"",	5,	"#a80020","nes"),	// Closest color: 24 (difference: 88)
	// 	"#": new PaletteEntry("#",	136,20,0,255,	"",	7,	"#881400","nes"),	// Closest color: 20 (difference: 88)
	// 	"$": new PaletteEntry("$",	0,88,0,255,	"",	11,	"#005800","nes"),	// Closest color: 0 (difference: 88)
	// 	"%": new PaletteEntry("%",	248,120,248,255,	"",	36,	"#f878f8","nes"),	// Closest color: 14 (difference: 88)
	// 	"&": new PaletteEntry("&",	172,124,0,255,	"",	24,	"#ac7c00","nes"),	// Closest color: 40 (difference: 83)
	// 	"'": new PaletteEntry("'",	216,184,248,255,	"",	51,	"#d8b8f8","nes"),	// Closest color: 6 (difference: 82)
	// 	"(": new PaletteEntry("(",	0,168,0,255,	"",	26,	"#00a800","nes"),	// Closest color: 27 (difference: 80)
	// 	")": new PaletteEntry(")",	248,184,248,255,	"",	52,	"#f8b8f8","nes"),	// Closest color: 7 (difference: 80)
	// 	"*": new PaletteEntry("*",	184,248,216,255,	"",	59,	"#b8f8d8","nes"),	// Closest color: 6 (difference: 80)
	// 	"+": new PaletteEntry("+",	0,88,248,255,	"",	18,	"#0058f8","nes"),	// Closest color: 28 (difference: 75)
	// 	",": new PaletteEntry(",",	104,136,252,255,	"",	34,	"#6888fc","nes"),	// Closest color: 46 (difference: 74)
	// 	"-": new PaletteEntry("-",	88,216,84,255,	"",	42,	"#58d854","nes"),	// Closest color: 37 (difference: 74)
	// 	".": new PaletteEntry(".",	0,184,0,255,	"",	25,	"#00b800","nes"),	// Closest color: 27 (difference: 70)
	// 	"/": new PaletteEntry("/",	184,184,248,255,	"",	50,	"#b8b8f8","nes"),	// Closest color: 6 (difference: 70)
	// 	":": new PaletteEntry(":",	248,164,192,255,	"",	53,	"#f8a4c0","nes"),	// Closest color: 15 (difference: 69)
	// 	";": new PaletteEntry(";",	252,160,68,255,	"",	39,	"#fca044","nes"),	// Closest color: 31 (difference: 67)
	// 	"<": new PaletteEntry("<",	228,92,16,255,	"",	23,	"#e45c10","nes"),	// Closest color: 25 (difference: 63)
	// 	"=": new PaletteEntry("=",	80,48,0,255,	"",	8,	"#503000","nes"),	// Closest color: 41 (difference: 57)
	// 	">": new PaletteEntry(">",	0,136,136,255,	"",	28,	"#008888","nes"),	// Closest color: 3 (difference: 56)
	// 	"?": new PaletteEntry("?",	184,248,184,255,	"",	58,	"#b8f8b8","nes"),	// Closest color: 45 (difference: 56)
	// 	"@": new PaletteEntry("@",	184,248,24,255,	"",	41,	"#b8f818","nes"),	// Closest color: 26 (difference: 55)
	// 	"[": new PaletteEntry("[",	248,88,152,255,	"",	37,	"#f85898","nes"),	// Closest color: 14 (difference: 54)
	// 	"]": new PaletteEntry("]",	120,120,120,255,	"",	45,	"#787878","nes"),	// Closest color: 13 (difference: 49)
	// 	"^": new PaletteEntry("^",	248,216,248,255,	"",	61,	"#f8d8f8","nes"),	// Closest color: 7 (difference: 48)
	// 	"_": new PaletteEntry("_",	152,120,248,255,	"",	35,	"#9878f8","nes"),	// Closest color: 46 (difference: 46)
	// 	"\{": new PaletteEntry("\{",	124,124,124,255,	"",	0,	"#7c7c7c","nes"),	// Closest color: 44 (difference: 42)
	// 	"|": new PaletteEntry("|",	68,40,188,255,	"",	3,	"#4428bc","nes"),	// Closest color: 38 (difference: 40)
	// 	"\}": new PaletteEntry("\}",	0,64,88,255,	"",	12,	"#004058","nes"),	// Closest color: 19 (difference: 38)
	// 	"~": new PaletteEntry("~",	228,0,88,255,	"",	21,	"#e40058","nes"),	// Closest color: 8 (difference: 38)

// A color comprised of a red, green, blue and alpha component
immutable Color
	string letter
	int index
	string name
	int value
	int red, green, blue, alpha

	Color: string hex
		if hex.length >= 1 and hex[0] == "#" then hex = hex.substring(1)
		red = hex.length >= 2 ? hex.substring(0,2).parseInt(16) : 0
		green = hex.length >= 4 ? hex.substring(2,4).parseInt(16) : 0
		blue = hex.length >= 6 ? hex.substring(4,6).parseInt(16) : 0
		alpha = hex.length >= 8 ? hex.substring(6,8).parseInt(16) : 255
		value = (red shiftLeft 0) + (green * 256) + (blue * 65536) + (alpha * 16777216)

	Color: int hex
		if(hex <= 0xffffff)
			red = hex.shiftRight(16) bitwiseAnd 0xff
			green = hex.shiftRight(8) bitwiseAnd 0xff
			blue = hex bitwiseAnd 0xff
			alpha = 255
		else
			red = hex.shiftRight(24) bitwiseAnd 0xff
			green = hex.shiftRight(16) bitwiseAnd 0xff
			blue = hex.shiftRight(8) bitwiseAnd 0xff
			alpha = hex bitwiseAnd 0xff
		value = (red shiftLeft 0) + (green * 256) + (blue * 65536) + (alpha * 16777216)

	Color: int value
		red = value shiftRight 0 bitwiseAnd 0xff
		green = value shiftRight 8 bitwiseAnd 0xff
		blue = value shiftRight 16 bitwiseAnd 0xff
		alpha = value shiftRight 24 bitwiseAnd 0xff

struct int
	inline Color toColor => new Color(value:this)
		
BitmapFont
	string name
	Vector2 charSize
	Vector2 charSizeWithoutSpacing
	Vector2 sourceSize
	int charsPerRow
	int startChar
	int[] pixels

Screen
	Vector2 size
	Vector2 activeSize, activeOffset
	float scale
	dynamic canvas, context
	dynamic pixelData
	int[] pixels

	bool smoothing
	int clipX1, clipY1, clipX2, clipY2
	
	js void setup: Vector2 size
		this.size = size
		if(system.isEmbedded) {
			this.pixels = new Uint32Array(size.x * size.y);
		} else {
			this.canvas = document.createElement("canvas")
			this.canvas.width = this.size.x
			this.canvas.height = this.size.y
			this.context = this.canvas.getContext("2d")
			this.pixelData = this.context.getImageData(0, 0, this.size.x, this.size.y, {pixelFormat: "rgba-unorm8" })
			this.pixels = new Uint32Array(this.pixelData.data.buffer, this.pixelData.data.byteOffset, this.pixelData.data.byteLength / 4)
		}
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
		int[] target = this.pixels
		int len = (size.x * size.y).floor
		for len target[.] = 0xff000000
			
	finishFrame
		if system.fastForward or system.isEmbedded then return
		context.putImageData(pixelData, 0, 0)
		graphics.context.imageSmoothingEnabled = smoothing;
		graphics.context.drawImage(canvas, activeOffset.x, activeOffset.y, activeSize.x, activeSize.y)

dynamic TileCollection
	string Author
	string Source
	string Tags
	string License
	int startY, sizeY

// --------------------------------------------- Compatibility ---------------------------------------------
	
enum HorizontalAlignment: Left, Center, Right
enum VerticalAlignment: Top, Middle, Bottom

internal skipInit transient unit gizmo
	init
	clear
	internal onTouch: InputType inputType, int id, Vector2 pixelPos, Vector2 referencePos, shift = false, alt = false, cmdOrCtrl = false

media
	init
	openMedia: void() then
		then()

transient global skipInit graphics
	updateBaseMatrix
	
	clearDebugInfo
	finishDrawingDebugInfo
	isDrawingDebugInfo = false
	getWhatIsOnScreen => ""

	const Color[] defaultColors = [{"#398CA9", name:"Blue"}, {"#C01352", name:"Red"}, {"#16C66E", name:"Green"}, {"#FFD166", name:"Yellow"}]
	const Color[] darkDefaultColors = [{"#193742", name:"Dark Blue"}, {"#470B21", name:"Dark Red"}, {"#0A3620", name:"Dark Green"}, {"#4B3F21", name:"Dark Yellow"}]	

// --------------------------------------------- Graphics ---------------------------------------------

transient global skipInit graphics
	const Vector2 tileSize = {8,8}
	const int tilesPerRow = 16
	const int tilesStride = 128

	private dynamic canvas
	internal dynamic context
	Vector2 windowSize
	float pixelRatio
	
	Screen screen
	Screen[] screens

	int[string] colorByLetter
	Color[] colors

	int[] tiles
	TileCollection[] tileCollections

	js void initHandlers
		if(system.isEmbedded) return
		window.onresize = () => this.onResize()
		this.onResize()

	internal js void onResize
		if(system.isEmbedded) return
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
		this.screen?.finishFrame()

	getPixelPos: int x, int y
		return screen.getPixelPos({x, y})

	setup
		screen = {}
		screens = [screen]

		setResolution {224, 168}
		// setResolution {256, 192}
		initHandlers

		colorByLetter = {}
		colors = []
		forDynamic Colors as color, name
			color.name = name
			colors.add color
			colorByLetter[color.letter] = color.value

		// openTiles
		openFonts

	getClosestColor: int value
		let r = value bitwiseAnd 0xff
		let g = (value shiftRight 8) bitwiseAnd 0xff
		let b = (value shiftRight 16) bitwiseAnd 0xff
		let a = (value shiftRight 24) bitwiseAnd 0xff
		Color closestColor
		let closestColorDifference = int.maxValue
		for colors
			let difference = math.abs(r - .red) + math.abs(g - .green) + math.abs(b - .blue) + math.abs(a - .alpha)
			if difference == 0 then return .
			if difference < closestColorDifference
				closestColorDifference = difference
				closestColor = .
		return closestColor

	inline js string fontsData => (typeof _data_fonts === "string" ? _data_fonts : "")
	inline js string tilesData => (typeof _data_tiles === "string" ? _data_tiles : "")

	// private openTiles
	// 	tiles = []
	// 	tileCollections = []
	// 	TileCollection collection, prevCollection
	// 	int index = 0
	// 	for tilesData.split("\n") as line
	// 		if line.startsWith "#"
	// 			int colonIndex = line.indexOf ":"
	// 			string key = line.substring(1, colonIndex).trim.toLowerCase
	// 			string value = line.substring(colonIndex+1).trim
	// 			if not collection then collection = {}
	// 			collection[key] = value
	// 		else
	// 		if line.length > 0
	// 			for line.length as i
	// 				PaletteEntry entry = colorByLetter[line[i]]
	// 				tiles[index + i] = entry ? entry.index : 0
	// 			index += tilesStride

	private openFonts
		font = {name: "monogram", sourceSize:{6,12}, charSize:{6,10}, charSizeWithoutSpacing:{5,9}, charsPerRow: 16, startChar: 32 }
		int index = 0
		for fontsData.split("\n") as line
			int pixelOffset = floor(i*font.sourceSize.x*font.charsPerRow)
			for line.length as i
				if line[i] != "0" then font.pixels[pixelOffset + i] = 1

	startFrame
		if system.fastForward then return
		screen.clear
		helpText = ""

	finishFrame
		screen.finishFrame

	int[] pixels
	BitmapFont font
	global Vector2 screenSize
	global Vector2 screenGridSize
	global string helpText

	setResolution: Vector2 size = {256, 192}
		screen.setup size
		pixels = screen.pixels
		screenSize.create screen.size
		screenGridSize.create screen.size / tileSize

	global void setPixel: Vector2 pos
		                  implicit Color color
		if system.fastForward then return
		if screen.clipX1 <= pos.x < screen.clipX2 and screen.clipY1 <= pos.y < screen.clipY2
			screen.pixels[(pos.y * screen.size.x + pos.x).floor] = color.value

	global int getPixel: Vector2 pos
		if system.fastForward then return
		if 0 <= pos.x < screen.size.x and 0 <= pos.y < screen.size.y
			return screen.pixels[(pos.y * screen.size.x + pos.x).floor]
		return 0

	copy: int[] source, int sourceStride, int sourceOffset, Vector2 pos = {0,0}, Vector2 size = {8,8}
		if system.fastForward then return
		int positionX = pos.x.floor, positionY = pos.y.floor
		int startX = positionX
		int endX = positionX + size.x.floor
		int startY = positionY
		int endY = positionY + size.y.floor
		int targetStride = screen.size.x.floor
		if startX < screen.clipX1 then startX = screen.clipX1
		if endX > screen.clipX2 then endX = screen.clipX2
		if startY < screen.clipY1 then startY = screen.clipY1
		if endY > screen.clipY2 then endY = screen.clipY2
		if startX >= endX or startY >= endY then return
		// int sourceOffset = floor(((sourceIndex mod tilesPerRow) + math.floor(sourceIndex / tilesPerRow) * tilesStride) * tileSize.x)
		sourceOffset += (startY - positionY) * tilesStride + startX - positionX
		int start = sourceOffset
		int end = start + endX - startX
		int offsetToTarget = startY * targetStride + startX - start
		int[] target = screen.pixels

		for startY to endY as y
			for start to end as i
				let sourceValue = source[i]
				if sourceValue != 0xff000000 then target[i + offsetToTarget] = sourceValue
			start += tilesStride
			end += tilesStride
			offsetToTarget += targetStride - tilesStride

	private handleClickAndHelp: void() onClick, string help, Vector2 pos, Vector2 size = {1,1}, Vector2 margin = {2,2}
		bool isClick = onClick != null and justPressed LeftMouseButton
		if not isClick and not help then return

		let pointerPos = getPointer()
		// if help == "x" print help, pos - margin, pointerPos, pos + size + margin*2, pos - margin <= pointerPos < pos + size + margin*2
		if pos - margin <= pointerPos < pos + size + margin*2
			if help then helpText = help
			if isClick then onClick()

	global wrapText: string text
		             Vector2 maxSize = screenSize
		int maxColumns = floor(maxSize.x / font.sourceSize.x)
		int maxRows = floor(maxSize.y / font.sourceSize.y)
		string[] lines
		string currentLine
		for text.split " " as word
			if currentLine.length + word.length + 1 > maxColumns
				if lines.length >= maxRows then break
				lines.add currentLine
				currentLine = word
			else
				if currentLine.length > 0 then currentLine += " "
				currentLine += word
		if currentLine.length > 0 then lines.add currentLine
		return lines

	global drawSprite: Sprite sprite
	                   Vector2 pos = {0,0}
					   int frame = 0
					   Color replaceColor = null
					   nocolon Color with = null
					   void() onClick = null
					   string help = ""
					   Color transparentColor = Black
					   Vector2 margin = {0,0}
		if not system.fastForward 
			int positionX = pos.x.floor, positionY = pos.y.floor
			int startX = positionX
			int endX = positionX + sprite.size.x.floor
			int startY = positionY
			int endY = positionY + sprite.size.y.floor
			int targetStride = screen.size.x.floor
			if startX < screen.clipX1 then startX = screen.clipX1
			if endX > screen.clipX2 then endX = screen.clipX2
			if startY < screen.clipY1 then startY = screen.clipY1
			if endY > screen.clipY2 then endY = screen.clipY2
			if startX >= endX or startY >= endY then return
			int spriteStride = sprite.stride
			int actualFrame = frame mod sprite.frames
			int start = (startY - positionY) * spriteStride + startX - positionX + actualFrame * sprite.size.x
			int end = start + endX - startX
			int offsetToTarget = startY * targetStride + startX - start
			int[] source = sprite.pixels, target = screen.pixels
			int transparentValue = transparentColor ? transparentColor.value : 0
			if with == null or replaceColor == with
				for startY to endY as y
					for start to end as i
						let sourceValue = source[i]
						if sourceValue != transparentValue then target[i + offsetToTarget] = sourceValue
					start += spriteStride
					end += spriteStride
					offsetToTarget += targetStride - spriteStride
			else
			if replaceColor
				int fromColor = replaceColor.value
				int toColor = with.value
				for startY to endY as y
					for start to end as i
						let sourceValue = source[i]
						if sourceValue == fromColor then sourceValue = toColor
						if sourceValue != transparentValue then target[i + offsetToTarget] = sourceValue
					start += spriteStride
					end += spriteStride
					offsetToTarget += targetStride - spriteStride
			else
				int singleColor = with.value
				for startY to endY as y
					for start to end as i
						let sourceValue = source[i]
						if sourceValue != transparentValue then target[i + offsetToTarget] = singleColor
					start += spriteStride
					end += spriteStride
					offsetToTarget += targetStride - spriteStride

		handleClickAndHelp onClick, help, pos, sprite.size, margin

	global drawText: string text
	                 Vector2 pos = {0,0}
					 implicit Color color = Colors.White
					 void() onClick = null
					 string help = ""
					 Vector2 margin = {0,0}
		if system.fastForward then return
		int stride = floor(screen.size.x)
		int fontStride = floor(font.charsPerRow * font.sourceSize.x)
		let target = screen.pixels
		int colorValue = color.value
		int charW = floor(font.charSizeWithoutSpacing.x)
		int charH = floor(font.charSizeWithoutSpacing.y)
		int clipX1 = screen.clipX1, clipX2 = screen.clipX2
		int clipY1 = screen.clipY1, clipY2 = screen.clipY2
		Vector2 p = pos
		for text.length
			int char = text.getCharCodeAt(i) - 32
			int glyphX = floor(p.x), glyphY = floor(p.y)
			int tileOffset = floor((char mod 16) * font.sourceSize.x + math.floor(char / 16) * fontStride * font.sourceSize.y)
			int startX = 0, endX = charW
			int startY = 0, endY = charH
			if glyphX + startX < clipX1 then startX = clipX1 - glyphX
			if glyphX + endX > clipX2 then endX = clipX2 - glyphX
			if glyphY + startY < clipY1 then startY = clipY1 - glyphY
			if glyphY + endY > clipY2 then endY = clipY2 - glyphY
			if startX < endX and startY < endY
				int screenOffset = (glyphY + startY) * stride + glyphX
				int tileRow = tileOffset + startY * fontStride
				for startY to endY as y
					for startX to endX as x
						if font.pixels[tileRow + x] then target[screenOffset + x] = colorValue
					screenOffset += stride
					tileRow += fontStride
			p.x += font.sourceSize.x

		// if help then print pos, {font.sourceSize.x * text.length, font.sourceSize.y}, margin
		handleClickAndHelp onClick, help, pos, {font.sourceSize.x * text.length, font.sourceSize.y}, margin

	global void drawRect: Vector2 pos = {0,0}
		                  implicit Vector2 size = {8,8}
						  implicit Color fillColor = null
						  implicit Color outlineColor = null
						  int outlineWidth = 1
					      void() onClick = null
					      string help = ""
					      Vector2 margin = {0,0}
		if system.fastForward then return
		let x = pos.x.floor, y = pos.y.floor
		let sizeX = size.x.ceil, sizeY = size.y.ceil
		let target = screen.pixels
		if fillColor == null and outlineColor == null then fillColor = White
		if fillColor != null
			int stride = floor(screen.size.x)
			int startX = x, endX = x + sizeX
			int startY = y, endY = y + sizeY
			if startX < screen.clipX1 then startX = screen.clipX1
			if endX > screen.clipX2 then endX = screen.clipX2
			if startY < screen.clipY1 then startY = screen.clipY1
			if endY > screen.clipY2 then endY = screen.clipY2
			if startX < endX and startY < endY
				int fillValue = fillColor.value
				int start = startY * stride + startX
				int end = start + endX - startX
				for startY to endY as yy
					for start to end as i
						target[i] = fillValue
					start += stride
					end += stride

		if outlineColor != null and outlineWidth > 0 and outlineColor != fillColor
			drawRect {x,y}, {sizeX, outlineWidth}, fillColor:outlineColor
			drawRect {x, y + sizeY - outlineWidth}, {sizeX, outlineWidth}, fillColor:outlineColor
			drawRect {x, y}, {outlineWidth, sizeY}, fillColor:outlineColor
			drawRect {x + sizeX - outlineWidth, y}, {outlineWidth, sizeY}, fillColor:outlineColor

		handleClickAndHelp onClick, help, pos, size, margin

	global void drawCircle: Vector2 pos = {0,0}
		                    Vector2 radius
							implicit Color fillColor = null
							implicit Color outlineColor = null
							int outlineWidth = 1
					        void() onClick = null
					        string help = ""
					        Vector2 margin = {0,0}
		if system.fastForward then return
		if fillColor == null and outlineColor == null then fillColor = Colors.White
		// TODO: Draw a pixel art cirlce
		
		handleClickAndHelp onClick, help, pos, radius*2, margin

	global void drawCircle: Vector2 pos = {0,0}, float radius = 8, Color fillColor = null, Color outlineColor = null, int outlineWidth = 1
		drawCircle pos, radius:{radius, radius}, fillColor, outlineColor, outlineWidth

	global clip: Vector2 pos = {0,0}
		         Vector2 size = {0,0}
		screen.clipX1 = pos.x atLeast 0
		screen.clipY1 = pos.y atLeast 0
		screen.clipX2 = (pos.x + size.x) atMost screen.size.x
		screen.clipY2 = (pos.y + size.y) atMost screen.size.y

	global stopClipping
		screen.clipX1 = 0
		screen.clipY1 = 0
		screen.clipX2 = screen.size.x.floor
		screen.clipY2 = screen.size.y.floor

enum SpriteType: None, Object, Character, Tile
enum CollisionType: None, Solid, Hazard, OneWayPlatform

Sprite
	int[] pixels
	Vector2 size
	int frames = 1
	int framesPerSecond = 10
	int stride
	
	SpriteType type = SpriteType.None
	CollisionType collisionType = CollisionType.None
	int expectNeighbors = 16
	string name
	string tags
	
	string srcFile
	Vector2 srcPos = Vector2.none
	int set = -1

	Sprite: string[] pixelsAsStrings = null
		if not pixelsAsStrings then return
		let maxWidth = pixelsAsStrings.max.length
		pixels = []
		size.create(floor(maxWidth/frames), pixelsAsStrings.length)
		if frames == int.undefined then frames = 1
		if framesPerSecond == int.undefined then framesPerSecond = 15
		stride = maxWidth
		int index
		for pixelsAsStrings as line
			for line.length as i
				pixels[index + i] = graphics.colorByLetter[line[i]]
			index += maxWidth

	toStrings
		string[] result
		for size.y as y
			string line
			for size.x*frames as x
				int pixelIndex = y * stride + x
				Color color = graphics.getClosestColor(pixels[pixelIndex])
				line += color ? color.letter : " "
			result.add line
		return result
