enum Unit
	pixels = "px" // Pixels
	percent = "%" // Makes the value relative to its parent's value
	fraction = "fr" // Fraction of the available space
	
	centimeters = "cm" // Centimeters
	millimeters = "mm" // Millimeters
	quarterMillimeters = "Q" // Quarter-Millimeters
	inches = "in" // Inches
	picas = "pc" // Picas
	points = "pt" // Points
	
	em = "em" // Font size of the parent (for font-size), font size of the element itself (for other properties)
	ex = "ex" // x-height of the element's font.
	ch = "ch" // The advance measure (width) of the glyph "0" of the element's font
	rem = "rem" // Font size of the root element
	
	lineHeight = "lh" // Line height of the element
	rootLineHeight = "rlh" // Line height of the root element
	
	viewportWidth = "vw" // 1% of the viewport's width
	viewportHeigh = "vh" // 1% of the viewport's height
	viewportMin = "vmin" // 1% of the viewport's smaller dimension
	viewportMax = "vmax" // 1% of the viewport's larger dimension
	viewportBlock = "vb" // 1% of the size of the initial block in the direction of the root element's block axis
	viewportInline = "vi" // 1% of the size of the initial block in the direction of the root element's inline axis
	
	smallViewportWidth = "svw" // 1% of the small viewport's width (without the address bar on mobile)
	smallViewportHeight = "svh" // 1% of the small viewport's height (without the address bar on mobile)
	largeViewportWidth = "lvw" // 1% of the large viewport's width (with the address bar on mobile)
	largeViewportHeight = "lvh" // 1% of the large viewport's height (with the address bar on mobile)
	dynamicViewportWidth = "dvw" // 1% of the dynamic viewport's width (with the address bar on mobile if visible)
	dynamicViewportHeight = "dvh" // 1% of the dynamic viewport's height (with the address bar on mobile if visible)
		
	geoLocation = "geo" // A geographic location on earth (x:longitude, y:latitude)
	
	turns = "turn"    // Turns (one full rotation is 1)
	radians = "rad"   // Radians (one full rotation is 2π)
	degrees = "deg"   // Degrees (one full rotation is 360)
	gradians = "grad" // Gradiants (one full rotation is 400)
	
	auto = "auto"
	none = "none"
	
struct Vector2
	importance:5 float x // The x coordinate of the vector
	importance:5 float y // The y coordinate of the vector
	Unit unit = pixels // The unit of the vector (pixels, percent, centimeters, points, viewportWidth, viewportHeight, ...)
	
	// Used to specify that the vector is not set or invalid
	const Vector2 none = Vector2(float.infinity, float.infinity, none)
	
	// {float.minValue, float.minValue}
	const Vector2 minValue = Vector2(float.minValue, float.minValue, pixels)
	
	// {float.maxValue, float.maxValue}
	const Vector2 maxValue = Vector2(float.maxValue, float.maxValue, pixels)
	
	// {0,0}
	const Vector2 zero = Vector2(0, 0, pixels)
		
	// A string representation of the vector
	toString := "{x}{unit} {y}{unit}"
	
	// Returns true if the vector is not equal to Vector2.None
	bool toBool := (x != float.infinity || y != float.infinity)
		
	// Creates a copy of the vector with the same values
	Vector2 clone() := {x, y, unit}
	
	inline js Vector2 assignReference(Vector2 value) (this = value)
		
	Vector2 assign Vector2 other: x = other.x; y = other.y; unit = other.unit; return this
		
	Vector2 + Vector2 other:   return {x + other.x, y + other.y}
	Vector2 - Vector2 other:   return {x - other.x, y - other.y}
	Vector2 * Vector2 other:   return {x * other.x, y * other.y}
	Vector2 / Vector2 other:   return {x / other.x, y / other.y}
	
	Vector2 * float other:     return {x * other, y * other}
	Vector2 / float other:     return {x / other, y / other}
		
	// The length of the vector
	importance:5 length := math.sqrt(x * x + y * y)
		
	// A vector with each coordinate rounded down to an integer value
	floor := Vector2(math.floor(x), math.floor(y))
	
	// A vector with each coordinate rounded down to an integer value
	ceil := Vector2(math.ceil(x), math.ceil(y))
		
	// A vector with the sign of each coordinate flipped
	inverse := Vector2(-x, -y)
		
	// A vector that points in the same direction, but has a length of 1
	normalized
		let len = math.sqrt(x * x + y * y)
		return len != 0 ? Vector2(x / len, y / len) : Vector2(0, 0)
		
	// The distance to another vector
	distanceTo: Vector2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return math.sqrt(x*x + y*y)
	
enum string AnimationFill
	none = "none"
	forwards = "forwards"
	backwards = "backwards"
	both = "both"
	
enum string FlexDirection
	row = "row" // The flex container's main-axis will be the same as the text direction
	column = "column" // The flex container's main-axis will be the same as the block-axis
	
	rowReverse = "row-reverse" // The flex container's main-axis will be the opposite direction of the text direction
	columnReverse = "column-reverse" // The flex container's main-axis will be the opposite direction of the block-axis
	
