//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DamTypeShockTankProximityExplosion extends VehicleDamageType;

DefaultProperties
{
    DeathString="%o got too close to %k's Paladin."

    bAlwaysSevers=true

    VehicleClass=class'ONSShockTank'
    bDetonatesGoop=true
    bThrowRagdoll=true
}
