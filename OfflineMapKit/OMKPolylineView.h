//
//  OMKPolylineView.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKOverlayPathView.h"
#import "OMKPolyline.h"

@interface OMKPolylineView : OMKOverlayPathView <NSCoding>

@property (nonatomic, readonly) OMKPolyline *polyline;

- (id)initWithPolyline:(OMKPolyline *)polyline;

@end
