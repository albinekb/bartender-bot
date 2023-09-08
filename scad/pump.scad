line_width = 0.48;
layer_height = 0.2;
function round_to_line_width(x) = floor(x / line_width) * line_width;
function round_to_layer_height(x) = floor(x / layer_height) * layer_height;
base_height = 2;
radius = 13.5;
// shaft_radius = 5;
shaft_height = 9 + base_height;

bolt_radius = 1.8;
shaft_radius = 2.5;
shaft_thickness = round_to_line_width(1.5);
bolt_clearence = 1.4;
bolt_count = 4;
bolt_leg_width = round_to_line_width(7);
bearing_lip = round_to_layer_height(0.4);

// 623zz bearing: 3mm inner diameter, 10mm outer diameter, 4mm thick
bearing_inner_radius = 1.5;
bearing_outer_radius = 5;
bearing_thickness = 4;

nema_inset = 0.5;
nema_width = 42;
nema_slop = 0.16;

debug = true;

$fn = 100;

module
nema_17(radius, h = 100)
{
  translate([ 0, 0, -10 ])
  {
    difference()
    {
      cylinder(h = h, r = radius + nema_slop);
      translate(v = [ (radius * 2) - nema_inset, 0, 0 ])
      {
        cube([ (radius * 2) - nema_slop, radius * 2, h ], center = true);
      }
    }
  }
}

// leg for holding bolt, rotated by angle. Leg is the same length as radius,
// starting at center. with a rounded end. using a cube and a cylinder with
// union. Thickness is base_height
module
bolt_leg(angle)
{

  rotate([ 0, 0, angle ])
  {
    translate([ 0, -bolt_leg_width / 2, 0 ])
    {
      union()
      {
        cube([ radius - bolt_leg_width / 2, bolt_leg_width, base_height ],
             center = false);
        translate([ radius - bolt_leg_width / 2, bolt_leg_width / 2, 0 ])
        {
          cylinder(h = base_height, r = bolt_leg_width / 2, center = false);
        }
      }
    }
  }
}

// hole for a bolt, with a small lip
module
bolt_hole(r)
{

  translate([ 0, 0, -1 ]) cylinder(h = 100, r = r);
}

module
top_cap(debug = false)
{
  union()
  {

    difference()
    {
      union()
      {
        bolt_legs();
        cylinder(h = base_height, r = shaft_thickness * 4);
        // cylinder(r = radius, h = base_height);
      }
      // NEMA 17 shaft, flat side
      nema_17(radius = shaft_radius);

      // bolt holes
      for (i = [0:bolt_count - 1]) {
        rotate([ 0, 0, i * 360 / bolt_count ])
        {
          translate([ radius - bolt_radius - bolt_clearence, 0, 0 ])
          {
            bolt_hole(r = bolt_radius);
          }
        }
      }
    }
    // One lip per bolt hole, 2mm high with the same bolt hole as the bolt
    // holes
    for (i = [0:bolt_count - 1]) {
      rotate([ 0, 0, i * 360 / bolt_count ])
      {
        translate([ radius - bolt_radius - bolt_clearence, 0, base_height ])
        {
          difference()
          {
            cylinder(h = bearing_lip, r = bolt_radius + 0.4);
            bolt_hole(r = bolt_radius);
          }
        }
      }
    }
    if (debug) {
      // Draw bearing mockups
      for (i = [0:bolt_count - 1]) {
        rotate([ 0, 0, i * 360 / bolt_count ])
        {
          translate([
            radius - bolt_radius - bolt_clearence,
            0,
            base_height +
            bearing_lip
          ])
          {
            bearing_mockup();
            translate([ 0, 0, bearing_thickness ])
            {
              bearing_mockup();
            }
          }
        }
      }
    }
  }
}

module
bolt_legs()
{
  union()
  {

    for (i = [0:bolt_count - 1]) {
      bolt_leg(angle = i * 360 / bolt_count);
    }
  }
}

module
bottom_cap(debug = false)
{
  union()
  {
    top_cap(debug = debug);

    difference()
    {
      cylinder(h = shaft_height, r = shaft_radius + shaft_thickness);

      // NEMA 17 shaft, flat side
      nema_17(radius = shaft_radius);
    }
  }
}

module
bearing_mockup()
{
  bearing_inner_race_height = 0.1;
  bearing_inner_race_width = bearing_lip;
  // Using bearing_inner_radius as the hole size, and bearing_outer_radius as
  // the outer size thickness is bearing_thickness

  difference()
  {

    color("Red") cylinder(h = bearing_thickness, r = bearing_outer_radius);
    translate([ 0, 0, -bearing_thickness / 2 ])
      cylinder(h = bearing_thickness * 2, r = bearing_inner_radius);

    color("Yellow") union()
    {
      translate([ 0, 0, bearing_thickness - bearing_inner_race_height ])
      {
        difference()
        {

          cylinder(h = bearing_thickness,
                   r = bearing_outer_radius + bearing_inner_race_height);
          translate([ 0, 0, -bearing_thickness / 2 ])
            cylinder(h = bearing_thickness * 2,
                     r = bearing_inner_radius + bearing_inner_race_width);
        }
      }
      translate([ 0, 0, -bearing_inner_race_height ])
      {
        difference()
        {
          cylinder(h = bearing_inner_race_height,
                   r = bearing_outer_radius + bearing_inner_race_height);
          translate([ 0, 0, 0 ])
            cylinder(h = bearing_lip * 2,
                     r = bearing_inner_radius + bearing_inner_race_width);
        }
      }
    }
  }
}

