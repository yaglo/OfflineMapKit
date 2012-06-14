//
//  OMKMapTileView.h
//  Private class to display tiles
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OfflineMapKit.h"
#import "OMKOverlayTileView.h"

@interface OMKMapTileView : UIView
{
@package
    __unsafe_unretained OMKOverlayTileView *_overlayTileView;
}

@property (nonatomic, assign) OMKMapView *mapView;
@property (nonatomic, assign) CGSize tileSize;

- (CGImageRef)fetchTileForRect:(CGRect)rect scale:(CGFloat)scale;

@end
