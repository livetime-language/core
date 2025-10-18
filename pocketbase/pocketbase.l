transient skipInit pocketBase
	string url, libUrl
	dynamic pb
	
	async void connect: string url
		pocketBase.url = pocketBase.libUrl = url + "/"
		await connect
		
	async js void connect
		if(!pocketBase.url) pocketBase.url = window.location && window.location.host && !Platform.isDebug ? location.origin : "http://localhost:8090"
		const PocketBase = (await import((pocketBase.libUrl || _basePath || location.href.getUntilLast("/")+"/")+"lib/pocketbase.es.js")).default
		if(pocketBase.pb) pocketBase.pb.realtime.unsubscribe();
		pocketBase.pb = new PocketBase(pocketBase.url);
		
	inline js void autoCancellation: value = true
		pocketBase.pb.@autoCancellation(value);
		
	inline js void onAuthChanged: inline void(any user) code
		pocketBase.pb.authStore.onChange((token, record) => code(record))
		
	js void authRefresh: void() ifNotLoggedIn
		try {
			await pocketBase.pb.collection("users").authRefresh();
		} catch(e) {
			console.log(e);
			pocketBase.logout();
			ifNotLoggedIn();
		}

	inline js string token() pocketBase.pb.authStore.token
		
	inline js dynamic get: string collectionName
		await pocketBase.pb.collection(collectionName).getFirstListItem("")
		
	// (await pocketBase.pb.collection(collectionName).getList(1,1)).items[0]
	
	async dynamic authWithPassword: string email
		                            string password
		return await pocketBase.pb.collection("users").authWithPassword(email, password)

	js void logout
		pocketBase.pb.authStore.clear();
		localStorage.removeItem('pocketbase_auth');

// Use this class to add, get, update and delete items from a remote PocketBase database table. 
// The items you fetch from the remote database table are stored locally in the member variable "items". 
// You can also subscribe to changes in the database table to automatically keep the local items up to date in realtime.
DatabaseTable<T> 
	importance:5 string name

	// The items you fetch from the database are stored locally in this list
	importance:5 T[] items = []

	// The total number of items in the database
	importance:4 int totalItems
	
	importance:5 
	async inline js void subscribe: string topic = "*"
		                            string filter = null
					                string fields = null
		                            string expand = null
		pocketBase.pb.collection(this.name).subscribe(topic, e => {
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
		
	// Fetch all items from the datebase table and store them in the member variable "items"
	importance:5 
	async T[] fetchAll
		items = cast await pocketBase.pb.collection(this.name).getFullList()
		return items
		
	// Fetch a subset of items from the datebase table and store them in the member variable "items"
	importance:5 
	async T[] fetch: string filter = null
		             string sort = null
					 string fields = null
		             string expand = null
		             int page = 1
		             int perPage = 1000
					 bool skipTotal = true
		let result = await pocketBase.pb.collection(this.name).getList(page, perPage, {filter, sort, expand, skipTotal, fields})
		items = cast result.items
		totalItems = result.totalItems
		return items
		
	// Fetch and return a single item from the database table
	importance:3
	async T fetchOne: string filter = ""
		              string sort = null
		              string expand = null
		// return await pocketBase.pb.collection(this.name).getFirstListItem(filter, {sort, expand})
		let result = await pocketBase.pb.collection(this.name).getList(1, 1, {filter, sort, expand, skipTotal:true})
		return result.items[0]
		
	// Fetch and return a single item from the database by id
	importance:3
	async inline js async T get: string id
		pocketBase.pb.collection(this.name).getOne(id)
		
	// Add an item to the database table and set its id member variable
	importance:5
	async string add: any item // An item with a id member variable of type string that is not set yet
		any newRecord = await pocketBase.pb.collection(this.name).create(item)
		item.id = newRecord.id
		return newRecord.id
		
	// Updates a complete item with a valid id member variable
	importance:5
	async inline js T update: T item // An item with a valid id member variable of type string
		pocketBase.pb.collection(this.name).update(item.id, item)
		
	// Updates an item partially
	importance:5
	async inline js T update: string id
		                      dynamic update
		pocketBase.pb.collection(this.name).@update(id, update)
		
	// If the item has a valid id member variable, update the item, otherwise add it to the database table
	importance:3
	async js T save: T item
		if(!item.id) return this.add(item)
		else         return pocketBase.pb.collection(this.name).update(item.id, item)
	
	// Remove an item from the database table
	importance:5
	async inline js void remove: T item // An item with a valid id member variable of type string
		pocketBase.pb.collection(this.name).delete(item.id)
		
	// Upload one or more files to the database table
	importance:3
	async js void upload: T item, string fileFieldName = "images", File[] files
		const formData = new FormData();
		for(let file of files) {
			formData.append(fileFieldName, file);
		}
		let newItem
		if(item.id) {
			newItem = await pocketBase.pb.collection(this.name).update(item.id, formData)
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
			newItem = await pocketBase.pb.collection(this.name).create(formData);
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
			newItem = await pocketBase.pb.collection(this.name).update(item.id, formData)
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
			newItem = await pocketBase.pb.collection(this.name).create(formData);
			item.id = newItem.id;
		}
		item[fileFieldName] = newItem[fileFieldName]
		return newItem;

	// ------------------------------------------------------- List -------------------------------------------------------
	
	// Gets the number of items stored locally
	importance:3
	inline js int length() this.items.length
	
	// Find an item the meets the given condition from the items stored locally
	importance:3 
	inline js T find: bool(T a) condition // The condition to check
		this.items.find(condition)
		
	// Find all items that meet the given condition from the items stored locally
	importance:3 
	inline js T[] where: bool(T a) condition // The condition to check
		this.items.filter(condition)
	
	// Shuffle the items stored locally
	importance:2 
	inline shuffle() this.items.shuffle
	
	// Get a new list that is a subset of the items stored locally
	importance:2 
	inline js T[] get: int from = 0 // Return a new list starting from this index, a negative index will start from the end of the list
		               int to       // Return a new list up to (but not including) this index, a negative index is counted from the end
		this.items.slice(from, to)
	
	// Get a new list that is a subset of the items stored locally
	importance:2 
	inline js T[] get: int from // Return a new list starting from this index, a negative index will start from the end of the list
		this.items.slice(from)
		
	// Remove a random item from the items stored locally and return it
	importance:2 
	T popRandom()
		if length == 0: return null
		int index = math.randomInteger(length)
		T item = items[index]
		items.removeAt(index)
		return item
