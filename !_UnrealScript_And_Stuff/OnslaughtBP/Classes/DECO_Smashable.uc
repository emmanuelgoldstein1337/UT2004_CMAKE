//-----------------------------------------------------------
// It Breaks good..
//-----------------------------------------------------------
class DECO_Smashable extends decoration;

var float RespawnTime;
var bool  bNeedsSingleShot;		// If true, it will only smash on damage if it's all in a single shot
var bool  bImperviusToPlayer;	// If true, the player can't smash it

function Reset()
{
	super.Reset();
    Gotostate('Working');
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	disable('tick');
	CullDistance = default.CullDistance;
}

function BreakApart(vector HitLocation, vector momentum)
{
	// If we are single player or on a listen server, just spawn the actor, otherwise
	// bHidden will trigger the effect

	if (Level.NetMode == NM_ListenServer || Level.NetMode == NM_StandAlone)
	{
		if ( (EffectWhenDestroyed!=None ) && EffectIsRelevant(location,false) )
			Spawn( EffectWhenDestroyed, Owner,, Location );
	}

	gotostate('Broken');
}

auto state Working
{
	function BeginState()
	{
		super.BeginState();

		SetCollision(true,true,true);
		NetUpdateTime = Level.TimeSeconds - 1;
		bHidden = false;
		Health = default.health;
	}

	function EndState()
	{
		super.EndState();

		NetUpdateTime = Level.TimeSeconds - 1;
		bHidden = true;
		SetCollision(false,false,false);
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,	Vector momentum, class<DamageType> damageType)
	{
		if ( Instigator != None )
			MakeNoise(1.0);

		if (bNeedsSingleShot)
		{
			if (Damage > Health)
				BreakApart(HitLocation, Momentum);
		}
		else
		{
			Health -= Damage;
			if ( Health < 0 )
				BreakApart(HitLocation, Momentum);
		}
	}

	function Bump( actor Other )
	{
		if ( Mover(Other) != None && Mover(Other).bResetting )
			return;

		if ( UnrealPawn(Other)!=None && bImperviusToPlayer )
			return;

		if ( VSize(Other.Velocity)>500 )
			BreakApart(Other.Location, Other.Velocity);
	}

	function bool EncroachingOn(Actor Other)
	{
		if ( Mover(Other) != None && Mover(Other).bResetting )
			return false;

		BreakApart(Other.Location, Other.Velocity);
		return false;
	}


	event EncroachedBy(Actor Other)
	{
		if ( Mover(Other) != None && Mover(Other).bResetting )
			return;

		BreakApart(Other.Location, Other.Velocity);
	}
}


state Broken
{
	function BeginState()
	{
		super.BeginState();
		SetTimer(30,false);
	}

	event Timer()
	{
		local pawn p;
		super.Timer();

		foreach RadiusActors(class'Pawn', P, CollisionRadius * 1.25)
		{
			SetTimer(5,false);
			return;
		}

		GotoState('Working');
	}
}

simulated function PostNetReceive()
{
	if ( bHidden && EffectWhenDestroyed != none && EffectIsRelevant(location,false) )
		Spawn( EffectWhenDestroyed, Owner,, Location );
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
	bStatic=false
	bStasis=false
	bDamageable=true
	bCanBeDamaged=true
	bEdShouldSnap=true
	bUseCylinderCollision=true
    bCollideActors=true
    bCollideWorld=true
    bBlockActors=true
	bBlockKarma=true
	bFixedRotationDir=true
	bOrientOnSlope=false
	bPushable=false
	bMovable=false

	RespawnTime=30
	bNeedsSingleShot=false
	bImperviusToPlayer=true
	bNetInitialRotation=true
	RemoteRole=ROLE_SimulatedProxy
	bNetNotify=true
	CullDistance=4500
	NetUpdateFrequency=1
}
