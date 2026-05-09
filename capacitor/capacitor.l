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
		let result = await Capacitor.Plugins.Filesystem.readdir({path:path})
		return result.files or result

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

	js async string getHash: string path
		const result = await Capacitor.Plugins.Filesystem.readFile({path})
		const bytes = Uint8Array.from(atob(result.data), c => c.charCodeAt(0))
		const hash = await crypto.subtle.digest("SHA-1", bytes)
		return Array.from(new Uint8Array(hash), b => b.toString(16).padStart(2, "0")).join("")

	js async string getHashOfFirstZipFile: string path
		const result = await Capacitor.Plugins.Filesystem.readFile({path})
		const bytes = Uint8Array.from(atob(result.data), c => c.charCodeAt(0))
		const fileBytes = await getFirstZipFileBytes(bytes, inflateRaw)
		const hash = await crypto.subtle.digest("SHA-1", fileBytes)
		return Array.from(new Uint8Array(hash), b => b.toString(16).padStart(2, "0")).join("")

		async function inflateRaw(bytes) {
			if(typeof DecompressionStream == "undefined") throw new Error("ZIP deflate is not supported on this platform")
			const stream = new Blob([bytes]).stream().pipeThrough(new DecompressionStream("deflate-raw"))
			return new Uint8Array(await new Response(stream).arrayBuffer())
		}

		async function getFirstZipFileBytes(bytes, inflateRaw) {
			const readUInt16 = offset => bytes[offset] | (bytes[offset + 1] << 8);
			const readUInt32 = offset => (bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16) | (bytes[offset + 3] << 24)) >>> 0;
			const minEndOffset = Math.max(0, bytes.length - 0xffff - 22);
			let endOffset = -1;
			for(let offset = bytes.length - 22; offset >= minEndOffset; offset--) {
				if(readUInt32(offset) == 0x06054b50) {
					endOffset = offset;
					break;
				}
			}
			if(endOffset < 0) throw new Error("Invalid ZIP file: end of central directory not found");
			let directoryOffset = readUInt32(endOffset + 16);
			const entryCount = readUInt16(endOffset + 10);
			for(let entryIndex = 0; entryIndex < entryCount; entryIndex++) {
				if(readUInt32(directoryOffset) != 0x02014b50) throw new Error("Invalid ZIP file: central directory entry not found");
				const compressionMethod = readUInt16(directoryOffset + 10);
				const compressedSize = readUInt32(directoryOffset + 20);
				const fileNameLength = readUInt16(directoryOffset + 28);
				const extraLength = readUInt16(directoryOffset + 30);
				const commentLength = readUInt16(directoryOffset + 32);
				const localHeaderOffset = readUInt32(directoryOffset + 42);
				const fileNameStart = directoryOffset + 46;
				const isDirectory = fileNameLength > 0 && bytes[fileNameStart + fileNameLength - 1] == 47;
				directoryOffset += 46 + fileNameLength + extraLength + commentLength;
				if(isDirectory) continue;
				if(readUInt32(localHeaderOffset) != 0x04034b50) throw new Error("Invalid ZIP file: local file header not found");
				const localFileNameLength = readUInt16(localHeaderOffset + 26);
				const localExtraLength = readUInt16(localHeaderOffset + 28);
				const dataStart = localHeaderOffset + 30 + localFileNameLength + localExtraLength;
				const compressedBytes = bytes.subarray(dataStart, dataStart + compressedSize);
				if(compressionMethod == 0) return compressedBytes;
				if(compressionMethod == 8) return await inflateRaw(compressedBytes);
				throw new Error(`Unsupported ZIP compression method: ${compressionMethod}`);
			}
			throw new Error("Invalid ZIP file: no file entries found");
		}

	js async void copy: string from
		                string to
		const directory = to.includes("/") ? to.substring(0, to.lastIndexOf("/")) : ""
		if(directory) {
			try { await Capacitor.Plugins.Filesystem.mkdir({path:directory, recursive:true}) } catch {}
		}
		await Capacitor.Plugins.Filesystem.copy({from, to})

	js async void move: string from
		                string to
		const directory = to.includes("/") ? to.substring(0, to.lastIndexOf("/")) : ""
		if(directory) {
			try { await Capacitor.Plugins.Filesystem.mkdir({path:directory, recursive:true}) } catch {}
		}
		await Capacitor.Plugins.Filesystem.rename({from, to})

	js async bool delete: string path
		try {
			await Capacitor.Plugins.Filesystem.deleteFile({path})
			return true
		} catch(error) {
			return false
		}

	js async bool saveUrl: string url
		                   string to
		try {
			const response = await Capacitor.Plugins.CapacitorHttp.get({url, responseType:"arraybuffer"})
			const type = Object.entries(response.headers || {}).find(([key]) => key.toLowerCase() == "content-type")?.[1]?.toLowerCase() || ""
			if(response.status < 200 || response.status >= 300) return false
			if(type.includes("text") || type.includes("json") || type.includes("xml") || type.includes("html")) return false
			let data = response.data
			if(data instanceof ArrayBuffer) data = arrayBufferToBase64(data)
			else if(ArrayBuffer.isView(data)) data = arrayBufferToBase64(data.buffer)
			else if(Array.isArray(data)) data = arrayBufferToBase64(new Uint8Array(data).buffer)
			else if(typeof data == "string" && data.startsWith("data:")) data = data.split(",")[1]
			if(typeof data != "string" || !data) return false
			await Capacitor.Plugins.Filesystem.writeFile({path:to, data, recursive:true})
			return true
		} catch(error) {
			return false
		}

	inline js string arrayBufferToBase64(dynamic buffer) => { let binary = ""; const bytes = new Uint8Array(buffer); for(let i = 0; i < bytes.byteLength; i += 0x8000) binary += String.fromCharCode(...bytes.subarray(i, i + 0x8000)); return btoa(binary); }

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
