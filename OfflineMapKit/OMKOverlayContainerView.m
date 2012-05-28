//
//  OMKOverlayContainerView.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKOverlayContainerView.h"
#import "OMKOverlayView.h"
#import "OMKTiledLayer.h"

@implementation OMKOverlayContainerView

@synthesize scrollView;

//- (void)layoutSubviews
//{
//    OMKZoomScale zoomScale = scrollView.zoomScale;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    for (OMKOverlayView *v in self.subviews) {
//        OMKMapRect r = OMKMapRectMake(v.frame.origin.x, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
//        if ([v canDrawMapRect:r zoomScale:zoomScale]) {
//            NSLog(@"overlay view frame = %@", NSStringFromCGRect(v.frame));
//            unsigned width = v.frame.size.width * zoomScale;
//            unsigned height = v.frame.size.height * zoomScale;
//            unsigned rowBytes = 4 * width;
//            CGImageRef imageBuffer = malloc(rowBytes * height);
//            CGContextRef context = CGBitmapContextCreate(imageBuffer,
//                                                         400,
//                                                         400,
//                                                         8,
//                                                         rowBytes,
//                                                         colorSpace,
//                                                         kCGBitmapAlphaInfoMask);
//            NSLog(@"context = %@", context);
//            CGContextScaleCTM(context, zoomScale, zoomScale);
//            [v drawMapRect:r zoomScale:zoomScale inContext:context];
//            v.layer.contents = (__bridge id)imageBuffer;
//            CGContextRelease(context);
//            free(imageBuffer);
//        }
//    }
//    CGColorSpaceRelease(colorSpace);
//}

@end
