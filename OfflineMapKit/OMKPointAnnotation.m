//
//  OMKPointAnnotation.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKPointAnnotation.h"

@implementation OMKPointAnnotation

@synthesize coordinate = _coordinate;

#pragma mark - NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
