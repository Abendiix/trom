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

extends Node

@onready var vibration
@onready var vibration_hold

@onready var scoreGame1
@onready var currentGame2
@onready var recordGame2

@onready var mode

func _ready():
	vibration = 15
	vibration_hold = 6
	scoreGame1 = 0
	currentGame2 = 0
	recordGame2 = 0
	mode = 1

func set_vibration(v, v_h):
	var config = ConfigFile.new()
	config.set_value("vibration", "default", v)
	config.set_value("vibration", "hold", v_h)
	config.save("user://data_0_10.cfg")
	vibration = config.get_value("vibration", "default")
	vibration_hold = config.get_value("vibration", "hold")

func set_scoregame1(score):
	var data = ConfigFile.new()
	data.set_value("score", "game1", score)
	data.save("user://scoresgame1_0_10.cfg")
	scoreGame1 = data.get_value("score", "game1")
	
func set_scoregame2(current, record):
	var data = ConfigFile.new()
	data.set_value("score", "game2current", current)
	data.set_value("score", "game2record", record)
	data.save("user://scoresgame2_0_10.cfg")
	currentGame2 = data.get_value("score", "game2current")
	recordGame2 = data.get_value("score", "game2record")

func set_mode(m):
	var config = ConfigFile.new()
	config.set_value("mode", "mode", m)
	config.save("user://mode_0_10.cfg")
	mode = config.get_value("mode", "mode")
