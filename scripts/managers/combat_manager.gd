extends Node
class_name CombatManager


signal energy_changed(current_energy: int, max_energy: int)
signal hand_updated(current_hand: Array[CardData])
signal enemy_health_changed(current_health: int, max_health: int)
signal player_health_changed(current_health: int, max_health: int)


enum CombatState {
	STARTING,
	PLAYER_TURN,
	ENEMY_TURN,
	WON,
	LOST,
}


var current_state: CombatState = CombatState.STARTING
var current_enemy: EnemyData
var enemy_current_health: int = 0

var draw_pile: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []

var current_energy: int = 0
var max_energy: int = 3

var current_block: int = 0


func start_combat(enemy: EnemyData) -> void:
	current_state = CombatState.STARTING
	current_enemy = enemy
	enemy_current_health = current_enemy.max_health

	draw_pile = GameManager.deck.duplicate()
	draw_pile.shuffle()
	hand.clear()
	discard_pile.clear()
	current_block = 0

	_start_player_turn()
	emit_signal("enemy_health_changed", enemy_current_health, current_enemy.max_health)


func draw_cards(amount: int) -> void:
	if amount <= 0:
		return

	for _i in range(amount):
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			draw_pile.append_array(discard_pile)
			discard_pile.clear()
			draw_pile.shuffle()

		if draw_pile.is_empty():
			break

		var drawn_card: CardData = draw_pile.pop_back()
		hand.append(drawn_card)

	emit_signal("hand_updated", hand)


func play_card(card: CardData) -> void:
	if current_state != CombatState.PLAYER_TURN:
		return
	if not hand.has(card):
		return
	if card.cost > current_energy:
		return

	current_energy -= card.cost
	emit_signal("energy_changed", current_energy, max_energy)

	match card.type:
		CardData.CardType.ATTACK:
			enemy_current_health = maxi(0, enemy_current_health - card.damage)
			emit_signal("enemy_health_changed", enemy_current_health, current_enemy.max_health)
		CardData.CardType.SKILL:
			current_block += card.block
		CardData.CardType.POWER:
			pass

	hand.erase(card)
	discard_pile.append(card)
	emit_signal("hand_updated", hand)

	if enemy_current_health <= 0:
		current_state = CombatState.WON


func end_player_turn() -> void:
	if current_state != CombatState.PLAYER_TURN:
		return

	current_state = CombatState.ENEMY_TURN
	_resolve_enemy_turn()

	if current_state == CombatState.LOST or current_state == CombatState.WON:
		return

	for card: CardData in hand:
		discard_pile.append(card)
	hand.clear()
	emit_signal("hand_updated", hand)

	_start_player_turn()


func _start_player_turn() -> void:
	current_state = CombatState.PLAYER_TURN
	current_energy = max_energy
	current_block = 0
	emit_signal("energy_changed", current_energy, max_energy)
	draw_cards(5)


func _resolve_enemy_turn() -> void:
	if current_enemy == null:
		return

	var incoming_damage: int = current_enemy.base_damage
	var mitigated_damage: int = maxi(0, incoming_damage - current_block)
	current_block = maxi(0, current_block - incoming_damage)

	GameManager.player_current_health = maxi(0, GameManager.player_current_health - mitigated_damage)
	emit_signal("player_health_changed", GameManager.player_current_health, GameManager.player_max_health)

	if GameManager.player_current_health <= 0:
		current_state = CombatState.LOST
