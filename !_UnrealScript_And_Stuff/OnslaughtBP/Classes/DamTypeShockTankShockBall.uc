//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DamTypeShockTankShockBall extends VehicleDamageType;

DefaultProperties
{
    DeathString="%o couldn't avoid the blast from %k's Paladin."

    bAlwaysSevers=true

    VehicleClass=class'ONSShockTank'
    bDetonatesGoop=true
    bThrowRagdoll=true
}
