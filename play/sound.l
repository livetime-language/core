// A sound
skipInit immutable Sound
	string file
	Time duration
	
	float fadeVolume = 1
	transient dynamic audioElement
	
	Sound
		audio.sounds.add this
	
	js void open
		return new Promise((resolve, reject) => {
			this.nextAudioElement = new Audio();
			this.nextAudioElement.onloadedmetadata = () => resolve()
			this.nextAudioElement.onerror = () => {
				System.print(`Failed to load sound ${this.file}`)
				reject();
			}
			this.nextAudioElement.src = Platform.getAbsoluteUrl(this.file);			
		})
		
	js void volume: float value
		this.fadeVolume = value
		if(this.audioElement) this.audioElement.volume = this.fadeVolume * audio.volume
		
	js void updateVolume
		if(this.audioElement) this.audioElement.volume = this.fadeVolume * audio.volume
		
	js void stop
		if(this.audioElement) this.audioElement.pause()
		
	play: needsToBeCertain = false
		if needsToBeCertain and not input.isCertain: return
			
		// We can play sounds immediately to ensure there is no lag
		// If a sound turns out to be wrong after receiving new inputs, we stop it
		let playingSound = audio.playingSounds.find(.sound == this and .frame == Time.frame)
		if !playingSound
			audio.playingSounds.add playingSound = {this, frame:Time.frame, isConfirmed:true}
			if core.isPremiere: doPlay playingSound
		else
			playingSound.isConfirmed = true
			
	js void currentTime: float value
		if(this.audioElement) this.audioElement.currentTime = value
		
	private js void doPlay: PlayingSound ps
		// Recreate audio if it was lost during serialization
		if(!this.nextAudioElement) this.preloadForNextPlayback();
			
		// Play audio
		this.fadeVolume = 1;
		this.audioElement = this.nextAudioElement;
		this.audioElement.volume = audio.volume;
		this.audioElement.onended = () => audio.playingSounds.remove(ps);
		this.audioElement.play();
		this.preloadForNextPlayback()
		
	internal js void preloadForNextPlayback
		this.nextAudioElement = new Audio();
		if(PeerNetwork.audioOutputId && this.nextAudioElement.setSinkId) 
			await this.nextAudioElement.setSinkId(PeerNetwork.audioOutputId);
		this.nextAudioElement.src = _basePath+this.file;
		
	isPlaying
		return audio.playingSounds.any.sound == this and .frame < Time.frame

	fadeOut: Time duration = 3000
		     Time delay = 0
		// Migrate to 3D
		fx.add FadeSoundAnimation startTime:Time.now+delay, duration, sound:this, startValue:1, delta:-1
		return this

internal transient PlayingSound
	immutable Sound sound
	immutable int frame
	bool isConfirmed
	
// A collection of functions for playing audio
transient global skipInit unit audio
	const float[] volumeLevels = [0, 0.0001, 0.0002, 0.0005, 0.001, 0.002, 0.005, .01, .02, .04, .08, .16, .32, .64, 1]
	int volumeLevel = 10
	float volume = volumeLevels[volumeLevel]
	
	PlayingSound[] playingSounds
	Sound[] sounds
	
	internal startFrame
		playingSounds.each.isConfirmed = false
		
	internal finishFrame
		// Stop sounds that turned out to be wrong after receiving new inputs
		playingSounds.each
			if .frame == Time.frame and !.isConfirmed
				.sound.stop
		
	internal reload
		sounds.each.preloadForNextPlayback
		
	stop
		playingSounds.each.sound.stop
		playingSounds.clear
	
	mute: Player forPlayer = null
		if !forPlayer or forPlayer.id == input.localUser.id
			volumeLevel = 0
			volume = volumeLevels[volumeLevel]
			playingSounds.each.sound.updateVolume
	
	adjustVolume: int delta = 1, Player forPlayer = null
		if !forPlayer or forPlayer.id == input.localUser.id
			volumeLevel = math.limit(volumeLevel+delta, min:0, max:volumeLevels.length-1)
			volume = volumeLevels[volumeLevel]
			playingSounds.each.sound.updateVolume
