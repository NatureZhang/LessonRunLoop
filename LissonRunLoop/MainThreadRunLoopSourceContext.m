//
//  MainThreadRunLoopSourceContext.m
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/18.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import "MainThreadRunLoopSourceContext.h"
#import "MainThreadRunLoopSource.h"

@interface MainThreadRunLoopSourceContext ()



@end

@implementation MainThreadRunLoopSourceContext

- (instancetype)initWithRunLoopRef:(CFRunLoopRef)runLoop runLoopSource:(MainThreadRunLoopSource *)runloopSource
{
    self = [super init];
    if (self) {
        self.runloop = runLoop;
        self.runloopSource = runloopSource;
    }
    return self;
}

@end
