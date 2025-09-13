//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSArtilleryTrajectoryBeamSegment extends Emitter;

simulated function SetLength(float Length)
{
    BeamEmitter(Emitters[0]).BeamDistanceRange.Min = Length;
    BeamEmitter(Emitters[0]).BeamDistanceRange.Max = Length;
}

DefaultProperties
{
    Begin Object Class=BeamEmitter Name=BeamEmitter0
        BeamDistanceRange=(Min=0.000000,Max=0.000000)
        DetermineEndPointBy=PTEP_Distance
        LowFrequencyPoints=2
        HighFrequencyPoints=2
        UseColorScale=True
        ColorScale(0)=(Color=(B=124,G=231,R=128,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.280000
        FadeOutStartTime=1.000000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        Name="BeamEmitter0"
        UseRotationFrom=PTRS_Actor
        StartSizeRange=(X=(Min=200.000000,Max=200.000000),Y=(Min=200.000000,Max=200.000000),Z=(Min=200.000000,Max=200.000000))
        InitialParticlesPerSecond=100.000000
        Texture=Texture'ONSBPTextures.fX.greenbeam'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=20.000000,Max=20.000000))
        WarmupTicksPerSecond=1.000000
        RelativeWarmupTime=1.000000
    End Object
    Emitters(0)=BeamEmitter'BeamEmitter0'

    bNoDelete=False
}
