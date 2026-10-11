// File System abstraction for Desktop, Mobile and Web platforms. 
// Capacitor (Capacitor.Plugins.Filesystem)
// Node.js (require("fs") or process.getBuiltinModule("fs"))
// File System API (showDirectoryPicker, FileSystemDirectoryHandle, etc), if above not available
// IndexedDB, if basePathOrHandle == null or above not available

class DirEntry
	string name
	bool isDir

// Binary data, a JavaScript Uint8Array
js Uint8Array
immutable Bytes
	inline js Bytes(int[] list) new Uint8Array(list)

	inline js int get: implicit int index
		this[index]

	importance:5 inline js int length() this.length

	inline js int[] toList() Array.from(this)

	// Copy of the bytes from start (inclusive) to end (exclusive)
	inline js Bytes slice: int start, int end
		this.slice(start, end)

transient storage
	private dynamic basePathOrHandle = null

	setBasePathOrHandle: dynamic pathOrHandle
		this.basePathOrHandle = pathOrHandle

	// Pick the backend based on basePathOrHandle and the current platform's capabilities
	private js string backend
		const h = this.basePathOrHandle;
		if (h && typeof h.getDirectoryHandle === "function") return "fsapi"; // FileSystemDirectoryHandle
		if (typeof h === "string") {
			if (typeof Capacitor !== "undefined" && Capacitor.Plugins && Capacitor.Plugins.Filesystem) return "capacitor";
			if (typeof require === "function" || globalThis.process?.getBuiltinModule) return "node";
		}
		return "idb";

	// Show a directory picker dialog and set basePathOrHandle (string for Capacitor/Node.js, FileSystemDirectoryHandle for Web)
	// Use this basePathOrHandle for all subsequent file system operations
	async js async dynamic showDirectoryPicker
		if(_global.core && !_global.core.isPremiere) return;
		// Electron/Node desktop: native folder dialog returns an absolute path string
		if (typeof require === "function") {
			try {
				const remote = require("@electron/remote");
				const result = await remote.dialog.showOpenDialog({properties: ["openDirectory"]});
				if (result.canceled || !result.filePaths || !result.filePaths.length) return null;
				this.basePathOrHandle = result.filePaths[0];
				return result.filePaths[0];
			} catch (e) {}
		}
		// Web: File System Access API returns a FileSystemDirectoryHandle
		if (typeof window !== "undefined" && window.showDirectoryPicker) {
			const handle = await window.showDirectoryPicker({mode: "readwrite"});
			this.basePathOrHandle = handle;
			return handle;
		}
		return null;

	// Show a dialog to pick a file to open, returns null if canceled
	// The file can be passed to readBinaryFile and writeBinaryFile, getFileName returns its name. It is
	// Electron: an absolute path, Web: a FileSystemFileHandle or a File where the File System API is not available (Firefox, Safari, Capacitor)
	async js async dynamic showOpenFilePicker: string description, string mimeType, string[] extensions
		if(_global.core && !_global.core.isPremiere) return null;
		if (typeof require === "function") {
			try {
				const result = await require("@electron/remote").dialog.showOpenDialog({filters: [{name: description, extensions: extensions.map(e => e.replace(".", ""))}], properties: ["openFile"]});
				return result.canceled || !result.filePaths.length ? null : result.filePaths[0];
			} catch (e) {}
		}
		if (typeof window === "undefined") return null;
		if (window.showOpenFilePicker) {
			try {
				return (await window.showOpenFilePicker({types: [{description, accept: {[mimeType]: extensions}}]}))[0];
			} catch (e) { return null; }
		}
		return await new Promise(resolve => {
			const input = document.createElement("input");
			input.type = "file";
			input.accept = extensions.join(",");
			input.onchange = () => resolve(input.files[0] || null);
			input.oncancel = () => resolve(null);
			input.click();
		});

	// Show a dialog to pick where to save a file, returns null if canceled
	// Electron: an absolute path, Web: a FileSystemFileHandle, or an empty Blob named like the suggested name if the File System API is not available,
	// writeBinaryFile downloads it then (Firefox, Safari). Capacitor has no dialog, it returns the suggested name, a path relative to basePathOrHandle
	async js async dynamic showSaveFilePicker: string suggestedName, string description, string mimeType, string[] extensions
		if(_global.core && !_global.core.isPremiere) return null;
		if (typeof require === "function") {
			try {
				const result = await require("@electron/remote").dialog.showSaveDialog({defaultPath: suggestedName, filters: [{name: description, extensions: extensions.map(e => e.replace(".", ""))}], properties: ["createDirectory"]});
				return result.canceled || !result.filePath ? null : result.filePath;
			} catch (e) {}
		}
		if (typeof Capacitor !== "undefined" && Capacitor.isNativePlatform?.()) return suggestedName;
		if (typeof window === "undefined") return null;
		if (window.showSaveFilePicker) {
			try {
				return await window.showSaveFilePicker({suggestedName, types: [{description, accept: {[mimeType]: extensions}}]});
			} catch (e) { return null; }
		}
		return Object.assign(new Blob(), {name: suggestedName});	// The File constructor is replaced by the LiveTime class File

	// Name of a file returned by a file picker or the last part of a path
	js string getFileName: dynamic file
		return typeof file === "string" ? file.split(/[\\/]/).pop() : file.name;

	// Read a utf8 string from relative path using Capacitor/Node/File System API if basePathOrHandle is set, otherwise using IndexedDB
	async js async string readFile: string path
		switch (this.backend()) {
			case "capacitor": {
				try {
					const result = await Capacitor.Plugins.Filesystem.readFile({path: this.joinPath(path), encoding: "utf8"});
					return result.data;
				} catch (e) { return null; }
			}
			case "node": {
				try {
					return await this.nodeModule("fs").promises.readFile(this.joinPath(path), "utf8");
				} catch (e) { return null; }
			}
			case "fsapi": {
				try {
					const parts = path.split("/").filter(p => p.length);
					const name = parts.pop();
					let dir = this.basePathOrHandle;
					for (const part of parts) dir = await dir.getDirectoryHandle(part);
					const file = await (await dir.getFileHandle(name)).getFile();
					return await file.text();
				} catch (e) { return null; }
			}
			default: {
				const store = await this.idbStore("readonly");
				return await new Promise((resolve, reject) => {
					const r = store.get(path);
					r.onsuccess = () => resolve(r.result === undefined ? null : r.result);
					r.onerror = () => reject(r.error);
				});
			}
		}

	// Read the raw bytes of a file returned by a file picker or of the file at path (absolute or relative)
	// using Capacitor/Node/File System API if basePathOrHandle is set, otherwise using IndexedDB
	// Returns null if the file doesn't exist
	async js async Bytes readBinaryFile: dynamic path
		try {
			if (typeof path !== "string") return new Uint8Array(await (path.getFile ? await path.getFile() : path).arrayBuffer());
			switch (this.backend()) {
				case "capacitor": {
					// Native platforms return base64, the web implementation returns a Blob
					const data = (await Capacitor.Plugins.Filesystem.readFile({path: this.joinPath(path)})).data;
					if (typeof data !== "string") return new Uint8Array(await data.arrayBuffer());
					const binary = atob(data), bytes = new Uint8Array(binary.length);
					for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
					return bytes;
				}
				case "node": {
					const data = await this.nodeModule("fs").promises.readFile(this.joinPath(path));
					return new Uint8Array(data.buffer, data.byteOffset, data.byteLength);
				}
				case "fsapi": {
					const parts = path.split("/").filter(p => p.length);
					const name = parts.pop();
					let dir = this.basePathOrHandle;
					for (const part of parts) dir = await dir.getDirectoryHandle(part);
					const file = await (await dir.getFileHandle(name)).getFile();
					return new Uint8Array(await file.arrayBuffer());
				}
				default: {
					const store = await this.idbStore("readonly");
					const data = await new Promise((resolve, reject) => {
						const r = store.get(path);
						r.onsuccess = () => resolve(r.result);
						r.onerror = () => reject(r.error);
					});
					if (data == null) return null;
					if (typeof data === "string") return new TextEncoder().encode(data);
					if (data instanceof Blob) return new Uint8Array(await data.arrayBuffer());
					if (ArrayBuffer.isView(data)) return new Uint8Array(data.buffer, data.byteOffset, data.byteLength);
					return new Uint8Array(data);
				}
			}
		} catch (e) { return null; }

	// Write a utf8 string to relative path using Capacitor/Node/File System API if basePathOrHandle is set, otherwise using IndexedDB
	async js async void writeFile: string path, string content
		switch (this.backend()) {
			case "capacitor":
				await Capacitor.Plugins.Filesystem.writeFile({path: this.joinPath(path), data: content, encoding: "utf8", recursive: true});
				return;
			case "node": {
				const fs = this.nodeModule("fs").promises;
				const full = this.joinPath(path);
				await fs.mkdir(this.nodeModule("path").dirname(full), {recursive: true});
				await fs.writeFile(full, content, "utf8");
				return;
			}
			case "fsapi": {
				const parts = path.split("/").filter(p => p.length);
				const name = parts.pop();
				let dir = this.basePathOrHandle;
				for (const part of parts) dir = await dir.getDirectoryHandle(part, {create: true});
				const writable = await (await dir.getFileHandle(name, {create: true})).createWritable();
				await writable.write(content);
				await writable.close();
				return;
			}
			default: {
				const store = await this.idbStore("readwrite");
				await new Promise((resolve, reject) => {
					const r = store.put(content, path);
					r.onsuccess = () => resolve();
					r.onerror = () => reject(r.error);
				});
				return;
			}
		}

	// Write raw bytes to a file returned by a file picker or to the file at path (absolute or relative)
	// using Capacitor/Node/File System API if basePathOrHandle is set, otherwise using IndexedDB
	// A File or Blob (from the pickers without the File System API) can't be written, it is downloaded with its name
	// Returns false on failure
	async js async bool writeBinaryFile: dynamic path, Bytes bytes
		try {
			if (path instanceof Blob) {
				const link = document.createElement("a");
				link.href = URL.createObjectURL(new Blob([bytes]));
				link.download = path.name;
				link.click();
				setTimeout(() => URL.revokeObjectURL(link.href), 10000);
				return true;
			}
			if (typeof path !== "string") {
				if (await path.queryPermission?.({mode: "readwrite"}) === "prompt") await path.requestPermission({mode: "readwrite"});
				const writable = await path.createWritable();
				await writable.write(bytes);
				await writable.close();
				return true;
			}
			switch (this.backend()) {
				case "capacitor": {
					let binary = "";
					for (let i = 0; i < bytes.length; i += 0x8000) binary += String.fromCharCode.apply(null, bytes.subarray(i, i + 0x8000));
					await Capacitor.Plugins.Filesystem.writeFile({path: this.joinPath(path), data: btoa(binary), recursive: true});
					return true;
				}
				case "node": {
					const fs = this.nodeModule("fs").promises;
					const full = this.joinPath(path);
					await fs.mkdir(this.nodeModule("path").dirname(full), {recursive: true});
					await fs.writeFile(full, bytes);
					return true;
				}
				case "fsapi": {
					const parts = path.split("/").filter(p => p.length);
					const name = parts.pop();
					let dir = this.basePathOrHandle;
					for (const part of parts) dir = await dir.getDirectoryHandle(part, {create: true});
					const writable = await (await dir.getFileHandle(name, {create: true})).createWritable();
					await writable.write(bytes);
					await writable.close();
					return true;
				}
				default: {
					const store = await this.idbStore("readwrite");
					await new Promise((resolve, reject) => {
						const r = store.put(bytes, path);
						r.onsuccess = () => resolve();
						r.onerror = () => reject(r.error);
					});
					return true;
				}
			}
		} catch (e) { return false; }

	// Delete the file at relative path using Capacitor/Node/File System API if basePathOrHandle is set, otherwise using IndexedDB
	async js async void deleteFile: string path
		switch (this.backend()) {
			case "capacitor":
				try { await Capacitor.Plugins.Filesystem.deleteFile({path: this.joinPath(path)}); } catch (e) {}
				return;
			case "node":
				try { await this.nodeModule("fs").promises.unlink(this.joinPath(path)); } catch (e) {}
				return;
			case "fsapi": {
				try {
					const parts = path.split("/").filter(p => p.length);
					const name = parts.pop();
					let dir = this.basePathOrHandle;
					for (const part of parts) dir = await dir.getDirectoryHandle(part);
					await dir.removeEntry(name);
				} catch (e) {}
				return;
			}
			default: {
				const store = await this.idbStore("readwrite");
				await new Promise((resolve, reject) => {
					const r = store.delete(path);
					r.onsuccess = () => resolve();
					r.onerror = () => reject(r.error);
				});
				return;
			}
		}

	// Return a list of DirEntry objects for relative path using Capacitor/Node/File System API if basePathOrHandle is set, otherwise using IndexedDB
	async js async DirEntry[] readDirectory: string path
		switch (this.backend()) {
			case "capacitor": {
				const result = await Capacitor.Plugins.Filesystem.readdir({path: this.joinPath(path)});
				return result.files.map(f => new DirEntry(f.name, f.type === "directory"));
			}
			case "node": {
				const entries = await this.nodeModule("fs").promises.readdir(this.joinPath(path), {withFileTypes: true});
				return entries.map(e => new DirEntry(e.name, e.isDirectory()));
			}
			case "fsapi": {
				const parts = path.split("/").filter(p => p.length);
				let dir = this.basePathOrHandle;
				for (const part of parts) dir = await dir.getDirectoryHandle(part);
				const entries = [];
				for await (const [name, handle] of dir.entries()) entries.push(new DirEntry(name, handle.kind === "directory"));
				return entries;
			}
			default: {
				const store = await this.idbStore("readonly");
				const keys = await new Promise((resolve, reject) => {
					const r = store.getAllKeys();
					r.onsuccess = () => resolve(r.result);
					r.onerror = () => reject(r.error);
				});
				const prefix = path && !path.endsWith("/") ? path + "/" : path;
				const seen = new Set();
				const entries = [];
				for (const key of keys) {
					if (prefix && key.indexOf(prefix) !== 0) continue;
					const rest = key.slice(prefix.length);
					if (!rest.length) continue;
					const slash = rest.indexOf("/");
					const name = slash >= 0 ? rest.slice(0, slash) : rest;
					if (seen.has(name)) continue;
					seen.add(name);
					entries.push(new DirEntry(name, slash >= 0));
				}
				return entries;
			}
		}

	// Load a built-in Node.js module, require is not available in ES modules
	private js dynamic nodeModule: string name
		return typeof require === "function" ? require(name) : process.getBuiltinModule(name);

	// Join the base path string (Capacitor/Node) with a relative path, file: URLs and absolute Node paths are kept
	private js string joinPath: string path
		const base = this.basePathOrHandle;
		if (!base || path.startsWith("file:") || this.backend() === "node" && this.nodeModule("path").isAbsolute(path)) return path;
		return base.replace(/\/+$/, "") + "/" + path.replace(/^\/+/, "");

	// Open the IndexedDB object store used as the fallback file system, in the given transaction mode
	private js dynamic idbStore: string mode
		return new Promise((resolve, reject) => {
			const request = indexedDB.open("FileSystem", 1);
			request.onupgradeneeded = () => request.result.createObjectStore("files");
			request.onerror = () => reject(request.error);
			request.onsuccess = () => resolve(request.result.transaction("files", mode).objectStore("files"));
		});
