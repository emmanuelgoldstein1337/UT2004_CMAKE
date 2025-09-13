//-----------------------------------------------------------
//
//-----------------------------------------------------------

class UT2K4_FilterEdit extends LargeWindow;

var automated GUISectionBackground sb_Options, sb_Mutators;
var automated moEditBox eb_Name;
var automated moComboBox cb_Stats, cb_WeaponStay, cb_Translocator, cb_Mutators;
var automated moCheckBox ck_Full, ck_Bots, ck_Empty, ck_Passworded;
var automated GUIButton b_Ok, b_Cancel;
var automated GUIMultiOptionListBox	lb_Mutators;
var GUIMultiOptionList				li_Mutators;

var int 			FilterIndex;
var	BrowserFilters 	FM;

var UT2K4_FilterListPage FLP;

var localized string ComboOpts[3];
var localized string MutOpts[3];

var array<CacheManager.MutatorRecord>			MutRecords;

var bool bInitialized;

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	local int i;
	local moComboBox CB;
	Super.InitComponent(MyC, MyO);

	FLP = UT2K4_FilterListPage(ParentPage);

	sb_Options.ManageComponent(ck_Full);
	sb_Options.ManageComponent(ck_Empty);
	sb_Options.ManageComponent(ck_Passworded);
	sb_Options.ManageComponent(ck_Bots);
	sb_Options.ManageComponent(cb_Stats);
	sb_Options.ManageComponent(cb_WeaponStay);
	sb_Options.ManageComponent(cb_Translocator);
	sb_Options.ManageComponent(cb_Mutators);

	for (i=0;i<3;i++)
	{
		cb_Stats.AddItem(ComboOpts[i]);
		cb_WeaponStay.AddItem(ComboOpts[i]);
		cb_Translocator.AddItem(ComboOpts[i]);
	}

	cb_Mutators.AddItem(MutOpts[0]);
	cb_Mutators.AddItem(MutOpts[1]);
	cb_Mutators.AddItem(MutOpts[2]);

	li_Mutators = lb_Mutators.List;

	sb_Mutators.ManageComponent(lb_Mutators);

    class'CacheManager'.static.GetMutatorList(MutRecords);
    for (i=0;i<MutRecords.Length;i++)
    {
    	cb = moComboBox(li_Mutators.AddItem("XInterface.moCombobox",,MutREcords[i].FriendlyName) );
    	cb.AddItem(ComboOpts[0]);
    	cb.AddItem(ComboOpts[1]);
    	cb.AddItem(ComboOpts[2]);
    	cb.ReadOnly(true);
    }

    cb_Mutators.OnChange=MutChange;
    lb_Mutators.DisableMe();

}

event HandleParameters(string Param1, string Param2)
{
	local int i;
	local array<CustomFilter.AFilterRule> Rules;
	local MasterServerClient.QueryData 	FilterItem;

    FilterIndex = int(Param1);
	eb_Name.SetComponentValue(Param2);

	if (Param2~="Default")
		eb_Name.DisableMe();
	else
		eb_Name.EnableMe();

	//Get the custom filter

 	Rules = FLP.FM.GetFilterRules(FilterIndex);
	for (i=0;i<Rules.Length;i++)
	{
		FilterItem = Rules[i].FilterItem;
		if ( FilterItem.Key~="currentplayers" && FilterItem.Value=="0" && FilterItem.QueryType==QT_GreaterThan )
			ck_Empty.Checked(true);

		if ( FilterItem.Key~="password" && FilterItem.Value=="false" && FilterItem.QueryType==QT_Equals )
			ck_Passworded.Checked(true);

		if ( FilterItem.Key~="freespace" && FilterItem.Value =="0" && FilterItem.QueryType==QT_GreaterThan )
			ck_Full.Checked(true);

		if ( FilterItem.Key~="nobots" && FilterItem.Value=="true" && FilterItem.QueryType==QT_Equals)
			ck_Bots.Checked(true);

		if ( FilterItem.Key~="stats" ) //( && FilterITem.Value=="true" )
		{
			 if ( FilterITem.Value~="true" )
				cb_Stats.MyComboBox.SetIndex(1);
			else
				cb_Stats.MyComboBox.SetIndex(2);
		}

		if ( FilterItem.Key~="weaponstay" )
		{
			 if ( FilterItem.Value~="true" )
				cb_WeaponStay.MyComboBox.SetIndex(1);
			else
				cb_WeaponStay.MyComboBox.SetIndex(2);
		}

		if ( FilterItem.Key~="transloc" )
		{
			 if ( FilterItem.Value~="true" )
				cb_Translocator.MyComboBox.SetIndex(1);
			else
				cb_Translocator.MyComboBox.SetIndex(2);
		}

		if (FilterItem.Key~="nomutators" && FilterItem.Value=="true" )
			cb_Mutators.MyComboBox.SetIndex(0);

		if (FilterItem.Key~="mutator")
		{
			cb_Mutators.MyComboBox.SetIndex(2);
			if ( FilterITem.QueryType==QT_Equals)
				SetMutator(FilterItem.Value,1);
			else if (FilterItem.QueryType==QT_NotEquals)
				SetMutator(FilterItem.Value,2);
		}
	}
}

