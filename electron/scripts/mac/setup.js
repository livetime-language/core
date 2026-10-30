// Sets up this Mac to build, sign and notarize the Electron app of the project in the current folder,
// and adds the VS Code tasks "Build Debug" (fast, for testing) and "Build Production" (signed and notarized, to publish), which call ../build.js with the answers.
// Usage: node lib/core/electron/scripts/mac/setup.js (from the project folder)
// Safe to run again: it skips what is already set up and offers the previous answers as defaults.
// Signing requires a Developer ID Application certificate, which only the Account Holder of an Apple Developer Program membership can create.
// Notarization uses an app-specific password, stored in the keychain as a notarytool profile that all projects of the team share.
const {execSync, spawnSync} = require("child_process"), fs = require("fs"), os = require("os"), path = require("path"), readline = require("readline/promises")
const run = command => execSync(command, {stdio:"inherit"})
const output = command => { try { return execSync(command, {encoding:"utf8", stdio:"pipe"}).trim() } catch { return null } }
const ask = async (question, answer) => {
	// A new interface for every question, so the commands in between (e.g. notarytool) can read from the terminal
	const rl = readline.createInterface({input:process.stdin, output:process.stdout})
	const reply = (await rl.question(answer ? `${question} [${answer}]: ` : `${question}: `)).trim()
	rl.close()
	return reply || answer
}
const confirm = async question => /^y/i.test(await ask(question + " (y/n)", "y"))
// Paths dragged into the terminal are quoted or have escaped spaces
const askPath = async (question, answer) => (await ask(question, answer) ?? "").replace(/^'(.*)'$/, "$1").replace(/\\(.)/g, "$1")
const step = title => console.log(`\n\x1b[1m${title}\x1b[0m`)
const keychain = os.homedir() + "/Library/Keychains/login.keychain-db", downloads = os.homedir() + "/Downloads"
const tasksFile = ".vscode/tasks.json", debugLabel = "\uF8FF Build Debug", productionLabel = "\uF8FF Build Production"

