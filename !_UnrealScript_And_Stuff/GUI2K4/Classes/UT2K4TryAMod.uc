//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT2K4TryAMod extends LockedFloatingWindow;

var automated GUIScrollTextBox sb_Info;
var automated GUIImage i_bk;
var localized string InfoText, InfoCaption;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local eFontScale fs;
	Super.InitComponent(MyController, MyOwner);

	t_WindowTitle.Style = Controller.GetStyle("NoBackground",fs);
	i_FrameBG.SetVisibility(false);

	sb_Main.bBoundToParent = true;
	sb_Main.bScaleToParent = true;
	sb_Main.Caption = InfoCaption;
	sb_Main.SetPosition(0,0,1,1);
	sb_Main.ManageComponent(sb_Info);
	sb_Info.SetContent(InfoText);
	sb_Main.TopPadding=0.1;
	sb_Main.LeftPadding=0;
	sb_Main.RightPadding=0;
	b_Cancel.SetVisibility(false);

	b_Ok.SetPosition(0.38,0.811524,0.2,b_Ok.WinHeight);
}


defaultproperties
{
	Begin Object Class=GUIScrollTextBox Name=sbInfo
		bNoTeletype=true
		TextAlign=TXTA_Center
	    TabOrder=0
	    WinWidth=1
	    WinHeight=1
	    WinLeft=0
	    WinTop=0
	End Object
	sb_Info=sbInfo

	Begin Object Class=GUIImage Name=imgBack
		Image=material'2K4Menus.NewControls.NewFooter'
		ImageStyle=ISTY_Stretched
		ImageRenderStyle=MSTY_Alpha
		bBoundToParent=true
		bScaleToParent=true
		WinWidth=0.978125
		WinHeight=0.900000
		WinLeft=0.010937
		WinTop=0.050000
		RenderWeight=0.00001
		ImageColor=(R=255,G=255,B=255,A=180)
	End Object
	i_bk=imgBack;

	WinWidth=0.800000
	WinHeight=0.556250
	WinLeft=0.100000
	WinTop=0.195833

	DefaultWidth=0.800000
	DefaultHeight=0.556250
	DefaultLeft=0.100000
	DefaultTop=0.195833

	InfoText="At the bottom of the server browser, there is a checkbox marked [Show Standard Servers Only], which is checked by default.  If you uncheck this box, the server browser will display servers running gameplay modifications which may radically alter gameplay.  If you are looking for something different, try unchecking that box."
	InfoCaption="Special Message..."

	DesiredFade=150
	CurFade=200
	FadeTime=0.35


}
