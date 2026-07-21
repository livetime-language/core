enum SoundEditorMode
	Pitch	= 0
	Tracker	= 1

class Sound
	string name
	SoundEditorMode editorMode = Pitch
	bool noiz, buzz, detune, reverb, dampen
	int noteDuration	// in multiples of 1/128 second
	int loopStartIndex	// as a note index (0-63)
	int loopEndIndex	// as a note index (0-63)
	ImmutableList<SoundNote> notes	// the notes played in sequence

	// Parse notes from strings like "c#0 a51": pitch as note and octave, waveform as hex digit, volume, effect ("." if none)
	Sound: string[] notesAsStrings = null
		if not notesAsStrings then return
		string noteNames = "c-c#d-d#e-f-f#g-g#a-a#b-"
		string digits = "0123456789abcdef"
		NoteWaveform[] waveforms = [Sine, Triangle, Sawtooth, LongSquare, ShortSquare, Ringing, Noise, RingingSine, Custom1, Custom2, Custom3, Custom4, Custom5, Custom6, Custom7, Custom8]
		NoteEffect[] effects = [None, Slide, Vibrato, Drop, FadeIn, FadeOut, ArpeggioFast, ArpeggioSlow]
		SoundNote[] list = []
		for notesAsStrings as str
			if str[0] == " "
				list.add SoundNote()
				continue
			int semitone = floor(noteNames.indexOf(str[0 to 2]) / 2)
			int octave = str.getCharCodeAt(2) - 48
			int waveformIndex = digits.indexOf(str[4])
			int volume = str.getCharCodeAt(5) - 48
			int effectIndex = str[6] == "." ? 0 : str.getCharCodeAt(6) - 48
			list.add SoundNote(pitch:octave*12 + semitone, waveform:waveforms[waveformIndex], volume:volume, effect:effects[effectIndex])
		notes = list

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

class SoundNote
	int pitch	// 0 - 63, c-0 to d#5, chromatic scale
	NoteWaveform waveform = Sine	// 0 - 15
	int volume	// 0 -  7
	NoteEffect effect = None	// 0 -  7

class MusicPattern
	Sound[] tracks
	bool startLoop, endLoop
	bool stopAtEndOfPattern
