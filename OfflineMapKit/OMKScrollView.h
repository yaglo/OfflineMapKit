//
//  OMKScrollView.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OMKMapView;

@interface OMKScrollView : UIScrollView

@property (nonatomic, unsafe_unretained) OMKMapView *mapView;

@end
