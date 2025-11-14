// Use this static class to login and logout users from the PocketBase backend. 
// You can administer the local PocketBase instance at: http://localhost:8090/_ 
// If you want to dive deeper into PocketBase, you can find the complete documentation at: https://pocketbase.io/docs/ 
// Example:
//     class User
//         string id
//         string name
//     static class app
//         User user
//         start
//             user = await database.getAuthenticatedUser
//             refresh
//         login: string email, string password
//             user = await database.authWithPassword email, password
//             refresh
//         logout
//             database.logout
//             user = null
//             refresh
transient skipInit static class database
	string url, libUrl
	dynamic pb
	DatabaseTable<User> users
	
	// Called automatically in Platform.start
	internal async void connect: string url
		database.url = database.libUrl = url + "/"
		await connect
		
	// Called automatically in Platform.start
	internal async js void connect
		if(!database.url) database.url = window.location && window.location.host && !Platform.isDebug ? location.origin : "http://localhost:8090"
		const PocketBase = (await import((database.libUrl || _basePath || location.href.getUntilLast("/")+"/")+"lib/pocketbase.es.js")).default
		if(database.pb) database.pb.realtime.unsubscribe();
		database.pb = new PocketBase(database.url);
		this.users = new DatabaseTable("users", []);
		
	// Calls the PocketBase authRefresh function to get the authenticated user. Call this function when the application starts.
	// Example:
	//     app
	//         User user
	//         start
	//             user = await database.getAuthenticatedUser
	//             refresh
	importance:5 async
	dynamic getAuthenticatedUser
		try
			let result = await pb.collection("users").authRefresh();
			return result.record
		catch as error
			logout
			return null

	// Log in a user with an email and password and return the authenticated user
	// Example:
	//     app
	//        drawLogin
	//            field model:email, type:email, placeholder:"Email"
	//            field model:password, type:password, placeholder:"Password"
	//            button text:"Login", padding:buttonPadding, color:white, backgroundColor:primaryColor
	//                onClick:
	//                    user = await database.authWithPassword email, password
	importance:5 async 
	dynamic authWithPassword: string email
		                      string password
		let result = await pb.collection("users").authWithPassword(email, password)
		return result.record

	// Create a new user and then call authWithPassword to log in the user. 
	// Ensure the user object has a valid email, password and passwordConfirm member variables.
	// Example:
	//     class User
	//         string email
	//         string password
	//         string passwordConfirm
	//     app
	//        User user
	//        drawSignup
	//            field model:user.email, type:email, placeholder:"Email"
	//            field model:user.password, type:password, placeholder:"Choose Password"
	//            field model:user.passwordConfirm, type:password, placeholder:"Confirm Password"
	//            button text:"Signup", padding:buttonPadding, color:white, backgroundColor:primaryColor
	//                onClick:
	//                    await database.signupNewUser user
	importance:5 async
	dynamic signupNewUser: dynamic user // A user object with a valid email, password and passwordConfirm member variables
		await users.add(user)
		return await authWithPassword(user.email, user.password)

	// Log out the current user
	// Example:
	//     app
	//         User user
	//         logout
	//             database.logout
	//             user = null
	importance:5
	void logout
		pb.authStore.clear();
		Platform.removeLocalStorageItem('pocketbase_auth');

	// Duplicated pending requests are automatically cancelled by default. Use this funtion to enable or disable this.
	// Example:
	//     itemsTable.fetchAll // canceled
	//     itemsTable.fetchAll // canceled
	//     itemsTable.fetchAll // executed
	inline void autoCancellation: value = true
		pb.autoCancellation(value)
		
	inline js void onAuthChanged: inline void(dynamic user) code
		database.pb.authStore.onChange((token, record) => code(record))
		
	inline js string token
		database.pb.authStore.token

