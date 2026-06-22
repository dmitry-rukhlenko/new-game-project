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

	# Level 0 is a tiny manual test level: it should contain only one monster.
	_assert_level_zero_rule(
		main.enemies.size() == 1,
		"Level 0 should spawn exactly one monster."
	)

	_assert_level_zero_rule(
		main.walls.size() == 0,
		"Level 0 should not spawn walls."
	)

	_assert_level_zero_rule(
		main.traps.size() == 0,
		"Level 0 should not spawn traps."
	)

	_assert_level_zero_rule(
		main.stars.size() == 0,
		"Level 0 should not spawn stars."
	)

	_assert_level_zero_rule(
		main.enemy2 == null,
		"Level 0 should not spawn the special level 3 monster."
	)

	_assert_level_zero_rule(
		main.moves == 1,
		"Level 0 should start with exactly one move."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _assert_level_zero_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
