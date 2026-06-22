extends SceneTree


const MAIN_SCENE = preload("res://main.tscn")


var failed := false


func _initialize():
	var main = MAIN_SCENE.instantiate()

	root.add_child(main)

	# The script runner does not enter the normal game loop before this test runs,
	# so the scene is initialized explicitly before changing character state.
	main._ready()
	main.current_character = main.PLAYER_10
	main.setup_character()
	main.start_new_game()

	_assert_snail_rule(
		main.player.texture.resource_path.ends_with("player10.png"),
		"The snail should use player10.png."
	)

	_assert_snail_rule(
		main.snail_trail_cells.is_empty(),
		"The snail should start without a trail."
	)

	main.velocity = Vector2(0.0, -8.0)
	main.player.position = Vector2(
		main.PLAYER_START_X,
		main.PLAYER_START_Y - main.CELL
	)
	main.record_snail_trail_from_first_launch()

	_assert_snail_rule(
		not main.snail_trail_cells.is_empty(),
		"The first snail launch should create trail cells."
	)

	var trail_size_after_first_launch = main.snail_trail_cells.size()
	var first_trail_cell = main.snail_trail_cells[0]

	main.player.position = main.position_for_cell(first_trail_cell)
	main.move_snail_on_trail(Vector2i(1, 0))

	_assert_snail_rule(
		main.snail_trail_cells.has(main.cell_for_position(main.player.position)),
		"Arrow movement should keep the snail on the existing trail."
	)

	main.record_snail_trail_from_first_launch()

	_assert_snail_rule(
		main.snail_trail_cells.size() == trail_size_after_first_launch,
		"The snail should not expand its trail after the first launch."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _assert_snail_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
