//
//  OMKTiledLayer.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKTiledLayer.h"
#import "OfflineMapKit-Private.h"

@implementation OMKTiledLayer

- (id)init
{
    self = [super init];
    if (self) {
        self.levelsOfDetail = 20;
        self.levelsOfDetailBias = 0;
        self.opaque = YES;
        self.tileSize = CGSizeMake(256, 256);
    }
    return self;
}

#pragma mark - CATiledLayer Overrides

+ (CFTimeInterval)fadeDuration
{
    return .25;
}

@end
