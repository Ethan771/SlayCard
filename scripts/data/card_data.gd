extends Resource
class_name CardData


enum CardType {
	ATTACK,
	SKILL,
	POWER,
}


@export var id: String = ""
@export var card_name: String = ""
@export var cost: int = 0
@export var type: CardType = CardType.ATTACK
@export_multiline var description: String = ""
@export var damage: int = 0
@export var block: int = 0
@export var icon: Texture2D
