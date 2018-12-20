// base w/ holes
difference() {
    base_x=32;
    base_y=20;
    base_z=1.75;
    color("red") cube([base_x,base_y,base_z]);
    hole_d=3.5;
    translate([3,14,-1])
        cylinder(d=3.5, h=base_z*2, $fn=50);
    translate([29,14,-1])
        cylinder(d=3.5, h=base_z*2, $fn=50);
}
// USB
translate([6,15,1.75])
    color("silver") cube([8,6,2]);
// JST
translate([26,1,2])
    color([0.2,0.2,0.2]) cube([6,8,4]);
