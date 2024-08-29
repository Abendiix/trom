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

@onready var Note1 = $Buttons/Note1/Sprite2D
@onready var Note1Frame = $Buttons/Note1/Frame
@onready var Note1Hold = $Buttons/Note1/Hold

@onready var Note2 = $Buttons/Note2/Sprite2D
@onready var Note2Frame = $Buttons/Note2/Frame
@onready var Note2Hold = $Buttons/Note2/Hold

@onready var Note3 = $Buttons/Note3/Sprite2D
@onready var Note3Frame = $Buttons/Note3/Frame
@onready var Note3Hold = $Buttons/Note3/Hold

@onready var Play = $Buttons/Play/Sprite2D
@onready var PlayFrame = $Buttons/Play/Frame
@onready var PlayHold = $Buttons/Play/Hold

@onready var Ok = $Buttons/Ok/Sprite2D
@onready var OkFrame = $Buttons/Ok/Frame
@onready var OkHold = $Buttons/Ok/Hold

@onready var Back = $Buttons/Back/Sprite2D
@onready var BackFrame = $Buttons/Back/Frame
@onready var BackHold = $Buttons/Back/Hold

@onready var frames = [Note1Frame, Note2Frame, Note3Frame, PlayFrame, OkFrame, BackFrame]
@onready var holds = [Note1Hold, Note2Hold, Note3Hold, PlayHold, OkHold, BackHold]

@onready var active = 0
@onready var selected
@onready var pressTimer = 0

@onready var settings = get_node("/root/settings")

@onready var trom = $TromAndNodes/Trom
@onready var noteRight = $TromAndNodes/NotesRight
@onready var noteLeft = $TromAndNodes/NotesLeft

@onready var soundEffect = $SoundEffect
@onready var sounds = ["res://assets/sounds/basicDo.wav", "res://assets/sounds/basicFa.wav", "res://assets/sounds/basicLa.wav", "res://assets/sounds/basicMi.wav", "res://assets/sounds/basicRe.wav", "res://assets/sounds/basicSi.wav", "res://assets/sounds/basicSol.wav"]
@onready var current = $Current
@onready var record = $Record
@onready var naturalCurrent = 0
@onready var naturalRecord = 0

@onready var notes = ["res://assets/sprites/notes1.png", "res://assets/sprites/notes2.png", "res://assets/sprites/notes3.png", "res://assets/sprites/notes4.png", "res://assets/sprites/notes5.png", "res://assets/sprites/notes6.png", "res://assets/sprites/notes7.png", "res://assets/sprites/notes8.png"]

@onready var rand = RandomNumberGenerator.new()

@onready var isHeld = false
@onready var screenSizeX: float = DisplayServer.screen_get_size().x
@onready var screenSizeY: float = DisplayServer.screen_get_size().y

@onready var currentNote

@onready var guesses = []

func _ready():
	holds[active].play()
	holds[active].stop()
	
	for i in 3:
		frames[i].visible = false
		frames[i].modulate = Color("ffd359")
	
	for i in range(3, 6):
		frames[i].visible = false
		frames[i].modulate = Color("ffac59")
	
	for i in 3:
		holds[i].visible = false
		holds[i].modulate = Color("ffd359")
	
	for i in range(3, 6):
		holds[i].visible = false
		holds[i].modulate = Color("ffac59")
	
	initializeData()
	
	naturalCurrent = settings.currentGame2
	naturalRecord = settings.recordGame2
	
	random()
	
	await(get_tree().create_timer(0.5).timeout)
	play()

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
		
		if Input.is_action_just_released("play"):
			frames[active].stop()
			frames[active].visible = false
			Input.vibrate_handheld(settings.vibration)
			
			if pressTimer < 0.2:
				active += 1
			
				if(active >= 6):
					active = 0
			
			pressTimer = 0
			
		if holds[active].hasFinished():
			holds[active].pause()
		
		if Input.is_action_just_released("play") && holds[active].hasFinished():
			holds[active].endFinished()
			var arrows = [$Buttons/Note1/ArrowYellow, $Buttons/Note2/ArrowYellow, $Buttons/Note3/ArrowYellow]
			if active <= 2:
				for a in arrows:
					a.visible = false
				
				arrows[active].visible = true
				
				soundEffect.stream = load(sounds[guesses[active]])
				soundEffect.play()
				selected = active
			if active == 3:
				play()
			elif active == 4:
				if(selected != null):
					guess(guesses[selected])
			elif active == 5:
				get_tree().change_scene_to_file("res://scenes/main.tscn")
		
		if Input.is_action_just_pressed("changeScreen"):
			print(DisplayServer.window_get_mode())
			if(DisplayServer.window_get_mode() == 0):
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			elif(DisplayServer.window_get_mode() != 0):
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_position(Vector2(screenSizeX/2-144, screenSizeY/2-256))

