//
//  SYCalloutView.m
//  Callout UI component
//
//  Created by Stanislav Yaglo on 6/18/12.
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//
//
//                                          bottomAnchorView
//     leftCapView   leftBackgroundView            ^            rightBackgroundView   rightCapView
//   /-------------+--------------------+---------/ \---------+---------------------+--------------\
//   |  +------+                                                                        +-------+  |
//   |  | left |     title                                                              | right |  |
//   |  | view |     subtitle                                                           | view  |  |
//   |  +------+                                                                        +-------+  |
//   \-------------+--------------------+---------\ /---------+---------------------+--------------/
//                                                 v
//                                           topAnchorView

#import <QuartzCore/QuartzCore.h>

#import "SYCalloutView.h"

@interface SYCalloutView ()

+ (UIImage *)backgroundImage;
+ (UIImage *)leftCapImage;
+ (UIImage *)rightCapImage;
+ (UIImage *)topAnchorImage;
+ (UIImage *)bottomAnchorImage;

+ (CGFloat)defaultHeight;
+ (CGFloat)anchorHeight;
+ (CGFloat)minimumWidth;
+ (CGFloat)capHeight;

+ (CGFloat)titleHeight;
+ (CGFloat)subtitleHeight;
+ (CGPoint)titleOffset;
+ (CGPoint)titleOffsetWithEmptySubtitle;
+ (CGPoint)subtitleOffset;

+ (CGFloat)horizontalPadding;
+ (CGFloat)horizontalMargin;
+ (CGFloat)topPadding;
+ (CGFloat)buttonPadding;
+ (CGFloat)textMargin;

- (void)setOriginForScale:(float)scale;
- (void)getRealAnchorPoint:(CGPoint *)realAnchorPoint frame:(CGRect *)frame forAnchorPoint:(CGPoint)anAnchorPoint bounds:(CGRect)bounds textWidth:(CGFloat *)tw;

- (CGRect)frameForLeftView:(UIView *)view;
- (CGRect)frameForRightView:(UIView *)view;

@end

@implementation SYCalloutView
{
    UIImageView *leftCapView, *rightCapView, *topAnchorView, *bottomAnchorView;
    UIImageView *leftBackgroundView, *rightBackgroundView;
    UILabel *titleLabel, *subtitleLabel;

    CGRect actualFrame;

    NSMutableArray *pendingAnimations;
}

@synthesize animatingFrame;

@synthesize offset;
@synthesize anchorPoint;
@synthesize boundaryRect;

@synthesize leftView;
@synthesize rightView;

@synthesize titleLineBreakMode, subtitleLineBreakMode;

@synthesize delegate;

@synthesize canAnchorFromBottom;

+ (SYCalloutView *)sharedCalloutView
{
    static SYCalloutView *shared = nil;
    if (!shared) {
        shared = [[self alloc] initWithFrame:CGRectZero];
    }
    return shared;
}

- (id)initWithFrame:(CGRect)frame
{
    frame.size.height = [SYCalloutView defaultHeight];

    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.delegate = self;
        self.opaque = NO;

        self.canAnchorFromBottom = YES;
        pendingAnimations = [[NSMutableArray alloc] init];

        leftCapView = [[UIImageView alloc] initWithImage:[SYCalloutView leftCapImage]];
//        leftCapView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        leftCapView.opaque = NO;
        leftCapView.userInteractionEnabled = NO;
        [self addSubview:leftCapView];

        rightCapView = [[UIImageView alloc] initWithImage:[SYCalloutView rightCapImage]];
//        rightCapView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        rightCapView.opaque = NO;
        rightCapView.userInteractionEnabled = NO;
        [self addSubview:rightCapView];

        topAnchorView = [[UIImageView alloc] initWithImage:[SYCalloutView topAnchorImage]];
//        topAnchorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        topAnchorView.opaque = NO;
        topAnchorView.userInteractionEnabled = NO;
        [self addSubview:topAnchorView];

        bottomAnchorView = [[UIImageView alloc] initWithImage:[SYCalloutView bottomAnchorImage]];
//        bottomAnchorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        bottomAnchorView.opaque = NO;
        bottomAnchorView.userInteractionEnabled = NO;
        [self addSubview:bottomAnchorView];

        leftBackgroundView = [[UIImageView alloc] initWithImage:[SYCalloutView backgroundImage]];
//        leftBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        leftBackgroundView.opaque = NO;
        leftBackgroundView.userInteractionEnabled = NO;
        [self addSubview:leftBackgroundView];

        rightBackgroundView = [[UIImageView alloc] initWithImage:[SYCalloutView backgroundImage]];
//        rightBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        rightBackgroundView.opaque = NO;
        rightBackgroundView.userInteractionEnabled = NO;
        [self addSubview:rightBackgroundView];

        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.clipsToBounds = YES;
        titleLabel.opaque = NO;
        titleLabel.userInteractionEnabled = NO;

        // Font
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        titleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        titleLabel.shadowOffset = CGSizeMake(0, -1);
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];

        subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.clipsToBounds = YES;
        subtitleLabel.opaque = NO;
        subtitleLabel.userInteractionEnabled = NO;

        subtitleLabel.font = [UIFont systemFontOfSize:12];
        subtitleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        subtitleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        subtitleLabel.shadowOffset = CGSizeMake(0, -1);
        subtitleLabel.textColor = [UIColor whiteColor];
        [self addSubview:subtitleLabel];
    }
    return self;
}

