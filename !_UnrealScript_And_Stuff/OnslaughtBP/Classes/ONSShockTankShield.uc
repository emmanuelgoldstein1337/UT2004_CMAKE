//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSShockTankShield extends Actor;

#exec OBJ LOAD FILE=..\StaticMeshes\ONS-BPJW1.usx

var Emitter ShockShieldEffect, ShockShieldHitEffect;

function Bump( actor Other )
{
	if ( Projectile(Other) != None )
	{
		Other.HitWall(-1*Normal(Other.Velocity),self);
	}
}

function TakeDamage(int Dam, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	if (ONSShockTankCannon(Owner) != None)
        ONSShockTankCannon(Owner).NotifyShieldHit(Dam, instigatedBy);
}

simulated function SpawnHitEffect(byte TeamNum)
{
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (ShockShieldEffect != None)
        {
            if (TeamNum == 1)
                ShockShieldHitEffect = spawn(class'ONSShockTankShieldHitEffectBlue', self);
            else
                ShockShieldHitEffect = spawn(class'ONSShockTankShieldHitEffectRed', self);
        }

        if (ShockShieldHitEffect != None && Owner != None && ONSShockTankCannon(Owner) != None)
            Owner.AttachToBone(ShockShieldEffect, 'ElectroGun');
    }
}

simulated function ActivateShield(byte TeamNum)
{
    SetCollision(True, False, False);

    if (Level.NetMode != NM_DedicatedServer)
    {
        if (ShockShieldEffect == None)
        {
            if (TeamNum == 1)
                ShockShieldEffect = spawn(class'ONSShockTankShieldEffectBlue', self);
            else
                ShockShieldEffect = spawn(class'ONSShockTankShieldEffectRed', self);

            PlaySound(sound'ONSBPSounds.ShockTank.ShieldActivate', SLOT_None, 2.0);
        }

        if (ShockShieldEffect != None && Owner != None && ONSShockTankCannon(Owner) != None)
            Owner.AttachToBone(ShockShieldEffect, 'ElectroGun');
    }
}

simulated function DeactivateShield()
{
    SetCollision(False, False, False);

    if (Level.NetMode != NM_DedicatedServer)
        PlaySound(sound'ONSBPSounds.ShockTank.ShieldOff', SLOT_None, 2.0);

    if (ShockShieldEffect != None)
        ShockShieldEffect.Destroy();
}

simulated function Destroyed()
{
    if (ShockShieldEffect != None)
        ShockShieldEffect.Destroy();

    Super.Destroyed();
}

DefaultProperties
{
	bBlockProjectiles=true
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'AW-2k4XP.Weapons.ShockShield'
    DrawScale3D=(X=2.0,Y=3.0,Z=3.0)
    bStatic=false
    bNoDelete=false
    bCollideWorld=false
    bHidden=true
    bProjTarget=true
    RemoteRole=ROLE_None
    CollisionHeight=350
    CollisionRadius=650
}
