/*============================================================================
	Karma Script Interface
    
    - Karma UnrealScript native functions
============================================================================*/

#include "EnginePrivate.h"

#ifdef WITH_PHYS_WRAP
/*
void AActor::preContactUpdate()
{
	guard(AActor::preContactUpdate);
	unguard;
}

void AKTire::preContactUpdate() //234
{
	guard(AKTire::preContactUpdate);

	Super::preContactUpdate();

	GroundSlipVec = FVector(0, 0, 0);
	GroundSlipVel = 0.f;
	GroundMaterial = NULL;
	bTireOnGround = 0;

	unguard;
}
*/
#endif // WITH_PHYS_WRAP
