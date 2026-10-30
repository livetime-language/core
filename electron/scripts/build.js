// Builds the Electron app of the project in the current folder
// Usage: node lib/core/electron/scripts/build.js <darwin|win32|linux> <arm64|x64> [--option=value ...]
//   --debug          fast build for testing in build/debug (see below)
//   --name           app name (default: name in the package.json of the source folder)
//   --version        app version (default: version in the package.json of the source folder)
//   --source         folder with boot.js and package.json (default: OutputPath in .livetime/targets.lc)
//   --icon           square PNG, relative to the source folder (default: Icon in .livetime/targets.lc)
//   --out            output folder (default: build/release, or build/debug with --debug)
//   --appId          bundle identifier, e.g. com.company.app (Mac)
//   --category       LSApplicationCategoryType, e.g. public.app-category.developer-tools (Mac)
//   --copyright      human-readable copyright (Mac)
//   --identity       "Developer ID Application: Name (TEAMID)" signing identity (Mac, without it the app is signed ad hoc)
//   --notaryProfile  notarytool keychain profile (Mac, requires --identity)
// lib/core/electron/scripts/mac/setup.js sets up a Mac for signing and notarization and adds VS Code tasks that call this script.
// Production builds install the runtime dependencies for the target platform (npm install --os --cpu), so every platform builds on any host; only macOS can sign the Mac app.
// Debug builds keep source maps, skip the hardened runtime, timestamps and notarization, and sign with the same identity every time,
// so macOS keeps the permissions and keychain access of the app. Built for this computer, they link the node_modules of the project instead of installing them,
// and when only the app files changed since the last debug build, they just replace those and reseal the bundle.
const {execSync} = require("child_process"), fs = require("fs"), os = require("os"), path = require("path"), {createHash} = require("crypto"), {pathToFileURL} = require("url")
const [platform, arch] = process.argv.slice(2), options = {}
for(const arg of process.argv.slice(4)) { const [, key, value = true] = arg.match(/^--(\w+)(?:=(.*))?$/s) ?? []; if(key) options[key] = value }
if(!["darwin", "win32", "linux"].includes(platform) || !["arm64", "x64"].includes(arch)) throw new Error("Usage: node build.js <darwin|win32|linux> <arm64|x64> [--option=value ...]")
const run = command => execSync(command, {stdio:"inherit"})
const targets = fs.existsSync(".livetime/targets.lc") ? fs.readFileSync(".livetime/targets.lc", "utf8") : ""
const target = key => targets.match(new RegExp(`^\\s*${key}:\\s*(.+?)\\s*$`, "m"))?.[1]
const resolve = id => require.resolve(id, {paths:[process.cwd()]})
const debug = options.debug, mac = platform == "darwin" && process.platform == "darwin", identity = mac && options.identity
const source = options.source ?? target("OutputPath") ?? "dist", out = options.out ?? (debug ? "build/debug" : "build/release")
const linkModules = debug && platform == process.platform && arch == process.arch

