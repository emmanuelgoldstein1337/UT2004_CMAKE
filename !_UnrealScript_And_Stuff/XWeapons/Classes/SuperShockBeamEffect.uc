class SuperShockBeamEffect extends ShockBeamEffect;

#exec obj load file=InstagibEffects.utx

simulated function SpawnEffects()
{
	local ShockBeamEffect E;
	
	Super.SpawnEffects();
	E = Spawn(class'ExtraRedBeam');
	if ( E != None )
		E.AimAt(mSpawnVecA, HitNormal); 
}
	
simulated function SpawnImpactEffects(rotator HitRot, vector EffectLoc)
{
	Spawn(class'ShockImpactFlareB',,, EffectLoc, HitRot);
	Spawn(class'ShockImpactRingB',,, EffectLoc, HitRot);
	Spawn(class'ShockImpactScorch',,, EffectLoc, Rotator(-HitNormal));
	Spawn(class'ShockExplosionCoreB',,, EffectLoc, HitRot);
}

defaultproperties
{
	bNetTemporary=false
	MuzFlashClass=class'ShockMuzFlashB'
	MuzFlash3Class=class'ShockMuzFlashB3rd'
	Skins(0)=InstagibEffects.RedSuperShockBeam
	CoilClass=class'ShockBeamCoilB'
    LightHue=0
}
