//
//  OMKOverlayView.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKOverlayView.h"
#import "OMKTiledLayer.h"

@implementation OMKOverlayView
{
    __strong id <OMKOverlay> _overlay;
}

#pragma mark - Properties

@synthesize overlay = _overlay;

#pragma mark - Object Lifecycle

- (id)initWithOverlay:(id<OMKOverlay>)overlay
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _overlay = overlay;
        _boundingMapRect = [overlay boundingMapRect];
        OMKTiledLayer *layer = (id)self.layer;
        layer.opaque = NO;
        layer.tileSize = CGSizeMake(512, 512);
    }
    return self;
}

#pragma mark - Core Animation

+ (Class)layerClass
{
    return [OMKTiledLayer class];
}

- (void)drawRect:(CGRect)rect
{
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGRect rect = CGContextGetClipBoundingBox(ctx);
    OMKMapRect r = OMKMapRectMake(rect.origin.x + [self.overlay boundingMapRect].origin.x,
                                  rect.origin.y + [self.overlay boundingMapRect].origin.y,
                                  rect.size.width,
                                  rect.size.height);

    if ([self canDrawMapRect:r zoomScale:CGContextGetCTM(ctx).a * 4])
        [self drawMapRect:r zoomScale:CGContextGetCTM(ctx).a * 4 inContext:ctx];
}

#pragma mark - Public Methods

- (BOOL)canDrawMapRect:(OMKMapRect)mapRect zoomScale:(OMKZoomScale)zoomScale
{
    return YES;
}

- (void)drawMapRect:(OMKMapRect)mapRect zoomScale:(OMKZoomScale)zoomScale inContext:(CGContextRef)context
{
}

#pragma mark - NSCoding Protocol

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _overlay = [coder decodeObjectForKey:@"overlay"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    // TODO: check for NSCoding conformity?
    _overlay = [coder decodeObjectForKey:@"overlay"];
}

@end
