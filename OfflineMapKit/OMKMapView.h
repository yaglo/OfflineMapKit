//
//  OMKMapView.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import "OMKBase.h"
#import "OMKPolyline.h"
#import "OMKMapViewDelegate.h"
#import <OfflineMapKit/OMKTileKey.h>

@protocol OMKMapTileProvider;
@protocol OMKMapViewDelegate;

@interface OMKMapView : UIView <CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, readonly) NSArray *annotations;
- (void)addAnnotation:(id <OMKAnnotation>)annotation;
- (void)addAnnotations:(NSArray *)annotations;

- (void)selectAnnotation:(id <OMKAnnotation>)annotation animated:(BOOL)animated;

- (void)addOverlay:(id <OMKOverlay>)overlay;

- (OMKAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier;

@property (readonly) CGFloat zoomLevel;

@property (nonatomic, assign) id<NSObject, OMKMapViewDelegate> delegate;
@property (nonatomic, strong) id<OMKMapTileProvider> tileProvider;

- (void)zoomToLocationCoordinate:(CLLocationCoordinate2D)coordinate zoomLevel:(NSInteger)zoomLevel animated:(BOOL)animated;

@property (nonatomic, assign) OMKUserTrackingMode userTrackingMode;

@property (nonatomic) BOOL showsOpenStreetMapAttribution;
@property (nonatomic) BOOL showsUserLocation;

- (void)setNeedsDisplayTileWithKey:(OMKTileKey *)tileKey;

@property(nonatomic) CLLocationCoordinate2D centerCoordinate;
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate animated:(BOOL)animated;

- (void)setVisibleMapRect:(OMKMapRect)mapRect animated:(BOOL)animate;

@end
