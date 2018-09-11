#!/usr/bin/env python

import RPi.GPIO as GPIO
import time
 
GPIO.setmode(GPIO.BCM)

Z_TRIG = 23
Z_ECHO = 24
X_TRIG = 22
X_ECHO = 27
Y_TRIG = 5
Y_ECHO = 6

GPIO.setup(Z_TRIG, GPIO.OUT)
GPIO.setup(X_TRIG, GPIO.OUT)
GPIO.setup(Y_TRIG, GPIO.OUT)
GPIO.setup(Z_ECHO, GPIO.IN)
GPIO.setup(X_ECHO, GPIO.IN)
GPIO.setup(Y_ECHO, GPIO.IN)

def distance():
    GPIO.output(Z_TRIG, GPIO.HIGH)
    time.sleep(0.00001)
    GPIO.output(Z_TRIG, GPIO.LOW)
    
    z_start = z_stop = time.time()
    
    while GPIO.input(Z_ECHO) == 0:
        z_start = time.time()
    
    while GPIO.input(Z_ECHO) == 1:
        z_stop = time.time()
    
    z_elapsed = z_stop - z_start
    z_distance = min((z_elapsed * 34300) / 2, 40)
    
    x_start = x_stop = time.time()
    
    GPIO.output(X_TRIG, GPIO.HIGH)
    time.sleep(0.00001)
    GPIO.output(X_TRIG, GPIO.LOW)

    while GPIO.input(X_ECHO) == 0:
        x_start = time.time()

    while GPIO.input(X_ECHO) == 1:
        x_stop = time.time()
    
    x_elapsed = x_stop - x_start
    x_distance = min((x_elapsed * 34300) / 2, 40)
    
    GPIO.output(Y_TRIG, GPIO.HIGH)
    time.sleep(0.00001)
    GPIO.output(Y_TRIG, GPIO.LOW)
    
    y_start = y_stop = time.time()
    
    while GPIO.input(Y_ECHO) == 0:
        y_start = time.time()

    while GPIO.input(Y_ECHO) == 1:
        y_stop = time.time()
    
    y_elapsed = y_stop - y_start
    y_distance = min((y_elapsed * 34300) / 2, 40)
    
    return (z_distance, x_distance, y_distance)

if __name__ == '__main__':
    try:
        while True:
            (z_distance, x_distance, y_distance) = distance()
            print("x: %.1f cm y: %.1f cm z: %.1f cm" % (x_distance, y_distance, z_distance))
            # print(("=" * min(int(dist), 80)))
            time.sleep(0.1)
    
    except KeyboardInterrupt:
        print("Measurement stopped by User")
        GPIO.cleanup()
