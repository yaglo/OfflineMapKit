//
//  OMKAnnotationContainerView.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKAnnotationContainerView.h"
#import "OMKAnnotationView.h"
#import "OMKPointAnnotation.h"
#import "OfflineMapKit-Private.h"
#import "UIImage+OMKAdditions.h"

#import "SYCalloutView.h"

@implementation OMKAnnotationContainerView
{
    __strong OMKAnnotationView *_activeAnnotationView;
    __strong NSMutableArray *_annotationViews;

    __strong SYCalloutView *_calloutView;

    __strong NSMutableDictionary *_reusableAnnotationViews;

    __strong UIImageView *_userHeadingView;
    __strong CLLocation *_userLocation;
    __strong UIImageView *_userLocationView;
    BOOL _viewsSorted;

    OMKUserTrackingMode _userTrackingMode;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _userHeadingView = [[UIImageView alloc] initWithImage:[UIImage omk_userHeadingViewImage]];
        _userHeadingView.hidden = YES;
        [self addSubview:_userHeadingView];
        
        _userLocationView = [[UIImageView alloc] initWithImage:[UIImage omk_userLocationDotImage]];
        _userLocationView.hidden = YES;
        [self addSubview:_userLocationView];
        
        _calloutView = [[SYCalloutView alloc] initWithFrame:CGRectZero];
        _calloutView.canAnchorFromBottom = NO;
        _calloutView.hidden = YES;
        [self addSubview:_calloutView];

        _reusableAnnotationViews = [NSMutableDictionary dictionary];
        _annotationViews = [NSMutableArray array];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        _activeAnnotationView = nil;
    }
}

#pragma mark - User Tracking

- (OMKUserTrackingMode)userTrackingMode
{
    return _userTrackingMode;
}

- (void)setUserTrackingMode:(OMKUserTrackingMode)userTrackingMode
{
    _userTrackingMode = userTrackingMode;

    if (userTrackingMode == OMKUserTrackingModeTrackingLocation) {
        _userLocationView.hidden = NO;
        _userHeadingView.hidden = YES;
        [self bringSubviewToFront:_userHeadingView];
        [self bringSubviewToFront:_userLocationView];
        [self bringSubviewToFront:_calloutView];
    }
    else if (userTrackingMode == OMKUserTrackingModeTrackingHeading) {
        _userLocationView.hidden = NO;
        _userHeadingView.hidden = NO;
        [self bringSubviewToFront:_userHeadingView];
        [self bringSubviewToFront:_userLocationView];
        [self bringSubviewToFront:_calloutView];
    }
    else {
        [_userHeadingView removeFromSuperview];
        [self insertSubview:_userHeadingView belowSubview:_userLocationView];
        _userHeadingView.hidden = YES;
    }
}

- (void)setUserHeading:(CLHeading *)heading
{    
    if (_userTrackingMode != OMKUserTrackingModeInactive) {
        _userHeadingView.hidden = NO;
#if OMK_ROTATE_MAP_ON_HEADING_CHANGE
        _userHeadingView.layer.transform = CATransform3DMakeRotation(heading.trueHeading * M_PI / 180, 0, 0, 1);
#else
        _userHeadingView.layer.transform = CATransform3DMakeRotation(-heading.trueHeading * M_PI / 180, 0, 0, 1);
#endif
    }
}

- (void)setUserLocation:(CLLocation *)location
{
    if (location.coordinate.latitude == 0 && location.coordinate.longitude == 0) {
        _userLocationView.hidden = YES;
        return;
    }

    _userLocationView.hidden = NO;
    _userLocation = location;

    [UIView animateWithDuration:0.2 animations:^{
        _userLocationView.center = OMKPointForCoordinate(location.coordinate, self.bounds.size, YES);
        _userHeadingView.center = _userLocationView.center;
        _userLocationView.layer.zPosition = _userLocationView.center.y;
    }];
}

- (void)hideUserLocationView
{
    _userLocationView.hidden = YES;
    _userHeadingView.hidden = YES;
}

