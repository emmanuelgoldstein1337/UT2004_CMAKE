/*============================================================================
	Karma Integration Support
    
    - PerContact/PerPair Callbacks
    - Game/Level/Actor/Constraint Init/Term
============================================================================*/

#ifdef WITH_PHYS_WRAP

#include "EM_PhysX.h"

/// ************* Some globals ************* ///

physx::PxDefaultAllocator	Allocator;
physx::PxDefaultErrorCallback	ErrorCallback;
physx::PxFoundation* Foundation = NULL;
physx::PxPhysics* Physics;
physx::PxDefaultCpuDispatcher* Dispatcher = NULL;
physx::PxSceneDesc* SceneDesc;
physx::PxPvd* Pvd = NULL; // PhysX Visual Debugger
physx::PxPvdTransport* transport; // Debugger transport
physx::PxTolerancesScale TolerancesScale;

static bool bODE_InitHasCallled;

void KInitGameKarma() // (1)
{
    guard(KInitGameKarma);
		
		// PhysX
		Foundation = PxCreateFoundation(PX_PHYSICS_VERSION, Allocator, ErrorCallback);
		
		// Debugging
		Pvd = physx::PxCreatePvd(*Foundation);
		transport = physx::PxDefaultPvdSocketTransportCreate("localhost", 5425, 10);
		Pvd->connect(*transport, physx::PxPvdInstrumentationFlag::eALL);

		// Unit scale
		TolerancesScale.length = K_ME2UScale;
		TolerancesScale.speed = 1;

		// Create physics
		Physics = PxCreatePhysics(PX_PHYSICS_VERSION, *Foundation, TolerancesScale, true, Pvd);

		// Scene
		SceneDesc = new physx::PxSceneDesc(Physics->getTolerancesScale());
		SceneDesc->gravity = physx::PxVec3(0.0f, 0.0f, -9.5f);

		// Dispatcher
		Dispatcher = physx::PxDefaultCpuDispatcherCreate(2);
		SceneDesc->cpuDispatcher = Dispatcher;
		SceneDesc->filterShader = physx::PxDefaultSimulationFilterShader;
    unguard;
}

void ENGINE_API KTermGameKarma()
{
	guard(KTermGameKarma);

		bODE_InitHasCallled = false;

		//Debugger
		//physx::PxPvdTransport* transport = Pvd->getTransport();
		//Pvd->release();
		//transport->release();

	unguard;
}


void KInitLevelKarma(ULevel* level)
{
    guard(KInitLevelKarma);

	level->KWorld = new PhysX_World;
	PhysX_World* world = (PhysX_World*)level->KWorld;
	
	world->Scene = Physics->createScene(*SceneDesc);

	physx::PxPvdSceneClient* PvdClient = world->Scene->getScenePvdClient();
	if (PvdClient)
	{
		PvdClient->setScenePvdFlag(physx::PxPvdSceneFlag::eTRANSMIT_CONSTRAINTS, true);
		PvdClient->setScenePvdFlag(physx::PxPvdSceneFlag::eTRANSMIT_CONTACTS, true);
		PvdClient->setScenePvdFlag(physx::PxPvdSceneFlag::eTRANSMIT_SCENEQUERIES, true);
	}

	// create simulation
	//physx::PxMaterial * Material = Physics->createMaterial(0.5f, 0.5f, 0.6f);
	//physx::PxRigidStatic* groundPlane = PxCreatePlane(*Physics, physx::PxPlane(0, 1, 0, 50), *Material);
	//world->Scene->addActor(*groundPlane);
	
	//physx::PxRigidStatic* sphere = physx::PxCreateStatic(*Physics, physx::PxTransform(physx::PxVec3(0, 0, 0)), physx::PxSphereGeometry(128), *Material);
	//physx::PxRigidDynamic* sphere = physx::PxCreateDynamic(*Physics, physx::PxTransform(physx::PxVec3(0, 0, 0)), physx::PxSphereGeometry(128), *Material, 1);
	//world->Scene->addActor(*sphere);

	// Now we add static level collision into arrays
	PWAddBSPTrianglesPerSurf(level->Model, &world->BSP_Data);
	//PWAddTerrainHeightmap(level, world);

	// Add Level BSP Geometry to PhysX
	physx::PxMaterial* Material = Physics->createMaterial(0.5f, 0.5f, 0.1f); // REMOVE THIS
	physx::PxRigidStatic* meshActor = physx::PxCreateStatic(*Physics, physx::PxTransform(physx::PxVec3(0, 0, 0)), physx::PxTriangleMeshGeometry(PWTrimeshFromTriData(&world->BSP_Data)), *Material);
	world->Scene->addActor(*meshActor);

    unguard;
}