enum string FlexWrap
	wrap = "wrap" // The flex items break into multiple lines
	wrapReverse = "wrap-reverse" // Behaves the same as wrap but cross-start and cross-end are permuted
	noWrap = "nowrap" // The flex items are laid out in a single line which may cause the flex container to overflow
	
enum string AlignItems
	start = "start" // The items are individually aligned toward the start edge of the container
	center = "center" // The items are individuallycentered on the secondary axis
	end = "end" // The items are individuallyaligned toward the end edge of the container
	stretch = "stretch" // The items are individually stretched along the secondary axis
	
	normal = "normal" // For flex items, the keyword behaves as stretch
	selfStart = "self-start" // The items are aligned toward the start edge of the container in the items writing mode
	selfEnd = "self-end" // The items are aligned toward the end edge of the container in the items writing mode
	
	baseline = "baseline" // All flex items are aligned such that their flex container baselines align
	firstBaseline= "first baseline" // All flex items are aligned such that their flex container baselines align
	
	flexStart = "flex-start" // The items are individually aligned toward the start edge of the container
	flexEnd = "flex-end" // The items are individuallyaligned toward the end edge of the container

	// Only supported in Firefox
	// LastBaseline = "last baseline" // All flex items are aligned such that their flex container baselines align
	
enum string AlignContent
	start = "start" // When wrapping, the whole content is aligned toward the start edge on the cross axis
	center = "center" // When wrapping, the whole content is centered on the cross axis
	end = "end" // When wrapping, the whole content is aligned toward the end edge on the cross axis
	
	spaceEvenly = "space-evenly" // When wrapping, distribte the lines evenly with the same space around them
	spaceBetween = "space-between" // When wrapping, distribte the lines evenly with no space at the top and bottom
	spaceAround = "space-around" // When wrapping, distribte the lines with the same margins around them
	
	normal = "normal" // The items are packed in their default position as if no align-content value was set
	baseline = "baseline" // When wrapping, the whole content is aligned so the baseline match on the cross axis
	stretch = "stretch" // When wrapping, stretch the whole content so the container is completely filled
	
	flexStart = "flex-start" // When wrapping, the whole content is aligned toward the start edge on the cross axis
	flexEnd = "flex-end" // When wrapping, the whole content is aligned toward the end edge on the cross axis
	
enum string JustifyContent
	start = "start" // The whole content is aligned toward the start edge on the main axis
	center = "center" // The whole content is centered on the main axis
	end = "end" // The whole content is aligned toward the end edge on the main axis
	
	spaceEvenly = "space-evenly" // Distribte the items evenly with the same space around them
	spaceBetween = "space-between" // Distribte the items evenly with no space at the top and bottom
	spaceAround = "space-around" // Distribte the items with the same margins around them
	
	normal = "normal" // The items are packed in their default position as if no justify-content value was set
	baseline = "baseline" // The whole content is aligned so the baseline match on the cross axis
	
	flexStart = "flex-start" // The items are packed flush to each other toward the start edge of the alignment container in the main axis.
	flexEnd = "flex-end" // The items are packed flush to each other toward the end edge of the alignment container in the main axis.
	
	// Added in Chrome 93
	// Left = "left" // The items are packed flush to each other toward the left edge of the alignment container. If the property's axis is not parallel with the inline axis, this value behaves like start.
	// Right = "right" // The items are packed flush to each other toward the right edge of the alignment container in the appropriate axis. If the property's axis is not parallel with the inline axis, this value behaves like start.
	
	// Only supported in Firefox
	// Safe = "safe" // Used alongside an alignment keyword. If the chosen keyword means that the item overflows the alignment container causing data loss, the item is instead aligned as if the alignment mode were start.
	// Unsafe = "unsafe" // Used alongside an alignment keyword. Regardless of the relative sizes of the item and alignment container, and regardless of whether overflow which causes data loss might happen, the given alignment value is honored.

	// Not supported for flexbox
	// Stretch = "stretch" // Stretch the whole content so the container is completely filled
	
enum string Display
	flex = "flex" // A block element that lays out its content according to the flexbox model
	grid = "grid" // A block element that lays out its content according to the grid model
	table = "table" // A block element that  behave like HTML <table> element
	
	block = "block" // A block element, generates line breaks before and after the element when in the normal flow
	inline = "inline" // An inline element, will be on the same line without line breaks in the normal flow
	
	inlineBlock = "inline-block" // A block element that will be flowed with surrounding content (like an image)
	inlineFlex = "inline-flex" // An inline element that lays out its content according to the flexbox model
	inlineGrid = "inline-grid" // An inline element that lays out its content according to the grid model
	inlineTable = "inline-table" // An inline element that  behave like HTML <table> element
	
	contents = "contents" // These elements don't produce a specific box by themselves
	flowRoot = "flow-root" // A block element that establishes a new block formatting context
	
	none = "none" // Turns off the display of an element so that it has no effect on layout
	
