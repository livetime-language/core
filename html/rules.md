---
description: LiveTime Programming Language, Pocketbase and HTML Framework
globs: *.l
alwaysApply: true
---
# We use the LiveTime Programming Language
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
	Color primaryColor = #000000
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
		div display:flex, flexDirection:column, gap:16, fontSize:16, margin:{left:32 right:32}
			div tag:"h1", text:"Todo List"

			if items.length > 0
				for items as item
					drawItem item
			else
				div text:"No items", fontSize:16, fontStyle:italic

			div display:flex, gap:20, margin:{top:32}, height:30px
				field model:newItemText, flex:1, width:400, fontSize:16
				button text:"Add", fontSize:16, padding:{left:40 right:40}, cursor:pointer, onClick:addItem newItemText

	// All functions that render html should start with "draw".
	drawItem: TodoItem item
		div display:flex, 
			gap:16,
			cursor:pointer,
			padding:{top:8 right:8 bottom:8 left:8},
			border:{width:2px, style:solid, color:#808080},
			boxShadow:{offset:{4,4}, blur:12, spread:4, color:#d0d0d0}
			onClick:item.state = item.state != Done ? Done : NotStarted; refresh

			div text:item.state == Done ? "☑" : "☐"
			div text:item.text, flex:1, fontWeight:bold, textDecoration:item.state == Done ? "line-through" : "none", color:primaryColor
			div text:"❌", cursor:pointer, onClick:items.remove item; refresh

	addItem: string text
		items.add {text, state:NotStarted}
		newItemText = ""
		refresh

# LiveTime Basics
enum State
	InProgress
	Done

class Item
	State state

static class app
	Item[] items
	string name
	int counter

	start
		// List
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

		// Map (hashtable)
		Item[int] itemById
		itemById[id] = {"My item"}
		itemById.remove id
		itemById.clear
		for items as item
			itemById[item.id] = item
		for itemsById as item, id
			print "id:{id} text:{item.text}"

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

		// Iterate over map
		for itemById as value, key
			print "{key}: {value}"

		// Define a function pointer that takes a touch as a parameter and returns void
		void(Touch touch) onClick

		// Define a function pointer that takes no parameter and returns float
		float() getTemperature

		// Important: If you divide an integer by an integer in LiveTime, you always get a float
		float fraction = 1 / 2

		// Use math.floor after a division if you need an integer
		int flooredInteger = math.floor(1 / 2)
		
	// This function renders the html elements (on startup and when refresh is called)
	draw
		// Div with blue text. Refer to the Styles class for all available css styles.
		div text:"Done items", fontSize:64, color:#ff0000

		// Div with children
		let doneItems = helpers.getAllDoneItems
		div display:flex, border:{width:1px, style:solid, color:black}, margin:{top:10percent, right:auto, bottom:10percent, left:auto}
			for doneItems as item
				div item.text

		// Call refresh to re-render the html after you changed any data.
		div "Counter: {counter}"
		button "Increment counter", onClick:counter++; refresh
		
		// Headlines
		div tag:"h1", text:"Title"
		div tag:"h2", text:"Section"

		// Read the file "src/media.l" for all available images 
		img Done, width:64
		img NotDone, width:64

		// Units
		div borderRadius:8px
		div width:100percent

		// If you don't specify a unit, it defaults to pixels
		div borderBottomWidth:8

		// Form
		field model:name
		button "Clear name", onClick:name = ""; refresh
		button "Submit name", onClick:http.post "/api/name", body:{name}

		// Border
		div border:{width:1, style:solid, color:#808080}

		// Shadow
		div boxShadow:{offset:{4,4}, blur:16, spread:4, color:#c0c0c0}

		// Calc
		div width:"calc(100% - 16px)"

static class helpers
	Item getItemByItem: int id
		return app.items.find.id == id

	Item[] getAllDoneItems
		return app.items.where.state == Done

	bool areAllItemsDone
		return app.items.all.state == Done

# References
Read this file for all available images in the current project:
src/media.l

Read this file for a complete reference of the LiveTime Programming Language and HTML Framwork with all available classes and functions:
lib/core/html/documentation.md