function SetMutator(string ClassName, int index)
{
	local int i,j;
	local string s;
	local moComboBox box;
	for (i=0;i<MutRecords.Length;i++)
	{
		j = Instr(MutRecords[i].ClassName,".");
		s = mid(MutRecords[i].ClassName,j+1);

		if (s ~= ClassName)
		{
			for (j=0;j<li_Mutators.ItemCount;j++)
			{
				Box = moComboBox( li_Mutators.GetItem(j) );
				if (Box.Caption ~= MutRecords[i].FriendlyName)
				{
					Box.SetIndex(Index);
					return;
				}
			}
		}
	}
}

function MutChange(GUIComponent Sender)
{
	if (Sender==cb_Mutators)
	{
		if (cb_Mutators.GetIndex() < 2)
			lb_Mutators.DisableMe();
		else
			lb_Mutators.EnableMe();
	}
}

function bool CancelClick(GUIComponent Sender)
{
	Controller.CloseMenu(true);
	return true;
}

function CustomFilter.AFilterRule BuildRule(string Key, string Value, MasterServerClient.EQueryType qType)
{
	local CustomFilter.AFilterRule NewRule;

	NewRule.FilterItem.Key   		= key;
	NewRule.FilterItem.Value 		= value;
	NewRule.FilterItem.QueryType	= qtype;

    if (Key=="mutator")
    	NewRule.FilterType = DT_Multiple;
    else
		NewRule.FilterType = DT_Unique;
	NewRule.ItemName = Key;

	return NewRule;
}


function bool OkClick(GUIComponent Server)
{
	local array<CustomFilter.AFilterRule> Rules;
	local int cnt,i;
	local moComboBox CB;

	cnt = 0;

	// Build Query lists

	if ( ck_Empty.IsChecked() )
		Rules[Cnt++] = BuildRule("currentplayers","0",QT_GreaterThan);

	if ( ck_Full.IsChecked() )
		Rules[Cnt++] = BuildRule("freespace","0",QT_GreaterThan);

	if ( ck_Passworded.IsChecked() )
		Rules[Cnt++] = BuildRule("password","false",QT_Equals);

	if ( ck_Bots.IsChecked() )
		Rules[Cnt++] = BuildRule("nobots","true", QT_Equals);

	if (cb_Stats.GetIndex()==1)
		Rules[Cnt++] = BuildRule("stats","true", QT_Equals);
	else if (cb_Stats.GetIndex()==2)
		Rules[Cnt++] = BuildRule("stats","false", QT_Equals);

	if (cb_WeaponStay.GetIndex()==1)
		Rules[Cnt++] = BuildRule("weaponstay","true", QT_Equals);
	else if (cb_WeaponStay.GetIndex()==2)
		Rules[Cnt++] = BuildRule("weaponstay","false", QT_Equals);

	if (cb_Translocator.GetIndex()==1)
		Rules[Cnt++] = BuildRule("transloc","true", QT_Equals);
	else if (cb_Translocator.GetIndex()==2)
		Rules[Cnt++] = BuildRule("transloc","false", QT_Equals);

	if (cb_Mutators.GetIndex()==0)
		Rules[Cnt++] = BuildRule("nomutators","true", QT_Equals);

	else if (cb_Mutators.GetIndex()==2)
	{
		for (i=0;i<li_Mutators.ItemCount;i++)
		{
			CB = moComboBox(li_Mutators.GetItem(i));
			if (cb.GetIndex() == 1)
				Rules[Cnt++] = BuildRule("mutator",FindMutClassFromFriendly(cb.Caption),QT_Equals);
			else if (cb.GetIndex() == 2)
				Rules[Cnt++] = BuildRule("mutator",FindMutClassFromFriendly(cb.Caption),QT_NotEquals);
		}
	}

	FLP.FM.PostEdit(FilterIndex,eb_Name.GetComponentValue(),Rules);
	Controller.CloseMenu(true);
	FLP.InitFilterList();

	FLP.li_Filters.SetIndex(FLP.li_Filters.Find(eb_Name.GetComponentValue()));

	return true;
}

function string FindMutClassFromFriendly(string friendly)
{
	local int i,p;
	local string cls;

	for (i=0;i<MutRecords.Length;i++)
		if (MutRecords[i].FriendlyName ~= Friendly)
		{
			cls = MutRecords[i].ClassName;
			p = Instr(Cls,".");
			return Mid(cls,p+1);
		}

	return "";
}

function bool ebPreDraw(canvas Canvas)
{

	// Reposition

	eb_Name.WinTop = sb_Options.ActualTop() + 36;
	return true;
}


