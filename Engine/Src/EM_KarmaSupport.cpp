/*============================================================================
	Karma Integration Support
    
    - PerContact/PerPair Callbacks
    - Game/Level/Actor/Constraint Init/Term
============================================================================*/

#ifdef WITH_PHYS_WRAP
#include "ode/ode.h"
#endif

#include "EnginePrivate.h"

#ifdef WITH_PHYS_WRAP

/// ************ Some constants ************ ///

/// *********** Internal structs *********** ///

typedef struct _LevelPhysicsTriData
{
	TArray<dReal>		triangles;
	TArray<dTriIndex>	indices;
	dTriMeshDataID		TriMeshID;
	dGeomID				TriMeshGeomID;
} LevelPhysicsTriData;

TArray<LevelPhysicsTriData *> LevelBSPCollision;

/// ********** Internal functions ********** ///
/*
static void PWAddBSPTriangles(UModel* model, LevelPhysicsTriData* triData)
{
	for (int i = 0; i < model->Points.Num(); i++) {
		//FVector temp_vector = ((FVector*)model->Points.GetData())[i];
		FVector temp_vector = model->Points(i);
		triData->triangles.AddItem((dReal)temp_vector[0]);
		triData->triangles.AddItem((dReal)temp_vector[1]);
		triData->triangles.AddItem((dReal)temp_vector[2]);
	}

	for (int i = 0; i < model->Nodes.Num(); i++) {
		FBspSurf* Surf = &model->Surfs(model->Nodes(i).iSurf);
		if (!(Surf->PolyFlags & PF_NotSolid)) {

			for (int k = 0; k < model->Nodes(i).NumVertices-2; k++) // !(Surf->PolyFlags & PF_NotSolid) // If there are any triangles to add.
			{
				triData->indices.AddItem(model->Verts(model->Nodes(i).iVertPool + k).pVertex);
				triData->indices.AddItem(model->Verts(model->Nodes(i).iVertPool + k + 1).pVertex);
				triData->indices.AddItem(model->Verts(model->Nodes(i).iVertPool + k + 2).pVertex);
			}
		}
	}
}
*/
static void PWAddBSPTrianglesPerSurf(UModel* model, LevelPhysicsTriData* triData) //CURRENT
{
	for (int i = 0; i < model->Points.Num(); i++) {
		//FVector temp_vector = ((FVector*)model->Points.GetData())[i];
		FVector temp_vector = model->Points(i);
		triData->triangles.AddItem((dReal)temp_vector[0]);
		triData->triangles.AddItem((dReal)temp_vector[1]);
		triData->triangles.AddItem((dReal)temp_vector[2]);
	}

	for (int i = 0; i < model->Surfs.Num(); i++) {
		FBspSurf* Surf = &model->Surfs(i);
		if (!(Surf->PolyFlags & PF_NotSolid)) {
			// Add Indices

			for (int k = 0; k < model->Surfs(i).Nodes.Num(); k++) // !(Surf->PolyFlags & PF_NotSolid) // If there are any triangles to add.
			{
				FBspNode * TempNode = &model->Nodes(model->Surfs(i).Nodes(k));
				int firstVertexIndex = model->Verts(TempNode->iVertPool).pVertex;
				for (int j = 0; j < TempNode->NumVertices - 2; j++) // !(Surf->PolyFlags & PF_NotSolid) // If there are any triangles to add.
				{
					triData->indices.AddItem(firstVertexIndex);
					triData->indices.AddItem(model->Verts(TempNode->iVertPool + j + 1).pVertex);
					triData->indices.AddItem(model->Verts(TempNode->iVertPool + j + 2).pVertex);
				}
			}
		}
	}
}

static void nearCallback(void* level_ptr, dGeomID o1, dGeomID o2)
{
	ULevel* level = (ULevel*)level_ptr;

	if (dGeomIsSpace(o1) || dGeomIsSpace(o2))
	{
		fprintf(stderr, "testing space %p %p\n", (void*)o1, (void*)o2);
		// colliding a space with something
		dSpaceCollide2(o1, o2, level_ptr, &nearCallback);
		// Note we do not want to test intersections within a space,
		// only between spaces.
		return;
	}

	//  fprintf(stderr,"testing geoms %p %p\n", o1, o2);

	const int N = 32;
	dContact contact[N];
	int n = dCollide(o1, o2, N, &(contact[0].geom), sizeof(dContact));
	if (n > 0)
	{
		for (int i = 0; i < n; i++)
		{
			contact[i].surface.slip1 = 0.7;
			contact[i].surface.slip2 = 0.7;
			contact[i].surface.mode = dContactBounce | dContactSoftCFM; //dContactSoftERP | dContactSoftCFM | dContactApprox1 | dContactSlip1 | dContactSlip2;
			contact[i].surface.mu = dInfinity; // was: dInfinity
			contact[i].surface.soft_erp = 0.8;
			contact[i].surface.soft_cfm = 0.0000001;
			contact[i].surface.bounce = 0.000001;
			dJointID c = dJointCreateContact((dWorldID)level->KWorld, (dJointGroupID)level->PWContactGroup, &contact[i]);
			dJointAttach(c,
				dGeomGetBody(contact[i].geom.g1),
				dGeomGetBody(contact[i].geom.g2));
		}
	}
}

void KInitGameKarma() // (1)
{
    guard(KInitGameKarma);

	dInitODE2(0);
	dAllocateODEDataForThread(dAllocateMaskAll);

    unguard;
}

void ENGINE_API KTermGameKarma()
{
	guard(KTermGameKarma);

	dCloseODE();

	unguard;
}


