const app = require('electron').app;
const remoteMain = require('@electron/remote/main')
remoteMain.initialize()

const isDebug = process.argv.includes("debug");
const shouldOpenDevTools = process.argv.includes("devTools");

// Node.js packages that run in the renderer (e.g. the Claude Agent SDK) need SharedArrayBuffer, which browsers only offer to cross-origin isolated pages
app.commandLine.appendSwitch('enable-features', 'SharedArrayBuffer');
if(isDebug) app.commandLine.appendSwitch('remote-debugging-port', '5198');
const BrowserWindow = require('electron').BrowserWindow;
var mainWindow = null;

// Quit when all windows are closed.
app.on('window-all-closed', function() {
	app.quit();
});

app.on('ready', function() {
	mainWindow = new BrowserWindow({
		width:	780,
		height:	585,
		icon:	'icon-v1.png', 
		acceptFirstMouse:	true,
		show:	true,
		titleBarStyle:	isDebug ? "default" : "hiddenInset",
		webPreferences: { 
			nodeIntegration:	true,
			nodeIntegrationInWorker:	true,
			nodeIntegrationInSubFrames:	true,
			sandbox:	false,
			webSecurity:	false,
			webviewTag:	true,
			enableRemoteModule:	true,
			contextIsolation:	false,
			zoomFactor:	1,
		},
	});
	
	remoteMain.enable(mainWindow.webContents);
	mainWindow.setMenu(null);

	// Electron has no Bluetooth device chooser: navigator.bluetooth.requestDevice gets the first matching device
	mainWindow.webContents.on('select-bluetooth-device', (event, devices, callback) => {
		event.preventDefault();
		if(devices.length) callback(devices[0].deviceId);
	});

	if(isDebug)	{mainWindow.loadURL('http://localhost:8080');}
	else	{mainWindow.loadURL('file://' + __dirname + '/index.html');  mainWindow.setFullScreen(false); }

	if(shouldOpenDevTools) mainWindow.openDevTools();

	mainWindow.on('closed', function() {
		mainWindow = null;
	});
});

app.on('browser-window-created', (_, window) => {
	require("@electron/remote/main").enable(window.webContents)
})
