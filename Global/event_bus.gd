extends Node

signal interact(interactee, interactor, action)
signal update_interactees(player, interactees, active_interactee)
signal trigger_interaction(player, interaction_area)
signal switch_interaction(player, interaction_area)
signal update_items(player, items, active_item)
signal switch_item(player)
signal update_actions(player, actions, active_action)
signal switch_action(player)

signal action_successful(interactor, interactee, action, custom_data)
signal action_unsuccessful(interactor, interactee, action, custom_data)
