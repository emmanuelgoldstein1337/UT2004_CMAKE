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