enum string Cursor
	pointer = "pointer" // The cursor is a pointer that indicates a link, typically an image of a pointing hand
	default = "default" // The platform-dependent default cursor, typically an arrow
	grab = "grab" // Something can be grabbed (dragged to be moved)
	grabbing = "grabbing" // Something is being grabbed (dragged to be moved)
	noDrop = "no-drop" // An item may not be dropped at the current location
	notAllowed = "not-allowed" // The requested action will not be carried out
	move = "move" // Something is to be moved
	copy = "copy" // Something is to be copied
	contextMenu = "context-menu" // A context menu is available
	help = "help" // Help information is available
	progress = "progress" // The program is busy in the background, but the user can still interact with the interface
	wait = "wait" // The program is busy, and the user can't interact with the interface
	cell = "cell" // The table cell or set of cells can be selected
	crosshair = "crosshair" // Cross cursor, often used to indicate selection in a bitmap
	text = "text" // The text can be selected Typically the shape of an I-beam
	verticalText = "vertical-text" // The vertical text can be selected, typically the shape of a sideways I-beam
	alias = "alias" // An alias or shortcut is to be created
	allScroll = "all-scroll" // Something can be scrolled in any direction (on Windows, all-scroll is the same as move)
		
	resizecol = "col-resize" // The column can be resized horizontally, typically an left-right arrow with a vertial line
	resizeRow = "row-resize" // The row can be resized vertically, typically an up-down arrow with a horizontal line
	resizeN = "n-resize" // The top of of box can be moved
	resizeE = "e-resize" // The right of of box can be moved
	resizeS = "s-resize" // The bottom of of box can be moved
	resizeW = "w-resize" // The left of of box can be moved
	resizeNE = "ne-resize" // The top right corner of a box can be moved
	resizeNW = "nw-resize" // The top left corner of a box can be moved
	resizeSE = "se-resize" // The bottom right corner of a box can be moved
	resizeSW = "sw-resize" // The bottom left corner of a box can be moved
	resizeEW = "ew-resize" // Something can be moved left and right
	resizeNS = "ns-resize" // Something can be moved up and down
	resizeNESW = "nesw-resize" // Something can be moved diagonally from the bottom left to the top right
	resizeNWSE = "nwse-resize" // Something can be moved diagonally from the top left to the bottom right
	
	zoomIn = "zoom-in" // Something can be zoomed in
	zoomOut = "zoom-out" // Something can be zoomed out	
	
	auto = "auto" // The cursor will be based on the current context, for example "text" when hovering text
	none = "none" // No cursor is rendered
	
enum string Position
	absolute = "absolute" // Remove the element from the normal flow, it can be moved with top, right, bottom and left
	relative = "relative" // Position the element in the normal flow, it can be moved with top, right, bottom and left
	fixed = "fixed" // Remove from the element from the normal flow and fix its position
	sticky = "sticky" // Position the element in the normal flow and fix its position
	static = "static" // Position the element in the normal flow of the document
	
enum string TextAlign
	left = "left" // The inline contents are aligned to the left edge of the line box
	center = "center" // The inline contents are centered within the line box
	right = "right" // The inline contents are aligned to the right edge of the line box
	justify = "justify" // The inline contents are justified
	
	start = "start" // The same as left if direction is left-to-right and right if direction is right-to-left
	end = "end" // The same as right if direction is left-to-right and left if direction is right-to-left
	
	matchParent = "match-parent" // Similar to inherit, but the values are calculated according to the parent's direction
	
enum string TextOverflow
	ellipsis = "ellipsis" // Use this to show "..." when text is too long
	clip = "clip" // Use the default behavior

enum string FontStyle
	normal = "normal" // The standard font style
	italic = "italic" // Italic is a way to emphasise key points in a printed text, to identify many types of creative works, to cite foreign words or phrases
	oblique = "oblique" // If no oblique version of the font is available, the italic style is used

enum string Overflow: 
	hidden = "hidden" // Content is clipped if necessary to fit the padding box.
	scroll = "scroll" // Content is clipped if necessary to fit the padding box and a scrollbar is shown.
	visible = "visible" // Content is not clipped, it may be rendered outside the padding box.
	auto = "auto" // Use the default behavior, which is visible.

enum string WhiteSpace
	noWrap = "nowrap" // Collapses white space as for normal and suppresses line breaks (text wrapping).
	pre = "pre" // Sequences of white space are preserved. Lines are only broken at newline characters and at <br>.
	preWrap = "pre-wrap" // Sequences of white space are preserved. Lines are broken as necessary to fill line boxes.
	preLine = "pre-line" // Sequences of white space are collapsed. Lines are broken as necessary to fill line boxes.
	breakSpaces = "break-spaces" // Sequences of white space are preserved. Lines can be broken at arbitrary points.
	normal = "normal" // Sequences of white space are collapsed. Lines are broken as necessary to fill line boxes.

importance:5 enum string BorderStyle
	solid = "solid" // Displays a single, straight, solid line
	dotted = "dotted" // Displays a series of rounded dots
	dashed = "dashed" // Displays a series of short square-ended dashes or line segments
	double = "double" // Displays two straight lines that add up to the pixel size defined by border-width
	groove = "groove" // Displays a border with a carved appearance (the opposite of ridge)
	ridge = "ridge" // Displays a border with an extruded appearance (the opposite of groove)
	inset = "inset" // Displays a border that makes the element appear embedded (the opposite of outset)
	outset = "outset" // Displays a border that makes the element appear embossed (the opposite of inset)
	hidden = "hidden" // Displays no border
	none = "none" // Displays no border

