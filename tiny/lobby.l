unit lobby
	bool inLobby = true
	// transient: client-local config set from system.isStaging - must not be serialized into
	// snapshots (see 2D/lobby.l)
	transient bool enableFullscreen
	show
	tick
		// The tiny layer has no lobby UI (no videos, no start buttons), so a connected session
		// enters the app as soon as the first JoinUser event has parsed and players exist.
		// core.restart is guarded on input.isCertain: in rollback mode only the certain replay
		// of this frame passes it, in lockstep mode every stepped frame is certain - either way
		// every client leaves the lobby at the same deterministic frame. Players joining later
		// drop into the running app when their JoinUser event parses
		if input.players
			core.restart
