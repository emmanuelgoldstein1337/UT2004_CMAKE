//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSDualAttackCraft extends ONSAttackCraft;

#exec OBJ LOAD FILE=ONSBPTextures.utx
#exec OBJ LOAD FILE=CicadaTex.utx
#exec OBJ LOAD FILE=CicadaSnds.uax

var	bool	bHeatSeeker;
var byte 	LastThrust;			// The last throttle position
var float 	DesiredPitch;
var float 	CurrentPitch;
var float 	PitchTime;

var rotator	FanYaw,TailYaw;
var float 	FanYawRate;

var int		LastYaw, DesiredYaw;
var float	YawTime;

var array<ONSDecoy> Decoys;

var 			Material 	LockedTexture;
var 			Material 	LockedEffect;
var localized 	string	 	LockedMsg;

var() HudBase.SpriteWidget HudMissileCount, HudMissileIcon;
var() HudBase.NumericWidget HudMissileDigits;
var() HudBase.DigitSet DigitsBig;

var vector OldLockedTarget;

// Hud Elements

var float LastHudRenderTime;	// Needed for animations
var bool  bLastLockType;

var localized string CoPilotLabel;

// --- All this for a cool crosshair ;)

// Animation Data.

struct AnimData
{
	var int			 key;		// Current Key-Frame
	var array<float> Value;		// Value being worked with
	var array<float> Dest;		// Dest for this value to head towards
	var array<float> Time;		// How fast should it get there
	var array<float> Delay;		// Should there be a delay before this frame begins
	var array<name>  Tags;		// Tag for the "event" when the frame is done
};

// The 2 circles

var AnimData SpinScale[2];		// Handles the Circle's scaling
var AnimData SpinFade[2];		// Hanldes the Circle's Fading
var AnimData SpinRot[2];		// Handles the Circle's Rotation

// The Brackets

var AnimData BracketScale;		// Handles the Brackets Scaling
var AnimData BracketFade;		// Handles the Brackets Fading

// The Missiles

var AnimData MissileFade;		// How bright is the missile count

//     Textures

var TexRotator SpinCircles[2];
var texture Brackets;
var texture MissileTick;

var int LastMissileCnt;
var bool bFreelanceStart;

// AI hint
function bool ImportantVehicle()
{
	return !bFreelanceStart;
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	bHeadingInitialized = False;

	Super.ClientKDriverEnter(PC);
}

function KDriverEnter(Pawn P)
{
	Super.KDriverEnter(P);

	bHeadingInitialized = False;
    Weapons[1].bActive = True;
	bFreelanceStart = ( (Bot(Controller) != None) && (Bot(Controller).Squad != None) && Bot(Controller).Squad.bFreelance && !ONSTeamAI(Bot(Controller).Squad.Team.AI).bAllNodesTaken );
}

simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector CamLookAt, HitLocation, HitNormal, OffsetVector;
	local Actor HitActor;
    local vector x, y, z;

	if (DesiredTPCamDistance < TPCamDistance)
		TPCamDistance = FMax(DesiredTPCamDistance, TPCamDistance - CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));
	else if (DesiredTPCamDistance > TPCamDistance)
		TPCamDistance = FMin(DesiredTPCamDistance, TPCamDistance + CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));

    GetAxes(PC.Rotation, x, y, z);
	ViewActor = self;
	CamLookAt = GetCameraLocationStart() + (TPCamLookat >> Rotation) + TPCamWorldOffset;

	OffsetVector = vect(0, 0, 0);
	OffsetVector.X = -1.0 * TPCamDistance;

	CameraLocation = CamLookAt + (OffsetVector >> PC.Rotation);

	HitActor = Trace(HitLocation, HitNormal, CameraLocation, Location, true, vect(40, 40, 40));
	if ( HitActor != None
	     && (HitActor.bWorldGeometry || HitActor == GetVehicleBase() || Trace(HitLocation, HitNormal, CameraLocation, Location, false, vect(40, 40, 40)) != None) )
			CameraLocation = HitLocation;

    CameraRotation = Normalize(PC.Rotation + PC.ShakeRot);
    CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
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

