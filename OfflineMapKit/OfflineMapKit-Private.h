//
//  OfflineMapKit-Private.h
//  Private header includes
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKAnnotationContainerView.h"

#import <OfflineMapKit/OMKMapView.h>

#import "OMKMapTileView.h"
#import "OMKScrollView.h"
#import "OMKTiledLayer.h"

extern const NSUInteger OMKMaxZoomLevel;
extern const NSUInteger OMKMinZoomLevel;

#define OMK_ROTATE_MAP_ON_HEADING_CHANGE 0

#define OMKDefaultZoomLevel 5
#define OMKDefaultLatitude 37.160317
#define OMKDefaultLongitude -95.976562
#define OMKScrollingDuration 0.7
#define OMKZoomingDuration 1

#pragma mark - OMKMapView

@interface OMKMapView (Private)
- (CGFloat)lowerZoomLevel:(CGFloat)zoomLevel;
- (CGFloat)higherZoomLevel:(CGFloat)zoomLevel;

@property (readonly) OMKScrollView *scrollView;

- (void)annotationView:(OMKAnnotationView *)view calloutAccessoryTapped:(UIControl *)calloutAccessoryControl;
- (OMKAnnotationView *)viewForAnnotation:(id <OMKAnnotation>)annotation;

@end

#pragma mark - OMKMapTileView

@interface OMKMapTileView (Private)
- (void)drawPathsInContext:(CGContextRef)context;
@end

#pragma mark - OMKMultiPoint

@interface OMKMultiPoint (Private)
- (void)setPoints:(OMKMapPoint *)points count:(NSUInteger)count;
- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;
- (OMKMapRect)boundingMapRect;
- (BOOL)intersectsMapRect:(OMKMapRect)mapRect;
@end

#pragma mark - OMKOverlayView

@interface OMKOverlayView (Private)
- (void)setOverlay:(id<OMKOverlay>)overlay;
@end

#pragma mark - OMKGeometry

#ifdef __cplusplus
extern "C" {
#endif

NS_INLINE double __OMKXForLongitude(CLLocationDegrees longitude, double planeWidth) { return (longitude + 180) / 360 * planeWidth; }
NS_INLINE double __OMKYForLatitude(CLLocationDegrees latitude, double planeHeight) { return (1.0 - log(tan(latitude * M_PI / 180) + (1.0 / cos(latitude * M_PI / 180))) / M_PI) / 2.0 * planeHeight; }

NS_INLINE CLLocationDegrees __OMKLongitudeForX(double x, double planeWidth) { return x / planeWidth * 360 - 180; }
NS_INLINE CLLocationDegrees __OMKLatitudeForY(double y, double planeHeight) { return atan(sinh(M_PI * (1 - 2 * y / planeHeight))) * 180 / M_PI; }

NS_INLINE CGPoint OMKPointForCoordinate(CLLocationCoordinate2D coordinate, CGSize planeSize, BOOL round)
{
    if (round) {
        return CGPointMake(floor(__OMKXForLongitude(coordinate.longitude, planeSize.width)),
                           floor(__OMKYForLatitude(coordinate.latitude, planeSize.height)));
    }
    else {
        return CGPointMake(__OMKXForLongitude(coordinate.longitude, planeSize.width),
                           __OMKYForLatitude(coordinate.latitude, planeSize.height));
    }
}

typedef struct {
    NSUInteger x;
    NSUInteger y;
    NSUInteger zoom;
} OMKTile;

typedef struct {
    CGPoint start;
    CGPoint end;
} OMKLine;

typedef struct {
    OMKLine a;
    OMKLine b;
} OMKLinePair;


bool OMKLineIntersectsRect(OMKLine line, CGRect rect);
OMKLinePair OMKLineSidesPair(OMKLine line, CGFloat thickness);


#ifdef __cplusplus
}
#endif
