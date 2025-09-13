//====================================================================
//  xVoting.MapVotingPage
//  Map Voting page.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class MapVotingPage extends VotingPage;

var automated MapVoteMultiColumnListBox      lb_MapListBox;
var automated MapVoteCountMultiColumnListBox lb_VoteCountListBox;
var automated moComboBox                     co_GameType;
var automated GUILabel                       l_Mode;
var automated GUIImage                       i_MapListBackground, i_MapCountListBackground;

// Localization
var localized string lmsgMapVotingDisabled, lmsgReplicationNotFinished, lmsgMapDisabled,
                     lmsgTotalMaps, lmsgMode[8];



//------------------------------------------------------------------------------------------------
function InternalOnOpen()
{
	local int i, d;

    if( MVRI == none || (MVRI != none && !MVRI.bMapVote) )
    {
		Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
		GUIQuestionPage(Controller.TopPage()).SetupQuestion(lmsgMapVotingDisabled, QBTN_Ok, QBTN_Ok);
		GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnOkButtonClick;
		return;
    }

	// check if all maps and gametypes have replicated
    if( MVRI.GameConfig.Length < MVRI.GameConfigCount || MVRI.MapList.Length < MVRI.MapCount )
    {
		Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
		GUIQuestionPage(Controller.TopPage()).SetupQuestion(lmsgReplicationNotFinished, QBTN_Ok, QBTN_Ok);
		GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnOkButtonClick;
		return;
    }

    for( i=0; i<MVRI.GameConfig.Length; i++ )
    	co_GameType.AddItem( MVRI.GameConfig[i].GameName, none, string(i));
    co_GameType.MyComboBox.List.SortList();

	t_WindowTitle.Caption = t_WindowTitle.Caption@"("$lmsgMode[MVRI.Mode]$")";

   	lb_MapListBox.LoadList(MVRI);
   	MapVoteCountMultiColumnList(lb_VoteCountListBox.List).LoadList(MVRI);

    lb_VoteCountListBox.List.OnDblClick = MapListDblClick;
    lb_VoteCountListBox.List.bDropTarget = True;

    lb_MapListBox.List.OnDblClick = MapListDblClick;
    lb_MaplistBox.List.bDropSource = True;
    co_GameType.OnChange = GameTypeChanged;
    f_Chat.OnSubmit = Submit;

    // set starting gametype to current
    d = co_GameType.MyComboBox.List.FindExtra(string(MVRI.CurrentGameConfig));
    if( d > -1 )
	   	co_GameType.SetIndex(d);
}
//------------------------------------------------------------------------------------------------
function Submit()
{
    SendVote(none);
}
//------------------------------------------------------------------------------------------------
function GameTypeChanged(GUIComponent Sender)
{
	local int GameTypeIndex;

	GameTypeIndex = int(co_GameType.GetExtra());
	if( GameTypeIndex > -1 )
	{
		lb_MapListBox.ChangeGameType( GameTypeIndex );
	    lb_MapListBox.List.OnDblClick = MapListDblClick;
	}
}
//------------------------------------------------------------------------------------------------
function OnOkButtonClick(byte bButton) // triggered by th GUIQuestionPage Ok Button
{
	Controller.CloseMenu(true);
}
//------------------------------------------------------------------------------------------------
function UpdateMapVoteCount(int UpdatedIndex, bool bRemoved)
{
	MapVoteCountMultiColumnList(lb_VoteCountListBox.List).UpdatedVoteCount(UpdatedIndex, bRemoved);
}
//------------------------------------------------------------------------------------------------
function bool MapListDblClick(GUIComponent Sender)
{
    SendVote(Sender);
    return true;
}
//------------------------------------------------------------------------------------------------
function SendVote(GUIComponent Sender)
{
    local int MapIndex,GameConfigIndex;

	if( Sender == lb_VoteCountListBox.List )
	{
		MapIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedMapIndex();
		if( MapIndex > -1)
	    {
		    GameConfigIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedGameConfigIndex();
		    if(MVRI.MapList[MapIndex].bEnabled || PlayerOwner().PlayerReplicationInfo.bAdmin)
		        MVRI.SendMapVote(MapIndex,GameConfigIndex);
		    else
				PlayerOwner().ClientMessage(lmsgMapDisabled);
		}
	}
	else
	{
    	MapIndex = MapVoteMultiColumnList(lb_MapListBox.List).GetSelectedMapIndex();
		if( MapIndex > -1)
	    {
		    GameConfigIndex = int(co_GameType.GetExtra());
		    if(MVRI.MapList[MapIndex].bEnabled || PlayerOwner().PlayerReplicationInfo.bAdmin)
		        MVRI.SendMapVote(MapIndex,GameConfigIndex);
		    else
				PlayerOwner().ClientMessage(lmsgMapDisabled);
		}
    }
}

