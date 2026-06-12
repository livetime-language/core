// system.start
// core.join

// ServerNetwork
//     setup
//     onConnectedToServer
//     sendJoinMessage
//     onJoinResponse            ->    PeerNetwork.initiate for each user already in the room
//     ping
//     onPong
//     startConnected 
	
// PeerNetwork (for each user already in the room)
//     initiate
//     setupPeerConnection
//     setupRemoteMedia
//     setupDataChannel
//     onNegotiationNeeded
//     createOffer               ->    onReceivedOffer called on the peer we are connection to
//                                         \/
//     onReceivedAnswer          <-    createAnswer
//     onConnectionStateChange

internal transient immutable Signal
	int receiverId
	string type
	string sdp

internal transient immutable IceMessage
	int receiverId
	object iceCandidate
	
enum VideoShape: Rectangle, Square, Circle
enum RelayMode: Never, Auto, Always
		
internal transient immutable MediaDeviceInfo
	string deviceId
	string groupId
	string kind
	string label

internal transient MediaDevices
	MediaDeviceInfo[] audioInput
	MediaDeviceInfo[] audioOutput
	MediaDeviceInfo[] videoInput
	
internal transient skipInit unit PeerNetwork
	RelayMode relayMode = Auto
	
	internal enableVideo = true
	internal enableAudio = true
	
	visible string error
	int retries
	int dataChannelId
	private object mediaSetupPromise
	private bool retryingMedia

	initiate: InternalUser user
		// The media setup runs in parallel with the signaling connection
		// Wait until it settled so the local tracks are added when the peer connection is created
		await whenLocalMediaSettled
		setupPeerConnection user, offerByMe:true
		setupRemoteMedia user
		
	tick
		let now = PlainDate.realTime
		
		for input.internalUsers as user
			if . and not .local
				// Reconnect to peer is we haven't received anything for a while
				if now > .lastIncomingMessageTime + 10000					
					core.log "[{Time.ticks}] <{.id}> #problem -------------------------------- State is {.connectionState} after {now-.startToConnectTime} ms, {.connectionTries} retries, last incomming message {now - .lastIncomingMessageTime} ms ago, offerByMe:{.offerByMe} --------------------------------"
					.startToConnectTime = user.lastIncomingMessageTime = PlainDate.realTime
					statistics.scheduleSendIn 3 seconds
					
					if user.offerByMe
						retries++
						if ++user.connectionTries < 3
							core.log "#peer Restarting ICE (offer by me)"
							user.peerConnection.restartIce()
						else
							core.log "#peer Recreate peer connection (offer by me)"
							initiate user
	
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
			user.startToConnectTime = user.lastIncomingMessageTime = Date.now();
			user.offerByMe = offerByMe;
			
			let options = {
				// We use the ice transport policy "relay" to test our turn server
				iceTransportPolicy: PeerNetwork.relayMode == 2 ? "relay" : "all",
				iceServers: [],
				// iceCandidatePoolSize: 10,
			}
			if(PeerNetwork.relayMode > 0) {
				// OVH turn server
				options.iceServers.push({
					urls: 'turn:193.70.81.132:39571',
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
			peerConnection.onconnectionstatechange = e => {
				core.log(`#peer <${user.id}> Connection State Change: ${peerConnection.connectionState}`);
				user.connectionState = peerConnection.connectionState;
				user.connected = peerConnection.connectionState == "connected";
				if(user.connected) PeerNetwork.onConnected(user);
				if(peerConnection.connectionState == "disconnected")
					setTimeout(() => statistics.saveStatistics(), 7000);
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
			user.startDataChannelTime = Date.now();
			core.log("#peer <"+user.id+"> Data Channel Creating");
			
			// Close all previous data channels
			for(let dataChannel of user.dataChannels) {
				try   { 
					dataChannel.close();
					core.log("#peer <"+user.id+"> Data Channel Closing previous channel (id:"+dataChannel._id+")");
				} catch {}
			}
			user.dataChannels.length = 0;
			
			// Create reliable data channel
			// let dataChannel = user.peerConnection.createDataChannel("channel"); // reliable
			let dataChannel = user.peerConnection.createDataChannel("channel", {ordered:false, maxRetransmits:0}); // unreliable
			dataChannel.binaryType = "arraybuffer";
			dataChannel._id = PeerNetwork.dataChannelId++;
			
			// Open
			dataChannel.onopen = e => {
				user.dataChannels.splice(0,0,dataChannel);
				core.log("#peer <"+user.id+"> Data Channel Open (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
			}
			
			// Close, Error
			dataChannel.onclosing = e => {
				user.dataChannels.remove();
				core.log("#peer <"+user.id+"> Data Channel Closing (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
			}
			dataChannel.onclose = e => {
				user.dataChannels.remove();
				core.log("#peer <"+user.id+"> Data Channel Close (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
			}
			dataChannel.onerror = e => {
				core.log("#peer <"+user.id+"> Data Channel Error " + ev.error.message+" (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
			}
			
			// Message
			dataChannel.onmessage = e => {
				// core.log("#data <"+user.id+"> received " + e.data.byteLength + " bytes on channel "+ dataChannel._id);
				PeerNetwork.onMessage(user, new Buffer(e.data, 0, 0, 0));
			}
		} 
		catch(e) {
			core.log("#peer <"+user.id+"> setupDataChannel failed " + e.message)
			console.error(e);
			core.log(e.stack);
		}
		
	onConnected: InternalUser user
		user.startDataChannelTime = user.lastIncomingMessageTime = PlainDate.realTime
		logConnectionType user
		
		if user.offerByMe
			setupDataChannel user
		
		if not statistics.connectTime
			int connectedCount = input.internalUsers.count.offerByMe and .connected
			int offerCount = input.internalUsers.count.offerByMe
			core.log "#peer Connected on try {user.connectionTries}, {connectedCount} of {offerCount} my offers are connected"
			
			if input.internalUsers.none.offerByMe and not .connected
				statistics.connectTime = PlainDate.preciseTime - statistics.startTime
				core.log "#peer All my offers are connected after {statistics.connectTime} ms and {retries} retries"
			
	disconnect: InternalUser user
		core.log "####### disconnect"
		user.dataChannels.each.close()
		if user.peerConnection != null then user.peerConnection.close
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
		}
		catch(e) {
			core.log("#peer <"+user.id+"> createOffer failed " + e.message)
			console.error(e);
			core.log(e.stack);
		}
		
	js void onReceivedOffer: InternalUser user, string sdp
		try {
			// The media setup runs in parallel with the signaling connection
			// Wait until it settled so the local tracks are added when the peer connection is created
			await PeerNetwork.whenLocalMediaSettled();
			core.log("#peer <"+user.id+"> Received offer -> Send answer");
			PeerNetwork.setupPeerConnection(user, /*offerByMe*/false);
			PeerNetwork.setupRemoteMedia(user);

			// Data channel
			user.peerConnection.ondatachannel = e => {
				core.log("#peer <"+user.id+"> Data Channel Received");
				let dataChannel = e.channel;
				dataChannel.binaryType = "arraybuffer";
				dataChannel._id = PeerNetwork.dataChannelId++;
				
				// Open
				dataChannel.onopen = e => {
					PeerNetwork.logConnectionType(user);
					user.dataChannels.splice(0,0,dataChannel);
					core.log("#peer <"+user.id+"> Data Channel Open (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
				}
				
				// Close, Error
				dataChannel.onclosing = e => {
					user.dataChannels.remove(dataChannel);
					core.log("#peer <"+user.id+"> Data Channel Closing (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
				}
				dataChannel.onclose = e => {
					user.dataChannels.remove(dataChannel);
					core.log("#peer <"+user.id+"> Data Channel Close (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
				}
				dataChannel.onerror = e => {
					core.log("#peer <"+user.id+"> Data Channel Error "+e.error.message+" (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
				}
				
				// Message
				dataChannel.onmessage = e => {
					// core.log("#data <"+user.id+"> received " + e.data.byteLength + " bytes on channel "+ dataChannel._id);
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
	
	private js int send: InternalUser user, Buffer buffer
		if(user.dataChannels.length == 0) {
			core.log("#data <"+user.id+"> Trying to send without dataChannels")
		}
		try {
			let data = buffer.toByteArray()
			let channel = user.dataChannels[0]
			channel.send(data)
			// core.log("#data <"+user.id+"> send " + data.byteLength + " bytes on channel "+ channel._id)
			return data.byteLength
		} 
		catch(e) {
			core.log("#peer <"+user.id+"> send failed " + e.message)
			console.error(e)
			core.log(e.stack)
			return 0
		}
	
	private onMessage: InternalUser user, Buffer buffer
		user.lastIncomingMessageTime = PlainDate.realTime
		NetworkMessageType type = cast buffer.readInt8
		switch type
			Tick	onTick user, buffer
			Ping	onPing user, buffer
			Pong	onPong user, buffer
			
	sendInputs: int inputFrame
		let inputs = input.localUser.inputs
		for input.internalUsers as receiver if receiver
			let length = inputs.writePos - receiver.receivedMyInputsUpToPos
			
			if not receiver.local and receiver.dataChannels
				sendBuffer.reset
				sendBuffer.writeInt8 cast NetworkMessageType.Tick
				sendBuffer.writeInt inputFrame                       // I send inputs up to and including this frame
				sendBuffer.writeInt receiver.receivedMyInputsUpToPos // I send inputs starting from the last pos you received
				sendBuffer.writeInt receiver.inputs.writePos         // I received your inputs up to this pos
				sendBuffer.writeBuffer inputs, receiver.receivedMyInputsUpToPos, length
				sendBuffer.writeInt core.lastChecksumFrame                           // The last certain frame with inputs from everybody
				sendBuffer.writeFloat64 core.checksums[core.lastChecksumFrame] || 0  // The checksum of the last certain frame
				
				core.tickMessageSize = send ., sendBuffer
				
				if length > 0 then core.log "[{inputFrame}] <{receiver.id}> #send -->> The other <{receiver.id}> received up to {receiver.receivedMyInputsUpToPos} and I'm <{input.localUser.id}> sending {length} bytes, from {receiver.receivedMyInputsUpToPos} to {inputs.writePos}"
		
	private onTick: InternalUser sender, Buffer buffer
		let inputFrame = buffer.readInt                     // The sender sent inputs up to and including this frame
		
		if inputFrame >= sender.inputFrame
			let prevInputFrame = sender.inputFrame         
			let incomingInputsWritePos = buffer.readInt     // The sender sent inputs starting from the last pos I received
			sender.receivedMyInputsUpToPos = buffer.readInt // The sender received my inputs up to this pos
			
			sender.inputFrame = inputFrame
			let length = buffer.readBuffer sender.inputs, incomingInputsWritePos
			
			if length > 0 then core.log "[{inputFrame}] <{sender.id}> #receive <<-- I <{input.localUser.id}> received {length} bytes, up to {sender.inputs.writePos} from {sender.id}"
			
			// Checksum
			int checksumFor = buffer.readInt
			float checksum = buffer.readFloat64
			
			let myChecksum = core.checksums[checksumFor]
			if !myChecksum                           core.checksums[checksumFor] = checksum; else
			if !myChecksum.isApproximately(checksum) core.onWrongChecksum checksumFor, mine: myChecksum theirs:checksum
				
			// Store incoming inputs
			if length then core.storeInputsToDB sender
		
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
			// Candidates routinely arrive before the peer connection exists or before setRemoteDescription
			// has completed; adding them now would fail, so queue them until the remote description is set
			if(!user.peerConnection || !user.peerConnection.remoteDescription) {
				user.pendingIceCandidates.push(JSON.parse(candidate));
				core.log("#peer <"+user.id+"> Queued Early Ice Candidate ("+user.pendingIceCandidates.length+" pending)");
				return;
			}
			await user.peerConnection.addIceCandidate(new RTCIceCandidate(JSON.parse(candidate)));
		}
		catch(e) {
			core.log("#peer <"+user.id+"> onIce failed " + e.message)
			core.log(e.stack);
		}

	// Add the ICE candidates that arrived before the remote description was set
	// Called right after setRemoteDescription resolved in onReceivedOffer and onReceivedAnswer
	private js void addPendingIceCandidates: InternalUser user
		let pendingIceCandidates = user.pendingIceCandidates;
		if(pendingIceCandidates.length == 0) return;
		user.pendingIceCandidates = [];
		for(let candidate of pendingIceCandidates) {
			try {
				core.log("#peer <"+user.id+"> Adding Queued Ice Candidate");
				await user.peerConnection.addIceCandidate(new RTCIceCandidate(candidate));
			}
			catch(e) {
				core.log("#peer <"+user.id+"> addPendingIceCandidates failed " + e.message)
				core.log(e.stack);
			}
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
		for input.internalUsers as user
			if user and user.dataChannels
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
			statistics.add "pingPongTime" userIndex:player.playerIndex, color:player.playerColor, value:pingPongTime, set:3, isPerFrame:false
				
	// --------------------------------------------- Checksum ---------------------------------------------
	
	sendChecksum: int checksumFor, float checksum
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Checksum
		sendBuffer.writeInt checksumFor
		sendBuffer.writeFloat64 checksum
		
		for input.internalUsers as user
			if user and user.dataChannels
				send ., sendBuffer

	onChecksum: InternalUser user, Buffer buffer
		int checksumFor = buffer.readInt
		float checksum = buffer.readFloat64
		if core.verbose then core.log "<{user.id}> #{checksumFor} {checksum}"
		
		let myChecksum = core.checksums[checksumFor]
		if !myChecksum
			core.checksums[checksumFor] = checksum
		else
		if !myChecksum.isApproximately(checksum)
			core.onWrongChecksum checksumFor, mine:myChecksum theirs:checksum
				
	// --------------------------------------------- Media Setup ---------------------------------------------
	
	MediaDevices devices = {}
	string videoInputId, audioInputId, audioOutputId	
	
	// Set up the local camera and microphone
	// This never throws: a player without a working camera or microphone must still be able to join,
	// the join continues with degraded media and PeerNetwork.error tells the player what is missing
	js async void setupLocalMedia: bool enableVideo, bool enableAudio
		core.log("setupLocalMedia: start")
		PeerNetwork.enableVideo = enableVideo
		PeerNetwork.enableAudio = enableAudio
		if(!enableVideo && !enableAudio) return
		PeerNetwork.mediaSetupPromise = PeerNetwork.requestLocalMedia()
		await PeerNetwork.mediaSetupPromise

	// Peer connections are only created after the media setup settled, so the local tracks
	// can be added when the connection is created (the media setup never rejects)
	private js async void whenLocalMediaSettled
		if(PeerNetwork.mediaSetupPromise) await PeerNetwork.mediaSetupPromise;

	// Request the local camera and microphone with a fallback ladder:
	// video+audio -> video only -> audio only -> no media at all
	// Each degradation sets PeerNetwork.error so the lobby can show the player what is missing
	// Returns true when a local media stream was created
	private js async bool requestLocalMedia
		let requestVideo = PeerNetwork.enableVideo;
		let requestAudio = PeerNetwork.enableAudio;
		let videoConstraints = {width: 500, height: 375};

		let attempts = [];
		if(requestVideo && requestAudio) attempts.push({video: videoConstraints, audio: true});
		if(requestVideo)                 attempts.push({video: videoConstraints, audio: false});
		if(requestAudio)                 attempts.push({video: false, audio: true});
		if(attempts.length == 0) return false;

		// Try each step of the fallback ladder until one succeeds
		let mediaStream = null;
		let lastError = null;
		for(let constraints of attempts) {
			try {
				mediaStream = await navigator.mediaDevices.getUserMedia(constraints);
				break;
			} catch(error) {
				lastError = error;
				core.log("#camera getUserMedia failed (video:"+!!constraints.video+" audio:"+!!constraints.audio+"): "+error.name+" "+error.message);
			}
		}

		if(!mediaStream) {
			// No media at all -> the player still joins, just without camera and microphone
			if(lastError && lastError.name == "NotAllowedError") {
				PeerNetwork.error = "To play with friends over a video call, you need to allow access to your webcam. Joining without video - allow access and press Retry.";
			} else {
				PeerNetwork.error = "Can't access your camera or microphone - joining without video. Make sure it's not used by another application and press Retry.";
			}
			core.log("#camera Local media setup finished without media, joining without camera and microphone");
			return false;
		}

		let gotVideo = mediaStream.getVideoTracks().length > 0;
		let gotAudio = mediaStream.getAudioTracks().length > 0;
		if(requestVideo && !gotVideo) {
			PeerNetwork.error = "Can't access your camera - joining without video. Make sure it's not used by another application and press Retry.";
		} else if(requestAudio && !gotAudio) {
			PeerNetwork.error = "Can't access your microphone - joining without sound. Press Retry to try again.";
		} else {
			PeerNetwork.error = "";
		}

		// Stop the previous local tracks (after a retry) before replacing the stream
		if(input.localUser.mediaStream) {
			for(let track of input.localUser.mediaStream.getTracks()) track.stop();
		}
		input.localUser.mediaStream = mediaStream;

		// Attach the stream to the local video elements (they already exist when the media setup finished late)
		for(let videoElement of input.localUser.videoElements) {
			videoElement.srcObject = mediaStream;
		}

		// Enummerate local devices
		// This must never reject: peer connections wait for this promise and must always be created
		try {
			let devices = await navigator.mediaDevices.enumerateDevices();
			core.log("setupLocalMedia: enumerateDevices done");

			PeerNetwork.devices.videoInput.length = 0;
			PeerNetwork.devices.audioInput.length = 0;
			PeerNetwork.devices.audioOutput.length = 0;
			for(let device of devices) {
				switch(device.kind) {
					case "videoinput":  PeerNetwork.devices.videoInput.push(device); break;
					case "audioinput":  PeerNetwork.devices.audioInput.push(device); break;
					case "audiooutput": PeerNetwork.devices.audioOutput.push(device); break;
				}
			}
			PeerNetwork.videoInputId = mediaStream.getVideoTracks()[0]?.getSettings().deviceId || PeerNetwork.devices.videoInput[0]?.deviceId
			PeerNetwork.audioInputId = mediaStream.getAudioTracks()[0]?.getSettings().deviceId || PeerNetwork.devices.audioInput[0]?.deviceId
			PeerNetwork.audioOutputId = PeerNetwork.devices.audioOutput[0]?.deviceId
		} catch(error) {
			core.log("#camera enumerateDevices failed: "+error.name+" "+error.message);
		}
		statistics.cameraTime = performance.now() - statistics.startTime
		core.log("#camera Set up local camera and microphone after "+statistics.cameraTime+" ms, video:"+gotVideo+" audio:"+gotAudio)
		return true;

	// Retry the media setup after it failed or was degraded (Retry button in the lobby)
	// On success the new tracks must reach the existing peer connections: sending a new track kind
	// needs renegotiation, which only the offer side starts -> initiate recreates the connection with us
	// as the offerer and adds the new tracks when the connection is created (the same path as a reconnect)
	js async void retryMediaSetup
		if(PeerNetwork.retryingMedia) return;
		PeerNetwork.retryingMedia = true;
		try {
			core.log("#camera Media setup retry started");
			let promise = PeerNetwork.requestLocalMedia();
			PeerNetwork.mediaSetupPromise = promise;
			let gotMedia = await promise;
			if(!gotMedia) {
				core.log("#camera Media setup retry failed, still no local media");
				return;
			}

			// Recreate the existing peer connections so the new tracks are added to each of them
			for(let user of input.internalUsers) {
				if(user && !user.local && user.peerConnection) {
					core.log("#camera <"+user.id+"> Reconnected peer to attach the new local tracks");
					PeerNetwork.initiate(user);
				}
			}
		} finally {
			PeerNetwork.retryingMedia = false;
		}
	
	js void setVideoInput: string videoInputId
		                   Player player
		if(system.fastForward || input.localUser.id != player.id ||  PeerNetwork.videoInputId == videoInputId || !videoInputId) return;
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
		if(system.fastForward || input.localUser.id != player.id || PeerNetwork.audioInputId == audioInputId || !audioInputId) return;
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
		if(system.fastForward || input.localUser.id != player.id || PeerNetwork.audioOutputId == audioOutputId || !audioOutputId) return;
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
		// When a track is not available (no, denied or broken camera/microphone), add a receive-only
		// transceiver instead, so the connection still negotiates and the remote tracks still arrive
		let mediaStream = input.localUser.mediaStream;
		if(PeerNetwork.enableVideo) {
			let videoTrack = mediaStream?.getVideoTracks()[0];
			if(videoTrack) user.peerConnection.addTrack(videoTrack, mediaStream);
			else           user.peerConnection.addTransceiver("video", {direction: "recvonly"});
		}
		if(PeerNetwork.enableAudio) {
			let audioTrack = mediaStream?.getAudioTracks()[0];
			if(audioTrack) user.peerConnection.addTrack(audioTrack, mediaStream);
			else           user.peerConnection.addTransceiver("audio", {direction: "recvonly"});
		}
		
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
