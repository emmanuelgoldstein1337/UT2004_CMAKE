/*============================================================================
	Karma Integration Support
    
    - PerContact/PerPair Callbacks
    - Game/Level/Actor/Constraint Init/Term
============================================================================*/

#ifdef WITH_PHYS_WRAP

#include "EM_ODE.h"

static bool bODE_InitHasCallled;

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

static void PWAddStaticMeshTriangles(ULevel* level, int vertex_offset, int index_offset)
{
	/*
	int smc = 0;
	int nsmc = 0;
	for (int i = 0; i < level->Actors.Num(); i++)
	{
		if (level->Actors(i)->DrawType == DT_StaticMesh) {
			smc++;
		}
		else {
			nsmc++;
		}
	}

	for (int i = 0; i < level->StaticMeshBatches.Num(); i++) {
		void * VertexData;
		void * IndexData;
		int VertexSize = level->StaticMeshBatches(i).Vertices.GetSize();
		int IndexSize = level->StaticMeshBatches(i).Indices.GetSize();
		int IndexSize1 = level->StaticMeshBatches(i).Indices.GetIndexSize();
		level->StaticMeshBatches(i).Vertices.GetStreamData(VertexData);
		level->StaticMeshBatches(i).Indices.GetContents(IndexData);
	}
	*/
}
static void nearCallback_space(void* level_ptr, dGeomID o1, dGeomID o2)
{
	ULevel* level = (ULevel*)level_ptr;
	ODE_World* world = (ODE_World*)level->KWorld;

	const int N = 32;
	dContact contact[N];
	int n = dCollide(o1, o2, N, &(contact[0].geom), sizeof(dContact));
	if (n > 0)
	{
		for (int i = 0; i < n; i++)
		{
			contact[i].surface.slip1 = 0.7;
			contact[i].surface.slip2 = 0.7;
			contact[i].surface.mode = dContactBounce | dContactSoftCFM | dContactSoftERP | dContactApprox1 | dContactSlip1 | dContactSlip2; //dContactSoftERP | dContactSoftCFM | dContactApprox1 | dContactSlip1 | dContactSlip2;
			contact[i].surface.mu = 0.1; // was: dInfinity
			contact[i].surface.soft_erp = 1e-10;
			contact[i].surface.soft_cfm = 1e-10;
			contact[i].surface.bounce = 0.000001;
			dJointID c = dJointCreateContact(world->id, world->contact_group, &contact[i]);
			dJointAttach(c,
				dGeomGetBody(contact[i].geom.g1),
				dGeomGetBody(contact[i].geom.g2));
		}
	}
}

