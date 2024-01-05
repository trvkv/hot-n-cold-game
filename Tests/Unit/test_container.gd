extends GutTest

func test_container_create():
    var c: ItemContainer = ItemContainer.new()
    assert_true(is_instance_valid(c), "ItemContainer created correctly")
    c.free()

func test_container_management():
    pass
