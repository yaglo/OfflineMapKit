//
//  OMKMapView.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "OfflineMapKit-Private.h"

#import "OMKAnnotationContainerView.h"
#import "OMKCalloutView.h"
#import "OMKMapView.h"
#import "OMKMapTileView.h"
#import "OMKOverlayContainerView.h"
#import "OMKOverlayTileView.h"

#import "NSObject+OMKDelayedBlock.h"
#import "UIColor+OMKAdditions.h"
#import "UIImage+OMKAdditions.h"

const CGSize OMKOpenStreetMapAttributionPadding = { 6, 6 };

@implementation OMKMapView
{
    __strong UIView *topView;
    __strong OMKAnnotationContainerView *_annotationContainerView;
    __strong OMKMapTileView *_mapTileView;
    __strong OMKOverlayContainerView *_overlayContainerView;
    __strong OMKOverlayTileView *_overlayTileView;
    __strong OMKScrollView *_scrollView;

    __strong CLLocationManager *_locationManager;

    __strong UIImageView *_openStreetMapAttributionView;

    __strong NSMutableSet *_annotations;

    BOOL _delegateRespondsToViewForAnnotation;
    BOOL _delegateRespondsToViewForOverlay;

    NSInteger minimumZoomLevel, maximumZoomLevel;
}

@synthesize delegate = _delegate;
@synthesize tileProvider = _tileProvider;
@synthesize showsUserLocation;
@synthesize userTrackingMode = _userTrackingMode;

- (void)dealloc
{
    _locationManager.delegate = nil;
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.contentScaleFactor = 1;
        minimumZoomLevel = maximumZoomLevel = 0;

#if OMK_ROTATE_MAP_ON_HEADING_CHANGE
        CGFloat diagonal = sqrt(CGRectGetHeight(self.bounds) * CGRectGetHeight(self.bounds) + CGRectGetWidth(self.bounds) * CGRectGetWidth(self.bounds)) + 2;
        if (floorf(diagonal) == diagonal) {
            diagonal -= 2;
        }
        diagonal = floorf(diagonal);
        topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, diagonal, diagonal)];
        topView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        topView.layer.anchorPoint = CGPointMake(.5, .5);
        [self addSubview:topView];
#else
        topView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:topView];
#endif

        _scrollView = [[OMKScrollView alloc] initWithFrame:topView.bounds mapView:self];
        _scrollView.delegate = self;
        [topView addSubview:_scrollView];

        _mapTileView = [[OMKMapTileView alloc] initWithFrame:CGRectMake(0, 0, OMKMapSizeWorld.width, OMKMapSizeWorld.height)];
        _mapTileView.mapView = self;
        _mapTileView.tileSize = self.tileSize;
        [_scrollView addSubview:_mapTileView];

        _annotationContainerView = [[OMKAnnotationContainerView alloc] initWithFrame:CGRectMake(0, 0, 256, 256)];
        _annotationContainerView->_mapView = self;

        UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTapGR.numberOfTapsRequired = 1;
        singleTapGR.delaysTouchesEnded = YES;
        singleTapGR.delaysTouchesBegan = YES;
        [_annotationContainerView addGestureRecognizer:singleTapGR];

        [_scrollView addSubview:_annotationContainerView];

        _overlayContainerView = [[OMKOverlayContainerView alloc] initWithFrame:_mapTileView.bounds];
        
        _overlayTileView = [[OMKOverlayTileView alloc] initWithFrame:_mapTileView.bounds];

        _overlayTileView.mapView = self;
        _overlayTileView.tileSize = self.tileSize;
        [_overlayContainerView addSubview:_overlayTileView];

        _mapTileView->_overlayTileView = _overlayTileView;
        [_mapTileView addSubview:_overlayContainerView];

        _userTrackingMode = OMKUserTrackingModeInactive;

        _openStreetMapAttributionView = [[UIImageView alloc] initWithImage:[UIImage omk_openStreetMapAttributionImage]];
        _openStreetMapAttributionView.frame = CGRectMake(
            self.bounds.origin.x + OMKOpenStreetMapAttributionPadding.width,
            self.bounds.origin.y + self.bounds.size.height - OMKOpenStreetMapAttributionPadding.height - _openStreetMapAttributionView.image.size.height,
            _openStreetMapAttributionView.image.size.width,
            _openStreetMapAttributionView.image.size.height);

        _openStreetMapAttributionView.hidden = NO;
        [self addSubview:_openStreetMapAttributionView];
        [self bringSubviewToFront:_openStreetMapAttributionView];

        _annotations = [NSMutableSet set];

        [self zoomToLocationCoordinate:CLLocationCoordinate2DMake(OMKDefaultLatitude, OMKDefaultLongitude) zoomLevel:OMKDefaultZoomLevel animated:NO];
    }
    return self;
}

