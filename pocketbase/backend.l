class User

// Use this static class to login and logout users from the PocketBase backend. 
// You can administer the local PocketBase instance at: http://localhost:8090/_ 
// PocketBase Docs: https://pocketbase.io/docs/ 
// Example:
//     class User
//         string id
//         string name
//     static class app
//         User user
//         start
//             user = await backend.getAuthenticatedUser
//             refresh
//         login: string email, string password
//             user = await backend.authWithPassword email, password
//             refresh
//         logout
//             backend.logout
//             user = null
//             refresh
transient skipInit static class backend
	string url, libUrl
	dynamic pocketbase, pocketbaseOrBatch
	DatabaseTable<User> users
	void() onDataChange = null
		
	async js void connect: string url = ""
		if(system.isHeadless) {
			// In headless mode (node.js), we can't load the PocketBase library, so we use a stub
			// that resolves all requests with empty results
			backend.pocketbase = backend.pocketbaseOrBatch = backend.createHeadlessStub()
			this.users = new DatabaseTable("users", [])
			return
		}
		if(url)	backend.url = backend.libUrl = url + "/"
		else	backend.url = window.location && window.location.host && !system.isDebug ? location.origin : "http://localhost:8090"
		const pbUrl = (backend.libUrl || _basePath || location.origin+"/")+"lib/pocketbase.es.js"
		let PocketBase
		try {
			PocketBase = (await import(pbUrl)).default
		} catch(importError) {
			// The page's CSP can block dynamic import (e.g. the bookmarklet running on youtube.com, where script-src
			// only allows Google domains but 'unsafe-eval' is allowed): fetch the module, turn its export statement
			// into a global assignment and eval it as a classic script
			let code = await (await fetch(pbUrl)).text()
			const start = code.lastIndexOf("export{"), end = code.indexOf("}", start)
			if(start == -1) throw importError
			const names = code.slice(start+7, end).split(",").map(n => {
				const p = n.trim().split(" as ")
				return (p[1] || p[0])+":"+p[0]
			})
			code = code.slice(0, start)+";window.__pocketbaseModule={"+names.join(",")+"}"+code.slice(end+1)
			// Pages that enforce require-trusted-types-for 'script' (youtube.com) only eval TrustedScript
			if(window.trustedTypes) try { code = trustedTypes.createPolicy("pocketbase-loader", {createScript: s => s}).createScript(code) } catch(e) {}
			(0,eval)(code)
			PocketBase = window.__pocketbaseModule.default
		}
		if(backend.pocketbase) backend.pocketbase.realtime.unsubscribe();
		backend.pocketbase = backend.pocketbaseOrBatch = new PocketBase(backend.url);
		this.users = new DatabaseTable("users", []);

	// Creates a stub of the PocketBase client for headless mode (node.js) that resolves all requests with empty results
	private js dynamic createHeadlessStub
		const none = async () => null
		const collection = {
			getList: async () => ({items:[], totalItems:0}),
			getFullList: async () => [],
			getFirstListItem: none,
			getOne: none,
			create: async item => ({...item, id:item?.id || "", created:"", updated:""}),
			update: async (id, item) => item,
			delete: none,
			subscribe: none,
			unsubscribe: none,
			authRefresh: none,
			authWithPassword: none,
			requestVerification: none,
			confirmVerification: none,
		}
		return {
			collection: () => collection,
			createBatch: () => ({collection: () => collection, requests: [], send: none}),
			send: none,
			autoCancellation: () => {},
			realtime: {unsubscribe: () => {}},
			authStore: {token:"", clear: () => {}, onChange: () => {}},
		}

	// Call a http GET endpoint on the PocketBase backend (e.g. "/api/custom-endpoint")
	// and automatically includes the auth token
	importance:5 inline js async
	dynamic get: string url // Relative url of the endpoint on the backend, e.g. "/api/negotiate/accept"
		backend.pocketbase.send(url, {method:"GET"})
		
	// Send data to a http POST endpoint on the PocketBase backend (e.g. "/api/custom-endpoint")
	// and automatically includes the auth token
	importance:5 inline js async 
	dynamic post: string url   // Relative url of the endpoint on the backend, e.g. "/api/negotiate/accept"
	              dynamic body // Object with data to send to the backend, e.g. {offerId: "nx7n98bscxomkl4", amount: 5000}
		backend.pocketbase.send(url, {method:"POST", @body:body})
		
	// Calls the PocketBase authRefresh function to get the authenticated user. Call this function when the application starts.
	// Example:
	//     app
	//         User user
	//         start
	//             user = await backend.getAuthenticatedUser
	//             refresh
	importance:5 async
	dynamic getAuthenticatedUser
		try
			if system.getLocalStorageString("pocketbase_auth")
				let result = await pocketbase.collection("users").authRefresh();
				return result.record
		catch as error
			print error
			if not system.isDebug then logout
		return null

	// Log in a user with an email and password and return the authenticated user
	// Example:
	//     app
	//        drawLogin
	//            field model:email, type:email, placeholder:"Email"
	//            field model:password, type:password, placeholder:"Password"
	//            button text:"Login", padding:buttonPadding, color:white, backgroundColor:primaryColor
	//                onClick:
	//                    user = await backend.authWithPassword email, password
	importance:5 async 
	dynamic authWithPassword: string email
		                      string password
		let result = await pocketbase.collection("users").authWithPassword(email, password)
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
	//                    await backend.signupNewUser user
	importance:5 async
	dynamic signupNewUser: dynamic user // A user object with a valid email, password and passwordConfirm member variables
		await users.add(user)
		return await authWithPassword(user.email, user.password)

	// Log out the current user
	// Example:
	//     app
	//         User user
	//         logout
	//             backend.logout
	//             user = null
	importance:5
	void logout
		pocketbase.authStore.clear();
		system.removeLocalStorageItem('pocketbase_auth');

	// Duplicated pending requests are automatically cancelled by default. Use this funtion to enable or disable this.
	// Example:
	//     itemsTable.fetchAll // canceled
	//     itemsTable.fetchAll // canceled
	//     itemsTable.fetchAll // executed
	inline void autoCancellation: value = true
		pocketbase.autoCancellation(value)
		
	inline js void onAuthChanged: inline void(dynamic user) code
		backend.pocketbase.authStore.onChange((token, record) => code(record))
		
	inline js string token
		backend.pocketbase.authStore.token

	async dynamic[] fetchAll: string collectionName, string sort = null
		return await backend.pocketbase.collection(collectionName).getFullList({sort})

	requestVerification: string email
		return pocketbase.collection('users').requestVerification(email);

	confirmVerification: string token
		return pocketbase.collection('users').confirmVerification(token);
		
	const validCharsForId = "abcdefghijklmnopqrstuvwxyz0123456789"
	
	// A PocketBase record id (15 characters from [a-z0-9]) generated on the client
	string newId
		string id
		for 15 id += validCharsForId[randomInteger(validCharsForId.length)]
		return id
		
	// Batch several add, update, remove statements into a transaction in a single request
	// Useful to save requests as well as ensuring several statements always all succeed or all fail
	// The Batch Web API has to be enabled in the PocketBase UI under Settings > Application 
	// By default, max requests in a batch is 50, max processing time is 3 seconds, can be changed in the UI
	// Docs: https://pocketbase.io/docs/api-records/#batch-createupdateupsertdelete-records
	// Example:
	//     await backend.batch
	//         for newDictionaryCards
	//             dueCards.add .
	batch: void() do
		let prevPocketbaseOrBatch = pocketbaseOrBatch
		let currentBatch = pocketbaseOrBatch = pocketbase.createBatch()
		try 
			do()
		finally
			pocketbaseOrBatch = prevPocketbaseOrBatch
		if currentBatch.requests.length then await currentBatch.send()

