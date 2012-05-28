//
//  OMKOverlayView.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OMKBase.h"
#import "OMKOverlay.h"

@interface OMKOverlayView : UIView <NSCoding>
{
@protected
    OMKMapRect _boundingMapRect;
}

@property (nonatomic, readonly) id <OMKOverlay> overlay;

- (id)initWithOverlay:(id <OMKOverlay>)overlay;

- (BOOL)canDrawMapRect:(OMKMapRect)mapRect zoomScale:(OMKZoomScale)zoomScale;
- (void)drawMapRect:(OMKMapRect)mapRect zoomScale:(OMKZoomScale)zoomScale inContext:(CGContextRef)context;

@end
