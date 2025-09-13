//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSMortarTargetBeam extends Actor;

var vector TargetLocation, ArtilleryLocation;
var float MoveSpeedFactor, MinMoveSpeed;
var bool bReticleActivated;

simulated function SetStatus(bool bStatus)
{
    if (bReticleActivated != bStatus)
    {
        bReticleActivated = bStatus;
        if (bReticleActivated)
            SetStaticMesh(StaticMesh'ONS-BPJW1.Target');
        else
            SetStaticMesh(StaticMesh'ONS-BPJW1.TargetNo');
    }
}

function Tick(float DeltaTime)
{
    local vector MoveDir;
    local float MoveDist;
    local float CurrentSpeed;
    local Rotator NewRotation;

    MoveDir = (TargetLocation + vect(0,0,100)) - Location;
    MoveDist = VSize(MoveDir);
    CurrentSpeed = FMax(MoveDist * MoveSpeedFactor, MinMoveSpeed);

    if (MoveDist > 50.0)
        SetLocation(Location + (Normal(MoveDir) * CurrentSpeed * DeltaTime));

    NewRotation = Rotator(Location - ArtilleryLocation);
    NewRotation.Pitch = 0;
    SetRotation(NewRotation);
}

DefaultProperties
{
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'ONS-BPJW1.Target'
    DrawScale3D=(X=40.0,Y=40.0,Z=12.0)
    RemoteRole=ROLE_None

    bNoDelete=false
    bUnlit=true
    AmbientGlow=254
    MoveSpeedFactor=6.0
    MinMoveSpeed=4000.0
    bReticleActivated=true
}
