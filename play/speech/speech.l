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
	// say bookkeeping: sayCounter invalidates the watchdog retry of an older say and the resolve
	// of a superseded say (a newer say or stop bumps it), currentUtterance keeps the utterance
	// alive against GC (see say)
	int sayCounter
	dynamic currentUtterance
	// Headless tests: the simulated utterance that is "speaking", as {text, resolve} - the test ends
	// it with speech.headlessSay.resolve(). A newer say overwrites it and stop clears it, dropping the
	// old resolve, so a superseded awaiter never resumes - the same rule the browser path enforces
	// with the sayCounter check in finish
	dynamic headlessSay
	
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
		
	// The promise resolves when the utterance ended - but only if this say is still the latest one:
	// a say that was superseded by a newer say or stop never resumes its awaiter (see finish),
	// so the code after "await speech.say" (training.nextStep, reader.updateProgress) cannot run stale
	js async Promise say: string value, string language, float rate = speech.rate, string title = "", string artist = "", float position = 0, float duration = 0
		if(system.isHeadless) {
			// Simulated utterance for headless tests: it stays "speaking" until the test ends it with
			// speech.headlessSay.resolve(). Overwriting the previous entry drops its resolve, so a
			// superseded awaiter never resumes (see headlessSay)
			speech.lastWord = value;
			console.log(`speech #${++speech.sayCounter} say headless "${value.length > 60 ? value.substring(0, 60) + "…" : value}"`);
			return new Promise(resolve => speech.headlessSay = {text: value, resolve: resolve});
		}
		// Editor replays and tests (isPremiere false) and uncertain (predicted) frames don't
		// speak - the certain replay of an uncertain frame calls say again. Logged so a skipped
		// say is visible in the console.
		if(!core.isPremiere || !input.isCertain) {
			console.log(`speech: say skipped (isPremiere:${core.isPremiere} isCertain:${input.isCertain}, frame ${core.frame}): "${value.substring(0, 40)}"`);
			return;
		}
		speech.lastWord = value;
		const id = ++speech.sayCounter;
		if(window.webkit) {
			console.log(`speech #${id} say via webkit "${value.substring(0, 60)}", language: ${language}, certain: ${input.isCertain}, frame: ${core.frame}`);
			let pref = speech.preferences.get(language) || speech.preferences.get("English")
			window.webkit.messageHandlers.speak.postMessage({text: value, language: pref.lang, preferredVoices: pref.names, title: title, artist: artist, position: position, duration: duration});
		} else {
			return new Promise((resolve, reject) => {
				const synth = window.speechSynthesis;
				const utterance = new SpeechSynthesisUtterance(value);
				let voice = speech.getVoice(language);
				utterance.lang = voice.langAndCountry;
				utterance.voice = speech.currentVoice = speech.voiceOverride || voice.voice;
				utterance.rate = Math.max(rate, voice.minSpeed);
				// Keep a reference: Chrome garbage-collects the utterance mid-speech otherwise,
				// which cuts the audio and swallows the onend/onerror events
				speech.currentUtterance = utterance;
				// Chrome's utterance events are unreliable: onstart/onend can be lost or arrive seconds
				// late while the audio itself plays fine (observed: a sentence audibly speaking with
				// speaking:true but no onstart - the old watchdog cancelled it mid-audio). So events are
				// only a fast path here; the poller below reads synth.speaking as the ground truth.
				let sawStart = false;      // onstart arrived
				let heardSpeaking = false; // synth.speaking observed after our speak - audio is running (or, rarely, Chrome is wedged)
				let done = false, ignoreNextError = false, retried = false, respoke = false;
				let silentMs = 0, wedgedMs = 0, notSpeakingPolls = 0, poll = 0;
				// A wedged engine keeps speaking:true without ever producing audio or events. Give a real
				// utterance generous time (voice loading, slow rate) before declaring it wedged.
				const wedgeLimitMs = 10000 + value.length * 150 / utterance.rate;
				const state = () => `speaking:${synth.speaking} pending:${synth.pending} paused:${synth.paused}`;
				const finish = (reason) => {
					if(done) return;
					done = true;
					clearInterval(poll);
					if(speech.currentUtterance === utterance) speech.currentUtterance = null;
					// Resume the awaiter only if no newer say or stop superseded this one: the code after
					// "await speech.say" (training.nextStep, reader.updateProgress) must not run for a
					// sentence that was cancelled by a newer one - the resolve via the cancel's onerror
					// used to fire a stale training.nextStep (double advance in the bubbles)
					if(speech.sayCounter === id) { console.log(`speech #${id} ${reason}`); resolve(); }
					else console.log(`speech #${id} ${reason} - superseded, awaiter not resumed`);
				};
				utterance.onstart = () => { sawStart = true; console.log(`speech #${id} started, voice: ${utterance.voice ? utterance.voice.name : "default"}, rate: ${utterance.rate}`); };
				utterance.onend = () => finish("ended");
				utterance.onerror = e => {
					// The retry cancel's error can arrive seconds late (Chrome delays utterance events),
					// so the guard keys on the error type, not on the current state. A real interruption
					// swallowed here is caught by the poller: not speaking → "ended without onend"
					if(ignoreNextError && (e.error === "canceled" || e.error === "interrupted")) { ignoreNextError = false; console.log(`speech #${id} ${e.error} from own retry cancel ignored`); return; }
					finish(`error: ${e.error}, started: ${sawStart || heardSpeaking}, ${state()}`);
				};
				const speak = () => {
					if(done || speech.sayCounter !== id) return;
					synth.speak(utterance);
					// Chrome sometimes leaves the queue stuck in paused state after cancel() - resume is a no-op otherwise
					synth.resume();
				};
				console.log(`speech #${id} say "${value.length > 60 ? value.substring(0, 60) + "…" : value}", lang: ${utterance.lang}, certain: ${input.isCertain}, frame: ${core.frame}, ${state()}`);
				if(synth.speaking || synth.pending) {
					// Only cancel a busy queue, and give Chrome a beat before the speak: cancel() with
					// speak() in the same task is the race that drops utterances or loses their events
					synth.cancel();
					setTimeout(speak, 100);
				} else speak();
				poll = setInterval(() => {
					if(done || speech.sayCounter !== id) { clearInterval(poll); return; }
					// Un-sticks Chrome's paused-after-cancel queue and its silent auto-pause on long
					// utterances; a no-op while speech runs normally
					synth.resume();
					if(sawStart || heardSpeaking) {
						if(synth.speaking) notSpeakingPolls = 0;
						else if(++notSpeakingPolls >= 2) { finish(`ended without onend (${state()})`); return; }
						// Never cancel running audio - only a heard-but-eventless utterance that exceeds
						// any plausible duration is a wedged engine, not a slow sentence
						if(!sawStart && (wedgedMs += 250) >= wedgeLimitMs) { synth.cancel(); finish(`gave up: speaking without events for ${Math.round(wedgeLimitMs)}ms - engine wedged (${state()})`); }
					} else if(synth.speaking) {
						heardSpeaking = true;
						console.log(`speech #${id} speaking without onstart, voice: ${utterance.voice ? utterance.voice.name : "default"} (${state()})`);
					} else {
						silentMs += 250;
						if(silentMs >= 2500) finish(`gave up: never started (${state()})`);
						else if(retried && !respoke) { respoke = true; speak(); }
						else if(silentMs >= 1000 && !retried) {
							// Dropped utterance: not speaking, no events. Clear the queue now, respeak on
							// the next poll tick - again never cancel and speak in the same task
							retried = true;
							ignoreNextError = true;
							console.warn(`speech #${id} did not start within ${silentMs}ms, retrying (${state()})`);
							synth.cancel();
						}
					}
				}, 250);
			});
		}

	js inline void stop
		speech.sayCounter++; // Invalidates the watchdog retry of a say that has not started yet and supersedes the awaiter of any pending say
		console.log("speech: stop");
		if(system.isHeadless) {
			speech.headlessSay = null; // Drops the pending resolve: the stopped say's awaiter never resumes
		} else if(window.webkit) {
			window.webkit.messageHandlers.speak.postMessage({action: "pause"});
		} else {
			window.speechSynthesis?.cancel()
		}
		
	js inline bool isSpeaking
		!!window.speechSynthesis?.speaking

