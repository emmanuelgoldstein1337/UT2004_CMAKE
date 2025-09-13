//-----------------------------------------------------------
// Server Logo - This mutator allows admins to show a logo
// when a player connects.
//-----------------------------------------------------------
class MutServerLogo extends Mutator
	config;

var config string 	LogoTextureName;	// Name of the Texture to be displayed
var config color	LogoColor;			// Color to display it in (note, alpha can be faded
var config float  	LogoX, LogoY;		// Where to display it (<1 = %)
var config float	LogoScale;			// Scale of the image
var config float 	LogoFadeInTime, LogoVisTime, LogoFadeOutTime;	// How long to stay in each state

var config bool 	bHandleMOTD;		// Should we handle displaying the MOTD as well?

var config float	MOTDLeft, MOTDTop, MOTDWidth, MOTDHeight;		// Dims for the MOTD Background Image
var config float    MOTDHBorder, MOTDVBorder;						// How much space on each side
var config string 	MOTDBackgroundTextureName;						// Background Image
var config string	MOTDFontName;									// Font to use
var config color 	MOTDColor;										// Color to use
var config bool		bStretchNotScale;								// Stretch the Image, not scale it

var	Material LogoMaterial, MOTDMaterial;
var float Fade, FadeDest, FadeTime;
var float MOTDFade, MOTDFadeDest, MOTDFadeTime;
var int VisState; 					// 0=fade in, 1=vis, 2=fadeout
var float LastRenderedTime;

var Hud MyHud;
var string MOTD;

delegate OnCalcFadeAlpha(float DeltaTime);

replication
{
	reliable if (role==ROLE_Authority && bNetInitial && bNetDirty)
		LogoTextureName, LogoX, LogoY, LogoScale, LogoFadeInTime, LogoVisTime, LogoFadeOutTime, bHandleMOTD,
		MOTDHBorder, MOTDVBorder,
		MOTDLeft, MOTDTop, MOTDWidth, MOTDHeight, MOTDBackgroundTextureName, MOTDFontName, MOTDColor, bStretchNotScale;
}

function BeginPlay()
{
	super.BeginPlay();

	log("");
	log("====================");
	log(" Server Logo Active");
	log("====================");
	log("");
}
simulated event PostNetReceive()
{
	local PlayerController PC;

	LogoMaterial = Material(DynamicLoadObject(LogoTextureName,class'Material'));
	if (LogoMaterial != none)
	{

		if (bHandleMOTD)
			MOTDMaterial = material(dynamicLoadObject(MOTDBackgroundTextureName,class'material'));

		foreach AllActors(class'PlayerController', PC)
			if (PC.MyHud != none)
			{
				PC.MyHud.OnPostRender = HudPostRender;
				PC.MyHud.OnBuildMOTD  = HudBuildMOTD;
				MyHud = PC.MyHud;
			}

		// Setup Fade In

		LastRenderedTime = Level.TimeSeconds;

		if (LogoFadeInTime>0)
			FadeIn();
		else
			Visible();
	}
	else
		log("WARNING: Could not load Logo");
}

simulated function HUDBuildMOTD(HUD Sender)
{
	if ( Sender.PlayerOwner == none || Sender.PlayerOwner.GameReplicationInfo == none )
		return;

	Sender.bBuiltMOTD = true;
	MOTD = Sender.PlayerOwner.GameReplicationInfo.MessageOfTheDay;
}

simulated function HudPostRender(HUD Sender, Canvas C)
{
	local float oX,oY, aX,aY;
	local color oColor;

	if (Sender.PlayerOwner==none || Sender.PlayerOwner.Player==None || Sender.PlayerOwner.Player.GUIController==none)
		return;

	oX = C.CurX;
	oY = C.CurY;
	oColor = C.DrawColor;

	OnCalcFadeAlpha(Level.TimeSeconds - LastRenderedTime);
	LastRenderedTime = Level.TimeSeconds;
	C.DrawColor = LogoColor;
	C.DrawColor.A = Fade;

	if (LogoMaterial!=None)
	{
		if (LogoX<1)
			aX = C.ClipX * LogoX;
		else
			aX = LogoX;

		if (LogoY<1)
			aY = C.ClipY * LogoY;

		C.SetPos(aX,aY);
		C.DrawTileScaled(LogoMaterial, LogoScale, LogoScale);
	}

	C.SetPos(oX,oY);
	C.DrawColor = oColor;

	if (bHandleMOTD)
		DrawMOTD(Sender,C);
}

