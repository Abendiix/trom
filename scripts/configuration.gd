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

@onready var Vibration1 = $Buttons/Vibration1/Sprite2D
@onready var Vibration1Frame = $Buttons/Vibration1/Frame
@onready var Vibration1Hold = $Buttons/Vibration1/Hold
@onready var Vibration1Arrow = $Buttons/Vibration1/Arrow

@onready var Vibration2 = $Buttons/Vibration2/Sprite2D
@onready var Vibration2Frame = $Buttons/Vibration2/Frame
@onready var Vibration2Hold = $Buttons/Vibration2/Hold
@onready var Vibration2Arrow = $Buttons/Vibration2/Arrow

@onready var Vibration3 = $Buttons/Vibration3/Sprite2D
@onready var Vibration3Frame = $Buttons/Vibration3/Frame
@onready var Vibration3Hold = $Buttons/Vibration3/Hold
@onready var Vibration3Arrow = $Buttons/Vibration3/Arrow

@onready var ModeTap = $Buttons/ModeTap/Sprite2D
@onready var ModeTapFrame = $Buttons/ModeTap/Frame
@onready var ModeTapHold = $Buttons/ModeTap/Hold
@onready var ModeTapArrow = $Buttons/ModeTap/Arrow

@onready var ModeTap_Hold = $Buttons/ModeTap_Hold/Sprite2D
@onready var ModeTap_HoldFrame = $Buttons/ModeTap_Hold/Frame
@onready var ModeTap_HoldHold = $Buttons/ModeTap_Hold/Hold
@onready var ModeTap_HoldArrow = $Buttons/ModeTap_Hold/Arrow

@onready var Credits = $Buttons/Credits/Sprite2D
@onready var CreditsFrame = $Buttons/Credits/Frame
@onready var CreditsHold = $Buttons/Credits/Hold

@onready var Back = $Buttons/Back/Sprite2D
@onready var BackFrame = $Buttons/Back/Frame
@onready var BackHold = $Buttons/Back/Hold

@onready var frames = [Vibration1Frame, Vibration2Frame, Vibration3Frame, ModeTapFrame, ModeTap_HoldFrame, CreditsFrame, BackFrame]
@onready var holds = [Vibration1Hold, Vibration2Hold, Vibration3Hold, ModeTapHold, ModeTap_HoldHold, CreditsHold, BackHold]
@onready var arrows = [Vibration1Arrow, Vibration2Arrow, Vibration3Arrow, ModeTapArrow, ModeTap_HoldArrow]

@onready var active = 0
@onready var pressTimer = 0

@onready var settings = get_node("/root/settings")

func _ready():
	holds[active].play()
	holds[active].stop()
	
	for h in holds:
		h.visible = false
		h.modulate = Color("ffac59")
	
	for f in frames:
		f.visible = false
		f.modulate = Color("ffac59")
	
	for a in arrows:
		a.visible = false

func _process(delta):
	
	if(settings.vibration == 0):
		arrows[0].visible = true
		arrows[1].visible = false
		arrows[2].visible = false
	elif(settings.vibration == 15):
		arrows[0].visible = false
		arrows[1].visible = true
		arrows[2].visible = false
	elif(settings.vibration == 30):
		arrows[0].visible = false
		arrows[1].visible = false
		arrows[2].visible = true
		
	if(settings.mode == 1):
		arrows[3].visible = true
		arrows[4].visible = false
	elif(settings.mode == 2):
		arrows[3].visible = false
		arrows[4].visible = true
	
	
	if settings.mode == 1:
		$FramesBackground.visible = true
	elif settings.mode == 2:
		$FramesBackground.visible = false
		for f in frames:
			f.visible = false

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
		
		if Input.is_action_just_released("play"):
			frames[active].stop()
			frames[active].visible = false
			Input.vibrate_handheld(settings.vibration)
			
			if pressTimer < 0.2:
				active += 1
			
				if(active >= 7):
					active = 0
			
			pressTimer = 0
			
		if holds[active].hasFinished():
			holds[active].pause()
		
		if Input.is_action_just_released("play") && holds[active].hasFinished():
			holds[active].endFinished()
			
			if active <= 2:
				settings.set_vibration(active*15, active*6)
			elif active == 3:
				settings.set_mode(1)
			elif active == 4:
				settings.set_mode(2)
			elif active == 5:
				get_tree().change_scene_to_file("res://scenes/credits.tscn")
			elif active == 6:
				get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_vibration1_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
			settings.set_vibration(0, 0)

func _on_vibration2_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
			settings.set_vibration(15, 6)

func _on_vibration3_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			settings.set_vibration(30, 12)

func _on_modetap_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			settings.set_mode(1)

func _on_modetap_hold_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			settings.set_mode(2)
			active = 3

func _on_credits_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_back_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			get_tree().change_scene_to_file("res://scenes/main.tscn")
