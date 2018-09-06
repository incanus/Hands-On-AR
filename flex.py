#!/usr/bin/env python

import time
# import Adafruit_GPIO.SPI as SPI
import Adafruit_MCP3008
import socket
import sys

CLK  = 18
MISO = 23
MOSI = 24
CS   = 25
mcp = Adafruit_MCP3008.MCP3008(clk=CLK, cs=CS, miso=MISO, mosi=MOSI)

VCC = 3.3
RDIV_THUMB = 47000
RDIV_FINGER = 10000
STRAIGHT_THUMB = 38000
STRAIGHT_FINGER = 10000
BEND_THUMB = 110000
BEND_FINGER = 20000
SUB_THUMB = 45
SUB_FINGER = 90

try:
    #create an AF_INET, STREAM socket (TCP)
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
except socket.error, msg:
    print 'Failed to create socket. Error code: ' + str(msg[0]) + ' , Error message : ' + msg[1]
    sys.exit();

s.connect(("192.168.1.4", 7777))

while True:
    raws = []
    ratios = []
    labels = ["thumb ", "index ", "middle", "ring  ", "pinky "]
    
    thumbADC = mcp.read_adc(0)
    thumbV = thumbADC * VCC / 1023
    thumbR = RDIV_THUMB * VCC / max(thumbV - 1, 0.001)
    # print("Thumb:")
    # print("  " + str(thumbR) + " ohms")
    thumbAngle = (thumbR / (BEND_THUMB - STRAIGHT_THUMB) * 90) - SUB_THUMB
    # print("  " + str(thumbAngle) + " degrees")
    flex = int(min((thumbAngle - 187) / 200, 1) * 10)
    raws.append(str(flex))
    ratios.append("  =" + ("=" * flex))
    
    for i in range(4):
        fingerADC = mcp.read_adc(i + 1)
        fingerV = fingerADC * VCC / 1023
        fingerR = RDIV_FINGER * VCC / max(fingerV - 1, 0.001)
        # print("Finger " + str(i + 1) + ":")
        # print("  " + str(fingerR) + " ohms")
        fingerAngle = (fingerR / (BEND_FINGER - STRAIGHT_FINGER) * 90) - SUB_FINGER
        # print("  " + str(fingerAngle) + " degrees")
        flex = int(min((fingerAngle - 400) / 1000, 1) * 10)
        raws.append(str(flex))
        ratios.append("  =" + ("=" * flex))
    
    print("  " + labels[0] + ratios[0])
    for i in range(4):
        print("  " + labels[i + 1] + ratios[i + 1])
    
    print("")
    
    try:
        s.sendall(",".join(raws))
    except socket.error:
        print 'Send failed'
        # sys.exit()
    
    time.sleep(0.25)
