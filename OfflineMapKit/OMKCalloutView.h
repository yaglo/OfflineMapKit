//
//  OMKCalloutView.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMKCalloutView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) UIControl *rightCalloutAccessoryView;

- (void)getAnchorPoint:(CGPoint *)anchorPoint
                 frame:(CGRect *)frame
  forTargetAnchorPoint:(CGPoint *)targetAnchorPoint
                bounds:(CGRect *)bounds;

@end
