extends CenterContainer

# So, about this editor. Width and height don't have default values, so they use NAN and
# use NumberEdit, rather than NumberField. Viewbox is a list and it also doesn't have a
# default value, so it uses 4 NumberEdits.

const NumberEditType = preload("res://src/ui_elements/number_edit.gd")

@onready var width_button: Button = %Size/Width/WidthButton
@onready var height_button: Button = %Size/Height/HeightButton
@onready var viewbox_button: Button = %Viewbox/ViewboxButton
@onready var width_edit: NumberEditType = %Size/Width/WidthEdit
@onready var height_edit: NumberEditType = %Size/Height/HeightEdit
@onready var viewbox_edit_x: NumberEditType = %Viewbox/Rect/ViewboxEditX
@onready var viewbox_edit_y: NumberEditType = %Viewbox/Rect/ViewboxEditY
@onready var viewbox_edit_w: NumberEditType = %Viewbox/Rect/ViewboxEditW
@onready var viewbox_edit_h: NumberEditType = %Viewbox/Rect/ViewboxEditH

func _ready() -> void:
	SVG.root_tag.resized.connect(update_attributes)
	SVG.root_tag.changed_unknown.connect(update_attributes)
	update_attributes()


func update_attributes() -> void:
	width_edit.set_value(SVG.root_tag.width, false)
	height_edit.set_value(SVG.root_tag.height, false)
	viewbox_edit_x.set_value(SVG.root_tag.viewbox.position.x, false)
	viewbox_edit_y.set_value(SVG.root_tag.viewbox.position.y, false)
	viewbox_edit_w.set_value(SVG.root_tag.viewbox.size.x, false)
	viewbox_edit_h.set_value(SVG.root_tag.viewbox.size.y, false)
	update_editable()


func update_editable() -> void:
	var is_width_valid: bool = !SVG.root_tag.attributes.width.get_value().is_empty()
	var is_height_valid: bool = !SVG.root_tag.attributes.height.get_value().is_empty()
	var is_viewbox_valid: bool = SVG.root_tag.attributes.viewBox.get_list_size() >= 4
	
	width_button.set_pressed_no_signal(is_width_valid)
	height_button.set_pressed_no_signal(is_height_valid)
	viewbox_button.set_pressed_no_signal(is_viewbox_valid)
	
	width_edit.editable = is_width_valid
	height_edit.editable = is_height_valid
	viewbox_edit_x.editable = is_viewbox_valid
	viewbox_edit_y.editable = is_viewbox_valid
	viewbox_edit_w.editable = is_viewbox_valid
	viewbox_edit_h.editable = is_viewbox_valid


func _on_width_edit_value_changed(new_value: float) -> void:
	if is_finite(new_value) and SVG.root_tag.attributes.width.get_num() != new_value:
		SVG.root_tag.width = new_value
		SVG.root_tag.attributes.width.set_num(new_value)
	else:
		SVG.root_tag.attributes.width.set_num(SVG.root_tag.width, false)

func _on_height_edit_value_changed(new_value: float) -> void:
	if is_finite(new_value) and SVG.root_tag.attributes.height.get_num() != new_value:
		SVG.root_tag.height = new_value
		SVG.root_tag.attributes.height.set_num(new_value)
	else:
		SVG.root_tag.attributes.height.set_num(SVG.root_tag.height, false)

func _on_viewbox_edit_x_value_changed(new_value: float) -> void:
	if SVG.root_tag.attributes.viewBox.get_value() != null:
		SVG.root_tag.viewbox.position.x = new_value
		SVG.root_tag.attributes.viewBox.set_list_element(0, new_value)

func _on_viewbox_edit_y_value_changed(new_value: float) -> void:
	if SVG.root_tag.attributes.viewBox.get_value() != null:
		SVG.root_tag.viewbox.position.y = new_value
		SVG.root_tag.attributes.viewBox.set_list_element(1, new_value)

func _on_viewbox_edit_w_value_changed(new_value: float) -> void:
	if SVG.root_tag.attributes.viewBox.get_value() != null and\
	SVG.root_tag.attributes.viewBox.get_list_element(2) != new_value:
		SVG.root_tag.viewbox.size.x = new_value
		SVG.root_tag.attributes.viewBox.set_list_element(2, new_value)

func _on_viewbox_edit_h_value_changed(new_value: float) -> void:
	if SVG.root_tag.attributes.viewBox.get_value() != null and\
	SVG.root_tag.attributes.viewBox.get_list_element(3) != new_value:
		SVG.root_tag.viewbox.size.y = new_value
		SVG.root_tag.attributes.viewBox.set_list_element(3, new_value)

func _on_width_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SVG.root_tag.attributes.width.set_num(SVG.root_tag.width)
	else:
		if SVG.root_tag.attributes.viewBox.get_list_size() == 4:
			SVG.root_tag.attributes.width.set_num(NAN)
		else:
			width_button.set_pressed_no_signal(true)

func _on_height_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SVG.root_tag.attributes.height.set_num(SVG.root_tag.height)
	else:
		if SVG.root_tag.attributes.viewBox.get_list_size() == 4:
			SVG.root_tag.attributes.height.set_num(NAN)
		else:
			height_button.set_pressed_no_signal(true)

func _on_viewbox_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SVG.root_tag.attributes.viewBox.set_rect(SVG.root_tag.viewbox)
	else:
		if not SVG.root_tag.attributes.width.get_value().is_empty() and\
		not SVG.root_tag.attributes.height.get_value().is_empty():
			SVG.root_tag.attributes.viewBox.set_value("")
		else:
			viewbox_button.set_pressed_no_signal(true)
