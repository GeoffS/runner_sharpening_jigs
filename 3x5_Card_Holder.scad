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

offSideX = 25;
offSideY = cardY + 2*10;
offSideZ = cardSideZ;

endCZ = 2;

module itemModule()
{
	jig(90);
}

module jig(angle)
{
	echo(str("jig( ", angle, ")"));
	a2 = angle/2;

	difference()
	{
		union()
		{
			rotate([0,a2,0]) cardSide();
			rotate([0,-a2,0]) offSide();

			difference()
			{
				// rotate([-90,0,0]) tcy([0,0,-cardSideY/2], d=cardSideZ*2, h=cardSideY);
				rotate([-90,0,0]) translate([0,0,-cardSideY/2]) simpleChamferedCylinderDoubleEnded(d=cardSideZ*2, h=cardSideY, cz=endCZ);
				tcu([-200, -200, -400], 400);
			}
			
		}

		// Clearance above the sharpened edge:
		edgeClearance = 2;
		rotate([-90,0,0]) tcy([0,0,-200], d=edgeClearance, h=400);
		tcu([-edgeClearance/2, -200, -100], [edgeClearance, 400, 100]);
	}
}

module cardSide()
{
	// tcu([0, -cardSideY/2, 0], [cardSideX, cardSideY, cardSideZ]);
	hull()
	{
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([0,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([cardSideX-offSideZ/2,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
	}
}

module offSide()
{
	// tcu([-offSideX, -offSideY/2, 0], [offSideX, offSideY, offSideZ]);
	hull()
	{
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([0,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([-offSideX+offSideZ/2,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
	}
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();
	displayGhost() runnerGhost(width=0.25*mm, angle=90);;
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
