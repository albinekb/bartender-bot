line_width = 0.4;
layer_height = 0.2;
function round_to_line_width(x) = floor(x / line_width) * line_width;
function round_to_layer_height(x) = floor(x / layer_height) * layer_height;
base_height = round_to_layer_height(2);
radius = 13.5;
// shaft_radius = 5;
shaft_height = 9 + base_height;

bolt_radius = 1.5;
shaft_radius = 2.5;
shaft_thickness = round_to_line_width(1.5);
bolt_clearence = 1.4;
bolt_count = 4;
bolt_leg_width = round_to_line_width(5);
bearing_lip = round_to_layer_height(0.4);

// 623zz bearing: 3mm inner diameter, 10mm outer diameter, 4mm thick
bearing_inner_radius = 1.5;
bearing_outer_radius = 5;
bearing_thickness = 4;

nema_inset = 0.5;

debug = true;

$fn = 100;

module
nema_17(radius, h = 100)
{
  translate([ 0, 0, -10 ])
  {
    difference()
    {
      cylinder(h = h, r = radius);
      translate(v = [ (radius * 2) - nema_inset, 0, 0 ])
      {
        cube([ radius * 2, radius * 2, h ], center = true);
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
bottom_cap()
{
  union()
  {
    top_cap();

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

// bearing_mockup();

top_cap(debug = true);