class IndexedDBIndex
	string name
	string[] keyPaths
	
	IndexedDBIndex
		if not keyPaths then keyPaths.add name
		
class IndexedDBStore<T>
	string name
	IndexedDBIndex[] indices
	
	string keyPath = "id"
	bool autoIncrement = false
	
	IndexedDBStore
		if IndexedDB.stores == null then IndexedDB.stores = []
		IndexedDB.stores.add this
		
	js async void put: T item
		return new Promise((resolve, reject) => {
			try {
				let trans = IndexedDB.db.transaction(this.name, "readwrite")
				trans.onerror = e => {
					system.print("Error in IndexedDBStore.put: "+trans.error)
					reject(trans.error)
				}
				trans.objectStore(this.name).put(item).onsuccess = e => {
					resolve()
				}
			} catch(error) {
				reject(error)
			}
		})
		
	js async T get: dynamic id
		return new Promise((resolve, reject) => {
			try {
				let trans = IndexedDB.db.transaction(this.name, "readonly");
				let req = trans.objectStore(this.name).get(id);
				req.onsuccess = async e => resolve(req.result)
				req.onerror = e => { 
					system.print("Error in IndexedDBStore.get: "+e)
					reject(e)
				}
			} catch(e) {
				system.print("Error in IndexedDBStore.get: "+e)
				reject(e)
			}
		})

	js async T[] getAll
		return new Promise((resolve, reject) => {
			try {
				let trans = IndexedDB.db.transaction(this.name, "readonly");
				let req = trans.objectStore(this.name).getAll();
				req.onsuccess = e => resolve(req.result)
				req.onerror = e => { 
					system.print("Error in IndexedDBStore.getAll: "+e)
					reject(e)
				}
			} catch(e) {
				system.print("Error in IndexedDBStore.getAll: "+e)
				reject(e)
			}
		})
	
	js async T[] getAllFromIndex: string index, dynamic query
		return new Promise((resolve, reject) => {
			try {
				let trans = IndexedDB.db.transaction(this.name, "readonly");
				let req = trans.objectStore(this.name).index(index).getAll(query);
				req.onsuccess = async e => resolve(req.result)
				req.onerror = e => { 
					system.print("Error in IndexedDBStore.getAllFromIndex: "+e)
					reject(e)
				}
			} catch(e) {
				system.print("Error in IndexedDBStore.getAllFromIndex: "+e)
				reject(e)
			}
		})

	js async T[] openCursor
		return  new Promise((resolve, reject) => {
			try {
				let trans = IndexedDB.db.transaction(this.name, "readonly");
				let req = trans.objectStore(this.name);
				req.openCursor().onsuccess = e => {
					var cursor = e.target.result;
					resolve(new IndexedDBCursor(cursor, cursor.value))
				}
			} catch(e) {
				system.print("Error in IndexedDBStore.openCursor: "+e)
				reject(e)
			}
		})

	js async T getAtPosition: int position
		return new Promise((resolve, reject) => {
			try {
				let trans = IndexedDB.db.transaction(this.name, "readonly");
				let req = trans.objectStore(this.name);
				let hasAdvancedToPosition = false;
				req.openCursor().onsuccess = e => {
					var cursor = e.target.result;
					if(position > 0 && !hasAdvancedToPosition) {
						hasAdvancedToPosition = true;
						cursor.advance(position);
						return;
					}
					if(cursor) {
						resolve(cursor.value);
					} else {
						resolve(null);
					}
				}
			} catch(e) {
				system.print("Error in IndexedDBStore.getAtPosition: "+e)
				reject(e)
			}
		})

	js async void clear
		return new Promise((resolve, reject) => {
			try {
				let trans = IndexedDB.db.transaction(this.name, "readwrite")
				trans.onerror = e => {
					system.print("Error in IndexedDBStore.clear: "+trans.error)
					reject(trans.error)
				}
				trans.objectStore(this.name).clear().onsuccess = e => {
					resolve()
				}
			} catch(error) {
				reject(error)
			}
		})

	js async void delete: T item
		if(!item) return
		return new Promise((resolve, reject) => {
			try {
				let id = item[this.keyPath]
				let trans = IndexedDB.db.transaction(this.name, "readwrite");
				let req = trans.objectStore(this.name).delete(id);
				req.onsuccess = e => resolve()
				req.onerror = e => { 
					system.print("Error in IndexedDBStore.delete: "+e)
					reject(e)
				}
			} catch(e) {
				system.print("Error in IndexedDBStore.delete: "+e)
				reject(e)
			}
		})

class IndexedDBCursor<T>
	dynamic cursor
	T initalValue = null

	js async T[] getRange: int count
		return new Promise((resolve, reject) => {
			try {
				this.cursor.onsuccess = e => {
					var cursor = e.target.result;
					let result = []
					if(this.initalValue != null) {
						result.push(this.initalValue);
						this.initalValue = null;
					}
					if(cursor) {
						result.push(cursor.value);
						if(result.length < count) {
							cursor.continue();
						} else {
							resolve(result);
						}
					} else {
						resolve(result);
					}
				}
				this.cursor.continue()
			} catch(e) {
				system.print("Error in IndexedDBCursor.getRange: "+e)
				reject(e)
			}
		})


internal transient skipInit unit IndexedDB
	internal dynamic db
	IndexedDBStore[] stores
	
	inline bool isReady => (IndexedDB.db != null)
	
	js async void start: string databaseName, int version = 1
		return new Promise((resolve, reject) => {
			try {
				var request = indexedDB.open(databaseName, version)
				request.onupgradeneeded = e => {
					system.print("IndexedDB: upgrade needed");
					IndexedDB.db = e.target.result;
					for(let store of IndexedDB.stores) {
						if(!IndexedDB.db.objectStoreNames.includes(store.name)) {
							let storeObject = IndexedDB.db.createObjectStore(store.name, { keyPath: store.keyPath, autoIncrement: store.autoIncrement });
							system.print("IndexedDB: created store "+store.name)
							for(let index of store.indices) {
								storeObject.createIndex(index.name, index.keyPaths.length == 1 ? index.keyPaths[0] : index.keyPaths)
							}
						}
					}
					system.print("IndexedDB: successfully upgraded to version "+version)
				}
				request.onsuccess = e => {
					system.print("IndexedDB: success");
					IndexedDB.db = e.target.result;
					for(let store of IndexedDB.stores) {
						store.db = IndexedDB.db
					}
					resolve();
				}
				request.onerror = e => {
					system.print("Error in IndexedDB.start: "+request.error)
					reject(request.error);
				}
			} catch(e) {
				system.print("Error in IndexedDB.start: "+e)
				reject(e);
			}
		})
