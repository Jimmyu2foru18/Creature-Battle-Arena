extends Node

# Experience System - Handles creature experience, leveling, and evolution

signal level_up(creature, old_level, new_level)
signal evolution(creature, old_id, new_id)

# Experience curve types
enum ExpCurve {FAST, MEDIUM, SLOW}

# Experience required for each level based on curve type
const EXP_REQUIREMENTS = {
    ExpCurve.FAST: {
        # Level: Experience required
        1: 0,
        2: 15,
        3: 52,
        4: 122,
        5: 237,
        # Add more levels as needed
        10: 1000,
        15: 3000,
        20: 8000
    },
    ExpCurve.MEDIUM: {
        1: 0,
        2: 20,
        3: 70,
        4: 165,
        5: 320,
        # Add more levels as needed
        10: 1500,
        15: 4200,
        20: 10000
    },
    ExpCurve.SLOW: {
        1: 0,
        2: 25,
        3: 85,
        4: 200,
        5: 400,
        # Add more levels as needed
        10: 2000,
        15: 5500,
        20: 12000
    }
}

# Calculate experience gained from defeating a creature
func calculate_experience(victor, defeated):
    # Base formula: defeated creature's level * base_exp_yield * modifiers
    var base_exp = defeated.level * 3
    
    # Apply modifiers
    var trainer_bonus = 1.0  # 1.5 if from a trainer battle
    var lucky_bonus = 1.0    # Could be increased with items
    
    # Calculate final experience
    var exp_gained = int(base_exp * trainer_bonus * lucky_bonus)
    
    return exp_gained

# Add experience to a creature and handle level ups
func add_experience(creature, exp_amount):
    # Add experience
    creature.experience += exp_amount
    
    # Check for level up
    var old_level = creature.level
    var new_level = calculate_level_from_experience(creature)
    
    if new_level > old_level:
        # Level up occurred
        var levels_gained = new_level - old_level
        creature.level = new_level
        
        # Update stats
        update_stats_on_level_up(creature, old_level, new_level)
        
        # Emit level up signal
        emit_signal("level_up", creature, old_level, new_level)
        
        # Check for evolution
        check_evolution(creature)
        
        # Check for new moves
        check_new_moves(creature, old_level, new_level)
        
        return true  # Level up occurred
    
    return false  # No level up

# Calculate creature's level based on current experience
func calculate_level_from_experience(creature):
    var curve = get_experience_curve(creature)
    var current_exp = creature.experience
    var current_level = creature.level
    
    # Check if creature has enough exp for next level
    while current_level < 100:  # Max level cap
        var next_level = current_level + 1
        var exp_needed = get_exp_for_level(curve, next_level)
        
        if current_exp >= exp_needed:
            current_level = next_level
        else:
            break
    
    return current_level

# Get the experience curve type for a creature
func get_experience_curve(creature):
    # This could be based on creature type or growth rate
    # For now, we'll use a simple mapping
    match creature.type:
        "Fire":
            return ExpCurve.FAST
        "Water":
            return ExpCurve.MEDIUM
        "Grass":
            return ExpCurve.SLOW
        _:
            return ExpCurve.MEDIUM

# Get experience required for a specific level
func get_exp_for_level(curve, level):
    if level <= 1:
        return 0
    
    # If exact level is defined in the table
    if EXP_REQUIREMENTS[curve].has(level):
        return EXP_REQUIREMENTS[curve][level]
    
    # Otherwise use a formula
    match curve:
        ExpCurve.FAST:
            return int(pow(level, 3) * 0.8)
        ExpCurve.MEDIUM:
            return int(pow(level, 3))
        ExpCurve.SLOW:
            return int(pow(level, 3) * 1.2)
        _:
            return int(pow(level, 3))

# Update creature stats when leveling up
func update_stats_on_level_up(creature, old_level, new_level):
    # Get base stats from creature data
    var data = DataLoader.get_creature(creature.id)
    if data == null:
        return
    
    # Calculate new stats
    creature.stats = GameManager.calculate_stats(data.base_stats, new_level)
    
    # Heal the creature to full HP on level up
    creature.current_hp = creature.stats.hp

# Check if a creature should evolve
func check_evolution(creature):
    var creature_data = DataLoader.get_creature(creature.id)
    
    if creature_data == null or not "evolution" in creature_data:
        return false
    
    # Check evolution conditions
    if creature.level >= creature_data.evolution.level:
        # Get evolution data
        var evolution_id = creature_data.evolution.evolves_to
        var evolution_data = DataLoader.get_creature(evolution_id)
        
        if evolution_data != null:
            # Store old ID for signal
            var old_id = creature.id
            
            # Update creature with evolution data
            creature.id = evolution_id
            creature.name = evolution_data.name
            creature.type = evolution_data.type
            
            # Recalculate stats with new base stats
            creature.stats = GameManager.calculate_stats(evolution_data.base_stats, creature.level)
            
            # Emit evolution signal
            emit_signal("evolution", creature, old_id, evolution_id)
            
            return true
    
    return false

# Check if a creature learns new moves on level up
func check_new_moves(creature, old_level, new_level):
    var creature_data = DataLoader.get_creature(creature.id)
    if creature_data == null or not "level_moves" in creature_data:
        return
    
    var new_moves = []
    
    # Check each level between old and new level
    for level in range(old_level + 1, new_level + 1):
        if str(level) in creature_data.level_moves:
            var move_id = creature_data.level_moves[str(level)]
            var move_data = DataLoader.get_move(move_id)
            
            if move_data != null:
                new_moves.append({
                    "id": move_id,
                    "name": move_data.name,
                    "level": level
                })
    
    # Return list of new moves (would be handled by UI)
    return new_moves

# Calculate experience progress to next level (0.0 to 1.0)
func get_level_progress(creature):
    var curve = get_experience_curve(creature)
    var current_level = creature.level
    var current_exp = creature.experience
    
    var exp_for_current = get_exp_for_level(curve, current_level)
    var exp_for_next = get_exp_for_level(curve, current_level + 1)
    
    var level_exp_range = exp_for_next - exp_for_current
    var current_level_progress = current_exp - exp_for_current
    
    return float(current_level_progress) / level_exp_range