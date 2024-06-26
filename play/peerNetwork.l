// Platform.start
// core.join

// ServerNetwork
//     setup
//     onConnectedToServer
//     sendJoinMessage
//     onJoinResponse     ->  PeerNetwork.initiate for each user already in the room
//     ping
//     onPong
//     startConnected 
	
// PeerNetwork (for each user already in the room)
//     initiate
//     setupPeerConnection
//     setupRemoteMedia
//     setupDataChannel
//     onNegotiationNeeded
//     createOffer
//     onAnwserReceived
//     onConnectionStateChange
	
// [ ] Test all users connecting at once
// [ ] Handle situations where a new user isn't connected to all users yet
//         A users probably shouldn't be able to do anything before they connect all their offers
//         For example: A+B connect, B+C connect, C does something, A can' rewind
// [ ] Allow removing users
// [ ] Save event stream to db
// [ ] Save snapshots to db
// [ ] Undo clicks
// [ ] Save statistics when a connection error occurs
	
transient immutable Signal
	int receiverId
	string type
	string sdp

transient immutable IceMessage
	int receiverId
	object iceCandidate
	
enum VideoShape: Rectangle, Square, Circle
enum RelayMode: Never, Auto, Always
		
immutable MediaDeviceInfo
	string deviceId
	string groupId
	string kind
	string label

immutable MediaDevices
	MediaDeviceInfo[] audioInput
	MediaDeviceInfo[] audioOutput
	MediaDeviceInfo[] videoInput
	
