#!/usr/bin/env python3

########################################################################################

#Video File
VIDEO1 = "Passif20MBS.mp4"
VIDEO2 = "Montage20MBS.mp4"
CHEMIN_VIDEO = "/boot/mirror/"
TIME_VIDEO2 = 30.0 # mettre la duree de chaque video active

# Sonar
DIST_MIN = 100
DIST_MAX = 110

#set GPIO Pins
GPIO_TRIGGER = 27
GPIO_ECHO = 17

########################################################################################

from omxplayer.player import OMXPlayer
from pathlib import Path
from time import sleep

#Libraries
import RPi.GPIO as GPIO
import time

player1 = OMXPlayer(CHEMIN_VIDEO+VIDEO1, dbus_name='org.mpris.MediaPlayer2.omxplayer2', args="--loop --orientation 180") # , args="--loop"
player2 = OMXPlayer(CHEMIN_VIDEO+VIDEO2, dbus_name='org.mpris.MediaPlayer2.omxplayer3', args="--orientation 180")

player2.pause()

GPIO.setmode(GPIO.BCM)

#set GPIO direction (IN / OUT)
GPIO.setup(GPIO_TRIGGER, GPIO.OUT)
GPIO.setup(GPIO_ECHO, GPIO.IN)

def distance():
	# set Trigger to HIGH
	GPIO.output(GPIO_TRIGGER, True)

	# set Trigger after 0.01ms to LOW
	time.sleep(0.00001)
	GPIO.output(GPIO_TRIGGER, False)

	StartTime = time.time()
	StopTime = time.time()

	# save StartTime
	while GPIO.input(GPIO_ECHO) == 0:
		StartTime = time.time()

	# save time of arrival
	while GPIO.input(GPIO_ECHO) == 1:
		StopTime = time.time()

	# time difference between start and arrival
	TimeElapsed = StopTime - StartTime
	# multiply with the sonic speed (34300 cm/s)
	# and divide by 2, because there and back
	distance = (TimeElapsed * 34300) / 2

	return distance


play = False
start = 0

try:
	while True:
		dist = distance()
		print ("Measured Distance = %.1f cm" % dist)
		if (dist > DIST_MIN and dist < DIST_MAX and not play):
			print("Play video")
			player1.pause()
			player2.set_position(0)
			player2.play()
			play = True
			start = time.time()
		if (play and time.time() > start + TIME_VIDEO2):
			play = False
			player2.pause()
			player1.set_position(0)
			player1.play()
		time.sleep(0.10)
	# Reset by pressing CTRL + C
except KeyboardInterrupt:
	GPIO.cleanup()
	player1.quit()
	player2.quit()
