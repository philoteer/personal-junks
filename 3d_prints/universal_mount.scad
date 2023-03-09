/////////////////////////////////// Consts
dim = [49, 58]; // x, y
screw_hole_r = 1.25; // M2.5
screw_insert_dim = [12,15,7]; //(h, r1, r2)
support_thickness = [6, 3]; // x, z
support_offset = 5;
additional_supports = 2;
////////////////////////////////// Create
//inserts
ScrewInsert([0,0,0]);
ScrewInsert([0,dim[1],0]);
ScrewInsert([dim[0],dim[1],0]);
ScrewInsert([dim[0],0,0]);

//support_right_angle
translate([-support_thickness[0]/2,support_offset,0])
    cube([support_thickness[0],dim[1]-(support_offset*2),support_thickness[1]]);

translate([-support_thickness[0]/2+dim[0],support_offset,0])
    cube([support_thickness[0],dim[1]-(support_offset*2),support_thickness[1]]);

translate([support_offset,-support_thickness[0]/2,0])
    cube([dim[0]-(support_offset*2),support_thickness[0],support_thickness[1]]);

translate([support_offset,-support_thickness[0]/2+dim[1],0])
    cube([dim[0]-(support_offset*2),support_thickness[0],support_thickness[1]]);

for (i = [1:1:additional_supports])
    translate([0,-support_thickness[0]/2+(dim[1] * (i/(additional_supports+1))),0])
        cube([dim[0],support_thickness[0],support_thickness[1]]);

for (i = [1:1:additional_supports])
    translate([-support_thickness[0]/2 + (dim[0] * (i/(additional_supports+1))),0,0])
        cube([support_thickness[0],dim[1],support_thickness[1]]);
    
////////////////////////////////// Building Blocks
module ScrewInsert(pos){
    translate(pos){
        difference(){
        //cylinder(h, r1, r2)
            cylinder(screw_insert_dim[0],screw_insert_dim[1],screw_insert_dim[2],$fn=4);
            cylinder(999,screw_hole_r,screw_hole_r);
        }
    }
}