extends Node
class_name MusicManager

@onready var level1: AudioStreamPlayer = $MusicLevel1

var chaosLevel: float = 1
var chaosLevel1PlayChance: int = 60 
var currentTrack: AudioStreamPlayer = null
var currentTrackStartingVolume: float = 0
var fadeInAmount: float = 0
 

#Function that runs every the 'MusicTimer' emits a signal
#Plays the appropriate track based on 'chaosLevel' (WIP)
func adaptive_music():
	if is_instance_valid(currentTrack) && currentTrack.playing == false:
		currentTrack.volume_db = currentTrackStartingVolume
		currentTrack = null
	if fadeInAmount != 0:
		_fade_in(currentTrack)
	if chaosLevel == 1 && currentTrack == null && randi_range(1, 60) == chaosLevel1PlayChance:
		_play_level_one()
		currentTrack = level1
		currentTrackStartingVolume = level1.volume_db
		fadeInAmount = -10
		currentTrack.volume_db = fadeInAmount + currentTrackStartingVolume


#Plays the calmest track
func _play_level_one():
	level1.play()


#Fades in the current track
func _fade_in(track: AudioStreamPlayer):
	track.volume_db = fadeInAmount + currentTrackStartingVolume
	fadeInAmount += 0.5
