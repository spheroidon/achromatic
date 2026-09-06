class_name AnimatedTextureRect extends TextureRect

@export var sprites: SpriteFrames
@export var current_animation: String = "default"
@export var frame_index: int = 0
@export_range(0.0, 1000.0, 0.001) var speed_scale: float = 1.0
@export var auto_play: bool = false
@export var playing: bool = false

var refresh_rate: float = 1.0
var fps: float = 30.0
var frame_delta: float = 0.0

func _ready() -> void:
	_get_animation_data(current_animation)
	if auto_play:
		play()

func _process(delta: float) -> void:
	if not sprites or not playing:
		return
	if not sprites.has_animation(current_animation):
		playing = false
		assert(false,"Animation %s doesn't exist." % current_animation)
	_get_animation_data(current_animation)
	frame_delta += (speed_scale * delta)
	if frame_delta >= refresh_rate/fps:
		texture = _get_next_frame()
		frame_delta = 0

func play(animation_name: String = current_animation):
	frame_index = -1
	frame_delta = 0.0
	current_animation = animation_name
	_get_animation_data(current_animation)
	texture = _get_next_frame()
	playing = true
	
func resume():
	playing = true
	
func pause():
	playing = false
	
func stop():
	frame_index = 0
	playing = false
	
func is_playing():
	return playing
	
func _get_next_frame():
	frame_index += 1
	var frame_count = sprites.get_frame_count(current_animation)
	if frame_index >= frame_count:
		if not sprites.get_animation_loop(current_animation):
			frame_index = frame_count-1
			playing = false
			return sprites.get_frame_texture(current_animation,frame_index)
		else:
			frame_index = 0
	_get_animation_data(current_animation)
	return sprites.get_frame_texture(current_animation,frame_index)
	
func _get_animation_data(animation_name: String = current_animation):
	fps = sprites.get_animation_speed(animation_name)
	refresh_rate = sprites.get_frame_duration(animation_name, frame_index||0)
	
