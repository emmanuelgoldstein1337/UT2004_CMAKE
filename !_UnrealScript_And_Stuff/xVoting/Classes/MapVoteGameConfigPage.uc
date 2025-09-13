// ====================================================================
//  Class:  xVoting.MapVoteGameConfigPage
//
//	this page allows modification of the xVotingHandler GameConfig
//  configuration variables.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class MapVoteGameConfigPage extends GUICustomPropertyPage DependsOn(VotingHandler);

var automated GUISectionBackground sb_List, sb_List2;
var automated GUIListBox lb_GameConfigList;
var automated moComboBox co_GameClass;
var automated moEditBox  ed_GameTitle;
var automated moEditBox  ed_Acronym;
var automated moEditBox  ed_Prefix;
var automated MultiSelectListBox lb_Mutator;
var automated moEditBox  ed_Parameter;
var automated GUIButton  b_New;
var automated GUIButton  b_Delete;
var automated moCheckBox ch_Default;

var array<CacheManager.GameRecord> GameTypes;
var array<CacheManager.MutatorRecord> Mutators;

var() editconst noexport CacheManager.GameRecord    CurrentGame;

// autosave
var() int SaveIndex, ListIndex;
var bool bChanged;

// localization
var localized string lmsgNew;
var localized string lmsgAdd;

//------------------------------------------------------------------------------------------------
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.Initcomponent(MyController, MyOwner);

	// load existing configuration
	for(i=0; i<class'xVoting.xVotingHandler'.default.GameConfig.Length; i++)
		lb_GameConfigList.List.Add( class'xVoting.xVotingHandler'.default.GameConfig[i].GameName, none, string(i));

	if (lb_GameConfigList.List.ItemCount==0)
		DisableComponent(b_Delete);

	// load game types
	class'CacheManager'.static.GetGameTypeList(GameTypes);
	for(i=0; i<GameTypes.Length; i++)
		co_GameClass.AddItem( GameTypes[i].GameName, none, GameTypes[i].ClassName);

	class'CacheManager'.static.GetMutatorList(Mutators);
	LoadMutators();

	sb_Main.SetPosition(0.483359,0.064678,0.451250,0.716991);
	lb_GameConfigList.List.AddLinkObject(co_GameClass);
	lb_GameConfigList.List.AddLinkObject(ed_GameTitle);
	lb_GameConfigList.List.AddLinkObject(ed_Acronym);
	lb_GameConfigList.List.AddLinkObject(ed_Prefix);
	lb_GameConfigList.List.AddLinkObject(ed_Parameter);
	lb_GameConfigList.List.AddLinkObject(lb_Mutator);
	lb_GameConfigList.List.AddLinkObject(ch_Default);
	lb_GameConfigList.List.AddLinkObject(b_Delete);

	lb_GameConfigList.OnChange=GameConfigList_Changed;
	bChanged = False;

	sb_Main.TopPadding=0.0.5;
	sb_Main.BottomPadding=0.4;
	sb_Main.Caption="Options";

	sb_List.ManageComponent(lb_GameConfigList);
	sb_List.LeftPadding=0.005;
	sb_List.RightPadding=0.005;

	sb_Main.ManageComponent(ch_Default);
	sb_Main.ManageComponent(co_GameClass);
	sb_Main.ManageComponent(ed_GameTitle);
	sb_Main.ManageComponent(ed_Acronym);
	sb_Main.ManageComponent(ed_Prefix);
    sb_Main.ManageComponent(ed_Parameter);

	sb_List2.ManageComponent(lb_Mutator);

	if (lb_GameConfigList.List.ItemCount==0)
		DisableComponent(b_Delete);
	else
		lb_GameConfigList.List.SetIndex(0);


}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_OK )
	{
		SaveChange();
		Controller.CloseMenu(false);
		return true;
	}

	if ( Sender == b_Cancel )
	{
		Controller.CloseMenu(true);
		return true;
	}

	return false;
}


