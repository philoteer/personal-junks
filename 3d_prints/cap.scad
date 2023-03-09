wall_thickness = 1.5;
inner_dim_1 = [55,42,10];

//////////////////////////////////////////////////////////////////////////////////////////////////////////
outer_dim = [inner_dim_1[0] + wall_thickness  + wall_thickness ,inner_dim_1[1] + wall_thickness  + wall_thickness ,inner_dim_1[2] + wall_thickness  + wall_thickness];

difference(){
cube(outer_dim);
    translate([wall_thickness,wall_thickness,wall_thickness]){
        cube([inner_dim_1[0],inner_dim_1[1],1000]);
    }
}
