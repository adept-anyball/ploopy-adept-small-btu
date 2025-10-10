// this openscad file lets you generate supports for trackballs of various sizes. it also supports several different types of btus, e.g. bosch and veichu.




// Global resolution
$fs = 0.1;  // Don't generate smaller facets than 0.1 mm
$fa = 5;    // Don't generate larger angles than 5 degrees

// extra gap for the cup.
cup_tolerance = 0.1;

// space between btu brim and cup rim.
// can be useful if you want to be able to pry btus out easily.
brim_rim_gap = 0.5;

// btu cups will be cut off at and below this level.
cup_floor=0;

// raw dimensions of the btu.
// dimensions names like those for bosch rexroth R053010810: https://store.boschrexroth.com/en/us/p/ball-transfer-unit-r053010810
// for other btus, derive the dimensions corresponding to those for the bosch btu.

// bosch rexroth 
btu_H = 11.2;
btu_h = 4.8;
btu_D = 12.6;
btu_D1 = 17;
btu_dw = 7.938;
btu_a = 1.9;

// veichu 7.5mm. 
//btu_H = 6.1;
//btu_h = 2.1;
//btu_D = 7.5;
//btu_D1 = 9;
//btu_dw = 4;
//btu_a = 1;

// raw dimensions for tracking ball
ball_d = 21.8;
ball_e = 2;

// angle of btus. adjust as needed.
phi = 75;

// how much the btu housing points down.
deflection = 20;

// extra space in front of btu rim. adjust as needed.
btu_clearance = ball_d/2;


//thickness of btu cup walls. adjust as needed.
holder_side_wall=1;
holder_back_wall=4;


// derived btu dimensions
btu_rw = btu_dw/2;
btu_Hd = btu_H - btu_h;

// derived dimensions for tracking ball
ball_r = ball_d/2;
ball_h = ball_e + ball_r;


// unit vectors.
vx = [1,0,0];
vy = [0,1,0];
vz = [0,0,1];


module rb_cylinder(r,h,c){
    hull() {
        translate([0,0,c])cylinder(r=r,h=h-c);
        translate([0, 0, c]) rotate_extrude() translate([r-c, 0]) circle(r=c);
}   
}


module orig() {
    translate([0,11.1,-29.5]){
        import("../v4-slim-34mm-trackball-support.stl");}
}


module base(){
difference () {
    orig();
    union(){
    translate([0,0,4])
        cylinder(r=40, h=20);
//    translate([0,0,2])
//        cylinder(r=27, h=21);
}
}

}

// virtual ball
translate(ball_h * vz)
    %sphere(r=ball_r);

module virtual_btu_atzero(clearance=0){
    sphere(r=btu_rw);
    translate(vz*(btu_rw - btu_H))
        cylinder(h=btu_Hd, r=(btu_D)/2 + cup_tolerance);
    translate(vz*(btu_rw - btu_h))
        cylinder(h=btu_a + clearance, r=(btu_D1)/2 + cup_tolerance);
}

module virtual_btu(clearance=0){
translate(ball_h * vz) rotate(-phi * vx) translate(-(ball_r + btu_rw)*vz) rotate(deflection * vx) virtual_btu_atzero(clearance);
}

module btu_holder_atzero(){
    translate((btu_rw - btu_H - holder_back_wall)*vz)
        rb_cylinder(h=btu_Hd + holder_back_wall - brim_rim_gap, r=btu_D/2 + holder_side_wall, c=holder_side_wall);
}

module btu_holder(){
    translate(ball_h * vz) rotate(-phi * vx) translate(-(ball_r + btu_rw)*vz) rotate(deflection * vx) btu_holder_atzero();
}

module btu_holders(){
   for(t=[0:120:359])rotate(vz*t)btu_holder();
}

module virtual_btus(clearance=0){
    for(t=[0:120:359])rotate(vz*t)virtual_btu(clearance);
}

module filler(){
    for(t=[0:120:359])rotate(vz*t)translate(-23*vy+2*vz)cube([10,10,4], center=true);
}

module below(h){
    translate(h*vz)rotate(vy*180)cylinder(r=60,h=60);
}

color("grey")
difference(){
    union(){
        base();
        difference(){
        btu_holders();
            below(cup_floor);
        }
        filler();
    }
    union(){
        virtual_btus(clearance=btu_clearance);
    }
}
%virtual_btus();
