//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSArtilleryCannon extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSBPAnimations.ukx
#exec OBJ LOAD FILE=VMParticleTextures.utx
#exec OBJ LOAD FILE=ONSBPTextures.utx
#exec OBJ LOAD FILE=ONSBPSounds.uax
#exec OBJ LOAD FILE=DistantBooms.uax

var ONSMortarShell MortarShell, LastMortarShell;
var ONSMortarCamera MortarCamera;
var Rotator LastAim;
var float LastWeaponCharge;
var float StartHoldTime;
var float MaxHoldTime; //wait this long between shots for full damage
var float MinSpeed, MaxSpeed;
var float MortarSpeed;
var bool bHoldingFire;
var bool bCanHitTarget;
var sound ChargingSound, ChargedLoop;
var float TargetPredictionTimeStep;
var float WeaponCharge;
var vector PredictedTargetLocation;
var float PredicatedTimeToImpact;
var float LastCameraLaunch;
var float CameraLaunchWait;
var float LastBeepTime;
var() float TrajectoryErrorFactor;
var int CameraAttempts;

replication
{
    reliable if (bNetOwner && (Role == ROLE_Authority))
        MortarCamera;

    reliable if (Role < ROLE_Authority)
        ServerSetWeaponCharge;
}

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'WeaponSkins.RocketShellTex');
    L.AddPrecacheMaterial(Material'XEffects.RocketFlare');
    L.AddPrecacheMaterial(Material'XEffects.SmokeAlphab_t');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TankTrail');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    L.AddPrecacheMaterial(Material'ONSInterface-TX.tankBarrelAligned');
    L.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.cloudParticleOrange');
    L.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.TankDustKick1');
    L.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.TankDustKick');
    L.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.tankHitRocks');
    L.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.DirtPuffTEX');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'WeaponSkins.RocketShellTex');
    Level.AddPrecacheMaterial(Material'XEffects.RocketFlare');
    Level.AddPrecacheMaterial(Material'XEffects.SmokeAlphab_t');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TankTrail');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    Level.AddPrecacheMaterial(Material'ONSInterface-TX.tankBarrelAligned');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.cloudParticleOrange');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.TankDustKick1');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.TankDustKick');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.tankHitRocks');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.DirtPuffTEX');

    Super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');
	Super.UpdatePrecacheStaticMeshes();
}

// =====================================================================
// AI Interface

function AllowCameraLaunch()
{
	CameraAttempts = 0;
	LastCameraLaunch = Level.TimeSeconds - CameraLaunchWait;
}

function bool CanAttack(Actor Other)
{
    local actor HitActor;
    local vector HitNormal, HitLocation;

	if ( (Instigator == None) || (Instigator.Controller == None) )
        return false;

	if ( (Bot(Instigator.Controller) != None) && (Level.TimeSeconds - ONSArtillery(Owner).StartDrivingTime < 1) )
		return false;

	if ( MortarCamera == None )
	{
		if ( ((Level.TimeSeconds - LastCameraLaunch > CameraLaunchWait) && (VSize(Other.Location - Location) < 15000))
			|| ((Other == Instigator.Controller.Enemy) && (VSize(Other.Location - Location) < 4000) && Bot(Instigator.Controller).EnemyVisible()) )
			return true;
	}
	else
	{
		if ( !MortarCamera.bDeployed )
			return true;
		HitActor = Trace(HitLocation, HitNormal, Other.Location, MortarCamera.Location, false);
		if ( HitActor != None )
		{
            MortarCamera.Destroy();
            FireCountDown = AltFireInterval;
		}
		return true;
	}
	return false;
}

function byte BestMode()
{
	local bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Target == None) )
		return 0;

	if ( MortarCamera == None )
	{
		if ( VSize(B.Pawn.Location - B.Target.Location) > 4000 )
			return 1;
		if ( B.Target == B.Enemy )
		{
			if ( !B.EnemyVisible() )
				return 1;
		}
		else if ( !B.LineOfSightTo(B.Target) )
			return 1;
	}

	return 0;
}