- (id)initWithMapTileProvider:(id<OMKMapTileProvider>)tileProvider
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _tileProvider = tileProvider;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        _locationManager.delegate = nil;
        [_locationManager stopUpdatingLocation];
        [_locationManager stopUpdatingHeading];
    }
    else {
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    }
}

- (void)layoutSubviews
{
    _scrollView.frame = topView.bounds;
}

#pragma mark - User Location

- (void)setShowsUserLocation:(BOOL)ifShowsUserLocation
{
    showsUserLocation = ifShowsUserLocation;

    if (showsUserLocation) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    else {
        [_locationManager stopUpdatingLocation];
        [_locationManager stopUpdatingHeading];
        _locationManager = nil;
    }
}

#pragma mark - Annotations

- (NSArray *)annotations
{
    return [_annotations allObjects];
}

- (void)addAnnotation:(id <OMKAnnotation>)annotation
{
    if (!annotation)
        return;

    [_annotations addObject:annotation];
    [_annotationContainerView addAnnotationViewForAnnotation:annotation];
}

- (void)addAnnotations:(NSArray *)annotations
{
    if (!annotations)
        return;

    [_annotations addObjectsFromArray:annotations];

    for (id<OMKAnnotation> annotation in annotations) {
        [_annotationContainerView addAnnotationViewForAnnotation:annotation];
    }
}

- (OMKAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier
{
    return [_annotationContainerView dequeueReusableAnnotationViewWithIdentifier:identifier];
}

- (void)selectAnnotation:(id <OMKAnnotation>)annotation animated:(BOOL)animated
{
    [_annotationContainerView selectAnnotation:annotation animated:(BOOL)animated];
}

#pragma mark - Overlays

- (void)addOverlay:(id <OMKOverlay>)overlay
{
    if (_delegateRespondsToViewForOverlay) {
        OMKOverlayView *view = [_delegate mapView:self viewForOverlay:overlay];
        OMKMapRect r = [view.overlay boundingMapRect];
        view.frame = CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height);
        view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.5];
        [_overlayTileView.overlayViews addObject:view];
    }
}

#pragma mark - Other stuff

- (void)setNeedsDisplayTileWithKey:(OMKTileKey *)tileKey
{
    // FIXME: don't update when zoom is totally different
    [_mapTileView.layer setNeedsDisplay];
}

- (void)setDelegate:(id <OMKMapViewDelegate>)delegate
{
    _delegate = delegate;
    _delegateRespondsToViewForAnnotation = [delegate respondsToSelector:@selector(mapView:viewForAnnotation:)];
    _delegateRespondsToViewForOverlay = [delegate respondsToSelector:@selector(mapView:viewForOverlay:)];
    minimumZoomLevel = maximumZoomLevel = 0;
    [_scrollView updateZoomScales];
    [self zoomToLocationCoordinate:CLLocationCoordinate2DMake(OMKDefaultLatitude, OMKDefaultLongitude) zoomLevel:OMKDefaultZoomLevel animated:NO];
}

- (CGFloat)zoomScaleForZoomLevel:(OMKZoomLevel)zoomLevel
{
    return powf(2, zoomLevel - OMKMaxZoomLevel);
}

- (CGFloat)zoomLevelForZoomScale:(OMKZoomScale)zoomScale
{
    return log2f(_scrollView.zoomScale) + OMKMaxZoomLevel;
}

- (CGFloat)zoomLevel
{
    return [self zoomLevelForZoomScale:_scrollView.zoomScale];
}

