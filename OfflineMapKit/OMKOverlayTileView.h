//
//  OMKOverlayTileView.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <OfflineMapKit/OMKMapView.h>

@interface OMKOverlayTileView : UIView

@property (nonatomic, assign) OMKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *overlayViews;
@property (nonatomic, assign) CGSize tileSize;

@end
