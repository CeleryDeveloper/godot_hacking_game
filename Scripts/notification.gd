extends Control
class_name Notification

@onready var header: RichTextLabel = $PanelOut/Margin/PanelIn/Margin/Rows/Header
@onready var content: RichTextLabel = $PanelOut/Margin/PanelIn/Margin/Rows/Content
@onready var panelOut: PanelContainer = $PanelOut
@onready var pauseTimer: Timer = $Timer

var headerText: String = "Debug"
var contentText: String = "debug"
var gameManager: Game
#So position can wait until animation is finished to be adjust,
#position will not change otherwise
var currentTween: Tween = null

#Target & default positions for the notification animation
var targetPos: Vector2
var defaultPos: Vector2
#Time it takes for the animation to slide in and out
var time: float = 0.5

#Arrays for making sure Notifications stack properly
var otherExistingNotifications: Array[Notification] = []
var otherNewNotifications: Array[Notification] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	header.text = headerText
	content.text = contentText
	#Finds all existing notifications and adds them to the "otherExistingNotifications" array
	for child in gameManager.get_children():
		if child is Notification && child != self:
			otherExistingNotifications.append(child)
			child.new_notification(self)
	#Adjusts position depending on number of existing notifications
	position.y = panelOut.size.y * otherExistingNotifications.size()
	targetPos = Vector2(position.x - panelOut.size.x, position.y)
	defaultPos = position
	start_animation()


#Slides the notification into frame
func start_animation():
	var tween = add_tween("position", targetPos, time)
	await tween.finished
	currentTween = null
	pauseTimer.start()


#Slides the notification out of frame then removes itself from the tree
func end_animation():
	var tween = add_tween("position", defaultPos, time)
	await tween.finished
	currentTween = null
	for notif in otherExistingNotifications:
		if is_instance_valid(notif):
			notif.removed_notification(self)
	for notif in otherNewNotifications:
		if is_instance_valid(notif):
			notif.removed_notification(self)
	queue_free()


#Adds a notification to "otherNotifications" if it is in the array already,
#should be called by other notifications upon creation
func new_notification(newNotification: Notification):
	if newNotification in otherExistingNotifications || newNotification in otherNewNotifications:
		return
	otherNewNotifications.append(newNotification)


#Removes a specific notification from both notification arrays,
#should be called by other notifications upon deletion
func removed_notification(removedNotification: Notification):
	if removedNotification in otherExistingNotifications:
		otherExistingNotifications.erase(removed_notification)
	elif removedNotification in otherNewNotifications:
		otherNewNotifications.erase(removedNotification)
	else:
		return
	#Ensures y position updates properly even during animation
	if is_instance_valid(currentTween):
		await currentTween.finished
	position.y -= panelOut.size.y
	defaultPos = Vector2(defaultPos.x, defaultPos.y - panelOut.size.y)


func set_header_text(text: String):
	headerText = text


func set_content_text(text: String):
	contentText = text


func set_game_manager(manager: Game):
	gameManager = manager


#Creates a tween, used to change the position of the notification smoothly
func add_tween(property: String, value, seconds: float) -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, property, value, seconds).set_trans(Tween.TRANS_LINEAR)
	currentTween = tween
	return tween
