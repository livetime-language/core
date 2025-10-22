---
description: LiveTime Programming Language, Pocketbase and HTML Framework
globs: *.l
alwaysApply: true
---
# We use the LiveTime Programming Language
LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation, never spaces. 

LiveTime uses inline styles for all html elements. Important: To re-render the html after changing data, you need to call refresh.

# ToDo-List Example
// Defines the enum ItemState
enum ItemState
	NotStarted
	InProgress
	Done

// Defines the class TodoItem
// Classes have uppercase names. All members are public by default.
class TodoItem
	int id
	ItemState state
	bool active = true
	string text

// Defines the static class app, the main class of every LiveTime application.
// Static classes have lowercase names. Their members are public and static by default.
// You can access its members from anywhere like this: app.items, app.newItemText, app.start, app.draw, ...
static class app
	Color primaryColor = #000000
	TodoItem[] items
	string newItemText = ""

	// Defines the member function start of the class app. 
	// All functions are member functions of a class. There are no top-level functions or nested functions in LiveTime.
	// app.start is the entry point of the application. It is called when the application starts.
	start
		items.add {text:"Buy groceries", state:Done}
		items.add {text:"Learn LiveTime", state:InProgress}

	// Defines the member function draw of the class app. 
	// app.draw is called to render the html elements when the application starts and when the refresh function is called.
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

	// All functions that render html should start with "draw"
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

class Document
	string id
	float created
	State state

static class app
	Document[] documents
	DatabaseTable<Document> documentsDatabaseTable = {name:"documents"}
	string name
	int counter

	start
		// List (array that can grow and shrink)
		Document[] documents = [
			{created:DateTime.now, state:InProgress}
		]
		Document doc = {id:"002e", created:DateTime.now, state:Done}
		documents.add doc
		documents.remove doc
		documents.orderBy.created
		documents.clear
		let firstTwoItems = documents[..2]
		let lastTwoItems = documents[-2..]

		// Map (called Hashtable or Dictionary in other languages)
		Document[string] documentsById
		documentsById["002f"] = {id:"002f"}
		documentsById.remove "002f"
		documentsById.clear
		for documents as doc
			documentsById[doc.id] = doc
		for documentsById as doc, id
			print "id:{id} created:{doc.created.toDayMonthYearString}"

		// Conditions
		if documents.length > 0
			print "There are {documents.length} documents."
		else
			print "There are no documents."

		// Iterate over a List
		for documents as doc
			print doc.id

		// Iterate over an integer range
		// Prints 01234
		for 0 to 5 as i
			print i

		// If you leave out the lower bound, it defaults to 0
		// If you leave out the index variable, it defaults to i
		for 5
			print i

		// You can use "." to refer to the current item while iterating
		for documents
			print .

		// Prints 01234
		for 5
			print .
			
		// Use the "backwards" keyword to iterate backwards
		// Prints 43210
		for 5 backwards as i
			print i

		// Iterate over a List by index
		for documents.length as i
			print documents[i].state

		// Iterate over a Map
		for documentsById as value, key
			print "{key}: {value}"

		// Very important: If you divide an integer by an integer in LiveTime, you always get a float
		float fraction = 1 / 2

		// Use math.floor after a division if you need an integer
		int flooredInteger = math.floor(1 / 2)
		
	// This function renders the html elements (on startup and when refresh is called)
	draw
		// Html div element with blue text. Refer to the Styles class for all available css styles.
		div text:"Done documents", fontSize:64, color:#ff0000

		// Html div element with children
		let doneItems = helpers.getAllDoneItems
		div display:flex, border:{width:1px, style:solid, color:black}, margin:{top:10percent, right:auto, bottom:10percent, left:auto}
			for doneItems as doc
				div text:"{doc.created.toDayMonthYearHourMinuteString} {doc.state}"

		// Call refresh to re-render the html after you changed any data.
		div "Counter: {counter}"
		button "Increment counter", onClick:counter++; refresh
		
		// Headlines
		div tag:"h1", text:"Title"
		div tag:"h2", text:"Section"

		// Images
		// Read the file "src/media.l" for all available images 
		img Done, width:64
		img NotDone, width:64

		// Form
		field model:name
		button "Clear name", onClick:name = ""; refresh
		button "Submit name", onClick:http.post "/api/name", body:{name}

		// Units
		div borderRadius:8px
		div width:100percent

		// If you don't specify a unit, it defaults to pixels
		div borderBottomWidth:8

		// Border
		div border:{width:1, style:solid, color:#808080}

		// Shadow
		div boxShadow:{offset:{4,4}, blur:16, spread:4, color:#c0c0c0}

		// Calc
		div width:"calc(100% - 16px)"

static class helpers
	// bool(Document doc) defines a function that takes a Document and returns a boolean
	Document[] filterDocuments: bool(Document doc) predicate
		return app.documents.where predicate(.)

	// void(Document[] documents) defines a function that takes a list of Documents and doesn't return anything
	async fetchAllDocuments: void(Document[] documents) callback
		await app.documentsDatabaseTable.fetchAll
		callback(app.documentsDatabaseTable.items)

	Document getItemByItem: string id
		return app.documents.find.id == id

	Document[] getAllDoneItems
		return app.documents.where.state == Done

	bool areAllItemsDone
		return app.documents.all.state == Done

# Check if everything is correct
1. Fix all linter errors. Do not finish until all linter errors are fixed.
2. The development server is always running at http://localhost:8080
3. Test the app in a browser to ensure it works and looks great. Do not finish until you verified that everything works as planned.

# References
Read this file for all available images in the current project:
src/media.l

Read this file for a complete reference of the LiveTime Programming Language and HTML Framework, with all available classes and functions:
lib/core/html/documentation.md