//------------------------------------------------------------------------------------------------
function InternalOnOpen()
{
	lb_GameConfigList.List.SetIndex(0);
}
//------------------------------------------------------------------------------------------------
function LoadMutators()
{
	local int i;

	lb_Mutator.List.Clear();
	for(i=0; i<Mutators.Length; i++)
		lb_Mutator.List.Add( Mutators[i].FriendlyName, none, Mutators[i].ClassName);
}
//------------------------------------------------------------------------------------------------
function GameConfigList_Changed(GUIComponent Sender)
{
	local int i;
	local array<string> MutatorArray;

	if (lb_GameConfigList.List.ItemCount==0 || lb_GameConfigList.List.Index == ListIndex)
		return;

   	SaveChange();

	SaveIndex = int(lb_GameConfigList.List.GetExtra());
	ListIndex = lb_GameConfigList.List.Index;

	LoadMutators();

	co_GameClass.Find(class'xVoting.xVotingHandler'.default.GameConfig[SaveIndex].GameClass, true, True);
	ed_GameTitle.SetComponentValue(class'xVoting.xVotingHandler'.default.GameConfig[SaveIndex].GameName, True);
	ed_Acronym.SetComponentValue(class'xVoting.xVotingHandler'.default.GameConfig[SaveIndex].Acronym, True);
	ed_Prefix.SetComponentValue(class'xVoting.xVotingHandler'.default.GameConfig[SaveIndex].Prefix, True);
	ed_Parameter.SetComponentValue(class'xVoting.xVotingHandler'.default.GameConfig[SaveIndex].Options, True);
	ch_Default.SetComponentValue(string(class'xVoting.xVotingHandler'.default.DefaultGameConfig == SaveIndex), True);

	Split(class'xVoting.xVotingHandler'.default.GameConfig[SaveIndex].Mutators, ",", MutatorArray);
	for(i=0; i<MutatorArray.Length; i++)
		lb_Mutator.List.Find(MutatorArray[i],False,True); // bExtra

	bChanged = False;

}

function int GameIndex()
{
	local string GameClass;
	local int i;

	GameClass = co_GameClass.GetExtra();
	for(i=0; i<GameTypes.Length; i++)
		if(GameTypes[i].ClassName == GameClass)
			return i;

	return -1;
}

//------------------------------------------------------------------------------------------------
function FieldChange(GUIComponent Sender)
{
	local int i,j;

	bChanged=True;

	if(Sender == co_GameClass)
	{
		i = GameIndex();

		for (j=0;j<GameTypes.Length;j++)
			if ( GameTypes[j].GameName == ed_GameTitle.GetText() )
			{
				ed_GameTitle.SetComponentValue(GameTypes[i].GameName, True);
				lb_GameConfigList.List.SetItemAtIndex(ListIndex,GameTypes[i].GameName);
			}

		ed_Acronym.SetComponentValue(GameTypes[i].GameAcronym, True);
		ed_Prefix.SetComponentValue(GameTypes[i].MapPrefix, True);

	}
	else if (Sender == ed_GameTitle)
	{
		if (ListIndex!=-1)
			lb_GameConfigList.List.SetItemAtIndex(ListIndex,ed_GameTitle.GetText());
	}
}
//------------------------------------------------------------------------------------------------
function bool SaveChange()
{
	local int i;

	if (!bChanged)
		return true;

	if( SaveIndex == -1 ) // Adding new record
	{
		i = class'xVoting.xVotingHandler'.default.GameConfig.Length;
		class'xVoting.xVotingHandler'.default.GameConfig.Length = i + 1;
		class'xVoting.xVotingHandler'.default.GameConfig[i].GameClass = co_GameClass.GetExtra();
		class'xVoting.xVotingHandler'.default.GameConfig[i].GameName = ed_GameTitle.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Acronym = ed_Acronym.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Prefix = ed_Prefix.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Options = ed_Parameter.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Mutators = lb_Mutator.List.GetExtra();
		if( bool(ch_Default.GetComponentValue()) )
			class'xVoting.xVotingHandler'.default.DefaultGameConfig = i;
		class'xVoting.xVotingHandler'.static.StaticSaveConfig();
		SaveIndex = i;
		lb_GameconfigList.List.SetExtraAtIndex(ListIndex,""$SaveIndex);
	}
	else  // modification of existing record
	{
		i = SaveIndex;
		class'xVoting.xVotingHandler'.default.GameConfig[i].GameClass = co_GameClass.GetExtra();
		class'xVoting.xVotingHandler'.default.GameConfig[i].GameName = ed_GameTitle.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Acronym = ed_Acronym.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Prefix = ed_Prefix.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Options = ed_Parameter.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Mutators = lb_Mutator.List.GetExtra();
		if( bool(ch_Default.GetComponentValue()) )
			class'xVoting.xVotingHandler'.default.DefaultGameConfig = i;
		class'xVoting.xVotingHandler'.static.StaticSaveConfig();
	}
	bChanged=False;
	return true;
}

