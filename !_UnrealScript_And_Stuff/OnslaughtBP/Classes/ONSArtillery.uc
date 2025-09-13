//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSArtillery extends ONSWheeledCraft;

#exec OBJ LOAD FILE=ONSBPTextures.utx

var float   YawAccel, PitchAccel;
var float   ClientUpdateTime;
var float	StartDrivingTime;	// AI Hint
var Rotator LastAim;
var bool    bJustDeployed;
var ONSMortarCamera MortarCamera;

var float LastLocalMsgTime;
var string ArtiLockOnClassString;

replication
{
    reliable if (Role == ROLE_Authority)
        MortarCamera;

	reliable if (Role < ROLE_Authority)
        ServerAim;
}

function bool IsArtillery()
{
	return true;
}

function bool IsDeployed()
{
	local ONSArtilleryCannon Cannon;

	Cannon = ONSArtilleryCannon(Weapons[ActiveWeapon]);
	if ( (Cannon != None) && (Cannon.MortarCamera != None) )
		return true;
	if ( Level.TimeSeconds - Cannon.LastCameraLaunch > Cannon.CameraLaunchWait )
		return true;
	return false;
}

function KDriverEnter(Pawn P)
{
	Super.KDriverEnter(P);
	StartDrivingTime = Level.TimeSeconds;
}

function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	local SquadAI Squad;

	Squad = SquadAI(S);

	if ( Squad.GetOrders() == 'Defend' )
		return 0;

	return super.BotDesireability(S,TeamIndex,Objective);
}

function VehicleFire(bool bWasAltFire)
{
	local vector TargetDir;
	local rotator AimRot;

	if ( bWasAltFire )
	{
		if (  MortarCamera != None )
		{
			if ( !MortarCamera.bDeployed )
			{
				if ( AIController(Instigator.Controller) != None )
				{
					return;
				}
				MortarCamera.Deploy();
				CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
			}
			else
			{
				if ( AIController(Instigator.Controller) != None )
					bWasAltFire = false;
				else
					MortarCamera.Destroy();
			}
			return;
		}
		else if ( (AIController(Instigator.Controller) != None) && (Controller.Target != None) )
		{
			TargetDir = Controller.Target.Location - Location;
			TargetDir.Z = 0;
			AimRot = Weapons[ActiveWeapon].CurrentAim;
			AimRot.Pitch = 0;
			if ( (Normal(TargetDir) Dot Vector(AimRot)) < 0.9 )
			{
				return;
			}
		}
	}
	Super.VehicleFire(bWasAltFire);
}


function AltFire( optional float F )
{
	local bool bHasCamera;

	bHasCamera = ( MortarCamera != None );

	Super.AltFire(F);
    if ( MortarCamera != None )
    {
		if ( Role < ROLE_Authority  && !MortarCamera.bDeployed )
		{
			MortarCamera.Deploy();
			CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
			bJustDeployed = true;
		}
	}
	if ( bHasCamera )
		bWeaponIsAltFiring = false;
}

function ServerAim(int NewYaw)
{
    CustomAim.Yaw = NewYaw;
    CustomAim.Pitch = Default.CustomAim.Pitch;
    CustomAim.Roll = Default.CustomAim.Roll;
}

simulated function RawInput(float DeltaTime,
							float aBaseX, float aBaseY, float aBaseZ, float aMouseX, float aMouseY,
							float aForward, float aTurn, float aStrafe, float aUp, float aLookUp)
{
	if (PlayerController(Controller) != None)
	{
        if (aStrafe > 0)
            YawAccel = 1.0;
        if (aStrafe < 0)
            YawAccel = -1.0;
        if (aForward > 0)
            PitchAccel = 1.0;
        if (aForward < 0)
            PitchAccel = -1.0;
    }
}

function int LimitPitch(int pitch)
{
	if (ActiveWeapon >= Weapons.length)
		return Super.LimitPitch(pitch);

	if (ONSArtilleryCannon(Weapons[ActiveWeapon]) != None && ONSArtilleryCannon(Weapons[ActiveWeapon]).MortarCamera != None)
	{
    	pitch = pitch & 65535;

        if (pitch > 2500 && pitch < 49153)
        {
            if (pitch - 2500 < 49153 - pitch)
                pitch = 2500;
            else
                pitch = 49153;
        }
        return pitch;
    }

	return Weapons[ActiveWeapon].LimitPitch(pitch, Rotation);
}

