//
//  OMKMapViewDelegate.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OMKMapView;

#import "OMKAnnotationView.h"
#import "OMKOverlayView.h"

@protocol OMKMapViewDelegate <NSObject>

@optional
- (void)mapView:(OMKMapView *)mapView annotationView:(OMKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
- (void)mapViewDidFinishTrackingUserLocation:(OMKMapView *)mapView;
- (void)mapViewDidFailTrackingUserLocation:(OMKMapView *)mapView withError:(NSError *)error;

- (OMKAnnotationView *)mapView:(OMKMapView *)mapView viewForAnnotation:(id <OMKAnnotation>)annotation;
- (OMKOverlayView *)mapView:(OMKMapView *)mapView viewForOverlay:(id<OMKOverlay>)overlay;

- (OMKZoomLevel)minimumZoomLevelForMapView:(OMKMapView *)mapView;
- (OMKZoomLevel)maximumZoomLevelForMapView:(OMKMapView *)mapView;

@end
