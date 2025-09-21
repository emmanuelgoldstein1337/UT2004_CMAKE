#include "EnginePrivate.h"

#ifdef WITH_PHYS_WRAP

void UKarmaParamsCollision::execCalcContactRegion(FFrame& Stack, RESULT_DECL)
{
	guard(UKarmaParamsCollision::execCalcContactRegion);

	P_FINISH;

	// no-op stub for builds without Karma support.  --ryan.

	unguard;
}

// Returns actors model (or NULL if it has none, or is a constraint.
McdModelID AActor::getKModel() const
{
	return 0;
}

void AActor::KWake()
{
	guard(AActor::KWake);
	unguard;
}

UBOOL AActor::KIsAwake()
{
	guard(AActor::KIsAwake);
	return 0;
	unguard;
}

void AActor::physKarma(FLOAT deltaTime)
{
	guard(AActor::physKarma);
	//clock(GStats.DWORDStats(GEngineStats.STATS_Karma_physKarma));
	//physKarma_internal(deltaTime);
	//unclock(GStats.DWORDStats(GEngineStats.STATS_Karma_physKarma));
	unguard;
}

void AActor::preKarmaStep(FLOAT DeltaTime) // This is called just before this actor is simulated. You CAN change damping and add forces. You CANNOT create or destroy anything.
{
	guard(AActor::preKarmaStep);
	check(Physics == PHYS_Karma || Physics == PHYS_KarmaRagDoll);

	if (Physics == PHYS_KarmaRagDoll)
	{
		this->preKarmaStep_skeletal(DeltaTime);
		return;
	}
	unguard;
}

void AActor::postKarmaStep() // Called just after the actor has finished being simulated.
{
	guard(AActor::postKarmaStep);
	unguard;
}

void AKRepulsor::Destroy() //533
{
	guard(AKRepulsor::Destroy);

	if (KContact)
	{
		//MdtContactGroupID cg = (MdtContactGroupID)KContact;if (MdtContactGroupIsEnabled(cg))MdtContactGroupDisable(cg);MdtContactGroupDestroy(cg);
		KContact = NULL;
	}

	Super::Destroy();

	unguard;
}

//////////// AKVEHICLE C++ ////////////////

void AKVehicle::PostNetReceive() //1189
{
	guard(AKVehicle::PostNetReceive);

	Super::PostNetReceive();
	eventVehicleStateReceived();

	unguard;
}

void AKVehicle::PostEditChange() //1199
{
	guard(AKVehicle::PostEditChange);
	Super::PostEditChange();

	// Tell script that a parameters has changed, in case it needs to KUpdateConstraintParams on any constraints.
	this->eventKVehicleUpdateParams();
	unguard;
}

void AKVehicle::setPhysics(BYTE NewPhysics, AActor* NewFloor, FVector NewFloorV) //1209
{
	guard(AKVehicle::setPhysics);
	check(Physics == PHYS_Karma);
	if (NewPhysics != PHYS_Karma)
	{
		debugf(TEXT("%s->setPhysics(%d). KVehicle's can only have Physics == PHYS_Karma."), this->GetName(), NewPhysics);
		return;
	}
	unguard;
}

void AKVehicle::TickSimulated(FLOAT DeltaSeconds) //1252
{
	guard(AKVehicle::TickSimulated);
	TickAuthoritative(DeltaSeconds);
	unguard;
}

void AKVehicle::TickAuthoritative(FLOAT DeltaSeconds) //1224
{
	guard(AKVehicle::TickAuthoritative);

	check(Physics == PHYS_Karma); // karma vehicles should always be in PHYS_Karma

	eventTick(DeltaSeconds);
	ProcessState(DeltaSeconds);
	UpdateTimers(DeltaSeconds);

	// Update LifeSpan.
	if (LifeSpan != 0.f)
	{
		LifeSpan -= DeltaSeconds;
		if (LifeSpan <= 0.0001f)
		{
			GetLevel()->DestroyActor(this);
			return;
		}
	}

	// Perform physics.
	if (!bDeleteMe)
		performPhysics(DeltaSeconds);

	unguard;
}
#endif // WITH_PHYS_WRAP