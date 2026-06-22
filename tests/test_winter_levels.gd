extends SceneTree


const MAIN_SCENE = preload("res://main.tscn")


var failed := false


func _initialize():
	var main = MAIN_SCENE.instantiate()

	root.add_child(main)

	# The script runner does not enter the normal game loop before this test runs,
	# so the scene is initialized explicitly before changing level state.
	main._ready()

	_assert_winter_rule(
		main.level_buttons.size() == 7,
		"The level selector should include 0, 1, 2, 3, 1S, 2S, and 3S."
	)

	main.current_level = main.LEVEL_1S
	main.start_new_game()

	_assert_winter_rule(
		main.background_sprite.texture.resource_path.ends_with("background2.png"),
		"Winter levels should use the ice background."
	)

	_assert_winter_rule(
		main.enemies.size() == 6,
		"Level 1S should spawn the same number of normal enemies as level 1."
	)

	_assert_winter_rule(
		main.enemies[0].texture.resource_path.ends_with("enemy3.png"),
		"Winter normal enemies should use the blue enemy3 texture."
	)

	_assert_winter_rule(
		main.traps.size() == 4,
		"Level 1S should keep the default trap count."
	)

	_assert_winter_rule(
		main.traps[0].texture.resource_path.ends_with("trap2.png"),
		"Winter traps should use trap2."
	)

	_assert_winter_rule(
		main.walls.size() == 4,
		"Level 1S should create two two-tile wall2 rectangles."
	)

	_assert_winter_rule(
		_all_winter_walls_use_wall2(main),
		"Winter wall tiles should use wall2."
	)

	_assert_winter_rule(
		_every_wall2_tile_has_exactly_one_partner(main),
		"Each wall2 tile should touch exactly one wall2 partner."
	)

	_assert_winter_rule(
		_every_wall2_tile_has_exactly_one_partner(main),
		"Separate wall2 rectangles should not merge into larger wall blocks."
	)

	main.current_level = main.LEVEL_2S
	main.start_new_game()

	_assert_winter_rule(
		main.enemies.size() == 8,
		"Level 2S should spawn the same number of normal enemies as level 2."
	)

	_assert_winter_rule(
		main.enemies[0].texture.resource_path.ends_with("enemy3.png"),
		"Level 2S should also use enemy3 for normal enemies."
	)

	_assert_winter_rule(
		main.walls.size() == 8,
		"Level 2S should create four two-tile wall2 rectangles."
	)

	_assert_winter_rule(
		_every_wall2_tile_has_exactly_one_partner(main),
		"Level 2S wall2 tiles should also form clean two-tile rectangles."
	)

	main.current_level = main.LEVEL_3S
	main.start_new_game()

	_assert_winter_rule(
		main.enemies.size() == 7,
		"Level 3S should spawn the same number of normal enemies as level 3."
	)

	_assert_winter_rule(
		main.walls.size() == 0,
		"Level 3S should not start with any walls."
	)

	_assert_winter_rule(
		main.stars.size() == 0,
		"Level 3S should start without stars."
	)

	_assert_winter_rule(
		main.enemy2 != null,
		"Level 3S should create the special boss object."
	)

	_assert_winter_rule(
		main.enemy2.texture.resource_path.ends_with("enemy4.png"),
		"Level 3S boss should use enemy4."
	)

	var boss_cell = _cell_for_position(main, main.enemy2.position)

	_assert_winter_rule(
		boss_cell.y == 2 or boss_cell.y == 3,
		"Enemy4 should spawn on the same rows as enemy2: row 2 or row 3."
	)

	_assert_winter_rule(
		main.crystals.size() == 3,
		"Level 3S should place three crystals under the boss."
	)

	_assert_winter_rule(
		_has_boss_crystal_pattern(main, boss_cell),
		"The three crystals should sit directly below the boss, left-center-right."
	)

	_assert_winter_rule(
		main.gift != null,
		"Level 3S should place one gift."
	)

	var gift_cell = _cell_for_position(main, main.gift.position)

	_assert_winter_rule(
		gift_cell.y == 0,
		"The level 3S gift should be on the top row."
	)

	var moves_before_gift = main.moves

	main.player.position = main.gift.position
	main.collect_gift_if_needed(main.player)

	_assert_winter_rule(
		main.moves == moves_before_gift + 6,
		"Collecting the gift should add six moves."
	)

	main.start_new_game()
	main.finish_turn()

	_assert_winter_rule(
		main.walls.size() == 4,
		"After the first 3S turn, enemy4 should summon two two-tile wall2 rectangles."
	)

	_assert_winter_rule(
		_every_wall2_tile_has_exactly_one_partner(main),
		"Summoned 3S wall2 tiles should also form clean two-tile rectangles."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _all_winter_walls_use_wall2(main) -> bool:
	for wall in main.walls:
		if wall == null:
			return false

		if not wall.texture.resource_path.ends_with("wall2.png"):
			return false

	return true


func _every_wall2_tile_has_exactly_one_partner(main) -> bool:
	for wall in main.walls:
		var touches = 0

		var cell = _cell_for_position(main, wall.position)

		for other in main.walls:
			if other == wall:
				continue

			var other_cell = _cell_for_position(main, other.position)

			var grid_distance = abs(cell.x - other_cell.x) + abs(cell.y - other_cell.y)

			if grid_distance == 1:
				touches += 1

		if touches != 1:
			return false

	return true


func _has_boss_crystal_pattern(main, boss_cell: Vector2i) -> bool:
	var expected = [
		Vector2i(boss_cell.x - 1, boss_cell.y + 1),
		Vector2i(boss_cell.x, boss_cell.y + 1),
		Vector2i(boss_cell.x + 1, boss_cell.y + 1)
	]

	for expected_cell in expected:
		var found = false

		for crystal in main.crystals:
			if _cell_for_position(main, crystal.position) == expected_cell:
				found = true

		if not found:
			return false

	return true


func _cell_for_position(main, position: Vector2) -> Vector2i:
	return Vector2i(
		int((position.x - main.LEFT_BORDER) / main.CELL),
		int((position.y - main.TOP_BORDER) / main.CELL)
	)


func _assert_winter_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
