//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSDualMissileExplosion extends Emitter;

function PostBeginPlay()
{
	local PlayerController PC;

	Super.PostBeginPlay();

	PC = Level.GetLocalPlayerController();
	if ( PC == None )
	{
		Destroy();
		return;
	}
	if ( Level.bDropDetail || (PC.ViewTarget == None) || (VSize(Location - PC.ViewTarget.Location) > 4000) )
		Emitters[0].Disabled = true;
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter19
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.400000,Color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=1.000000)
        MaxParticles=2
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.500000)
        StartSizeRange=(X=(Min=50.000000,Max=70.000000))
        InitialParticlesPerSecond=500.000000
        Texture=Texture'AW-2004Particles.Fire.GrenadeTest'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
		DetailMode=DM_High
        LifetimeRange=(Min=0.400000,Max=0.400000)
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter19'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter20
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=32,G=141,R=240))
        ColorScale(2)=(RelativeTime=0.500000,Color=(B=10,G=102,R=241))
        ColorScale(3)=(RelativeTime=1.000000)
        MaxParticles=4
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=5.000000,Max=10.000000)
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'AW-2004Particles.Fire.SmokeFragment'
        LifetimeRange=(Min=0.400000,Max=0.400000)
        StartVelocityRadialRange=(Min=-50.000000,Max=-100.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter20'

    bNoDelete=false
    AutoDestroy=true
    RemoteRole=ROLE_None

	bDynamicLight=false
    LightEffect=LE_None
    LightType=LT_None
	CullDistance=+8000.0
}