extends Node
class_name TimeManager


signal passout


#Stores the custom 'class_name' 
#as there is no way to access the name declared using the 'class_name' keyword
const _class: String = "TimeManager"


#The time in minutes from 00:00
var time: int = 0

#The current day starting at 1
var day: int = 1

#The time in minutes since the player has last slept
var wakeTime: int = 0

#The maximum time the player can stay awake in minutes
var maxWakeTime: int = 1680


#Updates time every time the 'MinuteTimer' cycles
func _time_cycle():
	time += 1
	wakeTime += 1
	if time >= 1440:
		day += 1
		time = 0 + (time - 1440)
	if wakeTime > maxWakeTime:
		passout.emit()
		player_sleep()


#Runs when player sleeps or passes out, adds 8hrs to the current time
#and sets the time since last rest to 0
func player_sleep():
	time += 480
	wakeTime = 0


#Returns the current time in minutes since 00:00
func get_time_minutes() -> int:
	return time


#Returns the current time in minutes since 00:00
func get_time_hours() -> float:
	var currentHours: float = time / 60
	return currentHours


#Returns the current time formatted in 24hr time hh:mm
func get_time_formatted() -> String:
	var hours = get_time_hours()
	return str(int(floor(hours))).pad_zeros(2) + ":" + str(time - int(hours) * 60).pad_zeros(2)


#Returns the time since last rest in 24hr time hh:mm
func get_wake_time_formatted() -> String:
	var wakeHours = wakeTime / 60
	return str(int(floor(wakeHours))).pad_zeros(2) + ":" + str(wakeTime - int(wakeHours) * 60).pad_zeros(2)


#Returns the maxWakeTime in 24hr format hh:mm
func get_max_wake_time_formatted() -> String:
	var maxWakeHours = maxWakeTime / 60
	return str(int(floor(maxWakeHours))).pad_zeros(2) + ":" + str(maxWakeTime - int(maxWakeHours) * 60).pad_zeros(2)


#Returns the current wakeTime
func get_wake_time() -> int:
	return wakeTime


#Returns the current maxWakeTime
func get_max_wake_time() -> int:
	return maxWakeTime


#Returns the current day
func get_day() -> int:
	return day


#Sets the current time
func set_time(minutes: int):
	time = minutes


#Sets the current day
func set_day(newDay: int):
	day = newDay


#Sets the current wakeTime
func set_wake_time(newWakeTime: int):
	wakeTime = newWakeTime


#Sets the maximumWakeTime
func set_max_wake_time(newMaxWakeTime: int):
	maxWakeTime = newMaxWakeTime
