//
//  OMKCXX.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#ifndef OfflineMapKit_OMKCXX_h
#define OfflineMapKit_OMKCXX_h

#include <vector>

typedef struct {
    double x;
    double y;
} OMKMapPointCXX;

std::vector<double> OMKSimplifiedPolyline(OMKMapPointCXX *points, unsigned pointCount, double tolerance);

#endif