void KTermLevelKarma(ULevel* level) // Warning : At the game exit functions KTermGameKarma and KTermLevelKarma called in reverse order
{
	if (!bODE_InitHasCallled) { return; } //do nothing if game exit;
	
	//transport->disconnect();

	PhysX_World* world = (PhysX_World*)level->KWorld;

	world->Scene->release();
	world->Scene = NULL;

	delete(level->KWorld);
	level->KWorld = NULL;



	/*
	ODE_World* world = (ODE_World*)level->KWorld;
	//dGeomDestroy(((LevelPhysicsTriData*)level->PWData)->TriMeshGeomID);
	dJointGroupEmpty(world->contact_group);
	dJointGroupDestroy(world->contact_group);
	dSpaceDestroy(world->KA_Space); //TODO: Destroy another spaces
	dWorldDestroy(world->id);	
	delete(world);
	level->KWorld = NULL;
	*/
}

void KTickLevelKarma(ULevel* level, FLOAT DeltaSeconds)
{
	guard(KTickLevelKarma);
	
	if (!level->KWorld)
		return;

	PhysX_World * world = (PhysX_World*)level->KWorld;

	world->Scene->simulate(1.0f / 60.0f);
	world->Scene->fetchResults(true);

	/*
	dSpaceCollide(world->KA_Space, level, &nearCallback); // Pass the level data to callbac function
	//dSpaceCollide(world->BSP_Space, level, &nearCallback);

	dWorldStep(world->id, static_cast<dReal>(0.01)); //DeltaSeconds
	//dWorldQuickStep(world->id, 0.01);
	dJointGroupEmpty(world->contact_group);
	*/
	unguard;
}

void KInitActorKarma(AActor* actor) //1161
{
    guard(KInitActorKarma);

	if (actor->StaticMesh == NULL && actor->Mesh == NULL) { return; } //TODO: REMOVE THIS LINE

	ULevel* level = actor->GetLevel();

	if (!level || GIsEditor || actor->bDeleteMe)
		return;

	if (!level || GIsEditor || /*!KGData->Framework ||*/ actor->bDeleteMe)
		return;

	actor->bShouldStopKarma = KShouldStopKarma(actor); // Cache this for speed.

	/* *** SKELETAL *** */
	// Try and initialise rag-doll physics (must have a SkeletalMeshInstance)
	// Doesn't actually matter if we fail here - thi is tried again at the start of physKarmaRagDoll.
	if (actor->Physics == PHYS_KarmaRagDoll)
	{
		if (actor->Mesh == NULL || !actor->Mesh->IsA(USkeletalMesh::StaticClass()))
			return;

		USkeletalMesh* skelMesh = Cast<USkeletalMesh>(actor->Mesh);
		USkeletalMeshInstance* inst = Cast<USkeletalMeshInstance>(skelMesh->MeshGetInstance(actor));

		//KInitSkeletonKarma(inst);

		return;
	}

	/* *** CONSTRAINT *** */
	// See if its a Constraint - and init.
	AKConstraint* conActor = Cast<AKConstraint>(actor);
	if (conActor)
	{
		// If neither constrained actor has been set, do nothing (do not change physics mode)
		// This is useful when spawning a constraint in game, as you can set it all up and _then_ call SetPhysics(PHYS_Karma)
		if (!conActor->KConstraintActor1 && !conActor->KConstraintActor2)
		{
			conActor->Physics = PHYS_None;
			return;
		}
		else
			//KInitConstraintKarma(conActor);

		return;
	}

	/* *** OTHER ACTOR *** */
	// If this actor is supposed to block Karma stuff - give it some kind of Karma collision geometry.
	if (actor->bBlockKarma)
	{
		// If this needs collision, but doesn't have a KarmaParamsCollision, create one here.
		// This will only allow you to turn Karma collision on (not dynamics),
		// but you would need to have given it a KarmaParams already anyway to do that.
		if (!actor->KParams)
		{
			actor->KParams = ConstructObject<UKarmaParamsCollision>(
				UKarmaParamsCollision::StaticClass(), actor->GetOuter());
		}

		KInitActorCollision(actor, 0);
	}

	if (actor->Physics == PHYS_Karma)
	{
		// If this is physics, but its not supposed to collide, we still need a model,
		// so create a 'null' one now.
		if (!actor->bBlockKarma)
		{
			if (!actor->KParams)
			{
				actor->KParams = ConstructObject<UKarmaParamsCollision>(
					UKarmaParamsCollision::StaticClass(), actor->GetOuter());
			}
			KInitActorCollision(actor, 1);
		}

		// Then initialise Karma dynamics.
		KInitActorDynamics(actor);
	}
    unguard;
}

