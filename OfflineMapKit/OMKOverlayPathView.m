//
//  OMKOverlayPathView.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKOverlayPathView.h"

@implementation OMKOverlayPathView
{
    CGPathRef _path;
}

#pragma mark - Properties

@synthesize fillColor;
@synthesize strokeColor;
@synthesize lineWidth;
@synthesize lineJoin;
@synthesize lineCap;
@synthesize miterLimit;
@synthesize lineDashPhase;
@synthesize lineDashPattern;

#pragma mark - Object Lifecycle

- (id)initWithOverlay:(id<OMKOverlay>)overlay
{
    self = [super initWithOverlay:overlay];
    if (self) {
        fillColor = nil;
        strokeColor = nil;
        lineWidth = 0;
        lineJoin = kCGLineJoinMiter;
        lineCap = kCGLineCapButt;
        miterLimit = 10;
        lineDashPhase = 0;
        lineDashPattern = nil;
    }
    return self;
}

- (void)dealloc
{
    CGPathRelease(_path);
}

- (CGPathRef)path
{
    if (!_path)
        [self createPath];

    return _path;
}

- (void)setPath:(CGPathRef)newPath
{
    if (_path == newPath)
        return;

    [self invalidatePath];
    _path = CGPathRetain(newPath);
}

#pragma mark - Public Methods

- (void)createPath
{
}

- (void)invalidatePath
{
    CGPathRelease(_path);
    _path = nil;
}

- (void)applyStrokePropertiesToContext:(CGContextRef)context atZoomScale:(OMKZoomScale)zoomScale
{
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineWidth(context, lineWidth * 1 / zoomScale);
    CGContextSetLineJoin(context, lineJoin);
    CGContextSetLineCap(context, lineCap);
    CGContextSetMiterLimit(context, miterLimit);

    if ([lineDashPattern count] > 0) {
        CGFloat lengths[[lineDashPattern count]]; // Thanks, C99
        int i = 0;
        // TODO: does MapKit check that all the objects in the array are NSNumber?
        for (NSNumber *number in lineDashPattern) {
            lengths[i++] = [number floatValue] * OMKRoadWidthAtZoomScale(zoomScale);
        }
        CGContextSetLineDash(context, lineDashPhase, lengths, [lineDashPattern count]);
    }
}

- (void)applyFillPropertiesToContext:(CGContextRef)context atZoomScale:(OMKZoomScale)zoomScale
{
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
}

- (void)strokePath:(CGPathRef)path inContext:(CGContextRef)context
{
    if (!strokeColor)
        return;

    CGContextAddPath(context, path);
    CGContextStrokePath(context);
}

- (void)fillPath:(CGPathRef)path inContext:(CGContextRef)context
{
    if (!fillColor)
        return;

    CGContextAddPath(context, path);
    CGContextFillPath(context);
}

#pragma mark - NSCoding Protocol

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        fillColor = [coder decodeObjectForKey:@"fillColor"];
        strokeColor = [coder decodeObjectForKey:@"strokeColor"];
        lineWidth = (CGFloat)[coder decodeDoubleForKey:@"lineWidth"];
        lineJoin = [coder decodeIntForKey:@"lineJoin"];
        lineCap = [coder decodeIntForKey:@"lineCap"];
        miterLimit = (CGFloat)[coder decodeDoubleForKey:@"miterLimit"];
        lineDashPhase = (CGFloat)[coder decodeDoubleForKey:@"lineDashPhase"];
        lineDashPattern = [coder decodeObjectForKey:@"lineDashPattern"];

        UIBezierPath *path = [coder decodeObjectForKey:@"path"];
        _path = CGPathRetain(path.CGPath);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:fillColor forKey:@"fillColor"];
    [coder encodeObject:strokeColor forKey:@"strokeColor"];
    [coder encodeDouble:(double)lineWidth forKey:@"lineWidth"];
    [coder encodeInt:lineJoin forKey:@"lineJoin"];
    [coder encodeInt:lineCap forKey:@"lineCap"];
    [coder encodeDouble:(double)miterLimit forKey:@"miterLimit"];
    [coder encodeDouble:(double)lineDashPhase forKey:@"lineDashPhase"];
    [coder encodeObject:lineDashPattern forKey:@"lineDashPattern"];
    [coder encodeObject:[UIBezierPath bezierPathWithCGPath:_path] forKey:@"path"];
}

@end
