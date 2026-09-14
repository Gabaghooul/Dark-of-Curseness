extends Node3D

func attack():
	$VisualPivot/Hitbox.set_deferred("monitorable", true)
	$AnimationPlayer.play("swing")
	
func finish_attack():
	$VisualPivot/Hitbox.set_deferred("monitorable", false)
