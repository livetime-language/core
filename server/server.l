skipInit unit Platform
	visible bool isDebug
	inline js int version := _buildVersion
		
	inline js void initPlatform
		Platform.init()
		Time.timezoneOffset = new Date().getTimezoneOffset() * 60000
		
	inline js void initApplication
		init()
		
	start: bool isDebug
		initPlatform
		this.isDebug = isDebug
		sendEvaluateFinished
		initApplication
		
	replay
		initApplication
		
	private inline js void sendEvaluateFinished
		if(Platform.isDebug) _sendToEditor({type:"evaluateFinished"})
	
	inline js string basePath := __dirname + "/"
	
	js void setupInterval: Time interval
		                   string name = "interval"
		                   void() code
		if(window[name]) clearInterval(window[name]);
		window[name] = setInterval(code, interval)
		
	inline js string getEnvironmentVariable: string key
		process.env[key]
		
	public inline js string encodeURIComponent(string value) encodeURIComponent(value)
	public inline js string decodeURIComponent(string value) decodeURIComponent(value)
		
global transient unit System
	// Prints a message to the console
	global js void print: logstring text // The text, variables or expressions to print
		                  SourceCodeLocation location
		if(location && Platform.isDebug) {
			var stringValue = typeof text === "string" ? text : JSON.stringify(text);
			if(stringValue) _sendToEditor({type:"log", value:stringValue, location:location.start, file:location.file});
		} else {
			console.log(text)
		}

global skipInit unit math
	// Generates a random integer
	global js int randomInteger: int min // The inclusive lower bound of the random integer
		                         int max // The exclusive upper bound of the random integer
		return min + Math.floor(Math.random() * (max-min))
	
	global js int randomInteger: int max = 2147483647 // The exclusive upper bound of the random integer
		return Math.floor(Math.random() * max)
	
	// Generates a random float
	global inline js int randomFloat
		math.random()
		
	js string generateRandomSeed:
		let crypto = !window.crypto && typeof(require) != "undefined" ? require("crypto") : window.crypto
		if(crypto) {
			let out = new Uint8Array(256);
			crypto.getRandomValues(out);
			return out.toString();
		}

	js string generateUUID
		return 'xxxx-xxxx-xxx-xxxx'.replace(/[x]/g, (c) => {  
			return math.floor(math.random() * 16).toString(16);  
		}); 

skipInit transient float Time
	// The number of milliseconds elapsed since January 1, 1970
	static inline js Time now := Date.now()
	
transient float Angle
	inline js float toFloat() this
	inline js string toString() this.toString()
		
	// Returns true if the angle is not zero
	inline js bool toBool := this
	
	inline Angle + Angle value
	inline Angle - Angle value
	inline float / Angle value
	inline float * Angle value
	
	inline Angle += Angle value
	inline Angle -= Angle value
	inline Angle /= Angle value
	inline Angle *= Angle value
	
	inline bool == Angle value
	inline bool != Angle value
	inline bool < Angle value
	inline bool <= Angle value
	inline bool > Angle value
	inline bool >= Angle value
	
	inline js Angle % ensureSingleExecution Angle value
		((this % value) + value) % value
	
	inline js float in: AngleUnit unit
		(unit==1 ? this*math.TwoPI : unit==2 ? this*360 : unit==3 ? this*400 : this)
		
enum AngleUnit
	turns // Turn (one full rotation is 1)
	rad   // Radians (one full rotation is 2π)
	deg   // Degrees (one full rotation is 360)
	grad  // Gradiants (one full rotation is 400)
	
enum HttpMethod: Get, Post, Put, Delete
			
