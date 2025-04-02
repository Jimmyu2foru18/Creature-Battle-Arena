extends Resource
class_name Creature

# Basic properties
export var id: String
export var name: String
export var type: String
export var level: int = 1
export var experience: int = 0

# Stats
export var stats = {
    "hp": 0,
    "attack": 0,
    "defense": 0,
    "speed": 0,
    "special": 0
}

# Battle properties
export var current_hp: int
export var status_effect: String = ""
export var moves = []

# Initialize a creature from data
func _init(creature_id="", init_level=1):
    if creature_id == "":
        return
    
    # Load creature data
    var data = DataLoader.get_creature(creature_id)
    if data == null:
        push_error("Creature not found: " + creature_id)
        return
    
    # Set basic properties
    id = creature_id
    name = data.name
    type = data.type
    level = init_level
    experience = GameManager.calculate_experience_for_level(level)
    
    # Calculate stats based on level
    stats = GameManager.calculate_stats(data.base_stats, level)
    current_hp = stats.hp
    
    # Assign moves
    for move_id in data.moves:
        if moves.size() < 4:  # Maximum 4 moves
            var move_data = DataLoader.get_move(move_id)
            if move_data != null:
                moves.append({
                    "id": move_id,
                    "name": move_data.name,
                    "type": move_data.type,
                    "pp": move_data.pp,
                    "current_pp": move_data.pp
                })

# Heal the creature to full HP
func heal_full():
    current_hp = stats.hp
    status_effect = ""
    
    # Restore PP for all moves
    for move in moves:
        move.current_pp = move.pp

# Apply damage to the creature
func take_damage(amount):
    current_hp = max(0, current_hp - amount)
    return current_hp <= 0  # Return true if fainted

# Use a move (reduce PP)
func use_move(move_index):
    if move_index < 0 or move_index >= moves.size():
        return false
    
    if moves[move_index].current_pp <= 0:
        return false
    
    moves[move_index].current_pp -= 1
    return true

# Check if the creature can evolve
func can_evolve():
    var data = DataLoader.get_creature(id)
    return "evolution" in data and level >= data.evolution.level

# Evolve the creature
func evolve():
    if not can_evolve():
        return false
    
    var data = DataLoader.get_creature(id)
    var evolution_id = data.evolution.evolves_to
    var evolution_data = DataLoader.get_creature(evolution_id)
    
    if evolution_data == null:
        return false
    
    # Update creature with evolution data
    id = evolution_id
    name = evolution_data.name
    type = evolution_data.type
    
    # Recalculate stats
    var old_max_hp = stats.hp
    stats = GameManager.calculate_stats(evolution_data.base_stats, level)
    
    # Adjust current HP proportionally
    var hp_ratio = float(current_hp) / old_max_hp
    current_hp = int(stats.hp * hp_ratio)
    
    return true

# Get a description of the creature
func get_description():
    return name + " (Lv. " + str(level) + " " + type + ")"