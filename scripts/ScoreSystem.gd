extends Node

# Score System - Handles score tracking, high scores, and achievements

signal score_changed(new_score, points_added, reason)
signal high_score_achieved(score, rank)

# Score categories
enum ScoreCategory {
    BATTLE_WIN,
    CREATURE_CAPTURE,
    CREATURE_EVOLUTION,
    LEVEL_UP,
    ITEM_FIND,
    AREA_DISCOVER,
    COMBO_BONUS,
    TIME_BONUS,
    SPECIAL_ACHIEVEMENT
}

# Score values for different actions
const SCORE_VALUES = {
    ScoreCategory.BATTLE_WIN: 100,
    ScoreCategory.CREATURE_CAPTURE: 200,
    ScoreCategory.CREATURE_EVOLUTION: 300,
    ScoreCategory.LEVEL_UP: 50,
    ScoreCategory.ITEM_FIND: 25,
    ScoreCategory.AREA_DISCOVER: 150,
    ScoreCategory.COMBO_BONUS: 75,
    ScoreCategory.TIME_BONUS: 100,
    ScoreCategory.SPECIAL_ACHIEVEMENT: 500
}

# Score multipliers
var combo_multiplier = 1.0
var difficulty_multiplier = 1.0

# Current score
var current_score = 0
var score_history = []

# High scores
var high_scores = []

func _ready():
    # Load high scores
    load_high_scores()
    
    # Connect to relevant signals
    var experience_system = $"/root/ExperienceSystem"
    if experience_system:
        experience_system.connect("level_up", self, "_on_creature_level_up")
        experience_system.connect("evolution", self, "_on_creature_evolution")

# Add points to the score
func add_score(points, category, reason=""):
    # Apply multipliers
    var adjusted_points = int(points * combo_multiplier * difficulty_multiplier)
    
    # Update score
    current_score += adjusted_points
    
    # Add to history
    score_history.append({
        "points": adjusted_points,
        "category": category,
        "reason": reason,
        "timestamp": OS.get_unix_time()
    })
    
    # Emit signal
    emit_signal("score_changed", current_score, adjusted_points, reason)
    
    # Check for high score
    check_high_score()
    
    return adjusted_points

# Add score for a specific category
func add_score_for_category(category, modifier=1.0, reason=""):
    if category in SCORE_VALUES:
        var base_points = SCORE_VALUES[category]
        var points = int(base_points * modifier)
        return add_score(points, category, reason)
    return 0

# Add score for winning a battle
func add_battle_win_score(opponent_level, turns_taken, hp_remaining, hp_max):
    # Base score for winning
    var base_points = SCORE_VALUES[ScoreCategory.BATTLE_WIN]
    
    # Level modifier
    var level_modifier = 1.0 + (opponent_level * 0.1)  # 10% bonus per level
    
    # Efficiency modifier based on turns
    var turn_modifier = 1.0
    if turns_taken <= 3:
        turn_modifier = 1.5  # 50% bonus for quick battles
    elif turns_taken <= 5:
        turn_modifier = 1.2  # 20% bonus for medium-length battles
    
    # Health modifier
    var health_percent = float(hp_remaining) / hp_max
    var health_modifier = 1.0 + (health_percent * 0.5)  # Up to 50% bonus for full health
    
    # Calculate total points
    var total_modifier = level_modifier * turn_modifier * health_modifier
    var points = int(base_points * total_modifier)
    
    # Add score with reason
    var reason = "Defeated level " + str(opponent_level) + " creature"
    return add_score(points, ScoreCategory.BATTLE_WIN, reason)

# Set combo multiplier
func set_combo_multiplier(value):
    combo_multiplier = value

# Set difficulty multiplier
func set_difficulty_multiplier(value):
    difficulty_multiplier = value

# Check if current score is a high score
func check_high_score():
    if high_scores.empty() or current_score > high_scores[0].score:
        # It's the highest score!
        emit_signal("high_score_achieved", current_score, 1)
        return 1
    
    # Check where this score ranks
    for i in range(high_scores.size()):
        if current_score > high_scores[i].score:
            emit_signal("high_score_achieved", current_score, i + 1)
            return i + 1
    
    # Not in top 10
    return 0

# Save current score to high scores
func save_score(player_name):
    var new_entry = {
        "name": player_name,
        "score": current_score,
        "date": OS.get_datetime()
    }
    
    high_scores.append(new_entry)
    
    # Sort scores in descending order
    high_scores.sort_custom(self, "sort_scores_descending")
    
    # Keep only top 10 scores
    if high_scores.size() > 10:
        high_scores.resize(10)
    
    # Save to file
    save_high_scores()
    
    # Return position in high scores
    return high_scores.find(new_entry) + 1

# Custom sort function for scores
func sort_scores_descending(a, b):
    return a.score > b.score

# Load high scores from file
func load_high_scores():
    var file = File.new()
    
    if file.file_exists("user://highscores.json"):
        file.open("user://highscores.json", File.READ)
        var text = file.get_as_text()
        file.close()
        
        var result = parse_json(text)
        if result != null and typeof(result) == TYPE_ARRAY:
            high_scores = result
            return high_scores
    
    # If file doesn't exist or is invalid, initialize with empty array
    high_scores = []
    return high_scores

# Save high scores to file
func save_high_scores():
    var file = File.new()
    file.open("user://highscores.json", File.WRITE)
    file.store_string(JSON.print(high_scores))
    file.close()

# Get score breakdown by category
func get_score_breakdown():
    var breakdown = {}
    
    for category in ScoreCategory.values():
        breakdown[category] = 0
    
    for entry in score_history:
        if entry.category in breakdown:
            breakdown[entry.category] += entry.points
    
    return breakdown

# Reset current score
func reset_score():
    current_score = 0
    score_history = []
    combo_multiplier = 1.0
    difficulty_multiplier = 1.0
    emit_signal("score_changed", current_score, 0, "Score reset")

# Signal handlers
func _on_creature_level_up(creature, old_level, new_level):
    var levels_gained = new_level - old_level
    var points = SCORE_VALUES[ScoreCategory.LEVEL_UP] * levels_gained
    
    add_score(points, ScoreCategory.LEVEL_UP, 
              creature.name + " grew to level " + str(new_level))

func _on_creature_evolution(creature, old_id, new_id):
    add_score_for_category(ScoreCategory.CREATURE_EVOLUTION, 1.0,
                          creature.name + " evolved")