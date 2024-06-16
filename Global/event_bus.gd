extends Node

signal interact(interactee, interactor, action)
signal update_interactees(player, interactees, active_interactee)
signal trigger_interaction(player, interaction_area)
signal switch_interaction(player, interaction_area)
signal update_items(player, items, active_item)
signal switch_item(player)
signal update_actions(player, actions, active_action)
signal switch_action(player)

signal set_trap(player, global_trap_position)
signal query_distance(player)
signal query_ready(player)
signal distance_updated(player, distance)

signal update_gameplay_stage(action, stage)

signal store_game_state(player, data_type, data)
signal retrieve_game_state(player, data_type, data)
signal game_state_updated(state_data)

signal action_successful(interaction_data)
signal action_unsuccessful(interaction_data)
