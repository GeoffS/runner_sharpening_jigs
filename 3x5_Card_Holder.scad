include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

mm = 25.4;

// Measured dimensions of a card, in mm:
// cardX = 82.6; // 3.25 * mm;
// cardY = 50.1; //2.00 * mm;  
cardX = 50.1;
cardY = 82.6;
cardZ = 1.4; //0.05 * mm;
echo(str("Card = ", cardX, " x ", cardY, " x ", cardZ));

sideX = cardX + 2*10;

nutThThickness = 3;
nutRecessX = 3;

pivotScrewMinLength = sideX + nutThThickness - nutRecessX;
echo(str("pivotScrewMinLength = ", pivotScrewMinLength, " mm"));
echo(str("pivotScrewMinLength = ", pivotScrewMinLength/mm, " inches"));

cardSideX = cardX + 2*10;
cardSideY = cardY + 2*10;
cardSideZ = cardZ + 8;

offSideX = 20;
offSideY = cardY + 2*10;
offSideZ = cardSideZ;

cardSlotX = cardX - 6;
cardSlotY = cardY + 1;
cardSlotZ = cardZ + 0.3;

endCZ = 2;

module itemModule()
{
	jig(angle=90, edgeClearance=1.5);
}

module jig(angle, edgeClearance)
{
	echo(str("jig( ", angle, ")"));
	a2 = angle/2;

	difference()
	{
		// The main body of the card holder:
		union()
		{
			// Sides:
			rotate([0,a2,0]) cardSide();
			rotate([0,-a2,0]) offSide();

			// Rounded top:
			difference()
			{
				rotate([-90,0,0]) translate([0,0,-cardSideY/2]) simpleChamferedCylinderDoubleEnded(d=cardSideZ*2, h=cardSideY, cz=endCZ);
				tcu([-200, -200, -400], 400);
			}
			
		}

		// Card slot:
		#rotate([0,a2,0]) tcu([-200+cardSlotX, -cardSlotY/2, 0], [200, cardSlotY, cardSlotZ]);

		// Clearance above the sharpened edge:
		rotate([-90,0,0]) tcy([0,0,-200], d=edgeClearance, h=400);
		tcu([-edgeClearance/2, -200, -100], [edgeClearance, 400, 100]);
		doubleY() hull()
		{
			translate([0,cardSideY/2-edgeClearance/2-endCZ,0]) rotate([-90,0,0]) cylinder(d2=10, d1=0, h=5);
			translate([0,cardSideY/2-edgeClearance/2-endCZ,-100]) rotate([-90,0,0]) cylinder(d2=10, d1=0, h=5);
		}
		
	}
}

module cardSide()
{
	hull()
	{
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([0,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([cardSideX-offSideZ/2,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
	}
}

module offSide()
{
	hull()
	{
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([0,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([-offSideX+offSideZ/2,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
	}
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
	// tcu([0, -200, -200], 400);
}

if(developmentRender)
{
	display() itemModule();
	// displayGhost() runnerGhost(width=3/8*mm, angle=90);
	// displayGhost() runnerGhost(width=1/4*mm, angle=90);
	displayGhost() runnerGhost(width=3/16*mm, angle=90);
}
else
{
	itemModule();
}

module runnerGhost(width, angle)
{
	y = 160;
	z = 40;
	translate([0,0,-0.05]) difference()
	{
		tcu([-width/2, -y/2, -z], [width, y, z]);

		doubleX() rotate([0, angle/2, 0]) tcu([-40, -200, 0], 400);
	}
}
