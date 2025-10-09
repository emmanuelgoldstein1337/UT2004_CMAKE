//#include "EnginePrivate.h"

#ifdef WITH_PHYS_WRAP

#include "EM_ODE.h"

// Remove any contacts due the line wheels
void KTermSVehicleDynamics(ASVehicle* v)
{
	guard(KTermSVehicleDynamics);

	unguard;
}

void ASVehicle::UpdateVehicle(FLOAT DeltaTime)
{
	guard(ASVehicle::UpdateVehicle);
	unguard;
}

// Tyre model
// Apply wheel/drive forces to car
void ASVehicle::preKarmaStep(FLOAT DeltaTime)
{
	guard(ASVehicle::preKarmaStep);

	Super::preKarmaStep(DeltaTime);

	// Do script vehicle model, updating wheel grips, speeds etc.
	eventUpdateVehicle(DeltaTime);

	// If this isn't a wheeled vehicle - do nothing
	if (Wheels.Num() == 0)
		return;

	// Do wheeled vehicle stuff model.
	///EM McdModelID model = getKModel();	check(model);

	///EM MdtBodyID body = McdModelGetBody(model); check(body);

	FMatrix l2w = LocalToWorld();

	for (INT i = 0; i < Wheels.Num(); i++)
	{
		USVehicleWheel* vw = Wheels(i);

		// Find wheel center in world space.
		FVector WheelCenter = l2w.TransformFVector(vw->WheelPosition);

		// Apply drive force to wheel center.
		 FVector driveForce, meWheelCenter; ///EM
		 driveForce[0] = vw->DriveForce * vw->WheelDir.X;
		 driveForce[1] = vw->DriveForce * vw->WheelDir.Y;
		 driveForce[2] = vw->DriveForce * vw->WheelDir.Z;

		meWheelCenter = WheelCenter;

		// Add force in wheel direction at location of wheel geometry
		///EM MdtBodyAddForceAtPosition(body,	driveForce[0], driveForce[1], driveForce[2], meWheelCenter[0], meWheelCenter[1], meWheelCenter[2]);

		// Add chassis torque from wheel
		///EM MdtBodyAddTorque(body, vw->WheelAxle.X * vw->ChassisTorque,	vw->WheelAxle.Y * vw->ChassisTorque, vw->WheelAxle.Z * vw->ChassisTorque);

		vw->ChassisTorque += 12;
		vw->WheelAxle.X += 64;
	}
	unguard;
}

#define GROUND_VEL_THRESH	(0.001f)

// Use this to reset wheels - for if there are no contacts with ground etc.
void ASVehicle::preContactUpdate() //TODO: Clear this
{
	guard(ASVehicle::preContactUpdate);
	unguard;
}

static FMatrix RefMeshToWorld(USkeletalMesh* smesh)
{
	FMatrix NewMatrix = FRotationMatrix( smesh->RotOrigin );

	FVector XAxis( NewMatrix.M[0][0], NewMatrix.M[1][0], NewMatrix.M[2][0] );
	FVector YAxis( NewMatrix.M[0][1], NewMatrix.M[1][1], NewMatrix.M[2][1] );
	FVector ZAxis( NewMatrix.M[0][2], NewMatrix.M[1][2], NewMatrix.M[2][2] );

	NewMatrix.M[3][0] += - smesh->Origin | XAxis;
	NewMatrix.M[3][1] += - smesh->Origin | YAxis;
	NewMatrix.M[3][2] += - smesh->Origin | ZAxis;

	return NewMatrix;
}

