//
//  OMKAnnotationContainerView.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import <OfflineMapKit/OMKBase.h>
#import <OfflineMapKit/OMKAnnotation.h>
#import <OfflineMapKit/OMKAnnotationView.h>
#import <OfflineMapKit/OMKCalloutView.h>

@class OMKMapView;

@interface OMKAnnotationContainerView : UIView
{
@package
    __unsafe_unretained OMKMapView *_mapView;
    __strong OMKCalloutView *_calloutView;
}

- (void)addAnnotationViewForAnnotation:(id <OMKAnnotation>)annotation;
- (void)annotationView:(OMKAnnotationView *)view calloutAccessoryTapped:(UIControl *)calloutAccessoryControl;
- (OMKAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier;
- (void)deselectActiveAnnotationView;
- (OMKAnnotationView *)findViewForAnnotation:(id <OMKAnnotation>)annotation;
- (void)selectAnnotation:(id <OMKAnnotation>)annotation animated:(BOOL)animated;
- (void)selectAnnotationView:(OMKAnnotationView *)view;
- (void)showCalloutForAnnotationView:(OMKAnnotationView *)annotationView animated:(BOOL)animated;

@property (nonatomic) OMKUserTrackingMode userTrackingMode;

- (void)setUserHeading:(CLHeading *)heading;
- (void)setUserLocation:(CLLocation *)location;
- (void)hideUserLocationView;

@end
