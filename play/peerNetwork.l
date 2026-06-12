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

	// Restore of our own input stream after a rejoin with the same userId (see startRestore)
	bool restoring
	private float restoreDeadline
	private float nextRestoreRequestTime

	initiate: InternalUser user
		// The media setup runs in parallel with the signaling connection
		// Wait until it settled so the local tracks are added when the peer connection is created
		await whenLocalMediaSettled
		setupPeerConnection user, offerByMe:true
		setupRemoteMedia user
		
	tick
		let now = PlainDate.realTime

		// After a rejoin, restore our previous session's input stream from our peers
		// before the session starts (ServerNetwork.onPong waits until this settled)
		if restoring then tickRestore now

		for input.internalUsers as user
			if . and not .local
				// A leaving peer is gone on purpose (tab closed or navigated away) - reconnect
				// attempts would be pointless churn; any later message clears the flag (F6)
				if .leaving then continue
				// Reconnect to peer is we haven't received anything for a while
				// A hidden tab is throttled and may fall silent - tolerate a longer silence (F6)
				if now > .lastIncomingMessageTime + (.hidden ? 60000 : 10000)
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
					else
						// The answerer must not wait for a new offer forever: the offerer may be gone for good,
						// or both peers ended up as answerers after crossing offers
						// Give the offerer one full silence period to reconnect us first, then take over as the offerer
						// If our offer crosses theirs, the politeness rule in onReceivedOffer resolves it
						if ++user.silentPeriods >= 2
							retries++
							core.log "#peer Recreate peer connection (answer by me, taking over as offerer)"
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
			// A pending connection-type report belongs to the connection being replaced (F30)
			clearTimeout(user.logConnectionTypeTimer);
			user.startToConnectTime = user.lastIncomingMessageTime = Date.now();
			user.offerByMe = offerByMe;
			// A fresh connection has no answer yet and no silence history
			// While offerByMe && !receivedAnswer our offer counts as outstanding -> the impolite peer ignores crossing offers (see onReceivedOffer)
			user.receivedAnswer = false;
			user.silentPeriods = 0;
			
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
		cancelLogConnectionType user
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
			// Crossing offers (glare): when both sides offer at the same time and each receives the other's
			// offer, both would flip to answerer below and wait for an answer forever. Politeness is
			// deterministic: the peer with the lower id is impolite and ignores the crossing offer (its own
			// offer stays outstanding and the polite peer answers it); the peer with the higher id is polite
			// and answers as usual. An offer counts as outstanding from setupPeerConnection/createOffer until
			// the answer arrives (receivedAnswer). Liveness: if our outstanding offer was lost on the way,
			// the silence timeout in tick re-offers within 10s and the polite peer answers that one.
			let polite = input.localUser.id > user.id;
			if(!polite && user.offerByMe && !user.receivedAnswer && user.peerConnection) {
				core.log("#peer <"+user.id+"> Ignoring crossing offer: my own offer is outstanding and I'm the impolite peer");
				return;
			}

			// This offer starts a new connection generation (runs synchronously, before the first await):
			// - candidates queued earlier belong to the previous connection -> discard them
			//   (signaling is ordered, so candidates for this offer can only arrive after the offer itself)
			// - candidates arriving from now on belong to this offer -> queue them until the remote description is set
			user.pendingIceCandidates.length = 0;
			user.settingRemoteDescription = true;

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
			user.settingRemoteDescription = false;
			await PeerNetwork.addPendingIceCandidates(user);
			let answer = await peerConnection.createAnswer();
			await peerConnection.setLocalDescription(answer);
			ServerNetwork.sendSignal(user.id, "answer", peerConnection.localDescription.sdp);
		}
		catch(e) {
			user.settingRemoteDescription = false;
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
		user.silentPeriods = 0
		user.leaving = false // Any message proves the user is still there (e.g. restored from the back/forward cache)
		NetworkMessageType type = cast buffer.readInt8
		switch type
			Tick	onTick user, buffer
			Ping	onPing user, buffer
			Pong	onPong user, buffer
			RequestHistory	onRequestHistory user, buffer
			History	onHistory user, buffer
			Status	onStatus user, buffer
			Leaving	onLeaving user, buffer
			
	// A single Tick must stay well below the smallest cross-browser SCTP message size limit:
	// a peer that is gone for minutes (or a fresh peer acking from 0 after a long game) would
	// otherwise make the cumulative delta exceed it, channel.send would throw on every frame and
	// the transfer would never succeed - both sides stall (F12). Larger backlogs are sent as one
	// chunk per Tick; the ack-driven cumulative resend delivers the rest over the following
	// frames (~16 KB at 30 Hz = 480 KB/s)
	const int maxTickBytes = 16384

	sendInputs: int inputFrame
		let inputs = input.localUser.inputs
		recordClaimSample inputs.writePos, inputFrame
		for input.internalUsers as receiver if receiver
			if not receiver.local and receiver.dataChannels
				// Don't pile onto a congested channel - the cumulative resend covers these bytes later
				if bufferedAmount(receiver) > 1048576 then continue

				let startPos = receiver.receivedMyInputsUpToPos
				int length = inputs.writePos - startPos
				int claim = inputFrame
				if length > maxTickBytes
					if ++receiver.stalledChunkSends <= 90
						// The receiver is far behind: send one chunk. The claim may only cover frames
						// whose bytes are fully inside what the receiver will then have (invariant 3),
						// so it comes from the position->frame samples, not the live inputFrame
						length = maxTickBytes
						claim = claimForPos startPos + length
					else
						// No ack progress for ~3s of chunked sends: the receiver's stored claim may
						// predate our samples (it held our stream from before our restore). Fall back
						// to one uncapped send - exactly the pre-chunking behavior, which works
						// whenever the whole delta fits into a message at all
						receiver.stalledChunkSends = 0
				else
					receiver.stalledChunkSends = 0

				sendBuffer.reset
				sendBuffer.writeInt8 cast NetworkMessageType.Tick
				sendBuffer.writeInt input.localUser.epoch            // The epoch of my stream, changes when I restart with a fresh session
				sendBuffer.writeInt input.localUser.epochStartPos    // My bytes below this pos are history restored from before this epoch
				sendBuffer.writeInt claim                            // I send inputs up to and including this frame
				sendBuffer.writeInt startPos                         // I send inputs starting from the last pos you received
				sendBuffer.writeInt receiver.inputs.writePos         // I received your inputs up to this pos
				sendBuffer.writeBuffer inputs, startPos, length
				sendBuffer.writeInt core.lastChecksumFrame                      // The last certain frame with inputs from everybody
				sendBuffer.writeFloat64 core.getChecksum core.lastChecksumFrame // The checksum of the last certain frame

				core.tickMessageSize = send ., sendBuffer

				if core.verbose and length > 0 then core.log "[{claim}] <{receiver.id}> #send -->> The other <{receiver.id}> received up to {startPos} and I'm <{input.localUser.id}> sending {length} bytes, from {startPos} to {startPos + length} of {inputs.writePos}"

	// --------------------------------------------- Claims for chunked Ticks ---------------------------------------------

	// Sparse samples of "bytes [0, claimSamplePositions[i]) of my stream contain all my inputs up
	// to and including frame claimSampleFrames[i]" - exactly what a claim promises, and true at
	// every send because the claim core.onFrame passes in only covers bytes already written (F19).
	// A chunked Tick looks up the newest sample fully covered by its bytes, so its claim can never
	// cover bytes the receiver doesn't have; a lower claim is always safe, it only delays certainty.
	// Sampled every ~2 KB or ~30 frames - the granularity costs at most about a second of certainty
	// during a catch-up. Never pruned: it grows orders of magnitude slower than the input stream
	// itself, which is append-only until state transfer exists (F17.3)
	private int[] claimSamplePositions
	private int[] claimSampleFrames

	private recordClaimSample: int writePos, int inputFrame
		let count = claimSamplePositions.length
		if count > 0 and claimSamplePositions[count-1] == writePos
			// Same bytes, newer claim: keep the newest claim for this position
			claimSampleFrames[count-1] = inputFrame
		else
		if count == 0 or writePos >= claimSamplePositions[count-1] + 2048 or inputFrame >= claimSampleFrames[count-1] + 30
			claimSamplePositions.add writePos
			claimSampleFrames.add inputFrame

	// The newest sampled claim whose bytes lie fully below pos; -1 when no sample qualifies
	// (start of a session, or restored history from before this session - restored bytes were
	// never sampled). Receivers start at inputFrame -1, so -1 is accepted by every fresh peer
	private int claimForPos: int pos
		int low = 0
		int high = claimSamplePositions.length - 1
		int result = -1
		while low <= high
			int mid = math.floor((low + high) / 2)
			if claimSamplePositions[mid] <= pos
				result = claimSampleFrames[mid]
				low = mid + 1
			else
				high = mid - 1
		return result

	private js int bufferedAmount: InternalUser user
		return user.dataChannels[0].bufferedAmount || 0
		
	private onTick: InternalUser sender, Buffer buffer
		let epoch = buffer.readInt                          // The epoch of the sender's stream, changes when the sender restarts with a fresh session
		let epochStartPos = buffer.readInt                  // The sender's bytes below this pos are history restored from before this epoch
		let inputFrame = buffer.readInt                     // The sender sent inputs up to and including this frame

		// A new epoch means the sender restarted and lost its in-memory stream (page refresh with
		// the same userId). Its stream only continues the one we stored if it restored at least
		// everything we hold - otherwise its writes would retroactively change history that our
		// snapshots and read positions reference, so we offer it its own history back instead
		if epoch != sender.epoch
			if sender.epoch != 0 and epochStartPos < sender.inputs.writePos
				sendHistory sender // Rate-limited, see onHistory on the receiving side
				return
			core.log "[{inputFrame}] <{sender.id}> #epoch Accepting new stream epoch {epoch} (was {sender.epoch}), continued from {epochStartPos}, we stored {sender.inputs.writePos}"
			sender.epoch = epoch

		// Discard late or out-of-order messages: a newer message always contains the older message's bytes
		if inputFrame < sender.inputFrame then return

		let incomingInputsWritePos = buffer.readInt     // The sender sent inputs starting from the last pos I received
		let ackPos = buffer.readInt                     // The sender received my inputs up to this pos

		// Peek the length to validate the write before it happens (readBuffer reads the length itself)
		let savedReadPos = buffer.readPos
		let length = buffer.readInt
		buffer.readPos = savedReadPos

		// Only contiguous appends are allowed: the stream is append-only within an epoch and snapshots
		// reference positions in it, so a write must neither leave a gap nor shrink what we already have
		// (dropped bytes are repaired by the cumulative resend of the next Tick)
		if incomingInputsWritePos > sender.inputs.writePos
			core.log "[{inputFrame}] <{sender.id}> #receive Dropped: bytes start at {incomingInputsWritePos} but we only have {sender.inputs.writePos}"
			return
		if incomingInputsWritePos + length < sender.inputs.writePos
			core.log "[{inputFrame}] <{sender.id}> #receive Dropped: bytes end at {incomingInputsWritePos + length}, shrinking below our {sender.inputs.writePos}"
			return

		sender.inputFrame = inputFrame
		// Ack progress: the receiver is consuming our chunked catch-up (see sendInputs)
		if ackPos > sender.receivedMyInputsUpToPos then sender.stalledChunkSends = 0
		sender.receivedMyInputsUpToPos = ackPos
		buffer.readBuffer sender.inputs, incomingInputsWritePos

		if core.verbose and length > 0 then core.log "[{inputFrame}] <{sender.id}> #receive <<-- I <{input.localUser.id}> received {length} bytes, up to {sender.inputs.writePos} from {sender.id}"

		// Checksum
		int checksumFor = buffer.readInt
		float checksum = buffer.readFloat64
		core.onRemoteChecksum checksumFor, checksum

		// Store incoming inputs
		if length then core.storeInputsToDB sender
		
	js void onReceivedAnswer: InternalUser user, string sdp
		core.log("#peer <"+user.id+"> Received Answer");
		try {
			// Candidates queued before this answer belong to a previous connection generation -> discard them
			// (signaling is ordered and the remote sends its answer before it gathers any candidate,
			// so candidates for this generation can only arrive after the answer itself)
			user.pendingIceCandidates.length = 0;
			user.settingRemoteDescription = true;
			await user.peerConnection.setRemoteDescription(new RTCSessionDescription({type: "answer", sdp}));
			user.settingRemoteDescription = false;
			user.receivedAnswer = true
			await PeerNetwork.addPendingIceCandidates(user);
		}
		catch(e) {
			user.settingRemoteDescription = false;
			core.log("#peer <"+user.id+"> onReceivedAnswer failed " + e.message)
			core.log(e.stack);
		}
			
	js void onIce: InternalUser user, string candidate
		core.log("#peer <"+user.id+"> Received Ice Candidate");
		try {
			// Candidates routinely arrive before the peer connection exists or before setRemoteDescription
			// has completed; adding them now would fail (or feed a connection that is being replaced),
			// so queue them until the remote description is set
			if(!user.peerConnection || !user.peerConnection.remoteDescription || user.settingRemoteDescription) {
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
		// One pending timer per user: a re-initiate within the 10s window would otherwise report
		// stats for a connection that no longer exists (F30); also cancelled in setupPeerConnection
		clearTimeout(user.logConnectionTypeTimer);
		let peerConnection = user.peerConnection;
		user.logConnectionTypeTimer = setTimeout(async () => {
			try {
				if(user.peerConnection != peerConnection) return; // The connection was replaced in the meantime
				let stats = await peerConnection.getStats()
				let candidatePairs = [...stats.values()].filter(s => s.type == "candidate-pair" && s.state == "succeeded")
				let candidatePair = candidatePairs.find(a => a.selected) || candidatePairs[0]
				if(candidatePair) {
					let candidate = stats.get(candidatePair.localCandidateId);
					let ip = candidate.ip || candidate.address
					user.connectionType = candidate.candidateType + " " + ip
					core.log("#connection <"+user.id+"> connection "+user.connectionType)
				} else {
					core.log("#connection <"+user.id+"> connection: no succeeded candidate pair for "+user.id);
					if(core.verbose) {
						try  { core.log(JSON.stringify([...stats.values()])) }
						catch{ }
					}
				}
			} catch(e) {
				core.log("#connection <"+user.id+"> logConnectionType failed: " + e.message)
			}
		}, 10000)

	private js void cancelLogConnectionType: InternalUser user
		clearTimeout(user.logConnectionTypeTimer)
		
	// --------------------------------------------- Restoring our stream after a rejoin ---------------------------------------------

	// When we rejoin a room with the same userId after a page refresh, our in-memory input stream
	// is gone, but every peer still stores a copy of it. We ask all peers for that copy and resume
	// the longest one we receive, so our outgoing Ticks continue the old stream instead of
	// overwriting it from position 0 on every peer (which would corrupt their snapshots)

	// A random non-zero id for this session's input stream, assigned in core.join (0 means unknown)
	js int generateEpoch
		return Math.floor(Math.random() * 0x3fffffff) + 1

	// Called from ServerNetwork.onJoinResponse when we joined with a preassigned userId and other
	// users exist in the room. While restoring is set, ServerNetwork.onPong delays startConnected,
	// so we neither append new inputs to our stream nor send Ticks until the restore settled
	startRestore
		restoring = true
		restoreDeadline = PlainDate.realTime + 5000
		nextRestoreRequestTime = 0
		core.log "#restore Joined with a preassigned userId -> requesting our previous session's input stream from all peers"

	private tickRestore: float now
		// Request our history from every peer that hasn't answered yet (repeated every second:
		// the data channel is unreliable and the channels open at different times)
		if now >= nextRestoreRequestTime
			nextRestoreRequestTime = now + 1000
			for input.internalUsers as user
				if . and not .local and .dataChannels and .historyTotalLength == -1
					core.log "#restore <{.id}> Requesting our input history"
					sendBuffer.reset
					sendBuffer.writeInt8 cast NetworkMessageType.RequestHistory
					send ., sendBuffer

		// Finished when every peer answered (we keep the longest history received), or when the
		// deadline passed (a peer is unreachable or its reply was too large -> start fresh; our
		// new epoch keeps peers that still hold more of our old stream from being corrupted)
		bool allAnswered = true
		for input.internalUsers as user
			if . and not .local and .historyTotalLength == -1 then allAnswered = false

		if allAnswered
			finishRestore "all peers answered"
		else
		if now > restoreDeadline
			finishRestore "timeout"

	private finishRestore: string reason
		restoring = false
		input.localUser.epochStartPos = input.localUser.inputs.writePos
		core.log "#restore Restore finished ({reason}): our own new inputs continue at {input.localUser.epochStartPos}"

	// A peer rejoined with a fresh session and asks for its own input stream as we stored it.
	// It also has none of our inputs any more -> resend our own stream from position 0
	// (the explicit position in every Tick makes the resend idempotent)
	private onRequestHistory: InternalUser user, Buffer buffer
		core.log "#restore <{user.id}> Received history request -> resend our inputs from 0 and reply with {user.inputs.writePos} bytes of its history"
		user.receivedMyInputsUpToPos = 0
		user.lastHistorySentTime = 0 // Answer a fresh request immediately
		sendHistory user

	// Send this user its own input stream as we stored it (the answer to RequestHistory, also
	// pushed from onTick when the user announces an epoch we can't accept). Rate-limited because
	// onTick can trigger it for every Tick of a rejoined sender
	private sendHistory: InternalUser user
		let now = PlainDate.realTime
		if now < user.lastHistorySentTime + 1000 then return
		user.lastHistorySentTime = now

		let length = user.inputs.writePos
		// Sent as a single message: longer streams exceed the data channel message size limit
		// -> the rejoiner times out and starts fresh (chunked transfer comes with state transfer)
		if length > 262144
			core.log "#restore <{user.id}> Can't send its history of {length} bytes, too large for a single message"
			return

		core.log "#restore <{user.id}> Sending {length} bytes of its own input history"
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.History
		sendBuffer.writeInt length // The total length of the stored stream
		sendBuffer.writeInt 0      // The position where this part starts (always 0 until chunking exists)
		sendBuffer.writeBuffer user.inputs, 0, length
		send user, sendBuffer

	// Our own previous-session input stream as this peer stored it.
	// Bytes are append-only: we may only adopt a longer history while our stream is still exactly
	// the restored prefix - once we appended our own new inputs, nothing below writePos may change
	// any more (our snapshots and the other peers already reference it)
	private onHistory: InternalUser user, Buffer buffer
		let totalLength = buffer.readInt // The total length of our stream as this peer stored it
		let startPos = buffer.readInt    // The position where this part starts

		// Peek the length to validate the write before it happens (readBuffer reads the length itself)
		let savedReadPos = buffer.readPos
		let length = buffer.readInt
		buffer.readPos = savedReadPos

		user.historyTotalLength = math.max user.historyTotalLength, totalLength
		let localUser = input.localUser
		core.log "#restore <{user.id}> Received {length} bytes of our own history at {startPos} of {totalLength}, we have {localUser.inputs.writePos}"

		if startPos > localUser.inputs.writePos then return           // Would leave a gap
		if startPos + length <= localUser.inputs.writePos then return // Nothing new
		if not restoring and localUser.inputs.writePos != localUser.epochStartPos
			core.log "#restore <{user.id}> Peer stored {startPos + length} bytes of our previous stream, but we already appended new inputs after {localUser.epochStartPos} -> can't restore"
			return

		buffer.readBuffer localUser.inputs, startPos
		if not restoring then localUser.epochStartPos = localUser.inputs.writePos
		core.log "#restore <{user.id}> Restored our input stream to {localUser.inputs.writePos} bytes"

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

	// --------------------------------------------- Background tab ---------------------------------------------

	// While the tab is hidden, requestAnimationFrame stops and timers are throttled (Chrome fires
	// them once per minute after 5 minutes in background; iOS Safari suspends JS entirely), so the
	// main loop falls silent and peers would start reconnect churn - ICE restarts, re-initiates,
	// video teardown - even though the hidden player is fine (F6). Three measures:
	// - peers are told when our tab hides (Status), so they show us as away and raise our silence
	//   tolerance instead of reconnecting (see tick)
	// - a Web Worker timer (throttled far less than main-thread timers) wakes the main thread so
	//   heartbeats, acks and the signaling connection stay alive while hidden (onHeartbeat)
	// - pagehide sends a best-effort Leaving so peers stop reconnect attempts immediately instead
	//   of discovering the silence 10 seconds later
	private object heartbeatWorker

	js void setupBackgroundBehaviour
		try {
			if(PeerNetwork.heartbeatWorker) return;
			let workerUrl = URL.createObjectURL(new Blob(["setInterval(() => postMessage(0), 5000)"], {type: "application/javascript"}));
			PeerNetwork.heartbeatWorker = new Worker(workerUrl);
			PeerNetwork.heartbeatWorker.onmessage = () => PeerNetwork.onHeartbeat();

			document.addEventListener("visibilitychange", () => {
				core.log("#background Visibility changed to " + document.visibilityState);
				PeerNetwork.sendStatus(document.hidden);
			});
			// pagehide is the last reliable event before the tab closes, navigates away or enters
			// the back/forward cache; pageshow with persisted is the return from that cache
			window.addEventListener("pagehide", () => PeerNetwork.sendLeaving());
			window.addEventListener("pageshow", e => { if(e.persisted) PeerNetwork.sendStatus(document.hidden); });
		} catch(e) {
			core.log("#background Setup failed: " + e.message);
		}

	private inline js bool isPageHidden => document.hidden

	// Called by the worker timer; only does work while the tab is hidden - in the foreground
	// core.onFrame already does all of this on every animation frame
	private onHeartbeat
		if not isPageHidden or core.mode != Connected then return
		// Keep the signaling connection alive (reconnect + ping), keep our peers' silence timers
		// fresh, and keep acking the inputs that still arrive while we are hidden (the data
		// channel's onmessage is event-driven and not throttled)
		ServerNetwork.tick
		ping
		sendInputs math.max(input.localUser.inputFrame-1, -1)

	// Tell every peer whether our tab is hidden, so they can show us as away and relax our
	// silence tolerance instead of reconnecting
	private sendStatus: bool hidden
		core.log "#background Sending status hidden:{hidden}"
		for input.internalUsers as user
			if . and not .local and .dataChannels
				sendBuffer.reset
				sendBuffer.writeInt8 cast NetworkMessageType.Status
				sendBuffer.writeBool hidden
				send ., sendBuffer

	// Best-effort goodbye when our page is closing, navigating away or entering the back/forward cache
	private sendLeaving
		core.log "#background Sending leaving"
		for input.internalUsers as user
			if . and not .local and .dataChannels
				sendBuffer.reset
				sendBuffer.writeInt8 cast NetworkMessageType.Leaving
				send ., sendBuffer

	private onStatus: InternalUser user, Buffer buffer
		user.hidden = buffer.readBool
		core.log "#background <{user.id}> is now {user.hidden ? "hidden" : "visible"}"

	private onLeaving: InternalUser user, Buffer buffer
		user.leaving = true
		core.log "#background <{user.id}> is leaving"

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
