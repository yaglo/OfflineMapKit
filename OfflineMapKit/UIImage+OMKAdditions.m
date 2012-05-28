//
//  UIImage+OMKTileAdditions.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//
//

#import "UIImage+OMKAdditions.h"

#define OMKBundleImage(name) [UIImage imageNamed:@"OfflineMapKit.bundle/" #name @".png"]

@implementation UIImage (OMKAdditions)

+ (UIImage *)omk_userHeadingViewImage
{
    return OMKBundleImage(HeadingView);
}

+ (UIImage *)omk_userLocationDotImage
{
    return OMKBundleImage(LocationDot);
}

+ (UIImage *)omk_openStreetMapAttributionImage
{
    return OMKBundleImage(OpenStreetMapAttribution);
}

@end
