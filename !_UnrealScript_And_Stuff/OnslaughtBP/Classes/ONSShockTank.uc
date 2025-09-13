//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSShockTank extends ONSWheeledCraft;


function bool ImportantVehicle()
{
	return true;
}

function ShouldTargetMissile(Projectile P)
{
	local AIController C;

	C = AIController(Controller);
	if ( (C != None) && (C.Skill >= 2.0) )
		ONSShockTankCannon(Weapons[0]).ShieldAgainstIncoming(P);
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	ONSShockTankCannon(Weapons[0]).ShieldAgainstIncoming();
	return false;
}

function VehicleCeaseFire(bool bWasAltFire)
{
    Super.VehicleCeaseFire(bWasAltFire);

    if (bWasAltFire && ONSShockTankCannon(Weapons[ActiveWeapon]) != None)
        ONSShockTankCannon(Weapons[ActiveWeapon]).CeaseAltFire();
}

event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	local vector ShieldHitLocation, ShieldHitNormal;

	// don't take damage if should have been blocked by shield
	if ( (Weapons.Length > 0) && ONSShockTankCannon(Weapons[0]).bShieldActive && (ONSShockTankCannon(Weapons[0]).ShockShield != None) && (Momentum != vect(0,0,0))
		&& (HitLocation != Location) && (DamageType != None) && (ClassIsChildOf(DamageType,class'WeaponDamageType') || ClassIsChildOf(DamageType,class'VehicleDamageType')) 
		&& !ONSShockTankCannon(Weapons[0]).ShockShield.TraceThisActor(ShieldHitLocation,ShieldHitNormal,HitLocation,HitLocation - 2000*Normal(Momentum)) )
		return;

    // Don't take self inflicated damage from proximity explosion
    if (DamageType == class'DamTypeShockTankProximityExplosion' && EventInstigator != None && EventInstigator == self)
        return;

    Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}


simulated function vector GetTargetLocation()
{
	return Location + vect(0,0,1)*CollisionHeight;
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.PaladinGreen');
    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.PaladinTan');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.ElecPanelsP');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.ElecPanels');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_framesP');
    L.AddPrecacheMaterial(Material'ONSInterface-TX.tankBarrelAligned');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore2');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectSwirl');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockBallTrail');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore2a');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockRingTex');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SmoothRing');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.Ripples1P');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.Ripples2P');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.BoloBlob');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ElectricShockTexG');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ElectricShockTexG2');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SoftFade');
    L.AddPrecacheMaterial(Material'AbaddonArchitecture.Base.bas27go');
}

simulated function UpdatePrecacheStaticMeshes()
{
    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.PaladinGreen');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.PaladinTan');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.ElecPanelsP');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.ElecPanels');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_framesP');
    Level.AddPrecacheMaterial(Material'ONSInterface-TX.tankBarrelAligned');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore2');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectSwirl');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockBallTrail');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore2a');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockRingTex');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SmoothRing');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.Ripples1P');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.Ripples2P');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.BoloBlob');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ElectricShockTexG');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ElectricShockTexG2');
    Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SoftFade');
    Level.AddPrecacheMaterial(Material'AbaddonArchitecture.Base.bas27go');

	Super.UpdatePrecacheMaterials();
}

