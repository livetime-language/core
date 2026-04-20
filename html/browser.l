file
	inline js async FileSystemDirectoryHandle showDirectoryPicker: string mode = "readwrite"
		window.showDirectoryPicker({ @mode:mode })

interface FileSystemDirectoryHandle
	inline js async FileSystemFileHandle getFileHandle: string path, bool create = false
		this.getFileHandle(path, { @create:create })

interface FileSystemFileHandle
	inline js async File getFile()
		this.getFile()

