extends Node

signal battle_ended(result)

# Battle states
enum BattleState {INTRO, PLAYER_TURN, ENEMY_TURN, BUSY, BATTLE_END}
var current_state = BattleState.INTRO

# Battle data
var player_creature = null
var enemy_creature = null
var selected_move = null
var battle_log = []
var turn_count = 0
var battle_result = {"victory": false, "turns": 0, "remaining_hp": 0, "max_hp": 0}

# UI references
onready var player_creature_sprite = $BattleUI/PlayerCreatureSprite
onready var enemy_creature_sprite = $BattleUI/EnemyCreatureSprite
onready var player_hp_bar = $BattleUI/PlayerHPBar
onready var enemy_hp_bar = $BattleUI/EnemyHPBar
onready var move_buttons = $BattleUI/MoveButtons.get_children()
onready var battle_text = $BattleUI/BattleText
onready var action_buttons = $BattleUI/ActionButtons

func _ready():
    # Connect signals for move buttons
    for i in range(move_buttons.size()):
        move_buttons[i].connect("pressed", self, "_on_move_button_pressed", [i])
    
    # Connect signals for action buttons
    $BattleUI/ActionButtons/FightButton.connect("pressed", self, "_on_fight_button_pressed")
    $BattleUI/ActionButtons/ItemButton.connect("pressed", self, "_on_item_button_pressed")
    $BattleUI/ActionButtons/CreatureButton.connect("pressed", self, "_on_creature_button_pressed")
    $BattleUI/ActionButtons/RunButton.connect("pressed", self, "_on_run_button_pressed")
    
    # Start the battle
    start_battle(GameManager.current_battle)

# Initialize the battle with data
func start_battle(battle_data):
    player_creature = battle_data.player_creature
    enemy_creature = battle_data.opponent
    turn_count = 0
    
    # Update UI
    update_creature_displays()
    update_move_buttons()
    
    # Show intro text
    battle_text.text = "A wild " + enemy_creature.name + " appeared!"
    
    # Start battle sequence
    yield(get_tree().create_timer(2.0), "timeout")
    change_state(BattleState.PLAYER_TURN)

# Update the battle state
func change_state(new_state):
    current_state = new_state
    
    match new_state:
        BattleState.PLAYER_TURN:
            battle_text.text = "What will " + player_creature.name + " do?"
            action_buttons.visible = true
            for button in move_buttons:
                button.visible = false
        
        BattleState.ENEMY_TURN:
            action_buttons.visible = false
            for button in move_buttons:
                button.visible = false
            
            # Enemy selects a move
            yield(get_tree().create_timer(1.0), "timeout")
            enemy_select_move()
        
        BattleState.BATTLE_END:
            action_buttons.visible = false
            for button in move_buttons:
                button.visible = false

# Update the creature displays (sprites, HP bars, etc.)
func update_creature_displays():
    # Update HP bars
    player_hp_bar.max_value = player_creature.stats.hp
    player_hp_bar.value = player_creature.current_hp
    
    enemy_hp_bar.max_value = enemy_creature.stats.hp
    enemy_hp_bar.value = enemy_creature.current_hp
    
    # Update creature sprites (in a real game, you'd load the actual sprites)
    # player_creature_sprite.texture = load("res://assets/creatures/" + player_creature.id + "/idle.png")
    # enemy_creature_sprite.texture = load("res://assets/creatures/" + enemy_creature.id + "/idle.png")

# Update the move buttons with the player creature's moves
func update_move_buttons():
    for i in range(move_buttons.size()):
        if i < player_creature.moves.size():
            move_buttons[i].text = player_creature.moves[i].name
            move_buttons[i].visible = true
        else:
            move_buttons[i].visible = false

# Handle player selecting the Fight option
func _on_fight_button_pressed():
    battle_text.text = "Choose a move:"
    action_buttons.visible = false
    for i in range(move_buttons.size()):
        if i < player_creature.moves.size():
            move_buttons[i].visible = true

