# Represents an attribute inside a tag, i.e. <tag attribute="value"/>.
# If the Attribute's data type is known, one of the inheriting classes should be used.
class_name Attribute extends RefCounted

signal value_changed(new_value: String)
signal propagate_value_changed(undo_redo: bool)

var name: String
var _value: String

enum SyncMode {LOUD, INTERMEDIATE, FINAL, NO_PROPAGATION, SILENT}

# LOUD means the attribute will emit value_changed and be noticed everywhere.

# INTERMEDIATE is the same as LOUD, but doesn't create an UndoRedo action.
# Can be used to update an attribute continuously (i.e. dragging a color).

# FINAL is the same as LOUD, but it runs even if the new value is the same.
# This can be used to force an UndoRedo action after some intermediate changes.
# Note that the attribute is not responsible for making sure the new value is
# different from the previous one in the UndoRedo, this must be handled in the widgets.

# NO_PROPAGATION means the tag won't learn about it. This can allow the attribute change
# to be noted by an attribute editor without the SVG text being updated.
# This can be used, for example, to update two attributes corresponding to 2D coordinates
# without the first one causing an update to the SVG text.

# SILENT means the attribute update is ignored fully. It only makes sense
# if there is logic for updating the corresponding attribute editor despite that.

func set_value(new_value: String, sync_mode := SyncMode.LOUD) -> void:
	var proposed_new_value := format(new_value)
	if proposed_new_value != _value or sync_mode == SyncMode.FINAL:
		_value = proposed_new_value
		_sync()
		if sync_mode != SyncMode.SILENT:
			value_changed.emit(proposed_new_value)
			if sync_mode != SyncMode.NO_PROPAGATION:
				propagate_value_changed.emit(sync_mode != SyncMode.INTERMEDIATE)

func get_value() -> String:
	return _value

# Override these functions in extending classes to update the non-string representation.
func _sync() -> void:
	return

func format(text: String) -> String:
	return text

func get_default() -> String:
	if name in DB.attribute_defaults:
		return DB.attribute_defaults[name]
	else:
		return ""

func _init(new_name: String, init_value := "") -> void:
	name = new_name
	set_value(init_value, SyncMode.FINAL)
