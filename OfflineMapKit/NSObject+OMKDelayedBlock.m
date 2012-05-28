//
//  NSObject+OMKDelayedBlock.m
//  OfflineMapKit
//
//  Copyright (c) 2012 Stanislav Yaglo. All rights reserved.
//

#import "NSObject+OMKDelayedBlock.h"

@implementation NSObject (OMKDelayedBlock)

- (void)omk_performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay 
{
    block = [block copy];
    [self performSelector:@selector(omk_fireBlockAfterDelay:) withObject:block afterDelay:delay];
}

- (void)omk_fireBlockAfterDelay:(void (^)(void))block
{
    block();
}

@end
