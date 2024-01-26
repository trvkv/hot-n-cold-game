@tool
extends Node2D

@export var curve_resolution: int = 10:
	get:
		return curve_resolution
	set(value):
		curve_resolution = value
		update_line()

@export var chaos_amount: float:
	get:
		return chaos_amount
	set(value):
		chaos_amount = value
		update_line()

@export var strength: float:
	get:
		return strength
	set(value):
		strength = value
		update_line()

@export var noise: Noise
@export var line: Line2D

@onready var path: Path2D = $Path2D

var base_curve: Curve2D
var t: float = 0.0
var debug_draw_position: Vector2

func _ready():
	if is_instance_valid(path):
		base_curve = path.curve
	else:
		base_curve = null

func update_line() -> void:
	if not is_instance_valid(base_curve) or not is_instance_valid(line) or not is_instance_valid(noise):
		return

	#
	# TO JEST NAJWAZNIEJSZA CZESC.
	#
	
	# tutaj zaczyna się część proceduralna. Po prostu przesuwany nieco istniejące punkty.
	# Można zrobić tutaj znacznie więcej, np. modyfikować całą krzywą Beziera, aby uzyskać
	# bardziej skomplikowane rezultaty
	
	# inizjujemy randomizer
	randomize()
	
	# kopiujemy krzywą, żeby przez przypadek nie zmienić właściwości tej, która jest w scenie.
	var c: Curve2D = base_curve.duplicate(true)
	
	# losujemy miejsce od którego zaczynamy przeglądać teksturę 'noise'. Ograniczamy losowanie do
	# jakichś dużych, ale za dużych wartości. Samo randi() mogłoby zacząć zwracać zero.
	var rp: Vector2 = Vector2(randi() % (1024 * 10), randi() % (1024 * 10))
	
	# zmieniamy pozycje punktów
	for i in range(c.point_count):
		var point: Vector2 = c.get_point_position(i)
		var random_noise_x: float = noise.get_noise_2d(rp.x + i * chaos_amount * 10, rp.y)
		var random_noise_y: float = noise.get_noise_2d(rp.x, rp.y + i * chaos_amount * 10)
		
		c.set_point_position(i, Vector2(point.x + (random_noise_x * strength), point.y + (random_noise_y * strength)))
	
	# 'tesselate' powoduje "pokrojenie" krzywej Beziera na określoną ilość punktów.
	var points: PackedVector2Array = c.tessellate(curve_resolution)

	# wpisujemy gotowe punkty do wskazanego Line2D. Można równie dobrze stworzyć tutaj
	# nowy Line2D, nadać jej określone właściwości i wrzucać ją na planszę.
	# Nie robię tego ze względów praktycznych.
	line.clear_points()
	for point in points:
		line.add_point(point)
