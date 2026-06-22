extends SceneTree


const MAIN_SCENE = preload("res://main.tscn")


var failed := false


func _initialize():
	var main = MAIN_SCENE.instantiate()

	root.add_child(main)

	# The script runner does not enter the normal game loop before this test runs,
	# so the scene is initialized explicitly before changing level state.
	main._ready()
	main.current_level = main.LEVEL_3
	main.start_new_game()

	for enemy in main.enemies:
		if enemy != null:
			enemy.queue_free()

	main.enemies.clear()

	if main.enemy2 != null:
		main.enemy2.queue_free()

	main.enemy2 = null
	main.enemy2_alive = false
	main.moves = 0

	main.finish_turn()

	var victory_popup = main.get("victory_popup")
	var defeat_popup = main.get("defeat_popup")

	_assert_all_monsters_victory_rule(
		main.game_over,
		"Finishing a turn with all monsters defeated should stop the game."
	)

	_assert_all_monsters_victory_rule(
		victory_popup != null and victory_popup.visible,
		"Finishing a turn with all monsters defeated should show victory even with no moves left."
	)

	_assert_all_monsters_victory_rule(
		defeat_popup == null or not defeat_popup.visible,
		"Finishing a turn with all monsters defeated should not show defeat."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _assert_all_monsters_victory_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
