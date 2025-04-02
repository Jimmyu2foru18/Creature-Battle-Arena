# System Analysis Report

# 2D Turn-Based Game
GROUP X
( Daniyal Shami, Davina Gurcharan )


# TABLE OF CONTENTS

1. Introduction
2. Overview
3. Functional requirements
4. Nonfunctional requirements
5. System models
   - 5.1. Use case model
   - 5.2. Dynamic models
   - 5.3. Object and class model
   - 5.4. User interface - navigational paths and screen mock-ups
6. Glossary & references

--------------------------------------------------------------------------------------------------------

# 1. Introduction

This document presents a comprehensive analysis of the 2D Turn-Based Pokémon-Like Game project. The game aims to capture the essence of classic turn-based monster collection RPGs while implementing modern game design principles and mechanics. This analysis document serves as a foundation for the design and implementation phases of the project.

The motivation behind developing this game stems from the enduring popularity of monster-collecting RPGs and the opportunity to create an engaging, accessible experience that appeals to both nostalgic fans of the genre and newcomers. By implementing core features like creature collection, strategic turn-based battles, and world exploration, we aim to deliver a compelling gaming experience that encourages replayability and strategic thinking.

This analysis document outlines the requirements, system models, and specifications necessary to guide the development process. It provides a clear roadmap for implementing the game's features and ensures that all stakeholders have a shared understanding of the project's scope and objectives.

# 2. Overview

The 2D Turn-Based Pokémon-Like Game is a role-playing game centered around collecting, training, and battling creatures in a vibrant 2D world. Players navigate through various environments, encounter wild creatures, battle other trainers, and progress through a narrative-driven adventure.

Core gameplay revolves around the following key elements:

- **Creature Collection**: Players can capture wild creatures encountered during exploration, building a diverse team with different abilities and strengths.

- **Turn-Based Combat**: Battles occur in a turn-based format where players select actions for their creatures, considering type advantages, status effects, and strategic positioning.

- **World Exploration**: Players navigate a 2D top-down world with various environments, interacting with NPCs, discovering items, and uncovering new areas.

- **Progression System**: Creatures gain experience from battles, level up to improve their stats, learn new abilities, and potentially evolve into stronger forms.

- **Score System**: Players earn points based on battle performance, collection completion, and achievement milestones, with a global leaderboard for competitive comparison.

The game will be developed using the Godot Engine, leveraging its 2D capabilities, scripting system, and cross-platform compatibility. The user interface will be intuitive and accessible, with clear visual feedback and streamlined controls.

# 3. Functional Requirements

## 3.1 Creature System

- **Creature Data Structure**
  - The game must store and manage data for multiple creature types with unique attributes
  - Each creature must have defined stats (HP, Attack, Defense, Speed, Special)
  - Creatures must have a type that determines battle effectiveness
  - Creatures must be able to learn and use up to 4 moves

- **Evolution System**
  - Creatures must be able to evolve at specific level thresholds
  - Evolution must change the creature's appearance and improve its base stats
  - Some evolutions may change or add types to the creature

- **Creature Collection**
  - Players must be able to capture wild creatures during encounters
  - The game must maintain a collection of captured creatures
  - Players must be able to view details about collected creatures

## 3.2 Battle System

- **Turn-Based Combat**
  - Battles must proceed in turns with player and opponent actions
  - Each turn must allow selection from available moves or other actions
  - Battle state must be maintained throughout the encounter

- **Move System**
  - Moves must have types, power values, accuracy ratings, and effects
  - Type effectiveness must modify damage based on predefined relationships
  - Status effects must alter creature performance (poison, sleep, etc.)

- **Battle AI**
  - Enemy trainers must make strategic decisions based on battle conditions
  - AI difficulty must scale with game progression

- **Battle Rewards**
  - Winning battles must award experience points to participating creatures
  - Battles must contribute to the player's score based on performance metrics

## 3.3 World & Exploration

- **Map System**
  - The game must provide navigable 2D environments with various terrains
  - Maps must contain interactive elements (NPCs, items, obstacles)
  - Transition between different areas must be seamless

- **NPC Interaction**
  - Players must be able to converse with non-player characters
  - NPCs must provide information, quests, or battle challenges

- **Item System**
  - Players must be able to collect, store, and use various items
  - Items must have different effects (healing, capturing creatures, etc.)

- **Environmental Interaction**
  - Certain areas must require specific conditions to access (abilities, items, etc.)
  - Different terrains may trigger special events (wild encounters, etc.)

## 3.4 Progression System

