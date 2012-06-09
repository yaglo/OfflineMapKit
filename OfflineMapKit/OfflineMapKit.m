//
//  OfflineMapKit.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OfflineMapKit.h"
#import "OfflineMapKit-Private.h"

const NSInteger OMKMaxZoomLevel = 20;
const NSInteger OMKMinZoomLevel = 2;

// http://stackoverflow.com/a/100165/261460

bool OMKLineIntersectsRect(OMKLine line, CGRect rect)
{
    // Find min and max X for the segment
    float minX = line.start.x;
    float maxX = line.end.x;

    if (line.start.x > line.end.x) {
        minX = line.end.x;
        maxX = line.start.x;
    }

    // Find the intersection of the segment's and rectangle's x-projections
    maxX = MIN(maxX, rect.origin.x + rect.size.width);
    minX = MAX(minX, rect.origin.x);

    // If their projections do not intersect return false
    if (minX > maxX) {
        return false;
    }

    // Find corresponding min and max Y for min and max X we found before
    float minY = line.start.y;
    float maxY = line.end.y;

    float dx = line.end.x - line.start.x;

    if (abs(dx) > 0.0000001) {
        float a = (line.end.y - line.start.y) / dx;
        float b = line.start.y - a * line.start.x;
        minY = a * minX + b;
        maxY = a * maxX + b;
    }

    if (minY > maxY) {
        float tmp = maxY;
        maxY = minY;
        minY = tmp;
    }

    // Find the intersection of the segment's and rectangle's y-projections
    maxY = MIN(maxY, rect.origin.y + rect.size.height);
    minY = MAX(minY, rect.origin.y);

    // If Y-projections do not intersect return false
    if (minY > maxY) {
        return false;
    }

    return true;
}

OMKLinePair OMKLineSidesPair(OMKLine line, CGFloat thickness)
{
    float angle = M_PI_2 - atanf(ABS(line.end.y - line.start.y) / ABS(line.end.x - line.start.x));
    float a = thickness / 2 * sin(angle);
    float c = thickness / 2 * cos(angle);

    OMKLine lineA, lineB;

    if (line.end.x > line.start.x) {
        if (line.end.y < line.start.y) {
            lineA = (OMKLine){ CGPointMake(line.start.x - c, line.start.y - a), CGPointMake(line.end.x - c, line.end.y - a) };
            lineB = (OMKLine){ CGPointMake(line.start.x + c, line.start.y + a), CGPointMake(line.end.x + c, line.end.y + a) };
        }
        else {
            lineA = (OMKLine){ CGPointMake(line.start.x + c, line.start.y - a), CGPointMake(line.end.x + c, line.end.y - a) };
            lineB = (OMKLine){ CGPointMake(line.start.x - c, line.start.y + a), CGPointMake(line.end.x - c, line.end.y + a) };
        }
    }
    else {
        if (line.end.y < line.start.y) {
            lineA = (OMKLine){ CGPointMake(line.start.x - c, line.start.y + a), CGPointMake(line.end.x - c, line.end.y + a) };
            lineB = (OMKLine){ CGPointMake(line.start.x + c, line.start.y - a), CGPointMake(line.end.x + c, line.end.y - a) };
        }
        else {
            lineA = (OMKLine){ CGPointMake(line.start.x - c, line.start.y - a), CGPointMake(line.end.x - c, line.end.y - a) };
            lineB = (OMKLine){ CGPointMake(line.start.x + c, line.start.y + a), CGPointMake(line.end.x + c, line.end.y + a) };
        }
    }

    OMKLinePair pair;
    pair.a = lineA;
    pair.b = lineB;

    return pair;
}
