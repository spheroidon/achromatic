class_name Player extends CharacterBody3D

@export var base_speed: float = 8.0
@export var sprint_speed: float = 14.0
@export var max_health: float = 100

const GUNS = [
	{
		"name": "Pistol",
		"sprites": preload("res://assets/pistol/pistol.tres"),
		"shoot_sound": preload("res://assets/pistol/pistol_shoot.ogg"),
		"cooldown": 0.45,
		"ammo_type": 0,
		"ammo_per_shot": 1
	},
	{
		"name": "Shotgun",
		"sprites": preload("res://assets/shotgun/shotgun.tres"),
		"shoot_sound": preload("res://assets/shotgun/shotgun_shoot.ogg"),
		"cooldown": 1.4,
		"ammo_type": 1,
		"ammo_per_shot": 2
	}
]

const AMMO_TYPES = [
	{
		"name": "Bullets",
		"max_amount": 200,
		"starting_amount": 50
	},
	{
		"name": "Shells",
		"max_amount": 50,
		"starting_amount": 8
	}
]

var ammo: Array[int] = []

var target_gun_index = 0
var gun_index = 0
var current_shoot_cooldown: float = 0.0

var sprinting: bool = false

@onready var camera: Camera3D = $Camera
@onready var gun_image: AnimatedTextureRect = $Guns/Control/GunImage
@onready var stair_handler: CollisionShape3D = $StairHandler
@onready var shoot_audio: AudioStreamPlayer = $Guns/ShootAudio
@onready var empty_audio: AudioStreamPlayer = $Guns/EmptyAudio

func _ready():
	for ammo_type in AMMO_TYPES:
		ammo.append(ammo_type["starting_amount"])
	switch_gun()
	
func _process(delta: float):
	# Cooldowns
	if current_shoot_cooldown > 0:
		current_shoot_cooldown -= delta
	
	# Animations
	if not gun_image.is_playing() and gun_image.current_animation != "default":
		gun_image.play("default")
	
	# Gun Switching
	if Input.is_action_just_pressed("next_gun"):
		target_gun_index = gun_index + 1
		if target_gun_index >= GUNS.size():
			target_gun_index = 0
	if Input.is_action_just_pressed("previous_gun"):
		target_gun_index = gun_index - 1
		if target_gun_index < 0:
			target_gun_index = GUNS.size()-1
	if Input.is_action_just_pressed("gun_0"):
		target_gun_index = 0
	if Input.is_action_just_pressed("gun_1"):
		target_gun_index = 1
	if current_shoot_cooldown <= 0 and gun_index != target_gun_index:
		switch_gun()
	
	# Shooting
	if Input.is_action_pressed("shoot") and current_shoot_cooldown <= 0:
		shoot()

func shoot():
		var gun = GUNS[gun_index]
		if ammo[gun["ammo_type"]] >= gun["ammo_per_shot"]:
			ammo[gun["ammo_type"]] -= gun["ammo_per_shot"]
			current_shoot_cooldown = gun["cooldown"]
			gun_image.play("shoot")
			shoot_audio.play()
		else:
			current_shoot_cooldown = 0.6
			gun_image.play("empty")
			empty_audio.play()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * 0.008)
			#camera.rotate_x(-event.relative.y * 0.008)

func _physics_process(delta: float) -> void:
	# Movement
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_pressed("run"):
		sprinting = true
	else:
		sprinting = false
		
	var speed: float = base_speed
	if sprinting:
		speed = sprint_speed

	var input_dir := Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	if abs(input_dir.length()) > 0.1:
		var offset = input_dir.normalized() * 0.6
		stair_handler.position = Vector3(offset.x,-0.5,offset.y)

func switch_gun():
	gun_index = target_gun_index
	gun_image.sprites = GUNS[gun_index]["sprites"]
	gun_image.stop()
	gun_image.play("default")
	shoot_audio.stop()
	shoot_audio.stream = GUNS[gun_index]["shoot_sound"]
	
func add_ammo(ammo_type: int, ammo_amount: int) -> bool:
	if ammo[ammo_type] == AMMO_TYPES[ammo_type]["max_amount"]:
		return false
	else:
		if ammo[ammo_type] + ammo_amount >= AMMO_TYPES[ammo_type]["max_amount"]:
			ammo[ammo_type] = AMMO_TYPES[ammo_type]["max_amount"]
		else:
			ammo[ammo_type] += ammo_amount
		return true
