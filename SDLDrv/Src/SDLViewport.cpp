/*=============================================================================
	SDLViewport.cpp: USDLViewport code.
	Copyright 2002 Epic Games, Inc. All Rights Reserved.

        SDL website: http://www.libsdl.org/

Revision history:
	* Created by Ryan C. Gordon, based on WinDrv.
      This is an updated rewrite of the original SDLDrv.
=============================================================================*/

#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "SDLDrv.h"

// Duplicated here for convenience.
enum EEditorMode
{
	EM_None 				= 0,	// Gameplay, editor disabled.
	EM_ViewportMove			= 1,	// Move viewport normally.
	EM_ViewportZoom			= 2,	// Move viewport with acceleration.
	EM_ActorRotate			= 5,	// Rotate actor.
	EM_ActorScale			= 8,	// Scale actor.
	EM_TexturePan			= 11,	// Pan textures.
	EM_TextureRotate		= 13,	// Rotate textures.
	EM_TextureScale			= 14,	// Scale textures.
	EM_ActorSnapScale		= 18,	// Actor snap-scale.
	EM_TexView				= 19,	// Viewing textures.
	EM_TexBrowser			= 20,	// Browsing textures.
	EM_StaticMeshBrowser	= 21,	// Browsing static meshes.
	EM_MeshView				= 22,	// Viewing mesh.
	EM_MeshBrowser			= 23,	// Browsing mesh.
	EM_BrushClip			= 24,	// Brush Clipping.
	EM_VertexEdit			= 25,	// Multiple Vertex Editing.
	EM_FaceDrag				= 26,	// Face Dragging.
	EM_Polygon				= 27,	// Free hand polygon drawing
	EM_TerrainEdit			= 28,	// Terrain editing.
	EM_PrefabBrowser		= 29,	// Browsing prefabs.
	EM_Matinee				= 30,	// Movie editing.
	EM_EyeDropper			= 31,	// Eyedropper
	EM_Animation			= 32,	// Viewing Animation
	EM_FindActor			= 33,	// Find Actor
	EM_MaterialEditor		= 34,	// Material editor
	EM_Geometry				= 35,	// Geometry editing mode
	EM_NewCameraMove		= 50,
};


/*-----------------------------------------------------------------------------
	Class implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(USDLViewport);

/*-----------------------------------------------------------------------------
	USDLViewport Init/Exit.
-----------------------------------------------------------------------------*/