//------------------------------------------------------------------------------------------------
function bool NewButtonClick(GUIComponent Sender)
{
	local int i;

	SaveChange();

	i = GameIndex();

	lb_GameConfigList.List.bNotify = false;
	lb_GameConfigList.List.Insert(0,"** New **",,"-1",true);
	lb_GameConfigList.List.bNotify = true;
	ed_GameTitle.SetComponentValue("** New **", True);
	ed_Acronym.SetComponentValue(GameTypes[i].GameAcronym, True);
	ed_Prefix.SetComponentValue(GameTypes[i].MapPrefix, True);
	ed_Parameter.SetComponentValue("", True);
	ch_Default.SetComponentValue("False", True);
	LoadMutators();

	ListIndex = 0;
	SaveIndex = -1;

	bChanged = true;

	EnableComponent(co_GameClass);
	EnableComponent(ed_GameTitle);
	EnableComponent(ed_Acronym);
	EnableComponent(ed_Prefix);
	EnableComponent(ed_Parameter);
	EnableComponent(lb_Mutator);
	EnableComponent(ch_Default);
	EnableComponent(b_Delete);
	return true;
}

//------------------------------------------------------------------------------------------------
function bool DeleteButtonClick(GUIComponent Sender)
{
	local int i,x;

	if (SaveIndex>=0)
	{
		class'xVoting.xVotingHandler'.default.GameConfig.Remove(SaveIndex,1);
		class'xVoting.xVotingHandler'.static.StaticSaveConfig();
	}

	if (ListIndex>=0)
	{

	    for (i=0;i<lb_GameConfigList.List.ItemCount;i++)
	    {
	    	x = int (lb_GameConfigList.List.GetExtraAtIndex(i));
			if ( x > SaveIndex )
				lb_GameconfigList.List.SetExtraAtIndex(i,""$(x-1));
	    }

		lb_GameConfigList.List.Remove(ListIndex,1);
	}

	SaveIndex = -1;
	ListIndex = -1;

	if (lb_GameConfigList.List.ItemCount==0)
	{
	 	DisableComponent(b_Delete);
	 	co_GameClass.SetIndex(-1);
		ed_GameTitle.SetComponentValue("", True);
		ed_Acronym.SetComponentValue("", True);
		ed_Prefix.SetComponentValue("", True);
		ed_Parameter.SetComponentValue("", True);
		ch_Default.SetComponentValue("False", True);

		DisableComponent(co_GameClass);
		DisableComponent(ed_GameTitle);
		DisableComponent(ed_Acronym);
		DisableComponent(ed_Prefix);
		DisableComponent(ed_Parameter);
		DisableComponent(lb_Mutator);
		DisableComponent(ch_Default);
		bChanged=false;
	}
	else
		lb_GameConfigList.List.SetIndex(0);

	return true;
}

