extends SceneTree


const MAIN_SCENE = preload("res://main.tscn")


var failed := false


func _initialize():
	var main = MAIN_SCENE.instantiate()

	root.add_child(main)

	# The script runner does not enter the normal game loop before this test runs,
	# so the scene is initialized explicitly before changing character state.
	main._ready()
	main.current_character = main.PLAYER_9
	main.setup_character()
	main.start_new_game()

	_assert_penguin_rule(
		main.character_buttons.size() == 8,
		"The character selector should include the two new characters."
	)

	_assert_penguin_rule(
		main.penguins.size() == 2,
		"Selecting the penguin character should create two penguins."
	)

	_assert_penguin_rule(
		main.penguins[0].texture.resource_path.ends_with("player9.png"),
		"Penguins should use player9.png."
	)

	var distance = abs(
		main.penguins[0].position.x -
		main.penguins[1].position.x
	)

	_assert_penguin_rule(
		distance == main.CELL * 3,
		"The two penguins should start three floor tiles apart."
	)

	var first_penguin_start_x = main.penguins[0].position.x
	var second_penguin_start_x = main.penguins[1].position.x

	Input.action_press("ui_right")
	main._process(0.1)
	Input.action_release("ui_right")

	_assert_penguin_rule(
		main.penguins[0].position.x > first_penguin_start_x,
		"The right arrow should move the first penguin before launch."
	)

	_assert_penguin_rule(
		main.penguins[1].position.x > second_penguin_start_x,
		"The right arrow should move the second penguin before launch."
	)

	_assert_penguin_rule(
		abs(main.penguins[0].position.x - main.penguins[1].position.x) == main.CELL * 3,
		"Arrow movement should keep the penguins three floor tiles apart."
	)

	main.mouse_pos = main.penguins[0].position + Vector2(-120.0, -40.0)
	main.launch_from_position(main.penguins[0].position)

	_assert_penguin_rule(
		main.penguin_velocities.size() == 2,
		"Launching penguins should track one velocity per penguin."
	)

	_assert_penguin_rule(
		main.penguin_velocities[0] == main.penguin_velocities[1],
		"Both penguins should launch with the same velocity."
	)

	main.penguin_alive[0] = false
	main.finish_turn()

	_assert_penguin_rule(
		not main.game_over,
		"Losing one penguin should not end the level while the second penguin is alive."
	)

	main.penguin_alive[1] = false
	main.moves = 1
	main.finish_turn()

	_assert_penguin_rule(
		main.game_over,
		"Losing both penguins should end the level if monsters remain."
	)

	var defeat_popup = main.get("defeat_popup")

	_assert_penguin_rule(
		defeat_popup != null and defeat_popup.visible,
		"Losing both penguins should show the defeat popup."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _assert_penguin_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
