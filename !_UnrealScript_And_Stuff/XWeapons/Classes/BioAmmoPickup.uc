class BioAmmoPickup extends UTAmmoPickup;

#exec OBJ LOAD FILE=PickupSounds.uax

simulated function PostBeginPlay()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;
	
	Super.PostBeginPlay();
	
	// check to see if imbedded (stupid LD)
	HitActor = Trace(HitLocation, HitNormal, Location - CollisionHeight * vect(0,0,1), Location + CollisionHeight * vect(0,0,1), false);
	if ( (HitActor != None) && HitActor.bWorldGeometry )
		SetLocation(HitLocation + vect(0,0,1) * CollisionHeight);
}

defaultproperties
{
    InventoryType=class'BioAmmo'
	PrePivot=(Z=10.5)
    PickupMessage="You picked up some Bio-Rifle ammo"
    PickupSound=Sound'PickupSounds.FlakAmmoPickup'
    PickupForce="FlakAmmoPickup"  // jdf

    AmmoAmount=20

    MaxDesireability=0.320000
    CollisionHeight=8.250000

    StaticMesh=StaticMesh'WeaponStaticMesh.BioAmmoPickup'
    DrawType=DT_StaticMesh
}
