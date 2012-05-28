//
//  OMKMultiPoint.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <OfflineMapKit/OMKMultiPoint.h>

@implementation OMKMultiPoint
{
    OMKMapPoint *_points;
    NSUInteger _pointCount;
}

#pragma mark - Properties

@synthesize points = _points;
@synthesize pointCount = _pointCount;

#pragma mark - Object Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        _points = NULL; // Avoiding "pointer being freed was not allocated"
        _pointCount = 0;
        _boundingMapRect = OMKMapRectNull;
    }
    return self;
}

- (void)dealloc
{
    free(_points);
}

#pragma mark - Public Methods

- (void)getCoordinates:(CLLocationCoordinate2D *)coords range:(NSRange)range
{
    range = NSIntersectionRange(NSMakeRange(0, _pointCount), range);

    if (range.length == 0)
        return;

    for (NSUInteger i = 0; i < range.length; i++) {
        coords[i] = OMKCoordinateForMapPoint(_points[range.location + i]);
    }
}

#pragma mark - Private Methods

- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    if (_points)
        free(_points);

    _pointCount = count;
    _points = malloc(count * sizeof(OMKMapPoint));

    for (int i = 0; i < count; i++) {
        _points[i] = OMKMapPointForCoordinate(coordinates[i]);
    }
}

- (void)setPoints:(OMKMapPoint *)points count:(NSUInteger)count
{
    if (_points)
        free(_points);

    _pointCount = count;

    size_t byteCount = count * sizeof(OMKMapPoint);
    _points = malloc(byteCount);
    memcpy(_points, points, byteCount);
}

#pragma mark - OMKOverlay Protocol

- (OMKMapRect)boundingMapRect
{
    if (_pointCount == 0) {
        _boundingMapRect = OMKMapRectMake(0, 0, 0, 0);
    }
    else if (OMKMapRectIsNull(_boundingMapRect)) {
        OMKMapPoint topLeft = _points[0];
        OMKMapPoint bottomRight = _points[0];

        for (NSUInteger i = 1; i < _pointCount; i++) {
            topLeft = OMKMapPointMake(MIN(topLeft.x, _points[i].x),
                                      MIN(topLeft.y, _points[i].y));
            bottomRight = OMKMapPointMake(MAX(bottomRight.x, _points[i].x),
                                          MAX(bottomRight.y, _points[i].y));
        }
        _boundingMapRect = OMKMapRectMake(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
    }
    return _boundingMapRect;
}

- (BOOL)intersectsMapRect:(OMKMapRect)mapRect
{
    return OMKMapRectIntersectsRect([self boundingMapRect], mapRect);
}

@end
