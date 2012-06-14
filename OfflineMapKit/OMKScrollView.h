//
//  OMKScrollView.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OMKMapView;

@interface OMKScrollView : UIScrollView

- (id)initWithFrame:(CGRect)frame mapView:(OMKMapView *)mapView;
- (void)updateZoomScales;

@end
