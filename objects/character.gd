extends CharacterBody3D

@export var base_speed: float = 8.0
@export var sprint_speed: float = 14.0
@export var max_health: float = 100

const GUNS = [
	{
		"name": "Pistol",
		"sprites": preload("res://assets/pistol/pistol.tres"),
		"cooldown": 0.45
	},
	{
		"name": "Shotgun",
		"sprites": preload("res://assets/shotgun/shotgun.tres"),
		"cooldown": 1.4
	}
]
var gun_index = 0
var current_shoot_cooldown: float = 0.0

var sprinting: bool = false

@onready var camera: Camera3D = $Camera
@onready var gun_image: AnimatedTextureRect = $Guns/Control/GunImage
@onready var stair_handler: CollisionShape3D = $StairHandler

func _ready():
	switch_gun()

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
	# Cooldowns
	if current_shoot_cooldown > 0:
		current_shoot_cooldown -= delta
		
	# Animations
	if not gun_image.is_playing() and gun_image.current_animation == "shoot":
		gun_image.play("default")
	
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
		
	# Gun Switching
	if Input.is_action_just_pressed("next_gun"):
		gun_index += 1
		if gun_index >= GUNS.size():
			gun_index = 0
		switch_gun()
	if Input.is_action_just_pressed("previous_gun"):
		gun_index -= 1
		if gun_index < 0:
			gun_index = GUNS.size()-1
		switch_gun()
	if Input.is_action_just_pressed("gun_0"):
		gun_index = 0
		switch_gun()
	if Input.is_action_just_pressed("gun_1"):
		gun_index = 1
		switch_gun()
	
	# Shooting
	if Input.is_action_pressed("shoot") and current_shoot_cooldown <= 0:
		current_shoot_cooldown = GUNS[gun_index]["cooldown"]
		gun_image.play("shoot")

func switch_gun():
	gun_image.sprites = GUNS[gun_index]["sprites"]
	gun_image.stop()
	gun_image.play("default")
