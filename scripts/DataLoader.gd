extends Node

# Paths to data files
const CREATURES_PATH = "res://data/creatures.json"
const MOVES_PATH = "res://data/moves.json"
const TYPE_CHART_PATH = "res://data/type_chart.json"

# Data containers
var creatures = {}
var moves = {}
var type_chart = {}

# Called when the node enters the scene tree for the first time
func _ready():
    load_all_data()
    scan_creature_sprites()

# Load all game data from JSON files
func load_all_data():
    creatures = load_json_file(CREATURES_PATH)
    moves = load_json_file(MOVES_PATH)
    type_chart = load_json_file(TYPE_CHART_PATH)
    
    if creatures.empty() or moves.empty() or type_chart.empty():
        push_error("Failed to load game data!")
    else:
        print("Game data loaded successfully!")

# Helper function to load a JSON file
func load_json_file(file_path):
    var file = File.new()
    if not file.file_exists(file_path):
        push_error("File does not exist: " + file_path)
        return {}
    
    file.open(file_path, File.READ)
    var text = file.get_as_text()
    file.close()
    
    var result = parse_json(text)
    if result == null:
        push_error("Invalid JSON in file: " + file_path)
        return {}
    
    return result

# Scan the creatures directory to find available sprites
func scan_creature_sprites():
    var dir = Directory.new()
    var creatures_dir = "res://assets/creatures/"
    
    if not dir.dir_exists(creatures_dir):
        push_error("Creatures directory does not exist: " + creatures_dir)
        return
    
    if dir.open(creatures_dir) == OK:
        dir.list_dir_begin(true, true)
        var folder_name = dir.get_next()
        
        while folder_name != "":
            if dir.current_is_dir():
                print("Found creature folder: " + folder_name)
                # Here you would check if the required sprite files exist
                check_creature_sprites(creatures_dir + folder_name)
            folder_name = dir.get_next()
    else:
        push_error("Failed to open creatures directory")

# Check if a creature folder has all required sprites
func check_creature_sprites(folder_path):
    var dir = Directory.new()
    var required_sprites = ["idle.png", "attack.png", "hurt.png"]
    
    if dir.open(folder_path) == OK:
        for sprite in required_sprites:
            if not dir.file_exists(sprite):
                push_warning("Missing sprite in " + folder_path + ": " + sprite)
    else:
        push_error("Failed to open folder: " + folder_path)

# Get creature data by ID
func get_creature(creature_id):
    if creatures.has(creature_id):
        return creatures[creature_id]
    push_error("Creature not found: " + creature_id)
    return null

# Get move data by ID
func get_move(move_id):
    if moves.has(move_id):
        return moves[move_id]
    push_error("Move not found: " + move_id)
    return null

# Get type effectiveness multiplier
func get_type_effectiveness(attacking_type, defending_type):
    if type_chart.has(attacking_type) and type_chart[attacking_type].has(defending_type):
        return type_chart[attacking_type][defending_type]
    return 1.0  # Default to normal effectiveness