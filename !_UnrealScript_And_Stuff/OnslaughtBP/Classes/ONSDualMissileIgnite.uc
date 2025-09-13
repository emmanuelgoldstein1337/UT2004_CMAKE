//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSDualMissileIgnite extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=51,G=163,R=244))
        ColorScale(2)=(RelativeTime=0.600000,Color=(B=47,G=156,R=255))
        ColorScale(3)=(RelativeTime=1.000000)
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.250000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        InitialParticlesPerSecond=500.000000
        Texture=Texture'AW-2k4XP.Weapons.ShockTankEffectCore2Ga'
        LifetimeRange=(Min=0.250000,Max=0.250000)
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter4
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=60,G=163,R=255))
        ColorScale(1)=(RelativeTime=0.500000,Color=(B=36,G=102,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=80.000000,Max=80.000000))
        InitialParticlesPerSecond=500.000000
        Texture=Texture'AW-2004Particles.Fire.SmokeFragment'
        LifetimeRange=(Min=0.300000,Max=0.300000)
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter4'
    AutoDestroy=true
    bNoDelete=false
	CullDistance=3000
}