// Use this class to add, remove, fetch and update items from a remote PocketBase collection. 
// The items are stored locally in the member variable "items". Use the functions "get", "find", "filter" and "length" to access the local items.
// You can also subscribe to changes in the remote PocketBase collection to automatically keep the local items up to date in realtime.
DatabaseTable<T> 
	// The name of the remote PocketBase collection
	importance:5 string name

	// The items you fetch from the backend are stored locally in this list
	importance:5 T[] items = []
	bool busy

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
		if backend.pocketbaseOrBatch == backend.pocketbase
			dynamic newRecord = await backend.pocketbaseOrBatch.collection(this.name).create(item)
			dynamicItem.id = newRecord.id
			dynamicItem.created = newRecord.created
			dynamicItem.updated = newRecord.updated
		else
			if not dynamicItem.id then dynamicItem.id = backend.newId
			backend.pocketbaseOrBatch.collection(this.name).create(item)
		items.ensure item

	// If the item has a valid id member variable, update the item, otherwise add it to the database table
	importance:3
	async T save: T item
		dynamic dynamicItem = item
		if dynamicItem.id
			await backend.pocketbaseOrBatch.collection(this.name).update(dynamicItem.id, dynamicItem)
		else if backend.pocketbaseOrBatch == backend.pocketbase
			let newRecord = await backend.pocketbaseOrBatch.collection(this.name).create(dynamicItem)
			dynamicItem.id = newRecord.id
			dynamicItem.created = newRecord.created
			dynamicItem.updated = newRecord.updated
		else
			dynamicItem.id = backend.newId
			backend.pocketbaseOrBatch.collection(this.name).create(dynamicItem)
	
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
		await backend.pocketbaseOrBatch.collection(this.name).delete(dynamicItem.id)
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
	async T[] fetchAll: string sort = null
		items = cast await backend.pocketbase.collection(this.name).getFullList({sort})
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
	async T[] fetch: string filter = null	// The PocketBase filter string, e.g. "id = 'nx7n98bscxomkl4' && active = true"
		             string sort = null	// The PocketBase sort string, e.g. "-created"
					 string fields = null	// A comma separated list of fields to fetch, e.g. "name,active,created"
		             string expand = null
		             int page = 1
		             int perPage = 1000
					 bool skipTotal = true
		try
			let result = await backend.pocketbase.collection(this.name).getList(page, perPage, {filter, sort, expand, skipTotal, fields})
			items = cast result.items
			totalItemsOfLastFetch = result.totalItems
		catch
			print error.message
			items = []
			totalItemsOfLastFetch = 0
		return items
		
	// Fetch and return a single item from the database table
	importance:5 async js
	T fetchOne: string filter	// The PocketBase filter string, e.g. "id = 'nx7n98bscxomkl4' && active = true"
		        string sort = null	// The PocketBase sort string, e.g. "-created"
		        string fields = null	// A comma separated list of fields to fetch, e.g. "name,active,created"
		        string expand = null
		try {
			return await backend.pocketbase.collection(this.name).getFirstListItem(filter, {fields:fields, sort:sort, expand:expand, skipTotal:true})
		} catch(e) {
			console.log(e)
			return null
		}
		
	// Fetch and return a single item from the database by id
	importance:5 async inline js
	T fetchById: string id // The id of the item to fetch (e.g "nx7n98bscxomkl4")
		backend.pocketbase.collection(this.name).getOne(id)

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
		// Keys with a PocketBase modifier ("count+", "count-", "+tags") don't hold the final value, so don't copy them locally
		forDynamic update
			if not (key.startsWith("+") or key.endsWith("+") or key.endsWith("-")) then dynamicItem[key] = .
		dynamic newRecord = await backend.pocketbaseOrBatch.collection(this.name).update(dynamicItem.id, update)
		// Copy the resolved values of modifier keys from the response (a batched update has no response, the local value stays stale until the next fetch)
		if newRecord
			forDynamic update
				string field
				if key.startsWith("+") then field = key[1..]
				else if key.endsWith("+") or key.endsWith("-") then field = key[..key.length-1]
				if field then dynamicItem[field] = newRecord[field]
		
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
		backend.pocketbaseOrBatch.collection(this.name).update(dynamicItem.id, item)
		
	// Update a single field of an item with a valid id member variable in the database table and the local items
	// Example:
	//     app
	//         DatabaseTable<Item> items = {name:"items"}
	//         drawItem: Item item
	//             div "{item.name}, active:{item.active}"
	//             div "Make item active", onClick:items.updateField item, fieldName:"active", value:true; refresh
	importance:3
	async js void updateField: T item
		                       string key
					           dynamic value
		item[key] = value
		if(!item.id) {
			await this.add(item)
		} else {
			await backend.pocketbaseOrBatch.collection(this.name).@update(item.id, {[key]:value})
		}

	// ------------------------------------------------------- Subscribe -------------------------------------------------------
		
	async js T[] subscribe: string filter = null
		                     string sort = null
					         string fields = null
		                     string expand = null
		                     int perPage = 10000
					         bool skipTotal = true
							 void() onChange = null
		backend.pocketbase.collection(this.name).subscribe("*", e => {
			console.log("subscribe", e.action, e.record);
			if(e.action == "create") {
				this.items.push(e.record);
			} else if(e.action == "update") {
				let item = this.items.find(i => i.id == e.record.id);
				if(item) {
					Object.assign(item, e.record);
				}
			} else if(e.action == "delete") {
				this.items.removeWhere(i => i.id == e.record.id);
			}
			onChange?.();
			backend.onDataChange?.invoke();
		}, {@filter:filter, @fields:fields, @expand:expand})
		let result = await backend.pocketbase.collection(this.name).getList(1, perPage, {filter, sort, expand, skipTotal, fields})
		this.items = result.items
		if(this.items.length > 0) {
			onChange?.();
			backend.onDataChange?.invoke();
		}
		return this.items

	async js T subscribeById: string id
		                      string fields = null
		                      string expand = null
							  void() onChange = null
		                      void() onDelete = null
		backend.pocketbase.collection(this.name).subscribe(id, e => {
			console.log("subscribeById", e.action, e.record);
			if(e.action == "delete") {
				onDelete?.();
			} else {
				// model = e.record;
				Object.assign(model, e.record);
				onChange?.();
			}
			backend.onDataChange?.invoke();
		}, {@fields:fields, @expand:expand})
		var model = await backend.pocketbase.collection(this.name).getOne(id, {@fields:fields, @expand:expand})
		return model;

	importance:3
	inline js async void unsubscribe: string topic = "*"
		backend.pocketbase.collection(this.name).unsubscribe(topic)
		
	// ------------------------------------------------------- Files -------------------------------------------------------
		
	importance:5
	async js void addFiles: Reference<string[]> model
		                    implicit File[] files
						    bool instantlyUpdateLocalFiles = false
						    void(File[] failedFiles) onError = null
		let prevBusy = this.busy;
		this.busy = true;
		backend.onDataChange?.invoke();
		let failedFiles = []
		let addedDateUrls = []
		try {
			if(instantlyUpdateLocalFiles) {
				let localFiles = model.container[model.key]
				for(let file of files) {
					let dataUrl = await this.getDataUrlForFile(file)
					localFiles.push(dataUrl);
					addedDateUrls.push(dataUrl);
				}
				backend.onDataChange?.invoke();
			}

			for(let i=0; i<files.length; i++) {
				let file = files[i]
				try {
					let result = await backend.pocketbase.collection(this.name).update(model.container.id, {[model.key+"+"]:[file]});
					model.container[model.key] = result[model.key];
					if(i < files.length-1) backend.onDataChange?.invoke();
				} catch(e) {
					alert(e.message)
					failedFiles.push(file)
				}
			}
		} finally {
			if(instantlyUpdateLocalFiles && addedDateUrls.length > 0) {
				let localFiles = model.container[model.key]
				for(let dataUrl of addedDateUrls) {
					localFiles.remove(dataUrl);
				}
			}
			this.busy = prevBusy;
			backend.onDataChange?.invoke();
			if(failedFiles.length > 0 && onError != null) {
				onError(failedFiles)
			}
		}

	importance:4
	async js void addFilesFromUrls: Reference<string[]> model
		                            implicit string[] urls
						            void(string[] failedUrls) onError = null
		let prevBusy = this.busy;
		this.busy = true;
		backend.onDataChange?.invoke();
		let failedUrls = []
		try {
			for(let i=0; i<urls.length; i++) {
				try {
					let url = urls[i]
					let response = await fetch(url);
					let imageBlob = await response.blob();
					let result = await backend.pocketbase.collection(this.name).update(model.container.id, {[model.key+"+"]:[imageBlob]});
					model.container[model.key] = result[model.key];
					// if(i < urls.length-1) html.refresh();
				} catch(e) {
					failedUrls.push(file)
				}
			}
		} finally {
			this.busy = prevBusy;
			// html.refresh();
			if(failedUrls.length > 0 && onError != null) {
				onError(failedUrls)
			}
		}

	importance:4
	async js void removeFile: Reference<string[]> model
		                      string file
		let listOfFiles = model.container[model.key];
		listOfFiles.remove(file);
		backend.onDataChange?.invoke();
		await backend.pocketbase.collection(this.name).update(model.container.id, {[model.key+"-"]:[file]});

	static js Promise<string> getDataUrlForFile: File file
		return new Promise((resolve, reject) => {
			const reader = new FileReader();
			reader.onload = e => resolve(e.target.result);
			reader.readAsDataURL(file);	
		})

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
	inline js T[] filter: bool(T a) condition // The condition to check
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
		if length == 0 then return null
		int index = math.randomInteger(length)
		T item = items[index]
		items.removeAt(index)
		return item

global transient priority unit system
	// Do something a given number of times or for each item in a list
	global inline js void for: DatabaseTable<T> subject    // The list to iterate over
		                       -> inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _i=0, _subject=subject.items, _len=_subject.length; _i<_len; ++_i) do(_subject[_i], _i)
		
	// Do something a given number of times or for each item in a list
	global inline js void for: DatabaseTable<T> subject    // The list to iterate over
		                       <- inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _subject=subject.items, _i=_subject.length-1; _i>=0; --_i) do(_subject[_i], _i)
