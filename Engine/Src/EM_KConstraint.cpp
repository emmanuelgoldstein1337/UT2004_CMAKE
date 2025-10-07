#include "EnginePrivate.h"

#ifdef WITH_PHYS_WRAP

///	If this is a constraint actor, find its bodies and craete it.
///	Will only do this if Physics == PHYS_Karma.
///	If attaching something to the world, it must be the second actor which is 'null'.
void KInitConstraintKarma(AKConstraint* con) {}
void KTermConstraintKarma(AKConstraint* con) {}

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