- **Experience and Leveling**
  - Creatures must gain experience points from battles
  - Leveling up must improve creature stats and potentially unlock new moves
  - Experience requirements must increase with each level

- **Player Advancement**
  - The game must track player progress through achievements or badges
  - Story progression must unlock new areas and features

## 3.5 Score System

- **Point Calculation**
  - The game must award points based on battle performance metrics
  - Collection completion must provide bonus points
  - Special achievements must offer score multipliers

- **Leaderboard**
  - The game must maintain a persistent high score list
  - Players must be able to view their ranking compared to others

## 3.6 Game Management

- **Save/Load System**
  - Players must be able to save their game progress
  - Save data must include creature collection, player progress, and score

- **Settings and Configuration**
  - Players must be able to adjust game settings (sound, display, controls)
  - Settings must persist between game sessions

# 4. Nonfunctional Requirements

## 4.1 Performance Requirements

- **Response Time**
  - The game must respond to user input within 100ms
  - Battle animations must complete within 2 seconds
  - Map transitions must occur within 3 seconds

- **Resource Usage**
  - The game must operate with less than 500MB of RAM
  - CPU usage must remain below 50% on target hardware
  - Storage requirements must not exceed 1GB

## 4.2 Usability Requirements

- **User Interface**
  - Controls must be intuitive and consistent throughout the game
  - UI elements must be clearly visible and distinguishable
  - Text must be legible at the intended display resolution

- **Accessibility**
  - The game must support configurable controls
  - Color schemes must consider color-blind players
  - Text size must be adjustable for readability

## 4.3 Reliability Requirements

- **Stability**
  - The game must not crash more than once per 20 hours of gameplay
  - Save data must not become corrupted under normal operation

- **Error Handling**
  - The game must gracefully handle unexpected conditions
  - Error messages must be clear and actionable when necessary

## 4.4 Compatibility Requirements

- **Platform Support**
  - The game must run on Windows, macOS, and Linux operating systems
  - Performance must be consistent across supported platforms

- **Hardware Requirements**
  - Minimum specifications must be clearly defined
  - The game must scale appropriately to different screen resolutions

## 4.5 Security Requirements

- **Data Protection**
  - Save files must be protected from unauthorized modification
  - Leaderboard submissions must be validated to prevent cheating

## 4.6 Maintainability Requirements

- **Code Structure**
  - The codebase must follow consistent naming conventions and organization
  - Modules must be loosely coupled to facilitate future modifications

- **Documentation**
  - Code must be adequately commented for future maintenance
  - System architecture must be documented for reference

# 5. System Models

## 5.1 Use Case Model

### 5.1.1 Primary Actors
- Player
- Game System
- AI Opponent

### 5.1.2 Key Use Cases

**Start New Game**
- Actor: Player
- Description: Player initiates a new game session
- Preconditions: None
- Main Flow:
  1. Player selects "New Game" option
  2. System presents starter creature selection
  3. Player chooses a starter creature
  4. System initializes game state with selected creature
  5. Game begins in the starting area
- Postconditions: New game session is active with initial creature

**Battle Wild Creature**
- Actor: Player, Game System
- Description: Player encounters and battles a wild creature
- Preconditions: Player is in an area with wild creatures
- Main Flow:
  1. System determines random encounter
  2. Battle interface is displayed
  3. Player selects actions each turn
  4. System processes turn outcomes until battle concludes
  5. System awards experience and updates score
- Postconditions: Battle resolved, experience gained, potential creature capture

**Capture Creature**
- Actor: Player
- Description: Player attempts to capture a wild creature
- Preconditions: Player is in battle with a wild creature
- Main Flow:
  1. Player selects capture item
  2. System calculates capture probability
  3. System determines success or failure
  4. If successful, creature is added to collection
- Postconditions: Creature added to collection or capture failed

**Level Up Creature**
- Actor: Game System
- Description: Creature gains enough experience to increase level
- Preconditions: Creature has sufficient experience points
- Main Flow:
  1. System detects experience threshold reached
  2. System increases creature level
  3. System recalculates creature stats
  4. System checks for new moves or evolution
  5. Player is notified of level up
- Postconditions: Creature has increased level and improved stats

**Evolve Creature**
- Actor: Game System, Player
- Description: Creature evolves into a stronger form
- Preconditions: Creature meets evolution requirements
- Main Flow:
  1. System detects evolution conditions met
  2. Player is prompted to confirm evolution
  3. If confirmed, system transforms creature
  4. System updates creature stats and appearance
  5. Player is shown evolution animation
- Postconditions: Creature has evolved with new form and stats

