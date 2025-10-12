#include "EM_PhysX.h"

void PWAddBSPTrianglesPerSurf(UModel* model, PhysicsTriData* triData)
{
	for (int i = 0; i < model->Points.Num(); i++) {
		physx::PxVec3 temp_v;
		temp_v.x = model->Points(i).X;
		temp_v.y = model->Points(i).Y;
		temp_v.z = model->Points(i).Z;
		triData->triangles.AddItem(temp_v);
	}

	for (int i = 0; i < model->Surfs.Num(); i++) {
		FBspSurf* Surf = &model->Surfs(i);
		if (!(Surf->PolyFlags & PF_NotSolid)) {
			// Add Indices

			for (int k = 0; k < model->Surfs(i).Nodes.Num(); k++) // !(Surf->PolyFlags & PF_NotSolid) // If there are any triangles to add.
			{
				FBspNode* TempNode = &model->Nodes(model->Surfs(i).Nodes(k));
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

void PWAddTerrainTriangles(ULevel* level)
{
	PhysX_World* world = (PhysX_World*)level->KWorld;

	for (INT z = 0; z < 64; z++)
	{
		AZoneInfo* Z = level->GetZoneActor(z);
		if (Z && Z->bTerrainZone)
		{
			for (INT t = 0; t < Z->Terrains.Num(); t++)
			{
				ATerrainInfo* tInfo = Z->Terrains(t);
				
				PhysicsTriData triData;

				for (int i = 0; i < tInfo->Vertices.Num(); i++)
				{
					physx::PxVec3 vertex;
					vertex.x = tInfo->Vertices(i).X;
					vertex.y = tInfo->Vertices(i).Y;
					vertex.z = tInfo->Vertices(i).Z;
					triData.triangles.AddItem(vertex);
				}

				int hy = tInfo->HeightmapY;
				int hx = tInfo->HeightmapX;
				for (int iy = 0; iy < hy - 1; iy++) {
					for (int ix = 0; ix < hx - 1; ix++)
					{
						triData.indices.AddItem(ix + iy * hy);
						triData.indices.AddItem(ix + iy * hy + 1);
						triData.indices.AddItem(ix + iy * hy + hy);
						triData.indices.AddItem(ix + iy * hy + hy);
						triData.indices.AddItem(ix + iy * hy + 1);
						triData.indices.AddItem(ix + iy * hy + hy + 1);
					}
				}

				physx::PxTriangleMesh* trimesh = PW_TerrainTrimeshFromTriData(&triData);
				physx::PxMaterial* TerrainMaterial = Physics->createMaterial(0.5f, 0.5f, 0.1f); // REMOVE THIS
				physx::PxRigidStatic* TerrainMesh = physx::PxCreateStatic(*Physics, physx::PxTransform(physx::PxVec3(0, 0, 0)), physx::PxTriangleMeshGeometry(trimesh), *TerrainMaterial);
				world->Scene->addActor(*TerrainMesh);
			}
		}
	}
}

// COOKING
physx::PxTriangleMesh* PWTrimeshFromTriData(PhysicsTriData* triData)
{
	physx::PxCookingParams params(TolerancesScale);
	params.midphaseDesc.setToDefault(physx::PxMeshMidPhase::eBVH34);
	params.meshPreprocessParams |= physx::PxMeshPreprocessingFlag::eDISABLE_ACTIVE_EDGES_PRECOMPUTE;
	params.meshPreprocessParams |= physx::PxMeshPreprocessingFlag::eDISABLE_CLEAN_MESH;
	
	physx::PxTriangleMeshDesc	desc;
	desc.points.count = triData->triangles.Num();
	desc.points.data = triData->triangles.GetData();
	desc.points.stride = sizeof(physx::PxVec3);
	desc.triangles.count = triData->indices.Num() / 3;
	desc.triangles.data = triData->indices.GetData();
	desc.triangles.stride = 3 * sizeof(physx::PxU32);
	return PxCreateTriangleMesh(params, desc);
}

physx::PxTriangleMesh* PW_TerrainTrimeshFromTriData(PhysicsTriData* triData)
{
	physx::PxCookingParams params(TolerancesScale);
	params.midphaseDesc.setToDefault(physx::PxMeshMidPhase::eBVH34);
	//params.meshPreprocessParams |= physx::PxMeshPreprocessingFlag::eENABLE_VERT_MAPPING;
	//params.meshPreprocessParams |= physx::PxMeshPreprocessingFlag::eWELD_VERTICES;
	//params.meshPreprocessParams |= physx::PxMeshPreprocessingFlag::eFORCE_32BIT_INDICES;
	params.meshPreprocessParams |= physx::PxMeshPreprocessingFlag::eDISABLE_ACTIVE_EDGES_PRECOMPUTE;
	params.meshPreprocessParams |= physx::PxMeshPreprocessingFlag::eDISABLE_CLEAN_MESH;

	physx::PxTriangleMeshDesc	desc;
	desc.points.count = triData->triangles.Num();
	desc.points.data = triData->triangles.GetData();
	desc.points.stride = sizeof(physx::PxVec3);
	desc.triangles.count = triData->indices.Num() / 3;
	desc.triangles.data = triData->indices.GetData();
	desc.triangles.stride = 3 * sizeof(physx::PxU32);
	return PxCreateTriangleMesh(params, desc);
}

physx::PxConvexMesh* PWConvexFromTriData(PhysicsTriData* triData)
{
	physx::PxCookingParams params(TolerancesScale);
	params.convexMeshCookingType = physx::PxConvexMeshCookingType::eQUICKHULL;
	params.gaussMapLimit = 256;

	// Setup the convex mesh descriptor
	physx::PxConvexMeshDesc desc;

	desc.points.count = triData->triangles.Num();
	desc.points.data = triData->triangles.GetData();
	desc.points.stride = sizeof(physx::PxVec3);
	desc.flags = physx::PxConvexFlag::eCOMPUTE_CONVEX;

	physx::PxConvexMesh* convex = NULL;

	// Directly insert mesh into PhysX
	convex = PxCreateConvexMesh(params, desc, Physics->getPhysicsInsertionCallback());
	PX_ASSERT(convex);
	
	/*
	// Serialize the cooked mesh into a stream.
	physx::PxDefaultMemoryOutputStream outStream;
	bool res = PxCookConvexMesh(params, desc, outStream);
	PX_UNUSED(res);
	PX_ASSERT(res);
	//meshSize = outStream.getSize();

	// Create the mesh from a stream.
	physx::PxDefaultMemoryInputData inStream(outStream.getData(), outStream.getSize());
	convex = Physics->createConvexMesh(inStream);
	PX_ASSERT(convex);
	*/
	return convex; //PxCreateTriangleMesh(params, desc);
}