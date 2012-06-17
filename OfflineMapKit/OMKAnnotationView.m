//
//  OMKAnnotationView.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "OMKAnnotationContainerView.h"
#import "OMKAnnotationView.h"
#import "OfflineMapKit-Private.h"

@implementation OMKAnnotationView
{
    __strong UIImageView *_imageView;
}

@synthesize annotation = _annotation;
@synthesize calloutOffset = _calloutOffset;
@synthesize canShowCallout;
@synthesize centerOffset = _centerOffset;
@synthesize image = _image;
@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize rightView;
@synthesize rightCalloutAccessoryView = _rightCalloutAccessoryView;

- (id)initWithAnnotation:(id<OMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.annotation = annotation;
        self.multipleTouchEnabled = YES;
        _reuseIdentifier = [reuseIdentifier copy];

        NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmedTitle = [[_annotation title] stringByTrimmingCharactersInSet:whitespaceSet];
        self.canShowCallout = ([trimmedTitle length] != 0);
    }
    return self;
}

- (void)dealloc
{
    if (_annotation) {
        [(NSObject *)_annotation removeObserver:self forKeyPath:@"coordinate"];
    }
}

- (void)setAnnotation:(id<OMKAnnotation>)annotation
{
    if (_annotation) {
        [(NSObject *)_annotation removeObserver:self forKeyPath:@"coordinate"];
    }

    _annotation = annotation;
    [(NSObject *)_annotation addObserver:self forKeyPath:@"coordinate" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    OMKAnnotationContainerView *container = (id)self.superview;
    [container performSelectorOnMainThread:@selector(repositionAnnotationView:) withObject:self waitUntilDone:YES];
}

- (void)setRightCalloutAccessoryView:(UIControl *)rightCalloutAccessoryView
{
    NSAssert([rightCalloutAccessoryView isKindOfClass:[UIControl class]], @"rightCalloutAccessoryView must be a UIControl subclass");

    if (_rightCalloutAccessoryView == rightCalloutAccessoryView)
        return;

    _rightCalloutAccessoryView = rightCalloutAccessoryView;
    [_rightCalloutAccessoryView addTarget:self action:@selector(calloutAccessoryControlTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setCenterOffset:(CGPoint)centerOffset
{
    if (_centerOffset.x == centerOffset.x && _centerOffset.y == centerOffset.y)
        return;

    _centerOffset = centerOffset;
    [self setNeedsLayout];
}

- (void)setImage:(UIImage *)image
{
    if (_image == image)
        return;

    _image = image;

    [_imageView removeFromSuperview];

    if (_image) {
        _imageView = [[UIImageView alloc] initWithImage:_image];
        _imageView.userInteractionEnabled = YES;
        [self addSubview:_imageView];
    }

    self.bounds = CGRectMake(0, 0, _image.size.width, _image.size.height);
}

- (void)calloutAccessoryControlTapped:(UIControl *)calloutAccessoryControl
{
    OMKAnnotationContainerView *container = (id)self.superview;
    [container->_mapView annotationView:self calloutAccessoryTapped:calloutAccessoryControl];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1) {
        [self performSelector:@selector(handleSingleTap) withObject:nil afterDelay:0.4];
    }
}

- (void)handleSingleTap
{
    OMKAnnotationContainerView *container = (id)self.superview;
    [container selectAnnotationView:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(_imageView.frame, point);
}

- (void)layoutSubviews
{
    _imageView.frame = self.bounds;
}

@end
