#include "EnginePrivate.h"

#if _MSC_VER && !_XBOX && !_WIN64
#pragma pack (push,8)
typedef long HRESULT;
#include "../../nvDXT/Inc/dxtlib.h"
#pragma pack (pop)
#else
typedef long HRESULT;
#include "../../nvDXT/Inc/dxtlib.h"
#endif

HRESULT nvDXTcompress(unsigned char* raw_data, // pointer to data (24 or 32 bit)
    unsigned long w, // width in texels
    unsigned long h, // height in texels
    DWORD byte_pitch,
    CompressionOptions* options,
    DWORD planes, // 3 or 4
    MIPcallback callback)   // callback for generated levels
    {
        return 0;
    }

#include "NvTriStrip.h"
void GenerateStrips(const unsigned short* in_indices, const unsigned int in_numIndices,
    PrimitiveGroup** primGroups, unsigned short* numGroups)
    {
        return;
    }

void SetListsOnly(const bool bListsOnly)
    {
        return;
    }
