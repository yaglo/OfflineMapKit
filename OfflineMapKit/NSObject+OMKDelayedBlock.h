//
//  NSObject+OMKDelayedBlock.h
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (OMKDelayedBlock)

- (void)omk_performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
- (void)omk_fireBlockAfterDelay:(void (^)(void))block;

@end
