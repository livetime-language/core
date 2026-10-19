# Install electron
npm install electron --save-dev
npm install @electron/remote

# dist/boot.js, dist/package.json
outputPath=$(sed -n '/^[[:space:]]*OutputPath:/{s/^[^:]*:[[:space:]]*//;s/[[:space:]]*$//;p;q;}' .livetime/targets.lc)
cp "$(dirname "$0")/boot.js" "$(dirname "$0")/package.json" "$outputPath/"

# VSCode task
if ! grep -qs "Start Electron Dev Server" .vscode/tasks.json; then
	mkdir -p .vscode
	[ -f .vscode/tasks.json ] || printf '{\n\t"version": "2.0.0",\n\t"tasks": [\n\t]\n}\n' > .vscode/tasks.json
	task=$(cat <<EOF
		{
			"label": "▶ Start Electron Dev Server",
			"detail": "This task will keep running and never finishes",
			"type": "shell",
			"command": "node_modules/.bin/electron $outputPath debug",
			"runOptions": {
				"runOn": "folderOpen",
				"instanceLimit": 1,
				"instancePolicy": "terminateOldest"
			}
		},
EOF
)
	task="$task" awk '{print} !done && /"tasks"[[:space:]]*:/ {print ENVIRON["task"]; done=1}' .vscode/tasks.json > .vscode/tasks.json.tmp && mv .vscode/tasks.json.tmp .vscode/tasks.json
fi
