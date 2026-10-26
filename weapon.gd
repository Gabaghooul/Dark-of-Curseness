extends Node3D

@export var base_damage = 10
@export var damage = 10

var combo_stage = 0
var max_combo = 3
var combo_multipliers = [1, 1.5, 2]
var combo_animations = ["swing", "swing2", "swing3"]
var connected_hits = []
signal animation_finished
signal combo_ready

func attack():
	damage = base_damage * combo_multipliers[combo_stage]
	connected_hits = []
	$AnimationPlayer.play(combo_animations[combo_stage])

func enable_hitbox():
	$VisualPivot/Hitbox.set_deferred("monitoring", true)
	
func combo_window():
	combo_stage += 1
	if combo_stage != max_combo:
		emit_signal("combo_ready")
	
func finish_attack():
	combo_stage = 0
	$VisualPivot/Hitbox.set_deferred("monitoring", false)
	emit_signal("animation_finished")
	$AnimationPlayer.play("RESET")
	
func interrupted():
	combo_stage = 0
	$VisualPivot/Hitbox.set_deferred("monitoring", false)
	$AnimationPlayer.play("RESET")

func _on_hitbox_area_entered(area: Area3D) -> void:
	var enemy = area.get_parent().get_parent()
	if enemy.has_node("Health") && !connected_hits.has(enemy):
		enemy.get_node("Health").take_damage(damage)
		connected_hits.append(enemy)
