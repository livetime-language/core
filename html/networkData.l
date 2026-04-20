http
	// Fetch JSON data from a url with a http GET request. Returns a promise to the parsed JSON response.
	// Example:
	//     dynamic config = await http.get "/api/config.json"
	importance:5 js async
	dynamic get: string url
		return (await fetch(url)).json()
		
	// Fetch a string from a url with a http GET request. Returns a promise to the text response.
	//     string configString = await http.getText "/api/config.txt"
	importance:5 js async
	string getText: string url
		return (await fetch(url)).text()
		
	// Fetch an ArrayBuffer from a url with a http GET request. Returns a promise to the array buffer response.
	importance:2 js async
	dynamic getArrayBuffer: string url
		return (await fetch(url)).arrayBuffer()
		
	// Fetch JSON data from a file url with a http GET request. Returns a promise to the parsed JSON response.
	importance:2 js async
	dynamic getFile: string url
		return (await fetch("file://"+url)).json()
		
	// Fetch JSON data from a url with a http POST request. Returns a promise to the parsed JSON response.
	// Example:
	//     User user = {name:"John", age:30}
	//     dynamic result = await http.post "/api/saveUser", user
	importance:5 js async
	dynamic post: string url
		          dynamic body = null // The body object that will be send as a JSON string
		return (await fetch(url, {method:"POST", body:JSON.stringify(body)})).json()
		
	// Fetch JSON data from a url with a http PUT request. Returns a promise to the parsed JSON response.
	// Example:
	//     User user = {name:"John", age:30}
	//     dynamic result = await http.put "/api/saveUser", user
	importance:4 js async
	dynamic put: string url
		         dynamic body = null  // The body object that will be send as a JSON string
		return (await fetch(url, {method:"PUT", body:JSON.stringify(body)})).json()
		
	// Fetch JSON data from a url with a http DELETE request. Returns a promise to the parsed JSON response.
	// Example:
	//     dynamic result = await http.delete "/api/deleteUser/{user.id}"
	importance:4 js async
	dynamic delete: string url
		return (await fetch(url, {method:"DELETE"})).json()