simulated function DrawMOTD(HUD Sender, Canvas C)
{
	local float l,t,w,h,xl,yl;
	local string MOTDText, MOTDLine;
	local plane OldCM;


	OldCM = C.ColorModulate;
	C.ColorModulate.X = 1;
	C.ColorModulate.Y = 1;
	C.ColorModulate.Z = 1;
	C.ColorModulate.W = Fade / 255;

	if (MOTDLeft<=1)
		l = C.ClipX * MOTDLeft;
	else
		l = MOTDLeft;

	if (MOTDTop<=1)
		t = C.ClipY * MOTDTop;
	else
		t = MOTDTop;

	if (MOTDWidth<=1)
		w = C.ClipX * MOTDWidth;
	else
		w = MOTDWidth;

	if (MOTDHeight<=1)
		h = C.ClipY * MOTDHeight;
	else
		h = MOTDHeight;

	// Draw the background

	if (MOTDMaterial!=None)
	{
		C.SetPos(l,t);
		if (bStretchNotScale)
			C.DrawTileStretched(MOTDMaterial, w,h);
		else
			C.DrawTile(MOTDMaterial,w,h,0,0,MOTDMaterial.MaterialUSize(),MOTDMaterial.MaterialVSize());
	}

	if (MOTDHBorder>0)
	{
		if (MOTDHBorder<1)
		{
			l += (C.ClipX * MOTDHBorder);
			w -= (C.ClipX * MOTDHBorder) *2;
		}
		else
		{
			l+= MOTDHBorder;
			W -= MOTDHBorder * 2;
		}
	}

	if (MOTDVBorder>0)
	{
		if (MOTDVBorder<1)
		{
			t += (C.ClipY * MOTDVBorder);
			h -= (C.ClipY * MOTDVBorder) *2;
		}
		else
		{
			t+= MOTDVBorder;
			w-= MOTDVBorder * 2;
		}
	}

    // Grab the font from the controller

	C.Font = GUIController(Sender.PlayerOwner.Player.GUIController).GetMenuFont(MOTDFontName).GetFont(C.ClipX);
	C.StrLen("Q,;WmM",xl,yl);
	yl *= 1.1;

	C.DrawColor = MOTDColor;


	// Draw the text

	MOTDText = MOTD;
	while (MOTDText != "")
	{
		C.SetPos(l,t);
		C.WrapText(MOTDText,MOTDLine,w,C.Font,1.0);
		C.DrawText(MOTDLine);
		t += yl;
	}

	C.ColorModulate = OldCM;
}

simulated function FadeIn()
{
    VisState = 0;
	Fade 	 = 0;
	FadeDest = LogoColor.A;
	FadeTime = LogoFadeInTime;

	OnCalcFadeAlpha = FadeInCalcAlpha;
}
simulated function FadeInCalcAlpha(float DeltaTime)
{
	Fade += (FadeDest - Fade) * (DeltaTime / FadeTime);
	FadeTime -= DeltaTime;
	if (Fade>=FadeDest)
	{
		Fade=FadeDest;
		Visible();
	}
}

simulated function Visible()
{
	OnCalcFadeAlpha = VisCalcAlpha;
	SetTimer(LogoVisTime,false);
}

simulated function Timer()
{
	if ( LogoFadeOutTime>0 )
		FadeOut();
	else
	{
		MyHud.OnPostRender = none;
		OnCalcFadeAlpha = none;
	}
}

simulated function VisCalcAlpha(float DeltaTime)
{
	Fade = LogoColor.A;
}

simulated function FadeOut()
{
	Fade = LogoColor.A;
	FadeDest = 0;
	FadeTime = LogoFadeOutTime;
	OnCalcFadeAlpha = FadeOutCalcAlpha;
}

simulated function FadeOutCalcAlpha(float DeltaTime)
{
	Fade += (FadeDest-Fade) * (DeltaTime / FadeTime);
	FadeTime -= DeltaTime;
	if (Fade<=0)
	{
		Fade = 0;
		MyHud.OnPostRender = none;
		OnCalcFadeAlpha = none;
	}
}

defaultproperties
{
	bAlwaysRelevant=true;
	bNetNotify=True
	RemoteRole=ROLE_SimulatedProxy

	IconMaterialName="MutatorArt.nosym"
    ConfigMenuClassName=""
    GroupName="Utility"
    FriendlyName="Server Logo"
    Description="Adds a graphical Server Logo on connect + Extended MOTD management."

	LogoScale=1;
	LogoX=0.0;
	LogoY=0.5;
	LogoColor=(R=255,G=255,B=255,A=255)
	LogoFadeInTime=3.0
	LogoVisTime=5.0
	LogoFadeOutTime=3.0

	bHandleMOTD=false;
	bStretchNotScale=false;
	MOTDLeft=0.25
	MOTDTop=0.25
	MOTDWidth=0.5
	MOTDHeight=0.5
	MOTDHBorder=14;
	MOTDVBorder=24;
	MOTDFontName="MediumFont"
	MOTDColor=(R=255,G=255,B=255,A=255)
	MOTDBackgroundTextureName="2K4MENUS.NewControls.Display95"

}
