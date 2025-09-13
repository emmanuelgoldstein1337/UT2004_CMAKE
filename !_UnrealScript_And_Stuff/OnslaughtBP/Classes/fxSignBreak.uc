//-----------------------------------------------------------
//
//-----------------------------------------------------------
class fxSignBreak extends Emitter;

DefaultProperties
{

    Begin Object Class=MeshEmitter Name=MeshEmitter0
        StaticMesh=StaticMesh'BonusParticles.UrbanParticles.BentSignpost'
        UseParticleColor=True
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1500.000000)
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.300000,Max=0.300000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        MaxParticles=1
        StartLocationOffset=(Z=40.000000)
        SpinCCWorCW=(Y=0.000000)
        SpinsPerSecondRange=(X=(Max=0.500000),Y=(Min=0.300000,Max=1.000000))
        StartSizeRange=(X=(Min=0.500000,Max=0.500000))
        Sounds(0)=(Sound=Sound'AW-2k4XP.Generic.Signbreak_SFX',Radius=(Min=512.000000,Max=512.000000),Pitch=(Min=1.000000,Max=1.500000),Volume=(Min=2.000000,Max=2.000000),Probability=(Min=1.000000,Max=1.000000))
        SpawningSound=PTSC_LinearLocal
        SpawningSoundProbability=(Min=1.000000,Max=1.000000)
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=2.500000,Max=2.500000)
        StartVelocityRange=(X=(Min=200.000000,Max=200.000000),Z=(Min=600.000000,Max=900.000000))
    End Object

    Emitters(0)=MeshEmitter'MeshEmitter0'

    Begin Object Class=MeshEmitter Name=MeshEmitter1
        StaticMesh=StaticMesh'BonusParticles.UrbanParticles.BentSignface'
        UseParticleColor=True
        UseCollision=True
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1500.000000)
        DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.300000,Max=0.300000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        MaxParticles=1
        StartLocationOffset=(X=-40.000000,Y=16.000000,Z=110.000000)
        SpinsPerSecondRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
        StartSpinRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=0.100000,Max=0.100000),Z=(Min=0.100000,Max=0.100000))
        StartSizeRange=(X=(Min=0.500000,Max=0.500000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        LifetimeRange=(Min=2.500000,Max=2.500000)
        StartVelocityRange=(X=(Min=200.000000,Max=500.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=600.000000,Max=900.000000))
    End Object

    Emitters(1)=MeshEmitter'MeshEmitter1'

	bNoDelete=false
	bBlockActors=False
	RemoteRole=Role_None
	Physics=PHYS_None
	bHardAttach=True

	AutoDestroy=1
	AutoReset=0
	CullDistance=3000

}