// - Update the data for a single animdata object.
simulated function UpdateAnimData(out AnimData Data, float Deltatime)
{

	local float key;
	if (Data.key >= Data.Value.Length)
		return;

	Key = Data.Key;

	if ( Data.Delay[Key] <= 0 )		// Make sure we aren't delaying this object
	{
		if ( Data.Time[Key] > 0 )		// Current keyframe
		{

			// Prefigure the constraint check for later on (ie: are we increasing or decreasing towards the Dest.
			// The constraint is critical for fades.

			if ( Data.Value[Key] < Data.Dest[Key] )
			{
				// Interpolate

				Data.Value[Key] += (Data.Dest[Key] - Data.Value[Key]) * (DeltaTime / Data.Time[Key]);
				if (Data.Value[Key] > Data.Dest[Key])
					Data.Value[Key] = Data.Dest[Key];
			}
			else
			{
				// Interpolate

				Data.Value[Key] += (Data.Dest[Key] - Data.Value[Key]) * (DeltaTime / Data.Time[Key]);
				if (Data.Value[Key] < Data.Dest[Key])
					Data.Value[Key] = Data.Dest[Key];
			}

			Data.Time[Key] -= Deltatime;
		}
		else
		{
			// Trigger an event if the frame changes

			AnimFrameChange(Data.Tags[Key]);
	    	Data.Key++;
		}

	}
	else
		Data.Delay[Key]-= DeltaTime;		// Count down the delay

}

// ClearAnimData - Scrubs the various arrays inside the struct
simulated function ClearAnimData(out AnimData Data)
{
	Data.Value.Remove(0,Data.Value.Length);
	Data.Dest.Remove(0,Data.Dest.Length);
	Data.Time.Remove(0,Data.Time.Length);
	Data.Delay.Remove(0,Data.Delay.Length);
	Data.Tags.Remove(0,Data.Tags.Length);
	Data.Key=0;
}

// AddAnimData - Adds data to the array.  Have to do it here since object creation in defprops doesn't
// support arrays within a struct
simulated function AddAnimData(out AnimData Data, float NewValue, float NewDest, float NewTime, optional float NewDelay, optional name NewTag)
{
	local int key;

	Key = Data.Value.Length + 1;
	Data.Value.Length 	= Key; 	Data.Value[Key-1] 	= NewValue;
	Data.Dest.Length 	= Key;	Data.Dest[Key-1] 	= NewDest;
	Data.Time.Length 	= Key;	Data.Time[Key-1]	= NewTime;
	Data.Delay.Length 	= Key;	Data.Delay[Key-1]	= NewDelay;
	Data.Tags.Length 	= Key;  Data.Tags[Key-1]	= NewTag;
}

// Value - Returns the current value of the AnimStruct.  If it's past the final key-frame,
// it returns the final values.
simulated function float Value(AnimData Data)
{
	if (Data.Key<Data.Value.Length)
		return Data.Value[Data.Key];
	else
		return Data.Value[Data.Value.Length-1];
}

// AnimFrameChange - Called when a the fame of a AnimData struc in incremented.

simulated function AnimFrameChange(name Tag)
{
	if (Tag=='Circ0Done')
	{
		SpinCircles[0].TexRotationType= TR_ConstantlyRotating;
		SpinCircles[0].Rotation.Yaw = 24000;
	}
	else if (Tag=='Circ1Done')
	{
		SpinCircles[1].TexRotationType= TR_ConstantlyRotating;
		SpinCircles[1].Rotation.Yaw = -24000;
	}
}

// Animate - Animate the various components of the crosshair
simulated function Animate(Canvas Canvas, float DeltaTime)
{
	local int i;

	for (i=0;i<2;i++)
	{
		UpdateAnimData(SpinScale[i],DeltaTime);
		UpdateAnimData(SpinFade[i],DeltaTime);
		UpdateAnimData(SpinRot[i],DeltaTime);

		if ( SpinCircles[i].TexRotationType == TR_FixedRotation )
			SpinCircles[i].Rotation.Yaw = Value(SpinRot[i]);
	}

	UpdateAnimData(BracketScale,DeltaTime);
	UpdateAnimData(BracketFade,DeltaTime);
	UpdateAnimData(MissileFade,DeltaTime);
}



