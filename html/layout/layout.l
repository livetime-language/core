// Where a dragged tab would go (PanelDropTarget)
enum PanelDropPosition: Tab, Center, Left, Right, Top, Bottom, Between

// Where a dragged tab would go: among the tabs of a switcher before the tab beforeKey ("" at the end), into a switcher (Center), beside a
// switcher or a fixed panel (Left, Right, Top, Bottom) or between two nodes of a split (Between, before its child index). The last two
// give the panel a new switcher of size extent
class PanelDropTarget
	LayoutNode	node
	PanelDropPosition	position
	string	beforeKey
	int	index
	float	extent

// A tab that the user drags
class PanelDrag
	Layout	layout
	string	key
	PanelDropTarget	target	// null while it is over no place it can go
	float	tabWidth, tabHeight	// The size of its tab, which its preview among the tabs has
	float	toCenterX	// From the pointer to the center of the tab (pixels of the page), so it goes where its center is, wherever the user holds it

// Arranges panels like the editors of VS Code: PanelSwitchers with tabs in rows and columns (PanelSplit), which the user resizes by
// dragging the edges between them. The user drags a panel by its tab to another position among the tabs, into another switcher, beside
// a switcher or a fixed panel, or onto an edge between two switchers: the last two give it a switcher of its own. A switcher whose last
// panel left disappears. The arrangement (root) is plain data of the panels' keys and sizes: save it when onChange is called and give it
// back to restore it. The panels come from panels whenever they are needed, so they can change with what the app shows: e.g. those of the
// selected item, which take the places of the previous item's panels with the same keys (Panel.place). A panel without a place goes to the
// largest switcher (mainSwitcher), a fixed panel to the start of root. Panels get show when they become visible and hide when they no
// longer are. Projects use it with the tag "layout" (.livetime/targets.lc).
// Example:
//     app
//         Panel board = Board(fixed:true, autoWidth:true)
//         Editor editor = {title:"Editor"}
//         Terminal terminal = {title:"Terminal"}
//         Layout layout = {root:settings.layout, panels:[board, editor, terminal], onChange:saveSettings}
//         draw
//             column position:fixed, inset:0
//                 layout.draw
Layout
	PanelSplit	root = {}	// The arrangement, changed in place
	Panel[]()	panels = null	// The panels it arranges
	void()	onChange = null	// The user changed the arrangement or a size: save root
	void(PanelSwitcher switcher, bool left) drawToolbar = null	// Draws buttons in the header of a switcher: after its tabs (left) or at its right end
	Color	tabColor = #004979
	Color	dividerColor = #00000018
	float	minimumSize = 120	// Resizing keeps nodes at least this wide or high
	PanelSwitcher	mainSwitcher	// The largest switcher of the last draw
	Panel[]	visiblePanels	// What the last draw showed
	PanelSwitcher[]	drawnSwitchers	// The switchers of the last draw and their elements (mainSwitcher)
	HTMLElement[]	switcherElements
	static PanelDrag	drag	// The tab the user drags, null if none

	Panel[] findPanels => panels != null ? panels() : []

	// The panel of a place, null if there is none (or only a hidden one)
	Panel findPanel: string key, Panel[] all
		return all.find(.placeKey == key and not .hidden)

	// The panels of a switcher in the order of their tabs, also those without a tab (Panel.tabHidden)
	Panel[] findPanelsOf: PanelSwitcher switcher, Panel[] all
		Panel[] found
		for key in switcher.keys
			Panel p = findPanel(key, all)
			if p then found.add p
		return found

	// The panel a switcher shows: the one it showed last, otherwise its first tab. null if it has none
	Panel findShownPanel: PanelSwitcher switcher, Panel[] all
		Panel[] present = findPanelsOf(switcher, all)
		for i to switcher.history.length step -1
			Panel p = present.find(.placeKey == switcher.history[i])
			if p then return p
		return present.find(not .tabHidden)

	// Whether the panel is visible
	bool isShown: Panel panel
		Panel[] all = findPanels
		if not panel or not all.includes(panel) or panel.hidden then return false
		if panel.fixed then return true
		PanelSwitcher switcher = findSwitcher(panel.placeKey)
		return switcher != null and findShownPanel(switcher, all) == panel

	// The node and the nodes in it
	LayoutNode[] collectNodes: LayoutNode node
		LayoutNode[] nodes = [node]
		if node is PanelSplit
			PanelSplit split = cast node
			for child in split.children
				nodes.addRange collectNodes(child)
		return nodes

	PanelSwitcher[] collectSwitchers
		PanelSwitcher[] switchers
		for node in collectNodes(root)
			if node is PanelSwitcher then switchers.add cast node
		return switchers

	// The switcher that has a place for the panel with this key, null if none has
	PanelSwitcher findSwitcher: string key
		return collectSwitchers.find(.keys.includes(key))

	// The split the node is in, null for root
	PanelSplit findParent: LayoutNode node
		for n in collectNodes(root)
			if n is PanelSplit
				PanelSplit split = cast n
				if split.children.includes(node) then return split
		return null

	// Gives each panel without a place one: a fixed panel at the start of root, the others in the largest switcher
	placePanels: Panel[] all
		LayoutNode[] nodes = collectNodes(root)
		PanelSwitcher[] switchers = collectSwitchers
		for p in all
			string key = p.placeKey
			if p.fixed
				bool placed
				for node in nodes
					if node is FixedPanelPlace
						FixedPanelPlace place = cast node
						if place.key == key then placed = true
				if not placed then root.children.insert FixedPanelPlace(key:key), index:0
			else if switchers.none(.keys.includes(key))
				PanelSwitcher target = mainSwitcher and switchers.includes(mainSwitcher) ? mainSwitcher : switchers.first
				if not target
					target = PanelSwitcher(size:1000)
					root.children.add target
					switchers.add target
				target.keys.add key

	// Shows the panel in its switcher, with focus it gets the keyboard focus. Nothing for a panel that panels doesn't have
	show: Panel panel, bool focus = false
		Panel[] all = findPanels
		if not panel or not all.includes(panel) or panel.hidden then return
		placePanels all
		PanelSwitcher switcher = findSwitcher(panel.placeKey)
		if switcher
			Panel previous = findShownPanel(switcher, all)
			switcher.history.remove panel.placeKey
			switcher.history.add panel.placeKey
			if previous != panel and previous and visiblePanels.includes(previous)
				visiblePanels.remove previous
				previous.hide
			// Started before start runs: start may refresh (and the draw would start it again)
			if not panel.isPanelStarted then panel.isPanelStarted = true; panel.start
			if not visiblePanels.includes(panel)
				visiblePanels.add panel
				panel.show
		refresh
		if focus then panel.focus

	// The panel closes: its switcher shows the panel it showed before. Unless keepPlace, its place is removed if no other panel of panels
	// has it (with its last place a switcher disappears)
	close: Panel panel, bool keepPlace = false
		string key = panel.placeKey
		Panel[] all = findPanels
		PanelSwitcher switcher = findSwitcher(key)
		if switcher and all.includes(panel) then switcher.history.remove key
		if switcher and not keepPlace and all.none(. != panel and .placeKey == key)
			switcher.keys.remove key
			switcher.history.remove key
			removeEmptyNodes root
			notifyChange
		refresh

	setCommands: bool shown
		Panel[] all = findPanels
		placePanels all
		for p in all
			bool visible = shown and isShown(p)
			// Panels that become visible start first, as in show
			if visible and not p.isPanelStarted then p.isPanelStarted = true; p.start
			p.setCommands visible

	notifyChange
		if onChange != null then onChange()

	draw
		Panel[] all = findPanels
		placePanels all
		html.style ".layoutTabs::-webkit-scrollbar", "display:none"
		html.style ".layoutTabs", "scrollbar-width:none"
		// The largest switcher of the last draw that is still there
		mainSwitcher = null
		float largestArea = -1
		PanelSwitcher[] switchers = collectSwitchers
		for drawnSwitchers
			float area = switcherElements[i].clientWidth * switcherElements[i].clientHeight
			if area > largestArea and switchers.includes(.)
				mainSwitcher = .
				largestArea = area
		Panel[] previouslyVisible = visiblePanels
		visiblePanels = []
		drawnSwitchers = []
		switcherElements = []
		drawNode root, all, flex:"1 1 0px"
		// After the draw, so they can refresh
		Panel[] hidden = previouslyVisible.filter(not visiblePanels.includes(.))
		Panel[] shown = visiblePanels.filter(not previouslyVisible.includes(.))
		if hidden.length > 0 or shown.length > 0
			delay 0
				for p in hidden
					p.hide
				for p in shown
					p.show

	// Whether the node shows a panel
	bool isNodeShown: LayoutNode node, Panel[] all
		if node is PanelSwitcher then return findShownPanel(cast node, all) != null
		if node is FixedPanelPlace
			FixedPanelPlace place = cast node
			return findPanel(place.key, all) != null
		PanelSplit split = cast node
		return split.children.any(isNodeShown(., all))

	// Whether the node is as wide as its content: a fixed panel with autoWidth, a column with one, a row of them
	bool isAutoWidth: LayoutNode node, Panel[] all
		if node is FixedPanelPlace
			FixedPanelPlace place = cast node
			return findPanel(place.key, all)?.autoWidth == true
		if not (node is PanelSplit) then return false
		PanelSplit split = cast node
		LayoutNode[] shown = split.children.filter(isNodeShown(., all))
		return split.vertical ? shown.any(isAutoWidth(., all)) : shown.length > 0 and shown.none(not isAutoWidth(., all))

	// Draws the node with the css property flex its split gives it
	void drawNode: LayoutNode node, Panel[] all, string flex
		if node is PanelSplit then drawSplit cast node, all, flex
		else if node is PanelSwitcher then drawSwitcher cast node, all, flex
		else
			FixedPanelPlace place = cast node
			Panel panel = findPanel(place.key, all)
			visiblePanels.add panel
			div class:"layoutNode", display:flex, flex, minWidth:0, minHeight:0, position:relative
				panel.draw
				drawDropZone node, centerAllowed:false

	// The nodes that show panels with an edge between each two of them. The largest one takes the space the others leave, the others have
	// their sizes (less if there isn't enough space), those of autoWidth the width of their content
	void drawSplit: PanelSplit split, Panel[] all, string flex
		LayoutNode[] shown = split.children.filter(isNodeShown(., all))
		LayoutNode largest = (shown.filter(split.vertical or not isAutoWidth(., all))).withMax(.size)
		div class:"layoutNode", display:flex, flexDirection:split.vertical ? column : row, flex, minWidth:0, minHeight:0
			// Where nothing takes the dragged tab, it goes nowhere (the places that take it stop the event)
			onDragOver:
				if split == root and drag?.layout == this and drag.target
					drag.target = null
					refresh
			for i = 0 to shown.length
				LayoutNode node = shown[i]
				if i > 0 then drawEdge split, shown, i, all
				drawNode node, all, flex:not split.vertical and isAutoWidth(node, all) ? "0 1 auto" : node == largest ? "1 0 {minimumSize}px" : "0 1 {node.size}px"

	// The line between two nodes of a split. Dragging it resizes them (not one with autoWidth in a row), a tab dropped on it gets a switcher
	// of its own there
	void drawEdge: PanelSplit split, LayoutNode[] shown, int index, Panel[] all
		bool vertical = split.vertical
		bool resizable = vertical or not (isAutoWidth(shown[index - 1], all) or isAutoWidth(shown[index], all))
		int childIndex = split.children.indexOf(shown[index])
		PanelDropTarget target = drag?.layout == this ? drag.target : null
		bool targeted = target != null and target.node == split and target.position == Between and target.index == childIndex
		float reach = drag?.layout == this ? 8 : 4
		div flexShrink:0, position:relative, backgroundColor:targeted ? tabColor : dividerColor, width:vertical ? "auto" : targeted ? "3px" : "1px", height:vertical ? targeted ? "3px" : "1px" : "auto",
				marginTop:vertical ? 0 : 8, marginBottom:vertical ? 0 : 8, marginLeft:vertical ? 8 : 0, marginRight:vertical ? 8 : 0
			div position:absolute, zIndex:30, left:vertical ? 0 : -reach, right:vertical ? 0 : -reach, top:vertical ? -reach : 0, bottom:vertical ? -reach : 0,
				cursor:not resizable ? Cursor.default : vertical ? Cursor.resizeRow : Cursor.resizecol,
				onPointerDown:if resizable and ev.button == 0 then startResize ev, split, shown, index
				onDragOver:
					HTMLElement edge = ev.currentTarget.parentNode
					float before = vertical ? edge.previousSibling.clientHeight : edge.previousSibling.clientWidth
					float after = vertical ? edge.nextSibling.clientHeight : edge.nextSibling.clientWidth
					dragOver ev, {node:split, position:Between, index:childIndex, extent:(before + after) / 4}
				onDrop:dropDragged ev

	// The tabs of the panels, the toolbars and the panel it shows. The left and right margins are the padding of the panel, so a panel can
	// reach into them. The tabs scroll horizontally if they don't fit
	void drawSwitcher: PanelSwitcher switcher, Panel[] all, string flex
		Panel shown = findShownPanel(switcher, all)
		Panel[] tabs = (findPanelsOf(switcher, all)).filter(not .tabHidden)
		visiblePanels.add shown
		PanelDropTarget target = drag?.layout == this and drag.target?.node == switcher and drag.target.position == Tab ? drag.target : null
		// Over tabs, the dragged tab leaves its switcher and a preview with its size shows where it would go
		string liftedKey = drag?.layout == this and drag.target?.position == Tab ? drag.key : ""
		HTMLElement element = column class:"layoutNode", flex, overflow:hidden, minWidth:0, minHeight:0, margin:{8 0 8 0}, gap:12
			// Header
			// Beside the tabs, the tab goes after the last one
			row gap:8, alignItems:center, height:24, flexShrink:0, margin:{0 8 0 14}
				onDragOver:dragOver ev, {node:switcher, position:Tab, beforeKey:""}
				onDrop:dropDragged ev
				HTMLElement tabsElement = row class:"layoutTabs", gap:8, alignItems:center, alignSelf:stretch, minWidth:0, overflowX:auto, padding:{0 6 0 6}
					onDragOver:dragOver ev, {node:switcher, position:Tab, beforeKey:findClosestTab(ev.currentTarget, ev.clientX + drag.toCenterX, drag.tabWidth)}
					onDrop:dropDragged ev
					for p in tabs
						bool selected = p == shown
						if target != null and target.beforeKey == p.placeKey then drawTabPreview
						div p.title, key:p.placeKey, data:{place:p.placeKey}, display:p.placeKey == liftedKey ? Display.none : Display.block, fontSize:10, padding:{0 10 0 10}, height:19, flexShrink:0, whiteSpace:noWrap, draggable:true, scrollIntoView:selected,
							color:selected ? white : tabColor
							backgroundColor:selected ? tabColor : transparent
							border:{1px solid tabColor}
							borderRadius:32
							cursor:pointer
							onClick:show p, focus:true
							onDragStart:startDrag ev, p
							onDragEnd:endDrag
					if target != null and (target.beforeKey == "" or tabs.none(.placeKey == target.beforeKey)) then drawTabPreview
				scrollWithWheel tabsElement
				if drawToolbar != null then drawToolbar switcher, true
				div flex:1
				if drawToolbar != null then drawToolbar switcher, false
			// The panel
			row flex:1, minHeight:0, overflow:hidden, padding:{0 8 0 8}, position:relative
				shown.draw
				drawDropZone switcher, centerAllowed:true
		drawnSwitchers.add switcher
		switcherElements.add element

	// Where the dragged tab would go among the tabs, with the size and the shape of the tab
	drawTabPreview
		div key:"tabPreview", class:"layoutTabPreview", width:drag.tabWidth, height:drag.tabHeight, flexShrink:0, borderRadius:32, backgroundColor:#000000, opacity:0.05

	// The tab before which the dragged tab goes ("" at the end): where the center of its preview would be closest to center, the center of
	// the dragged tab. Measured without the preview, so where the preview is doesn't change where the tab goes
	private js string findClosestTab: HTMLElement tabsElement, float center, float width
		const preview = tabsElement.querySelector(".layoutTabPreview")
		if(preview) preview.style.display = "none"
		const tabs = [...tabsElement.children].filter(child => child.hasAttribute("place") && child.style.display != "none")
		const half = width*system.scale/2, gap = parseFloat(getComputedStyle(tabsElement).columnGap) || 0
		// The center of the preview before each tab and at the end
		const centers = tabs.map(tab => tab.getBoundingClientRect().left + half)
		const last = tabs.at(-1)?.getBoundingClientRect()
		centers.push(last ? last.right + gap + half : tabsElement.getBoundingClientRect().left + parseFloat(getComputedStyle(tabsElement).paddingLeft) + half)
		if(preview) preview.style.display = ""
		let closest = 0
		centers.forEach((c, i) => { if(Math.abs(c - center) < Math.abs(centers[closest] - center)) closest = i })
		return closest < tabs.length ? tabs[closest].getAttribute("place") : ""

	// While a tab is dragged, the area of a switcher or fixed panel takes it: into the switcher at its center (centerAllowed), beside it at
	// its edges. It covers what the panel shows, which could take the events (an iframe), and shows where the tab would go
	drawDropZone: LayoutNode node, bool centerAllowed
		if drag?.layout != this then return
		PanelDropTarget target = drag.target?.node == node and drag.target.position != Tab ? drag.target : null
		div position:absolute, left:0, top:0, right:0, bottom:0, zIndex:20
			onDragOver:
				HTMLElement zone = ev.currentTarget
				Rect r = zone.getBoundingClientRect
				float x = (ev.clientX - r.left) / (r.right - r.left)
				float y = (ev.clientY - r.top) / (r.bottom - r.top)
				float nearest = x atMost (1 - x) atMost y atMost (1 - y)
				PanelDropPosition side = nearest == x ? Left : nearest == 1 - x ? Right : nearest == y ? Top : Bottom
				float extent = (side == Left or side == Right ? zone.clientWidth : zone.clientHeight) / 2
				dragOver ev, {node, position:centerAllowed and nearest > 0.25 ? Center : side, extent}
			onDrop:dropDragged ev
			if target
				PanelDropPosition at = target.position
				div position:absolute, borderRadius:8, backgroundColor:tabColor, opacity:0.15, pointerEvents:none,
					left:at == Right ? "50%" : "0", right:at == Left ? "50%" : "0", top:at == Bottom ? "50%" : "0", bottom:at == Top ? "50%" : "0"

	startDrag: DragEvent ev, Panel panel
		ev.dataTransfer.setData("text/plain", panel.title)
		ev.dataTransfer.effectAllowed = "move"
		Rect r = ev.currentTarget.getBoundingClientRect
		drag = {layout:this, key:panel.placeKey, tabWidth:(r.right - r.left) / system.scale, tabHeight:(r.bottom - r.top) / system.scale, toCenterX:(r.left + r.right) / 2 - ev.clientX}
		// Changing the page while the drag starts would cancel it
		delay 0, refresh

	endDrag
		if not drag then return
		drag = null
		refresh

	// The dragged tab is over a place where it can go: there it shows where it would go. Not where it would stay as it is
	dragOver: DragEvent ev, PanelDropTarget target
		if drag?.layout != this then return
		PanelSwitcher source = findSwitcher(drag.key)
		bool staysAsItIs = target.node == source and (target.position == Center or (target.position != Tab and source.keys.length == 1))
		PanelDropTarget previous = drag.target
		if staysAsItIs
			drag.target = null
			if previous then refresh
			return
		ev.preventDefault
		ev.stopPropagation
		ev.dataTransfer.dropEffect = "move"
		if previous and previous.node == target.node and previous.position == target.position and previous.beforeKey == target.beforeKey and previous.index == target.index then return
		drag.target = target
		refresh

	dropDragged: DragEvent ev
		PanelDrag dropped = drag
		if dropped?.layout != this or not dropped.target then return
		ev.preventDefault
		ev.stopPropagation
		drag = null
		movePanel dropped.key, dropped.target

	// Moves the place of a panel, which its switcher shows then
	movePanel: string key, PanelDropTarget target
		PanelSwitcher source = findSwitcher(key)
		bool intoSwitcher = target.position == Tab or target.position == Center
		PanelSwitcher destination = PanelSwitcher(size:target.extent)
		if intoSwitcher then destination = cast target.node
		int index = target.position == Tab and target.beforeKey ? destination.keys.indexOf(target.beforeKey) : destination.keys.length
		if source
			int sourceIndex = source.keys.indexOf(key)
			if source == destination and sourceIndex < index then index--
			source.keys.remove key
			source.history.remove key
		destination.keys.insert key, index:index
		destination.history.add key
		if target.position == Between
			PanelSplit split = cast target.node
			split.children.insert destination, index:target.index
		else if not intoSwitcher
			// Beside the node: in its split if it has the direction, otherwise the node and the new switcher get a split of their own
			LayoutNode node = target.node
			PanelSplit parent = findParent(node)
			bool vertical = target.position == Top or target.position == Bottom
			bool before = target.position == Left or target.position == Top
			int nodeIndex = parent.children.indexOf(node)
			if parent.vertical == vertical
				parent.children.insert destination, index:before ? nodeIndex : nodeIndex + 1
			else
				parent.children[nodeIndex] = PanelSplit(vertical:vertical, size:node.size, children:before ? [destination, node] : [node, destination])
			node.size = target.extent
		removeEmptyNodes root
		notifyChange
		refresh

	// Removes switchers without panels and splits without nodes. A split with one node gives way to it, a split in a split of the same
	// direction gives it its nodes. root stays: it takes the direction and the nodes of a split that is its only node
	LayoutNode removeEmptyNodes: LayoutNode node
		if node is PanelSwitcher
			PanelSwitcher switcher = cast node
			return switcher.keys.length > 0 ? node : null
		if not (node is PanelSplit) then return node
		PanelSplit split = cast node
		LayoutNode[] children
		for child in split.children
			LayoutNode kept = removeEmptyNodes(child)
			if not kept then continue
			if kept is PanelSplit
				PanelSplit inner = cast kept
				if inner.vertical == split.vertical
					children.addRange inner.children
					continue
			children.add kept
		split.children = children
		if split != root
			if children.length == 0 then return null
			if children.length > 1 then return split
			children[0].size = split.size
			return children[0]
		if children.length == 1 and children[0] is PanelSplit
			PanelSplit only = cast children[0]
			split.vertical = only.vertical
			split.children = only.children
		return split

	// Dragging the edge before shown[index] resizes the nodes at both its sides
	startResize: PointerEvent ev, PanelSplit split, LayoutNode[] shown, int index
		ev.preventDefault
		float[] sizes = measureNodes(ev.currentTarget.parentNode.parentNode, split.vertical)
		for i = 0 to shown.length
			shown[i].size = sizes[i]
		LayoutNode first = shown[index - 1]
		LayoutNode second = shown[index]
		float firstSize = first.size
		float secondSize = second.size
		followPointer ev,
			move:
				float moved = ((split.vertical ? offset.y : offset.x) atLeast minimumSize - firstSize) atMost secondSize - minimumSize
				first.size = firstSize + moved
				second.size = secondSize - moved
				refresh
			release:notifyChange

	// The widths (heights if vertical) of the nodes of a split element
	private js float[] measureNodes: HTMLElement split, bool vertical
		return [...split.children].filter(child => child.classList.contains("layoutNode")).map(child => vertical ? child.offsetHeight : child.offsetWidth)

	// Calls move with how far the pointer moved since it was pressed, until it is released
	private js void followPointer: PointerEvent pressed, stored void(Vector2 offset) move, stored void() release
		const scale = system.scale || 1, x = pressed.clientX, y = pressed.clientY
		// The element keeps getting the events while the pointer is over an iframe
		try { pressed.target.setPointerCapture(pressed.pointerId) } catch {}
		const onMove = ev => move.invoke(new Vector2((ev.clientX - x)/scale, (ev.clientY - y)/scale))
		const onEnd = () => {
			removeEventListener("pointermove", onMove, true)
			removeEventListener("pointerup", onEnd, true)
			removeEventListener("pointercancel", onEnd, true)
			release.invoke()
		}
		addEventListener("pointermove", onMove, true)
		addEventListener("pointerup", onEnd, true)
		addEventListener("pointercancel", onEnd, true)

	// The vertical wheel of a mouse scrolls the tabs horizontally
	private js void scrollWithWheel: HTMLElement tabs
		tabs.onwheel = ev => {
			if(Math.abs(ev.deltaY) <= Math.abs(ev.deltaX) || tabs.scrollWidth <= tabs.clientWidth) return
			tabs.scrollLeft += ev.deltaY
			ev.preventDefault()
		}
