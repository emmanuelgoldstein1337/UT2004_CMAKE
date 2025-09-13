//-----------------------------------------------------------
// ONSDaulACSideGun - (C) 2004, Epic Games
// Joe Wilcox
//
// This is the primary weapon the Cicada.
//-----------------------------------------------------------
class ONSDualACSideGun extends ONSLinkableWeapon;

var bool bSkipFire;			// If true, it ignore this shot and pass it to it's linked weapon
var bool bFiresRight;		// If true, this weapon will eject shells to the right instead of the left

var int LoadedShotCount, MaxShotCount;	// LoadedShotCount = # of shots loaded, MaxShotCount = Max # to load
var float RelockTime;					// Time before we can reacquire a lock

var sound ReloadSound;			// Sound to play when loading a rocket

var bool bDumpingLoad;			// Are we dumping our load of rockets?
var Controller FireControl;		// Temp. Storage of who is doing the firing.

var bool bLocked;				// If true all shots are locked to the vector below
var vector LockedTarget;		// If bLocked, all missiles will home to this location
var vector LockPosition;		// position when locked on

replication
{
	reliable if (Role==ROLE_Authority)
		bLocked, LockedTarget;
}

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim )
		return False;

	if (bAltFire)
	{
		if ( Bot(C) != None )
		{
			if ( (Vehicle(Instigator).Rise <= 0) && FastTrace(Instigator.Location - vect(0,0,500),Instigator.Location) )
				Vehicle(Instigator).Rise = -0.5;
			else
				Vehicle(Instigator).Rise = 1;
		}
		if (!bLocked && LoadedShotCount == 0)	// Handle Alt Fire
			ChangeTargetLock();

		if ( !bDumpingLoad && FireCountdown <= 0 )
		{
			if ( LoadedShotCount < MaxShotCount)
			{
				LoadedShotCount++;
				PlaySound(sound'CicadaSnds.Missile.MissileLoad');
				FireCountdown = AltFireInterval;
		   		Instigator.MakeNoise(1.0);
		   	}
		   	else
				WeaponCeaseFire(C, true);
		}
	}
	else
	{
		if ( Bot(Instigator.Controller) != None )
			Vehicle(Instigator).Rise = 0;
		if (LoadedShotCount==0 && FireCountdown <= 0)
			FireSingle(C,false, true);
	}

	return False;
}

function ChangeTargetLock()
{
	bLocked = true;
	CalcWeaponFire();
	ONSDualACSideGun(ChildWeapon).bLocked = true;
	LockedTarget = FindInitialTarget(WeaponFireLocation, WeaponFireRotation);
	ONSDualACSideGun(ChildWeapon).LockedTarget = LockedTarget;
	RelockTime = Level.TimeSeconds + 2.00;
    SpawnTargetBeam();
}

function SpawnTargetBeam()
{
	local PainterBeamEffect BP;

	BP = Spawn(class'CicadaLockBeamEffect',self);
	BP.StartEffect = WeaponFireLocation;
	BP.EndEffect = LockedTarget;
	BP.EffectOffset = vect(0,0,-20);
	BP.SetTargetState(PTS_Aquired);
}
function FireSingle(Controller C, bool bAltFire, optional bool bDontSkip)
{
    if (!bSkipFire || bDontSkip)
    {
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(false);

       	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);

	    if (bAltFire)
	    {
	    	FireCountdown = AltFireInterval;
		    AltFire(C);
		}
		else
		{
			FireCountdown = FireInterval;
			Fire(C);
		}

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;
	}
	else
	{
	    FireCountdown = FireInterval;
	}

	bSkipFire = !bSkipFire;

	if (ChildWeapon != none && ONSDualACSideGun(ChildWeapon) != None)
        ONSDualACSideGun(ChildWeapon).FireSingle(C, bAltFire, bDontSkip);

}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local vector StartLocation, StartVelocity;
    local rotator WFR, UpRot;
    local float Rand;

	// We want projectiles to "eject" from this gun then take flight.  Part is handled here, part in
	// the projectile.

	if ( Bot(Instigator.Controller) != None )
		Vehicle(Instigator).Rise = 0;
   	StartLocation = WeaponFireLocation;
	Rand = (400 * frand()) + 200;	// This is our range for the ejection.

	// if we are going forward, apply the ships velocity to the projectile,
	// if we are going backwards, apply the 1/4 the inverse X/Y.

	WFR = WeaponFireRotation;
	if (bLocked)
		WFR.Pitch += 2048;

    StartVelocity = Instigator.Velocity;

	// Modify the start velocity so it ejects to the proper side.

	if (bFiresRight)
	   	StartVelocity += (Vector(WFR) cross vect(0,0,-1)) * 450;
	else
	   	StartVelocity += (Vector(WFR) cross vect(0,0,1)) * 450;

	// Always kick it up a little bit more

	if ( bAltFire )
	   	StartVelocity.Z += (Rand * ( frand()*2));
	else
		StartVelocity.Z = 200;

    P = spawn(ProjClass, self, , StartLocation, WFR);

    P.Velocity = StartVelocity;	// Apply the velocity
	if ( bAltFire && bLocked && (Bot(Instigator.Controller) != None) && !FastTrace(LockedTarget,P.Location) )
	{
		UpRot = WeaponFireRotation;
		UpRot.Pitch = 12000;
		if ( !FastTrace(P.Location + 3000*vector(UpRot),P.Location) )
			UpRot.Pitch = 16000;
		ONSDualACRocket(P).Target = FindInitialTarget(WeaponFireLocation, UpRot);
	}
	else
		ONSDualACRocket(P).Target = FindInitialTarget(WeaponFireLocation, WeaponFireRotation);

    if (!bAltFire)
	    ONSDualACRocket(P).DesiredDistanceToAxis = 64;
	else
		ONSDualACRocket(P).KillRange=4500;

    if (bLocked)
    {
        ONSDualACRocket(P).bFinalTarget 	= false;
		ONSDualACRocket(P).SecondTarget 	= LockedTarget;
		ONSDualACRocket(P).SwitchTargetTime = 0.5;
	}
	else
        ONSDualACRocket(P).bFinalTarget = true;

	// Play effects

    if (P != None)
    {
        FlashMuzzleFlash();

        // Play firing noise
        if (bAltFire)
        {
            if (bAmbientAltFireSound)
                AmbientSound = AltFireSoundClass;
            else
                PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
        }
        else
        {
            if (bAmbientFireSound)
                AmbientSound = FireSoundClass;
            else
                PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }

    }

    return P;
}