- (NSString *)title
{
    return titleLabel.text;
}

- (void)setTitle:(NSString *)title
{
    [self setTitle:title animated:NO];
}

- (void)setTitle:(NSString *)title animated:(BOOL)animated
{
    if ([title isEqualToString:titleLabel.text])
        return;

    if (animated) {
        titleLabel.alpha = 0;
        titleLabel.text = title;

        [UIView animateWithDuration:.14 animations:^{
            [self sizeToFit];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.175 animations:^{
                titleLabel.alpha = 1;
            }];
        }];
    }
    else {
        titleLabel.text = title;
        [self sizeToFit];
    }
}

- (NSString *)subtitle
{
    return subtitleLabel.text;
}

- (void)setSubtitle:(NSString *)subtitle
{
    [self setSubtitle:subtitle animated:NO];
}

- (void)setSubtitle:(NSString *)subtitle animated:(BOOL)animated
{
    if ([subtitle isEqualToString:subtitleLabel.text])
        return;

    if (animated) {
        subtitleLabel.alpha = 0;
        subtitleLabel.text = subtitle;

        void (^animation)() = ^{
            [UIView animateWithDuration:.14 animations:^{
                [self sizeToFit];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.175 animations:^{
                    subtitleLabel.alpha = 1;
                } completion:^(BOOL finished) {
                    [self animationDidStop:nil finished:finished];
                }];
            }];
        };

        if ([self.layer.animationKeys count] > 0) {
            [pendingAnimations addObject:animation];
        }
        else {
            animation();
        }
    }
    else {
        subtitleLabel.text = subtitle;
        [self sizeToFit];
    }
}

- (CGRect)frameForLeftView:(UIView *)view
{
    CGRect frame = view.frame;
    frame.origin.x = [SYCalloutView horizontalMargin] + [SYCalloutView horizontalPadding] + [SYCalloutView buttonPadding];
    frame.origin.y = floorf([SYCalloutView capHeight] / 2) + [SYCalloutView topPadding] - floorf(CGRectGetHeight(frame) / 2);
    return frame;
}

- (CGRect)frameForRightView:(UIView *)view
{
    CGRect frame = view.frame;
    frame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(view.frame) - ([SYCalloutView horizontalMargin] + [SYCalloutView horizontalPadding] + [SYCalloutView buttonPadding]);
    frame.origin.y = floorf([SYCalloutView capHeight] / 2) + [SYCalloutView topPadding] - floorf(CGRectGetHeight(frame) / 2);
    return frame;
}

- (void)setLeftView:(UIView *)newLeftView
{
    [leftView removeFromSuperview];
    leftView = newLeftView;

    if (newLeftView) {
        if ([leftView isKindOfClass:[UIControl class]]) {
            UIControl *control = (id)leftView;
            [control addTarget:self action:@selector(handleAccessoryTap:) forControlEvents:UIControlEventTouchUpInside];
        }

        [self addSubview:leftView];
    }

    [self sizeToFit];
}

- (void)setLeftView:(UIView *)newLeftView animated:(BOOL)animated
{
    if (leftView == newLeftView)
        return;

    if (animated) {
        if (newLeftView) {
            void (^animation)() = ^{
                newLeftView.alpha = 0;
                newLeftView.frame = [self frameForLeftView:newLeftView];

                [UIView animateWithDuration:.14 animations:^{
                    [self setLeftView:newLeftView];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:.14 animations:^{
                        newLeftView.alpha = 1;
                    } completion:^(BOOL finished) {
                        [self animationDidStop:nil finished:finished];
                    }];
                }];
            };

            if ([self.layer.animationKeys count] > 0) {
                [pendingAnimations addObject:animation];
            }
            else {
                animation();
            }
        }
        else {
            [UIView animateWithDuration:.175 animations:^{
                leftView.alpha = 0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.175 animations:^{
                    [self setLeftView:nil];
                }];
            }];
        }
    }
    else {
        [self setLeftView:newLeftView];
    }
}

