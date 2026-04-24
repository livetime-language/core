unit System
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
		
	inline js async string read: string filename
		require("fs").promises.readFile(filename, "utf8")
				
	inline js async string write: string data, string to
		require("fs").promises.writeFile(to, data, "utf8")
		
	inline js void createDirectory: string path
		require("fs").mkdirSync(path)
		
	js string[] showOpenDialog: FileFilter[] filters = null
		return require('@electron/remote').dialog.showOpenDialogSync({ filters, properties: ["openFile"] })
		
	js string showSaveDialog: FileFilter[] filters = null
		return require('@electron/remote').dialog.showSaveDialogSync({ filters, properties: ["createDirectory"] })
	
	async string[] readCsv: string filename, void(string[] values) processLine, void() then = null
		let content = await read(filename)
		for content.split("\n")[1..] as line
			bool inQuotes
			string value
			string[] results
			for line
				if . == "\""
					inQuotes = !inQuotes
				else
				if . == ',' and !inQuotes
					results.add value.trim
					value = ""
				else
					value += .
			if results.length
				results.add value.trim
				processLine(results)
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

interface ReadDirectoryResult
	string name
	FileType type
	
interface FileInfo
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
