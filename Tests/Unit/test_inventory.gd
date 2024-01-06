extends GutTest

func test_inventory_create():
    var inventory: ItemInventory = ItemInventory.new()
    assert_true(is_instance_valid(inventory), "ItemInventory created correctly")
    inventory.free()

func test_inventory_management():
    var inventory: ItemInventory = ItemInventory.new()
    assert_true(inventory.get_items().size() == 0, "Inventory is empty")

    var favourite = ItemFavourite.new()
    inventory.add_item(favourite)
    assert_true(inventory.get_items().size() == 1, "'favourite' added connectly")
    assert_true(inventory.has_item(favourite), "Inventory has 'favourite' item")

    var key = ItemKey.new()
    inventory.add_item(key)
    assert_true(inventory.get_items().size() == 2, "'key' added correctly")
    assert_true(inventory.has_item(key), "Inventory has 'key' item")

    var trap = ItemTrap.new()
    inventory.add_item(trap)
    assert_true(inventory.get_items().size() == 3, "'trap' added correctly")
    assert_true(inventory.has_item(trap), "Inventory has 'trap' item")

    inventory.remove_item(favourite)
    assert_true(inventory.get_items().size() == 2, "'favourite' removed correctly")
    assert_false(inventory.has_item(favourite), "Inventory do not have 'favourite'")

    inventory.remove_item(key)
    assert_true(inventory.get_items().size() == 1, "'key' removed correctly")
    assert_false(inventory.has_item(key), "Inventory do not have 'key'")

    inventory.remove_item(trap)
    assert_true(inventory.get_items().size() == 0, "'trap' removed correctly")
    assert_false(inventory.has_item(trap), "Inventory do not have 'trap'")

    trap.free()
    key.free()
    favourite.free()
    inventory.free()