function float CalcZSpeed(float XYSpeed, float FlightSize, float FlightZ)
{
	local float FlightTime;

	FlightTime = FlightSize/XYSpeed;
	if ( FlightTime == 0 )
		return XYSpeed;

	return FlightZ/FlightTime - 0.5 * PhysicsVolume.Gravity.Z * FlightTime;
}

/* SetMuzzleVelocity()
return adjustment to Z component of aiming vector to compensate for arc given the target
distance
*/
function vector SetMuzzleVelocity(vector Start, vector End, float StartXYPct)
{
	local vector Flight, FlightDir, TraceStart, TraceEnd, StartVel, HitLocation, HitNormal, Mid1, Mid2, Mid3;
	local float XYSpeed, ZSpeed, XYPct, FlightZ, FlightSize, FlightTime;
	local bool bFailed;
	local Actor HitActor;

	Flight = End - Start;
	FlightZ = Flight.Z;
	Flight.Z = 0;
	FlightSize = VSize(Flight);

	XYPct = StartXYPct;
	XYSpeed = XYPct*MaxSpeed;
	ZSpeed = CalcZSpeed(XYSpeed, FlightSize, FlightZ);

	while ( (XYPct < 1.0) && (ZSpeed*ZSpeed + XYSpeed * XYSpeed > MaxSpeed * MaxSpeed) )
	{
		// pick an XYSpeed
		XYPct += 0.05;
		XYSpeed = XYPct*MaxSpeed;
		ZSpeed = CalcZSpeed(XYSpeed, FlightSize, FlightZ);
	}

	// trace check trajectory
	bFailed = true;
	FlightDir = Normal(Flight);
	while ( bFailed && (XYPct > 0) )
	{
		StartVel = XYSpeed*FlightDir + ZSpeed*vect(0,0,1);
		TraceStart = Start;
		FlightTime = 0.25 * FlightSize/XYSpeed;
		TraceEnd = Start + StartVel*FlightTime + (0.5 * PhysicsVolume.Gravity.Z * FlightTime * FlightTime ) * vect(0,0,1) - vect(0,0,40);
		Mid1 = TraceEnd;

		if ( FastTrace(TraceEnd,TraceStart) )
		{
			// next segment
			TraceStart = TraceEnd;
			FlightTime = 0.5 * FlightSize/XYSpeed;
			TraceEnd = Start + StartVel*FlightTime + (0.5 * PhysicsVolume.Gravity.Z * FlightTime * FlightTime ) * vect(0,0,1) - vect(0,0,40);
			Mid2 = TraceEnd;
			if ( FastTrace(TraceEnd,TraceStart) )
			{
				// next segment
				TraceStart = TraceEnd;
				FlightTime = 0.75 * FlightSize/XYSpeed;
				TraceEnd = Start + StartVel*FlightTime + (0.5 * PhysicsVolume.Gravity.Z * FlightTime * FlightTime ) * vect(0,0,1) - vect(0,0,40);
				Mid3 = TraceEnd;
				if ( FastTrace(TraceEnd,TraceStart) )
				{
					// next segment
					TraceStart = TraceEnd;
					FlightTime = FlightSize/XYSpeed;
					TraceEnd = Start + StartVel*FlightTime + (0.5 * PhysicsVolume.Gravity.Z * FlightTime * FlightTime ) * vect(0,0,1);
					bFailed = !FastTrace(TraceEnd,TraceStart);
				}
			}

			if ( !bFailed )
			{
				// trace with extent check since projectile has extent
				HitActor = Trace(HitLocation, HitNormal, Mid2, Mid1, false, vect(20,20,20));
				if ( HitActor == None )
				{
					HitActor = Trace(HitLocation, HitNormal, Mid3, Mid2, false, vect(20,20,20));
					if ( HitActor == None )
					{
						HitActor = Trace(HitLocation, HitNormal, Mid1, Start, false, vect(20,20,20));
					}
				}
				bFailed = ( HitActor != None );
			}
		}

		if ( bFailed )
		{
			// if failed and trajectory already lowered, destroy camera
			if ( XYPct > StartXYPct )
			{
				CameraAttempts = 0;
				LastCameraLaunch = Level.TimeSeconds;
				if ( MortarCamera != None )
				{
					MortarCamera.Destroy();
					FireCountDown = AltFireInterval;
				}
				bFailed = false;
			}
			else
			{
				// else raise trajectory
				XYPct -= 0.1;
				XYSpeed = XYPct*MaxSpeed;
				ZSpeed = CalcZSpeed(XYSpeed, FlightSize, FlightZ);
				if ( ZSpeed*ZSpeed + XYSpeed * XYSpeed > MaxSpeed * MaxSpeed )
				{
					CameraAttempts = 0;
					LastCameraLaunch = Level.TimeSeconds;
					if ( MortarCamera != None )
					{
						MortarCamera.Destroy();
						FireCountDown = AltFireInterval;
					}
					bFailed = false;
				}
			}
		}
	}
	return XYSpeed*FlightDir + ZSpeed*vect(0,0,1);
}

