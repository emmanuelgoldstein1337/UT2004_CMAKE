/*=============================================================================
	UnVcWin32.h: Unreal definitions for Visual C++ SP2 running under Win32.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

/*----------------------------------------------------------------------------
	Platform compiler definitions.
----------------------------------------------------------------------------*/

#define __WIN32__				1
#define __INTEL__				1
#define __INTEL_BYTE_ORDER__	1

/*----------------------------------------------------------------------------
	Platform specifics types and defines.
----------------------------------------------------------------------------*/

// Undo any Windows defines.
#undef BYTE
#undef WORD
#undef DWORD
#undef INT
#undef FLOAT
#undef MAXBYTE
#undef MAXWORD
#undef MAXDWORD
#undef MAXINT
#undef CDECL

// Make sure HANDLE is defined.
#ifndef _WINDOWS_
	#define HANDLE void*
	#define HINSTANCE void*
#endif

// Sizes.
enum {DEFAULT_ALIGNMENT = 8 }; // Default boundary to align memory allocations on.
enum {CACHE_LINE_SIZE   = 32}; // Cache line size.

// Optimization macros (preceeded by #pragma).
#define DISABLE_OPTIMIZATION optimize("",off)
#ifdef _DEBUG
	#define ENABLE_OPTIMIZATION  optimize("",off)
#else
	#define ENABLE_OPTIMIZATION  optimize("",on)
#endif

// Function type macros.
#define DLL_IMPORT	__declspec(dllimport)	/* Import function from DLL */
#define DLL_EXPORT  __declspec(dllexport)	/* Export function to DLL */
#define DLL_EXPORT_CLASS	__declspec(dllexport)	/* Export class to DLL */
#define VARARGS     __cdecl					/* Functions with variable arguments */
#define CDECL	    __cdecl					/* Standard C function */
#define STDCALL		__stdcall				/* Standard calling convention */
#define FORCEINLINE __forceinline			/* Force code to be inline */
#define ZEROARRAY                           /* Zero-length arrays in structs */

// Variable arguments.

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#if defined(NO_UNICODE_OS_SUPPORT) || !defined(UNICODE)
#define VSNPRINTF _vsnprintf
#else
#define VSNPRINTF _vsnwprintf
#endif

// Variable arguments.
#define GET_VARARGS(msg,len,lastarg,fmt)	\
{	\
	va_list ArgPtr;	\
	va_start( ArgPtr, lastarg );	\
	VSNPRINTF( msg, len, fmt, ArgPtr );	\
	va_end( ArgPtr );	\
}

#define GET_VARARGS_ANSI(msg,len,lastarg,fmt)	\
{	\
	va_list ArgPtr;	\
	va_start( ArgPtr, lastarg );	\
	_vsnprintf( msg, len, fmt, ArgPtr );	\
	va_end( ArgPtr );	\
}

#define GET_VARARGS_RESULT(msg,len,lastarg,fmt,result)	\
{	\
	va_list ArgPtr;	\
	va_start( ArgPtr, lastarg );	\
	result = VSNPRINTF( msg, len, fmt, ArgPtr );	\
	va_end( ArgPtr );	\
}

// Compiler name.
#ifdef _DEBUG
	#define COMPILER "Compiled with Visual C++ Debug"
#else
	#define COMPILER "Compiled with Visual C++"
#endif

// Unsigned base types.
typedef unsigned char		BYTE;		// 8-bit  unsigned.
typedef unsigned short		_WORD;		// 16-bit unsigned.
typedef unsigned long		DWORD;		// 32-bit unsigned.
typedef unsigned __int64	QWORD;		// 64-bit unsigned.

// Signed base types.
typedef	signed char			SBYTE;		// 8-bit  signed.
typedef signed short		SWORD;		// 16-bit signed.
typedef signed int  		INT;		// 32-bit signed.
typedef signed __int64		SQWORD;		// 64-bit signed.

