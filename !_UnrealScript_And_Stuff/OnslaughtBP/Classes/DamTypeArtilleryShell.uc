class DamTypeArtilleryShell extends VehicleDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth )
{
    HitEffects[0] = class'HitSmoke';

    if( VictimHealth <= 0 )
        HitEffects[1] = class'HitFlameBig';
    else if ( FRand() < 0.8 )
        HitEffects[1] = class'HitFlame';
}

defaultproperties
{
    DeathString="%k rained on %o's parade."
	MaleSuicide="%o was killed by an artillery strike."
	FemaleSuicide="%o was killed by an artillery strike."

    bDetonatesGoop=true
    bThrowRagdoll=true
	GibPerterbation=0.15
	bFlaming=true
	bDelayedDamage=true
	VehicleClass=class'ONSArtillery'
}
