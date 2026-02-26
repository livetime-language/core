enum NetworkMode: None, Ping, Local, Connected
internal transient immutable RoomInfo: int time, userId
enum SendInputsMode: None, Peer, Server
	
internal transient skipInit unit core
	int eventStreamVersion = 2
	int sendInterval = 1
	bool enabledMilestones = true
	int milestoneInterval = 1800
	int smoothStrength = 90
	bool smoothTouchPosition = true
	bool everybodyCanClickForEverybody = false
	bool simulateConnection = true
	bool simulateInputsForTesting = false
	bool simulateRollback = false
	bool drawPointsForTesting = false
	float sendStatisticsEvery = 2 minutes
	bool muteInvisibleUsers = false
	bool testLobby = false                // Start in the lobby for testing
	
	bool enableVideoForStaging = true
	bool enableAudioForStaging = false
		
	SendInputsMode sendInputsMode = Peer
	internal const ticksPerSecond = 30
	const frameTime = 1000/ticksPerSecond
	
	NetworkMode mode                // Whether we are in local or connected mode
	visible string errorMessage     // The error message if we caught any exceptions in the main loop
	public float startTime          // The time the room was created, syncroniced between all clients
	public float serverStartTime     // Used to calculate the same Time.now from core.frame for all users in core.step
	int frame               // Current frame, will increase by 1 at the end of every step (every targetFrameTime ms)
	internal int frames             // Total number of frames we have inputs for
	internal int frameWithNewWatches// First frame with new watches, do not send watches for frames below this
	int watchIndex
	internal bool startInLobby      // Connected sessions usually start in the lobby, local sessions start in the app
	private int joinFrame           // The frame the local user joined
	bool isPremiere
	UserAccount account
	
	// Checksum
	public float[] checksums
	public int lastChecksumFrame
	
	IndexedDBStore inputStore = {"input", indices:[{"roomId"}]}
	IndexedDBStore roomStore  = {"room"}
	
	startConnected: int frame
		if mode == Connected then return
			
		account = Platform.getLocalStorageObject("user") or {}
		if not account._id
			account._id = generateObjectId
			Platform.setLocalStorageObject("user", account)
				
		log "startConnected", joinFrame, this.frame, this.frames
		if this.frames == 0
			log "handleJoin", frame
			input.localUser.startInputFrame 0
			input.handleJoin frame, account
		
		mode = Connected
		input.localUser.collectInputs = true
		snapshotFrame = -1
		nextSnapshotFrame = 0
		checkSaveState
		log "Start", input.localUser.id, frame, startTime, serverStartTime
		
	js string generateObjectId
		const timestamp = Math.floor(new Date().getTime() / 1000).toString(16);
		const machineIdentifier = Math.floor(Math.random() * 0xFFFFFF).toString(16).padStart(6, '0');
		const processIdentifier = Math.floor(Math.random() * 0xFFFF).toString(16).padStart(4, '0');
		const counter = Math.floor(Math.random() * 0xFFFFFF).toString(16).padStart(6, '0');
		return (timestamp + machineIdentifier + processIdentifier + counter).toLowerCase();
		
	startLocal
		mode = Local
		input.internalUsers.clear
		math.setRandomSeed math.generateRandomSeed 
		stop
		
	// Clear all inputs and reset the application to the first frame
	void stop
		output.clear
		outputIndex = 0
		for input.internalUsers if .
			.inputs.reset
			.startInputFrame 0
		startTime = serverStartTime = currentTime
		frames = 0
		targetFrame = -1
		interrruptAtOutputIndex = -1
		frameWithNewWatches = 0
		watchIndex = 0
		startInLobby = false
		errorMessage = ""
		audio.stop
		isPremiere = true
		startTime = serverStartTime = currentTime
		reset
		animationFrame
		
	// Start recording (from the beginning or the middle of an existing event stream)
	// We remove all future inputs
	// This is called when the user clicks first clicks inside the app
	record
		frames = frameWithNewWatches = frame
		for input.internalUsers if .
			.inputs.writePos = .inputs.readPos
			.startInputFrame frame
		
	// Keep inputs, call init functions, create the local players, reset read positions and start app
	// This is called on startup, after every code change and when going backwards in the timeline
	reset
		outputIndex = 0
		players.clear
		input.playersById.clear
		input.host = null
		input.playersToRemove.clear
		errorMessage = ""
		HTMLElement.clear
		math.randomValueIndex = 0
		frame = 0
		watchIndex = 0
		input.isCertain = true
		lobby.inLobby = startInLobby
		Time.now = serverStartTime
		snapshotFrame = -1
		checksums.clear
		lastChecksumFrame = -1
		audio.stop
		initAll
		
		if !startInLobby or testLobby
			// When the developer changed Platform.userCount, add or remove internal users accordingly
			for Platform.userCount
				if not input.internalUsers[.]
					input.internalUsers[.] = {id:i, local:true, collectInputs:true}
			if input.internalUsers.length > Platform.userCount
				input.internalUsers.removeRange Platform.userCount..input.internalUsers.length
			
			// We always recreating players, because developers might have added fields to Player or Touch
			// By the time we call startApp, all players need to exist
			for input.internalUsers as internalUser
				Player user = {id:.id, index:i}
				input.playersById[.id] = user
				players.add user
				
			// Set local user
			let localUserId = input.localUser?.id < input.internalUsers.length ? input.localUser.id : 0
			input.localUser = input.internalUsers[localUserId]
			input.localPlayer = input.playersById[localUserId]
			input.updatePlayers
			account = {}
			
		// Reset read pos to replay inputs from the beginning
		for input.internalUsers if .
			.inputs.readPos = 0
			
		if !startInLobby and not testLobby
			graphics.startFrame
			startApp
		if simulateRollback then checkSaveState
		
	// Keep event stream running, recreate players, call init function and start app
	// Called manually with the global "restart" function	
	restart
		if not input.isCertain then return
		let hostPlayerId = input.host ? input.host.id : -1
		Framework.clear includingLockedObjects:true
		Platform.fastForward = false
		let prevLanguage = Loca.language
		initAll
		Loca.setLanguage prevLanguage
		Player[] newPlayers
		for input.players
			Player user = .cloneBaseData
			input.playersById[.id] = user
			newPlayers.add user
		input.players = newPlayers
		let localUserId = input.localUser?.id < input.internalUsers.length ? input.localUser.id : 0
		input.localUser = input.internalUsers[localUserId]
		input.localPlayer = input.playersById[localUserId]
		input.host = hostPlayerId != -1 ? input.playersById[hostPlayerId] : null
		input.updatePlayers
		startApp
	
	// Steps forward when going to a frame in the future
	// or replays from the beginning when going to a frame in the past
	// This is called after every code change with replayFromStart = true 
	// to replay all inputs with the new code from the beginning,
	// and when stepping through the timeline with replayFromStart = false
	// to only replay from the beginning when going to a frame in the past
	goToFrame: int targetFrame, int interrruptAtOutputIndex = -1, codeChanged = false
		let previouylyInterrupted = this.interrruptAtOutputIndex != -1
		this.targetFrame = targetFrame
		this.interrruptAtOutputIndex = interrruptAtOutputIndex
		this.reachedOutputId = false
		isPremiere = false
		try
			try
				if codeChanged
					frameWithNewWatches = 0
					reset
				else
				if targetFrame < frame or previouylyInterrupted
					let milestoneIndex = enabledMilestones ? math.floor(targetFrame/milestoneInterval) - 1 : -1
					if 0 <= milestoneIndex < milestones.length
						let milestone = milestones[milestoneIndex]
						frame = (milestoneIndex+1) * milestoneInterval
						rewind milestone
					else
						reset
					
				while frame < targetFrame
					step fastForward:true, draw:false
				step fastForward:false, draw:true
			catch
				onError .

			// If we interrupted in the middle of a tick, we draw the current state without events
			if frame <= targetFrame
				Platform.fastForward = false
				for input.internalUsers as user
					user?.clearEvent
				tick draw:true
		catch
			onError .
		finally
			adjustStartTime
			isPremiere = true
			let output = codeChanged ? core.output : null
			Platform.sendToEditor {type:"finished", frame:core.frame-1, frames:core.frames, playMode:Platform.playMode, output}

	runTest: string testFunctionName, int id = -1, int targetFrame = -1, int interrruptAtOutputIndex = -1
		let parts = testFunctionName.split(".")
		if parts.length < 2 then parts = ["tests", testFunctionName or "main"]
		dynamic testFunction = globals[parts[0]][parts[1]]
		if not testFunction then return
		isPremiere = false
		runningTest = true
		this.targetFrame = targetFrame
		this.interrruptAtOutputIndex = interrruptAtOutputIndex
		this.reachedOutputId = false
		Platform.fastForward = false
		try
			try
				reset
				testFunction()
			catch
				onError .

			// We draw the current state without events
			// We don't draw in the test function since we don't know when we are on the final frame
			Platform.fastForward = false
			for input.internalUsers as user
				user?.clearEvent
			tick draw:true
		catch
			core.onError .
		finally		
			isPremiere = true
			runningTest = false
			Platform.sendToEditor({type:"finishedTest", id, testFunction, output, frame, frames})
			// Platform.sendToEditor({type:"finishedTest", id, testFunction, output, onScreen:graphics.getDescriptionOfItemsOnScreen, testRunMode})

	bool runningTest
	string[] output
	int outputIndex = -1
	int interrruptAtOutputIndex = -1
	int targetFrame = -1
	bool reachedOutputId = false

	addToOutput: string value
		value += "|{outputIndex}|{frame}"
		output[outputIndex] = value
		if Platform.playMode == Record then Platform.sendStringToEditor value
		if interrruptAtOutputIndex != -1
			// Throw an exception when we reach interrruptAtOutputIndex
			if outputIndex == interrruptAtOutputIndex and not reachedOutputId
				reachedOutputId = true
				throw {message: "reached end of replay"}
		outputIndex++


	// Smooth out animations by only executing code when we received inputs from everybody	
	smooth: Player player
		    void() do
		let user = input.internalUsers[player.id]
		if user and (user.local or frame <= user.smoothFrame) then do
			
	float lastPingTime

	// animationFrame --> step --> tick

	// animationFrame  Send tick message, replay state, and call step
	// step            Save state, parse inputs, step physics, process tick, and calculate checksum
	// tick            Clear screen, process application tick, and draw all graphics
		
	// Send tick message, replay state, call step, and logging
	// This is called by the requestAnimationFrame callback.
	// We ensure that step is called every frameTime milliseconds.
	internal animationFrame
		now = currentTime
		if debug.waitUntilFrame and frame >= debug.waitUntilFrame	then debug.onWaitFinished; return
		if lastAnimationFrame	then frameTimes.add now - lastAnimationFrame

		ServerNetwork.tick
		PeerNetwork.tick
		statistics.tick
		if mode == None or mode == Ping then return
			
		let targetFrame = math.floor((now - startTime)/frameTime)+1
		if verbose then core.log "----- #{frame} -> #{targetFrame} -----"
		
		if mode == Local && targetFrame > frame + ticksPerSecond*2
			// After a long pause in local mode, we do not want to process all missed frames, so we adjust the start time
			let prevTargetFrame = targetFrame
			targetFrame = frame
			startTime = math.round(now - targetFrame*frameTime)
			log "Paused {prevTargetFrame-frame} frames, adjusting startTime. prevTargetTime:{prevTargetFrame} frame:{frame} targetFrame:{math.floor((now - startTime)/frameTime)}"
		
		if frame < targetFrame
			// Create artificial inputs to test the smoothness
			if simulateInputsForTesting and input.localUser and input.localUser.collectInputs
				for frame to targetFrame
					input.handleKeyEvent KeyDown, cast Key.F24, ""
				
			animationStartFrame = frame
			
			try
				sendInputs targetFrame-1
				// Replay all frames from the first uncertain frame until the current frame
				// when we received all inputs for frames that we were uncertain about before
				checkRewindAndReplayState
			
			catch 
				onError error
					
			// Ensure that step is called every frameTime milliseconds
			try
				while frame < targetFrame
					if Platform.playMode == Record
						for input.internalUsers as user
							if user?.local then user.startInputFrame frame+1
					step fastForward:false, draw:frame == targetFrame-1
					if not Platform.isDebug then collectStatistics
			catch
				onError .
				
				lastNetworkFrame = now
				
			// Store local inputs
			if IndexedDB.isReady
				core.storeInputsToDB input.localUser
				core.storeRoomToDB
				
		lastAnimationFrame = now
		if Platform.playMode == Play and frame >= frames then Platform.record()
			
		// Ping
		if currentTime - lastPingTime > 1000
			lastPingTime = currentTime
			PeerNetwork.ping
			
	private int animationStartFrame // The frame at the beginning of animationFrame, used to calculate iteration
	private float now               // The time at the beginning of animationFrame
	
	private float prevLogTime
	
	// Logs
	js void log: logstring text
		if(Time.now > core.prevLog + 3000) core.logs += "\n"
		core.prevLog = Time.now
		
		let str = new Date().toString() + " " + text
		statistics.systemLogs.push(str)
		debug.logs.push(str)
		console.log(str)
		core.logs += str + "\n"
		
		// !!! Temporary for debugging windows that are crashed or don't respond
		// if(Platform.isStaging) {
		// 	try {
		// 		localStorage.setItem(`logs-${core.roomId}-${input.localUser ? input.localUser.id : "?"}`, core.logs)
		// 	} catch(e) {
		// 		console.error(e)
		// 	}
		// }
			
	internal string logs
	internal bool hasErrors
	private float lastNetworkFrame, lastAnimationFrame, drawTime, tickTime, restoreTime, replayTime, saveTime
	internal int displayItems
	int tickMessageSize
	bool verbose = false
	int replayFrom = -1
	
	RollingList drawTimes, tickTimes, frameTimes = {length:150}
	
	collectStatistics
		// Players
		if mode == Connected and players.length > 1 and frame > joinFrame + 120
			for players
				let internalUser = input.internalUsers[.id]
				if not internalUser.local
					internalUser.collectStatistics frame
					statistics.add "input", userIndex:.index, value:frame - internalUser.inputFrame, .color, set:0
					statistics.add "smooth", userIndex:.index, value:frame - internalUser.smoothFrame, .color, set:1
					statistics.add "delta", userIndex:.index, value:internalUser.certainFrame - internalUser.prevCertainFrame, .color, set:2

			if replayFrom != -1 then statistics.add "replay", value:frame - replayFrom, color:Gray
		else
		if mode == Local and simulateRollback
			input.internalUsers.each.simulateRollback frame
			
		// Memory
		statistics.add "memory", value:Platform.usedMemory, color:Yellow set:4
		statistics.add "snapshotSize", value:snapshot.writePos, color:Red set:5
		statistics.add "inputs", value:input.localUser?.inputs.writePos, color:Blue set:6
		
		// Times
		statistics.add "drawTime", value:drawTime, color:Blue set:7
		statistics.add "tickTime", value:tickTime, color:Red set:7
		statistics.add "restoreTime", value:restoreTime, color:Green set:7
		statistics.add "replayTime", value:replayTime, color:Yellow set:7
		statistics.add "saveTime", value:saveTime, color:White set:7
		
	connectionStates
		string result
		for input.internalUsers
			if not .local
				if result then result += ", "
				result += .connectionState
		return result

	private int lastSendFrame
	
	private sendInputs: int inputFrame
		if mode != Connected then return
		
		if frame >= lastSendFrame + sendInterval
			switch sendInputsMode
				Peer	PeerNetwork.sendInputs inputFrame
				Server	ServerNetwork.sendInputs inputFrame
			lastSendFrame = frame
	
	internal switchToPlayer: Player player
		if not player then return
		let prevPlayer = input.localPlayer
		input.localPlayer = player
		input.localUser = input.internalUsers.find . and .id == player.id
		for prevPlayer.touches
			input.handleUpdateTouchAfterSwitchingUser .id, .referencePosition
		Platform.updateTitle
			
	switchSendInterval: int sendInterval
		this.sendInterval = sendInterval
		ServerNetwork.sendSwitch sendInputsMode, sendInterval
		
	switchSendInputMode: SendInputsMode sendInputsMode
		this.sendInputsMode = sendInputsMode
		ServerNetwork.sendSwitch sendInputsMode, sendInterval

	// Save state, parse inputs, step physics, process tick, and calculate checksum
	// This is called in animationFrame and during replays. 
	// All steps except the very last of an animation frame are fast forwared, which means that nothing is drawn.
	// The frame is increment at the end of this function. This means that while processing the frame,
	// frame will point to the current frame. After processing, frame will point to the next frame.
	internal step: bool fastForward // If we are replaying after a rollback or a code change
		           bool draw        // We don't draw if we are stepping multiple frames in one animation frame
		if verbose	then core.log "#{frame}{fastForward ? " fastForward":""}{draw ? " draw":""}"
		if debug.waitUntilFrame	then print "# Frame {frame}"

		// Flags
		Platform.fastForward = fastForward
		int certainFrame = input.internalUsers.min math.min(.inputFrame, .smoothFrame) where . != null
		input.isCertain = frame <= certainFrame
		
		// Send current frame to editor	
		if Platform.isDebug and !fastForward then Platform.sendFrameAndPlayMode
		
		// Save a snapshot when we are about to start the frame after the last certain frame where we got all inputs
		checkSaveState
		
		// Update game controllers
		input.updateGameControllers
		
		// Parse inputs
		input.parseInputs(frame)
		
		// Physics
		Physics.step
		
		// Tick
		tick draw
		
		if HTMLElement.elements then HTMLElement.elements.each.tick
		input.removePlayersIfNecessary
			
						
	// Clear screen, process application tick, draw all graphics, cleanup, and advance frame
	// This is all the logic that is executed in a unit test for each frame.
	// Called in step and in tests
	internal tick: bool draw
		// if targetFrame != -1 and frame > targetFrame	return

		// Set time
		Time.now = serverStartTime + math.round(frame * frameTime)
			
		// Start frame
		Platform.isDrawing = draw
		if frame > 0 then graphics.startFrame
		audio.startFrame

		// Debug info
		if Platform.showDebugInfo
			if draw then statistics.tickGraph
			networkVisualizer.tick
			
		try
			Framework.tick
			tickTimes.add tickTime = PlainDate.measure
				if lobby.inLobby	then lobby.tick; else
				if awardScreen.active	then awardScreen.tick; else
				                             appTick

			// Advance frame
			frame++
			if frames < frame	then frames = frame
			if frame > frameWithNewWatches	then frameWithNewWatches = frame
		finally			
			// Finish frame
			if draw and not Platform.waitingForInitialData
				drawTimes.add drawTime = PlainDate.measure
					graphics.finishFrame
				if Platform.playMode != Manipulator then input.updateCursor
			audio.finishFrame

			// Cleanup
			for input.internalUsers as user
				user?.clearEvent

			// Evaluate: Set isDown directly in input.touchDown instead of in player.postprocessEvents #easier-to-reason-about #evaluate
			// players.each.postprocessEvents

			// Currently, we use tests.printWhatIsOnScreen to print the screen contents
			// instead of automatically sending it every time
			// if frame == 0 and Platform.isDebug: debug.sendCurrentlyOnScreen
							
	js void appTick() if(app.tick) app.tick();
	js string appDebugString() (app.debugString || "")
		
	private Buffer snapshot = {}
	private Buffer secondSnapshotForTesting = {}
	private int snapshotFrame = -1
	private int nextSnapshotFrame = -1
	
	private Buffer[] milestones
	
	// This is called at the begining of animationFrame before we start stepping.
	private checkRewindAndReplayState
		if (mode != Connected and !simulateRollback) or input.internalUsers.length == 1 then return
			
		if mode == Local and simulateRollback then	nextSnapshotFrame = frame - 5
		else	nextSnapshotFrame = (input.internalUsers.min math.min(.smoothFrame, .inputFrame) where . and not .local)+1
		
		if snapshotFrame != -1
			if verbose
				core.log "rewindAndReplayState", snapshotFrame, frame, nextSnapshotFrame
				for input.internalUsers
					core.log "\t<{.id}>", .smoothFrame, .inputFrame, .local
			
			let prevSnapshotFrame = snapshotFrame
			snapshotFrame = -1
			rewind snapshot
			replay prevSnapshotFrame to frame

	private rewind: Buffer snapshot
		restoreTime = PlainDate.measure
			snapshot.rewind
			Snapshot.deserialize snapshot
			
			let userCount = snapshot.readInt
			for userCount
				let userId = snapshot.readInt
				let user = input.internalUsers[userId]
					user.inputs.readPos = snapshot.readInt
		
	private replay: int from, int to
		replayTime = PlainDate.measure
			frame = replayFrom = from
			while frame < to
				step fastForward:true, draw:false			
			
	// This is called at the beginning of each step
	private checkSaveState
		if enabledMilestones and input.isCertain and frame > 0 and frame mod milestoneInterval == 0
			Buffer buffer = {}
			saveState buffer
			int milestoneIndex = math.floor(frame / milestoneInterval) - 1
			milestones[milestoneIndex] = buffer
			watch "Milestone {milestoneIndex}"
			
		if (mode == Connected or simulateRollback) and snapshotFrame == -1 and frame >= nextSnapshotFrame
			snapshotFrame = frame
			saveState snapshot
			
	string[] serializeLogs
			
	private saveState: Buffer snapshot
		snapshot.reset
		saveTime = PlainDate.measure
			Snapshot.serialize snapshot
			if Platform.logSerialize
				serializeLogs[frame mod 100] = Snapshot.serializeLog
				
		// To check if serialization works consistently, deserialize, serialize a second snapshot and compare it with the first
		if simulateRollback
			Snapshot.deserialize snapshot
			Snapshot.serialize secondSnapshotForTesting
			if(snapshot != secondSnapshotForTesting)
				onError {"Inconsistent serialization"}
												
		snapshot.writeInt input.internalUsers.count . != null
		for input.internalUsers
			if .
				snapshot.writeInt .id
				snapshot.writeInt .inputs.readPos
				
		// Checksum
		if players.length >= 2 and input.isCertain
			float myChecksum = snapshot.checksum
			float theirChecksum = checksums[frame]
			if verbose then core.log "<{input.localUser.id}*> #{frame} {myChecksum} writePos:{snapshot.writePos}"
			if !theirChecksum                             checksums[frame] = myChecksum; else
			if !theirChecksum.isApproximately(myChecksum) onWrongChecksum frame, mine: myChecksum theirs:theirChecksum
			lastChecksumFrame = frame
				
	inline js int currentTime => Date.now()
	
	js void startApp
		lobby.inLobby = false
		if(app.start) app.start()
		
	private adjustStartTime
		startTime = math.round(currentTime - frame*frameTime - (frameTime*.5))
		
	adjustStartTimeIfNeeded
		if Platform.playMode < Play then adjustStartTime
			
	Buffer snapshotBuffer = {}
	Buffer eventStreamSnapshotBuffer = {}
		
	saveEventStreamAndLogs
		if input.isCertain
			saveEventStream
			Platform.delay 1 seconds
				saveLogs
			
	internal saveLogs
		// Ensure that current eventLog is added to the table even if we haven't processed a single frame
		file.saveText "{input.localUser.id} {Platform.appName} {Date.now.isoString} v{Platform.buildVersion}.csv", logs
			
	saveEventStream
		Buffer buffer = {}
		buffer.writeInt eventStreamVersion
		
		eventStreamSnapshotBuffer.reset
		Snapshot.serialize eventStreamSnapshotBuffer
		buffer.writeBuffer eventStreamSnapshotBuffer
		
		buffer.writeInt frame-1
		buffer.writeInt frames
		buffer.writeString math.randomSeed
		buffer.writeBool startInLobby
		buffer.writeBool Platform.isStaging
		
		let userCount = input.internalUsers.count . != null
		buffer.writeInt8 userCount
		for input.internalUsers if .
			buffer.writeInt .id
			buffer.writeBool .local
			buffer.writeBuffer .inputs
			
		buffer.writeInt milestones.length
		for milestones
			buffer.writeBuffer .
			
		let date = Date.now
		file.saveBinary "{Platform.appName} {date.dayShortMonthNameYearString} {date.hourMinuteSecondString} v{Platform.buildVersion}.state", buffer
		
	const chunkSize = 256
	
	storeRoomToDB
		// TEMP: Storing event stream in database is disabled for now
		return
		roomStore.put {
			id: roomId
			frame
			frames
			eventStreamVersion
			math.randomSeed
			startInLobby
			Platform.isStaging
			localUserId: input.localUser.id
		}
	
	storeInputsToDB: InternalUser user
		// TEMP: Storing event stream in database is disabled for now
		return
		let inputs = user.inputs
		if inputs.writePos > user.storedInputsUpTo
			// let chunkStart = math.floor(inputs.writePos / chunkSize) * chunkSize
			let start = inputs.writePos - (inputs.writePos mod chunkSize)
			let id = "{roomId}-{user.id}-{start}"
			print "[{frame}] <{user.id}> Storing inputs {id} ({start} to {inputs.writePos})"
			inputStore.put {id, roomId, userId:user.id, start, inputs:inputs.subArrayBuffer(start to inputs.writePos)}
				print "[{frame}] <{user.id}> Storing inputs successful"
			else
				print "[{frame}] <{user.id}> Storing inputs failed"
			user.storedInputsUpTo = inputs.writePos
			
	openFromDB
		// TEMP: Storing event stream in database is disabled for now
		return
		await IndexedDB.start Platform.isStaging ? "up4playing-{localUserId}" : "up4playing", version:2
		
		let room = await roomStore.get roomId
		int targetFrame = room.frame - 1
		frames = room.frames
		let randomSeed = room.randomSeed
		startInLobby = room.startInLobby
		Platform.isStaging = room.isStaging
		localUserId = room.localUserId
		
		print "#database opening from db {room.toJson}"
		dynamic[] rooms = await inputStore.getAllFromIndex "roomId", roomId
		rooms.orderBy.start
		forDynamic rooms as room
			int userId = room.userId
			int start = .start
			dynamic inputs = .inputs
			let user = input.internalUsers[.userId] ?= {id:.userId, local:.userId == localUserId, collectInputs:true}
			if user.local
				input.localUser = user
			user.inputs.insertArrayBuffer .inputs
			print "#database", userId, start, inputs.toString()
		print "#database", input.localUser.inputs.toString
			
		// Replay
		for input.internalUsers if .
			.startInputFrame frames
		math.setRandomSeed randomSeed
		replay 0 to targetFrame
	
	openState
		file.openBinary
			int version = buffer.readInt
			Buffer finalSnapshot = {}
			buffer.readBuffer finalSnapshot
			input.handleSetState finalSnapshot
						
	openEventStream
		Platform.pause
		file.openBinary
			// Read event stream
			int version = buffer.readInt
			
			if version >= 2
				Buffer finalSnapshot = {}
				buffer.readBuffer finalSnapshot
			
			int targetFrame = buffer.readInt
			frames = buffer.readInt
			let randomSeed = buffer.readString
			startInLobby = buffer.readBool
			Platform.isStaging = buffer.readBool
			let userCount = buffer.readInt8
			input.internalUsers.clear
			for userCount
				InternalUser user = {
					id: buffer.readInt
					local: buffer.readBool
				}
				if user.local then input.localUser = user
				buffer.readBuffer user.inputs
				input.internalUsers[user.id] = user
			
			if version >= 2
				milestones.clear
				let milestoneCount = buffer.readInt
				for milestoneCount
					Buffer milestone = {}
					buffer.readBuffer milestone
					milestones.add milestone
				
			// Replay
			for input.internalUsers if .
				.collectInputs = true
				if Platform.isDebug then .local = true
				.startInputFrame frames
			math.setRandomSeed randomSeed
			
			if Platform.isDebug then Platform.sendClearTimeline
			frame = int.maxValue
			goToFrame targetFrame
		
	string roomString
	int roomId
	string gameId
	int localUserId
	
	join: string gameId, string roomString, int userId
		statistics.scheduleSendIn 30 seconds
		isPremiere = true
		initAll
		log "{Platform.url}"
		log "{Date.realtime.dayMonthNameYearString} {Date.realtime.hourMinuteSecondString} v{Platform.buildVersion}"
		log "{Platform.userAgent}"
		startInLobby = true
		this.gameId = gameId
		this.roomString = roomString
		this.roomId = cast roomString
		this.localUserId = userId
		this.frame = 0
		this.frames = 0
		// TEMP: Storing event stream in database is disabled for now
		// try
		// 	await openFromDB
		// catch 
		// 	input.localUser = {this.localUserId, local:true, connected:true, connectionId:0}
		input.localUser = {this.localUserId, local:true, connected:true, connectionId:0}
		await PeerNetwork.setupLocalMedia 
			enableVideo:not Platform.isStaging || core.enableVideoForStaging
			enableAudio:not Platform.isStaging || core.enableAudioForStaging
		ServerNetwork.setup
		lobby.enableFullscreen = !Platform.isStaging
		
	private js void initAll
		init()
		graphics.updateBaseMatrix();
		
	internal storeUserId
		Platform.setLocalStorageObject "room"+roomId, RoomInfo(currentTime, input.localUser.id)
		
	string snapshotLogWithWrongChecksum
		
	onWrongChecksum: int frame, float mine, float theirs
		string message = " Out of sync. frame:{frame} mine:{mine} theirs:{theirs}"
		string serializeLog = serializeLogs[frame mod 100]
		core.log message
		if not snapshotLogWithWrongChecksum
			snapshotLogWithWrongChecksum = "frame:{frame} mine:{mine} theirs:{theirs}\n{serializeLog}"
			core.log "\n{serializeLog}"
			// file.saveText "{input.localUser.id}-snapshot{frame}.json", serializeLog
		onError {message}
		
	onError: Error error
		if error.message == "reached end of replay" then return
		errorMessage = error.stack
		hasErrors = true
		if(core.runningTest || Platform.isDebug) {
			addToOutput "exception|{errorMessage}||0"
		} else {
			core.log errorMessage
		}
		
