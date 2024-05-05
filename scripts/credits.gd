"""
MIT License

Copyright (c) 2024 Abendiix

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

extends Node2D

@onready var Back = $Buttons/Back/Sprite2D
@onready var BackFrame = $Buttons/Back/Frame
@onready var BackHold = $Buttons/Back/Hold

@onready var frames = [BackFrame]
@onready var holds = [BackHold]

@onready var active = 0
@onready var pressTimer = 0

@onready var settings = get_node("/root/settings")

func _ready():
	BackHold.play()
	BackHold.stop()
	
	BackHold.visible = false
	BackHold.modulate = Color("ffac59")
	
	BackFrame.visible = false
	BackFrame.modulate = Color("ffac59")

func _process(delta):
	if settings.mode == 1:
		$FramesBackground.visible = true
	elif settings.mode == 2:
		$FramesBackground.visible = false
		BackFrame.play()
		BackFrame.visible = true

		if Input.is_action_just_pressed("play"):
			pressTimer = 0
			Input.vibrate_handheld(settings.vibration)
		
		if Input.is_action_pressed("play"):
			pressTimer += delta
			if pressTimer >= 0.35:
				BackHold.play()
				Input.vibrate_handheld(settings.vibration_hold)
				BackHold.visible = true
		else:
			BackHold.stop()
			BackHold.visible = false
		
		if Input.is_action_just_released("play"):
			BackFrame.stop()
			BackFrame.visible = false
			Input.vibrate_handheld(settings.vibration)
			
			pressTimer = 0
			
		if BackHold.hasFinished():
			BackHold.pause()
		
		if Input.is_action_just_released("play") && BackHold.hasFinished():
			BackHold.endFinished()
			get_tree().change_scene_to_file("res://scenes/configuration.tscn")

func _on_back_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			get_tree().change_scene_to_file("res://scenes/main.tscn")
