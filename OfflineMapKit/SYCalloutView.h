//
//  SYCalloutView.h
//  Callout UI component
//
//  Created by Stanislav Yaglo on 6/18/12.
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SYCalloutViewDelegate <NSObject>

@optional
- (void)accessoryControlTapped:(UIControl *)control;

@end

@interface SYCalloutView : UIControl

@property BOOL animatingFrame;

// Singleton if you need only one instance in your view
+ (SYCalloutView *)sharedCalloutView;

// Offset from the center of the anchor point. Negative values move the callout up and to the left
@property (nonatomic) CGPoint offset;

// It's where the \/ should be placed
// This method does not resize callout
@property (nonatomic) CGPoint anchorPoint;

// The boundary rect for placement tending to the center and size calculation
// Maximum callout size is boundaryRect.size.width
// Set it with setAnchorPoint:boundaryRect:animated:
@property (nonatomic, readonly) CGRect boundaryRect;

// Label texts
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;

// If animated is YES, a callout will resize itself first, and then place the text
- (void)setTitle:(NSString *)title animated:(BOOL)animated;
- (void)setSubtitle:(NSString *)subtitle animated:(BOOL)animated;

// Line break mode for the labels, the default is UILineBreakModeMiddleTruncation
@property(assign, nonatomic) UILineBreakMode titleLineBreakMode;
@property(assign, nonatomic) UILineBreakMode subtitleLineBreakMode;

// Left and right views. Origin of the passed view's frame is ignored
@property (strong, nonatomic) UIView *leftView;
@property (strong, nonatomic) UIView *rightView;

// If animated is YES, the callout will resize itself first, and then place the view
- (void)setLeftView:(UIView *)leftView animated:(BOOL)animated;
- (void)setRightView:(UIView *)rightView animated:(BOOL)animated;

// Returns real anchor point and frame for the desired anchor point and bounds.
// If there is not enough space at the left or the right (for the cap view and a half of the anchor image),
// it will return displaced callout so you can calculate the needed scrolling distance for your container view
- (void)getRealAnchorPoint:(CGPoint *)realAnchorPoint frame:(CGRect *)frame forAnchorPoint:(CGPoint)anchorPoint bounds:(CGRect)bounds;

// Sets anchor point and boundary rect for the callout
// If animated is YES, it will animate with the bounce animation straight away
- (void)setAnchorPoint:(CGPoint)point boundaryRect:(CGRect)rect animated:(BOOL)animated;

// Fades out a callout with the given duration
- (void)fadeOutWithDuration:(NSTimeInterval)duration;

@property (unsafe_unretained, nonatomic) id <SYCalloutViewDelegate> delegate;

// Whether the view can show itself upside-down when there is not enought space at the top
@property (nonatomic, assign) BOOL canAnchorFromBottom;

@end