// Use this class to add, remove, fetch and update items from a remote PocketBase collection. 
// The items are stored locally in the member variable "items". Use the functions "get", "find", "where" and "length" to access the local items.
// You can also subscribe to changes in the remote PocketBase collection to automatically keep the local items up to date in realtime.
DatabaseTable<T> 
	// The name of the remote PocketBase collection
	importance:5 string name

	// The items you fetch from the database are stored locally in this list
	importance:5 T[] items = []

	// ------------------------------------------------------- Add -------------------------------------------------------

	// Add an item to the database table and the local items and set its id member variable to the id assigned by the database
	// Example:
	//     class Item
	//         string id
	//         string name
	//     app
	//         DatabaseTable<Item> items = {name:"items"}
	//         string newItemName
	//         draw
	//             field model:newItemName, placeholder:"Item name"
	//             button text:"Add", onClick:addItem {name:newItemName}
	//         addItem: Item item
	//             await items.add item
	//             print "Added item to database and assigned id: {item.id}"
	//             refresh
	importance:5
	async void add: T item // An item with a id member variable of type string that is not set yet
		dynamic dynamicItem = item
		dynamic newRecord = await database.pb.collection(this.name).create(item)
		dynamicItem.id = newRecord.id
		items.add item

	// If the item has a valid id member variable, update the item, otherwise add it to the database table
	importance:3
	async js T save: T item
		if(!item.id) {
			let newRecord = await database.pb.collection(this.name).create(item);
			item.id = newRecord.id
		} else {
			await database.pb.collection(this.name).update(item.id, item)
		}
	
	// ------------------------------------------------------- Remove -------------------------------------------------------

	// Remove an item from the database table and the local items
	// Example:
	//     app
	//         DatabaseTable<Item> items = {name:"items"}
	//         draw
	//             for items as item
	//                 div item.name
	//                 div "Remove item", onClick:items.remove item; refresh
	importance:5
	async void remove: T item // An item with a valid id member variable of type string
		dynamic dynamicItem = item
		await database.pb.collection(this.name).delete(dynamicItem.id)
		items.remove item
		
	// ------------------------------------------------------- Fetch -------------------------------------------------------

	// The total number of items in the database
	int totalItemsOfLastFetch
	
	// Fetch all items from the database table and store them locally in the member variable "items"
	// Example:
	//     class Item
	//         string id
	//         string name
	//     app
	//         DatabaseTable<Item> items = {name:"items"}
	//         start
	//             await items.fetchAll
	//             refresh
	//         draw
	//             for items as item
	//                 div item.name
	importance:5 
	async T[] fetchAll
		items = cast await database.pb.collection(this.name).getFullList()
		return items
		
	// Fetch a subset of items from the database table and store them locally in the member variable "items"
	// Example:
	//     class Item
	//         string id
	//         string userId
	//         string active
	//         TimeString created
	//     app
	//         DatabaseTable<Item> items = {name:"items"}
	//         User user
	//         start
	//             await items.fetch filter:"userId = '{user.id}' && active = true", sort:"-created"
	//             refresh
	//         draw
	//             div "{user.name} has {items.length} active items:"
	//             for items as item
	//                 div item.name
	importance:5 
	async T[] fetch: string filter = null
		             string sort = null
					 string fields = null
		             string expand = null
		             int page = 1
		             int perPage = 1000
					 bool skipTotal = true
		let result = await database.pb.collection(this.name).getList(page, perPage, {filter, sort, expand, skipTotal, fields})
		items = cast result.items
		totalItemsOfLastFetch = result.totalItems
		return items
		
	// Fetch and return a single item from the database table
	importance:5 async
	T fetchOne: string filter = ""
		              string sort = null
		              string expand = null
		let result = await database.pb.collection(this.name).getList(1, 1, {filter, sort, expand, skipTotal:true})
		return result.items[0]
		
	// Fetch and return a single item from the database by id
	importance:5 async
	T fetchOneById: string id
		let result = database.pb.collection(this.name).getOne(id)
		return result.items[0]

	// ------------------------------------------------------- Update -------------------------------------------------------

	// Update an item with a valid id member variable in the database table and the local items
	// Example:
	//     app
	//         DatabaseTable<Item> items = {name:"items"}
	//         drawItem: Item item
	//             div "{item.name}, active:{item.active}"
	//             div "Make item active", onClick:items.update item, {active:true}; refresh
	importance:5
	async void update: T item
		               dynamic update
		dynamic dynamicItem = item
		await database.pb.collection(this.name).update(dynamicItem.id, update)
		forDynamic update: dynamicItem[key] = .
		
	// Update a complete item with a valid id member variable in the database table and the local items
	// Example:
	//     app
	//         DatabaseTable<Item> items = {name:"items"}
	//         updateItem: Item item
	//             await items.update item
	//             print "Updated item in database"
	importance:3
	async void update: T item // An item with a valid id member variable of type string
		dynamic dynamicItem = item
		database.pb.collection(this.name).update(dynamicItem.id, item)
		
	// Update a single field of an item with a valid id member variable in the database table and the local items
	// Example:
	//     app
	//         DatabaseTable<Item> items = {name:"items"}
	//         drawItem: Item item
	//             div "{item.name}, active:{item.active}"
	//             div "Make item active", onClick:items.updateField item, fieldName:"active", value:true; refresh
	importance:3
	async js void updateField: T item
		                       string fieldName
					           dynamic value
		item[key] = value
		if(!item.id) {
			await this.add(item)
		} else {
			database.pb.collection(this.name).@update(item.id, {[fieldName]:value})
		}

	// ------------------------------------------------------- Subscribe -------------------------------------------------------
		
	importance:3
	async inline js void subscribe: string topic = "*"
		                            string filter = null
					                string fields = null
		                            string expand = null
		database.pb.collection(this.name).subscribe(topic, e => {
			console.log(e.action, e.record);
			if(e.action == "create") {
				this.items.push(e.record);
			} else if(e.action == "update") {
				let item = this.items.find(i => i.id == e.record.id);
				if(item) {
					Object.assign(item, e.record);
				}
			} else if(e.action == "delete") {
				let item = this.items.find(i => i.id == e.record.id);
				if(item) {
					this.items.remove(item);
				}
			}
		}, {@filter:filter, @fields:fields, @expand:expand})
		
	// ------------------------------------------------------- Upload -------------------------------------------------------
		
	// Upload one or more files to the database table
	importance:3
	async js void upload: T item, string fileFieldName = "images", File[] files
		const formData = new FormData();
		for(let file of files) {
			formData.append(fileFieldName, file);
		}
		let newItem
		if(item.id) {
			newItem = await database.pb.collection(this.name).update(item.id, formData)
		} else {
			for(let key in item) {
				if(key != fileFieldName) {
					let value = item[key];
					let type = typeof(value);
					if(type != "function" && type != "undefined") {
						formData.append(key, value);
					}
				}
			}
			newItem = await database.pb.collection(this.name).create(formData);
			item.id = newItem.id;
		}
		item[fileFieldName] = newItem[fileFieldName]
		return newItem;
		
	// Upload one or more files from urls to the database table
	importance:3
	async js void uploadFromUrls: T item, string fileFieldName = "images", string[] urls
		const formData = new FormData();
		for(let url of urls) {
			const response = await fetch(url);
			const imageBlob = await response.blob();
			formData.append('images', imageBlob, 'moved-image.jpg');
		}
		if(item.id) {
			newItem = await database.pb.collection(this.name).update(item.id, formData)
		} else {
			for(let key in item) {
				if(key != fileFieldName) {
					let value = item[key];
					let type = typeof(value);
					if(type != "function" && type != "undefined") {
						formData.append(key, value);
					}
				}
			}
			newItem = await database.pb.collection(this.name).create(formData);
			item.id = newItem.id;
		}
		item[fileFieldName] = newItem[fileFieldName]
		return newItem;

	// ------------------------------------------------------- Access local items -------------------------------------------------------
	
	// Get a new list that is a subset of the items stored locally in the member variable "items"
	importance:2 
	inline js T[] get: int from = 0 // Return a new list starting from this index, a negative index will start from the end of the list
		               int to       // Return a new list up to (but not including) this index, a negative index is counted from the end
		this.items.slice(from, to)
	
	// Get a new list that is a subset of the items stored locally in the member variable "items"
	importance:2 
	inline js T[] get: int from // Return a new list starting from this index, a negative index will start from the end of the list
		this.items.slice(from)
		
	// Find an item that meets the given condition from the items stored locally in the member variable "items"
	importance:3 
	inline js T find: bool(T a) condition // The condition to check
		this.items.find(condition)
		
	// Find all items that meet the given condition from the items stored locally in the member variable "items"
	importance:3 
	inline js T[] where: bool(T a) condition // The condition to check
		this.items.filter(condition)
	
	// Gets the number of items stored locally in the member variable "items"
	importance:3
	inline js int length() this.items.length
	
	// Shuffle the items stored locally in the member variable "items"
	importance:1 
	inline shuffle() this.items.shuffle
	
	// Remove a random item from the items stored locally in the member variable "items" and return it
	importance:1
	T popRandom()
		if length == 0: return null
		int index = math.randomInteger(length)
		T item = items[index]
		items.removeAt(index)
		return item

global transient priority unit System
	// Do something a given number of times or for each item in a list
	global inline js void for: DatabaseTable<T> subject    // The list to iterate over
		                       -> inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let i=0, _subject=subject.items, _len=_subject.length; i<_len; ++i) do(_subject[i], i)
		
	// Do something a given number of times or for each item in a list
	global inline js void for: DatabaseTable<T> subject    // The list to iterate over
		                       <- inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _subject=subject.items, i=_subject.length-1; i>=0; --i) do(_subject[i], i)