// Character types.
typedef char				ANSICHAR;	// An ANSI character.
typedef wchar_t				UNICHAR;	// A unicode character. //MYFIX: typedef unsigned short
typedef unsigned char		ANSICHARU;	// An ANSI character.
typedef wchar_t				UNICHARU;	// A unicode character. //MYFIX: typedef unsigned short

// Other base types.
typedef signed int			UBOOL;		// Boolean 0 (false) or 1 (true).
typedef float				FLOAT;		// 32-bit IEEE floating point.
typedef double				DOUBLE;		// 64-bit IEEE double.

#ifdef _WIN64
typedef unsigned __int64    SIZE_T;     // Corresponds to C SIZE_T.
#else
typedef unsigned long       SIZE_T;     // Corresponds to C SIZE_T.
#endif

// Bitfield type.
typedef unsigned long       BITFIELD;	// For bitfields.

#ifdef _WIN64
typedef unsigned __int64 PTRINT;
#else
typedef unsigned long PTRINT;
#endif

// Unwanted VC++ level 4 warnings to disable.
#pragma warning(disable : 4244) /* conversion to float, possible loss of data							*/
#pragma warning(disable : 4699) /* creating precompiled header											*/
#pragma warning(disable : 4200) /* Zero-length array item at end of structure, a VC-specific extension	*/
#pragma warning(disable : 4100) /* unreferenced formal parameter										*/
#pragma warning(disable : 4514) /* unreferenced inline function has been removed						*/
#pragma warning(disable : 4201) /* nonstandard extension used : nameless struct/union					*/
#pragma warning(disable : 4710) /* inline function not expanded											*/
#pragma warning(disable : 4714) /* __forceinline function not expanded									*/  
#pragma warning(disable : 4702) /* unreachable code in inline expanded function							*/
#pragma warning(disable : 4711) /* function selected for autmatic inlining								*/
#pragma warning(disable : 4725) /* Pentium fdiv bug														*/
#pragma warning(disable : 4127) /* Conditional expression is constant									*/
#pragma warning(disable : 4512) /* assignment operator could not be generated                           */
#pragma warning(disable : 4530) /* C++ exception handler used, but unwind semantics are not enabled     */
#pragma warning(disable : 4245) /* conversion from 'enum ' to 'unsigned long', signed/unsigned mismatch */
#pragma warning(disable : 4389) /* signed/unsigned mismatch (gam)                                       */
#pragma warning(disable : 4238) /* nonstandard extension used : class rvalue used as lvalue             */
#pragma warning(disable : 4251) /* needs to have dll-interface to be used by clients of class 'ULinker' */
#pragma warning(disable : 4275) /* non dll-interface class used as base for dll-interface class         */
#pragma warning(disable : 4511) /* copy constructor could not be generated                              */
#pragma warning(disable : 4284) /* return type is not a UDT or reference to a UDT                       */
#pragma warning(disable : 4355) /* this used in base initializer list                                   */
#pragma warning(disable : 4097) /* typedef-name '' used as synonym for class-name ''                    */
#pragma warning(disable : 4291) /* typedef-name '' used as synonym for class-name ''                    */
#pragma warning(disable : 4731) /* frame pointer register 'ebp' modified by inline assembly code        */
#pragma warning(disable : 4718) /* recursive call has no side effects, deleting (gam)                   */

// If C++ exception handling is disabled, force guarding to be off.
#ifndef _CPPUNWIND
	#error "Bad VCC option: C++ exception handling must be enabled"
#endif

// Make sure characters are unsigned.
#ifdef _CHAR_UNSIGNED
	#error "Bad VC++ option: Characters must be signed"
#endif

// No asm if not compiling for x86.
#if ((!defined _M_IX86) || (defined _WIN64))
	#undef ASM
	#define ASM 0
#endif

// Strings.
#define LINE_TERMINATOR TEXT("\r\n")
#define LINE_TERMINATOR_INLINE \r\n
#define PATH_SEPARATOR TEXT("\\")

