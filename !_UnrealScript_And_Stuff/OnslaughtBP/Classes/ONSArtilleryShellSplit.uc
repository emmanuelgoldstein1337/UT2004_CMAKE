//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSArtilleryShellSplit extends Emitter;

DefaultProperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter0
        StaticMesh=StaticMesh'ONS-BPJW1.Meshes.LargeShell_half'
        RespawnDeadParticles=False
        SpinParticles=True
        DampRotation=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-2213.385010)
        DampingFactorRange=(X=(Min=0.160000,Max=0.160000),Y=(Min=0.160000,Max=0.160000),Z=(Min=0.160000,Max=0.160000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=1
        Name="MeshEmitter0"
        SpinsPerSecondRange=(X=(Min=-0.390000,Max=-0.390000),Y=(Min=1.012000,Max=1.012000))
        StartSpinRange=(X=(Min=-0.250000,Max=-0.250000),Z=(Min=0.250000,Max=0.250000))
        StartSizeRange=(X=(Min=2.500000,Max=2.500000),Y=(Min=2.500000,Max=2.500000),Z=(Min=2.500000,Max=2.500000))
        InitialParticlesPerSecond=50.000000
        DrawStyle=PTDS_Regular
        StartVelocityRange=(X=(Min=500.000000,Max=650.000000),Y=(Min=-743.802002,Max=-540.000000),Z=(Min=198.000000,Max=500.000000))
    End Object
    Emitters(0)=MeshEmitter'MeshEmitter0'

    Begin Object Class=MeshEmitter Name=MeshEmitter2
        StaticMesh=StaticMesh'ONS-BPJW1.Meshes.LargeShell_half'
        RespawnDeadParticles=False
        SpinParticles=True
        DampRotation=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-2213.385010)
        DampingFactorRange=(X=(Min=0.160000,Max=0.160000),Y=(Min=0.160000,Max=0.160000),Z=(Min=0.160000,Max=0.160000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=1
        Name="MeshEmitter2"
        SpinsPerSecondRange=(X=(Min=0.390000,Max=0.390000),Y=(Min=-1.012000,Max=-1.012000))
        StartSpinRange=(X=(Min=0.250000,Max=0.250000),Z=(Min=0.250000,Max=0.250000))
        StartSizeRange=(X=(Min=2.500000,Max=2.500000),Y=(Min=2.500000,Max=2.500000),Z=(Min=2.500000,Max=2.500000))
        InitialParticlesPerSecond=50.000000
        DrawStyle=PTDS_Regular
        StartVelocityRange=(X=(Min=400.000000,Max=650.000000),Y=(Min=543.299011,Max=646.783997),Z=(Min=229.619995,Max=267.000000))
    End Object
    Emitters(1)=MeshEmitter'MeshEmitter2'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1536.275024)
        ColorScale(0)=(Color=(B=129,G=174,R=243,A=255))
        ColorScale(1)=(RelativeTime=0.314286,Color=(B=66,G=151,R=236,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=180,G=180,R=245,A=255))
        FadeOutStartTime=0.756000
        MaxParticles=20
        Name="SpriteEmitter1"
        SpinsPerSecondRange=(X=(Min=-2.000000,Max=2.000000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.170000,RelativeSize=4.740000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
        SizeScale(3)=(RelativeTime=0.620000,RelativeSize=1.000000)
        SizeScale(4)=(RelativeTime=1.000000,RelativeSize=1.000000)
        SizeScaleRepeats=20.000000
        StartSizeRange=(X=(Min=2.000000,Max=4.000000),Y=(Min=2.000000,Max=4.000000),Z=(Min=2.000000,Max=4.000000))
        InitialParticlesPerSecond=1000.000000
        Texture=Texture'ONSBPTextures.fX.Flair1'
        LifetimeRange=(Min=0.648000,Max=1.200000)
        StartVelocityRange=(X=(Min=500.000000,Max=1100.000000),Y=(Min=-700.000000,Max=700.000000),Z=(Min=-224.399994,Max=261.899994))
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter1'

    Skins(0)=Texture'ONSBPTextures.fX.Missile'
    bNoDelete=False
    AutoDestroy=True
	bHighDetail=true
}
