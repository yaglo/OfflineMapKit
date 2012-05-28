//
//  OMKPolyline.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OfflineMapKit-Private.h"

@implementation OMKPolyline

#pragma mark - Public Methods

+ (OMKPolyline *)polylineWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    OMKPolyline *polyline = [[OMKPolyline alloc] init];
    [polyline setCoordinates:coordinates count:count];
    [polyline boundingMapRect];
    return polyline;
}

+ (OMKPolyline *)polylineWithPoints:(OMKMapPoint *)points count:(NSUInteger)count
{
    OMKPolyline *polyline = [[OMKPolyline alloc] init];
    [polyline setPoints:points count:count];
    [polyline boundingMapRect];
    return polyline;
}

- (OMKMapRect)boundingMapRect
{
    if (OMKMapRectIsNull(_boundingMapRect))
        [super boundingMapRect];

    return _boundingMapRect;
}

- (BOOL)intersectsMapRect:(OMKMapRect)mapRect
{
    return OMKMapRectIntersectsRect(_boundingMapRect, mapRect);
}

@end