;(async () => {
	if(process.platform != "darwin") throw new Error("Run this script on a Mac")
	if(!fs.existsSync("package.json")) throw new Error("Run this script from the project folder")

	// Finds a task by its label in the JSONC text of tasks.json (which can have comments and trailing commas) to keep the rest of the file as it is
	let tasks = fs.existsSync(tasksFile) ? fs.readFileSync(tasksFile, "utf8") : '{\n\t"version": "2.0.0",\n\t"tasks": [\n\t]\n}\n'
	const findTask = label => {
		const at = tasks.search(new RegExp(`"label"\\s*:\\s*"${label}"`)), start = tasks.lastIndexOf("{", at)
		if(at >= 0) for(let i = start, depth = 0, quoted = false; i < tasks.length; i++) {
			if(quoted) { if(tasks[i] == "\\") i++; else if(tasks[i] == '"') quoted = false }
			else if(tasks[i] == '"') quoted = true
			else if(tasks[i] == "{") depth++
			else if(tasks[i] == "}" && --depth == 0) return [start, i + 1]
		}
	}
	const previous = {}
	for(const range of [findTask(debugLabel), findTask(productionLabel)]) if(range)
		for(const [, key, value] of tasks.slice(...range).matchAll(/"--(\w+)=((?:[^"\\]|\\.)*)"/g)) previous[key] = JSON.parse(`"${value}"`)

	step("Xcode Command Line Tools (codesign, notarytool, stapler)")
	if(!output("xcode-select -p")) {
		output("xcode-select --install")
		while(!output("xcode-select -p")) await ask("Click \"Install\" in the dialog and press Enter when the installation has finished")
	}
	console.log("✓ " + output("xcode-select -p"))

	step("Electron")
	if(!fs.existsSync("node_modules/electron")) run(`sh "${path.dirname(__dirname)}/setup.sh"`)
	if(!fs.existsSync("node_modules/@electron/packager")) run("npm install --save-dev @electron/packager")
	console.log(`✓ Electron ${require(path.resolve("node_modules/electron/package.json")).version}`)

	step("App")
	const name = await ask("App name", previous.name ?? path.basename(process.cwd()))
	const segment = text => text.toLowerCase().replace(/[^a-z0-9-]+/g, "")
	const appId = await ask("Bundle identifier (keep it after the first release)", previous.appId ?? `com.${segment(os.userInfo().username)}.${segment(name)}`)
	console.log("Categories: https://developer.apple.com/documentation/bundleresources/information-property-list/lsapplicationcategorytype")
	const category = await ask("Category", previous.category ?? "public.app-category.productivity")

	step("Developer ID certificate")
	// codesign needs Apple's intermediate certificate to build the chain of trust (security import fails harmlessly if it is already there)
	output(`curl -fsSL -o "${os.tmpdir()}/DeveloperIDG2CA.cer" https://www.apple.com/certificateauthority/DeveloperIDG2CA.cer && security import "${os.tmpdir()}/DeveloperIDG2CA.cer" -k "${keychain}"`)
	const identities = () => [...(output("security find-identity -v -p codesigning") ?? "").matchAll(/"(Developer ID Application: .+? \(\w+\))"/g)].map(match => match[1])
	let found = identities(), created = false, appleId = output("git config user.email")
	if(!found.length) {
		console.log("Signing requires a Developer ID Application certificate of the Apple Developer Program (99 USD per year).")
		if(!await confirm("Are you enrolled in the Apple Developer Program?")) {
			run("open https://developer.apple.com/programs/enroll/")
			return console.log("Enroll in the browser. Apple's approval can take up to 48 hours. Then run this script again.")
		}
		const p12 = await askPath("Path of a .p12 file exported from Keychain Access on another Mac (leave empty to create a new certificate)")
		// security import asks for the password of the .p12 file in a dialog
		if(p12) run(`security import "${p12}" -k "${keychain}" -T /usr/bin/codesign`)
		else {
			const dir = fs.mkdtempSync(path.join(os.tmpdir(), "developer-id-")), csr = `${downloads}/DeveloperID.certSigningRequest`, started = Date.now()
			// The request is only needed for the upload: delete it however the script ends (Ctrl+C included)
			process.on("exit", () => fs.rmSync(csr, {force:true})).on("SIGINT", () => process.exit(130))
			appleId = await ask("Apple ID (email)", appleId)
			run(`/usr/bin/openssl genrsa -out "${dir}/key.pem" 2048 && /usr/bin/openssl req -new -key "${dir}/key.pem" -out "${csr}" -subj "/emailAddress=${appleId}/CN=${output("git config user.name") ?? os.userInfo().username}"`)
			// The private key goes straight into the login keychain, where codesign finds it once the certificate is imported
			run(`security import "${dir}/key.pem" -k "${keychain}" -t priv -f openssl -T /usr/bin/codesign`)
			fs.rmSync(dir, {recursive:true})
			run(`open https://developer.apple.com/account/resources/certificates/add && open -R "${csr}"`)
			console.log(`In the browser:
  1. Sign in as the Account Holder (only the Account Holder can create Developer ID certificates)
  2. Select "Developer ID Application"
  3. Click "Continue"
  4. Select the profile type "G2 Sub-CA"
  5. Click "Choose File" and select ${csr}
  6. Click "Continue"
  7. Click "Download"`)
			await ask("Press Enter when the certificate has been downloaded")
			const latest = fs.readdirSync(downloads).filter(file => file.endsWith(".cer")).map(file => `${downloads}/${file}`)
				.filter(file => fs.statSync(file).mtimeMs > started).sort((a, b) => fs.statSync(b).mtimeMs - fs.statSync(a).mtimeMs)[0]
			const cer = await askPath("Certificate file", latest)
			run(`security import "${cer}" -k "${keychain}"`)
			created = true
		}
		found = identities()
		if(!found.length) throw new Error("No valid Developer ID Application identity in the keychain. Check the certificate in Keychain Access (login > My Certificates) and run this script again.")
	}
	found.forEach((identity, i) => console.log(`  ${i + 1}) ${identity}`))
	const identity = found.length == 1 ? found[0] : found[await ask("Signing identity", String(found.indexOf(previous.identity) + 1 || 1)) - 1] ?? found[0]
	const teamId = identity.match(/\((\w+)\)$/)[1]
	console.log("✓ " + identity)

	step("Notarization")
	const notaryProfile = `notary-${teamId}`
	if(output(`xcrun notarytool history --keychain-profile "${notaryProfile}"`) == null) {
		run("open https://account.apple.com/account/manage")
		console.log(`Notarization needs an app-specific password. In the browser:
  1. Sign in with your Apple ID
  2. Click "App-Specific Passwords"
  3. Click "+" or "Create App-Specific Passwords"
  4. Enter "notarytool" and click "Create"
  5. Copy the displayed password and paste it below`)
		appleId = await ask("Apple ID (email)", appleId)
		// notarytool asks for the password, checks the credentials with Apple and stores them in the keychain
		while(spawnSync("xcrun", ["notarytool", "store-credentials", notaryProfile, "--apple-id", appleId, "--team-id", teamId], {stdio:"inherit"}).status)
			console.log("Try again or press Ctrl+C to cancel. If Apple asks to accept an agreement, accept it at https://developer.apple.com/account first.")
	}
	console.log(`✓ Keychain profile ${notaryProfile}`)

	step("VS Code tasks")
	const build = path.relative(process.cwd(), path.join(__dirname, "..", "build.js")).split(path.sep).join("/")
	const args = [build, "darwin", "arm64", `--name=${name}`, `--appId=${appId}`, `--category=${category}`, `--identity=${identity}`], debugArgs = [...args, "--debug"]
	// Inserted at the top in reverse order, so "Build Debug" comes first
	for(const [label, taskArgs] of [[productionLabel, [...args, `--notaryProfile=${notaryProfile}`]], [debugLabel, debugArgs]]) {
		const task = JSON.stringify({label, type:"process", command:"node", args:taskArgs, problemMatcher:[]}, null, "\t").replace(/\n/g, "\n\t\t"), range = findTask(label)
		tasks = range ? tasks.slice(0, range[0]) + task + tasks.slice(range[1]) : tasks.replace(/"tasks"\s*:\s*\[/, match => `${match}\n\t\t${task},`)
		console.log(`✓ ${tasksFile}: "${label}"`)
	}
	fs.mkdirSync(".vscode", {recursive:true})
	fs.writeFileSync(tasksFile, tasks)

	step("Done")
	console.log(`"${debugLabel}" builds build/debug in seconds, "${productionLabel}" builds the DMG and ZIP to publish in build/release (notarization takes a few minutes).`)
	console.log(`On the first build, macOS asks for your login password so codesign can use the key: enter it and click "Always Allow".`)
	if(created) console.log("Back up the certificate: Keychain Access > login > My Certificates > right-click it > Export. Pass the .p12 file to this script on other Macs (Apple allows only a few Developer ID certificates per team).")
	if(await confirm("Build the debug app now?")) process.exitCode = spawnSync("node", debugArgs, {stdio:"inherit"}).status
})().catch(error => { console.error(error.message); process.exit(1) })