**Save Game**
- Actor: Player
- Description: Player saves current game progress
- Preconditions: Active game session
- Main Flow:
  1. Player selects save option
  2. System serializes game state
  3. System writes data to storage
  4. System confirms successful save
- Postconditions: Game progress is persisted to storage

## 5.2 Dynamic Models

### 5.2.1 Battle Sequence Diagram

```
Player                  BattleSystem              Creature                 AI
   |                         |                        |                      |
   |---(Encounter)---------->|                        |                      |
   |                         |---(Initialize)-------->|                      |
   |                         |---(Initialize)----------------------->|       |
   |                         |---(Display Battle UI)->|                      |
   |                         |                        |                      |
   |<--(Request Action)------|                        |                      |
   |---(Select Move)-------->|                        |                      |
   |                         |---(Process Player Turn)>|                      |
   |                         |                        |                      |
   |                         |---(Request AI Action)------------------>|     |
   |                         |<--(Select Move)-------------------------|     |
   |                         |---(Process AI Turn)---->|                      |
   |                         |                        |                      |
   |<--(Update Battle State)-|                        |                      |
   |                         |---(Check Battle End)--->|                      |
   |                         |                        |                      |
   |<--(Battle Result)-------|                        |                      |
   |                         |---(Award Experience)--->|                      |
   |                         |---(Update Score)------>|                      |
```

### 5.2.2 Creature Evolution Activity Diagram

```
[Start] --> [Check Level] --> [Level >= Evolution Threshold?]
  |                                   |
  | No                                | Yes
  v                                   v
[Continue] <------ [Check Special Conditions] --> [Conditions Met?]
                                                      |
                                                      | Yes
                                                      v
                                                 [Prompt Player]
                                                      |
                                                      v
                                                 [Player Accepts?]
                                                      |
                                                      | Yes
                                                      v
                                                 [Play Animation]
                                                      |
                                                      v
                                                 [Update Creature Data]
                                                      |
                                                      v
                                                 [Learn New Moves?]
                                                      |
                                                      | Yes
                                                      v
                                                 [Update Moveset]
                                                      |
                                                      v
                                                 [End Evolution]
```

## 5.3 Object and Class Model

### 5.3.1 Core Classes

**Creature Class**
- Attributes:
  - id: String
  - name: String
  - type: String
  - level: Integer
  - experience: Integer
  - stats: Dictionary (hp, attack, defense, speed, special)
  - current_hp: Integer
  - status_effect: String
  - moves: Array
- Methods:
  - take_damage(amount): void
  - heal(amount): void
  - use_move(move_index): Dictionary
  - can_evolve(): Boolean
  - evolve(): void
  - get_description(): String

**BattleSystem Class**
- Attributes:
  - current_state: Enum
  - player_creature: Creature
  - enemy_creature: Creature
  - selected_move: Dictionary
  - battle_log: Array
  - turn_count: Integer
  - battle_result: Dictionary
- Methods:
  - start_battle(battle_data): void
  - change_state(new_state): void
  - update_creature_displays(): void
  - execute_move(attacker, target, move): void
  - calculate_damage(attacker, target, move_data): Integer
  - check_battle_end(): Boolean
  - end_battle(result): void

**GameManager Class**
- Attributes:
  - current_state: Enum
  - player_name: String
  - player_creatures: Array
  - player_items: Dictionary
  - player_score: Integer
  - player_badges: Array
  - current_map: String
  - visited_locations: Array
  - completed_events: Array
- Methods:
  - initialize_player(): void
  - create_creature(creature_id, level): Creature
  - calculate_stats(base_stats, level): Dictionary
  - change_state(new_state): void
  - start_battle(opponent_data): void
  - add_score(points, reason): void
  - save_game(): void
  - load_game(): void

**DataLoader Class**
- Attributes:
  - creatures: Dictionary
  - moves: Dictionary
  - type_chart: Dictionary
- Methods:
  - load_all_data(): void
  - load_json_file(file_path): Dictionary
  - scan_creature_sprites(): void
  - get_creature(creature_id): Dictionary
  - get_move(move_id): Dictionary
  - get_type_effectiveness(attacking_type, defending_type): Float

**ExperienceSystem Class**
- Methods:
  - calculate_experience(victor, defeated): Integer
  - add_experience(creature, exp_amount): Boolean
  - calculate_level_from_experience(creature): Integer
  - get_experience_curve(creature): String
  - get_exp_for_level(curve, level): Integer
  - update_stats_on_level_up(creature, old_level, new_level): void
  - check_evolution(creature): Boolean
  - check_new_moves(creature, old_level, new_level): Array

