extends Node2D

# References
onready var player = $Player
onready var camera = $Camera2D
onready var hud = $HUD

# Map properties
export var map_name = "Starter Town"
export var wild_encounter_enabled = false
export var wild_encounter_rate = 0.1  # 10% chance per step in tall grass

func _ready():
    # Set up the HUD
    hud.update_score(GameManager.player_score)
    hud.update_map_name(map_name)
    
    # Update player position if coming from another map
    if GameManager.current_map != "":
        # This would position the player at the correct entrance
        # For simplicity, we're not implementing this yet
        pass
    
    # Set the current map
    GameManager.current_map = map_name
    
    # Add to visited locations if not already visited
    if not map_name in GameManager.visited_locations:
        GameManager.visited_locations.append(map_name)

# Handle player stepping on different terrain
func _on_player_stepped_on_terrain(terrain_type, terrain_data):
    match terrain_type:
        "grass":
            if wild_encounter_enabled and randf() < wild_encounter_rate:
                trigger_wild_encounter(terrain_data)
        "water":
            # Handle water terrain (might need a special ability to cross)
            pass
        "cave_entrance":
            # Handle entering a cave
            transition_to_map(terrain_data.target_map)

# Trigger a wild creature encounter
func trigger_wild_encounter(terrain_data):
    # Determine which creature to encounter based on the terrain
    var possible_creatures = terrain_data.get("creatures", ["creature1"])
    var creature_id = possible_creatures[randi() % possible_creatures.size()]
    
    # Determine level range based on the area
    var min_level = terrain_data.get("min_level", 2)
    var max_level = terrain_data.get("max_level", 5)
    var level = min_level + randi() % (max_level - min_level + 1)
    
    # Create the wild creature
    var wild_creature = GameManager.create_creature(creature_id, level)
    
    if wild_creature != null:
        # Start battle with the wild creature
        GameManager.start_battle(wild_creature)
        
        # Transition to battle scene
        get_tree().change_scene("res://scenes/Battle.tscn")

# Transition to another map
func transition_to_map(target_map):
    # Save current game state
    GameManager.save_game()
    
    # Load the target map
    get_tree().change_scene("res://scenes/maps/" + target_map + ".tscn")

# Handle player interaction with NPCs or objects
func _on_player_interact(interactable):
    match interactable.type:
        "npc":
            # Start dialogue with NPC
            GameManager.change_state(GameManager.GameState.DIALOGUE)
            # Show dialogue UI
            $DialogueUI.start_dialogue(interactable.dialogue_data)
        "item":
            # Collect item
            GameManager.player_items[interactable.item_id] = GameManager.player_items.get(interactable.item_id, 0) + 1
            hud.show_notification("Found " + interactable.item_name + "!")
            # Remove the item from the world
            interactable.queue_free()
        "trainer":
            # Start trainer battle
            var trainer_data = {
                "type": "trainer",
                "name": interactable.trainer_name,
                "creatures": interactable.creatures,
                "reward": interactable.reward
            }
            GameManager.start_battle(trainer_data)
            get_tree().change_scene("res://scenes/Battle.tscn")

# Handle game state changes
func _on_game_state_changed(new_state):
    match new_state:
        GameManager.GameState.EXPLORATION:
            # Enable player movement
            player.set_process_input(true)
        GameManager.GameState.BATTLE:
            # Disable player movement
            player.set_process_input(false)
        GameManager.GameState.MENU:
            # Show menu and disable player movement
            $MenuUI.show()
            player.set_process_input(false)
        GameManager.GameState.DIALOGUE:
            # Disable player movement during dialogue
            player.set_process_input(false)