- (CLLocationCoordinate2D)centerCoordinate
{
    CGPoint center = CGPointMake(CGRectGetMidX(_scrollView.bounds), CGRectGetMidY(_scrollView.bounds));
    return CLLocationCoordinate2DMake(__OMKLatitudeForY(center.y, _scrollView.contentSize.height),
                                      __OMKLongitudeForX(center.x, _scrollView.contentSize.width));
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
{
    [self setCenterCoordinate:centerCoordinate animated:NO];
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate animated:(BOOL)animated
{
    [self zoomToLocationCoordinate:centerCoordinate zoomLevel:-1 animated:animated animateDistance:NO];
}

- (void)setVisibleMapRect:(OMKMapRect)mapRect animated:(BOOL)animate
{
    OMKMapRect realMapRect = OMKMapRectMake(MAX(OMKMapRectWorld.origin.x, mapRect.origin.x),
                                            MAX(OMKMapRectWorld.origin.y, mapRect.origin.y),
                                            MIN(OMKMapRectWorld.size.height, mapRect.size.height),
                                            MIN(OMKMapRectWorld.size.width, mapRect.size.width));

    if (_scrollView.minimumZoomScale * OMKMapRectGetHeight(realMapRect) > CGRectGetHeight(self.bounds)) {
        realMapRect.size.height = CGRectGetHeight(self.bounds) / _scrollView.minimumZoomScale;
    }

    if (_scrollView.minimumZoomScale * OMKMapRectGetWidth(realMapRect) > CGRectGetWidth(self.bounds)) {
        realMapRect.size.width = CGRectGetWidth(self.bounds) / _scrollView.minimumZoomScale;
    }

    // TODO: complete the implementation
}

- (void)zoomToLocationCoordinate:(CLLocationCoordinate2D)coordinate zoomLevel:(NSInteger)zoomLevel animated:(BOOL)animated
{
    [self zoomToLocationCoordinate:coordinate zoomLevel:zoomLevel animated:animated animateDistance:YES];
}

- (void)zoomToLocationCoordinate:(CLLocationCoordinate2D)coordinate zoomLevel:(NSInteger)zoomLevel animated:(BOOL)animated animateDistance:(BOOL)animateDistance
{
    CGFloat zoomScale;

    if (zoomLevel < [self minimumZoomLevel]) {
        zoomLevel = -1;
        zoomScale = _scrollView.zoomScale;
    }
    else {
        zoomLevel = MIN(zoomLevel, [self maximumZoomLevel]);
        zoomScale = [self zoomScaleForZoomLevel:zoomLevel];
    }

    OMKMapPoint targetMapPoint = OMKMapPointForCoordinate(coordinate);

    CGSize targetRectSize = CGSizeMake(_scrollView.bounds.size.width / zoomScale,
                                       _scrollView.bounds.size.height / zoomScale);

    CGRect targetZoomRect = CGRectMake(targetMapPoint.x - targetRectSize.width / 2,
                                       targetMapPoint.y - targetRectSize.height / 2,
                                       targetRectSize.width,
                                       targetRectSize.height);

    if (animated) {
        _scrollView.backgroundColor = [UIColor omk_zoomingTileBackgroundColor];

        // Нужно только проскроллить на том же масштабе
        if (_scrollView.zoomScale == zoomScale) {
            CGPoint pointToScroll = OMKPointForCoordinate(coordinate, _scrollView.contentSize, NO);

            CGPoint visibleMapCenterPoint = CGPointMake(CGRectGetMidX(_scrollView.bounds), CGRectGetMidY(_scrollView.bounds));
            CGFloat distance = sqrtf(powf(pointToScroll.x - visibleMapCenterPoint.x, 2) + powf(pointToScroll.y - visibleMapCenterPoint.y, 2));

            // Если точка далеко, сначала удаляемся, потом приближаем
            if (animateDistance && distance > 1000)
            {
                CLLocationCoordinate2D centerCoordinate = self.centerCoordinate;
                [self zoomToLocationCoordinate:centerCoordinate zoomLevel:log2f(zoomScale) - 4 animated:YES];

                [self omk_performBlock:^{
                    [self zoomToLocationCoordinate:centerCoordinate zoomLevel:log2f(zoomScale) animated:YES];
                } afterDelay:0.5];
            }
            else {
                // Время анимации зависит от расстояния до точки от текущего центра
                CGFloat animationDuration = MIN(1, distance / 400) * OMKScrollingDuration;

                [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

                    CGRect targetRect = CGRectMake(pointToScroll.x - _scrollView.bounds.size.width / 2,
                                                   pointToScroll.y - _scrollView.bounds.size.height / 2,
                                                   _scrollView.bounds.size.width,
                                                   _scrollView.bounds.size.height);

                    [_scrollView scrollRectToVisible:targetRect animated:NO];
                } completion:^(BOOL finished){
                    if (finished) {
                        _scrollView.backgroundColor = [UIColor omk_loadingTileBackgroundColor];
                    }
                }];
            }
        }
        // Нужно масштабировать
        else {
            if (zoomScale / _scrollView.zoomScale <= 4) {
                [_scrollView zoomToRect:targetZoomRect animated:YES];
            }
            else {
                [UIView animateWithDuration:OMKZoomingDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    [_scrollView zoomToRect:targetZoomRect animated:NO];
                } completion:^(BOOL finished){
                    if (finished) {
                        _scrollView.backgroundColor = [UIColor omk_loadingTileBackgroundColor];
                    }
                }];
            }
        }
    }
    else {
        [_scrollView zoomToRect:targetZoomRect animated:NO];
    }
}