function rotator AdjustAim(bool bAltFire)
{

	if ( AIController(Instigator.Controller) == None )
		return Super.AdjustAim(bAltFire);

	return Instigator.Controller.Rotation;
}
// =====================================================================

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return false;

	if (FireCountdown <= 0)
	{
		CalcWeaponFire();

		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);

		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
		if (bAltFire)
		{
			FireCountdown = AltFireInterval;
			AltFire(C);
		}
		else
		{
            if ( (MortarCamera != None) && (AIController(Instigator.Controller) == None) )
            {
                PredictTarget();
                if (!bCanHitTarget)
                {
                    if (PlayerController(C) != None && Level.TimeSeconds - LastBeepTime > 1.0)
                    {
                        PlayerController(C).ClientPlaySound(sound'MenuSounds.Denied1');
                        LastBeepTime = Level.TimeSeconds;
                    }
                    return false;
                }
            }
		    FireCountdown = FireInterval;
		    Fire(C);
		}
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;
	    return true;
	}
	return false;
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local vector StartLocation, HitLocation, HitNormal, Extent, TargetLoc;
    local ONSIncomingShellSound ShellSoundMarker;
    local Controller C;
	local bool bFailed;

    for ( C=Level.ControllerList; C!=None; C=C.nextController )
		if ( PlayerController(C)!=None )
			PlayerController(C).ClientPlaySound(sound'DistantBooms.DistantSPMA',true,1);

	if ( AIController(Instigator.Controller) != None )
	{
		if ( Instigator.Controller.Target == None )
		{
			if ( Instigator.Controller.Enemy != None )
				TargetLoc = Instigator.Controller.Enemy.Location;
			else
				TargetLoc = Instigator.Controller.FocalPoint;
		}
		else
			TargetLoc = Instigator.Controller.Target.Location;

		if ( !bAltFire && ((MortarCamera == None) || MortarCamera.bShotDown)
			&& ((VSize(TargetLoc - WeaponFireLocation) > 4000) || !Instigator.Controller.LineOfSightTo(Instigator.Controller.Target)) )
		{
			ProjClass = AltFireProjectileClass;
			bAltFire = true;
		}
	}
    if (bDoOffsetTrace)
    {
       	Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
        Extent.Z = ProjClass.default.CollisionHeight;
        if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
            StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
    }
    else
    	StartLocation = WeaponFireLocation;

    P = spawn(ProjClass, self, , StartLocation, WeaponFireRotation);

    if (P != None)
    {
 		if ( AIController(Instigator.Controller) == None )
		{
			P.Velocity = Vector(WeaponFireRotation) * P.Speed;
		}
		else
		{
			if ( P.IsA('ONSMortarCamera') )
			{
				P.Velocity = SetMuzzleVelocity(StartLocation, TargetLoc,0.25);
				ONSMortarCamera(P).TargetZ = TargetLoc.Z;
			}
			else
				P.Velocity = SetMuzzleVelocity(StartLocation, TargetLoc,0.5);
			WeaponFireRotation = Rotator(P.Velocity);
			ONSArtillery(Owner).bAltFocalPoint = true;
			ONSArtillery(Owner).AltFocalPoint = StartLocation + P.Velocity;
		}
		if ( !P.IsA('ONSMortarCamera') )
        {
           if (MortarCamera != None)
            {
				if ( AIController(Instigator.Controller) == None )
				{
					MortarSpeed = FClamp(WeaponCharge * (MaxSpeed - MinSpeed) + MinSpeed, MinSpeed, MaxSpeed);
					ONSMortarShell(P).Velocity = Normal(P.Velocity) * MortarSpeed;
				}
				ONSMortarShell(P).StartTimer(3.0 + (WeaponCharge * 2.5));
                ShellSoundMarker = spawn(class'ONSIncomingShellSound',,, PredictedTargetLocation + vect(0,0,400));
                ShellSoundMarker.StartTimer(PredicatedTimeToImpact);
            }
			else
				P.LifeSpan = 2.0;
        }

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

        if (ONSMortarCamera(P) != None)
        {
			CameraAttempts = 0;
			LastCameraLaunch = Level.TimeSeconds;
            MortarCamera = ONSMortarCamera(P);
            if (ONSArtillery(Owner) != None)
                ONSArtillery(Owner).MortarCamera = MortarCamera;
        }
        else
            MortarShell = ONSMortarShell(P);
    }
	else if ( AIController(Instigator.Controller) != None )
	{
		bFailed = ONSMortarCamera(P) == None;
		if ( !bFailed )
		{
			// allow 2 tries
			CameraAttempts++;
			bFailed = ( CameraAttempts > 1 );
		}

		if ( bFailed )
		{
			CameraAttempts = 0;
			LastCameraLaunch = Level.TimeSeconds;
			if ( MortarCamera != None )
			{
				MortarCamera.Destroy();
			}
		}
	}
    return P;
}

