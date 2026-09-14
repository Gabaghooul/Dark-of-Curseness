extends CharacterBody3D

@onready var hp = 100

func _on_hurtbox_area_entered(area: Area3D):
	take_damage()

func take_damage():
	if hp > 0:
		hp -= 10
		print("Enemy hit: ", hp, "/", 100)
	if hp <= 0:
		print("Enemy dead")
