#!/usr/bin/env python

import sys
import time

sys.path.append('LSM6DS3')
from LSM6DS3 import LSM6DS3

lsm = LSM6DS3(address = 0x6b)

while True:
    print("x: " + str(int(lsm.getXRotation())))
    print("y: " + str(int(lsm.getYRotation())))
    print("z: " + str(int(lsm.getZRotation())) + "\n")
    
    time.sleep(0.5)
