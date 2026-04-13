extends Control
class_name CardUI


signal card_played(card: CardData)


var card_data: CardData

@onready var name_label: Label = get_node_or_null("NameLabel") as Label
@onready var cost_label: Label = get_node_or_null("CostLabel") as Label
@onready var description_label: Label = get_node_or_null("DescriptionLabel") as Label

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	# 记录初始位置，拖拽结束后用于复位。
	original_position = position


func set_card_data(new_data: CardData) -> void:
	card_data = new_data

	# 未来由设计师在场景中挂好 NameLabel / CostLabel / DescriptionLabel 节点。
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


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.pressed:
		# 开始拖拽时记录偏移，保证卡牌不会在鼠标下瞬移。
		is_dragging = true
		drag_offset = global_position - get_global_mouse_position()
		original_position = position
	else:
		if not is_dragging:
			return

		is_dragging = false

		# 松开鼠标时通知外部：这张卡被打出。
		if card_data != null:
			emit_signal("card_played", card_data)

		# 当前阶段先做简单复位，后续可替换为飞向目标区或销毁动画。
		position = original_position


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if not is_dragging:
		return

	# 拖拽中让卡牌跟随鼠标。
	global_position = get_global_mouse_position() + drag_offset
