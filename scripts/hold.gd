extends Node2D

@onready var hold = $HoldAnimation
@onready var isFinished = false

func play():
	hold.play("hold")

func stop():
	hold.stop()

func pause():
	hold.pause()

func hasFinished():
	return isFinished

func endFinished():
	isFinished = false

func _on_hold_animation_animation_finished(_anim_name):
	isFinished = true