- (void)setRightView:(UIView *)newRightView
{
    [rightView removeFromSuperview];
    rightView = newRightView;

    if (newRightView) {
        if ([rightView isKindOfClass:[UIControl class]]) {
            UIControl *control = (id)rightView;
            [control addTarget:self action:@selector(handleAccessoryTap:) forControlEvents:UIControlEventTouchUpInside];
        }

        [self addSubview:rightView];
    }

    [self sizeToFit];
}

- (void)setRightView:(UIView *)newRightView animated:(BOOL)animated
{
    if (rightView == newRightView)
        return;

    if (animated) {
        if (newRightView) {
            void (^animation)() = ^{
                newRightView.alpha = 0;
                newRightView.frame = [self frameForRightView:newRightView];
                
                [UIView animateWithDuration:.14 animations:^{
                    [self setRightView:newRightView];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:.14 animations:^{
                        newRightView.alpha = 1;
                    } completion:^(BOOL finished) {
                        [self animationDidStop:nil finished:finished];
                    }];
                }];
            };

            if ([self.layer.animationKeys count] > 0) {
                [pendingAnimations addObject:animation];
            }
            else {
                animation();
            }
        }
        else {
            [UIView animateWithDuration:.175 animations:^{
                rightView.alpha = 0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.175 animations:^{
                    [self setRightView:nil];
                }];
            }];
        }
    }
    else {
        [self setRightView:newRightView];
    }
}

- (void)setAnchorPoint:(CGPoint)point boundaryRect:(CGRect)rect animated:(BOOL)animated
{
    anchorPoint = point;
    boundaryRect = rect;

    if (animated) {
        self.hidden = NO;
        [self sizeToFit];

        self.transform = CGAffineTransformMakeScale(.1, .1);
        [self setOriginForScale:.1];

        self.animatingFrame = YES;
        [UIView animateWithDuration:.13 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            self.transform = CGAffineTransformMakeScale(1.1, 1.1);
            [self setOriginForScale:1.1];
        } completion:^(BOOL finished){
            [UIView animateWithDuration:.09 animations:^{
                self.transform = CGAffineTransformMakeScale(.95, .95);
                [self setOriginForScale:.95];
            } completion:^(BOOL finished){
                [UIView animateWithDuration:.075 animations:^{
                    self.transform = CGAffineTransformIdentity;
                    [self setOriginForScale:1];
                } completion:^(BOOL finished) {
                    self.animatingFrame = NO;
                    [self animationDidStop:nil finished:finished];
                }];
            }];
        }];
    }
    else {
        self.hidden = NO;
        self.alpha = 1;
        [self sizeToFit];
    }
}

- (void)setAnchorPoint:(CGPoint)newAnchorPoint
{
    CGFloat acp = (anchorPoint.x + offset.x - actualFrame.origin.x) / actualFrame.size.width; // 0..1

    anchorPoint = CGPointMake(newAnchorPoint.x - offset.x, newAnchorPoint.y - offset.y);

    CGRect frame = self.frame;
    frame.origin.x = anchorPoint.x - CGRectGetWidth(actualFrame) * acp;
    frame.origin.y = anchorPoint.y - [SYCalloutView defaultHeight];
    self.frame = actualFrame = frame;
}

- (void)sizeToFit
{
    CGRect frame;
    CGFloat textWidth;
    CGPoint realAnchorPoint;

    // Getting real sizes for placement
    [self getRealAnchorPoint:&realAnchorPoint frame:&frame forAnchorPoint:anchorPoint bounds:boundaryRect textWidth:&textWidth];

    // We don't need to keep offsets in our ivar anchorPoint
    anchorPoint = CGPointMake(realAnchorPoint.x - offset.x, realAnchorPoint.y - offset.y);

    self.frame = actualFrame = frame;

    [self layoutSubviewsWithAnchorPoint:realAnchorPoint textWidth:textWidth];
}