// DLL file extension.
#define DLLEXT TEXT(".dll")

// Pathnames.
#define PATH(s) s

// NULL.
#define NULL 0

// Package implementation.
#if __STATIC_LINK
#define IMPLEMENT_PACKAGE_PLATFORM(pkgname) \
	extern "C" { BYTE __declspec(dllexport) GLoaded##pkgname; }
#else
#define IMPLEMENT_PACKAGE_PLATFORM(pkgname) \
	extern "C" {HINSTANCE hInstance;} \
	INT DLL_EXPORT STDCALL DllMain( HINSTANCE hInInstance, DWORD Reason, void* Reserved ) \
	{ hInstance = hInInstance; return 1; }
#endif

// Platform support options.
#define PLATFORM_NEEDS_ARRAY_NEW 1 //FIXME
#define FORCE_ANSI_LOG           1

// OS unicode function calling.
#if defined(NO_UNICODE_OS_SUPPORT) || !defined(UNICODE)
	#define TCHAR_CALL_OS(funcW,funcA) (funcA)
	#define TCHAR_TO_ANSI(str) str
	#define ANSI_TO_TCHAR(str) str
	inline CORE_API TCHAR* winAnsiToTCHAR( char* str ) { return str; }
#elif defined(NO_ANSI_OS_SUPPORT)
	#define TCHAR_CALL_OS(funcW,funcA) (funcW)
	#define TCHAR_TO_ANSI(str) str
	#define ANSI_TO_TCHAR(str) str
	inline CORE_API TCHAR* winAnsiToTCHAR( char* str ) { return str; }
#else
	CORE_API ANSICHAR* winToANSI( ANSICHAR* ACh, const UNICHAR* InUCh, INT Count );
	CORE_API INT winGetSizeANSI( const UNICHAR* InUCh );
	CORE_API UNICHAR* winToUNICODE( UNICHAR* Ch, const ANSICHAR* InUCh, INT Count );
	CORE_API INT winGetSizeUNICODE( const ANSICHAR* InACh );
	#define TCHAR_CALL_OS(funcW,funcA) (GUnicodeOS ? (funcW) : (funcA))
	#define TCHAR_TO_ANSI(str) winToANSI((ANSICHAR*)appAlloca(winGetSizeANSI((const UNICHAR *)str)),(const UNICHAR *)str,winGetSizeANSI((const UNICHAR *)str))
	#define TCHAR_TO_OEM(str) winToOEM((ANSICHAR*)appAlloca(winGetSizeANSI(str)),str,winGetSizeANSI((const UNICHAR *)str))//FIXME
	//#define ANSI_TO_TCHAR(str) winToUNICODE((TCHAR*)appAlloca(sizeof(UNICHAR)*winGetSizeUNICODE(str)),str,winGetSizeUNICODE(str))//FIXME
	#define ANSI_TO_TCHAR(str) winToUNICODE((UNICHAR *)appAlloca(sizeof(UNICHAR)*winGetSizeUNICODE(str)),str,winGetSizeUNICODE(str))
	inline CORE_API UNICHAR* winAnsiToTCHAR( char* str );
#endif

// Bitfield alignment.
#define GCC_PACK(n)
#define GCC_ALIGN(n) 
#define GCC_MOVE_ALIGN(n) 

// This is for gcc bugs, mostly.  --ryan.
#ifndef BUGGYINLINE
#define BUGGYINLINE inline
#endif

/*----------------------------------------------------------------------------
	Globals.
----------------------------------------------------------------------------*/

// System identification.
extern "C"
{
	extern HINSTANCE      hInstance;
    #if ((defined _WIN64) && (!NO_SSE_SUPPORT))
    #define GIsSSE (1)
    #define GIsMMX (1)
    #else
	extern CORE_API UBOOL GIsMMX;
	extern CORE_API UBOOL GIsSSE;
    #endif
    #define GIsAltivec (0)
}

/*----------------------------------------------------------------------------
	Functions.
----------------------------------------------------------------------------*/
#include<intrin.h> //FIXME: Move this to another place(or maybe remove it).
// __rdtsc is in windows.h, which apparently can't be #included here. --ryan.
/*
#if _WIN64
extern "C" QWORD __rdtsc(void);
#pragma intrinsic(__rdtsc)
#else
FORCEINLINE QWORD __rdtsc(void)
{
	static union
	{
		struct
		{
			DWORD LowPart;
			DWORD HighPart;
		} lh;
		QWORD QuadPart;
	} largeint;

	__asm
	{
		rdtsc
		mov largeint.lh.HighPart, edx
		mov largeint.lh.LowPart, eax
	}

	return(largeint.QuadPart);
}
#endif
*/
extern CORE_API QWORD GBaseCycles;
#define DEFINED_appResetTimer 1
inline void appResetTimer(void)
{
    GBaseCycles = __rdtsc();
}

#define DEFINED_appCycles 1
FORCEINLINE DWORD appCycles(void)
{
    return((DWORD) (__rdtsc() & 0xFFFFFFFF));
}

// Intel SpeedStep and AMD Cool & Quiet CPUs automatically adjust their frequency so RDTSC 
// shouldn't be used for game relevant inter- frame timing. The code will default to using
// timeGetTime instead.

/*
#define DEFINED_appSeconds 1
extern CORE_API DOUBLE GSecondsPerCycle;
CORE_API DOUBLE appSecondsSlow(void);
FORCEINLINE DOUBLE appSeconds(void)
{
    QWORD Delta = __rdtsc() - GBaseCycles;
	return (double)Delta * GSecondsPerCycle;
}
*/

#include <cstring>
#define DEFINED_appMemcpy
inline void appMemcpy(void* Dst, const void* Src, INT Count)
{
	std::memcpy(Dst, Src, Count);
}


//
// Memory zero.
//
#if ASM
#define DEFINED_appMemzero
inline void appMemzero( void* Dest, INT Count )
{	
	std::memset(Dest, NULL, Count);
}
#endif

extern "C" void* __cdecl _alloca(size_t);
//#define appAlloca(size) _alloca((size+7)&~7)
#define appAlloca(size) ((size==0) ? 0 : _alloca((size+7)&~7))
//#define appAlloca(size) ((size==0) ? 0 : _alloca(size)) //FIXME

#include <math.h>
#include <float.h>  // newer platform sdk's need this for _isnan(). --ryan.
#define DEFINED_appMathIntrinsics 1
#define appExp(x) exp(x)
#define appLoge(x) log(x)
#define appFmod(x,y) fmod(x,y)
#define appSin(x) sin(x)
#define appAsin(x) asin(x)
#define appCos(x) cos(x)
#define appAcos(x) acos(x)
#define appTan(x) tan(x)
#define appAtan(x) atan(x)
#define appAtan2(x,y) atan2(x,y)
#define appPow(x,y) pow(x,y)
#define appIsNan(x) (_isnan(x))
#define appRand() rand()
#define appRandInit(x) srand(x)
#define appFrand() ((FLOAT) (rand() / (FLOAT) RAND_MAX))
#define appSqrt(x) sqrt(x)
#define appFloor(x) ((INT)floor(x))
#define appCeil(x) ((INT)ceil(x))
#define appRound(x) ((INT)floor(x + 0.5f))
#define appFractional(x) (x - floor(x))

#define DEFINED_appArgv0 1
#define appArgv0(x)

#if ASM
#define FAST_FTOL 1
FORCEINLINE INT appTrunc( FLOAT F )
{
	INT Result;
	if( GIsSSE )
	{
		__asm
		{
			cvttss2si eax,[F]
		}
	}
	else
	{
		__asm
		{
			lea eax, [Result]
			fld F
			fistp dword ptr [eax]
			mov eax, [eax]
		}
	}
	// return value in eax.
}
#endif

/*----------------------------------------------------------------------------
	The End.
----------------------------------------------------------------------------*/

