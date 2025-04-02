extends Node

# Game states
enum GameState {EXPLORATION, BATTLE, MENU, DIALOGUE}
var current_state = GameState.EXPLORATION

# Player data
var player_name = "Trainer"
var player_creatures = []
var player_items = {}
var player_score = 0
var player_badges = []

# Game progress
var current_map = ""
var visited_locations = []
var completed_events = []

# Battle data
var current_battle = null
var wild_encounter_rate = 0.1  # 10% chance per step in tall grass

# Called when the node enters the scene tree for the first time
func _ready():
    randomize()  # Initialize random number generator
    initialize_player()

# Initialize player with starter creature
func initialize_player():
    # Add a starter creature to the player's collection
    var starter = create_creature("creature1", 5)  # Leafling at level 5
    player_creatures.append(starter)
    
    # Add some basic items
    player_items = {
        "potion": 3,
        "creature_ball": 5
    }

# Create a new creature instance from the database
func create_creature(creature_id, level):
    var data = DataLoader.get_creature(creature_id)
    if data == null:
        return null
    
    # Create a new creature instance
    var creature = {
        "id": creature_id,
        "name": data.name,
        "type": data.type,
        "level": level,
        "experience": calculate_experience_for_level(level),
        "stats": calculate_stats(data.base_stats, level),
        "current_hp": 0,  # Will be set to max HP below
        "moves": [],
        "status_effect": null
    }
    
    # Set current HP to max HP
    creature.current_hp = creature.stats.hp
    
    # Assign moves based on level
    for move_id in data.moves:
        if creature.moves.size() < 4:  # Maximum 4 moves
            var move_data = DataLoader.get_move(move_id)
            if move_data != null:
                creature.moves.append({
                    "id": move_id,
                    "name": move_data.name,
                    "type": move_data.type,
                    "pp": move_data.pp,
                    "current_pp": move_data.pp
                })
    
    return creature

# Calculate stats based on base stats and level
func calculate_stats(base_stats, level):
    var stats = {}
    
    # HP calculation (different formula)
    stats.hp = floor((2 * base_stats.hp * level) / 100) + level + 10
    
    # Other stats
    stats.attack = floor((2 * base_stats.attack * level) / 100) + 5
    stats.defense = floor((2 * base_stats.defense * level) / 100) + 5
    stats.speed = floor((2 * base_stats.speed * level) / 100) + 5
    stats.special = floor((2 * base_stats.special * level) / 100) + 5
    
    return stats

# Calculate experience needed for a given level
func calculate_experience_for_level(level):
    return int(pow(level, 3))

# Change the current game state
func change_state(new_state):
    current_state = new_state
    print("Game state changed to: " + str(new_state))
    
    # Perform state-specific initialization
    match new_state:
        GameState.EXPLORATION:
            pass  # Resume exploration
        GameState.BATTLE:
            pass  # Battle initialization happens in start_battle
        GameState.MENU:
            pass  # Menu initialization happens in open_menu
        GameState.DIALOGUE:
            pass  # Dialogue initialization happens in start_dialogue

# Start a battle with a wild creature or trainer
func start_battle(opponent_data):
    change_state(GameState.BATTLE)
    current_battle = {
        "type": "wild",  # or "trainer"
        "opponent": opponent_data,
        "player_creature": player_creatures[0],  # Active creature
        "turn": 0
    }
    
    # Here you would transition to the battle scene
    # get_tree().change_scene("res://scenes/Battle.tscn")

# Add score points
func add_score(points, reason=""):
    # Use the ScoreSystem to add score
    var score_system = $"/root/ScoreSystem"
    if score_system:
        var category = score_system.ScoreCategory.BATTLE_WIN  # Default category
        score_system.add_score(points, category, reason)
    else:
        # Fallback if ScoreSystem isn't available
        player_score += points
        print("Added " + str(points) + " points" + (": " + reason if reason else ""))
        print("Total score: " + str(player_score))

# Save game data
func save_game():
    # Use the SaveSystem to save the game
    var save_system = $"/root/SaveSystem"
    if save_system:
        return save_system.save_game()
    else:
        # Fallback to basic implementation if SaveSystem isn't available
        var save_data = {
            "player_name": player_name,
            "player_creatures": player_creatures,
            "player_items": player_items,
            "player_score": player_score,
            "player_badges": player_badges,
            "current_map": current_map,
            "visited_locations": visited_locations,
            "completed_events": completed_events
        }
        
        var file = File.new()
        file.open("user://savegame.json", File.WRITE)
        file.store_string(JSON.print(save_data, "  "))
        file.close()
        print("Game saved successfully!")
        return true

# Load game data
func load_game():
    # Use the SaveSystem to load the game
    var save_system = $"/root/SaveSystem"
    if save_system:
        return save_system.load_game()
    else:
        # Fallback to basic implementation if SaveSystem isn't available
        var file = File.new()
        if not file.file_exists("user://savegame.json"):
            print("No save file found!")
            return false
        
        file.open("user://savegame.json", File.READ)
        var text = file.get_as_text()
        file.close()
        
        var save_data = parse_json(text)
        if save_data == null:
            print("Failed to parse save data!")
            return false
        
        # Load the saved data
        player_name = save_data.player_name
        player_creatures = save_data.player_creatures
        player_items = save_data.player_items
        player_score = save_data.player_score
        player_badges = save_data.player_badges
        current_map = save_data.current_map
        visited_locations = save_data.visited_locations
        completed_events = save_data.completed_events
        
        print("Game loaded successfully!")
        return true