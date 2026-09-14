extends Node3D

func attack():
	$Hitbox.set_deferred("monitorable", true)
	await get_tree().create_timer(0.2).timeout
	$Hitbox.set_deferred("monitorable", false)
