//
//  OMKPolylineView.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKPolylineView.h"
#import "OMKBase.h"
#import "OfflineMapKit-Private.h"
//#import <vector>
//#import "psimpl.hpp"

// dot product (3D) which allows vector operations in arguments
#define dot(u,v)   ((u).x * (v).x + (u).y * (v).y)
#define norm2(v)   dot(v,v)        // norm2 = squared length of vector
#define norm(v)    sqrt(norm2(v))  // norm = length of vector
#define d2(u)    norm2(u)      // distance squared = norm2 of difference
#define d(u,v)     norm(u-v)       // distance = norm of difference
void simplifyDP( float tol, OMKMapPoint *v, int j, int k, int* mk );

void simplifyDP( float tol, OMKMapPoint *v, int j, int k, int *mk )
{
    if (k <= j+1) // there is nothing to simplify
        return;
    
    // check for adequate approximation by segment S from v[j] to v[k]
    int     maxi = j;          // index of vertex farthest from S
    float   maxd2 = 0;         // distance squared of farthest vertex
    float   tol2 = tol * tol;  // tolerance squared
    OMKLine S;
    S.start = CGPointMake(v[j].x, v[j].y);
    S.end = CGPointMake(v[k].x, v[k].y);
    CGPoint u = CGPointMake(S.end.x - S.start.x, S.end.y - S.start.y);
    double  cu = dot(u,u);     // segment length squared
    
    // test each vertex v[i] for max distance from S
    // compute using the Feb 2001 Algorithm's dist_Point_to_Segment()
    // Note: this works in any dimension (2D, 3D, ...)
    CGPoint w;
    CGPoint   Pb;                // base of perpendicular from v[i] to S
    double  b, cw, dv2;        // dv2 = distance v[i] to S squared
    
    for (int i=j+1; i<k; i++)
    {
        // compute distance squared
        w = CGPointMake(v[i].x - S.start.x, v[i].y - S.start.y);
        cw = dot(w,u);
        if ( cw <= 0 )
            dv2 = d2(CGPointMake(v[i].x - S.start.x, v[i].y - S.start.y));
        else if ( cu <= cw )
            dv2 = d2(CGPointMake(v[i].x - S.end.x, v[i].y - S.end.y));
        else {
            b = cw / cu;
            CGPoint bb = CGPointMake(u.x * b, u.y * b);
            Pb = CGPointMake(S.start.x + bb.x, S.start.y + bb.y);
            dv2 = d2(CGPointMake(v[i].x - Pb.x, v[i].y - Pb.y));
        }
        // test with current max distance squared
        if (dv2 <= maxd2) 
            continue;
        // v[i] is a new max vertex
        maxi = i;
        maxd2 = dv2;
    } 
    if (maxd2 > tol2)        // error is worse than the tolerance
    {
        // split the polyline at the farthest vertex from S
        mk[maxi] = 1;      // mark v[maxi] for the simplified polyline
        // recursively simplify the two subpolylines at v[maxi]
        simplifyDP( tol, v, j, maxi, mk );  // polyline v[j] to v[maxi]
        simplifyDP( tol, v, maxi, k, mk );  // polyline v[maxi] to v[k]
    }
    // else the approximation is OK, so ignore intermediate vertices
    return;
}


@interface OMKSimplifiedMultiPoint : OMKMultiPoint
@property CGMutablePathRef path;
- (void)simplifyForZoomScale:(OMKZoomScale)zoomScale lineWidth:(CGFloat)lineWidth;
@end

@implementation OMKSimplifiedMultiPoint
@synthesize path;

- (void)simplifyForZoomScale:(OMKZoomScale)zoomScale lineWidth:(CGFloat)lineWidth
{
    OMKMapPoint *points = self.points;
    NSUInteger pointCount = self.pointCount;
    int markers[pointCount];

    float tolerance = 1 / zoomScale;
    simplifyDP(tolerance, points, 0, pointCount - 1, markers);

    int newPointCount = 0;
    for (int i = 0; i < pointCount; i++) {
        if (markers[i] == 1)
            newPointCount++;
    }

    OMKMapPoint newMapPoints[newPointCount + 2]; // +2 = always adding starting and ending points
    newMapPoints[0] = points[0];
    int j = 1;
    for (int i = 0; i < pointCount; i++) {
        if (markers[i] == 1) {
            newMapPoints[j] = points[i];
            j++;
        }
    }
    newMapPoints[newPointCount + 1] = points[pointCount - 1];

    [self setPoints:newMapPoints count:newPointCount + 2];
}