simulated event OwnerEffects()
{
	if (!bIsRepeatingFF)
	{
		if (bIsAltFire)
			ClientPlayForceFeedback( AltFireForce );
		else
			ClientPlayForceFeedback( FireForce );
	}
    ShakeView();

	if (Role < ROLE_Authority)
	{
        if (!bIsAltFire && (MortarCamera != None) && MortarCamera.bDeployed && !bCanHitTarget)
            return;

		if (bIsAltFire)
			FireCountdown = AltFireInterval;
		else
			FireCountdown = FireInterval;

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        FlashMuzzleFlash();

		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);

        // Play firing noise
        if (!bAmbientFireSound)
        {
            if (bIsAltFire)
            {
                if (MortarCamera == None)
                    PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
            }
            else
                PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
	}
	if ( !bIsAltFire && (MortarCamera != None) && MortarCamera.bDeployed && bCanHitTarget && (PlayerController(Instigator.Controller) != None) && (Viewport(PlayerController(Instigator.Controller).Player) != None) )
		PlayerController(Instigator.Controller).ClientPlaySound(FireSoundClass);
}

simulated function SetWeaponCharge(float Charge)
{
    WeaponCharge = Charge;
    if (Role < ROLE_Authority)
        ServerSetWeaponCharge(WeaponCharge);
}

function ServerSetWeaponCharge(float Charge)
{
    WeaponCharge = Charge;
}

simulated function float ChargeBar()
{
	return FClamp(1.0 - (FireCountDown / FireInterval), 0.0, 1.0);
}

simulated function NotifyDeployed()
{
    local vector LevelCameraPosition;
    local float LevelCameraDistance;

    // Roughly estimate what the WeaponCharge should be so that the reticle is close by
    LevelCameraPosition = MortarCamera.Location;
    LevelCameraPosition.Z = Location.Z;
    LevelCameraDistance = VSize(LevelCameraPosition - Location);
    WeaponCharge = FClamp((LevelCameraDistance - 3400.0)/10000.0, 0.0, 1.0);
}