//
// Constructor.
//
USDLViewport::USDLViewport()
:	UViewport()
{
	guard(USDLViewport::USDLViewport);

    FullscreenOnly = 0;

    TextToSpeechObject = -1;

	// Query current bit depth.
	int depth = 32; //DIXME //SDL_BITSPERPIXEL(SDL_GetCurrentDisplayMode(0)->format); //SDL_GetVideoInfo()->vfmt->BitsPerPixel;
	
	switch (depth)
	{
		case 8 :	
			ColorBytes = 2;
			break;

		case 15 :	
			ColorBytes = 2;		
			break;

		case 16 :
			ColorBytes = 2;
			Caps |= CC_RGB565;
			break;

		case 24 :
		case 32 :
			ColorBytes = 4;
			break;

		default :	
			ColorBytes = 2;
			Caps |= CC_RGB565;
	}
	
	SavedCursorX = -1;


	// EMNLGLSN
	
	// Zero out maps.
	for (INT i=0; i<512; i++)
		KeysymMap[i] = 0;//zero


	// Remap important keys.
	// EMNLGLSN
	
	// TTY Functions.
	KeysymMap[SDL_SCANCODE_BACKSPACE]= IK_Backspace; //SDL_SCANCODE_KP_BACKSPACE
	KeysymMap[SDL_SCANCODE_TAB]	= IK_Tab;
	KeysymMap[SDL_SCANCODE_RETURN]	= IK_Enter;
	KeysymMap[SDL_SCANCODE_PAUSE]	= IK_Pause;
	KeysymMap[SDL_SCANCODE_ESCAPE]	= IK_Escape;
	KeysymMap[SDL_SCANCODE_DELETE]	= IK_Delete;
	KeysymMap[SDL_SCANCODE_INSERT]  = IK_Insert;

	// Modifiers.
	KeysymMap[SDL_SCANCODE_LSHIFT]	= IK_LShift;
	KeysymMap[SDL_SCANCODE_RSHIFT]	= IK_RShift;
	KeysymMap[SDL_SCANCODE_LCTRL]	= IK_LControl;
	KeysymMap[SDL_SCANCODE_RCTRL]	= IK_RControl;
	KeysymMap[SDL_SCANCODE_LGUI]	= IK_F24;
	KeysymMap[SDL_SCANCODE_RGUI]	= IK_F24;
	KeysymMap[SDL_SCANCODE_LALT]	= IK_Alt;
	KeysymMap[SDL_SCANCODE_RALT]	= IK_Alt;
	
	// Special remaps.
	KeysymMap[SDL_SCANCODE_GRAVE] = IK_Tilde;
	KeysymMap[SDL_SCANCODE_APOSTROPHE] = IK_SingleQuote;
	KeysymMap[SDL_SCANCODE_SEMICOLON] = IK_Semicolon;
	KeysymMap[SDL_SCANCODE_COMMA] = IK_Comma;
	KeysymMap[SDL_SCANCODE_PERIOD] = IK_Period;
	KeysymMap[SDL_SCANCODE_SLASH] = IK_Slash;
	KeysymMap[SDL_SCANCODE_BACKSLASH] = IK_Backslash;
	KeysymMap[SDL_SCANCODE_LEFTBRACKET]  = IK_LeftBracket;
	KeysymMap[SDL_SCANCODE_RIGHTBRACKET] = IK_RightBracket;
 
	// Misc function keys.
	KeysymMap[SDL_SCANCODE_F1]	= IK_F1;
	KeysymMap[SDL_SCANCODE_F2]	= IK_F2;
	KeysymMap[SDL_SCANCODE_F3]	= IK_F3;
	KeysymMap[SDL_SCANCODE_F4]	= IK_F4;
	KeysymMap[SDL_SCANCODE_F5]	= IK_F5;
	KeysymMap[SDL_SCANCODE_F6]	= IK_F6;
	KeysymMap[SDL_SCANCODE_F7]	= IK_F7;
	KeysymMap[SDL_SCANCODE_F8]	= IK_F8;
	KeysymMap[SDL_SCANCODE_F9]	= IK_F9;
	KeysymMap[SDL_SCANCODE_F10]	= IK_F10;
	KeysymMap[SDL_SCANCODE_F11]	= IK_F11;
	KeysymMap[SDL_SCANCODE_F12]	= IK_F12;
	KeysymMap[SDL_SCANCODE_F13]	= IK_F13;
	KeysymMap[SDL_SCANCODE_F14]	= IK_F14;
	KeysymMap[SDL_SCANCODE_F15]	= IK_F15;

	// Cursor control and motion.
	KeysymMap[SDL_SCANCODE_HOME]	= IK_Home;
	KeysymMap[SDL_SCANCODE_LEFT]	= IK_Left;
	KeysymMap[SDL_SCANCODE_UP]	= IK_Up;
	KeysymMap[SDL_SCANCODE_RIGHT]	= IK_Right;
	KeysymMap[SDL_SCANCODE_DOWN]	= IK_Down;
	KeysymMap[SDL_SCANCODE_PAGEUP]	= IK_PageUp;
	KeysymMap[SDL_SCANCODE_PAGEDOWN]= IK_PageDown;
	KeysymMap[SDL_SCANCODE_END]	= IK_End;

	// Keypad functions and numbers.
	KeysymMap[SDL_SCANCODE_KP_ENTER]= IK_Enter;
	KeysymMap[SDL_SCANCODE_KP_0]	= IK_NumPad0;
	KeysymMap[SDL_SCANCODE_KP_1]	= IK_NumPad1;
	KeysymMap[SDL_SCANCODE_KP_2]	= IK_NumPad2;
	KeysymMap[SDL_SCANCODE_KP_3]	= IK_NumPad3;
	KeysymMap[SDL_SCANCODE_KP_4]	= IK_NumPad4;
	KeysymMap[SDL_SCANCODE_KP_5]	= IK_NumPad5;
	KeysymMap[SDL_SCANCODE_KP_6]	= IK_NumPad6;
	KeysymMap[SDL_SCANCODE_KP_7]	= IK_NumPad7;
	KeysymMap[SDL_SCANCODE_KP_8]	= IK_NumPad8;
	KeysymMap[SDL_SCANCODE_KP_9]	= IK_NumPad9;
	KeysymMap[SDL_SCANCODE_KP_MULTIPLY]= IK_GreyStar;
	KeysymMap[SDL_SCANCODE_KP_PLUS]	= IK_GreyPlus;
	KeysymMap[SDL_SCANCODE_KP_EQUALS] = IK_Separator;
	KeysymMap[SDL_SCANCODE_KP_MINUS] = IK_GreyMinus;
	KeysymMap[SDL_SCANCODE_KP_PERIOD] = IK_NumPadPeriod;
	KeysymMap[SDL_SCANCODE_KP_DIVIDE] = IK_GreySlash;

	// Other
	KeysymMap[SDL_SCANCODE_MINUS]	= IK_Minus;
	KeysymMap[SDL_SCANCODE_EQUALS]	= IK_Equals;     
	KeysymMap[SDL_SCANCODE_NUMLOCKCLEAR]	= IK_NumLock;
	KeysymMap[SDL_SCANCODE_CAPSLOCK]	= IK_CapsLock;
	KeysymMap[SDL_SCANCODE_SCROLLLOCK]	= IK_ScrollLock;
	
	// Numbers
		// Keypad functions and numbers.
	KeysymMap[SDL_SCANCODE_0] = IK_0;
	KeysymMap[SDL_SCANCODE_1] = IK_1;
	KeysymMap[SDL_SCANCODE_2] = IK_2;
	KeysymMap[SDL_SCANCODE_3] = IK_3;
	KeysymMap[SDL_SCANCODE_4] = IK_4;
	KeysymMap[SDL_SCANCODE_5] = IK_5;
	KeysymMap[SDL_SCANCODE_6] = IK_6;
	KeysymMap[SDL_SCANCODE_7] = IK_7;
	KeysymMap[SDL_SCANCODE_8] = IK_8;
	KeysymMap[SDL_SCANCODE_9] = IK_9;

	// Another
	KeysymMap[SDL_SCANCODE_SPACE] = IK_Space;
	// Letters. Yes, i can't do this in cycle
	KeysymMap[SDL_SCANCODE_A] = IK_A;
	KeysymMap[SDL_SCANCODE_B] = IK_B;
	KeysymMap[SDL_SCANCODE_C] = IK_C;
	KeysymMap[SDL_SCANCODE_D] = IK_D;
	KeysymMap[SDL_SCANCODE_E] = IK_E;
	KeysymMap[SDL_SCANCODE_F] = IK_F;
	KeysymMap[SDL_SCANCODE_G] = IK_G;
	KeysymMap[SDL_SCANCODE_H] = IK_H;
	KeysymMap[SDL_SCANCODE_I] = IK_I;
	KeysymMap[SDL_SCANCODE_J] = IK_J;
	KeysymMap[SDL_SCANCODE_K] = IK_K;
	KeysymMap[SDL_SCANCODE_L] = IK_L;
	KeysymMap[SDL_SCANCODE_M] = IK_M;
	KeysymMap[SDL_SCANCODE_N] = IK_N;
	KeysymMap[SDL_SCANCODE_O] = IK_O;
	KeysymMap[SDL_SCANCODE_P] = IK_P;
	KeysymMap[SDL_SCANCODE_Q] = IK_Q;
	KeysymMap[SDL_SCANCODE_R] = IK_R;
	KeysymMap[SDL_SCANCODE_S] = IK_S;
	KeysymMap[SDL_SCANCODE_T] = IK_T;
	KeysymMap[SDL_SCANCODE_U] = IK_U;
	KeysymMap[SDL_SCANCODE_V] = IK_V;
	KeysymMap[SDL_SCANCODE_W] = IK_W;
	KeysymMap[SDL_SCANCODE_X] = IK_X;
	KeysymMap[SDL_SCANCODE_Y] = IK_Y;
	KeysymMap[SDL_SCANCODE_Z] = IK_Z;

	KeyRepeatKey = 0;
	KeyRepeatUnicode = 0;
	LastJoyHat = IK_None;
	debugf( TEXT("Created and initialized a new SDL viewport.") );

	unguard;
}

//
// Destroy.
//
void USDLViewport::Destroy() //TODO: dont forget properly destroy window
{
	guard(USDLViewport::Destroy);
	Super::Destroy();

	if( BlitFlags & BLIT_Temporary )
		appFree( ScreenPointer );

    if (TextToSpeechObject != -1)
    {
		// EMNLGLSN close(TextToSpeechObject);
        TextToSpeechObject = -1;
    }

	unguard;
}

//
// Error shutdown.
//
void USDLViewport::ShutdownAfterError()
{
    SDL_Quit();
	Super::ShutdownAfterError();
}

