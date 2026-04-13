extends Node
class_name GameManager


var player_max_health: int = 80
var player_current_health: int = 80
var gold: int = 99

var deck: Array[CardData] = []


func _ready() -> void:
	# 纯代码模式下，默认在 _ready 时初始化一局测试状态。
	setup_new_run()


func setup_new_run() -> void:
	player_max_health = 80
	player_current_health = 80
	gold = 99
	deck.clear()
