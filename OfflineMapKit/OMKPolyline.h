//
//  OMKPolyline.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

#import "OMKBase.h"
#import "OMKMultiPoint.h"
#import "OMKOverlay.h"

@interface OMKPolyline : OMKMultiPoint <OMKOverlay>

+ (OMKPolyline *)polylineWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;
+ (OMKPolyline *)polylineWithPoints:(OMKMapPoint *)points count:(NSUInteger)count;

- (OMKMapRect)boundingMapRect;
- (BOOL)intersectsMapRect:(OMKMapRect)mapRect;

@end
