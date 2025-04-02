extends Node

# Save System - Handles saving and loading game data

signal game_saved(success)
signal game_loaded(success)

# Save file paths
const SAVE_FILE_PATH = "user://savegame.json"
const SETTINGS_FILE_PATH = "user://settings.json"

# Default settings
var default_settings = {
    "sound_volume": 0.8,
    "music_volume": 0.6,
    "fullscreen": false,
    "screen_shake": true,
    "battle_animations": true,
    "text_speed": 1.0
}

# Current settings
var current_settings = {}

func _ready():
    # Load settings on startup
    load_settings()

# Save the current game state
func save_game():
    var game_manager = $"/root/GameManager"
    if not game_manager:
        emit_signal("game_saved", false)
        return false
    
    # Collect game data
    var save_data = {
        "player_name": game_manager.player_name,
        "player_creatures": [],
        "player_items": game_manager.player_items,
        "player_badges": game_manager.player_badges,
        "current_map": game_manager.current_map,
        "visited_locations": game_manager.visited_locations,
        "completed_events": game_manager.completed_events,
        "timestamp": OS.get_unix_time(),
        "playtime": game_manager.get("playtime", 0),
        "version": "0.1.0"
    }
    
    # Save creature data (convert to serializable format)
    for creature in game_manager.player_creatures:
        var creature_data = {
            "id": creature.id,
            "name": creature.name,
            "type": creature.type,
            "level": creature.level,
            "experience": creature.experience,
            "stats": creature.stats,
            "current_hp": creature.current_hp,
            "status_effect": creature.status_effect,
            "moves": creature.moves
        }
        save_data.player_creatures.append(creature_data)
    
    # Get score from ScoreSystem
    var score_system = $"/root/ScoreSystem"
    if score_system:
        save_data["player_score"] = score_system.current_score
        save_data["score_history"] = score_system.score_history
    else:
        save_data["player_score"] = game_manager.player_score
    
    # Save to file
    var file = File.new()
    var error = file.open(SAVE_FILE_PATH, File.WRITE)
    
    if error != OK:
        push_error("Failed to open save file for writing: " + str(error))
        emit_signal("game_saved", false)
        return false
    
    file.store_string(JSON.print(save_data, "  "))
    file.close()
    
    print("Game saved successfully!")
    emit_signal("game_saved", true)
    return true

# Load a saved game
func load_game():
    var file = File.new()
    if not file.file_exists(SAVE_FILE_PATH):
        push_error("No save file found!")
        emit_signal("game_loaded", false)
        return false
    
    var error = file.open(SAVE_FILE_PATH, File.READ)
    if error != OK:
        push_error("Failed to open save file for reading: " + str(error))
        emit_signal("game_loaded", false)
        return false
    
    var text = file.get_as_text()
    file.close()
    
    var save_data = parse_json(text)
    if save_data == null:
        push_error("Failed to parse save data!")
        emit_signal("game_loaded", false)
        return false
    
    # Get GameManager
    var game_manager = $"/root/GameManager"
    if not game_manager:
        push_error("GameManager not found!")
        emit_signal("game_loaded", false)
        return false
    
    # Load the saved data into GameManager
    game_manager.player_name = save_data.player_name
    game_manager.player_items = save_data.player_items
    game_manager.player_badges = save_data.player_badges
    game_manager.current_map = save_data.current_map
    game_manager.visited_locations = save_data.visited_locations
    game_manager.completed_events = save_data.completed_events
    
    # Load creatures (convert from serialized format)
    game_manager.player_creatures = []
    for creature_data in save_data.player_creatures:
        # Create creature instance
        var creature = load("res://scripts/Creature.gd").new()
        
        # Set properties
        creature.id = creature_data.id
        creature.name = creature_data.name
        creature.type = creature_data.type
        creature.level = creature_data.level
        creature.experience = creature_data.experience
        creature.stats = creature_data.stats
        creature.current_hp = creature_data.current_hp
        creature.status_effect = creature_data.status_effect
        creature.moves = creature_data.moves
        
        game_manager.player_creatures.append(creature)
    
    # Load score data
    var score_system = $"/root/ScoreSystem"
    if score_system and save_data.has("player_score"):
        score_system.current_score = save_data.player_score
        if save_data.has("score_history"):
            score_system.score_history = save_data.score_history
    else:
        game_manager.player_score = save_data.player_score
    
    print("Game loaded successfully!")
    emit_signal("game_loaded", true)
    return true

# Save game settings
func save_settings():
    var file = File.new()
    var error = file.open(SETTINGS_FILE_PATH, File.WRITE)
    
    if error != OK:
        push_error("Failed to open settings file for writing: " + str(error))
        return false
    
    file.store_string(JSON.print(current_settings, "  "))
    file.close()
    
    print("Settings saved successfully!")
    return true

# Load game settings
func load_settings():
    # Start with default settings
    current_settings = default_settings.duplicate()
    
    var file = File.new()
    if not file.file_exists(SETTINGS_FILE_PATH):
        # No settings file, use defaults
        save_settings()  # Create settings file with defaults
        return true
    
    var error = file.open(SETTINGS_FILE_PATH, File.READ)
    if error != OK:
        push_error("Failed to open settings file for reading: " + str(error))
        return false
    
    var text = file.get_as_text()
    file.close()
    
    var settings_data = parse_json(text)
    if settings_data == null:
        push_error("Failed to parse settings data!")
        return false
    
    # Update current settings with loaded values
    for key in settings_data.keys():
        current_settings[key] = settings_data[key]
    
    print("Settings loaded successfully!")
    apply_settings()
    return true

# Apply current settings to the game
func apply_settings():
    # Apply sound settings
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(current_settings.sound_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(current_settings.music_volume))
    
    # Apply display settings
    OS.window_fullscreen = current_settings.fullscreen
    
    # Other settings would be accessed by relevant systems as needed
    return true

# Update a specific setting
func update_setting(key, value):
    if not current_settings.has(key):
        push_error("Invalid setting key: " + key)
        return false
    
    current_settings[key] = value
    save_settings()
    apply_settings()
    return true

# Get a specific setting value
func get_setting(key, default=null):
    if current_settings.has(key):
        return current_settings[key]
    return default

# Delete save file (for starting a new game)
func delete_save():
    var dir = Directory.new()
    if dir.file_exists(SAVE_FILE_PATH):
        var error = dir.remove(SAVE_FILE_PATH)
        if error != OK:
            push_error("Failed to delete save file: " + str(error))
            return false
        print("Save file deleted successfully!")
        return true
    return false  # No save file to delete

# Check if a save file exists
func has_save_file():
    var file = File.new()
    return file.file_exists(SAVE_FILE_PATH)

# Get save file info without loading the full game
func get_save_info():
    if not has_save_file():
        return null
    
    var file = File.new()
    var error = file.open(SAVE_FILE_PATH, File.READ)
    if error != OK:
        return null
    
    var text = file.get_as_text()
    file.close()
    
    var save_data = parse_json(text)
    if save_data == null:
        return null
    
    # Return just the basic info
    return {
        "player_name": save_data.player_name,
        "timestamp": save_data.get("timestamp", 0),
        "playtime": save_data.get("playtime", 0),
        "creature_count": save_data.player_creatures.size(),
        "highest_level": get_highest_level(save_data.player_creatures),
        "score": save_data.get("player_score", 0)
    }

# Helper function to get highest creature level
func get_highest_level(creatures):
    var highest = 1
    for creature in creatures:
        if creature.level > highest:
            highest = creature.level
    return highest