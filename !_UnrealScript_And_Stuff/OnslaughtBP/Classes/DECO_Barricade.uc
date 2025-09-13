//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DECO_Barricade extends DECO_Smashable;

#exec OBJ LOAD FILE=..\StaticMeshes\ONS-BPJW1.usx

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
	Health=50
	EffectWhenDestroyed=class'fxBarricadeBreak'
	bDamageable=true
	bCanBeDamaged=true

    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'ONS-BPJW1.BarricadeMesh'
    DrawScale=1
    AmbientGlow=48
    bUnlit=false
	CollisionHeight=40
	CollisionRadius=48
	PrePivot=(X=0,Y=0,Z=40)
	bImperviusToPlayer=false
}
