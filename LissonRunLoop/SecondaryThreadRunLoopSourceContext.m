//
//  SecondaryThreadRunLoopSourceContext.m
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/18.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import "SecondaryThreadRunLoopSourceContext.h"
#import "SecondaryThreadRunLoopSource.h"

@interface SecondaryThreadRunLoopSourceContext ()

@end

@implementation SecondaryThreadRunLoopSourceContext
- (instancetype)initWithRunLoopRef:(CFRunLoopRef)runLoop runLoopSource:(SecondaryThreadRunLoopSource *)runloopSource
{
    self = [super init];
    if (self) {
        self.runloop = runLoop;
        self.runloopSource = runloopSource;
    }
    return self;
}
@end
