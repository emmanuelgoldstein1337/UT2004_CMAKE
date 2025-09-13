//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT2K4Movies extends ModsAndDemosTabs;

var automated GUISectionBackground sb_Maps, sb_Preview;
var automated AltSectionBackground sb_Scroll;

var automated GUIScrollTextBox  lb_MapDesc;
var automated GUIListBox   		lb_Maps;
var automated GUIImage          i_MapPreview;
var automated GUILabel          l_MapAuthor,  l_NoPreview;

var array<CacheManager.MapRecord> Maps;

struct DefItem
{
	var localized string MapName;
	var localized string Title;
    var localized string Author;
};

var array<DefItem> DefaultItems;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	Super.InitComponent(MyController,MyOwner);

	for (i=0;i<DefaultItems.Length;i++)
		lb_Maps.List.Add(DefaultItems[i].title,,""$((i+1)*-1));

	class'CacheManager'.static.GetMapList(Maps,"MOV");
	for (i=0;i<Maps.Length;i++)
	{
		if ( !DefaultMovie(Maps[i].MapName) )
		{
			lb_Maps.List.Add(Maps[i].FriendlyName,,""$i);
		}
	}

	sb_Maps.ManageComponent(lb_Maps);
	sb_Scroll.ManageComponent(lb_MapDesc);


	lb_Maps.OnChange=MapListChange;
	MapListChange(lb_Maps);

	MyPage.MyFooter.b_Movie.OnClick = MovieClick;

}


function bool DefaultMovie(string Mov)
{
	local int i;
	for (i=0;i<DefaultItems.Length;i++)
		if (DefaultItems[i].MapName ~= mov)
			return true;

	return false;
}

function string GetMovieInfo(string Index,string prop)
{
	local int i;
	i = int(Index);

	if (i>=0)
	{
		if (prop=="author")
			return Maps[i].Author;
		if (prop=="desc")
			return Maps[i].Description;
		if (prop=="map")
			return Maps[i].MapName;
		if (prop=="screen")
			return Maps[i].ScreenshotRef;
	}
	else
	{
		i = abs(i);
		if (prop=="author")
			return DefaultItems[i-1].Author;
		if (prop=="desc")
			return DefaultItems[i-1].Title$".";
		if (prop=="map")
			return DefaultItems[i-1].MapName;
	}
	return "";
}

function MapListChange(GUIComponent Sender)
{
	l_MapAuthor.Caption = GetMovieInfo(lb_Maps.List.GetExtra(),"author");
	lb_MapDesc.SetContent(GetMovieInfo(lb_Maps.List.GetExtra(),"desc"));
	UpdateScreenshot( GetMovieInfo(lb_Maps.List.GetExtra(),"screen") );
}

function UpdateScreenshot(string ScreenShotRef)
{
	local Material Screenie;

    Screenie = Material(DynamicLoadObject(ScreenshotRef, class'Material'));
    i_MapPreview.Image = Screenie;
    l_NoPreview.SetVisibility( Screenie == none );
    i_MapPreview.SetVisibility( Screenie != None );
}


function bool MovieClick(GUIComponent Sender)
{
	Console(Controller.Master.Console).DelayedConsoleCommand("open"@GetMovieInfo(lb_Maps.List.GetExtra(),"map")$"?game=");
    return true;
}


defaultproperties
{
    Begin Object class=GUISectionBackground Name=sbMaps
		WinWidth=0.482149
		WinHeight=0.523611
		WinLeft=0.016993
		WinTop=0.018125
		Caption="Movie Selection"
		bFillClient=true
    End Object
    sb_Maps=sbMaps

    Begin Object Class=GUIListBox Name=lbMaps
		WinWidth=0.422481
		WinHeight=0.449870
		WinLeft=0.045671
		WinTop=0.169272
        bVisibleWhenEmpty=true
        Hint="Click a movie to see a preview and description.  Double-click to view it."
        StyleName="NoBackground"
        TabOrder=0
        bBoundToParent=false
        bScaleToParent=false
    End Object
    lb_Maps=lbMaps

    Begin Object class=GUISectionBackground Name=sbPreview
		WinWidth=0.470899
		WinHeight=0.527876
		WinLeft=0.515743
		WinTop=0.018125
		Caption="Preview"
		bFillClient=true
    End Object
    sb_Preview=sbPreview

    Begin Object Class=GUILabel Name=lNoPreview
		WinWidth=0.372002
		WinHeight=0.357480
		WinLeft=0.562668
		WinTop=0.107691
        TextFont="UT2HeaderFont"
        TextAlign=TXTA_Center
        VertAlign=TXTA_Center
        bMultiline=True
        bTransparent=False
        TextColor=(R=247,G=255,B=0,A=255)
        Caption="No Preview Available"
    End Object
    l_NoPreview=lNoPreview

    Begin Object Class=GUIImage Name=iMapPreview
		WinWidth=0.372002
		WinHeight=0.357480
		WinLeft=0.562668
		WinTop=0.107691
        ImageColor=(R=255,G=255,B=255,A=255)
        ImageStyle=ISTY_Scaled
        ImageRenderStyle=MSTY_Normal
        RenderWeight=0.2
    End Object
    i_MapPreview=iMapPreview

    Begin Object class=GUILabel Name=MapAuthorLabel
        Caption=""
        TextAlign=TXTA_Center
        StyleName="TextLabel"
		WinWidth=0.426180
		WinHeight=0.032552
		WinLeft=0.538209
		WinTop=0.467658
        RenderWeight=0.3
    End Object
    l_MapAuthor=MapAuthorLabel


	Begin Object class=AltSectionBackground name=sbScroll
		WinWidth=0.967924
		WinHeight=0.421870
		WinLeft=0.019970
		WinTop=0.561207
		Caption="Movie Description"
		bFillClient=true
	End Object
	sb_Scroll=sbScroll

    Begin Object Class=GUIScrollTextBox Name=lbMapDesc
		WinWidth=0.379993
		WinHeight=0.268410
		WinLeft=0.561065
		WinTop=0.628421
        CharDelay=0.0025
        EOLDelay=0.5
        bNeverFocus=true
        StyleName="NoBackground"
        bTabStop=False
    End Object
    lb_MapDesc=lbMapDesc
 	Tag=4

	DefaultItems(0)=(MapName="MOV-UT2004-Intro",Title="UT2004 Single Player Introduction Movie",Author="Epic Games")
	DefaultItems(1)=(MapName="MOV-UT2-Intro",Title="UT2003 Single Player Introduction Movie",Author="Epic Games")
	DefaultItems(2)=(MapName="TUT-BR",Title="Bombing Run Tutorial",Author="Epic Games")
	DefaultItems(3)=(MapName="TUT-CTF",Title="Capture the Flag Tutorial",Author="Epic Games")
	DefaultItems(4)=(MapName="TUT-DM",Title="Deathmatch Tutorial",Author="Epic Games")
	DefaultItems(5)=(MapName="TUT-DOM",Title="Double Domination Tutorial",Author="Epic Games")
	DefaultItems(6)=(MapName="TUT-ONS",Title="Onslaught Tutorial",Author="Epic Games")
}