simulated function ResetAnimation()
{

	ClearAnimData(SpinScale[0]);
	ClearAnimData(SpinScale[1]);
	ClearAnimData(SpinFade[0]);
	ClearAnimData(SpinFade[1]);
	ClearAnimData(SpinRot[0]);
	ClearAnimData(SpinRot[1]);

	SpinCircles[0].TexRotationType = TR_FixedRotation;
	SpinCircles[1].TexRotationType = TR_FixedRotation;

	ClearAnimData(BracketScale);
	ClearAnimData(BracketFade);

    // Circile 0

	AddAnimData(SpinScale[0], 2.25, 0.65, 0.75,0.0);
	AddAnimData(SpinFade[0],1.0,255,0.5,0.0);
	AddAnimData(SpinRot[0],65535,49152,0.75,0.0,'Circ0Done');

	// Circle 1

	AddAnimData(SpinScale[1],2.25,1.3,0.75,0.25);
	AddAnimData(SpinFade[1],1.0,200,0.5,0.25);
	AddAnimData(SpinFade[1],255,150,0.25,0.0);
	AddAnimData(SpinRot[1],0.0,16384,0.75,0.25,'Circ1Done');

	// Circle 2

	AddAnimData(BracketScale, 0.1, 0.0, 0.35, 0.5);
	AddAnimData(BracketFade,1.0,255,0.15,0.5);

	LastMissileCnt=0;

}

simulated function DrawBrackets(Canvas Canvas, float CX, float CY, float Scale)
{
	local float x,y;

	X = CX - (16*Scale) - (19*Scale) - ( Canvas.ClipX * Value(BracketScale) );
	Y = CY - (30*Scale);

	Canvas.SetPos(X,Y);
	Canvas.DrawTile(Brackets,19*Scale,64*Scale,19,30,19,64);
	X = CX + (16*Scale) + ( Canvas.ClipX * Value(BracketScale) );
	Canvas.SetPos(X,Y);
	Canvas.DrawTile(Brackets,19*Scale,60*Scale,88,30,19,64);

}

simulated function DrawMissiles(Canvas Canvas, float CX, float CY, float scale)
{

	local int h,MissileCnt;
	local float x1,x2,y;

	MissileCnt = ONSDualACSideGun(Weapons[0]).LoadedShotCount;
	h = (MissileCnt / 2) * 8;
	if (h>0)
	{
    	if (LastMissileCnt!=h)
    	{
    	 	ClearAnimData(MissileFade);
			AddAnimData(MissileFade,0,255,0.33,0.10);
    	}

		y  = (CY + (32*Scale) - (h*Scale) );
		x1 = (CX - (51*Scale));
		x2 = (CX + (18*Scale));

		Canvas.SetPos(x1,y);
		Canvas.DrawTile(MissileTick,32*Scale,h*Scale,0,64-h,32,h);
		Canvas.SetPos(x2,y);
		Canvas.DrawTile(MissileTick,32*Scale,h*Scale,32,64-h,-32,h);

		Canvas.SetDrawColor(255,255,255,Value(MissileFade));

		Canvas.SetPos(x1,y);
		Canvas.DrawTile(MissileTick,32*Scale,8*Scale,0,64-h,32,8);
		Canvas.SetPos(x2,y);
		Canvas.DrawTile(MissileTick,32*Scale,8*Scale,32,64-h,-32,8);
	}
	LastMissileCnt = h;
}