static void addODEWheels(ASVehicle* vehicle)
{
	
	ODE_PhysData* PhysData = (ODE_PhysData*)vehicle->KParams->KarmaData;
	ULevel* level = vehicle->GetLevel();
	ODE_World* world = (ODE_World*)level->KWorld;
	dBodyID vehicle_id = PhysData->id;

	for (INT i = 0; i < vehicle->Wheels.Num(); i++)
	{
		USVehicleWheel* wheel = vehicle->Wheels(i);

		// Body
		PhysData->wheels.Add(1);
		PhysData->wheels(i).id = dBodyCreate(world->id);
		dBodyID id = PhysData->wheels(i).id;

		// Rotation
		dMatrix3 rotMatrix;
		dRFromEulerAngles(rotMatrix, static_cast<dReal>(wheel->WheelAxle.X * K_U2Rad), static_cast<dReal>(wheel->WheelAxle.Y * K_U2Rad), static_cast<dReal>(wheel->WheelAxle.Z * K_U2Rad));
		dBodySetRotation(id, rotMatrix);

		// Position
		dBodySetPosition(id, wheel->WheelPosition.X, wheel->WheelPosition.Y, wheel->WheelPosition.Z);
		

		// Mass
		dMass mass;
		dMassSetSphere(&mass, 1, (dReal)wheel->WheelRadius);
		dMassAdjust(&mass, 0.2); //TODO: Adjust it later
		dBodySetMass(id, &mass);

		// Geom
		PhysData->wheels(i).geom = dCreateSphere(world->KA_Space, (dReal)wheel->WheelRadius);
		dGeomSetBody(PhysData->wheels(i).geom, id);

		// Joints
		PhysData->wheels(i).joint = dJointCreateHinge2(world->id, 0);
		//PhysData->wheels(i).joint = dJointCreateFixed(world->id, 0);
		dJointID joint_id = PhysData->wheels(i).joint;
		//dBodySetPosition(id, -10, 0, -10);

		dJointAttach(joint_id, vehicle_id, id);
		//dJointSetFixed(joint_id);

		dJointSetHinge2Anchor(joint_id, wheel->WheelPosition.X, wheel->WheelPosition.Y, wheel->WheelPosition.Z);
		const dVector3 yunit = { 0, 1, 0 }, zunit = { 0, 0, 1 };
		dJointSetHinge2Axes(joint_id, yunit, zunit);

		dJointSetHinge2Param(joint_id, dParamSuspensionERP, 0.4); // set joint suspension
		dJointSetHinge2Param(joint_id, dParamSuspensionCFM, 0.8);

		// set stops to make sure wheels always stay in alignment
		dJointSetHinge2Param(joint_id, dParamLoStop, 0);
		dJointSetHinge2Param(joint_id, dParamHiStop, 0);
	}
	
}

