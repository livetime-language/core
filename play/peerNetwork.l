// Resilient netcode for LiveTime
//
// system.start -> core.join -> PeerNetwork.connect
//
// ServerNetwork (signaling + relay fallback + clock sync)
//     setupServerConnection      Connects the WebSocket, rotates through candidate URLs, reconnects forever
//     onConnectedToServer        Sends Join (with recovery info so a restarted server can recreate the room)
//     onJoinResponse             Creates the users already in the room -> PeerNetwork.initiate for each
//     tick                       Reconnect, ping cadence, slew core.startTime toward the reference
//     onPong                     Clock sync: estimate the shared room start time, detect clock steps
//     relay                      Wraps any peer message so it travels via the server when the data channel is down
//
// PeerNetwork (WebRTC mesh + deterministic input streams)
//     initiate                   Creates a peer connection as the offerer
//     onReceivedOffer/Answer/Ice Perfect negotiation with a polite/impolite rule
//     tick                       Peer health, ICE restarts, reconnect notifications, removal of dead players
//     sendInputs                 Ack-driven idempotent Ticks, record-aligned chunking, channel or server relay
//     onTick                     Contiguous append of input bytes at explicit positions, claims, checksums
//     StreamRequest/StreamData   Any user's input stream can be fetched from any peer (rejoin restore,
//                                catch-up after removal, pre-removal gossip)
//
// Transport rules
//     Every peer message can travel over the unreliable data channel or, when that is not open,
//     wrapped in a Relay message over the signaling WebSocket. Both paths deliver the same bytes and
//     every handler is idempotent (explicit positions, contiguous appends, max-claims), so duplicates,
//     reordering and losses on any path are harmless.

// Messages between a client and the signaling server
enum ServerMessageType: Join, JoinResponse, Ping, Pong, Relay

// Messages between two peers (via data channel or wrapped in a server Relay)
enum PeerMessageType: Tick, Ping, Pong, Offer, Answer, IceCandidate, StreamRequest, StreamData, Status, Leaving, Removed

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

// The connection to the signaling server
internal transient skipInit unit ServerNetwork
	// Must match protocolVersion in server/main.go, sent in Join and verified in JoinResponse
	const int protocolVersion = 2
	private object socket
	private Buffer sendBuffer = {}
	int nextConnectionId = 1
	bool connected
	bool joined              // We received a JoinResponse over the current or an earlier connection
	// The server registers our membership per connection: every new socket needs its own
	// JoinResponse before relays flow. Reset in setupServerConnection, drives the Join resend
	bool joinedOnThisConnection
	float startToConnectTime = float.maxValue
	int retries

	tick
		// Use core.currentTime (monotonic) like onPong: the ping time below round-trips through the
		// server and is subtracted from core.currentTime there, so both must share one clock
		let now = core.currentTime

		// While playing, a better ping estimate must not snap core.startTime - targetFrame would
		// jump or stall - so onPong only updates referenceStartTime once we are Connected and we
		// slew startTime toward it here, at most about one frame per second
		if core.mode == Connected and referenceStartTime
			let maxAdjust = (now - lastSlewTime) * core.frameTime / 1000
			core.startTime += math.max(math.min(referenceStartTime - core.startTime, maxAdjust), -maxAdjust)
		lastSlewTime = now

		// Reconnect to server: Try again if we aren't connected some time after starting to connect.
		// The timeout grows with every failed attempt (5s up to 20s): on a high-latency link the
		// TCP+TLS+WebSocket handshake alone can take ~5s, so a fixed 5s cutoff would abort every
		// almost-complete attempt forever (seen with 600ms delay: ~5 minutes to join).
		// This never gives up: when the server restarts or the internet drops for minutes, the next
		// attempt after the outage succeeds and the re-join recovers the room
		if not connected and now > startToConnectTime + 5000 + math.min(retries, 5) * 3000
			core.log "#server WebSocket not connected after {now - startToConnectTime} ms -> Reconnecting (try {retries+1})"
			setupServerConnection
			retries++

		// The Join itself can be swallowed by a half-dead connection (socket open, nothing flows):
		// without the JoinResponse for THIS socket the server doesn't know us and we would sit
		// connected-but-unregistered indefinitely, sending nothing the server reacts to.
		// The Join is idempotent - resend it until the response arrives
		if connected and not joinedOnThisConnection and now > lastJoinSentTime + 2000
			core.log "#server No JoinResponse after {math.round(now - lastJoinSentTime)} ms -> Resending Join"
			sendJoinMessage

		// Ping for clock sync (fast until we have a stable estimate, then slow)
		if (core.mode == Ping or core.mode == Connected) and now >= nextPingTime
			sendBuffer.reset
			sendBuffer.writeInt8 cast ServerMessageType.Ping
			sendBuffer.writeFloat64 now
			send sendBuffer
			nextPingTime = now + (core.mode == Ping ? 200 : pongCount < 20 ? 1000 : 30000)

	js void setupServerConnection
		// Same monotonic clock as core.currentTime (inlined here: js blocks can't call inline functions)
		ServerNetwork.startToConnectTime = Math.round(performance.timeOrigin + performance.now())
		ServerNetwork.connected = false
		ServerNetwork.joinedOnThisConnection = false

		if(ServerNetwork.socket) {
			core.log("#server Closing Previous Websocket");
			ServerNetwork.socket.onopen = null
			ServerNetwork.socket.onclose = null
			ServerNetwork.socket.onmessage = null
			ServerNetwork.socket.onerror = null
			try { ServerNetwork.socket.close() } catch {}
		}

		// Candidate URLs: the page's own origin first (the Go server serves the page and the
		// WebSocket from one executable), then the well-known endpoints. While we never managed to
		// connect we rotate through the candidates; once a URL worked we stick to it, because the
		// room lives on that server
		if(!ServerNetwork.serverUrls) {
			let urls = [];
			// An explicit ?server=ws://host:port/ws in the page URL wins - used by the e2e tests
			// (which start servers on random ports) and for pointing a client at a staging server
			try {
				let override = new URLSearchParams(location.search).get("server");
				if(override) urls.push(override);
			} catch {}
			if(location.hostname == "localhost" || location.hostname == "127.0.0.1")
				urls.push("ws://localhost:3112/ws");
			else
				urls.push("wss://signal.up4playing.com/ws");
			ServerNetwork.serverUrls = [...new Set(urls)];
			ServerNetwork.serverUrlIndex = 0;
		}
		let url = ServerNetwork.serverUrls[ServerNetwork.serverUrlIndex % ServerNetwork.serverUrls.length];
		if(!ServerNetwork.joined) ServerNetwork.serverUrlIndex++;

		core.log("#server Creating Websocket to "+url);
		ServerNetwork.socket = new WebSocket(url);
		ServerNetwork.socket.binaryType = "arraybuffer";

		ServerNetwork.socket.onopen = () => {
			core.log("#server Websocket Open ("+url+")");
			ServerNetwork.connected = true;
			// A later outage starts with the fast 5s timeout again
			ServerNetwork.retries = 0;
			// Stick to the URL that worked for all future reconnects
			ServerNetwork.serverUrls = [url];
			ServerNetwork.serverUrlIndex = 0;
			ServerNetwork.workingServerHost = new URL(url.replace("ws://", "http://").replace("wss://", "https://")).hostname;
			ServerNetwork.onConnectedToServer();
		}
		ServerNetwork.socket.onclose = ev => {
			core.log("#server Websocket Closed "+ev.code+" "+ev.reason);
			ServerNetwork.connected = false;
		}
		ServerNetwork.socket.onerror = ev => {
			core.log("#server Websocket Error");
			ServerNetwork.connected = false;
		}
		ServerNetwork.socket.onmessage = ev => {
			ServerNetwork.onMessageFromServer(new Buffer(ev.data, 0, 0, 0));
		}

	// The hostname of the signaling server that accepted us - the TURN server lives on the same machine
	string workingServerHost

	private getOrCreateUser: int id
		let existing = input.internalUsers[id]
		if existing then return existing
		InternalUser user = {id, local:false}
		input.internalUsers[id] = user
		// A user appearing mid-session invalidates every prediction (their records may sit at
		// any frame above the pin) - force the next pass back to the pinned snapshot
		core.markRemoteChange 0
		// Keep the stored room recovery info aware of every user we ever saw: after a server
		// restart the first rejoiner's maxKnownUserId is what tells the server (and through its
		// user list, everyone else) that the currently unreachable users exist at all
		if core.roomId > 0 and input.localUser then core.storeRoomInfo
		return user

	// Called when we first connect to the server or when we reconnect
	private onConnectedToServer
		core.log "#server Connected to Server", input.localUser.id, core.roomId
		sendJoinMessage

	js int bufferedAmount
		return ServerNetwork.socket ? ServerNetwork.socket.bufferedAmount : 0

	private js int send: Buffer buffer
		try {
			if(!ServerNetwork.socket || ServerNetwork.socket.readyState != 1) return 0
			let data = buffer.toByteArray()
			ServerNetwork.socket.send(data)
			return data.byteLength
		} catch(e) {
			core.log("#server send failed: "+e.message)
			return 0
		}

	private onMessageFromServer: Buffer buffer
		try
			int typeValue = buffer.readInt8
			if typeValue == cast ServerMessageType.JoinResponse	then onJoinResponse buffer; else
			if typeValue == cast ServerMessageType.Pong	then onPong buffer; else
			if typeValue == cast ServerMessageType.Relay	then onRelay buffer
			else	core.log "#error Unknown server message type {typeValue} - client/server version mismatch?"
		catch
			core.log "#error Failed to handle server message ({buffer.writePos} bytes): {error.stack}"

	private float lastJoinSentTime

	// The Join carries everything a freshly restarted server needs to recreate the room:
	// seed, start time and the highest user id we know. This is what makes a server restart
	// invisible to the players - the first client to reconnect rebuilds the room
	private sendJoinMessage
		lastJoinSentTime = core.currentTime
		RoomInfo info = system.getLocalStorageObject("room"+core.roomId) or {}
		string seed = core.mode == Connected ? math.randomSeed : (info.seed or "")
		float serverStartTime = core.mode == Connected ? core.serverStartTime : (info.serverStartTime or 0)
		float elapsed = 0
		if core.mode == Connected	then elapsed = core.currentTime - core.startTime
		else if info.serverStartTime	then elapsed = core.currentTime - info.serverStartTime
		int maxKnownUserId = -1
		for input.internalUsers if . and .id > maxKnownUserId
			maxKnownUserId = .id
		if info and info.maxUserId > maxKnownUserId then maxKnownUserId = info.maxUserId

		// The recovery fields are what a freshly restarted server rebuilds the room from - log
		// them so a bad recovery (wrong seed, wrong time base) can be traced from both sides
		core.log "#server Sending Join: room:'{core.roomString}' userId:{input.localUser.id} v{system.buildVersion} protocol:{protocolVersion} recovery(seed:{seed ? seed : "-"} serverStartTime:{serverStartTime} elapsed:{math.round(elapsed)}ms maxKnownUserId:{maxKnownUserId})"

		sendBuffer.reset
		sendBuffer.writeInt8 cast ServerMessageType.Join
		sendBuffer.writeString core.roomString
		sendBuffer.writeInt32 input.localUser.id
		sendBuffer.writeInt32 system.buildVersion
		sendBuffer.writeInt16 protocolVersion
		sendBuffer.writeString seed
		sendBuffer.writeFloat64 serverStartTime
		sendBuffer.writeFloat64 elapsed
		sendBuffer.writeInt32 maxKnownUserId
		send sendBuffer

	bool alreadyJoinedBefore

	private onJoinResponse: Buffer buffer
		try
			// Read the fields in the exact order the server writes them in server/main.go
			int roomId = cast buffer.readFloat64
			let userId = buffer.readInt32
			let version = buffer.readInt32
			let serverProtocolVersion = buffer.readInt16
			if serverProtocolVersion != protocolVersion
				core.log "#server Protocol version mismatch: client uses {protocolVersion}, server uses {serverProtocolVersion}."
			let seed = buffer.readString
			let serverStartTime = buffer.readFloat64
			let userCount = buffer.readInt16

			joined = true
			joinedOnThisConnection = true

			if alreadyJoinedBefore
				// We re-joined after a WebSocket reconnect. The WebRTC peer connections are not
				// affected by a signaling outage, so the first-join setup must not run again.
				// New users may have joined the room while we were away - create them so the
				// health loop connects to them
				string rejoinUsers = ""
				for userCount
					let id = buffer.readInt32
					let present = buffer.readBool
					rejoinUsers += " {id}:{present ? "up" : "away"}"
					if id != input.localUser.id
						let user = getOrCreateUser id
						user.presentOnServer = present
				core.log "#server Rejoined room {roomId} as user {userId} (seed:{seed} serverStartTime:{serverStartTime} users:{rejoinUsers})"
				if roomId != core.roomId or userId != input.localUser.id
					core.log "#error Rejoin resolved to a different identity! expected room {core.roomId} user {input.localUser.id}, received room {roomId} user {userId}"
				return
			alreadyJoinedBefore = true

			string joinUsers = ""
			for userCount
				let id = buffer.readInt32
				let present = buffer.readBool
				InternalUser user
				if id == userId then user = input.internalUsers[id] ?= input.localUser
				else             user = input.internalUsers[id] ?= {offerByMe:true, connectionId:nextConnectionId++}
				user.id = id
				user.presentOnServer = present
				joinUsers += " {id}:{present ? "up" : "away"}"
			core.log "#server JoinResponse: room:{roomId} userId:{userId} v{version} protocol:{serverProtocolVersion} seed:{seed} serverStartTime:{serverStartTime} users:{joinUsers}"

			if roomId != core.roomId
				core.log "#server Received room id {roomId}"
				system.pushState "/{core.gameId}/{roomId}"
				core.roomId = roomId

			// Re-joins after a WebSocket reconnect must resolve to this exact room
			core.roomString = roomId.toString

			if version > system.buildVersion
				alert "You are using an old version of this application. Please refresh your browser."

			input.localUser.id = userId
			math.setRandomSeed seed
			PeerNetwork.retries = 0
			PeerNetwork.dataChannelId = 0
			core.serverStartTime = serverStartTime
			core.mode = Ping
			core.storeRoomInfo
			core.log "#server Joining room {roomId} as user {userId}"

			// Create an offer for each user already in the room
			for input.internalUsers
				if . and not .local and .presentOnServer
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

		statistics.serverPings.add pingPongTime

		// Ignore extreme outliers: pings that took at least three times as long as the link's own
		// average round trip. Never use an absolute cutoff - the link itself may have extremely
		// high latency and must still be able to sync
		pongCount++
		pingPongTimes.add pingPongTime maxLength:30
		let pingPongTimesAverage = pingPongTimes.average
		if pingPongTimes.length >= 15 and pingPongTime > pingPongTimesAverage * 3
			core.log "#server ignoring ping-pong outlier", pingPongTime, pingPongTimesAverage
			return

		// An accepted pong's start-time estimate is off by at most pingPongTime/2, so a much
		// larger deviation means the clock domains shifted: the machine slept or was suspended and
		// performance.now paused while the server clock kept running. Slewing can't absorb minutes
		// -> relearn the reference and snap startTime (the catch-up burst after the snap is budgeted)
		// The threshold scales with the round trip so extremely high latency isn't mistaken for a step
		if core.mode == Connected and math.abs(calculatedStartTime - core.startTime) > math.max(1000, pingPongTime)
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
			// Once Connected, tick slews startTime gently toward the reference instead
			if core.mode != Connected
				core.startTime = referenceStartTime

			core.log "#server New fastest pingPongTime", pongCount, now, pingPongTime, timeSinceStart, core.startTime, referenceStartTime

		// While we restore our previous session's input stream (from IndexedDB and our peers),
		// we keep pinging and only start the session when the restore settled
		if pongCount >= 5 and not PeerNetwork.restoring
			core.startConnected frame:math.floor((now - core.startTime)/core.frameTime)+1

	// Wrap a peer message so the server forwards it to the receiver - the fallback transport
	// whenever the data channel to that peer is not open
	relay: int receiverId, Buffer message
		if not connected then return
		sendBuffer.reset
		sendBuffer.writeInt8 cast ServerMessageType.Relay
		sendBuffer.writeInt32 receiverId
		sendBuffer.copyFromBuffer message
		send sendBuffer

	private onRelay: Buffer buffer
		let senderId = buffer.readInt32
		if senderId == input.localUser.id then return
		let sender = getOrCreateUser senderId
		PeerNetwork.onPeerMessage sender, buffer, viaServer:true

