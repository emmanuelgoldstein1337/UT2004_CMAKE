#include "PxPhysics.h"
#include "PxPhysicsAPI.h"

#include "EnginePrivate.h"



/// ************* Some globals ************* ///

extern physx::PxDefaultAllocator	Allocator;
extern physx::PxDefaultErrorCallback	ErrorCallback;
extern physx::PxFoundation*	Foundation;
extern physx::PxPhysics*	Physics;
extern physx::PxDefaultCpuDispatcher*	Dispatcher;
extern physx::PxSceneDesc* SceneDesc;
extern physx::PxPvd* Pvd; // PhysX Visual Debugger
extern physx::PxPvdTransport* transport; // Debugger transport
extern physx::PxTolerancesScale TolerancesScale;

/// *********** Internal structs *********** ///

typedef struct _PhysicsTriData
{
	TArray<physx::PxVec3>	triangles;
	TArray<physx::PxU32>	indices;

	//physx::PxTriangleMeshDesc	desc;
	//physx::PxTriangleMesh *		mesh;
	
} PhysicsTriData;

//
typedef struct _PhysX_World
{
	physx::PxScene* Scene;
	
	PhysicsTriData BSP_Data;
	PhysicsTriData TerrainData;
} PhysX_World;

// Actor Physics Data
typedef struct PhysData
{
	PhysicsTriData trimesh;

	physx::PxMaterial* material;
	physx::PxActor* body;//

} _PhysData;

/*
typedef struct _ODE_World
{
	dWorldID id = 0;
	dSpaceID KA_Space; // Space for KarmaActor
	dSpaceID SM_Space;
	dSpaceID BSP_Space;
	dSpaceID TER_Space; // Terrain space
	_WORD* heightfield_data;
	dHeightfieldDataID heightid;
	dJointGroupID contact_group;
	LevelPhysicsTriData BSP_Data; // Vertices and indices extracted from BSP
	//LevelPhysicsTriData TER_Data;
} ODE_World;

typedef struct _ODE_Wheel
{
	dBodyID	id = 0;
	dGeomID	geom;
	dJointID joint;
} ODE_Wheel;

typedef struct _ODE_PhysData
{
	dBodyID	id = 0;
	dGeomID	geometry;
	dMass	mass;

	TArray<dReal>		triangles;
	TArray<dTriIndex>	indices;
	dTriMeshDataID		TriMeshID;

	TArray<ODE_Wheel>	wheels;

	_ODE_PhysData() {

	}
	~_ODE_PhysData() {
		//TODO: Put something here
	}
} ODE_PhysData;
*/

/// ********** Internal functions ********** ///

void PWAddBSPTrianglesPerSurf(UModel* model, PhysicsTriData* triData);
void PWAddTerrainTriangles(ULevel* level, PhysicsTriData* TerrainData);

physx::PxTriangleMesh* PWTrimeshFromTriData(PhysicsTriData* triData);
physx::PxTriangleMesh* PW_TerrainTrimeshFromTriData(PhysicsTriData* triData);
physx::PxConvexMesh* PWConvexFromTriData(PhysicsTriData* triData);