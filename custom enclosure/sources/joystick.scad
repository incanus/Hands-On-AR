use <MCAD/regular_shapes.scad>

base_x=40;
base_y=40;
base_z=1.5;
difference() {
    // base
    color([0,0.3,0]) cube([base_x,base_y,base_z]);
    // holes
    hole_d=3.5;
    for (y = [4,36]) {
        for (x = [4:8:36]) {
            translate([x,y,-1])
                cylinder(d=hole_d, h=base_z*2, $fn=50);
        }
    }
}
// mechanics
translate([12,12,base_z])
    color("white") cube([16,16,11]);
// stick
translate([20,20,11]) color([0.3,0.3,0.3]) {
    // lower dome
    difference() {
        sphere(d=26, $fn=100);
        translate([0,0,-11])
        cube(size=[26,26,26], center=true);
    }
    // shaft
    translate([0,0,12])
        cylinder(d=10, h=5, $fn=50);
    // upper knob
    translate([0,0,20])
        union() {
            oval_torus(7, thickness=[2,6], $fn=50);
            cylinder(d=16, h=6, $fn=50, center=true);
        }
}
