extends CharacterBody3D

@export var hp = 100

func take_damage(damage):
	if hp > 0:
		$AnimationPlayer.play("Hurt")
		hp -= damage
		print("Enemy hit: ", hp, "/", 100)
	if hp <= 0:
		queue_free()
		print("Enemy dead")
