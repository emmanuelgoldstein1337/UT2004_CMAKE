//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSArtilleryCannonMuzzleFlash extends Emitter;


function PostBeginPlay()
{
	local PlayerController PC;

	PC = Level.GetLocalPlayerController();
	if ( PC == None )
	{
		Destroy();
		return;
	}
	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 8000) )
	{
		Emitters[4].Disabled = true;
		Emitters[5].Disabled = true;
		Emitters[8].Disabled = true;
		Emitters[9].Disabled = true;
	}
}

DefaultProperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.375000,Color=(B=223,G=223,R=223,A=255))
        ColorScale(2)=(RelativeTime=0.714286,Color=(B=201,G=201,R=201,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=58))
        ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(5)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(6)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        ColorScale(7)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        Opacity=0.720000
        FadeOutStartTime=0.214200
        MaxParticles=6
        Name="SpriteEmitter0"
        UseRotationFrom=PTRS_Actor
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(1)=(RelativeTime=0.170000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=0.310000,RelativeSize=4.000000)
        SizeScale(3)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=73.000000,Max=73.000000),Y=(Min=73.000000,Max=73.000000),Z=(Min=73.000000,Max=73.000000))
        InitialParticlesPerSecond=90.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'ONSBPTextures.fX.ExploTrans'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=0.376000,Max=0.476000)
        InitialDelayRange=(Min=0.200000,Max=0.200000)
        StartVelocityRange=(X=(Min=2267.261963,Max=2267.261963))
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter4
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=100,G=176,R=217,A=255))
        ColorScale(1)=(RelativeTime=0.500000,Color=(B=47,G=168,R=208,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=74,G=232,R=236,A=255))
        Opacity=0.80000
        FadeOutStartTime=0.107470
        MaxParticles=1
        Name="Flash"
        UseRotationFrom=PTRS_Actor
        SizeScale(0)=(RelativeSize=5.000000)
        SizeScale(1)=(RelativeTime=0.170000,RelativeSize=20.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=50.000,Max=50.000),Y=(Min=50.000,Max=50.000),Z=(Min=50.0,Max=50.000))
        InitialParticlesPerSecond=200.000000
        Texture=Texture'ONSBPTextures.fX.Flair1'
        LifetimeRange=(Min=0.772000,Max=0.772000)
        InitialDelayRange=(Min=0.200000,Max=0.200000)
        StartVelocityRange=(X=(Min=700.000000,Max=700.000000))
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter4'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter7
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.121429,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=0.521429,Color=(B=255,G=255,R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(5)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutStartTime=0.700000
        MaxParticles=8
        Name="FrontSmoke"
        UseRotationFrom=PTRS_Actor
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=0.140000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.680000)
        StartSizeRange=(X=(Min=26.806000,Max=73.730003),Y=(Min=26.806000,Max=73.730003),Z=(Min=26.806000,Max=73.730003))
        InitialParticlesPerSecond=70.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'ONSBPTextures.Smoke'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        InitialDelayRange=(Min=0.066000,Max=0.098000)
        StartVelocityRange=(X=(Min=490.000000,Max=490.000000))
        WarmupTicksPerSecond=0.700000
        RelativeWarmupTime=0.700000
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter7'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter19
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Y=-600.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.121429,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=0.521429,Color=(B=255,G=255,R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(5)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutStartTime=0.700000
        MaxParticles=5
        Name="LSmoke1Lead"
        StartLocationRange=(Y=(Min=-107.500000,Max=-107.500000))
        UseRotationFrom=PTRS_Actor
        SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=0.700000)
        SizeScale(1)=(RelativeTime=0.070000,RelativeSize=3.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=10.000000)
        StartSizeRange=(X=(Min=25.805000,Max=25.805000),Y=(Min=25.805000,Max=25.805000),Z=(Min=25.805000,Max=25.805000))
        InitialParticlesPerSecond=100.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'ONSBPTextures.Smoke'
        LifetimeRange=(Min=0.620000,Max=0.620000)
        InitialDelayRange=(Min=0.218000,Max=0.218000)
        StartVelocityRange=(Y=(Min=-854.320007,Max=-854.320007),Z=(Min=-60.000000,Max=60.000000))
    End Object
    Emitters(3)=SpriteEmitter'SpriteEmitter19'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter8
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        Acceleration=(Y=-300.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.121429,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=0.764286,Color=(B=255,G=255,R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutStartTime=0.700000
        MaxParticles=10
        Name="LFire1"
        AddLocationFromOtherEmitter=3
        SpinsPerSecondRange=(X=(Min=-0.020000,Max=0.020000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.070000,RelativeSize=3.520000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=5.440000)
        StartSizeRange=(X=(Min=7.000000,Max=70.000000),Y=(Min=7.000000,Max=70.000000),Z=(Min=7.000000,Max=70.000000))
        InitialParticlesPerSecond=24.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'ONSBPTextures.fX.ExploTrans'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=0.457000,Max=0.557000)
        InitialDelayRange=(Min=0.160000,Max=0.160000)
        StartVelocityRange=(X=(Min=-272.000000,Max=272.000000),Z=(Min=-272.000000,Max=272.000000))
        WarmupTicksPerSecond=0.700000
        RelativeWarmupTime=0.700000
		DetailMode=DM_High
    End Object
    Emitters(4)=SpriteEmitter'SpriteEmitter8'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter10
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Y=-600.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.121429,Color=(B=255,G=255,R=255,A=174))
        ColorScale(2)=(RelativeTime=0.521429,Color=(B=255,G=255,R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(5)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutStartTime=0.700000
        MaxParticles=9
        Name="LSmoke2"
        AddLocationFromOtherEmitter=3
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=0.003000)
        SizeScale(1)=(RelativeSize=1.290000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=6.000000)
        StartSizeRange=(X=(Min=50.049999,Max=73.730003),Y=(Min=50.049999,Max=73.730003),Z=(Min=50.049999,Max=73.730003))
        InitialParticlesPerSecond=20.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'ONSBPTextures.Smoke'
        LifetimeRange=(Min=0.510000,Max=0.510000)
        InitialDelayRange=(Min=0.102000,Max=0.102000)
        WarmupTicksPerSecond=0.700000
        RelativeWarmupTime=0.700000
		DetailMode=DM_High
    End Object
    Emitters(5)=SpriteEmitter'SpriteEmitter10'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter16
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=89,G=124,R=227,A=255))
        ColorScale(1)=(RelativeTime=0.346429,Color=(B=43,G=187,R=213,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=40,G=145,R=215,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=74,G=232,R=236,A=255))
        Name="MainBeam"
        UseRotationFrom=PTRS_Actor
        SizeScale(0)=(RelativeSize=50.000000)
        SizeScale(1)=(RelativeTime=0.170000,RelativeSize=20.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
        InitialParticlesPerSecond=150.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'ONSBPTextures.fX.Flair1Alpha'
        LifetimeRange=(Min=0.217000,Max=0.217000)
        InitialDelayRange=(Min=0.200000,Max=0.200000)
        StartVelocityRange=(X=(Min=2820.000000,Max=2820.000000))
    End Object
    Emitters(6)=SpriteEmitter'SpriteEmitter16'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Y=600.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.121429,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=0.521429,Color=(B=255,G=255,R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(5)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutStartTime=0.700000
        MaxParticles=5
        Name="RSmoke1Lead"
        StartLocationRange=(Y=(Min=107.500000,Max=107.500000))
        UseRotationFrom=PTRS_Actor
        SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=0.700000)
        SizeScale(1)=(RelativeTime=0.070000,RelativeSize=3.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=10.000000)
        StartSizeRange=(X=(Min=25.805000,Max=25.805000),Y=(Min=25.805000,Max=25.805000),Z=(Min=25.805000,Max=25.805000))
        InitialParticlesPerSecond=100.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'ONSBPTextures.Smoke'
        LifetimeRange=(Min=0.620000,Max=0.620000)
        InitialDelayRange=(Min=0.218000,Max=0.218000)
        StartVelocityRange=(Y=(Min=854.320007,Max=854.320007),Z=(Min=-60.000000,Max=60.000000))
    End Object
    Emitters(7)=SpriteEmitter'SpriteEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter6
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        Acceleration=(Y=300.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.121429,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=0.764286,Color=(B=255,G=255,R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutStartTime=0.700000
        MaxParticles=10
        Name="RFire1"
        AddLocationFromOtherEmitter=7
        SpinsPerSecondRange=(X=(Min=-0.020000,Max=0.020000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.070000,RelativeSize=3.520000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=5.440000)
        StartSizeRange=(X=(Min=7.000000,Max=70.000000),Y=(Min=7.000000,Max=70.000000),Z=(Min=7.000000,Max=70.000000))
        InitialParticlesPerSecond=24.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'ONSBPTextures.fX.ExploTrans'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        LifetimeRange=(Min=0.457000,Max=0.557000)
        InitialDelayRange=(Min=0.160000,Max=0.160000)
        StartVelocityRange=(X=(Min=-272.000000,Max=272.000000),Z=(Min=-272.000000,Max=272.000000))
        WarmupTicksPerSecond=0.700000
        RelativeWarmupTime=0.700000
		DetailMode=DM_High
    End Object
    Emitters(8)=SpriteEmitter'SpriteEmitter6'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter9
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Y=-600.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.121429,Color=(B=255,G=255,R=255,A=174))
        ColorScale(2)=(RelativeTime=0.521429,Color=(B=255,G=255,R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(5)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutStartTime=0.700000
        MaxParticles=9
        Name="RSmoke2"
        AddLocationFromOtherEmitter=7
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=0.003000)
        SizeScale(1)=(RelativeSize=1.290000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=6.000000)
        StartSizeRange=(X=(Min=50.049999,Max=73.730003),Y=(Min=50.049999,Max=73.730003),Z=(Min=50.049999,Max=73.730003))
        InitialParticlesPerSecond=20.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'ONSBPTextures.Smoke'
        LifetimeRange=(Min=0.500000,Max=0.500000)
        InitialDelayRange=(Min=0.102000,Max=0.102000)
        WarmupTicksPerSecond=0.700000
        RelativeWarmupTime=0.700000
		DetailMode=DM_High
    End Object
    Emitters(9)=SpriteEmitter'SpriteEmitter9'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter14
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=100.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.940000
        FadeOutStartTime=0.560550
        MaxParticles=10
        Name="finalsmoke"
        StartLocationRange=(X=(Min=-80.000000,Max=80.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-120.000000,Max=100.000000))
        UseRotationFrom=PTRS_Actor
        SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(2)=(RelativeTime=0.070000,RelativeSize=1.000000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=2.190000)
        StartSizeRange=(X=(Min=300.000000,Max=320.000000),Y=(Min=300.000000,Max=320.000000),Z=(Min=300.000000,Max=320.000000))
        InitialParticlesPerSecond=1000.000000
        DrawStyle=PTDS_Darken
        Texture=Texture'ONSBPTextures.fX.seexpt'
        LifetimeRange=(Min=1.000000,Max=1.515000)
        InitialDelayRange=(Min=0.302000,Max=0.430000)
        StartVelocityRange=(X=(Min=140.399994,Max=270.000000),Y=(Min=-380.559998,Max=380.559998),Z=(Min=150.000000,Max=221.199997))
    End Object
    Emitters(10)=SpriteEmitter'SpriteEmitter14'

    bNoDelete=False
    AutoDestroy=True
}