- (void)setTileProvider:(id<OMKMapTileProvider>)tileProvider
{
    _tileProvider = tileProvider;
    [self updateTileSize];
}

- (void)updateTileSize
{
    _mapTileView.tileSize = _overlayTileView.tileSize = self.tileSize;
}

- (CGSize)tileSize
{
    if ([_tileProvider respondsToSelector:@selector(tileSizeForMapView:)]) {
        CGSize tileSize = [_tileProvider tileSizeForMapView:self];
        NSAssert(!CGSizeEqualToSize(tileSize, CGSizeZero), @"Tile size must not be zero");
        return tileSize;
    }
    return OMKDefaultTileSize;
}

- (OMKZoomLevel)maximumZoomLevel
{
    if (maximumZoomLevel != 0)
        return maximumZoomLevel;

    maximumZoomLevel = OMKMaxZoomLevel;

    if ([_delegate respondsToSelector:@selector(maximumZoomLevelForMapView:)]) {
        maximumZoomLevel = [_delegate maximumZoomLevelForMapView:self];
    }
    return maximumZoomLevel;
}

- (OMKZoomLevel)minimumZoomLevel
{
    if (minimumZoomLevel != 0)
        return minimumZoomLevel;

    minimumZoomLevel = OMKMinZoomLevel;
    
    if ([_delegate respondsToSelector:@selector(minimumZoomLevelForMapView:)]) {
        minimumZoomLevel = [_delegate minimumZoomLevelForMapView:self];
    }
    return minimumZoomLevel;
}

- (void)setUserTrackingMode:(OMKUserTrackingMode)userTrackingMode
{
    if (_userTrackingMode == userTrackingMode)
        return;

    if (userTrackingMode != OMKUserTrackingModeInactive) {
        if (![CLLocationManager locationServicesEnabled]) {
            if ([_delegate respondsToSelector:@selector(mapViewDidFailTrackingUserLocation:withError:)]) {
                NSError *error = [NSError errorWithDomain:kCLErrorDomain code:kCLErrorDenied userInfo:nil];
                [_delegate mapViewDidFailTrackingUserLocation:self withError:error];
            }
        }
    }

    _userTrackingMode = userTrackingMode;
    _annotationContainerView.userTrackingMode = userTrackingMode;

    if (userTrackingMode == OMKUserTrackingModeTrackingLocation) {
        [_locationManager startUpdatingLocation];
        if (_locationManager.location.coordinate.latitude != 0 && _locationManager.location.coordinate.longitude != 0) {
            if (self.zoomLevel < 12) {
                [self zoomToLocationCoordinate:_locationManager.location.coordinate zoomLevel:[self maximumZoomLevel] - [self minimumZoomLevel] animated:YES];
            }
            else {
                [self zoomToLocationCoordinate:_locationManager.location.coordinate zoomLevel:-1 animated:YES];
            }
        }
    }
    else if (userTrackingMode == OMKUserTrackingModeTrackingHeading) {
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];

        if (_locationManager.location.coordinate.latitude != 0 && _locationManager.location.coordinate.longitude != 0) {
            [self zoomToLocationCoordinate:_locationManager.location.coordinate zoomLevel:-1 animated:YES];
        }
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            topView.layer.transform = CATransform3DIdentity;
        }];
        if ([_delegate respondsToSelector:@selector(mapViewDidFinishTrackingUserLocation:)]) {
            [_delegate mapViewDidFinishTrackingUserLocation:self];
        }
        [_locationManager stopUpdatingHeading];
    }
}

