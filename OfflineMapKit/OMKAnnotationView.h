//
//  OMKAnnotationView.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import "OMKAnnotation.h"

@interface OMKAnnotationView : UIView
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIControl *rightCalloutAccessoryView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGPoint centerOffset;
@property (nonatomic) CGPoint calloutOffset;

@property (nonatomic) BOOL canShowCallout;

@property (nonatomic, readonly) NSString *reuseIdentifier;

- (id)initWithAnnotation:(id <OMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic, strong) id <OMKAnnotation> annotation;

@end
