//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSArtilleryCamThrusterRed extends Emitter;

DefaultProperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter10
        UseColorScale=True
        FadeOut=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
		MaxParticles=8
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.90000
        FadeOutStartTime=0.320000
        Name="SpriteEmitter10"
        StartLocationRange=(Z=(Min=-14.000000,Max=-14.000000))
        SizeScale(0)=(RelativeSize=1.780000)
        SizeScale(1)=(RelativeTime=0.750000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.860000)
        StartSizeRange=(X=(Min=13.400000,Max=13.400000),Y=(Min=30.000000,Max=30.000000),Z=(Min=13.400000,Max=13.400000))
        Texture=Texture'ONSBPTextures.fX.Fire'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=1.600000,Max=2.000000)
        StartVelocityRange=(Z=(Min=-11.553000,Max=-11.553000))
        WarmupTicksPerSecond=1.000000
        RelativeWarmupTime=1.000000
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter10'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter11
        UseColorScale=True
        FadeOut=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorScale(0)=(Color=(B=0,G=0,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=0,G=0,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.900000
        FadeOutStartTime=0.300000
        MaxParticles=3
        Name="SpriteEmitter11"
        SizeScale(0)=(RelativeSize=1.230000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=15.870000,Max=15.870000),Y=(Min=15.870000,Max=15.870000),Z=(Min=15.870000,Max=15.870000))
        Texture=Texture'ONSBPTextures.fX.Flair1'
        LifetimeRange=(Min=0.860000,Max=0.860000)
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter11'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        UseColorScale=True
        FadeOut=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ColorScale(0)=(Color=(B=16,G=10,R=254,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=62,G=57,R=215,A=255))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.90000
        FadeOutStartTime=1.590000
        MaxParticles=3
        Name="SpriteEmitter2"
        StartLocationRange=(Z=(Min=33.000000,Max=33.000000))
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
        SizeScaleRepeats=2.000000
        StartSizeRange=(X=(Min=10.000000,Max=15.000000),Y=(Min=10.000000,Max=15.000000),Z=(Min=10.000000,Max=15.000000))
        Texture=Texture'XEffects.GoldGlow'
        LifetimeRange=(Min=3.000000,Max=3.000000)
        WarmupTicksPerSecond=1.000000
        RelativeWarmupTime=1.000000
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter2'

    bNoDelete=False
    GlobalOffsetRange=(Z=(Min=-10,Max=-10))
}
