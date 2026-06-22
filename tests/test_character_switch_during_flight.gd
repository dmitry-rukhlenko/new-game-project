extends SceneTree


const MAIN_SCENE = preload("res://main.tscn")


var failed := false


func _initialize():
	var main = MAIN_SCENE.instantiate()

	root.add_child(main)

	# The script runner does not enter the normal game loop before this test runs,
	# so the scene is initialized explicitly before we simulate a moving character.
	main._ready()

	main.current_character = main.PLAYER_1
	main.setup_character()
	main.start_new_game()

	var generation_before_switch = main.get("map_generation_id")

	# A non-zero velocity means the old character is currently flying across the
	# level. Character switching must still be accepted in this state.
	main.velocity = Vector2(7.0, 0.0)

	var wolf_button = main.character_buttons[1]

	var handled = main.handle_character_button_click(wolf_button.position)

	_assert_switch_rule(
		handled,
		"The character button click should be handled while the character is flying."
	)

	_assert_switch_rule(
		main.current_character == main.PLAYER_2,
		"Clicking the second character button should select PLAYER_2."
	)

	_assert_switch_rule(
		main.velocity == Vector2.ZERO,
		"Switching characters during flight should reset the old movement."
	)

	_assert_switch_rule(
		main.get("map_generation_id") > generation_before_switch,
		"Switching characters during flight should redraw the level."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _assert_switch_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
