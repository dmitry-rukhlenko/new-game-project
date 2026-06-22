extends SceneTree


const MAIN_SCENE = preload("res://main.tscn")


var failed := false


func _initialize():
	var main = MAIN_SCENE.instantiate()

	root.add_child(main)

	# The script runner does not enter the normal game loop before this test runs,
	# so the scene is initialized explicitly before we simulate mouse dragging.
	main._ready()

	main.current_character = main.PLAYER_1
	main.setup_character()
	main.start_new_game()

	var start_position = main.player.position

	main.dragging = true
	main.drag_start = start_position
	main.drag_launch_position = start_position
	main.mouse_pos = start_position + Vector2(120, 12)
	main.update_dragged_player_position()

	_assert_drag_rule(
		main.player.position.x == main.mouse_pos.x,
		"Horizontal mouse dragging should move a regular character while the cursor stays near the character center."
	)

	_assert_drag_rule(
		main.player.position.y == start_position.y,
		"Mouse dragging should not move the character vertically; vertical movement is slingshot pull."
	)

	var repositioned_x = main.player.position.x

	main.mouse_pos = start_position + Vector2(180, 80)
	main.update_dragged_player_position()

	_assert_drag_rule(
		main.player.position.x == repositioned_x,
		"Horizontal mouse dragging should stop moving the character when the cursor leaves the vertical drag zone."
	)

	main.current_character = main.PLAYER_8
	main.setup_character()
	main.start_new_game()

	var sparrow_position = main.player.position

	main.dragging = true
	main.drag_start = sparrow_position
	main.drag_launch_position = sparrow_position
	main.mouse_pos = sparrow_position + Vector2(120, 12)
	main.update_dragged_player_position()

	_assert_drag_rule(
		main.player.position == sparrow_position,
		"The sparrow should not move horizontally by mouse drag; it only uses slingshot pull."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _assert_drag_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