module
structural_bend()
{
  difference()
  {
    cube([ 10, 10, 10 ]);
    translate([ 10, 10, 0 ])
    {
      cylinder(h = 12, r = 10);
    }
  }
}

extra_innner_width = 0.2;
pump_circle_inner_radius =
  radius + (bearing_outer_radius / 2) + (extra_innner_width);
nema_17_circle_bump_radius = 11.4;
module
nema17_base()
{
  difference()
  {
    radius = 8;
    intersection()
    {
      union()
      {
        translate([ -nema_width / 2, -(nema_width / 2), 0 ])
        {
          roundedcube(size = [ nema_width, nema_width, base_height ],
                      apply_to = "z",
                      radius = radius);
        }
      }
      translate([ -nema_width / 2, -(nema_width / 2), 0 ])
        cube([ nema_width, nema_width, base_height ]);
    }
    translate([ 0, 0, -base_height * 2 ])
      cylinder(h = base_height * 4, r = nema_17_circle_bump_radius);
  }
}

module
nema17_bolt_holes()
{
  bolt_radius = 1.8;
  bolt_clearence = 1.4;
  bolt_count = 4;
  bolt_spacing = 31.5;
  translate([ 0, 0, 0 ]) for (i = [0:bolt_count - 1])
  {
    rotate([ 0, 0, (i * 90) ])
    {
      translate([ bolt_spacing / 2, bolt_spacing / 2, 0 ])
      {
        bolt_hole(r = bolt_radius);
      }
    }
  }
}

module
pump_circle()
{

  wall_thickness = 1;
  inner_lip_height = 6;
  tube_slop = -0.4;

  difference()
  {
    union()
    {
      difference()
      {
        cylinder(h = 17, r = pump_circle_inner_radius + wall_thickness);
        cylinder(h = 24, r = pump_circle_inner_radius + tube_slop);
      }
      difference()
      {
        cylinder(h = inner_lip_height, r = pump_circle_inner_radius);
        cylinder(h = 24, r = pump_circle_inner_radius - 2);
      }
    }

    tube_hole_radius = 2.02;
    tube_spacing = 7.6;
    tube_height = 12;
    translate([ tube_spacing, 0, tube_height ])
    {
      rotate([ 90, 0, 0 ]) cylinder(h = 100, r = tube_hole_radius);
    }
    translate([ -tube_spacing, 0, tube_height ])
    {
      rotate([ 90, 0, 0 ]) cylinder(h = 100, r = tube_hole_radius);
    }
  }
}

module
housing()
{
  difference()
  {
    union()
    {
      nema17_base();
      pump_circle();
    }
    nema17_bolt_holes();
  }
}

housing();

// bearing_mockup();

// top_cap(debug = false);
// bottom_cap(debug = false);

//*** LIB ***//

module
roundedcube(size = [ 1, 1, 1 ], center = false, radius = 0.5, apply_to = "all")
{
  // If single value, convert to [x, y, z] vector
  size = (size[0] == undef) ? [ size, size, size ] : size;

  translate_min = radius;
  translate_xmax = size[0] - radius;
  translate_ymax = size[1] - radius;
  translate_zmax = size[2] - radius;

  diameter = radius * 2;

  obj_translate = (center == false)
                    ? [ 0, 0, 0 ]
                    : [ -(size[0] / 2), -(size[1] / 2), -(size[2] / 2) ];

  translate(v = obj_translate)
  {
    hull()
    {
      for (translate_x = [ translate_min, translate_xmax ]) {
        x_at = (translate_x == translate_min) ? "min" : "max";
        for (translate_y = [ translate_min, translate_ymax ]) {
          y_at = (translate_y == translate_min) ? "min" : "max";
          for (translate_z = [ translate_min, translate_zmax ]) {
            z_at = (translate_z == translate_min) ? "min" : "max";

            translate(
              v = [ translate_x, translate_y,
                    translate_z ]) if ((apply_to == "all") ||
                                       (apply_to == "xmin" && x_at == "min") ||
                                       (apply_to == "xmax" && x_at == "max") ||
                                       (apply_to == "ymin" && y_at == "min") ||
                                       (apply_to == "ymax" && y_at == "max") ||
                                       (apply_to == "zmin" && z_at == "min") ||
                                       (apply_to == "zmax" && z_at == "max"))
            {
              sphere(r = radius);
            }
            else
            {
              rotate =
                (apply_to == "xmin" || apply_to == "xmax" || apply_to == "x")
                  ? [ 0, 90, 0 ]
                  : ((apply_to == "ymin" || apply_to == "ymax" ||
                      apply_to == "y")
                       ? [ 90, 90, 0 ]
                       : [ 0, 0, 0 ]);
              rotate(a = rotate)
                cylinder(h = diameter, r = radius, center = true);
            }
          }
        }
      }
    }
  }
}