# Handle player selecting a move
func _on_move_button_pressed(move_index):
    if move_index >= player_creature.moves.size():
        return
    
    selected_move = player_creature.moves[move_index]
    
    # Hide move buttons
    for button in move_buttons:
        button.visible = false
    
    # Execute the move
    execute_move(player_creature, enemy_creature, selected_move)
    
    # After player's turn, switch to enemy turn
    change_state(BattleState.ENEMY_TURN)

# Handle player selecting the Item option
func _on_item_button_pressed():
    battle_text.text = "Items are not implemented yet."
    yield(get_tree().create_timer(1.5), "timeout")
    change_state(BattleState.PLAYER_TURN)

# Handle player selecting the Creature option
func _on_creature_button_pressed():
    battle_text.text = "Creature switching is not implemented yet."
    yield(get_tree().create_timer(1.5), "timeout")
    change_state(BattleState.PLAYER_TURN)

# Handle player selecting the Run option
func _on_run_button_pressed():
    # 75% chance to run from wild battles
    if randf() < 0.75:
        battle_text.text = "Got away safely!"
        yield(get_tree().create_timer(1.5), "timeout")
        end_battle("run")
    else:
        battle_text.text = "Couldn't escape!"
        yield(get_tree().create_timer(1.5), "timeout")
        change_state(BattleState.ENEMY_TURN)

# Enemy selects a move randomly
func enemy_select_move():
    if enemy_creature.moves.size() > 0:
        var move_index = randi() % enemy_creature.moves.size()
        var enemy_move = enemy_creature.moves[move_index]
        
        battle_text.text = "Wild " + enemy_creature.name + " used " + enemy_move.name + "!"
        yield(get_tree().create_timer(1.0), "timeout")
        
        execute_move(enemy_creature, player_creature, enemy_move)
    else:
        battle_text.text = "Wild " + enemy_creature.name + " has no moves!"
        yield(get_tree().create_timer(1.0), "timeout")
    
    # Check if battle should end
    if check_battle_end():
        return
    
    # After enemy's turn, switch back to player turn
    change_state(BattleState.PLAYER_TURN)

# Execute a move from attacker to target
func execute_move(attacker, target, move):
    # Get move data
    var move_data = DataLoader.get_move(move.id)
    if move_data == null:
        battle_text.text = "Move not found!"
        return
    
    # Calculate damage for damaging moves
    if move_data.category == "Physical" or move_data.category == "Special":
        var damage = calculate_damage(attacker, target, move_data)
        
        # Apply damage
        target.current_hp = max(0, target.current_hp - damage)
        
        # Update HP bars
        if target == player_creature:
            player_hp_bar.value = target.current_hp
        else:
            enemy_hp_bar.value = target.current_hp
        
        # Show effectiveness message
        var type_effectiveness = DataLoader.get_type_effectiveness(move_data.type, target.type)
        if type_effectiveness > 1.5:
            battle_text.text = "It's super effective!"
            yield(get_tree().create_timer(1.0), "timeout")
        elif type_effectiveness < 0.5:
            battle_text.text = "It's not very effective..."
            yield(get_tree().create_timer(1.0), "timeout")
        
        # Apply status effects if any
        if "status_effect" in move_data and randf() * 100 <= move_data.status_effect.chance:
            target.status_effect = move_data.status_effect.effect
            battle_text.text = target.name + " was " + move_data.status_effect.effect + "ed!"
            yield(get_tree().create_timer(1.0), "timeout")
        
        # Apply stat changes if any
        if "stat_changes" in move_data:
            for stat_change in move_data.stat_changes:
                var stat_target = target if stat_change.target == "opponent" else attacker
                var chance = stat_change.get("chance", 100)
                
                if randf() * 100 <= chance:
                    # Apply stat change logic here
                    battle_text.text = stat_target.name + "'s " + stat_change.stat + " " + ("rose" if stat_change.change > 0 else "fell") + "!"
                    yield(get_tree().create_timer(1.0), "timeout")
    
    # Check if battle should end
    check_battle_end()

