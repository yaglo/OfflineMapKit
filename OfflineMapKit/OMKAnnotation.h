//
//  OMKAnnotation.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@protocol OMKAnnotation <NSObject>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@optional
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

@end