simulated function DrawHUD(Canvas Canvas)
{
	local vector X,Y,Z, Dir, LockedTarget;
	local float Dist,scale,xl,yl,posy;
	local PlayerController PC;
//	local ONSHudOnslaught H;
	local HudCDeathmatch H;

	local bool bIsLocked;
	local float DeltaTime;

	local string CoPilot;

	if ( !ONSDualACSideGun(Weapons[0]).bLocked )
		super.DrawHud(Canvas);

    DeltaTime = Level.TimeSeconds - LastHudRenderTime;
	LastHudRenderTime = Level.TimeSeconds;

	bIsLocked = ONSDualACSideGun(Weapons[0]).bLocked;

	PC = PlayerController(Owner);
	if (PC==None)
		return;

//	H = ONSHudOnslaught(PC.MyHud);
	H = HudCDeathmatch(PC.MyHud);
	if (H==None)
		return;

	if ( ONSDualACSideGun(Weapons[0]).bLocked )
	{
		if (bIsLocked != bLastLockType)	// Initialize the Crosshair
			ResetAnimation();

		Animate(Canvas,DeltaTime);

	    GetAxes(PC.GetViewRotation(), X,Y,Z);

	    LockedTarget = ONSDualACSideGun(Weapons[0]).LockedTarget;
	    if (OldLockedTarget != LockedTarget)
			PlaySound(Sound'CicadaSnds.Hud.TargetLock', SLOT_None, 2.0);

	    OldLockedTarget = LockedTarget;

		Dir = LockedTarget - Location;
		Dist = VSize(Dir);
		Dir = Dir/Dist;

	    if ( (Dir dot X) > 0.4 )
	    {
			// Draw the Locked on Symbol
			Dir = Canvas.WorldToScreen( LockedTarget );
			scale = float(Canvas.SizeX) / 1600;

			// new Stuff

			Canvas.SetDrawColor( 64,255,64,Value(SpinFade[0]) );
			CenterDraw(Canvas, SpinCircles[0], Dir.X, Dir.Y, Value(SpinScale[0])*Scale, Value(SpinScale[0])*Scale );
			Canvas.SetDrawColor(64,255,64,Value(SpinFade[1]) );
			CenterDraw(Canvas, SpinCircles[1], Dir.X, Dir.Y, Value(SpinScale[1])*Scale, Value(SpinScale[1])*Scale );

			Canvas.SetDrawColor(128,255,128,Value(BracketFade));
			DrawBrackets(Canvas,Dir.X,Dir.Y,Scale);
			DrawMissiles(Canvas,Dir.X,Dir.Y,Scale);

		}
	}

	bLastLockType = bIsLocked;

	HudMissileCount.Tints[0] = H.HudColorRed;
	HudMissileCount.Tints[1] = H.HudColorBlue;

	H.DrawSpriteWidget( Canvas, HudMissileCount );
	H.DrawSpriteWidget( Canvas, HudMissileIcon );
	HudMissileDigits.Value = ONSDualACSideGun(Weapons[0]).LoadedShotCount;
	H.DrawNumericWidget(Canvas, HudMissileDigits, DigitsBig);

	if (WeaponPawns[0]!=none && WeaponPawns[0].PlayerReplicationInfo!=None)
	{
		CoPilot = WeaponPawns[0].PlayerReplicationInfo.PlayerName;
		Canvas.Font = H.GetMediumFontFor(Canvas);
		Canvas.Strlen(CoPilot,xl,yl);
		posy = Canvas.ClipY*0.7;
		Canvas.SetPos(Canvas.ClipX-xl-5, posy);//(Canvas.ClipY/2) - (YL/2));
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.DrawText(CoPilot);

		Canvas.Font = H.GetConsoleFont(Canvas);
        Canvas.StrLen(CoPilotLabel,xl,yl);
        Canvas.SetPos(Canvas.ClipX-xl-5,posy-5-yl);
		Canvas.SetDrawColor(160,160,160,255);
		Canvas.DrawText(CoPilotLabel);
	}

}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if (Role == ROLE_Authority)
	{
		if (WeaponPawns[0]!=None)
		    WeaponPawns[0].Gun.SetOwner(self);

		if (Weapons.Length == 2 && ONSLinkableWeapon(Weapons[0]) != None)
    {
        ONSLinkableWeapon(Weapons[0]).ChildWeapon = Weapons[1];
        if (ONSDualACSideGun(Weapons[1]) != None)
            ONSDualACSideGun(Weapons[1]).bSkipFire = True;

	        if (ONSDualACSideGun(Weapons[0]) != None)
	            ONSDualACSideGun(Weapons[0]).bFiresRight = true;
	    }

    }
}

