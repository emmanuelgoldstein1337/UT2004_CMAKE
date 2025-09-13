#include "EnginePrivate.h"

#include <MeMath.h>
#include <McdBox.h>

#ifndef _WIN64  // !!! FIXME: Merge headers.
#include <McdCheck.h>
#endif

#include <McdInteractionTable.h>
#include <McdModel.h>
#include <McdContact.h>
//#include "lsTransform.h"
#include <McdTriangleList.h>
#include <McdModelPair.h>
#include <McdPrimitives.h>
//#include "vectormath.h"
//#include <GeomUtils.h>

void MEAPI MeMatrix4TMInvert(MeMatrix4 tm)
{
	return;
}

MeReal* MEAPI McdBoxGetRadii(McdBoxID)
{
	return 0;
}

McdGeometryID     MEAPI McdModelGetGeometry(McdModelID g)
{
	return 0;
}

void              MEAPI McdModelSetTransformPtr(const McdModelID cm, const MeMatrix4Ptr geometryTM)
{
	return;
}

MeReal            MEAPI McdModelGetContactTolerance(McdModelID cm)
{
	return 0;
}

MeMatrix4Ptr      MEAPI McdModelGetTransformPtr(McdModelID cm)
{
	return 0;
}

MEPUBLIC void     MEAPI McdBoxGetBSphere(McdGeometryID, MeVector3 center, MeReal* radius)
{
	return;
}