func random():
	currentNote = rand.randi_range(0, 6)
	guesses = [rand.randi_range(0, 6), rand.randi_range(0, 6), rand.randi_range(0, 6)]
	
	guesses[rand.randi_range(0, 2)] = currentNote

func play():
	trom.scale = Vector2(1.5, 1.5)
	noteRight.texture = ResourceLoader.load(notes[rand.randf_range(0, 7)])
	noteRight.visible = true
	noteRight.modulate = Color(rand.randf_range(0, 1), rand.randf_range(0, 1), rand.randf_range(0, 1))
	noteLeft.texture = ResourceLoader.load(notes[rand.randf_range(0, 7)])
	noteLeft.visible = true
	noteLeft.modulate = Color(rand.randf_range(0, 1), rand.randf_range(0, 1), rand.randf_range(0, 1))
	soundEffect.stream = load(sounds[currentNote])
	soundEffect.play()
	Input.vibrate_handheld(settings.vibration)
	
	await(get_tree().create_timer(0.5).timeout)
	noteRight.visible = false
	noteLeft.visible = false
	trom.scale = Vector2(2, 2)

func guess(guessedNote):
	active = 0
	
	$Buttons/Note1/ArrowYellow.visible = false
	$Buttons/Note2/ArrowYellow.visible = false
	$Buttons/Note3/ArrowYellow.visible = false
	
	if(currentNote == guessedNote):
		naturalCurrent += 1
		current.text = str(naturalCurrent)
		random()
		if(naturalRecord < naturalCurrent):
			naturalRecord = naturalCurrent
			record.text = str(naturalRecord)
		
		soundEffect.stream = load("res://assets/sounds/correct.wav")
		soundEffect.play()
		await(get_tree().create_timer(0.8).timeout)
		play()
	else:
		naturalCurrent = 0
		current.text = str(naturalCurrent)
		soundEffect.stream = load("res://assets/sounds/incorrect.wav")
		soundEffect.play()
		await(get_tree().create_timer(0.8).timeout)
		play()
	
	frames[active].stop()
	frames[active].visible = false
	settings.set_scoregame2(naturalCurrent, naturalRecord)

func initializeData():
	var scoreFile = ConfigFile.new()
	var err_score = scoreFile.load("user://scoresgame2_0_10.cfg")
		
	if(err_score != OK):
		settings.set_scoregame2(0, 0)
	else:
		scoreFile = ConfigFile.new()
		scoreFile.load("user://scoresgame2_0_10.cfg")
		settings.set_scoregame2(scoreFile.get_value("score", "game2current"), scoreFile.get_value("score", "game2record"))
		naturalCurrent = scoreFile.get_value("score", "game2current")
		naturalRecord = scoreFile.get_value("score", "game2record")
		current.text = str(naturalCurrent)
		record.text = str(naturalRecord)


func _on_note1_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			soundEffect.stream = load(sounds[guesses[0]])
			soundEffect.play()
			selected = 0
			$Buttons/Note1/ArrowYellow.visible = true
			$Buttons/Note2/ArrowYellow.visible = false
			$Buttons/Note3/ArrowYellow.visible = false

func _on_note2_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			soundEffect.stream = load(sounds[guesses[1]])
			soundEffect.play()
			selected = 1
			$Buttons/Note1/ArrowYellow.visible = false
			$Buttons/Note2/ArrowYellow.visible = true
			$Buttons/Note3/ArrowYellow.visible = false

func _on_note3_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			soundEffect.stream = load(sounds[guesses[2]])
			soundEffect.play()
			selected = 2
			$Buttons/Note1/ArrowYellow.visible = false
			$Buttons/Note2/ArrowYellow.visible = false
			$Buttons/Note3/ArrowYellow.visible = true

func _on_play_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			play()

func _on_ok_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			if(selected != null):
				guess(guesses[selected])

func _on_back_click(_viewport, event, _shape_idx):
	if(settings.mode == 1):
		if event is InputEventMouseButton and event.pressed:
			Input.vibrate_handheld(settings.vibration)
		if event is InputEventMouseButton and !event.pressed:
			Input.vibrate_handheld(settings.vibration)
			get_tree().change_scene_to_file("res://scenes/main.tscn")