static void nearCallback(void* level_ptr, dGeomID o1, dGeomID o2)
{
	ULevel* level = (ULevel*)level_ptr;
	ODE_World* world = (ODE_World*)level->KWorld;

	if(dGeomGetBody)
	if (dGeomIsSpace(o1) || dGeomIsSpace(o2))
	{
		fprintf(stderr, "testing space %p %p\n", (void*)o1, (void*)o2);
		// colliding a space with something
		dSpaceCollide2(o1, o2, level_ptr, &nearCallback_space);
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
			contact[i].surface.mode = dContactBounce | dContactSoftCFM | dContactSoftERP | dContactApprox1 | dContactSlip1 | dContactSlip2; //dContactSoftERP | dContactSoftCFM | dContactApprox1 | dContactSlip1 | dContactSlip2;
			contact[i].surface.mu = 0.1; // was: dInfinity
			contact[i].surface.soft_erp = 1e-10;
			contact[i].surface.soft_cfm = 1e-10;
			contact[i].surface.bounce = 0.000001;
			dJointID c = dJointCreateContact(world->id, world->contact_group, &contact[i]);
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
		bODE_InitHasCallled = true;
		dAllocateODEDataForThread(dAllocateMaskAll);
    unguard;
}

void ENGINE_API KTermGameKarma()
{
	guard(KTermGameKarma);
		dCloseODE();
		bODE_InitHasCallled = false;
	unguard;
}


void KInitLevelKarma(ULevel* level)
{
    guard(KInitLevelKarma);

	float gx = 0.0;
	float gy = 0;
	float gz = -950;

	level->KWorld = new ODE_World;
	ODE_World* world = (ODE_World *)level->KWorld;

	level->PWData = new LevelPhysicsTriData;
	world->id = dWorldCreate();
	dWorldSetGravity(world->id, gx, gy, gz); //relocate // x, y, z
	dWorldSetQuickStepNumIterations(world->id, 512); // <-- increase for more stability
	//dWorldSetAutoDisableFlag((dWorldID)level->KWorld, 0);
	//dWorldSetAutoDisableAverageSamplesCount((dWorldID)level->KWorld, 0);
	dReal CFM = 0.8;// 1e-10;
	dWorldSetCFM(world->id, CFM);
	world->space = dHashSpaceCreate(0);
	world->BSP_Space = dHashSpaceCreate(world->space);
	world->SM_Space = dHashSpaceCreate(world->space);
	dHashSpaceSetLevels(world->space, -2, 4096);
	dHashSpaceSetLevels(world->BSP_Space, -2, 4096);
	dHashSpaceSetLevels(world->SM_Space, -2, 4096);
	world->contact_group = dJointGroupCreate(0); // Contact group
	
	// Now we add static level collision into arrays
	PWAddBSPTrianglesPerSurf(level->Model, (LevelPhysicsTriData*)level->PWData);
	PWAddStaticMeshTriangles(level, ((LevelPhysicsTriData*)level->PWData)->triangles.Num(), ((LevelPhysicsTriData*)level->PWData)->indices.Num());
	LevelPhysicsTriData* DebugTriDar = (LevelPhysicsTriData*)level->PWData;
	((LevelPhysicsTriData*)level->PWData)->TriMeshID = dGeomTriMeshDataCreate();
	dGeomTriMeshDataBuildDouble(((LevelPhysicsTriData*)level->PWData)->TriMeshID,
		((LevelPhysicsTriData*)level->PWData)->triangles.GetData(), 3 * sizeof(dReal), ((LevelPhysicsTriData*)level->PWData)->triangles.Num() / 3, // Verticles: Data, ?Step?, Count
		((LevelPhysicsTriData*)level->PWData)->indices.GetData(), ((LevelPhysicsTriData*)level->PWData)->indices.Num(), 3 * sizeof(dTriIndex));
	dGeomTriMeshDataPreprocess2(((LevelPhysicsTriData*)level->PWData)->TriMeshID, (1U << dTRIDATAPREPROCESS_BUILD_FACE_ANGLES), NULL);
	((LevelPhysicsTriData*)level->PWData)->TriMeshGeomID = dCreateTriMesh(world->BSP_Space, ((LevelPhysicsTriData*)level->PWData)->TriMeshID, 0, 0, 0);
	dGeomSetPosition(((LevelPhysicsTriData*)level->PWData)->TriMeshGeomID, 0, 0, 0);
	dSpaceSetSublevel(world->BSP_Space, 1);
	dSpaceSetSublevel(world->space, 1);
    unguard;
}

void KTermLevelKarma(ULevel* level) // Warning : At the game exit functions KTermGameKarma and KTermLevelKarma called in reverse order
{
	if (!bODE_InitHasCallled) { return; } //do nothing if game exit;

	ODE_World* world = (ODE_World*)level->KWorld;
	//dGeomDestroy(((LevelPhysicsTriData*)level->PWData)->TriMeshGeomID);
	dJointGroupEmpty(world->contact_group);
	dJointGroupDestroy(world->contact_group);
	dSpaceDestroy(world->space);
	dWorldDestroy(world->id);
	
	delete world;
}

void KTickLevelKarma(ULevel* level, FLOAT DeltaSeconds)
{
	guard(KTickLevelKarma);

	if (!level->KWorld)
		return;

	ODE_World* world = (ODE_World*)level->KWorld;

	dSpaceCollide(world->space, level, &nearCallback); // Pass the level data to callbac function
	//dSpaceCollide(world->BSP_Space, level, &nearCallback);

	//dWorldStep(world->id, static_cast<dReal>(DeltaSeconds)); //DeltaSeconds
	dWorldQuickStep(world->id, 0.01);
	dJointGroupEmpty(world->contact_group);
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
    unguard;
}

void KInitActorCollision(AActor* actor, UBOOL makeNull)
{
//FVector scale3D = actor->DrawScale * actor->DrawScale3D;
	if (actor->StaticMesh == NULL) { return; }

	ULevel* level = actor->GetLevel();
	ODE_World* world = (ODE_World*)level->KWorld;

	actor->KParams->KarmaData = (PTRINT) new ODE_PhysData; ///TODO: DONT FORGET TO FREE IT
	ODE_PhysData* PhysData = (ODE_PhysData*)actor->KParams->KarmaData;

	// Add triangles
	for (int i = 0; i < actor->StaticMesh->VertexStream.Vertices.Num(); i++) {
		PhysData->triangles.AddItem((dReal)(actor->StaticMesh->VertexStream.Vertices(i).Position.X));
		PhysData->triangles.AddItem((dReal)(actor->StaticMesh->VertexStream.Vertices(i).Position.Y));
		PhysData->triangles.AddItem((dReal)(actor->StaticMesh->VertexStream.Vertices(i).Position.Z));
	}
	// Add indices
	for (int i = 0; i < actor->StaticMesh->IndexBuffer.Indices.Num(); i += 3) {
		PhysData->indices.AddItem((dTriIndex)actor->StaticMesh->IndexBuffer.Indices(i));
		PhysData->indices.AddItem((dTriIndex)actor->StaticMesh->IndexBuffer.Indices(i + 2));
		PhysData->indices.AddItem((dTriIndex)actor->StaticMesh->IndexBuffer.Indices(i + 1));
	}

	PhysData->TriMeshID = dGeomTriMeshDataCreate();
	dGeomTriMeshDataBuildDouble(PhysData->TriMeshID, PhysData->triangles.GetData(), 3 * sizeof(dReal), PhysData->triangles.Num() / 3, PhysData->indices.GetData(), PhysData->indices.Num(), 3 * sizeof(dTriIndex));
	//dGeomTriMeshDataPreprocess2(PhysData->TriMeshID, (1U << dTRIDATAPREPROCESS_BUILD__MIN), NULL);
	PhysData->geometry = dCreateTriMesh(world->SM_Space, PhysData->TriMeshID, 0, 0, 0);

	//Set position of the geom
	dGeomSetPosition(PhysData->geometry, static_cast<dReal>(actor->Location[0]), static_cast<dReal>(actor->Location[1]), static_cast<dReal>(actor->Location[2]));
	//Set rotation for the geom
	dMatrix3 rotMatrix;
	dRFromEulerAngles(rotMatrix, static_cast<dReal>(actor->Rotation.Roll * K_U2Rad), static_cast<dReal>(actor->Rotation.Pitch * K_U2Rad), static_cast<dReal>(actor->Rotation.Yaw * K_U2Rad));
	dGeomSetRotation(PhysData->geometry, rotMatrix);
}
void KTermActorCollision(AActor* actor) {

}

void KInitActorDynamics(AActor* actor) 
{
	guard(KInitActorDynamics);

	if (actor->bDeleteMe)
		return;

	ULevel* level = actor->GetLevel();
	ODE_World* world = (ODE_World*)level->KWorld;
	ODE_PhysData* PhysData = (ODE_PhysData*)actor->KParams->KarmaData;

	if (GIsEditor || !level || actor->bDeleteMe)
		return;

	if (actor->bStatic)
		debugf(TEXT("(ODE): KInitActorDynamics: bStatic is true."));

	
	PhysData->id = dBodyCreate(world->id);
	dGeomSetBody(PhysData->geometry, PhysData->id);


	// Set start position
	dBodySetPosition(PhysData->id, static_cast<dReal>(actor->Location[0]), static_cast<dReal>(actor->Location[1]), static_cast<dReal>(actor->Location[2]));
	// Set rotation
	dMatrix3 rotMatrix;
	dRFromEulerAngles(rotMatrix, static_cast<dReal>(actor->Rotation.Roll * K_U2Rad), static_cast<dReal>(actor->Rotation.Pitch * K_U2Rad), static_cast<dReal>(actor->Rotation.Yaw * K_U2Rad));
	dBodySetRotation(PhysData->id, rotMatrix);

	dMassSetBox(&PhysData->mass, 1, 128, 128, 128);
	dBodySetMass(PhysData->id, &PhysData->mass);
	dSpaceRemove(world->SM_Space, PhysData->geometry); //Remove from StaticMesh space
	dSpaceAdd(world->space, PhysData->geometry); // And put it into dynamic space
	unguard;
}
void KTermActorDynamics(AActor* actor) {
}

#endif // WITH_PHYS_WRAP
