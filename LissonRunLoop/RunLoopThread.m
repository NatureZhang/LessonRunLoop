//
//  TestThread.m
//  LissonRunLoop
//
//  Created by zhangdong on 16/5/17.
//  Copyright © 2016年 zhangdong. All rights reserved.
//

#import "RunLoopThread.h"

@implementation RunLoopThread

- (void)launch {
    NSLog(@"First event in Main Thread.");
    
    [NSThread detachNewThreadSelector:@selector(createAndConfigObserverInSecondaryThread) toTarget:self withObject:nil];
    
    NSLog(@"%d", [NSThread isMultiThreaded]);
    
    sleep(3);
    
    NSLog(@"Second event in Main Thread.");
}

- (void)createAndConfigObserverInSecondaryThread {
    @autoreleasepool {
        NSRunLoop *myRunloop = [NSRunLoop currentRunLoop];
        
        RunLoopThread *aSelf = self;
        
        /*
         typedef struct {
         CFIndex	version;
         void *	info;
         const void *(*retain)(const void *info);
         void	(*release)(const void *info);
         CFStringRef	(*copyDescription)(const void *info);
         } CFRunLoopObserverContext;
         
         1 verson:结构体版本号，必须设置为0
         2 info: 上下文中 retain release copyDescription 三个回调函数以及runloop观察者的回调函数所有者对象的指针
         */
        
        CFRunLoopObserverContext context = {0, &aSelf, nil, nil, nil};

        // 1 创建观察者
        //  第一个参数：分配空间
        //  第二个参数：要监听的状态
        //  第三个参数：YES持续监听 NO 只监听一次
        //  第四个参数：观察者优先级，当runloop中有多个观察者监听同一个运行状态时，根据该优先级判断，0为最高级别
        //  第五个参数：观察者的回调函数 函数指针 当发现runloop状态改变的时候会调用该方法
        //  第六个参数：观察者上下文环境
        CFRunLoopObserverRef observerRef = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &myRunLoopObserver, &context);
        
        if (observerRef) {
            
            // 将NSRunLoop类型转换成 CFRunLoopRef类型
            CFRunLoopRef cfloop = [myRunloop getCFRunLoop];
            
            // 添加observe到runloop中
            // 第一个参数：runloop对象
            // 第二个参数：观察者对象
            // 第三个参数：运行模式（要监听那种模式下状态的改变）
            // ps: 一个观察者只能被添加到一个runloop中，但可以被添加到runloop中的多个模式中
            CFRunLoopAddObserver(cfloop, observerRef, kCFRunLoopDefaultMode);
        }
        
        // 创建定时器，驱动runloop循环，每0.1秒触发 如果没有事件源，runloop会马上退出
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doFireTimer:) userInfo:nil repeats:YES];
        
        NSInteger loopCount = 5;
        
        while (loopCount) {
            // 启动runloop开始循环，直到指定的时间才结束
            // 当调用runUnitDate方法时，观察者检测到循环已经启动，开始根据你循环的各个阶段的事件，调用回调函数
            [myRunloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            // 执行完之后，会再一次调用回调函数，状态是KCFRunLoopExit，表示结束
            
            loopCount--;
        }
        
        NSLog(@"The End");
    }
}

// Run loop观察者的回调函数：
void myRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"run loop entry");
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"run loop before timers");
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"run loop before sources");
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"run loop before waiting");
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"run loop after waiting");
            break;
        case kCFRunLoopExit:
            NSLog(@"run loop exit");
            break;
        default:
            break;
    }
}

- (void)doFireTimer:(NSTimer *)timer {
    NSLog(@"Fire timer");
}
@end
