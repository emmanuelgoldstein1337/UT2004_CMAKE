class BlueSuperShockBeam extends ShockBeamEffect;

simulated function SpawnEffects()
{
	local ShockBeamEffect E;
	
	Super.SpawnEffects();
	E = Spawn(class'ExtraBlueBeam');
	if ( E != None )
		E.AimAt(mSpawnVecA, HitNormal); 
}

defaultproperties
{
	bNetTemporary=false
	MuzFlashClass=class'ShockMuzFlash'
	MuzFlash3Class=class'ShockMuzFlash3rd'
	Skins(0)=InstagibEffects.BlueSuperShockTex
    LightHue=230
	CoilClass=class'ShockBeamCoilBlue'
}