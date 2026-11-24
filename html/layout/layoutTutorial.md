# The Layout system: a tutorial

This tutorial explains the layout system in `lib/core/html/layout`. It assumes you know a little LiveTime (classes, `draw`, `refresh`) but nothing about this system.

## 1. What it does

Think of the editor area of VS Code. You see files in **tabs**. You can drag a tab to another position, drag it into another group of tabs, or drag it to the side of the window to split the window into two groups. You can drag the line between two groups to make one bigger. When you close VS Code and open it again, everything is where you left it.

This library gives your app exactly that, for any content you like: a chat, a terminal, a board, a settings page, and so on.

## 2. The words

**Panel**: one piece of content that the user sees as a whole, e.g. "Terminal" or "Settings". In code, a class that extends `Panel` and draws its content in `draw`.

**Tab**: the small rounded button with the panel's title. Clicking it shows the panel, dragging it moves the panel.

**Switcher** (`PanelSwitcher`): a group of panels. It shows a row of tabs at the top and below them the content of *one* of its panels, the shown panel.

**Split** (`PanelSplit`): puts several things side by side (a row) or on top of each other (a column, `vertical:true`). A split can contain switchers, fixed panels and other splits. That is how arbitrary arrangements are built, e.g. "a column of two switchers, next to a third switcher".

**Edge**: the thin line between two neighbors in a split. Dragging it resizes them.

**Fixed panel**: a panel without a tab that always stays where it is (`fixed:true`), e.g. the Board of a project management app. The user can't drag it, but can drop other panels to its left, right, top or bottom.

**Auto width** (`autoWidth:true`): the panel is exactly as wide as its content needs, and the user can't resize it.

**Place** (`Panel.place`): the name of a panel's spot in the arrangement. It is the panel's title unless you set it. More on why this matters in section 7.

**Arrangement** (`Layout.root`): the tree of splits, switchers and fixed places, with their sizes. It contains only names and numbers, never the panels themselves, so it can be saved to a file.

**Layout**: the object that draws the arrangement, handles all dragging and resizing, and tells you when the arrangement changed.

A picture of a typical arrangement:

```
root: PanelSplit (a row)
├── FixedPanelPlace "Board"                (fixed, auto width)
├── PanelSplit (a column)
│   ├── PanelSwitcher [Description, Agent]  (shows Agent)
│   └── PanelSwitcher [Terminal]
└── PanelSwitcher [Explorer, Search]        (size 300)
```

On screen:

```
┌────────┬───────────────────────┬───────────┐
│        │ (Description) [Agent] │ [Explorer]│
│ Board  │  chat ...             │  (Search) │
│        ├───────────────────────┤  files... │
│        │ [Terminal]            │           │
│        │  $ _                  │           │
└────────┴───────────────────────┴───────────┘
```

## 3. Turning it on

The library lives in a subfolder that is only compiled for projects that ask for it. Add the tag `layout` to your targets file:

```
// .livetime/targets.lc
Common
	Tags:	js, html, layout
```

## 4. Your first layout

