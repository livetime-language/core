class AudioTrack
	string name
	SoundEditorMode editorMode = Pitch
	bool noiz, buzz
	int detune, reverb, dampen	// filter levels 0 (off), 1 or 2
	int noteDuration	// in ticks of 183/22050 seconds (~1/120 second)
	int loopStartIndex	// as a note index (0-63)
	int loopEndIndex	// as a note index (0-63)
	ImmutableList<AudioNote> notes	// the notes played in sequence
	transient int trackId = -1	// id in the synthesizer, assigned on first playback

	// Parse notes from strings like "c#0.a51": pitch as note and octave, waveform as hex digit, volume, effect ("." if none)
	AudioTrack: string[] notesAsStrings = null
		if not notesAsStrings then return
		string noteNames = "c-c#d-d#e-f-f#g-g#a-a#b-"
		string digits = "0123456789abcdef"
		NoteWaveform[] waveforms = [Sine, Triangle, Sawtooth, LongSquare, ShortSquare, Ringing, Noise, RingingSine, Custom1, Custom2, Custom3, Custom4, Custom5, Custom6, Custom7, Custom8]
		NoteEffect[] effects = [None, Slide, Vibrato, Drop, FadeIn, FadeOut, ArpeggioFast, ArpeggioSlow]
		AudioNote[] list = []
		for notesAsStrings as str
			if str[0] == " " or str[0] == "."
				list.add AudioNote()
				continue
			int semitone = floor(noteNames.indexOf(str[0 to 2]) / 2)
			int octave = str.getCharCodeAt(2) - 48
			int waveformIndex = digits.indexOf(str[4])
			int volume = str.getCharCodeAt(5) - 48
			int effectIndex = str[6] == "." ? 0 : str.getCharCodeAt(6) - 48
			list.add AudioNote(pitch:octave*12 + semitone, waveform:waveforms[waveformIndex], volume:volume, effect:effects[effectIndex])
		notes = list

enum SoundEditorMode
	Pitch	= 0
	Tracker	= 1

enum NoteWaveform
	Sine	= 0
	Triangle	= 1
	Sawtooth	= 2
	LongSquare	= 3
	ShortSquare	= 4
	Ringing	= 5
	Noise	= 6
	RingingSine	= 7
	Custom1	= 8
	Custom2	= 9
	Custom3	= 10
	Custom4	= 11
	Custom5	= 12
	Custom6	= 13
	Custom7	= 14
	Custom8	= 15

enum NoteEffect
	None	= 0
	Slide	= 1
	Vibrato	= 2
	Drop	= 3
	FadeIn	= 4
	FadeOut	= 5
	ArpeggioFast	= 6	// loop over groups of four notes with noteDuration 2
	ArpeggioSlow	= 7	// loop over groups of four notes with noteDuration 4

class AudioNote
	int pitch	// 0 - 63, c-0 to d#5, chromatic scale
	NoteWaveform waveform = Sine	// 0 - 15
	int volume	// 0 -  7
	NoteEffect effect = None	// 0 -  7

class MusicPattern
	AudioTrack[] tracks
	bool startLoop, endLoop
	bool stopAtEndOfPattern

class Music
	MusicPattern[] patterns
	string name

