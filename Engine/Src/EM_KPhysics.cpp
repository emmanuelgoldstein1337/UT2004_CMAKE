#include "ode/ode.h"

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
void * AActor::getKModel() const
{
	if (!this->KParams)
		return 0;

	return ((void *)this->KParams->KarmaData);
}

void AActor::physKarma(FLOAT deltaTime)
{
	guard(AActor::physKarma);
	clock(GStats.DWORDStats(GEngineStats.STATS_Karma_physKarma));

	check(Physics == PHYS_Karma);

	FRotator rot;
	FVector newPos, moveBy;
	FCheckResult Hit(1.0f);

	dWorldID world = (dWorldID)this->GetLevel()->KWorld;
	dBodyID model = (dBodyID)this->KParams->KarmaData;


	// Handle any updates to the rigid body state from script.
	// Note: Because actors are always ticked before constraints, we can be sure the constraint will
	// get the most up-to-date state.
	FKRigidBodyState newState;
	eventKUpdateState(newState);

	const dReal * CPos = dBodyGetPosition(model);
	const dReal * CRot = dBodyGetRotation(model); // 0,2, 3?, 5, 7?,8 10, 11; // 0 5 10
	
	//const dReal* CRot = dGeomGetRotation(cylgeom);

	//newState.AngVel.X = CPos[0];
	//newState.AngVel.Y = CPos[1];
	//newState.AngVel.Z = CPos[0];
	//this->Velocity = FVector(CPos[0], CPos[1], CPos[2]);
	//this->Location = FVector(CPos[0], CPos[1], CPos[2]);
	//this->Rotation = FRotator(2000, 222, 2);
	//this->UpdateRenderData(); //no need this
	ULevel* level = GetLevel();
	//level->MoveActor(this, {static_cast<float>(CPos[0]), static_cast<float>(CPos[1]), static_cast<float>(CPos[2])} , FRotator(0, 0, 0), Hit); //PostKarmaStep() //5 //6 //9
	this->Location = { static_cast<float>(CPos[0]), static_cast<float>(CPos[1]), static_cast<float>(CPos[2]) };
	this->Rotation = { static_cast<INT>(CRot[2] * -10430.2192), static_cast<INT>(CRot[4] * 10430.2192), static_cast<INT>(CRot[6] * 10430.2192) };// 65536 / 2pi const MeReal K_Rad2U = (MeReal)10430.2192; const MeReal K_U2Rad = (MeReal)0.000095875262;
	this->ClearRenderData();
	unclock(GStats.DWORDStats(GEngineStats.STATS_Karma_physKarma));
	unguard;
}

/*
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
*/
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

UBOOL KShouldStopKarma(AActor* actor) //639
{
	guard(KShouldStopKarma);

	check(actor);

	if (actor->IsA(ATerrainInfo::StaticClass()) || actor->IsA(ALevelInfo::StaticClass()))
		return true;

	if (!actor->bBlockKarma)
		return false;

	// Do safetime against blocking volumes (but not if class specific blocker - it depends on the class type).
	ABlockingVolume* BV = Cast<ABlockingVolume>(actor);
	if (BV && !BV->bClassBlocker)
		return true;

	UPrimitive* prim = actor->GetPrimitive();
	if (!prim)
		return false;

	UStaticMesh* statMesh = NULL;
	USkeletalMesh* skelMesh = NULL;
	if ((statMesh = Cast<UStaticMesh>(prim)) != NULL)
	{
		if (!statMesh->UseSimpleKarmaCollision)
			return true; // Karma collision with graphics triangles

		if (statMesh->UseSimpleKarmaCollision && statMesh->KPhysicsProps)
			return true; // Karma collision with collision model.
	}
	else if ((skelMesh = Cast<USkeletalMesh>(prim)) != NULL)
	{
		if (skelMesh->KPhysicsProps)
			return true;
	}

	return false;

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