//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSDualACGatlingGun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Textures\TurretParticles.utx

var class<ONSTurretBeamEffect> BeamEffectClass[2];

function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
    local int Damage;

    X = Vector(Dir);
    End = Start + TraceRange * X;

    //skip past vehicle driver
    if (ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
    {
      	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
       	Other = Trace(HitLocation, HitNormal, End, Start, True);
       	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
    }
    else
       	Other = Trace(HitLocation, HitNormal, End, Start, True);

    if (Other != None)
    {
	if (!Other.bWorldGeometry)
        {
            Damage = (DamageMin + Rand(DamageMax - DamageMin));
            Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
            HitNormal = vect(0,0,0);
        }
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

    HitCount++;
    LastHitLocation = HitLocation;
    SpawnHitEffects(Other, HitLocation, HitNormal);
}

state InstantFireMode
{
	simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
	{
		local ONSTurretBeamEffect Beam;

		if (Level.NetMode != NM_DedicatedServer)
		{
			if (Role < ROLE_Authority)
			{
				CalcWeaponFire();
				DualFireOffset *= -1;
			}

			Beam = Spawn(BeamEffectClass[Team],,, WeaponFireLocation, rotator(HitLocation - WeaponFireLocation));
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			Beam.SpawnEffects(HitLocation, HitNormal);
		}
	}

    function AltFire(Controller C)
    {
		local ONSDecoy P;
		local ONSDualAttackCraft V;

    	if (AltFireProjectileClass != none)
    	{
			P =	ONSDecoy( SpawnProjectile(AltFireProjectileClass, True) );
			V = ONSDualAttackCraft(Owner);
			if (P != none && V != none)
			{
				V.Decoys.Insert(0,1);
				V.Decoys[0] = P;

			    P.ProtectedTarget = V;
			}
		}
    }
}

function rotator AdjustAim(bool bAltFire)
{
	local Rotator Result;
	local Projectile Incoming;

	if ( bAltFire && (Instigator.Controller == None) )
	{
		Incoming = ONSDualACGatlingGunPawn(Instigator).Incoming;
		if ( Incoming != None )
		{
			Result = Rotator(Incoming.Location + Incoming.Velocity * (VSize(Incoming.Location - WeaponFireLocation)/class'ONSDecoy'.Default.Speed) - WeaponFireLocation);
			if ( (Result.Pitch > 0) && (Result.Pitch < 32768) )
				Result.Pitch = 0;
			return Result;
		}
	}
	return Super.AdjustAim(bAltFire);
}

DefaultProperties
{
    Mesh=Mesh'ONSBPAnimations.DualAttackCraftGatlingGunMesh'
    YawBone=GatlingGun
    PitchBone=GatlingGun
    WeaponFireAttachmentBone=GatlingGunFirePoint
    AltFireProjectileClass=class'ONSDecoy'
    FireInterval=0.2
    DamageMin=25
    DamageMax=25
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchUpLimit=0
    PitchDownLimit=50000
    FireSoundClass=none
    FireSoundVolume=720
    FireForce="Laser01"
    BeamEffectClass(0)=class'ONSBellyTurretFire'
    BeamEffectClass(1)=class'ONSBellyTurretFire'
    bAimable=True
    bInstantFire=True
    bInstantRotation=True
    DualFireOffset=15
    TraceRange=20000
    AltFireInterval=1.5
    FireSoundPitch=2.0
    bAmbientFireSound
    DamageType=class'DamTypeONSCicadaLaser'
	CullDistance=+15000.0
}
