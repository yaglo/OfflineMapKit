//
//  OMKOverlayTileView.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKOverlayTileView.h"
#import "OfflineMapKit-Private.h"
#import "OMKTiledLayer.h"

@implementation OMKOverlayTileView
{
    CGSize _tileSize;
}

#pragma mark - Properties

@synthesize mapView = _mapView;
@synthesize overlayViews = _overlayViews;

#pragma mark - Object Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.opaque = NO;
        _overlayViews = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - UIView Overrides

+ (Class)layerClass
{
    return [OMKTiledLayer class];
}

#pragma mark - CALayer Overrides

- (void)layoutSubviews
{
    self.contentScaleFactor = 1;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    @synchronized(self){
        CGRect rect = CGContextGetClipBoundingBox(context);
        CGFloat zoomScale = CGContextGetCTM(context).a;

        OMKMapRect mapRect = OMKMapRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

        for (OMKOverlayView *view in _overlayViews) {
            if ([view canDrawMapRect:mapRect zoomScale:zoomScale]) {
//                CGContextSetFillColorWithColor(context, [[UIColor blueColor] colorWithAlphaComponent:.05].CGColor);
//                CGContextFillRect(context, rect);
                [view drawMapRect:mapRect zoomScale:zoomScale inContext:context];
            }
        }
    }
}

#pragma mark - Tile Size

- (void)setTileSize:(CGSize)tileSize
{
    _tileSize = tileSize;
    OMKTiledLayer *layer = (id)self.layer;
    layer.tileSize = _tileSize;
}

- (CGSize)tileSize
{
    if (CGSizeEqualToSize(_tileSize, CGSizeZero)) {
        _tileSize = [_mapView tileSize];
    }
    return _tileSize;
}

@end
