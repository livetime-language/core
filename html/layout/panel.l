// Content that a Layout arranges: in a PanelSwitcher, which shows a tab for each of its panels and one of them, or in a place of its own
// (fixed). A panel can also be drawn anywhere without a Layout: it fills the space its parent (a row or column) gives it and starts with
// its first draw
Panel
	string	title	// The text of its tab
	string	place	// Its place in a Layout, its title if empty. Panels with the same place take turns there, e.g. the panel "Agent" of each task when the layout shows the panels of the selected task
	bool	fixed	// It has no tab and can't be dragged, other panels can be dropped beside it
	bool	autoWidth	// As wide as its content needs, the user can't change its width
	bool	hidden	// The Layout leaves it out as if it didn't have it, setCommands still runs
	bool	tabHidden	// Has no tab in its switcher, which still shows it if it is the panel shown last
	bool	isPanelStarted

	// The key of its place in a Layout
	string placeKey => place or title

	start
	// It became visible
	show
	// It is no longer visible
	hide
	draw
		if not isPanelStarted
			isPanelStarted = true
			start
	// Tells what the commands of the panel do right now. A Layout calls it before each draw for each of its panels, shown tells whether
	// the panel is visible: the others can offer commands too
	setCommands: bool shown
	// Gives the panel the keyboard focus (Layout.show with focus)
	focus
