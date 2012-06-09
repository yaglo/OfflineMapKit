//
//  OMKCalloutView.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <OfflineMapKit/OMKAnnotationContainerView.h>
#import <OfflineMapKit/OMKCalloutView.h>
#import <OfflineMapKit/OMKMapView.h>
#import <OfflineMapKit/OMKScrollView.h>

#import "OfflineMapKit-Private.h"

@interface OMKCalloutView ()
- (void)resize;
- (void)scrollMapViewIfNeeded;
@end

@implementation OMKCalloutView
{
    UIImageView *leftCapView;
    UIImageView *centerView;
    UIImageView *rightCapView;
    UILabel *titleLabel;
    UILabel *subtitleLabel;
    UIView *rightButton;
}

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize rightCalloutAccessoryView = _rightCalloutAccessoryView;

#define kRightControlPadding -3
#define kLeftControlPadding -3
#define kLabelPadding 6

#define kCapWidth 17
#define kCapHeight 57
#define kAnchorWidth 41
#define kCalloutHeight 70

#define kVisibleHeight 47

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, kCalloutHeight)];
    if (self) {
        self.clipsToBounds = NO;
        leftCapView = [[UIImageView alloc] initWithFrame:CGRectZero];
        leftCapView.image = [[UIImage imageNamed:@"OfflineMapKit.bundle/CalloutLeftCap.png"] stretchableImageWithLeftCapWidth:kCapWidth topCapHeight:0];
        [self addSubview:leftCapView];

        centerView = [[UIImageView alloc] initWithFrame:CGRectZero];
        centerView.image = [UIImage imageNamed:@"OfflineMapKit.bundle/CalloutBottomAnchor.png"];
        [self addSubview:centerView];

        rightCapView = [[UIImageView alloc] initWithFrame:CGRectZero];
        rightCapView.image = [[UIImage imageNamed:@"OfflineMapKit.bundle/CalloutRightCap.png"] stretchableImageWithLeftCapWidth:-kCapWidth topCapHeight:0];
        [self addSubview:rightCapView];

        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        titleLabel.shadowOffset = CGSizeMake(0, -1);
        [self addSubview:titleLabel];

        subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.font = [UIFont systemFontOfSize:12];
        subtitleLabel.textColor = [UIColor whiteColor];
        subtitleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        subtitleLabel.shadowOffset = CGSizeMake(0, -1);
        [self addSubview:subtitleLabel];

        [self setNeedsLayout];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle
{
    subtitleLabel.text = subtitle;
}

- (void)setRightCalloutAccessoryView:(UIControl *)rightCalloutAccessoryView;
{
    if (_rightCalloutAccessoryView == rightCalloutAccessoryView)
        return;

    [_rightCalloutAccessoryView removeFromSuperview];
    _rightCalloutAccessoryView = rightCalloutAccessoryView;
    [self addSubview:rightCalloutAccessoryView];
}

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    id hitView = [super hitTest:point withEvent:event];

    if (hitView == _rightCalloutAccessoryView)
        return _rightCalloutAccessoryView;

    if (hitView == self || hitView == leftCapView || hitView == centerView || hitView == rightCapView)
        return nil;
    else
        return hitView;
}

- (OMKMapView *)mapView
{
    return ((OMKAnnotationContainerView *)self.superview)->_mapView;
}

