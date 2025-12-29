extends Control
class_name Notification

@onready var header: RichTextLabel = $PanelOut/Margin/PanelIn/Rows/Header
@onready var content: RichTextLabel = $PanelOut/Margin/PanelIn/Rows/Content
@onready var pauseTimer: Timer = $Timer

var headerText: String = "Debug"
var contentText: String = "debug"

#Target & default positions for the notification animation
var targetPos: Vector2 = Vector2(632, 0)
var defaultPos: Vector2 = Vector2(1152, 0)
#Time it takes for the animation to slide in and out
var time: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	header.text = headerText
	content.text = contentText
	start_animation()


#Slides the notification into frame
func start_animation():
	add_tween("position", targetPos, time)
	pauseTimer.start()


#Slides the notification out of frame then removes itself from the tree
func end_animation():
	var tween = add_tween("position", defaultPos, time)
	await tween.finished
	queue_free()


func set_header_text(text: String):
	headerText = text


func set_content_text(text: String):
	contentText = text


#Creates a tween, used to change the position of the notification smoothly
func add_tween(property: String, value, seconds: float) -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, property, value, seconds).set_trans(Tween.TRANS_LINEAR)
	return tween
