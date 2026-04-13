extends Node
class_name GameManager


var player_max_health: int = 80
var player_current_health: int = 80
var gold: int = 99

var deck: Array[CardData] = []


func _ready() -> void:
	player_max_health = 80
	player_current_health = 80
	gold = 99
