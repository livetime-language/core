internal interface SpeechSynthesisVoice
	bool default // Indicates whether the voice is the default voice for the current app language
	string lang // Returns a BCP 47 language tag indicating the language of the voice.
	bool localService // Indicates if its local speech synthesizer service (true) or a remote service (false)
	string name // Returns a human-readable name that represents the voice.
	string voiceURI // Returns the type of URI and location of the speech synthesis service for this voice.
	
VoiceNameAndSpeed
	string name
	float minSpeed

internal VoicePreference
	string lang
	string langAndCountry
	VoiceNameAndSpeed[] voices
	SpeechSynthesisVoice voice
	float minSpeed
	
transient speech
	int voiceIndex
	SpeechSynthesisVoice[] voices
	SpeechSynthesisVoice voiceOverride, currentVoice
	float rate = 1
	string lastWord = ""
	
	VoicePreference[string] preferences = {
		Spanish: {"es", "es-ES", [
			{"Microsoft Sofia", minSpeed:0.75}
			{"Microsoft Catalina", minSpeed:0.75}
			{"Microsoft Ximena", minSpeed:0.75}
			{"Google", minSpeed:0.9}
			{"Google español de Estados Unidos", minSpeed:1.0}
			{"Paulina", minSpeed:0.75}
			{"Mónica", minSpeed:0.75}
		]}
		German:  {"de", "de-DE", [
			{"Microsoft", minSpeed:0.75}
			{"Google", minSpeed:0.75}
			{"Helena", minSpeed:0.75}
			{"Anna", minSpeed:0.75}
		]}
		English: {"en", "en-US", [
			{"Zoe (Enhanced)", minSpeed:0.75}
			{"Microsoft", minSpeed:0.75}
			{"Google", minSpeed:0.75}
		]}
	}
	string[string] voiceForLanguage
	// The speed the user picked in the settings, 0 to use the tuned minSpeed of the voice
	float userSpeedPreference = 0
	
	// The voice and the speed the user picked in the settings. An empty voiceName keeps the current voice (the user only changed the speed).
	// The cached voice is dropped, so the next getVoice picks up both.
	setVoiceAndSpeed: string language, string voiceName, float speed
		if voiceName then voiceForLanguage[language] = voiceName
		userSpeedPreference = speed
		let pref = preferences[language] or preferences["English"]
			pref.voice = null
	
	inline js SpeechSynthesisVoice[] getVoices() (window.speechSynthesis?.getVoices() || [])
		
	nextVoice
		voiceOverride = voices[voiceIndex incrementAndWrap voices.length]
		
	js void setup: string language = "Spanish", float rate = 1
		if(system.isHeadless) return
		var utterance = new SpeechSynthesisUtterance("");
		// speechSynthesis.addEventListener("voiceschanged", () => speech.setupVoice(language, voicePreferences));
		let voice = speech.getVoice();
		utterance.lang = voice.langAndCountry;
		utterance.voice = speech.currentVoice = voice.voice;
		utterance.rate = speech.rate = rate;
		speechSynthesis.speak(utterance);
		document.onclick = e => {
			const utterance = new SpeechSynthesisUtterance("");
			speechSynthesis.speak(utterance);
			document.onclick = null;
		}
		
	VoicePreference getVoice: string language
		let pref = preferences[language] or preferences["English"]
		if pref.voice == null
			let allVoices = getVoices
			voices = allVoices.filter.lang.startsWith(pref.lang)
			// for voices: print "{.lang} {.name}"
			
			// User preference
			let userPref = voiceForLanguage[language]
				let voice = allVoices.find.name.includes(userPref)
					pref.voice = voice
					pref.minSpeed = userSpeedPreference
					return pref
					
			// System preferences
			for pref.voices as voicePreference
				let voice = voices.find.name.includes(voicePreference.name)
					pref.voice = voice
					pref.minSpeed = userSpeedPreference > 0 ? userSpeedPreference : voicePreference.minSpeed
					return pref
		return pref
		
	js async Promise say: string value, string language, float rate = speech.rate, string title = "", string artist = "", float position = 0, float duration = 0
		if(system.isHeadless) return
		if(core.isPremiere && input.isCertain) {
			if(window.webkit) {
				let pref = speech.preferences.get(language) || speech.preferences.get("English")
				window.webkit.messageHandlers.speak.postMessage({text: value, language: pref.lang, preferredVoices: pref.names, title: title, artist: artist, position: position, duration: duration});
			} else {
				return new Promise((resolve, reject) => {
					speech.lastWord = value;
					speechSynthesis.cancel();
					const utterance = new SpeechSynthesisUtterance(value);
					let voice = speech.getVoice(language);
					utterance.lang = voice.langAndCountry;
					utterance.voice = speech.currentVoice = speech.voiceOverride || voice.voice;
					utterance.rate = Math.max(rate, voice.minSpeed);
					console.log("rate", utterance.rate);
					utterance.onend = () => resolve()
					speechSynthesis.speak(utterance);
				});
			}
		}
		
	js inline void stop
		if(window.webkit) {
			window.webkit.messageHandlers.speak.postMessage({action: "pause"});
		} else {
			window.speechSynthesis?.cancel()
		}
		
	js inline bool isSpeaking
		!!window.speechSynthesis?.speaking

