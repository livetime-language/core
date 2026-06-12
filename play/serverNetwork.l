// This enum must stay in sync with the NetworkMessageType enum in server/src/app.l (same members, same order)
enum NetworkMessageType: Join, JoinResponse, Ping, Pong, Signal, Ice, Tick, Switch, Reload, ReadyForStateRequests, MakePrimary, RequestState, State, Checksum, RequestHistory, History

internal transient skipInit unit ServerNetwork
	// Must match protocolVersion in server/src/app.l, sent in Join and verified in JoinResponse
	const int protocolVersion = 1
	private object socket
	private Buffer sendBuffer = {}
	int nextConnectionId = 1
	bool connected
	float startToConnectTime = float.maxValue
	int retries
	
	tick
		// Use core.currentTime (monotonic) like onPong: the ping time below round-trips through the
		// server and is subtracted from core.currentTime there, so both must share one clock (F20)
		let now = core.currentTime

		// While playing, a better ping estimate must not snap core.startTime - targetFrame would
		// jump or stall - so onPong only updates referenceStartTime once we are Connected and we
		// slew startTime toward it here, at most about one frame per second
		if core.mode == Connected and referenceStartTime
			let maxAdjust = (now - lastSlewTime) * core.frameTime / 1000
			core.startTime += math.max(math.min(referenceStartTime - core.startTime, maxAdjust), -maxAdjust)
		lastSlewTime = now

		// Reconnect to server: Try to connect again if we aren't connected 5 seconds after starting to connect
		// We use a central place to reconnect and no intervals, timeouts or reloads to make it easier to reason about
		if not connected and now > startToConnectTime + 5000
			core.log "#server WebSocket not connected after {now - startToConnectTime} ms -> Reconnecting"
			setupServerConnection
			retries++
			
		// Ping
		// After a failed rejoin the server has us in the wrong room -> its pongs would corrupt core.startTime
		if not rejoinFailed and (core.mode == Ping or core.mode == Connected) and now >= nextPingTime
			sendBuffer.reset
			sendBuffer.writeInt8 cast NetworkMessageType.Ping
			sendBuffer.writeFloat64 now
			send sendBuffer
			nextPingTime = now + (core.mode == Ping ? 200 : pongCount < 20 ? 1000 : 30000)
		
	js void setupServerConnection
		// Same monotonic clock as core.currentTime (inlined here: js blocks can't call inline functions)
		ServerNetwork.startToConnectTime = Math.round(performance.timeOrigin + performance.now())
		ServerNetwork.connected = false
		
		if(ServerNetwork.socket) {
			core.log("#server Closing Previous Websocket");
			ServerNetwork.socket.onopen = null
			ServerNetwork.socket.onclose = null
			ServerNetwork.socket.onmessage = null
			ServerNetwork.socket.onerror = null
			ServerNetwork.socket.close()
		}
		
		core.log("#server Creating Websocket");
		if(location.href.indexOf("localhost") != -1) ServerNetwork.socket = new WebSocket("ws://localhost:3112");
		else                                         ServerNetwork.socket = new WebSocket("wss://signal.up4playing.com");
		ServerNetwork.socket.binaryType = "arraybuffer";
		
		ServerNetwork.socket.onopen = () => {
			core.log("#server Websocket Open");
			ServerNetwork.connected = true;
			if(!ServerNetwork.firstConnectionTime)
				ServerNetwork.firstConnectionTime = Math.round(performance.timeOrigin + performance.now()) - ServerNetwork.startToConnectTime;
			ServerNetwork.onConnectedToServer();
		}
		ServerNetwork.socket.onclose = ev => {
			core.log("#server Websocket Closed "+ev.code+" "+ev.reason);
			ServerNetwork.connected = false;
		}
		ServerNetwork.socket.onerror = ev => {
			core.log("#server Websocket Error "+ev);
		}
		ServerNetwork.socket.onmessage = ev => {
			ServerNetwork.onMessageFromServer(new Buffer(ev.data, 0, 0, 0));
		}
	
	private getOrCreateUser: int id
		return input.internalUsers[id] || (input.internalUsers[id] = {id, local:false})
		
	// Called when we first connec to the server or when we reconnect
	private onConnectedToServer
		core.log "#server Connected to Server", input.localUser.id, core.roomId
		// After a failed rejoin the server no longer knows our room (see onJoinResponse) -> don't join a different room
		if rejoinFailed then return
		// Ticks sent while the connection was down may be lost
		// -> Resend our whole input history; the explicit position in each Tick makes the resend idempotent
		inputsSentPos = 0
		sendJoinMessage core.roomString, input.localUser.id, version:system.buildVersion
		
	js int bufferedAmount
		return ServerNetwork.socket.bufferedAmount 
		
	private js int send: Buffer buffer
		try {
			let data = buffer.toByteArray()
			ServerNetwork.socket.send(data)
			return data.byteLength
		} catch(e) { 
			core.log(e)
			return 0
		}
		
	private onMessageFromServer: Buffer buffer
		NetworkMessageType type = cast buffer.readInt8
		switch type
			NetworkMessageType.JoinResponse	onJoinResponse buffer; break
			NetworkMessageType.Pong	onPong buffer; break
			NetworkMessageType.Signal	onSignal buffer; break
			NetworkMessageType.Ice	onIce buffer; break
			NetworkMessageType.Tick	onTick buffer; break
			NetworkMessageType.Switch	onSwitch buffer; break
			NetworkMessageType.Reload	onReload buffer; break
		
	private void sendJoinMessage: string roomId, int userId, int version
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Join
		sendBuffer.writeString roomId
		sendBuffer.writeInt16 userId
		sendBuffer.writeInt16 version
		sendBuffer.writeInt16 protocolVersion
		send sendBuffer
		
		
	bool alreadyJoinedBefore
	// Set when a re-join after a WebSocket reconnect resolved to a different room or user (the server probably restarted)
	// We then stop re-joining so our signaling isn't silently routed inside the wrong server-side room
	bool rejoinFailed

	private onJoinResponse: Buffer buffer
		if rejoinFailed then return

		try
			// Read the fields in the exact order the server writes them in app.l
			// Use float64 or string for roomId in future to support 20240603121500
			int roomId = cast buffer.readFloat64
			// let roomId = buffer.readInt32
			let userId = buffer.readInt32
			let version = buffer.readInt32
			let serverProtocolVersion = buffer.readInt16
			if serverProtocolVersion != protocolVersion
				core.log "#server Protocol version mismatch: client uses {protocolVersion}, server uses {serverProtocolVersion}. Network messages may be misinterpreted."
			let seed = buffer.readString
			let serverStartTime = buffer.readFloat64
			let userCount = buffer.readInt16

			if alreadyJoinedBefore
				// We re-joined after a WebSocket reconnect
				// A signaling reconnect doesn't touch the WebRTC peer connections, so the first-join setup must not run again
				if roomId == core.roomId and userId == input.localUser.id
					core.log "#server Rejoined room {roomId} as user {userId}"
				else
					rejoinFailed = true
					core.log "#server Rejoin failed: received room {roomId} user {userId}, expected room {core.roomId} user {input.localUser.id}"
					alert "Connection to the room was lost (the server restarted). Please reload the page."
				return
			alreadyJoinedBefore = true

			for userCount
				let id = buffer.readInt32
				InternalUser user
				if id == userId then user = input.internalUsers[id] ?= input.localUser
				else             user = input.internalUsers[id] ?= {offerByMe:true, connectionId:nextConnectionId++}
				user.id = id
				
				// We don't send inputs from server any more
				// buffer.readBuffer user.inputs
				
				core.log "#onJoinResponse", userCount, id, user.local, input.internalUsers.joinToString(. ? .id.toString : "null"), user.inputs
	
			if roomId != core.roomId
				core.log "#server Received room id {roomId}"
				system.pushState "/{core.gameId}/{roomId}"
				core.roomId = roomId

			// Re-joins after a WebSocket reconnect must resolve to this exact room
			// -> Replace the original room string (which may have been empty, "staging" or "latest") with the assigned room id
			core.roomString = roomId.toString

			if version != system.buildVersion
				alert "You are using an old version of this application. Please refresh your browser."
				
			inputsSentPos = input.localUser.inputs.writePos
			input.localUser.id = userId
			math.setRandomSeed seed
			PeerNetwork.retries = 0
			PeerNetwork.dataChannelId = 0
			core.serverStartTime = serverStartTime
			core.mode = Ping
			core.storeUserId
			core.log "#server Joining room {roomId} as user {userId}"
			
			// Create an offer for each user already in the room
			for input.internalUsers
				if . and not .local
					PeerNetwork.initiate .

			// When we join with a preassigned userId, we may be rejoining after a page refresh and
			// the other users may still hold our previous session's input stream -> restore it from
			// them before the session starts (onPong delays startConnected until the restore settled)
			if core.localUserId != -1 and userCount > 1
				PeerNetwork.startRestore
		catch 
			core.onError error
		
	float nextPingTime, fastestPingPongTime = int.maxValue
	int pongCount

	float[] calculatedStartTimes
	float referenceStartTime
	float[] pingPongTimes
	private float lastSlewTime
	// Accepted pongs in a row whose start-time estimate was far off core.startTime (clock-step suspicion)
	private int driftedPongs
			
	private onPong: Buffer buffer
		float now = core.currentTime
		float timeSinceStart = buffer.readFloat64
		float pingTime = buffer.readFloat64
		float pingPongTime = now - pingTime
		float calculatedStartTime = now - pingPongTime/2 - timeSinceStart
		
		int deltaFromAverage = math.round(calculatedStartTime - core.startTime)
		statistics.serverPings.add pingPongTime
		
		// Ignore pings that took more than twice as long as the average
		pongCount++
		pingPongTimes.add pingPongTime maxLength:30
		let pingPongTimesAverage = pingPongTimes.average
		if pingPongTime > 400 or (pingPongTimes.length >= 15 and pingPongTime > pingPongTimesAverage * 2)
			core.log "#server ignoring ping-pong", pingPongTimes.length, pingPongTimesAverage
			return
			
		statistics.addInfo "from average", deltaFromAverage

		// An accepted pong's start-time estimate is off by at most pingPongTime/2 (< 200ms), so a much
		// larger deviation means the clock domains shifted: the machine slept or was suspended and
		// performance.now paused while the server clock kept running. Slewing can't absorb minutes
		// -> relearn the reference and snap startTime (the catch-up burst after the snap is F5 territory)
		if core.mode == Connected and math.abs(calculatedStartTime - core.startTime) > 1000
			driftedPongs++
			if driftedPongs == 1
				// A single pong could be a fluke -> confirm with an immediate second ping before re-anchoring
				nextPingTime = 0
			else
				core.log "#server Clock step of {math.round(calculatedStartTime - core.startTime)} ms detected -> re-anchoring startTime"
				driftedPongs = 0
				fastestPingPongTime = pingPongTime
				referenceStartTime = calculatedStartTime
				core.startTime = calculatedStartTime
			return
		driftedPongs = 0

		// Use the fastest ping-pong-time we have ever seen to calculate the reference start time
		if pingPongTime < fastestPingPongTime
			fastestPingPongTime = pingPongTime
			referenceStartTime = calculatedStartTime

			// Snapping startTime is only safe while the frame loop isn't pacing yet
			// Once Connected, tick slews startTime gently toward the reference instead (F20)
			if core.mode != Connected
				core.startTime = referenceStartTime

			core.log "#server New fastest pingPongTime", pongCount, now, pingPongTime, timeSinceStart, core.startTime, referenceStartTime
			
		// While we restore our previous session's input stream from our peers after a rejoin,
		// we keep pinging and only start the session when the restore settled (PeerNetwork.tickRestore)
		if pongCount >= 5 and not PeerNetwork.restoring
			core.startConnected frame:math.floor((now - core.startTime)/core.frameTime)+1
			
	sendSignal:	int receiverId, string type, string sdp
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Signal
		sendBuffer.writeInt32 receiverId
		sendBuffer.writeInt32 input.localUser.id
		sendBuffer.writeString type
		sendBuffer.writeString sdp
		send sendBuffer
		
	private onSignal: Buffer buffer
		let receiverId = buffer.readInt32
		let senderId = buffer.readInt32
		let type = buffer.readString
		let sdp = buffer.readString
		
		let sender = getOrCreateUser senderId
		if type == "offer"
			// When we receive an offer, a new user is connecting or an old user is reconnecting
			// -> Assign a new connection id
			sender.connectionId = nextConnectionId++
			PeerNetwork.onReceivedOffer sender, sdp
		else
		if type == "answer"
			PeerNetwork.onReceivedAnswer sender, sdp
			
	sendIce: int receiverId, string candidate
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Ice
		sendBuffer.writeInt32 receiverId
		sendBuffer.writeInt32 input.localUser.id
		sendBuffer.writeString candidate
		send sendBuffer
		
	private onIce: Buffer buffer
		let receiverId = buffer.readInt32
		let senderId = buffer.readInt32
		let candidate = buffer.readString
		
		let sender = getOrCreateUser senderId
		PeerNetwork.onIce sender, candidate
		
	int inputsSentPos
		
	sendInputs: int inputFrame
		let inputs = input.localUser.inputs

		let length = inputs.writePos - inputsSentPos
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Tick
		sendBuffer.writeInt32 input.localUser.id
		sendBuffer.writeInt32 inputFrame // You got all inputs up to and including this frame
		sendBuffer.writeInt inputsSentPos // I send inputs starting from this pos in my stream
		sendBuffer.writeBuffer inputs, inputsSentPos, length
		sendBuffer.writeInt core.lastChecksumFrame                           // The last certain frame with inputs from everybody
		sendBuffer.writeFloat64 core.checksums[core.lastChecksumFrame] || 0  // The checksum of the last certain frame
		send sendBuffer

		inputsSentPos = inputs.writePos
		core.tickMessageSize = sendBuffer.writePos

	private onTick: Buffer buffer
		let senderId = buffer.readInt32
		let sender = getOrCreateUser senderId
		let inputFrame = buffer.readInt32 // The sender sent inputs up to and including this frame

		// Discard late or out-of-order messages: a newer message always contains the older message's bytes
		if inputFrame >= sender.inputFrame
			let incomingInputsWritePos = buffer.readInt // The sender sent inputs starting from this pos in its stream

			// Peek the length to validate the write before it happens (readBuffer reads the length itself)
			let savedReadPos = buffer.readPos
			let length = buffer.readInt
			buffer.readPos = savedReadPos

			// Only contiguous appends are allowed: the stream is append-only and snapshots reference
			// positions in it, so a write must neither leave a gap nor shrink what we already have
			if incomingInputsWritePos > sender.inputs.writePos then return
			if incomingInputsWritePos + length < sender.inputs.writePos then return

			sender.inputFrame = inputFrame

			// Write the inputs at the explicit position so resent messages repair gaps and duplicates are idempotent
			buffer.readBuffer sender.inputs, incomingInputsWritePos

			// Checksum: the same trailing fields as the peer Tick, only read for accepted messages (F21)
			int checksumFor = buffer.readInt
			float checksum = buffer.readFloat64
			core.onRemoteChecksum checksumFor, checksum

	sendSwitch: SendInputsMode mode, int sendInterval
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Switch
		sendBuffer.writeInt32 cast mode
		sendBuffer.writeInt32 sendInterval
		send sendBuffer

	onSwitch: Buffer buffer
		SendInputsMode mode = cast buffer.readInt32
		core.sendInterval = buffer.readInt32
		
		if mode != core.sendInputsMode
			core.sendInputsMode = mode
	
	sendReload: bool newRoom, bool newUserId, bool keepMaster
		string url = "/{core.gameId}/{newRoom ? core.roomId+(core.roomId < 0 ? -1 : 1) : core.roomId}"
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Reload
		sendBuffer.writeBool keepMaster
		sendBuffer.writeBool newUserId
		sendBuffer.writeString url
		send sendBuffer

	onReload: Buffer buffer
		let keepMaster = buffer.readBool
		let newUserId = buffer.readBool
		let url = buffer.readString
		if !newUserId then url += "u{input.localUser.id}"
		system.setLocation url
