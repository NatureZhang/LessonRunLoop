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
#import "RunLoopDelegate.h"
@interface MainThreadRunLoopSource ()

@end

/*
 
 typedef struct {
 
 // 事件源上下文的版本，必须设置为0
 CFIndex	version;
 
 // 上下文中 retain release copyDescription equal hash schedule cancel perform这八个回调函数所有者对象的指针
 void *	info;
 
 const void *(*retain)(const void *info);
 void	(*release)(const void *info);
 CFStringRef	(*copyDescription)(const void *info);
 Boolean	(*equal)(const void *info1, const void *info2);
 CFHashCode	(*hash)(const void *info);
 
 // 该回调函数的作用是将该事件源与给他发送事件消息的线程进行关联，也就是说如果主线程想要给该事件源发送事件消息，那么首先主线程得能获取到该事件源
 void	(*schedule)(void *info, CFRunLoopRef rl, CFStringRef mode);
 
 // 该回调函数的作用是使该事件源失效
 void	(*cancel)(void *info, CFRunLoopRef rl, CFStringRef mode);

 // 该回调函数的作用是执行其他线程或当前线程给该事件源发来的事件消息
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
        
        /*
         1 该参数为对象内存分配器
         2 事件源优先级
         3 事件源上下文
         */
        _runloopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &contex);
        
        _commandBuffer = [NSMutableArray array];
    }
    return self;
}

/*
 
 1 希望添加事件源的runloop对象，类型是CFRunLoop
 2 我们创建好的事件源
 3 runloop的模式
 CFRunLoopAddSource(CFRunLoopRef rl, CFRunLoopSourceRef source, CFStringRef mode)
 
 */
- (void)addToCurrentRunLoop {
    CFRunLoopRef cfrunloop = CFRunLoopGetCurrent();
    
    CFRunLoopSourceRef rls = _runloopSource;
    if (rls) {
        CFRunLoopAddSource(cfrunloop, rls, kCFRunLoopDefaultMode);
    }
    
}

- (void)stopCurrentRunLoop {
    CFRunLoopRef cfRunLoop = CFRunLoopGetCurrent();
    
    CFRunLoopStop(cfRunLoop);
    
    CFRunLoopSourceRef rls = _runloopSource;
    if (rls) {
        CFRunLoopRemoveSource(cfRunLoop, rls, kCFRunLoopDefaultMode);
    }

}

/*
 source0 类型，也就是非port类型的事件源都需要进行手动标记，标记完还需要手动唤醒runloop
 注意：唤醒runloop并不等价于启动runloop，因为启动runloop时需要对runloop进行模式、时限的设置，而唤醒runloop只是当已启动的runloop休眠时重新让其运行
 */
- (void)signalSourceAndWakeUpRunloop:(CFRunLoopRef)runloop {
    CFRunLoopSourceSignal(_runloopSource);
    CFRunLoopWakeUp(runloop);
}

// 当把当前的runloop source添加到runloop中时，会回调这个方法，主线程管理该input source，
// 所以使用performSelectorOnMainThread 通知主线程。主线程和当前线程的通信使用CFRunLoopSourceContext来完成
void runloopSourceScheduleRoutine(void *info, CFRunLoopRef runLoopRef, CFStringRef mode) {
    
    MainThreadRunLoopSource *mainThreadRunLoopSources = (__bridge MainThreadRunLoopSource *)info;

    MainThreadRunLoopSourceContext *mainThreadRunLoopSourcesContext = [[MainThreadRunLoopSourceContext alloc] initWithRunLoopRef:runLoopRef runLoopSource:mainThreadRunLoopSources];
    
    [[RunLoopDelegate shareDelegate] registerMainThreadRunLoopSource:mainThreadRunLoopSourcesContext];
}

/// 如果使用CFRunLoopSourceInvalidate函数把输入源从Runloop里面移除的话，系统会调用该方法。
void runloopSourceCancelRoutine(void *info, CFRunLoopRef runLoopRef, CFStringRef mode) {

    [[RunLoopDelegate shareDelegate] performMainThreadRunLoopSourceCancelTask];
}

/// 当前input source 被告知需要处理事件的回调方法
void runloopSourcePerformRoutine(void *info) {
    
    [[RunLoopDelegate shareDelegate] performMainThreadRunLoopSourceTask];

}
@end