internal transient unit Snapshot
	int autoSaveCount
	int lastSnapshotSize
	
	Buffer snapshots = {}
	int[] snapshotStarts
	int snapshotEvery = 100
	
	private bool autoSaveAtEndOfStep
	
	inline js string serialize(Buffer buffer) serialize_internal(buffer)
	inline js void deserialize(Buffer buffer) deserialize_internal(buffer)
	inline js string serializeLog() _serializeLog
		
	js string toString: object value
		let buffer = new Buffer(null, 1024, 0, 0);
		setup_serialize();
		value.serialize_external(buffer);
		return btoa(String.fromCharCode(...new Uint8Array(buffer.buffer, 0, buffer.writePos)));	
		
	js void fromString: object value, string base64String
		let bytes = Uint8Array.from(atob(base64String), c => c.charCodeAt(0))
		let buffer = new Buffer(bytes.buffer,0,0,0);
		setup_deserialize();
		value.deserialize_external(buffer);
		
	js void fromBase64: object value, string base64String
		let bytes = Uint8Array.from(atob(base64String), c => c.charCodeAt(0))
		let buffer = new Buffer(bytes.buffer,0,0,0);
		setup_deserialize();
		value.deserialize_internal(buffer);
				
	Buffer save
		Buffer buffer = {}
		serialize(buffer)
		return buffer
		
	restore: Buffer buffer
		deserialize(buffer)
		
	autoSave() autoSaveAtEndOfStep = true

