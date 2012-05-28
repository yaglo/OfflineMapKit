//
//  OMKBase.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OfflineMapKit-Private.h"

#import "OMKBase.h"

const OMKMapSize OMKMapSizeWorld = { 268435456.0, 268435456.0 };
const OMKMapRect OMKMapRectWorld = { 0.0, 0.0, 268435456.0, 268435456.0 };
const OMKMapRect OMKMapRectNull = { INFINITY, INFINITY, INFINITY, INFINITY };

OMKMapPoint OMKMapPointForCoordinate(CLLocationCoordinate2D coordinate)
{
    return OMKMapPointMake(__OMKXForLongitude(coordinate.longitude, OMKMapSizeWorld.width),
                           __OMKYForLatitude(coordinate.latitude, OMKMapSizeWorld.height));
}

CLLocationCoordinate2D OMKCoordinateForMapPoint(OMKMapPoint mapPoint)
{
    return CLLocationCoordinate2DMake(__OMKLongitudeForX(mapPoint.x, OMKMapSizeWorld.width),
                                      __OMKLatitudeForY(mapPoint.y, OMKMapSizeWorld.height));
}

BOOL OMKMapRectIntersectsRect(OMKMapRect rect1, OMKMapRect rect2)
{
	if (OMKMapRectGetMaxY(rect1) < OMKMapRectGetMinY(rect2))
        return NO;

	if (OMKMapRectGetMinY(rect1) > OMKMapRectGetMaxY(rect2))
        return NO;

    if (OMKMapRectGetMaxX(rect1) < OMKMapRectGetMinX(rect2))
        return NO;

    if (OMKMapRectGetMinX(rect1) > OMKMapRectGetMaxX(rect2))
        return NO;

    return YES;
}

CGFloat OMKRoadWidthAtZoomScale(OMKZoomScale zoomScale)
{
    return 21.0 / zoomScale;
}
