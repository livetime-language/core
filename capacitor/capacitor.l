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

	async void write: string text
		              string to
		await Capacitor.Plugins.Filesystem.writeFile({path:to, data:text, encoding:"utf8"})

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