enum lowercase string PrintIcon: Action, Reaction, Debug, Info, Error, Warning, Touch, Key, GameController
	
global transient unit System
	// Reset all variables to their initial value and restart the app
	global inline restart() core.restart
		
	global inline refresh()
		
	// Prints a message to the console
	global js void print: logstring text	// The text, variables or expressions to print
	                      PrintIcon type = Info	// Action: Action performed by a player, Reaction: Consequence of an action, Debug: Temporary debug information, Info: Information, Error: Error, Warning: Warning
						  Color color = null	// The color to use when showing the message in the console or the event stream panel
		                  void(bool isSelected) drawDebugInformation = null	// A function that will be called to draw debug information. The isSelected parameter indicates whether this message is currently selected in the event stream panel, which can be used to hightlight the information or draw more detailed information.
		                  SourceCodeLocation location
		if((core.runningTest || Platform.isDebug) && location) {
			if(color) console.log(`%c${text}`, `color: ${color.hex}`)
			else      console.log(text)
			if(drawDebugInformation != null && (core.interrruptAtOutputIndex == -1 ||core.outputIndex <= core.interrruptAtOutputIndex)) {
				drawDebugInformation(core.outputIndex == core.interrruptAtOutputIndex)
			}
			core.addToOutput(`${type}|${text}|${location.file}|${location.start}|${color ? color.hex : ""}`)
		} else {
			core.log(text);
		}

