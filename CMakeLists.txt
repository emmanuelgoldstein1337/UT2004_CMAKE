cmake_minimum_required(VERSION 3.15)

project(UT2004 VERSION 3369.0 DESCRIPTION "Unreal Tournament 2004" LANGUAGES CXX C)

#SET(LIBZ_LIB optimized ${PROJECT_SOURCE_DIR}/zlib.lib debug ${PROJECT_SOURCE_DIR}/zlib.lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/System_Archive)#Move it to another location
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/System_Archive)
option(BIN_IN_SYSTEM "Place binaries in System folder" ON)
if (BIN_IN_SYSTEM)	
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/System)
else()
   	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/System)
endif()

option(BUILD_CORE "Enable building Core" ON)
option(BUILD_CORE "Enable building Engine" ON)

#set(CMAKE_CXX_FLAGS "/Zc:wchar_t")

if (MSVC)#/Zp4
    add_compile_options(/Zc:wchar_t- /EHsc /std:c++14)
else()
    # additional warnings
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

add_compile_definitions(
    ZLIB_DLL
    _WINDOWS
    _WIN32_IE=0x0200
    NDEBUG
    WIN32
    _WINDLL
    _UNICODE
    UNICODE
    DO_CHECK=0
    DO_CHECK_SLOW=0
    DO_GUARD=0
    DO_GUARD_SLOW=0
    DO_STAT=0
    DO_STAT_SLOW=0
    DO_CLOCK=0
    DO_CLOCK_SLOW=0
    ASM=1
    ASM3DNOW=0
    RESTRICTEXPORT=0
    NO_KARMA=1
    FORCE_EXTREME_PACKING=0
    WINDOWS_IGNORE_PACKING_MISMATCH=0
)


#target_compile_definitions(Core PRIVATE DO_CHECK=1 DO_CHECK_SLOW=0)
#if(BUILD_CORE)
#include_directories(PUBLIC Core/Inc Vorbis/vorbis/include Vorbis/ogg/include)

add_subdirectory(Vorbis/ogg)
set(OGG_LIBRARY Ogg::ogg)
set(OGG_INCLUDE_DIR Ogg::ogg)
add_subdirectory(Vorbis/vorbis)
add_subdirectory(Vorbis/speex)
add_subdirectory(zlib)

