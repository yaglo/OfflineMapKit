//
//  OMKTileKey.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKTileKey.h"

@implementation OMKTileKey

@synthesize x;
@synthesize y;
@synthesize zoomLevel;

+ (OMKTileKey *)tileKeyForX:(NSUInteger)x Y:(NSUInteger)y zoomLevel:(NSUInteger)zoomLevel
{
    OMKTileKey *tileKey = [[OMKTileKey alloc] init];
    tileKey.x = x;
    tileKey.y = y;
    tileKey.zoomLevel = zoomLevel;
    return tileKey;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; x = %d; y = %d; zoomLevel = %d>", NSStringFromClass([self class]), self, x, y, zoomLevel];
}

- (NSUInteger)hash
{
    // FIXME
    return [[NSString stringWithFormat:@"%d_%d_%d", x, y, zoomLevel] hash];
}

- (BOOL)isEqual:(OMKTileKey *)other
{
    if (self == other)
        return YES;

    if (![other isKindOfClass:[OMKTileKey class]])
        return NO;

    if (self.x != other.x)
        return NO;

    if (self.y != other.y)
        return NO;

    if (self.zoomLevel != other.zoomLevel)
        return NO;

    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
