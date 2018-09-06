#!/usr/bin/env python

from gpiozero import Buzzer

bz = Buzzer(4)

while True:
  bz.beep(0.25, 0.25, None, False)
