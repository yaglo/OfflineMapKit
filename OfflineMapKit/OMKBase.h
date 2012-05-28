//
//  OMKBase.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
//#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    double x;
    double y;
} OMKMapPoint;

typedef struct {
    double width;
    double height;
} OMKMapSize;

typedef struct {
    OMKMapPoint origin;
    OMKMapSize size;
} OMKMapRect;

typedef enum {
    OMKUserTrackingModeInactive = 0,
    OMKUserTrackingModeTrackingLocation,
    OMKUserTrackingModeTrackingHeading,
} OMKUserTrackingMode;

typedef CGFloat OMKZoomScale;

extern const OMKMapSize OMKMapSizeWorld;
extern const OMKMapRect OMKMapRectWorld;
extern const OMKMapRect OMKMapRectNull;

OMKMapPoint OMKMapPointForCoordinate(CLLocationCoordinate2D coordinate);
CLLocationCoordinate2D OMKCoordinateForMapPoint(OMKMapPoint mapPoint);
BOOL OMKMapRectIntersectsRect(OMKMapRect rect1, OMKMapRect rect2);
CGFloat OMKRoadWidthAtZoomScale(OMKZoomScale zoomScale);

NS_INLINE OMKMapPoint OMKMapPointMake(double x, double y)
{
    return (OMKMapPoint){x, y};
}

NS_INLINE OMKMapSize OMKMapSizeMake(double width, double height)
{
    return (OMKMapSize){width, height};
}

NS_INLINE OMKMapRect OMKMapRectMake(double x, double y, double width, double height)
{
    return (OMKMapRect){ OMKMapPointMake(x, y), OMKMapSizeMake(width, height) };
}

NS_INLINE double OMKMapRectGetMinX(OMKMapRect rect)
{
    if (rect.size.width > 0) {
        return rect.origin.x;
    }
    else {
        return rect.origin.x + rect.size.width;
    }
}

NS_INLINE double OMKMapRectGetMinY(OMKMapRect rect)
{
    if (rect.size.height > 0) {
        return rect.origin.y;
    }
    else {
        return rect.origin.y + rect.size.height;
    }
}

NS_INLINE double OMKMapRectGetMidX(OMKMapRect rect)
{
    return rect.origin.x + rect.size.width / 2.0;
}

NS_INLINE double OMKMapRectGetMidY(OMKMapRect rect)
{
    return rect.origin.y + rect.size.height / 2.0;
}

NS_INLINE double OMKMapRectGetMaxX(OMKMapRect rect)
{
    if (rect.size.width > 0) {
        return rect.origin.x + rect.size.width;
    }
    else {
        return rect.origin.x;
    }
}

NS_INLINE double OMKMapRectGetMaxY(OMKMapRect rect)
{
    if (rect.size.height > 0) {
        return rect.origin.y + rect.size.height;
    }
    else {
        return rect.origin.y;
    }
}

NS_INLINE double OMKMapRectGetWidth(OMKMapRect rect)
{
    return rect.size.width;
}

NS_INLINE double OMKMapRectGetHeight(OMKMapRect rect)
{
    return rect.size.height;
}

NS_INLINE BOOL OMKMapRectIsNull(OMKMapRect rect)
{
    return isinf(rect.origin.x) || isinf(rect.origin.y);
}

NS_INLINE BOOL OMKMapRectIsEmpty(OMKMapRect rect)
{
    return OMKMapRectIsNull(rect) || (rect.size.width == 0.0 && rect.size.height == 0.0);
}

NS_INLINE NSString *OMKStringFromMapRect(OMKMapRect rect)
{
    return [NSString stringWithFormat:@"{ %f %f; %f %f }", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

#ifdef __cplusplus
}
#endif

