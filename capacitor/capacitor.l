file
	async string read: string filename
		const result = await Capacitor.Plugins.Filesystem.readFile({path:filename, encoding:"utf8"})
		return result.data

	getFileUrl: string filename, string cacheKey = null
		if cacheKey then	return Platform.protocolAndHost() + "/_capacitor_content_/org.livetime.mygames.media?path=" + Platform.encodeURIComponent(filename) + "&cacheKey=" + cacheKey
		else	return Platform.protocolAndHost() + "/_capacitor_content_/org.livetime.mygames.media?path=" + Platform.encodeURIComponent(filename)

	readdir

	async bool exists: string filename
		try
			await Capacitor.Plugins.Filesystem.stat({path:filename})
			return true
		catch
			return false

	async ReadDirectoryResult[] readDirectory: string path
		return await Capacitor.Plugins.Filesystem.readdir({path:path})

	async FileInfo getInfo: string path
		try
			let stat = await Capacitor.Plugins.Filesystem.stat({path:path})
			stat.creationTime = stat.ctime
			stat.modificationTime = stat.mtime
			return stat
		catch
			return null

	async string getHash: string path
		let result = await Capacitor.Plugins.Filesystem.readFile({path})
		let binary = atob(result.data)
		let bytes = new Uint8Array(binary.length)
		for binary.length
			bytes[i] = binary.charCodeAt(i)
		let hashBytes = new Uint8Array(await crypto.subtle.digest("SHA-1", bytes))
		string hash
		for hashBytes.length
			hash += hashBytes[i].toString(16).padStart(2, "0")
		return hash

	async void write: string text
		              string to
		await Capacitor.Plugins.Filesystem.writeFile({path:to, data:text, encoding:"utf8"})

	async void copy: string from
		            string to
		let slash = to.lastIndexOf("/")
		if slash != -1
			await createDirectory(to[0 to slash], recursive:true)
		let result = await Capacitor.Plugins.Filesystem.readFile({path:from})
		await Capacitor.Plugins.Filesystem.writeFile({path:to, data:result.data})

	async bool saveUrl: string url
		               string to
		let response = await fetch(url)
		if not response.ok then return false
		let type = (response.headers.get("content-type") or "").toLowerCase
		if type.contains("text") or type.contains("json") or type.contains("xml") or type.contains("html")
			let text = ((await response.text) or "").trim
			if text == "NOMEDIA" or text == "CRCOK" or text == "MD5OK" or text == "SHA1OK" or text.startsWith("Erreur") then return false
			return false
		let slash = to.lastIndexOf("/")
		if slash != -1
			await createDirectory(to[0 to slash], recursive:true)
		let bytes = new Uint8Array(await response.arrayBuffer())
		let binary = ""
		for bytes.length
			binary += string.fromCharCode bytes[i]
		await Capacitor.Plugins.Filesystem.writeFile({path:to, data:btoa(binary)})
		return true

	async void createDirectory: string path
		                     bool recursive = true
		await Capacitor.Plugins.Filesystem.mkdir({path:path, recursive})

	void execute: string command

unit Platform
	//inline js string os() Capacitor.getPlatform()
	openDevTools
		print "Dev Tools"

	inline js void onResume: void() do
		Capacitor?.Plugins?.App?.addListener("resume",	do)	

	// inline js void onResume: inline void() code
	// 	Capacitor?.Plugins?.App?.addListener("resume", () => code())

enum lowercase string FileType: File, Directory

interface ReadDirectoryResult
	string name	// The name of the file or directory.
	FileType type	// "file" or "directory"

	int size	// Capacitor only: The size of the file in bytes.
	int ctime	// Capacitor only: The time the file was last changed in milliseconds
	int mtime	// Capacitor only: The time the file was last modified in milliseconds
	string uri	// Capacitor only: The URI of the file.

interface FileInfo
	int	size	// The size of the file in bytes
	float	creationTime	// The time the file was created, in milliseconds since the Unix epoch
	float	modificationTime	// The time the file was last modified, in milliseconds since the Unix epoch

	string name	// Capacitor only: The name of the file or directory.
	FileType type	// Capacitor only: "file" or "directory"
	int ctime	// Capacitor only: The time the file was last changed in milliseconds
	int mtime	// Capacitor only: The time the file was last modified in milliseconds
	string uri	// Capacitor only: The URI of the file.