/* Terminate all dynamics and collision for an Actor. */
void KTermActorKarma(AActor* actor) //1280
{
    guard(KTermActorKarma);

	/* *** OTHER ACTOR *** */
	if (actor->getKModel())
	{
		/* If there are dynamics on this actor - terminate them. */
		if (actor->getKModel())
			KTermActorDynamics(actor);

		KTermActorCollision(actor);
		return;
	}
    unguard;
}

void KInitActorCollision(AActor* actor, UBOOL makeNull) //KCreateActorGeometry
{

	actor->KParams->KarmaData = (PTRINT) new PhysData; ///TODO: DONT FORGET TO FREE IT
	PhysData* PhData = (PhysData*)actor->KParams->KarmaData;

	FVector scale3D = actor->DrawScale * actor->DrawScale3D;
	ULevel* level = actor->GetLevel();

	PhysX_World* world = (PhysX_World*)level->KWorld;

	// Static Mesh
	if (actor->StaticMesh) {
		// Add triangles
		for (int i = 0; i < actor->StaticMesh->VertexStream.Vertices.Num(); i++) {
			physx::PxVec3 temp_v;
			temp_v.x = actor->StaticMesh->VertexStream.Vertices(i).Position.X * scale3D.X;
			temp_v.y = actor->StaticMesh->VertexStream.Vertices(i).Position.Y * scale3D.Y;
			temp_v.z = actor->StaticMesh->VertexStream.Vertices(i).Position.Z * scale3D.Z;
			PhData->trimesh.triangles.AddItem(temp_v);
		}
		// Add indices
		for (int i = 0; i < actor->StaticMesh->IndexBuffer.Indices.Num(); i+=3) {
			PhData->trimesh.indices.AddItem((physx::PxU32)actor->StaticMesh->IndexBuffer.Indices(i));
			PhData->trimesh.indices.AddItem((physx::PxU32)actor->StaticMesh->IndexBuffer.Indices(i + 2));
			PhData->trimesh.indices.AddItem((physx::PxU32)actor->StaticMesh->IndexBuffer.Indices(i + 1));
		}

		//PhysData->TriMeshID = dGeomTriMeshDataCreate();
		//dGeomTriMeshDataBuildDouble(PhysData->TriMeshID, PhysData->triangles.GetData(), 3 * sizeof(dReal), PhysData->triangles.Num() / 3, PhysData->indices.GetData(), PhysData->indices.Num(), 3 * sizeof(dTriIndex));
		//dGeomTriMeshDataPreprocess2(PhysData->TriMeshID, (1U << dTRIDATAPREPROCESS_BUILD__MIN), NULL);
		//PhysData->geometry = dCreateTriMesh(world->SM_Space, PhysData->TriMeshID, 0, 0, 0);
	}
	
	// Skeletar Mesh
	if (actor->Mesh) {
		//PhysData->geometry = dCreateSphere(world->SM_Space, 128);
		USkeletalMesh* smesh = Cast<USkeletalMesh>(actor->Mesh);
		//PhysData->geometry = dCreateBox(world->SM_Space, (dReal)smesh->KPhysicsProps->AggGeom.BoxElems(0).X * K_ME2UScale,
			//(dReal)smesh->KPhysicsProps->AggGeom.BoxElems(0).Y * K_ME2UScale, (dReal)smesh->KPhysicsProps->AggGeom.BoxElems(0).Z * K_ME2UScale);
	}
	/*
	
	}


	//Set position of the geom
	dGeomSetPosition(PhysData->geometry, static_cast<dReal>(actor->Location[0]), static_cast<dReal>(actor->Location[1]), static_cast<dReal>(actor->Location[2]));
	//Set rotation for the geom
	dMatrix3 rotMatrix;
	dRFromEulerAngles(rotMatrix, static_cast<dReal>(actor->Rotation.Roll * K_U2Rad), static_cast<dReal>(actor->Rotation.Pitch * K_U2Rad), static_cast<dReal>(actor->Rotation.Yaw * K_U2Rad));
	dGeomSetRotation(PhysData->geometry, rotMatrix);
	*/
}
void KTermActorCollision(AActor* actor)
{
	guard(KTermActorCollision);
	/*
	if (!bODE_InitHasCallled) { return; } //maybe at exit we need this to avoid errors, maybe not.
	if (!actor->KParams->KarmaData) { return; }
	if (!actor->GetLevel()->KWorld) { return; }

	ODE_PhysData* PhysData = (ODE_PhysData*)actor->KParams->KarmaData;
	dGeomDestroy(PhysData->geometry);
	delete((ODE_PhysData*)actor->KParams->KarmaData);
	actor->KParams->KarmaData = NULL;
	*/
	unguard;
}

