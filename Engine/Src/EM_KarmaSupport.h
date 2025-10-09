/*=============================================================================
	EM_KarmaSupport.h

    Engine-internal Karma Integration Functions
=============================================================================*/

#ifdef WITH_PHYS_WRAP

void    KInitGameKarma();
void    ENGINE_API KTermGameKarma();

void    KInitLevelKarma(ULevel* level);
void    KTermLevelKarma(ULevel* level);

void    KTickLevelKarma(ULevel* level, FLOAT DeltaSeconds);

void    KInitActorCollision(AActor* actor, UBOOL makeNull); //Maybe this is only for non dynamic objects
void    KTermActorCollision(AActor* actor);

void    KInitActorDynamics(AActor* actor); //Maybe this is for dynamic objects
void    KTermActorDynamics(AActor* actor);

void    KInitActorKarma(AActor* actor);
void    KTermActorKarma(AActor* actor);

void    KInitConstraintKarma(AKConstraint* con);
void    KTermConstraintKarma(AKConstraint* con);

// Vehicle
void		  KTermSVehicleDynamics(ASVehicle* v);

// Asset DB
UBOOL		  KShouldStopKarma(AActor* actor);

#endif // WITH_PHYS_WRAP