//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT2K4_FilterListPage extends LargeWindow;

var automated GUISectionBackground  sb_Background;
var automated GUIButton				b_Create, b_Remove, b_Edit, b_OK, b_Cancel;
var automated GUIMultiOptionListBox	lb_Filters;
var GUIMultiOptionList				li_Filters;

var	BrowserFilters 					FM;

var localized string CantRemove;

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	Super.InitComponent(MyC, MyO);
	sb_Background.ManageComponent(lb_Filters);

	li_Filters = lb_Filters.List;
	li_Filters.ItemScaling = 0.04;
	li_Filters.ItemPadding = 0.3;
	li_Filters.OnChange=FilterChange;
	FM = UT2K4ServerBrowser(ParentPage).FilterMaster;
	InitFilterList();

	b_ExitButton.OnClick = CancelClick;
	li_Filters.OnDblClick=FilterDblClick;
}


function InitFilterList()
{
	local array<string> FilterNames;
	local moCheckbox ch;
	local int i;

	li_Filters.Clear();
	FilterNames = FM.GetFilterNames();
	for (i = 0; i < FilterNames.Length; i++)
	{
		ch = moCheckBox(li_Filters.AddItem("XInterface.moCheckbox",,FilterNames[i]));
		if (ch != None)
			ch.Checked(FM.IsActiveAt(i));
	}

	if (li_Filters.ItemCount==0)
		DisableComponent(b_Remove);
	else
		EnableComponent(b_Remove);

	li_Filters.SetIndex(0);

}

function FilterChange(GUIComponent Sender)
{
	local int i;
	local moCheckbox Sent;

	if (Sender == li_Filters)	// selected a different filter
	{
		if (li_Filters.ValidIndex(li_Filters.Index))
		{
			Sent = moCheckbox(li_Filters.Get());

			i = FM.FindFilterIndex(Sent.Caption);
			if (Sent.IsChecked() != FM.IsActiveAt(i))
				FM.ActivateFilter(i,Sent.IsChecked());
		}
	}
}

function bool CreateClick(GUIComponent Sender)
{
	local string FN;
	local int i,cnt;
	local moCheckbox cb;

	cnt = 0;
	for (i=0;i<li_Filters.ItemCount;i++)
	{
		cb = moCheckbox( li_Filters.GetItem(i) );
		if (inStr(cb.Caption,"New Filter")>=0)
			cnt++;
	}

	if (cnt==0)
		FN ="New Filter";
	else
		FN = "New Filter"@cnt;

	FM.AddCustomFilter(FN);
	InitFilterList();
    i= FM.FindFilterIndex(FN);
    Controller.OpenMenu("GUI2K4.UT2K4_FilterEdit",""$i,FN);

    return true;
}

function bool FilterDBLClick(GUIComponent Sender)
{
	EditClick(b_Edit);
	return true;
}

function bool EditClick(GUIComponent Sender)
{
	local string FN;
	local int i;
	local moCheckbox cb;

	cb = moCheckbox( li_Filters.Get() );
	FN = cb.Caption;
    i= FM.FindFilterIndex(FN);
    Controller.OpenMenu("GUI2K4.UT2K4_FilterEdit",""$i,FN);

    return true;
}


function bool RemoveClick(GUIComponent Sender)
{

	if ( moCheckbox(li_Filters.Get()).Caption ~= "Default")
	{
		Controller.OpenMenu("GUI2K4.UT2K4GenericMessageBox",CantRemove);
		return true;
	}

	FM.RemoveFilterAt( li_Filters.Index );
	InitFilterList();
}

function bool OKClick(GUIComponent Sender)
{
	local int i;
	local bool b;
	local UT2K4ServerBrowser Br;
	FM.SaveFilters();

    b = false;
	for (i=0;i<FM.AllFilters.Length;i++)
		if ( FM.IsActiveAt(i) )
			b = true;

	if (b)
	{
		Br = UT2K4ServerBrowser(ParentPage);
		UT2K4Browser_Footer(Br.t_Footer).ch_Standard.Checked(false);
	}

	Controller.CloseMenu(true);



	return true;
}

function bool CancelClick(GUIComponent Sender)
{
	FM.ResetFilters();
	Controller.CloseMenu(true);
	return true;
}

DefaultProperties
{
	Begin Object Class=ALTSectionBackground Name=sbBackground
		WinWidth=0.343359
		WinHeight=0.766448
		WinLeft=0.262656
		WinTop=0.103281
		Caption="Filters..."
		LeftPadding=0.0025
		RightPadding=0.0025
		TopPadding=0.0025
		bFillClient=true
		BottomPadding=0.0025
	End Object
	sb_Background=sbBackground

	Begin Object class=GUIMultiOptionListBox name=lbFilters
		WinWidth=0.343359
		WinHeight=0.766448
		WinLeft=0.262656
		WinTop=0.103281
	End Object
	lb_Filters=lbFilters

	Begin Object Class=GUIButton name=bCreate
		WinWidth=0.168750
		WinHeight=0.050000
		WinLeft=0.610001
		WinTop=0.105000
		OnClick=CreateClick
		Caption="Create"
	End Object
	b_Create=bCreate

	Begin Object Class=GUIButton name=bRemove
		WinWidth=0.168750
		WinHeight=0.050000
		WinLeft=0.610001
		WinTop=0.158333
		Caption="Remove"
		OnClick=RemoveClick
	End Object
	b_Remove=bRemove

	Begin Object Class=GUIButton name=bEdit
		WinWidth=0.168750
		WinHeight=0.050000
		WinLeft=0.610001
		WinTop=0.266666
		OnClick=EditClick
		Caption="Edit"
	End Object
	b_Edit=bEdit

   	Begin Object Class=GUIButton name=bOK
   		WinWidth=0.168750
		WinHeight=0.050000
		WinLeft=0.610001
		WinTop=0.770000
		Caption="OK"
		OnClick=OKClick
	End Object
	b_OK=bOK;

   	Begin Object Class=GUIButton name=bCancel
   		WinWidth=0.168750
		WinHeight=0.050000
		WinLeft=0.610001
		WinTop=0.820000
		Caption="Cancel"
		OnClick=CancelClick
	End Object
	b_Cancel=bCancel;


	WinWidth=0.568750
	WinHeight=0.875001
	WinLeft=0.237500
	WinTop=0.046667
	WindowName="Select Filters"

	CantRemove="You can not remove the default filter"

}
