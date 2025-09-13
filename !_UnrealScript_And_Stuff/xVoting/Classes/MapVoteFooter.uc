//==============================================================================
//  Created on: 01/02/2004
//  Contains controls for participating in chat while mapvote menus are open
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class MapVoteFooter extends GUIFooter;

var() noexport array<string> RecallQueue;
var() noexport int RecallIdx;
var() noexport int idxLastChatMsg;
var() noexport float LastMsgTime;

var automated GUISectionBackground sb_Background;
var automated GUIScrollTextBox lb_Chat;
var automated moEditBox        ed_Chat;
var automated GUIButton        b_Accept, b_Submit, b_Close;

delegate OnSubmit();
delegate OnAccept();
delegate bool OnSendChat( string Text )
{
	if ( Text != "" )
	{
		if ( RecallQueue.Length == 0 || RecallQueue[RecallQueue.Length - 1] != Text )
		{
			RecallIdx = RecallQueue.Length;
			RecallQueue[RecallIdx] = Text;
		}

		if ( Left(Text,4) ~= "cmd " )
			PlayerOwner().ConsoleCommand( Mid(Text, 4) );
		else
		{
			if ( Left(Text,1) == "." )
				PlayerOwner().TeamSay( Mid(Text,1) );
			else PlayerOwner().Say( Text );
		}
	}

	return true;
}

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	local string str;
	local ExtendedConsole C;

	Super.InitComponent(InController, InOwner);

	lb_Chat.MyScrollText.SetContent("");
	lb_Chat.MyScrollText.FontScale=FNS_Small;

	C = ExtendedConsole(Controller.ViewportOwner.Console);
	if ( C != None )
	{
		C.OnChatMessage = ReceiveChat;
		if ( C.bTyping )
		{
			str = C.TypedStr;
			C.TypingClose();

			if ( Left(str,4) ~= "say " )
				str = Mid(str, 4);

			else if ( Left(str,8) ~= "teamsay " )
				str = Mid(str, 8);

			ed_Chat.SetText(str);
		}
	}

	sb_Background.Managecomponent(lb_Chat);


	OnDraw=MyOnDraw;

}

function bool MyOnDraw(canvas C)
{
	local float l,t,w,xl,yl;
	local eFontScale fs;
	// Reposition everything

	t = sb_Background.ActualTop() + sb_Background.ActualHeight();
	l = sb_Background.ActualLeft() + sb_Background.ActualWidth() - sb_Background.ImageOffset[3];

	b_Close.Style.TextSize(C,MSAT_Blurry,b_Close.Caption, XL,YL,FS);
	w = XL;
	b_Submit.Style.TextSize(C,MSAT_Blurry,b_Close.Caption, XL,YL,FS);
	if (XL>w)
		w = XL;
	b_Accept.Style.TextSize(C,MSAT_Blurry,b_Close.Caption, XL,YL,FS);
	if (XL>w)
		w = XL;

	w = w*3;
	w = ActualWidth(w);

	l -= w;
	b_Close.WinWidth = w;
	b_Close.WinTop = t;
	b_Close.WinLeft = l;

	l -= w;
	b_Submit.WinWidth = w;
	b_Submit.WinTop = t;
	b_Submit.WinLeft = l;

	l -= w;
	b_Accept.WinWidth = w;
	b_Accept.WinTop = t;
	b_Accept.WinLeft = l;


	ed_Chat.WinLeft   = sb_Background.ActualLeft() + sb_Background.ImageOffset[0];
	ed_Chat.WinWidth  = L - ed_Chat.WinLeft;
	ed_Chat.WinHeight = 25;
	ed_Chat.WinTop    = t;

 	return false;
}