- (void)resize
{
//    NSLog(@"-[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    [self scrollMapViewIfNeeded];

    OMKMapView *mapView = [self mapView];

    CGFloat maxTextWidth = mapView.bounds.size.width - kCapWidth * 2;
    CGFloat titleWidth = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(maxTextWidth, 22) lineBreakMode:UILineBreakModeTailTruncation].width;
    CGFloat subtitleWidth = [subtitleLabel.text sizeWithFont:subtitleLabel.font constrainedToSize:CGSizeMake(maxTextWidth, 16) lineBreakMode:UILineBreakModeTailTruncation].width;
    CGFloat textWidth = MAX(titleWidth, subtitleWidth);

    CGFloat totalWidth = 0;
    CGFloat mapViewWidth = mapView.scrollView.bounds.size.width;

    CGFloat textPositionLeft = kCapWidth;

    // Есть правый аксесуар
    if (_rightCalloutAccessoryView) {
        totalWidth = kCapWidth + textWidth + kLabelPadding + _rightCalloutAccessoryView.frame.size.width + kRightControlPadding + kCapWidth;

        if (totalWidth > mapViewWidth) {
            CGFloat diff = totalWidth - mapViewWidth;
            totalWidth = mapViewWidth;
            textWidth -= diff;
        }
    }
    // Только текст
    else {
        totalWidth = kCapWidth + textWidth + kCapWidth;
    }

    // Прячем подпись если она пустая
    subtitleLabel.hidden = ([subtitleLabel.text length] == 0 || [[subtitleLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0);

    if (subtitleLabel.hidden) {
        titleLabel.frame = CGRectMake(textPositionLeft, 11, textWidth, 22);
    }
    else {
        titleLabel.frame = CGRectMake(textPositionLeft, 3, textWidth, 22);
    }
    subtitleLabel.frame = CGRectMake(textPositionLeft, 25, textWidth, 16);

    _rightCalloutAccessoryView.frame = CGRectMake(totalWidth - kCapWidth - _rightCalloutAccessoryView.frame.size.width - kRightControlPadding,
                                                  rintf((kVisibleHeight - _rightCalloutAccessoryView.frame.size.height) / 2),
                                                  _rightCalloutAccessoryView.frame.size.width,
                                                  _rightCalloutAccessoryView.frame.size.height);

    // Позиционируем наиболее близко к центру
    CGFloat frameDisplacementLeft = 0;
    CGFloat leftPadding = self.center.x - mapView.scrollView.bounds.origin.x;
    CGFloat pinToMapCenterDistance = - (mapViewWidth / 2 - leftPadding);

    if (ABS(pinToMapCenterDistance) > (totalWidth - kAnchorWidth) / 2 - kCapWidth) {
        frameDisplacementLeft = copysignf(1, pinToMapCenterDistance) * ((totalWidth - kAnchorWidth) / 2 - kCapWidth - ABS(pinToMapCenterDistance));
    }

    CGFloat leftOriginX = rintf(mapView.scrollView.bounds.origin.x + (mapView.scrollView.bounds.size.width - totalWidth) / 2 - frameDisplacementLeft);
    leftCapView.frame = CGRectMake(0, 0, rintf(self.center.x - leftOriginX - kAnchorWidth / 2), kCapHeight);
    centerView.frame = CGRectMake(leftCapView.frame.size.width, 0, kAnchorWidth, kCalloutHeight);
    rightCapView.frame = CGRectMake(leftCapView.frame.size.width + kAnchorWidth, 0, totalWidth - leftCapView.frame.size.width - kAnchorWidth, kCapHeight);

    self.layer.anchorPoint = CGPointMake((self.center.x - leftOriginX) / totalWidth, 1);
    self.frame = CGRectMake(leftOriginX,
                            self.center.y - kCalloutHeight / 2,
                            totalWidth,
                            kCalloutHeight);
}

- (void)scrollMapViewIfNeeded
{
//    NSLog(@"-[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    OMKMapView *mapView = [self mapView];

    CGFloat xOffsetDelta = 0;
    CGFloat yOffsetDelta = 0;
    const CGFloat xNeededPadding = rintf(kCapWidth + kAnchorWidth / 2) + 1;
    const CGFloat topNeededPadding = kCalloutHeight;
    const CGFloat bottomNeededPadding = CGRectGetMinY(mapView.scrollView.bounds) + 10;

    CGFloat leftPadding = self.center.x - mapView.scrollView.bounds.origin.x - [mapView topViewInsets].left;
    CGFloat rightPadding = mapView.scrollView.bounds.origin.x + mapView.scrollView.bounds.size.width - self.center.x - [mapView topViewInsets].right;
    CGFloat topPadding = self.center.y - mapView.scrollView.bounds.origin.y - [mapView topViewInsets].top;
    CGFloat bottomPadding = self.center.y - mapView.scrollView.bounds.origin.y - [mapView topViewInsets].top;

    if (leftPadding < xNeededPadding) {
        xOffsetDelta = leftPadding - xNeededPadding;
    }
    else if (rightPadding < xNeededPadding) {
        xOffsetDelta = xNeededPadding - rightPadding;
    }

    if (topPadding < topNeededPadding) {
        yOffsetDelta = topPadding - topNeededPadding;
    }

    if (bottomPadding < bottomNeededPadding) {
        yOffsetDelta = bottomNeededPadding - bottomPadding;
    }

    [UIView animateWithDuration:0.175 animations:^{
        mapView.scrollView.bounds = CGRectMake(mapView.scrollView.bounds.origin.x + xOffsetDelta, mapView.scrollView.bounds.origin.y + yOffsetDelta, mapView.scrollView.bounds.size.width, mapView.scrollView.bounds.size.height);
    }];
}

@end
