//
//  OMKOverlayPathView.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMKOverlayView.h"

@interface OMKOverlayPathView : OMKOverlayView <NSCoding>

@property (strong) UIColor *fillColor;
@property (strong) UIColor *strokeColor;
@property CGFloat lineWidth;
@property CGLineJoin lineJoin;
@property CGLineCap lineCap;
@property CGFloat miterLimit;
@property CGFloat lineDashPhase;
@property (copy) NSArray *lineDashPattern;

@property CGPathRef path;
- (void)createPath;
- (void)invalidatePath;

- (void)applyStrokePropertiesToContext:(CGContextRef)context atZoomScale:(OMKZoomScale)zoomScale;
- (void)applyFillPropertiesToContext:(CGContextRef)context atZoomScale:(OMKZoomScale)zoomScale;
- (void)strokePath:(CGPathRef)path inContext:(CGContextRef)context;
- (void)fillPath:(CGPathRef)path inContext:(CGContextRef)context;

@end
