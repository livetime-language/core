unit lobby
	bool inLobby = true
	// transient: client-local config set from system.isStaging - must not be serialized into
	// snapshots (see 2D/lobby.l)
	transient bool enableFullscreen = true
	tick
