extends Node

var max_hp = 0
var hp = 0
signal hurt
signal death

func init(parent_hp):
	max_hp = parent_hp
	hp = parent_hp

func take_damage(damage):
	if hp > 0:
		hp -= damage
		print("Entity hit: ", hp, "/", max_hp)
		if hp <= 0:
			print("Entity dead")
			emit_signal("death")
		emit_signal("hurt")
