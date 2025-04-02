extends Control

# References to UI elements
onready var score_label = $ScoreLabel
onready var high_score_label = $HighScoreLabel
onready var restart_button = $VBoxContainer/RestartButton
onready var main_menu_button = $VBoxContainer/MainMenuButton

# Game data
var final_score = 0
var player_name = "Player"

func _ready():
    # Connect button signals
    restart_button.connect("pressed", self, "_on_restart_button_pressed")
    main_menu_button.connect("pressed", self, "_on_main_menu_button_pressed")
    
    # Get final score from ScoreSystem
    var score_system = get_node("/root/ScoreSystem")
    if score_system:
        final_score = score_system.current_score
    else:
        # Fallback to BattleManager if ScoreSystem isn't available
        var battle_manager = get_node("/root/BattleManager")
        if battle_manager:
            final_score = battle_manager.player_score
    
    # Update score display
    score_label.text = "Final Score: " + str(final_score)
    
    # Check if this is a high score using ScoreSystem
    var is_high_score = false
    var high_score_rank = 0
    
    if score_system:
        high_score_rank = score_system.check_high_score()
        is_high_score = high_score_rank > 0
        
        if is_high_score:
            high_score_label.text = "NEW HIGH SCORE! Rank: " + str(high_score_rank)
            
            # Ask for player name
            ask_for_player_name()
        else:
            var high_scores = score_system.high_scores
            if high_scores.size() > 0:
                high_score_label.text = "High Score: " + str(high_scores[0].score)
            else:
                high_score_label.text = "No high scores yet!"
    else:
        # Fallback to old method
        var high_scores = load_high_scores()
        
        if high_scores.empty() or final_score > high_scores[0].score:
            is_high_score = true
            high_score_label.text = "NEW HIGH SCORE!"
            
            # Ask for player name
            ask_for_player_name()
        else:
            high_score_label.text = "High Score: " + str(high_scores[0].score)
        
        # Save score using old method
        save_score(final_score)

# Ask player for their name
func ask_for_player_name():
    var dialog = AcceptDialog.new()
    dialog.window_title = "New High Score!"
    
    var line_edit = LineEdit.new()
    line_edit.placeholder_text = "Enter your name"
    line_edit.text = "Player"
    
    dialog.add_child(line_edit)
    dialog.connect("confirmed", self, "_on_name_confirmed", [line_edit])
    
    add_child(dialog)
    dialog.popup_centered()

# Handle name confirmation
func _on_name_confirmed(line_edit):
    player_name = line_edit.text
    if player_name.empty():
        player_name = "Player"
    
    # Save high score with name using ScoreSystem
    var score_system = get_node("/root/ScoreSystem")
    if score_system:
        var rank = score_system.save_score(player_name)
        high_score_label.text = "NEW HIGH SCORE! Rank: " + str(rank)
    else:
        # Fallback to old method
        save_high_score(player_name, final_score)

# Load high scores from file
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

# Save current score to scores file
func save_score(score):
    var file = File.new()
    var scores = []
    
    if file.file_exists("user://scores.json"):
        file.open("user://scores.json", File.READ)
        var text = file.get_as_text()
        file.close()
        
        var result = parse_json(text)
        if result != null and typeof(result) == TYPE_ARRAY:
            scores = result
    
    scores.append({"score": score, "date": OS.get_datetime()})
    
    file.open("user://scores.json", File.WRITE)
    file.store_string(JSON.print(scores))
    file.close()

# Save high score with player name
func save_high_score(name, score):
    var scores = load_high_scores()
    
    # Add new score
    scores.append({"name": name, "score": score, "date": OS.get_datetime()})
    
    # Sort scores in descending order
    scores.sort_custom(self, "sort_scores_descending")
    
    # Keep only top 10 scores
    if scores.size() > 10:
        scores.resize(10)
    
    # Save to file
    var file = File.new()
    file.open("user://highscores.json", File.WRITE)
    file.store_string(JSON.print(scores))
    file.close()

# Custom sort function for scores
func sort_scores_descending(a, b):
    return a.score > b.score

# Restart the game
func _on_restart_button_pressed():
    var battle_manager = get_node("/root/BattleManager")
    if battle_manager:
        battle_manager.start_new_game()

# Return to main menu
func _on_main_menu_button_pressed():
    get_tree().change_scene("res://scenes/MainMenu.tscn")