extends GutTest

func test_inventory_create():
    var inventory: ItemInventory = ItemInventory.new()
    assert_true(is_instance_valid(inventory), "ItemInventory not created correctly")
    inventory.free()

func test_inventory_management():
    var inventory: ItemInventory = ItemInventory.new()
    assert_true(inventory.get_items().size() == 0, "Inventory should be empty")

    var favourite = ItemFavourite.new()
    inventory.add_item(favourite)
    assert_true(inventory.get_items().size() == 1, "'favourite' not added connectly")
    assert_true(inventory.has_item(favourite), "Inventory should have 'favourite' item")

    var key = ItemKey.new()
    inventory.add_item(key)
    assert_true(inventory.get_items().size() == 2, "'key' not added correctly")
    assert_true(inventory.has_item(key), "Inventory should have 'key' item")

    var trap = ItemTrap.new()
    inventory.add_item(trap)
    assert_true(inventory.get_items().size() == 3, "'trap' not added correctly")
    assert_true(inventory.has_item(trap), "Inventory should have 'trap' item")

    inventory.remove_item(favourite)
    assert_true(inventory.get_items().size() == 2, "'favourite' not removed correctly")
    assert_false(inventory.has_item(favourite), "Inventory shouldn't have 'favourite' item")

    inventory.remove_item(key)
    assert_true(inventory.get_items().size() == 1, "'key' not removed correctly")
    assert_false(inventory.has_item(key), "Inventory shouldn't have 'key' item")

    inventory.remove_item(trap)
    assert_true(inventory.get_items().size() == 0, "'trap' not removed correctly")
    assert_false(inventory.has_item(trap), "Inventory shouldn't have 'trap' item")

    trap.free()
    key.free()
    favourite.free()
    inventory.free()