;(async () => {
	if(targets) run("livetime build")
	const app = JSON.parse(fs.readFileSync(source + "/package.json")), name = options.name ?? app.productName ?? app.name, version = options.version ?? app.version
	Object.assign(app, {productName:name, dependencies:JSON.parse(fs.readFileSync("package.json")).dependencies})
	const lock = fs.existsSync("package-lock.json") ? fs.readFileSync("package-lock.json", "utf8") : ""
	const electronVersion = require(resolve("electron/package.json")).version, icon = `${source}/${options.icon ?? target("Icon") ?? "icon.png"}`
	const appDir = `${out}/${name}-${platform}-${arch}`, bundle = `${appDir}/${name}.app`, resources = platform == "darwin" ? `${bundle}/Contents/Resources/app` : `${appDir}/resources/app`
	const sign = deep => run(`codesign --force${deep ? " --deep" : ""} --sign "${identity || "-"}" --timestamp=none "${bundle}"`)

	const stampFile = appDir + ".stamp", stamp = createHash("sha1").update(JSON.stringify([options, app, lock, electronVersion, linkModules, fs.statSync(icon).mtimeMs])).digest("hex")
	if(debug && fs.existsSync(resources) && fs.existsSync(stampFile) && fs.readFileSync(stampFile, "utf8") == stamp) {
		for(const file of fs.readdirSync(resources)) if(file != "node_modules") fs.rmSync(`${resources}/${file}`, {recursive:true})
		fs.cpSync(source, resources, {recursive:true})
		fs.writeFileSync(resources + "/package.json", JSON.stringify(app, null, "\t"))
		if(mac) sign(false)
		return console.log(`Updated ${appDir}`)
	}
	fs.rmSync(stampFile, {force:true})

	// .icns and .ico files can contain PNG images, so the app icon is wrapped without converting it
	const temp = fs.mkdtempSync(path.join(os.tmpdir(), "electron-build-")), png = fs.readFileSync(icon), size = png.readUInt32BE(16)
	const icns = Buffer.alloc(16), ico = Buffer.alloc(22)
	icns.write("icns"); icns.writeUInt32BE(16 + png.length, 4); icns.write({16:"icp4", 32:"icp5", 64:"icp6", 128:"ic07", 256:"ic08", 512:"ic09", 1024:"ic10"}[size], 8); icns.writeUInt32BE(8 + png.length, 12)
	ico.writeUInt16LE(1, 2); ico.writeUInt16LE(1, 4); ico.writeUInt8(size % 256, 6); ico.writeUInt8(size % 256, 7); ico.writeUInt16LE(1, 10); ico.writeUInt16LE(32, 12); ico.writeUInt32LE(png.length, 14); ico.writeUInt32LE(22, 18)
	fs.writeFileSync(temp + "/icon.icns", Buffer.concat([icns, png]))
	fs.writeFileSync(temp + "/icon.ico", Buffer.concat([ico, png]))

	const {packager} = await import(pathToFileURL(resolve("@electron/packager")))
	// Without asar, so executables of npm packages (e.g. claude, codex) can be spawned. Without pruning, which would remove peer dependencies
	// that packages import (e.g. zod, which the Claude Agent SDK imports) and must not touch the linked node_modules of the project
	await packager({dir:source, out, name, platform, arch, overwrite:true, asar:false, prune:false, ignore:debug ? [] : [/\.map$/], icon:temp + "/icon",
		electronVersion, appVersion:version, buildVersion:version, appBundleId:options.appId, appCategoryType:options.category, appCopyright:options.copyright,
		afterCopy:[({buildPath}) => {
			fs.writeFileSync(buildPath + "/package.json", JSON.stringify(app, null, "\t"))
			// A symlink is sealed by its path, so signing doesn't hash the hundreds of megabytes of agent binaries
			if(linkModules) return fs.symlinkSync(path.resolve("node_modules"), buildPath + "/node_modules", "junction")
			if(lock) fs.writeFileSync(buildPath + "/package-lock.json", lock)
			run(`cd "${buildPath}" && npm install --omit=dev --os=${platform} --cpu=${arch} --prefer-offline --no-audit --no-fund`)
			// The lockfile has no libc field, so npm installs the musl builds too, which Electron doesn't use
			for(const dir of fs.globSync(buildPath + "/node_modules/{*,@*/*}/*-musl")) fs.rmSync(dir, {recursive:true})
		}],
		// Executables of npm packages get their own entitlements: the hardened runtime blocks JIT compilers (e.g. Bun, which compiles claude) by default
		osxSign:!debug && identity && {identity, continueOnError:false, optionsForFile:file => file.includes(".app/Contents/Resources/") ? {entitlements:[
			"com.apple.security.cs.allow-jit", "com.apple.security.cs.allow-unsigned-executable-memory", "com.apple.security.cs.disable-executable-page-protection",
			"com.apple.security.cs.allow-dyld-environment-variables", "com.apple.security.cs.disable-library-validation"]} : {}}})
	fs.rmSync(temp, {recursive:true})

	// Packaging changes Info.plist, which breaks the signature: debug builds and builds without an identity are signed here, so macOS launches the app
	if(mac && (debug || !identity)) sign(true)
	if(debug) return fs.writeFileSync(stampFile, stamp)

	if(identity) {
		if(!options.notaryProfile) return console.warn("No --notaryProfile: the app is signed, but not notarized, so Gatekeeper blocks it on other Macs")
		const zip = `${out}/${name}-${version}-mac-${arch}.zip`, dmg = `${out}/${name}-${version}-${arch}.dmg`
		const notarize = file => {
			console.log(`Notarizing ${file} (this usually takes a few minutes)`)
			const result = JSON.parse(execSync(`xcrun notarytool submit "${file}" --keychain-profile "${options.notaryProfile}" --wait --output-format json`, {encoding:"utf8"}))
			if(result.status != "Accepted") { run(`xcrun notarytool log ${result.id} --keychain-profile "${options.notaryProfile}"`); throw new Error(`Notarization of ${file}: ${result.status}`) }
		}
		// The app and the disk image are notarized separately, so both have a stapled ticket and pass Gatekeeper offline
		run(`ditto -c -k --keepParent "${bundle}" "${zip}"`)
		notarize(zip)
		run(`xcrun stapler staple "${bundle}" && rm "${zip}" && ditto -c -k --keepParent "${bundle}" "${zip}"`)
		const dmgDir = `${out}/dmg-${arch}`
		fs.rmSync(dmgDir, {recursive:true, force:true}); fs.mkdirSync(dmgDir)
		fs.symlinkSync("/Applications", dmgDir + "/Applications")
		run(`ditto "${bundle}" "${dmgDir}/${name}.app" && hdiutil create -volname "${name}" -srcfolder "${dmgDir}" -ov -format UDZO "${dmg}" && codesign --sign "${identity}" --timestamp "${dmg}"`)
		fs.rmSync(dmgDir, {recursive:true})
		notarize(dmg)
		run(`xcrun stapler staple "${dmg}" && spctl --assess --type open --context context:primary-signature --verbose "${dmg}" && spctl --assess --type execute --verbose "${bundle}"`)
		console.log(`Ready to publish: ${dmg} and ${zip}`)
	}
	else if(platform == "win32") {
		// TODO: sign with Authenticode (@electron/windows-sign) and create an installer
	}
	else if(platform == "linux") {
		// TODO: create AppImage, .deb and .rpm packages
	}
})().catch(error => { console.error(error); process.exit(1) })