function ReceiveChat(string Msg)
{
	lb_Chat.AddText(Msg);
	lb_Chat.MyScrollText.End();

	// remove top messages from list if there are more than 10
	if( lb_Chat.MyScrollText.ItemCount > 10 )
		lb_Chat.MyScrollText.Remove(0,lb_Chat.MyScrollText.ItemCount - 10);
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if ( State == 3 && Key == 0x0D ) // enter
	{
		if ( OnSendChat(ed_Chat.GetText()) )
			ed_Chat.SetComponentValue("", True);

		return true;
	}

	else if ( State == 1 && RecallQueue.Length > 0 )
	{
		if ( Key == 0x26 ) // up
		{
			ed_Chat.SetText(RecallQueue[RecallIdx]);
			RecallIdx = Max(0, RecallIdx - 1);
			return true;
		}
		else if ( Key == 0x28 ) // down
		{
			ed_Chat.SetText(RecallQueue[RecallIdx]);
			RecallIdx = Min(RecallQueue.Length - 1, RecallIdx + 1);
			return true;
		}
	}

	return false;
}

function bool InternalOnClick(GUIComponent Sender)
{
	if (Sender == b_Close )
	{
		Controller.CloseMenu(true);
		return true;
	}

	if ( Sender == b_Submit )
	{
		OnSubmit();
		return true;
	}

	if ( Sender == b_Accept )
	{
		OnAccept();
		return true;
	}
}

DefaultProperties
{
	bNeverFocus=false
	Begin Object Class=AltSectionBackground Name=MapvoteFooterBackground
		Caption="Chat"
		WinWidth=1
		WinHeight=0.82
		WinLeft=0
		WinTop=0
		bBoundToParent=True
		bScaleToParent=True
		bFillClient=true
		LeftPadding=0.01
		RightPadding=0.01
	End Object
	sb_Background=MapvoteFooterBackground

	Begin Object Class=GUIScrollTextBox Name=ChatScrollBox
		WinWidth=0.918970
		WinHeight=0.582534
		WinLeft=0.043845
		WinTop=0.223580
		CharDelay=0.0025
		EOLDelay=0
        bBoundToParent=true
        bScaleToParent=true
		bVisibleWhenEmpty=true
        bNoTeletype=true
        bNeverFocus=true
		bStripColors=false
//		StyleName="NoBackground"
		StyleName="ServerBrowserGrid"
		TabOrder=2
	End Object
	lb_Chat=ChatScrollBox

	Begin Object class=moEditBox Name=ChatEditbox
		WinWidth=0.700243
		WinHeight=0.106609
		WinLeft=0.007235
		WinTop=0.868598
		Caption="Say"
		CaptionWidth=0.15
		OnKeyEvent=InternalOnKeyEvent
		TabOrder=0
		bStandardized=true
	End Object
	ed_Chat=ChatEditbox

	Begin Object Class=GUIButton Name=AcceptButton
		Caption="Accept"
		Hint="Click once you are satisfied with all settings and wish to offer no further modifications"
		WinWidth=0.191554
		WinHeight=0.071145
		WinLeft=0.562577
		WinTop=0.906173
		OnClick=InternalOnClick
		TabOrder=1
		bRepeatClick=False
		bStandardized=true
		bBoundToParent=false
		bScaleToParent=false
		bVisible=false
	End Object
	b_Accept=AcceptButton
	Begin Object Class=GUIButton Name=SubmitButton
		Caption="Submit"
		WinWidth=0.160075
		WinHeight=0.165403
		WinLeft=0.704931
		WinTop=0.849625
		OnClick=InternalOnClick
		TabOrder=1
		bStandardized=true
		bBoundToParent=false
		bScaleToParent=false
	End Object
	b_Submit=SubmitButton

	Begin Object class=GUIButton Name=CloseButton
		Caption="Close"
		WinWidth=0.137744
		WinHeight=0.165403
		WinLeft=0.861895
		WinTop=0.849625
		OnClick=InternalOnClick
		bStandardized=true
		TabOrder=1
		bBoundToParent=false
		bScaleToParent=false
	End Object
	b_Close=CloseButton
	StyleName="BindBox"
}