// EMNLGLSN
/*
void USDLViewport::UpdateMouseGrabState()
{
	MouseIsGrabbed = 0;
	if (Window != NULL)
	{
		MouseIsGrabbed = (SDL_GetWindowFlags(Window) & SDL_WINDOW_FULLSCREEN || SDL_GetWindowMouseGrab(Window));
		//MouseIsGrabbed = ( (surface->flags & SDL_FULLSCREEN) ||
		                   //(SDL_WM_GrabInput(SDL_GRAB_QUERY) == SDL_GRAB_ON) );//SDL_CaptureMouse(bool enabled);
	}
}
*/

/*-----------------------------------------------------------------------------
	Command line.
-----------------------------------------------------------------------------*/

//
// Command line.
//
UBOOL USDLViewport::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(USDLViewport::Exec);
	if( UViewport::Exec( Cmd, Ar ) )
	{
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("ENDFULLSCREEN")) )
	{
		if( BlitFlags & BLIT_Fullscreen )
			EndFullscreen();
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("TOGGLEFULLSCREEN")) )
	{
		ToggleFullscreen();
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("GETCURRENTRES")) )
	{
		Ar.Logf( TEXT("%ix%i"), SizeX, SizeY ); // gam
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("GETCURRENTCOLORDEPTH")) )
	{
		Ar.Logf( TEXT("%i"), (ColorBytes?ColorBytes:2)*8 );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("GETCOLORDEPTHS")) )
	{
		Ar.Log( TEXT("32") ); //16
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("GETCURRENTRENDERDEVICE")) )
	{
		Ar.Log( RenDev->GetClass()->GetPathName() );
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("SUPPORTEDRESOLUTION")) )
	{
		INT		Width = 0,
				Height = 0,
				BitDepth = 0;
		UBOOL	Supported = 0;

		if(Parse(Cmd,TEXT("WIDTH="),Width) && Parse(Cmd,TEXT("HEIGHT="),Height) && Parse(Cmd,TEXT("BITDEPTH="),BitDepth))
		{
			// EMNLGLSN
			/*
            Uint32 flags = SDL_FULLSCREEN;
            if (RenDev && (BlitFlags & BLIT_OpenGL))
                flags |= SDL_OPENGL;
            if (SDL_VideoModeOK(Width, Height, BitDepth, flags))
                Supported = 1;
			*/
		}

		Ar.Logf(TEXT("%u"),Supported);

		return 1;
	}

	else if( ParseCommand(&Cmd,TEXT("SETRES")) )
	{
		INT X=appAtoi(Cmd);
		const TCHAR* CmdTemp = appStrchr(Cmd,'x') ? appStrchr(Cmd,'x')+1 : appStrchr(Cmd,'X') ? appStrchr(Cmd,'X')+1 : TEXT("");
		INT Y=appAtoi(CmdTemp);
		Cmd = CmdTemp;
		CmdTemp = appStrchr(Cmd,'x') ? appStrchr(Cmd,'x')+1 : appStrchr(Cmd,'X') ? appStrchr(Cmd,'X')+1 : TEXT("");
		INT BPP=appAtoi(CmdTemp);
		Cmd = CmdTemp;
		UBOOL	Fullscreen = IsFullscreen() || FullscreenOnly;
		if(appStrchr(Cmd,'w') || appStrchr(Cmd,'W'))
			Fullscreen = 0;
		else if(appStrchr(Cmd,'f') || appStrchr(Cmd,'F'))
			Fullscreen = 1;
		if( X && Y )
		{
			INT ColorBytes = 0;
			switch( BPP )
			{
			case 16:
				ColorBytes = 2;
				break;
			case 24:
			case 32:
				ColorBytes = 4;
				break;
			}
			UBOOL Result = RenDev->SetRes( this, X, Y, Fullscreen || FullscreenOnly, ColorBytes );
			if( !Result )
				EndFullscreen();

			if ( GUIController )
				GUIController->ResolutionChanged(X, Y);
		}
		return 1;
	}

	else if( ParseCommand(&Cmd,TEXT("TEMPSETRES")) )
	{
		INT X=appAtoi(Cmd);
		const TCHAR* CmdTemp = appStrchr(Cmd,'x') ? appStrchr(Cmd,'x')+1 : appStrchr(Cmd,'X') ? appStrchr(Cmd,'X')+1 : TEXT("");
		INT Y=appAtoi(CmdTemp);
		Cmd = CmdTemp;
		CmdTemp = appStrchr(Cmd,'x') ? appStrchr(Cmd,'x')+1 : appStrchr(Cmd,'X') ? appStrchr(Cmd,'X')+1 : TEXT("");
		INT BPP=appAtoi(CmdTemp);
		Cmd = CmdTemp;
		UBOOL	Fullscreen = IsFullscreen() || FullscreenOnly;
		if(appStrchr(Cmd,'w') || appStrchr(Cmd,'W'))
			Fullscreen = 0;
		else if(appStrchr(Cmd,'f') || appStrchr(Cmd,'F'))
			Fullscreen = 1;

		USDLClient*	Client = GetOuterUSDLClient();
		INT				SavedX,
						SavedY;
		if(Fullscreen)
		{
			SavedX = Client->FullscreenViewportX;
			SavedY = Client->FullscreenViewportY;
		}
		else
		{
			SavedX = Client->WindowedViewportX;
			SavedY = Client->WindowedViewportY;
		}

		if( X && Y )
		{
			INT ColorBytes = 0;
			switch( BPP )
			{
			case 16:
				ColorBytes = 2;
				break;
			case 24:
			case 32:
				ColorBytes = 4;
				break;
			}
			UBOOL Result = RenDev->SetRes( this, X, Y, Fullscreen || FullscreenOnly, ColorBytes,0 );
			if( !Result )
				EndFullscreen();

			if ( GUIController )
				GUIController->ResolutionChanged(X, Y);
		}

		if(Fullscreen)
		{
			Client->FullscreenViewportX = SavedX;
			Client->FullscreenViewportY = SavedY;
		}
		else
		{
			Client->WindowedViewportX = SavedX;
			Client->WindowedViewportY = SavedY;
		}
		Client->SaveConfig();

		return 1;
	}

    #if 0  // !!! uh...?
	else if( ParseCommand(&Cmd,TEXT("PREFERENCES")) )
	{
		USDLClient* Client = GetOuterUSDLClient();
		Client->ConfigReturnFullscreen = 0;
		if( BlitFlags & BLIT_Fullscreen )
		{
			EndFullscreen();
			Client->ConfigReturnFullscreen = 1;
		}
		if( !Client->ConfigProperties )
		{
			Client->ConfigProperties = new WConfigProperties( TEXT("Preferences"), LocalizeGeneral("AdvancedOptionsTitle",TEXT("Window")) );
			Client->ConfigProperties->SetNotifyHook( Client );
			Client->ConfigProperties->OpenWindow( Window->hWnd );
			Client->ConfigProperties->ForceRefresh();
		}
		GetOuterUSDLClient()->ConfigProperties->Show(1);
		SetFocus( *GetOuterUSDLClient()->ConfigProperties );
		return 1;
	}
    #endif

	// gam ---
	else if( ParseCommand(&Cmd,TEXT("SETMOUSE")) )
	{
	    const TCHAR* CmdTemp = Cmd;
		INT X, Y;
		
		X = appAtoi(CmdTemp);
		
		while( appIsDigit( *CmdTemp) )
		    CmdTemp++;

		while( appIsSpace( *CmdTemp) )
		    CmdTemp++;
		    
		Y = appAtoi(CmdTemp);
		
        //FIXME SDL_WarpMouse(X, Y);
		//SDL_WarpMouseInWindow( Window , 0, 0);
        return 1;
	}

	else if( ParseCommand(&Cmd,TEXT("TTS")) )
	{
		if( appStrcmp(Cmd,TEXT("")) != 0 )
			TextToSpeech( FString(Cmd), 1.f );
		return 1;
	}

        // vi represent!  --ryan.
    else if ((ParseCommand(&Cmd,TEXT(":wq"))) || (ParseCommand(&Cmd,TEXT(":q!"))))
    {
        GIsRequestingExit = 1;
    }

	// --- gam
	else return 0;
	unguard;
}

