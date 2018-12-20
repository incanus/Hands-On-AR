difference() {
    dip_x=20;
    dip_y=10;
    dip_z=4.5;
    color("black") cube([dip_x,dip_y,dip_z]);
    hole_x=14;
    hole_y=2.75;
    translate([(dip_x-hole_x)/2,(dip_y-hole_y)/2,-1])
        cube([14,2.75,dip_z*2]);
}
