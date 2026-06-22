extends SceneTree


const MAIN_SCENE = preload("res://main.tscn")


var failed := false


func _initialize():
	var main = MAIN_SCENE.instantiate()

	root.add_child(main)

	# The script runner does not enter the normal game loop before this test runs,
	# so the scene is initialized explicitly before changing level state.
	main._ready()
	main.current_level = 0
	main.start_new_game()

	var level_zero_button = main.level_buttons[0]
	var level_one_button = main.level_buttons[1]

	_assert_level_button_rule(
		_has_active_outline(level_zero_button),
		"The current level button should have a light outline."
	)

	_assert_level_button_rule(
		_get_active_outline_color(level_zero_button) == Color8(244, 214, 166),
		"The current level outline should use the light floor highlight color."
	)

	_assert_level_button_rule(
		not _has_active_outline(level_one_button),
		"Inactive level buttons should not have a light outline."
	)

	main.current_level = 1
	main.start_new_game()

	_assert_level_button_rule(
		not _has_active_outline(level_zero_button),
		"The previous level button should lose the light outline after switching levels."
	)

	_assert_level_button_rule(
		_has_active_outline(level_one_button),
		"The newly selected level button should have a light outline."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _has_active_outline(button: Node) -> bool:
	if button == null:
		return false

	return button.get_node_or_null("ActiveLevelOutline") != null


func _get_active_outline_color(button: Node) -> Color:
	var outline = button.get_node_or_null("ActiveLevelOutline")

	if outline == null:
		return Color.TRANSPARENT

	return outline.default_color


func _assert_level_button_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
