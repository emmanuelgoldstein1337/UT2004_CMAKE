#include "EM_PhysX.h"

#ifdef WITH_PHYS_WRAP

void AActor::KWake() {}

void AActor::preKarmaStep(FLOAT DeltaTime) {} //559


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

	return (void *)KParams->KarmaData;
}

void AActor::physKarma(FLOAT deltaTime)
{
	guard(AActor::physKarma);
	clock(GStats.DWORDStats(GEngineStats.STATS_Karma_physKarma));

	check(Physics == PHYS_Karma);

	PhysData* model = (PhysData*)this->getKModel();

	if (!model) {
		return; 
	}

	physx::PxTransform transform = model->body->is<physx::PxRigidActor>()->getGlobalPose();
	physx::PxVec3 location = transform.p;

	//Rotation
	physx::PxMat44 tm = physx::PxMat44(transform.getNormalized());
	FCoords cords = FCoords(
		FVector(tm[3][0], tm[3][1], tm[3][2]),
		FVector(tm[0][0], tm[0][1], tm[0][2]),
		FVector(tm[1][0], tm[1][1], tm[1][2]),
		FVector(tm[2][0], tm[2][1], tm[2][2]));
	Rotation = cords.OrthoRotation();

	ULevel* level = GetLevel();
	
	level->FarMoveActor(this, { (FLOAT)location.x, (FLOAT)location.y, (FLOAT)location.z });
	/*
	

	dWorldID world = ((ODE_World*)this->GetLevel()->KWorld)->id;
	if (!world)
	{
		debugf(TEXT("(Karma:) AActor::physKarma: No ODE World found."));
		return;
	}

	dBodyID model = ((ODE_PhysData*)KParams->KarmaData)->id;
	if (!model)
		return;

	preKarmaStep(deltaTime);// !!!! BUG ALERT: ORIGINALY THIS CALLED NOT FROM HERE !!!!

	// Handle any updates to the rigid body state from script.
	// Note: Because actors are always ticked before constraints, we can be sure the constraint will
	// get the most up-to-date state.
	FKRigidBodyState newState;
	eventKUpdateState(newState);

	
	const dReal * CPos = dBodyGetPosition(model);
	const dReal * CRot = dBodyGetRotation(model); // 0,2, 3?, 5, 7?,8 10, 11; // 0 5 10

	this->Rotation = RotatorFromMatrix(CRot);
	

	unclock(GStats.DWORDStats(GEngineStats.STATS_Karma_physKarma));
	*/
	unguard;
}

/*
void UKarmaParamsCollision::CalcContactRegion()
{
	return;
}
*/
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