function DriverLeft()
{
    Super.DriverLeft();
    Weapons[1].bActive = False;
}

simulated function Tick(float DeltaTime)
{
	local rotator 	Adjusted,EnginePitch;
	local int 		Yaw;
	local actor		HitActor;
	local vector	HitLocation, HitNormal;
	local float GroundDist;

	super.Tick(DeltaTime);

	if ( !IsVehicleEmpty() )
		Enable('tick');

	if ( (Bot(Controller) != None) && !Controller.InLatentExecution(Controller.LATENT_MOVETOWARD)  )
	{
		if ( Rise < 0 )
		{
			if ( Velocity.Z < 0 )
			{
				if ( Velocity.Z < -2000 )
					Rise = -0.1;

				// FIX - use dist to adjust down as get closer
				HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,2000), Location, false);
				if ( HitActor != None )
				{
					GroundDist = Location.Z - HitLocation.Z;
					if ( GroundDist/(-1*Velocity.Z) < 0.85 )
						Rise = 1.0;
				}
			}
		}
		else if ( Rise == 0 )
		{
			if ( !FastTrace(Location - vect(0,0,300),Location) )
				Rise = FClamp((-1 * Velocity.Z)/MaxRiseForce,0.f,1.f);
		}
	}
	// Adjust the various effects

    if (Level.NetMode != NM_DedicatedServer)
	{
		if (LastThrust != CopState.ServerThrust)
		{
			if (CopState.ServerThrust<128)
				DesiredPitch = -10240;
			else if (CopState.ServerThrust>128)
				DesiredPitch = 10240;
			else
				DesiredPitch = 0;

			PitchTime = 1.0;
			LastThrust = CopState.ServerThrust;
		}
		if (CurrentPitch != DesiredPitch)
		{

			CurrentPitch += (DesiredPitch - CurrentPitch) * (DeltaTime / PitchTime);
			PitchTime -= DeltaTime;

			if (PitchTime<=0 || DesiredPitch == CurrentPitch)
			{
				PitchTime = 0.0;
				DesiredPitch = CurrentPitch;
			}
		}

		FanYaw.Yaw += FanYawRate * DeltaTime;

		EnginePitch.Pitch = CurrentPitch;
		SetBoneRotation('Engines',	 EnginePitch);
		SetBoneRotation('Fans_Left', FanYaw);
		SetBoneRotation('Fans_Right',FanYaw);

		Yaw = Rotation.Yaw;	// Give some deadzone
		if (Yaw != LastYaw)
		{
			if ( (Yaw>0 && LastYaw>0) || (Yaw<0 && LastYaw<0) )	// Skip sign changes
			{
				if (LastYaw>Yaw)
					DesiredYaw=-6144;
				else
					DesiredYaw=6144;

				YawTime = 1.0;
			}
		}
		else
		{
			DesiredYaw=0;
			YawTime = 1.0;
		}

		LastYaw = Yaw;
		if (DesiredYaw != TailYaw.Yaw)
		{
			TailYaw.Yaw += (DesiredYaw-TailYaw.Yaw) * (DeltaTime/YawTime);
			YawTime-= DeltaTime;

			if (YawTime<=0 || DesiredYaw == TailYaw.Yaw)
			{
				YawTime = 0.0;
				TailYaw.Yaw = DesiredYaw;
			}
		}

		Adjusted = TailYaw;

		if (Adjusted.Yaw < -2048)
			Adjusted.Yaw += 2048;

		else if (Adjusted.Yaw > 2048)
			Adjusted.Yaw -= 2048;

		else
			Adjusted.Yaw = 0;

		SetBoneRotation('Rudder',Adjusted);
	}
}

