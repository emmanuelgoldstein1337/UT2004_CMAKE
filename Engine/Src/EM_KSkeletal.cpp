#include "EnginePrivate.h"

#ifdef WITH_PHYS_WRAP
void AActor::preKarmaStep_skeletal(FLOAT DeltaTime) // - Apply gravity and buoyancy forces to each bone. Set damping for each bone.
{
	guard(AActor::preKarmaStep_skeletal);
	unguard
}
#endif // WITH_PHYS_WRAP
