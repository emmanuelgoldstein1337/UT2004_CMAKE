/** use this factory to make defending bots use the vehicle */
class ASDefensiveVehicleFactory extends ASVehicleFactory;

function VehicleSpawned()
{
	Super.VehicleSpawned();
	Child.bDefensive = true;
}