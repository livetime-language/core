---
description: LiveTime Programming Language
globs: *.l
---
# We use the LiveTime Programming Language and HTML Framework with a PocketBase backend
LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation (never spaces). 

LiveTime uses inline styles for all html elements. Important: To re-render the html after changing data, you need to call refresh.

Always write the simplest possible and most efficient code. Avoid code duplication.

# Example application
// Defines the enum ItemState that stores its values as strings
enum string ItemState
	NotStarted
	InProgress
	Done

// Defines the class User
// Classes have uppercase names. All members are public by default.
class User
	string id
	string email
	string password

// Defines the class TodoItem
class TodoItem
	string id
	string userId
	ItemState state = NotStarted
	string text

// Defines the static class app, the main class of every LiveTime application.
// Static classes have lowercase names. Their members are public and static by default.
// You can access their members from anywhere like this: app.items, app.newItemText, app.start, app.draw, ...
static class app
	const Color primaryColor = #118ab2
	const fontSize = 16px
	const Padding buttonPadding = {topAndBottom:6 leftAndRight:16}

	User user
	DatabaseTable<TodoItem> items = {name:"todoItems"}

	string newItemText
	string email, password

	// Defines the member function start of the class app. 
	// All functions need to be part of a class. There are no top-level functions in LiveTime.
	// app.start is the entry point of the application. It is called when the application starts.
	start
		user = await database.getAuthenticatedUser
		fetchItems

	fetchItems
		if not user: return
		await items.fetch filter:"userId = '{user.id}'"
		refresh

	// Defines the member function draw of the class app. 
	// app.draw is called to render the html elements when the application starts and when the refresh function is called.
	draw
		if not user
			column gap:8 margin:{all:40px}
				div tag:"h1", text:"Login"
				field model:email, type:email, placeholder:"Email", fontSize
				field model:password, type:password, placeholder:"Password", fontSize

				button text:"Login", fontSize, padding:buttonPadding, color:white, backgroundColor:primaryColor
					onClick:
						user = await database.authWithPassword email, password
						fetchItems
		else
			div display:flex, flexDirection:column, gap:16, fontSize, margin:{left:32 right:32}
				row alignItems:center
					div tag:"h1", text:"Todo List", flex:1

					button "Logout", fontSize, padding:buttonPadding, color:white, backgroundColor:primaryColor
						onClick:
							database.logout
							user = null
							refresh

				if items.length > 0
					for items as item
						drawItem item
				else
					div text:"No items", fontSize, fontStyle:italic

				div display:flex, gap:20, margin:{top:16}, height:30px
					field model:newItemText, flex:1, width:400, fontSize, onEnter:addItem newItemText
					button text:"Add", fontSize, padding:buttonPadding, cursor:pointer, color:white, backgroundColor:primaryColor, onClick:addItem newItemText

	// All functions that render html should start with "draw"
	drawItem: TodoItem item
		div display:flex, 
			gap:16,
			cursor:pointer,
			padding:{top:8 right:8 bottom:8 left:8},
			border:{width:2px, style:solid, color:#808080},
			boxShadow:{offset:{4,4}, blur:12, spread:4, color:#d0d0d0},
			onClick:
				// Toggle the state of the item
				ItemState state = item.state != Done ? Done : NotStarted
				await items.update item, {state}
				refresh
			children:
				div text:item.state == Done ? "☑" : "☐"
				div text:item.text, flex:1, fontWeight:bold, textDecoration:item.state == Done ? "line-through" : "none"
				div text:"❌", cursor:pointer, onClick:await items.remove item; refresh

	addItem: string text
		await items.add {userId:user.id, state:NotStarted, text}
		newItemText = ""
		refresh
		
# Basics of the LiveTime programming language
enum State
	InProgress
	Done

class Document
	string id
	float created
	State state

static class app
	Color buttonColor = #0000ff
	Document[] documents
	DatabaseTable<Document> documentsDatabaseTable = {name:"documents"}
	string name
	int counter

	start
		// List (array that grows in size as needed)
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

		// Dictionary (hashtable that maps keys to values)
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

		// Iterate over a Dictionary
		for documentsById as value, key
			print "{key}: {value}"

		// If you divide an integer by an integer in LiveTime, you always get a float
		float fraction = 1 / 2

		// Use math.floor after a division if you need an integer
		int flooredInteger = math.floor(1 / 2)

		// Cast
		string jsonString = "\{value:7\}"
		dynamic config = json.parse(jsonString)
		int value = (int)config.value

		// In LiveTime, the % symbol is used for percentages, like in css, e.g. width:100%
		// To calucate the remainder of a division, use mod or remainder. 
		// mod returns the remainder after a floored division, always producing a result with the same sign as the divisor, like in Python.
		float bufferSize = 100
		let a = 107 mod bufferSize // a = 7
		let b = -1 mod bufferSize  // b = 99
		
	// This function renders the html elements (on startup and when refresh is called)
	draw
		// Html div element with blue text. Refer to the Styles class for all available css styles.
		div text:"Hello", color:#ff0000, border:{width:1px, style:solid, color:black}, margin:{top:10%, right:auto, bottom:10%, left:auto}

		// Html div element with children
		let doneItems = helpers.getAllDoneItems
		div display:flex, flexDirection:column
			for doneItems as doc
				div text:"{doc.created.toDayMonthYearHourMinuteString} {doc.state}"

		// Html div element with onClick handler and children (include the "children:" label in this case)
		div display:flex, flexDirection:row, backgroundColor:app.buttonColor
			onClick:
				print "Saving document"
			children:
				img SaveIcon
				div "Save", fontSize:64, color:white

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
		div width:100%

		// If you don't specify a unit, it defaults to pixels
		div borderBottomWidth:8

		// Border
		div border:{width:1, style:solid, color:#808080}

		// Shadow
		div boxShadow:{offset:{4,4}, blur:16, spread:4, color:#c0c0c0}

		// Instead of a value, you can specify a css string. In css, you always need to specify units.
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

# More information
Read this file for all available images in the current project:
src/media.l

Read this file for a complete reference of the LiveTime Programming Language and HTML Framework, with all available classes and functions:
lib/core/html/documentation.md
Always read this documentation if you encounter problems.

# Check if everything is correct
Always add some debug logs that will help you find out what is the problem in case the code isn't working as expected.

1. Double check your code to ensure you wrote the simples possible, most efficient code.
2. Double check you fixed all linter errors.
3. Navigate to http://localhost:8080 in the browser. Test the app to ensure it works and looks great.

Do not finish until all errors are fixed and you verified that everything works as intended.
