file
	async string read: string filename
		const result = await Capacitor.Plugins.Filesystem.readFile({path:filename, encoding:"utf8"})
		return result.data

	getFileUrl: string filename
		return Platform.protocolAndHost() + "/_capacitor_content_/org.livetime.mygames.media?path=" + Platform.encodeURIComponent(filename)

	readdir

	async bool exists: string filename
		try
			await Capacitor.Plugins.Filesystem.stat({path:filename})
			return true
		catch
			return false

unit Platform
	//inline js string os() Capacitor.getPlatform()
	openDevTools
		print "Opening dev tools"