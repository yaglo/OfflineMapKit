//
//  OMKMapTileProvider.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OfflineMapKit/OMKMapView.h>
#import <OfflineMapKit/OMKTileKey.h>

@protocol OMKMapTileProvider <NSObject>

- (UIImage *)mapView:(OMKMapView *)mapView imageForTileWithKey:(OMKTileKey *)tileKey;

@end