internal transient skipInit unit PeerNetwork
	RelayMode relayMode = Auto

	internal enableVideo = true
	internal enableAudio = true

	visible string error
	int retries
	int dataChannelId
	private object mediaSetupPromise
	private bool retryingMedia
	Buffer sendBuffer = {}

	// TURN credentials for the embedded TURN server in the Go executable
	// (must match the -turn-user/-turn-password flags of the server)
	const string turnUsername = "livetime"
	const string turnPassword = "u9zK2mFq7RxWc4bT8nHd3vGs6yLpJa5e"

	// A user is considered gone for good (and removed from the game) after this much silence
	// (variables instead of consts so resilience tests can shorten them)
	float removalGraceMillis = 60000
	// How long the host merges the silent user's stream from all peers before removing them
	float removalGossipMillis = 10000
	// The app is told that we are trying to reconnect to a user after this much silence
	float reconnectNotifyMillis = 4000
	// An open data channel that has neither delivered a message nor acked our outstanding bytes
	// for this long is silently dead until proven otherwise (half-dead NAT, dying router): every
	// peer message is then mirrored over the server relay, so inputs and repair offers keep
	// flowing within seconds of an outage instead of stalling until a reconnect happens to close
	// the channel. The protocol is idempotent and ack-driven, so duplicates are harmless
	float channelSuspectMillis = 3000

	// --------------------------------------------- Connect ---------------------------------------------

	// Called once from core.join: open IndexedDB and restore our own inputs, then connect to the
	// signaling server. The media setup runs in parallel (core.join starts it right after)
	connect
		setupBackgroundBehaviour
		openDatabaseAndConnect

	// The database open must never block the join for long and must never abort it:
	// any failure (private mode, quota) just means we join without local input persistence
	private js async void openDatabaseAndConnect
		try {
			await Promise.race([
				(async () => {
					await IndexedDB.start("up4playing", 2);
					await core.restoreOwnInputsFromDB();
				})(),
				new Promise(resolve => setTimeout(resolve, 3000))
			]);
		} catch(e) {
			core.log("#db IndexedDB not available: "+(e && e.message));
		}
		ServerNetwork.setupServerConnection();

	// --------------------------------------------- Tick (peer health) ---------------------------------------------

	tick
		// All peer-health, removal and restore timers run on core.currentTime (monotonic) for the
		// same reason frame pacing does: Date.now() steps arbitrarily on NTP corrections, manual
		// clock changes and resume. A forward step would make every peer look silent at once
		// (reconnect churn on healthy links, spurious removal gossip); a backward step would put
		// every watchdog to sleep for the step duration
		let now = core.currentTime
		ServerNetwork.tick

		// After a rejoin, restore our previous session's input stream from our peers
		// before the session starts (ServerNetwork.onPong waits until this settled)
		if restoring then tickRestore now

		// After a restore that ended with unconfirmed peers, keep asking them for our history
		// until every live peer confirmed its holdings - only then may we append new inputs
		if holdingConfirmationPending and not restoring then tickHoldingConfirmations now

		// Handle a removal of our own player that was parsed from the event stream
		if core.mode == Connected and not system.isDebug and input.localUser and input.localUser.removed then onRemovedNotice

		// Ping peers once per second (RTT statistics and channel liveness)
		if now > lastPeerPingTime + 1000
			lastPeerPingTime = now
			pingPeers

		for input.internalUsers as user
			if . and not .local and not .removed
				// A user we never heard from starts its silence timers when we first see it, so
				// zombie entries (listed by the server but never sending) are eventually removed
				// instead of blocking certainty forever
				if .lastIncomingMessageTime == float.maxValue then .lastIncomingMessageTime = now
				if .lastIncomingChannelTime == float.maxValue then .lastIncomingChannelTime = now
				if .lastChannelMessageTime == float.maxValue then .lastChannelMessageTime = now
				if .lastAckProgressTime == float.maxValue then .lastAckProgressTime = now
				// A peer with nothing outstanding is not ack-stalled (see channelSuspect)
				if input.localUser and .receivedMyInputsUpToPos >= input.localUser.inputs.writePos then .lastAckProgressTime = now

				// Tell the app when a user has fallen silent on every transport, so it can show
				// a "trying to reconnect" hint. Any incoming message clears the notification
				if now > .lastIncomingMessageTime + reconnectNotifyMillis and not .reconnectNotified and core.mode == Connected
					.reconnectNotified = true
					app.onTryingToReconnectTo??(.id)

				// A leaving peer is gone on purpose (tab closed or navigated away) - reconnect
				// attempts would be pointless churn; any later message clears the flag
				if not .leaving
					// Reconnect the peer connection if the data channel has been silent for a while.
					// The timeout grows with consecutive fruitless reconnects (10s up to 30s): over a
					// high-latency TURN relay, signaling+ICE+DTLS take longer than 10s, and a fixed
					// cutoff would keep killing connections right before the channel opens.
					// A hidden tab is throttled and may fall silent - tolerate a longer silence
					float channelSilenceTimeout = .hidden ? 60000 : 10000 + math.min(.channelReconnects, 4) * 5000
					if now > .lastIncomingChannelTime + channelSilenceTimeout
						core.log "[{Time.ticks}] <{.id}> #problem ------ State is {.connectionState} after {now-.startToConnectTime} ms, {.connectionTries} retries, last channel message {now - .lastIncomingChannelTime} ms ago, offerByMe:{.offerByMe} ------"
						.startToConnectTime = .lastIncomingChannelTime = now
						.channelReconnects++
						statistics.scheduleSendIn 3 seconds

						if .offerByMe
							retries++
							if ++.connectionTries < 3
								core.log "#peer <{.id}> Restarting ICE (offer by me)"
								restartIce .
							else
								core.log "#peer <{.id}> Recreate peer connection (offer by me)"
								initiate .
						else
							// The answerer must not wait for a new offer forever: the offerer may be
							// gone for good, or both peers ended up as answerers after crossing offers.
							// Give the offerer one full silence period to reconnect us first, then take over
							if ++.silentPeriods >= 2
								retries++
								core.log "#peer <{.id}> Recreate peer connection (answer by me, taking over as offerer)"
								initiate .

				// Removal of users that are gone for good, decided by the host (the lowest-id living
				// user) and made deterministic by writing a RemoveUser event into the host's input
				// stream. Before writing the event, the host gossips: it fetches the user's stream
				// from every living peer, so the removal frame covers everything any client committed
				if core.mode == Connected and amHost and now > .lastIncomingMessageTime + removalGraceMillis and not .removalEventWritten
					if .removalGossipStart == 0
						.removalGossipStart = now
						core.log "#removal <{.id}> Starting removal gossip (silent for {now - .lastIncomingMessageTime} ms)"
					if now > .removalGossipStart + removalGossipMillis
						.removalEventWritten = true
						core.log "#removal <{.id}> Writing RemoveUser event, lastFrame:{.inputFrame}"
						input.handleRemoveUser .id, .inputFrame

		// Fetch missing input stream bytes (rejoin restore is handled in tickRestore):
		// - a removed user whose stream we don't fully have yet (we heard about the removal
		//   before we received all their inputs)
		// - a user in removal gossip (the host merges everything the mesh knows before removing)
		if now > lastStreamFetchTime + 1000
			lastStreamFetchTime = now
			for input.internalUsers as user
				if . and not .local
					bool missingRemovedBytes = .removed and .inputFrame < .removedAfterFrame
					bool gossiping = .removalGossipStart != 0 and not .removalEventWritten
					if missingRemovedBytes or gossiping
						string reason = missingRemovedBytes ? "removed but incomplete" : "removal gossip"
						core.log "#stream Requesting user {.id}'s stream from all peers ({reason}): we hold {.inputs.writePos} bytes, claims up to {.inputFrame}, removedAfterFrame:{.removedAfterFrame}"
						requestStreamFromAllPeers .id

		// The periodic status summary: one block every 10 seconds with everything needed to
		// diagnose a field report from the logs alone - per-peer connection state, transports,
		// stream positions, claims, silences and drop counters
		if core.mode != None and now > lastStatusLogTime + 10000
			lastStatusLogTime = now
			logStatusSummary now

	private float lastPeerPingTime
	private float lastStreamFetchTime
	private float lastStatusLogTime

	private logStatusSummary: float now
		let localUser = input.localUser
		string wsState = ServerNetwork.connected ? "up" : "DOWN"
		if not ServerNetwork.joined then wsState += " not-joined"
		string modeFlags = ""
		if restoring then modeFlags += " RESTORING"
		if holdingConfirmationPending then modeFlags += " HOLDING-GATE"
		if core.catchingUp then modeFlags += " CATCHING-UP"
		// behind: how far the frame loop lags the shared clock (should be 0..1)
		// drift: how far core.startTime is from the pong-derived reference (slew should keep it near 0)
		int framesBehind = math.floor((core.currentTime - core.startTime)/core.frameTime)+1 - core.frame
		int clockDrift = ServerNetwork.referenceStartTime ? math.round(ServerNetwork.referenceStartTime - core.startTime) : 0
		string summary = "#status frame:{core.frame} certain:{core.certainFrame} lag:{core.frame - core.certainFrame} behind:{framesBehind} drift:{clockDrift}ms players:{input.players.length} ws:{wsState} host:{amHost}{modeFlags} me:<{localUser.id}> epoch:{localUser.epoch} writePos:{localUser.inputs.writePos} epochStart:{localUser.epochStartPos} inputFrame:{localUser.inputFrame}"
		for input.internalUsers as user
			if user and not user.local
				string channelState = hasOpenChannel(user) ? "open buffered:{channelBufferedAmount(user)}" : "closed"
				string channelAgo = user.lastIncomingChannelTime == float.maxValue ? "never" : "{math.round(now - user.lastIncomingChannelTime)}ms"
				string messageAgo = user.lastIncomingMessageTime == float.maxValue ? "never" : "{math.round(now - user.lastIncomingMessageTime)}ms"
				string smooth = user.smoothFrame == int.maxValue ? "-" : "{user.smoothFrame}"
				string userFlags = ""
				if user.hidden then userFlags += " hidden"
				if user.leaving then userFlags += " leaving"
				if user.removed then userFlags += " REMOVED@" + user.removedAfterFrame
				string pcState = user.connectionState ? user.connectionState : "none"
				string connectionType = user.connectionType ? user.connectionType : "?"
				summary += "\n    <{user.id}> pc:{pcState} channel:{channelState} type:{connectionType} inputFrame:{user.inputFrame} smooth:{smooth} writePos:{user.inputs.writePos} ackedOfMine:{user.receivedMyInputsUpToPos} lastChannelMsg:{channelAgo} lastMsg:{messageAgo} drops:{user.droppedTickCount} tries:{user.connectionTries}{userFlags}"
		core.log "{summary}"

	// The host is the living, not removed user with the lowest id (internalUsers is indexed by id,
	// so the iteration order is the id order). Only the host writes RemoveUser events, so two
	// clients don't both write one for the same user (and if they briefly disagree, the parse is
	// idempotent and the first event in the deterministic stream order wins)
	bool amHost
		let now = core.currentTime
		for input.internalUsers as user
			if user and not user.removed
				if user.local then return true
				if now < user.lastIncomingMessageTime + removalGraceMillis then return false
		return true

	// Called deterministically from input.parseInputs when a RemoveUser event is parsed.
	// Everything nondeterministic about a removal (closing the connection, statistics) is safe
	// to repeat - this can run again during a replay
	onUserRemoved: InternalUser user
		core.log "#removal <{user.id}> User removed from the game"
		cancelLogConnectionType user
		closeDataChannels user
		closePeerConnection user
		statistics.scheduleSendIn 3 seconds

	// Our own player was removed while we were away: our userId is retired. Wipe the stored
	// identity and inputs for this room and reload as a fresh player. Guarded against loops
	onRemovedNotice
		if removedHandled then return
		removedHandled = true
		core.log "#removal We were removed from the game -> rejoining as a new player"
		wipeRoomStorageAndReload

	private bool removedHandled

	js void wipeRoomStorageAndReload
		try { localStorage.removeItem("room"+core.roomId) } catch {}
		try { sessionStorage.setItem("removedAt", ""+Date.now()) } catch {}
		// Keep the query string: it can carry the ?server/?turn/?relay overrides
		let reload = () => { location.href = "/"+core.gameId+"/"+core.roomId+location.search; };
		try {
			// Delete our stored input chunks so a future player with a reused id can't load them
			let trans = IndexedDB.db.transaction("input", "readwrite");
			let store = trans.objectStore("input");
			let index = store.index("roomId");
			let req = index.getAllKeys(core.roomId);
			req.onsuccess = () => {
				for(let key of req.result) {
					if((""+key).startsWith(core.roomId+"-"+input.localUser.id+"-")) store.delete(key);
				}
			};
			trans.oncomplete = reload;
			trans.onerror = reload;
			setTimeout(reload, 2000);
		} catch(e) {
			reload();
		}

	// Our post-reload inputs forked from the group timeline (see onOwnHistory): delete only our
	// stored input chunks for this room - identity and RoomInfo stay, so we reload and rejoin as
	// the same player, and the restore rebuilds our stream from the peers' copies (which provably
	// hold more of it than we do). Guarded against loops like selfHealReload
	private bool forkDiscardHandled

	js void discardForkedInputsAndReload
		if(PeerNetwork.forkDiscardHandled) return;
		PeerNetwork.forkDiscardHandled = true;
		try {
			let count = parseInt(sessionStorage.getItem("forkDiscards") || "0");
			let last = parseInt(sessionStorage.getItem("forkDiscardTime") || "0");
			if(Date.now() - last > 600000) count = 0;
			if(count >= 2) {
				core.log("#restore Not discarding the fork again, already discarded "+count+" times");
				return;
			}
			sessionStorage.setItem("forkDiscards", ""+(count+1));
			sessionStorage.setItem("forkDiscardTime", ""+Date.now());
		} catch {}
		core.log("#restore Deleting our stored input chunks for room "+core.roomId+" and reloading");
		let reload = () => { location.reload(); };
		try {
			let trans = IndexedDB.db.transaction("input", "readwrite");
			let store = trans.objectStore("input");
			let index = store.index("roomId");
			let req = index.getAllKeys(core.roomId);
			req.onsuccess = () => {
				for(let key of req.result) {
					if((""+key).startsWith(core.roomId+"-"+input.localUser.id+"-")) store.delete(key);
				}
			};
			trans.oncomplete = reload;
			trans.onerror = reload;
			setTimeout(reload, 2000);
		} catch(e) {
			reload();
		}

	// Reload the page to self-heal from a state divergence: our own input stream survives
	// (IndexedDB + peers), all other streams are re-fetched from the mesh, and the full replay
	// rebuilds a state that is consistent with the group. Rate-limited to avoid reload loops
	js void selfHealReload: string reason
		try {
			let count = parseInt(sessionStorage.getItem("selfHealReloads") || "0");
			let last = parseInt(sessionStorage.getItem("selfHealReloadTime") || "0");
			if(Date.now() - last > 600000) count = 0;
			if(count >= 2) {
				core.log("#selfheal Not reloading again ("+reason+"), already reloaded "+count+" times");
				return;
			}
			sessionStorage.setItem("selfHealReloads", ""+(count+1));
			sessionStorage.setItem("selfHealReloadTime", ""+Date.now());
		} catch {}
		core.log("#selfheal Reloading page: "+reason);
		setTimeout(() => location.reload(), 500);

	// --------------------------------------------- WebRTC connection ---------------------------------------------

	initiate: InternalUser user
		// The media setup runs in parallel with the signaling connection
		// Wait until it settled so the local tracks are added when the peer connection is created
		await whenLocalMediaSettled
		setupPeerConnection user, offerByMe:true
		// Create the data channel before the offer, so the very first SDP round trip negotiates it
		// and it opens right after DTLS. Creating it later would trigger a renegotiation - one more
		// full signaling round trip during which a high-latency link looks dead to the watchdog
		setupDataChannel user
		setupRemoteMedia user

	private js void restartIce: InternalUser user
		try {
			if(user.peerConnection) user.peerConnection.restartIce();
		} catch(e) {
			core.log("#peer <"+user.id+"> restartIce failed "+e.message);
		}

	private js void closePeerConnection: InternalUser user
		if(!user.peerConnection) return;
		try {
			user.peerConnection.onnegotiationneeded = null;
			user.peerConnection.onsignalingstatechange = null;
			user.peerConnection.onconnectionstatechange = null;
			user.peerConnection.onicecandidate = null;
			user.peerConnection.icecandidateerror = null;
			user.peerConnection.oniceconnectionstatechange = null;
			user.peerConnection.onicegatheringstatechange = null;
			user.peerConnection.ondatachannel = null;
			user.peerConnection.close();
		} catch {}
		user.peerConnection = null;
		user.connected = false;

	private js void closeDataChannels: InternalUser user
		for(let dataChannel of user.dataChannels) {
			try { dataChannel.close(); } catch {}
		}
		user.dataChannels.length = 0;

	private js object setupPeerConnection: InternalUser user, bool offerByMe
		if(user.peerConnection) {
			core.log(`#peer <${user.id}> Close Previous Peer Connection`)
			PeerNetwork.closePeerConnection(user);
		}
		try {
			// A pending connection-type report belongs to the connection being replaced
			clearTimeout(user.logConnectionTypeTimer);
			// Same monotonic clock as core.currentTime (inlined: js blocks can't call inline functions)
			user.startToConnectTime = user.lastIncomingChannelTime = Math.round(performance.timeOrigin + performance.now());
			user.offerByMe = offerByMe;
			// A fresh connection has no answer yet and no silence history
			// While offerByMe && !receivedAnswer our offer counts as outstanding -> the impolite peer ignores crossing offers (see onReceivedOffer)
			user.receivedAnswer = false;
			user.silentPeriods = 0;

			// STUN and TURN both live inside the Go server executable. The TURN server is on the
			// same host that accepted our WebSocket; UDP first, TCP as the firewall fallback.
			// ?turn=port in the page URL overrides the port (the e2e tests use random ports)
			let turnHost = ServerNetwork.workingServerHost || location.hostname;
			let turnPort = 3478;
			try { turnPort = parseInt(new URLSearchParams(location.search).get("turn")) || 3478; } catch {}
			let options = {
				iceTransportPolicy: PeerNetwork.relayMode == 2 ? "relay" : "all",
				iceServers: [],
			}
			if(PeerNetwork.relayMode > 0) {
				options.iceServers.push({
					urls: [
						"turn:"+turnHost+":"+turnPort+"?transport=udp",
						"turn:"+turnHost+":"+turnPort+"?transport=tcp",
					],
					username: PeerNetwork.turnUsername,
					credential: PeerNetwork.turnPassword,
				});
			}
			options.iceServers.push({
				urls: [
					"stun:"+turnHost+":"+turnPort,
					"stun:stun1.l.google.com:19302",
					"stun:stun2.l.google.com:19302",
				],
			});
			core.log(`#peer <${user.id}> Setup Peer Connection offerByMe:${offerByMe} relayMode:${PeerNetwork.relayMode} turn:${turnHost}:${turnPort}`);
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
				// "failed" means ICE gave up - restart immediately instead of waiting for the silence timer.
				// This is also the path that reconnects TURN allocations after the TURN server restarted
				if(peerConnection.connectionState == "failed" && offerByMe) {
					core.log(`#peer <${user.id}> Connection failed -> restarting ICE`);
					try { peerConnection.restartIce(); } catch {}
				}
			}

			// ICE: Candidate, Error
			let candidateCount = 0
			peerConnection.onicecandidate = async event => {
				if (event.candidate) {
					core.log(`#peer <${user.id}> Gathered Local Ice Candidate ${++candidateCount} -> Send to peer`);
					PeerNetwork.sendIceCandidate(user, JSON.stringify(event.candidate));
				} else {
					core.log(`#peer <${user.id}> Gathered Local Ice Candidates Complete`);
				}
			}
			peerConnection.icecandidateerror = e => {
				core.log(`#peer <${user.id}> ICE Candidate Error: ${e.errorText}`);
			}

			return peerConnection;
		}
		catch(e) {
			core.log("#peer <"+user.id+"> setupPeerConnection failed " + e.message)
			console.error(e);
			core.log(e.stack);
			return null;
		}

	// Recreates the data channel only if the previous one is gone for good. While it is still
	// "connecting" it was negotiated with the offer and will open on its own; closing it and
	// creating a new one would trigger a renegotiation (a full extra signaling round trip)
	private js void ensureDataChannel: InternalUser user
		let channel = user.latestDataChannel;
		if(channel && (channel.readyState == "open" || channel.readyState == "connecting")) return;
		PeerNetwork.setupDataChannel(user);

	private js void setupDataChannel: InternalUser user
		try {
			user.startDataChannelTime = Math.round(performance.timeOrigin + performance.now());
			core.log("#peer <"+user.id+"> Data Channel Creating");
			PeerNetwork.closeDataChannels(user);

			// Unreliable, unordered: losses are repaired by the ack-driven cumulative resend
			let dataChannel = user.peerConnection.createDataChannel("channel", {ordered:false, maxRetransmits:0});
			user.latestDataChannel = dataChannel;
			PeerNetwork.attachDataChannel(user, dataChannel);
		}
		catch(e) {
			core.log("#peer <"+user.id+"> setupDataChannel failed " + e.message)
			console.error(e);
			core.log(e.stack);
		}

	private js void attachDataChannel: InternalUser user, object dataChannel
		dataChannel.binaryType = "arraybuffer";
		dataChannel._id = PeerNetwork.dataChannelId++;

		dataChannel.onopen = e => {
			user.dataChannels.splice(0,0,dataChannel);
			// Same monotonic clock as core.currentTime (inlined: js blocks can't call inline functions)
			user.lastIncomingChannelTime = Math.round(performance.timeOrigin + performance.now());
			// The link proved it can establish a channel - the silence watchdog starts fast again
			user.channelReconnects = 0;
			core.log("#peer <"+user.id+"> Data Channel Open (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
			PeerNetwork.logConnectionType(user);
		}
		dataChannel.onclosing = e => {
			let index = user.dataChannels.indexOf(dataChannel);
			if(index != -1) user.dataChannels.splice(index, 1);
			core.log("#peer <"+user.id+"> Data Channel Closing (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
		}
		dataChannel.onclose = e => {
			let index = user.dataChannels.indexOf(dataChannel);
			if(index != -1) user.dataChannels.splice(index, 1);
			core.log("#peer <"+user.id+"> Data Channel Close (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
		}
		dataChannel.onerror = e => {
			core.log("#peer <"+user.id+"> Data Channel Error (id:"+dataChannel._id+")");
		}
		dataChannel.onmessage = e => {
			user.lastIncomingChannelTime = user.lastChannelMessageTime = Math.round(performance.timeOrigin + performance.now());
			PeerNetwork.onPeerMessage(user, new Buffer(e.data, 0, 0, 0), false);
		}

	onConnected: InternalUser user
		// Fresh silence window: the channel created with the offer still needs the SCTP handshake
		user.startDataChannelTime = user.lastIncomingChannelTime = core.currentTime
		user.connectionTries = 0
		logConnectionType user

		// The channel was already negotiated with the offer and normally just opens now. Only when
		// it died for good (SCTP gone but ICE recovered) create a new one - that costs a renegotiation
		if user.offerByMe
			ensureDataChannel user

		if not statistics.connectTime
			int connectedCount = input.internalUsers.count.offerByMe and .connected
			int offerCount = input.internalUsers.count.offerByMe
			core.log "#peer Connected, {connectedCount} of {offerCount} of my offers are connected"

			if input.internalUsers.none.offerByMe and not .connected
				statistics.connectTime = PlainDate.preciseTime - statistics.startTime
				core.log "#peer All my offers are connected after {statistics.connectTime} ms and {retries} retries"

	private js void createOffer: InternalUser user
		try {
			core.log("#peer <"+user.id+"> Sending offer, waiting for answer. Try:"+user.connectionTries);
			let peerConnection = user.peerConnection
			let offer = await peerConnection.createOffer();
			await peerConnection.setLocalDescription(offer);
			PeerNetwork.sendSdp(user, /*Offer*/3, peerConnection.localDescription.sdp);
			user.receivedAnswer = false
		}
		catch(e) {
			core.log("#peer <"+user.id+"> createOffer failed " + e.message)
			console.error(e);
			core.log(e.stack);
		}

	// Offers, answers and ICE candidates are peer messages: they normally travel via the server
	// (the data channel doesn't exist yet), but renegotiations can also use an open channel
	private sendSdp: InternalUser user, int peerType, string sdp
		sendBuffer.reset
		sendBuffer.writeInt8 peerType
		sendBuffer.writeString sdp
		send user, sendBuffer

	private sendIceCandidate: InternalUser user, string candidate
		sendBuffer.reset
		sendBuffer.writeInt8 cast PeerMessageType.IceCandidate
		sendBuffer.writeString candidate
		send user, sendBuffer

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
			// - candidates arriving from now on belong to this offer -> queue them until the remote description is set
			user.pendingIceCandidates.length = 0;
			user.settingRemoteDescription = true;

			// The media setup runs in parallel with the signaling connection
			// Wait until it settled so the local tracks are added when the peer connection is created
			await PeerNetwork.whenLocalMediaSettled();
			core.log("#peer <"+user.id+"> Received offer -> Send answer");
			PeerNetwork.setupPeerConnection(user, /*offerByMe*/false);
			PeerNetwork.setupRemoteMedia(user);

			// Data channel (created by the offerer, received here)
			user.peerConnection.ondatachannel = e => {
				core.log("#peer <"+user.id+"> Data Channel Received");
				PeerNetwork.attachDataChannel(user, e.channel);
			}

			// Answer
			let peerConnection = user.peerConnection;
			await peerConnection.setRemoteDescription(new RTCSessionDescription({type: "offer", sdp}));
			user.settingRemoteDescription = false;
			await PeerNetwork.addPendingIceCandidates(user);
			let answer = await peerConnection.createAnswer();
			await peerConnection.setLocalDescription(answer);
			PeerNetwork.sendSdp(user, /*Answer*/4, peerConnection.localDescription.sdp);
		}
		catch(e) {
			user.settingRemoteDescription = false;
			core.log("#peer <"+user.id+"> onReceivedOffer failed " + e.message)
			console.error(e)
			core.log(e.stack);
		}

	js void onReceivedAnswer: InternalUser user, string sdp
		core.log("#peer <"+user.id+"> Received Answer");
		try {
			if(!user.peerConnection || !user.offerByMe) {
				core.log("#peer <"+user.id+"> Ignoring answer: no outstanding offer");
				return;
			}
			// Candidates queued before this answer belong to a previous connection generation -> discard them
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
			}
		}

	private js void logConnectionType: InternalUser user
		// One pending timer per user: a re-initiate within the 10s window would otherwise report
		// stats for a connection that no longer exists; also cancelled in setupPeerConnection
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
					core.log("#connection <"+user.id+"> connection: no succeeded candidate pair");
				}
			} catch(e) {
				core.log("#connection <"+user.id+"> logConnectionType failed: " + e.message)
			}
		}, 10000)

	private js void cancelLogConnectionType: InternalUser user
		clearTimeout(user.logConnectionTypeTimer)

	js void setBitrate: InternalUser user, float scaleResolutionDownBy = 1, float maxBitrate
		try {
			let senderList = user.peerConnection.getSenders();
			for(let sender of senderList) {
				const params = sender.getParameters();
				if (!params.encodings) {
					params.encodings = [{ }];
				}
				params.encodings[0].scaleResolutionDownBy = scaleResolutionDownBy;
				params.encodings[0].maxBitrate = maxBitrate;
				await sender.setParameters(params);
			}
		}
		catch(e) {
			core.log("#peer <"+user.id+"> setBitrate failed " + e.message)
		}

	// --------------------------------------------- Transport ---------------------------------------------

	private js bool hasOpenChannel: InternalUser user
		return user.dataChannels.length > 0 && user.dataChannels[0].readyState == "open"

	private js int channelBufferedAmount: InternalUser user
		return user.dataChannels.length > 0 ? (user.dataChannels[0].bufferedAmount || 0) : 0

	// Send a peer message: over the data channel when it is open, otherwise wrapped in a server
	// Relay. Every peer message works on both transports, so signaling outages and P2P outages
	// mask each other - only when both are down at the same time is the peer unreachable
	private int send: InternalUser user, Buffer buffer
		if hasOpenChannel user
			int sentBytes = sendOnChannel user, buffer
			// An "open" channel can be silently dead (a dying router or NAT eats the packets but
			// the SCTP association never notices). While the channel is suspect, mirror every
			// message over the server relay too - inputs and repair offers keep flowing seconds
			// into an outage instead of stalling until a reconnect happens to close the channel
			if channelSuspect user and ServerNetwork.connected and ServerNetwork.bufferedAmount < 1048576
				ServerNetwork.relay user.id, buffer
			return sentBytes
		ServerNetwork.relay user.id, buffer
		return buffer.writePos

	// True when the open channel cannot be trusted: it delivered nothing for a while (their
	// direction is dead), or the peer stopped acking our outstanding bytes (our direction is
	// dead - visible without any wire change because acks ride on the peer's Ticks, which
	// still arrive when only our direction died)
	private bool channelSuspect: InternalUser user
		let now = core.currentTime
		return now > user.lastChannelMessageTime + channelSuspectMillis or now > user.lastAckProgressTime + channelSuspectMillis

	private js int sendOnChannel: InternalUser user, Buffer buffer
		try {
			let data = buffer.toByteArray()
			let channel = user.dataChannels[0]
			channel.send(data)
			return data.byteLength
		}
		catch(e) {
			core.log("#peer <"+user.id+"> send failed " + e.message)
			return 0
		}

	// A crashing handler must never take down the message pump, and the exception must reach the
	// saved logs (uncaught exceptions in data channel callbacks only reach the browser console)
	internal onPeerMessage: InternalUser user, Buffer buffer, bool viaServer
		try
			handlePeerMessage user, buffer, viaServer
		catch
			core.log "#error <{user.id}> Failed to handle peer message via {viaServer ? "server relay" : "data channel"} ({buffer.writePos} bytes): {error.stack}"

	private handlePeerMessage: InternalUser user, Buffer buffer, bool viaServer
		user.lastIncomingMessageTime = core.currentTime
		user.silentPeriods = 0
		user.leaving = false // Any message proves the user is still there (e.g. restored from the back/forward cache)
		user.presentOnServer = true // The JoinResponse presence snapshot goes stale; any message proves liveness
		// A user that proves it is alive before its RemoveUser event was written cancels the removal
		// gossip: otherwise the 1s stream-fetch loop would keep requesting its stream forever, and a
		// LATER outage would inherit this stale start time and remove the user with zero gossip time
		// (removalEventWritten stays: once the event is in the stream, the removal is deterministic)
		if user.removalGossipStart != 0 and not user.removalEventWritten
			user.removalGossipStart = 0
			core.log "#removal <{user.id}> Back before removal -> gossip cancelled"
		if user.reconnectNotified
			user.reconnectNotified = false
			core.log "#peer <{user.id}> Reachable again via {viaServer ? "server relay" : "data channel"}"
		int typeValue = buffer.readInt8
		if typeValue < 0 or typeValue > cast PeerMessageType.Removed
			core.log "#error <{user.id}> Unknown peer message type {typeValue} via {viaServer ? "server relay" : "data channel"} - version mismatch between clients?"
			return
		PeerMessageType type = cast typeValue
		switch type
			Tick	onTick user, buffer
			Ping	onPing user, buffer
			Pong	onPong user, buffer
			Offer	onReceivedOffer user, buffer.readString
			Answer	onReceivedAnswer user, buffer.readString
			IceCandidate	onIce user, buffer.readString
			StreamRequest	onStreamRequest user, buffer
			StreamData	onStreamData user, buffer
			Status	onStatus user, buffer
			Leaving	onLeaving user, buffer
			Removed	onRemovedNotice

	// --------------------------------------------- Input Ticks ---------------------------------------------

	// A single Tick must stay well below the smallest cross-browser SCTP message size limit:
	// a peer that is gone for minutes (or a fresh peer acking from 0 after a long game) would
	// otherwise make the cumulative delta exceed it, channel.send would throw on every frame and
	// the transfer would never succeed - both sides stall. Larger backlogs are sent as one
	// chunk per Tick; the ack-driven cumulative resend delivers the rest over the following
	// frames (~16 KB at 30 Hz = 480 KB/s)
	const int maxTickBytes = 16384

	sendInputs: int inputFrame
		let inputs = input.localUser.inputs
		recordClaimSample inputs.writePos, inputFrame
		for input.internalUsers as receiver if receiver
			if receiver.local or receiver.removed then continue

			bool viaChannel = hasOpenChannel receiver
			if not viaChannel and not ServerNetwork.connected then continue
			// Don't pile onto a congested transport - the cumulative resend covers these bytes later
			if viaChannel and channelBufferedAmount(receiver) > 1048576 then continue
			if not viaChannel and ServerNetwork.bufferedAmount > 1048576 then continue

			// A transport change is a connectivity event worth one log line: it shows exactly
			// when the P2P path went down (Ticks fall back to the server or are mirrored while
			// the channel is suspect) and when it recovered
			int transport = viaChannel ? (channelSuspect(receiver) ? 3 : 1) : 2
			if receiver.lastTickTransport != transport
				if receiver.lastTickTransport != 0 or transport != 1
					core.log "#transport <{receiver.id}> Sending inputs via {transport == 1 ? "data channel" : transport == 2 ? "server relay" : "data channel + server relay (channel suspect)"}"
				receiver.lastTickTransport = transport

			// A returning peer can ack MORE of our stream than we hold (it kept our pre-reload
			// inputs while our own restore was cut short) - nothing to send it until the
			// history adoption in onOwnHistory catches our writePos up to its copy
			let startPos = math.min(receiver.receivedMyInputsUpToPos, inputs.writePos)
			int length = inputs.writePos - startPos
			int claim = inputFrame
			if length > maxTickBytes
				// The receiver is far behind: send one chunk, cut at a record boundary (a cut inside
				// an input record would make the receiver's stream end mid-record - unparseable).
				// The claim may only cover frames whose bytes are fully inside what the receiver
				// will then have, so it comes from the position->frame samples too
				int cutPos = alignedCutBelow startPos + maxTickBytes
				if cutPos > startPos
					length = cutPos - startPos
					claim = claimForPos cutPos
				else
					// No aligned cut below the cap: restored pre-epoch history was never claim-sampled
					// (a rejoiner serving its restored stream to a peer that acks from 0). Send a capped,
					// NON-aligned chunk with a conservative claim: the claim only gates parsing, so the
					// receiver's stream may briefly end mid-record and it simply keeps its old claim
					// (-1 when nothing is sampled) until the resend cursor reaches sampled territory -
					// the same principle onStreamData's non-aligned 16 KB cuts rely on. An uncapped send
					// would exceed the SCTP message limit (channel.send throws, the same oversized send
					// is retried forever) or the server's 4 MB read limit (which closes our own
					// signaling connection - a reconnect death loop)
					length = maxTickBytes
					claim = claimForPos startPos + length

			sendBuffer.reset
			sendBuffer.writeInt8 cast PeerMessageType.Tick
			sendBuffer.writeInt input.localUser.epoch            // The epoch of my stream, changes when I restart with a fresh session
			sendBuffer.writeInt input.localUser.epochStartPos    // My bytes below this pos are history restored from before this epoch
			sendBuffer.writeInt claim                            // I sent inputs up to and including this frame
			sendBuffer.writeInt startPos                         // I send inputs starting from the last pos you received
			sendBuffer.writeInt receiver.inputs.writePos         // I received your inputs up to this pos
			sendBuffer.writeBuffer inputs, startPos, length
			sendBuffer.writeInt core.lastChecksumFrame                      // The last frame with a computed state checksum
			sendBuffer.writeFloat64 core.getChecksum core.lastChecksumFrame // The checksum of that frame

			core.tickMessageSize = send receiver, sendBuffer

			// These stream bytes are now on the wire and must never be mutated in place
			// (see the TouchMove patch guard in input.handleTouchEvent)
			if input.localUser.sentInputsUpToPos < startPos + length then input.localUser.sentInputsUpToPos = startPos + length

			if core.verbose and length > 0 then core.log "[{claim}] <{receiver.id}> #send -->> sending {length} bytes, from {startPos} to {startPos + length} of {inputs.writePos}{viaChannel ? "" : " via server"}"

	private onTick: InternalUser sender, Buffer buffer
		let epoch = buffer.readInt                          // The epoch of the sender's stream, changes when the sender restarts with a fresh session
		let epochStartPos = buffer.readInt                  // The sender's bytes below this pos are history restored from before this epoch
		let claim = buffer.readInt                          // The sender sent inputs up to and including this frame

		// A removed user's stream is closed forever - and if they honestly came back after being
		// removed, they need to know that their id is retired so they rejoin as a fresh player
		if sender.removed
			let now = core.currentTime
			if now > sender.lastStreamSentTime + 1000
				sender.lastStreamSentTime = now
				sendBuffer.reset
				sendBuffer.writeInt8 cast PeerMessageType.Removed
				send sender, sendBuffer
			return

		bool epochConflict = epoch != sender.epoch

		let incomingStartPos = buffer.readInt           // The sender sent inputs starting from this pos
		let ackPos = buffer.readInt                     // The sender received my inputs up to this pos

		// Peek the length to validate the write before it happens (readBuffer reads the length itself)
		let savedReadPos = buffer.readPos
		let length = buffer.readInt
		buffer.readPos = savedReadPos

		// Ack progress: the receiver is consuming our chunked catch-up (see sendInputs).
		// Acks only move forward - a late message must not regress the resend cursor.
		// Exception: an epoch other than the one we recorded means the sender restarted and lost
		// every byte of our stream it ever held (peers never persist each other's streams), so
		// that message's ack is the truth even when it regresses. Normally the sender's restore
		// request resets the cursor to 0 anyway - but if that request was lost (the sender rejoined
		// while we were unreachable), this is the only signal left: without it we would resend from
		// the stale cursor forever and the sender would drop every Tick as a gap. Processed even
		// when we refuse the epoch below, otherwise the deadlock is mutual: we don't take their
		// bytes AND they never receive ours
		if epochConflict and ackPos < sender.receivedMyInputsUpToPos
			core.log "[{claim}] <{sender.id}> #epoch Epoch {epoch} acks only {ackPos} of our {input.localUser.inputs.writePos} bytes (cursor was {sender.receivedMyInputsUpToPos}) -> resend from {ackPos}"
		if epochConflict or ackPos > sender.receivedMyInputsUpToPos
			sender.receivedMyInputsUpToPos = ackPos
			sender.lastAckProgressTime = core.currentTime

		// A new epoch means the sender restarted and lost its in-memory stream (page refresh with
		// the same userId). Its stream only continues the one we stored if it restored at least
		// everything we hold - otherwise its writes would retroactively change history that our
		// snapshots and read positions reference, so we offer it its own history back instead
		// (the rejoiner discards its fork and reloads when it sees the offer, see onOwnHistory)
		if epochConflict
			if sender.epoch != 0 and epochStartPos < sender.inputs.writePos
				sendStreamChunk sender, sender.id, epochStartPos // Rate-limited, gives the rejoiner its own history back
				return
			core.log "[{claim}] <{sender.id}> #epoch Accepting new stream epoch {epoch} (was {sender.epoch}), continued from {epochStartPos}, we stored {sender.inputs.writePos}"
			sender.epoch = epoch

		// Only contiguous appends are allowed: the stream is append-only within an epoch and snapshots
		// reference positions in it, so a write must neither leave a gap nor shrink what we already have
		// (dropped bytes are repaired by the cumulative resend of the next Tick).
		// Gap drops are the packet-loss signal: counted always, logged at most every 2 seconds
		// (the cumulative count also appears in the periodic #status summary)
		if incomingStartPos > sender.inputs.writePos
			sender.droppedTickCount++
			let now = core.currentTime
			if now > sender.lastDropLogTime + 2000
				sender.lastDropLogTime = now
				core.log "[{claim}] <{sender.id}> #receive Dropped Tick (gap): bytes start at {incomingStartPos}, we have {sender.inputs.writePos} ({sender.droppedTickCount} drops so far)"
			return
		if incomingStartPos + length < sender.inputs.writePos
			// A late or duplicated message on the unreliable channel - routine, only counted
			sender.droppedTickCount++
			return

		buffer.readBuffer sender.inputs, incomingStartPos

		// Claims only move forward, and only when the claimed bytes are actually here.
		// A claim advance is what makes new records parseable: tell the rollback machinery the
		// first frame whose parse can differ (records are never stamped at or below their
		// sender's previous claim), so the next pass rewinds no further than necessary
		if claim > sender.inputFrame
			core.markRemoteChange sender.inputFrame + 1
			sender.inputFrame = claim

		if core.verbose and length > 0 then core.log "[{claim}] <{sender.id}> #receive <<-- received {length} bytes, up to {sender.inputs.writePos}"

		// Checksum
		int checksumFor = buffer.readInt
		float checksum = buffer.readFloat64
		core.onRemoteChecksum checksumFor, checksum

		// Store incoming inputs of remote users is not needed - only our own inputs are persisted

	// --------------------------------------------- Claims for chunked Ticks ---------------------------------------------

	// Samples of "bytes [0, claimSamplePositions[i]) of my stream contain all my inputs up to and
	// including frame claimSampleFrames[i]" - exactly what a claim promises, and true at every send
	// because the claim core.onFrame passes in only covers bytes already written. Every sample
	// position is also a record boundary (samples are taken between frames), so chunked Ticks are
	// cut here and a receiver's stream never ends in the middle of an input record.
	// Sampled once per frame. Never pruned: it grows orders of magnitude slower than the input
	// stream itself, which is append-only
	private int[] claimSamplePositions
	private int[] claimSampleFrames

	private recordClaimSample: int writePos, int inputFrame
		let count = claimSamplePositions.length
		if count > 0 and claimSamplePositions[count-1] == writePos
			// Same bytes, newer claim: keep the newest claim for this position
			claimSampleFrames[count-1] = inputFrame
		else
			claimSamplePositions.add writePos
			claimSampleFrames.add inputFrame

	// The index of the newest sample whose position lies at or below pos; -1 when no sample qualifies
	// (start of a session, or restored history from before this session - restored bytes were never sampled)
	private int sampleIndexForPos: int pos
		int low = 0
		int high = claimSamplePositions.length - 1
		int result = -1
		while low <= high
			int mid = math.floor((low + high) / 2)
			if claimSamplePositions[mid] <= pos
				result = mid
				low = mid + 1
			else
				high = mid - 1
		return result

	// The newest sampled claim whose bytes lie fully below pos; -1 when no sample qualifies.
	// Receivers start at inputFrame -1 and claims only move forward, so -1 is always safe
	private int claimForPos: int pos
		int index = sampleIndexForPos pos
		return index == -1 ? -1 : claimSampleFrames[index]

	// The largest record-aligned position at or below pos (0 when no sample qualifies)
	private int alignedCutBelow: int pos
		int index = sampleIndexForPos pos
		return index == -1 ? 0 : claimSamplePositions[index]

	// --------------------------------------------- Stream transfer ---------------------------------------------

	// Any user's input stream can be fetched from any peer. Used for:
	// - restoring our own stream after a page refresh (peers still hold it)
	// - fetching a removed user's remaining inputs (another client received more than we did)
	// - the pre-removal gossip of the host (merge everything the mesh knows before removing)
	private requestStreamFromAllPeers: int streamUserId
		let streamUser = input.internalUsers[streamUserId]
		if not streamUser then return
		for input.internalUsers as peer
			if . and not .local and .id != streamUserId and not .removed
				if hasOpenChannel(.) or ServerNetwork.connected
					sendBuffer.reset
					sendBuffer.writeInt8 cast PeerMessageType.StreamRequest
					sendBuffer.writeInt streamUserId
					sendBuffer.writeInt streamUser.inputs.writePos
					send ., sendBuffer

	// A peer asks for a user's input stream as we stored it, starting at fromPos.
	// The answer always reports the total length and the claim, even when there are no new bytes,
	// so the requester learns how much exists. Rate-limited per requesting peer
	private onStreamRequest: InternalUser requester, Buffer buffer
		int streamUserId = buffer.readInt
		int fromPos = buffer.readInt

		// A rejoiner asking for its own history also has none of our inputs any more
		// -> resend our own stream from position 0 (the explicit positions make this idempotent)
		if streamUserId == requester.id and requester.receivedMyInputsUpToPos > 0
			core.log "#stream <{requester.id}> Rejoiner asks for its own history -> resend our inputs from 0"
			requester.receivedMyInputsUpToPos = 0

		sendStreamChunk requester, streamUserId, fromPos

	private sendStreamChunk: InternalUser requester, int streamUserId, int fromPos
		let now = core.currentTime
		if now < requester.lastStreamSentTime + 200 then return
		requester.lastStreamSentTime = now

		let streamUser = input.internalUsers[streamUserId]
		if not streamUser then return

		int totalLength = streamUser.inputs.writePos
		int length = math.min(totalLength - fromPos, maxTickBytes)
		if length < 0 then length = 0
		int claim = streamUser.local ? input.localUser.inputFrame - 1 : streamUser.inputFrame

		core.log "#stream <{requester.id}> Sending {length} bytes of user {streamUserId}'s stream at {fromPos} of {totalLength}, claim {claim}"
		sendBuffer.reset
		sendBuffer.writeInt8 cast PeerMessageType.StreamData
		sendBuffer.writeInt streamUserId
		sendBuffer.writeInt totalLength
		sendBuffer.writeInt claim
		sendBuffer.writeInt fromPos
		sendBuffer.writeBuffer streamUser.inputs, fromPos, length
		send requester, sendBuffer

		// Our own stream bytes sent here are on the wire and must never be mutated in place
		// (see the TouchMove patch guard in input.handleTouchEvent)
		if streamUser.local and streamUser.sentInputsUpToPos < fromPos + length
			streamUser.sentInputsUpToPos = fromPos + length

	private onStreamData: InternalUser peer, Buffer buffer
		int streamUserId = buffer.readInt
		int totalLength = buffer.readInt
		int claim = buffer.readInt
		int startPos = buffer.readInt // The pos where these bytes start

		// Our own stream: handled by the restore rules (append-only prefix)
		if streamUserId == input.localUser.id
			onOwnHistory peer, buffer, totalLength, claim, startPos
			return

		let streamUser = input.internalUsers[streamUserId]
		if not streamUser or streamUser.local then return

		let savedReadPos = buffer.readPos
		int length = buffer.readInt
		buffer.readPos = savedReadPos

		// Contiguous appends only, like onTick
		if startPos > streamUser.inputs.writePos then return
		if length > 0 and startPos + length > streamUser.inputs.writePos
			buffer.readBuffer streamUser.inputs, startPos
			core.log "#stream <{peer.id}> Received {length} bytes of user {streamUserId}'s stream, now {streamUser.inputs.writePos} of {totalLength}"

		// The claim becomes valid once we hold the full stream the peer reported. Bytes between our
		// old claim and this one may end mid-record (the 16 KB cuts here are not record-aligned),
		// so the claim - which gates parsing - only moves when the transfer is complete
		if streamUser.inputs.writePos >= totalLength and claim > streamUser.inputFrame
			core.markRemoteChange streamUser.inputFrame + 1
			streamUser.inputFrame = claim

	// --------------------------------------------- Restoring our stream after a rejoin ---------------------------------------------

	// When we rejoin a room with the same userId after a page refresh, our in-memory input stream
	// is gone, but IndexedDB and every peer still hold a copy of it. We restore the longest copy
	// we can get, so our outgoing Ticks continue the old stream instead of overwriting it from
	// position 0 on every peer (which would corrupt their snapshots)

	// A random non-zero id for this session's input stream, assigned in core.join (0 means unknown)
	js int generateEpoch
		return Math.floor(Math.random() * 0x3fffffff) + 1

	bool restoring
	private float restoreDeadline
	private float restoreStartTime
	private float lastRestoreWaitLogTime
	private float nextRestoreRequestTime

	// The restore ended without every live peer confirming how much of our previous stream it
	// holds (they were unreachable during the restore window). A returning peer may still hold
	// MORE of our old stream than we restored, so until every live peer confirmed - or was
	// removed from the game (a removed user that returns wipes its storage and rejoins fresh,
	// so its copy of our old stream dies with it) - we must not append new input records and
	// must not raise our claims: new bytes would fork the longer copy (a peer holding less
	// accepts the fork, the peer holding more refuses it, and their copies of our stream can
	// never match again), and a claim covering frames whose old records may still surface would
	// make receivers apply those records at the wrong frames (their rewind snapshots are only
	// pinned down to claim+1). Enforced in core.inputRecordingPaused (input recording),
	// core.onFrame (the claim counter stays at the floor adopted from confirmed peers) and
	// core.startConnected (Join deferral); resolved in tickHoldingConfirmations
	bool holdingConfirmationPending

	// Called from ServerNetwork.onJoinResponse when we joined with a preassigned userId and other
	// users exist in the room. While restoring is set, ServerNetwork.onPong delays startConnected,
	// so we neither append new inputs to our stream nor send Ticks until the restore settled
	startRestore
		restoring = true
		restoreStartTime = core.currentTime
		restoreDeadline = core.currentTime + 5000
		nextRestoreRequestTime = 0
		core.log "#restore Joined with a preassigned userId -> requesting our previous session's input stream from all peers (we hold {input.localUser.inputs.writePos} bytes from IndexedDB)"

	private tickRestore: float now
		// Request our history from every peer that hasn't answered yet (repeated every second:
		// the data channel is unreliable and the channels open at different times)
		if now >= nextRestoreRequestTime
			nextRestoreRequestTime = now + 1000
			for input.internalUsers as user
				if . and not .local and .historyTotalLength < input.localUser.inputs.writePos and (hasOpenChannel(.) or ServerNetwork.connected)
					core.log "#restore <{.id}> Requesting our input history from {input.localUser.inputs.writePos}"
					sendBuffer.reset
					sendBuffer.writeInt8 cast PeerMessageType.StreamRequest
					sendBuffer.writeInt input.localUser.id
					sendBuffer.writeInt input.localUser.inputs.writePos
					send ., sendBuffer

		// Finished when every peer told us the total it holds and we received all of it,
		// or when the deadline passed (a peer is unreachable -> its copy is lost to us; our
		// new epoch keeps peers that still hold more of our old stream from being corrupted)
		bool allAnswered = true
		bool presentUnanswered = false
		for input.internalUsers as user
			if . and not .local and not .removed
				if .historyTotalLength == -1 or .historyTotalLength > input.localUser.inputs.writePos
					allAnswered = false
					if .historyTotalLength == -1 and .presentOnServer then presentUnanswered = true

		if allAnswered
			finishRestore "all peers answered"
		else
		if now > restoreDeadline
			// Don't give up while a server-listed peer simply hasn't answered yet: starting without
			// its copy risks appending a fork that only a discard-reload can repair, and right after
			// a reload the connections can take several seconds to re-establish. Waiting also means
			// the peers' streams arrive before we start stepping, so the catch-up replay parses them
			// at their true frames. Capped: a listed-but-dead peer must not block us forever
			if presentUnanswered and now < restoreStartTime + 30000
				restoreDeadline = now + 1000
				if now > lastRestoreWaitLogTime + 5000
					lastRestoreWaitLogTime = now
					core.log "#restore Waiting for present peers to answer ({math.round(now - restoreStartTime)} ms)"
			else
				finishRestore "timeout"

	private finishRestore: string reason
		restoring = false
		input.localUser.epochStartPos = input.localUser.inputs.writePos
		core.log "#restore Restore finished ({reason}): our own new inputs continue at {input.localUser.epochStartPos}"

		// Peers that never answered may still hold more of our previous stream than we restored
		// -> hold back new inputs and claims until every live peer confirmed its holdings, so
		// the doomed fork bytes never exist (see holdingConfirmationPending)
		string unconfirmedIds = ""
		for input.internalUsers as user
			if . and not .local and not .removed and (.historyTotalLength == -1 or .historyTotalLength > input.localUser.inputs.writePos)
				unconfirmedIds += " {.id}"
		if unconfirmedIds
			holdingConfirmationPending = true
			core.log "#restore Peers{unconfirmedIds} did not confirm their holdings of our stream -> not appending new inputs until every live peer confirmed"

	// While holdingConfirmationPending: request our history from every peer that has not
	// confirmed yet (the restore's request loop, continued past the restore timeout), and open
	// the gate once every live peer confirmed. A peer that never returns stops blocking when
	// the removal protocol removes it from the game
	private tickHoldingConfirmations: float now
		bool allConfirmed = true
		for input.internalUsers as user
			if . and not .local and not .removed and (.historyTotalLength == -1 or .historyTotalLength > input.localUser.inputs.writePos)
				allConfirmed = false
				if now >= nextRestoreRequestTime and (hasOpenChannel(.) or ServerNetwork.connected)
					core.log "#restore <{.id}> Requesting our input history from {input.localUser.inputs.writePos} (holding confirmation pending)"
					sendBuffer.reset
					sendBuffer.writeInt8 cast PeerMessageType.StreamRequest
					sendBuffer.writeInt input.localUser.id
					sendBuffer.writeInt input.localUser.inputs.writePos
					send ., sendBuffer
		if now >= nextRestoreRequestTime then nextRestoreRequestTime = now + 1000
		if allConfirmed then finishHoldingConfirmations

	// Every live peer confirmed its holdings: we hold the longest copy of our previous stream
	// (onOwnHistory adopted the reported bytes and raised epochStartPos and the claim floor),
	// so our new appends continue the group timeline instead of forking it
	private finishHoldingConfirmations
		holdingConfirmationPending = false
		// The gate held our claim (and with it the snapshot pin) down; new records may now be
		// stamped below existing ring snapshots - force the next pass back to the pinned snapshot
		core.markRemoteChange 0
		let localUser = input.localUser
		core.log "#restore Every live peer confirmed its holdings of our stream -> new inputs continue at {localUser.inputs.writePos}, stamps from {localUser.inputFrame}"
		// A rejoiner that could restore nothing at all (fresh IndexedDB and no live peer held
		// our old stream) deferred its Join event until now (see core.startConnected)
		if core.mode == Connected and localUser.inputs.writePos == 0 and localUser.epochStartPos == 0
			core.log "handleJoin (deferred)", core.frame
			localUser.startInputFrame 0
			input.handleJoin core.frame, core.account

	// Our own previous-session input stream as a peer stored it.
	// Bytes are append-only: we may only adopt a longer history while our stream is still exactly
	// the restored prefix - once we appended our own new inputs, nothing below writePos may change
	// any more (our snapshots and the other peers already reference it)
	private onOwnHistory: InternalUser peer, Buffer buffer, int totalLength, int claim, int startPos
		let savedReadPos = buffer.readPos
		let length = buffer.readInt
		buffer.readPos = savedReadPos

		if totalLength > peer.historyTotalLength then peer.historyTotalLength = totalLength
		let localUser = input.localUser
		core.log "#restore <{peer.id}> Received {length} bytes of our own history at {startPos} of {totalLength} (claimed up to frame {claim}), we have {localUser.inputs.writePos}"

		if not restoring and localUser.inputs.writePos != localUser.epochStartPos
			// Irreconcilable fork: a peer holds parts of our previous stream that our new appends
			// overwrote (our restore requests were lost, or IndexedDB lagged behind what we had
			// sent before the reload). Our appends can never join the group timeline - the peers
			// refuse them, correctly.
			// A fork is only proven when the peer holds MORE of our stream than we ever produced
			// (previous-session bytes we lost) or when its bytes DIFFER from ours at the same
			// positions. The peer's total merely exceeding epochStartPos is normal once the game
			// runs - peers hold our current-session appends too, and on a high-latency link late
			// duplicate restore answers routinely arrive after we started appending; treating those
			// as forks caused spurious reload loops.
			// The resilient exit: discard our forked inputs and reload. The restore then rebuilds
			// our stream purely from the peers' copies (this peer provably holds it and is alive -
			// it just sent it to us) and we resume as the same player. Only our few forked inputs
			// are lost, which nobody else ever saw
			if totalLength > localUser.inputs.writePos or not buffer.chunkMatches(localUser.inputs, startPos)
				core.log "#restore <{peer.id}> Peer stored {totalLength} bytes of our previous stream (we hold {localUser.inputs.writePos}, continued from {localUser.epochStartPos}), which forks our appended inputs -> discarding our forked inputs"
				discardForkedInputsAndReload
				return

		// The peer's claim for our stream is the floor for the stamps of our new records: peers
		// have parsed our old records up to it and their snapshots are only pinned down to claim+1,
		// so a new record stamped at or below it would be applied at different frames on live peers
		// vs replaying peers - a permanent desync. Only adopted once we hold the full stream the
		// claim covers, so the claims we send stay truthful (like the remote rule in onStreamData)
		adoptOwnClaimFloor totalLength, claim

		if startPos > localUser.inputs.writePos then return           // Would leave a gap
		if startPos + length <= localUser.inputs.writePos then return // Nothing new

		buffer.readBuffer localUser.inputs, startPos
		// Restored history records carry old stamps - predictions above the pin are invalid
		core.markRemoteChange 0
		if not restoring then localUser.epochStartPos = localUser.inputs.writePos
		adoptOwnClaimFloor totalLength, claim
		// More of our history may exist beyond this chunk - the 1s request loop keeps fetching.
		// Extend the deadline while we are making progress
		if restoring then restoreDeadline = math.max(restoreDeadline, core.currentTime + 2000)
		nextRestoreRequestTime = 0
		core.log "#restore <{peer.id}> Restored our input stream to {localUser.inputs.writePos} bytes"

	// Raise the stamp floor for our new input records to one above the claim a peer reported for
	// our own (pre-reload) stream. core.onFrame keeps localUser.inputFrame monotonic from there
	private adoptOwnClaimFloor: int totalLength, int claim
		let localUser = input.localUser
		if localUser.inputs.writePos >= totalLength and claim + 1 > localUser.inputFrame
			core.log "#restore Our previous session already claimed inputs up to frame {claim} -> new records start at frame {claim + 1}"
			localUser.inputFrame = claim + 1

	// --------------------------------------------- Ping/Pong ---------------------------------------------

	private pingPeers
		for input.internalUsers as user
			if user and not user.local and not user.removed and hasOpenChannel user
				sendBuffer.reset
				sendBuffer.writeInt8 cast PeerMessageType.Ping
				sendBuffer.writeFloat64 core.currentTime
				send ., sendBuffer

	private onPing: InternalUser user, Buffer buffer
		float pingTime = buffer.readFloat64
		sendBuffer.reset
		sendBuffer.writeInt8 cast PeerMessageType.Pong
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
	// video teardown - even though the hidden player is fine. Three measures:
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
		pingPeers
		sendInputs math.max(input.localUser.inputFrame-1, -1)

	// Tell every peer whether our tab is hidden, so they can show us as away and relax our
	// silence tolerance instead of reconnecting
	private sendStatus: bool hidden
		core.log "#background Sending status hidden:{hidden}"
		for input.internalUsers as user
			if . and not .local and not .removed
				sendBuffer.reset
				sendBuffer.writeInt8 cast PeerMessageType.Status
				sendBuffer.writeBool hidden
				send ., sendBuffer

	// Best-effort goodbye when our page is closing, navigating away or entering the back/forward cache
	private sendLeaving
		core.log "#background Sending leaving"
		for input.internalUsers as user
			if . and not .local and not .removed
				sendBuffer.reset
				sendBuffer.writeInt8 cast PeerMessageType.Leaving
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
				if(user && !user.local && !user.removed && user.peerConnection) {
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
				const sender = user.peerConnection.getSenders().find((s) => s.track && s.track.kind === videoTrack.kind);
				if(sender) sender.replaceTrack(videoTrack);
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
				const sender = user.peerConnection.getSenders().find((s) => s.track && s.track.kind === audioTrack.kind);
				if(sender) sender.replaceTrack(audioTrack);
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