simulated function Tick(float DT)
{
	local DestroyableObjective ObjectiveTarget;

	Super.Tick(DT);

	if ( AIController(Controller) != None )
	{
		bCustomAiming = true;
        CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
		if ( Controller.Target != None )
			CustomAim.Yaw = Rotator(Controller.Target.Location - Location).Yaw;
		LastAim = CustomAim;
		if ( MortarCamera != None )
		{
			bAltFocalPoint = true;
			if ( Controller.Target != None )
			{
				if ( MortarCamera.bDeployed )
				{
					if ( ShootTarget(Controller.Target) != None )
						ObjectiveTarget = DestroyableObjective(Controller.Target.Owner);
					else
						ObjectiveTarget = DestroyableObjective(Controller.Target);
				}
				if ( (ObjectiveTarget != None) && !ObjectiveTarget.LegitimateTargetOf(Bot(Controller)) )
				{
					MortarCamera.Destroy();
					ONSArtilleryCannon(Weapons[ActiveWeapon]).AllowCameraLaunch();
					Weapons[ActiveWeapon].FireCountDown = Weapons[ActiveWeapon].AltFireInterval;
				}
				else
				{
					Throttle = 0.0;
					Steering = 0.0;
				}
			}
			else
			{
				bAltFocalPoint = false;
				MortarCamera.Destroy();
				ONSArtilleryCannon(Weapons[ActiveWeapon]).AllowCameraLaunch();
				Weapons[ActiveWeapon].FireCountDown = Weapons[ActiveWeapon].AltFireInterval;
			}
		}
		else
			bAltFocalPoint = false;
	}
    else if (MortarCamera != None)
    {
	    bCustomAiming = True;

        CustomAim.Pitch = Default.CustomAim.Pitch;
        CustomAim.Roll = Default.CustomAim.Roll;

        if ( IsLocallyControlled() && IsHumanControlled() )
        {
            if ( PlayerController(Controller) != None && PlayerController(Controller).ViewTarget != MortarCamera )
                PlayerController(Controller).SetViewTarget(MortarCamera);

            CustomAim.Yaw += YawAccel * 8192 * DT;

            if (Weapons[ActiveWeapon] != None && ONSArtilleryCannon(Weapons[ActiveWeapon]) != None)
                ONSArtilleryCannon(Weapons[ActiveWeapon]).SetWeaponCharge(FClamp(ONSArtilleryCannon(Weapons[ActiveWeapon]).WeaponCharge + (PitchAccel * DT), 0.0, 0.999));

            if (bCustomAiming && bJustDeployed || ((Level.TimeSeconds - ClientUpdateTime > 0.0222) && CustomAim != LastAim))
            {
                ClientUpdateTime = Level.TimeSeconds;
                ServerAim(CustomAim.Yaw);
                LastAim = CustomAim;
                bJustDeployed = false;
            }

            YawAccel = 0.0;
            PitchAccel = 0.0;
        }

        Throttle = 0.0;
        Steering = 0.0;
    }
    else
    {
        bCustomAiming = False;
        if (IsLocallyControlled() && Weapons[ActiveWeapon] != None)
            CustomAim = Weapons[ActiveWeapon].WeaponFireRotation;
    }
}

simulated function PrevWeapon()
{
    if (MortarCamera != None && Weapons[ActiveWeapon] != None && ONSArtilleryCannon(Weapons[ActiveWeapon]) != None)
        ONSArtilleryCannon(Weapons[ActiveWeapon]).SetWeaponCharge(FMin(ONSArtilleryCannon(Weapons[ActiveWeapon]).WeaponCharge + 0.025, 0.999));
    else
        Super.PrevWeapon();
}

simulated function NextWeapon()
{
    if (MortarCamera != None && Weapons[ActiveWeapon] != None && ONSArtilleryCannon(Weapons[ActiveWeapon]) != None)
        ONSArtilleryCannon(Weapons[ActiveWeapon]).SetWeaponCharge(FMax(ONSArtilleryCannon(Weapons[ActiveWeapon]).WeaponCharge - 0.025, 0.0));
    else
        Super.NextWeapon();
}

simulated function actor AlternateTarget()
{
    return MortarCamera;
}

event bool VerifyLock(actor Aggressor, out actor NewTarget)
{
	local	class<LocalMessage>	LockOnClass;

	if (MortarCamera != None && !FastTrace(Location, Aggressor.Location))
	{
        NewTarget = MortarCamera;
        return False;
    }

	// Lock has switched from the Camera to the SPMA, notify the Avril Controller

	if (Aggressor.Instigator!=None && Aggressor.Instigator.Controller !=None &&
			PlayerController(Aggressor.Instigator.Controller) != none)
	{
	 	if (Level.TimeSeconds > LastLocalMsgTime + LockWarningInterval)
	 	{
			LockOnClass = class<LocalMessage>(DynamicLoadObject(ArtiLockOnClassString, class'class'));
			PlayerController(Aggressor.Instigator.Controller).ReceiveLocalizedMessage(LockOnClass, 32);
		}
	}

    return True;
}

