extends Control
class_name CardUI


signal card_played(card: CardData, ui_node: Control)


var card_data: CardData

var background: ColorRect
var name_label: Label
var cost_label: Label
var description_label: Label

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO
var base_z_index: int = 0


func _ready() -> void:
	# 纯代码创建卡牌 UI 子节点，不依赖任何预制场景。
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(220.0, 320.0)
	size = custom_minimum_size
	original_position = position
	base_z_index = z_index

	_build_visual_nodes()
	_apply_card_data()


func set_card_data(new_data: CardData) -> void:
	card_data = new_data
	_apply_card_data()


func _apply_card_data() -> void:
	if card_data == null:
		return

	if name_label != null:
		name_label.text = card_data.card_name
	if cost_label != null:
		cost_label.text = str(card_data.cost)
	if description_label != null:
		description_label.text = card_data.description


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)


func _build_visual_nodes() -> void:
	background = ColorRect.new()
	background.color = Color(0.12, 0.12, 0.12, 0.95)
	background.position = Vector2.ZERO
	background.size = size
	add_child(background)

	name_label = Label.new()
	name_label.text = "Card Name"
	name_label.position = Vector2(12.0, 10.0)
	name_label.size = Vector2(size.x - 24.0, 28.0)
	add_child(name_label)

	cost_label = Label.new()
	cost_label.text = "0"
	cost_label.position = Vector2(size.x - 40.0, 10.0)
	cost_label.size = Vector2(28.0, 28.0)
	add_child(cost_label)

	description_label = Label.new()
	description_label.text = "Card Description"
	description_label.position = Vector2(12.0, 56.0)
	description_label.size = Vector2(size.x - 24.0, size.y - 68.0)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(description_label)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.pressed:
		# 开始拖拽时记录偏移，避免卡牌瞬移。
		is_dragging = true
		drag_offset = global_position - get_global_mouse_position()
		original_position = position
		base_z_index = z_index
		z_index = 100
	else:
		if not is_dragging:
			return

		is_dragging = false
		z_index = base_z_index

		# 上半屏视为尝试打牌，否则回弹到原位。
		if global_position.y < 300.0 and card_data != null:
			emit_signal("card_played", card_data, self)
		else:
			reset_to_original_position()


func reset_to_original_position() -> void:
	position = original_position
	z_index = base_z_index


func _handle_mouse_motion(_event: InputEventMouseMotion) -> void:
	if not is_dragging:
		return

	# 拖拽中让卡牌跟随鼠标。
	global_position = get_global_mouse_position() + drag_offset
