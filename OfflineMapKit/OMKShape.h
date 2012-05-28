//
//  OMKShape.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMKAnnotation.h"

@interface OMKShape : NSObject <OMKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
