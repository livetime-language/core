internal interface SpeechSynthesisVoice
	bool default // Indicates whether the voice is the default voice for the current app language
	string lang // Returns a BCP 47 language tag indicating the language of the voice.
	bool localService // Indicates if its local speech synthesizer service (true) or a remote service (false)
	string name // Returns a human-readable name that represents the voice.
	string voiceURI // Returns the type of URI and location of the speech synthesis service for this voice.
	
internal VoicePreference
	string lang
	string langAndCountry
	string[] names
	SpeechSynthesisVoice voice
	
transient speech
	int voiceIndex
	SpeechSynthesisVoice[] voices
	SpeechSynthesisVoice voiceOverride, currentVoice
	float rate = 1
	string lastWord = ""
	
	VoicePreference[string] preferences = {
		Spanish: {"es", "es-ES", ["Microsoft Sofia", "Microsoft Catalina", "Microsoft Ximena", "Google", "Paulina", "Mónica"]}
		German:  {"de", "de-DE", ["Microsoft", "Google", "Helena", "Anna"]}
		English: {"en", "en-US", ["Microsoft", "Google"]}
	}
	
	inline js SpeechSynthesisVoice[] getVoices() speechSynthesis.getVoices()
		
	nextVoice
		voiceOverride = voices[voiceIndex incrementAndWrap voices.length]
		
	js void setup: string language = "Spanish", float rate = 1
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
			// for allVoices
			// 	print "{.lang} {.name}"
			voices = allVoices.where.lang.startsWith(pref.lang)
			for pref.names as name
				let voice = voices.find.name.contains(name)
					pref.voice = voice
					// print "--> {voice.name}"
					break
		return pref
		
	js void say: string value, string language, float rate = speech.rate, string title = "", string artist = "", float position = 0, float duration = 0
		if(core.isPremiere && input.isCertain) {
			if(window.webkit) {
				let pref = speech.preferences.get(language) || speech.preferences.get("English")
				window.webkit.messageHandlers.speak.postMessage({text: value, language: pref.lang, preferredVoices: pref.names, title: title, artist: artist, position: position, duration: duration});
			} else {
				speech.lastWord = value;
				speechSynthesis.cancel();
				const utterance = new SpeechSynthesisUtterance(value);
				let voice = speech.getVoice(language);
				utterance.lang = voice.langAndCountry;
				utterance.voice = speech.currentVoice = speech.voiceOverride || voice.voice;
				utterance.rate = rate || 1;
				utterance.onend = () => reader.onSpeakingFinished(value, language)
				speechSynthesis.speak(utterance);
			}
		}
		
	js inline void stop
		if(window.webkit) {
			window.webkit.messageHandlers.speak.postMessage({action: "pause"});
		} else {
			speechSynthesis.cancel()
		}
		
	js inline bool isSpeaking
		speechSynthesis.speaking

