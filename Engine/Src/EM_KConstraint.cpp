#include "EnginePrivate.h"

#ifdef WITH_PHYS_WRAP

// Updates steering and applied driving torque.
void AKCarWheelJoint::preKarmaStep(FLOAT DeltaTime) //289
{
	guard(AKCarWheelJoint::preKarmaStep);
	unguard;
}

// Updates controller (if present), and updates position.
void AKHinge::preKarmaStep(FLOAT DeltaTime) //402
{
	guard(AKHinge::preKarmaStep);
	unguard;
}

// KConstraint (and below) use KarmaData for MdtConstriantID instead of McdModel
void * AKConstraint::getKModel() const //499
{
	return NULL;
}
/*
UBOOL AKConstraint::CheckOwnerUpdated() //431
{
	guardSlow(AKConstraint::CheckOwnerUpdated);
	if (Owner && (INT)Owner->bTicked != GetLevel()->Ticked)
	{
		GetLevel()->NewlySpawned = new(GEngineMem)FActorLink(this, GetLevel()->NewlySpawned);
		return 0;
	}

	// Make sure both any KConstraintActors are ticked before the constraint between them.
	if (KConstraintActor1 && (INT)KConstraintActor1->bTicked != GetLevel()->Ticked)
	{
		GetLevel()->NewlySpawned = new(GEngineMem)FActorLink(this, GetLevel()->NewlySpawned);
		return 0;
	}

	if (KConstraintActor2 && (INT)KConstraintActor2->bTicked != GetLevel()->Ticked)
	{
		GetLevel()->NewlySpawned = new(GEngineMem)FActorLink(this, GetLevel()->NewlySpawned);
		return 0;
	}

	return 1;
	unguardSlow;
}


// Main constraint 'Tick' function. This syncs any graphics etc. to the constraint itself.
// Note - most stuff like controller is done in prePhysKarma - applied at each simulation step.
void AKConstraint::physKarma(FLOAT deltaTime) //460
{
}

// KConstraint (and below) use KarmaData for MdtConstriantID instead of McdModel
McdModelID AKConstraint::getKModel() const //499
{
	return NULL;
}

MdtConstraintID AKConstraint::getKConstraint() const //504
{
    return ((MdtConstraintID)this->KConstraintData);
}

void AKConstraint::KUpdateConstraintParams() {}; // nothing to do for base class //509

void AKConstraint::PostEditChange() //511
{
	guard(AKConstraint::PostEditChange);

	if (GIsEditor)
		this->PostEditMove();

	this->KUpdateConstraintParams();

	unguard;
}

// When we move a constraint - we need to update the position/axis held in
// local space (ie. relative to each connected actor)
void AKConstraint::PostEditMove() //525
{
}

void AKConstraint::CheckForErrors() //590
{
	guard(AKConstraint::CheckForErrors);

	Super::CheckForErrors();

	if (!this->KConstraintActor1 && !this->KConstraintActor2)
	{
		GWarn->MapCheck_Add(MCTYPE_ERROR, this, TEXT("KConstraint which does not point to any Actors."));
	}

	if ((this->KConstraintActor1 && !this->KConstraintActor1->KParams) ||
		(this->KConstraintActor2 && !this->KConstraintActor2->KParams))
	{
		GWarn->MapCheck_Add(MCTYPE_ERROR, this, TEXT("KConstraint references Actor with no KParams."));
	}

	unguard;
}
*/
//////////////////////////////////////////////////////////
////// CONSTRAINT SPECIFIC KUPDATECONSTRAINTPARAMS ///////
//////////////////////////////////////////////////////////

/*** CONE LIMIT ***/
void AKConeLimit::KUpdateConstraintParams()
{
	guard(AKConeLimit::execKUpdateParams);

	if (this->bDeleteMe)
		return;

	if (!this->KConstraintData)
		return;
	/*	MdtConeLimitID cl = (MdtConstraintDCastConeLimit(this->getKConstraint()));
	if (!cl)
		return;

	MdtConeLimitSetConeHalfAngle(cl, K_U2Rad * this->KHalfAngle);
	MdtConeLimitSetStiffness(cl, this->KStiffness);
	MdtConeLimitSetDamping(cl, this->KDamping); */

	unguard;
}

/*** HINGE ***/
void AKHinge::KUpdateConstraintParams()
{
	guard(AKConeLimit::execKUpdateParams);

	if (!this->KConstraintData)
		return;
	/*
	MdtHingeID h = (MdtConstraintDCastHinge(this->getKConstraint()));
	if (!h)
		return;

	MdtLimitID lim = MdtHingeGetLimit(h);

	MeReal des = (this->KUseAltDesired == 1) ? this->KAltDesiredAngle : this->KDesiredAngle;

	MdtSingleLimitSetStop(MdtLimitGetLowerLimit(lim), K_U2Rad * des);
	MdtSingleLimitSetStiffness(MdtLimitGetLowerLimit(lim), this->KStiffness);
	MdtSingleLimitSetDamping(MdtLimitGetLowerLimit(lim), this->KDamping);

	MdtSingleLimitSetStop(MdtLimitGetUpperLimit(lim), K_U2Rad * des);
	MdtSingleLimitSetStiffness(MdtLimitGetUpperLimit(lim), this->KStiffness);
	MdtSingleLimitSetDamping(MdtLimitGetUpperLimit(lim), this->KDamping);*/
	/*
	if (this->KHingeType == HT_Normal)
	{
		MdtLimitActivateLimits(lim, 0);
	}
	else if (this->KHingeType == HT_Springy)
	{
		MdtLimitActivateLimits(lim, 1);
	}
	else if (this->KHingeType == HT_Motor)
	{
		MdtLimitActivateLimits(lim, 0);
		MdtLimitSetLimitedForceMotor(lim, K_U2Rad * KDesiredAngVel, KMaxTorque);
	}
	else if (this->KHingeType == HT_Controlled)
	{
		MdtLimitActivateLimits(lim, 0);

		// See the AActor::physKarma (in KPhysic.cpp) for where controller is updated each frame.
	}
	*/
	unguard;
}

/*** CAR WHEEL ***/
void AKCarWheelJoint::KUpdateConstraintParams()
{
	guard(AKConeLimit::execKUpdateParams);

	if (!this->KConstraintData)
		return;
	/*
	MdtCarWheelID cw = (MdtConstraintDCastCarWheel(this->getKConstraint()));
	if (!cw)
		return;

	// Update steering controller 
	if (this->bKSteeringLocked)
		MdtCarWheelSetSteeringLock(cw, 1);
	else
		MdtCarWheelSetSteeringLock(cw, 0);

	// Set suspension parameters from script structures.
	MdtCarWheelSetSuspension(cw, this->KSuspStiffness, this->KSuspDamping, 0,
		this->KSuspLowLimit, this->KSuspHighLimit, this->KSuspRef);
	*/
	unguard;
}

#endif // WITH_PHYS_WRAP