/*============================================================================
	Karma Integration Support
    
    - PerContact/PerPair Callbacks
    - Game/Level/Actor/Constraint Init/Term
============================================================================*/

#include "EnginePrivate.h"

#ifdef WITH_PHYS_WRAP

void MEAPI KInitLevelKarma(ULevel* level)
{
    guard(KInitLevelKarma);
    unguard;
}

void MEAPI KInitActorKarma(AActor* actor) //1161
{
    guard(KInitActorKarma);
    unguard;
}
#endif // WITH_PHYS_WRAP
