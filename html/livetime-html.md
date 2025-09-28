---
description: LiveTime Programming Language, HTML Framework and Standard Library
globs: *.l
alwaysApply: true
---
# We use the LiveTime programming language and HTML Framework
LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation, never spaces. 

LiveTime uses inline styles for all html elements. Important: To re-render the html after changing data, you need to call refresh.

# ToDo-List Example
// Defines the "ItemState" enum.
enum ItemState
	NotStarted
	InProgress
	Done

// Defines the "TodoItem" class. All fields are public by default.
class TodoItem
	int id
	ItemState state
	bool active = true
	string text

// Defines the main class "app". Classes with lowercase names are singletons.
// You can access their fields from anywhere like this: app.items, app.newItemText, app.start, app.draw, ...
static class app
	TodoItem[] items
	string newItemText = ""

	// Defines the function "start" of the class "app".
	// All functions need to be part of a class. There are no top-level functions in LiveTime.
	// This function is called when the application starts.
	start
		items.add {text:"Buy groceries", state:Done}
		items.add {text:"Learn LiveTime", state:InProgress}

	// This function is called to render the html elements when the application starts or when the refresh function is called.
	draw
		div display:Flex, flexDirection:Column, gap:30, fontSize:60, margin:{top:80 left:80}
			div tag:"h1", text:"Todo List"
			if items.length > 0
				for items as item
					drawItem item
			else
				div text:"No items", fontSize:60, fontStyle:Italic

			div display:Flex, gap:20
				field model:newItemText width:400, fontSize:60
				button text:"Add", fontSize:60, padding:{left:40 right:40}, cursor:Pointer, onClick:addItem newItemText

	// All functions that render html should start with "draw".
	drawItem: TodoItem item
		div display:Flex, gap:20, cursor:Pointer, onClick:item.state = item.state != Done ? Done : NotStarted; refresh
			div text:item.state == Done ? "☑" : "☐"
			div text:item.text, textDecoration:item.state == Done ? "line-through" : "none"
			div text:"❌", cursor:Pointer, onClick:items.remove item; refresh

	addItem: string text
		items.add {text, state:NotStarted}
		newItemText = ""
		refresh

# LiveTime Basics
static class app
	Item[] items
	string name

	start
		// Lists
		TodoItem[] items = [
			{text:"Example", state:NotStarted}
		]
		Item newItem = {"Another example"}
		items.add newItem
		items.remove newItem
		items.orderBy.text
		items.clear
		let firstTwoItems = items[..2]
		let lastTwoItems = items[-2..]

		// Maps
		Item[int] itemById
		for items as item
			itemById[item.id] = item
		for itemsById as item, id
			print "id:{id} text:{item.text}"
		items.clear

		// Conditions
		if items.length > 0
			print "There are {items.length} items."
		else
			print "There are no items."

		// Iterate over items
		for items as item
			print item.text

		// Iterate over an integer range
		for items.length as i
			print item[i].text

		// Prints 01234
		for 0 to 5 as i
			print i

		// In a for loop, the lower bound is 0 by default, and the current index is named i by default, so we can leave them out. 
		// Prints 01234
		for 5
			print i

		// Use "backwards" to iterate backwards
		// Prints 43210
		for 5 backwards as i
			print i

		// Important: If you divide an integer by an integer in LiveTime, you always get a float
		float fraction = 1 / 2

		// Use math.floor after a division if you need an integer
		int flooredInteger = math.floor(1 / 2)
		
	// This function renders the html elements (on startup and when refresh is called)
	draw
		// Div with blue text
		div text:"Done items" fontSize:64 color:#0000ff

		// Div with children
		let doneItems = helpers.getAllDoneItems
		div display:Flex border:{width:1px, style:Solid, color:Black} margin:{top:8, right:8, bottom:8, left:8}
			for doneItems as item
				div item.text

		// Headlines
		div tag:"h1", text:"Title"
		div tag:"h2", text:"Section"

		// Read the file "src/media.l" for all available images 
		img Done, width:64
		img NotDone, width:64

		// Form
		field model:name
		button "Clear name", onClick:name = ""; refresh
		button "Submit name", onClick:http.post "/api/name", body:{name}

static class helpers
	Item getItemByItem: int id
		return app.items.find.id == id

	Item[] getAllDoneItems
		return app.items.where.state == Done

	bool areAllItemsDone
		return app.items.all.state == Done

# References
For all available styles, read this file:
lib/core/html/styles.l

For all available html elements, read this file:
lib/core/html/html.l

For all available classes and functions in the LiveTime Standard Library, read this file:
lib/core/js/base.l

For all available images in the current project, read this file:
src/media.l
