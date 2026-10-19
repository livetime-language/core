# Example: ToDo app
// Define enum that stores its values as strings
enum string ItemState
	NotStarted
	InProgress
	Done

// Models are classes stored in the database
// List rule:	@request.auth.id != ""
// View rule:	@request.auth.id != ""
// Create rule:	id = "" || id = @request.auth.id
// Update rule:	@request.auth.id != "" && id = @request.auth.id
// Delete rule:	@request.auth.id != "" && id = @request.auth.id
// Index:	email
model User
	string id
	string email
	string password
	
// List rule:	@request.auth.id != "" && userId = @request.auth.id
// View rule:	@request.auth.id != "" && userId = @request.auth.id
// Create rule:	@request.auth.id != "" && userId = @request.auth.id
// Update rule:	@request.auth.id != "" && userId = @request.auth.id && @request.body.userId:changed = false
// Delete rule:	@request.auth.id != "" && userId = @request.auth.id
// Index: userId
model TodoItem
	string id
	string userId
	ItemState state = NotStarted
	string text
	TimeString created, updated

static class app
	const Color primaryColor = #118ab2
	const fontSize = 16px
	const Padding buttonPadding = {topAndBottom:6 leftAndRight:16}

	// Used to add, remove, fetch and update items from a remote PocketBase collection. Also stores TodoItems locally in the member variable "items".
	DatabaseTable<TodoItem> items = {name:"todoItems"}

	User user
	string newItemText
	string email, password

	// All functions need to be part of a class. There are no top-level functions in LiveTime.
	// app.start is the entry point of the application. It is called when the application starts.
	start
		user = await backend.getAuthenticatedUser
		fetchItems

	fetchItems
		if not user then return
		await items.fetch filter:"userId = '{user.id}'"
		refresh

	// app.draw is called to render the html elements when the application starts or when the refresh function is called.
	draw
		if not user
			column gap:8 margin:{all:40px}
				div tag:"h1", "Login"
				field model:email, type:email, placeholder:"Email", fontSize
				field model:password, type:password, placeholder:"Password", fontSize

				button "Login", fontSize, padding:buttonPadding, color:white, backgroundColor:primaryColor
					onClick:
						user = await backend.authWithPassword email, password
						fetchItems
		else
			div display:flex, flexDirection:column, gap:16, fontSize, margin:{left:32 right:32}
				row alignItems:center
					div tag:"h1", text:"Todo List", flex:1

					button "Logout", fontSize, padding:buttonPadding, color:white, backgroundColor:primaryColor
						onClick:
							backend.logout
							user = null
							refresh

				if items.length > 0
					for items.items
						drawItem .
				else
					div "No items", fontSize, fontStyle:italic

				div display:flex, gap:20, margin:{top:16}, height:30px
					field model:newItemText, flex:1, width:400, fontSize, onEnter:addItem newItemText
					button "Add", fontSize, padding:buttonPadding, cursor:pointer, color:white, backgroundColor:primaryColor, onClick:addItem newItemText

	// Functions that render html should start with "draw"
	drawItem: TodoItem item
		div display:flex, 
			gap:16,
			cursor:pointer,
			padding:{top:8 right:8 bottom:8 left:8},
			border:{width:2px, style:solid, color:#808080},
			boxShadow:{offset:{4,4}, blur:12, spread:4, color:#d0d0d0},
			children:
				div item.state == Done ? "☑" : "☐"
				div item.text, flex:1, fontWeight:bold, textDecoration:item.state == Done ? linethrough : none
				div "❌", cursor:pointer, onClick:await items.remove item; refresh
			onClick:
				// Toggle the state of the item
				ItemState state = item.state != Done ? Done : NotStarted
				await items.update item, {state}
				refresh

	addItem: string text
		await items.add {userId:user.id, state:NotStarted, text}
		newItemText = ""
		refresh
