/* This file must be included if ME_HEADERS is not defined */
#ifndef _EM_ME_DEFINE_H
#define _EM_ME_DEFINE_H


/* Calling convention for standard library functions */

#ifdef WIN32
#define MEAPI_CDECL    __cdecl
#define MEAPI_STDCALL  __stdcall
#define MEAPI_FASTCALL __fastcall
#define MEAPI          MEAPI_STDCALL
#else
#define MEAPI_CDECL
#define MEAPI_STDCALL
#define MEAPI_FASTCALL
#define MEAPI
#endif

#ifdef WIN32
 #if defined KARMADLL
  #if defined KARMADLL_EXPORTS
   #define MEPUBLIC __declspec(dllexport)
  #else
   #define MEPUBLIC __declspec(dllimport)
  #endif
 #else
  #define MEPUBLIC
 #endif
#else
 #define MEPUBLIC
#endif

#if (MeDONTINLINE)
#   define MeDEFINE MePUT_FUNCTIONS_HERE_IF_NOT_INLINED
#   define MeINLINE
#elif (__cplusplus)
#   define MeDEFINE 1
#   define MeINLINE static inline
#elif (defined __GNUC__ || defined _MSC_VER)
#   define MeDEFINE 1
#   define MeINLINE static __inline
#elif (defined __MWERKS__)
#   define MeDEFINE 1
#   define MeINLINE static inline
#else
#   define MeDEFINE MePUT_FUNCTIONS_HERE_IF_NOT_INLINED
#   define MeINLINE
#endif

#include <math.h>
#include <float.h>

/* Basic types */
typedef unsigned __int8     MeU8;
typedef __int8              MeI8;
typedef __int16             MeI16;
typedef float               MeReal;
typedef int                 MeBool;
#define MEFALSE             (0)

/* Vector types */
typedef MeReal              MeVector3[3];
typedef MeReal              MeVector4[4];

/* Matrix types */
typedef MeVector3           MeMatrix3[3]; /** MathEngine 3x3 MeReal matrix */
typedef MeVector3 *			MeMatrix3Ptr;
typedef MeVector4           MeMatrix4[4]; /// MathEngine 4x4 MeReal matrix
typedef MeVector4 *			MeMatrix4Ptr;

#define MeSqrt               sqrtf
#define MeSin                sinf
#define MeAsin               asinf
#define MeCos                cosf
#define MeAcos               acosf
#define MeTan                tanf
#define MeAtan               atanf
#define MeAtan2              atan2f
#define MeFabs               fabsf
#define MeRecip(x)           (1.0f/(x))
#define MeRecipSqrt(x)       (1.0f/sqrtf(x))
#define ME_PI                (3.14159265358979323846f)
#define MeMAX(a,b)              (((a)<(b)) ? b : a)
#define MEINFINITY ((MeReal) FLT_MAX)
#define ME_SMALL_EPSILON             (1.0e-6f)
/* Enums */

typedef enum
{
    kMcdTriangleUseSmallestPenetration = 1,
    kMcdTriangleTwoSided = 2,
    kMcdTriangleUseEdge0 = 4,  /* use edge v1 - v0 */
    kMcdTriangleUseEdge1 = 8,  /* use edge v2 - v1 */
    kMcdTriangleUseEdge2 = 16, /* use edge v0 - v2 */
    kMcdTriangleUseEdges = 28,
    kMcdTriangleStandard = 31
} McdTriangleFlags;

typedef enum {
    kMcdFFStateInactive,
    kMcdFFStateHello,
    kMcdFFStateStaying,
    kMcdFFStateGoodbye
} McdModelPairPhase;