- (void)setShowsOpenStreetMapAttribution:(BOOL)showsOpenStreetMapAttribution
{
    _openStreetMapAttributionView.hidden = !showsOpenStreetMapAttribution;
}

- (BOOL)showsOpenStreetMapAttribution
{
    return !_openStreetMapAttributionView.hidden;
}

#pragma mark - Scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _mapTileView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_userTrackingMode != OMKUserTrackingModeInactive) {
        self.userTrackingMode = OMKUserTrackingModeInactive;
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)aScrollView withView:(UIView *)view atScale:(float)scale
{
    _scrollView.backgroundColor = [UIColor omk_loadingTileBackgroundColor];
    [_annotationContainerView setNeedsLayout];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)aScrollView withView:(UIView *)view
{
    _scrollView.backgroundColor = [UIColor omk_zoomingTileBackgroundColor];
}

- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
{
    _annotationContainerView.frame = _mapTileView.frame;
    [_annotationContainerView layoutSubviews];
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    _annotationContainerView.userLocation = newLocation;

    if (_userTrackingMode != OMKUserTrackingModeInactive) {
        if (_locationManager.location.coordinate.latitude != 0 && _locationManager.location.coordinate.longitude != 0) {
            [self zoomToLocationCoordinate:_locationManager.location.coordinate zoomLevel:-1 animated:YES];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [UIView animateWithDuration:0.2 animations:^{
#if OMK_ROTATE_MAP_ON_HEADING_CHANGE
        topView.layer.transform = CATransform3DMakeRotation(-newHeading.trueHeading * M_PI / 180, 0, 0, 1);
        [_annotationContainerView setUserHeading:newHeading];
#else
        [_annotationContainerView setUserHeading:newHeading];
#endif
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [_annotationContainerView hideUserLocationView];

    [_locationManager stopUpdatingHeading];
    [_locationManager stopUpdatingLocation];

    if ([_delegate respondsToSelector:@selector(mapViewDidFailTrackingUserLocation:withError:)]) {
        [_delegate mapViewDidFailTrackingUserLocation:self withError:error];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

#pragma mark - Private API

- (UIScrollView *)scrollView
{
    return _scrollView;
}

- (UIEdgeInsets)topViewInsets
{
    return UIEdgeInsetsMake(CGRectGetMinY(topView.frame) - CGRectGetMinY(self.bounds),
                            CGRectGetMinX(topView.frame) - CGRectGetMinX(self.bounds),
                            CGRectGetMaxY(topView.frame) - CGRectGetMaxY(self.bounds),
                            CGRectGetMaxX(topView.frame) - CGRectGetMaxX(self.bounds));
}

- (OMKAnnotationView *)viewForAnnotation:(id<OMKAnnotation>)annotation
{
    if (_delegateRespondsToViewForAnnotation)
        return [_delegate mapView:self viewForAnnotation:annotation];

    return nil;
}

- (void)annotationView:(OMKAnnotationView *)annotationView calloutAccessoryTapped:(UIControl *)calloutAccessoryControl
{
    if ([_delegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)]) {
        [_delegate mapView:self annotationView:annotationView calloutAccessoryControlTapped:calloutAccessoryControl];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tapGR
{
//    NSLog(@"-[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (tapGR.state == UIGestureRecognizerStateRecognized) {
        [_annotationContainerView deselectActiveAnnotationView];
    }
}

- (CGFloat)lowerZoomLevel:(CGFloat)zoomLevel
{
    CGFloat lowerZoomLevel = floorf(zoomLevel);

    // Если мы сейчас на масштабе 16.1, то уменьшение нам нужно 15, не 16, т.к. разница в 0.1 слишком мала для зума
    if (zoomLevel - floorf(zoomLevel) < 0.5)
        lowerZoomLevel -= 1;

    return lowerZoomLevel;
}

- (CGFloat)higherZoomLevel:(CGFloat)zoomLevel
{
    CGFloat higherZoomLevel = floorf(zoomLevel) + 1;

    // Если мы сейчас на масштабе 16.7, то увеличение нам нужно 17, не 16, т.к. разница в 0.3 слишком мала для зума
    if (zoomLevel - floorf(zoomLevel) > 0.5)
        higherZoomLevel += 1;

    return higherZoomLevel;
}

@end
