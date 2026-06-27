include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

// Measured dimensions of a card, in mm:
// paperX = 82.6; // 3.25 * mm;
// paperY = 50.1; //2.00 * mm;  
paperX = 50.1;
paperY = 93;
paperZ = 0.3;;
echo(str("Paper = ", paperX, " x ", paperY, " x ", paperZ));

sideX = paperX + 2*10;

nutThThickness = 3;
nutRecessX = 3;

pivotScrewMinLength = sideX + nutThThickness - nutRecessX;
echo(str("pivotScrewMinLength = ", pivotScrewMinLength, " mm"));
echo(str("pivotScrewMinLength = ", pivotScrewMinLength/mm, " inches"));

cardSideX = 20; //paperX + 2*10;
cardSideY = paperY + 2*12;
cardSideZ = paperZ + 8;

offSideX = 20;
offSideY = cardSideY;
offSideZ = cardSideZ;

cardSlotX = paperX - 6;
cardSlotY = paperY + 1;
cardSlotZ = paperZ; // + 0.3;

paperSlotExtraZ = 0; //0.1; //0.04;

endCZ = 2;

// cardSlotExtension():
outsideX = cardSideX-offSideZ/2;
insideX = 12;
cardSideExtensionIMiddleX = (outsideX + insideX)/2;

cardSlotExtensionX = -5;
retentionScrewHoleDia = 3.0;;

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
			hull()
			{
				rotate([0,a2,0]) cardSide();
				roundedTop();
			}
			rotate([0,a2,0]) cardSideExtension();

			hull()
			{
				rotate([0,-a2,0]) offSide();
				mirror([1,0,0]) roundedTop();
			}	
			hull()
			{
				roundedTop();
				mirror([1,0,0]) roundedTop();
			}	
		}

		// Paper slot:
        rotate([0,a2,0]) tcu([cardSlotExtensionX, -cardSlotY/2, -paperSlotExtraZ], [200, cardSlotY, cardSlotZ]);

		// Clearance on the off-side for debris::
        ec2 = edgeClearance/2;
		tcu([-ec2, -200, -100], [ec2, 400, 100]);
        clip = edgeClearance/4;
        clipOffsetX = paperZ/4;
        clipX = edgeClearance * cos(a2) * 0.5 + clipOffsetX;
        clipZ = edgeClearance * cos(a2) * 0.5;
        echo(str("clipX = ", clipX));
        echo(str("clipZ = ", clipZ));
        translate([0, -200, 0]) rotate([0,-a2,0]) tcu([-clipX+clipOffsetX,0,0], [clipX, 400, clipZ]);
		
	}
}

// module cardSlotRetneentionScrewHole(a2, y)
// {
// 	rotate([0,a2,0]) 
// 	{
// 		tcy([cardSlotExtensionX/2,y,0], d=retentionScrewHoleDia, h=100);
// 		tcy([cardSideExtensionIMiddleX,y,0], d=retentionScrewHoleDia, h=100);
// 	}
// }

module roundedTop()
{
	d = cardSideZ + 6; //cardSideZ*2;

	translate([1.5,0,1]) difference()
	{
		rotate([-90,0,0]) translate([0,0,-cardSideY/2]) simpleChamferedCylinderDoubleEnded(d=d, h=cardSideY, cz=endCZ);
		tcu([-200, -200, -400], 400);
		tcu([-400, -200, -200], 400);
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

module cardSideExtension()
{
	hull()
	{
		
		dy = -3;
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([insideX,dy,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([outsideX,dy,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([outsideX,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);

		// MAGIC!!!!!
		//   ------------------------------------------------------------------------vvvv
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([cardSideExtensionIMiddleX,dy-1.3,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
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
	tcu([-200, -400+d, -200], 400);
}

if(developmentRender)
{
	display() itemModule();
	displayGhost() runnerGhost(width=3/8*mm, angle=90);
	displayGhost() paperGhost(angle=90);
	// displayGhost() runnerGhost(width=1/4*mm, angle=90);
	// displayGhost() runnerGhost(width=3/16*mm, angle=90);
}
else
{
	rotate([90,0,0]) itemModule();
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

module paperGhost(angle=90)
{
	rotate([0,angle/2,0]) tcu([cardSlotExtensionX, -paperY/2, -paperSlotExtraZ], [paperX, paperY, paperZ]);
}
