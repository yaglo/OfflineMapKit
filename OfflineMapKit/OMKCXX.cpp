//
//  OMKCPPFunctions.cpp
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#include "OMKCXX.h"
#include "psimpl.hpp"

std::vector<double> OMKSimplifiedPolyline(OMKMapPointCXX *points, unsigned pointCount, double tolerance)
{
    std::deque<double> polyline;
    for (int i = 0; i < pointCount; i++) {
        polyline.push_back(points[i].x);
        polyline.push_back(points[i].y);
    }

    std::vector<double> result;
    psimpl::simplify_douglas_peucker_n <2> (polyline.begin(), polyline.end(), tolerance, std::back_inserter(result));

    return result;
}