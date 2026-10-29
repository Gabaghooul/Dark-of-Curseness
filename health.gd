extends Node

var max_hp = 0
var hp = 0
signal damage_taken(amount: int)
signal hurt
signal block
signal death

func init(parent_hp):
	max_hp = parent_hp
	hp = parent_hp

func take_damage(damage):
	if get_parent().state != "GUARD" && get_parent().state != "DODGE":
		if hp > 0:
			hp -= damage
			damage_taken.emit(damage)
			if hp <= 0:
				emit_signal("death")
			emit_signal("hurt")
	else:
		if get_parent().state == "GUARD":
			emit_signal("block")