internal class StatisticsGraph
	int userIndex = -1
	int set
	string label = null
	float[] values
	Color color
	
	float[] recentValues
	float[] valuesToSend
	int sendingUntil
	int successfullySentUntil
	
	float lastValue => values.length > 0 ? values[values.length-1] : 0
	
	add: float value
		recentValues.add value
		if recentValues.length >= statistics.framesPerValue
			values.add recentValues.max .
			recentValues.clear

	addDirectly: float value
		values.add value
			
internal immutable StatisticsInfo
	float value
	int index
	int frame
				
skipInit transient unit statistics
	const Vector2 margin = {224,126}
	const Vector2 position = {-960, 540}
	const Vector2 size = {1920+margin.x, margin.y}
	const framesPerValue = 15
	
	float[] serverPings
	int successfullySentServerPings
	
	private StatisticsGraph[] graphs
	
	string[] systemLogs
	private dynamic[] gameLogs
	int successfullySentGameLogs
	int successfullySentSystemLogs
	
	float startTime, loadTime, cameraTime, connectTime
	internal float maxValue
	int currentSet
	int sets = 1
	int id
	
	private StatisticsInfo[] infos
	private string[] infoNames
	private bool currentlySendingStatistics
	
	bool sessionStarted
	float nextSendTime = float.maxValue
	
	scheduleSendIn: float delay
		nextSendTime = math.min(nextSendTime, PlainDate.realTime + delay)
	
	tick
		if PlainDate.realTime > nextSendTime
			if not sessionStarted then startSession
			else                   saveStatistics
			nextSendTime = PlainDate.realTime + core.sendStatisticsEvery
	
	// Log game events (like scores, playtimes, etc)
	log: dynamic value
		value.frame = Time.frame
		this.gameLogs.add value
	
	private startSession
		core.log "#statistics Start Session"
		if currentlySendingStatistics then return
		currentlySendingStatistics = true
		
		let user = storage.getObjectDirectly("user")
		let server = Platform.hostname.getUntil(".")
		let userId = input.localUser.id
		id = core.roomId*100 + userId
		int sendingSystemLogsUntil = systemLogs.length

		http.postDirectly "{Platform.protocolAndHost}:3114/startSession", body:{
			id
			gameId: core.gameId
			roomId: core.roomId
			userId
			userIndex: input.localUser.index
			userEmail: user.email
			version: Platform.buildVersion
			staging: Platform.isStaging
			server
			times: [ loadTime, connectTime, cameraTime ]
			systemLogs: systemLogs[successfullySentSystemLogs..]
		}
			successfullySentSystemLogs = sendingSystemLogsUntil
			currentlySendingStatistics = false
			sessionStarted = true
		else
			currentlySendingStatistics = false
	
	private saveStatistics
		core.log "#statistics Send Statistics"
		if currentlySendingStatistics then return
		currentlySendingStatistics = true
		
		// Compile server and peer pings to send
		string[] connections
		for players as p
			let internalUser = input.internalUsers[.id]
			connections.add internalUser.connectionType
			
		for graphs
			.valuesToSend = .values[.successfullySentUntil..]
			.sendingUntil = .values.length

		int sendingServerPingsUntil = serverPings.length
		int sendingSystemLogsUntil = systemLogs.length
		int sendingGameLogsUntil = gameLogs.length
			
		// Send statistics to server
		http.postDirectly "{Platform.protocolAndHost}:3114/saveStatistics", body:{
			id
			connections
			graphLabels: graphs.select.label
			graphs: graphs.select.valuesToSend
			serverPings: serverPings[successfullySentServerPings..]
			systemLogs: systemLogs[successfullySentSystemLogs..]
			gameLogs: gameLogs[successfullySentGameLogs..]
		}
			graphs.each.successfullySentUntil = .sendingUntil
			successfullySentServerPings = sendingServerPingsUntil
			successfullySentSystemLogs = sendingSystemLogsUntil
			successfullySentGameLogs = sendingGameLogsUntil
			currentlySendingStatistics = false
		else
			currentlySendingStatistics = false
						
	add: string label, int userIndex = -1, float value, Color color = White, int set = 0, isPerFrame = true
		if userIndex != -1 then label += " #{userIndex}"
		var s = graphs.find.label == label
		if !s
			graphs.add s = {label, userIndex, color, set}
			sets assignIfGreater set+1
		s.color = color
		if isPerFrame then s.add value
		else           s.addDirectly value

	addInfo: string name, float value
		int index = infoNames.indexOf name
		if index == -1 then index = infoNames.length; infoNames.add name
		infos.add {value, index, frame:core.frame}
		
	internal tickGraph
		input.onTouchDown position, size, align:Left, valign:Top
			currentSet incrementAndWrap sets
	
		maxValue = 12
		for graphs as s
			if .set != currentSet then continue
			int len = math.min(.values.length, 50)
			for len
				 
				let value = s.values[s.values.length-1-i]
				if value > maxValue then maxValue = value
					
		draw