// Plays audio tracks and music through a Pico-8 compatible synthesizer running in an AudioWorklet.
// The synthesis is a JavaScript port of zepto8 (github.com/samhocevar/zepto8, WTFPL), the most
// accurate open source reimplementation of the Pico-8 sound chip.
transient global skipInit audio
	// Play an audio track (like Pico-8 sfx()). channel -1 picks a free channel automatically.
	js void playSound: AudioTrack audioTrack, int channel = -1, int startIndex = 0, int length = 0
		audio.setup();
		audio.sendMessage({type: "sound", id: audio.defineTrack(audioTrack), channel: channel, offset: startIndex, length: length});

	// Stop a playing audio track, or all of them (like Pico-8 sfx(-1))
	js void stopSound: AudioTrack audioTrack = null, int channel = -1
		audio.setup();
		audio.sendMessage({type: "stopSound", id: audioTrack ? audioTrack.trackId : -1, channel: channel});

	// Let a looping audio track run to its end (like Pico-8 sfx(-2))
	js void releaseLoop: int channel = -1
		audio.setup();
		audio.sendMessage({type: "releaseLoop", channel: channel});

	// Play music, optionally fading in over fadeDuration milliseconds (like Pico-8 music()).
	// reservedChannels is a bitmask of channels only music may use (like the Pico-8 channel mask).
	js void playMusic: Music music, float fadeDuration = 0, int startPattern = 0, int reservedChannels = 0
		audio.setup();
		const patterns = [];
		for(let i = 0; i < music.patterns.length; i++) {
			const p = music.patterns[i];
			const trackIds = [];
			for(let c = 0; c < 4; c++) trackIds.push(p.tracks && c < p.tracks.length && p.tracks[c] ? audio.defineTrack(p.tracks[c]) : -1);
			patterns.push({tracks: trackIds, begin: !!p.startLoop, end: !!p.endLoop, stop: !!p.stopAtEndOfPattern});
		}
		audio.sendMessage({type: "music", patterns: patterns, start: startPattern, fade: fadeDuration, mask: reservedChannels});

	// Stop the music, optionally fading out over fadeDuration milliseconds (like Pico-8 music(-1))
	js void stopMusic: float fadeDuration = 0
		audio.setup();
		audio.sendMessage({type: "stopMusic", fade: fadeDuration});

	// Set the master volume (0 to 1)
	js void setVolume: float volume
		audio.setup();
		audio.sendMessage({type: "volume", value: volume});

	// Set the tracks that notes with waveform Custom1 - Custom8 play as instruments
	js void setInstruments: AudioTrack[] audioTracks
		audio.setup();
		const ids = [];
		for(let i = 0; i < 8; i++) ids.push(i < audioTracks.length && audioTracks[i] ? audio.defineTrack(audioTracks[i]) : -1);
		audio.sendMessage({type: "instruments", ids: ids});

	// Send a track's data to the synthesizer once and return its id
	internal js int defineTrack: AudioTrack audioTrack
		if(audioTrack.trackId >= 0) return audioTrack.trackId;
		audioTrack.trackId = audio.trackCount++;
		const notes = audioTrack.notes || [];
		const pitch = [], wave = [], vol = [], fx = [], custom = [];
		for(let i = 0; i < notes.length; i++) {
			pitch.push(notes[i].pitch | 0);
			wave.push(notes[i].waveform & 7);
			custom.push(notes[i].waveform >= 8 ? 1 : 0);
			vol.push(notes[i].volume | 0);
			fx.push(notes[i].effect | 0);
		}
		audio.sendMessage({type: "track", id: audioTrack.trackId,
			speed: audioTrack.noteDuration | 0, noiz: !!audioTrack.noiz, buzz: !!audioTrack.buzz,
			detune: +audioTrack.detune || 0, reverb: +audioTrack.reverb || 0, dampen: +audioTrack.dampen || 0,
			loopStart: audioTrack.loopStartIndex | 0, loopEnd: audioTrack.loopEndIndex | 0,
			pitch: pitch, wave: wave, vol: vol, fx: fx, custom: custom});
		return audioTrack.trackId;

	// Send a message to the synthesizer, queueing it while the AudioWorklet is still loading
	internal js void sendMessage: dynamic message
		if(audio.node) audio.node.port.postMessage(message);
		else if(audio.pendingMessages) audio.pendingMessages.push(message);

	// Create the AudioContext and synthesizer worklet, and unlock playback on the first user gesture
	internal js void setup
		if(audio.context) return;
		audio.pendingMessages = [];
		audio.trackCount = 0;
		const AC = window.AudioContext || window.webkitAudioContext;
		try { audio.context = new AC({sampleRate: 22050}); } catch(e) { audio.context = new AC(); }
		const code = audio.synthesizer.toString();
		const body = code.slice(code.indexOf("{") + 1, code.lastIndexOf("}"));
		const url = URL.createObjectURL(new Blob([body], {type: "application/javascript"}));
		audio.context.audioWorklet.addModule(url).then(() => {
			URL.revokeObjectURL(url);
			audio.node = new AudioWorkletNode(audio.context, "pico8", {outputChannelCount: [1]});
			audio.node.connect(audio.context.destination);
			const messages = audio.pendingMessages;
			audio.pendingMessages = null;
			for(const m of messages) audio.node.port.postMessage(m);
		}).catch(e => console.error("audio setup failed", e));
		audio.unlock = () => {
			audio.context.resume().then(() => {
				if(audio.context.state == "running") {
					window.removeEventListener("pointerdown", audio.unlock);
					window.removeEventListener("keydown", audio.unlock);
					window.removeEventListener("touchend", audio.unlock);
				}
			});
		};
		window.addEventListener("pointerdown", audio.unlock);
		window.addEventListener("keydown", audio.unlock);
		window.addEventListener("touchend", audio.unlock);

	// The synthesizer that runs inside the AudioWorklet. This function is never called directly:
	// its body is extracted with toString() and loaded as the worklet module (see setup).
	// It is a direct port of zepto8's sfx.cpp / synth.cpp / filter.cpp.
	internal js void synthesizer
		const SR = sampleRate;                       // context sample rate; all constants derive from it
		const INV = 1 / SR;                          // seconds per output sample
		const DELAY1 = Math.round(366 * SR / 22050); // reverb 1: 2 ticks
		const DELAY2 = Math.round(732 * SR / 22050); // reverb 2: 4 ticks
		function keyToFreq(key) { return 440 * Math.pow(2, (key - 33) / 12); }
		function mix(a, b, t) { return a + (b - a) * t; }
		function clamp(x, lo, hi) { return x < lo ? lo : x > hi ? hi : x; }
		// RBJ audio-eq-cookbook highshelf biquad (zepto8 filter.cpp), state = {c1..c5, x1, x2, y1, y2}
		function makeHighshelf(freq, q, gain) {
			const w0 = 2 * Math.PI * freq / SR;
			const cosw0 = Math.cos(w0), a = Math.pow(10, gain / 40);
			const alpha = (Math.sin(w0) / 2) * Math.sqrt((a + 1 / a) * (1 / q - 1) + 2);
			const sqra = 2 * Math.sqrt(a) * alpha;
			const a0 = (a + 1) - (a - 1) * cosw0 + sqra;
			return {
				c1: a * ((a + 1) + (a - 1) * cosw0 + sqra) / a0,
				c2: -2 * a * ((a - 1) + (a + 1) * cosw0) / a0,
				c3: a * ((a + 1) + (a - 1) * cosw0 - sqra) / a0,
				c4: 2 * ((a - 1) - (a + 1) * cosw0) / a0,
				c5: ((a + 1) - (a - 1) * cosw0 - sqra) / a0,
				x1: 0, x2: 0, y1: 0, y2: 0 };
		}
		function runFilter(f, x) {
			const y = f.c1 * x + f.c2 * f.x1 + f.c3 * f.x2 - f.c4 * f.y1 - f.c5 * f.y2;
			f.x2 = f.x1; f.x1 = x;
			f.y2 = f.y1; f.y1 = y;
			return y;
		}
		function makeSynth() {
			return {instrument: 0, custom: 0, key: 0, freq: 0, volume: 0, phi: 0,
				lastAdvance: 0, lastSample: 0, isMusic: false,
				noiz: false, buzz: false, detune: 0, reverb: 0, dampen: 0};
		}
		function copySynth(dst, src) {
			dst.instrument = src.instrument; dst.custom = src.custom;
			dst.key = src.key; dst.freq = src.freq; dst.volume = src.volume; dst.phi = src.phi;
			dst.lastAdvance = src.lastAdvance; dst.lastSample = src.lastSample; dst.isMusic = src.isMusic;
			dst.noiz = src.noiz; dst.buzz = src.buzz;
			dst.detune = src.detune; dst.reverb = src.reverb; dst.dampen = src.dampen;
		}
		function makeSfxState() { return {sfx: -1, offset: 0, time: 0, prevKey: 24, prevVol: 0}; }
		// The 8 waveforms (zepto8 synth.cpp); formulas and amplitudes measured from PICO-8 WAV exports
		function waveform(inst, phi, key, noiz, buzz, state) {
			const t = phi % 1;
			let ret = 0;
			switch(inst) {
				case 0: // triangle
					ret = 1 - Math.abs(4 * t - 2);
					if(buzz) { // averaged with a tilted saw
						const bret = t < 0.875 ? 2 * t / 0.875 - 1 : 2 * (1 - t) / 0.125 - 1;
						ret = ret * 0.75 + bret * 0.25;
					}
					return ret * 0.5;
				case 1: { // tilted saw
					const a = buzz ? 0.975 : 0.875;
					ret = t < a ? 2 * t / a - 1 : 2 * (1 - t) / (1 - a) - 1;
					return ret * 0.5;
				}
				case 2: // saw
					ret = t < 0.5 ? t : t - 1;
					if(buzz) ret = ret * 0.83 - (Math.abs(phi % 2 - 1) < 0.5 ? 0.085 : 0); // adds a square sub-oscillator at half frequency
					return 0.653 * ret;
				case 3: // square
					return t < (buzz ? 0.4 : 0.5) ? 0.25 : -0.25;
				case 4: // pulse
					return t < (buzz ? 0.255 : 0.316) ? 0.25 : -0.25;
				case 5: // organ
					ret = t < 0.5 ? 3 - Math.abs(24 * t - 6) : 1 - Math.abs(16 * t - 12);
					if(buzz) { // add a cut on the first of the two triangles
						ret = t < 0.5 ? ret * 2 + 3 : ret;
						ret = (t < 0.5 && ret > -1.875) ? ret * 0.2 - 1 : ret + 0.5;
					}
					return ret / 9;
				case 6: { // noise: a pitch-tracking smoothed random walk
					const scale = (phi - state.lastAdvance) * 8.858923; // 8.858923 = 22050 / freq(63)
					const sample = (state.lastSample + scale * (Math.random() * 2 - 1)) / (1 + scale);
					const factor = 1 - key / 63;
					ret = sample * 1.5 * (1 + factor * factor);
					if(noiz) ret *= 2 * (t < 0.5 ? t : t - 1); // "pure white noise" switch
					state.lastAdvance = phi;
					state.lastSample = sample;
					return ret;
				}
				case 7: { // phaser: two triangle waves with slightly different frequencies
					ret = 2 - Math.abs(8 * t - 4);
					ret += 1 - Math.abs(4 * ((phi * 109 / 110) % 1) - 2);
					if(buzz) { // add even partials
						ret += 0.25 - Math.abs(((phi * 2 + 0.5) % 1) - 0.5);
						ret += 0.125 - Math.abs(0.5 * ((phi * 4) % 1) - 0.25);
					}
					return ret / 6;
				}
			}
			return 0;
		}
		class Pico8Processor extends AudioWorkletProcessor {
			constructor() {
				super();
				this.tracks = [];
				this.instruments = [-1, -1, -1, -1, -1, -1, -1, -1];
				this.masterVolume = 1;
				this.volumeSfx = 0.5;   // headroom, like zepto8
				this.volumeMusic = 0.5;
				this.music = {patterns: null, pattern: -1, offset: 0, length: 0, fadeVolume: 1, fadeStep: 0, mask: 0};
				this.channels = [];
				for(let i = 0; i < 4; i++) this.channels.push({
					main: makeSfxState(), custom: makeSfxState(),
					sfxMusic: -1, length: 0, canLoop: true, isMusic: false,
					lastMainInstrument: 255, lastMainKey: 255,
					newSynth: makeSynth(), lastSynth: makeSynth(), fadeSynth: makeSynth(), fade: 0,
					reverb2: new Float32Array(DELAY1), reverb4: new Float32Array(DELAY2), reverbIndex: 0,
					damp1: makeHighshelf(2400, 1, -6), damp2: makeHighshelf(1000, 1, -12)});
				this.port.onmessage = (e) => this.onMessage(e.data);
			}
			onMessage(m) {
				if(m.type == "track") {
					const rows = Math.max(32, Math.ceil(m.pitch.length / 4) * 4);
					const pitch = new Float64Array(rows), wave = new Int32Array(rows), vol = new Float64Array(rows);
					const fx = new Int32Array(rows), custom = new Int32Array(rows);
					let lastNote = 0;
					for(let i = 0; i < m.pitch.length; i++) {
						pitch[i] = m.pitch[i]; wave[i] = m.wave[i]; vol[i] = m.vol[i]; fx[i] = m.fx[i]; custom[i] = m.custom[i];
						if(m.vol[i] > 0) lastNote = Math.min(rows, i + 1);
					}
					this.tracks[m.id] = {speed: Math.max(1, m.speed), noiz: m.noiz, buzz: m.buzz,
						detune: m.detune, reverb: m.reverb, dampen: m.dampen,
						loopStart: m.loopStart, loopEnd: m.loopEnd, rows: rows, lastNote: lastNote,
						pitch: pitch, wave: wave, vol: vol, fx: fx, custom: custom};
				}
				else if(m.type == "instruments") this.instruments = m.ids;
				else if(m.type == "sound") this.startSound(m.id, m.channel, m.offset, m.length);
				else if(m.type == "stopSound") {
					for(let i = 0; i < 4; i++) {
						if(m.id >= 0 ? this.channels[i].main.sfx == m.id
							: (m.channel < 0 || m.channel == i) && !this.channels[i].isMusic)
							this.channels[i].main.sfx = -1;
					}
				}
				else if(m.type == "releaseLoop") {
					for(let i = 0; i < 4; i++)
						if((m.channel < 0 || m.channel == i) && !this.channels[i].isMusic) this.channels[i].canLoop = false;
				}
				else if(m.type == "music") {
					this.music.patterns = m.patterns;
					this.music.mask = m.mask & 0xf;
					this.music.fadeVolume = 1;
					this.music.fadeStep = 0;
					if(m.fade > 0) { this.music.fadeVolume = 0; this.music.fadeStep = 1000 / m.fade; }
					this.setMusicPattern(m.start);
				}
				else if(m.type == "stopMusic") {
					if(this.music.pattern < 0) return;
					if(m.fade > 0) this.music.fadeStep = -this.music.fadeVolume * (1000 / m.fade);
					else this.setMusicPattern(-1);
				}
				else if(m.type == "volume") this.masterVolume = m.value;
			}
			// Channel allocation and preemption, like Pico-8 sfx(n, channel) (zepto8 api_sfx)
			startSound(id, chan, offset, length) {
				if(!this.tracks[id]) return;
				if(chan < 0) {
					// first idle channel, or one already playing this track
					for(let i = 0; i < 4; i++) {
						if((1 << i) & this.music.mask) continue;
						if(this.channels[i].main.sfx == -1 || this.channels[i].main.sfx == id) { chan = i; break; }
					}
					// otherwise interrupt a music channel
					if(chan < 0) {
						for(let i = 0; i < 4; i++) {
							if((1 << i) & this.music.mask) continue;
							if(this.channels[i].isMusic) { chan = i; break; }
						}
					}
					// otherwise the channel with the fastest speed (latest one on ties)
					if(chan < 0) {
						let fastest = 256;
						for(let i = 0; i < 4; i++) {
							if((1 << i) & this.music.mask) continue;
							const index = this.channels[i].main.sfx;
							if(index < 0 || !this.tracks[index]) continue;
							if(this.tracks[index].speed <= fastest) { chan = i; fastest = this.tracks[index].speed; }
						}
					}
					if(chan < 0) return;
				}
				// stop any channel already playing this track
				for(let i = 0; i < 4; i++)
					if(this.channels[i].main.sfx == id) this.channels[i].main.sfx = -1;
				// remember an interrupted music track so it can resume when this sound ends
				if(this.channels[chan].main.sfx != -1 && this.channels[chan].isMusic)
					this.channels[chan].sfxMusic = this.channels[chan].main.sfx;
				this.launchSfx(id, chan, offset, length, false);
			}
			launchSfx(id, chan, offset, length, isMusic) {
				const ch = this.channels[chan];
				ch.main.sfx = id;
				ch.main.offset = Math.max(0, offset);
				ch.main.time = 0;
				ch.length = Math.max(0, length);
				ch.canLoop = true;
				ch.isMusic = isMusic;
				ch.lastMainInstrument = 255;
				ch.lastMainKey = 255;
				ch.main.prevKey = 24; // C2, the note that makes the slide effect a no-op
				ch.main.prevVol = 0;
			}
			// Start a pattern of the current music (zepto8 set_music_pattern)
			setMusicPattern(index) {
				const music = this.music;
				for(let n = 0; n < 4; n++) {
					if(this.channels[n].isMusic) {
						this.channels[n].main.sfx = -1;
						this.channels[n].sfxMusic = -1;
					}
				}
				if(!music.patterns || index < 0 || index >= music.patterns.length) {
					music.pattern = -1; music.offset = -1; music.length = 0; music.mask = 0; music.patterns = null;
					return;
				}
				// pattern duration: the first non-looping channel, or the slowest looping channel
				const pattern = music.patterns[index];
				let durationLooping = -1, durationNoLoop = -1;
				for(let i = 0; i < 4; i++) {
					const id = pattern.tracks[i];
					if(id < 0 || !this.tracks[id]) continue;
					const t = this.tracks[id];
					if(t.loopEnd > 0 && t.loopEnd > t.loopStart)
						durationLooping = Math.max(durationLooping, t.rows * t.speed);
					else {
						let endTime = t.rows;
						if(t.loopEnd == 0 && t.loopStart > 0) endTime = Math.min(endTime, t.loopStart);
						durationNoLoop = endTime * t.speed;
						break;
					}
				}
				const duration = durationNoLoop > 0 ? durationNoLoop : durationLooping;
				if(duration <= 0) {
					music.pattern = -1; music.offset = -1; music.length = 0; music.mask = 0; music.patterns = null;
					return;
				}
				music.pattern = index;
				music.offset = 0;
				music.length = duration;
				for(let i = 0; i < 4; i++) {
					const id = pattern.tracks[i];
					if(id < 0 || !this.tracks[id]) continue;
					if(this.channels[i].main.sfx == -1) this.launchSfx(id, i, 0, 0, true);
					else this.channels[i].sfxMusic = id; // resume once the current sound ends
				}
			}
			// Advance one sfx by one sample and set up the synth parameters (zepto8 update_sfx_state)
			updateSfxState(cur, synth, freqFactor, length, isMusic, canLoop) {
				if(cur.sfx < 0) return;
				const t = this.tracks[cur.sfx];
				const speed = t.speed;
				const offset = cur.offset;
				const offsetPerSecond = 22050 / (183 * speed);
				const offsetPerFrame = offsetPerSecond * INV;
				let nextOffset = offset + offsetPerFrame;
				const nextTime = cur.time + offsetPerFrame;
				// looping is on when loop start < loop end
				const loopRange = t.loopEnd - t.loopStart;
				if(loopRange > 0 && nextOffset >= t.loopEnd && canLoop)
					nextOffset = (nextOffset - t.loopStart) % loopRange + t.loopStart;
				let hasEnd = false, endTime = t.rows;
				if(length > 0) { hasEnd = true; endTime = length; }
				// loop end 0 with loop start > 0 means the track length is the loop start
				// (like Pico-8, not applied to music tracks except for the pattern length)
				if(!isMusic && t.loopEnd == 0 && t.loopStart > 0) { hasEnd = true; endTime = Math.min(endTime, t.loopStart); }
				if(loopRange <= 0) {
					hasEnd = true;
					if(!isMusic) endTime = Math.min(endTime, t.lastNote); // skip trailing silent notes
				}
				if(offset < t.rows) {
					const noteId = Math.floor(offset);
					const key = t.pitch[noteId];
					let volume = t.vol[noteId] / 7;
					let freq = keyToFreq(key) * freqFactor;
					if(volume > 0) {
						const fx = t.fx[noteId];
						switch(fx) {
							case 1: { // slide from the previous note and volume
								const s = offset % 1;
								freq = mix(keyToFreq(cur.prevKey), freq, s);
								if(cur.prevVol > 0) volume = mix(cur.prevVol, volume, s);
								break;
							}
							case 2: { // vibrato: 7.5 Hz triangle, a quarter semitone deep
								const s = Math.abs((7.5 * offset / offsetPerSecond) % 1 - 0.5) - 0.25;
								freq = mix(freq, freq * 1.059463094359, s);
								break;
							}
							case 3: // drop: fall to zero within the note
								freq *= 1 - offset % 1;
								break;
							case 4: // fade in
								volume *= offset % 1;
								break;
							case 5: // fade out
								volume *= 1 - offset % 1;
								break;
							case 6:
							case 7: { // arpeggio over the note's group of four, at 4 or 8 ticks per step
								const m = (speed <= 8 ? 32 : 16) / (fx == 6 ? 4 : 8);
								const n = Math.floor(m * 7.5 * offset / offsetPerSecond);
								const arpNote = (noteId & ~3) | (n & 3);
								freq = keyToFreq(t.pitch[arpNote]);
								break;
							}
						}
						synth.key = key;
						synth.freq = freq;
						synth.instrument = t.wave[noteId];
						synth.custom = t.custom[noteId];
						synth.noiz = t.noiz; synth.buzz = t.buzz;
						synth.detune = t.detune; synth.reverb = t.reverb; synth.dampen = t.dampen;
						synth.volume = volume;
						synth.isMusic = isMusic;
						synth.phi += freq * INV;
					}
					if(Math.floor(nextOffset) != noteId) {
						cur.prevKey = t.pitch[noteId];
						cur.prevVol = t.vol[noteId] / 7;
					}
				}
				cur.offset = nextOffset;
				cur.time = nextTime;
				let ended = hasEnd && nextTime >= endTime;
				// a released loop (Pico-8 sfx(-2)) plays through to the end of the track
				if(loopRange > 0 && !canLoop && nextOffset >= (isMusic ? t.rows : t.lastNote)) ended = true;
				if(ended) cur.sfx = -1;
			}
			// The waveform with the detune filter and volumes applied (zepto8 get_synth_sample)
			getSynthSample(synth) {
				let value = waveform(synth.instrument, synth.phi, synth.key, synth.noiz, synth.buzz, synth);
				if(synth.detune != 0 && synth.instrument != 6) { // a second, slightly offset wave
					let factor;
					if(synth.instrument == 0) factor = synth.detune == 1 ? 3 / 4 : 3 / 2; // a fourth below or a fifth above
					else if(synth.instrument == 5) factor = synth.detune == 1 ? 200 / 199 : 800 / 199;
					else if(synth.instrument == 7) factor = synth.detune == 1 ? 49 / 50 : 400 / 199;
					else factor = synth.detune == 1 ? 200 / 199 : 400 / 199;
					const inst2 = synth.detune == 2 && synth.instrument == 5 ? 0 : synth.instrument; // organ's second wave is a triangle
					value += waveform(inst2, synth.phi * factor, synth.key, synth.noiz, synth.buzz, synth) * 0.5;
				}
				let volume = synth.volume;
				if(synth.isMusic) volume *= this.music.fadeVolume * this.volumeMusic;
				else volume *= this.volumeSfx;
				return clamp(value * volume, -1, 1);
			}
			process(inputs, outputs) {
				const out = outputs[0][0];
				const music = this.music;
				for(let i = 0; i < out.length; i++) {
					let mixed = 0;
					for(let chan = 0; chan < 4; chan++) {
						// advance the music clock with the first channel
						if(chan == 0 && music.pattern != -1) {
							music.offset += (22050 / 183) * INV;
							music.fadeVolume = clamp(music.fadeVolume + music.fadeStep * INV, 0, 1);
							if(music.fadeStep < 0 && music.fadeVolume <= 0)
								this.setMusicPattern(-1);
							else if(music.offset >= music.length) {
								const pattern = music.patterns[music.pattern];
								let next = music.pattern + 1;
								if(pattern.stop) next = -1;
								else if(pattern.end)
									while(--next > 0 && !music.patterns[next].begin) {}
								this.setMusicPattern(next);
							}
						}
						const ch = this.channels[chan];
						// resume an interrupted music track, at the music clock's current position
						if(ch.main.sfx == -1 && ch.sfxMusic != -1) {
							const t = this.tracks[ch.sfxMusic];
							let wantPlay = true;
							let newOffset = music.offset / t.speed;
							const loopRange = t.loopEnd - t.loopStart;
							if(loopRange > 0 && ch.canLoop) {
								if(newOffset > t.loopStart) newOffset = (newOffset - t.loopStart) % loopRange + t.loopStart;
							}
							else if(newOffset > t.rows) wantPlay = false;
							if(wantPlay) this.launchSfx(ch.sfxMusic, chan, newOffset, 0, true);
							ch.sfxMusic = -1;
						}
						const newSynth = ch.newSynth, lastSynth = ch.lastSynth;
						copySynth(newSynth, lastSynth);
						newSynth.instrument = 0; newSynth.custom = 0; newSynth.key = 0;
						newSynth.freq = 0; newSynth.volume = 0; newSynth.isMusic = false;
						newSynth.noiz = false; newSynth.buzz = false;
						newSynth.detune = 0;
						// reverb and dampen keep their last levels so the echo rings out
						// after a track ends (real Pico-8 does this, zepto8 cuts it)
						let value = 0;
						const mainBaseOffset = ch.main.offset;
						this.updateSfxState(ch.main, newSynth, 1, ch.length, ch.isMusic, ch.canLoop);
						let restartCustom = newSynth.instrument != ch.lastMainInstrument || newSynth.key != ch.lastMainKey;
						ch.lastMainInstrument = newSynth.instrument;
						ch.lastMainKey = newSynth.key;
						if(newSynth.volume > 0) {
							if(newSynth.custom) {
								// notes with waveform Custom1-8 play another track as their instrument,
								// transposed relative to C2 and scaled by the note's volume
								const instrumentId = this.instruments[newSynth.instrument];
								if(instrumentId >= 0 && this.tracks[instrumentId]) {
									if(ch.main.offset < mainBaseOffset) restartCustom = true; // the main track looped
									if(ch.custom.sfx == -1 && Math.floor(mainBaseOffset) != Math.floor(ch.main.offset)) restartCustom = true;
									if(restartCustom) {
										ch.custom.sfx = instrumentId;
										ch.custom.offset = 0;
										ch.custom.time = 0;
									}
									newSynth.phi = lastSynth.phi;
									const freqFactor = newSynth.freq / keyToFreq(24);
									const mainVolume = newSynth.volume;
									this.updateSfxState(ch.custom, newSynth, freqFactor, 0, false, true);
									newSynth.volume *= mainVolume;
								}
							}
							value = this.getSynthSample(newSynth);
						}
						// crossfade over harsh changes to avoid clicks (Pico-8's volume ramping)
						const freqThreshold = Math.min(newSynth.freq, lastSynth.freq) * 0.01;
						if(Math.abs(newSynth.volume - lastSynth.volume) > 0.1
							|| Math.abs(newSynth.freq - lastSynth.freq) > freqThreshold
							|| newSynth.instrument != lastSynth.instrument) {
							if(ch.fade <= 0) copySynth(ch.fadeSynth, lastSynth);
							ch.fade = 1;
							newSynth.phi = newSynth.phi % 1;
						}
						copySynth(lastSynth, newSynth);
						let reverb1 = lastSynth.reverb == 1 ? 1 : 0;
						let reverb2 = lastSynth.reverb == 2 ? 1 : 0;
						let dampen1 = lastSynth.dampen == 1 ? 1 : 0;
						let dampen2 = lastSynth.dampen == 2 ? 1 : 0;
						if(ch.fade > 0) {
							const fadeSynth = ch.fadeSynth;
							fadeSynth.phi += fadeSynth.freq * INV;
							const fadeValue = this.getSynthSample(fadeSynth);
							value = mix(value, fadeValue, ch.fade);
							reverb1 = mix(reverb1, fadeSynth.reverb == 1 ? 1 : 0, ch.fade);
							reverb2 = mix(reverb2, fadeSynth.reverb == 2 ? 1 : 0, ch.fade);
							dampen1 = mix(dampen1, fadeSynth.dampen == 1 ? 1 : 0, ch.fade);
							dampen2 = mix(dampen2, fadeSynth.dampen == 2 ? 1 : 0, ch.fade);
							ch.fade -= 130 * INV;
						}
						// reverb: a feedback comb delaying 2 or 4 ticks
						const ri = ch.reverbIndex;
						if(reverb1 > 0) value += reverb1 * ch.reverb2[ri % DELAY1] * 0.5;
						if(reverb2 > 0) value += reverb2 * ch.reverb4[ri % DELAY2] * 0.5;
						ch.reverb2[ri % DELAY1] = value;
						ch.reverb4[ri % DELAY2] = value;
						ch.reverbIndex = ri + 1;
						// dampen: a high shelf cut, -6 dB above 2400 Hz or -12 dB above 1000 Hz
						const damped1 = runFilter(ch.damp1, value);
						if(dampen1 > 0) value = mix(value, damped1, dampen1);
						const damped2 = runFilter(ch.damp2, value);
						if(dampen2 > 0) value = mix(value, damped2, dampen2);
						mixed += clamp(value, -0.99, 0.99);
					}
					out[i] = clamp(mixed, -1, 1) * this.masterVolume;
				}
				return true;
			}
		}
		registerProcessor("pico8", Pico8Processor);
