// Iomrá Body Shell v3 — Print-Ready River Stone
// Refinements: domed top, mating lip/groove, alignment pins, manifold geometry
// Resin print: matte black
//
// Units: millimeters

$fn = 180;

// === PARAMETERS ===
base_w = 90;       // widest point width
base_d = 68;       // widest point depth
total_h = 105;     // total height
wall = 2.5;        // shell thickness
split_h = 42;      // where base meets head

// Mating joint
lip_h = 3;         // height of the registration lip
lip_t = 1.2;       // lip wall thickness
lip_gap = 0.25;    // clearance for fit

// Top dome
dome_h = 8;        // how much the dome rises above the last profile

// LED window
led_outer_r = 20;
led_inner_r = 11;

// USB-C
usbc_w = 12;
usbc_h = 7;

// Servo
servo_shaft_d = 8;
servo_horn_d = 22;

// Alignment pins (2 pins on base, 2 holes in head)
pin_d = 3;
pin_h = 4;
pin_positions = [[20, 0], [-20, 0]];

// === ORGANIC PROFILE ===
// Superellipse (Lamé curve) for river stone shape
// n=2 = ellipse, n=2.5 = squircle, n=4+ = rectangle

function superellipse_point(a, b, n, angle) =
    let(
        ca = cos(angle),
        sa = sin(angle),
        x = a * pow(abs(ca), 2/n) * sign(ca),
        y = b * pow(abs(sa), 2/n) * sign(sa)
    ) [x, y];

function sign(x) = x > 0 ? 1 : x < 0 ? -1 : 0;

// Profile at height fraction (0=bottom, 1=top)
// Returns [width, depth, squareness, x_offset, y_offset]
function profile_at(t) =
    let(
        // Width: widest at 30% height, tapers both ways
        w = base_w * (0.6 + 0.4 * sin(min(t / 0.3, 1.0) * 90))
            * (1 - 0.3 * pow(max(0, (t - 0.3) / 0.7), 1.8)),
        // Depth: similar but slightly offset peak
        d = base_d * (0.6 + 0.4 * sin(min(t / 0.35, 1.0) * 90))
            * (1 - 0.35 * pow(max(0, (t - 0.35) / 0.65), 1.6)),
        // Squareness: rounder at bottom and top, slightly squared in middle
        n = 2.0 + 0.6 * sin(t * 180),
        // Asymmetry: center drifts slightly as we go up
        xoff = 2 * sin(t * 140),
        yoff = -1.5 * sin(t * 120 + 30)
    ) [w, d, n, xoff, yoff];

// Superellipse polygon at height fraction t
module stone_slice(t) {
    p = profile_at(t);
    w = p[0]; d = p[1]; n = p[2]; xoff = p[3]; yoff = p[4];
    steps = 72;
    translate([xoff, yoff, 0])
        polygon([for (i = [0:steps-1])
            superellipse_point(w/2, d/2, n, i * 360 / steps)
        ]);
}

// Inset version of a slice (for inner cavity, lip, etc.)
module stone_slice_inset(t, inset) {
    p = profile_at(t);
    w = p[0] - 2*inset; d = p[1] - 2*inset;
    n = p[2]; xoff = p[3]; yoff = p[4];
    steps = 72;
    if (w > 0 && d > 0)
        translate([xoff, yoff, 0])
            polygon([for (i = [0:steps-1])
                superellipse_point(w/2, d/2, n, i * 360 / steps)
            ]);
}

// Solid body from stacked slices
module stone_body() {
    slices = 60;
    for (i = [0:slices-1]) {
        t0 = i / slices;
        t1 = (i + 1) / slices;
        z0 = t0 * total_h;
        z1 = t1 * total_h;
        hull() {
            translate([0, 0, z0]) linear_extrude(0.01) stone_slice(t0);
            translate([0, 0, z1]) linear_extrude(0.01) stone_slice(t1);
        }
    }
}

// Inner cavity body (follows the profile with uniform wall offset)
module stone_body_inner() {
    slices = 60;
    for (i = [0:slices-1]) {
        t0 = i / slices;
        t1 = (i + 1) / slices;
        z0 = t0 * total_h;
        z1 = t1 * total_h;
        hull() {
            translate([0, 0, z0]) linear_extrude(0.01) stone_slice_inset(t0, wall);
            translate([0, 0, z1]) linear_extrude(0.01) stone_slice_inset(t1, wall);
        }
    }
}

// Hollow shell (true profile-following cavity)
module stone_hollow() {
    difference() {
        stone_body();
        translate([0, 0, wall]) stone_body_inner();
    }
}

// Dome cap for the top of the head
// Must be wider than the shell opening to seal fully
module top_dome() {
    p_top = profile_at(1.0);
    w = p_top[0]; d = p_top[1]; xoff = p_top[3]; yoff = p_top[4];
    // Use full width + slight overshoot so the dome intersects the shell walls
    translate([xoff, yoff, total_h - dome_h])
        resize([w * 1.02, d * 1.02, dome_h * 2])
            sphere(d = 10);
}

// Inner dome cavity (matches wall thickness)
module top_dome_inner() {
    p_top = profile_at(1.0);
    w = p_top[0] - 2*wall; d = p_top[1] - 2*wall;
    xoff = p_top[3]; yoff = p_top[4];
    translate([xoff, yoff, total_h - dome_h])
        resize([w * 1.02, d * 1.02, (dome_h - wall) * 2])
            sphere(d = 10);
}

