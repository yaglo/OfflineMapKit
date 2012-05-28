//
//  OMKOverlayContainerView.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OMKScrollView.h"

@interface OMKOverlayContainerView : UIView

@property (nonatomic, unsafe_unretained) OMKScrollView *scrollView;

@end
