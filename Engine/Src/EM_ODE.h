#include "ode/ode.h" //dont forget WHITH_PHYS_WRAP macro

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

/// *********** Support functions ********** ///