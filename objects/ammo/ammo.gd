extends Node3D

@export var ammo_type: int = 0
@export var ammo_amount: int = 1

@onready var area: Area3D = $PickupArea

func _on_pickup_area_body_entered(player: Node3D) -> void:
	if player is Player:
		var added = player.add_ammo(ammo_type, ammo_amount)
		if added:
			queue_free()