- (void)layoutSubviewsWithAnchorPoint:(CGPoint)anAnchorPoint textWidth:(CGFloat)textWidth
{
    // Aligning right cap, the left cap is always at { 0, 0 }
    rightCapView.frame = CGRectMake(CGRectGetMaxX(self.bounds) - CGRectGetWidth(rightCapView.bounds), 0,
                                    CGRectGetWidth(rightCapView.bounds), CGRectGetHeight(rightCapView.bounds));


    // Anchor views
    CGSize anchorSize = bottomAnchorView.image.size;
    CGFloat anchorDisplacement = rintf(anAnchorPoint.x - CGRectGetMinX(self.frame) - anchorSize.width / 2);
    topAnchorView.frame = CGRectMake(anchorDisplacement, 0, anchorSize.width, anchorSize.height);
    bottomAnchorView.frame = CGRectMake(anchorDisplacement, 0, anchorSize.width, anchorSize.height);


    // Backgrounds
    leftBackgroundView.frame = CGRectMake(CGRectGetMaxX(leftCapView.frame), 0,
                                          CGRectGetMinX(bottomAnchorView.frame) - CGRectGetMaxX(leftCapView.frame),
                                          CGRectGetHeight(leftBackgroundView.bounds));

    rightBackgroundView.frame = CGRectMake(CGRectGetMaxX(bottomAnchorView.frame), 0,
                                           CGRectGetMinX(rightCapView.frame) - CGRectGetMaxX(bottomAnchorView.frame),
                                           CGRectGetHeight(rightBackgroundView.bounds));

    // Aligning controls
    leftView.frame = [self frameForLeftView:leftView];
    rightView.frame = [self frameForRightView:rightView];


    // Aligning labels
    CGPoint titleOffset = [SYCalloutView titleOffset];
    CGFloat textMargin = leftView ? CGRectGetWidth(leftView.frame) + [SYCalloutView textMargin] + [SYCalloutView buttonPadding] : 0;
    
    if ([subtitleLabel.text length] == 0) {
        titleOffset = [SYCalloutView titleOffsetWithEmptySubtitle];
        subtitleLabel.frame = CGRectZero;
    }
    else {
        CGPoint subtitleOffset = [SYCalloutView subtitleOffset];
        subtitleLabel.frame = CGRectMake(subtitleOffset.x + textMargin, subtitleOffset.y,
                                         textWidth, [SYCalloutView subtitleHeight]);
    }

    titleLabel.frame = CGRectMake(titleOffset.x + textMargin, titleOffset.y,
                                  textWidth, [SYCalloutView titleHeight]);
}

- (void)setOriginForScale:(float)scale
{
    CGFloat acp = (anchorPoint.x + offset.x - actualFrame.origin.x) / actualFrame.size.width; // 0..1
    CGRect frame = self.frame;
    frame.origin.x = CGRectGetMinX(actualFrame) + acp * CGRectGetWidth(actualFrame) - (acp * CGRectGetWidth(actualFrame) * scale);
    frame.origin.y = CGRectGetMaxY(actualFrame) - (CGRectGetHeight(actualFrame) - [SYCalloutView anchorHeight]) * scale - [SYCalloutView anchorHeight];
    self.frame = frame;
}

- (void)getRealAnchorPoint:(CGPoint *)realAnchorPoint frame:(CGRect *)frame forAnchorPoint:(CGPoint)anAnchorPoint bounds:(CGRect)bounds textWidth:(CGFloat *)tw
{
    CGFloat capWidth = [SYCalloutView horizontalMargin] + [SYCalloutView horizontalPadding];
    CGFloat buttonAndTextMargin = [SYCalloutView buttonPadding] + [SYCalloutView textMargin];
    CGFloat minWidth_2 = roundf([SYCalloutView minimumWidth] / 2);


    // We're calculating real anchor point, so we must take offset into account
    anAnchorPoint.x += offset.x;
    anAnchorPoint.y += offset.y;


    // Calculating needed size first
    CGFloat maxContentWidth = CGRectGetWidth(bounds) - 2 * capWidth;

    if (leftView)
        maxContentWidth -= CGRectGetWidth(leftView.frame) + buttonAndTextMargin;

    if (rightView)
        maxContentWidth -= CGRectGetWidth(rightView.frame) + buttonAndTextMargin;

    CGSize titleSize = [titleLabel.text sizeWithFont:titleLabel.font];
    CGSize subtitleSize = [subtitleLabel.text sizeWithFont:subtitleLabel.font];

    CGFloat textWidth = MIN(maxContentWidth, MAX(titleSize.width, subtitleSize.width));

    CGFloat frameWidth = capWidth
        + (leftView ? CGRectGetWidth(leftView.frame) + buttonAndTextMargin : 0)
        + textWidth
        + (rightView ? CGRectGetWidth(rightView.frame) + buttonAndTextMargin : 0)
        + capWidth;

    frameWidth = MAX(frameWidth, [SYCalloutView minimumWidth]);
    frameWidth = MIN(frameWidth, CGRectGetWidth(bounds));

    // Positioning tending to the bounds center
    CGFloat frameDisplacementLeft = 0;
    CGFloat leftPadding = anAnchorPoint.x - CGRectGetMinX(bounds);
    CGFloat anchorToCenterDistance = - (CGRectGetWidth(bounds) / 2 - leftPadding);

    // If the bounds center is too far from the anchor point and the frame size is small, we need to move the frame
    // |      +-------+      |
    // |      |       |      |
    // |      +----  -+      |
    // |           \/___.    | . is our needed anchor point, ___ is frameDisplacementLeft

    if (ABS(anchorToCenterDistance) > frameWidth / 2 - minWidth_2) {
        frameDisplacementLeft = copysignf(1, anchorToCenterDistance)
                              * (frameWidth / 2 - minWidth_2 - ABS(anchorToCenterDistance));
    }


    // Calculating the origin
    CGPoint origin;
    origin.x = rintf(CGRectGetMinX(bounds) + (CGRectGetWidth(bounds) - frameWidth) / 2 - frameDisplacementLeft);

    if (origin.x < CGRectGetMinX(bounds)) {
        anAnchorPoint.x += CGRectGetMinX(bounds) - origin.x;
        origin.x = CGRectGetMinX(bounds);
    }

    if (origin.x + frameWidth > CGRectGetMaxX(bounds)) {
        anAnchorPoint.x += CGRectGetMaxX(bounds) - frameWidth - origin.x;
        origin.x = CGRectGetMaxX(bounds) - frameWidth;
    }

    origin.y = anAnchorPoint.y - [SYCalloutView defaultHeight];

    if (origin.y < CGRectGetMinY(bounds) && canAnchorFromBottom) {
        origin.y = anAnchorPoint.y;
    }


    // Setting the values
    if (realAnchorPoint != NULL)
        *realAnchorPoint = CGPointMake(anAnchorPoint.x, anAnchorPoint.y);

    if (tw != NULL)
        *tw = textWidth;

    if (frame != NULL)
        *frame = CGRectMake(origin.x, origin.y, frameWidth, [SYCalloutView defaultHeight] + [SYCalloutView anchorHeight]);
}