void KInitActorDynamics(AActor* actor) 
{
	guard(KInitActorDynamics);

	if (actor->bDeleteMe)
		return;

	ULevel* level = actor->GetLevel();
	UKMeshProps* MeshProps = 0;
	PhysData* PhData = (PhysData *)actor->KParams->KarmaData;
	PhysX_World* world = (PhysX_World*)level->KWorld;

	if (GIsEditor || !level || actor->bDeleteMe)
		return;

	if (actor->bStatic)
		debugf(TEXT("(PhysX): KInitActorDynamics: bStatic is true."));

	PhData->material = Physics->createMaterial(0.5f, 0.5f, 0.6f);
	PhData->body = physx::PxCreateDynamic(*Physics, physx::PxTransform(physx::PxVec3(actor->Location[0], actor->Location[1], actor->Location[2])), physx::PxConvexMeshGeometry(PWConvexFromTriData(&PhData->trimesh)), *PhData->material, 1.0);
	world->Scene->addActor(*PhData->body);

	//physx::PxRigid
	/*
	PhysData->id = dBodyCreate(world->id);
	dGeomSetBody(PhysData->geometry, PhysData->id);

	if (actor->StaticMesh && !actor->Mesh) {
		MeshProps = actor->StaticMesh->KPhysicsProps;
		
		dMassSetTrimesh(&PhysData->mass, 1, PhysData->geometry);
		PhysData->mass.c[0] = 0;
		PhysData->mass.c[1] = 0;
		PhysData->mass.c[2] = 0;
		//dMassTranslate(&PhysData->mass, 0, 0, 0);
		dBodySetMass(PhysData->id, &PhysData->mass);
	}
	if (actor->Mesh) {
		MeshProps = (Cast<USkeletalMesh>(actor->Mesh))->KPhysicsProps;
		dMassSetSphere(&PhysData->mass, 1, 128);
		dBodySetMass(PhysData->id, &PhysData->mass);
	}
	
	
	// Set start position
	dBodySetPosition(PhysData->id, static_cast<dReal>(actor->Location[0]), static_cast<dReal>(actor->Location[1]), static_cast<dReal>(actor->Location[2]));//static_cast<dReal>(actor->Location[0]), static_cast<dReal>(actor->Location[1]), static_cast<dReal>(actor->Location[2])
	// Set rotation
	dMatrix3 rotMatrix;
	dRFromEulerAngles(rotMatrix, static_cast<dReal>(actor->Rotation.Roll * K_U2Rad), static_cast<dReal>(actor->Rotation.Pitch * K_U2Rad), static_cast<dReal>(actor->Rotation.Yaw * K_U2Rad));
	dBodySetRotation(PhysData->id, rotMatrix);

	

	//dMassSetBox(&PhysData->mass, 1, 128, 128, 128);
	dSpaceRemove(world->SM_Space, PhysData->geometry); //Remove from StaticMesh space
	dSpaceAdd(world->KA_Space, PhysData->geometry); // And put it into dynamic space
	*/
	unguard;
}
void KTermActorDynamics(AActor* actor) {
	guard(KTermActorDynamics);
	/*
	if (!bODE_InitHasCallled) { return; } //maybe at exit we need this to avoid errors, maybe not.
	if (!actor->KParams->KarmaData) { return; }
	if (!actor->GetLevel()->KWorld) { return; }

	ODE_PhysData* PhysData = (ODE_PhysData*)actor->KParams->KarmaData;
	
	if (!PhysData->id) { return; }

	// Do any vehicle clean-up (removing wheel-contacts)
	ASVehicle* v = Cast<ASVehicle>(actor);
		if (v) { KTermSVehicleDynamics(v); }

	// I dont know, maybe actor must be removed from ODE space
	
	// all geoms that link to this body must be notified that the body is about	to disappear.
	dGeomSetBody(PhysData->geometry, 0);

	// Destroy body
	dBodyDestroy(PhysData->id);
	PhysData->id = NULL;
	*/
	unguard;
}

#endif // WITH_PHYS_WRAP
