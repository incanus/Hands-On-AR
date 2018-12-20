PATH  := $(PATH):/Applications/OpenSCAD.app/Contents/MacOS
SHELL := env PATH=$(PATH) /bin/bash

all: joystick dip_socket_16 lipo_charger_14411 lipo_battery_1000mAh enclosure

joystick: sources/joystick.scad
	OpenSCAD -o renders/joystick.stl sources/joystick.scad

dip_socket_16: sources/dip_socket_16.scad
	OpenSCAD -o renders/dip_socket_16.stl sources/dip_socket_16.scad

lipo_charger_14411: sources/lipo_charger_14411.scad
	OpenSCAD -o renders/lipo_charger_14411.stl sources/lipo_charger_14411.scad

lipo_battery_1000mAh: sources/lipo_battery_1000mAh.scad
	OpenSCAD -o renders/lipo_battery_1000mAh.stl sources/lipo_battery_1000mAh.scad

enclosure: sources/enclosure.scad
	OpenSCAD -o renders/enclosure.stl sources/enclosure.scad

clean:
	rm renders/*.stl
