//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSMortarCamera extends ONSMortarShell;

var bool                        bDeployed, bLastDeployed;
var bool                        bShotDown, bLastShotDown;
var ONSMortarTargetBeam         TargetBeam;
var float                       TargetUpdateTime;
var Emitter                     Thruster[4];
var byte                        TeamNum;
var vector                      MortarCameraOffset;
var vector                      DeployedLocation;
var float                       MessageUpdateTime;
var vector                      RealLocation, LastRealLocation;

// for AI use
var float						DeployRand;
var	float						MaxHeight;
var float						TargetZ;
var	float						AnnounceTargetTime;

replication
{
    reliable if (Role == ROLE_Authority)
        RealLocation, bDeployed, bShotDown, TeamNum;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    if (Instigator != None && Instigator.Controller != None)
        TeamNum = Instigator.Controller.GetTeamNum();
}

simulated function PostNetReceive()
{
    Super.PostNetReceive();

    if (bDeployed != bLastDeployed)
    {
        GotoState('Deployed');
        bLastDeployed = bDeployed;
    }

    if (bShotDown != bLastShotDown)
    {
        ShotDown();
        bLastShotDown = bShotDown;
    }

	if ( RealLocation != LastRealLocation )
	{
		SetLocation(RealLocation);
		LastRealLocation = RealLocation;
	}
}

simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
	if ( NewVolume.bWaterVolume )
		Landed(vect(0,0,0));
}

function Deploy()
{
	AnnounceTargetTime = Level.TimeSeconds + 1 + (7 - Level.Game.GameDifficulty);
    bDeployed = True;
    AmbientSound = sound'ONSBPSounds.Artillery.CameraAmbient';

    GotoState('Deployed');
}

simulated function SpawnThrusters()
{
	if ( Level.NetMode == NM_DedicatedServer )
		return;
    if (TeamNum == 0)
    {
        Thruster[0] = spawn(class'ONSArtilleryCamThrusterRed');
        Thruster[1] = spawn(class'ONSArtilleryCamThrusterRed');
        Thruster[2] = spawn(class'ONSArtilleryCamThrusterRed');
        Thruster[3] = spawn(class'ONSArtilleryCamThrusterRed');
    }
    else
    {
        Thruster[0] = spawn(class'ONSArtilleryCamThrusterBlue');
        Thruster[1] = spawn(class'ONSArtilleryCamThrusterBlue');
        Thruster[2] = spawn(class'ONSArtilleryCamThrusterBlue');
        Thruster[3] = spawn(class'ONSArtilleryCamThrusterBlue');
    }

    AttachToBone(Thruster[0], 'BoosterRight');
    AttachToBone(Thruster[1], 'BoosterLeft');
    AttachToBone(Thruster[2], 'BoosterTop');
    AttachToBone(Thruster[3], 'BoosterBottom');
}

simulated state Deployed
{
Begin:
	RealLocation = Location;
    Velocity = vect(0,0,0);
    DeployedLocation = Location;
    SpawnThrusters();
    SetPhysics(PHYS_Projectile);
    bRotateToDesired = true;
    DesiredRotation = rot(-16384,0,0);
    PlayAnim('Deploy', 1.0, 0.0);
    if ( Instigator != None && Instigator.IsLocallyControlled() && Instigator.IsHumanControlled() )
    {
        TargetBeam = spawn(class'ONSMortarTargetBeam', self,, Location, rot(0,0,100));
        TargetBeam.ArtilleryLocation = Instigator.Location;
        ONSArtilleryCannon(Owner).NotifyDeployed();
    }
    sleep(2.0);
    bRotateToDesired = false;
	RealLocation = Location;
}

simulated function SetTarget(vector loc)
{
    if (TargetBeam != None)
        TargetBeam.TargetLocation = loc;
}

simulated function SetReticleStatus(bool bStatus)
{
    if (TargetBeam != None)
        TargetBeam.SetStatus(bStatus);
}

simulated function bool SpecialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation, bool bBehindView)
{
	local vector HitNormal, HitLocation;

	if (bDeployed && !bBehindView)
        CameraLocation = Location + (MortarCameraOffset >> Rotation);
    else
        CameraLocation = Location + (vect(-800,0,300) >> CameraRotation);

    if( Trace( HitLocation, HitNormal, CameraLocation, Location,false,vect(10,10,10) ) != None )
		CameraLocation = HitLocation;

    return True;
}

