include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

makeStrip = false;
makeSheet = false;
makeGuide = false;

// Measured dimensions of a paper, in mm:
// paperX = 82.6; // 3.25 * mm;
// paperY = 50.1; //2.00 * mm;  
paperX = 50.1;
paperY = 93;
paperZ = 0.55;
echo(str("Paper = ", paperX, " x ", paperY, " x ", paperZ));

sideX = paperX + 2*10;

nutThThickness = 3;
nutRecessX = 3;

paperSlotX = paperX - 6;
paperSlotY = paperY + 1;
paperSlotZ = paperZ;

paperSlotExtraZ = paperSlotZ;

endCZ = 2;



retentionScrewHoleDia = 3.0;

$fn=180;

// module itemModule()
// {
// 	jig(angle=90, edgeClearance=1.5);
// }

module jig(angle, edgeClearance, throughSlot=false, extensionY)
{
	echo(str("jig( ", angle, ")"));
	a2 = angle/2;

    paperSideX = 20;
    paperSideY = paperY + 2*extensionY;
    paperSideZ = paperZ + 8;

    offSideX = 12;
    offSideY = paperSideY;
    offSideZ = paperSideZ;

    outsideX = paperSideX-offSideZ/2;
    insideX = 12;

	difference()
	{
		// The main body of the paper holder:
		union()
		{
			// Sides:
			hull()
			{
				rotate([0,a2,0]) paperSide(paperSideX, offSideY, offSideZ);
				roundedTop(paperSideY, paperSideZ);
			}
			rotate([0,a2,0]) paperSideExtension(insideX, outsideX, offSideY, offSideZ);

			hull()
			{
				rotate([0,-a2,0]) offSide(offSideX, offSideY, offSideZ);
				mirror([1,0,0]) roundedTop(paperSideY, paperSideZ);
			}	
			hull()
			{
				roundedTop(paperSideY, paperSideZ);
				mirror([1,0,0]) roundedTop(paperSideY, paperSideZ);
			}	
		}

		// Clearance on the off-side for debris::
        ec2 = edgeClearance/2;
		tcu([-ec2, -200, -100], [ec2, 400, 100]);
        clip = edgeClearance/4;
        clipOffsetX = 0; //paperZ/4;
        clipX = edgeClearance * cos(a2) * 0.5 + clipOffsetX;
        clipZ = edgeClearance * cos(a2) * 0.5;
        echo(str("clipX = ", clipX));
        echo(str("clipZ = ", clipZ));
        translate([0, -200, 0]) rotate([0,-a2,0]) tcu([-clipX+clipOffsetX,0,0], [clipX, 400, clipZ]);

		// Paper slot:
        rotate([0,a2,0]) translate([-clipX+clipOffsetX, -paperSlotY/2, -paperSlotExtraZ]) 
        {
            
            // Slot to the bottom:
            slotOffsetX = throughSlot ? 0 : -1;
            tcu([slotOffsetX, 0, 0], [200, paperSlotY, paperSlotZ]);

            // Chamfer at bottom entry:
            // MAGIC!!!
            //  -------++++
            //  -------||||-------------------------------------+
            //  -------vvvv-------------------------------------v------------------------vvvv
            translate([20.6,0,0]) rotate([-90,0,0]) rotate([0,0,8]) tcy([0,-paperSlotZ/2+0.17,0], d=2, h=paperSlotY, $fn=4); 
            
            // Chamfer at exit to blade:
            // MAGIC!!!
            //  -------+++
            //  -------vvv-------------------------------------v
            translate([8.3,0,0]) rotate([-90,0,0]) rotate([0,0,0]) 
            {
                // MAGIC!!!
                //  -----------------------vvvv
                translate([0,-paperSlotZ/2+0.07,0]) difference()
                {
                    cylinder(d=2, h=paperSlotY, $fn=4); 
                    tcu([-200,-400,-10], 400);
                }
            }

            if(throughSlot)
            {
                // Slot through the top:
                paperSlotTurnDia = 6;
                paperSlotTurnAngle = 45;
                rotate([-90,0,0]) difference()
                {
                    tcy([0,-paperSlotTurnDia/2,0], d=paperSlotTurnDia, h=paperSlotY);

                    tcy([0,-paperSlotTurnDia/2,-100], d=paperSlotTurnDia-2*paperSlotZ, h=400);

                    tcu([0,-200,-100], 400);
                    translate([0, -paperSlotTurnDia/2, 0]) rotate([0,0,paperSlotTurnAngle]) tcu([-400,-200,-100], 400);
                }

                shift = paperSlotTurnDia/2;
                rotate([-90,0,0]) translate([0, -shift, 0]) rotate([0,0,paperSlotTurnAngle]) 
                    tcu([-100, shift-paperSlotZ, 0], [100, paperSlotZ, paperSlotY]);
            }
        }

        // Clearance at the end for debris:
        doubleY()
        {
            endCleanceDia = 6;
            // MAGIC!!!!!
            //   ------------------------------------------------------vvv
            transitionChamferOffsetY = -paperSlotY/2-endCleanceDia/2 - 0.2;

            magicExtensionYLimit = 4;
            echo(str("extensionY = ", extensionY));
            if(extensionY > magicExtensionYLimit)
            {
                // Transition to end clerance cylinder:
                hull()
                {
                    rotate([-90,0,0]) translate([0,0,transitionChamferOffsetY]) cylinder(d1=endCleanceDia, d2=0, h=endCleanceDia/2);
                    rotate([-90,0,0]) translate([0,20,transitionChamferOffsetY]) cylinder(d1=endCleanceDia, d2=0, h=endCleanceDia/2);
                }

            
                rotate([-90,0,0]) tcy([0,0,transitionChamferOffsetY-100+nothing], d=endCleanceDia, h=100);
                tcu([-endCleanceDia/2, transitionChamferOffsetY-400+nothing, -100], [endCleanceDia, 400, 100]);
            }

            // End Chamfer:
            coneZ = 20;
            endChamferOffsetBigExtensionY = -paperSideY/2 - coneZ + endCleanceDia/2 + endCZ;
            // MAGIC!!!!
            //  ------------------------------------------------------------------vvvv
            endChamferOffsetSmallExtensionY = -paperSideY/2 - coneZ + extensionY - 0.7;

            endChamferOffsetY = extensionY > magicExtensionYLimit ? endChamferOffsetBigExtensionY : endChamferOffsetSmallExtensionY;
            echo(str("endChamferOffsetY = ", endChamferOffsetY));

            hull()
            {
                translate([0, endChamferOffsetY,    0]) rotate([-90,0,0]) cylinder(d1=coneZ*2, d2=0, h=coneZ);
                translate([0, endChamferOffsetY, -100]) rotate([-90,0,0]) cylinder(d1=coneZ*2, d2=0, h=coneZ);
            }
        }
	}
}

