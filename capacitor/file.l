file
	js async string read: string filename
		const result = await Capacitor.Plugins.Filesystem.readFile({path:filename, encoding:"utf8"})
		return result.data

	getFileUrl: string filename
		return Platform.protocolAndHost() + "/_capacitor_content_/org.livetime.mygames.media?path=" + Platform.encodeURIComponent(filename)

// unit Platform
// 	inline js string os() Capacitor.getPlatform()