unit networkVisualizer		
	visible int[] posForPlayer = [0,-10000,-10000,-10000,-10000,-10000]
		
	internal tick
		if core.simulateInputsForTesting
			for players
				if posForPlayer[.index] == -10000 then posForPlayer[.index] = posForPlayer[0]
					
			// Move circle with artificially created inputs to test the smoothness
			for players as player
				core.smooth player
					input.onKeyDown by:player
						if (posForPlayer[player.index] += 2) > 1080
							posForPlayer[player.index] -= 1080
				
		draw
				
	private getHeightForFrame: int frame
		return (50+frame-core.frame)*20

global skipInit unit math
	init
		initDefaultRandomGenerator
		
	js void initDefaultRandomGenerator
		math.randomGenerator = Math.random
		
	js string generateRandomSeed:
		let crypto = !window.crypto && typeof(require) != "undefined" ? require("crypto") : window.crypto
		if(crypto) {
			let out = new Uint8Array(256);
			crypto.getRandomValues(out);
			return out.toString();
		}
		
	transient internal string randomSeed
	internal int randomValueIndex
	transient internal float[] randomValues
	
	internal recreateRandomValues
		let targetRandomValueIndex = randomValueIndex
		setRandomSeed randomSeed
		for targetRandomValueIndex
			randomFloat
	
	js void setRandomSeed: string seed
		math.randomSeed = seed
		math.randomValues.length = 0
		math.randomValueIndex = 0
		
		// Seeding the random number generator in Javascript
		// https://stackoverflow.com/a/47593316
		function xmur3(str) {
		    for(var i = 0, h = 1779033703 ^ str.length; i < str.length; i++) {
		        h = Math.imul(h ^ str.charCodeAt(i), 3432918353);
		        h = h << 13 | h >>> 19;
		    } return function() {
		        h = Math.imul(h ^ (h >>> 16), 2246822507);
		        h = Math.imul(h ^ (h >>> 13), 3266489909);
		        return (h ^= h >>> 16) >>> 0;
		    }
		}
		
		function sfc32(a, b, c, d) {
		    return function() {
		      a >>>= 0; b >>>= 0; c >>>= 0; d >>>= 0; 
		      var t = (a + b) | 0;
		      a = b ^ b >>> 9;
		      b = c + (c << 3) | 0;
		      c = (c << 21 | c >>> 11);
		      d = d + 1 | 0;
		      t = t + d | 0;
		      c = c + t | 0;
		      return (t >>> 0) / 4294967296;
		    }
		}
		
		function mulberry32(a) {
		    return function() {
		      var t = a += 0x6D2B79F5;
		      t = Math.imul(t ^ t >>> 15, t | 1);
		      t ^= t + Math.imul(t ^ t >>> 7, t | 61);
		      return ((t ^ t >>> 14) >>> 0) / 4294967296;
		    }
		}
		
		var seed = xmur3(seed);
		var rand = sfc32(seed(), seed(), seed(), seed());
		var rand = mulberry32(seed());
		
		math.randomGenerator = function() {
			let value
			if(math.randomValueIndex < math.randomValues.length) {
				value = math.randomValues[math.randomValueIndex]
				math.randomValueIndex++
			} else {
				value = rand()
				math.randomValues[math.randomValueIndex++] = value;
			}
			return value
		}

	// Generates a random integer
	global js int randomInteger: int from // The inclusive lower bound of the random integer
		                         int to // The exclusive upper bound of the random integer
		return from + Math.floor(math.randomGenerator() * (to-from))
	
	global js int randomInteger: int to = 2147483647 // The exclusive upper bound of the random integer
		return Math.floor(math.randomGenerator() * to)
	
	// Generates a random float
	global js int randomFloat: float from
		                       float to
		return from + math.randomGenerator() * (to-from)
	
	global js int randomFloat: float to = 1.0
		return math.randomGenerator() * to