defaultproperties
{
	Begin Object class=moEditBox name=ebName
		WinWidth=0.654297
		WinHeight=0.030000
		WinLeft=0.184531
		WinTop=0.124114
		bStandardized=true
		Caption="Filter Name:"
		ComponentWidth=0.7
		TabOrder=0
		OnPreDraw=ebPreDraw
	End Object
	eb_Name=ebName

	Begin Object Class=GUISectionBackground Name=sbOptions
		WinWidth=0.927735
		WinHeight=0.375823
		WinLeft=0.036094
		WinTop=0.057448
		Caption="Options..."
		LeftPadding=0.0025
		RightPadding=0.0025
		TopPadding=0.1
		bFillClient=true
		BottomPadding=0.0025
		NumColumns=2
	End Object
	sb_Options=sbOptions


	Begin Object class=moCheckBox name=ckFull
		WinWidth=0.5
		WinLeft=0.25
		WinTop=0.25
		bStandardized=true
		Caption="No Full Servers"
		ComponentWidth=0.1
		TabOrder=1
	End Object
	ck_Full=ckFull

	Begin Object class=moCheckBox name=ckBots
		WinWidth=0.5
		WinLeft=0.25
		WinTop=0.25
		bStandardized=true
		Caption="No Bots"
		ComponentWidth=0.1
		TabOrder=2
	End Object
	ck_Bots=ckBots

	Begin Object class=moCheckBox name=ckEmpty
		WinWidth=0.5
		WinLeft=0.25
		WinTop=0.25
		bStandardized=true
		Caption="No Empty Servers"
		ComponentWidth=0.1
		TabOrder=3
	End Object
	ck_Empty=ckEmpty

	Begin Object class=moCheckBox name=ckPassworded
		WinWidth=0.5
		WinLeft=0.25
		WinTop=0.25
		bStandardized=true
		Caption="No Passworded Servers"
		ComponentWidth=0.1
		TabOrder=4
	End Object
	ck_Passworded=ckPassworded


	Begin Object class=moComboBox name=cbStats
		WinWidth=0.5
		WinLeft=0.25
		WinTop=0.25
		bStandardized=true
		Caption="Stats Servers:"
		ComponentWidth=0.55
		bReadOnly=true
		TabOrder=5
	End Object
	cb_Stats=cbStats

	Begin Object class=moComboBox name=cbWeaponStay
		WinWidth=0.5
		WinLeft=0.25
		WinTop=0.25
		bStandardized=true
		Caption="Weapon Stay:"
		ComponentWidth=0.55
		TabOrder=6
		bReadOnly=true
	End Object
	cb_WeaponStay=cbWeaponStay

	Begin Object class=moComboBox name=cbTranslocator
		WinWidth=0.5
		WinLeft=0.25
		WinTop=0.25
		bStandardized=true
		Caption="Translocator:"
		ComponentWidth=0.55
		TabOrder=7
		bReadOnly=true
	End Object
	cb_Translocator=cbTranslocator

	Begin Object class=moComboBox name=cbMutators
		WinWidth=0.5
		WinLeft=0.25
		WinTop=0.25
		bStandardized=true
		Caption="Mutators:"
		ComponentWidth=0.55
		TabOrder=8
		bReadOnly=true
	End Object
	cb_Mutators=cbMutators


	Begin Object Class=ALTSectionBackground Name=sbMutators
		WinWidth=0.929296
		WinHeight=0.453948
		WinLeft=0.036094
		WinTop=0.436614
		Caption="Custom Mutator Config"
		LeftPadding=0.0025
		RightPadding=0.0025
		TopPadding=0.0025
		bFillClient=true
		BottomPadding=0.0025
	End Object
	sb_Mutators=sbMutators

	Begin Object class=GUIMultiOptionListBox name=lbMutators
		WinWidth=0.343359
		WinHeight=0.766448
		WinLeft=0.262656
		WinTop=0.103281
		TabOrder=9
	End Object
	lb_Mutators=lbMutators


   	Begin Object Class=GUIButton name=bOK
		WinWidth=0.168750
		WinHeight=0.050000
		WinLeft=0.611564
		WinTop=0.903612
		Caption="OK"
		OnClick=OKClick
	End Object
	b_OK=bOK;

   	Begin Object Class=GUIButton name=bCancel
		WinWidth=0.168750
		WinHeight=0.050000
		WinLeft=0.792814
		WinTop=0.903507
		Caption="Cancel"
		OnClick=CancelClick
	End Object
	b_Cancel=bCancel;



	WinWidth=1
	WinHeight=1
	WinLeft=0
	WinTop=0
	WindowName="Edit Filter Rules..."

	ComboOpts(0)="Does Not Matter"
	ComboOpts(1)="Must Be On"
	ComboOpts(2)="Must Be Off"

	MutOpts(0)="No Mutators"
	MutOpts(1)="Any Mutator"
	MutOpts(2)="Custom"

}