- (void)createPath
{
    if (self.path)
        CGPathRelease(self.path);

    path = CGPathCreateMutable();
    OMKMapPoint *points = self.points;
    NSUInteger pointCount = self.pointCount;

    if (self.pointCount > 1) {
        CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
        for (NSUInteger i = 1; i < pointCount; i++) {
            CGPathAddLineToPoint(path, NULL, points[i].x, points[i].y);
        }
    }
    self.path = path;
}

- (void)dealloc
{
    CGPathRelease(self.path);
}
@end

@implementation OMKPolylineView
{
    NSMutableDictionary *_multiPointsForZoomLevels;
}

- (id)initWithPolyline:(OMKPolyline *)polyline
{
    self = [super initWithOverlay:polyline];
    if (self) {
        [self simplify];
    }
    return self;
}

- (OMKPolyline *)polyline
{
    return (OMKPolyline *)self.overlay;
}

- (void)simplify
{
    _multiPointsForZoomLevels = [NSMutableDictionary dictionary];
    
    OMKMapPoint *points = self.polyline.points;
    NSUInteger pointCount = self.polyline.pointCount;
    
    for (int i = OMKMinZoomLevel; i <= OMKMaxZoomLevel; i++) {
        float zoomScale = 1. / powf(2, i);
        NSNumber *zoomScaleNumber = [NSNumber numberWithFloat:zoomScale];
        OMKSimplifiedMultiPoint *toSimplify = [[OMKSimplifiedMultiPoint alloc] init];
        [toSimplify setPoints:points count:pointCount];
        [toSimplify simplifyForZoomScale:zoomScale lineWidth:self.lineWidth];
        [toSimplify createPath];
        [_multiPointsForZoomLevels setObject:toSimplify forKey:zoomScaleNumber];
    }
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    [super setLineWidth:lineWidth];
    [self simplify];
}

- (void)createPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    OMKPolyline *polyline = (OMKPolyline *)self.overlay;
    OMKMapPoint *points = polyline.points;
    NSUInteger pointCount = polyline.pointCount;
//    CGPoint origin = CGPointMake(INFINITY, INFINITY);
//
//    for (int i = 0; i < pointCount; i++) {
//        origin = CGPointMake(MIN(points[i].x, origin.x), MIN(points[i].y, origin.y));
//    }
//
//    CGAffineTransform translation = CGAffineTransformMakeTranslation(-origin.x, -origin.y);

    if (polyline.pointCount > 1) {
        CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
        for (NSUInteger i = 1; i < pointCount; i++) {
            CGPathAddLineToPoint(path, NULL, points[i].x, points[i].y);
        }
    }
    self.path = path;
    CGPathRelease(path);
}

- (BOOL)canDrawMapRect:(OMKMapRect)mapRect zoomScale:(OMKZoomScale)zoomScale
{
    if (![self.overlay intersectsMapRect:mapRect])
        return NO;

    NSNumber *zoomScaleNumber = [NSNumber numberWithFloat:zoomScale];

    OMKSimplifiedMultiPoint *polyline = [_multiPointsForZoomLevels objectForKey:zoomScaleNumber];

    OMKMapPoint *points = polyline.points;
    NSUInteger pointCount = polyline.pointCount;

    CGRect rect = CGRectMake(mapRect.origin.x, mapRect.origin.y, mapRect.size.width, mapRect.size.height);
    CGFloat thickness = self.lineWidth * OMKRoadWidthAtZoomScale(zoomScale) * 1.5;

    if (pointCount < 2)
        return NO;

    for (int i = 0; i < pointCount - 1; i++) {
        OMKLine line;
        line.start.x = points[i].x; line.start.y = points[i].y;
        line.end.x = points[i + 1].x; line.end.y = points[i + 1].y;
    
        OMKLinePair pair = OMKLineSidesPair(line, thickness);
        if (OMKLineIntersectsRect(pair.a, rect) || OMKLineIntersectsRect(pair.b, rect))
            return YES;
    }
    return NO;
}

- (void)drawMapRect:(OMKMapRect)mapRect zoomScale:(OMKZoomScale)zoomScale inContext:(CGContextRef)context
{
    NSNumber *zoomScaleNumber = [NSNumber numberWithFloat:zoomScale];
    OMKSimplifiedMultiPoint *polyline = [_multiPointsForZoomLevels objectForKey:zoomScaleNumber];

    if (self.lineWidth == 0) {
        self.lineWidth = 1;
        [self applyStrokePropertiesToContext:context atZoomScale:zoomScale];
        self.lineWidth = 0;
    }
    else {
        [self applyStrokePropertiesToContext:context atZoomScale:zoomScale];
    }
    [self strokePath:polyline.path inContext:context];
}

@end
