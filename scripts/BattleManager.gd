extends Node

# Battle Manager - Handles sequential battles and game progression

signal battle_completed(result, score_earned)
signal game_over(final_score)

# Game state
enum GameState {PREPARING, BATTLING, BETWEEN_BATTLES, GAME_OVER}
var current_state = GameState.PREPARING

# Battle progression
var battle_count = 0
var max_battles = 10  # Number of battles before game completion
var difficulty_multiplier = 1.0  # Increases as player progresses

# Player data
var player_creatures = []
var current_creature_index = 0
var player_score = 0

# Current battle data
var current_opponent = null

# Called when the node enters the scene tree for the first time
func _ready():
	pass

# Initialize a new game
func start_new_game():
	# Reset game state
	battle_count = 0
	player_score = 0
	difficulty_multiplier = 1.0
	current_state = GameState.PREPARING
	
	# Initialize player with starter creature
	player_creatures = []
	var starter = create_starter_creature()
	player_creatures.append(starter)
	current_creature_index = 0
	
	# Start first battle
	prepare_next_battle()

# Create a starter creature for the player
func create_starter_creature():
	# Let player choose between three starter types
	var starter_options = ["creature1", "creature2", "creature3"]
	var selected_starter = starter_options[0]  # Default to first option
	
	# In a real implementation, you would show a UI for selection
	# For now, we'll just use the first option
	
	return GameManager.create_creature(selected_starter, 5)  # Start at level 5

# Prepare the next battle
func prepare_next_battle():
	battle_count += 1
	current_state = GameState.PREPARING
	
	# Check if we've reached the maximum number of battles
	if battle_count > max_battles:
		end_game()
		return
	
	# Create an opponent based on current battle count
	var opponent_level = 5 + battle_count  # Level increases with each battle
	
	# Select a random creature type for opponent
	var creature_types = ["creature1", "creature2", "creature3"]
	var opponent_type = creature_types[randi() % creature_types.size()]
	
	# Create the opponent
	current_opponent = GameManager.create_creature(opponent_type, opponent_level)
	
	# Adjust difficulty
	difficulty_multiplier = 1.0 + (battle_count * 0.1)  # 10% increase per battle
	
	# Start the battle
	start_battle()

# Start the current battle
func start_battle():
	current_state = GameState.BATTLING
	
	# Set up the battle data
	var battle_data = {
		"player_creature": player_creatures[current_creature_index],
		"opponent": current_opponent,
		"difficulty": difficulty_multiplier
	}
	
	# Set the current battle in GameManager
	GameManager.current_battle = battle_data
	
	# Change to battle scene
	get_tree().change_scene("res://scenes/Battle.tscn")

# Handle battle completion
func on_battle_completed(result):
	current_state = GameState.BETWEEN_BATTLES
	
	# Calculate score based on battle result
	var score_earned = 0
	var score_system = $"/root/ScoreSystem"
	
	if result.victory:
		# Use ScoreSystem to calculate battle win score
		if score_system:
			score_earned = score_system.add_battle_win_score(
				current_opponent.level,
				result.turns,
				result.remaining_hp,
				result.max_hp
			)
		else:
			# Fallback if ScoreSystem isn't available
			# Base score for winning
			score_earned = 100 * difficulty_multiplier
			
			# Bonus for efficiency (fewer turns)
			var turn_bonus = max(0, 50 - (result.turns * 5))
			score_earned += turn_bonus
			
			# Bonus for health remaining
			var health_percent = float(result.remaining_hp) / result.max_hp
			var health_bonus = int(50 * health_percent)
			score_earned += health_bonus
		
		# Level up the creature using ExperienceSystem
		var experience_system = $"/root/ExperienceSystem"
		if experience_system:
			experience_system.add_experience(
				player_creatures[current_creature_index],
				current_opponent.level * 3 * difficulty_multiplier
			)
		else:
			# Fallback to old method
			level_up_creature(player_creatures[current_creature_index])
		
		# Heal creature partially between battles
		partial_heal_creature(player_creatures[current_creature_index])
	else:
		# Small score for trying
		if score_system:
			score_earned = score_system.add_score(10 * difficulty_multiplier, 
				score_system.ScoreCategory.BATTLE_WIN, "Battle attempt")
		else:
			score_earned = 10 * difficulty_multiplier
			player_score += int(score_earned)
		
		# Check if all creatures are fainted
		if all_creatures_fainted():
			end_game()
			return
		
		# Switch to next available creature
		switch_to_next_available_creature()
	
	# Update total score if not using ScoreSystem
	if not score_system:
		player_score += int(score_earned)
	
	# Emit signal with result and score
	emit_signal("battle_completed", result, score_earned)
	
	# Prepare for next battle
	prepare_next_battle()

# Check if all player creatures are fainted
func all_creatures_fainted():
	for creature in player_creatures:
		if creature.current_hp > 0:
			return false
	return true

# Switch to the next available creature with HP
func switch_to_next_available_creature():
	for i in range(player_creatures.size()):
		var index = (current_creature_index + i + 1) % player_creatures.size()
		if player_creatures[index].current_hp > 0:
			current_creature_index = index
			return

# Level up a creature after winning a battle
func level_up_creature(creature):
	# Increase level
	creature.level += 1
	
	# Recalculate stats
	var data = DataLoader.get_creature(creature.id)
	if data != null:
		creature.stats = GameManager.calculate_stats(data.base_stats, creature.level)
		
		# Update experience
		creature.experience = GameManager.calculate_experience_for_level(creature.level)
		
		# Check for evolution
		if creature.can_evolve():
			evolve_creature(creature)

# Evolve a creature if conditions are met
func evolve_creature(creature):
	if creature.can_evolve():
		var data = DataLoader.get_creature(creature.id)
		var evolution_id = data.evolution.evolves_to
		
		# Create new evolved creature
		var evolved = GameManager.create_creature(evolution_id, creature.level)
		
		# Replace the old creature with the evolved one
		var index = player_creatures.find(creature)
		if index >= 0:
			player_creatures[index] = evolved
			
			# If this was the current creature, update the index
			if index == current_creature_index:
				current_creature_index = index

# Partially heal creature between battles
func partial_heal_creature(creature):
	# Heal 30% of max HP
	var heal_amount = int(creature.stats.hp * 0.3)
	creature.current_hp = min(creature.stats.hp, creature.current_hp + heal_amount)
	
	# Restore some PP to each move
	for move in creature.moves:
		move.current_pp = min(move.pp, move.current_pp + 1)

# End the game and show final score
func end_game():
	current_state = GameState.GAME_OVER
	
	# Emit game over signal with final score
	emit_signal("game_over", player_score)
	
	# Change to game over scene
	# get_tree().change_scene("res://scenes/GameOver.tscn")
	
	# For now, just return to main menu
	get_tree().change_scene("res://scenes/MainMenu.tscn")