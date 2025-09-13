class WaterVolume extends PhysicsVolume;

var string EntrySoundName, ExitSoundName, EntryActorName, PawnEntryActorName;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( (EntrySound == None) && (EntrySoundName != "") )
		EntrySound = Sound(DynamicLoadObject(EntrySoundName,class'Sound'));
	if ( (ExitSound == None) && (ExitSoundName != "") )
		ExitSound = Sound(DynamicLoadObject(ExitSoundName,class'Sound'));
	if ( (EntryActor == None) && (EntryActorName != "") )
		EntryActor = class<Actor>(DynamicLoadObject(EntryActorName,class'Class'));
	if ( (PawnEntryActor == None) && (PawnEntryActorName != "") )
		PawnEntryActor = class<Actor>(DynamicLoadObject(PawnEntryActorName,class'Class'));
}

defaultproperties
{
	PawnEntryActorName="xGame.WaterRing"
	EntryActorName="xGame.WaterSplash"
	EntrySoundName="PlayerSounds.FootstepWater1"
	ExitSoundName="GeneralImpacts.ImpactSplash2"
	bWaterVolume=True
    FluidFriction=+00002.400000
	LocationName="under water"
	bDistanceFog=true
	DistanceFogColor=(R=32,G=64,B=128,A=64)
	DistanceFogStart=+8.0
	DistanceFogEnd=+2000.0
	KExtraLinearDamping=2.5
	KExtraAngularDamping=0.4
}
