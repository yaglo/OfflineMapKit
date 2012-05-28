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
    __strong UIView *_touchableView;
}

@synthesize annotation = _annotation;
@synthesize calloutOffset = _calloutOffset;
@synthesize canShowCallout;
@synthesize centerOffset = _centerOffset;
@synthesize image = _image;
@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize rightView;
@synthesize rightCalloutAccessoryView = _rightCalloutAccessoryView;
@synthesize touchArea = _touchArea;

- (id)initWithAnnotation:(id<OMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _annotation = annotation;
        _reuseIdentifier = [reuseIdentifier copy];
    }
    return self;
}

- (void)setAnnotation:(id<OMKAnnotation>)annotation
{
    [(NSObject *)_annotation removeObserver:self forKeyPath:@"coordinate"];
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
    [self setNeedsLayout];
}

- (void)calloutAccessoryControlTapped:(UIControl *)calloutAccessoryControl
{
    OMKAnnotationContainerView *container = (id)self.superview;
    [container->_mapView annotationView:self calloutAccessoryTapped:calloutAccessoryControl];
}

- (void)setTouchArea:(CGRect)touchArea
{
    if (CGRectEqualToRect(_touchArea, touchArea))
        return;

    _touchArea = touchArea;
    [self setNeedsLayout];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];

    if (hitView != _touchableView)
        return nil;

    return hitView;
}

- (void)layoutSubviews
{
    _imageView.frame = self.bounds;

    if (CGRectEqualToRect(_touchArea, CGRectZero)) {
        _touchArea = _imageView.bounds;
    }

    _touchableView.frame = _touchArea;

    if (!_touchableView) {
        _touchableView = [[UIView alloc] initWithFrame:_touchArea];
        _imageView.userInteractionEnabled = YES;
        _touchableView.userInteractionEnabled = YES;
        [_imageView addSubview:_touchableView];

        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchableViewTap:)];
        gestureRecognizer.numberOfTapsRequired = 1;
        gestureRecognizer.numberOfTouchesRequired = 1;
        [_touchableView addGestureRecognizer:gestureRecognizer];
    }
}

- (void)handleTouchableViewTap:(UITapGestureRecognizer *)gestureRecognizer
{
//    NSLog(@"-[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    OMKAnnotationContainerView *container = (id)self.superview;
    [container selectAnnotationView:self];
}

@end
