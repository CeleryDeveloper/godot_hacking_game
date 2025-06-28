extends Node
class_name TimeManager

#Stores the custom 'class_name' 
#as there is no way to access the name declared using the 'class_name' keyword
const _class: String = "TimeManager"

#The time in minutes from 00:00
var time: int = 0

#The current day starting at 1
var day: int = 1


#Updates time every time the 'MinuteTimer' cycles
func _time_cycle():
	time += 1
	if time >= 1440:
		day += 1
		time = 0


#Returns the current time in minutes since 00:00
func _get_time_minutes() -> int:
	return time


#Returns the current time in minutes since 00:00
func _get_time_hours() -> float:
	var currentHours: float = time / 60
	return currentHours


#Returns the current time formated in 24hr time hh:mm
func _get_time_formated() -> String:
	var hours = _get_time_hours()
	return str(int(floor(hours))).pad_zeros(2) + ":" + str(time - int(hours) * 60).pad_zeros(2)


#Sets the current time
func _set_time(minutes: int):
	time = minutes
