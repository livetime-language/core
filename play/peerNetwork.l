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

	// --------------------------------------------- WebRTC Connection ---------------------------------------------

	void connect
		
	void tick

	void sendInputs: int inputFrame

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
