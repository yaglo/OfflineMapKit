//
//  UIColor+OMKAdditions.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "UIColor+OMKAdditions.h"

#define OMKBundlePatternImageColor(name) [UIColor colorWithPatternImage:[UIImage imageNamed:@"OfflineMapKit.bundle/" #name @".png"]]
#define OMKColorFromRGB(rgbValue) \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
    green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
    blue:((float)(rgbValue & 0xFF))/255.0 \
    alpha:1.0]

@implementation UIColor (OMKAdditions)

+ (UIColor *)omk_failedTileColor
{
    return OMKColorFromRGB(0xf3f2ef);
}

+ (UIColor *)omk_loadingTileBackgroundColor
{
    return OMKBundlePatternImageColor(LoadingTile);
}

+ (UIColor *)omk_zoomingTileBackgroundColor
{
    return OMKColorFromRGB(0xc1bfbb);
}

@end
