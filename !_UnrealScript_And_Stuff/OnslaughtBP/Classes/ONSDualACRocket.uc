//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSDualACRocket extends Projectile;

#exec OBJ LOAD FILE=..\Sounds\VMVehicleSounds-S.uax

var()   float   SpiralForceMag;
var()   float   InwardForceMag;
var()   float   ForwardForceMag;
var()   float   DesiredDistanceToAxis;
var()   float   DesiredDistanceDecayRate;
var()	float	InwardForceMagGrowthRate;

var		float	CurSpiralForceMag;
var		float	CurInwardForceMag;
var		float	CurForwardForceMag;

var     float   DT;

var bool bSpiralClockwise;

var vector AxisOrigin;
var vector AxisDir;
var vector RepAxisDir;

var Emitter SmokeTrailEffect;

var vector 	Target, SecondTarget, InitialDir;
var float 	KillRange;
var bool 	bFinalTarget;
var float 	SwitchTargetTime;

var sound  	IgniteSound;
var sound 	FlightSound;

replication
{
    reliable if ( Role == ROLE_Authority )
        RepAxisDir, AxisOrigin, bSpiralClockwise, Target, SecondTarget, SwitchTargetTime, bFinalTarget;
}

simulated function Destroyed()
{

	if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();

	Super.Destroyed();
}

simulated function PostNetBeginPlay()
{
	local float t;

	super.PostNetBeginPlay();

	t = (frand() * 0.15) + 0.15;
	SetTimer(t,false);

}

simulated function Timer()
{
	local float dist,travelTime;
	local PlayerController PC;

	SetCollision(true,true);

	if (Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrailEffect = Spawn(class'ONSDualMissileSmokeTrail',self);

		if ( EffectIsRelevant(location,false) )
		{
			PC = Level.GetLocalPlayerController();
			if ( (PC.ViewTarget != None) && (VSize(PC.ViewTarget.Location - Location) < 3000) )
				Spawn(class'ONSDualMissileIgnite',,,location,rotation);
		}

		SetDrawType(DT_None);

		PlaySound(IgniteSound, SLOT_Misc, 255, true, 512);
		AmbientSound = FlightSound;
	}

	Velocity = vector(Rotation) * MaxSpeed;

	if (!bFinalTarget)
	{
		Dist = vsize(Target - Location);
		TravelTime = Dist / vsize(Velocity);
		if ( FastTrace(SecondTarget, Location) )
		{
			if ( TravelTime < (SwitchTargetTime*0.9) )
			{
				Target = SecondTarget;
				bFinalTarget = true;
			}
		}
		else
		{

			if (TravelTime < SwitchTargetTime)
				SwitchTargetTime = TravelTime * 0.9;
		}

		GotoState('Spiraling');
	}
	else
	{
		if ( Vsize(Location - Target) <= KillRange )
		{
			GotoState('Homing');
		}
		else
		{

			GotoState('Spiraling');
		}
	}
}


state Spiraling
{
	simulated function BeginState()
	{
    	CurSpiralForceMag = SpiralForceMag;
    	CurInwardForceMag = InwardForceMag;
    	CurForwardForceMag = ForwardForceMag;

	    bSpiralClockwise = (FRand() > 0.5);

	    AxisOrigin = Location;
	    AxisDir =  Normal(Target - AxisOrigin);

	    if (Role == ROLE_Authority)
	        RepAxisDir = AxisDir * 100.0;

	    if (Owner != None && Owner.Instigator != None && Owner.Instigator.IsA('Vehicle'))
	        Velocity = FMax(Owner.Instigator.Velocity dot AxisDir, 0.0) * AxisDir;
	    else
	        Velocity = AxisDir * Speed;


		if (PhysicsVolume != None && PhysicsVolume.bWaterVolume)
			Velocity = 0.6 * Velocity;

		SetTimer(DT, true);
	}

	simulated function Timer()
	{
	    local vector ParallelComponent, PerpendicularComponent, NormalizedPerpendicularComponent;
	    local vector SpiralForce, InwardForce, ForwardForce;
	    local float InwardForceScale;

		// Add code to switch directions

		// Update the inward force magnitude.
  		CurInwardForceMag += InwardForceMagGrowthRate * DT;

	    ParallelComponent = ((Location - AxisOrigin) dot AxisDir) * AxisDir;
	    PerpendicularComponent = (Location - AxisOrigin) - ParallelComponent;
	    NormalizedPerpendicularComponent = Normal(PerpendicularComponent);

	    InwardForceScale = VSize(PerpendicularComponent) - DesiredDistanceToAxis;

	    SpiralForce = CurSpiralForceMag * Normal(AxisDir cross NormalizedPerpendicularComponent);
	    InwardForce = -CurInwardForceMag * InwardForceScale * NormalizedPerpendicularComponent;
	    ForwardForce = CurForwardForceMag * AxisDir;

	    if (bSpiralClockwise)
	        SpiralForce *= -1.0;

	    Acceleration = SpiralForce + InwardForce + ForwardForce;

	    DesiredDistanceToAxis -= DesiredDistanceDecayRate * DT;
	    DesiredDistanceToAxis = FMax(DesiredDistanceToAxis, 0.0);

		// Update rocket so it faces in the direction its going.
		SetRotation(rotator(Velocity));

		// Check to see if we should switch to Home in Mode

		if (!bFinalTarget)
		{
			SwitchTargetTime -= DT;
			if ( SwitchTargetTime<=0 )
			{
				bFinalTarget = true;
				SwitchTargetTime = 0;
				Target = SecondTarget;
				BeginState();
				return;
			}
		}
		else
		{
			if ( Vsize(Location - Target) <= KillRange )
			{
				GotoState('Homing');
				return;
			}
		}
	}

}