transient skipInit unit PeerNetwork
	RelayMode relayMode = Auto
	
	internal enableVideo = true
	internal enableAudio = true
	
	visible string error
	int retries
	
	initiate: InternalUser user
		setupPeerConnection user, offerByMe:true
		setupRemoteMedia user
		setupDataChannel user
		
	tick
		let now = Time.realTime
		for input.internalUsers
			if . 
				// Reconnect to peer: Try to connect again if we aren't connected 5 seconds after starting to connect
				// We use a central place to reconnect and no intervals, timeouts or reloads to make it easier to reason about
				if .connectionState != "connected" and now > .startToConnectTime + 5000
				
				// !!! EVALUATE Wait longer for the 2nd retry
				// if .connectionState != "connected" and (now > .startToConnectTime + 10000
				// or (retries == 0 and now > .startToConnectTime + 5000))
				
				// !!! EVALUATE Reconned immediately when failed
				// or .connectionState == "failed"
					
					core.log "#peer The state is {.connectionState} after {now-.startToConnectTime} ms and {.connectionTries} retries"
					.startToConnectTime = Time.realTime
					statistics.scheduleSendIn 3 seconds
					
					if .offerByMe
						core.log "#peer Restarting ICE (offer by me)"
						setupDataChannel .
						.peerConnection.restartIce()
						retries++
						.connectionTries++
					
					// !!! EVALUATE Recreate peer channel after a few failed tries
					// if .connectionTries < 2
					// 	core.log "#peer The state is {.connectionState} after {now-.startToConnectTime} ms and {.connectionTries} tries -> Restart ICE"
					// 	setupDataChannel .
					// 	.peerConnection.restartIce()
					// else
					// 	core.log "#peer The state is {.connectionState} after {now-.startToConnectTime} ms and {.connectionTries} tries -> Recreate Peer Connection"
					// 	setupPeerConnection . offerByMe:true
					// 	setupDataChannel .
						
					
				if .connectionState == "connected" and (.dataChannel == null or .dataChannel.readyState != "open") and now > .startDataChannelTime + 5000
					core.log "#peer The data channel is {.dataChannel?.readyState} after {now-.startDataChannelTime} ms -> Recreate data channel"
					setupDataChannel .
				
	
	private js object setupPeerConnection: InternalUser user, bool offerByMe
		if(user.peerConnection) {
			try {
				core.log(`#peer <${user.id}> Close Previous Peer Connection`)
				user.peerConnection.onnegotiationneeded = null;
				user.peerConnection.onsignalingstatechange = null;
				user.peerConnection.onconnectionstatechange = null;
				user.peerConnection.onicecandidate = null;
				user.peerConnection.icecandidateerror = null;
				user.peerConnection.oniceconnectionstatechange = null;
				user.peerConnection.onicegatheringstatechange = null;
				user.peerConnection.close();
			} catch {}
		}
		try {
			user.startToConnectTime = Date.now();
			user.offerByMe = offerByMe;
			
			let options = {
				// We use the ice transport policy "relay" to test our turn server
				iceTransportPolicy: PeerNetwork.relayMode == 2 ? "relay" : "all",
				iceServers: [],
				// iceCandidatePoolSize: 10,
			}
			if(PeerNetwork.relayMode > 0) {
				// OVH turn server
				// options.iceServers.push({
				// 	urls: 'turn:193.70.81.132:39571',
				// 	username: 'play-user-x8env28gx41odbxzwjyut2oq871987syq8ovyuqp128djbsjue',
				// 	credential: 'qoy91n981vlplabb1873jdcgsouz2qm87qmmakqpc2t8hbeyjsyaqkuz'
				// });	
				
				// Alphahosting turn server
				options.iceServers.push({
					urls: 'turn:89.22.121.145:39571',
					username: 'play-user-x8env28gx41odbxzwjyut2oq871987syq8ovyuqp128djbsjue',
					credential: 'qoy91n981vlplabb1873jdcgsouz2qm87qmmakqpc2t8hbeyjsyaqkuz'
				});	
			}
			options.iceServers.push({
				urls: [
					// OVH stun server
					// "stun:193.70.81.132:39571",
					
					// Google stun server
					"stun:stun1.l.google.com:19302",
					"stun:stun2.l.google.com:19302",
				],
			});
			core.log(`#peer <${user.id}> Setup Peer Connection offerByMe: ${offerByMe}`);
			let peerConnection = user.peerConnection = new RTCPeerConnection(options);
			
			// Negotiation
			peerConnection.onnegotiationneeded = e => {
				core.log(`#peer <${user.id}> Negotiation Needed`);
				if(offerByMe) PeerNetwork.createOffer(user);
			}
			
			// Signaling, Connection
			peerConnection.onsignalingstatechange = e => {
				core.log(`#peer <${user.id}> Signaling State Change: ${peerConnection.signalingState}`);
			}
			peerConnection.onconnectionstatechange = e => {
				core.log(`#peer <${user.id}> Connection State Change: ${peerConnection.connectionState}`);
				user.connectionState = peerConnection.connectionState;
				user.connected = peerConnection.connectionState == "connected";
				if(user.connected) PeerNetwork.onConnected(user);
					
				// !!! EVALUATE Retry right away when connection failed
				// if(peerConnection.connectionState == "failed" && offerByMe) {
				// 	core.log(`#peer <${user.id}> Connection Failed -> Restart ICE`);
				// 	// if(user.dataChannel) user.dataChannel.close();
				// 	user.startToConnectTime = Date.now();
				// 	PeerNetwork.setupDataChannel(user);
				// 	peerConnection.restartIce();
				// }
			}
			
			// ICE: Candidate, Error, Connection, Gathering
			let candidateCount = 0
			peerConnection.onicecandidate = async event => {
				if (event.candidate) {
					core.log(`#peer <${user.id}> Gathered Local Ice Candidate ${++candidateCount} -> Send to peer`);
					ServerNetwork.sendIce(user.id, JSON.stringify(event.candidate));
				} else {
					core.log(`#peer <${user.id}> Gathered Local Ice Candidates Complete`);
				}
			}
			peerConnection.icecandidateerror = e => {
				core.log(`#peer <${user.id}> IDE Candidate Error: ${e.errorText}`);
			}
			peerConnection.oniceconnectionstatechange = e => {
				core.log(`#peer <${user.id}> ICE Connection State Change: ${peerConnection.iceConnectionState}`);
				if(peerConnection.iceConnectionState == "disconnected") {
					// Send logfiles to server
					setTimeout(() => statistics.saveStatistics(), 7000);
				}
			}
			peerConnection.onicegatheringstatechange = e => {
				core.log(`#peer <${user.id}> ICE Gathering State Change: ${peerConnection.iceGatheringState}`);
			}
			
			// !!! EVALUATE Create offer right away, because sometimes "negotiationneeded" isn't fired
			// if(offerByMe) PeerNetwork.createOffer(user);
			
			return peerConnection;
		} 
		catch(e) {
			core.log("#peer <"+user.id+"> setupPeerConnection failed " + e.message)
			console.error(e);
			core.log(e.stack);
			return null;
		}

	private js void setupDataChannel: InternalUser user
		try {
			core.log("#peer <"+user.id+"> Data Channel Creating");
			user.startDataChannelTime = Date.now();
			
			if(user.dataChannel) {
				core.log("#peer <"+user.id+"> Closing previous Data Channel");
				user.dataChannel.onopen = null;
				user.dataChannel.onclosing = null;
				user.dataChannel.onclose = null;
				user.dataChannel.onerror = null;
				user.dataChannel.onmessage = null;
				user.dataChannel.close();
				user.dataChannel = null;
				core.log("#peer <"+user.id+"> Closed previous Data Channel");
			}
			user.dataChannel = null
			
			// Create reliable data channel
			// These options would create an unreliable one: {ordered:false, maxRetransmits:0}
			let dataChannel = user.peerConnection.createDataChannel("channel");
			dataChannel.binaryType = "arraybuffer";
			
			// Open
			dataChannel.onopen = e => {
				core.log("#peer <"+user.id+"> Data Channel Open");
				user.dataChannel = dataChannel;
			}
			
			// Close, Error
			dataChannel.onclosing = e => {
				core.log("#peer <"+user.id+"> Data Channel Closing");
			}
			dataChannel.onclose = e => {
				core.log("#peer <"+user.id+"> Data Channel Close");
				user.dataChannel = null;
				user.connected = false;
			}
			dataChannel.onerror = e => {
				core.log("#peer <"+user.id+"> Data Channel Error " + ev.error.message);
			}
			
			// Message
			dataChannel.onmessage = e => {
				PeerNetwork.onMessage(user, new Buffer(e.data, 0, 0, 0));
			}
		} 
		catch(e) {
			core.log("#peer <"+user.id+"> setupDataChannel failed " + e.message)
			console.error(e);
			core.log(e.stack);
		}
		
	onConnected: InternalUser user
		user.startDataChannelTime = Time.realTime
		logConnectionType user
		
		if not statistics.connectTime
			int connectedCount = input.internalUsers.count.offerByMe and .connected
			int offerCount = input.internalUsers.count.offerByMe
			core.log "#peer Connected on try {user.connectionTries}, {connectedCount} of {offerCount} my offers are connected"
			
			if input.internalUsers.none.offerByMe and not .connected
				statistics.connectTime = Time.preciseTime - statistics.startTime
				core.log "#peer All my offers are connected after {statistics.connectTime} ms and {retries} retries"
			
	disconnect: InternalUser user
		if user.dataChannel != null: user.dataChannel.close
		if user.peerConnection != null: user.peerConnection.close
		input.internalUsers[user.id] = null
		
	js void setBitrate: InternalUser user, float scaleResolutionDownBy = 1, float maxBitrate
		try {
			let senderList = user.peerConnection.getSenders();
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
		}
		catch(e) {
			core.log("#peer <"+user.id+"> setBitrate failed " + e.message)
			console.error(e);
			core.log(e.stack);
		}
				
	private js void createOffer: InternalUser user
		try {
			core.log("#peer <"+user.id+"> Sending offer to "+user.id+", waiting for answer. Try:"+user.connectionTries);
			let peerConnection = user.peerConnection
			let offer = await peerConnection.createOffer();
			await peerConnection.setLocalDescription(offer);
			ServerNetwork.sendSignal(user.id, "offer", peerConnection.localDescription.sdp)
			user.receivedAnswer = false

			// !!! EVALUATE Reconnect using timeout
			// setTimeout(() => {
			// 	let state = peerConnection.connectionState 
			// 	core.log(`#peer <${user.id}> Checking connection state after ${retryIfNotConnectedAfter}: ${state}`);
			// 	if(state != "connected") {
			// 		peerConnection.restartIce();
			// 		PeerNetwork.retries++
			// 	}
			// }, retryIfNotConnectedAfter);
		}
		catch(e) {
			core.log("#peer <"+user.id+"> createOffer failed " + e.message)
			console.error(e);
			core.log(e.stack);
		}
		
	js void onReceivedOffer: InternalUser user, string sdp
		try {
			core.log("#peer <"+user.id+"> Received offer -> Send answer");
			PeerNetwork.setupPeerConnection(user, /*offerByMe*/false);
			PeerNetwork.setupRemoteMedia(user);

			// Data channel
			user.peerConnection.ondatachannel = e => {
				core.log("#peer <"+user.id+"> Data Channel Received");
				let dataChannel = e.channel;
				dataChannel.binaryType = "arraybuffer";
				user.dataChannel = dataChannel;
				
				// Open
				dataChannel.onopen = e => {
					core.log("#peer <"+user.id+"> Data Channel Open");
					user.dataChannel = dataChannel;
					user.connected = true;
					PeerNetwork.logConnectionType(user);
				}
				
				// Close, Error
				dataChannel.onclosing = e => {
					core.log("#peer <"+user.id+"> Data Channel Closing "+e);
					user.dataChannel = null;
				}
				dataChannel.onclose = e => {
					user.dataChannel = null;
					user.connected = false;
					core.log("#peer <"+user.id+"> Data Channel Close "+e);
				}
				dataChannel.onerror = e => {
					core.log("#peer <"+user.id+"> Data Channel Error "+e.error.message);
				}
				
				// Message
				dataChannel.onmessage = e => {
					PeerNetwork.onMessage(user, new Buffer(e.data, 0, 0, 0));
				}
			}
						
			// Answer
			let peerConnection = user.peerConnection;
			await peerConnection.setRemoteDescription(new RTCSessionDescription({type: "offer", sdp}));
			let answer = await peerConnection.createAnswer();
			await peerConnection.setLocalDescription(answer);
			ServerNetwork.sendSignal(user.id, "answer", peerConnection.localDescription.sdp);
		}
		catch(e) {
			core.log("#peer <"+user.id+"> onReceivedOffer failed " + e.message)
			console.error(e)
			core.log(e.stack);
		}
		
	Buffer sendBuffer = {}
	
	sendInputs: int inputFrame
		for input.internalUsers -> user if user
			let inputs = input.localUser.inputs
			let length = inputs.writePos - user.inputsSentPos
			
			if user.dataChannel != null
				sendBuffer.reset
				sendBuffer.writeInt8 cast NetworkMessageType.Tick
				sendBuffer.writeInt inputFrame // You got all inputs up to and including this frame
				sendBuffer.writeInt user.inputsSentPos
				sendBuffer.writeBuffer inputs, user.inputsSentPos, length
				sendBuffer.writeInt core.lastChecksumFrame                           // The last certain frame with inputs from everybody
				sendBuffer.writeFloat64 core.checksums[core.lastChecksumFrame] || 0  // The checksum of the last certain frame
				
				core.tickMessageSize = send ., sendBuffer
				user.inputsSentPos = inputs.writePos
				
			// if length
			// 	core.storeInputsToDB user
			// core.storeRoomToDB
			
	private js int send: InternalUser user, Buffer buffer
		try {
			let data = buffer.toByteArray()
			user.dataChannel.send(data)
			return data.byteLength
		} 
		catch(e) {
			core.log("#peer <"+user.id+"> send failed " + e.message)
			console.error(e)
			core.log(e.stack)
			return 0
		}
		
	// private js void onMessage: InternalUser user, Buffer buffer
	// 	setTimeout(() => PeerNetwork.onMessageDo(user, buffer), 1000)
								
	private onMessage: InternalUser user, Buffer buffer
		NetworkMessageType type = cast buffer.readInt8
		if type == Tick:         onTick user, buffer; else
		if type == Ping:         onPing user, buffer;  else
		if type == Pong:         onPong user, buffer;
			
	private onTick: InternalUser sender, Buffer buffer
		let inputFrame = buffer.readInt
		
		if inputFrame >= sender.inputFrame
			let prevInputFrame = sender.inputFrame
			let prevWritePos = buffer.readInt
			
			sender.inputFrame = inputFrame
			buffer.readBuffer sender.inputs, prevWritePos
			
			if core.verbose: core.log "<{sender.id}> Received inputFrame: {prevInputFrame}->{inputFrame} writePos: {prevWritePos}->{sender.inputs.writePos}"
			
			// Checksum
			int checksumFor = buffer.readInt
			float checksum = buffer.readFloat64
			if core.verbose: core.log "<{sender.id}> #{checksumFor} {checksum}"
			
			let myChecksum = core.checksums[checksumFor]
			if !myChecksum                           core.checksums[checksumFor] = checksum; else
			if !myChecksum.isApproximately(checksum) core.onWrongChecksum checksumFor, mine:myChecksum theirs:checksum
		
	js void onReceivedAnswer: InternalUser user, string sdp
		core.log("#peer <"+user.id+"> Received Answer");
		try {
			await user.peerConnection.setRemoteDescription(new RTCSessionDescription({type: "answer", sdp}));
			user.receivedAnswer = true
		}
		catch(e) {
			core.log("#peer <"+user.id+"> onReceivedAnswer failed " + e.message)
			core.log(e.stack);
		}	
			
	js void onIce: InternalUser user, string candidate
		core.log("#peer <"+user.id+"> Received Ice Candidate");
		try {
			await user.peerConnection.addIceCandidate(new RTCIceCandidate(JSON.parse(candidate)));
		}
		catch(e) {
			core.log("#peer <"+user.id+"> onIce failed " + e.message)
			core.log(e.stack);
		}
		
	private js void logConnectionType: InternalUser user
		setTimeout(async () => {
			let stats = await user.peerConnection.getStats()
			let candidatePairs = [...stats.values()].filter(s => s.type == "candidate-pair" && s.state == "succeeded")
			let candidatePair = candidatePairs.find(a => a.selected) || candidatePairs[0]
			if(candidatePair) {
				let candidate = stats.get(candidatePair.localCandidateId);
				let ip = candidate.ip || candidate.address
				user.connectionType = candidate.candidateType + " " + ip
				core.log("#connection <"+user.id+"> connection "+user.connectionType)
			} else {
				core.log("#connection <"+user.id+"> connection: no candidate pair for "+user.id)
				window.stats = [...stats.values()]
				console.log(window.stats)
				try  { core.log(JSON.stringify(window.stats)) }
				catch{ }
			}
		}, 10000)
		
	// --------------------------------------------- Ping/Pong ---------------------------------------------
	
	ping
		for input.internalUsers -> user
			if user and user.dataChannel != null
				sendBuffer.reset
				sendBuffer.writeInt8 cast NetworkMessageType.Ping
				sendBuffer.writeFloat64 core.currentTime
				send ., sendBuffer
				
	private onPing: InternalUser user, Buffer buffer
		float pingTime = buffer.readFloat64
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Pong
		sendBuffer.writeFloat64 pingTime
		send user, sendBuffer
		
	private onPong: InternalUser user, Buffer buffer
		float now = core.currentTime
		float pingTime = buffer.readFloat64
		float pingPongTime = now - pingTime
		let player = input.players.find.id == user.id
			statistics.add "pingPongTime" userIndex:player.index, color:player.color, value:pingPongTime, set:3, isPerFrame:false
				
	// --------------------------------------------- Checksum ---------------------------------------------
	
	sendChecksum: int checksumFor, float checksum
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Checksum
		sendBuffer.writeInt checksumFor
		sendBuffer.writeFloat64 checksum
		
		for input.internalUsers -> user
			if user and user.dataChannel != null	
				send ., sendBuffer

	onChecksum: InternalUser user, Buffer buffer
		int checksumFor = buffer.readInt
		float checksum = buffer.readFloat64
		if core.verbose: core.log "<{user.id}> #{checksumFor} {checksum}"
		
		let myChecksum = core.checksums[checksumFor]
		if !myChecksum
			core.checksums[checksumFor] = checksum
		else
		if !myChecksum.isApproximately(checksum)
			core.onWrongChecksum checksumFor, mine:myChecksum theirs:checksum
				
	// --------------------------------------------- Media Setup ---------------------------------------------
	
	MediaDevices devices = {}
	string videoInputId, audioInputId, audioOutputId	
	
	js async void setupLocalMedia: bool enableVideo, bool enableAudio
		core.log("setupLocalMedia: start")
		PeerNetwork.enableVideo = enableVideo
		PeerNetwork.enableAudio = enableAudio
		if(!enableVideo && !enableAudio) return
			
		try {
			// Create local media stream
			input.localUser.mediaStream = await navigator.mediaDevices.getUserMedia({
				video: {width: 500, height: 375},
				audio: enableAudio
			});
			core.log("setupLocalMedia: getUserMedia done")
			
			// Enummerate local devices
			let devices = await navigator.mediaDevices.enumerateDevices();
			core.log("setupLocalMedia: enumerateDevices done")
			
			for(let device of devices) {
				switch(device.kind) {
					case "videoinput":  PeerNetwork.devices.videoInput.push(device); break;
					case "audioinput":  PeerNetwork.devices.audioInput.push(device); break;
					case "audiooutput": PeerNetwork.devices.audioOutput.push(device); break;
				}
			}
			PeerNetwork.videoInputId = input.localUser.mediaStream.getVideoTracks()[0]?.getSettings().deviceId || PeerNetwork.devices.videoInput[0]?.deviceId
			PeerNetwork.audioInputId = input.localUser.mediaStream.getAudioTracks()[0]?.getSettings().deviceId || PeerNetwork.devices.audioInput[0]?.deviceId
			PeerNetwork.audioOutputId = PeerNetwork.devices.audioOutput[0]?.deviceId
			statistics.cameraTime = performance.now() - statistics.startTime
			core.log("#camera Setup Local Camera and Microphone after "+statistics.cameraTime+" ms")
			
		} catch(error) {
			core.log(error.message)
			if(error.name == "NotAllowedError") {
				PeerNetwork.error = "To play with friends over a video call, you need to allow access to your webcam."
			} else {
				PeerNetwork.error = "Can't access webcam. Please make sure it's not used by another application."
			}
			core.errorMessage = error.message
			throw error
		}
	
	js void setVideoInput: string videoInputId
		                   Player player
		if(Platform.fastForward || input.localUser.id != player.id ||  PeerNetwork.videoInputId == videoInputId || !videoInputId) return;
		PeerNetwork.videoInputId = videoInputId;
		
		// Create local media stream
		input.localUser.mediaStream = await navigator.mediaDevices.getUserMedia({
			audio: {deviceId: PeerNetwork.audioInputId},
			video: {deviceId: PeerNetwork.videoInputId},
		});
		
		// Update video elements and tracks
		for(let el of input.localUser.videoElements) {
			el.srcObject = input.localUser.mediaStream;
		}
		const [videoTrack] = input.localUser.mediaStream.getVideoTracks();
		for(let user of input.internalUsers) {
			if(user?.peerConnection) {
				const sender = user.peerConnection.getSenders().find((s) => s.track.kind === videoTrack.kind);
				sender.replaceTrack(videoTrack);
			}
		}
			
	js void setAudioInput: string audioInputId
		                   Player player
		if(Platform.fastForward || input.localUser.id != player.id || PeerNetwork.audioInputId == audioInputId || !audioInputId) return;
		PeerNetwork.audioInputId = audioInputId;
		
		// Create local media stream
		input.localUser.mediaStream = await navigator.mediaDevices.getUserMedia({
			audio: {deviceId: PeerNetwork.audioInputId},
			video: {deviceId: PeerNetwork.videoInputId},
		});
		
		// Update tracks
		const [audioTrack] = input.localUser.mediaStream.getAudioTracks();
		for(let user of input.internalUsers) {
			if(user?.peerConnection) {
				const sender = user.peerConnection.getSenders().find((s) => s.track.kind === audioTrack.kind);
				sender.replaceTrack(audioTrack);
			}
		}
			
	js void setAudioOutput: string audioOutputId
		                    Player player
		if(Platform.fastForward || input.localUser.id != player.id || PeerNetwork.audioOutputId == audioOutputId || !audioOutputId) return;
		PeerNetwork.audioOutputId = audioOutputId;
		
		// Update audio elements
		for(let user of input.internalUsers) {
			if(user) {
				if(user.audioElement && user.audioElement.setSinkId) {
					user.audioElement.setSinkId(PeerNetwork.audioOutputId);
				}
				for(let videoElement of user.videoElements) {
					if(videoElement.setSinkId) {
						videoElement.setSinkId(PeerNetwork.audioOutputId);
					}
				}
			}
		}
		audio.reload();
		
	private js void setupRemoteMedia: InternalUser user
		// Remove old video elements
		for(let videoElement of user.videoElements)
			videoElement.remove()
		user.videoElements.length = 0
		
		if(!PeerNetwork.enableVideo && !PeerNetwork.enableAudio) return
			
		// Add local tracks to peer connection
		for(let track of input.localUser.mediaStream.getTracks())
			user.peerConnection.addTrack(track, input.localUser.mediaStream);
		
		// Create media stream for remote player
		user.mediaStream = new MediaStream();
		
		// Add incoming tracks to media stream for remote player
		user.peerConnection.ontrack = event => {
			core.log("#peer <"+user.id+"> Add track");
			event.streams[0].getTracks().forEach(track => {
				user.mediaStream.addTrack(track);
			});
		}
		user.peerConnection.onremovetrack = event => {
			core.log("#peer <"+user.id+"> Remove track");
		}

	// --------------------------------------------- Media elements ---------------------------------------------
	
	js object createVideoElement: object stream, bool local
		let el = document.createElement("video")
		el.style = "border-radius: 500px; object-fit: cover; position:absolute; top:0px; left:0px; z-index:10000; visibility:hidden; pointer-events: none; user-select: none; "+(local ? "transform: scaleX(-1)" : "")
		el.autoplay = true
		el.playsinline = true
		el.controls = false
		el.muted = local
		el.srcObject = stream
		document.body.appendChild(el)
		return el
		
	js void removeVideoElement: object videoElement
		videoElement.remove()
						
	js void updateVideoElement: object videoElement, float x, float y, float sizeX, float sizeY, float radius
		videoElement.style.left = (x-sizeX/2)+"px"
		videoElement.style.top = (y-sizeY/2)+"px"
		videoElement.style.width = sizeX+"px"
		videoElement.style.height = sizeY+"px"
		videoElement.style.visibility = "visible"
		videoElement.style.borderRadius = radius+"px"
		
	js void setAudioMuted: object audioElement, bool muted
		if(audioElement) audioElement.muted = muted