global unit http
	object handlerMap = null
	object contentTypeMap = null
	private methodName = ["GET", "POST", "PUT", "DELETE"]
	
	init
		initMap
		
	js void initMap
		http.handlerMap = new Map()
		http.contentTypeMap = {
			js:"application/javascript; charset=utf-8",
			html:"text/html; charset=utf-8",
			css:"text/css",
			png:"image/png",
			jpg:"image/jpeg",
			"":"text/plain; charset=utf-8",
		}
	
	js void startHttpsServer: port = 3100, string certPath = "", string keyPath = "", void(string[] path, dynamic body, Request request, Response response) onRequest = null
		const fs = require('fs');
		const startTime = new Date();
		function handleRequest(request, response) {
			var body = "";
			request.on("data", a => body += a)
			request.on("end", async () => {
				try {
					response.setHeader('Access-Control-Allow-Origin', '*');
					response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS, PUT, DELETE");
					var path = request.url.substring(1).split("/");
					await onRequest(path, body ? JSON.parse(body) : null, request, response);

					if(!response.writableEnded) {
						var procedureName = path[0];
						handler = http.handlerMap.get(request.method+procedureName)
						if(handler) {
							// For named handlers, the procedure name isn't included in the path
							path.splice(0,1);
						} else {
							// For wildcard handlers, we pass the procedure name as path[0]
							handler = http.handlerMap.get(request.method+"*")
						}
						
						if(handler) {
							await handler(path, body ? JSON.parse(body) : null, request, response);
						} else {
							response.end("Server v"+_buildVersion+" up since "+startTime);
						}
					}
				} catch(e) {
					console.error(e)
					if(Platform.isDebug) _sendErrorToEditor(e);
					response.end(`{error:"${e.message}"}`)
				}
			})
		}
		if(window.server) server.close();
		if(certPath && keyPath && !Platform.isDebug) {
			window.server = require('https').createServer({
				cert: fs.readFileSync(certPath),
				key: fs.readFileSync(keyPath)
			}, handleRequest)
		} else {
			window.server = require('http').createServer({}, handleRequest)
		}

		server.listen(port)
		
	js void on:string path, HttpMethod method = Get, void(string[] path, dynamic body, Request request, Response response) handler
		http.handlerMap.set(http.methodName[method]+path, handler)
	
class Request
	inline js string ip() this. .connection.remoteAddress
		
class Response
	inline js void sendText(string result, int code = 200, filename = "") this.writeHead(code, {'Content-Type': http.contentTypeMap[filename.getExtension()] || "text/plain; charset=utf-8"}); response.end(result);
	inline js void send(ensureSingleExecution any result, int code = 200) if(result) { if(typeof result == "string") {this.writeHead(code, {"Content-Type": "text/plain; charset=utf-8"}); response.end(result);} else {this.writeHead(code, {"Content-Type": "application/json; charset=utf-8"}); response.end(JSON.stringify(result)); }}
	inline js void redirect(string url, int code = 302) this.writeHead(code, {Location: url}); response.end();
		
unit File
	js void save: string file, string data, void() success
		require('fs').writeFile(file, data, "utf8", () => success())

	js void open: string file, void(string fileContent) then, void(string error) else
		require('fs').readFile(file, (error, fileContent) => {
			if(error) else(error)
			else      then(fileContent)
		})
		
unit websocket
	js void startWebsocketServer: int port
		                          string keypath = ""
		                          void(string[] path, WebsocketHttpResponse response) onGet
		                          void() onStart
		                          void(Connection connection) onOpen
		                          void(Connection connection, int errorCode) onClose
		                          void(Connection connection, Buffer buffer) onMessage
		const uWS = require('uWebSockets.js')
		const app =  process.platform == "win32" || process.platform == "darwin" ? uWS.App() :
			uWS.SSLApp({
				key_file_name: "/etc/letsencrypt/live/"+keypath+"/privkey.pem",
				cert_file_name: "/etc/letsencrypt/live/"+keypath+"/fullchain.pem",
			})
		app.ws('/*'/**/, {
			compression: uWS.SHARED_COMPRESSOR,
			maxPayloadLength: 16 * 1024 * 1024,
			idleTimeout: 0,
			maxBackpressure: 0,
			open: (ws) => {
				onOpen(ws);
			},
			message: (ws, message, isBinary) => {
				onMessage(ws, new Buffer(message, 0, 0, 0))
			},
			drain: (ws) => {
				log('WebSocket backpressure: ' + ws.getBufferedAmount());
			},
			close: (ws, code, message) => {
				onClose(ws, code);
			}
		}).any('/*' /**/, (response, request) => {
			let path = request.getUrl().split("/");
			path.splice(0,1);
			onGet(path, response);
		}).listen(port, (token) => {
			if (token) {
				onStart();
			} else {
				console.log('Failed to listen to port ' + port);
			}
		});
		
class WebsocketHttpResponse
	inline js void writeHeader(string key, string value)
		this.writeHeader(key, value); 
	inline js void send(string result, int code = 200, filename = "") 
		this.writeHeader("Content-Type", http.contentTypeMap[filename.getExtension()] || "text/plain"); 
		this.end(result);
	inline js void onAborted(void() code)
		this.onAborted(code)
	inline js void redirect(string location)
		this.writeStatus('302')
		this.writeHeader('location', location)
		this.end()
		
class Connection
	inline js bool send(Buffer buffer) this.send(buffer.toByteArray(), /*isBinary*/true, /*compress*/false)
	inline js int bufferedAmount() this.getBufferedAmount()
	inline js object data := this.data
	inline js void data(object value) this.data = value
	inline js void close() this.close()
