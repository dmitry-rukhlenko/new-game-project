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

	main.player.position = main.enemies[0].position
	main.finish_turn()

	var popup = main.get("victory_popup")
	var label = main.get("victory_label")
	var retry_button = main.get("victory_retry_button")
	var retry_label = main.get("victory_retry_label")
	var next_button = main.get("victory_next_button")
	var next_label = main.get("victory_next_label")
	var victory_audio_player = main.get("victory_audio_player")

	_assert_victory_popup_rule(
		main.game_over,
		"Winning level 0 should stop the game."
	)

	_assert_victory_popup_rule(
		popup != null,
		"Winning a level should create a victory popup."
	)

	_assert_victory_popup_rule(
		popup != null and popup.visible,
		"The victory popup should be visible after the level is completed."
	)

	_assert_victory_popup_rule(
		label != null and label.text == "Победа",
		"The victory popup should show the text 'Победа'."
	)

	_assert_victory_popup_rule(
		victory_audio_player != null,
		"Winning a level should create a victory audio player."
	)

	_assert_victory_popup_rule(
		victory_audio_player != null and victory_audio_player.stream != null,
		"The victory audio player should load the copied victory sound."
	)

	_assert_victory_popup_rule(
		main.get("victory_sound_requested"),
		"The victory sound should be requested when the victory popup opens."
	)

	_assert_victory_popup_rule(
		retry_button != null,
		"The victory popup should contain a retry button."
	)

	_assert_victory_popup_rule(
		retry_label != null and retry_label.text == "Играть снова",
		"The victory retry button should show the text 'Играть снова'."
	)

	_assert_victory_popup_rule(
		next_button != null,
		"The victory popup should contain a next-level button."
	)

	_assert_victory_popup_rule(
		next_label != null and next_label.text == "Следующий уровень",
		"The next-level button should show the text 'Следующий уровень'."
	)

	var level_field_bottom = main.TOP_BORDER + main.ROWS * main.CELL

	_assert_victory_popup_rule(
		retry_button != null and retry_button.position.y > level_field_bottom,
		"The victory retry button should be below the tile field."
	)

	_assert_victory_popup_rule(
		next_button != null and next_button.position.y > level_field_bottom,
		"The next-level button should be below the tile field."
	)

	var generation_before_retry = main.get("map_generation_id")

	if retry_button != null:
		main.handle_victory_retry_click(retry_button.position)

	_assert_victory_popup_rule(
		main.current_level == 0,
		"Clicking the victory retry button should keep the current level."
	)

	_assert_victory_popup_rule(
		not main.game_over,
		"Clicking the victory retry button should restart the level."
	)

	_assert_victory_popup_rule(
		main.get("map_generation_id") > generation_before_retry,
		"Clicking the victory retry button should generate a fresh map."
	)

	main.player.position = main.enemies[0].position
	main.finish_turn()

	if next_button != null:
		main.handle_victory_next_click(next_button.position)

	_assert_victory_popup_rule(
		main.current_level == 1,
		"Clicking the next-level button after level 0 should switch to level 1."
	)

	_assert_victory_popup_rule(
		not main.game_over,
		"Clicking the next-level button should start the next level."
	)

	main.queue_free()
	quit(1 if failed else 0)


func _assert_victory_popup_rule(condition: bool, message: String):
	if condition:
		return

	failed = true
	push_error(message)
