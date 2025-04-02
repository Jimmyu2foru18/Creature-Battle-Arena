extends Control

# Main Menu UI - Handles the main menu interface and navigation

# References to UI elements
onready var title_label = $TitleLabel
onready var version_label = $VersionLabel
onready var start_button = $MenuButtons/StartButton
onready var continue_button = $MenuButtons/ContinueButton
onready var options_button = $MenuButtons/OptionsButton
onready var high_scores_button = $MenuButtons/HighScoresButton
onready var credits_button = $MenuButtons/CreditsButton
onready var quit_button = $MenuButtons/QuitButton
onready var options_panel = $OptionsPanel
onready var high_scores_panel = $HighScoresPanel
onready var credits_panel = $CreditsPanel

# Game version
const GAME_VERSION = "v0.1.0"

func _ready():
    # Set game title and version
    title_label.text = "Creature Battle Arena"
    version_label.text = GAME_VERSION
    
    # Connect button signals
    start_button.connect("pressed", self, "_on_start_button_pressed")
    continue_button.connect("pressed", self, "_on_continue_button_pressed")
    options_button.connect("pressed", self, "_on_options_button_pressed")
    high_scores_button.connect("pressed", self, "_on_high_scores_button_pressed")
    credits_button.connect("pressed", self, "_on_credits_button_pressed")
    quit_button.connect("pressed", self, "_on_quit_button_pressed")
    
    # Check if save game exists and enable/disable continue button
    var file = File.new()
    continue_button.disabled = !file.file_exists("user://savegame.json")
    
    # Hide panels initially
    options_panel.visible = false
    high_scores_panel.visible = false
    credits_panel.visible = false
    
    # Initialize systems
    var autoload_manager = $"/root/AutoloadManager"
    if autoload_manager:
        # Systems will be registered by AutoloadManager
        pass
    else:
        # Manually register systems if AutoloadManager isn't available
        register_systems()

# Register game systems manually if needed
func register_systems():
    # Check if ExperienceSystem exists
    if not has_node("/root/ExperienceSystem"):
        var exp_script = load("res://scripts/ExperienceSystem.gd")
        if exp_script:
            var exp_node = Node.new()
            exp_node.set_script(exp_script)
            exp_node.name = "ExperienceSystem"
            get_tree().root.add_child(exp_node)
    
    # Check if ScoreSystem exists
    if not has_node("/root/ScoreSystem"):
        var score_script = load("res://scripts/ScoreSystem.gd")
        if score_script:
            var score_node = Node.new()
            score_node.set_script(score_script)
            score_node.name = "ScoreSystem"
            get_tree().root.add_child(score_node)

# Start a new game
func _on_start_button_pressed():
    # Reset game state in GameManager
    var game_manager = get_node("/root/GameManager")
    if game_manager:
        game_manager.initialize_player()
    
    # Reset score
    var score_system = get_node("/root/ScoreSystem")
    if score_system:
        score_system.reset_score()
    
    # Start the game using BattleManager
    var battle_manager = get_node("/root/BattleManager")
    if battle_manager:
        battle_manager.start_new_game()
    else:
        push_error("BattleManager not found!")
        # Fallback to direct scene change
        get_tree().change_scene("res://scenes/World.tscn")

# Continue a saved game
func _on_continue_button_pressed():
    var game_manager = get_node("/root/GameManager")
    if game_manager and game_manager.load_game():
        # Successfully loaded game, transition to world
        get_tree().change_scene("res://scenes/World.tscn")
    else:
        # Failed to load game
        var dialog = AcceptDialog.new()
        dialog.window_title = "Error"
        dialog.dialog_text = "Failed to load saved game!"
        add_child(dialog)
        dialog.popup_centered()

# Show options panel
func _on_options_button_pressed():
    options_panel.visible = true
    high_scores_panel.visible = false
    credits_panel.visible = false

# Show high scores panel
func _on_high_scores_button_pressed():
    options_panel.visible = false
    high_scores_panel.visible = true
    credits_panel.visible = false
    
    # Load and display high scores
    var score_system = get_node("/root/ScoreSystem")
    if score_system:
        var scores = score_system.load_high_scores()
        update_high_scores_display(scores)
    else:
        # Fallback to direct file loading
        var scores = load_high_scores()
        update_high_scores_display(scores)

# Update the high scores display
func update_high_scores_display(scores):
    var scores_label = high_scores_panel.get_node("ScoresLabel")
    if scores_label:
        var score_text = "Top Scores:\n"
        
        if scores.empty():
            score_text += "No scores yet!"
        else:
            # Display top 10 scores
            for i in range(min(10, scores.size())):
                score_text += "%d. %s: %d\n" % [i+1, scores[i].name, scores[i].score]
        
        scores_label.text = score_text

# Load high scores from file (fallback method)
func load_high_scores():
    var scores = []
    var file = File.new()
    
    if file.file_exists("user://highscores.json"):
        file.open("user://highscores.json", File.READ)
        var text = file.get_as_text()
        file.close()
        
        var result = parse_json(text)
        if result != null and typeof(result) == TYPE_ARRAY:
            scores = result
    
    return scores

# Show credits panel
func _on_credits_button_pressed():
    options_panel.visible = false
    high_scores_panel.visible = false
    credits_panel.visible = true

# Quit the game
func _on_quit_button_pressed():
    get_tree().quit()