/*-----------------------------------------------------------------------------
	Window openining and closing.
-----------------------------------------------------------------------------*/

//
// Open this viewport's window.
//
void USDLViewport::OpenWindow( PTRINT InParentWindow, UBOOL IsTemporary, INT NewX, INT NewY, INT OpenX, INT OpenY )
{
	guard(USDLViewport::OpenWindow);

	Window = SDL_CreateWindow("NULL", 640, 480, SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
	Context = SDL_GL_CreateContext(Window);
	ScreenSurface = SDL_GetWindowSurface(Window); // This function must be called every time window resised
	SDL_GL_MakeCurrent(Window, Context);
	SDL_SetWindowRelativeMouseMode(Window, true); // Maybe i need move this to another location

    // Can't do multiple windows with SDL 1.2.
    // Eh...Splash screen. !!! FIXME.
    //check(SDL_GetVideoSurface() == NULL);

	// Check resolution.
	//FIXME
	/*
	if (SDL_BITSPERPIXEL(SDL_GetCurrentDisplayMode(0)->format) < 24 && GIsEditor)
		appErrorf(TEXT("Editor requires desktop set to 32 bit resolution"));
	*/
	check(Actor);
	UBOOL DoRepaint=0, DoSetActive=0;
	USDLClient* C = GetOuterUSDLClient();

    if (TextToSpeechObject == -1)
    {
        if (C->TextToSpeechFile.Len() == 0)
            debugf(TEXT("TTS: No output filename specified."));
        else
        {
            // Please note we don't create this file...
			// EMNLGLSN TextToSpeechObject = open(appToAnsi(*(C->TextToSpeechFile)), O_WRONLY);
            if (TextToSpeechObject != -1)
                debugf(TEXT("TTS: Opened file \"%s\" for text-to-speech output."), *(C->TextToSpeechFile));
            else
            {
                int err = errno;
                debugf(TEXT("TTS: Couldn't open TTS file \"%s\""), *(C->TextToSpeechFile));
                debugf(TEXT("TTS: System error is \"%s\" (%d)."), appFromAnsi(strerror(err)), err);
                if (err == ENOENT)
                {
                    debugf(TEXT("TTS: (We intentionally don't create this file if it doesn't exist!)"));
                    debugf(TEXT("TTS: Disabling Text-to-speech support..."));
                }
            }
        }
    }


	if( NewX!=INDEX_NONE )
		NewX = Align( NewX, 2 );

	// User window of launcher if no parent window was specified.
    // !!! FIXME: commented out because of compiler issue. --ryan.
	//if( !InParentWindow )
	//	Parse( appCmdLine(), TEXT("HWND="), InParentWindow );

	// Create frame buffer.
	if( IsTemporary )
	{
		// Create in-memory data.
		BlitFlags     = BLIT_Temporary;
		ColorBytes    = 2;
		SizeX         = NewX;
		SizeY         = NewY;
		ScreenPointer = (BYTE*)appMalloc( 2 * NewX * NewY, TEXT("TemporaryViewportData") );	
		debugf( NAME_Log, TEXT("Opened temporary viewport") );
   	}

	// Create rendering device.
	if( !RenDev && !appStrcmp( GetName(), TEXT("VisibiltyViewport") ) )
		TryRenderDevice( TEXT("Editor.VisibilityRenderDevice"), NewX, NewY, 0 );
	if( !RenDev && (BlitFlags & BLIT_Temporary) )
		TryRenderDevice( TEXT("NullDrv.NullRenderDevice"), NewX, NewY, 0 );
	if( !RenDev && !GIsEditor && ParseParam(appCmdLine(),TEXT("windowed")) )
		TryRenderDevice( TEXT("ini:Engine.Engine.RenderDevice"), NewX, NewY, 0 );
	if( !RenDev )
		TryRenderDevice( TEXT("ini:Engine.Engine.RenderDevice"), NewX, NewY, GIsEditor ? 0 : C->StartupFullscreen );

	check(RenDev);
	RenDev->UpdateGamma( this );
	UpdateWindowFrame();

	unguard;
}

//
// Close a viewport window.  Assumes that the viewport has been opened with
// OpenViewportWindow.  Does not affect the viewport's object, only the
// platform-specific information associated with it.
//
void USDLViewport::CloseWindow()
{
	guard(USDLViewport::CloseWindow);
	
	SDL_DestroyWindow(Window);
	SDL_GL_DestroyContext(Context);

	unguard;
}

/*-----------------------------------------------------------------------------
	USDLViewport operations.
-----------------------------------------------------------------------------*/

//
// Set window position according to menu's on-top setting:
//
void USDLViewport::SetTopness()
{
	guard(USDLViewport::SetTopness);
    /* no-op. */
	unguard;
}

//
// Repaint the viewport.
//
void USDLViewport::Repaint( UBOOL Blit )
{
	guard(USDLViewport::Repaint);
	GetOuterUSDLClient()->Engine->Draw( this, Blit );
	SDL_GL_SwapWindow(Window);
	unguard;
}

//
// Return whether fullscreen.
//
UBOOL USDLViewport::IsFullscreen()
{
	guard(USDLViewport::IsFullscreen);
	return (BlitFlags & BLIT_Fullscreen)!=0;
	unguard;
}

//
// Set the mouse cursor according to Unreal or UnrealEd's mode, or to
// an hourglass if a slow task is active.
//
void USDLViewport::SetModeCursor()
{
	guard(USDLViewport::SetModeCursor);

// !!! FIXME: What to do with this?
#if 0 // original WinDrv code follows:
	if( GIsSlowTask )
	{
		SetCursor(LoadCursorIdX(NULL,IDC_WAIT));
		return;
	}
	HCURSOR hCursor = NULL;
	switch( GetOuterUSDLClient()->Engine->edcamMode(this) )
	{
		case EM_ViewportZoom:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_CameraZoom); break;
		case EM_ActorRotate:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_BrushRot); break;
		case EM_ActorScale:			hCursor = LoadCursorIdX(hInstance,IDCURSOR_BrushScale); break;
		case EM_ActorSnapScale:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_BrushSnap); break;
		case EM_TexturePan:			hCursor = LoadCursorIdX(hInstance,IDCURSOR_TexPan); break;
		case EM_TextureRotate:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_TexRot); break;
		case EM_TextureScale:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_TexScale); break;
		case EM_None: 				hCursor = LoadCursorIdX(NULL,IDC_CROSS); break;
		case EM_ViewportMove:		hCursor = LoadCursorIdX(NULL,IDC_CROSS); break;
		case EM_TexView:			hCursor = LoadCursorIdX(NULL,IDC_ARROW); break;
		case EM_TexBrowser:			hCursor = LoadCursorIdX(NULL,IDC_ARROW); break;
		case EM_StaticMeshBrowser:	hCursor = LoadCursorIdX(NULL,IDC_CROSS); break;
		case EM_MeshView:			hCursor = LoadCursorIdX(NULL,IDC_CROSS); break;
		case EM_Animation:			hCursor = LoadCursorIdX(NULL,IDC_CROSS); break;
		case EM_VertexEdit:			hCursor = LoadCursorIdX(hInstance,IDCURSOR_VertexEdit); break;
		case EM_BrushClip:			hCursor = LoadCursorIdX(hInstance,IDCURSOR_BrushClip); break;
		case EM_FaceDrag:			hCursor = LoadCursorIdX(hInstance,IDCURSOR_FaceDrag); break;
		case EM_Polygon:			hCursor = LoadCursorIdX(hInstance,IDCURSOR_BrushWarp); break;
		case EM_TerrainEdit:
		{
			switch( GetOuterUSDLClient()->Engine->edcamTerrainBrush() )
			{
				case TB_VertexEdit:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_TB_VertexEdit); break;
				case TB_Paint:			hCursor = LoadCursorIdX(hInstance,IDCURSOR_TB_Paint); break;
				case TB_Smooth:			hCursor = LoadCursorIdX(hInstance,IDCURSOR_TB_Smooth); break;
				case TB_Noise:			hCursor = LoadCursorIdX(hInstance,IDCURSOR_TB_Noise); break;
				case TB_Flatten:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_TB_Flatten); break;
				case TB_TexturePan:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_TexPan); break;
				case TB_TextureRotate:	hCursor = LoadCursorIdX(hInstance,IDCURSOR_TexRot); break;
				case TB_TextureScale:	hCursor = LoadCursorIdX(hInstance,IDCURSOR_TexScale); break;
				case TB_Select:			hCursor = LoadCursorIdX(hInstance,IDCURSOR_TB_Selection); break;
				case TB_Visibility:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_TB_Visibility); break;
				case TB_Color:			hCursor = LoadCursorIdX(hInstance,IDCURSOR_TB_Color); break;
				case TB_EdgeTurn:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_TB_EdgeTurn); break;
				default:				hCursor = LoadCursorIdX(hInstance,IDCURSOR_TerrainEdit); break;
			}
		}
		break;
		case EM_PrefabBrowser:	hCursor = LoadCursorIdX(NULL,IDC_CROSS); break;
		case EM_Matinee:	 	hCursor = LoadCursorIdX(hInstance,IDCURSOR_Matinee); break;
		case EM_EyeDropper:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_EyeDropper); break;
		case EM_FindActor:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_FindActor); break;
		case EM_Geometry:		hCursor = LoadCursorIdX(hInstance,IDCURSOR_Geometry); break;
		
		case EM_NewCameraMove:	hCursor = LoadCursorIdX(NULL,IDC_CROSS); break;
		default: 				hCursor = LoadCursorIdX(NULL,IDC_ARROW); break;
	}
	check(hCursor);
	SetCursor( hCursor );