// Lip ring at the split line (sits on top of the base)
module split_lip() {
    t_split = split_h / total_h;
    hull() {
        translate([0, 0, split_h])
            linear_extrude(0.01) stone_slice_inset(t_split, wall);
        translate([0, 0, split_h + lip_h])
            linear_extrude(0.01) stone_slice_inset(t_split + lip_h/total_h, wall);
    }
}

// Lip cavity (cut into head for the lip to nest into)
module split_lip_cavity() {
    t_split = split_h / total_h;
    hull() {
        translate([0, 0, split_h - 0.1])
            linear_extrude(0.01) stone_slice_inset(t_split, wall - lip_t - lip_gap);
        translate([0, 0, split_h + lip_h + 0.2])
            linear_extrude(0.01) stone_slice_inset(t_split + lip_h/total_h, wall - lip_t - lip_gap);
    }
}

// Alignment pins
module alignment_pins() {
    for (pos = pin_positions) {
        translate([pos[0], pos[1], split_h])
            cylinder(d = pin_d, h = pin_h);
    }
}

// Alignment pin holes
module alignment_holes() {
    for (pos = pin_positions) {
        translate([pos[0], pos[1], split_h - 0.1])
            cylinder(d = pin_d + 0.4, h = pin_h + 0.5);
    }
}


// === BASE SHELL ===
module base_shell() {
    difference() {
        union() {
            // Bottom portion of hollow stone
            intersection() {
                stone_hollow();
                translate([0, 0, split_h/2])
                    cube([200, 200, split_h], center = true);
            }

            // Registration lip (rises above split line)
            difference() {
                split_lip();
                // Hollow out the lip interior
                t_split = split_h / total_h;
                hull() {
                    translate([0, 0, split_h - 0.1])
                        linear_extrude(0.01) stone_slice_inset(t_split, wall + lip_t);
                    translate([0, 0, split_h + lip_h + 0.1])
                        linear_extrude(0.01) stone_slice_inset(t_split + lip_h/total_h, wall + lip_t);
                }
            }

            // Alignment pins
            alignment_pins();
        }

        // Floor: flat bottom
        translate([0, 0, -50]) cube([200, 200, 100], center = true);

        // Bottom plate recess (1.8mm deep for laser-cut plate)
        translate([0, 0, -0.1])
            linear_extrude(1.8)
                stone_slice_inset(0.0, wall - 1);

        // USB-C port (rear center)
        translate([0, base_d/2 - 2, 8])
            cube([usbc_w, wall * 4, usbc_h], center = true);

        // Servo shaft hole (top of base)
        translate([0, 0, split_h - 8])
            cylinder(d = servo_shaft_d, h = lip_h + 12);

        // Wire channels (2 slots for LED + mic wires from head)
        translate([-8, 0, split_h - 3])
            cylinder(d = 4, h = lip_h + 8);
        translate([8, 0, split_h - 3])
            cylinder(d = 4, h = lip_h + 8);
    }

    // Internal shelf ledge
    translate([0, 0, 14])
        difference() {
            linear_extrude(2)
                stone_slice_inset(0.15, wall + 1);
            linear_extrude(3)
                stone_slice_inset(0.15, wall + 5);
        }
}


// === HEAD SHELL ===
module head_shell() {
    difference() {
        union() {
            // Top portion of hollow stone
            intersection() {
                stone_hollow();
                translate([0, 0, split_h + (total_h - split_h)/2])
                    cube([200, 200, total_h - split_h], center = true);
            }

            // Dome cap (solid)
            top_dome();
        }

        // Hollow the dome interior
        top_dome_inner();

        // Remove anything below the split line (dome extends down)
        translate([0, 0, split_h/2 - 1])
            cube([200, 200, split_h], center = true);

        // Registration lip cavity (head slides over the base lip)
        split_lip_cavity();

        // Alignment pin holes
        alignment_holes();

        // LED ring window (front face, angled down ~20 degrees)
        led_z = split_h + (total_h - split_h) * 0.5;
        p_led = profile_at(led_z / total_h);
        translate([p_led[3], -(p_led[1]/2) * 0.7 + p_led[4], led_z])
            rotate([20, 0, 0]) {
                // Recess for diffuser (outer ring)
                cylinder(r = led_outer_r, h = wall + 1);
                // Through-hole for light (inner)
                translate([0, 0, -wall])
                    cylinder(r = led_outer_r - 4, h = wall * 3);
            }

        // Mic pinhole (above LED window)
        mic_z = split_h + (total_h - split_h) * 0.75;
        p_mic = profile_at(mic_z / total_h);
        translate([p_mic[3], -(p_mic[1]/2) * 0.6 + p_mic[4], mic_z])
            rotate([25, 0, 0])
                cylinder(d = 2.5, h = wall * 3, center = true);

        // Servo horn recess (bottom of head, inside)
        translate([0, 0, split_h])
            cylinder(d = servo_horn_d, h = 6);
        translate([0, 0, split_h - 1])
            cylinder(d = servo_shaft_d, h = 10);

        // Wire channels matching base
        translate([-8, 0, split_h - 1])
            cylinder(d = 4, h = 8);
        translate([8, 0, split_h - 1])
            cylinder(d = 4, h = 8);
    }
}


// === RENDER ===
// Preview: both pieces together
color("#2a2a2a") base_shell();
color("#333333") translate([0, 0, 0.5]) head_shell();  // 0.5mm gap to show seam

// For STL export — uncomment one at a time:
// base_shell();
// head_shell();
