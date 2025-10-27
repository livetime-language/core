http
	// Perform an http get request
	js async dynamic get: string url
		return (await fetch(url)).json()
		
	js async dynamic getText: string url
		return (await fetch(url)).text()
		
	js async dynamic getArrayBuffer: string url
		return (await fetch(url)).arrayBuffer()
		
	js void get: string url
		         void(dynamic result) do = null
		let result = await (await fetch(url)).json()
		do(result)
		
	js void getFile: string url
		             void(dynamic result) do = null
		let result = await (await fetch("file://"+url)).json()
		do(result)
		
	js void getText: string url
		             void(string result) do = null
		let result = await (await fetch(url)).text()
		do(result)
		
	// Perform an http post request
	js void post: string url
		          dynamic body = null
		          void(dynamic result) do = null
		let result = await (await fetch(url, {method:"POST", body:JSON.stringify(body)})).json()
		do(result)
		
	// Perform an http post request
	js void put: string url
		         dynamic body = null
		         void(dynamic result) do = null
		let result = await (await fetch(url, {method:"PUT", body:JSON.stringify(body)})).json()
		do(result)
		
	// Perform an http delete request
	js void delete: string url
		            void(dynamic result) do = null
		let result = await (await fetch(url, {method:"DELETE"})).json()
		do(result)
