//
//  OMKMapTileView.m
//  Private class to display tiles
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OfflineMapKit-Private.h"

#import <OfflineMapKit/UIColor+OMKAdditions.h>

@implementation OMKMapTileView
{
    NSCache *_tileCache;
}

#pragma mark - Properties

@synthesize mapView = _mapView;

#pragma mark - Object Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        self.layer.opaque = YES;
        self.contentScaleFactor = 1;
    }
    return self;
}

#pragma mark - UIView Overrides

- (void)layoutSubviews
{
    self.contentScaleFactor = 1;
}

+ (Class)layerClass
{
    return [OMKTiledLayer class];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    CGRect rect = CGContextGetClipBoundingBox(context);
    CGFloat scale = CGContextGetCTM(context).a;
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    UIImage *image = nil;
    
    OMKTileKey *tileKey = [OMKTileKey tileKeyForX:(CGRectGetMinX(rect) * scale) / 256
                                                Y:(CGRectGetMinY(rect) * scale) / 256
                                        zoomLevel:28 - (int)log2f(rect.size.width)];
    
    id<OMKMapTileProvider> tileProvider = _mapView.tileProvider;
    
    CGImageRef img = (__bridge CGImageRef)[_tileCache objectForKey:tileKey];
    
    if (img) {
        CALayer *l = [[CALayer alloc] init];
        l.contents = (__bridge id)img;
        l.frame = rect;
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
        [l renderInContext:context];
        CGContextRestoreGState(context);
    }
    else {
        if (tileProvider) {
            image = [tileProvider mapView:_mapView imageForTileWithKey:tileKey];
            [_tileCache setObject:(__bridge id)image.CGImage forKey:tileKey];
        }

        if (image) {
            CALayer *l = [[CALayer alloc] init];
            l.contents = (__bridge id)image.CGImage;
            l.frame = rect;
            
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
            [l renderInContext:context];
            CGContextRestoreGState(context);
        }
        else {
            CGContextSetFillColorWithColor(context, [UIColor omk_failedTileColor].CGColor);
            CGContextFillRect(context, rect);
        }
    }
//
//    [_overlayTileView drawLayer:_overlayTileView.layer inContext:context];
}

- (void)drawRect:(CGRect)rect
{

}

@end