# Calculate damage for a move
func calculate_damage(attacker, target, move_data):
    # Basic damage formula
    var level = attacker.level
    var power = move_data.power
    var attack = attacker.stats.attack if move_data.category == "Physical" else attacker.stats.special
    var defense = target.stats.defense if move_data.category == "Physical" else target.stats.special
    
    # Calculate base damage
    var damage = (2 * level / 5 + 2) * power * attack / defense / 50 + 2
    
    # Apply STAB (Same Type Attack Bonus)
    if move_data.type == attacker.type:
        damage *= 1.5
    
    # Apply type effectiveness
    var type_effectiveness = DataLoader.get_type_effectiveness(move_data.type, target.type)
    damage *= type_effectiveness
    
    # Apply random factor (85-100%)
    damage *= (85 + randi() % 16) / 100.0
    
    return int(damage)

# Check if the battle should end
func check_battle_end():
    if player_creature.current_hp <= 0:
        battle_text.text = player_creature.name + " fainted!"
        yield(get_tree().create_timer(2.0), "timeout")
        end_battle("lose")
        return true
    
    if enemy_creature.current_hp <= 0:
        battle_text.text = "Wild " + enemy_creature.name + " fainted!"
        yield(get_tree().create_timer(2.0), "timeout")
        
        # Calculate experience gained
        var exp_gained = calculate_experience(enemy_creature)
        battle_text.text = player_creature.name + " gained " + str(exp_gained) + " EXP!"
        
        # Add experience and check for level up
        var experience_system = $"/root/ExperienceSystem"
        var leveled_up = experience_system.add_experience(player_creature, exp_gained)
        
        # If leveled up, show message
        if leveled_up:
            yield(get_tree().create_timer(1.0), "timeout")
            battle_text.text = player_creature.name + " grew to level " + str(player_creature.level) + "!"
            yield(get_tree().create_timer(2.0), "timeout")
        
        end_battle("win")
        return true
    
    return false

# Calculate experience gained from defeating a creature
func calculate_experience(defeated_creature):
    # Use the ExperienceSystem to calculate experience
    return $"/root/ExperienceSystem".calculate_experience(player_creature, defeated_creature)

# Check if a creature should level up
func check_level_up(creature):
    var experience_system = $"/root/ExperienceSystem"
    var leveled_up = experience_system.add_experience(creature, 0)  # Just check if already has enough XP
    
    if leveled_up:
        battle_text.text = creature.name + " grew to level " + str(creature.level) + "!"
        yield(get_tree().create_timer(2.0), "timeout")
        
        # Evolution and new moves are handled by the ExperienceSystem
        # through signals, but we can check for new moves to display them
        var new_moves = experience_system.check_new_moves(creature, creature.level-1, creature.level)
        if new_moves and new_moves.size() > 0:
            for move in new_moves:
                battle_text.text = creature.name + " learned " + move.name + "!"
                yield(get_tree().create_timer(2.0), "timeout")

# Check if a creature should evolve
func check_evolution(creature):
    # This is now handled by the ExperienceSystem
    # We'll keep this function for compatibility but it's no longer needed
    pass

# Check if a creature learns new moves on level up
func check_new_moves(creature):
    # This would check if there are new moves to learn at this level
    # For simplicity, we're not implementing this yet
    pass

# End the battle and return to the previous state
func end_battle(result):
    # Add score based on result
    if result == "win":
        GameManager.add_score(enemy_creature.level * 10, "Defeated " + enemy_creature.name)
    
    # Signal that the battle has ended
    emit_signal("battle_ended", result)
    
    # Return to exploration mode
    GameManager.change_state(GameManager.GameState.EXPLORATION)
    
    # Return to the previous scene
    # get_tree().change_scene("res://scenes/World.tscn")
    
    # For now, just change state to BATTLE_END
    change_state(BattleState.BATTLE_END)