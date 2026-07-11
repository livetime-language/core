enum NetworkMode: None, Ping, Local, Connected

// Everything a client remembers about a room: the identity to rejoin with (including the
// session token proving the id is ours) and the recovery info a freshly restarted server needs
// to recreate the room (seed, start time). Stored in sessionStorage (this tab's own identity,
// survives a reload) and - only by the tab holding the identity lease - in localStorage (the
// browser's identity, survives a browser restart). See core.requestIdentityLease
internal transient immutable RoomInfo
	int time
	int userId
	string seed
	float serverStartTime
	int maxUserId
	string token

enum SendInputsMode: None, Peer, Server
	
internal transient skipInit unit core
	int eventStreamVersion = 2
	int sendInterval = 1
	bool enabledMilestones = false
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
	const ticksPerSecond = 30
	const frameTime = 1000/ticksPerSecond
	
	NetworkMode mode                // Whether we are in local or connected mode
	visible string errorMessage     // The error message if we caught any exceptions in the main loop
	public float startTime          // The time the room was created, syncroniced between all clients
	public float serverStartTime     // Used to calculate the same Time.now from core.frame for all users in core.step
	int frame               // Current frame, will increase by 1 at the end of every step (every targetFrameTime ms)
	int certainFrame = -1   // The last frame whose inputs are final from every user (min over users of min(inputFrame, smoothFrame), set in step)
	internal int frames             // Total number of frames we have inputs for
	internal int frameWithNewWatches// First frame with new watches, do not send watches for frames below this
	int watchIndex
	internal bool startInLobby      // Connected sessions usually start in the lobby, local sessions start in the app
	private int joinFrame           // The frame the local user joined
	bool isPremiere
	UserAccount account
	
	// Checksum
	// Kept in a fixed-size ring keyed by frame instead of a flat float[frame] array, which grew
	// for the whole session (F29). Each slot remembers the frame it belongs to, so a stale entry
	// can never be mistaken for the requested frame - it just reads as missing
	const checksumWindow = 4096
	private float[] checksumValues
	private int[] checksumFrames
	private int[] checksumRosters
	public int lastChecksumFrame

	float getChecksum: int frame
		if frame < 0 then return 0
		return checksumFrames[frame mod checksumWindow] == frame ? checksumValues[frame mod checksumWindow] : 0

	// The roster hash stored with a checksum: which players' inputs fed the state it was
	// computed from. Two internally consistent forks of a partitioned room differ exactly here,
	// and their state checksums MUST differ - comparing them would report a determinism bug
	// where there is none, so mismatched-roster checksums are skipped instead (the fork itself
	// is the removal protocol's job to arbitrate)
	int getChecksumRoster: int frame
		if frame < 0 then return 0
		return checksumFrames[frame mod checksumWindow] == frame ? checksumRosters[frame mod checksumWindow] : 0

	// Presence is keyed by the ring's frame slot, never by the value: a genuine checksum of 0
	// (1 in 2^32 per frame, and the sessions are long-lived) must be stored and compared like
	// any other value - the old 0-sentinel skipped the compare for exactly those frames
	bool hasChecksum: int frame
		return frame >= 0 and checksumFrames[frame mod checksumWindow] == frame

	private setChecksum: int frame, float value, int roster
		if frame < 0 then return // Peers send checksumFrame -1 until their first checksum exists
		checksumFrames[frame mod checksumWindow] = frame
		checksumValues[frame mod checksumWindow] = value
		checksumRosters[frame mod checksumWindow] = roster

	// A deterministic hash of the current roster (the player ids whose inputs feed the
	// simulation). Players enter on their first parsed input record and leave through
	// removeUserDeterministically, so every client on the same timeline computes the same
	// value for the same frame
	internal int rosterHash
		int hash = 0
		for input.players
			hash = (hash * 31 + .id + 1) mod 1000000007
		return hash

	private float lastRosterSkipLogTime

	// Rate-limited: during a live partition every Tick of the diverged side carries a
	// mismatched-roster checksum (~30/s per peer)
	private logRosterSkip: int frame
		if currentTime < lastRosterSkipLogTime + 2000 then return
		lastRosterSkipLogTime = currentTime
		log "#checksum Skipped checksum compare for frame {frame}: rosters diverged (fork, arbitrated by the removal protocol)"

	// Catch-up after a long pause in Connected mode (background tab, laptop sleep, late join):
	// stepping is budgeted per animation frame so the tab never blocks for seconds, and the
	// progress is exposed so the app can draw an overlay instead of looking frozen (F5)
	visible bool catchingUp
	visible float catchUpProgress
	private int catchUpFromFrame
	const maxCatchUpMillisPerFrame = 100

	// New input records must not be appended while we replay a catch-up (the stamps would lag
	// the claims we already sent) or while a rejoin's holding confirmations are pending (the
	// bytes would fork the longer copy of our previous stream a returning peer may still hold,
	// see PeerNetwork.holdingConfirmationPending). Checked by every input record handler
	bool inputRecordingPaused
		return catchingUp or PeerNetwork.holdingConfirmationPending
	
	IndexedDBStore inputStore = {"input", indices:[{"roomId"}]}
	
	startConnected: int frame
		if mode == Connected then return

		// A late joiner's first seconds are catch-up noise - collectStatistics gates on this
		joinFrame = frame

		account = system.getLocalStorageObject("user") or {}
		if not account._id
			account._id = generateObjectId
			system.setLocalStorageObject("user", account)
				
		log "startConnected", joinFrame, this.frame, this.frames
		if this.frames == 0
			if input.localUser.epochStartPos > 0
				// We restored our previous session's input stream after a rejoin: it already contains
				// our Join event, so we resume that player instead of joining again - the replay from
				// frame 0 recreates our player from the restored stream
				log "resume", input.localUser.epochStartPos
			else if PeerNetwork.holdingConfirmationPending
				// We restored nothing, but not every peer confirmed its holdings - one of them may
				// still hold our previous session's stream, and a fresh Join at position 0 would
				// fork it. The Join is written when the confirmations settle
				// (PeerNetwork.finishHoldingConfirmations) or the restore rebuilds our old stream
				log "handleJoin deferred until every live peer confirmed its holdings"
			else
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
		outputSentUpTo = 0
		for input.internalUsers if .
			.inputs.reset
			.startInputFrame 0
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
		onFrame
		
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
		addOutput "start"
		input.players.clear
		input.playersById.clear
		input.host = null
		errorMessage = ""
		HTMLElement??.clear()
		math.randomValueIndex = 0
		frame = 0
		watchIndex = 0
		input.isCertain = true
		lobby.inLobby = startInLobby
		Time.now = serverStartTime
		snapshotFrame = -1
		integrationReplayTo = -1
		remoteInputsChanged = true
		earliestChangedFrame = int.maxValue
		nextPredictionPassFrame = 0
		checksumValues.clear
		checksumFrames.clear
		lastChecksumFrame = -1
		catchingUp = false
		audio.stop
		graphics.clearDebugInfo
		initAll
		
		if !startInLobby or testLobby
			// When the developer changed system.userCount, add or remove internal users accordingly
			for system.userCount
				if not input.internalUsers[.]
					input.internalUsers[.] = {id:i, local:true, collectInputs:true}
			if input.internalUsers.length > system.userCount
				input.internalUsers.removeRange system.userCount..input.internalUsers.length
			
			// We always recreating players, because developers might have added fields to Player or Touch
			// By the time we call startApp, all players need to exist
			for input.internalUsers as internalUser
				Player user = {id:.id, playerIndex:i}
				input.playersById[.id] = user
				input.players.add user
				
			// Set local user
			let localUserId = input.localUser?.id < input.internalUsers.length ? input.localUser.id : 0
			input.localUser = input.internalUsers[localUserId]
			input.localPlayer = input.playersById[localUserId]
			input.updatePlayers
			account = {}
			
		// Reset read pos to replay inputs from the beginning
		for input.internalUsers if .
			.inputs.readPos = 0
			
		graphics.startFrame
		if !startInLobby and not testLobby
			lobby.inLobby = false
			app.start??()
		if simulateRollback then checkSaveState
		
	// Keep event stream running, recreate players, call init function and start app
	// Called manually with the global "restart" function	
	restart
		if not input.isCertain then return
		let hostPlayerId = input.host ? input.host.id : -1
		Framework??.clear(true)
		system.fastForward = false
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
		lobby.inLobby = false
		app.start??()
	
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
		isPremiere = false
		try
			try
				if codeChanged
					frameWithNewWatches = 0
					outputSentUpTo = 0
					output.clear
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

			// If we interrupted in the middle of a tick, we draw the current state without events and animations
			if frame <= targetFrame
				system.fastForward = false
				for input.internalUsers as user
					user?.clearEvent
				fx??.clear()
				tick draw:true

			graphics.finishDrawingDebugInfo
		catch
			onError .
		finally
			adjustStartTime
			isPremiere = true
			let output = codeChanged ? core.output : null
			sendOutputToEditor frame:core.frame-1

	runTest: dynamic testFunction, int id = -1, int targetFrame = -1, int interrruptAtOutputIndex = -1
		isPremiere = false
		runningTest = true
		errorCount = 0
		this.targetFrame = targetFrame
		this.interrruptAtOutputIndex = interrruptAtOutputIndex
		system.fastForward = true
		try
			try
				outputSentUpTo = 0
				reset
				testFunction()
			catch
				onError .

			// We draw the current state without events and animations
			// We don't draw in the test function since we don't know when we are on the final frame
			if not system.isHeadless
				system.fastForward = false
				for input.internalUsers as user
					user?.clearEvent
				fx??.clear()
				tick draw:true
				graphics.finishDrawingDebugInfo
		catch
			core.onError .
		finally		
			isPremiere = true
			runningTest = false
			system.sendToEditor({type:"finishedTest", id, testFunction, output, frame, frames, playMode:system.playMode})
			// system.sendToEditor({type:"finishedTest", id, testFunction, output, onScreen:graphics.getDescriptionOfItemsOnScreen, testRunMode})

	bool runningTest
	int errorCount
	string[] output
	int outputIndex = -1
	int interrruptAtOutputIndex = -1
	int targetFrame = -1
	int outputSentUpTo = 0

	addOutput: string value
		value += "|{outputIndex}|{frame}"
		output[outputIndex] = value

		// Throw an exception when we reach interrruptAtOutputIndex
		// interrruptAtOutputIndex is -1 when no interrupt is armed. outputIndex also starts at -1
		// in connected sessions, so without the -1 check the first output (the first local click)
		// would throw a spurious interrupt that silently aborts the step between parseInputs and tick
		if outputIndex++ == interrruptAtOutputIndex and interrruptAtOutputIndex != -1
			throw {"interrrupt"}

	sendOutputToEditor: int frame = core.frame
		string result
		for outputSentUpTo to output.length
			if(result) result += "\n"
			result += "{output[.].replaceAll("\n", "\\n")}"
		if result then result += "\n"
		result += "#{frame}|{frames}|{(int)system.playMode}"
		outputSentUpTo = output.length
		system.sendStringToEditor result

	// Smooth out animations by only executing code when we received inputs from everybody	
	smooth: Player player
		    void() do
		let user = input.internalUsers[player.id]
		if user and (user.local or frame <= user.smoothFrame) then do
			
	float lastPingTime

	// onFrame --> step --> tick

	// onFrame	Send tick message, replay state, and call step
	// step	Save state, parse inputs, step physics, process tick, and calculate checksum
	// tick	Clear screen, process application tick, and draw all graphics
		
	// Send tick message, replay state, call step, and logging
	// This is called by the requestAnimationFrame callback.
	// We ensure that step is called every frameTime milliseconds.
	internal onFrame
		now = currentTime
		if lastAnimationFrame	then frameTimes.add now - lastAnimationFrame

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

		// A backwards clock re-anchor (F20) can drop targetFrame below frame mid-catch-up;
		// the step loop then doesn't run, so the flag must be cleared here (F5)
		if catchingUp and frame >= targetFrame then catchingUp = false
		
		if frame < targetFrame
			// Create artificial inputs to test the smoothness
			if simulateInputsForTesting and input.localUser and input.localUser.collectInputs
				for frame to targetFrame
					input.handleKeyEvent KeyDown, cast Key.F24, ""
				
			frameAtBeginningOfOnFrame = frame

			// A long pause (background tab, sleep, late join) leaves us many frames behind.
			// Stepping them all in one synchronous loop would freeze the tab for seconds and
			// silence our Ticks (peers would start reconnect churn), so the loop below is
			// budgeted and the catch-up is spread over several animation frames, with Ticks,
			// acks and pings still going out in between (F5)
			if mode == Connected and not catchingUp and targetFrame - frame > ticksPerSecond*2
				catchingUp = true
				catchUpFromFrame = frame
				log "#catchup {targetFrame - frame} frames behind -> catching up in budgeted chunks"

			try
				// Replay all frames from the first uncertain frame until the current frame
				// when we received all inputs for frames that we were uncertain about before
				checkRewindAndReplayState

			catch
				onError error

			// Ensure that step is called every frameTime milliseconds
			try
				let catchUpDeadline = now + maxCatchUpMillisPerFrame
				while frame < targetFrame
					// A fork rebuild is scheduled: stepping on would parse the fork's records at
					// wrong frames and broadcast checksums of that corrupted state - stay quiet
					// until the reload lands
					if rebuildPending then break
					if system.playMode == Record
						for input.internalUsers as user
							// Never regress the stamp for new records: during a catch-up replay frame
							// counts up from below claims we (or our pre-reload session) already sent,
							// and a record stamped at or below a sent claim can't be rewound to its
							// true frame by peers (their snapshot is only pinned down to claim+1) -
							// they would apply it at their current frame and desync forever.
							// While a rejoin's holding confirmations are pending, the counter (and
							// with it the claim we send) instead stays at the floor adopted from
							// confirmed peers: old records of our previous session may still surface
							// from a peer holding more of our stream, and a claim covering their
							// frames would break the receivers' rewind pinning the same way
							if user?.local and not PeerNetwork.holdingConfirmationPending then user.startInputFrame math.max(frame+1, user.inputFrame)
					// Frames below integrationReplayTo re-step frames the player already saw (a
					// budgeted integration replay, see checkRewindAndReplayState): they run
					// fastForwarded like a synchronous replay - sounds and app effects must not
					// fire again - are never drawn, and don't feed the smoothing statistics
					bool integrating = frame < integrationReplayTo
					// While catching up or integrating, stop stepping when the budget is used up.
					// A catch-up chunk draws its last frame so the player sees progress instead
					// of a frozen canvas; an integration keeps the last live frame on the canvas
					bool lastStepOfChunk = frame == targetFrame-1 or ((catchingUp or integrating) and currentTime >= catchUpDeadline)
					bool drawThisStep = lastStepOfChunk and not integrating
					step fastForward:integrating, draw:drawThisStep
					if not system.isDebug and not integrating then collectStatistics
					if lastStepOfChunk then break
			catch
				onError .

			if catchingUp
				catchUpProgress = math.min((frame - catchUpFromFrame) / math.max(targetFrame - catchUpFromFrame, 1), 1)
				if frame >= targetFrame
					catchingUp = false
					log "#catchup Caught up at frame {frame}"

			// Deliver networkData callbacks (storage.get / http.*) that resolved while input
			// recording was blocked - queued in input.handleObject, written here once recording
			// is possible again so the app still hears back after a catch-up or holding gate
			input.flushPendingObjectRecords

			// Send inputs after the step loop: stepping writes gamepad records stamped frame+1,
			// so a claim sent before the loop would cover bytes that only travel in a later message.
			// localUser.inputFrame-1 claims exactly the frames no future write can be stamped with
			// (at least -1: receivers drop claims below their initial inputFrame of -1)
			try
				sendInputs math.max(input.localUser.inputFrame-1, -1)
			catch
				onError .

			// Store all input streams (our own and the copies we hold of every other user's)
			if IndexedDB.isReady
				core.storeInputsToDB
				
		lastAnimationFrame = now
		if system.playMode == Play and frame >= frames then system.record()
			
	private int frameAtBeginningOfOnFrame	// The frame at the beginning of onFrame, used to calculate iteration
	private float now	// The time at the beginning of onFrame
	
	private float prevLogTime
	
	// Logs
	// Each line carries a millisecond timestamp and the current frame, so client logs can be
	// correlated with each other and with the server log (which logs microseconds) after a
	// real-world incident
	js void log: logstring text
		if(Time.now > core.prevLog + 3000) core.logs += "\n"
		core.prevLog = Time.now

		let d = new Date()
		let pad = (n, l) => String(n).padStart(l, "0")
		let timestamp = d.getFullYear()+"-"+pad(d.getMonth()+1,2)+"-"+pad(d.getDate(),2)+" "
			+pad(d.getHours(),2)+":"+pad(d.getMinutes(),2)+":"+pad(d.getSeconds(),2)+"."+pad(d.getMilliseconds(),3)
		let str = timestamp + " [" + core.frame + "] " + text
		statistics.systemLogs.push(str)
		// Bound the unsent backlog: in debug mode, or when the statistics server is unreachable,
		// nothing ever flushes it (F28). The sent prefix is trimmed in statistics.trimSentData
		if(statistics.systemLogs.length > 20000) {
			statistics.systemLogs.splice(0, 10000);
			statistics.successfullySentSystemLogs = Math.max(0, statistics.successfullySentSystemLogs - 10000);
		}
		console.log(str)
		core.logs += str + "\n"
		// Bound the in-memory log: drop the oldest half once it exceeds ~2 MB (F28)
		if(core.logs.length > 2097152) {
			core.logs = core.logs.substring(core.logs.indexOf("\n", core.logs.length - 1048576) + 1);
		}
			
	internal string logs
	internal bool hasErrors
	private float lastAnimationFrame, drawTime, tickTime, restoreTime, replayTime, saveTime
	internal int displayItems
	int tickMessageSize
	bool verbose = false
	int replayFrom = -1
	
	RollingList drawTimes, tickTimes, frameTimes = {length:150}
	
	collectStatistics
		// Players
		if mode == Connected and input.players.length > 1 and frame > joinFrame + 120
			for input.players
				let internalUser = input.internalUsers[.id]
				if not internalUser.local
					internalUser.collectStatistics frame
					statistics.add "input", userIndex:.playerIndex, value:frame - internalUser.inputFrame, .playerColor, set:0
					statistics.add "smooth", userIndex:.playerIndex, value:frame - internalUser.smoothFrame, .playerColor, set:1
					statistics.add "delta", userIndex:.playerIndex, value:internalUser.certainFrame - internalUser.prevCertainFrame, .playerColor, set:2

			if replayFrom != -1 then statistics.add "replay", value:frame - replayFrom, color:Gray
		else
		if mode == Local and simulateRollback
			input.internalUsers.each.simulateRollback frame
			
		// Memory
		statistics.add "memory", value:system.usedMemory, color:Yellow set:4
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
			PeerNetwork.sendInputs inputFrame
			lastSendFrame = frame
	
	internal switchToPlayer: Player player
		if not player then return
		let prevPlayer = input.localPlayer
		input.localPlayer = player
		input.localUser = input.internalUsers.find . and .id == player.id
		for prevPlayer.touches
			input.handleUpdateTouchAfterSwitchingUser .id, .position
		system.updatePageIconAndTitle

	// Save state, parse inputs, step physics, process tick, and calculate checksum
	// This is called in onFrame and during replays. 
	// All steps except the very last of an animation frame are fast forwared, which means that nothing is drawn.
	// The frame is increment at the end of this function. This means that while processing the frame,
	// frame will point to the current frame. After processing, frame will point to the next frame.
	internal step: bool fastForward // If we are replaying after a rollback or a code change
		           bool draw        // We don't draw if we are stepping multiple frames in one animation frame
		if verbose	then core.log "#{frame}{fastForward ? " fastForward":""}{draw ? " draw":""}"

		// Flags
		system.fastForward = fastForward
		// A removed user stops blocking certainty once we hold their complete final stream
		// (their claims reached the removal frame) - before that, their missing bytes are part
		// of the timeline and must arrive (fetched from peers) before frames become certain
		certainFrame = input.internalUsers.min (.removed and .inputFrame >= .removedAfterFrame ? int.maxValue : math.min(.inputFrame, .smoothFrame)) filter: . != null
		input.isCertain = frame <= certainFrame
		
		// Send current frame to editor	
		if system.isDebug and (system.playMode == Play or system.playMode == Record) then sendOutputToEditor
		
		// Save a snapshot when we are about to start the frame after the last certain frame filter we got all inputs
		checkSaveState
		
		// Update game controllers
		input.updateGamepads
		
		// Parse inputs
		input.parseInputs(frame)
		
		// Physics
		Physics.step
		
		// Tick
		tick draw
		
		HTMLElement??.tickAll()
				
	// Clear screen, process application tick, draw all graphics, cleanup, and advance frame
	// This is all the logic that is executed in a unit test for each frame.
	// Called in step and in tests
	internal tick: bool draw
		// if targetFrame != -1 and frame > targetFrame	return

		// Set time
		Time.now = serverStartTime + math.round(frame * frameTime)
			
		// Start frame
		system.isDrawing = draw
		if frame > 0 then graphics.startFrame
		audio.startFrame

		// Debug info
		if system.showDebugInfo
			if draw then statistics.tickGraph
			networkVisualizer.tick

		// Show the progress while catching up after a long pause, instead of looking frozen (F5)
		// Implemented in the 2D layer (lib/core/2D/lobby.l), missing in headless builds
		if draw and catchingUp then this.drawCatchUpOverlay??()

		try
			Framework??.tick
			tickTimes.add tickTime = PlainDate.measure
				if lobby.inLobby then	lobby.tick
				else	appTick

			// Advance frame
			frame++
			if frames < frame	then frames = frame
			if frame > frameWithNewWatches	then frameWithNewWatches = frame
		finally			
			// Finish frame
			if draw and not system.waitingForInitialData
				drawTimes.add drawTime = PlainDate.measure
					graphics.finishFrame
				if system.playMode != Manipulator then input.updateCursor
			audio.finishFrame

			// Cleanup
			for input.internalUsers as user
				user?.clearEvent

			// Evaluate: Set isDown directly in input.touchDown instead of in player.postprocessEvents #easier-to-reason-about #evaluate
			// players.each.postprocessEvents

			// Currently, we use tests.printWhatIsOnScreen to print the screen contents
			// instead of automatically sending it every time
			// if frame == 0 and system.isDebug: debug.sendCurrentlyOnScreen
							
	js void appTick() if(app.tick) app.tick();
	js string appDebugString() (app.debugString || "")
		
	private Buffer snapshot = {}
	private Buffer secondSnapshotForTesting = {}
	internal int snapshotFrame = -1 // The pinned snapshot's frame: the only valid rewind root (read by input.removeUserDeterministically's fork check)
	private int nextSnapshotFrame = -1
	
	private Buffer[] milestones
	
	// Arrival tracking for the rollback replay: rewind+replay only runs when something that can
	// change the deterministic parse actually arrived since the last completed pass (03a).
	// earliestChangedFrame is the first frame whose parsed inputs may differ from what the last
	// replay predicted: when it lies above the current frame, forward stepping parses the new
	// records at their true stamps anyway and no replay is needed at all
	private bool remoteInputsChanged = true
	private int earliestChangedFrame = int.maxValue
	
	// While a large integration replay is spread over several animation frames (03c), new rewinds
	// are blocked and nextSnapshotFrame stays frozen until the replay reached this frame
	// (see checkRewindAndReplayState); -1 = no integration replay in progress
	int integrationReplayTo = -1

	// A fork rebuild (reload + full replay from the mesh) is scheduled: stop stepping and
	// replaying until it lands, see the fork detection in checkRewindAndReplayState
	internal bool rebuildPending
	
	// While the snapshot pin is frozen (a silent peer, a rejoin's holding gate), every pass
	// replays the whole window back to the pin. Those prediction passes run on a cooldown
	// proportional to the window (see checkRewindAndReplayState), which bounds the total replay
	// work to a constant rate no matter how long the outage lasts (03b). Remote inputs then
	// integrate in slightly larger batches as the window grows.
	// Note: a ring of intermediate snapshots would bound the window itself, but the serializer's
	// _objectIndex reuse stamps only allow restoring the snapshot that was serialized LAST -
	// interleaving extra serialize calls corrupts the next restore (verified by test)
	private int nextPredictionPassFrame
	
	// Diagnostics for the resilience tests and the statistics graphs
	internal int replayPassCount        // Executed rewind+replay passes
	internal int skippedReplayPassCount // Passes skipped because they would have reproduced the current state
	internal int replayedFrameCount     // Total frames stepped by replay passes
	internal int lastReplayFrameCount   // Frames stepped by the most recent replay pass
	internal int maxReplayFrameCount    // Largest single replay window (tests reset this between phases)
	
	// Called by PeerNetwork whenever something arrived that can change the deterministic parse:
	// a user's claim advanced (records above it became parseable), a user appeared or was removed,
	// or restored history bytes were adopted. firstChangedFrame is the first frame whose parsed
	// inputs may differ from the last replay's prediction - a claim advance changes nothing below
	// oldClaim+1, because records are never stamped at or below their sender's claim
	internal markRemoteChange: int firstChangedFrame
		remoteInputsChanged = true
		if firstChangedFrame < earliestChangedFrame then earliestChangedFrame = firstChangedFrame

	// A stream can arrive immediately before a Tick carrying the sender's checksum. Do this
	// fork check from the checksum handler as well as the next animation frame: otherwise a
	// hidden user that joined AND left below our snapshot pin has the same current roster as us,
	// so the checksum looks comparable and falsely trips the desync self-heal before the normal
	// fork recovery gets a chance to inspect the newly arrived history.
	private bool checkForForkBelowSnapshot
		if rebuildPending then return true
		if snapshotFrame == -1 then return false
		for input.internalUsers as user
			if user and not user.local and user.inputs.canRead
				int firstUnparsedFrame = user.inputs.peekInt32
				bool willParse = firstUnparsedFrame <= user.inputFrame and (not user.removed or firstUnparsedFrame <= user.removedAfterFrame)
				if willParse and firstUnparsedFrame < snapshotFrame
					log "#fork <{user.id}> Unparsed record stamped {firstUnparsedFrame} below the snapshot pin {snapshotFrame}: we certified these frames without user {user.id} -> rebuilding from the mesh"
					rebuildPending = PeerNetwork.forkRecoveryReload "user {user.id}'s record at frame {firstUnparsedFrame} is below the snapshot pin {snapshotFrame}"
					if rebuildPending then return true
		return false
	
	// This is called at the begining of onFrame before we start stepping.
	private checkRewindAndReplayState
		if (mode != Connected and !simulateRollback) or input.internalUsers.length == 1 then return
		if rebuildPending then return

		// Fork detection: a user we only just discovered can hold records stamped below the
		// pinned snapshot - the only valid rewind root. Known users can't (their claims pin the
		// snapshot down, that is the pin's invariant), it takes a user whose join a partition
		// hid from us while our certainty advanced without their inputs. Those records can
		// never replay at their true frames: our certified timeline is a fork of the group's.
		// Parsing on would apply them at wrong frames and desync us for good - rebuild
		// deliberately instead: the reload replays every stream from frame 0 and lands us on
		// the group timeline with our identity and inputs intact. (The checksum self-heal
		// would find the same way out, but only after recording a false determinism failure
		// and broadcasting checksums of the corrupted state to healthy peers)
		if checkForForkBelowSnapshot then return

		// A budgeted integration replay is still stepping toward integrationReplayTo: don't
		// restart it on every arriving chunk (that made a returning peer's recovery cost many
		// consecutive full-window replays, O(window²) in total). nextSnapshotFrame stays frozen
		// too, so the pinned snapshot is re-saved at the frame this pass planned for - every byte
		// below it was already present when the pass started. Arrivals during the pass stay
		// recorded in remoteInputsChanged/earliestChangedFrame and the next pass integrates them
		if integrationReplayTo != -1
			if frame < integrationReplayTo then return
			integrationReplayTo = -1

		if mode == Local and simulateRollback then	nextSnapshotFrame = frame - 5
		else
			// Removed users with a complete final stream no longer hold the snapshot back: when
			// every remote user is gone for good this becomes int.maxValue+1, snapshots stop and
			// the rewind below runs one final time to replay the last received bytes into the state.
			// The LOCAL user is part of the min for the same reason it is part of certainFrame:
			// the snapshot must never advance beyond certainFrame+1. Frames above it are not final
			// yet, and decisions the app deferred at uncertain frames (core.restart returns while
			// not input.isCertain) must stay replayable until their frames become certain. In
			// normal play the local inputFrame is frame+1 and never binds - it only pins the
			// snapshot down while our own claim trails the remote claims, e.g. while a rejoin's
			// holding confirmations are pending (PeerNetwork.holdingConfirmationPending)
			nextSnapshotFrame = (input.internalUsers.min (.removed and .inputFrame >= .removedAfterFrame ? int.maxValue : math.min(.smoothFrame, .inputFrame)) filter: . != null)+1
		
		if snapshotFrame == -1 then return
		
		bool pinAdvances = nextSnapshotFrame > snapshotFrame
		if not pinAdvances
			// Skip the pass when it provably reproduces the current state (03a): nothing relevant
			// arrived, or every newly parseable record is stamped above the current frame - forward
			// stepping parses those at their true stamps anyway. Without this, one silent peer
			// meant replaying its whole silence window on every animation frame, with the total
			// work growing quadratically over the outage
			if not remoteInputsChanged or earliestChangedFrame > frame
				skippedReplayPassCount++
				remoteInputsChanged = false
				earliestChangedFrame = int.maxValue
				replayFrom = -1
				return
			// The pin is frozen, so this pass replays the whole window. Respect the cooldown set
			// by the previous pass (03b) - arrivals keep accumulating in earliestChangedFrame
			if frame < nextPredictionPassFrame then return
		
		if verbose
			core.log "rewindAndReplayState", snapshotFrame, frame, nextSnapshotFrame
			for input.internalUsers
				core.log "\t<{.id}>", .smoothFrame, .inputFrame, .local
		
		remoteInputsChanged = false
		earliestChangedFrame = int.maxValue
		
		int rewindFrame = snapshotFrame
		int replayToFrame = frame
		
		// The pin is only re-serialized when it moves - re-saving an identical snapshot on every
		// animation frame was one of the hidden costs of the old code. The pin is also the only
		// valid rewind root: the serializer's _objectIndex stamps belong to the last serialize
		// call, so restoring any snapshot other than the most recently serialized one corrupts
		// the object-reuse decisions of deserialize
		if pinAdvances then snapshotFrame = -1
		
		rewind snapshot
		
		// Passes with a frozen pin cost the full window every time: space them out so the total
		// replay work stays at a constant rate however long the outage lasts (03b)
		nextPredictionPassFrame = replayToFrame + math.floor((replayToFrame - rewindFrame) / ticksPerSecond)
		
		// The threshold is generous (5 seconds of frames): mid-sized windows replay synchronously
		// in well under a frame budget, and the synchronous path is bit-identical to the old code
		if replayToFrame - rewindFrame > ticksPerSecond*5
			// A huge window (a peer returning after a long outage, a removal releasing a backlog)
			// is not replayed synchronously - that froze the tab for seconds and silenced our own
			// Ticks. It is spread over several animation frames with the catch-up budget instead:
			// core.onFrame's step loop steps frames below integrationReplayTo fastForwarded and
			// budgeted (03c). Unlike a real catch-up this does not pause input recording: new
			// records are stamped localUser.inputFrame, which stays monotonic above every claim
			// we have sent, so records arriving between chunks are safe
			frame = replayFrom = rewindFrame
			integrationReplayTo = replayToFrame
			replayPassCount++
			lastReplayFrameCount = replayToFrame - rewindFrame
			if lastReplayFrameCount > maxReplayFrameCount then maxReplayFrameCount = lastReplayFrameCount
			replayedFrameCount += lastReplayFrameCount
			log "#catchup Integrating {lastReplayFrameCount} replayed frames in budgeted chunks (rewound to {rewindFrame})"
		else
			replay rewindFrame to replayToFrame

	private rewind: Buffer snapshot
		restoreTime = PlainDate.measure
			snapshot.rewind
			Snapshot.deserialize snapshot
			input.refreshLocalPlayer

			// Users discovered AFTER this snapshot was saved have no stored readPos: reset them
			// to 0 so the replay re-parses their whole stream. Keeping the live readPos silently
			// skipped every record the live state had already consumed - including the Join that
			// carries the account id - while the deserialize above rolled the players list back
			// to before the user existed: the player was then recreated by whatever record came
			// next, at a wrong frame, a permanent fork (churn desync, seed 321831152). For a
			// late-discovered user the pin lies below their first record, so the replay parses
			// them at true stamps; records below the pin are the hidden-join fork, detected
			// before every pass in checkRewindAndReplayState
			for input.internalUsers as user
				if user then user.inputs.readPos = 0

			let userCount = snapshot.readInt
			for userCount
				let userId = snapshot.readInt
				int storedReadPos = snapshot.readInt
				let user = input.internalUsers[userId]
					user.inputs.readPos = storedReadPos
		
	private replay: int from, int to
		replayPassCount++
		lastReplayFrameCount = to - from
		if lastReplayFrameCount > maxReplayFrameCount then maxReplayFrameCount = lastReplayFrameCount
		replayedFrameCount += lastReplayFrameCount
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
			if system.logSerialize
				serializeLogs[frame mod 100] = Snapshot.serializeLog

		// Checksum
		// The snapshot is the state before this frame, so it is final once every frame below it is
		// certain - that includes the steady-play snapshot at certainFrame+1, which the previous
		// isCertain gate (frame <= certainFrame) skipped, so checksums never fired in smooth play (F35)
		// Computed here, before the internalUsers section below is appended: user membership and
		// readPos are local bookkeeping that depends on when signaling created each user, not on
		// the simulation - including them made the checksum differ between clients around joins
		if input.players.length >= 2 and frame <= certainFrame + 1
			float myChecksum = snapshot.checksum
			int myRoster = rosterHash
			if verbose then core.log "<{input.localUser.id}*> #{frame} {myChecksum} writePos:{snapshot.writePos}"
			if hasChecksum frame
				if getChecksumRoster(frame) == myRoster
					// Exact compare: the checksums are exact int32 hashes (transported as float64,
					// lossless for int32) - there is no reason to accept any tolerance
					float theirChecksum = getChecksum frame
					if theirChecksum != myChecksum then onWrongChecksum frame, mine:myChecksum theirs:theirChecksum
				else
					// The stored checksum came from a diverged roster (see getChecksumRoster) and is
					// incomparable - replace it with ours so peers on our own timeline still get
					// compared for this frame
					logRosterSkip frame
					setChecksum frame, myChecksum, myRoster
			else
				setChecksum frame, myChecksum, myRoster
			lastChecksumFrame = frame

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
				
	// Monotonic milliseconds anchored to the wall clock at page load: frame pacing must not follow
	// Date.now(), which steps arbitrarily on NTP corrections, manual clock changes and resume (F20)
	inline js int currentTime => Math.round(performance.timeOrigin + performance.now())
		
	private adjustStartTime
		startTime = math.round(currentTime - frame*frameTime - (frameTime*.5))
		
	adjustStartTimeIfNeeded
		if system.playMode < Play then adjustStartTime
			
	Buffer snapshotBuffer = {}
	Buffer eventStreamSnapshotBuffer = {}
		
	saveEventStreamAndLogs
		if input.isCertain
			saveEventStream
			system.delay 1 seconds
				saveLogs
			
	internal saveLogs
		// Ensure that current eventLog is added to the table even if we haven't processed a single frame
		file.saveText "{input.localUser.id} {system.appName} {Date.now.isoString} v{system.buildVersion}.csv", logs
			
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
		buffer.writeBool system.isStaging
		
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
		file.saveBinary "{system.appName} {date.dayShortMonthNameYearString} {date.hourMinuteSecondString} v{system.buildVersion}.state", buffer
		
	const dbChunkSize = 4096
	private float lastInputStoreTime
	private dynamic storedStreamRows // Stream rows loaded by restoreInputsFromDB, keyed by userId, consumed by applyStoredStream

	// Persist every user's input stream to IndexedDB in fixed chunks (the tail chunk is rewritten
	// as it fills) plus one meta row carrying the claim. Our own stream lets the player pick up
	// where they left off after a page refresh even when all peers are gone. The copies of the
	// OTHER users' streams are what keeps a removed user's inputs recoverable when every survivor
	// reloads at once: those bytes live nowhere else once the user is gone, and the RemoveUser
	// event in the host's persisted stream would otherwise make every replay wait forever for
	// bytes no client can provide (a permanent certainFrame deadlock).
	// Failures are ignored: persistence is best-effort.
	// force skips the rate limit: pagehide/hidden flush the tail immediately - inputs younger
	// than the persist interval exist only in memory, and when every holder reloads at once
	// (both players hit refresh, a shared crash) those bytes would be lost everywhere
	storeInputsToDB: bool force = false
		if roomId <= 0 then return
		if not force and currentTime < lastInputStoreTime + 500 then return
		lastInputStoreTime = currentTime
		// Remote users first: IndexedDB commits the puts in order, so whenever a RemoveUser event
		// in our own persisted stream survives, the removed user's bytes it cuts at survived too
		for input.internalUsers as user
			if user and not user.local then storeUserInputsToDB user
		storeUserInputsToDB input.localUser

	private storeUserInputsToDB: InternalUser user
		let inputs = user.inputs
		// The claim gates parsing on a restoring client, so it is persisted alongside the bytes.
		// It can advance without new bytes arriving (a peer's stream answer raised it), hence the
		// separate storedClaim check
		int claim = user.local ? math.max(user.inputFrame - 1, -1) : user.inputFrame
		// The removal cut is persisted too: a stored stream can be LONGER than the cut (its claim
		// arrived live, before the removal did), and the RemoveUser event that cuts it sits at a
		// LATER frame in the host's stream - a restoring replay would parse the discarded tail
		// before it ever reaches the event and bake it into the timeline for good, forking against
		// clients whose copy ends at the cut (lifecycle seeds 170692360, 485951509)
		int removedAfterFrame = user.removed ? user.removedAfterFrame : int.maxValue
		if inputs.writePos <= user.storedInputsUpTo and claim <= user.storedClaim and removedAfterFrame >= user.storedRemovedAfterFrame then return

		int start = user.storedInputsUpTo - (user.storedInputsUpTo mod dbChunkSize)
		while start < inputs.writePos
			int end = math.min(start + dbChunkSize, inputs.writePos)
			inputStore.put {id:"{roomId}-{user.id}-{start}", roomId, userId:user.id, start, bytes:inputs.subArrayBuffer(start to end)}
			start += dbChunkSize
		// The meta row is written after the chunks it covers: a restore may only adopt the claim
		// when it restored every byte up to writePos, so a torn write can never claim unheld bytes
		inputStore.put {id:"{roomId}-{user.id}-meta", roomId, userId:user.id, writePos:inputs.writePos, claim, removedAfterFrame}
		user.storedInputsUpTo = inputs.writePos
		user.storedClaim = claim
		user.storedRemovedAfterFrame = removedAfterFrame

	// Load the input streams stored for this room back from IndexedDB after a page refresh
	// (called by PeerNetwork.connect before the signaling connection starts). Our own stream is
	// applied immediately; the other users' streams are stashed and applied once their
	// InternalUser exists (see PeerNetwork.onJoinResponse and ServerNetwork.getOrCreateUser)
	js async void restoreInputsFromDB
		if(core.roomId <= 0 || core.localUserId == -1 || !IndexedDB.db) return;
		let rows = await core.inputStore.getAllFromIndex("roomId", core.roomId);
		core.storedStreamRows = new Map();
		for(let row of rows) {
			if(row.userId == null) continue;
			let list = core.storedStreamRows.get(row.userId);
			if(!list) core.storedStreamRows.set(row.userId, list = []);
			list.push(row);
		}
		core.applyStoredStream(input.localUser);
		// The restored bytes are pre-epoch history: this session must append after them, never
		// write into them. Setting the boundary here (not only in finishRestore) keeps it truthful
		// even when the restore protocol never runs - e.g. when we rejoin a freshly restarted server
		// that lists nobody else. Peers that hold up to this much of our old stream then accept our
		// new epoch instead of refusing it forever, and startConnected resumes our player instead
		// of writing a second Join event
		input.localUser.epochStartPos = input.localUser.inputs.writePos;
		// Users that already exist pick up their stored streams now (only happens when the
		// database open lost its 3s race against the signaling connection)
		for(let user of input.internalUsers) if(user && !user.local) core.applyStoredStream(user);

	// Apply the stored chunk rows for this user's stream (chunks are applied in order and only
	// while they extend the stream contiguously - a missing chunk ends the restore) and adopt the
	// stored claim when every byte it covers was restored - the same completeness rule
	// onStreamData uses, so an adopted claim never covers bytes we don't hold.
	// For a removed user this is what breaks the stream-loss deadlock after every survivor
	// reloaded at once: their bytes and claim reach removedAfterFrame again, so the replay parses
	// their stream up to the removal cut and certainFrame releases them
	js void applyStoredStream: InternalUser user
		if(!user || !core.storedStreamRows) return;
		let rows = core.storedStreamRows.get(user.id);
		if(!rows) return;
		core.storedStreamRows.delete(user.id); // Applied at most once, to a freshly created user
		let inputs = user.inputs;
		if(!user.local && inputs.writePos > 0) return; // Bytes already arrived over the network - the stream protocol fills the rest
		let meta = null;
		let chunks = [];
		for(let row of rows) {
			if(row.bytes) chunks.push(row);
			else meta = row;
		}
		chunks.sort((a, b) => a.start - b.start);
		for(let row of chunks) {
			if(row.start > inputs.writePos) {
				// Gap: nothing beyond it may be used
				core.log("#db Gap in user "+user.id+"'s stored input chunks: next chunk starts at "+row.start+", we have "+inputs.writePos+" -> stopping the restore here");
				break;
			}
			if(row.start + row.bytes.byteLength <= inputs.writePos) continue;
			inputs.writePos = row.start;
			inputs.insertArrayBuffer(row.bytes);
		}
		user.storedInputsUpTo = inputs.writePos;
		let claim = meta && inputs.writePos >= meta.writePos ? meta.claim : -1;
		user.storedClaim = claim;
		if(user.local) {
			// Our previous session already claimed inputs up to this frame - new records must be
			// stamped above it even when no peer is reachable to report the floor (the same rule
			// as PeerNetwork.adoptOwnClaimFloor)
			if(claim + 1 > user.inputFrame) user.inputFrame = claim + 1;
		} else if(claim > user.inputFrame) {
			user.inputFrame = claim;
			core.markRemoteChange(0);
		}
		// A persisted removal cut is re-applied BEFORE the replay parses a single record: the
		// stored stream may be longer than the cut, and the RemoveUser event that cuts it sits at
		// a later frame - parsing the discarded tail first would bake it into the timeline for
		// good (see storeUserInputsToDB). Lower-only, like every cut application. Rows written by
		// older builds have no removedAfterFrame field and restore as not-removed
		let storedCut = meta && meta.removedAfterFrame != null ? meta.removedAfterFrame : Number.MAX_SAFE_INTEGER;
		user.storedRemovedAfterFrame = storedCut;
		if(!user.local && storedCut < user.removedAfterFrame) {
			user.removed = true;
			user.removedAfterFrame = storedCut;
			core.log("#db User "+user.id+"'s stored stream carries a removal cut at frame "+storedCut+" -> the replay parses it only up to the cut");
		}
		core.log("#db Restored "+inputs.writePos+" bytes of user "+user.id+"'s stream from IndexedDB ("+chunks.length+" chunks stored for room "+core.roomId+", claim "+claim+")");
	
	openState
		file.openBinary
			int version = buffer.readInt
			Buffer finalSnapshot = {}
			buffer.readBuffer finalSnapshot
			input.handleSetState finalSnapshot
						
	openEventStream
		system.pause
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
			system.isStaging = buffer.readBool
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
				if system.isDebug then .local = true
				.startInputFrame frames
			math.setRandomSeed randomSeed
			
			if system.isDebug then system.sendClearTimeline
			frame = int.maxValue
			goToFrame targetFrame
		
	string roomString
	int roomId
	string gameId
	int localUserId

	// This tab holds the room's identity lease (a Web Lock, auto-released when the tab dies):
	// it resumes the identity stored in localStorage and is the only tab that persists to it.
	// A second live tab of the same browser joins as a brand-new player instead of stealing the
	// live identity (the Testrun206/331 two-tab theft)
	bool identityLeaseOwner
	// The Join is held back (see sendJoinMessage) until the lease decided who we are
	bool identityLeasePending

	join: string gameId, string roomString, int userId
		statistics.scheduleSendIn 30 seconds
		isPremiere = true
		initAll
		log "{system.url}"
		log "{Date.realtime.dayMonthNameYearString} {Date.realtime.hourMinuteSecondString} v{system.buildVersion}"
		log "{system.userAgent}"
		startInLobby = true
		this.gameId = gameId
		this.roomString = roomString
		this.roomId = cast roomString
		this.localUserId = userId
		this.frame = 0
		this.frames = 0
		// Local sessions reset outputIndex from -1 to 0 in core.stop, connected sessions must do it here
		this.outputIndex = 0
		input.localUser = {this.localUserId, local:true, connected:true, connectionId:0}
		// Each session tags its input stream with a fresh random epoch: peers use it to detect
		// that we restarted and lost our in-memory stream (see PeerNetwork.onTick)
		input.localUser.epoch = PeerNetwork.generateEpoch

		// A page refresh must not turn us into a new player - the old player would freeze as a
		// permanent ghost - so the identity for this room is resumed from storage. But the SAME
		// identity in two live tabs is identity theft (both fight over the id): the stored
		// identity belongs to the tab holding the room's Web Lock. requestIdentityLease decides
		// asynchronously (the Join waits, see sendJoinMessage) and onIdentityLeaseDecided adopts
		// the identity; a second live tab joins as a brand-new player instead
		if this.roomId > 0
			identityLeasePending = true
			requestIdentityLease

		// Open IndexedDB (restores the stored input streams after a page refresh), then connect to the
		// signaling server. The media setup runs in parallel: signaling doesn't need media, and
		// a media failure must never abort the join (setupLocalMedia never throws)
		PeerNetwork.connect
		PeerNetwork.setupLocalMedia
			enableVideo:not system.isStaging || core.enableVideoForStaging
			enableAudio:not system.isStaging || core.enableAudioForStaging
		lobby.enableFullscreen = !system.isStaging
		
	private js void initAll
		init()
		graphics.updateBaseMatrix();
		if(typeof _initJavaScriptApp === "function") {
			try {
				app = _initJavaScriptApp();
			} catch (error) {
				console.error("Error initializing JavaScript app:", error);
			}
		}		
		
	// Remember everything needed to rejoin this room after a page refresh (userId + session
	// token) and to recreate it on a freshly restarted server (seed, start time, highest known
	// user id). Our own identity always survives a reload of THIS tab via sessionStorage; only
	// the lease-owning tab writes the shared localStorage record (what a future tab resumes
	// after a browser restart) - a second live tab must never overwrite the owner's identity
	internal storeRoomInfo
		int maxUserId = input.localUser.id
		for input.internalUsers
			if . and .id > maxUserId then maxUserId = .id
		RoomInfo info = {currentTime, input.localUser.id, math.randomSeed, serverStartTime, maxUserId, ServerNetwork.sessionToken}
		system.setSessionStorageObject "room"+roomId, info
		if identityLeaseOwner then system.setLocalStorageObject "room"+roomId, info

	// The identity we may resume for this room: this tab's own (sessionStorage - a reload of
	// this tab always continues as the same player), falling back to the browser's stored
	// identity (localStorage) only for the tab that holds the identity lease
	internal RoomInfo getStoredRoomInfo
		RoomInfo own = system.getSessionStorageObject("room"+roomId)
		if own then return own
		if identityLeaseOwner then return system.getLocalStorageObject("room"+roomId)
		return null

	// Requests this room's identity lease: an exclusive, origin-wide Web Lock the browser
	// auto-releases when the holding tab closes, crashes or navigates. Exactly one tab per
	// browser profile owns a room's stored identity at any time - a second live tab must not
	// claim it (identity theft, see the identity-contention spec). The request stays queued in
	// the background after losing the initial decision: when the owner tab closes, the
	// surviving tab inherits the persistence duty (onIdentityLeaseAcquiredLate)
	internal js void requestIdentityLease
		const name = "livetime-identity-" + core.roomId;
		let decided = false;
		const decide = owner => {
			if(decided) return;
			decided = true;
			if(core.identityLeasePending) { core.identityLeasePending = false; core.onIdentityLeaseDecided(owner); }
		};
		if(!(navigator.locks && navigator.locks.request)) {
			// No Web Locks API (old browser): behave like before the lease existed - this tab
			// uses the shared localStorage identity
			core.identityLeaseOwner = true;
			decide(true);
			return;
		}
		try {
			navigator.locks.request(name, () => {
				const late = decided || !core.identityLeasePending;
				core.identityLeaseOwner = true;
				decide(true);
				if(late) core.onIdentityLeaseAcquiredLate();
				return new Promise(() => {});  // Hold the lease until this tab dies
			}).catch(() => decide(false));
			// Decision window: a closing owner tab (the user just closed it, a browser session
			// restore is racing us) releases the lease within moments - give it a second before
			// concluding a live tab owns the identity and we are a second player
			setTimeout(() => decide(false), 1000);
		} catch(e) {
			core.identityLeaseOwner = true;
			decide(true);
		}

	// The lease decided who we are - adopt the stored identity (or none) and let the held-back
	// Join go out (see sendJoinMessage)
	internal onIdentityLeaseDecided: bool owner
		RoomInfo info = getStoredRoomInfo
		if localUserId == -1
			if info and currentTime - info.time < 24 hours
				localUserId = info.userId
				input.localUser.id = info.userId
				ServerNetwork.sessionToken = info.token or ""
				log "Rejoining room {roomId} as stored user {localUserId}"
			else if not owner
				log "Another tab of this browser holds this room's identity -> joining as a new player"
		else if info and info.userId == localUserId and info.token
			// Preassigned id (staging x-suffix): the identity is fixed, the lease only decides
			// where it is persisted - but the session token proving the id is ours still comes
			// from storage
			ServerNetwork.sessionToken = info.token

	// The lease was granted after the initial decision: the owner tab closed and we (the
	// surviving tab) inherit the persistence duty, or we opened a brand-new room whose lease was
	// free. From now on our identity survives a browser restart via localStorage
	internal onIdentityLeaseAcquiredLate
		log "#server This tab now holds the identity lease for room {roomId}"
		if ServerNetwork.joined and input.localUser and input.localUser.id != -1
			storeRoomInfo

	// A checksum received over the network (carried in the trailing fields of every peer and
	// server-relay Tick). When we haven't computed ours for that frame yet, store theirs -
	// saveState compares against it once its own snapshot reaches that frame
	internal onRemoteChecksum: int checksumFor, float checksum, int roster
		// StreamData and Tick handlers can append old history and then receive a checksum before
		// the next onFrame. Detect the resulting below-pin fork first; comparing a checksum from
		// that history against our already-certified snapshot would be a false desync.
		if checkForForkBelowSnapshot then return
		if hasChecksum checksumFor
			if getChecksumRoster(checksumFor) != roster
				// The sender computed its state from a different roster (a fork after a
				// partition) - the values are incomparable, see getChecksumRoster
				logRosterSkip checksumFor
				return
			float myChecksum = getChecksum checksumFor
			if myChecksum != checksum then onWrongChecksum checksumFor, mine:myChecksum theirs:checksum
		else
			setChecksum checksumFor, checksum, roster

	string snapshotLogWithWrongChecksum

	private int wrongChecksumCount

	onWrongChecksum: int frame, float mine, float theirs
		string message = " Out of sync. frame:{frame} mine:{mine} theirs:{theirs}"
		string serializeLog = serializeLogs[frame mod 100]
		core.log message
		if not snapshotLogWithWrongChecksum
			snapshotLogWithWrongChecksum = "frame:{frame} mine:{mine} theirs:{theirs}\n{serializeLog}"
			core.log "\n{serializeLog}"
			// file.saveText "{input.localUser.id}-snapshot{frame}.json", serializeLog
		onError {message}

		// Self-heal from a persistent divergence: reload the page and rebuild the state by
		// replaying the streams as the mesh holds them (our own inputs survive in IndexedDB and
		// on our peers). Rate-limited inside selfHealReload to avoid reload loops
		if ++wrongChecksumCount >= 3 and mode == Connected and not system.isDebug
			statistics.scheduleSendIn 0 seconds
			PeerNetwork.selfHealReload "out of sync at frame {frame}"
		
	onError: Error error
		if error.message == "interrrupt" then return
		errorMessage = error.stack
		hasErrors = true
		errorCount++
		if(core.runningTest || system.isDebug) {
			addOutput "exception|{errorMessage}||0"
			sendOutputToEditor
		} else {
			core.log errorMessage
		}
		system.logError error
		if system.isDebug
			// Advance frame on error to ensure the current frame is replayed
			frame++
			if frames < frame	then frames = frame
			if frame > frameWithNewWatches	then frameWithNewWatches = frame

			system.pause()
		
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
	