simulated event DrivingStatusChanged()
{
	local vector RotX, RotY, RotZ;
	local int i;

	super(ONSChopperCraft).DrivingStatusChanged();

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{
        GetAxes(Rotation,RotX,RotY,RotZ);

        if (TrailEffects.Length == 0)
        {
            TrailEffects.Length = TrailEffectPositions.Length;

        	for(i=0;i<TrailEffects.Length;i++)
            	if (TrailEffects[i] == None)
            	{
                	TrailEffects[i] = spawn(TrailEffectClass, self,, Location + (TrailEffectPositions[i] >> Rotation) );
                	TrailEffects[i].SetBase(self);
                    TrailEffects[i].SetRelativeRotation( rot(-16384,32768,0) );
                }
        }
    }
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
    	{
        	for(i=0;i<TrailEffects.Length;i++)
        	   TrailEffects[i].Destroy();

        	TrailEffects.Length = 0;
        }
    }
}

// Check all of the active decoys and see if any take effect.

event bool VerifyLock(actor Aggressor, out actor NewTarget)
{
	local int i;

	for (i=0;i<Decoys.Length;i++)
	{
		if ( Decoys[i].CheckRange(Aggressor) )
		{
			NewTarget = Decoys[i];
			return false;
		}
	}

	return true;
}

function Vehicle FindEntryVehicle(Pawn P)
{
	local Bot B, S;

	B = Bot(P.Controller);
	if ( (B == None) || !IsVehicleEmpty() || (WeaponPawns[0].Driver != None) )
		return Super.FindEntryVehicle(P);

	for ( S=B.Squad.SquadMembers; S!=None; S=S.NextSquadMember )
	{
		if ( (S != B) && (S.RouteGoal == self) && S.InLatentExecution(S.LATENT_MOVETOWARD)
			&& ((S.MoveTarget == self) || (Pawn(S.MoveTarget) == None)) )
			return WeaponPawns[0];
	}
	return Super.FindEntryVehicle(P);
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function float RangedAttackTime()
{
	local ONSDualACSideGun G;

	G = ONSDualACSideGun(Weapons[0]);
	if ( G.LoadedShotCount > 0 )
		return (0.05 + (G.MaxShotCount - G.LoadedShotCount) * G.FireInterval);
	return 1;
}

function ShouldTargetMissile(Projectile P)
{
}

// LockOnWarning() called every LockWarningInterval when bEnemyLockedOn is true (on server/standalone)
event LockOnWarning()
{
	local	class<LocalMessage>	LockOnClass;
	local   PlayerController PC;
	local  byte LockNum;

	if ( bHeatSeeker )
	{
		LockNum = 31;
		bHeatSeeker = false;
	}
	else
		LockNum = 12;

	LockOnClass = class<LocalMessage>(DynamicLoadObject(LockOnClassString, class'class'));

	PC = PlayerController(Controller);
	if (PC!=None)
		PC.ReceiveLocalizedMessage(LockOnClass, LockNum);

	if (WeaponPawns[0]!=None)
	{
		PC = PlayerController(WeaponPawns[0].Controller);
		if (PC!=None)
			PC.ReceiveLocalizedMessage(LockOnClass, LockNum);
	}

    LastLockWarningTime = Level.TimeSeconds;
}

function IncomingMissile(Projectile P)
{
	bHeatSeeker = true;
	if ( WeaponPawns.Length > 0 )
		ONSDualACGatlingGunPawn(WeaponPawns[0]).IncomingMissile(P);
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    bDriving = False;
    Super.Died(Killer, damageType, HitLocation);
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'VMWeaponsSM.PlayerWeaponsGroup.bomberBomb');

    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.CicadaGreen');
    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.CicadaTan');
    L.AddPrecacheMaterial(Material'ONSInterface-TX.tankBarrelAligned');
    L.AddPrecacheMaterial(Material'CicadaTex.HUD.RocketIcon');
    L.AddPrecacheMaterial(Material'VMWeaponsTX.PlayerWeaponsGroup.bomberBomb');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore2Ga');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Cicada.MissileTrail1a');
    L.AddPrecacheMaterial(Material'CicadaTex.HUD.ONS_Cic_Circle');
    L.AddPrecacheMaterial(Material'CicadaTex.HUD.ONS_Cic_Brackets');
    L.AddPrecacheMaterial(Material'XEffectMat.Ion.painter_beam');
    L.AddPrecacheMaterial(Material'CicadaTex.HUD.ONS_Cic_Missles');
    L.AddPrecacheMaterial(Material'XGameTextures.SuperPickups.DOMpointLINESg');
    L.AddPrecacheMaterial(Material'Turrets.Huds.TurretHud2');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Cicada.LongSpark');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaFlare');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'VMWeaponsSM.PlayerWeaponsGroup.bomberBomb');

	Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.CicadaGreen');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.CicadaTan');
    Level.AddPrecacheMaterial(Material'ONSInterface-TX.tankBarrelAligned');
    Level.AddPrecacheMaterial(Material'CicadaTex.HUD.RocketIcon');
    Level.AddPrecacheMaterial(Material'VMWeaponsTX.PlayerWeaponsGroup.bomberBomb');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore2Ga');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Cicada.MissileTrail1a');
    Level.AddPrecacheMaterial(Material'CicadaTex.HUD.ONS_Cic_Circle');
    Level.AddPrecacheMaterial(Material'CicadaTex.HUD.ONS_Cic_Brackets');
    Level.AddPrecacheMaterial(Material'XEffectMat.Ion.painter_beam');
    Level.AddPrecacheMaterial(Material'CicadaTex.HUD.ONS_Cic_Missles');
    Level.AddPrecacheMaterial(Material'XGameTextures.SuperPickups.DOMpointLINESg');
    Level.AddPrecacheMaterial(Material'Turrets.Huds.TurretHud2');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Cicada.LongSpark');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaFlare');

	Super.UpdatePrecacheMaterials();
}

