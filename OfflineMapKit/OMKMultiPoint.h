//
//  OMKMultiPoint.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

#import <OfflineMapKit/OMKBase.h>
#import <OfflineMapKit/OMKShape.h>

@interface OMKMultiPoint : OMKShape
{
@protected
    OMKMapRect _boundingMapRect;
}

@property (nonatomic, readonly) OMKMapPoint *points;
@property (nonatomic, readonly) NSUInteger pointCount;

- (void)getCoordinates:(CLLocationCoordinate2D *)coords range:(NSRange)range;

@end
