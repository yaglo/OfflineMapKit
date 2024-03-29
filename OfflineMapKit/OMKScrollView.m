//
//  OMKScrollView.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKScrollView.h"

#import "OfflineMapKit-Private.h"

#import "UIColor+OMKAdditions.h"

@implementation OMKScrollView
{
    __unsafe_unretained OMKMapView *mapView;
}

#pragma mark - Properties

- (id)initWithFrame:(CGRect)frame mapView:(OMKMapView *)theMapView
{
    self = [super initWithFrame:frame];
    if (self) {
        mapView = theMapView;
        [self updateZoomScales];
        self.autoresizesSubviews = NO;
        self.contentSize = CGSizeMake(OMKMapSizeWorld.width, OMKMapSizeWorld.height);
        self.contentMode = UIViewContentModeTopLeft;
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.bouncesZoom = NO;
        self.bounces = NO;
        self.backgroundColor = [UIColor omk_loadingTileBackgroundColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.scrollsToTop = NO;
        self.opaque = YES;
        self.multipleTouchEnabled = YES;

        UITapGestureRecognizer *singleDoubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleDoubleTap:)];
        singleDoubleTapGR.numberOfTapsRequired = 2;
        [self addGestureRecognizer:singleDoubleTapGR];

        UITapGestureRecognizer *singleDoubleTouchGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleDoubleTouch:)];
        singleDoubleTouchGR.numberOfTapsRequired = 1;
        singleDoubleTouchGR.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:singleDoubleTouchGR];
    }
    return self;
}

#pragma mark - Private Methods

- (void)updateZoomScales
{
    self.minimumZoomScale = 1. / powf(2, OMKMaxZoomLevel - [mapView minimumZoomLevel]);
    self.maximumZoomScale = 1. / powf(2, OMKMaxZoomLevel - [mapView maximumZoomLevel]);
}

- (void)handleSingleDoubleTap:(UITapGestureRecognizer *)tapGR
{
    CGPoint tapPoint = [tapGR locationInView:tapGR.view.superview];

    // Скролл должен производиться посередине между текущим центром и точкой нажатия
    CGPoint tapMapPoint = CGPointMake(self.bounds.origin.x + tapPoint.x, self.bounds.origin.y + tapPoint.y);
    CGPoint visibleMapCenterPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGPoint targetMapPoint = CGPointMake((tapMapPoint.x + visibleMapCenterPoint.x) / 2, (tapMapPoint.y + visibleMapCenterPoint.y) / 2);

    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(__OMKLatitudeForY(targetMapPoint.y, self.contentSize.height),
                                                                   __OMKLongitudeForX(targetMapPoint.x, self.contentSize.width));
    [mapView zoomToLocationCoordinate:coordinate zoomLevel:[mapView higherZoomLevel:mapView.zoomLevel] animated:YES];
}

- (void)handleSingleDoubleTouch:(UITapGestureRecognizer *)tapGR
{
    CGPoint visibleMapCenterPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(__OMKLatitudeForY(visibleMapCenterPoint.y, self.contentSize.height),
                                                                   __OMKLongitudeForX(visibleMapCenterPoint.x, self.contentSize.width));

    [mapView zoomToLocationCoordinate:coordinate zoomLevel:[mapView lowerZoomLevel:mapView.zoomLevel] animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1) {
        [self performSelector:@selector(handleSingleTap) withObject:nil afterDelay:0.4];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)handleSingleTap
{
    [mapView deselectActiveAnnotationView];
}

@end