simulated event Destroyed()
{
    if (MortarCamera != None)
        MortarCamera.TakeDamage(1, None, vect(0,0,0), vect(0,0,0), class'DamageType');

    Super.Destroyed();
}

function DriverLeft()
{
    if (MortarCamera != None)
        MortarCamera.TakeDamage(1, None, vect(0,0,0), vect(0,0,0), class'DamageType');

    Super.DriverLeft();
}

event ApplyFireImpulse(bool bAlt)
{
	if ( AIController(Instigator.Controller) != None )
	{
		if ( Controller.Target != None )
		{
			Weapons[ActiveWeapon].CalcWeaponFire();
			Weapons[ActiveWeapon].WeaponFireRotation = Rotator(Controller.Target.Location - Weapons[ActiveWeapon].WeaponFireLocation);
			Weapons[ActiveWeapon].WeaponFireRotation.Pitch = 10000;
			Weapons[ActiveWeapon].WeaponFireLocation.Z = Location.Z + 500;
		}
	}
	Super.ApplyFireImpulse(bAlt);
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function ShouldTargetMissile(Projectile P)
{
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.LargeShell');
	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Target');
	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Mini_Shell');
	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.TargetNo');

    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMAGreen');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.MuzzleSpray');
    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMATan');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Missile');
    L.AddPrecacheMaterial(Material'ONSBPTextures.Smoke');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.ExploTrans');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1Alpha');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.seexpt');
    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.ArtilleryCamTexture');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test2');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Fire');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'BenTex01.textures.SmokePuff01');
    L.AddPrecacheMaterial(Material'ArboreaTerrain.ground.flr02ar');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlphaNo');
    L.AddPrecacheMaterial(Material'AbaddonArchitecture.Base.bas28go');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.LargeShell');
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Target');
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Mini_Shell');
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.TargetNo');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMAGreen');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.MuzzleSpray');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMATan');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Missile');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Smoke');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.ExploTrans');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1Alpha');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.seexpt');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.ArtilleryCamTexture');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test2');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Fire');
    Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    Level.AddPrecacheMaterial(Material'BenTex01.textures.SmokePuff01');
    Level.AddPrecacheMaterial(Material'ArboreaTerrain.ground.flr02ar');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlphaNo');
    Level.AddPrecacheMaterial(Material'AbaddonArchitecture.Base.bas28go');

	Super.UpdatePrecacheMaterials();
}

