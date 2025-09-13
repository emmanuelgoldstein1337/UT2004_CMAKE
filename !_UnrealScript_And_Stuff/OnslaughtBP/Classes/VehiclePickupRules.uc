//-----------------------------------------------------------
//
//-----------------------------------------------------------
class VehiclePickupRules extends GameRules;

function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup)
{
    if (Other.IsA('Vehicle') && Vehicle(Other).bDriving)
    {
        item.Touch(Vehicle(Other).Driver);
        bAllowPickup = 0;

        return True;
    }
    return False;
}

DefaultProperties
{

}
