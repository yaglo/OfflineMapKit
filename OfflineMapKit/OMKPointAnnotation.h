//
//  OMKPointAnnotation.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKShape.h"

@interface OMKPointAnnotation : OMKShape <NSCopying>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