DefaultProperties
{
	Mesh=Mesh'ONSBPAnimations.ArtilleryMesh'
	VehiclePositionString="in a SPMA"
	VehicleNameString="SPMA"

	DriverWeapons(0)=(WeaponClass=class'OnslaughtBP.ONSArtilleryCannon',WeaponBone=CannonAttach);
	PassengerWeapons(0)=(WeaponPawnClass=class'OnslaughtBP.ONSArtillerySideGunPawn',WeaponBone=SideGunAttach);

	RedSkin=Texture'ONSBPTextures.Skins.SPMATan'
    BlueSkin=Texture'ONSBPTextures.Skins.SPMAGreen'

	DestroyedVehicleMesh=StaticMesh'ONSBP_DestroyedVehicles.SPMA.DestroyedSPMA'
    DestructionEffectClass=class'Onslaught.ONSVehicleExplosionEffect'
	DisintegrationEffectClass=class'OnslaughtBP.ONSArtilleryDeathExp'
    DestructionLinearMomentum=(Min=250000,Max=400000)
    DestructionAngularMomentum=(Min=100,Max=150)
    DisintegrationHealth=-100
	ImpactDamageMult=0.0010

	Health=600
	HealthMax=600
	DriverDamageMult=0.1
	MomentumMult=2.0
	RanOverDamageType=class'DamTypePRVRoadkill'
	CrushedDamageType=class'DamTypePRVPancake'

	DrawScale=1.0
	DrawScale3D=(X=1.0,Y=1.0,Z=1.0)
	CollisionRadius=260.0

	FPCamPos=(X=160,Y=-30,Z=75)
	TPCamLookat=(X=100,Y=-30,Z=-100)
	TPCamWorldOffset=(X=0,Y=0,Z=350)
	TPCamDistance=375
	TPCamDistRange=(Min=200,Max=1500)

	bDoStuntInfo=true
	DaredevilThreshInAirSpin=90.0
	DaredevilThreshInAirPitch=300.0
	DaredevilThreshInAirRoll=300.0
	DaredevilThreshInAirTime=1.2
	DaredevilThreshInAirDistance=17.0

	AirTurnTorque=35.0
	AirPitchTorque=55.0
	AirPitchDamping=35.0
	AirRollTorque=35.0
	AirRollDamping=35.0

	bDrawDriverInTP=True
	bDrawMeshInFP=True
	bHasHandbrake=true
	bAllowBigWheels=true

	MaxViewYaw=16000
	MaxViewPitch=16000

	DrivePos=(X=145,Y=-30.0,Z=75.0)
	DriveRot=(Pitch=0)

	IdleSound=sound'ONSVehicleSounds-S.PRV.PRVEng01'
	StartUpSound=sound'ONSBPSounds.Artillery.EngineRampUp'
	ShutDownSound=sound'ONSBPSounds.Artillery.EngineRampDown'
	EngineRPMSoundRange=10000
	IdleRPM=500
	RevMeterScale=4000
	SoundVolume=200
	SoundRadius=220

	StartUpForce="PRVStartUp"
	ShutDownForce="PRVShutDown"

	SteerBoneName=""
	SteerBoneAxis=AXIS_Z
	SteerBoneMaxAngle=90

	EntryPosition=(X=40,Y=-60,Z=10)
	EntryRadius=320.0

	ExitPositions(0)=(X=0,Y=-165,Z=100)
	ExitPositions(1)=(X=0,Y=165,Z=100)
	ExitPositions(2)=(X=0,Y=-165,Z=-100)
	ExitPositions(3)=(X=0,Y=165,Z=-100)

	HeadlightCoronaOffset(0)=(X=290,Y=50,Z=40)
	HeadlightCoronaOffset(1)=(X=290,Y=-50,Z=40)
	HeadlightCoronaMaterial=Material'EpicParticles.flashflare1'
	HeadlightCoronaMaxSize=70

	bMakeBrakeLights=true
	BrakeLightOffset(0)=(X=46,Y=47,Z=45)
	BrakeLightOffset(1)=(X=46,Y=-47,Z=45)
	BrakeLightMaterial=Material'EpicParticles.flashflare1'

	HeadlightProjectorOffset=(X=290,Y=0,Z=40)
	HeadlightProjectorRotation=(Yaw=0,Pitch=-1500,Roll=0)
	HeadlightProjectorMaterial=Texture'VMVehicles-TX.NewPRVGroup.PRVProjector'
	HeadlightProjectorScale=0.65

	DamagedEffectOffset=(X=250,Y=20,Z=50)
	DamagedEffectScale=1.2

	bHasFireImpulse=True
	FireImpulse=(X=-110000,Y=0.0,Z=0.0)

	WheelPenScale=1.5
	WheelPenOffset=0.01
	WheelSoftness=0.06
	WheelRestitution=0.1
	WheelAdhesion=0.0
	WheelLongFrictionFunc=(Points=((InVal=0,OutVal=0.0),(InVal=100.0,OutVal=1.0),(InVal=200.0,OutVal=0.9),(InVal=10000000000.0,OutVal=0.9)))
	WheelLongFrictionScale=1.1
	WheelLatFrictionScale=1.5
	WheelLongSlip=0.001
	WheelLatSlipFunc=(Points=((InVal=0.0,OutVal=0.0),(InVal=30.0,OutVal=0.009),(InVal=45.0,OutVal=0.00),(InVal=10000000000.0,OutVal=0.00)))

	WheelHandbrakeSlip=0.01
	WheelHandbrakeFriction=0.15
	WheelSuspensionTravel=25.0
	WheelSuspensionOffset=-10.0
	WheelSuspensionMaxRenderTravel=25.0

	TurnDamping=35

	HandbrakeThresh=200
	FTScale=0.03
	ChassisTorqueScale=1.25

	MinBrakeFriction=4.0
	MaxBrakeTorque=20.0
	MaxSteerAngleCurve=(Points=((InVal=0,OutVal=35.0),(InVal=700.0,OutVal=35.0),(InVal=800.0,OutVal=10.0),(InVal=1000000000.0,OutVal=10.0)))
	SteerSpeed=110
	StopThreshold=100
	TorqueCurve=(Points=((InVal=0,OutVal=9.0),(InVal=200,OutVal=10.0),(InVal=1500,OutVal=11.0),(InVal=2500,OutVal=0.0)))
	EngineBrakeFactor=0.0001
	EngineBrakeRPMScale=0.1
	EngineInertia=0.2
	WheelInertia=0.1

	TransRatio=0.11
	GearRatios[0]=-0.5
	GearRatios[1]=0.4
	GearRatios[2]=0.65
	GearRatios[3]=0.85
	GearRatios[4]=1.1
	ChangeUpPoint=2000
	ChangeDownPoint=1000
	LSDFactor=1.0

	VehicleMass=4.0

    Begin Object Class=KarmaParamsRBFull Name=KParams0
		KStartEnabled=True
		KFriction=0.5
		KLinearDamping=0.05
		KAngularDamping=0.05
		KImpactThreshold=500
		bKNonSphericalInertia=True
        bHighDetailOnly=False
        bClientOnly=False
		bKDoubleTickRate=True
		KInertiaTensor(0)=1.0
		KInertiaTensor(1)=0.0
		KInertiaTensor(2)=0.0
		KInertiaTensor(3)=3.0
		KInertiaTensor(4)=0.0
		KInertiaTensor(5)=3.5
		KCOMOffset=(X=1.5,Y=0.0,Z=-0.5)
		bDestroyOnWorldPenetrate=True
		bDoSafetime=True
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'

	Begin Object Class=SVehicleWheel Name=RWheel1
		BoneName="Wheel_Right01"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=-15.0,Y=0.0,Z=0.0)
		WheelRadius=43
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Steered
		SupportBoneName="SuspensionRight01"
		SupportBoneAxis=AXIS_X
	End Object
	Wheels(0)=SVehicleWheel'RWheel1'

	Begin Object Class=SVehicleWheel Name=LWheel1
		BoneName="Wheel_Left01"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=15.0,Y=0.0,Z=0.0)
		WheelRadius=43
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Steered
		SupportBoneName="SuspensionLeft01"
		SupportBoneAxis=AXIS_X
	End Object
	Wheels(1)=SVehicleWheel'LWheel1'

	Begin Object Class=SVehicleWheel Name=RWheel2
		BoneName="Wheel_Right02"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=-15.0,Y=0.0,Z=0.0)
		WheelRadius=43
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Fixed
		SupportBoneName="SuspensionRight02"
		SupportBoneAxis=AXIS_X
	End Object
	Wheels(2)=SVehicleWheel'RWheel2'

	Begin Object Class=SVehicleWheel Name=LWheel2
		BoneName="Wheel_Left02"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=15.0,Y=0.0,Z=0.0)
		WheelRadius=43
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Fixed
		SupportBoneName="SuspensionLeft02"
		SupportBoneAxis=AXIS_X
	End Object
	Wheels(3)=SVehicleWheel'LWheel2'

	Begin Object Class=SVehicleWheel Name=RWheel3
		BoneName="Wheel_Right03"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=-15.0,Y=0.0,Z=0.0)
		WheelRadius=43
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Inverted
		SupportBoneName="SuspensionRight03"
		SupportBoneAxis=AXIS_X
	End Object
	Wheels(4)=SVehicleWheel'RWheel3'

	Begin Object Class=SVehicleWheel Name=LWheel3
		BoneName="Wheel_Left03"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=15.0,Y=0.0,Z=0.0)
		WheelRadius=43
		bPoweredWheel=True
		bHandbrakeWheel=True
		SteerType=VST_Inverted
		SupportBoneName="SuspensionLeft03"
		SupportBoneAxis=AXIS_X
	End Object
	Wheels(5)=SVehicleWheel'LWheel3'

	GroundSpeed=840
	bDriverHoldsFlag=false
	FlagOffset=(X=200.0,Z=150.0)
	FlagBone=Body
	FlagRotation=(Yaw=32768)

	HornSounds(0)=sound'ONSBPSounds.Artillery.SPMAHorn'
	HornSounds(1)=sound'ONSVehicleSounds-S.Horn04'
	//VehicleIcon=(Material=Texture'AS_FX_TX.HUD.AssaultHUD',X=380,Y=83,SizeX=130,SizeY=64)
	VehicleIcon=(Material=Texture'AS_FX_TX.Icons.OBJ_HellBender',X=0,Y=0,SizeX=64,SizeY=64,bIsGreyScale=true)

	ObjectiveGetOutDist=1500.0
	CustomAim=(Pitch=12000,Roll=0)
	MaxDesireability=0.6
	ArtiLockOnClassString="Onslaught.ONSOnslaughtMessage"
}
