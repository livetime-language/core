transient class Signal
	int receiverId
	string type
	string sdp

transient class IceMessage
	int receiverId
	object iceCandidate

transient unit PeerNetwork
	private enableVideo = true
	private enableAudio = true
	
	private object localVideoStream
	visible object localVideoElement
	private Vector2 localVideoPos
	private float localVideoWidth = 440
	visible string connectionType
	visible string error
	
	private js object setupPeerConnection: InternalUser user, bool offerByMe
		let peerConnection = PeerNetwork_peerConnection = new RTCPeerConnection({
			// Set the ice transport policy to "relay" to test a turn server
			// iceTransportPolicy: "relay",
			// iceTransportPolicy: "all",
			iceServers: [
			{
				urls: [
					'stun:stun1.l.google.com:19302',
					'stun:stun2.l.google.com:19302',
				],
			},{
				urls: 'turn:81.169.197.127',
				username: 'app',
				credential: 'cyancircle'
			}
			],
			// iceCandidatePoolSize: 10,
		})
		
		// Event handlers
		peerConnection.onconnectionstatechange = e => {
			Network_log("onconnectionstatechange " + peerConnection.connectionState)
			if(peerConnection.connectionState == "disconnected")
				PeerNetwork_onDisconnectFromPeer(user)
		}
		
		peerConnection.onicecandidate = async event => {
			if (event.candidate)
				ServerNetwork_sendIce(user.id, JSON.stringify(event.candidate))
			else
				Network_log("Final ice candidate");
		}
		user.peerConnection = peerConnection
		user.offerByMe = offerByMe
		return peerConnection
			
	// private Connection createConnection: int partnerId, int connectionId, bool offerByMe
	// 	let user = Input.internalUsers[partnerId] || (Input.internalUsers[partnerId] = {id:partnerId, local:false})
	// 	let existingConnection = connections.find.userId == partnerId
	// 		log "removing existing connections", partnerId
	// 		closeConnection existingConnection
	// 		connections.removeAllWhere.userId == partnerId
		
	// 	let connection = Connection(partnerId)
	// 	connections.add connection
	// 	connection.state = user.state = Connecting
	// 	connection.peerConnection = setupPeerConnection(connection)
	// 	connection.offerByMe = offerByMe
	// 	user.connectionId = connectionId
	// 	log partnerId, connectionId, offerByMe, connection.state, connection.dataChannel
	// 	return connection
	
	object peerConnection
		
	js void createOffer: InternalUser user
		try {
			PeerNetwork_setupPeerConnection(user, /*offerByMe*/true)
			PeerNetwork_setupRemoteVideo(user)
		
			// Create reliable data channel
			// These options would create an unreliable one: {ordered:false, maxRetransmits:0}
			// let dataChannel = peerConnection.createDataChannel("channel")
			// dataChannel.binaryType = "arraybuffer"
			// connection.dataChannel = dataChannel
			// dataChannel.onopen = e => {
			// 	Network_log("createOffer: connection opened!")
			// 	Network_logConnectionType(peerConnection);
			// 	Network_onConnectedToPeer(connection, /*isNewUser*/true);
			// }
			// dataChannel.onerror = e => Network_log("DataChannel error: ", e)
			// dataChannel.onclose = e => Network_log("DataChannel close: ", e)
			// dataChannel.onclosing = e => {
			// 	Network_log("DataChannel closing: ", e)
			// 	Network_onDisconnectFromPeer(connection)
			// }
			// dataChannel.onmessage = e => {
			// 	Network_onPeerMessage(connection, new Buffer(e.data, 0, 0, 0))
			// }
			
			// Offer
			let peerConnection = user.peerConnection
			let offer = await peerConnection.createOffer();
			await peerConnection.setLocalDescription(offer);
			// offers.push({receiverId:partnerId, type: "offer", sdp: peerConnection.localDescription.sdp, connectionId:Network_connectionId })
			// offers.push({receiverId:user.id, type: "offer", sdp: peerConnection.localDescription.sdp })
			ServerNetwork_sendSignal(user.id, "offer", peerConnection.localDescription.sdp)
			Network_log("Sent offer to "+user.id+", waiting for answer.");
		}
		catch(e) {
			console.error(e);
			Network_log(e.stack);
		}
		
	js void setBitrate: float scaleResolutionDownBy = 1, float maxBitrate
		let senderList = PeerNetwork_peerConnection.getSenders();
		for(let sender of senderList) {
			const params = sender.getParameters();
			console.log(params);
			if (!params.encodings) {
				params.encodings = [{ }];
			}
			params.encodings[0].scaleResolutionDownBy = scaleResolutionDownBy;
			params.encodings[0].maxBitrate = maxBitrate;
			// params.encodings[0].adaptivePtime = true;
			await sender.setParameters(params);
		}
		
	js void onReceivedOffer: InternalUser user, string sdp
		try {
			PeerNetwork_setupPeerConnection(user, /*offerByMe*/false)
			PeerNetwork_setupRemoteVideo(user)
			
			// Data channel
			// peerConnection.addEventListener('datachannel', e => {
			// 	Network_log("onReceivedOffer: received datachannel")
			// 	let dataChannel = e.channel
			// 	dataChannel.binaryType = "arraybuffer"
			// 	connection.dataChannel = dataChannel
			// 	dataChannel.onopen = e => {
			// 		Network_log("onReceivedOffer: connection opened!")
			// 		Network_logConnectionType(peerConnection);
			// 		Network_onConnectedToPeer(connection, /*isNewUser*/false);
			// 	}
			// 	dataChannel.onerror = e => Network_log("DataChannel error: ", e)
			// 	dataChannel.onclose = e => Network_log("DataChannel close: ", e)
			// 	dataChannel.onclosing = e => {
			// 		Network_log("DataChannel closing: ", e)
			// 		Network_onDisconnectFromPeer(connection)
			// 	}
			// 	dataChannel.onmessage = e => {
			// 		Network_onPeerMessage(connection, new Buffer(e.data, 0, 0, 0))
			// 	}
			// })
			// Network_log("onReceivedOffer: data channel listeners")
						
			// Answer
			let peerConnection = user.peerConnection
			await peerConnection.setRemoteDescription(new RTCSessionDescription({type: "offer", sdp}));
			let answer = await peerConnection.createAnswer();
			await peerConnection.setLocalDescription(answer);
			ServerNetwork_sendSignal(user.id, "answer", peerConnection.localDescription.sdp)
			Network_log("Received offer from "+user.id+", sent answer, waiting for connection.");
			
			// Network_sendToServer(new SignalMessage(Network_userId, {receiverId:partnerId, type: "answer", sdp: peerConnection.localDescription.sdp, connectionId:Network_connectionId }))
			// Network_log("onReceivedOffer: Created and sent answer for "+partnerId+", received connectionId:"+offer.connectionId+" my connectionId:"+Network_connectionId+", waiting for connection")
		}
		catch(e) {
			console.error(e)
			Network_log(e.stack);
		}
		
	js void onReceivedAnswer: InternalUser user, string sdp
		await user.peerConnection.setRemoteDescription(new RTCSessionDescription({type: "answer", sdp}));
		Network_log("Received answer from "+user.id+".");
		
	js void onIce: InternalUser user, string candidate
		try {
			await user.peerConnection.addIceCandidate(new RTCIceCandidate(JSON.parse(candidate)));
		} catch(e) {
			Network_log("onIce failed " + e.message)
			Network_log(e.stack);
		}
		
	private js void setupLocalVideo: bool enableVideo, bool enableAudio
		PeerNetwork_enableVideo = enableVideo
		PeerNetwork_enableAudio = enableAudio
		if(!enableVideo && !enableAudio) return
			
		try {
			PeerNetwork_localVideoStream = await navigator.mediaDevices.getUserMedia({
				video: {
					width: 500,
					height: 375,
					// frameRate: 30
				},
				// video: true,
				audio: enableAudio
			});
			PeerNetwork_localVideoElement = PeerNetwork_createVideoElement(PeerNetwork_localVideoStream, /*local*/true);
			// let localUser = Input_internalUsers.find(a => a.local);
			// if(localUser) localUser.videoElement = PeerNetwork_localVideoElement;
			Network_log("setupLocalVideo: success")
		} catch(error) {
			Network_log(error.message)
			if(error.name == "NotAllowedError") {
				PeerNetwork_error = "To play with friends over a video call, you need to allow access to your webcam."
			} else {
				PeerNetwork_error = "Can't access webcam. Please make sure it's not used by another application."
			}
			Network_errorMessage = error.message
			throw error
		}
			
	private js void setupRemoteVideo: InternalUser user
		if(!PeerNetwork_enableVideo && !PeerNetwork_enableAudio) return
		for(let track of PeerNetwork_localVideoStream.getTracks())
			user.peerConnection.addTrack(track, PeerNetwork_localVideoStream);
		
		// TEMP logging
		Network_log("creating video for user "+user.id)
		var remoteStream = new MediaStream();
		user.videoElement = PeerNetwork_createVideoElement(remoteStream, /*local*/false)
		
		user.peerConnection.addEventListener('track', event => {
			Network_log('Got remote track:', event.streams[0]);
			event.streams[0].getTracks().forEach(track => {
				Network_log('Add a track to the remoteStream:', track);
				remoteStream.addTrack(track);
			});
		});

	private js object createVideoElement: object stream, bool local
		let el = document.createElement('video')
		el.style = "position:absolute; top:0px; left:0px; z-index:10000; visibility:hidden; "+(local ? "transform: scaleX(-1)" : "")
		el.autoplay = true
		el.playsinline = true
		el.controls = false
		el.muted = local
		document.body.appendChild(el)
		el.srcObject = stream
		return el
		
	js void removeVideoElement: int userId
		let internalUser = Input_internalUsers[userId];
		if(internalUser?.videoElement) internalUser.videoElement.remove()
			
	setUserVideoAndColor: int userId = 0, Vector2 pos = {}, float width = 440, Color color = null
		let user = Input.usersById[userId]
			user.videoPosition = pos
			user.videoWidth = width
			user.color = color
			
	internal setLocalVideo: Vector2 pos={}, float width = 440
		// Set position and size of local video before we connected
		localVideoPos = pos
		localVideoWidth = width
		
	internal js void updateVideoScreen
		if(Network_mode == 2/*Local*/ || !PeerNetwork_enableVideo) {
			for(let user of Input_users) {
				if(user && user.videoWidth) {
					graphics_drawImage(Image_VideoScreen, user.videoPosition, 0, user.videoWidth/440, -1, 1000000, 1.0)
				}
			}
		} else if(Input_users.length > 0) {
			// Set position and size of videos
			for(let user of Input_users) {
				if(user) {
					let internetUser = Input_internalUsers[user.id];
					let el = internetUser?.videoElement
					if(el) {
						let pixelPos = Input_logicalToPixelPosition(user.videoPosition)
						let pixelSizeX = user.videoWidth*graphics_totalMatrix.m0/Platform_pixelRatio
						let pixelSizeY = (user.videoWidth*3/4)*graphics_totalMatrix.m3/Platform_pixelRatio
						el.style.left = (pixelPos.x-pixelSizeX/2)+"px"
						el.style.top = (pixelPos.y-pixelSizeY/2)+"px"
						el.style.width = pixelSizeX+"px"
						el.style.height = pixelSizeY+"px"
						el.style.visibility = "visible"
					}
				}
			}
		} else if(PeerNetwork_localVideoElement) {
			// Set position and size of local video before we connected
			let pixelPos = Input_logicalToPixelPosition(PeerNetwork_localVideoPos)
			let pixelSizeX = PeerNetwork_localVideoWidth*graphics_totalMatrix.m0/Platform_pixelRatio
			let pixelSizeY = (PeerNetwork_localVideoWidth*3/4)*graphics_totalMatrix.m3/Platform_pixelRatio
			PeerNetwork_localVideoElement.style.left = (pixelPos.x-pixelSizeX/2)+"px"
			PeerNetwork_localVideoElement.style.top = (pixelPos.y-pixelSizeY/2)+"px"
			PeerNetwork_localVideoElement.style.width = pixelSizeX+"px"
			PeerNetwork_localVideoElement.style.height = pixelSizeY+"px"
			PeerNetwork_localVideoElement.style.visibility = "visible"
		}
		
	private onDisconnectFromPeer: InternalUser user
		Network.log "onDisconnectFromPeer userId:"+user.id
		
	private js void logConnectionType(object peerConnection)
		setTimeout(async () => {
			let stats = await peerConnection.getStats()
			let candidatePairs = [...stats.values()].filter(s => s.type == "candidate-pair" && s.state == "succeeded")
			let candidatePair = candidatePairs.find(a => a.selected) || candidatePairs[0]
			if(candidatePair) {
				let candidate = stats.get(candidatePair.localCandidateId);
				let ip = candidate.ip || candidate.address
				PeerNetwork_connectionType = candidate.candidateType
				Network_log("Connection: " + Network_connectionType+" "+ip+" "+candidate)
			} else {
				window.stats = [...stats.values()]
				Network_log("Can't access stats", window.stats)
			}
		}, 5000)
		
	// private float nextPingTime
	// private int pongCount
	
	// private onConnectedToPeer: Connection connection
	// 	                       bool isNewUser // Did this user just join the already exiting users (and make the offer)
		
	// 	let user = Input.internalUsers[connection.userId]
	// 	// if mode == Reconnecting && user && user.acknowledgedPos > 0
	// 	// 	mode = Connected
	// 	// 	connection.state = user.state = Connected
	// 	// 	log "Both users were already connected before", connection.userId, userId, mode, connection.state
	// 	// else
	// 	if isNewUser
	// 		// New users will send out ping messages to sync the startTime (and this way also the current frame)
	// 		mode = Ping
	// 		nextPingTime = currentTime + 100
	// 		pongCount = 0
	// 		connection.state = user.state = PingPong
	// 		log "New user, starting to ping", connection.userId, userId, mode, connection.state
	// 	else
	// 		// Existing users will wait for the new user to finish pinging
	// 		// to prevent sending the large initial message several times
	// 		if mode == Reconnecting: mode = Connected
	// 		connection.state = user.state = PingPong
	// 		log "Answering user, waiting for ping", connection.userId, userId, mode, connection.state
		
	// 	log connection.userId, isNewUser, mode, connection.state

	// private onWrongChecksum: float mine, float theirs
	// 	errorMessage = "Checksum mismatch"
	// 	checksumLog += " MISMATCH mine:{mine} theirs:{theirs}"
		
	// 	if !alertShown
	// 		alert "Clients out of sync. Please send me the log file that will be created."
	// 		saveLogs
	// 		alertShown = true
	
	// // Calculate the frame we received all remote inputs for.
	// // The lowest of all user frames. Called in onTickMessage.
	// private getReceivedInputFrames
	// 	int minFrames = -1
	// 	for user -> Input.internalUsers
	// 		if user && user.state == Connected && !user.local && (minFrames == -1 || user.inputFrame < minFrames)
	// 			minFrames = user.inputFrame
	// 	return minFrames
		
	// // Send inputs to other user. This is called in animationFrame.
	// private sendInputs: int inputFrame, float aheadAverage
	// 	let localPlayer = Input.internalUsers[userId]
	// 	let inputs = localPlayer.inputs
	// 	for c -> connections
	// 		if c.state == Connected
	// 			let receiver = Input.internalUsers[c.userId]
	// 			receiver.sendInterval = receiver.lagFrom < 15 and receiver.lagTo < 15 ? 1 : 60
				
	// 			if (inputFrame % receiver.sendInterval) == 0
	// 				sendBuffer.reset
	// 				sendBuffer.writeInt8 cast NetworkMessageType.Tick
	// 				sendBuffer.writeInt32 inputFrame        // You got all inputs up to and including this frame
	// 				sendBuffer.writeInt32 receiver.lagFrom  // TEMP for testing
	// 				sendBuffer.writeBuffer inputs, receiver.inputsSentPos, inputs.writePos - receiver.inputsSentPos
	// 				send c, sendBuffer
					
	// 				sentLog += " #{inputFrame} to:{c.userId} lag:{receiver.lagFrom} {receiver.inputsSentPos}->{inputs.writePos} {inputs.toRangeString(receiver.inputsSentPos, inputs.writePos)}"
	// 				receiver.inputsSentPos = inputs.writePos
	// 				tickMessageSize = sendBuffer.writePos

	// private onTickMessage: Connection c, Buffer buffer
	// 	let sender = Input.internalUsers[c.userId]
	// 	if c.state != Connected: c.state = sender.state = Connected
	// 	let prevWritePos = sender.inputs.writePos
		
	// 	sender.inputFrame = buffer.readInt32
	// 	sender.lagTo = buffer.readInt32
	// 	buffer.readBuffer sender.inputs, prevWritePos
		
	// 	receivedFrames = getReceivedInputFrames
	// 	sender.lagFrom = frame - sender.inputFrame
		
	// 	receivedLog += " [{currentTime}] <{c.userId}> #{sender.inputFrame} lag:{sender.lagTo} {prevWritePos}->{sender.inputs.writePos} {sender.inputs.toRangeString(prevWritePos, sender.inputs.writePos)}"

	// private onSignal: SignalMessage message
	// 	log "on signal: "+message.signal.type+" "+message.senderId+" -> "+message.signal.receiverId
	// 	if message.signal.type == "offer":  onReceivedOffer message.senderId, message.signal; else
	// 	if message.signal.type == "answer": onReceivedAnswer message.senderId, message.signal
	
	// private onPeerMessage: Connection c, Buffer buffer
	// 	NetworkMessageType type = cast buffer.readInt8
	// 	if type == Tick:         onTickMessage c, buffer; else
	// 	if type == Ping:         onPingMessage c, buffer; else
	// 	if type == Pong:         onPongMessage c, buffer; else
	// 	if type == RequestState: onRequestState c, buffer; else
	// 	if type == State:        onState c, buffer;
			
	// private ping
	// 	if (mode == Ping or mode == Connected) and currentTime >= nextPingTime
	// 		master = Input.internalUsers.withMin.connectionId where . and (.state == Connected or .state == PingPong or .local)
	// 		if master and (master.state == Connected or master.state == PingPong)
	// 			let c = connections.find.userId == master.id
	// 			sendPingMessage c, currentTime
	// 			nextPingTime = currentTime + 2000
		
	// private void sendPingMessage: Connection c, float pingTime
	// 	sendBuffer.reset
	// 	sendBuffer.writeInt8 cast NetworkMessageType.Ping
	// 	sendBuffer.writeFloat64 pingTime
	// 	sendBuffer.writeInt32 certainFrame                    // The last certain frame with inputs from everybody
	// 	sendBuffer.writeFloat64 checksums[certainFrame] || 0  // The checksum of the last certain frame
		
	// 	send c, sendBuffer
			
	// private onPingMessage: Connection c, Buffer buffer
	// 	if c.state != Disconnected
	// 		let pingTime = buffer.readFloat64
			
	// 		// Checksum
	// 		let checksumFor = buffer.readInt32
	// 		let checksum = buffer.readFloat64
	// 		checksumLog += " <{c.userId}> #{checksumFor} {checksum}"
	// 		if checksum
	// 			let myChecksum = checksums[checksumFor]
	// 			if !myChecksum
	// 				checksums[checksumFor] = checksum
	// 			else
	// 			if !myChecksum.isApproximately(checksum)
	// 				onWrongChecksum mine:myChecksum theirs:checksum
			
	// 		sendPongMessage c, currentTime-startTime, pingTime
		
	// private void sendPongMessage: Connection c, float timeSinceStart, float pingTime
	// 	log c.userId, c.state, timeSinceStart, pingTime, startTime
	// 	sendBuffer.reset
	// 	sendBuffer.writeInt8 cast NetworkMessageType.Pong
	// 	sendBuffer.writeFloat64 timeSinceStart		
	// 	sendBuffer.writeFloat64 pingTime
	// 	send c, sendBuffer

	// private onPongMessage: Connection c, Buffer buffer
	// 	float now = currentTime
	// 	float timeSinceStart = buffer.readFloat64
	// 	float pingTime = buffer.readFloat64
	// 	float pingPongTime = now - pingTime
	// 	if pingPongTime < c.fastestPingPongTime
	// 		// Use the fastest ping-pong-time we have ever seen to calculate the start time
	// 		c.fastestPingPongTime = pingPongTime
	// 		startTime = Math.round(now - pingPongTime/2 - timeSinceStart)
	// 		log "New fastest pingPongTime", c.userId, pongCount, pingPongTime, startTime
	// 	else
	// 		log c.userId, pongCount, pingPongTime, c.fastestPingPongTime, startTime
			
	// 	pongCount++
	// 	lastPingPongTime = pingPongTime
		
	// 	// Finish pinging after the 20th pong
	// 	if mode == Ping and pongCount >= 20 and c.fastestPingPongTime < 1000
	// 		// Request the state from the user who has been here the longest (has the lowest connectionId)
	// 		log "Ping-Pong complete", pongCount, c.fastestPingPongTime
	// 		master = Input.internalUsers.withMin.connectionId where . and (.state == Connected or .state == PingPong or .local)
	// 		let connection = connections.find.userId == master.id
	// 			sendRequestState connection

	// 	nextPingTime = now + (c.state == PingPong ? 100 : 3000)
		
	// private sendRequestState: Connection to
	// 	sendBuffer.reset
	// 	sendBuffer.writeInt8 cast NetworkMessageType.RequestState
	// 	send to, sendBuffer
	// 	log "requesting state from {to.userId}"	
		
	// private onRequestState: Connection c, Buffer buffer
	// 	snapshotBuffer.reset
	// 	Snapshot.serialize snapshotBuffer
	// 	sendState c, snapshotBuffer
		
	// private sendState: Connection to, Buffer buffer
	// 	let localPlayer = Input.internalUsers[userId]
	// 	sendBuffer.reset
	// 	sendBuffer.writeInt8 cast NetworkMessageType.State
	// 	sendBuffer.writeInt32 frame-1
	// 	let userCount = Input.internalUsers.count . != null
	// 	sendBuffer.writeInt32 userCount
	// 	for Input.internalUsers
	// 		if .
	// 			sendBuffer.writeInt32 .id
	// 			sendBuffer.writeInt32 .inputs.readPos
	// 	sendBuffer.writeBuffer buffer
	// 	send to, sendBuffer	
	// 	log "sending state to {to.userId} frame:{frame-1} readPos:{localPlayer.inputs.readPos} size:{buffer.writePos}"	
		
	// private onState: Connection c, Buffer buffer
	// 	snapshotBuffer.reset
	// 	let frame = buffer.readInt32
	// 	let userCount = buffer.readInt32
	// 	for userCount
	// 		let id = buffer.readInt32
	// 		let readPos = buffer.readInt32
	// 		let user = Input.internalUsers[id]
	// 			user.inputFrame = frame
	// 			user.inputs.readPos = user.inputs.writePos = readPos
	// 			log user.id, user.inputFrame, user.inputs.readPos
	// 	buffer.readBuffer snapshotBuffer
	// 	Snapshot.deserialize Network.snapshotBuffer
	// 	Math.recreateRandomValues
	// 	// int startFrame = Math.floor((currentTime - this.startTime)/targetFrameTime)+1
	// 	// startConnected startFrame
	// 	startConnected
	// 	log "received state",c.userId, frame, snapshotBuffer.writePos, userCount
			
	// private js void send: Connection connection, Buffer buffer
	// 	connection.dataChannel.send(buffer.buffer)

	// private js void closeConnection: Connection connection
	// 	Network_removeVideoElement(connection.userId)
		
	// 	if(connection.dataChannel) {
	// 		Network_log("closeConnection: dataChannel")
	// 		connection.dataChannel.close();
	// 		connection.dataChannel = null;
	// 	}
	// 	if(connection.peerConnection) {
	// 		Network_log("closeConnection: peerConnection")
	// 		connection.peerConnection.close();
	// 		connection.peerConnection = null;
	// 	}
		
	// private reconnect
	// 	if currentTime >= nextReconnect
	// 		if(socket)
	// 			log "Existing socket -> resending offers"
	// 			resendOffers
	// 		else
	// 			log "No existing socket -> reconnecting to server"
	// 			join gameId, roomId, userId
	// 		nextReconnect = currentTime + 6000
	
	// private resendOffers
	// 	Partner[] partners
	// 	for c -> connections
	// 		if c: log "Connection "+c.userId+" state:"+c.state+" offerByMe:"+c.offerByMe
	// 		else  log "Connection null"
	// 		if c && (c.state == Disconnected || c.state == Reconnecting) && c.offerByMe
	// 			partners.add {c.userId, Input.internalUsers[c.userId]?.connectionId}
	// 	log "Resending offers", userId, partners
	// 	createOffers partners		