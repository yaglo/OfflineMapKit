//
//  OMKOverlay.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OMKBase.h"

@protocol OMKOverlay <NSObject>

@property (nonatomic, readonly) OMKMapRect boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (BOOL)intersectsMapRect:(OMKMapRect)mapRect;

@end
