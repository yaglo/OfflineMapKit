//
//  OMKTViewController.m
//  OfflineMapKitTests
//
//  Created by Stanislav Yaglo on 6/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "OMKTViewController.h"
#import "OMKTTileProvider.h"

@implementation OMKTViewController
{
    OMKMapView *omkmapView;
    MKMapView *mkmapView;

    OMKTTileProvider *tileProvider;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
    [self testAnnotations];
}

- (void)setUp
{
    tileProvider = [[OMKTTileProvider alloc] init];
    omkmapView = [[OMKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    omkmapView.delegate = self;
    omkmapView.tileProvider = tileProvider;
//    omkmapView.showsUserLocation = YES;
    [self.view addSubview:omkmapView];

//    mkmapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 240, 320, 240)];
    mkmapView.delegate = self;
//    mkmapView.showsUserLocation = YES;
    [self.view addSubview:mkmapView];
}

- (void)testAnnotations
{
    __block OMKPointAnnotation *omkAnnotation = [[OMKPointAnnotation alloc] init];
    omkAnnotation.title = @"Hello";
    omkAnnotation.subtitle = @"World";
    omkAnnotation.coordinate = CLLocationCoordinate2DMake(37.160317, -95.976562);
//    [omkmapView zoomToLocationCoordinate:CLLocationCoordinate2DMake(0, 0) zoomLevel:3 animated:NO];
    [omkmapView addAnnotation:omkAnnotation];

    __block MKPointAnnotation *mkAnnotation = [[MKPointAnnotation alloc] init];
    mkAnnotation.title = @"Hello";
    mkAnnotation.subtitle = @"World";
    mkAnnotation.coordinate = CLLocationCoordinate2DMake(0, 0);
    [mkmapView addAnnotation:mkAnnotation];
//    [mkmapView setVisibleMapRect:MKMapRectWorld animated:YES];

    /*
    double delayInSeconds = .5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIScrollView *omkscrollView = [[[omkmapView.subviews objectAtIndex:0] subviews] objectAtIndex:0];
        UIScrollView *mkscrollView = [[[mkmapView.subviews objectAtIndex:0] subviews] objectAtIndex:0];

        if (omkscrollView.zoomScale != mkscrollView.zoomScale) {
            NSLog(@"Initial scroll view zoom scale is wrong!");
            NSLog(@"Source: %f, Target: %f", omkscrollView.zoomScale, mkscrollView.zoomScale);
        }

        if (!CGPointEqualToPoint(omkscrollView.contentOffset, mkscrollView.contentOffset)) {
            NSLog(@"Initial scroll view content offset is wrong!");
            NSLog(@"Source: %@, Target: %@", NSStringFromCGPoint(omkscrollView.contentOffset), NSStringFromCGPoint(mkscrollView.contentOffset));
        }
        
        if (!CGRectEqualToRect(omkscrollView.frame, mkscrollView.frame)) {
            NSLog(@"Initial scroll view frame is wrong!");
            NSLog(@"Source: %@, Target: %@", NSStringFromCGRect(omkscrollView.frame), NSStringFromCGRect(mkscrollView.frame));
        }

        [omkmapView selectAnnotation:omkAnnotation animated:YES];
        [mkmapView selectAnnotation:mkAnnotation animated:YES];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (!CGPointEqualToPoint(omkscrollView.contentOffset, mkscrollView.contentOffset)) {
                NSLog(@"After annotation selection scroll view content offset is wrong!");
                NSLog(@"Source: %@, Target: %@", NSStringFromCGPoint(omkscrollView.contentOffset), NSStringFromCGPoint(mkscrollView.contentOffset));
            }

            if (!CGRectEqualToRect(omkscrollView.frame, mkscrollView.frame)) {
                NSLog(@"After annotation selection scroll view frame is wrong!");
                NSLog(@"Source: %@, Target: %@", NSStringFromCGRect(omkscrollView.frame), NSStringFromCGRect(mkscrollView.frame));
            }
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(55.75578, 37.615149);
                [omkmapView setCenterCoordinate:coordinate animated:YES];
                [mkmapView setCenterCoordinate:coordinate animated:YES];
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    if (!CGPointEqualToPoint(omkscrollView.contentOffset, mkscrollView.contentOffset)) {
                        NSLog(@"After setting center coordinate selection scroll view content offset is wrong!");
                        NSLog(@"Source: %@, Target: %@", NSStringFromCGPoint(omkscrollView.contentOffset), NSStringFromCGPoint(mkscrollView.contentOffset));
                    }
                    
                    if (!CGRectEqualToRect(omkscrollView.frame, mkscrollView.frame)) {
                        NSLog(@"After setting center coordinate scroll view frame is wrong!");
                        NSLog(@"Source: %@, Target: %@", NSStringFromCGRect(omkscrollView.frame), NSStringFromCGRect(mkscrollView.frame));
                    }
                });
            });
        });
    });*/
}

- (id)mapView:(id)mapView viewForAnnotation:(id)annotation
{
    if ([mapView isKindOfClass:[MKMapView class]]) return nil;

    OMKPinAnnotationView *annotationView = (id)[(OMKMapView *)mapView dequeueReusableAnnotationViewWithIdentifier:@"POI"];
    if (!annotationView) {
        annotationView = [[OMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"POI"];
    }
//    annotationView.image = [UIImage imageNamed:@"OfflineMapKit.bundle/CalloutLeftCap.png"];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    button.frame = CGRectMake(0, 0, 29, 31);
    [annotationView performSelector:@selector(setRightCalloutAccessoryView:) withObject:button];

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [[[UIAlertView alloc] initWithTitle:@"Hello" message:@"World" delegate:nil cancelButtonTitle:@"Hi!" otherButtonTitles:nil] show];
}

@end