#ifdef __cplusplus
extern "C"
{
#endif
	typedef void * McdModelID;
    typedef void * McdGeometryID;
    typedef McdGeometryID McdTriangleListID;
    MeINLINE int MEAPI NextMod3(const int i) { return (1 << i) & 3; }
    MeINLINE void MEAPI MeVector3Copy(MeVector3 c, const MeVector3 b) { c[0] = b[0]; c[1] = b[1]; c[2] = b[2]; }
    MeINLINE void MEAPI MeVector3Add(MeVector3 a, const MeVector3 b, const MeVector3 c) { a[0] = b[0] + c[0], a[1] = b[1] + c[1], a[2] = b[2] + c[2]; }
    MeINLINE void MEAPI MeVector3Scale(MeVector3 v, const MeReal a) { v[0] *= a; v[1] *= a; v[2] *= a; }
    MeINLINE MeReal MEAPI MeSafeRecip(MeReal x) { return ((MeReal)0.0f != x ? (MeReal)1.0f / x : (MeReal)0.0f); }
    MeINLINE void MEAPI MeVector3Cross(MeVector3 a, const MeVector3 b, const MeVector3 c) { a[0] = b[1] * c[2] - b[2] * c[1]; a[1] = b[2] * c[0] - b[0] * c[2]; a[2] = b[0] * c[1] - b[1] * c[0]; }
    MeINLINE MeReal MEAPI MeVector3Dot(const MeVector3 b, const MeVector3 c) { return b[0] * c[0] + b[1] * c[1] + b[2] * c[2]; }
    MeINLINE void MEAPI MeVectorSetZero(MeReal* const A, const int n) { int i; for (i = 0; i < n; i++) A[i] = 0.0f; } /* Set the first \p n elements of \p A to zero. */

    MEPUBLIC McdGeometryID MEAPI McdModelGetGeometry(McdModelID g);
    MEPUBLIC MeReal MEAPI McdModelGetContactTolerance(McdModelID cm);
    MEPUBLIC MeMatrix4Ptr MEAPI McdModelGetTransformPtr(McdModelID cm);

    typedef McdGeometryID McdBoxID;
    typedef struct _McdUserTriangle
    {
        MeVector3* vertices[3]; /**< pointers to vertices */
        MeVector3* normal;

        union { void* ptr; int tag; } triangleData;
        McdTriangleFlags flags;

    } McdUserTriangle;

    typedef struct _McdModelPair
    {

        /** @internal */
        McdModelID model1;
        /** @internal */
        McdModelID model2;

        /** @internal */
        McdModelPairPhase phase;

        /** @internal */
        void* request; //McdRequest* request;

        /** @internal */
        void* userData;

        /** @internal */
        void* m_cachedData;

        /** @internal */
        void* responseData;

    } McdModelPair;

    typedef struct _McdIntersectResult
    {
        McdModelPair* pair;
        void* contacts;           /**< array of contacts to be filled */ //McdContact* contacts;
        int contactMaxCount;            /**< size of array */
        int contactCount;               /**< number of contacts returned in array */
        int touch;                      /**< 1 if objects are in contact, 0 otherwise */
        MeReal normal[3];               /**< average normal of contacts returned */
        void* data;                     /**< auxiliary data */
    } McdIntersectResult;

    typedef struct MePoolFixed
    {
        /** Actual chunk of memory holding structs. */
        void* structArray;

        /** Stack of pointers to free structs. */
        void** freeStructStack;

        /** Index of next free pointer in stack. */
        int                 nextFreeStruct;

        /** Size of each struct in the pool. */
        int                 structSize;

        /** Total number of structs in pool. */
        int                 poolSize;

        /**
         * Indicates if the pool memory was allocated with
         * createAligned or create.
         */
        MeBool              createdAligned;
    } MePoolFixed;

    typedef struct MePoolMalloc
    {
        /** Number of allocated structs */
        int                 usedStructs;

        /** Size of each struct in the pool. */
        int                 structSize;

        /** Total number of structs in pool. */
        int                 poolSize;

        /**
         * Indicates requested alignment, if != 0.
         */
        int                 alignment;
    } MePoolMalloc;

    typedef struct MePool
    {
        enum MePoolType     t;

        union
        {
            struct MePoolFixed      fixed;
            struct MePoolMalloc     malloc;
        }
        u;
    } MePool;


    /* global collision framework structure */
    typedef struct _McdFramework
    {
        int geometryRegisteredCountMax;
        int geometryRegisteredCount;

        McdModelID firstModel;
        McdGeometryID firstGeometry;

        int modelCount;
        int geometryCount;

        void* geometryVTableTable; // McdGeometryVTable* geometryVTableTable;
        void* termActions; //McdTermActionLink* termActions;
        void* interactionTable; //McdInteractions* interactionTable;

        MePool cachePool;   /* for GJK coherence */

        void * mHelloCallbackFnPtr;//McdHelloCallbackFnPtr mHelloCallbackFnPtr;

        MePool modelPool;
        MePool instancePool;
        MeReal mDefaultPadding;

        MeReal mScale;              /* approximate magnitude of the objects we're dealing with */

        void* request;        /* one we allocate */ //McdRequest* request;
        void* defaultRequest; /* one that gets used; usually pointer points to default */ //McdRequest* defaultRequest;
        const char* toolkitVersionString;
    } McdFramework;

#ifdef __cplusplus
}
#endif

#endif /* _EM_ME_DEFINE_H */
