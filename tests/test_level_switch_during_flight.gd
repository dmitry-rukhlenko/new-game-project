extends SceneTree


const MAIN_SCENE = preload("res://main.tscn")


var failed := false


func _initialize():
	var main = MAIN_SCENE.instantiate()

	root.add_child(main)

	# The script runner does not enter the normal game loop before this test runs,
	# so the scene is initialized explicitly before we simulate a moving character.
	main._ready()

	main.current_level = main.LEVEL_0
	main.start_new_game()

	var generation_before_switch = main.get("map_generation_id")

	# A non-zero velocity means the current character is flying. Level switching
	# must still be accepted in this state, exactly like character switching.
	main.velocity = Vector2(7.0, 0.0)

	var level_one_button = main.level_buttons[1]

	var handled = main.handle_level_button_click(level_one_button.position)

	_assert_switch_rule(
		handled,
		"The level button click should be handled while the character is flying."
	)

	_assert_switch_rule(
		main.current_level == main.LEVEL_1,
		"Clicking the second level button should select LEVEL_1."
	)

	_assert_switch_rule(
		main.velocity == Vector2.ZERO,
		"Switching levels during flight should reset the old movement."
	)

	_assert_switch_rule(
		main.get("map_generation_id") > generation_before_switch,
		"Switching levels during flight should redraw the level."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _assert_switch_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