#endif

	unguard;
}


void USDLViewport::SetTitleBar()
{
    TCHAR WindowName[80];
	// Set viewport window's name to show resolution.
	if( !GIsEditor || (Actor->ShowFlags&SHOW_PlayerCtrl) )
	{
		appSprintf( WindowName, LocalizeGeneral("Product",appPackage()) );
	}
	else switch( Actor->RendMap )
	{
		case REN_Wire:		appStrcpy(WindowName,LocalizeGeneral(TEXT("ViewPersp"),TEXT("WinDrv"))); break;
		case REN_OrthXY:	appStrcpy(WindowName,LocalizeGeneral(TEXT("ViewXY")   ,TEXT("WinDrv"))); break;
		case REN_OrthXZ:	appStrcpy(WindowName,LocalizeGeneral(TEXT("ViewXZ")   ,TEXT("WinDrv"))); break;
		case REN_OrthYZ:	appStrcpy(WindowName,LocalizeGeneral(TEXT("ViewYZ")   ,TEXT("WinDrv"))); break;
		default:			appStrcpy(WindowName,LocalizeGeneral(TEXT("ViewOther"),TEXT("WinDrv"))); break;
	}

	//SDL_WM_SetCaption(appToAnsi(WindowName), appToAnsi(appPackage()));
	SDL_SetWindowTitle(Window, appToAnsi(WindowName));
	//FIXME SDL_SetWindowIcon(Window, )
	/*
    static bool loaded_icon = false;
    if (!loaded_icon)
    {
        loaded_icon = true;
        SDL_Surface *icon = SDL_LoadBMP("../Help/Unreal.bmp");
        if (icon != NULL)
        {
            Uint8 *mask = NULL;
            int bpp = icon->format->BytesPerPixel;

            if ((bpp >= 1) && (bpp <= 4))
            {
                int masksize = (icon->h * (icon->w + 7)) / 8;
                mask = new Uint8[masksize];
                Uint8 *dst = mask;
                Uint8 *src = (Uint8 *) icon->pixels;

                int bit = 7;
                memset(dst, '\0', masksize);

                for (int h = 0; h < icon->h; h++)
                {
                    for (int w = 0; w < icon->w; w++)
                    {
                        Uint8 r, g, b;

                        if (bit < 0)
                        {
                            dst++;
                            bit = 7;
                        }

                        if (bpp == 3)
                        {
                            // !!! FIXME: this is wrong, really.
                            r = src[0];
                            g = src[1];
                            b = src[2];
                        }

                        else
                        {
                            Uint32 pixel = 0;
                            if (bpp == 4)
                                pixel = *((Uint32 *) src);
                            else if (bpp == 2)
                                pixel = *((Uint16 *) src);
                            else
                                pixel = *((Uint8 *) src);

                            SDL_GetRGB(pixel, icon->format, &r, &g, &b);
                        }

                        if (!((r == 0xFF) && (b == 0xFF) && (g == 0)))
                            *dst |= (1 << bit);

                        bit--;
                        src += bpp;
                    }
                }
            }
            SDL_WM_SetIcon(icon, mask);
        }
    } */
}


