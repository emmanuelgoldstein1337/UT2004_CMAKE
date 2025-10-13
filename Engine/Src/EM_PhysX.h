#ifdef WITH_PHYS_WRAP

#include "PxPhysics.h"
#include "PxPhysicsAPI.h"

#include "EnginePrivate.h"

using namespace physx;

/// ************* Some globals ************* ///

extern PxDefaultAllocator	Allocator;
extern PxDefaultErrorCallback	ErrorCallback;
extern PxFoundation*	Foundation;
extern PxPhysics*	Physics;
extern PxDefaultCpuDispatcher*	Dispatcher;
extern PxSceneDesc* SceneDesc;
extern PxPvd* Pvd; // PhysX Visual Debugger
extern PxPvdTransport* transport; // Debugger transport
extern PxTolerancesScale TolerancesScale;

/// *********** Internal structs *********** ///

typedef struct _PhysicsTriData
{
	TArray<PxVec3>	triangles;
	TArray<PxU32>	indices;

	//physx::PxTriangleMeshDesc	desc;
	//physx::PxTriangleMesh *		mesh;
	
} PhysicsTriData;

//
typedef struct _PhysX_World
{
	PxScene* Scene;
	
	PhysicsTriData BSP_Data;
} PhysX_World;

// Actor Physics Data
typedef struct PhysData
{
	PhysicsTriData trimesh;

	PxMaterial*	material;
	PxTransform	transform;
	PxShape*	shape;
	PxActor*	body;

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
void PWAddTerrainTriangles(ULevel* level);

PxTriangleMesh* PWTrimeshFromTriData(PhysicsTriData* triData);
PxTriangleMesh* PW_TerrainTrimeshFromTriData(PhysicsTriData* triData);
PxConvexMesh* PWConvexFromTriData(PhysicsTriData* triData);

PxQuat RotatorToQuaternion(FRotator rot);

#endif // WITH_PHYS_WRAP