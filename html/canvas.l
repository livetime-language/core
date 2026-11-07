// A canvas that fills its html element. Its backing store follows the element's size and the devicePixelRatio, all coordinates are in css pixels.
// Example:
//     app
//         draw
//             html.canvas width:200, height:100
//                 canvas.drawRectangle pos:{0,0}, size:{100,100}, color:red, radius:8
//                 canvas.drawText "Hello", pos:{10,60}, font:{family:"Inter", size:20, weight:600}
Canvas
	HTMLElement element
	dynamic context
	float pixelRatio = 1
	Vector2 size	// The size of the element in css pixels
	void() onResize = null	// Called after the size or the pixel ratio changed, which clears the canvas
	private CanvasFont font
	private string fillStyle

	Canvas: HTMLElement element
		this.element = element
		context = element.getContext("2d")
		observeSize

	// Keeps the backing store at the element's size × devicePixelRatio, also when the window moves to a screen with another pixel ratio
	private js void observeSize
		const resize = (width, height) => {
			this.pixelRatio = devicePixelRatio
			this.size = new Vector2(this.element.clientWidth, this.element.clientHeight, "px")
			width = width || Math.round(this.size.x * this.pixelRatio)
			height = height || Math.round(this.size.y * this.pixelRatio)
			if(this.element.width == width && this.element.height == height) return
			this.element.width = width
			this.element.height = height
			this.font = null
			this.fillStyle = null
			this.context.setTransform(this.pixelRatio, 0, 0, this.pixelRatio, 0, 0)
			this.onResize?.invoke()
		}
		new ResizeObserver(entries => {
			const box = entries[0].devicePixelContentBoxSize?.[0]
			resize(box?.inlineSize, box?.blockSize)
		}).observe(this.element)
		const watchPixelRatio = () => matchMedia(`(resolution: ${devicePixelRatio}dppx)`).addEventListener("change", () => { resize(); watchPixelRatio() }, {once:true})
		watchPixelRatio()
		resize()

	// Clear the whole canvas
	inline js void clear() this.context.clearRect(0, 0, this.size.x, this.size.y)

	// Save the transform and clipping, restore them with restore
	js void save
		this.context.save()

	js void restore
		this.context.restore()
		this.font = null
		this.fillStyle = null

	// Move the origin of all following drawing operations
	inline js void translate(Vector2 offset) this.context.translate(offset.x, offset.y)

	// Restrict all following drawing operations to a rectangle (until restore)
	js void clip: Vector2 pos
		          Vector2 size
		this.context.beginPath()
		this.context.rect(pos.x, pos.y, size.x, size.y)
		this.context.clip()

	// Draw a filled rectangle, with rounded corners if radius is set
	js void drawRectangle: Vector2 pos
		                   Vector2 size
		                   Color color = black
		                   float radius = 0
		this.setFillStyle(color.colorString)
		if(radius <= 0) { this.context.fillRect(pos.x, pos.y, size.x, size.y); return }
		this.context.beginPath()
		this.context.roundRect(pos.x, pos.y, size.x, size.y, Math.min(radius, size.x/2, size.y/2))
		this.context.fill()

	// Draw the outline of a rectangle, with rounded corners if radius is set
	js void strokeRectangle: Vector2 pos
		                     Vector2 size
		                     Color color = black
		                     float width = 1
		                     float radius = 0
		this.context.strokeStyle = color.colorString
		this.context.lineWidth = width
		this.context.beginPath()
		this.context.roundRect(pos.x + width/2, pos.y + width/2, size.x - width, size.y - width, Math.max(0, radius - width/2))
		this.context.stroke()

	// Draw a filled polygon
	js void drawPolygon: Vector2[] points
		                 Color color = black
		this.setFillStyle(color.colorString)
		this.context.beginPath()
		for(const p of points) this.context.lineTo(p.x, p.y)
		this.context.fill()

	// Draw a straight line
	js void drawLine: Vector2 from
		              Vector2 to
		              Color color = black
		              float width = 1
		this.context.strokeStyle = color.colorString
		this.context.lineWidth = width
		this.context.beginPath()
		this.context.moveTo(from.x, from.y)
		this.context.lineTo(to.x, to.y)
		this.context.stroke()

	// Draw text, pos is the left end of its baseline
	js void drawText: implicit string text
		              Vector2 pos
		              CanvasFont font = CanvasFont.default
		              Color color = black
		this.setFont(font)
		this.setFillStyle(color.colorString)
		this.context.fillText(text, pos.x, pos.y)

	// Measure the width of a text and the ascent and descent of its font
	js TextMetrics measureText: implicit string text
		                        CanvasFont font = CanvasFont.default
		this.setFont(font)
		return this.context.measureText(text)

	// Draw an image (an img element or Image object that has completed loading)
	js void drawImage: dynamic image
		               Vector2 pos
		               Vector2 size
		if(image?.complete && image.naturalWidth) this.context.drawImage(image, pos.x, pos.y, size.x, size.y)

	private js void setFont: CanvasFont font
		if(this.font === font) return
		this.font = font
		this.context.font = font.css()

	private js void setFillStyle: string style
		if(this.fillStyle === style) return
		this.fillStyle = style
		this.context.fillStyle = style

// A font to draw text on a canvas. Create it once and reuse it, its css string is computed once
class CanvasFont
	static CanvasFont default = {}
	string family = "sans-serif"	// A css font family, e.g. "Inter, sans-serif"
	float size = 16	// In css pixels
	int weight = 400	// 400 is normal, 700 is bold
	bool italic
	private string cssString

	string css
		if not cssString then cssString = "{italic ? "italic " : ""}{weight} {size}px {family}"
		return cssString

js TextMetrics
dynamic TextMetrics
	float width
	inline js float ascent() this.fontBoundingBoxAscent
	inline js float descent() this.fontBoundingBoxDescent
