include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

mm = 25.4;

// Measured dimensions of a card, in mm:
cardX = 82.6; // 3.25 * mm;
cardY = 50.1; //2.00 * mm;  
cardZ = 1.4; //0.05 * mm;
echo(str("Card = ", cardX, " x ", cardY, " x ", cardZ));

sideX = cardX + 2*10;

nutThThickness = 3;
nutRecessX = 3;

pivotScrewMinLength = sideX + nutThThickness - nutRecessX;
echo(str("pivotScrewMinLength = ", pivotScrewMinLength, " mm"));
echo(str("pivotScrewMinLength = ", pivotScrewMinLength/mm, " inches"));

module itemModule()
{
	difference()
    {

    }
}

module clip(d=0)
{
	//tc([-200, -400-d, -10], 400);
}

if(developmentRender)
{
	display() itemModule();
}
else
{
	itemModule();
}
