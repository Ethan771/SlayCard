extends Resource
class_name EnemyData


var id: String = ""
var enemy_name: String = ""
var max_health: int = 1
var base_damage: int = 0
var texture: Texture2D


func _init(
	new_id: String = "",
	new_enemy_name: String = "",
	new_max_health: int = 1,
	new_base_damage: int = 0,
	new_texture: Texture2D = null
) -> void:
	id = new_id
	enemy_name = new_enemy_name
	max_health = new_max_health
	base_damage = new_base_damage
	texture = new_texture
@export var id: String = ""
@export var enemy_name: String = ""
@export var max_health: int = 1
@export var base_damage: int = 0
@export var texture: Texture2D
