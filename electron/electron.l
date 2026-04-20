unit Platform
	js void openDevTools
		require('@electron/remote').getCurrentWindow().toggleDevTools()

	inline js void onResume: void() do
		window.onfocus = do

