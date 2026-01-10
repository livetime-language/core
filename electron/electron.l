unit Platform
	js void openDevTools
		require('@electron/remote').getCurrentWindow().toggleDevTools()

