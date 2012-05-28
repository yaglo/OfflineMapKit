//
//  OMKPinAnnotationView.m
//  Concrete implementation of the pin annotation view
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKPinAnnotationView.h"

@implementation OMKPinAnnotationView

- (id)initWithAnnotation:(id<OMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.touchArea = CGRectMake(0, 0, 16, 37);
        self.image = [UIImage imageNamed:@"OfflineMapKit.bundle/Pin.png"];
        self.centerOffset = CGPointZero;
        self.calloutOffset = CGPointMake(-8, 0);
        self.layer.anchorPoint = CGPointMake(.25, 34. / 39.);
        self.frame = CGRectMake(-8, -34, 32, 39);
    }
    return self;
}

@end
