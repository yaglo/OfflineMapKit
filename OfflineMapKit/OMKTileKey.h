//
//  OMKTileKey.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMKTileKey : NSObject <NSCopying>

@property NSUInteger x;
@property NSUInteger y;
@property NSUInteger zoomLevel;

+ (OMKTileKey *)tileKeyForX:(NSUInteger)x Y:(NSUInteger)y zoomLevel:(NSUInteger)zoomLevel;

@end