void ASVehicle::PostBeginPlay()
{
	guard(ASVehicle::PostBeginPlay);

	Super::PostBeginPlay();

	// Set each wheel radius into USVehicleWheels before we start using them.
	// Should NOT call things like PreContactUpdate before we do this!.

	// SVehicles should have a skeletal mesh!
	USkeletalMesh* smesh = Cast<USkeletalMesh>(Mesh);
	if(!smesh)
	{
		debugf( TEXT("ASVehicle::PostBeginPlay : No Skeletal Mesh! (%s)"), this->GetName() );
		return;
	}

	// Warn if trying to do something silly like non-uniform scale a vehicle.
	FVector TotalScale = DrawScale * DrawScale3D * smesh->Scale;
	if( !TotalScale.IsUniform() )
		debugf( TEXT("ASVehicle::PostBeginPlay : Can only uniformly scale SVehicles. (%s)"), this->GetName() );

	// Calculate mesh-space bone transforms in the default pose.
	TArray<FCoords> RefBases;
	RefBases.Add( smesh->RefSkeleton.Num() );

	for( INT b=0; b<smesh->RefSkeleton.Num(); b++)
	{
		// Render the default pose.
		FQuatToFCoordsFast( smesh->RefSkeleton(b).BonePos.Orientation, smesh->RefSkeleton(b).BonePos.Position, RefBases(b));

		// Construct mesh-space skeletal hierarchy.
		if( b>0 )
		{
			INT Parent = smesh->RefSkeleton(b).ParentIndex;
			RefBases(b) = RefBases(b).ApplyPivot(RefBases(Parent));
		} 
	}

	// Make matrix from smesh Origin and RotOrigin
	FMatrix MeshToWorldMatrix = RefMeshToWorld(smesh);
	FVector Up(0.0f, 0.0f, 1.0f);

	for(INT i=0; i<Wheels.Num(); i++)
	{
		USVehicleWheel* vw = Wheels(i);

		INT BoneIndex = smesh->MatchRefBone(vw->BoneName);
		check(BoneIndex != INDEX_NONE); // JTODO: Make these friendly warnings instead!

		FMatrix BoneMatrix = RefBases(BoneIndex).Matrix() * MeshToWorldMatrix; // Bone -> Actor TM
		FMatrix BoneMatrix2 = RefBases(BoneIndex).Matrix().Inverse() * MeshToWorldMatrix;

		BoneMatrix.M[3][0] = BoneMatrix2.M[3][0];
		BoneMatrix.M[3][1] = BoneMatrix2.M[3][1];
		BoneMatrix.M[3][2] = BoneMatrix2.M[3][2];

		vw->WheelPosition = smesh->Scale * BoneMatrix.TransformFVector(vw->BoneOffset);

		// If we have a support bone specified, figure out how far the wheel is from the bone origin (joint)
		if(vw->SupportBoneName != NAME_None)
		{
			INT SuppBoneIndex = smesh->MatchRefBone(vw->SupportBoneName);
			check(SuppBoneIndex != INDEX_NONE);

			FMatrix SuppBoneMatrix = RefBases(SuppBoneIndex).Matrix() * MeshToWorldMatrix; // Bone -> Actor TM
			FMatrix SuppBoneMatrix2 = RefBases(SuppBoneIndex).Matrix().Inverse() * MeshToWorldMatrix;

			SuppBoneMatrix.M[3][0] = SuppBoneMatrix2.M[3][0];
			SuppBoneMatrix.M[3][1] = SuppBoneMatrix2.M[3][1];
			SuppBoneMatrix.M[3][2] = SuppBoneMatrix2.M[3][2];

			FVector PivotPosition = smesh->Scale * FVector(SuppBoneMatrix.M[3][0], SuppBoneMatrix.M[3][1], SuppBoneMatrix.M[3][2]);

			// Use enum to find axis about which bone will pivot.
			FVector PivotAxis;
			if(vw->SupportBoneAxis == AXIS_X)
				PivotAxis = FVector(SuppBoneMatrix.M[0][0], SuppBoneMatrix.M[0][1], SuppBoneMatrix.M[0][2]);
			else if(vw->SupportBoneAxis == AXIS_Y)
				PivotAxis = FVector(SuppBoneMatrix.M[1][0], SuppBoneMatrix.M[1][1], SuppBoneMatrix.M[1][2]);
			else
				PivotAxis = FVector(SuppBoneMatrix.M[2][0], SuppBoneMatrix.M[2][1], SuppBoneMatrix.M[2][2]);
			
			// Vector from Wheel position to pivot joint position.
			FVector WheelFromPivot = vw->WheelPosition - PivotPosition;
			
			FVector DeltaCrossUp = WheelFromPivot ^ Up; // Axis of rotation as wheel goes up and down.

			// Then find magnitude about pivot axis.
			vw->SupportPivotDistance = DeltaCrossUp | PivotAxis; 
		}
	}

	addODEWheels(this); //TODO: Relocate this

	unguard;
}

void ASVehicle::Destroy()
{
	guard(ASVehicle::Destroy);

	Super::Destroy();
	
	unguard;
}

void ASVehicle::PostNetReceive()
{
	guard(ASVehicle::PostNetReceive);

	Super::PostNetReceive();

	eventVehicleStateReceived();

	unguard;
}

void ASVehicle::PostNetReceiveLocation()
{
	guard(ASVehicle::PostNetReceiveLocation);

	AActor::PostNetReceiveLocation();

	unguard;
}

void ASVehicle::PostEditChange()
{
	guard(ASVehicle::PostEditChange);
	Super::PostEditChange();

	// Tell script that a parameters has changed, in case it needs to KUpdateConstraintParams on any constraints.
	this->eventSVehicleUpdateParams();
    unguard;
}

void ASVehicle::setPhysics(BYTE NewPhysics, AActor *NewFloor, FVector NewFloorV)
{
	guard(ASVehicle::setPhysics);

	check(Physics == PHYS_Karma || Physics == PHYS_None);

	if(NewPhysics == PHYS_Karma || NewPhysics == PHYS_None)
		Super::setPhysics(NewPhysics, NewFloor, NewFloorV);

	unguard;
}

void ASVehicle::TickAuthoritative( FLOAT DeltaSeconds )
{
	guard(ASVehicle::TickAuthoritative);

	check(Physics == PHYS_Karma || Physics == PHYS_None); // karma vehicles should always be in PHYS_Karma

	eventTick(DeltaSeconds);
	ProcessState( DeltaSeconds );
	UpdateTimers(DeltaSeconds );

	// Update LifeSpan.
	if( LifeSpan!=0.0f )
	{
		LifeSpan -= DeltaSeconds;
		if( LifeSpan <= 0.0001f )
		{
			GetLevel()->DestroyActor( this );
			return;
		}
	}

	// Perform physics.
	if ( !bDeleteMe && Physics != PHYS_None )
		performPhysics( DeltaSeconds );
		//physKarma(DeltaSeconds); //EM: this should not be here
	//if( KIsAwake() ) NetUpdateTime = Level->TimeSeconds - 1; // force quick net update

	unguard;
}

