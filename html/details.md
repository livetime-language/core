	js void navigateTo: string url	// Use js keyword to write function body in JavaScript for low-level interop. Return type is required.
		location.href = url;	// JavaScript code. Do not use nested functions.

# HTML Framework
Elements that are grouped together visually should be in the same function.

# Improve core library if needed
Avoid javascript function bodies in application code if possible. If the core library (lib/core/) is missing a feature you need, that might be useful in other projects, implement it in a way, that enables the simplest, most elegant application code. The core library is used in many projects. Be careful not to break other projects. Don't change the behavior of the library, unless you are fixing a bug. Don't put application-specific code in the library.

# Test when you are done
When you are done, always test the build to verify everything works as specified.

# HTML pitfalls
- An element reuses the one drawn at the same position by the same code, keeping its text but getting the new item's handlers, so a field being edited saves to another item when items move before it. Key lists with fields (`key:`, `keyOf:` of `forDraggable`).
- A focused element removed by a refresh gets a blur event with the locals of its old draw: check member variables there, not captured locals.
- `state` variables belong to the call's location and its position in the order of calls of a draw, so calls must not change their order while the state matters.
- `refresh` clears the stylesheet: add `html.style` rules in every `draw`.
- `row` and `column` have no `styleWhenHovering`: use `div display:flex`.
- `lineHeight` is a factor of the font size, not a length.
- `forDraggable` drags elements with computed `cursor:move`.
- Register keys that aren't commands with `html.onKeyDown` once in `app.start`, with `whileEditingText:false` for keys text fields need.
- Shift-clicks extend the page's selection: `onPointerDown:if ev.shiftKey then ev.preventDefault`.
- Don't use `userSelect:"none"` on ancestors of inputs: Safari can't type into them.
- Windows narrower than 1000px get a 500px layout (`system.referenceSizes`).
