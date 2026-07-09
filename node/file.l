global transient skipInit unit system
	global inline js dynamic require: string moduleName
		require(moduleName)

file
	inline js string homeDirectory() require("os").homedir()
	
	js async void save: string text
		                string to
		const fs = require("fs").promises;
		await fs.writeFile(to, text)
		
	js async void save: ArrayBuffer buffer
		                string to
		const fs = require("fs").promises;
		const { Buffer } = require('node:buffer');
		await fs.writeFile(to, Buffer.from(buffer), {encoding:null})

	js async void save: dynamic object
		                string to
		const fs = require("fs").promises;
		await fs.writeFile(to, JSON.stringify(object, null, "\t"))

	js async void copy: string from
		                string to
		const fs = require("fs").promises;
		const path = require("path");
		await fs.mkdir(path.dirname(to), {recursive:true})
		await fs.copyFile(from, to)

	js async void move: string from
		                string to
		const fs = require("fs").promises;
		const path = require("path");
		await fs.mkdir(path.dirname(to), {recursive:true})
		await fs.rename(from, to)

	js async bool saveUrl: string url
		                   string to
		const fs = require("fs").promises;
		const path = require("path");
		const { Buffer } = require("node:buffer");
		const response = await fetch(url)
		if(!response.ok) return false
		const type = (response.headers.get("content-type") || "").toLowerCase()
		if(type.includes("text") || type.includes("json") || type.includes("xml") || type.includes("html")) {
			const text = (await response.text()).trim()
			if(text == "NOMEDIA" || text == "CRCOK" || text == "MD5OK" || text == "SHA1OK" || text.startsWith("Erreur")) return false
			return false
		}
		await fs.mkdir(path.dirname(to), {recursive:true})
		await fs.writeFile(to, Buffer.from(await response.arrayBuffer()), {encoding:null})
		return true
		
	js void download: string text
		              string to
		var element = document.createElement("a");
		element.setAttribute("href", "data:text/plain;charset=utf-8," + encodeURIComponent(text));
		element.setAttribute("download", to);
		element.style.display = "none";
		document.body.appendChild(element);
		element.click();
		document.body.removeChild(element);
		
	js async ReadDirectoryResult[] readDirectory: string path
		let fs = require("fs").promises
		let infos = await fs.readdir(path, { withFileTypes: true })
		let result = []
		for(let info of infos)
			result.push( { name: info.name, type: info.isDirectory() ? "directory" : "file" } )
		return result
				
	js async FileInfo getInfo: string path
		try {
			let stat = await require("fs").promises.stat(path);
			stat.creationTime = stat.birthtimeMs;
			stat.modificationTime = stat.mtimeMs;
			return stat;
		} catch (error) {
			return null
		}

	js async string getHash: string path
		const fs = require("fs").promises;
		const crypto = require("crypto");
		const buffer = await fs.readFile(path);
		return crypto.createHash("sha1").update(buffer).digest("hex")

	js async string getHashOfFirstZipFile: string path
		const fs = require("fs").promises;
		const crypto = require("crypto");
		const zlib = require("zlib");
		const buffer = await fs.readFile(path);
		const fileBytes = getFirstZipFileBytes(buffer, data => zlib.inflateRawSync(data));
		return crypto.createHash("sha1").update(fileBytes).digest("hex")

		function getFirstZipFileBytes(bytes, inflateRaw) {
			const readUInt16 = offset => bytes.readUInt16LE(offset);
			const readUInt32 = offset => bytes.readUInt32LE(offset);
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
				if(compressionMethod == 8) return inflateRaw(compressedBytes);
				throw new Error(`Unsupported ZIP compression method: ${compressionMethod}`);
			}
			throw new Error("Invalid ZIP file: no file entries found");
		}
	
	js async bool exists: string path
		try {
			let stat = await require("fs").promises.stat(path)
			return stat != null
		} catch (error) {
			return false
		}
		
	js async string[] readDirectorySortedByTime: string path
		try {
			const fs = require("fs").promises
			const p = require("path")
			
			const files = await fs.readdir(path)
			const filesWithStats = await Promise.all(files.map(async name => {
				const filePath = p.join(path, name);
				const stats = await fs.stat(filePath);
				return { name, time: stats.birthtimeMs };
			}));
	
			filesWithStats.sort((a, b) => a.time - b.time);
			return filesWithStats.map(file => file.name);
		} catch (error) {
			console.error(error);
			return [];
		}
		
	inline js async void rename: string from, string to
		require("fs").promises.rename(from, to)

	js async bool delete: string path
		try {
			await require("fs").promises.rm(path)
			return true
		} catch (error) {
			return false
		}
		
	inline js async string read: string filename
		require("fs").promises.readFile(filename, "utf8")
				
	inline js async string write: string data, string to
		require("fs").promises.writeFile(to, data, "utf8")
		
	inline js async void createDirectory: string path
		                                  bool recursive = true
		require("fs").promises.mkdir(path, {@recursive:recursive})
		
	js string[] showOpenDialog: FileFilter[] filters = null
		return require('@electron/remote').dialog.showOpenDialogSync({ filters, properties: ["openFile"] })
		
	js string showSaveDialog: FileFilter[] filters = null
		return require('@electron/remote').dialog.showSaveDialogSync({ filters, properties: ["createDirectory"] })
	
	async string[] readCsv: string filename, void(string[] values) processItem, void() then = null
		let content = await read(filename)
		bool inQuotes
		string quoteChar
		string value
		string[] results
		bool isFirstRow = true
		for content
			if inQuotes
				if . == quoteChar
					inQuotes = false
				else
					value += .
			else
			if . == "\"" or . == "'"
				inQuotes = true
				quoteChar = .
			else
			if . == ','
				results.add value.trim
				value = ""
			else
			if . == "\n"
				if results.length
					results.add value.trim
					if not isFirstRow
						processItem(results)
				value = ""
				results = []
				isFirstRow = false
			else
				value += .
		if results.length
			results.add value.trim
			if not isFirstRow
				processItem(results)
		if then != null
			then()
	
	async string[] readTsv: string filename, void(string[] values) processLine
		let content = await read(filename)
		for content.split("\n")[1..] as line
			if line
				let values = line.split("\t")
					processLine(values)

	getFileUrl: string filename, string cacheKey = null
		if cacheKey then	return "file://{filename}?cacheKey={cacheKey}"
		else	return "file://{filename}"

	inline js void execute: string command
		require("child_process").exec(command, (error, stdout, stderr) => {
			if (error) {
				console.error(`Error executing command: ${error}`)
				return
			}
			if (stdout) console.log(`Output: ${stdout}`)
			if (stderr) console.error(`Error Output: ${stderr}`)
		})
	
