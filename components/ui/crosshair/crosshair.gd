extends CenterContainer
class_name Crosshair

var current_color: Color = Color(1.0, 1.0, 1.0, 0.5)

var default_color: Color = Color(1.0, 1.0, 1.0, 0.4)
var select_color: Color = Color(1.0, 1.0, 1.0, 1.0)
var error_color: Color = Color(1.0, 0.0, 0.0, 0.75)
var size_mult: float = 1.0

var dist: float = 0.0
var dist_mult: float = 1.0

var alpha_add: float = 0.0
var alpha_size_mult: float = 1.0

var can_select: bool = false
var selected: bool = false
var doing_error: bool = false

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if (dist > 0.1):
		dist_mult = 3.0 - dist
		dist_mult = clampf(dist_mult, 1.0, 3.0)
	else:
		dist_mult = 1.0
		
	if can_select && !selected:
		alpha_add = 0.5
		alpha_size_mult = 1.5
	else:
		alpha_add = 0.0
		alpha_size_mult = 1.0
	
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2(0,0), Game.settings.crosshair_radius * size_mult * dist_mult * alpha_size_mult, current_color + Color(0,0,0,alpha_add))

func do_lesser_error() -> void:
	if tween: tween.kill()
	tween = self.create_tween()
	
	tween.set_parallel().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "size_mult", 2.0, 0.1)
	tween.set_parallel(false)
	tween.tween_callback(resize_out)

func do_error() -> void:
	if tween: tween.kill()
	tween = self.create_tween()
	
	tween.set_parallel().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "current_color", error_color, 0.1)
	tween.tween_property(self, "size_mult", 2.0, 0.1)
	tween.set_parallel(false)
	tween.tween_callback(resize_out)

func resize_in() -> void:
	selected = true
	
	if tween: tween.kill()
	tween = self.create_tween()
	
	tween.set_parallel().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "current_color", select_color, 0.3)
	tween.tween_property(self, "size_mult", 2.0, 0.3)

func resize_out() -> void:
	selected = false
	
	if tween: tween.kill()
	tween = self.create_tween()
	
	tween.set_parallel().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "current_color", default_color, 0.3)
	tween.tween_property(self, "size_mult", 1.0, 0.3)