module roundedTop(paperSideY, paperSideZ)
{
	d = paperSideZ + 6;

	translate([1.5,0,1]) difference()
	{
		rotate([-90,0,0]) translate([0,0,-paperSideY/2]) simpleChamferedCylinderDoubleEnded(d=d, h=paperSideY, cz=endCZ);
		tcu([-200, -200, -400], 400);
		tcu([-400, -200, -200], 400);
	}
}

module paperSide(paperSideX, offSideY, offSideZ)
{
	hull()
	{
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([0,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([paperSideX-offSideZ/2,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
	}
}

module paperSideExtension(insideX, outsideX, offSideY, offSideZ)
{
	hull()
	{
		
		dy = -3;
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([insideX,dy,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([outsideX,dy,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([outsideX,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);

        
        paperSideExtensionIMiddleX = (outsideX + insideX)/2;
		// MAGIC!!!!!
		//   ---------------------------------------------------------------------------------------------vvv
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([paperSideExtensionIMiddleX, dy-1.3, 0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz = endCZ);
	}
}

module offSide(offSideX, offSideY, offSideZ)
{
	hull()
	{
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([0,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz=endCZ);
		translate([0, offSideY/2, offSideZ/2]) rotate([90,0,0]) translate([-offSideX+offSideZ/2,0,0]) simpleChamferedCylinderDoubleEnded(d=offSideZ, h=offSideY, cz=endCZ);
	}
}

cutStripX = 22;
cornerDia = 6;
cz = 1;
jigX = cornerDia +cutStripX + 130  + cornerDia/2;
jigY = cornerDia + paperY + 10 + cornerDia/2;
jigZ = 4 + 2*cz;
guideZ = jigZ + 4;
slotX = 1;
echo(str("jigY = ", jigY));
echo(str("jigZ = ", jigZ));

module paperCutGuide()
{
    ctrX = -(jigX - cornerDia/2)/2;
    ctrY = -(jigY - cornerDia/2)/2;
    echo(str("ctrX = ", ctrX));
    echo(str("ctrY = ", ctrY));
    
    ctrX1 = ctrX + cutStripX;
    ctrX2 = ctrX1 + cornerDia/2 + slotX + cornerDia/2;
    echo(str("ctrX1 = ", ctrX1));
    echo(str("ctrX2 = ", ctrX2));

    difference()
    {
        union()
        {
            hull()
            {
                doubleX() doubleY() translate([ctrX, ctrY, 0]) simpleChamferedCylinderDoubleEnded(d=cornerDia, h=jigZ, cz=cz);
            }
            
            hull()
            {
                translate([ctrX, ctrY, 0]) simpleChamferedCylinderDoubleEnded(d=cornerDia, h=guideZ, cz=cz);
                translate([ctrX, -ctrY, 0]) simpleChamferedCylinderDoubleEnded(d=cornerDia, h=guideZ, cz=cz);
            }
            
            
            hull()
            {
                translate([ctrX, ctrY, 0]) simpleChamferedCylinderDoubleEnded(d=cornerDia, h=guideZ, cz=cz);
                translate([ctrX1, ctrY, 0]) simpleChamferedCylinderDoubleEnded(d=cornerDia, h=guideZ, cz=cz);
            }
            hull()
            {
                translate([ctrX2,  ctrY, 0]) simpleChamferedCylinderDoubleEnded(d=cornerDia, h=guideZ, cz=cz);
                translate([-ctrX, ctrY, 0]) simpleChamferedCylinderDoubleEnded(d=cornerDia, h=guideZ, cz=cz);
            }
        }

        tcu([ctrX1+cornerDia/2-slotX/2, -150, jigZ-1.5], [slotX, 300, 100]);
    }
}

module clip(d=0)
{
	// tc([-200, -400-d, -10], 400);
	// tcu([0, -200, -200], 400);
    // tcu([-400, -200, -200], 400);
	// tcu([-200, -400+d, -200], 400);
}

if(developmentRender)
{
    display() translate([0,0,-6]) paperCutGuide();

    // displayAngle = 90;
    
	// display() jig(angle=displayAngle, edgeClearance=1.5, throughSlot=true, extensionY=12);
	// displayGhost() paperGhost(angle=displayAngle);

    // display() translate([-45,0,0]) jig(angle=displayAngle, edgeClearance=1.5, throughSlot=false, extensionY=4);

	// displayGhost() runnerGhost(width=3/8*mm, angle=displayAngle);
	// displayGhost() runnerGhost(width=1/4*mm, angle=displayAngle);
	// displayGhost() runnerGhost(width=3/16*mm, angle=displayAngle);
}
else
{
	if(makeStrip) rotate([90,0,0]) jig(angle=90, edgeClearance=1.5, throughSlot=true, extensionY=12);
    if(makeSheet) rotate([90,0,0]) jig(angle=90, edgeClearance=1.5, throughSlot=false, extensionY=4);
    if(makeGuide) paperCutGuide();
}

module runnerGhost(width, angle)
{
	y = 160;
	z = 40;
    dz = 0.35;
    dx = dz; //0.65;
	translate([-dx,0,-0.05-dz]) difference()
	{
		tcu([-width/2, -y/2, -z], [width, y, z]);

		doubleX() rotate([0, angle/2, 0]) tcu([-40, -200, 0], 400);
	}
}

module paperGhost(angle=90)
{
	rotate([0,angle/2,0]) tcu([-.5, -paperY/2, -paperSlotExtraZ], [paperX, paperY, paperZ]);
}