void KInitLevelKarma(ULevel* level)
{
    guard(KInitLevelKarma);
    
	level->PWData = new LevelPhysicsTriData;
	float gx = 0.0;
	float gy = 0;
	float gz = -9.81;
	level->KWorld = (void *)dWorldCreate();
	dWorldSetGravity( (dWorldID)level->KWorld, gx, gy, gz); //relocate // x, y, z
	dWorldSetQuickStepNumIterations((dWorldID)level->KWorld, 512); // <-- increase for more stability
	//dWorldSetAutoDisableFlag((dWorldID)level->KWorld, 0);
	//dWorldSetAutoDisableAverageSamplesCount((dWorldID)level->KWorld, 0);
	dReal CFM = 1e-10;
	dWorldSetCFM((dWorldID)level->KWorld, CFM);
	//level->ODE_SpaceID = dSimpleSpaceCreate(0); // Space
	level->ODE_SpaceID = dHashSpaceCreate(0);
	level->PWContactGroup = (dJointGroupID)dJointGroupCreate(0); // Contact group
	
	PWAddBSPTrianglesPerSurf(level->Model, (LevelPhysicsTriData*)level->PWData);
	LevelPhysicsTriData* DebugTriDar = (LevelPhysicsTriData*)level->PWData;
	((LevelPhysicsTriData*)level->PWData)->TriMeshID = dGeomTriMeshDataCreate();
	dGeomTriMeshDataBuildDouble(((LevelPhysicsTriData*)level->PWData)->TriMeshID,
		((LevelPhysicsTriData*)level->PWData)->triangles.GetData(), 3 * sizeof(dReal), ((LevelPhysicsTriData*)level->PWData)->triangles.Num() / 3, // Verticles: Data, ?Step?, Count
		((LevelPhysicsTriData*)level->PWData)->indices.GetData(), ((LevelPhysicsTriData*)level->PWData)->indices.Num(), 3 * sizeof(dTriIndex));
	dGeomTriMeshDataPreprocess2(((LevelPhysicsTriData*)level->PWData)->TriMeshID, (1U << dTRIDATAPREPROCESS_BUILD__MAX), NULL);
	((LevelPhysicsTriData*)level->PWData)->TriMeshGeomID = dCreateTriMesh((dSpaceID)level->ODE_SpaceID, ((LevelPhysicsTriData*)level->PWData)->TriMeshID, 0, 0, 0);
	dGeomSetPosition(((LevelPhysicsTriData*)level->PWData)->TriMeshGeomID, 0, 0, 0);

    unguard;
}

void KTermLevelKarma(ULevel* level) // Warning : At the game exit functions KTermGameKarma and KTermLevelKarma called in reverse order
{
	//dGeomDestroy(((LevelPhysicsTriData*)level->PWData)->TriMeshGeomID);
	dJointGroupEmpty((dJointGroupID)level->PWContactGroup);
	dJointGroupDestroy((dJointGroupID)level->PWContactGroup);
	dSpaceDestroy((dSpaceID)level->ODE_SpaceID);
	dWorldDestroy((dWorldID)level->KWorld);
	delete (LevelPhysicsTriData *)level->PWData;

	for (int i = 0; i < LevelBSPCollision.Num(); i++) {
		delete (LevelBSPCollision(i));
		LevelBSPCollision.Remove(i, 1);
	}

}

void KTickLevelKarma(ULevel* level, FLOAT DeltaSeconds)
{
	guard(KTickLevelKarma);

	if (!level->KWorld)
		return;
	dSpaceCollide((dSpaceID)level->ODE_SpaceID, level, &nearCallback); // Pass the level data to callbac function
	dWorldStep((dWorldID)level->KWorld, static_cast<dReal>(DeltaSeconds)); //DeltaSeconds
	//dWorldQuickStep((dWorldID)level->KWorld, 0.01);
	dJointGroupEmpty((dJointGroupID)level->PWContactGroup);
	unguard;
}

void KInitActorKarma(AActor* actor) //1161
{
    guard(KInitActorKarma);

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

		//KInitActorCollision(actor, 0);
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
    unguard;
}

void KInitActorCollision(AActor* actor, UBOOL makeNull) {}
void KTermActorCollision(AActor* actor) {}

void KInitActorDynamics(AActor* actor) 
{
	guard(KInitActorDynamics);

	if (actor->bDeleteMe)
		return;

	ULevel* level = actor->GetLevel();
	if (GIsEditor || /*!KGData->Framework || */ !level || actor->bDeleteMe)
		return;

	if (actor->bStatic)
		debugf(TEXT("(Karma): KInitActorDynamics: bStatic is true."));

	//RTN_WITH_ERR_IF(!actor->KParams, "(Karma): KInitActorDynamics: No KParams.");

	actor->KParams->KarmaData = (PTRINT)dBodyCreate((dWorldID)level->KWorld);
	
	dGeomID gid = dCreateBox((dSpaceID)level->ODE_SpaceID, 128, 128, 128);
	dGeomSetBody(gid, (dBodyID)actor->KParams->KarmaData);
	// Set start position
	dBodySetPosition((dBodyID)actor->KParams->KarmaData, static_cast<dReal>(actor->Location[0]), static_cast<dReal>(actor->Location[1]), static_cast<dReal>(actor->Location[2]));
	// Set rotation
	//dBodySetRotation
	dMass box_mass;
	dMassSetBox(&box_mass, 1, 1, 1, 1);
	dBodySetMass((dBodyID)actor->KParams->KarmaData, &box_mass);

	unguard;
}
void KTermActorDynamics(AActor* actor) {
}

#endif // WITH_PHYS_WRAP