simulated function ClientStopFire(Controller C, bool bWasAltFire)
{
	if (Level.NetMode != NM_Client)
		return;

	if (bWasAltFire)
		LoadedShotCount=0;

	super.ClientStopFire(C,bWasAltFire);
}

function Timer()
{
	if (LoadedShotCount>0)
	{
		FireSingle(FireControl,true);
		LoadedShotCount--;
	}

	if (LoadedShotCount<=0)
	{
		RemoveLock();
		FireCountdown = FireInterval;
		Disable('Timer');
		SetTimer(0,false);
		bDumpingLoad = false;
	}
}

function WeaponCeaseFire(Controller C, bool bWasAltFire)
{
	if (bWasAltFire)
	{
		if (LoadedShotCount>0)
		{
			bDumpingLoad=true;
			FireControl = C;
			Enable('timer');
			SetTimer(0.1,true);
		}
	}
}

simulated event OwnerEffects()
{
	if (Level.NetMode == NM_Client && bIsAltFire)
		LoadedShotCount++;

	if (LoadedShotCount<MaxShotCount)
		super.OwnerEffects();

}

function vector FindInitialTarget(vector Start, rotator Dir)
{
	local vector HitLocation,HitNormal,end;
	local actor a;

	end = Start + Instigator.Region.Zone.DistanceFogEnd *vector(Dir);
	a = trace(HitLocation,HitNormal,End,Start,true);
	if (  a != none )
		return HitLocation;
	else
		return End;

}

function RemoveLock()
{
	bLocked = false;
	ONSDualACSideGun(ChildWeapon).bLocked = false;
}

//=====================================================
// AI Interface

// return false if out of range, can't see target, etc.
function bool CanAttack(Actor Other)
{
	if ( (LoadedShotCount>0) && (VSize(LockedTarget - Other.Location) < 100 + Other.CollisionRadius + Other.CollisionHeight) )
		return true;
	return Super.CanAttack(Other);
}

//AI: return the best fire mode for the situation
function byte BestMode()
{
	if ( (Instigator.Controller == None) || (Instigator.Controller.Target == None) )
		return 1;
	if ( (Pawn(Instigator.Controller.Target) != None) && !Pawn(Instigator.Controller.Target).bStationary && (Instigator.Controller.Focus == Instigator.Controller.Target) )
		return 0;
	return 1;
}

defaultproperties
{
    Mesh=Mesh'ONSBPAnimations.DualAttackCraftSideGunMesh'
    YawBone=RL_Right
    PitchBone=RL_Right
    WeaponFireAttachmentBone=FirePoint
    ProjectileClass=class'OnslaughtBP.ONSDualACRocket'
    AltFireProjectileClass=class'OnslaughtBP.ONSDualACRocket'
    FireInterval=0.5
    AltFireInterval=0.33
    YawStartConstraint=-5000
    YawEndConstraint=5000
    PitchUpLimit=18000
    PitchDownLimit=50000
    FireSoundClass=sound'CicadaSnds.Missile.MissileEject'
    AltFireSoundClass=sound'CicadaSnds.Missile.MissileEject'
    bAimable=True
    RotationsPerSecond=0.09
    MaxShotCount=16
	FireSoundVolume=70.0
	AltFireSoundVolume=70.0
	bInstantRotation=true
    AIInfo(0)=(bLeadTarget=true,bTrySplash=true,WarnTargetPct=0.5,RefireRate=0.99)
    AIInfo(1)=(bLeadTarget=false,bTrySplash=true,WarnTargetPct=0.2,RefireRate=0.99)
	CullDistance=+7000.0
}