tests
	// Used internally in the compiled code. Do not call in your code.
	//     expect players.length == 2    ->    tests.expectToBeEqual(`players.length`, players.length, 2, new SourceCodeLocation("tests/tests.l", 69312, 69317, null, null));
	importance:-1
	internal expectToBeEqual: string expressionString
	                          dynamic actual
		                      dynamic expected
				              SourceCodeLocation location
		string actualString, expectedString, result
		try	actualString = json.stringify(actual)
		catch	actualString = actual?.toString()
		if actual == expected
			result = "+"
		else
			result = "-"
			try		expectedString = json.stringify(expected)
			catch		expectedString = expected?.toString()
		core.addToOutput "expect|{expressionString}|{result}|{actualString}|{expectedString}|{location.file}|{location.start}"

	// Used internally in the compiled code. Do not call in your code.
	//     expect players.all.ready      ->    tests.expectToBeTrue(`players.all.ready`, players.all.ready, new SourceCodeLocation("tests/tests.l", 69312, 69317, null, null));
	importance:-1
	internal expectToBeTrue: string expressionString
	                         dynamic actual
				             SourceCodeLocation location
		string actualString
		try	actualString = json.stringify(actual)
		catch	actualString = actual?.toString()
		string result = actual ? "+" : "-"
		core.addToOutput "expect|{expressionString}|{result}|{actualString}|true|{location.file}|{location.start}"
	
	// Used internally. Do not call in your code.
	internal tick
		System.log "### tick core.frame:{core.frame} core.targetFrame:{core.targetFrame} "
		// if core.frame <= core.targetFrame
		Platform.fastForward = core.frame != core.targetFrame
		core.tick draw:core.frame == core.targetFrame