global transient skipInit unit system
	// Reset all variables to their initial value and restart the app
	global inline restart() core.restart
		
	global inline refresh()
		
	// Prints a message to the console
	global js void print: logstring text	// The text, variables or expressions to print
	                      PrintType type = Info	// Action: Action performed by a player, Reaction: Consequence of an action, Debug: Temporary debug information, Info: Information, Error: Error, Warning: Warning
						  Color color = null	// The color to use when showing the message in the console or the event stream panel
		                  void() drawDebugInfo = null	// A function that will be called to draw debug information.
		                  SourceCodeLocation location
		if((core.runningTest || system.isDebug) && location) {
			if(color) console.log(`%c${text}`, `color: ${color.hex}`)
			else      console.log(text)
			if(drawDebugInfo != null && core.outputIndex == core.interrruptAtOutputIndex) {
				graphics.isDrawingDebugInfo = true
				drawDebugInfo()
				graphics.isDrawingDebugInfo = false
			}
			core.addOutput(`${type}|${text}|${location.file}|${location.start}|${color ? color.hex : ""}`)
		} else {
			core.log(text);
		}

	global debug: void() drawDebugInfo
		if system.isDebug
			graphics.isDrawingDebugInfo = true
			drawDebugInfo()
			graphics.isDrawingDebugInfo = false

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
	const url = "signal.up4playing.com"
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

		// Only outside an active send: a send in flight references absolute indices
		if not currentlySendingStatistics then trimSentData

	// Drop data that was already flushed to the statistics server, so logs, pings and graph
	// values don't grow for the whole session (F28/F29). A tail of the graph values is kept
	// for the on-screen debug graphs, and a hard cap bounds the graphs even when the
	// statistics server is unreachable for a long time
	private trimSentData
		if successfullySentSystemLogs > 0
			systemLogs.removeRange 0..successfullySentSystemLogs
			successfullySentSystemLogs = 0
		if successfullySentGameLogs > 0
			gameLogs.removeRange 0..successfullySentGameLogs
			successfullySentGameLogs = 0
		if successfullySentServerPings > 0
			serverPings.removeRange 0..successfullySentServerPings
			successfullySentServerPings = 0
		for graphs as graph
			int removeCount = math.min(graph.successfullySentUntil, graph.values.length - 150)
			if graph.values.length > 10000 then removeCount = graph.values.length - 5000
			if removeCount > 0
				graph.values.removeRange 0..removeCount
				graph.successfullySentUntil = math.max(graph.successfullySentUntil - removeCount, 0)

	// Log game events (like scores, playtimes, etc)
	log: dynamic value
		value.frame = Time.ticks
		this.gameLogs.add value
		// Bound the unsent backlog when the statistics server is unreachable (F29)
		if gameLogs.length > 10000
			gameLogs.removeRange 0..5000
			successfullySentGameLogs = math.max(successfullySentGameLogs - 5000, 0)
	
	private startSession
		// Debug sessions never post statistics. Checked before anything else: the old code
		// returned AFTER setting currentlySendingStatistics, leaving the flag stuck true for
		// the whole session (trimSentData disabled, tick re-entering forever)
		if system.isDebug then return
		core.log "#statistics Start Session"
		if currentlySendingStatistics then return
		currentlySendingStatistics = true

		let user = storage.getObjectDirectly("user")
		let server = system.hostname.getUntil(".")
		let userId = input.localUser.id
		id = core.roomId*100 + userId
		int sendingSystemLogsUntil = systemLogs.length

		http.postDirectly "{url}/startSession", body:{
			id
			gameId: core.gameId
			roomId: core.roomId
			userId
			userIndex: input.localUser.index
			userEmail: user.email
			version: system.buildVersion
			staging: system.isStaging
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
		if system.isDebug then return
		core.log "#statistics Send Statistics"
		if currentlySendingStatistics then return
		currentlySendingStatistics = true
		
		// Compile server and peer pings to send
		string[] connections
		for input.players as p
			let internalUser = input.internalUsers[.id]
			connections.add internalUser.connectionType
			
		for graphs
			.valuesToSend = .values[.successfullySentUntil..]
			.sendingUntil = .values.length

		int sendingServerPingsUntil = serverPings.length
		int sendingSystemLogsUntil = systemLogs.length
		int sendingGameLogsUntil = gameLogs.length
			
		// Send statistics to server
		http.postDirectly "{url}/saveStatistics", body:{
			id
			connections
			graphLabels: graphs.map.label
			graphs: graphs.map.valuesToSend
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
		// Only the recent infos are ever drawn (F29)
		if infos.length > 1000 then infos.removeRange 0..500
		
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
					
		this.draw??()

unit networkVisualizer		
	visible int[] posForPlayer = [0,-10000,-10000,-10000,-10000,-10000]
		
	internal tick
		if core.simulateInputsForTesting
			for input.players
				if posForPlayer[.playerIndex] == -10000 then posForPlayer[.playerIndex] = posForPlayer[0]
					
			// Move circle with artificially created inputs to test the smoothness
			for input.players as player
				core.smooth player
					input.onKeyDown by:player
						if (posForPlayer[player.playerIndex] += 2) > 1080
							posForPlayer[player.playerIndex] -= 1080
				
		this.draw??()
				
	private getHeightForFrame: int frame
		return (50+frame-core.frame)*20

tests
	// Used internally in the compiled code. Do not call in your code.
	//     expect players.length == 2    ->    tests.expectToBeEqual(`players.length`, players.length, 2, new SourceCodeLocation("tests/tests.l", 69312, 69317, null, null));
	importance:-1
	internal expectToBeEqual: string expressionString
	                          dynamic actual
		                      dynamic expected
				              SourceCodeLocation location
		if core.interrruptAtOutputIndex != -1 or core.targetFrame != -1
			core.outputIndex++
			return
		string actualString, expectedString, result
		try	actualString = json.stringify(actual)
		catch	actualString = actual?.toString()
		if actual == expected
			result = "+"
		else
			result = "-"
			core.errorCount++
			try		expectedString = json.stringify(expected)
			catch		expectedString = expected?.toString()
			system.log "FAIL {expressionString}: expected {expectedString}, but got {actualString}";
		core.addOutput "expect|{expressionString}|{result}|{actualString}|{expectedString}|{location.file}|{location.start}"

	// Used internally in the compiled code. Do not call in your code.
	//     expect players.all.ready      ->    tests.expectToBeTrue(`players.all.ready`, players.all.ready, new SourceCodeLocation("tests/tests.l", 69312, 69317, null, null));
	importance:-1
	internal expectToBeTrue: string expressionString
	                         dynamic actual
				             SourceCodeLocation location
		if core.interrruptAtOutputIndex != -1 or core.targetFrame != -1
			core.outputIndex++
			return
		string actualString
		try	actualString = json.stringify(actual)
		catch	actualString = actual?.toString()
		string result = actual ? "+" : "-"
		if not actual
			core.errorCount++
			system.log "FAIL {expressionString}: expected true, but got {actualString}";
		core.addOutput "expect|{expressionString}|{result}|{actualString}|true|{location.file}|{location.start}"
	
	// Used internally. Do not call in your code.
	internal tick
		system.log "### tick core.frame:{core.frame} core.targetFrame:{core.targetFrame} "
		// if core.frame <= core.targetFrame
		system.fastForward = core.frame != core.targetFrame
		core.tick draw:core.frame == core.targetFrame
