global static class html
	Dragging dragging	// The item the user pressed or drags (null if there is none)
	private DropZone[] dropZones	// The lists forDraggable drew during the last refresh
	private bool dragEnded	// Suppresses the click that follows the drop
	private dynamic dragStyleSheet	// Enabled while an item is dragged

	// Draw a list of items that the user can reorder and move into other lists of the same group by dragging them.
	// Dragging starts when the user presses an element with cursor:move (on touch screens: presses and holds it) and moves the pointer.
	// The parent element is the drop zone. A preview with the size of the dragged item shows where it will be dropped.
	// A hint at the pointer can tell what dropping the item on a list does, for example while the user holds CmdOrCtrl (Cmd on Apple
	// devices, Ctrl everywhere else). canDrop can allow an item only at some positions of a list, or in none of them (then the item
	// goes back where it was while it is near that list).
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
		                 string(T it) keyOf = null	// A unique key of the item (by default its index): its elements follow it when items are added, removed or moved before it, so a field that is being edited keeps its item and the focus
		                 stored void(T it) onDrag = null	// The user started to drag the item
		                 stored void(T it, T prev, T next, bool cmdOrCtrl) onDrop = null	// The user dropped the item between prev and next (its neighbors in this list without the dragged item, null at the start or end), cmdOrCtrl tells whether CmdOrCtrl was held
		                 stored bool(T it, int index) canDrop = null	// Whether the item can be dropped at index of this list (not counting the dragged item; everywhere if null). It can always be put back where it was
		                 stored string(T it, bool cmdOrCtrl) hint = null	// The html shown at the pointer while the item is dragged over this list (none if empty), cmdOrCtrl tells whether CmdOrCtrl is held
		                 Style hintStyle = {padding:{topAndBottom:2 leftAndRight:6}, borderRadius:4, fontSize:12, color:#ffffff, backgroundColor:#303030}	// The style of the hint
		                 SourceCodeLocation location
		ItemDropZone<T> zone = {element:parentNode, before:currentNode ? currentNode.previousSibling : parentNode.lastChild, group:group ? group : location.toString, items, onDrag, onDrop, canDrop}
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
			wrapper := div key:keyOf != null ? keyOf(item) : "{i}", onPointerDown:startDrag ., zone, i, angleWhileDragging
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
		// Not a caret: the text that is being edited keeps it if the press didn't take its focus
		if(!getSelection().isCollapsed) getSelection().removeAllRanges()
		document.documentElement.style.userSelect = "none"
		html.dragStyleSheet.disabled = false
		html.moveDragged()
		d.source.drag(d)
		html.refresh()
		html.autoScroll(d)

	// Move the dragged item to the pointer and find where it would be dropped: in the list and at the position where the center of the drop
	// preview would be closest to the center of the item (wherever the user holds it). The positions are measured with the preview hidden,
	// so where the preview is doesn't change where it goes: it moves what follows it, also other lists (by less than its size if one of
	// them has room to spare), and measured with it the preview would jump back and forth between two lists underneath each other
	private js void moveDragged
		const d = html.dragging, s = system.scale
		d.element.style.cssText = `position:fixed;left:${(d.x - d.offsetX)/s}px;top:${(d.y - d.offsetY)/s}px;width:${(d.itemWidth + d.marginX)/s}px;rotate:${d.angle}deg;pointer-events:none;z-index:1000`
		html.moveHint()
		const centerX = d.x + d.toCenterX, centerY = d.y + d.toCenterY
		// Without the preview its scrolling ancestors may be too short for their scroll positions, which they get back afterwards
		const preview = d.preview?.isConnected ? d.preview : null, display = preview?.style.display, scrolled = []
		for(let el = preview?.parentElement; el; el = el.parentElement) scrolled.push([el, el.scrollLeft, el.scrollTop])
		if(preview) preview.style.display = "none"
		const zones = html.dropZones.filter(z => z.group == d.source.group && !d.element.contains(z.element)).map(z => {
			const style = getComputedStyle(z.element)
			return {z, style, r:z.element.getBoundingClientRect(), horizontal:style.display.includes("flex") && style.flexDirection.startsWith("row")}
		})
		// Whether a starts right of b (horizontal) or below b
		const follows = (a, b, horizontal) => horizontal ? a.left >= b.right - 1 && a.top < b.bottom && a.bottom > b.top : a.top >= b.bottom - 1 && a.left < b.right && a.right > b.left
		let zone = d.zone, index = d.index, best = Infinity
		for(const {z, style, r, horizontal} of zones) {
			const start = horizontal ? "left" : "top", end = horizontal ? "right" : "bottom", center = horizontal ? centerX : centerY
			const across = horizontal ? Math.max(r.top - centerY, 0, centerY - r.bottom) : Math.max(r.left - centerX, 0, centerX - r.right)
			const half = (horizontal ? d.itemWidth : d.itemHeight)/2
			// A list extends from its last position in its direction, so items can be dropped below (or right of) short and empty lists. Not if
			// another list follows it there: between them the closer position wins
			const isFollowed = zones.some(o => follows(o.r, r, horizontal))
			const items = z.wrappers.filter(w => w != d.element).map(w => (w.firstElementChild || w).getBoundingClientRect())
			// The positions where the item can be dropped. Near a list where it can't be dropped at all, it goes back where it was
			const all = [...items.keys(), items.length], accepted = all.filter(i => z.accepts(d, i)), positions = accepted.length ? accepted : all
			for(const i of positions) {
				// The preview at i would start where item i starts or follow item i-1. In an empty list it follows the element drawn before the items
				const previewCenter = half + (
					i < items.length ? items[i][start] :
					i ? items[i - 1][end] + (horizontal ? d.marginX : d.marginY) + (parseFloat(horizontal ? style.columnGap : style.rowGap) || 0)*s :
					z.before?.parentNode == z.element ? z.before.getBoundingClientRect()[end] : r[start] + parseFloat(horizontal ? style.paddingLeft : style.paddingTop)*s)
				const along = i == positions.at(-1) && !isFollowed && center > previewCenter ? 0 : Math.abs(previewCenter - center)
				const distance = Math.hypot(across, along)
				// Lists are drawn from outside to inside and from start to end: on a tie the innermost and the later list wins, in a list the first position
				if(distance < best || distance == best && z != zone) { best = distance; [zone, index] = accepted.length ? [z, i] : [d.source, d.sourceIndex] }
			}
		}
		if(preview) {
			const clamped = scrolled.filter(([el, left, top]) => el.scrollLeft != left || el.scrollTop != top)
			preview.style.display = display
			for(const [el, left, top] of clamped) el.scrollTo({left, top, behavior:"instant"})
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
		removeDragStyles
		if drop then d.zone.drop d
		refresh

	private js void removeDragStyles
		document.documentElement.style.userSelect = ""
		html.dragStyleSheet.disabled = true

	private js void initDragAndDrop
		// When the drop preview moves above the visible items of a scrolling list (while it scrolls up), the browser would scroll back to keep
		// them in place (scroll anchoring)
		html.dragStyleSheet = new CSSStyleSheet({disabled:true})
		html.dragStyleSheet.replaceSync("* { overflow-anchor: none }")
		document.adoptedStyleSheets = [...document.adoptedStyleSheets, html.dragStyleSheet]
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
	HTMLElement before	// The element drawn before the items (null if they come first): an empty list shows the drop preview after it
	string group	// Items can be moved between lists of the same group
	HTMLElement[] wrappers	// The wrappers of the items
	drag: Dragging d
	drop: Dragging d
	bool accepts: Dragging d, int index	// Whether the dragged item can be dropped at index
		return true

DropZone ItemDropZone<T>
	T[] items
	stored void(T it) onDrag = null
	stored void(T it, T prev, T next, bool cmdOrCtrl) onDrop = null
	stored bool(T it, int index) canDrop = null

	// Call canDrop with the dragged item, unless it goes back where it was
	bool accepts: Dragging d, int index
		ItemDropZone<T> source = cast d.source
		return canDrop == null or (source == this and index == d.sourceIndex) or canDrop(source.items[d.sourceIndex], index)

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