**ScoreSystem Class**
- Attributes:
  - combo_multiplier: Float
  - difficulty_multiplier: Float
  - current_score: Integer
  - score_history: Array
  - high_scores: Array
- Methods:
  - add_score(points, category, reason): void
  - add_battle_win_score(opponent_level, turns_taken, hp_remaining, hp_max): void
  - check_high_score(): Boolean
  - save_score(player_name): Integer
  - load_high_scores(): Array
  - reset_score(): void

### 5.3.2 Class Relationships

- **GameManager** manages the overall game state and coordinates between subsystems
- **BattleSystem** handles battle logic and interacts with Creature instances
- **Creature** represents individual monsters with stats and abilities
- **DataLoader** provides data from JSON files to other classes
- **ExperienceSystem** manages creature growth and evolution
- **ScoreSystem** tracks player performance and maintains high scores

## 5.4 User Interface - Navigational Paths and Screen Mock-ups

### 5.4.1 Main Navigation Flow

```
[Main Menu] --> [New Game] --> [Starter Selection] --> [Game World]
    |
    |--> [Continue] --> [Game World]
    |
    |--> [Options] --> [Settings Screen] --> [Main Menu]
    |
    |--> [High Scores] --> [Leaderboard Screen] --> [Main Menu]
    |
    |--> [Credits] --> [Credits Screen] --> [Main Menu]
    |
    |--> [Quit]
```

### 5.4.2 In-Game Navigation

```
[Game World] --> [Menu] --> [Creature Roster] --> [Creature Details] --> [Menu]
    |               |
    |               |--> [Items] --> [Item Use] --> [Menu]
    |               |
    |               |--> [Save] --> [Game World]
    |               |
    |               |--> [Options] --> [Menu]
    |               |
    |               |--> [Quit to Main Menu] --> [Main Menu]
    |
    |--> [Battle] --> [Move Selection] --> [Battle Resolution] --> [Game World]
                        |
                        |--> [Item Use] --> [Battle]
                        |
                        |--> [Creature Switch] --> [Battle]
                        |
                        |--> [Run] --> [Game World]
```

### 5.4.3 Screen Mock-ups

**Main Menu Screen**
- Title at top center
- Version number at bottom right
- Centered vertical menu with options:
  - Start Game
  - Continue
  - Options
  - High Scores
  - Credits
  - Quit
- Background artwork featuring game creatures

**Battle Screen**
- Enemy creature at top right with health bar
- Player creature at bottom left with health bar and experience bar
- Battle menu at bottom with options:
  - Fight (expands to show moves)
  - Item
  - Creature
  - Run
- Battle log/text box above battle menu
- Background varies based on battle location

**World Screen**
- Top-down view of current map area
- Player character centered or in lower portion of screen
- HUD elements:
  - Mini-map in corner
  - Current score display
  - Menu button
  - Quick access to first creature's status

**Creature Roster Screen**
- Grid or list of player's creatures
- Each entry shows:
  - Creature sprite
  - Name and level
  - Health status
  - Type indicator
- Selection highlights creature for detailed view

**Creature Detail Screen**
- Large creature sprite
- Name, type, and level
- Stats display (HP, Attack, Defense, Speed, Special)
- Experience bar with next level indicator
- Move list with type, power, and PP
- Description text

# 6. Glossary & References

## 6.1 Glossary

**Creature**: Collectible monsters with unique stats, abilities, and types that players can capture, train, and battle.

**Type**: Elemental classification (Fire, Water, Grass, etc.) that determines strengths and weaknesses in battle.

**Move**: An action a creature can perform in battle, with associated type, power, and effects.

**Evolution**: The process by which a creature transforms into a stronger form, typically triggered by reaching a certain level.

**Experience Points (XP)**: Units gained from battles that contribute to a creature's growth and level progression.

**Turn-Based Combat**: Battle system where players and opponents take alternating turns to select and execute actions.

**Status Effect**: Temporary condition affecting a creature's performance (poison, sleep, paralysis, etc.).

**NPC**: Non-Player Character; computer-controlled game character that provides information, items, or battle challenges.

**Godot Engine**: The open-source game development platform used to create this project.

**GDScript**: Python-like scripting language used in the Godot Engine.

## 6.2 References

1. Godot Engine Documentation: https://docs.godotengine.org/

2. Game Design Patterns for Building Engaging RPGs, Game Developer Conference 2018

3. "The Art of Game Design: A Book of Lenses" by Jesse Schell

4. "Game Programming Patterns" by Robert Nystrom

5. Pokémon Game Mechanics: https://bulbapedia.bulbagarden.net/wiki/Gameplay

-------------------------------------------------------------------------------------------------------------------