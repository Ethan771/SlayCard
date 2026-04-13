extends Resource
class_name CardData


enum CardType {
	ATTACK,
	SKILL,
	POWER,
}


var id: String = ""
var card_name: String = ""
var cost: int = 0
var type: CardType = CardType.ATTACK
var description: String = ""
var damage: int = 0
var block: int = 0
var icon: Texture2D


func _init(
	new_id: String = "",
	new_card_name: String = "",
	new_cost: int = 0,
	new_type: CardType = CardType.ATTACK,
	new_description: String = "",
	new_damage: int = 0,
	new_block: int = 0,
	new_icon: Texture2D = null
) -> void:
	id = new_id
	card_name = new_card_name
	cost = new_cost
	type = new_type
	description = new_description
	damage = new_damage
	block = new_block
	icon = new_icon