enum string ObjectFit
	contain = "contain" // The replaced content is scaled to maintain its aspect ratio while fitting within the element's content box. The entire object is made to fill the box, while preserving its aspect ratio, so the object will be "letterboxed" or "pillarboxed" if its aspect ratio does not match the aspect ratio of the box.
	cover = "cover" // The replaced content is sized to maintain its aspect ratio while filling the element's entire content box. If the object's aspect ratio does not match the aspect ratio of its box, then the object will be clipped to fit.
	fill = "fill" // The replaced content is sized to fill the element's content box. The entire object will completely fill the box. If the object's aspect ratio does not match the aspect ratio of its box, then the object will be stretched to fit.
	none = "none" // The replaced content is not resized.
	scaleDown = "scale-down" // The content is sized as if none or contain were specified, whichever would result in a smaller concrete object size.

enum string PointerEvents
	none // On its own, it doesn't trigger pointer event, but its subtree could by setting pointerEvents 
	auto // The element behaves as it would if the pointerEvents property were not specified
	
enum string InputType
	text // The default value. A single-line text field. Line-breaks are automatically removed from the input value.	
	email // A field for editing an email address. Looks like a text input, but has validation parameters and relevant keyboard in supporting browsers and devices with dynamic keyboards.	
	password // A single-line text field whose value is obscured. Will alert user if site is not secure.	
	number // A control for entering a number. Displays a spinner and adds default validation. Displays a numeric keypad in some devices with dynamic keypads.	
	range // A control for entering a number whose exact value is not important. Displays as a range widget defaulting to the middle value. Used in conjunction min and max to define the range of acceptable values.	
	tel	// A control for entering a telephone number. Displays a telephone keypad in some devices with dynamic keypads.	
	url	// A field for entering a URL. Looks like a text input, but has validation parameters and relevant keyboard in supporting browsers and devices with dynamic keyboards.	
	date // A control for entering a date (year, month, and day, with no time). Opens a date picker or numeric wheels for year, month, day when active in supporting browsers.	
	time // A control for entering a time value with no time zone.	
	datetime = "datetime-local" // A control for entering a date and time, with no time zone. Opens a date picker or numeric wheels for date- and time-components when active in supporting browsers.	
	month // A control for entering a month and year, with no time zone.	
	week // A control for entering a date consisting of a week-year number and a week number with no time zone.
	color // A control for specifying a color; opening a color picker when active in supporting browsers.	
	search	// A single-line text field for entering search strings. Line-breaks are automatically removed from the input value. May include a delete icon in supporting browsers that can be used to clear the field. Displays a search icon instead of enter key on some devices with dynamic keypads.	
	hidden // A control that is not displayed but whose value is submitted to the server. There is an example in the next column, but it's hidden!	
	
enum string TextDecoration
	none = "none" // No text decoration
	underline = "underline" // A line below the text
	overline = "overline" // A line above the text
	linethrough = "line-through" // A line through the text

importance:5 struct Dimension
	global const Dimension auto = {dimensionString:"auto"} // Automatically adjust the value to distribute the space evenly

	string dimensionString
	toString := dimensionString
		
	Dimension: float value        // The value in the specified unit
		       Unit unit = pixels // The unit of the value (pixels, percent, centimeters, points, viewportWidth, viewportHeight, ...)
		dimensionString = "{value}{unit}"

	Dimension: string dimensionString
		this.dimensionString = dimensionString
	
	// bool toBool := value != 0

	inline Padding toPadding() Padding(this, this, this, this)
	inline Margin toMargin() Margin(this, this, this, this)
	
importance:5 class Border
	global const Border none = {borderString:"none"} // Display no border
		
	string borderString
	toString := borderString

	Border: string borderString // Specify all parameters as a single string, e.g. "1px solid #808080"
		this.borderString = borderString
	
	Border: implicit Dimension width = 1px // The thickness of the border
	        BorderStyle style = solid      // The style of the border
            Color color = black            // The color of the border. You can use a color literal to define a color, e.g. color:#ff0000
		borderString = "{width} {style} {color}"

importance:5 class BoxShadow
	string boxShadowString
	toString := boxShadowString

	BoxShadow: string boxShadowString // Specify all parameters as a single string, e.g. "10px 5px 5px #808080"
		this.boxShadowString = boxShadowString

	BoxShadow: Vector2 offset                  // How far should the shadow be away from the element as a vector, e.g. {10px, 10px}
		       implicit Dimension blur = 8px   // How blurry should the shadow be?
		       implicit Dimension spread = 8px // Positive values will make the shadow bigger, negative values make it smaller
		       Color color = black             // The color of the shadow. You can use a color literal to define a color, e.g. color:#ff0000
		       bool inset = false              // Changes the shadow to one inside the frame (as if the content was debossed inside the box)
		boxShadowString = "{inset ? "inset ":""}{offset.x}{offset.unit} {offset.y}{offset.unit} {blur} {spread} {color}"

	BoxShadow: implicit Dimension offsetX = 0px // How far should the shadow be away from the element in the x direction?
		       implicit Dimension offsetY = 0px // How far should the shadow be away from the element in the y direction?
		       implicit Dimension blur = 8px    // How blurry should the shadow be?
		       implicit Dimension spread = 8px  // Positive values will make the shadow bigger, negative values make it smaller
		       Color color = black              // The color of the shadow. You can use a color literal to define a color, e.g. color:#ff0000
		       bool inset = false               // Changes the shadow to one inside the frame (as if the content was debossed inside the box)
		boxShadowString = "{inset ? "inset ":""}{offsetX} {offsetY} {blur} {spread} {color}"