interface ArrayBuffer
struct FileFilter
	string name
	string[] extensions

enum lowercase string FileType: File, Directory

class ReadDirectoryResult
	string name
	FileType type
	
class FileInfo
	int	size	// The size of the file in bytes
	float	creationTime	// The time the file was created, in milliseconds since the Unix epoch
	float	modificationTime	// The time the file was last modified, in milliseconds since the Unix epoch

	int	dev	// Node.js only: The numeric identifier of the device containing the file.
	int	ino	// Node.js only: The file system specific "Inode" number for the file.
	int	mode	// Node.js only: A bit-field describing the file type and mode.
	int	nlink	// Node.js only: The number of hard-links that exist for the file.
	int	uid	// Node.js only: The numeric user identifier of the user that owns the file (POSIX).
	int	gid	// Node.js only: The numeric group identifier of the group that owns the file (POSIX).
	int	rdev	// Node.js only: A numeric device identifier if the file represents a device.
	int	blksize	// Node.js only: The file system block size for i/o operations.
	int	blocks	// Node.js only: The number of blocks allocated for this file.
	float	atimeMs	// Node.js only: The time the file was last accessed in milliseconds
	float	mtimeMs	// Node.js only: The time the file was last modified in milliseconds
	float	ctimeMs	// Node.js only: The time the file was last changed in milliseconds
	float	birthtimeMs	// Node.js only: The time the file was created in milliseconds
	string	atime	// Node.js only: The time the file was last accessed as a string
	string	mtime	// Node.js only: The time the file was last modified as a string
	string	ctime	// Node.js only: The time the file was last changed as a string
	string	birthtime	// Node.js only: The time the file was created as a string
