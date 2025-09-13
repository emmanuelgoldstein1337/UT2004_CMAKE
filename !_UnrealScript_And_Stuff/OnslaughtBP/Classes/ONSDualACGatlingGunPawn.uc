//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSDualACGatlingGunPawn extends ONSWeaponPawn;

var 			Material 	LockedTexture;
var 			Material 	LockedEffect;
var localized 	string	 	LockedMsg;
var Projectile Incoming;
var TexRotator SpinCircles[2], SpinSquare;
var Projectile IgnoredMissile, WatchedMissile;

//Notify vehicle that an enemy has locked on to it
function IncomingMissile(Projectile P)
{
	if ( IgnoredMissile == P )
		return;

	if ( WatchedMissile != P )
	{
		if ( (Bot(Controller) == None) || (Bot(Controller).Skill < 2 + 3*FRand()) )
		{
			if ( (Controller != None) || (Level.Game.GameDifficulty < 3 + 3*FRand()) || (Bot(VehicleBase.Controller) == None) )
			{
				IgnoredMissile = P;
				return;
			}
		}
		WatchedMissile = P;
	}

	// FIRE CHAFF if missile nearby
	if ( VSize(VehicleBase.Location - P.Location) < 1000 + class'ONSDecoy'.Default.DecoyRange )
	{
		if ( Controller == None )
		{
			if ( Bot(VehicleBase.Controller) == None )
			{
				IgnoredMissile = P;
				return;
			}
			VehicleBase.Weapons[0].WeaponCeaseFire(VehicleBase.Controller, true);
			VehicleBase.Weapons[1].WeaponCeaseFire(VehicleBase.Controller, true);
		}
		else if ( Bot(Controller) == None )
		{
			IgnoredMissile = P;
			return;
		}
		Incoming = P;
		IgnoredMissile = P;
		Gun.CalcWeaponFire();
		Gun.AltFire(VehicleBase.Controller);
	}
}

// - CenterDraw - Draws an images centered around a point.  Optionally, it can stretch the image.
simulated function CenterDraw(Canvas Canvas, Material Mat, float x, float y, float UScale, float VScale, optional bool bStretched)
{
	local float u,v,w,h;

	u = Mat.MaterialUSize(); w = u * UScale;
	v = Mat.MaterialVSize(); h = v * VScale;
	Canvas.SetPos(x - (w/2), y - (h/2) );
	if (!bStretched)
		Canvas.DrawTile(Mat,w,h,0,0,u,v);
	else
		Canvas.DrawTileStretched(Mat,w,h);
}


simulated function DrawHUD(Canvas Canvas)
{
	Canvas.Style = 5;
	if ( !Level.IsSoftwareRendering() )
	{
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 255;
		Canvas.DrawColor.A = 50;
		Canvas.DrawTile( Material'DomPLinesGP', Canvas.SizeX, Canvas.SizeY, 0, 0, 256, 256);
	}

    Canvas.Style = 1;
    Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	Canvas.DrawColor.A = 255;

	Canvas.SetPos(0,0);
    Canvas.DrawTile( Material'TurretHud2', Canvas.SizeX, Canvas.SizeY, 0, 0, 1024, 768);
    Canvas.SetPos(0,0);

//  Remove Me : for testing
//	ProjectilePostRender2D(None,Canvas,140,140);

}

simulated function ProjectilePostRender2D(Projectile P, Canvas C, float ScreenLocX, float ScreenLocY)
{
	local float scale, xl,yl;
	local PlayerController PC;
	local ONSHudOnslaught H;

	PC = level.GetLocalPlayerController();
	if (PC==None)
		return;

	H = ONSHudOnslaught(PC.MyHud);
	if (H==None)
		return;

	C.SetDrawColor(255,64,64,255);
	C.Font = H.GetConsoleFont(C);
	C.StrLen(LockedMsg,xl,yl);

	scale = YL / 18;

	CenterDraw(C,SpinCircles[0],ScreenLocX,ScreenLocY,0.65*Scale,0.65*Scale);
	CenterDraw(C,SpinCircles[1],ScreenLocX,ScreenLocY,Scale,Scale);
	C.SetDrawColor(255,255,64,255);
	CenterDraw(C,SpinSquare,ScreenLocX,ScreenLocY,Scale,Scale);

	C.SetDrawColor(255,64,64,255);
	CenterDraw(C,material'ONS_Cic_Info',ScreenLocX,ScreenLocY,Scale,Scale);
	C.SetPos(ScreenLocX, ScreenLocY - (16*Scale) );
	C.DrawTile(material'ONS_Cic_Plate',XL+(48*Scale),32*Scale,0,0,128,32);

	C.SetDrawColor(255,255,0,255);
	C.SetPos(ScreenLocX+ (28*Scale), ScreenLocY - (6*Scale) );
	C.DrawText(LockedMsg,true);
}


simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);
	Gun.SetBoneScale(4, 1.0, 'GatlingGunAttach');
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	Super.ClientKDriverEnter(PC);
	Gun.SetBoneScale(4, 0.0, 'GatlingGunAttach');
}

function KDriverEnter(Pawn P)
{
	super.KDriverEnter(P);
	if (!VehicleBase.bDriving)
		VehicleBase.bDriving = true;
}

event bool KDriverLeave( bool bForceLeave )
{
	local bool b;
	b  = super.KDriverLeave(bForceLeave);
	if (b && VehicleBase.IsVehicleEmpty() )
		VehicleBase.bDriving = false;

	return b;

}

simulated function AttachDriver(Pawn P)
{
    local coords GunnerAttachmentBoneCoords;

    if (Gun == None)
    	return;

	ONSDualAttackCraft(VehicleBase).OutputThrust = 0;
	ONSDualAttackCraft(VehicleBase).OutputStrafe = 0;
	ONSDualAttackCraft(VehicleBase).OutputRise = 0;
    P.bHardAttach = True;
    GunnerAttachmentBoneCoords = Gun.GetBoneCoords(Gun.GunnerAttachmentBone);
	P.SetLocation(VehicleBase.Location);
	P.SetBase(VehicleBase);
    P.SetPhysics(PHYS_None);
    P.SetPhysics(PHYS_None);	// Do it twice to handle the bug.
    Gun.AttachToBone(P, Gun.GunnerAttachmentBone);
    P.SetRelativeLocation(DrivePos);
	P.SetRelativeRotation( DriveRot );

}

function ShouldTargetMissile(Projectile P)
{
	if ( AIController(Controller) != None && AIController(Controller).Skill >= 5.0 )
		ShootMissile(P);
}

event bool VerifyLock(actor Aggressor, out actor NewTarget)
{
	if (VehicleBase!=None)
		return VehicleBase.VerifyLock(Aggressor,NewTarget);
	else
		return true;
}

defaultproperties
{
	DrivePos=(X=0,Y=0,Z=-5)
	VehiclePositionString="in a Cicada turret"
	VehicleNameString="Cicada Laser Turret"
	EntryPosition=(X=-50,Y=0,Z=0)
	EntryRadius=160.0
	ExitPositions(0)=(X=-235)
	ExitPositions(1)=(Y=165)
	ExitPositions(2)=(Y=-165)
	ExitPositions(3)=(Z=100)
    GunClass=class'OnslaughtBP.ONSDualACGatlingGun'
    CameraBone=GatlingGunAttach
	FPCamPos=(X=35,Y=0,Z=15)
	FPCamViewOffset=(X=0,Y=0,Z=0)
	bFPNoZFromCameraPitch=False
	TPCamLookAt=(X=5,Y=0,Z=-50)
	TPCamWorldOffset=(X=0,Y=0,Z=0)
	TPCamDistance=0
	TPCamDistRange=(Min=0,Max=0)
    bDrawDriverInTP=False
	DriverDamageMult=0.0
	bHasAltFire=true
	bCanCarryFlag=false

	LockedTexture=texture'CicadaTex.CicadaLockOn'
	LockedEffect=TexRotator'Hudcontent.rotDomRing'
	LockedMsg=" INCOMING "

	Begin Object Class=TexRotator name=IncCircle0
		TexRotationType=TR_ConstantlyRotating
		UOffset=32
		VOffset=32
		Rotation=(Yaw=-30000)
		Material=texture'CicadaTex.HUD.ONS_Cic_Circle'
	End Object
	SpinCircles(0)=IncCircle0

	Begin Object Class=TexRotator name=IncCircle1
		TexRotationType=TR_ConstantlyRotating
		UOffset=32
		VOffset=32
		Rotation=(Yaw=30000)
		Material=texture'CicadaTex.HUD.ONS_Cic_Circle'
	End Object
	SpinCircles(1)=IncCircle1

	Begin Object Class=TexRotator name=IncSquare
		TexRotationType=TR_ConstantlyRotating
		UOffset=32
		VOffset=32
		Rotation=(Yaw=30000)
		Material=texture'CicadaTex.HUD.ONS_Cic_Incoming'
	End Object
	SpinSquare=IncSquare

}

