box_t=1.5;
box_d=[110,75,23];
box_c=[1,0.9,0];

pi_offset=[5,45];

top_show=false;
top_explode=40;

// base
color(box_c) cube([box_d.x,box_d.y,box_t]);

// Pi posts
for (i = [ [3.5,    3.5,    box_t], 
           [3.5,    3.5+23, box_t], 
           [3.5+58, 3.5,    box_t], 
           [3.5+58, 3.5+23, box_t] ]) {
    j = [i.x+pi_offset.x, i.y+pi_offset.y, i.z];
    translate(j)
        color(box_c) cylinder(d=2.75, h=box_t*1.5, $fn=50);
}

// walls
color(box_c) {
    cube([box_t,box_d.y,box_d.z]); // left
    translate([box_d.x-box_t,0,0])
        cube([box_t,box_d.y,box_d.z]); // right
    cube([box_d.x,box_t,box_d.z]); // front
    translate([0,box_d.y,0]) {
        difference() {
            cube([box_d.x,box_t,box_d.z]); // back
            translate([11,-5,3])
                cube([23,10,3]); // 2x mini USB hole
            translate([100,0,5]) rotate([90,0,0])
                cylinder(d=5, h=20, $fn=50, center=true); // LED hole
            translate([87,-5,4])
                cube([6,10,2]); // switch hole
        }
    }
}

if (top_show) {
    // top
    translate([0,0,box_d.z+top_explode]) {
        difference() {
            union() {
                color(box_c) cube([box_d.x,box_d.y+box_t,box_t]);
                translate([50,38,-5])
                    cube([40,40,10], center=true); // mount
            }
            translate([50,38,box_d.z-10])
                cylinder(d=29, h=50, $fn=100, center=true); // joystick hole
        }
    }
    // joystick
    translate([30,18,12+top_explode])
        color("darkgray") import("../renders/joystick.stl");
}

// Pi
translate([3.5+pi_offset.x,3.5+pi_offset.y,box_t])
    color("green") import("../vendor/pi_zero_w.stl");

// charger
translate([72,20,box_t])
    color("red") import("../renders/lipo_charger_14411.stl");

// battery
translate([5,5,box_t])
    color("silver") import("../renders/lipo_battery_1000mAh.stl");

// ADC DIP socket
translate([75,5,box_t])
    color("black") import("../renders/dip_socket_16.stl");

// power LED
translate([100,72,5]) rotate([-90,0,0])
    color([0,1,0]) import("../vendor/led_5mm.stl");

// power switch
translate([90,70,5]) rotate([-90,0,0])
    color([0.2,0.2,0.2]) import("../vendor/switch.stl");