//
// Update user viewport interface.
//
void USDLViewport::UpdateWindowFrame()
{
	guard(USDLViewport::UpdateWindowFrame);

	// If not a window, exit.
	if( !ScreenSurface || (BlitFlags&BLIT_Fullscreen) || (BlitFlags&BLIT_Temporary) || !Actor)
		return;

    SetTitleBar();

	unguard;
}

//
// Return the viewport's window.
//
void* USDLViewport::GetWindow()
{
	guard(USDLViewport::GetWindow);
	return ScreenSurface;
	unguard;
}

/*-----------------------------------------------------------------------------
	Input.
-----------------------------------------------------------------------------*/

//
// Input event router.
//
UBOOL USDLViewport::CauseInputEvent( INT iKey, EInputAction Action, FLOAT Delta )
{
	guard(USDLViewport::CauseInputEvent);
	return GetOuterUSDLClient()->Engine->InputEvent( this, (EInputKey)iKey, Action, Delta );
	unguard;
}

//
// If the cursor is currently being captured, stop capturing, clipping, and 
// hiding it, and move its position back to where it was when it was initially
// captured.
//
void USDLViewport::SetMouseCapture( UBOOL Capture, UBOOL Clip, UBOOL OnlyFocus )
{
	guard(USDLViewport::SetMouseCapture);

	// Handle capturing.
	if( Capture )
	{
		if (SavedCursorX == -1) {
				SDL_GetMouseState((float *) &SavedCursorX, (float*)&SavedCursorY);
			}

		//FIXME SDL_WM_GrabInput(SDL_GRAB_ON);
		//SDL_SetWindowMouseGrab(Window, true);
	}
	else
	{
		//FIXME SDL_WM_GrabInput(SDL_GRAB_OFF);
		//SDL_SetWindowMouseGrab(Window, false);

        #if 1  // !!! FIXME: This is screwey on the main menu (pops mouse on quit dialog)
		if (GetOuterUSDLClient()->Engine->edcamMouseControl(this) == MOUSEC_Locked)
			//SDL_WarpMouse(SavedCursorX, SavedCursorY);
			//SDL_WarpMouseInWindow( Window, (float)SavedCursorX, (float)SavedCursorY ); //BULLSHIT ALERT
        #endif

  		SavedCursorX = -1;
	}

	// EMNLGLSN	UpdateMouseGrabState();

	unguard;
}


//
// Update input for this viewport.
//
void USDLViewport::UpdateInput( UBOOL Reset, FLOAT DeltaSeconds )
{
	guard(USDLViewport::UpdateInput);

    UpdateSpeech();

	USDLClient* Client = GetOuterUSDLClient();

	if ((Client->UseJoystick) && (USDLClient::Joystick != NULL))
	{
		SDL_UpdateJoysticks();
	}

	// Keyboard.
	EInputKey Key = IK_None;
	EInputKey UpperCase = IK_None;
	EInputKey LowerCase = IK_None;

	// Mouse movement management.
	UBOOL MouseMoved = false;
	UBOOL JoyHatMoved = false;
	INT DX = 0, DY = 0;
	EInputKey ThisJoyHat = IK_None;

	SDL_Event Event;
	while (SDL_PollEvent(&Event))
	{
		switch (Event.type)
		{
		case SDL_EVENT_QUIT:
			GIsRequestingExit = 1;
			break;
		case SDL_EVENT_KEY_DOWN:
			Key = (EInputKey)KeysymMap[Event.key.scancode];
			CauseInputEvent(Key, IST_Press);
			if(Key >= IK_A && Key <= IK_Z) //Lowercase a in 97 //IK_Z
			{
				if (Event.key.mod & SDL_KMOD_SHIFT) {
					Client->Engine->Key(this, Key, (TCHAR)Key);
				}
				else {
					Client->Engine->Key(this, Key, (TCHAR)Key+32);
				}
			}
			else {
				Client->Engine->Key(this, Key, (TCHAR)Key);
			}
			break;
		case SDL_EVENT_KEY_UP:
			Key = (EInputKey)KeysymMap[Event.key.scancode];
			CauseInputEvent(Key, IST_Release);
			break;
		// Mouse:
		case SDL_EVENT_MOUSE_BUTTON_DOWN:
			switch (Event.button.button)
			{
			case 1:
				Key = IK_LeftMouse;
				break;
			case 2:
				Key = IK_MiddleMouse;
				break;
			case 3:
				Key = IK_RightMouse;
				break;
			case 4:
				Key = IK_MouseWheelUp;
				break;
			case 5:
				Key = IK_MouseWheelDown;
				break;
			case 6:
				Key = IK_Mouse4;
				break;
			case 7:
				Key = IK_Mouse5;
				break;
			case 8:
				Key = IK_Mouse6;
				break;
			case 9:
				Key = IK_Mouse7;
				break;
			case 10:
				Key = IK_Mouse8;
				break;
			}
			// Send to input system.
			CauseInputEvent(Key, IST_Press);
			break;
		case SDL_EVENT_MOUSE_BUTTON_UP:
			switch (Event.button.button)
			{
			case 1:
				Key = IK_LeftMouse;
				break;
			case 2:
				Key = IK_MiddleMouse;
				break;
			case 3:
				Key = IK_RightMouse;
				break;
			case 4:
				Key = IK_MouseWheelUp; // Maybe we need something else this
				break;
			case 5:
				Key = IK_MouseWheelDown; // Maybe we need something else this
				break;
			case 6:
				Key = IK_Mouse4;
				break;
			case 7:
				Key = IK_Mouse5;
				break;
			case 8:
				Key = IK_Mouse6;
				break;
			case 9:
				Key = IK_Mouse7;
				break;
			case 10:
				Key = IK_Mouse8;
				break;
			}
			// Send to input system.
			CauseInputEvent(Key, IST_Release);
			break;

		case SDL_EVENT_MOUSE_WHEEL: //TODO: rewrite this
			if (Event.wheel.integer_y > 0) {
				Key = IK_MouseWheelUp;
				}
			else {
				Key = IK_MouseWheelDown;
			}
			CauseInputEvent(Key, IST_Press);
			CauseInputEvent(Key, IST_Release);
			break;
		case SDL_EVENT_MOUSE_MOTION:
			if ((!MouseIsGrabbed) && (Client->IgnoreUngrabbedMouse))
				break;

			//MouseMoved = true;
			//DX += Event.motion.xrel;
			//DY += Event.motion.yrel;
			CauseInputEvent(IK_MouseX, IST_Axis, Event.motion.xrel);
			CauseInputEvent(IK_MouseY, IST_Axis, -Event.motion.yrel);
			break;

		default:
			break;
		}
	}

	unguard;
}



