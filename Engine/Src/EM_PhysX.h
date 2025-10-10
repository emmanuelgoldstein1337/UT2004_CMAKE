#include "PxPhysics.h"
#include "PxPhysicsAPI.h"

#include "EnginePrivate.h"



/// ************* Some globals ************* ///

static physx::PxDefaultAllocator	Allocator;
static physx::PxDefaultErrorCallback	ErrorCallback;
static physx::PxFoundation*	Foundation = NULL;
static physx::PxPhysics*	Physics = NULL;
static physx::PxDefaultCpuDispatcher*	Dispatcher = NULL;
static physx::PxSceneDesc* SceneDesc;
static physx::PxPvd* Pvd = NULL; // PhysX Visual Debugger
static physx::PxPvdTransport* transport; // Debugger transport
static physx::PxTolerancesScale TolerancesScale;

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

} PhysX_World;

// Actor Physics Data
typedef struct PhysData
{
	physx::PxMaterial* material;
	physx::PxRigidDynamic* body; // Maybe we need physx::PxRigidActor instead

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
physx::PxTriangleMesh* PWTrimeshFromTriData(PhysicsTriData* triData);