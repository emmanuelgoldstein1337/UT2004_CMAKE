//-----------------------------------------------------------
// Vehicles will pickup items and give them to the driver
//-----------------------------------------------------------
class MutVehiclePickups extends Mutator;

function PostBeginPlay()
{
	local VehiclePickupRules G;

	Super.PostBeginPlay();
	G = spawn(class'VehiclePickupRules');

	if ( Level.Game.GameRulesModifiers == None )
		Level.Game.GameRulesModifiers = G;
	else
		Level.Game.GameRulesModifiers.AddGameRules(G);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local Vehicle V;

	V = Vehicle(Other);

	if (V != None)
		V.bCanPickupInventory = True;

	return true;
}

DefaultProperties
{
    GroupName="VehiclePickups"
    FriendlyName="Vehicle Pickups"
    Description="Vehicles will pickup items and give them to the driver"
}