Each panel is a class that extends `Panel`. Its `draw` draws the content. (A `draw` in a subclass *extends* `Panel.draw`, which calls `start` the first time the panel is drawn, so you don't have to do anything for that.)

```
Panel NotesPanel
	title = "Notes"
	string text
	draw
		input text, rows:10, flex:1, onInput:text = value

Panel ClockPanel
	title = "Clock"
	draw
		div "It is {Time.now}", padding:16

static class app
	NotesPanel notes = {}
	ClockPanel clock = {}
	Layout layout = {panels:[notes, clock]}

	draw
		column position:fixed, inset:0
			layout.draw
```

That's all. The first time it draws, the layout notices that `notes` and `clock` have no place yet and puts both into one switcher. You see two tabs, "Notes" and "Clock", and the content of Notes.

Now try it out:
- Click "Clock": the switcher shows the clock.
- Drag the "Clock" tab to the right half of the notes: while you drag, a translucent area shows where it will land. Drop it: you now have two switchers side by side.
- Drag the line between them to resize.
- Drag "Clock" back onto the tabs of the first switcher: the second switcher has no panels left and disappears.

**Why is `panels` written like a list but called like a function?** The field is declared as `Panel[]() panels`, a function that returns a list. LiveTime turns the expression `[notes, clock]` into a small function, and the layout calls it whenever it needs the panels. That's important later (section 7): the answer can change over time.

## 5. Where the panel can land

While you drag a tab, the layout looks at what is under the pointer:

| Under the pointer | Result |
|---|---|
| A switcher's tabs | The tabs move apart and a placeholder shows where it goes. It goes where its center is closest. |
| The empty area of a switcher's header | It becomes the last tab of that switcher. |
| The middle of a switcher's content | It becomes the last tab of that switcher. |
| Near an edge of a switcher's content (outer quarter) | A new switcher is created on that side. |
| Any side of a fixed panel | A new switcher is created on that side. |
| The edge between two switchers | A new switcher is created right there, between them. |
| Anything else | Nothing happens. |

If the new switcher goes in the same direction as its parent split (e.g. to the right of something in a row), it simply joins that row. If not (e.g. below something in a row), the layout wraps the target and the new switcher into a new column split. You never have to think about that: the tree is cleaned up after every change (empty switchers are removed, a split with one child is replaced by that child).

## 6. Sizes

Every node has a `size` in pixels: its width in a row, its height in a column. In each split, the **largest** node takes whatever space is left, and the others keep their size. So with a 300 px sidebar and a large main area, making the window bigger only makes the main area bigger, like in VS Code.

An `autoWidth` panel in a row ignores its size and is as wide as its content. If you drop something above or below it, the new column becomes as wide as it too.

When the user drags an edge, the layout measures the real sizes of all neighbors, applies the change, and calls `onChange` when the pointer is released. Nodes never become smaller than `minimumSize` (120 px by default).

## 7. Places: the same spot for different panels

This is the one idea that makes the system more than a copy of VS Code.

Imagine a task manager. Each task has its own Description, its own Agent chat and its own Terminal: different objects for each task. When the user selects another task, they expect "the chat is still on the right, the terminal still at the bottom", just with the new task's content.

The arrangement therefore doesn't store panels. It stores **places**, short names like `"Agent"`. A switcher holds a list of places (`keys`) in the order of its tabs. When the layout draws, it asks `panels` for the current panels and puts each one into the switcher whose list contains its place.

```
Panel TaskChat
	title = "Agent"
	Task task
	draw
		div "Chat of {task.name}"

Task
	string name
	TaskChat chat
	TaskTerminal terminal

static class app
	Task selected
	Layout layout = {panels:selected ? [selected.chat, selected.terminal] : []}

	select: Task task
		selected = task
		refresh	// The new task's chat appears where the old task's chat was
```

When `selected` changes, `panels` returns other objects with the same places, and they appear in the same spots. The layout notices that different panels are visible now and calls `hide` on the old ones and `show` on the new ones.

**Keep places stable.** By default the place is the title. If a panel's title changes (say, "Changes" becomes "Commit" for some tasks), set `place` so it stays in its spot:

```
Panel ChangesPanel
	title = "Changes"
	place = "Changes"	// stays the same when the title becomes "Commit"
```

Panels that exist several times per item need unique places, e.g. `place:"Terminal {number}"` or `place:"file:{path}"`.

**Switchers with nothing to show are not drawn.** If you move the Agent into a switcher of its own and then select something that has no Agent, that switcher is hidden until an Agent comes back. Its place is kept.

## 8. Saving and restoring the arrangement

The arrangement (`layout.root`) is plain data: splits, switchers, place names and sizes. Save it whenever `onChange` is called, and give it back next time:

```
static class app
	Layout layout = {panels:[notes, clock], onChange:saveLayout}

	start
		string saved = await storage.readFile("layout.yaml", basePath:Home)
		if saved then layout.root = object.fromYaml(saved)

	saveLayout
		storage.writeFile "layout.yaml", object.toYaml(layout.root), basePath:Home
```

`object.toYaml` writes the class names along with the data, so `object.fromYaml` gives you real `PanelSplit` and `PanelSwitcher` objects back.

The layout changes `root` in place (it never replaces the object), so you can also keep `root` inside a bigger settings object and save that. Never put panels or HTML elements into the arrangement: saving compares and copies it deeply.

If the saved arrangement doesn't mention a panel (say you added a new panel in a later version of your app), the layout gives it a place automatically: in the largest switcher, or for a fixed panel at the start.

## 9. A default arrangement

Without a saved arrangement, everything starts in one switcher. To start with something nicer, build the tree yourself:

```
static PanelSplit createDefaultLayout
	return {children:[
		FixedPanelPlace(key:"Board"),
		PanelSwitcher(size:1000),
		PanelSwitcher(size:300, keys:["Explorer", "Search"])
	]}
```

This makes a row: the Board on the left, an empty main switcher (all other panels will be placed there because it is the largest) and a 300 px sidebar with Explorer and Search.

A column on the right with two switchers:

```
	return {children:[
		PanelSwitcher(size:1000, keys:["Editor"]),
		PanelSplit(vertical:true, size:400, children:[
			PanelSwitcher(size:600, keys:["Preview"]),
			PanelSwitcher(size:250, keys:["Terminal"])
		])
	]}
```

## 10. Fixed and auto-width panels

```
Panel Board
	title = "Board"
	fixed = true
	autoWidth = true
	draw
		row overflowX:auto
			for c in columns
				drawColumn c
```

The board has no tab and never moves. The user can still drop panels on any of its sides. Because of `autoWidth` it takes exactly the width of its columns. If the window is too narrow it shrinks, and its own `overflowX:auto` lets it scroll.

## 11. Doing things from code

```
layout.show agentPanel	// switch its switcher to it
layout.show terminal, focus:true	// ... and give it the keyboard focus (Panel.focus)
if layout.isShown(browser) then browser.reload

// A panel goes away: remove it from what panels returns, then tell the layout
openFiles.remove editor
layout.close editor	// its switcher shows the previous panel, its place is forgotten
layout.close settings, keepPlace:true	// remembers the spot for next time
```

`show` does nothing for a panel that `panels` doesn't currently return. That's intentional: if a background job wants to show the chat of a task that isn't selected, nothing jumps around.

Each switcher remembers the order in which its panels were shown (`history`). When the shown panel closes or disappears, the one shown before it takes over.

## 12. Hiding panels

- `hidden = true`: the layout acts as if the panel didn't exist. Good for a sidebar the user can switch off. If all panels of a switcher are hidden, the switcher disappears and its space goes to the others. Set it back to `false` and everything returns where it was.
- `tabHidden = true`: the panel has no tab, but its switcher still shows it if it was the one shown last. Good for panels that are only sometimes relevant.

## 13. The panel lifecycle

| Method | Called when |
|---|---|
| `start` | The panel is shown for the first time (once) |
| `show` | It became visible: it was clicked, dropped somewhere, or another item's panel was replaced by it |
| `hide` | It is no longer visible |
| `focus` | `layout.show panel, focus:true` or a click on its tab |
| `setCommands: bool shown` | Before each draw, for every panel (if you call `layout.setCommands`), so it can enable its menu commands. `shown` tells whether it is visible. |

`show` and `hide` from the layout's own detection run right after the draw, so they may call `refresh`.

## 14. Toolbars in the header

A switcher's header has room for buttons after the tabs and at the right end. Draw them with `drawToolbar`. It gets the switcher and whether it should draw the left or the right part:

```
Layout layout = {panels:allPanels, drawToolbar:drawButtons(switcher, left)}

drawButtons: PanelSwitcher switcher, bool left
	Panel shown = layout.findShownPanel(switcher, layout.findPanels)
	if not left and shown == terminal then button "Clear", onClick:terminal.clear
	// Global buttons only once: in the largest switcher
	if not left and switcher == layout.mainSwitcher then button "Settings", onClick:openSettings
```

## 15. Looks

- `tabColor`: color of the tabs (the shown one is filled) and of the drop previews.
- `dividerColor`: color of the edges.
- `minimumSize`: the smallest size resizing allows.

```
Layout layout = {panels:allPanels, tabColor:app.primaryColor, dividerColor:#00000018}
```

## 16. Common mistakes

- **Forgetting the tag**: without `layout` in `Tags`, the classes don't exist.
- **Changing titles without a place**: the panel jumps to the largest switcher because its place "changed". Set `place`.
- **Passing null**: `layout.show null` is safe, but your own `list.includes(panel)` throws if `panel` is null.
- **Storing panels in the arrangement**: the arrangement is saved and compared, so keep it plain data.
- **Removing a panel without `close`**: it works (its tab just disappears), but the switcher keeps its place forever. Call `layout.close` when the panel is really gone.
