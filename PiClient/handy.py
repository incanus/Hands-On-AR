#!/usr/bin/env python

import time
import Adafruit_MCP3008
import socket
import sys

sys.path.append('LSM6DS3')
from LSM6DS3 import LSM6DS3

CLK  = 18
MISO = 23
MOSI = 24
CS   = 25
mcp = Adafruit_MCP3008.MCP3008(clk=CLK, cs=CS, miso=MISO, mosi=MOSI)

lsm = LSM6DS3()

VCC = 3.316
RDIV_THUMB = 47100
RDIV_FINGER = 10000
STRAIGHT_THUMB = 68000
STRAIGHT_FINGER = 101100
BEND_THUMB = 98000
BEND_FINGER = 250000

CH_X = 5
CH_Y = 6
CH_K = 7

X_MIN = 0.0
X_MID = 1.62
X_MAX = 3.3
Y_MIN = 0.0
Y_MID = 1.59
Y_MAX = 3.3
K_OFF = 1.65
K_ON  = 0.0

SCALE = 6

try:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
except socket.error, msg:
    print 'Failed to create socket. Error code: ' + str(msg[0]) + ' , Error message : ' + msg[1]
    sys.exit();

while True:
    raws = []
    ratios = []
    labels = ["thumb ", "index ", "middle", "ring  ", "pinky "]
    
    # fingers
    thumbADC = mcp.read_adc(0)
    thumbV = thumbADC * VCC / 1023
    thumbR = RDIV_THUMB * (VCC / max(thumbV - 1, 0.001))
    thumbR = min(BEND_THUMB, max(thumbR, STRAIGHT_THUMB))
    # print("Thumb:")
    # print("  " + str(thumbR) + " ohms")
    thumbAngle = ((thumbR - STRAIGHT_THUMB) / (BEND_THUMB - STRAIGHT_THUMB)) * 90
    # print("  " + str(thumbAngle) + " degrees")
    flex = int((thumbAngle / 90) * 10)
    raws.append(str(flex))
    ratios.append("  =" + ("=" * flex))
    
    for i in range(4):
        fingerADC = mcp.read_adc(i + 1)
        fingerV = fingerADC * VCC / 1023
        fingerR = RDIV_FINGER * VCC / max(fingerV - 1, 0.001)
        fingerR = min(BEND_FINGER, max(fingerR, STRAIGHT_FINGER))
        # print("Finger " + str(i + 1) + ":")
        # print("  " + str(fingerR) + " ohms")
        fingerAngle = ((fingerR - STRAIGHT_FINGER) / (BEND_FINGER - STRAIGHT_FINGER)) * 90
        # print("  " + str(fingerAngle) + " degrees")
        flex = int((fingerAngle / 90) * 10)
        raws.append(str(flex))
        ratios.append("  =" + ("=" * flex))
    
    print("  " + labels[0] + ratios[0])
    for i in range(4):
        print("  " + labels[i + 1] + ratios[i + 1])
    
    print("")
    
    # gyro
    xRot = str(int(lsm.getXRotation()))
    yRot = str(int(lsm.getYRotation()))
    zRot = str(int(lsm.getZRotation()))
    raws.extend([xRot, yRot, zRot])
    print("  x:" + xRot)
    print("  y:" + yRot)
    print("  z:" + zRot)
    
    print("")
    
    # joystick
    xADC = mcp.read_adc(CH_X)
    x = round((xADC * VCC) / 1023, 2)
    if x < X_MID:
        xp = (X_MID - x) / -X_MID
    elif x == X_MID:
        xp = 0
    else:
        xp = min((x - X_MID) / X_MID, 1)
    print("  x pos: " + str(xp))
    
    yADC = mcp.read_adc(CH_Y)
    y = round((yADC * VCC) / 1023, 2)
    if y < Y_MID:
        yp = (Y_MID - y) / -Y_MID
    elif y == Y_MID:
        yp = 0
    else:
        yp = min((y - Y_MID) / Y_MID, 1)
    print("  y pos: " + str(yp))
    
    kADC = mcp.read_adc(CH_K)
    k = (kADC * VCC) / 1023
    if k == K_ON:
        kp = 1
    else:
        kp = 0
    print("  k pos: " + str(kp))
    
    raws.extend([str(xp), str(yp), str(kp)])
    
    print("")
    
    try:
        s.sendto(",".join(raws), ("10.0.1.4", 8080))
    except socket.error:
        print 'Send failed'
        # sys.exit()
    
    time.sleep(0.1)
