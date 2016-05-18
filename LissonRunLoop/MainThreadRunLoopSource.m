//
//  MainThreadRunLoopSource.m
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/18.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import "MainThreadRunLoopSource.h"
#import "MainThreadRunLoopSourceContext.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface MainThreadRunLoopSource ()

@end

/*
 
 typedef struct {
 
 CFIndex	version;
 void *	info;
 const void *(*retain)(const void *info);
 void	(*release)(const void *info);
 CFStringRef	(*copyDescription)(const void *info);
 Boolean	(*equal)(const void *info1, const void *info2);
 CFHashCode	(*hash)(const void *info);
 void	(*schedule)(void *info, CFRunLoopRef rl, CFStringRef mode);
 void	(*cancel)(void *info, CFRunLoopRef rl, CFStringRef mode);
 void	(*perform)(void *info);
 
 } CFRunLoopSourceContext;

 
 */

@implementation MainThreadRunLoopSource
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
            &runloopSourceScheduleRoutine,
            &runloopSourceCancelRoutine,
            &runloopSourcePerformRoutine};
        
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
void runloopSourceScheduleRoutine(void *info, CFRunLoopRef runLoopRef, CFStringRef mode) {
    
    MainThreadRunLoopSource *mainThreadRunLoopSources = (__bridge MainThreadRunLoopSource *)info;

    MainThreadRunLoopSourceContext *mainThreadRunLoopSourcesContext = [[MainThreadRunLoopSourceContext alloc] initWithRunLoopRef:runLoopRef runLoopSource:mainThreadRunLoopSources];
    
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;

    [appdelegate performSelector:@selector(registerMainThreadRunLoopSource:) withObject:mainThreadRunLoopSourcesContext];
}

/// 如果使用CFRunLoopSourceInvalidate函数把输入源从Runloop里面移除的话，系统会调用该方法。
void runloopSourceCancelRoutine(void *info, CFRunLoopRef runLoopRef, CFStringRef mode) {
    MainThreadRunLoopSource *mainThreadRunLoopSources = (__bridge MainThreadRunLoopSource *)info;
    
    MainThreadRunLoopSourceContext *mainThreadRunLoopSourcesContext = [[MainThreadRunLoopSourceContext alloc] initWithRunLoopRef:runLoopRef runLoopSource:mainThreadRunLoopSources];
    
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    
    [appdelegate performSelector:@selector(performMainThreadRunLoopSourceTask)];
}

/// 当前input source 被告知需要处理事件的回调方法
void runloopSourcePerformRoutine(void *info) {
    
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    
    [appdelegate performSelector:@selector(performMainThreadRunLoopSourceTask)];
}
@end