#pragma mark - Callout

- (CGPoint)calloutAnchorPointForAnnotationView:(OMKAnnotationView *)view
{
    return CGPointMake(CGRectGetMidX(_activeAnnotationView.frame) + _activeAnnotationView.calloutOffset.x,
                       CGRectGetMinY(_activeAnnotationView.frame) + _activeAnnotationView.calloutOffset.y);
}

- (void)scrollMapIfNeededForCalloutForAnnotationView:(OMKAnnotationView *)annotationView animated:(BOOL)animated
{
    CGPoint realAnchorPoint;
    CGRect realFrame;
    CGPoint anchorPoint = [self calloutAnchorPointForAnnotationView:_activeAnnotationView];

    [_calloutView getRealAnchorPoint:&realAnchorPoint frame:&realFrame forAnchorPoint:anchorPoint bounds:_mapView.scrollView.bounds];

    NSLog(@"realAnchor.x = %f, anchor.x = %f", realAnchorPoint.x, anchorPoint.x);
    NSLog(@"realAnchor.y = %f, anchor.y = %f", realAnchorPoint.y, anchorPoint.y);
    NSLog(@"callout frame = {{ %f, %f }, { %f %f }}", realFrame.origin.x, realFrame.origin.y, realFrame.size.width, realFrame.size.height);
    CGFloat scrollX = realAnchorPoint.x - anchorPoint.x;
    CGFloat scrollY = 0;

    CGRect bounds = _mapView.scrollView.bounds;
    if (CGRectGetMinY(realFrame) < CGRectGetMinY(bounds)) {
        scrollY = CGRectGetMinY(bounds) - CGRectGetMinY(realFrame);
    }

    CGRect newBounds = CGRectMake(bounds.origin.x - scrollX,
                                  bounds.origin.y - scrollY,
                                  bounds.size.width,
                                  bounds.size.height);

    if (animated) {
        [UIView animateWithDuration:.175 animations:^{
            _mapView.scrollView.bounds = newBounds;
        }];
    }
    else {
        _mapView.scrollView.bounds = newBounds;
    }
}

- (void)showCalloutForAnnotationView:(OMKAnnotationView *)annotationView animated:(BOOL)animated
{
//    NSLog(@"-[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    if (_activeAnnotationView == annotationView && !_calloutView.hidden)
        return;

    _activeAnnotationView = annotationView;

    _calloutView.hidden = YES;

    _calloutView.title = annotationView.annotation.title;
    _calloutView.subtitle = annotationView.annotation.subtitle;
    _calloutView.rightView = annotationView.rightCalloutAccessoryView;

    [self scrollMapIfNeededForCalloutForAnnotationView:annotationView animated:animated];

    [_calloutView setAnchorPoint:[self calloutAnchorPointForAnnotationView:_activeAnnotationView]
                    boundaryRect:_mapView.scrollView.bounds
                        animated:animated];
}