simulated function Tick(float DT)
{
    local actor HitActor;
    local vector HitNormal, HitLocation;
	local Controller C;
	local Bot B;

    Super.Tick(DT);

    if (Instigator == None || ONSArtillery(Instigator) == None || ONSArtillery(Instigator).Driver == None)
    {
        bShotDown = True;
        ShotDown();
    }

    if ( Level.TimeSeconds - MessageUpdateTime > 2.0 )
    {
		if ( (Instigator != None) && (Instigator.Controller != None)
			&& (Instigator.Controller == Level.GetLocalPlayerController()) && (Level.GetLocalPlayerController().ViewTarget == self) )
		{
			if (bDeployed)
				PlayerController(Instigator.Controller).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 33);
			else
				PlayerController(Instigator.Controller).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 34);
		}
        MessageUpdateTime = Level.TimeSeconds;
    }

    if (!bDeployed)
	{
        SetRotation(Rotator(Velocity));

		if ( (Instigator != None) && (AIController(Instigator.Controller) != None) && (Velocity.Z <= 0) )
        {
			if ( MaxHeight == 0 )
			{
				MaxHeight = Location.Z;
				DeployRand = FRand();
				if ( DeployRand < 0.5 )
					DeployRand = 1;
			}
			if ( Location.Z - TargetZ > (0.2 + 0.8*DeployRand) * (MaxHeight - TargetZ) )
				return;
			HitActor = Trace(HitLocation, HitNormal, Instigator.Controller.Target.Location, Location, false);
			if ( HitActor == None )
			{
				Deploy();
			}
		}
	}
	else if ( (Level.TimeSeconds - AnnounceTargetTime > 1.0) && (Role == ROLE_Authority) )
	{
		if ( (Instigator == None) || (Instigator.Controller == None) || (ONSArtilleryCannon(Owner) == None) )
		{
			Disable('Tick');
			return;
		}
		AnnounceTargetTime = Level.TimeSeconds;
		if ( !bShotDown )
		{
			For ( C=Level.ControllerList; C!=None; C=C.NextController )
			{
				B = Bot(C);
				if ( (B != None) && !B.SameTeamAs(Instigator.Controller) && (B.Pawn != None) && !B.Pawn.IsFiring()
					&& ((B.Enemy == None) || (B.Enemy == Instigator) || !B.EnemyVisible())
					&& B.LineOfSightTo(self) )
				{
					// give B a chance to shoot at me
					B.GoalString = "Destroy Mortar Camera";
					B.Target = self;
					B.SwitchToBestWeapon();
					if ( B.Pawn.CanAttack(self) )
					{
						B.DoRangedAttackOn(self);
						if ( FRand() < 0.5 )
							break;
					}
				}
			}
		}
	}

	if ( (Instigator != None) && (Instigator.Controller == Level.GetLocalPlayerController()) && (ONSArtilleryCannon(Owner) != None)
		&& (Level.TimeSeconds - TargetUpdateTime > 0.1)  )
    {
        // Target Prediction
        TargetUpdateTime = Level.TimeSeconds;
        ONSArtilleryCannon(Owner).PredictTarget();
    }
}

simulated function ShotDown()
{
	if ( ONSArtilleryCannon(Owner) != None )
		ONSArtilleryCannon(Owner).AllowCameraLaunch();
	if ( ONSArtillery(Instigator) != None )
		ONSArtillery(Instigator).MortarCamera = None;
    PlaySound(sound'ONSBPSounds.Artillery.CameraShotDown', SLOT_None, 1.5);
    SetPhysics(PHYS_Falling);
	LifeSpan = FMin(LifeSpan, 5);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    if ((Damage > 0) && ((InstigatedBy == None) || (InstigatedBy.Controller == None) || (Instigator == None) || (Instigator.Controller == None) || !InstigatedBy.Controller.SameTeamAs(Instigator.Controller)))
	{
        bShotDown = True;
		ShotDown();
	}
}

simulated function Destroyed()
{
    local int i;

    if (TargetBeam != None)
        TargetBeam.Destroy();

    for(i=0; i<=3; i++)
    {
        if (Thruster[i] != None)
            Thruster[i].Destroy();
    }

    Super.Destroyed();
}


simulated function SpawnEffects( vector HitLocation, vector HitNormal )
{
	if ( bShotDown )
		Super.SpawnEffects(HitLocation, HitNormal);
	else if ( EffectIsRelevant(Location,false) )
		spawn(class'RocketSmokeRing',,,HitLocation + HitNormal*16, rotator(HitNormal) );
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if ( bShotDown )
		Super.Explode(HitLocation, HitNormal);
	else
	{
		bExploded = true;
		Destroy();
	}
}

DefaultProperties
{
    DrawType=DT_Mesh
    Mesh=Mesh'ONSBPAnimations.MortarCameraMesh'
    Skins(0)=Texture'ONSBPTextures.Skins.ArtilleryCamTexture'
    Skins(1)=Texture'ONSBPTextures.Skins.ArtilleryCamTexture'
    RotationRate=(Pitch=15000,Yaw=15000,Roll=15000)
    AmbientGlow=0
    AmbientSound=None
    LifeSpan=0
    DrawScale=1.0
    DrawScale3D=(X=1.0,Y=1.0,Z=1.0)
    bNetNotify=true
    bUseCylinderCollision=true
    CollisionHeight=80
    CollisionRadius=110
    bIgnoreEncroachers=true
    bOrientToVelocity=false
    bSpecialCalcView=true
    MortarCameraOffset=(X=100)
    bUpdateSimulatedPosition=true
}
