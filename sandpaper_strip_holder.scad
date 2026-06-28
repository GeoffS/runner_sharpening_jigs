include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

// Measured dimensions of a paper, in mm:
// paperX = 82.6; // 3.25 * mm;
// paperY = 50.1; //2.00 * mm;  
paperX = 50.1;
paperY = 93;
paperZ = 0.3;;
echo(str("Paper = ", paperX, " x ", paperY, " x ", paperZ));

sideX = paperX + 2*10;

nutThThickness = 3;
nutRecessX = 3;

extensionY = 12;

paperSideX = 20; //paperX + 2*10;
paperSideY = paperY + 2*extensionY;
paperSideZ = paperZ + 8;

offSideX = 20;
offSideY = paperSideY;
offSideZ = paperSideZ;

paperSlotX = paperX - 6;
paperSlotY = paperY + 1;
paperSlotZ = paperZ; // + 0.3;

paperSlotExtraZ = 0; //0.1; //0.04;

endCZ = 2;

// paperSlotExtension():
outsideX = paperSideX-offSideZ/2;
insideX = 12;
paperSideExtensionIMiddleX = (outsideX + insideX)/2;

paperSlotExtensionX = -5;
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
		// The main body of the paper holder:
		union()
		{
			// Sides:
			hull()
			{
				rotate([0,a2,0]) paperSide();
				roundedTop();
			}
			rotate([0,a2,0]) paperSideExtension();

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
        rotate([0,a2,0]) tcu([paperSlotExtensionX, -paperSlotY/2, -paperSlotExtraZ], [200, paperSlotY, paperSlotZ]);

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

        // Clearance at the end for debris:
        doubleY()
        {
            endCleanceDia = 6;
            // MAGIC!!!!!
            //   ------------------------------------------------------vvvvv
            transitionChamferOffsetY = -paperSlotY/2-endCleanceDia/2 + 0.535; //+edgeClearance/2;

            // Transition to end clerance cylinder:
            hull()
            {
                rotate([-90,0,0]) translate([0,0,transitionChamferOffsetY]) cylinder(d1=endCleanceDia, d2=0, h=endCleanceDia/2);
                rotate([-90,0,0]) translate([0,20,transitionChamferOffsetY]) cylinder(d1=endCleanceDia, d2=0, h=endCleanceDia/2);
            }

            // Cylinder:
            rotate([-90,0,0]) tcy([0,0,transitionChamferOffsetY-100+nothing], d=endCleanceDia, h=100);
            tcu([-endCleanceDia/2, transitionChamferOffsetY-400+nothing, -100], [endCleanceDia, 400, 100]);

            // End Chamfer:
            hull()
            {
                coneZ = 20;
                // MAGIC!!!!!
                //   vvvvv
                cz = 1.104;
                endChamferOffsetY = -paperSideY/2 - coneZ + endCleanceDia/2 + cz;
                translate([0, endChamferOffsetY,    0]) rotate([-90,0,0]) cylinder(d1=coneZ*2, d2=0, h=coneZ);
                translate([0, endChamferOffsetY, -100]) rotate([-90,0,0]) cylinder(d1=coneZ*2, d2=0, h=coneZ);
            }
        }
	}
}

// module paperSlotRetneentionScrewHole(a2, y)
// {
// 	rotate([0,a2,0]) 
// 	{
// 		tcy([paperSlotExtensionX/2,y,0], d=retentionScrewHoleDia, h=100);
// 		tcy([paperSideExtensionIMiddleX,y,0], d=retentionScrewHoleDia, h=100);
// 	}
// }

module roundedTop()
{
	d = paperSideZ + 6; //paperSideZ*2;

	translate([1.5,0,1]) difference()
	{
		rotate([-90,0,0]) translate([0,0,-paperSideY/2]) simpleChamferedCylinderDoubleEnded(d=d, h=paperSideY, cz=endCZ);
		tcu([-200, -200, -400], 400);
		tcu([-400, -200, -200], 400);
	}
}

module paperSide()
{
	hull()
	{
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([0,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([paperSideX-offSideZ/2,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
	}
}

module paperSideExtension()
{
	hull()
	{
		
		dy = -3;
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([insideX,dy,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([outsideX,dy,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([outsideX,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);

		// MAGIC!!!!!
		//   ---------------------------------------------------------------------------------------------vvv
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([paperSideExtensionIMiddleX, dy-1.3, 0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
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
    tcu([-400, -200, -200], 400);
	// tcu([-200, -400+d, -200], 400);
}

if(developmentRender)
{
	display() itemModule();
	// displayGhost() runnerGhost(width=3/8*mm, angle=90);
	// displayGhost() paperGhost(angle=90);

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
	rotate([0,angle/2,0]) tcu([paperSlotExtensionX, -paperY/2, -paperSlotExtraZ], [paperX, paperY, paperZ]);
}