- (void)addAnnotationViewForAnnotation:(id <OMKAnnotation>)annotation
{
    OMKAnnotationView *view = [_mapView viewForAnnotation:annotation];

    if (!view && [annotation isKindOfClass:[OMKPointAnnotation class]]) {
        view = [[OMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    }

    if (view) {
        [_annotationViews addObject:view];
        [view setNeedsLayout];
        view.layer.zPosition = -annotation.coordinate.latitude + 90;
        [self addSubview:view];
        _viewsSorted = NO;
        [self setNeedsLayout];
    }
}

- (void)annotationView:(OMKAnnotationView *)annotationView calloutAccessoryTapped:(UIControl *)calloutAccessoryControl
{
    [_mapView annotationView:annotationView calloutAccessoryTapped:calloutAccessoryControl];
}

- (OMKAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier
{
    NSMutableSet *identifierSet = [_reusableAnnotationViews objectForKey:identifier];
    
    if (!identifierSet)
        return nil;
    
    OMKAnnotationView *annotationView = [identifierSet anyObject];
    
    if (annotationView)
        [identifierSet removeObject:annotationView];
    
    return annotationView;
}

- (void)deselectActiveAnnotationView
{
    _activeAnnotationView.layer.zPosition = -_activeAnnotationView.annotation.coordinate.latitude;
    _activeAnnotationView = nil;
    _calloutView.hidden = YES;
    _viewsSorted = NO;
    [self setNeedsLayout];
}

- (OMKAnnotationView *)findViewForAnnotation:(id <OMKAnnotation>)annotation
{
    // TODO: optimize?
    for (OMKAnnotationView *view in _annotationViews) {
        if (view.annotation == annotation) {
            return view;
        }
    }

    return [_mapView viewForAnnotation:annotation];
}

- (void)selectAnnotation:(id <OMKAnnotation>)annotation animated:(BOOL)animated
{
    OMKAnnotationView *v = [self findViewForAnnotation:annotation];

    if (v.canShowCallout)
        [self showCalloutForAnnotationView:v animated:animated];
}

- (void)selectAnnotationView:(OMKAnnotationView *)view
{
    if (view.canShowCallout)
        [self showCalloutForAnnotationView:view animated:YES];
}

- (void)layoutSubviews
{
    BOOL integerPositioning = !_mapView.scrollView.zooming;

    for (OMKAnnotationView *annotationView in _annotationViews) {
        CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
        CGPoint centerPoint = OMKPointForCoordinate(coordinate, self.bounds.size, integerPositioning);
        annotationView.center = CGPointMake(centerPoint.x + annotationView.centerOffset.x, centerPoint.y + annotationView.centerOffset.y);

        // +--------------+
        // |  +-----+     |
        // |  |     |     |
        // |  |  +-----+  |
        // |  +--|     |  |
        // |   +-----+ |  |
        // |   |     |-+  |
        // |   |     |    |
        // |   +-----+    |
        // +--------------+
        annotationView.layer.zPosition = -coordinate.latitude + 90;
    }

    if (_activeAnnotationView && !_calloutView.hidden) {
        if (!_calloutView.animatingFrame) {
            CGPoint anchorPoint = [self calloutAnchorPointForAnnotationView:_activeAnnotationView];
            [_calloutView setAnchorPoint:anchorPoint];

            NSLog(@"anchor point = { %f, %f }", anchorPoint.x, anchorPoint.y);
            NSLog(@"callout frame = {{ %f, %f }, { %f %f }}", _calloutView.frame.origin.x,
                  _calloutView.frame.origin.y, _calloutView.frame.size.width, _calloutView.frame.size.height);
        }
    }
    
    if (!_userLocationView.hidden) {
        _userLocationView.center =  OMKPointForCoordinate(_userLocation.coordinate, self.bounds.size, integerPositioning);
    }

    if (!_userHeadingView.hidden) {
        _userHeadingView.center =  _userLocationView.center;
    }

    if (_activeAnnotationView) {
        _activeAnnotationView.layer.zPosition = 200;
    }

    // Callout всегда сверху
    _calloutView.layer.zPosition = 201;

    if (!_viewsSorted) {
        [self sortAnnotationViewsByZPosition];
        _viewsSorted = YES;
    }
}

- (void)repositionAnnotationView:(OMKAnnotationView *)view
{
    CLLocationCoordinate2D coordinate = view.annotation.coordinate;
    view.center = OMKPointForCoordinate(coordinate, self.bounds.size, !_mapView.scrollView.zooming);
    view.layer.zPosition = -coordinate.latitude + 90;
    [view setNeedsDisplay];
}

- (void)sortAnnotationViewsByZPosition
{
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"layer.zPosition" ascending:YES];
    NSArray *x = [_annotationViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    for (UIView *v in x) {
        [self bringSubviewToFront:v];
    }
    [self bringSubviewToFront:_activeAnnotationView];
    [self bringSubviewToFront:_calloutView];
}

@end
