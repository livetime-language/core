global static class html
	Dragging dragging	// The item the user pressed or drags (null if there is none)
	private DropZone[] dropZones	// The lists forDraggable drew during the last refresh
	private bool dragEnded	// Suppresses the click that follows the drop

	// Draw a list of items that the user can reorder and move into other lists of the same group by dragging them.
	// Dragging starts when the user presses an element with cursor:move (on touch screens: presses and holds it) and moves the pointer.
	// The parent element is the drop zone. A preview with the size of the dragged item shows where it will be dropped.
	// A hint at the pointer can tell what dropping the item on a list does, for example while the user holds CmdOrCtrl (Cmd on Apple
	// devices, Ctrl everywhere else).
	// Example:
	//     column
	//         forDraggable stack.cards, angleWhileDragging:10
	//             drawCard .
	//         onDrop:
	//             order := prev and next ? (prev.order + next.order)/2 : next ? next.order - 1024 : prev ? prev.order + 1024 : 0
	//             app.cards.update ., {stack:stack.id, order}
	importance:4
	global forDraggable: T[] items	// The items to draw
		                 float angleWhileDragging = 0	// Rotate the dragged item by this angle in degrees
		                 Style dropPreview = {backgroundColor:#000000, opacity:0.05, borderRadius:4}	// The style of the drop preview, which has the size of the dragged item unless you specify width or height
		                 string group = null	// Items can be moved between lists of the same group (by default, lists drawn by the same line of code)
		                 void(T it, int i) do	// Draw the item
		                 stored void(T it) onDrag = null	// The user started to drag the item
		                 stored void(T it, T prev, T next, bool cmdOrCtrl) onDrop = null	// The user dropped the item between prev and next (its neighbors in this list without the dragged item, null at the start or end), cmdOrCtrl tells whether CmdOrCtrl was held
		                 stored string(T it, bool cmdOrCtrl) hint = null	// The html shown at the pointer while the item is dragged over this list (none if empty), cmdOrCtrl tells whether CmdOrCtrl is held
		                 Style hintStyle = {padding:{topAndBottom:2 leftAndRight:6}, borderRadius:4, fontSize:12, color:#ffffff, backgroundColor:#303030}	// The style of the hint
		                 SourceCodeLocation location
		ItemDropZone<T> zone = {element:parentNode, group:group ? group : location.toString, items, onDrag, onDrop}
		dropZones.add zone
		// Every refresh creates new lists, so the drag switches to them
		Dragging d = dragging?.started ? dragging : null
		if d and d.source.element == zone.element then d.source = zone
		if d and d.zone.element == zone.element then d.zone = zone
		int index = 0
		for item in items
			isDragged := d?.source == zone and d.sourceIndex == i
			if not isDragged
				if d?.zone == zone and d.index == index then d.preview = div key:"dropPreview", style:withDraggedSize(dropPreview)
				index++
			wrapper := div key:"{i}", onPointerDown:startDrag ., zone, i, angleWhileDragging
				do item, i
			zone.wrappers.add wrapper
			if not isDragged then setContentsOnly wrapper
		if d?.zone == zone and d.index == index then d.preview = div key:"dropPreview", style:withDraggedSize(dropPreview)
		if d?.zone == zone
			// Only lists of the same group exchange items, so the source has the same item type
			ItemDropZone<T> source = cast d.source
			string text = hint != null ? hint(source.items[d.sourceIndex], d.cmdOrCtrl) : ""
			if text then d.hint = div text, key:"dragHint", style:hintStyle
			else         d.hint = null
			moveHint

	// The wrapper of an item doesn't generate a box, unless the item is dragged
	private js void setContentsOnly: HTMLElement wrapper
		if(wrapper.style.cssText != "display: contents;") wrapper.style.cssText = "display:contents"

	// The style of the drop preview with the size and margins of the dragged item, unless the style specifies them
	private js Style withDraggedSize: Style style
		return {...html.dragging.previewStyle, ...style}

	// The hint follows the pointer
	private js void moveHint
		const d = html.dragging, s = system.scale
		if(d.hint) Object.assign(d.hint.style, {position:"fixed", left:(d.x + 12)/s + "px", top:(d.y + 16)/s + "px", zIndex:"1001", pointerEvents:"none", whiteSpace:"nowrap"})

	private startDrag: PointerEvent event, DropZone zone, int index, float angle
		if event.button != 0 or dragging or getCursor(event.target) != "move" then return
		// Nested draggables: the innermost item is dragged
		event.stopPropagation
		dragging = {source:zone, sourceIndex:index, element:event.currentTarget, angle, pointerId:event.pointerId, x:event.clientX, y:event.clientY, startX:event.clientX, startY:event.clientY}
		if event.pointerType == Touch
			dragging.timer = delay 300
				beginDrag

	private inline js string getCursor(HTMLElement element) getComputedStyle(element).cursor

	private js void beginDrag
		const d = html.dragging, child = d.element.firstElementChild || d.element, s = system.scale
		const r = child.getBoundingClientRect(), cs = getComputedStyle(child), ml = parseFloat(cs.marginLeft), mt = parseFloat(cs.marginTop)
		clearTimeout(d.timer)
		d.started = true
		// The dragged wrapper includes the margins of the item, the preview gets them too
		d.offsetX = d.x - r.left + ml*s
		d.offsetY = d.y - r.top + mt*s
		d.toCenterX = r.left + r.width/2 - d.x
		d.toCenterY = r.top + r.height/2 - d.y
		d.itemWidth = r.width
		d.itemHeight = r.height
		d.marginX = (ml + parseFloat(cs.marginRight))*s
		d.marginY = (mt + parseFloat(cs.marginBottom))*s
		d.previewStyle = {width:r.width/s + "px", height:r.height/s + "px", margin:cs.marginTop + " " + cs.marginRight + " " + cs.marginBottom + " " + cs.marginLeft, flexShrink:"0"}
		d.zone = d.source
		d.index = d.sourceIndex
		getSelection().removeAllRanges()
		document.documentElement.style.userSelect = "none"
		html.moveDragged()
		d.source.drag(d)
		html.refresh()
		html.autoScroll(d)

	// Move the dragged item to the pointer, find the drop zone closest to the pointer
	// and the position where the center of the drop preview would be closest to the center of the item
	private js void moveDragged
		const d = html.dragging, s = system.scale
		d.element.style.cssText = `position:fixed;left:${(d.x - d.offsetX)/s}px;top:${(d.y - d.offsetY)/s}px;width:${(d.itemWidth + d.marginX)/s}px;rotate:${d.angle}deg;pointer-events:none;z-index:1000`
		html.moveHint()
		let zone = d.zone, best = Infinity, cs, horizontal
		for(const z of html.dropZones) {
			if(z.group != d.source.group || d.element.contains(z.element)) continue
			const zoneStyle = getComputedStyle(z.element), isHorizontal = zoneStyle.display.includes("flex") && zoneStyle.flexDirection.startsWith("row")
			// A list extends from its end in its direction, so items can be dropped below (or right of) short and empty lists
			const r = z.element.getBoundingClientRect(), right = isHorizontal ? Infinity : r.right, bottom = isHorizontal ? r.bottom : Infinity
			const distance = Math.hypot(Math.max(r.left - d.x, 0, d.x - right), Math.max(r.top - d.y, 0, d.y - bottom))
			// Lists are drawn from outside to inside and from start to end, so the innermost and the later one wins
			if(distance <= best) { best = distance; zone = z; cs = zoneStyle; horizontal = isHorizontal }
		}
		const start = horizontal ? "left" : "top", end = horizontal ? "right" : "bottom"
		const items = zone.wrappers.filter(w => w != d.element).map(w => (w.firstElementChild || w).getBoundingClientRect())
		const preview = zone == d.zone ? d.preview?.getBoundingClientRect() : null
		const center = horizontal ? d.x + d.toCenterX : d.y + d.toCenterY, half = (preview ? preview[end] - preview[start] : horizontal ? d.itemWidth : d.itemHeight)/2
		let index = 0
		best = Infinity
		for(let i = 0; i <= items.length; i++) {
			// Moving the preview to i moves the items in between by its size, so it would start where item i starts or end where item i-1 ends
			const previewCenter =
				preview && i == d.index ? (preview[start] + preview[end])/2 :
				preview && i > d.index ? items[i - 1][end] - half :
				i < items.length ? items[i][start] + half :
				i ? items[i - 1][end] + (horizontal ? d.marginX : d.marginY) + (parseFloat(horizontal ? cs.columnGap : cs.rowGap) || 0)*s + half : 0
			const distance = Math.abs(previewCenter - center)
			if(distance < best) { best = distance; index = i }
		}
		if(zone != d.zone || index != d.index) {
			d.zone = zone
			d.index = index
			html.refresh()
		}

	// Scroll the elements under the pointer while it is near their edges
	private js void autoScroll: Dragging d
		if(html.dragging != d) return
		let scrolled = false
		for(let el = document.elementFromPoint(d.x, d.y); el; el = el.parentElement) {
			const cs = getComputedStyle(el), r = el.getBoundingClientRect()
			const dx = /auto|scroll/.test(cs.overflowX) ? Math.max(0, 40 - (r.right - d.x)) - Math.max(0, 40 - (d.x - r.left)) : 0
			const dy = /auto|scroll/.test(cs.overflowY) ? Math.max(0, 40 - (r.bottom - d.y)) - Math.max(0, 40 - (d.y - r.top)) : 0
			if(dx || dy) {
				const left = el.scrollLeft, top = el.scrollTop
				el.scrollBy(dx/3, dy/3)
				scrolled ||= el.scrollLeft != left || el.scrollTop != top
			}
		}
		if(scrolled) html.moveDragged()
		requestAnimationFrame(() => html.autoScroll(d))

	private endDrag: bool drop
		Dragging d = dragging
		dragging = null
		if not d.started
			clearDelay d.timer
			return
		dragEnded = true
		delay 0
			dragEnded = false
		allowTextSelection
		if drop then d.zone.drop d
		refresh

	private inline js void allowTextSelection() document.documentElement.style.userSelect = ""

	private js void initDragAndDrop
		for(const type of ["pointermove", "pointerup", "pointercancel"]) addEventListener(type, ev => {
			const d = html.dragging
			if(!d || ev.pointerId != d.pointerId) return
			d.x = ev.clientX
			d.y = ev.clientY
			if(type != "pointermove") html.endDrag(type == "pointerup")
			else if(d.started) html.moveDragged()
			// Touches that move before they were held long enough scroll instead
			else if(Math.hypot(d.x - d.startX, d.y - d.startY) > 4) d.timer ? html.endDrag(false) : html.beginDrag()
		})
		// Hints and drops can depend on CmdOrCtrl. Capturing, so a drop knows the keys of its pointerup
		for(const type of ["pointermove", "pointerup", "keydown", "keyup"]) addEventListener(type, ev => {
			const d = html.dragging, cmdOrCtrl = html.isAppleDevice() ? ev.metaKey : ev.ctrlKey
			if(!d || d.cmdOrCtrl == cmdOrCtrl) return
			d.cmdOrCtrl = cmdOrCtrl
			if(d.started) html.refresh()
		}, true)
		addEventListener("keydown", ev => { if(ev.key == "Escape" && html.dragging?.started) { ev.stopPropagation(); html.endDrag(false) } }, true)
		addEventListener("touchmove", ev => { if(html.dragging?.started) ev.preventDefault() }, {passive:false})
		addEventListener("contextmenu", ev => { if(html.dragging) ev.preventDefault() }, true)
		addEventListener("click", ev => { if(html.dragEnded) ev.stopPropagation() }, true)

// The item the user pressed or drags with forDraggable
class Dragging
	DropZone source	// The list the item comes from
	int sourceIndex	// The index of the item in the source list
	HTMLElement element	// The wrapper of the item
	float angle	// Rotate the item by this angle in degrees
	int pointerId
	float x, y	// The position of the pointer
	float startX, startY	// The position where the user pressed the item
	int timer	// On touch screens, this timer starts dragging when the user held the touch long enough
	bool started	// The pointer moved far enough or the touch was held long enough
	float offsetX, offsetY	// The position of the pointer relative to the wrapper
	float toCenterX, toCenterY	// The center of the item relative to the pointer
	float itemWidth, itemHeight	// The size of the item without margins
	float marginX, marginY	// The sum of the horizontal and the vertical margins of the item
	Style previewStyle	// The size and margins of the item
	DropZone zone	// The list the item will be dropped into
	HTMLElement preview	// The drop preview in that list
	int index	// The position in that list, not counting the dragged item
	bool cmdOrCtrl	// The user holds Cmd (Apple devices) or Ctrl (everywhere else)
	HTMLElement hint	// The hint at the pointer (null if there is none)

// A list that forDraggable drew into an element
class DropZone
	HTMLElement element
	string group	// Items can be moved between lists of the same group
	HTMLElement[] wrappers	// The wrappers of the items
	drag: Dragging d
	drop: Dragging d

DropZone ItemDropZone<T>
	T[] items
	stored void(T it) onDrag = null
	stored void(T it, T prev, T next, bool cmdOrCtrl) onDrop = null

	// Call onDrag with the item the user started to drag
	drag: Dragging d
		onDrag items[d.sourceIndex]

	// Call onDrop with the dragged item and its new neighbors
	drop: Dragging d
		// Only lists of the same group exchange items, so the source has the same item type
		ItemDropZone<T> source = cast d.source
		T item = source.items[d.sourceIndex]
		rest := items.filter . != item
		onDrop item, rest[d.index - 1], rest[d.index], d.cmdOrCtrl
