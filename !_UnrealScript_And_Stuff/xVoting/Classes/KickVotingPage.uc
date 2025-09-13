//====================================================================
//  xVoting.KickVotingPage
//  Kick Voting page.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class KickVotingPage extends VotingPage;

var automated GUISectionBackground sb_List;
var automated KickVoteMultiColumnListBox lb_PlayerListBox;
var automated GUILabel         l_PlayerListTitle;
var automated GUIButton         b_Info, b_Kick;

// Localization
var localized string lmsgKickVotingDisabled;


function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);
	sb_List.ManageComponent(lb_PlayerListBox);
	sb_List.ImageOffset[1]=8;
}

//------------------------------------------------------------------------------------------------
function InternalOnOpen()
{
    if( MVRI == none || (MVRI != none && !MVRI.bKickVote) )
    {
		Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
		GUIQuestionPage(Controller.TopPage()).SetupQuestion(lmsgKickVotingDisabled, QBTN_Ok, QBTN_Ok);
		GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnOkButtonClick;
		return;
    }
    lb_PlayerListBox.List.OnDblClick = PlayerListDblClick;
    KickVoteMultiColumnList(lb_PlayerListBox.List).LoadPlayerList(MVRI);
    f_Chat.OnSubmit = SendKickVote;

	f_Chat.WinTop = 0.561457;
	f_Chat.WinHeight=0.432031;
}
//------------------------------------------------------------------------------------------------
function OnOkButtonClick(byte bButton) // triggered by th GUIQuestionPage Ok Button
{
	Controller.CloseAll(true,true);
}
//------------------------------------------------------------------------------------------------
function UpdateKickVoteCount(VotingHandler.KickVoteScore KVCData)
{
	KickVoteMultiColumnList(lb_PlayerListBox.List).UpdatedVoteCount(KVCData.PlayerID, KVCData.KickVoteCount);
}
//------------------------------------------------------------------------------------------------
function bool PlayerListDblClick(GUIComponent Sender)
{
	SendKickVote();
    return true;
}
//------------------------------------------------------------------------------------------------
function SendKickVote()
{
    local int PlayerID;

    PlayerID = KickVoteMultiColumnList(lb_PlayerListBox.List).GetSelectedPlayerID();
    if( PlayerID > -1 )
        MVRI.SendKickVote(PlayerID);
}
//------------------------------------------------------------------------------------------------

function bool InfoClick(GUIComponent Sender)
{
	lb_PlayerListBox.InternalOnClick(lb_PlayerListBox.ContextMenu,1);
	return true;
}


function bool KickClick(GUIComponent Sender)
{
	lb_PlayerListBox.InternalOnClick(lb_PlayerListBox.ContextMenu,0);
	return true;
}

defaultproperties
{
    OnOpen=InternalOnOpen;

    Begin Object Class=KickVoteMultiColumnListBox Name=PlayerListBoxControl
		WinWidth=0.473047
		WinHeight=0.481758
		WinLeft=0.254141
		WinTop=0.162239
        bVisibleWhenEmpty=true
        StyleName="ServerBrowserGrid"
    End Object
    lb_PlayerListBox = PlayerListBoxControl

	Begin Object Class=AltSectionBackground Name=ListBackground
		Caption=""
		WinWidth=0.953125
		WinHeight=0.461357
		WinLeft=0.023438
		WinTop=0.052083
		bBoundToParent=True
		bScaleToParent=True
		bFillClient=true
	End Object
	sb_List=ListBackground

	Begin Object Class=GUIButton Name=InfoButton
		Caption="Info"
		WinWidth=0.160075
		WinHeight=0.040000
		WinLeft=0.550634
		WinTop=0.511082
		OnClick=InfoClick
		TabOrder=1
		bStandardized=true
		bBoundToParent=false
		bScaleToParent=false
	End Object
	b_Info=InfoButton

	Begin Object class=GUIButton Name=KickButton
		Caption="Kick"
		WinWidth=0.137744
		WinHeight=0.040000
		WinLeft=0.715411
		WinTop=0.511082
		OnClick=KickClick
		bStandardized=true
		TabOrder=1
		bBoundToParent=false
		bScaleToParent=false
	End Object
	b_Kick=KickButton



	lmsgKickVotingDisabled="Sorry, Kick Voting has been disabled by the server administrator."
	WindowName="Kick Voting"
}

