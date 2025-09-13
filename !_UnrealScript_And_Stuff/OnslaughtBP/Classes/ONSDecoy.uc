//-----------------------------------------------------------
//  When out in the world, this can be used to decoy an avril.
//-----------------------------------------------------------
class ONSDecoy extends Projectile;

var class<emitter> 	DecoyFlightSFXClass; 	// Class of the emitter to spawn for the effect
var class<emitter> 	DecoyLaunchSFXClass;	// Class of the emitter to spawn when launched
var emitter			DecoyFlightSFX;			// The actual effect
var float 			DecoyRange;				// Much much range before the decoy says look at me

var ONSDualAttackCraft	ProtectedTarget;	// Protect this vehicle

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	Velocity = Speed * Vector(Rotation);
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	if ( EffectIsRelevant(Location, false) )
		Spawn(DecoyLaunchSFXClass,,,location,Rotation);

	if ( (Level.NetMode != NM_DedicatedServer) && (DecoyFlightSFXClass != None) )
	{
		DecoyFlightSFX = spawn(DecoyFlightSFXClass);
		if (DecoyFlightSFX!=None)
			DecoyFlightSFX.SetBase(self);
	}
}

function bool CheckRange(actor Aggressor)
{
	return vsize(Aggressor.Location - location) <= DecoyRange;
}

simulated event Destroyed()	// Remove it from the Dual Attack craft's array
{
	local int i;

	super.Destroyed();

	if (ProtectedTarget!=None)
	{
		for (i=0;i<ProtectedTarget.Decoys.Length;i++)
		{
			if (ProtectedTarget.Decoys[i]!=none && ProtectedTarget.Decoys[i] == self)
			{
				ProtectedTarget.Decoys.Remove(i,1);
				return;
			}
		}
	}

	if (DecoyFlightSFX!=None)
		DecoyFlightSFX.Destroy();
}


simulated function Landed( vector HitNormal )
{
	super.Landed(HitNormal);
	Destroy();
}

defaultproperties
{
	LifeSpan=5.0
	DecoyFlightSFXClass=class'ONSDecoyFlight'
	DecoyLaunchSFXClass=class'ONSDecoyLaunch'
	DecoyRange=2048
    Speed=1000
    MaxSpeed=1500
    MomentumTransfer=10000
    Damage=50.0
    DamageRadius=250.0
    RemoteRole=ROLE_SimulatedProxy
    bBounce=true
    bNetTemporary=True
    Physics=PHYS_Falling
    AmbientSound=sound'CicadaSnds.Decoy.DecoyFlight'
}
