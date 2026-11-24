// A node of the arrangement of a Layout (Layout.root): a PanelSplit, a PanelSwitcher or a FixedPanelPlace. Plain data with the keys of
// the panels (Panel.placeKey), which the app saves (Layout.onChange) and gives back to restore the arrangement.
// Saving may compare and copy it deeply, so it holds no panels or elements
LayoutNode
	float	size = 300	// Its width in a row, its height in a column (pixels). The largest node of a split takes the space the others leave

// A row (or with vertical a column) of nodes, the user changes their sizes by dragging the edges between them
LayoutNode PanelSplit
	bool	vertical
	LayoutNode[]	children

// Shows a tab for each of its panels and one of them: the one shown last that the layout has
LayoutNode PanelSwitcher
	string[]	keys	// Its panels in the order of their tabs
	string[]	history	// The panels it showed, the current one last

// The place of a panel that isn't in a switcher (Panel.fixed)
LayoutNode FixedPanelPlace
	string	key