- (void)getRealAnchorPoint:(CGPoint *)realAnchorPoint frame:(CGRect *)frame forAnchorPoint:(CGPoint)anAnchorPoint bounds:(CGRect)bounds
{
    return [self getRealAnchorPoint:realAnchorPoint frame:frame forAnchorPoint:anAnchorPoint bounds:bounds textWidth:NULL];
}

- (void)fadeOutWithDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1;
    }];
}

- (void)handleAccessoryTap:(UIControl *)control
{
    if ([delegate respondsToSelector:@selector(accessoryControlTapped:)]) {
        [delegate accessoryControlTapped:control];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self)
        return nil;

    return view;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([pendingAnimations count] > 0) {
        void (^animation)() = [pendingAnimations objectAtIndex:0];
        [pendingAnimations removeObject:animation];
        animation();
    }
}

#pragma mark - Control Constants

+ (UIImage *)backgroundImage
{
    return [UIImage imageNamed:@"OfflineMapKit.bundle/CalloutBackground.png"];
}

+ (UIImage *)leftCapImage
{
    return [UIImage imageNamed:@"OfflineMapKit.bundle/CalloutLeftCap.png"];
}

+ (UIImage *)rightCapImage
{
    return [UIImage imageNamed:@"OfflineMapKit.bundle/CalloutRightCap.png"];
}

+ (UIImage *)topAnchorImage
{
    return [UIImage imageNamed:@"OfflineMapKit.bundle/CalloutTopAnchor.png"];
}

+ (UIImage *)bottomAnchorImage
{
    return [UIImage imageNamed:@"OfflineMapKit.bundle/CalloutBottomAnchor.png"];
}

+ (CGFloat)defaultHeight
{
    return 60;
}

+ (CGFloat)anchorHeight
{
    return 10;
}

+ (CGFloat)minimumWidth
{
    return 75;
}

+ (CGFloat)capHeight
{
    return 43;
}

+ (CGFloat)titleHeight
{
    return 22;
}

+ (CGFloat)subtitleHeight
{
    return 16;
}

+ (CGPoint)titleOffset
{
    return CGPointMake(17, 3);
}

+ (CGPoint)titleOffsetWithEmptySubtitle
{
    return CGPointMake(17, 11);
}

+ (CGPoint)subtitleOffset
{
    return CGPointMake(17, 25);
}

+ (CGFloat)horizontalPadding
{
    return 10;
}

+ (CGFloat)horizontalMargin
{
    return 7;
}

+ (CGFloat)topPadding
{
    return 2;
}

+ (CGFloat)buttonPadding
{
    return -3;
}

+ (CGFloat)textMargin
{
    return 6;
}

@end
