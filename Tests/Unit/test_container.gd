extends GutTest

func test_container_create():
    var c: ItemContainer = load("res://Scenes/Environment/item_container.tscn").instantiate()
    add_child_autofree(c)
    assert_true(is_instance_valid(c), "ItemContainer created correctly")

func test_mesh_setting():
    var c1: ItemContainer = load("res://Scenes/Environment/item_container.tscn").instantiate()
    var s1: PackedScene = load("res://Scenes/Environment/cube_with_collision.tscn")
    c1.container_mesh_scene = s1
    add_child_autofree(c1)
    assert_true(is_instance_valid(c1) and is_instance_valid(c1.container_mesh), "Adding mesh before ready is ok")

    var c2: ItemContainer = load("res://Scenes/Environment/item_container.tscn").instantiate()
    var s2: PackedScene = load("res://Scenes/Environment/cube_with_collision.tscn")
    add_child_autofree(c2)
    c2.container_mesh_scene = s2
    assert_true(is_instance_valid(c2) and is_instance_valid(c2.container_mesh), "Adding mesh after ready is ok")

func test_negative():
    var c: ItemContainer = load("res://Scenes/Environment/item_container.tscn").instantiate()
    add_child_autofree(c)

    var k: ItemKey = ItemKey.new()
    assert_false(c.retrieve(k), "Retrieve non existent ok")

    assert_true(c.peek().size() == 0, "Peek size is ok")
    assert_true(c.peek(&"ItemFavourite").size() == 0, "Fav peek filter is ok")
    assert_true(c.peek(&"ItemTrap").size() == 0, "Trap peek filter is ok")
    assert_true(c.peek(&"ItemKey").size() == 0, "Key peek filter is ok")

    assert_true(c.peek(&"SomeRandomItem").size() == 0, "Random peek filter is ok")

    k.free()

func test_container_management():
    var c: ItemContainer = load("res://Scenes/Environment/item_container.tscn").instantiate()
    add_child_autofree(c)

    var favourite: ItemFavourite = ItemFavourite.new()
    assert_true(c.put(favourite), "'favourite' put in the container")
    assert_true(c.peek().size() == 1, "Peek size is ok")
    assert_true(c.peek(&"ItemFavourite").size() == 1, "Peek filter is ok")

    var key: ItemKey = ItemKey.new()
    assert_true(c.put(key), "'key' put in the container")
    assert_true(c.peek().size() == 2, "Peek size is ok")
    assert_true(c.peek(&"ItemKey").size() == 1, "Peek filter is ok")

    var trap: ItemTrap = ItemTrap.new()
    assert_true(c.put(trap), "'trap' put in the container")
    assert_true(c.peek().size() == 3, "Peek size is ok")
    assert_true(c.peek(&"ItemTrap").size() == 1, "Peek filter is ok")

    assert_true(c.retrieve(trap), "'trap' retrieved")
    assert_true(c.peek().size() == 2, "Peek size is ok")
    assert_true(c.peek(&"ItemTrap").size() == 0, "Peek filter is ok")

    assert_true(c.retrieve(key), "'key' retrieved")
    assert_true(c.peek().size() == 1, "Peek size is ok")
    assert_true(c.peek(&"ItemKey").size() == 0, "Peek filter is ok")

    assert_true(c.retrieve(favourite), "'favourite' retrieved")
    assert_true(c.peek().size() == 0, "Peek size is ok")
    assert_true(c.peek(&"ItemFavourite").size() == 0, "Peek filter is ok")

    favourite.free()
    key.free()
    trap.free()
