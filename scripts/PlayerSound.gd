extends AudioStreamPlayer

@export var sound_run: AudioStream
@export var sound_jump: AudioStream
@export var sound_hurt: AudioStream
@export var sound_dash: AudioStream

func play_sfx(sfx_name: String):
	match sfx_name:
		"jump": stream = sound_jump
		"run": stream = sound_run
		"hurt": stream = sound_hurt
		"dash": stream = sound_dash
		_: return
	
	play()
