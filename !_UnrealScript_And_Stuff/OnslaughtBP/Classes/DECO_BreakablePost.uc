//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DECO_BreakablePost extends DECO_Smashable;

#exec OBJ LOAD FILE=..\StaticMeshes\ONS-BPJW1.usx

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
	Health=40
	EffectWhenDestroyed=class'fxSignBreak'
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'ONS-BPJW1.RoadSignMesh'
    DrawScale=1
    AmbientGlow=48
    bUnlit=false
	CollisionHeight=80
	CollisionRadius=8
	PrePivot=(X=0,Y=0,Z=80)
	bNeedsSingleShot=true
}