state Homing
{
	simulated function Timer()
	{
	    local vector ForceDir;
	    local float VelMag;

	    if ( InitialDir == vect(0,0,0) )
	        InitialDir = Normal(Velocity);

		Acceleration = vect(0,0,0);
	    Super.Timer();

		// do normal guidance to target.
		ForceDir = Normal(Target - Location);

		if( (ForceDir Dot InitialDir) > 0 )
		{
			VelMag = VSize(Velocity);

			// track vehicles better
			ForceDir = Normal(ForceDir * 0.5 * VelMag + Velocity);
			Velocity =  VelMag * ForceDir;
			Acceleration += 5 * ForceDir;
		}
		// Update rocket so it faces in the direction its going.
		SetRotation(rotator(Velocity));
	}

	simulated function BeginState()
	{
	    SetTimer(0.1, true);
	}
}


simulated function Landed( vector HitNormal )
{
	Explode(Location, HitNormal);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
	{
		Explode(HitLocation, vect(0,0,1));
	}
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);

    if ( EffectIsRelevant(Location,false) )
    {
 			PC = Level.GetLocalPlayerController();
			if ( (PC.ViewTarget != None) && (VSize(PC.ViewTarget.Location - Location) < 8000) )
   				Spawn(class'ONSDualMissileExplosion',,,HitLocation + HitNormal*20,rotator(HitNormal));
    }

	BlowUp(HitLocation);
	Destroy();
}

defaultproperties
{
    Speed=25.0
    MaxSpeed=8000.0
    SpiralForceMag=800.0
    InwardForceMag=25.0
    ForwardForceMag=15000.0
    DesiredDistanceToAxis=250.0
    DesiredDistanceDecayRate=500.0
    InwardForceMagGrowthRate=0.0
    DT=0.1
    MomentumTransfer=10000
    Damage=50
    DamageRadius=250.0
    AmbientSound=none //sound'VMVehicleSounds-S.HoverTank.IncomingShell'
    SoundVolume=255
    SoundRadius=256
    MyDamageType=class'DamTypeONSCicadaRocket'
    ExplosionDecal=class'ONSRocketScorch'
    RemoteRole=ROLE_SimulatedProxy
    LifeSpan=7.0
    DrawType=DT_StaticMesh
    DrawScale=0.25
    StaticMesh=StaticMesh'VMWeaponsSM.BomberBomb'
    AmbientGlow=96
    bUnlit=True
    bBounce=False
    bFixedRotationDir=True
    RotationRate=(Roll=50000)
    DesiredRotation=(Roll=900000)
    ForceType=FT_Constant
    ForceScale=5.0
    ForceRadius=100.0
    bCollideWorld=True
    bCollideActors=false
    FluidSurfaceShootStrengthMod=10.0
    bNetTemporary=True
    LightType=LT_None
    bDynamicLight=False
    KillRange=3000
    IgniteSound=sound'CicadaSnds.MissileIgnite'
    FlightSound=sound'CicadaSnds.MissileFlight'
	CullDistance=+3000.0
}