/*-----------------------------------------------------------------------------
	Lock and Unlock.
-----------------------------------------------------------------------------*/

//
// Lock the viewport window and set the approprite Screen and RealScreen fields
// of Viewport.  Returns 1 if locked successfully, 0 if failed.  Note that a
// lock failing is not a critical error; it's a sign that a DirectDraw mode
// has ended or the user has closed a viewport window.
//
UBOOL USDLViewport::Lock( BYTE* HitData, INT* HitSize )
{
	guard(USDLViewport::Lock);

	// Success here, so pass to superclass.
	return UViewport::Lock(HitData,HitSize);

	unguard;
}

//
// Unlock the viewport window.  If Blit=1, blits the viewport's frame buffer.
//
void USDLViewport::Unlock()
{
	guard(USDLViewport::Unlock);
	UViewport::Unlock();
	unguard;
}

/*-----------------------------------------------------------------------------
	Viewport modes.
-----------------------------------------------------------------------------*/

//
// Try switching to a new rendering device.
//
UBOOL USDLViewport::TryRenderDevice( const TCHAR* ClassName, INT NewX, INT NewY, UBOOL Fullscreen )
{
	guard(USDLViewport::TryRenderDevice);

	// Shut down current rendering device.
	guard(ShutdownOldRenDev);
	if( RenDev && RenDev != GetOuterUSDLClient()->Engine->GRenDev ) 
	{
		RenDev->Exit(this);
		delete RenDev;
		RenDev = NULL;
	}
	unguard;

	// Use appropriate defaults.
	USDLClient* C = GetOuterUSDLClient();
	if( NewX==INDEX_NONE )
		NewX = (Fullscreen || FullscreenOnly) ? C->FullscreenViewportX : C->WindowedViewportX;
	if( NewY==INDEX_NONE )
		NewY = (Fullscreen || FullscreenOnly) ? C->FullscreenViewportY : C->WindowedViewportY;

	// Find device driver.
	UClass* RenderClass = UObject::StaticLoadClass( URenderDevice::StaticClass(), NULL, ClassName, NULL, 0, NULL );
	if( RenderClass  )
	{
//!!FIXME Clean up when we remove Softdrv.
		if( RenderClass == GetOuterUSDLClient()->Engine->GRenDev->GetClass() )
		{
			RenDev = GetOuterUSDLClient()->Engine->GRenDev;
		}
		else
		{
			RenDev = ConstructObject<URenderDevice>( RenderClass, this );
			RenDev->Init();
		}

        // !!! FIXME: "ColorBytes" should be zero unless we need to fallback. It's complicated. Check this later. --ryan.
		if( RenDev->SetRes( this, NewX, NewY, Fullscreen | FullscreenOnly, ColorBytes ) )
		{
			if( GIsRunning )
				Actor->GetLevel()->DetailChange(
					RenDev->SuperHighDetailActors ? DM_SuperHigh :
					RenDev->HighDetailActors ? DM_High :
					DM_Low
					);
		}
		else
		{
			debugf( NAME_Log, LocalizeError(TEXT("Failed3D"),TEXT("SDLDrv")) );
			if( RenDev != GetOuterUSDLClient()->Engine->GRenDev ) 
				delete RenDev;
			RenDev = NULL;
		}
	}

  	if( !GIsEditor )
	{
		if ( GUIController )
		{
			GUIController->ResetInput();
			GUIController->ResolutionChanged(SizeX,SizeY);
		}
		if ( Input )
			Input->ResetInput();
    }

    return RenDev != NULL;
	unguard;
}


//
// If in fullscreen mode, end it and return to Windows.
//
void USDLViewport::EndFullscreen()
{
	guard(USDLViewport::EndFullscreen);
	USDLClient* Client = GetOuterUSDLClient();
	debugf(TEXT("EndFullscreen"));
	if( RenDev && (BlitFlags & (BLIT_Direct3D|BLIT_OpenGL)) && !FullscreenOnly )
	{
		RenDev->SetRes( this, Client->WindowedViewportX, Client->WindowedViewportY, 0 );
	}
	else if( RenDev && (BlitFlags & BLIT_OpenGL) )
	{
		RenDev->SetRes( this, INDEX_NONE, INDEX_NONE, FullscreenOnly );
	}
	UpdateWindowFrame();

	if ( GUIController )
	{
		GUIController->ResetInput();
		GUIController->ResolutionChanged(SizeX, SizeY);
	}

	if ( Input )
		Input->ResetInput();

	unguard;
}

//
// Toggle fullscreen.
//
void USDLViewport::ToggleFullscreen()
{
	guard(USDLViewport::ToggleFullscreen);
	if( BlitFlags & BLIT_Fullscreen )
	{
		EndFullscreen();
		SetMouseCapture(1,1,0);
	}
	else if( !(Actor->ShowFlags & SHOW_ChildWindow) )
	{
		debugf(TEXT("AttemptFullscreen"));
		TryRenderDevice( TEXT("ini:Engine.Engine.RenderDevice"), INDEX_NONE, INDEX_NONE, 1 );
	}
	unguard;
}