function bool AlignBK(Canvas C)
{

	i_MapCountListBackground.WinWidth  = lb_VoteCountListbox.MyList.ActualWidth();
	i_MapCountListBackground.WinHeight = lb_VoteCountListbox.MyList.ActualHeight();
	i_MapCountListBackground.WinLeft   = lb_VoteCountListbox.MyList.ActualLeft();
	i_MapCountListBackground.WinTop    = lb_VoteCountListbox.MyList.ActualTop();

	i_MapListBackground.WinWidth  	= lb_MapListBox.MyList.ActualWidth();
	i_MapListBackground.WinHeight 	= lb_MapListBox.MyList.ActualHeight();
	i_MapListBackground.WinLeft  	= lb_MapListBox.MyList.ActualLeft();
	i_MapListBackground.WinTop	 	= lb_MapListBox.MyList.ActualTop();

	return false;
}
//------------------------------------------------------------------------------------------------
defaultproperties
{
    Begin Object Class=MapVoteCountMultiColumnListBox Name=VoteCountListBox
		WinWidth=0.96
		WinHeight=0.223770
		WinLeft=0.02
		WinTop=0.052930
        bVisibleWhenEmpty=true
        bScaleToParent=True
        bBoundToParent=True
        FontScale=FNS_Small
        HeaderColumnPerc(0)=0.40
        HeaderColumnPerc(1)=0.40
        HeaderColumnPerc(2)=0.20
    End Object
    lb_VoteCountListBox = VoteCountListBox

    Begin Object class=moComboBox Name=GameTypeCombo
		WinWidth=0.757809
		WinHeight=0.037500
		WinLeft=0.199219
		WinTop=0.334309
		Caption="Filter Game Type:"
        CaptionWidth=0.35
		bScaleToParent=True
    End Object
    co_GameType = GameTypeCombo

    Begin Object Class=MapVoteMultiColumnListBox Name=MapListBox
		WinWidth=0.96
		WinHeight=0.293104
		WinLeft=0.02
		WinTop=0.371020
        bVisibleWhenEmpty=true
        StyleName="ServerBrowserGrid"
        bScaleToParent=True
        bBoundToParent=True
        FontScale=FNS_Small
        HeaderColumnPerc(0)=0.60
        HeaderColumnPerc(1)=0.20
        HeaderColumnPerc(2)=0.20
    End Object
    lb_MapListBox = MapListBox

   	Begin Object Class=GUIImage Name=MapCountListBackground
		WinWidth=0.98
		WinHeight=0.223770
		WinLeft=0.01
		WinTop=0.052930
		Image=Material'2K4Menus.NewControls.NewFooter'
		ImageStyle=ISTY_Stretched
        OnDraw=AlignBK
	End Object
	i_MapCountListBackground=MapCountListBackground

   	Begin Object Class=GUIImage Name=MapListBackground
		WinWidth=0.98
		WinHeight=0.316542
		WinLeft=0.01
		WinTop=0.371020
		Image=Material'2K4Menus.NewControls.NewFooter'
		ImageStyle=ISTY_Stretched
	End Object
	i_MapListBackground=MapListBackground



    OnOpen=InternalOnOpen;

	lmsgMapVotingDisabled="Sorry, Map Voting has been disabled by the server administrator."
	lmsgReplicationNotFinished="Map data download in progress. Please try again later."
	lmsgMapDisabled="The selected Map is disabled."
	lmsgTotalMaps="%mapcount% Total Maps"
	lmsgMode(0)="Majority Mode"
	lmsgMode(1)="Majority & Elimination Mode"
	lmsgMode(2)="Score Mode"
	lmsgMode(3)="Score & Elimination Mode"
	lmsgMode(4)="Majority & Accumulation Mode"
	lmsgMode(5)="Majority & Accumulation & Elimination Mode"
	lmsgMode(6)="Score & Accumulation Mode"
	lmsgMode(7)="Score & Accumulation & Elimination Mode"
	WindowName="Map Voting"
}