importance:5 class Padding
	string paddingString
	toString := paddingString

	Padding: implicit Dimension all // Padding on the top, right, bottom and left of the element
		paddingString = "{all}"

	Padding: implicit Dimension topAndBottom // Padding on the top and bottom of the element
		     implicit Dimension leftAndRight // Padding on the left and right of the element
		paddingString = "{topAndBottom} {leftAndRight}"

	Padding: implicit Dimension top = 0 px    // Padding on the top of the element
		     implicit Dimension right = 0 px  // Padding on the right of the element
		     implicit Dimension bottom = 0 px // Padding on the bottom of the element
		     implicit Dimension left = 0 px   // Padding on the left of the element
		paddingString = "{top} {right} {bottom} {left}"

	Padding: string paddingString
		this.paddingString = paddingString
	
importance:5 class Margin
	string marginString
	toString := marginString

	Margin: implicit Dimension all // Margin on the top, right, bottom and left of the element
		marginString = "{all}"

	Margin: implicit Dimension topAndBottom = 0 px // Margin on the top and bottom of the element
		    implicit Dimension leftAndRight = 0 px // Margin on the left and right of the element
		marginString = "{topAndBottom} {leftAndRight}"

	Margin: implicit Dimension top = 0 px    // Margin on the top of the element
		    implicit Dimension right = 0 px  // Margin on the right of the element
		    implicit Dimension bottom = 0 px // Margin on the bottom of the element
		    implicit Dimension left = 0 px   // Margin on the left of the element
		marginString = "{top} {right} {bottom} {left}"

	Margin: string marginString
		this.marginString = marginString

importance:5 class FontWeight
	global const FontWeight normal = {fontWeightString:"normal"} // Normal font weight. Same as 400.
	global const FontWeight bold = {fontWeightString:"bold"} // Bold font weight. Same as 700.
	global const FontWeight lighter = {fontWeightString:"lighter"} // One relative font weight lighter than the parent element.
	global const FontWeight bolder = {fontWeightString:"bolder"} // One relative font weight heavier than the parent element.

	string fontWeightString
	toString := fontWeightString

	FontWeight: string fontWeightString
		this.fontWeightString = fontWeightString
	
	FontWeight: float weight // A value from 1 to 1000. Higher values mean bolder, lower numbers mean lighter. 
		fontWeightString = "{weight}"

struct float
	implicit inline Padding toPadding() new Padding(this, this, this, this)
	implicit inline Margin toMargin() new Margin(this, this, this, this)
	implicit inline FontWeight toFontWeight() new FontWeight(weight:this)

class string
	implicit inline Dimension toDimension() new Dimension(dimensionString:this)
	implicit inline Border toBorder() new Border(borderString:this)
	implicit inline BoxShadow toBoxShadow() new BoxShadow(boxShadowString:this)
	implicit inline Padding toPadding() new Padding(paddingString:this)
	implicit inline Margin toMargin() new Margin(marginString:this)
	implicit inline FontWeight toFontWeight() new FontWeight(fontWeightString:this)

enum string FileInputCaptureMode
	none = "" // Do not capture an image with the camera
	user // Capture the image from the front-facing camera
	environment // Capture the image from the backwards-facing camera

enum string AlignSelf
	auto // Use the parent's align-items value.
	normal // Use the element's default alignment.
	selfStart = "self-start" // Aligns the items to be flush with the edge of the alignment container corresponding to the item's start side in the cross axis.
	selfEnd = "self-end" // Aligns the items to be flush with the edge of the alignment container corresponding to the item's end side in the cross axis.
	flexStart = "flex-start" // The cross-start margin edge of the flex item is flushed with the cross-start edge of the line.
	flexEnd = "flex-end" // The cross-end margin edge of the flex item is flushed with the cross-end edge of the line.
	center // The flex item's margin box is centered within the line on the cross-axis. If the cross-size of the item is larger than the flex container, it will overflow equally in both directions.
	baseline // Specifies participation in first- or last-baseline alignment: aligns the alignment baseline of the box's first or last baseline set with the corresponding baseline in the shared first or last baseline set of all the boxes in its baseline-sharing group.
	firstBaseline = "first baseline" // Like baseline, but the fallback alignment is start.
	lastBaseline = "last baseline" // Like baseline, but the fallback alignment is end.
	stretch // If the item's cross-size is auto, the used size is set to the length necessary to be as close to filling the container as possible, respecting the item's width and height limits. If the item is not auto-sized, this value falls back to flex-start, and to self-start or self-end if the container's align-content is first baseline (or baseline) or last baseline.
	anchorCenter = "anchor-center" // In the case of anchor-positioned elements, aligns the item to the center of the associated anchor element in the block direction. See Centering on the anchor using anchor-center.
	safe // If the size of the item overflows the alignment container, the item is instead aligned as if the alignment mode were start.
	unsafe // Regardless of the relative sizes of the item and alignment container, the given alignment value is honored.
	
