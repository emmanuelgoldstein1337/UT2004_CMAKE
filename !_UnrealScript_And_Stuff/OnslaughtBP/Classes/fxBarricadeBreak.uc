//-----------------------------------------------------------
// Barricade Breaking
//-----------------------------------------------------------
class fxBarricadeBreak extends Emitter;

#exec OBJ LOAD FIlE=..\Sounds\ONSVehicleSounds-S.uax

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.bDropDetail )
	{
		Emitters[5].UseCollision = false;
		Emitters[6].UseCollision = false;
	}
}

DefaultProperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter0
        StaticMesh=StaticMesh'BonusParticles.UrbanParticles.Broken_Saw1'
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-900.000000)
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.300000,Max=0.300000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.900000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutStartTime=2.000000
        MaxParticles=1
        StartLocationOffset=(X=28.000000,Y=16.000000)
        UseRotationFrom=PTRS_Actor
        SpinCCWorCW=(X=1.000000,Y=1.000000,Z=1.000000)
        SpinsPerSecondRange=(X=(Min=0.200000,Max=0.300000),Y=(Min=0.300000,Max=0.600000),Z=(Max=0.200000))
        RotationDampingFactorRange=(X=(Min=0.300000,Max=0.300000),Y=(Min=0.300000,Max=0.300000))
        Sounds(0)=(Sound=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision02',Radius=(Min=512.000000,Max=512.000000),Pitch=(Min=1.000000,Max=1.500000),Volume=(Min=2.000000,Max=2.000000),Probability=(Min=1.000000,Max=1.000000))
        SpawningSound=PTSC_LinearLocal
        SpawningSoundProbability=(Min=1.000000,Max=1.000000)
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=1.500000,Max=1.500000)
        StartVelocityRange=(X=(Min=220.000000,Max=400.000000),Y=(Min=100.000000,Max=200.000000),Z=(Min=360.000000,Max=400.000000))
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter0'

    Begin Object Class=MeshEmitter Name=MeshEmitter1
        StaticMesh=StaticMesh'BonusParticles.UrbanParticles.Broken_Saw2'
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-900.000000)
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.300000,Max=0.300000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        MaxParticles=1
        StartLocationOffset=(X=-16.000000,Y=-16.000000)
        UseRotationFrom=PTRS_Actor
        SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
        SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000),Y=(Min=0.200000,Max=0.400000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-300.000000,Max=-400.000000),Y=(Min=-60.000000,Max=-140.000000),Z=(Min=260.000000,Max=300.000000))
    End Object
    Emitters(1)=MeshEmitter'MeshEmitter1'

    Begin Object Class=MeshEmitter Name=MeshEmitter2
        StaticMesh=StaticMesh'BonusParticles.UrbanParticles.Sawhorse_Leg'
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-900.000000)
        DampingFactorRange=(X=(Min=0.600000,Max=0.600000),Y=(Min=0.600000,Max=0.600000),Z=(Min=0.300000,Max=0.300000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        MaxParticles=1
        StartLocationOffset=(X=44.000000,Y=-20.000000,Z=-8.000000)
        UseRotationFrom=PTRS_Actor
        SpinCCWorCW=(Y=1.000000)
        SpinsPerSecondRange=(X=(Max=0.300000),Y=(Min=0.250000,Max=2.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=1.500000,Max=1.500000)
        StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-150.000000,Max=-200.000000),Z=(Min=200.000000,Max=280.000000))
        DetailMode=DM_High
    End Object
    Emitters(2)=MeshEmitter'MeshEmitter2'

    Begin Object Class=MeshEmitter Name=MeshEmitter3
        StaticMesh=StaticMesh'BonusParticles.UrbanParticles.Sawhorse_Leg'
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-900.000000)
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.300000,Max=0.300000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        MaxParticles=1
        StartLocationOffset=(X=-36.000000,Y=20.000000,Z=-8.000000)
        UseRotationFrom=PTRS_Actor
        SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=0.500000))
        StartSpinRange=(X=(Min=0.500000,Max=0.500000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(Y=(Min=320.000000,Max=400.000000),Z=(Min=230.000000,Max=250.000000))
        DetailMode=DM_High
    End Object
    Emitters(3)=MeshEmitter'MeshEmitter3'

    Begin Object Class=MeshEmitter Name=MeshEmitter4
        StaticMesh=StaticMesh'BonusParticles.UrbanParticles.Sawhorse_Light'
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-800.000000)
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.300000,Max=0.300000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        MaxParticles=1
        StartLocationOffset=(X=40.000000,Z=28.000000)
        UseRotationFrom=PTRS_Actor
        SpinsPerSecondRange=(X=(Max=0.500000),Y=(Max=0.200000))
        RotationDampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=200.000000,Max=250.000000))
    End Object
    Emitters(4)=MeshEmitter'MeshEmitter4'

    Begin Object Class=MeshEmitter Name=MeshEmitter5
        StaticMesh=StaticMesh'BonusParticles.UrbanParticles.WoodShard'
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        Acceleration=(Z=-900.000000)
        DampingFactorRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.200000,Max=0.400000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        MaxParticles=5
        StartLocationOffset=(Z=15.000000)
        StartLocationRange=(Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
        SphereRadiusRange=(Min=2.000000,Max=5.000000)
        UseRotationFrom=PTRS_Actor
        SpinsPerSecondRange=(X=(Max=0.100000),Y=(Max=0.100000))
        StartSpinRange=(Y=(Min=-0.200000,Max=0.200000))
        SizeScale(1)=(RelativeTime=0.100000,RelativeSize=0.750000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.750000)
        StartSizeRange=(X=(Max=4.000000),Y=(Min=0.500000,Max=2.000000))
        InitialParticlesPerSecond=200.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=100.000000))
        StartVelocityRadialRange=(Min=-300.000000,Max=-400.000000)
        VelocityLossRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=0.500000,Max=1.000000))
        GetVelocityDirectionFrom=PTVD_AddRadial
        DetailMode=DM_High
    End Object
    Emitters(5)=MeshEmitter'MeshEmitter5'

    Begin Object Class=MeshEmitter Name=MeshEmitter6
        StaticMesh=StaticMesh'BonusParticles.UrbanParticles.WoodShard'
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        Acceleration=(Z=-900.000000)
        DampingFactorRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.200000,Max=0.400000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        MaxParticles=5
        StartLocationOffset=(Z=15.000000)
        StartLocationRange=(Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
        SphereRadiusRange=(Min=2.000000,Max=5.000000)
        UseRotationFrom=PTRS_Actor
        SpinsPerSecondRange=(X=(Max=0.100000),Y=(Max=0.100000))
        StartSpinRange=(Y=(Min=-0.200000,Max=0.200000))
        SizeScale(1)=(RelativeTime=0.100000,RelativeSize=0.750000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.750000)
        StartSizeRange=(X=(Max=4.000000),Y=(Min=0.500000,Max=2.000000))
        InitialParticlesPerSecond=200.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=100.000000))
        StartVelocityRadialRange=(Min=-300.000000,Max=-400.000000)
        VelocityLossRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=0.500000,Max=1.000000))
        GetVelocityDirectionFrom=PTVD_AddRadial
        DetailMode=DM_High
    End Object
    Emitters(6)=MeshEmitter'MeshEmitter6'


    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        FadeIn=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=128,G=128,R=128,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
        Opacity=0.500000
        FadeInEndTime=0.200000
        MaxParticles=8
        StartLocationOffset=(Z=24.000000)
        StartLocationRange=(Y=(Min=-80.000000,Max=80.000000))
        SphereRadiusRange=(Min=5.000000,Max=5.000000)
        UseRotationFrom=PTRS_Actor
        SizeScale(0)=(RelativeSize=0.700000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=80.000000))
        InitialParticlesPerSecond=500.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'AW-2004Particles.Weapons.DustSmoke'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=2.000000,Max=2.000000)
        DetailMode=DM_High
    End Object
    Emitters(7)=SpriteEmitter'SpriteEmitter0'
	bNoDelete=false
	bBlockActors=False
	RemoteRole=Role_None
	Physics=PHYS_None
	bHardAttach=True

	AutoDestroy=1
	AutoReset=0
	CullDistance=3000
}