file(GLOB_RECURSE CORE_SRC ${PROJECT_SOURCE_DIR}/Core/Src/*.cpp ${PROJECT_SOURCE_DIR}/Core/Inc/*.h)
add_library(Core SHARED ${CORE_SRC})
add_dependencies(Core ogg vorbis vorbisfile)
target_compile_definitions(Core PRIVATE CORE_API=DLL_EXPORT)
#set_target_properties(Core PROPERTIES LINKER_LANGUAGE C)
target_link_libraries(Core PRIVATE System_Archive/ogg System_Archive/vorbis System_Archive/vorbisfile winmm)
target_include_directories(Core PRIVATE Vorbis/ogg/include Vorbis/vorbis/include Core/Inc)

file(GLOB_RECURSE ENGINE_SRC ${PROJECT_SOURCE_DIR}/Engine/Src/*.cpp ${PROJECT_SOURCE_DIR}/Engine/Inc/*.h)
add_library(Engine SHARED ${ENGINE_SRC})
add_dependencies(Engine Core)
target_compile_definitions(Engine PRIVATE ENGINE_API=DLL_EXPORT)
target_link_libraries(Engine PRIVATE System_Archive/Core)
target_include_directories(Engine PRIVATE Metoolkit/include Engine/Inc Core/Inc IFC/Inc)

file(GLOB_RECURSE FIRE_SRC ${PROJECT_SOURCE_DIR}/Fire/Src/*.cpp ${PROJECT_SOURCE_DIR}/Fire/Inc/*.h)
add_library(Fire SHARED ${FIRE_SRC})
add_dependencies(Fire Engine Core)
target_link_libraries(Fire PUBLIC System_Archive/Core System_Archive/Engine)
target_include_directories(Fire PUBLIC Engine/Inc Core/Inc Fire/Inc)

file(GLOB_RECURSE XGAME_SRC ${PROJECT_SOURCE_DIR}/XGame/Src/*.cpp ${PROJECT_SOURCE_DIR}/XGame/Inc/*.h)
add_library(XGame SHARED ${XGAME_SRC})
add_dependencies(XGame Engine Core)
target_compile_definitions(XGame PRIVATE XGAME_API=DLL_EXPORT)
target_link_libraries(XGame PUBLIC System_Archive/Core System_Archive/Engine)
target_include_directories(XGame PUBLIC Engine/Inc Core/Inc XGame/Inc)

file(GLOB_RECURSE EDITOR_SRC ${PROJECT_SOURCE_DIR}/Editor/Src/*.cpp ${PROJECT_SOURCE_DIR}/Editor/Inc/*.h)
add_library(Editor SHARED ${EDITOR_SRC})
add_dependencies(Editor Engine Core)
target_compile_definitions(Editor PRIVATE EDITOR_API=DLL_EXPORT)
target_link_libraries(Editor PUBLIC System_Archive/Core System_Archive/Engine)
target_include_directories(Editor PUBLIC Engine/Inc Core/Inc Window/Inc Metoolkit/include Editor/Inc)

file(GLOB_RECURSE IPDRV_SRC ${PROJECT_SOURCE_DIR}/IpDrv/Src/*.cpp ${PROJECT_SOURCE_DIR}/IpDrv/Inc/*.h)
add_library(IpDrv SHARED ${IPDRV_SRC})
add_dependencies(IpDrv Engine Core)
target_compile_definitions(IpDrv PRIVATE IPDRV_API=DLL_EXPORT)
target_link_libraries(IpDrv PUBLIC System_Archive/Core System_Archive/Engine PRIVATE wsock32)
target_include_directories(IpDrv PUBLIC Engine/Inc Core/Inc IpDrv/Inc)

file(GLOB_RECURSE ALAUDIO_SRC ${PROJECT_SOURCE_DIR}/ALAudio/Src/*.cpp ${PROJECT_SOURCE_DIR}/ALAudio/Inc/*.h)
add_library(ALAudio SHARED ${ALAUDIO_SRC})
add_dependencies(ALAudio Engine Core vorbis vorbisfile vorbisenc ogg libspeex)
target_compile_definitions(ALAudio PRIVATE ALAUDIO_API=DLL_EXPORT _USRDLL ALAUDIO_EXPORTS)
target_link_libraries(ALAudio PUBLIC System_Archive/Core System_Archive/Engine
    System_Archive/vorbis System_Archive/ogg System_Archive/vorbisfile
    System_Archive/vorbisenc
    System_Archive/libspeex
    PRIVATE DxGuid dsound odbc32 odbccp32)
target_include_directories(ALAudio PUBLIC Engine/Inc Core/Inc ALAudio/Inc OpenAL/Inc Vorbis/vorbis/include Vorbis/ogg/include)

file(GLOB_RECURSE WINDOW_SRC ${PROJECT_SOURCE_DIR}/Window/Src/*.cpp ${PROJECT_SOURCE_DIR}/Window/Inc/*.h)
add_library(Window SHARED ${WINDOW_SRC})
add_dependencies(Window Engine Core)
target_compile_definitions(Window PRIVATE WINDOW_API=DLL_EXPORT)
target_link_libraries(Window PUBLIC System_Archive/Core System_Archive/Engine PRIVATE comctl32)
target_include_directories(Window PUBLIC Engine/Inc Core/Inc Window/Inc)

add_library(UWeb SHARED UWeb/Src/UWeb.cpp UWeb/Src/UWebNative.cpp UWeb/Src/WebServer.cpp)
add_dependencies(UWeb Engine Core)
target_compile_definitions(UWeb PRIVATE UWEB_API=DLL_EXPORT)
target_link_libraries(UWeb PUBLIC System_Archive/Core System_Archive/Engine)
target_include_directories(UWeb PUBLIC Engine/Inc Core/Inc UWeb/Inc)

file(GLOB_RECURSE XINTERFACE_SRC ${PROJECT_SOURCE_DIR}/XInterface/Src/*.cpp ${PROJECT_SOURCE_DIR}/XInterface/Inc/*.h)
add_library(XInterface SHARED ${XINTERFACE_SRC})
add_dependencies(XInterface Engine Core IpDrv Window XGame)
target_compile_definitions(XInterface PRIVATE XINTERFACE_API=DLL_EXPORT)
target_link_libraries(XInterface PUBLIC System_Archive/Core System_Archive/Engine
    System_Archive/IpDrv System_Archive/Window System_Archive/XGame)
target_include_directories(XInterface PUBLIC
    Engine/Inc Core/Inc Window/Inc
    XInterface/Inc XGame/Inc Metoolkit/include IpDrv/Inc)

file(GLOB_RECURSE WINDRV_SRC ${PROJECT_SOURCE_DIR}/WinDrv/Src/*.cpp ${PROJECT_SOURCE_DIR}/WinDrv/Inc/*.h)
add_library(WinDrv SHARED ${WINDRV_SRC})
add_dependencies(WinDrv Window Engine Core)
target_compile_definitions(WinDrv PRIVATE WINDRV_API=DLL_EXPORT)
target_link_libraries(WinDrv PUBLIC System_Archive/Core System_Archive/Engine System_Archive/Window PRIVATE imm32 dinput8 dxguid)#dxerr8
target_include_directories(WinDrv PUBLIC Engine/Inc Core/Inc Window/Inc WinDrv/Inc
    ALegacy/DirectX8/Inc Metoolkit/include)


file(GLOB_RECURSE UTV2004_SRC ${PROJECT_SOURCE_DIR}/UTV2004/Src/*.cpp ${PROJECT_SOURCE_DIR}/UTV2004/Inc/*.h)
add_library(UTV2004 SHARED ${UTV2004_SRC})
add_dependencies(UTV2004 Engine Core IpDrv)
target_link_libraries(UTV2004 PUBLIC System_Archive/Core System_Archive/Engine System_Archive/IpDrv PRIVATE wsock32)
target_include_directories(UTV2004 PUBLIC Engine/Inc Core/Inc IpDrv/Inc UTV2004/Inc)

file(GLOB_RECURSE OPENGLDRV_SRC ${PROJECT_SOURCE_DIR}/OpenGLDrv/Src/*.cpp ${PROJECT_SOURCE_DIR}/OpenGLDrv/Inc/*.h)
add_library(OpenGLDrv SHARED ${OPENGLDRV_SRC})
add_dependencies(OpenGLDrv Engine Core)
target_compile_definitions(OpenGLDrv PRIVATE OPENGLDRV_API=DLL_EXPORT _USRDLL OPENGLDRV_EXPORTS)
target_link_libraries(OpenGLDrv PUBLIC System_Archive/Core System_Archive/Engine)
target_include_directories(OpenGLDrv PUBLIC Engine/Inc Core/Inc OpenGLDrv/Inc)

file(GLOB_RECURSE ONSLAUGHT_SRC ${PROJECT_SOURCE_DIR}/Onslaught/Src/*.cpp ${PROJECT_SOURCE_DIR}/Onslaught/Inc/*.h)
add_library(Onslaught SHARED ${ONSLAUGHT_SRC})
add_dependencies(Onslaught Engine Core XGame IpDrv)
target_compile_definitions(Onslaught PRIVATE ONSLAUGHT_API=DLL_EXPORT)
target_link_libraries(Onslaught PUBLIC System_Archive/Core System_Archive/Engine System_Archive/XGame System_Archive/IpDrv)
target_include_directories(Onslaught PUBLIC Engine/Inc Core/Inc XGame/Inc IpDrv/Inc Onslaught/Inc)

add_library(GUIDesigner SHARED GUIDesigner/Src/GUIDesign.cpp)
add_dependencies(GUIDesigner Engine Core XGame IpDrv Window XInterface)
target_compile_definitions(GUIDesigner PRIVATE GUIDESIGNER_API=DLL_EXPORT)
target_link_libraries(GUIDesigner PUBLIC System_Archive/Core System_Archive/Engine System_Archive/XGame System_Archive/XInterface System_Archive/IpDrv System_Archive/Window)
target_include_directories(GUIDesigner PUBLIC Engine/Inc Core/Inc XGame/Inc IpDrv/Inc Window/Inc UnrealEd/Inc XInterface/Inc GUIDesigner/Inc)

#file(GLOB_RECURSE D3DDRV_SRC ${PROJECT_SOURCE_DIR}/D3DDrv/Src/*.cpp ${PROJECT_SOURCE_DIR}/D3DDrv/Src/*.h)
#add_library(D3DDrv SHARED ${D3DDRV_SRC})
#target_compile_definitions(D3DDrv PRIVATE D3DDRV_API=DLL_EXPORT _USRDLL D3DDRV_EXPORTS)
#target_link_libraries(D3DDrv PUBLIC System_Archive/Core System_Archive/Engine)
#target_include_directories(D3DDrv PUBLIC Engine/Inc Core/Inc ALegacy/DirectX8/Inc D3DDrv/Src)

#file(GLOB_RECURSE D3D9DRV_SRC ${PROJECT_SOURCE_DIR}/D3D9Drv/Src/*.cpp ${PROJECT_SOURCE_DIR}/D3D9Drv/Src/*.h)
#add_library(D3D9Drv SHARED ${D3D9DRV_SRC})
#target_compile_definitions(D3D9Drv PRIVATE D3D9DRV_API=DLL_EXPORT _USRDLL D3D9DRV_EXPORTS)
#target_link_libraries(D3D9Drv PUBLIC System_Archive/Core System_Archive/Engine)
#arget_include_directories(D3D9Drv PUBLIC Engine/Inc Core/Inc ALegacy/DirectX9/Include D3D9Drv/Src)

#------- ------- ------- EXECUTABLES------- ------- -------#
add_executable(UCC UCC/Src/UCC.cpp)
add_dependencies(UCC Core Engine zlib)
target_compile_definitions(UCC PRIVATE _CONSOLE)
target_link_libraries(UCC PUBLIC System_Archive/Core System_Archive/zlib)
target_include_directories(UCC PUBLIC Core/Inc Engine/Inc Metoolkit/include)

file(GLOB_RECURSE SETUP_SRC ${PROJECT_SOURCE_DIR}/Setup/Src/*.cpp ${PROJECT_SOURCE_DIR}/Setup/Inc/*.h)
add_executable(Setup ${SETUP_SRC})
add_dependencies(Setup Core Window zlib)
#target_compile_definitions(Setup PUBLIC _CONSOLE)
target_link_options(Setup PRIVATE "/SUBSYSTEM:WINDOWS")
target_link_libraries(Setup PUBLIC System_Archive/Core System_Archive/Window System_Archive/zlib PRIVATE wsock32)
target_include_directories(Setup PUBLIC Core/Inc Window/Inc Setup/Inc ALegacy/DirectX8/Inc)

add_executable(UT2004_Game Launch/Src/Launch.cpp Launch/Src/Helper.cpp)
add_dependencies(UT2004_Game Core Engine Window zlib)
target_link_options(UT2004_Game PRIVATE "/SUBSYSTEM:WINDOWS")
target_link_libraries(UT2004_Game PUBLIC System_Archive/Core System_Archive/Engine System_Archive/Window System_Archive/zlib PRIVATE Comdlg32 Dbghelp DxGuid ddraw wbemuuid comsupp)
target_include_directories(UT2004_Game PUBLIC Core/Inc Engine/Inc Window/Inc)

#file(GLOB_RECURSE UNREALED_SRC ${PROJECT_SOURCE_DIR}/UnrealEd/Src/*.cpp ${PROJECT_SOURCE_DIR}/UnrealEd/Inc/*.h)
#add_executable(UnrealEd ${UNREALED_SRC})
#target_link_options(UnrealEd PRIVATE "/SUBSYSTEM:WINDOWS")
##target_compile_definitions(UnrealEd PUBLIC UNREALED_API=DLL_EXPORT)
#target_link_libraries(UnrealEd PUBLIC System_Archive/Core System_Archive/Engine System_Archive/Window System_Archive/Editor PRIVATE comctl32)
#target_include_directories(UnrealEd PUBLIC Core/Inc Engine/Inc Window/Inc Editor/Inc Metoolkit/include UnrealEd/Inc UnrealEd/Src)