//
// Resize the viewport.
//
UBOOL USDLViewport::ResizeViewport( DWORD NewBlitFlags, INT InNewX, INT InNewY, UBOOL bSaveSize )
{
	guard(USDLViewport::ResizeViewport);
	USDLClient* Client = GetOuterUSDLClient();

	// Andrew says: I made this keep the BLIT_Temporary flag so the temporary screen buffer doesn't get leaked
	// during light rebuilds.

	// Remember viewport.
	UViewport* SavedViewport = NULL;
	if( Client->Engine->Audio && !GIsEditor && !(GetFlags() & RF_Destroyed) )
		SavedViewport = Client->Engine->Audio->GetViewport();

	// Accept default parameters.
	INT NewX          = InNewX         ==INDEX_NONE ? SizeX      : InNewX;
	INT NewY          = InNewY         ==INDEX_NONE ? SizeY      : InNewY;

	// Default resolution handling.
	NewX = InNewX!=INDEX_NONE ? InNewX : (NewBlitFlags&BLIT_Fullscreen) ? Client->FullscreenViewportX : Client->WindowedViewportX;
	NewY = InNewX!=INDEX_NONE ? InNewY : (NewBlitFlags&BLIT_Fullscreen) ? Client->FullscreenViewportY : Client->WindowedViewportY;

	// Align NewX.
	check(NewX>=0);
	check(NewY>=0);
	NewX = Align(NewX,2);

	if( !(NewBlitFlags & BLIT_Temporary) )
	{
		ScreenPointer = NULL;
	}

	// Set new info.
	DWORD OldBlitFlags = BlitFlags;
	BlitFlags          = NewBlitFlags & ~BLIT_ParameterFlags;
	SizeX              = NewX;
	SizeY              = NewY;

	SQWORD VideoFlags = 0;
	INT VideoBPP   = 0;



#if 0
	// Pull current driver string.
	FString CurrentDriver = RenDev->GetClass()->GetPathName();

	// Checking whether to use Glide specific settings or OpenGL.
	if ( !appStrcmp( *CurrentDriver, TEXT("GlideDrv.GlideRenderDevice") ) ) 
	{
		// Don't use DGA in conjunction with Glide unless user overrides it.
		if ( getenv( "SDL_VIDEO_X11_DGAMOUSE" ) == NULL )
			putenv( "SDL_VIDEO_X11_DGAMOUSE=0" );
		NewBlitFlags |= BLIT_Fullscreen;
		debugf( TEXT("GlideDrv.GlideRenderDevice") );	
	} 
	else if ( !appStrcmp( *CurrentDriver, TEXT("SDLSoftDrv.SDLSoftwareRenderDevice") ) )
	{		
		debugf( TEXT("SDLSoftDrv.SDLSoftwareRenderDevice") );
		VideoBPP = 16;
		ColorBytes = 2;
		Caps |= CC_RGB565;
	}
	else
	{
		VideoFlags |= SDL_OPENGL;
		debugf( TEXT("OpenGL") );
	}
#endif

	if( NewBlitFlags & BLIT_OpenGL )
	{
		VideoFlags |= SDL_WINDOW_OPENGL;
		debugf( TEXT("OpenGL") );
	}

	if( NewBlitFlags & BLIT_Fullscreen )
	{
		VideoFlags |= SDL_WINDOW_FULLSCREEN;
	}

    SDL_ShowCursor();

    SetTitleBar();  // This can be done before SDL_SetVideoMode().

	// OLD
	/*
  	if ( SDL_SetVideoMode( NewX, NewY, VideoBPP, VideoFlags ) == NULL )
	{
		appErrorf( TEXT("Couldn't set video mode: %s\n"), appFromAnsi(SDL_GetError()) );
		appExit();
	}
	*/
	
	//SDL_SetWindowFullscreen(Window, VideoFlags & SDL_WINDOW_FULLSCREEN);
	//SDL_SetWindowSize(Window, NewX, NewY);
	//ScreenSurface = SDL_GetWindowSurface(Window);
	//SDL_RestoreWindow(Window);
	//SDL_SetWindowPosition(Window, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
	if (VideoFlags & SDL_WINDOW_FULLSCREEN) {
		SDL_DisplayMode mode;
		mode = *SDL_GetFullscreenDisplayModes(SDL_GetDisplays(NULL)[0], NULL)[0];
		//mode = *SDL_GetWindowFullscreenMode(Window);
		mode.h = NewY;
		mode.w = NewX;
		SDL_SetWindowFullscreenMode(Window, &mode);
		SDL_SetWindowFullscreen(Window, true);
	}
	else {
		SDL_SetWindowFullscreen(Window, false);
		SDL_SetWindowSize(Window, NewX, NewY);
	}
	// EMNLGLSN UpdateMouseGrabState();

	// Make this viewport current and update its title bar.
	GetOuterUClient()->MakeCurrent( this );	

	// Update audio.
	if( SavedViewport && SavedViewport!=Client->Engine->Audio->GetViewport() )
		Client->Engine->Audio->SetViewport( SavedViewport );

	// Update the window.
	UpdateWindowFrame();

	// Save info.
	if( RenDev && !GIsEditor && bSaveSize )
	{
		if( NewBlitFlags & BLIT_Fullscreen )
		{
			if( NewX && NewY )
			{
				Client->FullscreenViewportX  = NewX;
				Client->FullscreenViewportY  = NewY;
			}
		}
		else
		{
			if( NewX && NewY )
			{
				Client->WindowedViewportX  = NewX;
				Client->WindowedViewportY  = NewY;
			}
		}
		Client->SaveConfig();
	}

	if ((VideoFlags & SDL_WINDOW_FULLSCREEN) == 0)
    {
		// EMNLGLSN SDL_WM_GrabInput(Client->CaptureMouse ? SDL_GRAB_ON : SDL_GRAB_OFF);
		SDL_SetWindowMouseGrab(Window, Client->CaptureMouse ? true : false);
		// EMNLGLSN UpdateMouseGrabState();
    }

	return 1;
	unguard;
}

//
// Get localized keyname.
//
TCHAR * USDLViewport::GetLocalizedKeyName( EInputKey Key )
{
	return TEXT("");  // !!! FIXME: implement this! --ryan.
}


void USDLViewport::UpdateSpeech()
{

}


void USDLViewport::TextToSpeech( const FString& Text, FLOAT Volume )
{
    INT len = Text.Len();
    if (len == 0)
        return;

    if (TextToSpeechObject != -1)
    {
        char *cvt = (char *) appAlloca(len + 2);
        if (cvt)
        {
            appToAnsi(*Text, cvt);
            if (cvt[len-1] != '\n')
            {
                cvt[len++] = '\n';
                cvt[len] = '\0';
            }

            // !!! FIXME: make non-blocking and use SpeechQueue
			// EMNLGLSN write(TextToSpeechObject, cvt, len);
        }
    }

    UpdateSpeech();
}


/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

