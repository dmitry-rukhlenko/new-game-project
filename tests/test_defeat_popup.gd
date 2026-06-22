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

	main.player.position = _find_empty_level_zero_position(main)
	main.moves = 0
	main.finish_turn()

	var popup = main.get("defeat_popup")
	var label = main.get("defeat_label")
	var retry_button = main.get("defeat_retry_button")
	var retry_label = main.get("defeat_retry_label")

	_assert_defeat_popup_rule(
		main.game_over,
		"Missing the only level 0 move should stop the game."
	)

	_assert_defeat_popup_rule(
		popup != null and popup.visible,
		"Missing the only level 0 move should show the defeat popup."
	)

	_assert_defeat_popup_rule(
		label != null and label.text == "Поражение",
		"The defeat popup should show the text 'Поражение'."
	)

	_assert_defeat_popup_rule(
		retry_button != null,
		"The defeat popup should contain a retry button."
	)

	_assert_defeat_popup_rule(
		retry_label != null and retry_label.text == "Играть снова",
		"The retry button should show the text 'Играть снова'."
	)

	if retry_button != null:
		main.handle_defeat_retry_click(retry_button.position)

	_assert_defeat_popup_rule(
		not main.game_over,
		"Clicking the retry button should restart the level."
	)

	_assert_defeat_popup_rule(
		popup != null and not popup.visible,
		"Clicking the retry button should hide the defeat popup."
	)

	_assert_defeat_popup_rule(
		main.moves == 1,
		"Restarting level 0 from the defeat popup should restore one move."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _find_empty_level_zero_position(main) -> Vector2:
	for x in range(main.COLS):
		for y in range(main.ROWS):
			var position = Vector2(
				main.LEFT_BORDER + x * main.CELL + main.CELL / 2,
				main.TOP_BORDER + y * main.CELL + main.CELL / 2
			)

			if not main.overlap_cell(position, main.enemies[0].position):
				return position

	return Vector2(
		main.LEFT_BORDER,
		main.TOP_BORDER
	)


func _assert_defeat_popup_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