DefaultProperties
{
	Mesh=Mesh'ONSBPAnimations.ShockTankMesh'
	VehiclePositionString="in a Paladin"
	VehicleNameString="Paladin"
	bReplicateAnimations=True

    RedSkin=Texture'ONSBPTextures.Skins.PaladinTan'
    BlueSkin=Texture'ONSBPTextures.Skins.PaladinGreen'

	DriverWeapons(0)=(WeaponClass=class'OnslaughtBP.ONSShockTankCannon',WeaponBone=CannonAttach);

    DestroyedVehicleMesh=StaticMesh'ONSBP_DestroyedVehicles.Paladin.DestroyedPaladin'
	DestructionEffectClass=class'Onslaught.ONSSmallVehicleExplosionEffect'
	DisintegrationEffectClass=class'OnslaughtBP.ONSShockTankDeathExp'
    DestructionLinearMomentum=(Min=200000,Max=300000)
    DestructionAngularMomentum=(Min=100,Max=150)
    DisintegrationHealth=-25
	ImpactDamageMult=0.0010

	Health=800
	HealthMax=800
	CollisionHeight=+40.0
	CollisionRadius=+260.0
	DriverDamageMult=0.01
	bHasAltFire=True
	bSeparateTurretFocus=True
	RanOverDamageType=class'DamTypeRVRoadkill'
	CrushedDamageType=class'DamTypeRVPancake'

	DrawScale=1.0
	DrawScale3D=(X=1.0,Y=1.0,Z=1.0)

	FPCamPos=(X=-45,Y=0,Z=250)
	FPCamViewOffset=(X=-30,Y=0,Z=0)
	TPCamLookat=(X=0,Y=0,Z=0)
	TPCamWorldOffset=(X=0,Y=0,Z=375)
	TPCamDistance=375

	bDrawDriverInTP=False
	bDrawMeshInFP=True
	bHasHandbrake=False
	bAllowBigWheels=True

	MaxViewYaw=16000
	MaxViewPitch=16000

	FlipTorque=400

	IdleSound=sound'ONSBPSounds.ShockTank.EngineCruise'
	StartUpSound=sound'ONSBPSounds.ShockTank.EngineRampUp'
	ShutDownSound=sound'ONSBPSounds.ShockTank.EngineRampDown'
	EngineRPMSoundRange=9000
	SoundVolume=255
	AmbientSoundScaling=2.0
	IdleRPM=500
	RevMeterScale=4000

	StartUpForce="RVStartUp"

	SteerBoneName="SteeringWheel"
	SteerBoneAxis=AXIS_Z
	SteerBoneMaxAngle=90

	EntryPosition=(X=0,Y=0,Z=0)
	EntryRadius=300.0

	ExitPositions(0)=(X=0,Y=-265,Z=100)
	ExitPositions(1)=(X=0,Y=265,Z=100)
	ExitPositions(2)=(X=0,Y=-265,Z=-100)
	ExitPositions(3)=(X=0,Y=265,Z=-100)

	AirPitchDamping=25.0

//	HeadlightCoronaOffset(0)=(X=86,Y=30,Z=7)
//	HeadlightCoronaOffset(1)=(X=86,Y=-30,Z=7)
//	HeadlightCoronaMaterial=Material'EpicParticles.flashflare1'
//	HeadlightCoronaMaxSize=65

//	bMakeBrakeLights=true
//	BrakeLightOffset(0)=(X=-100,Y=23,Z=7)
//	BrakeLightOffset(1)=(X=-100,Y=-23,Z=7)
//	BrakeLightMaterial=Material'EpicParticles.flashflare1'

//	HeadlightProjectorOffset=(X=90,Y=0,Z=7)
//	HeadlightProjectorRotation=(Yaw=0,Pitch=-1000,Roll=0)
//	HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVProjector'
//	HeadlightProjectorScale=0.3

	DamagedEffectOffset=(X=60,Y=10,Z=10)
	DamagedEffectScale=1.0

	WheelPenScale=1.2
	WheelPenOffset=0.01
	WheelSoftness=0.1
	WheelRestitution=0.1
	WheelAdhesion=0.0
	WheelLongFrictionFunc=(Points=((InVal=0,OutVal=0.0),(InVal=100.0,OutVal=1.0),(InVal=200.0,OutVal=0.9),(InVal=10000000000.0,OutVal=0.9)))
	WheelLongFrictionScale=2.0
	WheelLatFrictionScale=1.5
	WheelLongSlip=0.001
	WheelLatSlipFunc=(Points=((InVal=0.0,OutVal=0.0),(InVal=30.0,OutVal=0.010),(InVal=45.0,OutVal=0.00),(InVal=10000000000.0,OutVal=0.00)))
	WheelHandbrakeSlip=0.01
	WheelHandbrakeFriction=0.1
	WheelSuspensionTravel=45.0
	WheelSuspensionOffset=-12.0
	WheelSuspensionMaxRenderTravel=45.0
	TurnDamping=35

	HandbrakeThresh=200
	FTScale=0.02
	ChassisTorqueScale=0.2

	MinBrakeFriction=4.0
	MaxBrakeTorque=20.0
	MaxSteerAngleCurve=(Points=((InVal=0,OutVal=35.0),(InVal=450.0,OutVal=35.0),(InVal=550.0,OutVal=11.0),(InVal=1000000000.0,OutVal=11.0)))
	SteerSpeed=80
	StopThreshold=100
	TorqueCurve=(Points=((InVal=0,OutVal=27.0),(InVal=200,OutVal=30.0),(InVal=1500,OutVal=33.0),(InVal=2800,OutVal=0.0)))
	EngineBrakeFactor=0.0001
	EngineBrakeRPMScale=0.1
	EngineInertia=0.1
	WheelInertia=0.1

	TransRatio=0.03
	GearRatios[0]=-0.5
	GearRatios[1]=0.4
	GearRatios[2]=0.65
	GearRatios[3]=0.85
	GearRatios[4]=1.1
	ChangeUpPoint=2000
	ChangeDownPoint=1000
	LSDFactor=1.0

	VehicleMass=6.0
	MomentumMult=0.8

    Begin Object Class=KarmaParamsRBFull Name=KParams0
		KStartEnabled=True
		KFriction=0.5
		KLinearDamping=0.05
		KAngularDamping=0.05
		KImpactThreshold=700
		bKNonSphericalInertia=True
        bHighDetailOnly=False
        bClientOnly=False
		bKDoubleTickRate=True
		KInertiaTensor(0)=1.0
		KInertiaTensor(1)=0.0
		KInertiaTensor(2)=0.0
		KInertiaTensor(3)=3.0
		KInertiaTensor(4)=0.0
		KInertiaTensor(5)=3.0
		KCOMOffset=(X=-0.25,Y=0.0,Z=-1.35)
		bDestroyOnWorldPenetrate=True
		bDoSafetime=True
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'

	Begin Object Class=SVehicleWheel Name=RWheel1
		BoneName="8WheelerWheel01"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=7.0,Z=0.0)
		WheelRadius=44
		bPoweredWheel=True
		SteerType=VST_Steered
		SupportBoneAxis=AXIS_X
		SupportBoneName="Suspension_Right1"
	End Object
	Wheels(0)=SVehicleWheel'RWheel1'

	Begin Object Class=SVehicleWheel Name=RWheel2
		BoneName="8WheelerWheel03"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=7.0,Z=0.0)
		WheelRadius=44
		bPoweredWheel=True
		SteerType=VST_Fixed
		SupportBoneAxis=AXIS_X
		SupportBoneName="Suspension_Right2"
	End Object
	Wheels(1)=SVehicleWheel'RWheel2'

	Begin Object Class=SVehicleWheel Name=RWheel3
		BoneName="8WheelerWheel05"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=7.0,Z=0.0)
		WheelRadius=44
		bPoweredWheel=True
		SteerType=VST_Fixed
		SupportBoneAxis=AXIS_X
		SupportBoneName="Suspension_Right3"
	End Object
	Wheels(2)=SVehicleWheel'RWheel3'

	Begin Object Class=SVehicleWheel Name=RWheel4
		BoneName="8WheelerWheel07"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=7.0,Z=0.0)
		WheelRadius=44
		bPoweredWheel=True
		SteerType=VST_Inverted
		SupportBoneAxis=AXIS_X
		SupportBoneName="Suspension_Right4"
	End Object
	Wheels(3)=SVehicleWheel'RWheel4'

	Begin Object Class=SVehicleWheel Name=LWheel1
		BoneName="8WheelerWheel02"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=7.0,Z=0.0)
		WheelRadius=44
		bPoweredWheel=True
		SteerType=VST_Steered
		SupportBoneAxis=AXIS_X
		SupportBoneName="Suspension_Left1"
	End Object
	Wheels(4)=SVehicleWheel'LWheel1'

	Begin Object Class=SVehicleWheel Name=LWheel2
		BoneName="8WheelerWheel04"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=7.0,Z=0.0)
		WheelRadius=44
		bPoweredWheel=True
		SteerType=VST_Fixed
		SupportBoneAxis=AXIS_X
		SupportBoneName="Suspension_Left2"
	End Object
	Wheels(5)=SVehicleWheel'LWheel2'

	Begin Object Class=SVehicleWheel Name=LWheel3
		BoneName="8WheelerWheel06"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=7.0,Z=0.0)
		WheelRadius=44
		bPoweredWheel=True
		SteerType=VST_Fixed
		SupportBoneAxis=AXIS_X
		SupportBoneName="Suspension_Left3"
	End Object
	Wheels(6)=SVehicleWheel'LWheel3'

	Begin Object Class=SVehicleWheel Name=LWheel4
		BoneName="8WheelerWheel08"
		BoneRollAxis=AXIS_Y
		BoneSteerAxis=AXIS_Z
		BoneOffset=(X=0.0,Y=7.0,Z=0.0)
		WheelRadius=44
		bPoweredWheel=True
		SteerType=VST_Inverted
		SupportBoneAxis=AXIS_X
		SupportBoneName="Suspension_Left4"
	End Object
	Wheels(7)=SVehicleWheel'LWheel4'

	GroundSpeed=940
	CenterSpringForce="SpringONSSRV"

	HornSounds(0)=sound'ONSBPSounds.ShockTank.PaladinHorn'
	HornSounds(1)=sound'ONSVehicleSounds-S.Dixie_Horn'

	MaxDesireability=0.6
	ObjectiveGetOutDist=1500.0
	bDriverHoldsFlag=false
	FlagOffset=(Z=50.0)
	FlagBone=CannonAttach
	FlagRotation=(Yaw=32768)
}