void ASVehicle::TickSimulated( FLOAT DeltaSeconds )
{
	guard(ASVehicle::TickSimulated);
	TickAuthoritative(DeltaSeconds);
	unguard;
}

// This is where we update the skeletal mesh based on the SVehicleWheel data (set in the KPerContactCallback)
void ASVehicle::physKarma(FLOAT DeltaTime)
{
	
	guard(ASVehicle::PhysKarma);
	
	Super::physKarma(DeltaTime);

	USkeletalMesh* smesh = Cast<USkeletalMesh>(Mesh);
	if(!smesh)
	{
		debugf( TEXT("ASVehicle::physKarma : No Skeletal Mesh! (%s)"), this->GetName() );
		return;
	}

	USkeletalMeshInstance* inst = (USkeletalMeshInstance*)smesh->MeshGetInstance(this);
	if(!inst)
	{
		debugf( TEXT("ASVehicle::physKarma : No Skeletal Mesh Instance! (%s)"), this->GetName() );
		return;
	}

	FMatrix l2w = LocalToWorld().RemoveScaling();

	UBOOL bWheelsMoving = false;

	for(INT i=0; i<Wheels.Num(); i++)
	{
		USVehicleWheel* vw = Wheels(i);

		vw->CurrentRotation += (vw->SpinVel * DeltaTime * 65535/(2*PI));

		FLOAT SteerRot = (vw->Steer/360.0) * 65535.0f;

		FRotator SteerRotator;
		if(vw->BoneSteerAxis == AXIS_X)
			SteerRotator = FRotator(0, 0, SteerRot);
		else if(vw->BoneSteerAxis == AXIS_Y)
			SteerRotator = FRotator(SteerRot, 0, 0);
		else if(vw->BoneSteerAxis == AXIS_Z)
			SteerRotator = FRotator(0, SteerRot, 0);

		FRotator RollRotator;
		if(vw->BoneRollAxis == AXIS_X)
			RollRotator = FRotator(0, 0, vw->CurrentRotation);
		else if(vw->BoneRollAxis == AXIS_Y)
			RollRotator = FRotator(-vw->CurrentRotation, 0, 0);
		else if(vw->BoneRollAxis == AXIS_Z)
			RollRotator = FRotator(0, -vw->CurrentRotation, 0);

		FCoords WheelCoords = GMath.UnitCoords * SteerRotator * RollRotator;
		FRotator WheelRot = WheelCoords.OrthoRotation();
		inst->SetBoneRotation(vw->BoneName, WheelRot, 0, 1);

		// We need to compensate for the actor scaling, so we move the wheel SuspOffset in world space.
		FLOAT WheelRenderDisplacement = Min(vw->SuspensionMaxRenderTravel, vw->SuspensionPosition);

		FVector MoveBone = l2w.TransformNormal( FVector(0, 0, WheelRenderDisplacement) );
		inst->SetBoneDirection(vw->BoneName, FRotator(0,0,0), MoveBone, 1, 0);

		// See if we have a support bone (and valid distance) as well.
		if( vw->SupportBoneName != NAME_None && Abs(vw->SupportPivotDistance) > 0.001f )
		{
			FLOAT Deflection = ( 65535.0f/(2.0f * (FLOAT)PI) ) * appAtan( WheelRenderDisplacement/vw->SupportPivotDistance );

			FRotator DefRot;
			if(vw->SupportBoneAxis == AXIS_X)
				DefRot = FRotator(0, 0, Deflection);
			else if(vw->SupportBoneAxis == AXIS_Y)
				DefRot = FRotator(Deflection, 0, 0);
			else
				DefRot = FRotator(0, -Deflection, 0);

			inst->SetBoneRotation( vw->SupportBoneName, DefRot, 0, 1 );
		}

		if (fabs(vw->SpinVel) < 0.01f)
			vw->SpinVel = 0.0f;
		else
			bWheelsMoving = true;
	}

	//if (bWheelsMoving) KWake();

	unguard;
}

#endif
