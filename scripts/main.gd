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

@onready var gameplaySprite = $Buttons/Gameplay/Sprite2D
@onready var gameplayFrame = $Buttons/Gameplay/Frame
@onready var gameplayHold = $Buttons/Gameplay/Hold

@onready var gameplay2Sprite = $Buttons/Gameplay/Sprite2D
@onready var gameplay2Frame = $Buttons/Gameplay2/Frame
@onready var gameplay2Hold = $Buttons/Gameplay2/Hold

@onready var configurationSprite = $Buttons/Gameplay/Sprite2D
@onready var configurationFrame = $Buttons/Configuration/Frame
@onready var configurationHold = $Buttons/Configuration/Hold

@onready var frames = [gameplayFrame, gameplay2Frame, configurationFrame]
@onready var holds = [gameplayHold, gameplay2Hold, configurationHold]
@onready var active = 0
@onready var pressTimer = 0

@onready var settings = get_node("/root/settings")

func _ready():
	holds[active].play()
	holds[active].stop()
	
	initializeData()
	
	for h in holds:
		h.visible = false
	
	for f in frames:
		f.visible = false
	
	frames[0].modulate = Color("ffd359")
	frames[1].modulate = Color("ffd359")
	holds[0].modulate = Color("ffd359")
	holds[1].modulate = Color("ffd359")
	
	frames[2].modulate = Color("ffac59")
	holds[2].modulate = Color("ffac59")

func _process(delta):
	if settings.mode == 1:
		$FramesBackground.visible = true
	elif settings.mode == 2:
		$FramesBackground.visible = false
		frames[active].play()
		frames[active].visible = true

		if Input.is_action_just_pressed("play"):
			pressTimer = 0
			Input.vibrate_handheld(settings.vibration)
		
		if Input.is_action_pressed("play"):
			pressTimer += delta
			
			if pressTimer >= 0.35:
				holds[active].play()
				Input.vibrate_handheld(settings.vibration_hold)
				holds[active].visible = true

		else:
			holds[active].stop()
			holds[active].visible = false
		
		if Input.is_action_just_released("play") && !holds[active].hasFinished():
			frames[active].stop()
			frames[active].visible = false
			Input.vibrate_handheld(settings.vibration)
			
			if pressTimer < 0.2:
				active += 1
			
				if(active >= 3):
					active = 0
			
			pressTimer = 0
		
		if holds[active].hasFinished():
			holds[active].pause()
	
		if Input.is_action_just_released("play") && holds[active].hasFinished():
			if active == 0:
				get_tree().change_scene_to_file("res://scenes/game.tscn")
			elif active == 1:
				get_tree().change_scene_to_file("res://scenes/game2.tscn")
			else:
				get_tree().change_scene_to_file("res://scenes/configuration.tscn")

func initializeData():
	var config = ConfigFile.new()
	var err_config = config.load("user://data_0_10.cfg")
	var mode = ConfigFile.new()
	var err_mode = mode.load("user://mode_0_10.cfg")
	
	if(err_config != OK):
		settings.set_vibration(15, 6)
	else:
		config = ConfigFile.new()
		config.load("user://data_0_10.cfg")
		settings.set_vibration(config.get_value("vibration", "default"), config.get_value("vibration", "hold"))

	if(err_mode != OK):
		settings.set_mode(1)
	else:
		mode = ConfigFile.new()
		mode.load("user://mode_0_10.cfg")
		settings.set_mode(mode.get_value("mode", "mode"))

func _on_gameplay_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_gameplay2_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			get_tree().change_scene_to_file("res://scenes/game2.tscn")

func _on_configuration_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			get_tree().change_scene_to_file("res://scenes/configuration.tscn")
