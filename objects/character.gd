extends CharacterBody3D

@export var base_speed: float = 8.0
@export var sprint_speed: float = 14.0
@export var max_health: float = 100

var sprinting: bool = false

@onready var camera: Camera3D = $Camera
@onready var stair_handler: CollisionShape3D = $StairHandler

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
