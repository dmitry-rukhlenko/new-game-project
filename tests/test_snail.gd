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

	var trail_start = main.player.position

	main.velocity = Vector2(0.0, -main.CELL)
	main.turn_active = false
	main._process(1.0)

	_assert_snail_rule(
		not main.snail_trail_cells.is_empty(),
		"The snail should leave trail cells immediately while moving."
	)

	_assert_snail_rule(
		main.snail_trail_segments.size() > 0,
		"The snail should draw trail segments immediately behind its movement."
	)

	_assert_snail_rule(
		main.snail_trail_segments[0] is Line2D,
		"The snail trail should be drawn as a narrow strip, not as square cells."
	)

	_assert_snail_rule(
		main.snail_trail_segments[0].width <= 12.0,
		"The snail trail strip should stay visually narrow."
	)

	_assert_snail_rule(
		main.snail_trail_cells.has(main.cell_for_position(trail_start)),
		"The live trail should include the launch cell."
	)

	_assert_snail_rule(
		main.snail_trail_cells.has(main.cell_for_position(main.player.position)),
		"The live trail should include the current snail cell."
	)

	main.velocity = Vector2.ZERO
	main.snail_first_launch_recorded = true
	main.move_snail_on_trail(Vector2i(0, 1))

	_assert_snail_rule(
		main.cell_for_position(main.player.position) == main.cell_for_position(trail_start),
		"The down arrow should move the snail backward along the vertical trail."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _assert_snail_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
