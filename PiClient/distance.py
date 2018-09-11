#!/usr/bin/env python

import RPi.GPIO as GPIO
import time
import socket
import sys
 
GPIO.setmode(GPIO.BCM)

X_TRIG = 22
X_ECHO = 27
Y_TRIG = 5
Y_ECHO = 6
Z_TRIG = 23
Z_ECHO = 24

GPIO.setup(X_TRIG, GPIO.OUT)
GPIO.setup(Y_TRIG, GPIO.OUT)
GPIO.setup(Z_TRIG, GPIO.OUT)
GPIO.setup(X_ECHO, GPIO.IN)
GPIO.setup(Y_ECHO, GPIO.IN)
GPIO.setup(Z_ECHO, GPIO.IN)

def distance():
    x_start = x_stop = time.time()
    
    GPIO.output(X_TRIG, GPIO.HIGH)
    time.sleep(0.00001)
    GPIO.output(X_TRIG, GPIO.LOW)
    
    while GPIO.input(X_ECHO) == 0:
        x_start = time.time()
    
    while GPIO.input(X_ECHO) == 1:
        x_stop = time.time()
    
    x_elapsed = x_stop - x_start
    x_distance = min((x_elapsed * 34300) / 2, 50)
    
    time.sleep(0.1)
    
    GPIO.output(Y_TRIG, GPIO.HIGH)
    time.sleep(0.00001)
    GPIO.output(Y_TRIG, GPIO.LOW)
    
    y_start = y_stop = time.time()
    
    while GPIO.input(Y_ECHO) == 0:
        y_start = time.time()
    
    while GPIO.input(Y_ECHO) == 1:
        y_stop = time.time()
    
    y_elapsed = y_stop - y_start
    y_distance = min((y_elapsed * 34300) / 2, 50)
    
    time.sleep(0.1)
    
    GPIO.output(Z_TRIG, GPIO.HIGH)
    time.sleep(0.00001)
    GPIO.output(Z_TRIG, GPIO.LOW)
    
    z_start = z_stop = time.time()
    
    while GPIO.input(Z_ECHO) == 0:
        z_start = time.time()
    
    while GPIO.input(Z_ECHO) == 1:
        z_stop = time.time()
    
    z_elapsed = z_stop - z_start
    z_distance = min((z_elapsed * 34300) / 2, 50)
    
    return (x_distance, y_distance, z_distance)

if __name__ == '__main__':
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    except socket.error, msg:
        print 'Failed to create socket. Error code: ' + str(msg[0]) + ' , Error message : ' + msg[1]
        sys.exit();
    
    try:
        while True:
            (x_distance, y_distance, z_distance) = distance()
            print("x: %.1f cm y: %.1f cm z: %.1f cm" % 
                  (x_distance, y_distance, z_distance))
            try:
                s.sendto("b:" + 
                         str(int(x_distance)) + "," + 
                         str(int(y_distance)) + "," + 
                         str(int(z_distance)), 
                         ("192.168.1.7", 8080))
            except socket.error:
                print 'Send failed'
                # sys.exit()
            
            time.sleep(0.1)
    
    except KeyboardInterrupt:
        print("Measurement stopped by User")
        GPIO.cleanup()
