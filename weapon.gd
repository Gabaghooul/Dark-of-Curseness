extends Node3D

@export var damage = 10
var connected_hits = []
signal animation_finished

func attack():
	connected_hits = []	
	$AnimationPlayer.play("swing")
	
func enable_hitbox():
	$VisualPivot/Hitbox.set_deferred("monitoring", true)
	
func finish_attack():
	$VisualPivot/Hitbox.set_deferred("monitoring", false)
	emit_signal("animation_finished")

func _on_hitbox_area_entered(area: Area3D) -> void:
	var enemy = area.get_parent().get_parent()
	if enemy.has_node("Health") && !connected_hits.has(enemy):
		enemy.get_node("Health").take_damage(damage)
		connected_hits.append(enemy)