defaultproperties
{

	OnOpen=InternalOnOpen

	Begin Object class=AltSectionBackground name=SBList
		Caption="GameTypes"
		WinWidth=0.377929
		WinHeight=0.753907
		WinLeft=0.042969
		WinTop=0.044272
		bFillClient=true
	End Object
	sb_List=SBList

	Begin Object class=ALtSectionBackground name=SBList2
		Caption="Mutators"
		HeaderBase=material'2K4Menus.NewControls.Display2'
		WinWidth=0.451250
		WinHeight=0.295899
		WinLeft=0.483359
		WinTop=0.540159
		TopPadding=0.1
		BottomPadding=0.1
		LeftPadding=0.0
		RightPadding=0.0
		RenderWeight=0.49;
	End Object
	sb_List2=SBList2

	Begin Object Class=GUIListBox Name=GameConfigListBox
		Hint="Select a game configuration to edit or delete."
		WinWidth=0.344087
		WinHeight=0.727759
		WinLeft=0.626758
		WinTop=0.160775
		TabOrder=0
		bVisibleWhenEmpty=true
	End Object
	lb_GameConfigList = GameConfigListBox

	Begin Object class=GUIButton Name=NewButton
		Caption="New"
		Hint="Create a new game configuration."
		StyleName="SquareButton"
		TabOrder=1
		OnClick=NewButtonClick
		WinWidth=0.158281
		WinLeft=0.060047
		WinTop=0.913925
	End Object
	b_New=NewButton

	Begin Object class=GUIButton Name=DeleteButton
		Caption="Delete"
		Hint="Delete the selected game configuration."
		StyleName="SquareButton"
		TabOrder=2
		OnClick=DeleteButtonClick
		WinWidth=0.159531
		WinLeft=0.268403
		WinTop=0.913925
        MenuState=MSAT_Disabled
	End Object
	b_Delete=DeleteButton

	Begin Object Class=moEditBox Name=GameTitleEditBox
	    Caption = "Game Title"
	    Hint="Enter a custom game configuration title."
		TabOrder=3
		WinWidth=0.592970
		WinHeight=0.074249
		WinLeft=0.028955
		WinTop=0.223844
		CaptionWidth=0.4
		ComponentWidth=0.6
		OnChange=FieldChange
        MenuState=MSAT_Disabled
	End Object
	ed_GameTitle = GameTitleEditBox


	Begin Object Class=moComboBox Name=GameClassComboBox
		Caption = "Game Class"
		Hint="Select a game type for the select game configuration."
		TabOrder=4
		WinWidth=0.592970
		WinHeight=0.076855
		WinLeft=0.028955
		WinTop=0.136135
		CaptionWidth=0.4
		ComponentWidth=0.6
		OnChange=FieldChange
        MenuState=MSAT_Disabled
	End Object
	co_GameClass = GameClassComboBox

	Begin Object Class=moEditBox Name=AcronymEditBox
	    //Caption = "Acronym"
	    Caption = "Abbreviation"
	    Hint="A short abbreviation, description, or acronym that identifies the game configuration. This will be appended to the map name in vote messages."
		TabOrder=5
		WinWidth=0.592970
		WinHeight=0.076855
		WinLeft=0.028955
		WinTop=0.306343
		CaptionWidth=0.4
		ComponentWidth=0.6
		OnChange=FieldChange
        MenuState=MSAT_Disabled
	End Object
	ed_Acronym = AcronymEditBox

	Begin Object Class=moEditBox Name=PrefixEditBox
	    Caption = "Map Prefixes"
	    Hint="List of map name prefixes. Separate each with commas."
		WinWidth=0.592970
		WinHeight=0.074249
		WinLeft=0.028955
		WinTop=0.393185
		TabOrder=6
		CaptionWidth=0.4
		ComponentWidth=0.6
		OnChange=FieldChange
        MenuState=MSAT_Disabled
	End Object
	ed_Prefix = PrefixEditBox

	Begin Object Class=moEditBox Name=ParameterEditBox
	    Caption = "Parameters"
	    Hint="(Advanced) List of game parameters with values. Separated each with a comma. (ex. GoalScore=4,MinPlayers=4)"
		WinWidth=0.490431
		WinHeight=0.030000
		WinLeft=0.077783
		WinTop=0.826949
		CaptionWidth=0.4
		TabOrder=7
		ComponentWidth=0.6
		OnChange=FieldChange
        MenuState=MSAT_Disabled
	End Object
	ed_Parameter = ParameterEditBox

	Begin Object class=moCheckbox Name=DefaultCheckBox
		Caption="Default"
		Hint="The selected game configuration will be the default if all the players leave the server"
		CaptionWidth=0.8
		ComponentWidth=0.2
		OnChange=FieldChange
		TabOrder=8
		WinWidth=0.194922
		WinHeight=0.030000
		WinLeft=0.659814
		WinTop=0.826949
        MenuState=MSAT_Disabled
	End Object
	ch_Default = DefaultCheckBox


	Begin Object Class=MultiSelectListBox Name=MutatorListBox
        Hint="Select each mutator that should be loaded with this game configuration."
		WinWidth=0.396485
		WinHeight=0.315234
		WinLeft=0.224267
		WinTop=0.484369
		TabOrder=9
		bVisibleWhenEmpty=true
		OnChange=FieldChange
        MenuState=MSAT_Disabled
	End Object
	lb_Mutator = MutatorListBox

	Background=None

	bAcceptsInput=false

	WinWidth=0.917187
	WinHeight=0.885075
	WinLeft=0.041015
	WinTop=0.031510

	DefaultWidth=0.917187
	DefaultHeight=0.885075
	DefaultLeft=0.041015
	DefaultTop=0.031510

 	WindowName="Map Voting Game Configuration"

 	lmsgNew="New"
 	lmsgAdd="Add"

 	ListIndex=-1;
 	SaveIndex=-1;

}

