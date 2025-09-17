# UT2004_CMAKE
The leaked Unreal Tournament 2004 source code was modified to compile with the modern MSVC compiler.


Currently works when compiled with the msvc_x86 or msvc_x64 toolset. For the x86_64 debug builds, increased stack size is needed in build options.

To run the game, you need the "UT2004" folder beside the "UT2004_CMAKE" project folder, or edit the "System/UT2004_Game.ini" file to modify the game path.

If audio won't work, then you need to download OpenAL DLLs and place them in the "System" folder. In x86_64 builds, the DLL name should be "OpenAL64.dll" or "DefOpenAL64.dll".
Also, you need to uncheck "System Driver" in the game audio settings. You may download OpenAL Soft from https://github.com/kcat/openal-soft and rename soft_oal.dll.

KARMA Physics Engine, ForceFeedback, UnrealEd, and other stuff were disabled to make compilation possible.
