extends Node


var game_manager: GameManager
var combat_manager: CombatManager

var card_library: Array[CardData] = []
var enemy_library: Array[EnemyData] = []


func _ready() -> void:
	# 纯代码实例化管理器，替代 Autoload。
	game_manager = GameManager.new()
	add_child(game_manager)
	game_manager.setup_new_run()

	combat_manager = CombatManager.new()
	add_child(combat_manager)
	combat_manager.setup(game_manager)

	_build_runtime_data()

	# 使用代码动态生成的敌人数据启动战斗。
	if enemy_library.is_empty():
		push_error("No enemy data available to start combat.")
		return

	combat_manager.start_combat(enemy_library[0])


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
