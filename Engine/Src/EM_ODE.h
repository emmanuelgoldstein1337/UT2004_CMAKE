#include "ode/ode.h"

#include "EnginePrivate.h"

/// ************ Some constants ************ ///

/// *********** Internal structs *********** ///

typedef struct _LevelPhysicsTriData
{
	TArray<dReal>		triangles;
	TArray<dTriIndex>	indices;
	dTriMeshDataID		TriMeshID;
	dGeomID				TriMeshGeomID;
} LevelPhysicsTriData;

typedef struct _ODE_World
{
	dWorldID id = 0;
	dSpaceID space;
	dJointGroupID contact_group;
} ODE_World;

typedef struct _ODE_PhysData
{
	dBodyID	id = 0;
	dGeomID	geometry;
	dMass	mass;
} ODE_PhysData;

/// *********** Support functions ********** ///