importance:5 dynamic Style
	// Align the individual items along the cross axis. 
	// Possible values: start, center, end, stretch, normal, selfStart, selfEnd, baseline, firstBaseline, flexStart, flexEnd
	// Example:
	//     div display:flex, flexDirection:column, width:100%
	//         div "CenteredText", alignItems:center
	AlignItems alignItems
	// When wrapping, align the whole content along the cross axis. 
	// Possible values: start, center, end, spaceEvenly, spaceBetween, spaceAround, normal, baseline, stretch, flexStart, flexEnd
	AlignContent alignContent
	AlignSelf alignSelf // Overrides a grid or flex item's align-items value. In grid, it aligns the item inside the grid area. In flexbox, it aligns the item on the cross axis.
	string animation // A shorthand property for all the animation properties, except the animationPlayState
	string animationDelay // When the animation will start
	string animationDirection // Whether or not the animation should play in reverse on alternate cycles
	string animationDuration // How many seconds or milliseconds an animation takes to complete one cycle
	string animationFillMode // What values are applied by the animation outside the time it is executing
	string animationIterationCount // The number of times an animation should be played
	string animationName // A name for the @keyframes animation
	string animationTimingFunction // The speed curve of the animation
	string animationPlayState // Whether the animation is running or paused
	string background // All the background properties in one declaration
	string backgroundAttachment // Whether a background-image is fixed or scrolls with the page
	// The background-color of an element. You can use a color literal to define a color, e.g. backgroundColor:#ff0000
	// Example:
	//     div "Abort", backgroundColor:#ff0000
	Color backgroundColor
	// The background-image for an element. 
	// Place an image in the folder "assets/pb_public/media" and it will automatically show up in the auto completions (without the file extension).
	// 
	// Example: We place the image "OkButton.png" in "assets/pb_public/media".
	//     div backgroundImage:OkButton
	Image backgroundImage // The background-image for an element
	string backgroundPosition // The starting position of a background-image
	string backgroundRepeat // How to repeat (tile) a background-image
	string backgroundClip // The painting area of the background
	string backgroundOrigin // The positioning area of the background images
	string backgroundSize // The size of the background image
	string backfaceVisibility // Whether or not an element should be visible when not facing the screen
	// The border of an element. 
	// Example:
	//     div "Text with border", border:{width:2px, style:solid, color:#ff0000}
	Border border
	Border borderBottom // All the borderBottom properties in one declaration
	Color borderBottomColor // The color of the bottom border. You can use a color literal to define a color, e.g. borderBottomColor:#ff0000
	implicit Dimension borderBottomLeftRadius // The shape of the border of the bottom-left corner
	implicit Dimension borderBottomRightRadius // The shape of the border of the bottom-right corner
	BorderStyle borderBottomStyle // The style of the bottom border
	implicit Dimension borderBottomWidth // The width of the bottom border
	string borderCollapse // Whether the table border should be collapsed into a single border, or not
	Color borderColor // The color of an element's border. You can use a color literal to define a color, e.g. borderColor:#ff0000
	string borderImage // A shorthand property for setting or returning all the borderImage properties
	implicit Dimension borderImageOutset // The amount by which the border image area extends beyond the border box
	string borderImageRepeat // Whether the image-border should be repeated, rounded or stretched
	string borderImageSlice // The inward offsets of the image-border
	string borderImageSource // The image to be used as a border
	implicit Dimension borderImageWidth // The widths of the image-border
	Border borderLeft // All the borderLeft properties in one declaration
	Color borderLeftColor // The color of the left border
	BorderStyle borderLeftStyle // The style of the left border
	implicit Dimension borderLeftWidth // The width of the left border
	implicit Dimension borderRadius // A shorthand property for setting or returning all the four borderRadius properties
	Border borderRight // All the borderRight properties in one declaration
	Color borderRightColor // The color of the right border. You can use a color literal to define a color, e.g. borderRightColor:#ff0000
	BorderStyle borderRightStyle // The style of the right border
	implicit Dimension borderRightWidth // The width of the right border
	implicit Dimension borderSpacing // The space between cells in a table
	BorderStyle borderStyle // The style of an element's border (can have up to four values)
	Border borderTop // All the borderTop properties in one declaration
	Color borderTopColor // The color of the top border. You can use a color literal to define a color, e.g. borderTopColor:#ff0000
	implicit Dimension borderTopLeftRadius // The shape of the border of the top-left corner
	implicit Dimension borderTopRightRadius // The shape of the border of the top-right corner
	BorderStyle borderTopStyle // The style of the top border
	implicit Dimension borderTopWidth // The width of the top border
	implicit Dimension borderWidth // The width of an element's border (can have up to four values)
	implicit Dimension bottom // The bottom position of a positioned element
	string boxDecorationBreak // The behaviour of the background and border at page-break or line-break
	// Draws one or more drop-shadows to the box. 
	// Example:
	//     div "Text with box shadow", boxShadow:{offset:{8,8}, blur:50, spread:10, color:#c0c0c0}
	BoxShadow boxShadow
	string boxSizing // Allows you to define certain elements to fit an area in a certain way
	string captionSide // The position of the table caption
	Color caretColor // The caret/cursor color of an element. You can use a color literal to define a color, e.g. caretColor:#ff0000
	string clear // The position of the element relative to floating objects
	string clip // Which part of a positioned element is visible
	// The color of the text. You can use a color literal to define a color, e.g. color:#ff0000
	// Example:
	//     app
	//         Color mainColor = #ff0000
	//         draw
	//            div "Red text", color:mainColor
	//            div "Blue text", color:#0000ff
	Color color
	string columnCount // The number of columns an element should be divided into
	string columnFill // How to fill columns
	implicit Dimension columnGap // The gap between the columns
	string columnRule // A shorthand property for setting or returning all the columnRule properties
	Color columnRuleColor // The color of the rule between columns. You can use a color literal to define a color, e.g. columnRuleColor:#ff0000
	string columnRuleStyle // The style of the rule between columns
	implicit Dimension columnRuleWidth // The width of the rule between columns
	string columns // A shorthand property for setting or returning columnWidth and columnCount
	int columnSpan // How many columns an element should span across
	implicit Dimension columnWidth // The width of the columns
	string content // Used with the :before and :after pseudo-elements, to insert generated content
	string counterIncrement // Increments one or more counters
	string counterReset // Creates or resets one or more counters
	Cursor cursor // The type of cursor to display for the mouse pointer
	string direction // The text direction
	Display display // An element's display type
	string emptyCells // Whether to show the border and background of empty cells, or not
	string filter // Image filters (visual effects, like blur and saturation)
	implicit string flex // The length of the item, relative to the rest
	implicit Dimension flexBasis // The initial length of a flexible item
	// The direction of the flexible items. 
	// Possible values: row, rowReverse, column, columnReverse
	// Example:
	//     div display:flex, flexDirection:column, width:100%
	//         for items as item
	//             div text:item.text
	FlexDirection flexDirection
	string flexFlow // A shorthand property for the flexDirection and the flexWrap properties
	float flexGrow // How much the item will grow relative to the rest
	float flexShrink // How the item will shrink relative to the rest
	// Whether the flexible items should wrap or not. 
	// Possible values: noWrap, wrap, wrapReverse
	// Example:
	//     div display:flex, flexWrap:wrap, width:100%
	//         for items as item
	//             div text:item.text
	FlexWrap flexWrap
	string cssFloat // The horizontal alignment of an element
	string font // FontStyle, fontVariant, fontWeight, fontSize, lineHeight, and fontFamily in one declaration
	string fontFamily // The font family for text
	implicit Dimension fontSize // The font size of the text
	// Whether the style of the font is normal, italic or oblique. 
	// Example:
	//     div "Hello", fontStyle:italic
	FontStyle fontStyle
	string fontVariant // Whether the font should be displayed in small capital letters
	// The boldness of the font. 
	// Possible values: normal, bold, lighter, bolder, or a number from 1 to 1000. Higher values mean bolder, lower numbers mean lighter. 
	// Example:
	//     div "Bold text", fontWeight:bold
	FontWeight fontWeight 
	string fontSizeAdjust // Preserves the readability of text when font fallback occurs
	string fontStretch // Selects a normal, condensed, or expanded face from a font family
	implicit Dimension gap // The gap between rows or columns
	string hangingPunctuation // Specifies whether a punctuation character may be placed outside the line box
	implicit Dimension height // The height of an element
	string hyphens // Sets how to split words to improve the layout of paragraphs
	string icon // Provides the author the ability to style an element with an iconic equivalent
	string imageOrientation // Specifies a rotation in clockwise direction appied to an image
	string isolation // Defines whether an element must create a new stacking content
	// Justify the whole content along the main axis (as in "justified text"). 
	// Possible values: start, center, end, spaceEvenly, spaceBetween, spaceAround, normal, baseline, flexStart, flexEnd
	// Example:
	//     div display:flex, flexDirection:row, justifyContent:center, width:100%
	//         div "This is centered horizontally"
	JustifyContent justifyContent
	implicit Dimension left // The left position of a positioned element
	implicit Dimension letterSpacing // The space between characters in a text
	string lineHeight // The distance between lines in a text
	string listStyle // ListStyleImage, listStylePosition, and listStyleType in one declaration
	string listStyleImage // An image as the list-item marker
	string listStylePosition // The position of the list-item marker
	string listStyleType // The list-item marker type
	implicit Margin margin // Can be single float like 8 an object like {top:8, right:8, bottom:8, left:8}
	implicit Margin inset // A shorthand for the top, right, bottom, left properties
	implicit Dimension marginBottom // The bottom margin of an element
	implicit Dimension marginLeft // The left margin of an element
	implicit Dimension marginRight // The right margin of an element
	implicit Dimension marginTop // The top margin of an element
	implicit Dimension maxHeight // The maximum height of an element
	implicit Dimension maxWidth // The maximum width of an element
	implicit Dimension minHeight // The minimum height of an element
	implicit Dimension minWidth // The minimum width of an element
	string navDown // Where to navigate when using the arrow-down navigation key
	string navIndex // The tabbing order for an element
	string navLeft // Where to navigate when using the arrow-left navigation key
	string navRight // Where to navigate when using the arrow-right navigation key
	string navUp // Where to navigate when using the arrow-up navigation key
	ObjectFit objectFit // Specifies how the contents of a replaced element should be fitted its box
	string objectPosition // Specifies the alignment of the replaced element inside its box
	float opacity // The opacity level for an element
	int order // The order of the flexible item, relative to the rest
	string orphans // The minimum number of lines that must be left at the bottom before a page-break
	Border outline // All the outline properties in one declaration
	Color outlineColor // The color of the outline around a element. You can use a color literal to define a color, e.g. outlineColor:#ff0000
	string outlineOffset // Offsets an outline, and draws it beyond the border edge
	string outlineStyle // The style of the outline around an element
	implicit Dimension outlineWidth // The width of the outline around an element
	Overflow overflow // What to do with content that renders outside the element box
	Overflow overflowX // Specifies what to do with the left/right edges of content rendering outside the element box
	Overflow overflowY // Specifies what to do with the top/bottom edges of content rendering outside the element box
	implicit Padding padding // Can be single float like 8 an object like {top:8, right:8, bottom:8, left:8}
	implicit Dimension paddingBottom // The bottom padding of an element
	implicit Dimension paddingLeft // The left padding of an element
	implicit Dimension paddingRight // The right padding of an element
	implicit Dimension paddingTop // The top padding of an element
	string pageBreakAfter // The page-break behavior after an element
	string pageBreakBefore // The page-break behavior before an element
	string pageBreakInside // The page-break behavior inside an element
	string perspective // The perspective on how 3D elements are viewed
	string perspectiveOrigin // The bottom position of 3D elements
	// The type of positioning method used for an element. 
	// Possible values: absolute, relative, fixed, sticky, static
	// Example:
	//     div position:absolute, left:0px, top:0px
	//         div "This is positioned in the top left corner"
	Position position 
	string quotes // The type of quotation marks for embedded quotations
	string resize // Whether or not an element is resizable by the user
	implicit Dimension right // The right position of a positioned element
	string scrollBehavior // Specifies whether to smoothly animate the scroll position when a link is clicked
	string tableLayout // The way to lay out table cells, rows, and columns
	string tabSize // The length of the tab-character
	// The horizontal alignment of text. 
	// Possible values: left, center, right, justify, start, end, matchParent
	// Example:
	//     div textAlign:center text:"This is centered horizontally"
	TextAlign textAlign 
	string textAlignLast // How the last line of a block is aligned when text-align is "justify"
	TextDecoration textDecoration // The decoration of a text
	Color textDecorationColor // The color of the text-decoration. You can use a color literal to define a color, e.g. textDecorationColor:#ff0000
	string textDecorationLine // The type of line in a text-decoration
	string textDecorationStyle // The style of the line in a text decoration
	string textIndent // The indentation of the first line of text
	string textJustify // The justification method used when text-align is "justify"
	// What should happen when text overflows the containing element. 
	// Possible values: ellipsis, clip
	// Example:
	//     div textOverflow:ellipsis text:"This is an example of text overflow"
	TextOverflow textOverflow 
	string textShadow // The shadow effect of a text
	string textTransform // The capitalization of a text
	implicit Dimension top // The top position of a positioned element
	string transform // Applies a 2D or 3D transformation to an element
	string transformOrigin // The position of transformed elements
	string transformStyle // How nested elements are rendered in 3D space
	string transition // A shorthand property for setting or returning the four transition properties
	string transitionProperty // The CSS property that the transition effect is for
	string transitionDuration // How many seconds or milliseconds a transition effect takes to complete
	string transitionTimingFunction // The speed curve of the transition effect
	string transitionDelay // When the transition effect will start
	string unicodeBidi // Whether the text should be overridden to support multiple languages in the same document
	string userSelect // Whether the text of an element can be selected or not
	string verticalAlign // The vertical alignment of the content in an element
	string visibility // Whether an element should be visible
	WhiteSpace whiteSpace // How to handle tabs, line breaks and whitespace in a text
	implicit Dimension width // The width of an element
	string wordBreak // Line breaking rules for non-CJK scripts
	string wordSpacing // The spacing between words in a text
	string wordWrap // Allows long, unbreakable words to be broken and wrap to the next line
	string widows // The minimum number of lines for an element that must be visible at the top of a page
	int zIndex // The stack order of a positioned element
	string gridTemplateColumns // The line names and track sizing functions of the grid columns
	PointerEvents pointerEvents
	
	Vector2 translate // Move the element by this vector
	implicit Angle rotate // Rotate the element by this angle
	
	Vector2 size
	bool overlay
		