simulated function PredictTarget()
{
    local int i;
    local vector CurrentPosition, LastPosition, HitLocation, HitNormal, CurrentVelocity;
    local float ErrorCorrection;

   if ( MortarCamera == None || !MortarCamera.bDeployed || (CurrentAim == LastAim && WeaponCharge == LastWeaponCharge) || (AIController(Instigator.Controller) != None) )
        return;

    CalcWeaponFire();
    CurrentPosition = WeaponFireLocation;
    LastPosition = CurrentPosition;

    MortarSpeed = FClamp(WeaponCharge * (MaxSpeed - MinSpeed) + MinSpeed, MinSpeed, MaxSpeed);

    // Estimation of the error accumulated from predicting the trajectory based on a smaller number of iterations than the actual shell will use
    ErrorCorrection = WeaponCharge * TrajectoryErrorFactor;

    CurrentVelocity = Vector(WeaponFireRotation) * (MortarSpeed + ErrorCorrection);

    for (i=0; i<=50; i++)
    {
        CurrentVelocity += PhysicsVolume.Gravity * TargetPredictionTimeStep;
        CurrentPosition += CurrentVelocity * TargetPredictionTimeStep;

        if (Trace(HitLocation, HitNormal, CurrentPosition, LastPosition, False) != None)
            break;
        LastPosition = CurrentPosition;
    }

    if (FireInterval - FireCountDown > 1.0 || VSize(LastHitLocation - HitLocation) > 500.0 + (WeaponCharge * 2000.0))  // Jitter Protection
    {
        MortarCamera.SetTarget(HitLocation);
        PredictedTargetLocation = HitLocation;
        PredicatedTimeToImpact = i * TargetPredictionTimeStep;
    	bCanHitTarget = ( (VSize(HitLocation - MortarCamera.Location) < FMin(17000,Region.Zone.DistanceFogEnd))
    						&& (FastTrace(HitLocation + vect(0,0,80), MortarCamera.Location)
    							|| FastTrace(HitLocation + vect(200,0,80), MortarCamera.Location)
    							|| FastTrace(HitLocation + vect(-200,0,80), MortarCamera.Location)
    							|| FastTrace(HitLocation + vect(0,200,80), MortarCamera.Location)
    							|| FastTrace(HitLocation + vect(0,-200,80), MortarCamera.Location))	);
        MortarCamera.SetReticleStatus(bCanHitTarget);
        LastHitLocation = HitLocation;
        LastAim = CurrentAim;
        LastWeaponCharge = WeaponCharge;
    }
}

simulated event FlashMuzzleFlash()
{
    Super.FlashMuzzleFlash();

	PlayAnim('Fire', 3.5);
}

DefaultProperties
{
    Mesh=Mesh'ONSBPAnimations.ArtilleryCannonMesh'
	RedSkin=Texture'ONSBPTextures.Skins.SPMATan'
    BlueSkin=Texture'ONSBPTextures.Skins.SPMAGreen'
    YawBone=BigGunbase
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchBone=Gun
    PitchUpLimit=12000
    PitchDownLimit=65535
    FireSoundClass=sound'ONSBPSounds.Artillery.ArtilleryFire'
    AltFireSoundClass=sound'ONSBPSounds.Artillery.ArtilleryFire'
    FireForce="Explosion05"
    ProjectileClass=class'OnslaughtBP.ONSMortarShell'
    AltFireProjectileClass=class'OnslaughtBP.ONSMortarCamera'
    EffectEmitterClass=class'OnslaughtBP.ONSArtilleryCannonMuzzleFlash'
    FireInterval=4.0
    AltFireInterval=4.0
    FireSoundVolume=512
    ShakeRotMag=(Z=250)
    ShakeRotRate=(Z=2500)
    ShakeRotTime=6
    ShakeOffsetMag=(Z=10)
    ShakeOffsetRate=(Z=200)
    ShakeOffsetTime=10
    WeaponFireAttachmentBone=CannonFirePoint
    WeaponFireOffset=200.0
    bAimable=True
    RotationsPerSecond=0.18
    Spread=0.015
    MinSpeed=2000
    MaxSpeed=4000
    MaxHoldTime=1.5
    bShowChargingBar=True
	bShowAimCrosshair=False
    TargetPredictionTimeStep=0.3
    WeaponCharge=0.25
    TrajectoryErrorFactor=150.0
    RotateSound=sound'ONSBPSounds.Artillery.CannonRotate'
    AIInfo(0)=(bTossed=true,bLeadTarget=true,bTrySplash=true,WarnTargetPct=1.0,RefireRate=0.99)
    AIInfo(1)=(bTossed=true,bLeadTarget=true,bTrySplash=true,WarnTargetPct=1.0,RefireRate=0.99)
	CameraLaunchWait=+5.0
}
