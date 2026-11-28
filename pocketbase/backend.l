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
	string url
	dynamic pocketbase, pocketbaseOrBatch
	DatabaseTable<User> users
	void() onDataChange = null
	dynamic headlessData	// Records the headless stub serves per collection, seeded by tests: backend.headlessData["cards"] = [...]
	dynamic headlessFilters	// The filter of the last fetch per collection in headless mode (the stub ignores it, a test checks it): backend.headlessFilters["cards"]
	// The error while the server can't be reached, "" while it can: a request got no answer (no network, the server is down) or a proxy
	// couldn't reach the server (502-504), the realtime connection broke or the device went offline. It is set when the server still can't
	// be reached 2 seconds later, so brief interruptions (the server closes idle realtime connections) show nothing. Then the server is asked
	// every 2 seconds until it answers and the realtime connection is back (waitUntilConnected). onConnectionChange is called when it changes
	// Example:
	//     app
	//         start
	//             backend.onConnectionChange = refresh
	//         draw
	//             if backend.connectionError then div backend.connectionError, color:white, backgroundColor:red
	string connectionError
	void() onConnectionChange = null
	private string lastConnectionError	// The error of the last failed request or broken connection, connectionError once it lasts
	private dynamic connected	// Resolved while the connection works (waitUntilConnected)
	private dynamic resolveConnected	// Resolves connected, null while the connection works
	private bool watchesNetwork	// The offline event of the window is handled
	// The realtime subscriptions of DatabaseTable.subscribe and subscribeById, null without any (subscribeTable)
	private dynamic[] subscriptions

	async js void connect: string url = ""
		if(system.isHeadless) {
			// In headless mode (node.js), we can't load the PocketBase library, so we use a stub
			// that resolves all requests with empty results
			backend.pocketbase = backend.pocketbaseOrBatch = backend.createHeadlessStub()
			this.users = new DatabaseTable("users", [])
			return
		}
		
		// Load PocketBase ES module dynamically using import or fetch
		// if(url)	backend.url = backend.libUrl = url + "/"
		// else	backend.url = window.location && window.location.host && !system.isDebug ? location.origin : "http://localhost:8090"
		// const pbUrl = (backend.libUrl || _basePath || location.origin+"/")+"lib/pocketbase.es.js"
		// let PocketBase
		// try {
		// 	PocketBase = (await import(pbUrl)).default
		// } catch(importError) {
		// 	// The page's CSP can block dynamic import (e.g. the bookmarklet running on youtube.com, where script-src
		// 	// only allows Google domains but 'unsafe-eval' is allowed): fetch the module, turn its export statement
		// 	// into a global assignment and eval it as a classic script
		// 	let code = await (await fetch(pbUrl)).text()
		// 	const start = code.lastIndexOf("export{"), end = code.indexOf("}", start)
		// 	if(start == -1) throw importError
		// 	const names = code.slice(start+7, end).split(",").map(n => {
		// 		const p = n.trim().split(" as ")
		// 		return (p[1] || p[0])+":"+p[0]
		// 	})
		// 	code = code.slice(0, start)+";window.__pocketbaseModule={"+names.join(",")+"}"+code.slice(end+1)
		// 	// Pages that enforce require-trusted-types-for 'script' (youtube.com) only eval TrustedScript
		// 	if(window.trustedTypes) try { code = trustedTypes.createPolicy("pocketbase-loader", {createScript: s => s}).createScript(code) } catch(e) {}
		// 	(0,eval)(code)
		// 	PocketBase = window.__pocketbaseModule.default
		// }
		
		// Use the PocketBase client embedded in the main.js bundle
		if(url)	backend.url = url + "/"
		else	backend.url = window.location && window.location.host && !system.isDebug ? location.origin : "http://localhost:8090"
		if(backend.pocketbase) backend.pocketbase.realtime.unsubscribe();
		backend.pocketbase = backend.pocketbaseOrBatch = new PocketBase(backend.url);
		backend.subscriptions = null
		this.users = new DatabaseTable("users", []);
		// All requests (also of collections, batches and the realtime client) go through send
		const send = backend.pocketbase.send.bind(backend.pocketbase)
		backend.pocketbase.send = async (path, options) => {
			try {
				return await send(path, options)
			} catch(e) {
				backend.reportIfConnectionError(e)
				throw e
			}
		}
		// The realtime client reconnects by itself. Its topics are empty when it was disconnected on purpose
		backend.pocketbase.realtime.onDisconnect = topics => { if(topics.length) backend.reportConnectionError("The realtime connection was interrupted") }
		if(!backend.watchesNetwork) {
			backend.watchesNetwork = true
			window.addEventListener("offline", () => backend.reportConnectionError("The network connection was lost"))
		}

	// Whether the error of a request means that the server can't be reached: the request got no answer (no network, the server is down)
	// or a proxy in front of the server couldn't reach it
	js bool isConnectionError: dynamic error
		return error?.status === 0 && !error.isAbort || error?.status >= 502 && error?.status <= 504

	// Returns once the server answers and the realtime connection is there (if there are subscriptions), at once unless a request failed for
	// lack of a connection or the realtime connection broke
	// Example: sign in again until the server can be reached
	//     while not user
	//         try
	//             user = await backend.authWithPassword email, password
	//         catch
	//             if not backend.isConnectionError(error) then throw error
	//             await backend.waitUntilConnected
	async js void waitUntilConnected
		await backend.connected

	// Reports the error of a request if the server couldn't be reached (connectionError) and returns whether it did
	private js bool reportIfConnectionError: dynamic error
		if(!backend.isConnectionError(error)) return false
		backend.reportConnectionError(error.status ? error.status + " " + (error.response?.message || {502:"Bad Gateway", 503:"Service Unavailable", 504:"Gateway Timeout"}[error.status]) : error.originalError?.message || error.message)
		return true

	private js void reportConnectionError: string detail
		backend.lastConnectionError = "Can't reach " + new URL(backend.url).host + ": " + detail + (navigator.onLine === false ? " (the device is offline)" : "")
		if(backend.resolveConnected) return
		backend.connected = new Promise(resolve => backend.resolveConnected = resolve)
		setTimeout(() => backend.checkConnection(), 2000)

	// The realtime client reconnects by itself, but not when its first connection failed: connect starts it then (and does nothing while it
	// reconnects)
	private async js void checkConnection
		const realtime = backend.pocketbase.realtime
		try {
			await backend.pocketbase.send("/api/health", {requestKey:null})
			if(realtime.hasSubscriptionListeners() && !realtime.isConnected) await realtime.connect()
			if(!realtime.hasSubscriptionListeners() || realtime.isConnected) {
				backend.resolveConnected()
				backend.resolveConnected = null
				backend.setConnectionError("")
				return
			}
		} catch(e) {}
		backend.setConnectionError(backend.lastConnectionError)
		setTimeout(() => backend.checkConnection(), 2000)

	private js void setConnectionError: string error
		if((backend.connectionError || "") == error) return	// The fields of backend have no defaults (skipInit)
		backend.connectionError = error
		backend.onConnectionChange?.invoke()

	// Subscribes to the realtime events of the topic of the collection and fetches the items with load, then again after each reconnect: the
	// server forgets the client while its realtime connection is interrupted, so the events of meanwhile are lost. This also happens when the
	// server closes the connection (after 5 minutes without events and after 30 minutes). The events (apply) that arrive while the items are
	// fetched follow them (merge), so a fetch neither overwrites nor misses them. While the server can't be reached, the fetch waits for it
	private js async void subscribeTable: dynamic table
		                                   string topic
		                                   dynamic options
		                                   dynamic load
		                                   dynamic merge
		                                   dynamic apply
		const subscription = {table, topic: table.name + "/" + topic, load, merge, apply, fetches: 0, pendingEvents: []}
		try {
			// Resolves once the server sends the events, so the first fetch misses none
			subscription.unsubscribe = await backend.pocketbase.collection(table.name).subscribe(topic, e => subscription.pendingEvents ? subscription.pendingEvents.push(e) : apply(e), options)
		} catch(e) {
			if(!backend.reportIfConnectionError(e)) throw e
		}
		await backend.connected
		if(!backend.subscriptions) {
			backend.subscriptions = []
			// Added while the realtime connection is there, so only reconnects call it
			backend.pocketbase.realtime.subscribe("PB_CONNECT", () => {
				for(const subscription of backend.subscriptions ?? []) backend.fetchSubscription(subscription).catch(e => console.error(e))
			}).catch(e => backend.reportIfConnectionError(e) || console.error(e))
		}
		// Subscribing the table to the topic again replaces the subscription
		const previous = backend.subscriptions.find(s => s.table == table && s.topic == subscription.topic)
		if(previous) previous.unsubscribe?.()
		backend.subscriptions = backend.subscriptions.filter(s => s != previous).concat(subscription)
		await backend.fetchSubscription(subscription)

	// The fetch that started last applies its items and then the events that arrived since the first unfinished one started. A fetch that
	// failed for lack of a connection is tried again when the server answers, unless the items were fetched again meanwhile (after a reconnect)
	private js async void fetchSubscription: dynamic subscription
		for(;;) {
			const fetch = ++subscription.fetches
			subscription.pendingEvents ??= []
			try {
				const result = await subscription.load()
				if(fetch == subscription.fetches) subscription.merge(result)
				return
			} catch(e) {
				if(!backend.isConnectionError(e)) throw e
			} finally {
				if(fetch == subscription.fetches) {
					const events = subscription.pendingEvents
					subscription.pendingEvents = null
					for(const e of events) subscription.apply(e)
				}
			}
			await backend.connected
			if(fetch != subscription.fetches || !backend.subscriptions?.includes(subscription)) return
		}

	// Like the realtime client, unsubscribing removes the subscriptions of the topic of all tables. The last one ends the realtime connection
	private js async void unsubscribeTable: string collectionName
		                                     string topic
		backend.subscriptions = backend.subscriptions?.filter(s => s.topic != collectionName + "/" + topic)
		await backend.pocketbase.collection(collectionName).unsubscribe(topic)
		if(backend.subscriptions?.length === 0) {
			backend.subscriptions = null
			await backend.pocketbase.realtime.unsubscribe("PB_CONNECT")
		}

	// Creates a stub of the PocketBase client for headless mode (node.js). Fetches serve the records a test
	// seeded via backend.headlessData["cards"] = [...] (unfiltered and unsorted - filter, sort and fields are
	// ignored), an unseeded collection returns empty results, getOne finds the seeded record by id. create assigns
	// a real id like the server would. update resolves with null like a batched update, so DatabaseTable.update keeps
	// the locally computed values instead of overwriting modifier fields ("count+") with values from a fake response.
	// Every call goes through backend.pocketbase.send like in the real client (the stub's send resolves null), so a test
	// can record or reject requests by path: backend.pocketbase.send = async (path, options) => ...
	private js dynamic createHeadlessStub
		backend.headlessData = {}
		backend.headlessFilters = {}
		const none = async () => null
		const seeded = name => backend.headlessData[name] || []
		const records = name => "/api/collections/"+name+"/records"
		// then instead of await: the compiler would make this function async, and connect expects the stub itself
		const request = (method, path, result) => backend.pocketbase.send(path, {method}).then(() => result)
		const collection = name => ({
			getList: (page, perPage, options) => (backend.headlessFilters[name] = options && options.filter, request("GET", records(name), {items:[...seeded(name)], totalItems:seeded(name).length})),
			getFullList: options => (backend.headlessFilters[name] = options && options.filter, request("GET", records(name), [...seeded(name)])),
			// Like the server: an empty result is a 404 (DatabaseTable.fetchOne turns it into null)
			getFirstListItem: filter => (backend.headlessFilters[name] = filter, request("GET", records(name), seeded(name)[0])).then(item => {
				if(!item) throw Object.assign(new Error("The requested resource wasn't found."), {status:404})
				return item
			}),
			getOne: id => request("GET", records(name)+"/"+id, seeded(name).find(r => r.id == id) || null),
			create: item => request("POST", records(name), {...item, id:item?.id || backend.newId(), created:"", updated:""}),
			update: id => request("PATCH", records(name)+"/"+id, null),
			delete: id => request("DELETE", records(name)+"/"+id, null),
			subscribe: none,
			unsubscribe: none,
			authRefresh: () => request("POST", "/api/collections/"+name+"/auth-refresh", null),
			authWithPassword: none,
			requestVerification: none,
			confirmVerification: none,
		})
		return {
			collection,
			createBatch: () => ({collection, requests: [], send: none}),
			send: none,
			autoCancellation: () => {},
			realtime: {subscribe: none, unsubscribe: () => {}},
			// A signed in session; clear signs out like the real store
			authStore: {token:"headless", record:null, isValid:true, clear() { this.token = ""; this.record = null }, onChange: () => {}},
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
		backend.pocketbase.send(url, {method:"POST", @body:body, requestKey:null})
		
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

	// A request the server rejected (4xx): a retry with the same token and body fails the same way, unlike a network error or a 5xx
	js bool isRejected: dynamic error
		return error?.status >= 400 && error?.status < 500

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

	// Duplicated pending reads are automatically cancelled by default. Use this function to enable or disable this.
	// Writes are never cancelled (requestKey:null): the server saves a cancelled write anyway, the client would only lose
	// its answer, e.g. the first of two records added in quick succession would throw although it was saved
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

	// A PocketBase record id (15 characters from [a-z0-9]) that is always the same for the same key. The database has at most one
	// record with it: the server rejects a second one, whichever client adds it and whatever that client has loaded. Use it with
	// DatabaseTable.addOnce for records that must exist only once, e.g. one per user and day. Everybody who adds the record must
	// be able to read it
	// Example:
	//     Entry entry = await entries.addOnce {id:await backend.idOf("{user.id} {day}"), user:user.id, day}
	js async string idOf: string key
		const hash = new Uint8Array(await crypto.subtle.digest("SHA-256", new TextEncoder().encode(key)))
		return Array.from(hash.subarray(0, 15), byte => (byte % 36).toString(36)).join("")

	// Batch several add, update, remove statements into a transaction in a single request
	// Useful to save requests as well as ensuring several statements always all succeed or all fail
	// Important: You need to await all add/update/remove calls (just like outside a batch) to ensure their errors are caught
	// The closure's awaits suspend while the batch is collecting, so code that runs in between (e.g. the rest of the
	// caller's tick) must not start unrelated saves: they would be silently queued into this batch
	// The Batch Web API has to be enabled in the PocketBase UI under Settings > Application 
	// By default, max requests in a batch is 50, max processing time is 3 seconds, can be changed in the UI
	// Docs: https://pocketbase.io/docs/api-records/#batch-createupdateupsertdelete-records
	// Example:
	//     await backend.batch
	//         await dueCards.add card
	//         await app.users.update app.user, {"trainingCount+": 1}
	js async void batch: void() do
		let prevPocketbaseOrBatch = backend.pocketbaseOrBatch;
		let currentBatch = backend.pocketbaseOrBatch = backend.pocketbase.createBatch();
		try {
			await do();
		} finally {
			backend.pocketbaseOrBatch = prevPocketbaseOrBatch;
		}
		if(currentBatch.requests.length) await currentBatch.send({requestKey:null});

// Use this class to add, remove, fetch and update items from a remote PocketBase collection. 
// The items are stored locally in the member variable "items". Use the functions "get", "find", "filter" and "length" to access the local items.
// You can also subscribe to changes in the remote PocketBase collection to automatically keep the local items up to date in realtime.
DatabaseTable<T> 
	// The name of the remote PocketBase collection
	importance:5 string name

	// The items you fetch from the backend are stored locally in this list
	importance:5 T[] items = []
	bool busy

	// The updates of each item that are sent or waiting to be sent, by id. They are sent one after another: the record of a
	// realtime event is the one the server loaded before the other updates of the same time were saved, so updates sent at
	// once would each bring back the old values of the other's fields. Realtime events keep the local values of these fields
	private dynamic unfinishedUpdatesById = {}

	// Sends an update of an item after the earlier updates of this item are done (at once in a batch, which must get it
	// before it is sent) and returns the record of the server (null in a batch)
	private js async dynamic sendAfterEarlierUpdates: string id
		                                             dynamic update
		const collection = backend.pocketbaseOrBatch.collection(this.name);
		if (backend.pocketbaseOrBatch != backend.pocketbase) return collection.update(id, update);
		const unfinishedUpdates = this.unfinishedUpdatesById[id] ??= [];
		const previousRequest = unfinishedUpdates.at(-1)?.request;
		const thisUpdate = {update, request: (async () => { try { await previousRequest; } catch (e) {} return collection.update(id, update, {requestKey:null}); })()};
		unfinishedUpdates.push(thisUpdate);
		try {
			return await thisUpdate.request;
		} finally {
			unfinishedUpdates.splice(unfinishedUpdates.indexOf(thisUpdate), 1);
			if (!unfinishedUpdates.length) delete this.unfinishedUpdatesById[id];
		}

	// Copies the record of a realtime event onto the local item, except the fields that unfinished updates of this client change
	private js void assignEventRecord: dynamic item
		                               dynamic record
		const unfinishedUpdates = this.unfinishedUpdatesById[record.id];
		if (unfinishedUpdates) {
			record = {...record};
			for (const {update} of unfinishedUpdates) for (const key in update) delete record[key.replace(/^\+|[+-]$/, "")];
		}
		Object.assign(item, record);

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
			// The item gets the values the server set (id, created, updated and those of hooks), like with the realtime event of the creation (subscribe)
			dynamic newRecord = await backend.pocketbaseOrBatch.collection(this.name).create(item, {requestKey:null})
			forDynamic newRecord
				dynamicItem[key] = .
		else
			if not dynamicItem.id then dynamicItem.id = backend.newId
			backend.pocketbaseOrBatch.collection(this.name).create(item)
			
		dynamic[] dynamicList = items
		if dynamicList.none.id == dynamicItem.id
			items.add item

	// Adds an item with a given id (backend.idOf) unless the database has an item with this id, and returns the local item with
	// this id. That is the item of the database if it exists already, e.g. because another client added it at the same time: the
	// server decides which client adds it, so it is added only once even if the local items are not up to date. Returns null if
	// the database has the item but the user may not read it. Not in a batch
	importance:3
	async T addOnce: T item // An item whose id member variable is set
		dynamic dynamicItem = item
		dynamic existing
		try
			await add item
		catch
			// The server rejects the id: it is taken. The local items get the item unless a realtime event has brought it
			dynamic rejected = error
			if not rejected.response?.data?.id then throw error
			existing = await fetchOne("id = '{dynamicItem.id}'")
		dynamic[] dynamicList = items
		if existing and dynamicList.none.id == dynamicItem.id then dynamicList.add existing
		return cast dynamicList.find.id == dynamicItem.id

	// If the item has a valid id member variable, update the item, otherwise add it to the database table
	importance:3
	async T save: T item
		dynamic dynamicItem = item
		if dynamicItem.id
			await sendAfterEarlierUpdates dynamicItem.id, dynamicItem
		else if backend.pocketbaseOrBatch == backend.pocketbase
			let newRecord = await backend.pocketbaseOrBatch.collection(this.name).create(dynamicItem, {requestKey:null})
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
		await backend.pocketbaseOrBatch.collection(this.name).delete(dynamicItem.id, {requestKey:null})
		items.remove item
		
	// ------------------------------------------------------- Fetch -------------------------------------------------------

	// The total number of items in the database
	int totalItemsOfLastFetch

	// The last page of fetch, subscribe or fetchMore was full and sorted, so fetchMore may find more items
	bool hasMore

	// Where fetchMore continues: the page size, the options of the last fetch or subscribe and the filter for the items
	// after the last fetched one
	private dynamic nextPage
	
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
		hasMore = false
		return items
		
	// Fetch a subset of items from the database table and store them locally in the member variable "items".
	// Throws when the request fails (the local items stay as they were), so a caller can tell an empty result from a failure
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
		if sort then sort += ",id"	// Equal values in the same order on every page (see fetchMore)
		let result = await backend.pocketbase.collection(this.name).getList(page, perPage, {filter, sort, expand, skipTotal, fields})
		items = cast result.items
		totalItemsOfLastFetch = result.totalItems
		rememberNextPage result.items, perPage, {filter, sort, expand, fields}
		return items

	// Fetch the next page of the last fetch or subscribe (same filter, sort and page size, at most 1000) and add it to the
	// local items. It fetches the items after the last fetched one in the sort order (the ids decide between equal values),
	// so items that are added or removed meanwhile make it neither skip nor repeat one. Paging needs a sort, and the
	// fetched fields must include the sort fields.
	// Example: messages, the newest at the bottom, with older ones fetched when the user scrolls near the top
	//     app
	//         DatabaseTable<Message> messages = {name:"messages"}
	//         start
	//             await messages.fetch sort:"-created", perPage:50
	//             refresh
	//         draw
	//             column height:100%, overflowY:auto
	//                 if messages.hasMore then div onVisible:await messages.fetchMore
	//                 for messages.items.sortBy .created
	//                     div .text
	importance:5
	async void fetchMore
		if not hasMore then return
		dynamic query = nextPage.query
		dynamic[] page = (await backend.pocketbase.collection(this.name).getList(1, nextPage.perPage, {filter:nextPage.filter, sort:query.sort, expand:query.expand, fields:query.fields, skipTotal:true})).items
		dynamic[] dynamicList = items
		for item in page
			if dynamicList.none.id == item.id then dynamicList.add item	// Unless a realtime event added it already
		rememberNextPage page, nextPage.perPage, query

	// The items after the last one of the page in the sort order of the query follow on the next page. For the sort "a,-b,id"
	// and the last item {a:1, b:2, id:"x"}, these are the items with a > 1 || a = 1 && b < 2 || a = 1 && b = 2 && id > "x"
	rememberNextPage: dynamic[] page, int perPage, dynamic query
		hasMore = query.sort and page.length == perPage
		if not hasMore then return
		string sort = query.sort
		string after, equalBefore
		for key in sort.split(",")
			bool isDescending = key.startsWith("-")
			string field = isDescending ? key.substring(1) : key
			string value = backend.pocketbase.filter("\{:value}", {value:page.last[field]})
			after += "{after ? " || " : ""}{equalBefore}{field} {isDescending ? "<" : ">"} {value}"
			equalBefore += "{field} = {value} && "
		nextPage = {perPage:perPage atMost 1000, query, filter:query.filter ? "({query.filter}) && ({after})" : after}
		
	// Fetch and return a single item from the database table. Returns null only when no item matches the filter
	// (PocketBase answers 404) and throws on every other error (network, not signed in, ...): a caller that creates
	// the item when it gets null must catch the error, or a dropped connection creates a duplicate
	importance:5 async js
	T fetchOne: string filter	// The PocketBase filter string, e.g. "id = 'nx7n98bscxomkl4' && active = true"
		        string sort = null	// The PocketBase sort string, e.g. "-created"
		        string fields = null	// A comma separated list of fields to fetch, e.g. "name,active,created"
		        string expand = null
		try {
			return await backend.pocketbase.collection(this.name).getFirstListItem(filter, {fields:fields, sort:sort, expand:expand, skipTotal:true})
		} catch(e) {
			if(e.status == 404) return null
			throw e
		}
		
	// Fetch and return a single item from the database by id
	importance:5 async inline js
	T fetchById: string id // The id of the item to fetch (e.g "nx7n98bscxomkl4")
		backend.pocketbase.collection(this.name).getOne(id)

	// ------------------------------------------------------- Update -------------------------------------------------------

	// Update an item with a valid id member variable in the server database table and the local items
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
		dynamic newRecord = await sendAfterEarlierUpdates(dynamicItem.id, update)
		// Copy the resolved values of modifier keys from the response (a batched update has no response, the local value stays stale until the next fetch)
		if newRecord
			forDynamic update
				string field
				if key.startsWith("+") then field = key[1..]
				else if key.endsWith("+") or key.endsWith("-") then field = key[..key.length-1]
				if field then dynamicItem[field] = newRecord[field]
					
	// Update an item in the server database table (don't update the local items)
	async void updateOnServer: string id
		                       dynamic update	
		await sendAfterEarlierUpdates id, update
		
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
		await sendAfterEarlierUpdates dynamicItem.id, item
		
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
			await this.sendAfterEarlierUpdates(item.id, {[key]:value})
		}

	// ------------------------------------------------------- Subscribe -------------------------------------------------------
		
	// Fetches the items and keeps them up to date with realtime events, also after reconnects. An update event of an item that isn't
	// there adds it: the user may see it now (the list rule) or it matches the filter now
	async js T[] subscribe: string filter = null
		                     string sort = null
					         string fields = null
		                     string expand = null
		                     int perPage = 10000
					         bool skipTotal = true
							 void() onChange = null
							 string() fetchFilter = null	// Narrows the fetches, not the realtime events, read for each fetch: e.g. a filter by indexed fields the list rule implies
		if(sort) sort += ",id" // Equal values in the same order on every page (see fetchMore)
		const collection = backend.pocketbase.collection(this.name), realtimeOptions = {filter, sort, expand, skipTotal, fields}
		const notify = () => { onChange?.(); backend.onDataChange?.invoke() }
		let fetchedBefore = false
		let options = realtimeOptions
		await backend.subscribeTable(this, "*", {@filter:filter, @fields:fields, @expand:expand},
			async () => {
				const narrowing = fetchFilter?.()
				options = narrowing ? {...realtimeOptions, filter: filter ? `(${filter}) && (${narrowing})` : narrowing} : realtimeOptions
				// After a reconnect, as many pages as the items fill (fetchMore adds pages)
				const count = fetchedBefore ? Math.max(perPage, Math.ceil(this.items.length / perPage) * perPage) : perPage, pageSize = Math.min(count, 1000)
				// The server returns at most 1000 items per page. If more are asked for, the following pages are read while they are full
				const records = (await collection.getList(1, pageSize, options)).items
				for(let page = 2, last = records; last.length == pageSize && records.length < count; page++) {
					last = (await collection.getList(page, pageSize, options)).items
					records.push(...last)
				}
				if(records.length > count) records.length = count
				return {records, count}
			},
			({records, count}) => {
				// Items that are still there keep their objects (the app refers to them) and the local values of unfinished updates
				const itemsById = new Map(this.items.map(item => [item.id, item])), hadItems = this.items.length > 0
				this.items = records.map(record => {
					const item = itemsById.get(record.id)
					if(item) this.assignEventRecord(item, record)
					return item || record
				})
				this.rememberNextPage(this.items, count, {filter:options.filter, sort, expand, fields})
				if(this.nextPage) this.nextPage.perPage = Math.min(perPage, 1000)
				fetchedBefore = true
				if(hadItems || this.items.length) notify()
			},
			e => {
				console.log("subscribe", e.action, e.record)
				const item = this.items.find(i => i.id == e.record.id)
				// add already inserted the item if the server answered before this event. It gets the values the server set (hooks)
				if(e.action == "delete") this.items.removeWhere(i => i.id == e.record.id)
				else if(item) this.assignEventRecord(item, e.record)
				else this.items.push(e.record)
				notify()
			})
		return this.items

	// Fetches the items of the filter (all pages) and adds those that aren't there, e.g. those a subscription's fetchFilter left out
	// that the user may see now. The items that are there keep their objects, which realtime events keep up to date
	importance:3
	async js void fetchAndAdd: string filter
		                       string expand = null
		const records = await backend.pocketbase.collection(this.name).getFullList({filter, expand, batch:1000, requestKey:null})
		const ids = new Set(this.items.map(item => item.id))
		for(const record of records) if(!ids.has(record.id)) this.items.push(record)
		backend.onDataChange?.invoke()

	async js T subscribeById: string id
		                      string fields = null
		                      string expand = null
							  void() onChange = null
		                      void() onDelete = null
		const options = {@fields:fields, @expand:expand}
		let model = null
		await backend.subscribeTable(this, id, options,
			// After a reconnect, a deleted item is null
			() => backend.pocketbase.collection(this.name).getOne(id, options).catch(e => { if(model && e?.status == 404) return null; throw e }),
			record => {
				if(!model) return model = record
				if(record) {
					this.assignEventRecord(model, record)
					onChange?.()
				} else {
					onDelete?.()
				}
				backend.onDataChange?.invoke()
			},
			e => {
				console.log("subscribeById", e.action, e.record)
				if(!model) return
				if(e.action == "delete") {
					onDelete?.()
				} else {
					this.assignEventRecord(model, e.record)
					onChange?.()
				}
				backend.onDataChange?.invoke()
			})
		return model

	importance:3
	async js void unsubscribe: string topic = "*"
		await backend.unsubscribeTable(this.name, topic)
		
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
					let result = await backend.pocketbase.collection(this.name).update(model.container.id, {[model.key+"+"]:[file]}, {requestKey:null});
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
					let result = await backend.pocketbase.collection(this.name).update(model.container.id, {[model.key+"+"]:[imageBlob]}, {requestKey:null});
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
		await backend.pocketbase.collection(this.name).update(model.container.id, {[model.key+"-"]:[file]}, {requestKey:null});

	// Adds a file to a file field (e.g. card.images) and returns its name in the database, which is the name with a random suffix
	// Example:
	//     string name = await cards.addFile card.images, bytes, "photo.png"
	importance:4
	async js string addFile: Reference<string[]> model
		                     dynamic data	// Bytes, a Blob or a data url
		                     string name
		if(typeof data == "string") data = await (await fetch(data)).blob()
		const form = new FormData()
		form.append(model.key + "+", data instanceof Blob ? data : new Blob([data]), name)
		const before = model.container[model.key] || []
		const files = (await backend.pocketbase.collection(this.name).update(model.container.id, form, {requestKey:null}))[model.key]
		model.container[model.key] = files
		return files.find(file => !before.includes(file))

	// The url of a file of a record's file field
	importance:4
	js string fileUrl: string id, string name
		return backend.pocketbase.buildURL("/api/files/" + encodeURIComponent(this.name) + "/" + encodeURIComponent(id) + "/" + encodeURIComponent(name))

	baseUrl => "{backend.url}/api/files/{this.name}"

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
