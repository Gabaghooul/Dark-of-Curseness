extends Label3D

@export var lifetime := 0.8
@export var rise_height := 1.0

func show_damage(amount: int):
	text = str(amount)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y + rise_height, lifetime)
	tween.tween_property(self, "modulate:a", 0.0, lifetime)
	tween.chain().tween_callback(queue_free)
