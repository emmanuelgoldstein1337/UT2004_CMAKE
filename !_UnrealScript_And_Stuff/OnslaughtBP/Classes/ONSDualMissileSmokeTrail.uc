//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSDualMissileSmokeTrail extends Emitter;


defaultproperties
{
    Begin Object Class=TrailEmitter Name=TrailEmitter4
        TrailShadeType=PTTST_PointLife
        TrailLocation=PTTL_FollowEmitter
        MaxPointsPerTrail=150
        DistanceThreshold=20.000000
        UseCrossedSheets=True
        PointLifeTime=0.750000
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        MaxParticles=1
        StartSizeRange=(X=(Min=80.000000,Max=80.000000))
        InitialParticlesPerSecond=2000.000000
        Texture=Texture'AW-2k4XP.Cicada.MissileTrail1a'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=999999.000000,Max=999999.000000)
    End Object
    Emitters(0)=TrailEmitter'TrailEmitter4'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter9
        ProjectionNormal=(X=1.000000,Z=0.000000)
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=64,G=255,R=241))
        ColorScale(1)=(RelativeTime=0.750000,Color=(B=64,G=155,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        Opacity=0.750000
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        StartLocationOffset=(X=-10.000000)
        SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.200000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.500000)
        SizeScale(2)=(RelativeTime=0.150000,RelativeSize=1.000000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=0.750000)
        StartSizeRange=(X=(Max=200.000000))
        InitialParticlesPerSecond=50.000000
        Texture=Texture'EpicParticles.Flares.FlickerFlare'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=2.000000,Max=2.000000)
        InitialDelayRange=(Min=0.050000,Max=0.050000)
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter9'

	bStasis=false
	bDirectional=true
	bHardAttach=true
   	bNoDelete=false
	RemoteRole=ROLE_None
	AutoDestroy=True

    Physics=PHYS_Trailer
}
