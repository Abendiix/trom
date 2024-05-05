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

@onready var Back = $Back/Sprite2D
@onready var BackFrame = $Back/Frame
@onready var BackHold = $Back/Hold

@onready var frames = [BackFrame]
@onready var holds = [BackHold]

@onready var active = 0
@onready var pressTimer = 0

@onready var settings = get_node("/root/settings")

@onready var trom = $TromAndNodes/Trom
@onready var noteRight = $TromAndNodes/NotesRight
@onready var noteLeft = $TromAndNodes/NotesLeft

@onready var soundEffect = $SoundEffect
@onready var sounds = ["res://assets/sounds/basicDo.wav", "res://assets/sounds/basicFa.wav", "res://assets/sounds/basicLa.wav", "res://assets/sounds/basicMi.wav", "res://assets/sounds/basicRe.wav", "res://assets/sounds/basicSi.wav", "res://assets/sounds/basicSol.wav"]
@onready var score = $Score
@onready var naturalScore = 0

@onready var notes = ["res://assets/sprites/notes1.png", "res://assets/sprites/notes2.png", "res://assets/sprites/notes3.png", "res://assets/sprites/notes4.png", "res://assets/sprites/notes5.png", "res://assets/sprites/notes6.png", "res://assets/sprites/notes7.png", "res://assets/sprites/notes8.png"]

@onready var rand = RandomNumberGenerator.new()

@onready var isHeld = false
@onready var screenSizeX: float = DisplayServer.screen_get_size().x
@onready var screenSizeY: float = DisplayServer.screen_get_size().y

func _ready():
	soundEffect.stream = load("res://assets/sounds/basicLa.wav")
	
	BackHold.play()
	BackHold.stop()
	
	BackHold.visible = false
	BackHold.modulate = Color("ffac59")
	
	BackFrame.visible = false
	BackFrame.modulate = Color("ffac59")
	
	noteRight.visible = false
	noteLeft.visible = false
	
	initializeData()

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
			if(pressTimer > 0.2):
				BackFrame.stop()
				BackFrame.visible = false
			Input.vibrate_handheld(settings.vibration)
			
			pressTimer = 0
			
		if BackHold.hasFinished():
			BackHold.pause()
		
		if Input.is_action_just_released("play") && BackHold.hasFinished():
			BackHold.endFinished()
			get_tree().change_scene_to_file("res://scenes/main.tscn")
			
		if Input.is_action_just_pressed("changeScreen"):
			print(DisplayServer.window_get_mode())
			if(DisplayServer.window_get_mode() == 0):
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			elif(DisplayServer.window_get_mode() != 0):
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_position(Vector2(screenSizeX/2-144, screenSizeY/2-256))
				
		if Input.is_action_just_pressed("play"):
			playNote()
		
		if Input.is_action_just_released("play"):
			releaseNote()
			
		if Input.is_action_pressed("play"):
			if(!isHeld):
				trom.scale = Vector2(1.5, 1.5)
				noteRight.texture = ResourceLoader.load(notes[rand.randf_range(0, 7)])
				noteRight.visible = true
				noteRight.modulate = Color(rand.randf_range(0, 1), rand.randf_range(0, 1), rand.randf_range(0, 1))
				noteLeft.texture = ResourceLoader.load(notes[rand.randf_range(0, 7)])
				noteLeft.visible = true
				noteLeft.modulate = Color(rand.randf_range(0, 1), rand.randf_range(0, 1), rand.randf_range(0, 1))
				soundEffect.play()
				isHeld = true
				Input.vibrate_handheld(settings.vibration)

func playNote():
	trom.scale = Vector2(1.5, 1.5)
	noteRight.texture = ResourceLoader.load(notes[rand.randf_range(0, 7)])
	noteRight.visible = true
	noteRight.modulate = Color(rand.randf_range(0, 1), rand.randf_range(0, 1), rand.randf_range(0, 1))
	noteLeft.texture = ResourceLoader.load(notes[rand.randf_range(0, 7)])
	noteLeft.visible = true
	noteLeft.modulate = Color(rand.randf_range(0, 1), rand.randf_range(0, 1), rand.randf_range(0, 1))
	soundEffect.play()
	naturalScore += 1
	score.text = str(naturalScore)
	settings.set_scoregame1(naturalScore)

func releaseNote():
	trom.scale = Vector2(2, 2)
	noteRight.visible = false
	noteLeft.visible = false
	isHeld = false

func initializeData():
	var scoreFile = ConfigFile.new()
	var err_score = scoreFile.load("user://scoresgame1_0_10.cfg")

	if(err_score != OK):
		settings.set_scoregame1(0)
	else:
		scoreFile = ConfigFile.new()
		scoreFile.load("user://scoresgame1_0_10.cfg")
		settings.set_scoregame1(scoreFile.get_value("score", "game1"))
		naturalScore = scoreFile.get_value("score", "game1")
		score.text = str(naturalScore)
	

func _on_trom_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
			playNote()
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			releaseNote()

func _on_back_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_trom_exit():
	if(settings.mode == 1):
		Input.vibrate_handheld(settings.vibration)
		releaseNote()