DefaultProperties
{
    Mesh=Mesh'ONSBPAnimations.DualAttackCraftMesh'
    Begin Object Class=KarmaParamsRBFull Name=KParams0
		KStartEnabled=True
		KFriction=0.5
		KLinearDamping=0.0
		KAngularDamping=0.0
		KImpactThreshold=300
		bKNonSphericalInertia=True
        bHighDetailOnly=False
        bClientOnly=False
		bKDoubleTickRate=True
		bKStayUpright=True
		bKAllowRotate=True
		KInertiaTensor(0)=1.0
		KInertiaTensor(1)=0.0
		KInertiaTensor(2)=0.0
		KInertiaTensor(3)=3.0
		KInertiaTensor(4)=0.0
		KInertiaTensor(5)=3.5
		KCOMOffset=(X=-0.25,Y=0.0,Z=0.0)
		KActorGravScale=0.0
		KMaxSpeed=2000.0
		bDestroyOnWorldPenetrate=True
		bDoSafetime=True
        Name="KParams0"
    End Object

	CollisionRadius=+240.0

    MaxRiseForce=200.0
    MaxStrafeForce=65.0
    MaxThrustForce=80.0
	LongDamping=0.3

    Health=500
    HealthMax=500

    DriverWeapons(0)=(WeaponClass=class'OnslaughtBP.ONSDualACSideGun',WeaponBone=RightRLAttach);
    DriverWeapons(1)=(WeaponClass=class'OnslaughtBP.ONSDualACSideGun',WeaponBone=LeftRLAttach);
    PassengerWeapons(0)=(WeaponPawnClass=class'OnslaughtBP.ONSDualACGatlingGunPawn',WeaponBone=GatlingGunAttach);
    TPCamWorldOffset=(Z=350)
    FanYawRate=98000

    RollTorqueMax=100
    RollTorqueStrafeFactor=100
    RollTorqueTurnFactor=750

	TrailEffectPositions(0)=(X=250,Y=-20,Z=10);
   	TrailEffectPositions(1)=(X=250,Y=20,Z=10);

    RedSkin=texture'ONSBPTextures.CicadaTan'
    BlueSkin=texture'ONSBPTextures.CicadaGreen'

	IdleSound=sound'CicadaSnds.CicadaIdle'
	StartUpSound=sound'CicadaSnds.CicadaStartUp'
	ShutDownSound=sound'CicadaSnds.CicadaShutDown'

	SoundVolume=255
	SoundRadius=300

	VehiclePositionString="in a Cicada"
	VehicleNameString="Cicada"


	EntryPosition=(X=0,Y=0,Z=-20)
	EntryRadius=300

	ExitPositions(0)=(X=0,Y=-400,Z=100)
	ExitPositions(1)=(X=0,Y=400,Z=100)
	ExitPositions(2)=(X=-600,Y=0,Z=100)
	PushForce=200000.0


	HudMissileCount=(WidgetTexture=Texture'HudContent.Generic.HUD',PosX=1.0,PosY=1.0,DrawPivot=DP_LowerRight,RenderStyle=STY_Alpha,TextureCoords=(X1=0,Y1=110,X2=166,Y2=163),TextureScale=0.53,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,B=255,A=200),Tints[1]=(G=255,R=255,B=255,A=200))
	HudMissileIcon=(WidgetTexture=Texture'CicadaTex.Hud.RocketIcon',PosX=1.0,PosY=1.0,DrawPivot=DP_LowerRight,OffsetX=-15,RenderStyle=STY_Alpha,TextureCoords=(X1=0,Y1=0,X2=32,Y2=64),TextureScale=0.53,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,B=255,A=200),Tints[1]=(G=255,R=255,B=255,A=200))
	HudMissileDigits=(RenderStyle=STY_Alpha,TextureScale=0.49,DrawPivot=DP_MiddleLeft,PosX=0.861,PosY=1.0,OffsetX=20,OffsetY=-29,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
	DigitsBig=(DigitTexture=Texture'HudContent.Generic.HUD',TextureCoords[0]=(X1=0,Y1=0,X2=38,Y2=38),TextureCoords[1]=(X1=39,Y1=0,X2=77,Y2=38),TextureCoords[2]=(X1=78,Y1=0,X2=116,Y2=38),TextureCoords[3]=(X1=117,Y1=0,X2=155,Y2=38),TextureCoords[4]=(X1=156,Y1=0,X2=194,Y2=38),TextureCoords[5]=(X1=195,Y1=0,X2=233,Y2=38),TextureCoords[6]=(X1=234,Y1=0,X2=272,Y2=38),TextureCoords[7]=(X1=273,Y1=0,X2=311,Y2=38),TextureCoords[8]=(X1=312,Y1=0,X2=350,Y2=38),TextureCoords[9]=(X1=351,Y1=0,X2=389,Y2=38),TextureCoords[10]=(X1=390,Y1=0,X2=428,Y2=38))
	LockedTexture=texture'CicadaTex.CicadaLockOn'
	LockedEffect=TexRotator'Hudcontent.rotDomRing'
	LockedMsg=" Locked "

	Begin Object Class=TexRotator name=CicCircle0
		TexRotationType=TR_FixedRotation
		UOffset=32
		VOffset=32
		Material=texture'CicadaTex.HUD.ONS_Cic_Circle'
	End Object
	SpinCircles(0)=CicCircle0

	Begin Object Class=TexRotator name=CicCircle1
		TexRotationType=TR_FixedRotation
		UOffset=32
		VOffset=32
		Material=texture'CicadaTex.HUD.ONS_Cic_Circle'
	End Object
	SpinCircles(1)=CicCircle1

	Brackets=texture'CicadaTex.HUD.ONS_Cic_Brackets'
	MissileTick=texture'CicadaTex.HUD.ONS_Cic_Missles'

	DestroyedVehicleMesh=StaticMesh'ONSBP_DestroyedVehicles.Cicada.DestroyedCicada'
    DestructionEffectClass=class'Onslaught.ONSVehicleExplosionEffect'
    DestructionLinearMomentum=(Min=250000,Max=400000)
    DestructionAngularMomentum=(Min=100,Max=150)
    DisintegrationHealth=-100
   	DisintegrationEffectClass=class'OnslaughtBP.ONSDualACDeathExp'

	CoPilotLabel="Gunner"

}
