//
//  SecondaryThreadRunLoopSource.m
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/18.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import "SecondaryThreadRunLoopSource.h"
#import "SecondaryThreadRunLoopSourceContext.h"
#import "AppDelegate.h"
@interface SecondaryThreadRunLoopSource ()

@end

@implementation SecondaryThreadRunLoopSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        CFRunLoopSourceContext contex = {
            0,
            (__bridge void *)self,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            &runloopSourceScheduleRoutineSecond,
            &runloopSourceCancelRoutineSecond,
            &runloopSourcePerformRoutineSecond};
        
        _runloopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &contex);
        
        _commandBuffer = [NSMutableArray array];
        
    }
    return self;
}
- (void)addToCurrentRunLoop {
    CFRunLoopRef cfrunloop = CFRunLoopGetCurrent();
    
    CFRunLoopSourceRef rls = _runloopSource;
    if (rls) {
        CFRunLoopAddSource(cfrunloop, rls, kCFRunLoopDefaultMode);
    }
    
}

- (void)signalSourceAndWakeUpRunloop:(CFRunLoopRef)runloop {
    CFRunLoopSourceSignal(_runloopSource);
    CFRunLoopWakeUp(runloop);
}


// 当把当前的runloop source添加到runloop中时，会回调这个方法，主线程管理该input source，
// 所以使用performSelectorOnMainThread 通知主线程。主线程和当前线程的通信使用CFRunLoopSourceContext来完成
void runloopSourceScheduleRoutineSecond(void *info, CFRunLoopRef runLoopRef, CFStringRef mode) {
    
    SecondaryThreadRunLoopSource *secondThreadRunLoopSources = (__bridge SecondaryThreadRunLoopSource *)info;
    
    SecondaryThreadRunLoopSourceContext *secondThreadRunLoopSourcesContext = [[SecondaryThreadRunLoopSourceContext alloc] initWithRunLoopRef:runLoopRef runLoopSource:secondThreadRunLoopSources];
    
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    
    [appdelegate performSelector:@selector(registerSecondaryThreadRunLoopSource:) withObject:secondThreadRunLoopSourcesContext];
}

/// 如果使用CFRunLoopSourceInvalidate函数把输入源从Runloop里面移除的话，系统会调用该方法。
void runloopSourceCancelRoutineSecond(void *info, CFRunLoopRef runLoopRef, CFStringRef mode) {
//    SecondaryThreadRunLoopSource *secondThreadRunLoopSources = (__bridge SecondaryThreadRunLoopSource *)info;
    
//    SecondaryThreadRunLoopSourceContext *secondThreadRunLoopSourcesContext = [[SecondaryThreadRunLoopSourceContext alloc] initWithRunLoopRef:runLoopRef runLoopSource:secondThreadRunLoopSources];
//    
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    
    [appdelegate performSelector:@selector(removeSecondaryThreadRunloopSourceContext)];
}

/// 当前input source 被告知需要处理事件的回调方法
void runloopSourcePerformRoutineSecond(void *info) {
    
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    
    [appdelegate performSelector:@selector(performSecondaryThreadRunLoopSourceTask)];
}

@end
