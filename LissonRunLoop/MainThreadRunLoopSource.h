//
//  MainThreadRunLoopSource.h
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/18.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainThreadRunLoopSource : NSObject
{
    CFRunLoopSourceRef _runloopSource;
    CFRunLoopSourceContext _runloopSourceContext;
}

@property (nonatomic, strong) NSMutableArray *commandBuffer;
- (void)signalSourceAndWakeUpRunloop:(CFRunLoopRef)runloop;
- (void)addToCurrentRunLoop;
@end
