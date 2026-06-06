include <../OpenSCAD_Lib/MakeInclude.scad>
include <../OpenSCAD_Lib/chamferedCylinders.scad>

firstLayerHeight = 0.2;
layerHeight = 0.2;

mm = 25.4;

cardX = 3.25 * mm;
cardY = 2.00 * mm;  
cardZ = 0.05 * mm;
echo(str("Card = ", cardX, " x ", cardY, " x ", cardZ));

module itemModule()
{
	
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
