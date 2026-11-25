# Layout (lib/core/html/layout)
Panels in tabbed switchers that the user resizes and rearranges by dragging, like the editors of VS Code. Needs the tag `layout` in `.livetime/targets.lc`.

## Use
```
Panel NotesPanel
	title = "Notes"
	draw	// extends Panel.draw, which starts the panel on its first draw
		div "Notes", flex:1

app
	Panel board = Board(fixed:true, autoWidth:true)
	NotesPanel notes = {}
	Layout layout = {panels:[board, notes], onChange:saveLayout}
	start
		layout.root = loadedLayout or {}	// a saved PanelSplit, restored as it was
	draw
		column position:fixed, inset:0
			layout.draw
```
- `panels` is a function, evaluated whenever needed: return what is shown now (e.g. the panels of the selected item).
- Call `layout.setCommands shown` before each draw if panels use `setCommands`.

## Panel
- `title`: tab text. `place`: key of its spot in the layout (default: title). Keep it stable: a panel whose title changes needs a `place`. Panels of different items with the same place take turns there.
- `fixed`: no tab, not draggable, others can be dropped beside it. `autoWidth`: as wide as its content, not resizable.
- `hidden`: left out (e.g. a hidden sidebar). `tabHidden`: no tab, still shown if it was shown last.
- `closeable`: while shown, a cross at the right end of its switcher's header calls `close`, which the panel implements (remove it from `panels`, call `layout.close`).
- `tabTogglesVisibility`: a click on its tab while it is shown hides its switcher (`layout.hideSwitcher`, without it the switcher's panels get `hidden`).
- Lifecycle: `start` (first time visible), `show` (became visible), `hide` (no longer visible), `focus`, `setCommands: bool shown`.

## Layout
- `root: PanelSplit`: the arrangement, plain data (`PanelSplit{vertical, children}`, `PanelSwitcher{keys, history}`, `FixedPanelPlace{key}`, each with `size` in px). Changed in place; save it in `onChange` (e.g. `object.toYaml`, restore with `object.fromYaml`). Never put panels or elements into it.
- `show panel, focus`: makes it the shown tab of its switcher. Ignores panels that `panels` doesn't return.
- `close panel, keepPlace`: its switcher shows the previous panel. Remove the panel from `panels` yourself. Without `keepPlace`, its spot is forgotten and an emptied switcher disappears.
- `isShown panel`, `findShownPanel(switcher, findPanels)`, `findSwitcher(placeKey)`.
- `drawToolbar: (switcher, left)`: draws header buttons after the tabs (left) or at the right end.
- `hideSwitcher: (switcher)`: hides a switcher whose shown tab with `tabTogglesVisibility` was clicked. `drawCloseButton: (panel)`: draws the cross of a closeable panel, otherwise the layout draws `closeIcon`.
- `mainSwitcher`: the largest switcher; panels without a spot go there. `tabColor`, `dividerColor`, `minimumSize`.
- Default arrangement: build a `PanelSplit` with `FixedPanelPlace(key:…)` and `PanelSwitcher(size:…, keys:[…])`. Panels missing from it are added automatically.

## Pitfalls
- `list.includes(null)` throws: check panels for null before passing them.
- The largest node of a split fills the remaining space, the others keep their `size`.
