extends Node


var game_manager: GameManager
var combat_manager: CombatManager

var card_library: Array[CardData] = []
var enemy_library: Array[EnemyData] = []

var background_rect: ColorRect
var status_label: Label
var hand_root: Control


func _ready() -> void:
	# 纯代码实例化管理器，替代 Autoload。
	game_manager = GameManager.new()
	add_child(game_manager)
	game_manager.setup_new_run()

	combat_manager = CombatManager.new()
	add_child(combat_manager)
	combat_manager.setup(game_manager)
	combat_manager.hand_updated.connect(_on_hand_updated)
	combat_manager.enemy_health_changed.connect(_on_enemy_health_changed)
	combat_manager.energy_changed.connect(_on_energy_changed)

	_build_runtime_data()
	_build_runtime_ui()

	# 使用代码动态生成的敌人数据启动战斗。
	if enemy_library.is_empty():
		push_error("No enemy data available to start combat.")
		return

	combat_manager.start_combat(enemy_library[0])
	update_ui()


func _build_runtime_data() -> void:
	card_library.clear()
	enemy_library.clear()

	var strike: CardData = CardData.new(
		"strike",
		"Strike",
		1,
		CardData.CardType.ATTACK,
		"Deal 6 damage.",
		6,
		0
	)
	card_library.append(strike)

	var defend: CardData = CardData.new(
		"defend",
		"Defend",
		1,
		CardData.CardType.SKILL,
		"Gain 5 Block.",
		0,
		5
	)
	card_library.append(defend)

	# 测试牌库：直接复制到玩家牌库中。
	game_manager.deck = [
		strike,
		defend,
		strike,
		defend,
		strike,
	]

	var slime: EnemyData = EnemyData.new(
		"green_slime",
		"Green Slime",
		30,
		6
	)
	enemy_library.append(slime)


func _build_runtime_ui() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	background_rect = ColorRect.new()
	background_rect.color = Color(0.16, 0.16, 0.18, 1.0)
	background_rect.position = Vector2.ZERO
	background_rect.size = viewport_size
	add_child(background_rect)

	status_label = Label.new()
	status_label.position = Vector2(16.0, 16.0)
	status_label.size = Vector2(viewport_size.x - 32.0, 40.0)
	status_label.text = "Preparing combat..."
	add_child(status_label)

	hand_root = Control.new()
	hand_root.position = Vector2.ZERO
	hand_root.size = viewport_size
	add_child(hand_root)


func update_ui() -> void:
	_update_status_text()
	_draw_hand()


func _draw_hand() -> void:
	if hand_root == null:
		return

	for child: Node in hand_root.get_children():
		child.queue_free()

	var card_count: int = combat_manager.hand.size()
	if card_count <= 0:
		return

	var card_width: float = 220.0
	var spacing: float = 18.0
	var total_width: float = card_count * card_width + (card_count - 1) * spacing
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var start_x: float = (viewport_size.x - total_width) * 0.5
	var y: float = viewport_size.y - 340.0

	for i in range(card_count):
		var card: CardData = combat_manager.hand[i]
		var card_node: CardUI = CardUI.new()
		card_node.position = Vector2(start_x + i * (card_width + spacing), y)
		card_node.set_card_data(card)
		card_node.card_played.connect(_on_card_played)
		hand_root.add_child(card_node)


func _update_status_text() -> void:
	if status_label == null:
		return

	if combat_manager.current_enemy == null:
		status_label.text = "No enemy"
		return

	var state_text: String = _combat_state_to_text(combat_manager.current_state)
	status_label.text = "%s | Enemy: %s HP %d/%d | Energy: %d/%d" % [
		state_text,
		combat_manager.current_enemy.enemy_name,
		combat_manager.enemy_current_health,
		combat_manager.current_enemy.max_health,
		combat_manager.current_energy,
		combat_manager.max_energy,
	]


func _combat_state_to_text(state: CombatManager.CombatState) -> String:
	match state:
		CombatManager.CombatState.STARTING:
			return "Starting"
		CombatManager.CombatState.PLAYER_TURN:
			return "Player Turn"
		CombatManager.CombatState.ENEMY_TURN:
			return "Enemy Turn"
		CombatManager.CombatState.WON:
			return "Won"
		CombatManager.CombatState.LOST:
			return "Lost"
		_:
			return "Unknown"


func _on_card_played(card: CardData) -> void:
	combat_manager.play_card(card)
	update_ui()


func _on_hand_updated(_current_hand: Array[CardData]) -> void:
	_draw_hand()


func _on_enemy_health_changed(_current_health: int, _max_health: int) -> void:
	_update_status_text()


func _on_energy_changed(_current_energy: int, _max_energy: int) -> void:
	_update_status_text()
