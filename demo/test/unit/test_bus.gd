extends "res://addons/gut/test.gd"

class TestBus:
	extends "res://addons/gut/test.gd"
	
	var fmodEvent: FmodEvent
	var sprite: Sprite2D = Sprite2D.new()
	
	func before_all():
		# load banks
		# warning-ignore:return_value_discarded
		FmodServer.load_bank("res://assets/Banks/Master.strings.bank", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
		# warning-ignore:return_value_discarded
		FmodServer.load_bank("res://assets/Banks/Master.bank", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
		# warning-ignore:return_value_discarded
		FmodServer.load_bank("res://assets/Banks/Music.bank", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
		# warning-ignore:return_value_discarded
		FmodServer.load_bank("res://assets/Banks/Vehicles.bank", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
		FmodServer.set_listener_number(1)
		fmodEvent = FmodServer.create_event_instance("event:/Vehicles/Car Engine")
		get_tree().get_root().add_child(sprite)
		FmodServer.add_listener(0, sprite)
	
	func after_all():
		fmodEvent.release()
		FmodServer.remove_listener(0)
		FmodServer.unload_bank("res://assets/Banks/Master.strings.bank")
		FmodServer.unload_bank("res://assets/Banks/Master.bank")
		FmodServer.unload_bank("res://assets/Banks/Music.bank")
		FmodServer.unload_bank("res://assets/Banks/Vehicles.bank")
	
	func test_assert_should_has_master_bus():
		var wanted: String = "bus:/"
		assert_true(FmodServer.check_bus_path(wanted), wanted + " should be present")
	
	func test_assert_should_not_has_bus():
		var wanted: String = "undefined"
		assert_false(FmodServer.check_bus_path(wanted), wanted + " should not be present")
	
	func test_assert_mute_unmute():
		var masterBus: FmodBus = FmodServer.get_bus("bus:/")
		assert_false(masterBus.mute, "Master bus should not be muted")
		masterBus.mute = true
		assert_true(masterBus.mute, "Master bus should be muted")
		masterBus.mute = false
		assert_false(masterBus.mute, "Master bus should not be muted")
	
	func test_assert_pause_unpause():
		var masterBus: FmodBus = FmodServer.get_bus("bus:/")
		assert_false(masterBus.paused, "Master bus should not be paused")
		masterBus.paused = true
		assert_true(masterBus.paused, "Master bus should be paused")
		masterBus.paused = false
		assert_false(masterBus.paused, "Master bus should not be paused")
	
	func test_assert_volume():
		var masterBus: FmodBus = FmodServer.get_bus("bus:/")
		
		var desiredValue: float = 1.0
		assert_eq(masterBus.volume, desiredValue, "Bus volume should be " + str(desiredValue))
		desiredValue = 0.5
		masterBus.volume = desiredValue
		assert_eq(masterBus.volume, desiredValue, "Bus volume should be " + str(desiredValue))
		masterBus.volume = 1
	
	func test_assert_bus_stop_events():
		var fmodEvent2: FmodEvent = FmodServer.create_event_instance("event:/Vehicles/Car Engine")
		fmodEvent.start()
		fmodEvent2.start()
		await wait_seconds(2)
		assert_eq(fmodEvent.get_playback_state(), FmodServer.FMOD_STUDIO_PLAYBACK_PLAYING, "Event " + str(fmodEvent) + " playback state should be " + str(FmodServer.FMOD_STUDIO_PLAYBACK_PLAYING))
		assert_eq(fmodEvent2.get_playback_state(), FmodServer.FMOD_STUDIO_PLAYBACK_PLAYING, "Event " + str(fmodEvent2) + " playback state should be " + str(FmodServer.FMOD_STUDIO_PLAYBACK_PLAYING))
		FmodServer.get_bus("bus:/").stop_all_events(FmodServer.FMOD_STUDIO_STOP_IMMEDIATE)
		await wait_seconds(2)
		assert_eq(fmodEvent.get_playback_state(), FmodServer.FMOD_STUDIO_PLAYBACK_STOPPED, "Event " + str(fmodEvent) + " playback state should be " + str(FmodServer.FMOD_STUDIO_PLAYBACK_STOPPED))
		assert_eq(fmodEvent2.get_playback_state(), FmodServer.FMOD_STUDIO_PLAYBACK_STOPPED, "Event " + str(fmodEvent2) + " playback state should be " + str(FmodServer.FMOD_STUDIO_PLAYBACK_STOPPED))
		fmodEvent2.release()
