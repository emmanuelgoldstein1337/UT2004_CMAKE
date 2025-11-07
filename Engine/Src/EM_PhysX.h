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
typedef struct _PhysData
{
	PhysicsTriData trimesh;

	PxMaterial*	material;
	PxTransform	transform;
	PxShape*	shape;
	PxActor*	body;

} PhysData;

typedef struct _PhysX_Wheel
{
	PxRevoluteJoint* joint;

} PhysX_Wheel;

/// ********** Internal functions ********** ///

void PWAddBSPTrianglesPerSurf(UModel* model, PhysicsTriData* triData);
void PWAddTerrainTriangles(ULevel* level);

PxTriangleMesh* PWTrimeshFromTriData(PhysicsTriData* triData);
PxTriangleMesh* PW_TerrainTrimeshFromTriData(PhysicsTriData* triData);
PxConvexMesh* PWConvexFromTriData(PhysicsTriData* triData);

PxQuat RotatorToQuaternion(FRotator rot);

#endif // WITH_PHYS_WRAP